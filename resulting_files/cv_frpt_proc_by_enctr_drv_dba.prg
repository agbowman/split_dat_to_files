CREATE PROGRAM cv_frpt_proc_by_enctr_drv:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Organization" = 0.0
  WITH outdev, start_date, end_date,
  org_id
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 IF (validate(cv_log_stat_cnt)=0)
  DECLARE cv_log_stat_cnt = i4
  DECLARE cv_log_msg_cnt = i4
  DECLARE cv_debug = i2 WITH constant(4)
  DECLARE cv_info = i2 WITH constant(3)
  DECLARE cv_audit = i2 WITH constant(2)
  DECLARE cv_warning = i2 WITH constant(1)
  DECLARE cv_error = i2 WITH constant(0)
  DECLARE cv_log_levels[5] = c8
  SET cv_log_levels[1] = "ERROR  :"
  SET cv_log_levels[2] = "WARNING:"
  SET cv_log_levels[3] = "AUDIT  :"
  SET cv_log_levels[4] = "INFO   :"
  SET cv_log_levels[5] = "DEBUG  :"
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00"))
  DECLARE null_f8 = f8 WITH protect, noconstant(0.000001)
  DECLARE cv_log_error_file = i4 WITH noconstant(0)
  IF (currdbname IN ("PROV", "SOLT", "SURD"))
   SET cv_log_error_file = 1
  ENDIF
  DECLARE cv_err_msg = vc WITH noconstant(fillstring(128," "))
  DECLARE cv_log_file_name = vc WITH noconstant(build("cer_temp:CV_DEFAULT",cnvtstring(curtime2),
    ".dat"))
  DECLARE cv_log_error_string = vc WITH noconstant(fillstring(32000," "))
  DECLARE cv_log_error_string_cnt = i4
  CALL cv_log_msg(cv_info,"CV_LOG_MSG version: 002 10/16/08 AR012547")
 ENDIF
 CALL cv_log_msg(cv_info,concat("*** Entering ",curprog," at ",format(cnvtdatetime(sysdate),
    "@SHORTDATETIME")))
 IF (validate(request)=1
  AND (reqdata->loglevel >= cv_info))
  IF (cv_log_error_file=1)
   CALL echorecord(request,cv_log_file_name,1)
  ENDIF
  CALL echorecord(request)
 ENDIF
 SUBROUTINE (cv_log_stat(log_lev=i2,op_name=vc,op_stat=c1,obj_name=vc,obj_value=vc) =null)
   SET cv_log_stat_cnt = (size(reply->status_data.subeventstatus,5)+ 1)
   SET stat = alterlist(reply->status_data.subeventstatus,cv_log_stat_cnt)
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationstatus = op_stat
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectname = obj_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectvalue = obj_value
   IF ((reqdata->loglevel >= log_lev))
    CALL cv_log_msg(log_lev,build("Subevent:",nullterm(op_name),"=",nullterm(op_stat),"::",
      nullterm(obj_name),"::",obj_value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg(log_lev=i2,the_message=vc(byval)) =null)
   IF ((reqdata->loglevel >= log_lev))
    SET cv_err_msg = fillstring(128," ")
    SET cv_err_msg = concat("**",nullterm(cv_log_levels[(log_lev+ 1)]),trim(the_message)," at :",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
    CALL echo(cv_err_msg)
    IF (cv_log_error_file=1)
     SET cv_log_error_string_cnt += 1
     SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg_post(script_vrsn=vc) =null)
  IF ((reqdata->loglevel >= cv_info))
   IF (validate(reply))
    IF (cv_log_error_file=1
     AND validate(request)=1)
     CALL echorecord(request,cv_log_file_name,1)
    ENDIF
    CALL echorecord(reply)
   ENDIF
   CALL cv_log_msg(cv_info,concat("*** Leaving ",curprog," version:",script_vrsn," at ",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME")))
  ENDIF
  IF (cv_log_error_string_cnt > 0)
   CALL cv_log_msg(cv_info,concat("*** The Error Log File is: ",cv_log_file_name))
   EXECUTE cv_log_flush_message
   SET cv_log_msg_cnt = 0
  ENDIF
 END ;Subroutine
 DECLARE auditsize = i4 WITH protect, noconstant(0)
 DECLARE auditcnt = i4 WITH protect, noconstant(0)
 DECLARE auditmode = i4 WITH protect, noconstant(0)
 RECORD audit_record(
   1 qual[*]
     2 order_id = f8
 ) WITH protect
 SUBROUTINE (auditevent(event_name=vc,event_type=vc,event_string=vc) =null WITH protect)
  SET auditsize = size(audit_record->qual,5)
  IF (auditsize=1)
   EXECUTE cclaudit 0, event_name, event_type,
   "Person", "Patient", "Order",
   "View", audit_record->qual[1].order_id, event_string
  ELSE
   FOR (auditcnt = 1 TO auditsize)
    IF (auditcnt=1)
     SET auditmode = 1
    ELSEIF (auditcnt < auditsize)
     SET auditmode = 2
    ELSEIF (auditcnt=auditsize)
     SET auditmode = 3
    ENDIF
    EXECUTE cclaudit auditmode, event_name, event_type,
    "Person", "Patient", "Order",
    "View", audit_record->qual[auditcnt].order_id, event_string
   ENDFOR
  ENDIF
 END ;Subroutine
 DECLARE list_cnt = i2 WITH protect
 SET act_start_dt_tm = cnvtdatetime(cnvtdate2( $START_DATE,"DD-MMM-YYYY"),0)
 SET act_stop_dt_tm = datetimeadd(cnvtdatetime(cnvtdate2( $END_DATE,"DD-MMM-YYYY"),0),1)
 DECLARE org_sec_ind = f8 WITH protect, noconstant(0)
 DECLARE getorgsecurityind(dummy) = null WITH protect
 IF (act_start_dt_tm > act_stop_dt_tm)
  GO TO exit_script
 ENDIF
 DECLARE c_proc_status_cancelled = f8 WITH constant(uar_get_code_by("MEANING",4000341,"CANCELLED"))
 DECLARE c_proc_status_discontinued = f8 WITH constant(uar_get_code_by("MEANING",4000341,
   "DISCONTINUED"))
 IF (validate(reply_obj) != 1)
  RECORD reply_obj(
    1 plist[*]
      2 proc_catalog_disp = vc
      2 proc_encntr = vc
      2 proc_encntr_cd = f8
      2 proc_birthday = dq8
      2 proc_reg_dt_tm = dq8
      2 proc_age = c12
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply_obj->status_data.status = "F"
 SUBROUTINE getorgsecurityind(dummy)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="SECURITY"
     AND di.info_name="SEC_ORG_RELTN"
    DETAIL
     org_sec_ind = di.info_number
   ;end select
 END ;Subroutine
 CALL getorgsecurityind(0)
 SELECT
  IF (( $ORG_ID=0.0)
   AND org_sec_ind=0.0)
   FROM cv_proc c,
    encounter e,
    person p
   PLAN (c
    WHERE c.action_dt_tm >= cnvtdatetime(act_start_dt_tm)
     AND c.action_dt_tm < cnvtdatetime(act_stop_dt_tm)
     AND  NOT (c.proc_status_cd IN (c_proc_status_cancelled, c_proc_status_discontinued)))
    JOIN (e
    WHERE e.encntr_id=c.encntr_id)
    JOIN (p
    WHERE p.person_id=e.person_id)
  ELSEIF (( $ORG_ID=0.0)
   AND org_sec_ind=1.0)
   FROM cv_proc c,
    encounter e,
    person p
   PLAN (c
    WHERE c.action_dt_tm >= cnvtdatetime(act_start_dt_tm)
     AND c.action_dt_tm < cnvtdatetime(act_stop_dt_tm)
     AND  NOT (c.proc_status_cd IN (c_proc_status_cancelled, c_proc_status_discontinued)))
    JOIN (e
    WHERE e.encntr_id=c.encntr_id
     AND e.organization_id IN (
    (SELECT DISTINCT
     p.organization_id
     FROM prsnl_org_reltn p
     WHERE (p.person_id=reqinfo->updt_id))))
    JOIN (p
    WHERE p.person_id=e.person_id)
  ELSE
   FROM cv_proc c,
    encounter e,
    person p
   PLAN (c
    WHERE c.action_dt_tm >= cnvtdatetime(act_start_dt_tm)
     AND c.action_dt_tm < cnvtdatetime(act_stop_dt_tm)
     AND  NOT (c.proc_status_cd IN (c_proc_status_cancelled, c_proc_status_discontinued)))
    JOIN (e
    WHERE e.encntr_id=c.encntr_id
     AND (e.organization_id= $ORG_ID))
    JOIN (p
    WHERE p.person_id=e.person_id)
  ENDIF
  INTO "NL:"
  c_catalog_disp = uar_get_code_display(c.catalog_cd), e_encntr_type_disp = uar_get_code_display(e
   .encntr_type_cd)
  ORDER BY c_catalog_disp, e_encntr_type_disp
  HEAD REPORT
   list_cnt = 0, stat = alterlist(audit_record->qual,100)
  DETAIL
   list_cnt += 1
   IF (mod(list_cnt,10)=1)
    stat = alterlist(reply_obj->plist,(list_cnt+ 9)), stat = alterlist(audit_record->qual,(list_cnt+
     9))
   ENDIF
   reply_obj->plist[list_cnt].proc_age = cnvtage(p.birth_dt_tm,c.action_dt_tm,0), reply_obj->plist[
   list_cnt].proc_birthday = cnvtdatetime(p.birth_dt_tm), reply_obj->plist[list_cnt].proc_reg_dt_tm
    = cnvtdatetime(e.reg_dt_tm),
   reply_obj->plist[list_cnt].proc_catalog_disp = c_catalog_disp, reply_obj->plist[list_cnt].
   proc_encntr_cd = e.encntr_type_cd, reply_obj->plist[list_cnt].proc_encntr = e_encntr_type_disp,
   audit_record->qual[list_cnt].order_id = c.order_id
  FOOT REPORT
   stat = alterlist(reply_obj->plist,list_cnt), stat = alterlist(audit_record->qual,list_cnt)
  WITH nocounter
 ;end select
 SET stat = alterlist(audit_record->qual,list_cnt)
 CALL auditevent("CVWFM View Results","Viewed Admin Reports","User Viewed/Printed the admin reports")
 IF (curqual > 0)
  SET reply_obj->status_data.status = "S"
 ELSEIF (curqual=0)
  SET reply_obj->status_data.status = "Z"
 ELSE
  SET reply_obj->status_data.status = "F"
 ENDIF
 IF ((reqdata->loglevel >= cv_info))
  CALL echorecord(reply_obj)
 ENDIF
#exit_script
 CALL cv_log_msg_post("MOD 009 16/08/2019 RT050705")
END GO

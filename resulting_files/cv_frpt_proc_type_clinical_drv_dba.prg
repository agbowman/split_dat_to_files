CREATE PROGRAM cv_frpt_proc_type_clinical_drv:dba
 PROMPT
  "output to file/printer/mine" = "MINE",
  "starting date" = "CURDATE",
  "ending date" = "CURDATE",
  "Section Display" = "",
  "Field Name" = "",
  "Organization" = 0.0
  WITH outdev, start_date, end_date,
  section_text, field_text, org_id
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
 DECLARE proc_idx = i4
 DECLARE proc_cnt = i4
 DECLARE qrlstartdate = q8 WITH protect
 DECLARE qrlenddate = q8 WITH protect
 SET qrlstartdate = cnvtdatetime(cnvtdate2( $START_DATE,"DD-MMM-YYYY"),0)
 SET qrlenddate = cnvtdatetime(cnvtdate2( $END_DATE,"DD-MMM-YYYY"),235959)
 DECLARE g_parse_string1 = vc WITH noconstant(nullterm(trim( $SECTION_TEXT)))
 DECLARE g_parse_string2 = vc WITH noconstant(nullterm(trim( $FIELD_TEXT)))
 DECLARE g_parse_sep = c1 WITH noconstant(",")
 DECLARE g_parse_pos = i2 WITH noconstant(1)
 DECLARE g_flag1 = i2 WITH noconstant(1)
 DECLARE g_flag2 = i2 WITH noconstant(2)
 DECLARE g_idx1 = i4
 DECLARE g_idx2 = i4
 DECLARE ce_cnt = i4
 DECLARE org_sec_ind = f8 WITH protect, noconstant(0)
 IF (qrlstartdate > qrlenddate)
  GO TO exit_script
 ENDIF
 IF (validate(reply_obj)=0)
  RECORD reply_obj(
    1 cv_list[*]
      2 rpl_full_name = vc
      2 rpl_catalog_disp = vc
      2 rpl_descriptor = vc
      2 rpl_proc_cnt = f8
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
 IF (validate(proc_list)=0)
  RECORD proc_list(
    1 qual[*]
      2 cv_proc_id = f8
  )
 ENDIF
 IF (validate(ce_title)=0)
  RECORD ce_title(
    1 ce1_list[*]
      2 ce1_event_title_text = vc
    1 ce2_list[*]
      2 ce2_event_title_text = vc
  )
 ENDIF
 DECLARE getorgsecurityind(dummy) = null WITH protect
 CALL cv_parse_text(g_parse_sep,g_parse_string1,g_parse_pos,g_flag1)
 CALL cv_parse_text(g_parse_sep,g_parse_string2,g_parse_pos,g_flag2)
 CALL getorgsecurityind(0)
 SUBROUTINE (cv_parse_text(param_sep=vc(ref),param_string=vc(ref),param_pos=i4(ref),param_flag=i4(ref
   )) =null)
   SET curparsedone = 0
   SET param_pos = 1
   SET ce_cnt = 0
   WHILE ((param_pos != - (1)))
     SET curpos = findstring(param_sep,param_string,param_pos)
     IF (curpos=0)
      SET curpos = (size(param_string,1)+ 1)
      SET curparsedone = 1
     ENDIF
     SET ce_cnt += 1
     IF (param_flag=1)
      SET stat = alterlist(ce_title->ce1_list,ce_cnt)
      SET ce_title->ce1_list[ce_cnt].ce1_event_title_text = trim(substring(param_pos,(curpos -
        param_pos),param_string),3)
     ENDIF
     IF (param_flag=2)
      SET stat = alterlist(ce_title->ce2_list,ce_cnt)
      SET ce_title->ce2_list[ce_cnt].ce2_event_title_text = trim(substring(param_pos,(curpos -
        param_pos),param_string),3)
     ENDIF
     SET param_pos = (curpos+ size(param_sep,1))
     IF (curparsedone=1)
      SET param_pos = - (1)
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE getorgsecurityind(dummy)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="SECURITY"
     AND di.info_name="SEC_ORG_RELTN"
    DETAIL
     org_sec_ind = di.info_number
   ;end select
 END ;Subroutine
 SELECT
  IF (((g_parse_string1=null) OR (g_parse_string2=null))
   AND ( $ORG_ID=0.0)
   AND org_sec_ind=0.0)
   PLAN (c
    WHERE c.action_dt_tm BETWEEN cnvtdatetime(qrlstartdate) AND cnvtdatetime(qrlenddate)
     AND ((c.prim_physician_id+ 0) > 0.0))
    JOIN (p
    WHERE c.prim_physician_id=p.person_id)
    JOIN (cs
    WHERE cs.cv_proc_id=c.cv_proc_id
     AND ((cs.event_id+ 0) > 0.0))
    JOIN (ce
    WHERE ce.event_id=cs.event_id
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (ce1
    WHERE ce1.parent_event_id=ce.event_id
     AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce1.event_id
     AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND ce2.result_val != " "
     AND ce2.result_status_cd IN (reqdata->auth_altered_cd, reqdata->auth_auth_cd, reqdata->
    auth_modified_cd))
    JOIN (cc
    WHERE cc.event_id=ce2.event_id
     AND cc.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (e
    WHERE e.encntr_id=c.encntr_id)
  ELSEIF (((g_parse_string1=null) OR (g_parse_string2=null))
   AND ( $ORG_ID=0.0)
   AND org_sec_ind=1.0)
   PLAN (c
    WHERE c.action_dt_tm BETWEEN cnvtdatetime(qrlstartdate) AND cnvtdatetime(qrlenddate)
     AND ((c.prim_physician_id+ 0) > 0.0))
    JOIN (p
    WHERE c.prim_physician_id=p.person_id)
    JOIN (cs
    WHERE cs.cv_proc_id=c.cv_proc_id
     AND ((cs.event_id+ 0) > 0.0))
    JOIN (ce
    WHERE ce.event_id=cs.event_id
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (ce1
    WHERE ce1.parent_event_id=ce.event_id
     AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce1.event_id
     AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND ce2.result_val != " "
     AND ce2.result_status_cd IN (reqdata->auth_altered_cd, reqdata->auth_auth_cd, reqdata->
    auth_modified_cd))
    JOIN (cc
    WHERE cc.event_id=ce2.event_id
     AND cc.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (e
    WHERE e.encntr_id=c.encntr_id
     AND e.organization_id IN (
    (SELECT DISTINCT
     p.organization_id
     FROM prsnl_org_reltn p
     WHERE (p.person_id=reqinfo->updt_id))))
  ELSEIF (((g_parse_string1=null) OR (g_parse_string2=null))
   AND ( $ORG_ID > 0.0))
   PLAN (c
    WHERE c.action_dt_tm BETWEEN cnvtdatetime(qrlstartdate) AND cnvtdatetime(qrlenddate)
     AND ((c.prim_physician_id+ 0) > 0.0))
    JOIN (p
    WHERE c.prim_physician_id=p.person_id)
    JOIN (cs
    WHERE cs.cv_proc_id=c.cv_proc_id
     AND ((cs.event_id+ 0) > 0.0))
    JOIN (ce
    WHERE ce.event_id=cs.event_id
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (ce1
    WHERE ce1.parent_event_id=ce.event_id
     AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce1.event_id
     AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND ce2.result_val != " "
     AND ce2.result_status_cd IN (reqdata->auth_altered_cd, reqdata->auth_auth_cd, reqdata->
    auth_modified_cd))
    JOIN (cc
    WHERE cc.event_id=ce2.event_id
     AND cc.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (e
    WHERE e.encntr_id=c.encntr_id
     AND (e.organization_id= $ORG_ID))
  ELSEIF (g_parse_string1 != null
   AND g_parse_string2 != null
   AND ( $ORG_ID=0.0)
   AND org_sec_ind=0.0)
   PLAN (c
    WHERE c.action_dt_tm BETWEEN cnvtdatetime(cnvtdate2( $START_DATE,"DD-MMM-YYYY"),0) AND
    cnvtdatetime(cnvtdate2( $END_DATE,"DD-MMM-YYYY"),235959)
     AND ((c.prim_physician_id > 0.0) OR (c.action_dt_tm = null)) )
    JOIN (p
    WHERE c.prim_physician_id=p.person_id)
    JOIN (cs
    WHERE cs.cv_proc_id=c.cv_proc_id
     AND ((cs.event_id+ 0) > 0.0))
    JOIN (ce
    WHERE ce.event_id=cs.event_id
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (ce1
    WHERE ce1.parent_event_id=ce.event_id
     AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND expand(g_idx1,1,size(ce_title->ce1_list,5),ce1.event_title_text,ce_title->ce1_list[g_idx1].
     ce1_event_title_text))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce1.event_id
     AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND expand(g_idx2,1,size(ce_title->ce2_list,5),ce2.event_title_text,ce_title->ce2_list[g_idx2].
     ce2_event_title_text)
     AND ce2.result_val != " "
     AND ce2.result_status_cd IN (reqdata->auth_altered_cd, reqdata->auth_auth_cd, reqdata->
    auth_modified_cd))
    JOIN (cc
    WHERE cc.event_id=ce2.event_id
     AND cc.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (e
    WHERE e.encntr_id=c.encntr_id)
  ELSEIF (g_parse_string1 != null
   AND g_parse_string2 != null
   AND ( $ORG_ID=0.0)
   AND org_sec_ind=1.0)
   PLAN (c
    WHERE c.action_dt_tm BETWEEN cnvtdatetime(cnvtdate2( $START_DATE,"DD-MMM-YYYY"),0) AND
    cnvtdatetime(cnvtdate2( $END_DATE,"DD-MMM-YYYY"),235959)
     AND ((c.prim_physician_id > 0.0) OR (c.action_dt_tm = null)) )
    JOIN (p
    WHERE c.prim_physician_id=p.person_id)
    JOIN (cs
    WHERE cs.cv_proc_id=c.cv_proc_id
     AND ((cs.event_id+ 0) > 0.0))
    JOIN (ce
    WHERE ce.event_id=cs.event_id
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (ce1
    WHERE ce1.parent_event_id=ce.event_id
     AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND expand(g_idx1,1,size(ce_title->ce1_list,5),ce1.event_title_text,ce_title->ce1_list[g_idx1].
     ce1_event_title_text))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce1.event_id
     AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND expand(g_idx2,1,size(ce_title->ce2_list,5),ce2.event_title_text,ce_title->ce2_list[g_idx2].
     ce2_event_title_text)
     AND ce2.result_val != " "
     AND ce2.result_status_cd IN (reqdata->auth_altered_cd, reqdata->auth_auth_cd, reqdata->
    auth_modified_cd))
    JOIN (cc
    WHERE cc.event_id=ce2.event_id
     AND cc.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (e
    WHERE e.encntr_id=c.encntr_id
     AND e.organization_id IN (
    (SELECT DISTINCT
     p.organization_id
     FROM prsnl_org_reltn p
     WHERE (p.person_id=reqinfo->updt_id))))
  ELSEIF (g_parse_string1 != null
   AND g_parse_string2 != null
   AND ( $ORG_ID > 0.0))
   PLAN (c
    WHERE c.action_dt_tm BETWEEN cnvtdatetime(cnvtdate2( $START_DATE,"DD-MMM-YYYY"),0) AND
    cnvtdatetime(cnvtdate2( $END_DATE,"DD-MMM-YYYY"),235959)
     AND ((c.prim_physician_id > 0.0) OR (c.action_dt_tm = null)) )
    JOIN (p
    WHERE c.prim_physician_id=p.person_id)
    JOIN (cs
    WHERE cs.cv_proc_id=c.cv_proc_id
     AND ((cs.event_id+ 0) > 0.0))
    JOIN (ce
    WHERE ce.event_id=cs.event_id
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (ce1
    WHERE ce1.parent_event_id=ce.event_id
     AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND expand(g_idx1,1,size(ce_title->ce1_list,5),ce1.event_title_text,ce_title->ce1_list[g_idx1].
     ce1_event_title_text))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce1.event_id
     AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND expand(g_idx2,1,size(ce_title->ce2_list,5),ce2.event_title_text,ce_title->ce2_list[g_idx2].
     ce2_event_title_text)
     AND ce2.result_val != " "
     AND ce2.result_status_cd IN (reqdata->auth_altered_cd, reqdata->auth_auth_cd, reqdata->
    auth_modified_cd))
    JOIN (cc
    WHERE cc.event_id=ce2.event_id
     AND cc.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (e
    WHERE e.encntr_id=c.encntr_id
     AND (e.organization_id= $ORG_ID))
  ELSE
  ENDIF
  INTO "NL:"
  p.name_full_formatted, c_catalog_disp = uar_get_code_display(c.catalog_cd), c.prim_physician_id,
  ce.result_val, ce1.result_val, ce2.result_val,
  cc.descriptor, ce.event_id, ce1.event_id,
  ce2.event_id, c.cv_proc_id, ce1.event_title_text,
  ce2_result_status_disp = uar_get_code_display(ce2.result_status_cd), ctest = substring(1,40,cc
   .descriptor)
  FROM person p,
   cv_proc c,
   clinical_event ce,
   cv_step cs,
   clinical_event ce1,
   clinical_event ce2,
   ce_coded_result cc,
   encounter e
  ORDER BY c.prim_physician_id, c_catalog_disp, cc.descriptor
  HEAD REPORT
   list_cnt = 0, proc_cnt = 0, stat2 = initrec(proc_list),
   stat = alterlist(audit_record->qual,100)
  HEAD c.prim_physician_id
   temp = substring(1,30,p.name_full_formatted), col 5, temp,
   row + 1
  HEAD c_catalog_disp
   temp2 = substring(1,30,c_catalog_disp), col 5, temp2,
   row + 0
  HEAD cc.descriptor
   col + 1, ctest, row + 1
  DETAIL
   list_cnt += 1
   IF (mod(list_cnt,10)=1)
    stat = alterlist(reply_obj->cv_list,(list_cnt+ 9)), stat = alterlist(audit_record->qual,(list_cnt
     + 9))
   ENDIF
   reply_obj->cv_list[list_cnt].rpl_catalog_disp = trim(c_catalog_disp), reply_obj->cv_list[list_cnt]
   .rpl_descriptor = trim(cc.descriptor), reply_obj->cv_list[list_cnt].rpl_full_name = trim(p
    .name_full_formatted,4),
   proc_idx = locateval(proc_idx,1,proc_cnt,c.cv_proc_id,proc_list->qual[proc_idx].cv_proc_id)
   IF (proc_idx=0)
    proc_cnt += 1
    IF (mod(proc_cnt,10)=1)
     stat2 = alterlist(proc_list->qual,(proc_cnt+ 9))
    ENDIF
    proc_list->qual[proc_cnt].cv_proc_id = c.cv_proc_id
   ENDIF
   reply_obj->cv_list[list_cnt].rpl_proc_cnt = proc_cnt, audit_record->qual[list_cnt].order_id = c
   .order_id
  FOOT  cc.descriptor
   col 50, reply_obj->cv_list[list_cnt].rpl_proc_cnt, row + 0
  FOOT  c_catalog_disp
   proc_cnt = 0, row + 0
  FOOT  c.prim_physician_id
   col + 1, c.cv_proc_id, row + 1
  FOOT REPORT
   stat = alterlist(reply_obj->cv_list,list_cnt), stat2 = alterlist(proc_list->qual,proc_cnt), stat
    = alterlist(audit_record->qual,list_cnt)
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
#exit_script
 CALL cv_log_msg_post("MOD 005 16/08/2019 RT050705")
END GO

CREATE PROGRAM cv_frpt_phys_proc_drv:dba
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
 DECLARE nlistcnt = i2 WITH protect
 DECLARE naddrecord = i2 WITH protect
 DECLARE qstartdate = q8 WITH protect
 DECLARE qenddate = q8 WITH protect
 SET qstartdate = cnvtdatetime(cnvtdate2( $START_DATE,"DD-MMM-YYYY"),0)
 SET qenddate = datetimeadd(cnvtdatetime(cnvtdate2( $END_DATE,"DD-MMM-YYYY"),0),1)
 DECLARE begin_date = dq8 WITH protect
 IF (qstartdate > qenddate)
  GO TO exit_script
 ENDIF
 DECLARE signed_var = f8 WITH constant(uar_get_code_by("MEANING",4000341,"SIGNED"))
 DECLARE e_alias_type_cd_mrn = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE pa_alias_type_cd_dodid = f8 WITH constant(uar_get_code_by("MEANING",4,"MILITARYID"))
 DECLARE pa_alias_type_cd_cmrn = f8 WITH constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE dattendphyscd = f8 WITH constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE c_proc_block = i4 WITH noconstant(50), protect
 DECLARE var_idx = i4 WITH protect
 DECLARE var_pad = i4 WITH protect
 DECLARE var_cnt = i4 WITH protect
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE locate_idx = i4 WITH protect, noconstant(0)
 DECLARE org_sec_ind = f8 WITH protect, noconstant(0)
 DECLARE orgs_block = i4 WITH protect, constant(20)
 DECLARE orgs_cnt = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE order_idx = i4 WITH protect, noconstant(1)
 DECLARE getorgsecurityind(dummy) = null WITH protect
 DECLARE getassociatedorgs(dummy) = null WITH protect
 IF (validate(reply_obj)=0)
  RECORD reply_obj(
    1 qual[*]
      2 patient_name = vc
      2 provider_name = vc
      2 catalog_display = vc
      2 proc_status_disp = vc
      2 reason_for_proc = vc
      2 proc_date = dq8
      2 patient_mrn = vc
      2 patient_dodid = vc
      2 patient_cmrn = vc
      2 encntr_id = f8
      2 location = vc
      2 sex_disp = vc
      2 attending_phys = vc
      2 patient_age = vc
      2 admit_date = dq8
    1 person_alias_enabled = vc
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
 FREE RECORD pref_request
 RECORD pref_request(
   1 context = vc
   1 context_id = vc
   1 section = vc
   1 section_id = vc
   1 groups[*]
     2 name = vc
   1 debug = vc
 )
 FREE RECORD pref_reply
 RECORD pref_reply(
   1 entries[*]
     2 name = vc
     2 values[*]
       3 value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD associated_orgs(
   1 qual[*]
     2 organization_id = f8
 ) WITH protect
 RECORD orders(
   1 qual[*]
     2 order_id = f8
 ) WITH protect
 RECORD logs(
   1 count = f8
   1 text = vc
 )
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
 DECLARE idx = i4 WITH protect, noconstant(0)
 CALL loadpreferences(0)
 SUBROUTINE getorgsecurityind(dummy)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="SECURITY"
     AND di.info_name="SEC_ORG_RELTN"
    DETAIL
     org_sec_ind = di.info_number
   ;end select
 END ;Subroutine
 SUBROUTINE getassociatedorgs(dummy)
   SELECT DISTINCT INTO "nl:"
    FROM prsnl_org_reltn por
    WHERE (por.person_id=reqinfo->updt_id)
     AND por.active_ind=1
     AND por.end_effective_dt_tm >= cnvtdate(12312100)
    HEAD REPORT
     stat = alterlist(associated_orgs->qual,orgs_block)
    DETAIL
     orgs_cnt += 1
     IF (mod(orgs_cnt,orgs_block)=0)
      stat = alterlist(associated_orgs->qual,(orgs_block+ orgs_cnt))
     ENDIF
     associated_orgs->qual[orgs_cnt].organization_id = por.organization_id
    FOOT REPORT
     stat = alterlist(associated_orgs->qual,orgs_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 CALL getorgsecurityind(0)
 CALL getassociatedorgs(0)
 SELECT
  IF (( $ORG_ID=0.0)
   AND org_sec_ind=0.0)
   FROM cv_proc c,
    person p,
    prsnl pr,
    encntr_alias ea,
    person_alias pa,
    encounter e
   PLAN (c
    WHERE c.action_dt_tm >= cnvtdatetime(qstartdate)
     AND c.action_dt_tm < cnvtdatetime(qenddate)
     AND c.proc_status_cd=signed_var)
    JOIN (p
    WHERE p.person_id=c.person_id)
    JOIN (pr
    WHERE pr.person_id=c.prim_physician_id)
    JOIN (ea
    WHERE (ea.encntr_id= Outerjoin(c.encntr_id))
     AND (ea.encntr_alias_type_cd= Outerjoin(e_alias_type_cd_mrn))
     AND (ea.active_ind= Outerjoin(1))
     AND (ea.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
     AND (ea.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    JOIN (pa
    WHERE (pa.person_id= Outerjoin(p.person_id)) )
    JOIN (e
    WHERE (e.encntr_id= Outerjoin(c.encntr_id)) )
  ELSEIF (( $ORG_ID=0.0)
   AND org_sec_ind=1.0)
   FROM cv_proc c,
    person p,
    prsnl pr,
    encntr_alias ea,
    person_alias pa,
    encounter e
   PLAN (c
    WHERE c.action_dt_tm >= cnvtdatetime(qstartdate)
     AND c.action_dt_tm < cnvtdatetime(qenddate)
     AND c.proc_status_cd=signed_var)
    JOIN (p
    WHERE p.person_id=c.person_id)
    JOIN (pr
    WHERE pr.person_id=c.prim_physician_id)
    JOIN (ea
    WHERE (ea.encntr_id= Outerjoin(c.encntr_id))
     AND (ea.encntr_alias_type_cd= Outerjoin(e_alias_type_cd_mrn))
     AND (ea.active_ind= Outerjoin(1))
     AND (ea.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
     AND (ea.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    JOIN (pa
    WHERE pa.person_id=p.person_id)
    JOIN (e
    WHERE (e.encntr_id= Outerjoin(c.encntr_id))
     AND expand(num,1,orgs_cnt,e.organization_id,associated_orgs->qual[num].organization_id))
  ELSE
   FROM cv_proc c,
    person p,
    prsnl pr,
    encntr_alias ea,
    person_alias pa,
    encounter e
   PLAN (c
    WHERE c.action_dt_tm >= cnvtdatetime(qstartdate)
     AND c.action_dt_tm < cnvtdatetime(qenddate)
     AND c.proc_status_cd=signed_var)
    JOIN (p
    WHERE p.person_id=c.person_id)
    JOIN (pr
    WHERE pr.person_id=c.prim_physician_id)
    JOIN (ea
    WHERE (ea.encntr_id= Outerjoin(c.encntr_id))
     AND (ea.encntr_alias_type_cd= Outerjoin(e_alias_type_cd_mrn))
     AND (ea.active_ind= Outerjoin(1))
     AND (ea.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
     AND (ea.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    JOIN (pa
    WHERE (pa.person_id= Outerjoin(p.person_id)) )
    JOIN (e
    WHERE (e.encntr_id= Outerjoin(c.encntr_id))
     AND (e.organization_id= $ORG_ID))
  ENDIF
  INTO "NL:"
  HEAD REPORT
   nlistcnt = 0, stat = alterlist(reply_obj->qual,100), stat = alterlist(audit_record->qual,100)
  HEAD c.cv_proc_id
   nlistcnt += 1
   IF (nlistcnt > 100
    AND mod(nlistcnt,10)=1)
    stat = alterlist(reply_obj->qual,(nlistcnt+ 9)), stat = alterlist(audit_record->qual,(nlistcnt+ 9
     ))
   ENDIF
  DETAIL
   stat = alterlist(orders->qual,order_idx), locate_idx = locateval(locate_idx,1,size(orders->qual,5),
    c.order_id,orders->qual[locate_idx].order_id)
   IF (locate_idx <= 0)
    reply_obj->qual[order_idx].reason_for_proc = c.reason_for_proc, reply_obj->qual[order_idx].
    provider_name = pr.name_full_formatted, reply_obj->qual[order_idx].patient_name = p
    .name_full_formatted,
    reply_obj->qual[order_idx].catalog_display = trim(uar_get_code_display(c.catalog_cd)), reply_obj
    ->qual[order_idx].proc_status_disp = trim(uar_get_code_display(c.proc_status_cd)), reply_obj->
    qual[order_idx].proc_date = c.action_dt_tm,
    reply_obj->qual[order_idx].patient_mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
    IF (pa.person_alias_type_cd=pa_alias_type_cd_dodid
     AND pa.active_ind)
     reply_obj->qual[order_idx].patient_dodid = cnvtalias(pa.alias,pa.alias_pool_cd)
    ENDIF
    IF (pa.person_alias_type_cd=pa_alias_type_cd_cmrn
     AND pa.active_ind)
     reply_obj->qual[order_idx].patient_cmrn = cnvtalias(pa.alias,pa.alias_pool_cd)
    ENDIF
    reply_obj->qual[order_idx].location = uar_get_code_display(e.loc_nurse_unit_cd), reply_obj->qual[
    order_idx].sex_disp = uar_get_code_display(p.sex_cd), reply_obj->qual[order_idx].patient_age =
    cnvtage(p.birth_dt_tm,c.action_dt_tm,0),
    reply_obj->qual[order_idx].admit_date = cnvtdatetimeutc(e.reg_dt_tm,0), reply_obj->qual[order_idx
    ].encntr_id = c.encntr_id, begin_date = c.action_dt_tm,
    audit_record->qual[order_idx].order_id = c.order_id, orders->qual[order_idx].order_id = c
    .order_id, order_idx += 1
   ENDIF
  FOOT REPORT
   stat = alterlist(reply_obj->qual,(order_idx - 1)), stat = alterlist(audit_record->qual,(order_idx
     - 1))
  WITH nocounter
 ;end select
 SET block_size = c_proc_block
 SET nlistcnt = size(reply_obj->qual,5)
 SET var_cnt = nlistcnt
 SET var_pad = (nlistcnt+ ((block_size - 1) - mod((nlistcnt - 1),block_size)))
 SET stat = alterlist(reply_obj->qual,var_pad)
 FOR (var_idx = (var_cnt+ 1) TO var_pad)
   SET reply_obj->qual[var_idx].encntr_id = reply_obj->qual[var_cnt].encntr_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
   encntr_prsnl_reltn epr,
   prsnl pr
  PLAN (d
   WHERE d.seq > 0
    AND assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
   JOIN (epr
   WHERE epr.encntr_id > 0.0
    AND expand(var_idx,nstart,((nstart+ block_size) - 1),epr.encntr_id,reply_obj->qual[var_idx].
    encntr_id)
    AND epr.encntr_prsnl_r_cd=dattendphyscd)
   JOIN (pr
   WHERE epr.prsnl_person_id=pr.person_id
    AND epr.end_effective_dt_tm >= cnvtdatetime(begin_date)
    AND epr.beg_effective_dt_tm <= cnvtdatetime(begin_date))
  DETAIL
   locate_idx = locateval(locate_idx,1,var_cnt,epr.encntr_id,reply_obj->qual[locate_idx].encntr_id)
   WHILE (locate_idx > 0)
    reply_obj->qual[locate_idx].attending_phys = pr.name_full_formatted,locate_idx = locateval(
     locate_idx,(locate_idx+ 1),var_cnt,epr.encntr_id,reply_obj->qual[locate_idx].encntr_id)
   ENDWHILE
  WITH nocounter
 ;end select
 SET stat = alterlist(reply_obj->qual,nlistcnt)
 SET stat = alterlist(audit_record->qual,nlistcnt)
 SUBROUTINE loadpreferences(dummy)
   DECLARE lvindex = i4 WITH protect, noconstant(0)
   DECLARE nprefcnt = i4 WITH protect, noconstant(0)
   SET pref_request->context = "default"
   SET pref_request->context_id = "system"
   SET pref_request->section = "module"
   SET pref_request->section_id = "CVNet"
   SET pref_request->debug = "0"
   EXECUTE fn_get_prefs  WITH replace("REQUEST",pref_request), replace("REPLY",pref_reply)
   IF ((pref_reply->status_data.status="F"))
    CALL cv_log_message(build("*** Unable to find preference ***"))
    SET reply_obj->status_data.status = "F"
   ENDIF
   SET nprefcnt = size(pref_reply->entries,5)
   CALL echo(build("nPrefCnt = ",nprefcnt))
   SET lvindex = locateval(idx,1,nprefcnt,"display person alias",pref_reply->entries[idx].name)
   IF (lvindex > 0)
    IF ((pref_reply->entries[lvindex].values[1].value="1"))
     SET reply_obj->person_alias_enabled = "1"
    ELSE
     SET reply_obj->person_alias_enabled = "0"
    ENDIF
   ENDIF
 END ;Subroutine
 CALL auditevent("CVWFM View Results","Viewed Admin Reports","User Viewed/Printed the admin reports")
 IF (curqual > 0)
  SET reply_obj->status_data.status = "S"
 ELSEIF (curqual=0)
  SET reply_obj->status_data.status = "Z"
 ELSE
  SET reply_obj->status_data.status = "F"
 ENDIF
#exit_script
 CALL cv_log_msg_post("MOD 013 10/03/2021 AK077940")
END GO

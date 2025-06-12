CREATE PROGRAM cv_flip_procs_status_drv
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "CURDATE",
  "End Date" = "CURDATE",
  "I want to view" = 1,
  "Accession" = " "
  WITH outdev, start_date, end_date,
  u_view, accession
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
 DECLARE qstartdate = q8 WITH protect
 DECLARE qenddate = q8 WITH protect
 DECLARE dprocedureid = f8 WITH protect
 DECLARE vcaccession = vc WITH protect
 DECLARE begin_date = dq8 WITH protect
 DECLARE ipatsize = i4 WITH public, noconstant(0)
 DECLARE iacpatsize = i4 WITH public, noconstant(0)
 DECLARE ipatcnt = i4 WITH public, noconstant(1)
 DECLARE iexecnt = i4 WITH public, noconstant(1)
 DECLARE irecsize = i4 WITH public, noconstant(1)
 DECLARE idx = i4 WITH public, noconstant(1)
 DECLARE fresval = f8 WITH public, noconstant(0.0)
 DECLARE senddatetime = vc WITH protect, constant(concat(trim( $END_DATE)," 23:59:59"))
 DECLARE e_alias_type_cd_mrn = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE attending_phys_cd = f8 WITH constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE proc_type_ecg = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",5801,"ECG"))
 DECLARE ecg_step_status_cd_saved = f8 WITH protect, constant(uar_get_code_by("MEANING",4000440,
   "SAVED"))
 DECLARE ecg_step_status_cd_unsigned = f8 WITH protect, constant(uar_get_code_by("MEANING",4000440,
   "UNSIGNED"))
 DECLARE ecg_proc_status_cd_completed = f8 WITH protect, constant(uar_get_code_by("MEANING",4000341,
   "COMPLETED"))
 DECLARE order_dept_status_cd_cvcompleted = f8 WITH protect, constant(uar_get_code_by("MEANING",14281,
   "CVCOMPLETED"))
 DECLARE order_action_type_cd_status_change = f8 WITH protect, constant(uar_get_code_by("MEANING",
   6003,"STATUSCHANGE"))
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
      2 encntr_id = f8
      2 location = vc
      2 sex_disp = vc
      2 attending_phys = vc
      2 patient_age = vc
      2 admit_date = dq8
      2 order_id = f8
      2 accession = vc
      2 final_report_step_id = f8
      2 provider_id = f8
      2 cv_step_id = f8
      2 updt_cnt = i4
      2 step_status_cd = f8
      2 cv_proc_id = f8
      2 prim_physician_id = f8
      2 phys_group_id = f8
      2 proc_updt_cnt = i4
      2 proc_normalcy_cd = f8
      2 perf_provider_id = f8
      2 event_id = f8
      2 action_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD updt_request(
   1 cv_step_id = f8
   1 updt_cnt = i4
   1 step_status_cd = f8
   1 cv_proc_id = f8
   1 prim_physician_id = f8
   1 phys_group_id = f8
   1 proc_updt_cnt = i4
   1 proc_normalcy_cd = f8
   1 perf_provider_id = f8
   1 event_id = f8
 )
 RECORD updt_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply_obj->status_data.status = "F"
 SET reply->status_data.status = "F"
 SET qstartdate = cnvtdatetime( $START_DATE)
 SET qenddate = cnvtdatetime(senddatetime)
 SET vcaccession =  $ACCESSION
 IF (qstartdate > qenddate)
  CALL cv_log_msg(cv_debug,build("EndDate: ",qenddate," is before StartDate: ",qstartdate))
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 CALL cv_log_msg(cv_debug,build("qStartDate: ",qstartdate))
 CALL cv_log_msg(cv_debug,build("qEndDate: ",qenddate))
 CALL echo(qstartdate)
 CALL echo(qenddate)
 IF (((vcaccession=" ") OR (vcaccession="")) )
  CALL echo("Invoking GetProceduresByActionDtTm()")
  CALL cv_log_msg(cv_debug,build("Invoking GetProceduresByActionDtTm() due to vcAccession: ",
    vcaccession))
  CALL getproceduresbyactiondttm(0)
 ELSE
  CALL echo("Invoking GetProceduresByAccession()")
  CALL cv_log_msg(cv_debug,build("Invoking GetProceduresByAccession() due to vcAccession: ",
    vcaccession))
  CALL getproceduresbyaccession(0)
 ENDIF
 IF (size(reply_obj->qual,5) > 0)
  CALL cv_log_msg(cv_debug,build("Size of the retrived procedures: ",size(reply_obj->qual,5)))
  IF (( $U_VIEW=3))
   CALL updatestatus(0)
  ENDIF
  SET reply_obj->status_data.status = "S"
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply_obj)
 COMMIT
 SUBROUTINE (getproceduresbyactiondttm(dummy=i2) =null WITH protect)
   CALL cv_log_msg(cv_debug,"Entering GetProceduresByActionDtTm()")
   SELECT DISTINCT INTO "NL:"
    FROM cv_proc c,
     cv_step cs,
     long_text lt,
     person p,
     prsnl pr,
     encntr_alias ea,
     encounter e
    PLAN (c
     WHERE c.proc_status_cd=ecg_proc_status_cd_completed
      AND c.activity_subtype_cd=proc_type_ecg
      AND c.updt_task != 4100700)
     JOIN (cs
     WHERE cs.cv_proc_id=c.cv_proc_id
      AND cs.step_status_cd=ecg_step_status_cd_saved
      AND cs.updt_dt_tm >= cnvtdatetime(qstartdate)
      AND cs.updt_dt_tm < cnvtdatetime(qenddate))
     JOIN (lt
     WHERE lt.parent_entity_id=cs.cv_step_id)
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
     JOIN (e
     WHERE (e.encntr_id= Outerjoin(c.encntr_id)) )
    ORDER BY c.accession
    HEAD REPORT
     nlistcnt = 0, stat = alterlist(reply_obj->qual,500)
    DETAIL
     nlistcnt += 1
     IF (nlistcnt > 500
      AND mod(nlistcnt,50)=1)
      stat = alterlist(reply_obj->qual,(nlistcnt+ 49))
     ENDIF
     reply_obj->qual[nlistcnt].action_dt_tm = c.action_dt_tm, reply_obj->qual[nlistcnt].
     reason_for_proc = c.reason_for_proc, reply_obj->qual[nlistcnt].provider_name = pr
     .name_full_formatted,
     reply_obj->qual[nlistcnt].patient_name = p.name_full_formatted, reply_obj->qual[nlistcnt].
     catalog_display = trim(uar_get_code_display(c.catalog_cd)), reply_obj->qual[nlistcnt].
     proc_status_disp = trim(uar_get_code_display(c.proc_status_cd)),
     reply_obj->qual[nlistcnt].proc_date = c.action_dt_tm, reply_obj->qual[nlistcnt].patient_mrn =
     cnvtalias(ea.alias,ea.alias_pool_cd), reply_obj->qual[nlistcnt].location = uar_get_code_display(
      e.loc_nurse_unit_cd),
     reply_obj->qual[nlistcnt].sex_disp = uar_get_code_display(p.sex_cd), reply_obj->qual[nlistcnt].
     patient_age = cnvtage(p.birth_dt_tm,c.action_dt_tm,0), reply_obj->qual[nlistcnt].admit_date =
     cnvtdatetimeutc(e.reg_dt_tm,0),
     reply_obj->qual[nlistcnt].encntr_id = c.encntr_id, reply_obj->qual[nlistcnt].order_id = c
     .order_id, reply_obj->qual[nlistcnt].accession = c.accession,
     reply_obj->qual[nlistcnt].final_report_step_id = cs.cv_step_id, reply_obj->qual[nlistcnt].
     provider_id = pr.person_id, reply_obj->qual[nlistcnt].cv_step_id = cs.cv_step_id,
     reply_obj->qual[nlistcnt].updt_cnt = cs.updt_cnt, reply_obj->qual[nlistcnt].step_status_cd = cs
     .step_status_cd, reply_obj->qual[nlistcnt].cv_proc_id = cs.cv_proc_id,
     reply_obj->qual[nlistcnt].prim_physician_id = c.prim_physician_id, reply_obj->qual[nlistcnt].
     phys_group_id = c.phys_group_id, reply_obj->qual[nlistcnt].proc_updt_cnt = c.updt_cnt,
     reply_obj->qual[nlistcnt].proc_normalcy_cd = c.normalcy_cd, reply_obj->qual[nlistcnt].
     perf_provider_id = reqinfo->updt_id
    FOOT REPORT
     stat = alterlist(reply_obj->qual,nlistcnt)
    WITH nocounter
   ;end select
   CALL cv_log_msg(cv_debug,"Exit GetProceduresByActionDtTm()")
 END ;Subroutine
 SUBROUTINE (getproceduresbyaccession(dummy=i2) =null WITH protect)
   CALL cv_log_msg(cv_debug,"Entering GetProceduresByAccession()")
   SELECT DISTINCT INTO "NL:"
    FROM cv_proc c,
     cv_step cs,
     long_text lt,
     person p,
     prsnl pr,
     encntr_alias ea,
     encounter e
    PLAN (c
     WHERE c.accession=vcaccession
      AND c.proc_status_cd=ecg_proc_status_cd_completed
      AND c.activity_subtype_cd=proc_type_ecg)
     JOIN (cs
     WHERE cs.cv_proc_id=c.cv_proc_id
      AND cs.step_status_cd=ecg_step_status_cd_saved)
     JOIN (lt
     WHERE lt.parent_entity_id=cs.cv_step_id)
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
     JOIN (e
     WHERE (e.encntr_id= Outerjoin(c.encntr_id)) )
    ORDER BY c.accession
    HEAD REPORT
     nlistcnt = 0, stat = alterlist(reply_obj->qual,500)
    DETAIL
     nlistcnt += 1
     IF (nlistcnt > 500
      AND mod(nlistcnt,50)=1)
      stat = alterlist(reply_obj->qual,(nlistcnt+ 49))
     ENDIF
     reply_obj->qual[nlistcnt].action_dt_tm = c.action_dt_tm, reply_obj->qual[nlistcnt].provider_name
      = pr.name_full_formatted, reply_obj->qual[nlistcnt].patient_name = p.name_full_formatted,
     reply_obj->qual[nlistcnt].catalog_display = trim(uar_get_code_display(c.catalog_cd)), reply_obj
     ->qual[nlistcnt].proc_status_disp = trim(uar_get_code_display(c.proc_status_cd)), reply_obj->
     qual[nlistcnt].proc_date = c.action_dt_tm,
     reply_obj->qual[nlistcnt].patient_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), reply_obj->qual[
     nlistcnt].location = uar_get_code_display(e.loc_nurse_unit_cd), reply_obj->qual[nlistcnt].
     sex_disp = uar_get_code_display(p.sex_cd),
     reply_obj->qual[nlistcnt].patient_age = cnvtage(p.birth_dt_tm,c.action_dt_tm,0), reply_obj->
     qual[nlistcnt].admit_date = cnvtdatetimeutc(e.reg_dt_tm,0), reply_obj->qual[nlistcnt].encntr_id
      = c.encntr_id,
     reply_obj->qual[nlistcnt].order_id = c.order_id, reply_obj->qual[nlistcnt].accession = c
     .accession, reply_obj->qual[nlistcnt].final_report_step_id = cs.cv_step_id,
     reply_obj->qual[nlistcnt].provider_id = pr.person_id, reply_obj->qual[nlistcnt].cv_step_id = cs
     .cv_step_id, reply_obj->qual[nlistcnt].updt_cnt = cs.updt_cnt,
     reply_obj->qual[nlistcnt].step_status_cd = cs.step_status_cd, reply_obj->qual[nlistcnt].
     cv_proc_id = cs.cv_proc_id, reply_obj->qual[nlistcnt].prim_physician_id = c.prim_physician_id,
     reply_obj->qual[nlistcnt].phys_group_id = c.phys_group_id, reply_obj->qual[nlistcnt].
     proc_updt_cnt = c.updt_cnt, reply_obj->qual[nlistcnt].proc_normalcy_cd = c.normalcy_cd,
     reply_obj->qual[nlistcnt].perf_provider_id = reqinfo->updt_id
    FOOT REPORT
     stat = alterlist(reply_obj->qual,nlistcnt)
    WITH nocounter
   ;end select
   CALL cv_log_msg(cv_debug,"Exit GetProceduresByAccession()")
 END ;Subroutine
 SUBROUTINE (updatestatus(param=i4) =null)
   CALL cv_log_msg(cv_debug,"Entering UpdateStatus()")
   SET iacpatsize = size(reply_obj->qual,5)
   IF (iacpatsize > 0)
    IF (iacpatsize <= 20)
     SET fresval = 1
     SET iexecnt = 1
    ELSE
     SET fresval = (iacpatsize/ 20)
     SET iexecnt = (ceil(fresval)+ 1)
    ENDIF
    FOR (idx1 = 1 TO iexecnt)
     SET irecsize = (20 * idx1)
     IF (irecsize < iacpatsize)
      CALL sendinformation(irecsize)
     ELSE
      CALL sendinformation(iacpatsize)
     ENDIF
    ENDFOR
   ENDIF
   CALL cv_log_msg(cv_debug,"Exit UpdateStatus()")
 END ;Subroutine
 SUBROUTINE (sendinformation(dummy=i2) =null WITH protect)
   CALL cv_log_msg(cv_debug,"Entering SendInformation()")
   DECLARE idx = i4 WITH public, noconstant(0)
   IF (dummy=20)
    SET ipatsize = dummy
    SET ipatcnt = 1
   ELSE
    SET ipatsize = dummy
   ENDIF
   CALL recurcall(ipatcnt)
   CALL cv_log_msg(cv_debug,"Exit SendInformation()")
 END ;Subroutine
 SUBROUTINE (recurcall(iidx=i4) =null WITH protect)
   CALL cv_log_msg(cv_debug,"Entering RecurCall()")
   SET updt_request->cv_step_id = reply_obj->qual[iidx].cv_step_id
   SET updt_request->updt_cnt = reply_obj->qual[iidx].updt_cnt
   SET updt_request->step_status_cd = ecg_step_status_cd_unsigned
   SET updt_request->proc_normalcy_cd = reply_obj->qual[iidx].proc_normalcy_cd
   SET updt_request->perf_provider_id = reply_obj->qual[iidx].perf_provider_id
   CALL echorecord(updt_request)
   EXECUTE cv_set_step_status  WITH replace("REQUEST",updt_request), replace("REPLY",updt_reply)
   CALL echorecord(updt_reply)
   IF (ipatsize > ipatcnt)
    SET ipatcnt += 1
    IF ((updt_reply->status_data.status != "F"))
     CALL recurcall(ipatcnt)
    ENDIF
   ENDIF
   CALL cv_log_msg(cv_debug,"Exit RecurCall()")
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="F"))
  CALL cv_log_msg(cv_error,"cv_flip_procs_status_drv failed!")
  CALL echorecord(request)
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL cv_log_msg_post("MOD 001 25/02/21 SS028138")
END GO

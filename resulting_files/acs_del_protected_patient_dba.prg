CREATE PROGRAM acs_del_protected_patient:dba
 IF ( NOT (validate(log_error)))
  DECLARE log_error = i4 WITH protect, constant(0)
 ENDIF
 IF ( NOT (validate(log_warning)))
  DECLARE log_warning = i4 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(log_audit)))
  DECLARE log_audit = i4 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(log_info)))
  DECLARE log_info = i4 WITH protect, constant(3)
 ENDIF
 IF ( NOT (validate(log_debug)))
  DECLARE log_debug = i4 WITH protect, constant(4)
 ENDIF
 DECLARE __lpahsys = i4 WITH protect, noconstant(0)
 DECLARE __lpalsysstat = i4 WITH protect, noconstant(0)
 IF (validate(logmessage,char(128))=char(128))
  SUBROUTINE (logmessage(psubroutine=vc,pmessage=vc,plevel=i4) =null)
    DECLARE cs23372_failed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23372,"FAILED"))
    DECLARE hmsg = i4 WITH protect, noconstant(0)
    DECLARE hreq = i4 WITH protect, noconstant(0)
    DECLARE hrep = i4 WITH protect, noconstant(0)
    DECLARE hobjarray = i4 WITH protect, noconstant(0)
    DECLARE srvstatus = i4 WITH protect, noconstant(0)
    DECLARE submit_log = i4 WITH protect, constant(4099455)
    CALL echo("")
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    IF (size(trim(psubroutine,3)) > 0)
     CALL echo(concat(curprog," : ",psubroutine,"() : ",pmessage))
    ELSE
     CALL echo(concat(curprog," : ",pmessage))
    ENDIF
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    CALL echo("")
    SET __lpahsys = 0
    SET __lpalsysstat = 0
    CALL uar_syscreatehandle(__lpahsys,__lpalsysstat)
    IF (__lpahsys > 0)
     CALL uar_sysevent(__lpahsys,plevel,curprog,nullterm(pmessage))
     CALL uar_sysdestroyhandle(__lpahsys)
    ENDIF
    IF (plevel=log_error)
     SET hmsg = uar_srvselectmessage(submit_log)
     SET hreq = uar_srvcreaterequest(hmsg)
     SET hrep = uar_srvcreatereply(hmsg)
     SET hobjarray = uar_srvadditem(hreq,"objArray")
     SET stat = uar_srvsetdouble(hobjarray,"final_status_cd",cs23372_failed_cd)
     SET stat = uar_srvsetstring(hobjarray,"task_name",nullterm(curprog))
     SET stat = uar_srvsetstring(hobjarray,"completion_msg",nullterm(pmessage))
     SET stat = uar_srvsetdate(hobjarray,"end_dt_tm",cnvtdatetime(sysdate))
     SET stat = uar_srvsetstring(hobjarray,"current_node_name",nullterm(curnode))
     SET stat = uar_srvsetstring(hobjarray,"server_name",nullterm(build(curserver)))
     SET srvstatus = uar_srvexecute(hmsg,hreq,hrep)
     IF (srvstatus != 0)
      CALL echo(build2("Execution of pft_save_system_activity_log was not successful"))
     ENDIF
     CALL uar_srvdestroyinstance(hreq)
     CALL uar_srvdestroyinstance(hrep)
    ENDIF
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(go_to_exit_script)))
  DECLARE go_to_exit_script = i2 WITH constant(1)
 ENDIF
 IF ( NOT (validate(dont_go_to_exit_script)))
  DECLARE dont_go_to_exit_script = i2 WITH constant(0)
 ENDIF
 IF (validate(beginservice,char(128))=char(128))
  SUBROUTINE (beginservice(pversion=vc) =null)
   CALL logmessage("",concat("version:",pversion," :Begin Service"),log_debug)
   CALL setreplystatus("F","Begin Service")
  END ;Subroutine
 ENDIF
 IF (validate(exitservicesuccess,char(128))=char(128))
  SUBROUTINE (exitservicesuccess(pmessage=vc) =null)
    DECLARE errmsg = vc WITH noconstant(" ")
    DECLARE errcode = i2 WITH noconstant(1)
    IF (size(trim(pmessage,3)) > 0)
     CALL logmessage("",pmessage,log_info)
    ENDIF
    IF ((((currevminor2+ (currevminor * 100))+ (currev * 10000)) >= 080311))
     IF (curdomain IN ("SURROUND", "SOLUTION"))
      SET errmsg = fillstring(132," ")
      SET errcode = error(errmsg,1)
      IF (errcode != 0)
       CALL exitservicefailure(errmsg,true)
      ELSE
       CALL logmessage("","Exit Service - SUCCESS",log_debug)
       CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
       SET reqinfo->commit_ind = true
      ENDIF
     ELSE
      CALL logmessage("","Exit Service - SUCCESS",log_debug)
      CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
      SET reqinfo->commit_ind = true
     ENDIF
    ELSE
     CALL logmessage("","Exit Service - SUCCESS",log_debug)
     CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
     SET reqinfo->commit_ind = true
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(exitservicefailure,char(128))=char(128))
  SUBROUTINE (exitservicefailure(pmessage=vc,exitscriptind=i2) =null)
    CALL addtracemessage("",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage))
    CALL logmessage("",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage),log_error)
    IF (validate(reply->failure_stack.failures))
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = reply->failure_stack.failures[1].
     programname
     SET reply->status_data.subeventstatus[1].targetobjectname = reply->failure_stack.failures[1].
     routinename
     SET reply->status_data.subeventstatus[1].targetobjectvalue = reply->failure_stack.failures[1].
     message
    ELSE
     CALL setreplystatus("F",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage))
    ENDIF
    SET reqinfo->commit_ind = false
    IF (exitscriptind)
     GO TO exit_script
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(exitservicenodata,char(128))=char(128))
  SUBROUTINE (exitservicenodata(pmessage=vc,exitscriptind=i2) =null)
    IF (size(trim(pmessage,3)) > 0)
     CALL logmessage("",pmessage,log_info)
    ENDIF
    CALL logmessage("","Exit Service - NO DATA",log_debug)
    CALL setreplystatus("Z",evaluate(pmessage,"","Exit Service - NO DATA",pmessage))
    SET reqinfo->commit_ind = false
    IF (exitscriptind)
     GO TO exit_script
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setreplystatus,char(128))=char(128))
  SUBROUTINE (setreplystatus(pstatus=vc,pmessage=vc) =null)
    IF (validate(reply->status_data))
     SET reply->status_data.status = nullterm(pstatus)
     SET reply->status_data.subeventstatus[1].operationstatus = nullterm(pstatus)
     SET reply->status_data.subeventstatus[1].operationname = nullterm(curprog)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = nullterm(pmessage)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addtracemessage,char(128))=char(128))
  SUBROUTINE (addtracemessage(proutinename=vc,pmessage=vc) =null)
   CALL logmessage(proutinename,pmessage,log_debug)
   IF (validate(reply->failure_stack))
    DECLARE failcnt = i4 WITH protect, noconstant((size(reply->failure_stack.failures,5)+ 1))
    SET stat = alterlist(reply->failure_stack.failures,failcnt)
    SET reply->failure_stack.failures[failcnt].programname = nullterm(curprog)
    SET reply->failure_stack.failures[failcnt].routinename = nullterm(proutinename)
    SET reply->failure_stack.failures[failcnt].message = nullterm(pmessage)
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addstatusdetail,char(128))=char(128))
  SUBROUTINE (addstatusdetail(pentityid=f8,pdetailflag=i4,pdetailmessage=vc) =null)
    IF (validate(reply->status_detail))
     DECLARE detailcnt = i4 WITH protect, noconstant((size(reply->status_detail.details,5)+ 1))
     SET stat = alterlist(reply->status_detail.details,detailcnt)
     SET reply->status_detail.details[detailcnt].entityid = pentityid
     SET reply->status_detail.details[detailcnt].detailflag = pdetailflag
     SET reply->status_detail.details[detailcnt].detailmessage = nullterm(pdetailmessage)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(copystatusdetails,char(128))=char(128))
  SUBROUTINE (copystatusdetails(pfromrecord=vc(ref),prtorecord=vc(ref)) =null)
    IF (validate(pfromrecord->status_detail)
     AND validate(prtorecord->status_detail))
     DECLARE fromidx = i4 WITH protect, noconstant(0)
     DECLARE fromcnt = i4 WITH protect, noconstant(size(pfromrecord->status_detail.details,5))
     DECLARE toidx = i4 WITH protect, noconstant(size(prtorecord->status_detail.details,5))
     DECLARE fromparamidx = i4 WITH protect, noconstant(0)
     DECLARE toparamcnt = i4 WITH protect, noconstant(0)
     FOR (fromidx = 1 TO fromcnt)
       SET toidx += 1
       SET stat = alterlist(prtorecord->status_detail.details,toidx)
       SET prtorecord->status_detail.details[toidx].entityid = pfromrecord->status_detail.details[
       fromidx].entityid
       SET prtorecord->status_detail.details[toidx].detailflag = pfromrecord->status_detail.details[
       fromidx].detailflag
       SET prtorecord->status_detail.details[toidx].detailmessage = pfromrecord->status_detail.
       details[fromidx].detailmessage
       SET toparamcnt = 0
       FOR (fromparamidx = 1 TO size(pfromrecord->status_detail.details[fromidx].parameters,5))
         SET toparamcnt += 1
         SET stat = alterlist(prtorecord->status_detail.details[toidx].parameters,toparamcnt)
         SET prtorecord->status_detail.details[toidx].parameters[toparamcnt].paramname = pfromrecord
         ->status_detail.details[fromidx].parameters[fromparamidx].paramname
         SET prtorecord->status_detail.details[toidx].parameters[toparamcnt].paramvalue = pfromrecord
         ->status_detail.details[fromidx].parameters[fromparamidx].paramvalue
       ENDFOR
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addstatusdetailparam,char(128))=char(128))
  SUBROUTINE (addstatusdetailparam(pdetailidx=i4,pparamname=vc,pparamvalue=vc) =null)
    IF (validate(reply->status_detail))
     IF (validate(reply->status_detail.details[pdetailidx].parameters))
      DECLARE paramcnt = i4 WITH protect, noconstant((size(reply->status_detail.details[pdetailidx].
        parameters,5)+ 1))
      SET stat = alterlist(reply->status_detail.details[pdetailidx].parameters,paramcnt)
      SET reply->status_detail.details[pdetailidx].parameters[paramcnt].paramname = pparamname
      SET reply->status_detail.details[pdetailidx].parameters[paramcnt].paramvalue = pparamvalue
     ENDIF
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(copytracemessages,char(128))=char(128))
  SUBROUTINE (copytracemessages(pfromrecord=vc(ref),prtorecord=vc(ref)) =null)
    IF (validate(pfromrecord->failure_stack)
     AND validate(prtorecord->failure_stack))
     DECLARE fromidx = i4 WITH protect, noconstant(0)
     DECLARE fromcnt = i4 WITH protect, noconstant(size(pfromrecord->failure_stack.failures,5))
     DECLARE toidx = i4 WITH protect, noconstant(size(prtorecord->failure_stack.failures,5))
     FOR (fromidx = 1 TO fromcnt)
       SET toidx += 1
       SET stat = alterlist(prtorecord->failure_stack.failures,toidx)
       SET prtorecord->failure_stack.failures[toidx].programname = pfromrecord->failure_stack.
       failures[fromidx].programname
       SET prtorecord->failure_stack.failures[toidx].routinename = pfromrecord->failure_stack.
       failures[fromidx].routinename
       SET prtorecord->failure_stack.failures[toidx].message = pfromrecord->failure_stack.failures[
       fromidx].message
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
 CALL beginservice("709419")
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD t_record
 RECORD t_record(
   1 columns_cnt = i4
   1 columns[*]
     2 name = vc
     2 type = vc
     2 value = vc
   1 exclude_cols_cnt = i4
   1 exclude_cols[*]
     2 name = vc
 )
 DECLARE delete_encounter_level_data(null) = null
 DECLARE delete_patient_level_data(null) = null
 DECLARE delete_correspondence_documents(null) = null
 DECLARE is_patient_protected(null) = i2
 DECLARE family_cd = f8 WITH protect, constant(load_code_value(351,"FAMILY"))
 DECLARE family_hist_cd = f8 WITH protect, constant(load_code_value(351,"FAMILYHIST"))
 DECLARE confid_protected_cd = f8 WITH protect, constant(load_code_value(87,"PROTECTED"))
 DECLARE confid_prohibited_cd = f8 WITH protect, constant(load_code_value(87,"PROHIBITED"))
 DECLARE error_message = vc WITH protect, noconstant("")
 IF (validate(request,0))
  FREE RECORD registration_request
  RECORD registration_request(
    1 person_id = f8
    1 encntr_id = f8
    1 transaction_id = f8
    1 pm_hist_tracking_id = f8
    1 transaction_dt_tm = dq8
    1 transaction_type_txt = vc
    1 swap_person_id = f8
    1 swap_encntr_id = f8
    1 swap_transaction_id = f8
  )
  IF (validate(request->patientid)=1)
   SET registration_request->person_id = request->patientid
  ENDIF
  IF (validate(request->encounterid)=1)
   SET registration_request->encntr_id = request->encounterid
  ENDIF
  IF (validate(request->transactionid)=1)
   SET registration_request->transaction_id = request->transactionid
  ENDIF
  IF (validate(request->transactionhistoryid)=1)
   SET registration_request->pm_hist_tracking_id = request->transactionhistoryid
  ENDIF
  IF (validate(request->transactiondatetime)=1)
   SET registration_request->transaction_dt_tm = request->transactiondatetime
  ENDIF
  IF (validate(request->transactiontype)=1)
   SET registration_request->transaction_type_txt = request->transactiontype
  ENDIF
  IF (validate(request->swappatientid)=1)
   SET registration_request->swap_person_id = request->swappatientid
  ENDIF
  IF (validate(request->swapencounterid)=1)
   SET registration_request->swap_encntr_id = request->swapencounterid
  ENDIF
  IF (validate(request->swaptransactionid)=1)
   SET registration_request->swap_transaction_id = request->swaptransactionid
  ENDIF
 ENDIF
 IF ((registration_request->person_id <= 0.0))
  CALL exitservicefailure("Invalid Request - Person ID is zero.",true)
 ENDIF
 IF (is_patient_protected(null))
  CALL delete_encounter_level_data(null)
  CALL delete_correspondence_documents(null)
  CALL delete_patient_level_data(null)
 ENDIF
 CALL exitservicesuccess("acs_del_protected_patient completed successfully.")
 SUBROUTINE is_patient_protected(null)
   DECLARE protected_ind = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM person p
    WHERE (p.person_id=registration_request->person_id)
     AND p.confid_level_cd IN (confid_protected_cd, confid_prohibited_cd)
    DETAIL
     protected_ind = 1
    WITH nocounter
   ;end select
   RETURN(protected_ind)
 END ;Subroutine
 SUBROUTINE delete_encounter_level_data(null)
   DELETE  FROM encntr_person_reltn_hist eprh
    WHERE eprh.encntr_id IN (
    (SELECT
     e.encntr_id
     FROM encounter e
     WHERE (e.person_id=registration_request->person_id)))
     AND  NOT (eprh.person_reltn_type_cd IN (family_cd, family_hist_cd))
     AND eprh.encntr_person_reltn_hist_id != 0.0
    WITH nocounter
   ;end delete
   CALL check_error("ENCNTR_PERSON_RELTN_HIST")
   DELETE  FROM encntr_person_reltn epr
    WHERE epr.encntr_id IN (
    (SELECT
     e.encntr_id
     FROM encounter e
     WHERE (e.person_id=registration_request->person_id)))
     AND  NOT (epr.person_reltn_type_cd IN (family_cd, family_hist_cd))
     AND epr.encntr_person_reltn_id != 0.0
    WITH nocounter
   ;end delete
   CALL check_error("ENCNTR_PERSON_RELTN")
   DELETE  FROM encntr_social_health_hist eshh
    WHERE eshh.encntr_social_healthcare_id IN (
    (SELECT
     esh.encntr_social_healthcare_id
     FROM encntr_social_healthcare esh
     WHERE esh.encntr_id IN (
     (SELECT
      e.encntr_id
      FROM encounter e
      WHERE (e.person_id=registration_request->person_id)))))
     AND eshh.encntr_social_health_hist_id != 0.0
    WITH nocounter
   ;end delete
   CALL check_error("ENCNTR_SOCIAL_HEALTH_HIST")
   DELETE  FROM encntr_social_healthcare esh
    WHERE esh.encntr_id IN (
    (SELECT
     e.encntr_id
     FROM encounter e
     WHERE (e.person_id=registration_request->person_id)))
     AND ((esh.active_ind=0) OR (((esh.beg_effective_dt_tm > cnvtdatetime(sysdate)) OR (esh
    .end_effective_dt_tm < cnvtdatetime(sysdate))) ))
     AND esh.encntr_social_healthcare_id != 0.0
    WITH nocounter
   ;end delete
   CALL check_error("ENCNTR_SOCIAL_HEALTHCARE")
   CALL blank_social_healthcare("ENCNTR_SOCIAL_HEALTHCARE")
 END ;Subroutine
 SUBROUTINE delete_correspondence_documents(null)
   DELETE  FROM long_blob lb
    WHERE lb.parent_entity_id IN (
    (SELECT
     ppd.pm_post_doc_id
     FROM pm_post_doc ppd
     WHERE ppd.parent_entity_id IN (
     (SELECT
      se.sch_event_id
      FROM sch_event se
      WHERE se.sch_event_id IN (
      (SELECT
       sep.sch_event_id
       FROM sch_event_patient sep
       WHERE (sep.person_id=registration_request->person_id)))))
      AND ppd.parent_entity_name="SCH_EVENT"))
     AND lb.parent_entity_name="PM_POST_DOC"
     AND lb.long_blob_id != 0.0
    WITH nocounter
   ;end delete
   CALL check_error("LONG_BLOB for SCH_EVENT")
   DELETE  FROM long_blob lb
    WHERE lb.parent_entity_id IN (
    (SELECT
     ppd.pm_post_doc_id
     FROM pm_post_doc ppd
     WHERE ppd.parent_entity_id IN (
     (SELECT
      e.encntr_id
      FROM encounter e
      WHERE (e.person_id=registration_request->person_id)))
      AND ppd.parent_entity_name="ENCOUNTER"))
     AND lb.parent_entity_name="PM_POST_DOC"
     AND lb.long_blob_id != 0.0
    WITH nocounter
   ;end delete
   CALL check_error("LONG_BLOB for ENCOUNTER")
   DELETE  FROM long_blob lb
    WHERE lb.parent_entity_id IN (
    (SELECT
     ppd.pm_post_doc_id
     FROM pm_post_doc ppd
     WHERE (ppd.parent_entity_id=registration_request->person_id)
      AND ppd.parent_entity_name="PERSON"))
     AND lb.parent_entity_name="PM_POST_DOC"
     AND lb.long_blob_id != 0.0
    WITH nocounter
   ;end delete
   CALL check_error("LONG_BLOB for PERSON")
 END ;Subroutine
 SUBROUTINE delete_patient_level_data(null)
   DELETE  FROM address_hist ah
    WHERE ah.address_id IN (
    (SELECT
     a.address_id
     FROM address a
     WHERE (a.parent_entity_id=registration_request->person_id)
      AND a.parent_entity_name="PERSON"))
     AND ah.address_hist_id != 0.0
    WITH nocounter
   ;end delete
   CALL check_error("ADDRESS_HIST")
   DELETE  FROM address a
    WHERE (a.parent_entity_id=registration_request->person_id)
     AND a.parent_entity_name="PERSON"
     AND a.address_id != 0.0
    WITH nocounter
   ;end delete
   CALL check_error("ADDRESS")
   DELETE  FROM phone_hist ph
    WHERE ph.phone_id IN (
    (SELECT
     p.phone_id
     FROM phone p
     WHERE (p.parent_entity_id=registration_request->person_id)
      AND p.parent_entity_name IN ("PERSON_PATIENT", "PERSON")))
     AND ph.phone_hist_id != 0.0
    WITH nocounter
   ;end delete
   CALL check_error("PHONE_HIST")
   DELETE  FROM phone p
    WHERE (p.parent_entity_id=registration_request->person_id)
     AND p.parent_entity_name IN ("PERSON_PATIENT", "PERSON")
     AND p.phone_id != 0.0
    WITH nocounter
   ;end delete
   CALL check_error("PHONE")
   DELETE  FROM person_person_reltn_hist pprh
    WHERE (pprh.person_id=registration_request->person_id)
     AND  NOT (pprh.person_reltn_type_cd IN (family_cd, family_hist_cd))
     AND pprh.person_person_reltn_hist_id != 0.0
    WITH nocounter
   ;end delete
   CALL check_error("PERSON_PERSON_RELTN_HIST")
   DELETE  FROM person_person_reltn ppr
    WHERE (ppr.person_id=registration_request->person_id)
     AND  NOT (ppr.person_reltn_type_cd IN (family_cd, family_hist_cd))
     AND ppr.person_person_reltn_id != 0.0
    WITH nocounter
   ;end delete
   CALL check_error("PERSON_PERSON_RELTN")
   DELETE  FROM person_social_health_hist pshh
    WHERE pshh.person_social_healthcare_id IN (
    (SELECT
     psh.person_social_healthcare_id
     FROM person_social_healthcare psh
     WHERE (psh.person_id=registration_request->person_id)))
     AND pshh.person_social_health_hist_id != 0.0
    WITH nocounter
   ;end delete
   CALL check_error("PERSON_SOCIAL_HEALTH_HIST")
   DELETE  FROM person_social_healthcare psh
    WHERE (psh.person_id=registration_request->person_id)
     AND ((psh.active_ind=0) OR (((psh.beg_effective_dt_tm > cnvtdatetime(sysdate)) OR (psh
    .end_effective_dt_tm < cnvtdatetime(sysdate))) ))
     AND psh.person_social_healthcare_id != 0.0
    WITH nocounter
   ;end delete
   CALL check_error("PERSON_SOCIAL_HEALTH")
   CALL blank_social_healthcare("PERSON_SOCIAL_HEALTHCARE")
 END ;Subroutine
 SUBROUTINE (blank_social_healthcare(table_name=vc) =null)
   DECLARE social_column_list = vc WITH protect, noconstant("")
   DECLARE social_update_stmt = vc WITH protect, noconstant("")
   DECLARE default_value = vc WITH protect, noconstant("")
   DECLARE where_clause = vc WITH protect, noconstant("")
   DECLARE column_idx = i4 WITH protect, noconstant(0)
   SET stat = initrec(t_record)
   SET t_record->exclude_cols_cnt = 25
   SET stat = alterlist(t_record->exclude_cols,t_record->exclude_cols_cnt)
   SET t_record->exclude_cols[1].name = "PERSON_ID"
   SET t_record->exclude_cols[2].name = "ENCNTR_ID"
   SET t_record->exclude_cols[3].name = "UPDT_DT_TM"
   SET t_record->exclude_cols[4].name = "UPDT_APPLCTX"
   SET t_record->exclude_cols[5].name = "UPDT_CNT"
   SET t_record->exclude_cols[6].name = "UPDT_ID"
   SET t_record->exclude_cols[7].name = "UPDT_TASK"
   SET t_record->exclude_cols[8].name = "ACTIVE_STATUS_CD"
   SET t_record->exclude_cols[9].name = "ACTIVE_STATUS_DT_TM"
   SET t_record->exclude_cols[10].name = "ACTIVE_STATUS_PRSNL_ID"
   SET t_record->exclude_cols[11].name = "ACTIVE_IND"
   SET t_record->exclude_cols[12].name = "BEG_EFFECTIVE_DT_TM"
   SET t_record->exclude_cols[13].name = "END_EFFECTIVE_DT_TM"
   SET t_record->exclude_cols[14].name = "ADMIN_REGION_CD"
   SET t_record->exclude_cols[15].name = "DEREGISTRATION_REASON_CD"
   SET t_record->exclude_cols[16].name = "DEREGISTRATION_DT_TM"
   SET t_record->exclude_cols[17].name = "CHARGING_CATEGORY_CD"
   SET t_record->exclude_cols[18].name = "ENCNTR_SOCIAL_HEALTHCARE_ID"
   SET t_record->exclude_cols[19].name = "PERSON_SOCIAL_HEALTHCARE_ID"
   SET t_record->exclude_cols[20].name = "VERIFY_PRSNL_ID"
   SET t_record->exclude_cols[21].name = "VERIFY_SOURCE_CD"
   SET t_record->exclude_cols[22].name = "VERIFY_STATUS_CD"
   SET t_record->exclude_cols[23].name = "INST_ID"
   SET t_record->exclude_cols[24].name = "TXN_ID_TEXT"
   SET t_record->exclude_cols[25].name = "LAST_UTC_TS"
   SELECT INTO "nl:"
    FROM user_tab_cols utc
    WHERE utc.table_name=table_name
     AND ((utc.hidden_column="YES") OR (utc.virtual_column="YES"))
    HEAD REPORT
     null
    DETAIL
     t_record->exclude_cols_cnt += 1, stat = alterlist(t_record->exclude_cols,t_record->
      exclude_cols_cnt), t_record->exclude_cols[t_record->exclude_cols_cnt].name = utc.column_name
    FOOT REPORT
     stat = alterlist(t_record->exclude_cols,t_record->exclude_cols_cnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM dtable t,
     dtableattr a,
     dtableattrl l
    WHERE t.table_name=table_name
     AND t.table_name=a.table_name
     AND l.structtype="F"
     AND btest(l.stat,11)=0
     AND  NOT (expand(column_idx,1,t_record->exclude_cols_cnt,l.attr_name,t_record->exclude_cols[
     column_idx].name))
    ORDER BY l.attr_name
    HEAD REPORT
     t_record->columns_cnt = 0
    DETAIL
     t_record->columns_cnt += 1
     IF (mod(t_record->columns_cnt,10)=1)
      stat = alterlist(t_record->columns,(t_record->columns_cnt+ 9))
     ENDIF
     IF ((t_record->columns_cnt > 1))
      social_column_list = concat(social_column_list,",SHC.",l.attr_name)
     ELSE
      social_column_list = concat("SHC.",l.attr_name)
     ENDIF
     t_record->columns[t_record->columns_cnt].name = l.attr_name
     IF (l.type="F")
      t_record->columns[t_record->columns_cnt].type = "F8"
     ELSEIF (l.type="I")
      t_record->columns[t_record->columns_cnt].type = "I4"
     ELSEIF (l.type="C")
      IF (btest(l.stat,13))
       t_record->columns[t_record->columns_cnt].type = "VC"
      ELSE
       t_record->columns[t_record->columns_cnt].type = build(l.type,l.len)
      ENDIF
     ELSEIF (l.type="Q")
      t_record->columns[t_record->columns_cnt].type = "DQ8"
     ENDIF
    FOOT REPORT
     IF (mod(t_record->columns_cnt,10) != 0)
      stat = alterlist(t_record->columns,t_record->columns_cnt)
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM all_tab_columns c,
     (dummyt d  WITH seq = value(t_record->columns_cnt))
    PLAN (d)
     JOIN (c
     WHERE c.table_name=table_name
      AND (c.column_name=t_record->columns[d.seq].name))
    DETAIL
     t_record->columns[d.seq].value = c.data_default
    WITH nocounter
   ;end select
   SET social_update_stmt = concat("update into ",table_name," SHC "," set (",social_column_list,
    ",updt_applctx, updt_cnt, updt_dt_tm, ","updt_id, updt_task) (","select ")
   FOR (column_idx = 1 TO t_record->columns_cnt)
     SET default_value = t_record->columns[column_idx].value
     IF ((t_record->columns[column_idx].type="DQ8"))
      IF (textlen(default_value) > 0)
       SET default_value = concat("cnvtdatetime('",t_record->columns[column_idx].value,"')")
      ELSE
       SET default_value = "null"
      ENDIF
     ELSEIF ((t_record->columns[column_idx].type="*C*"))
      SET default_value = concat("'",t_record->columns[column_idx].value,"'")
     ENDIF
     IF (column_idx=1)
      SET social_update_stmt = concat(social_update_stmt," ",default_value)
     ELSE
      SET social_update_stmt = concat(social_update_stmt,",",default_value)
     ENDIF
   ENDFOR
   IF (table_name="ENCNTR_SOCIAL_HEALTHCARE")
    SET where_clause = concat(" where SHC.encntr_id in (select e.encntr_id from encounter e ",
     "where e.person_id = registration_request->person_id)")
   ELSE
    SET where_clause = " where SHC.person_id = registration_request->person_id"
   ENDIF
   SET where_clause = concat(where_clause," and SHC.active_ind = 1 and ",
    "SHC.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3) and ",
    "SHC.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
   SET social_update_stmt = concat(social_update_stmt,", reqinfo->updt_applctx, SHC.updt_cnt + 1,",
    "cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task "," from dual)",
    where_clause,
    " with nocounter go")
   CALL parser(social_update_stmt,1)
   CALL check_error(table_name)
 END ;Subroutine
 SUBROUTINE (check_error(table_name=vc) =null)
   IF (error(error_message,0) != 0)
    CALL exitservicefailure(build("Error deleting or updating table: ",table_name," : ",error_message
      ),true)
   ENDIF
 END ;Subroutine
 SUBROUTINE (load_code_value(code_set=i4,cdf_meaning=vc) =f8)
   DECLARE t_code_value = f8 WITH private, noconstant(0.0)
   SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),1,t_code_value)
   IF (((stat != 0) OR (t_code_value <= 0.0)) )
    CALL exitservicefailure(build("ERROR: loading code value for code set: ",code_set,
      " with cdf meaning: ",cdf_meaning),true)
   ENDIF
   RETURN(t_code_value)
 END ;Subroutine
#exit_script
END GO

CREATE PROGRAM dm_call_combine:dba
 IF (validate(dcue_upt_exc_reply->message,"YYY")="YYY"
  AND validate(dcue_upt_exc_reply->message,"zzz")="zzz")
  FREE RECORD dcue_upt_exc_reply
  RECORD dcue_upt_exc_reply(
    1 status = c1
    1 message = c255
    1 error_table = c30
  )
 ENDIF
 CALL echo("*****pm_confid_lvl_compatibility.inc - 696026*****")
 SUBROUTINE (isconfidentialitylevelcompatible(dperson1id=f8,dperson2id=f8) =i2 WITH protect)
   DECLARE d_prohibited_confid_level_cd = f8 WITH constant(uar_get_code_by("MEANING",87,"PROHIBITED")
    ), protect
   DECLARE d_protected_confid_level_cd = f8 WITH constant(uar_get_code_by("MEANING",87,"PROTECTED")),
   protect
   DECLARE dperson1confidlevelcd = f8 WITH noconstant(0.0), protect
   DECLARE dperson2confidlevelcd = f8 WITH noconstant(0.0), protect
   IF (d_prohibited_confid_level_cd <= 0.0
    AND d_protected_confid_level_cd <= 0.0)
    RETURN(true)
   ENDIF
   SELECT INTO "nl:"
    FROM person p
    WHERE p.person_id IN (dperson1id, dperson2id)
    DETAIL
     IF (p.person_id=dperson1id)
      dperson1confidlevelcd = p.confid_level_cd
     ELSE
      dperson2confidlevelcd = p.confid_level_cd
     ENDIF
    WITH nocounter
   ;end select
   IF (isprohibitedorprotected(dperson1confidlevelcd,d_prohibited_confid_level_cd,
    d_protected_confid_level_cd)=isprohibitedorprotected(dperson2confidlevelcd,
    d_prohibited_confid_level_cd,d_protected_confid_level_cd))
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE (isprohibitedorprotected(dconfidlevelcd=f8,dprohibitedcd=f8,dprotectedcd=f8) =i2 WITH
  protect)
  IF (dconfidlevelcd > 0.0
   AND dconfidlevelcd IN (dprohibitedcd, dprotectedcd))
   RETURN(true)
  ENDIF
  RETURN(false)
 END ;Subroutine
 DECLARE serrormessage = vc WITH protect, noconstant("")
 DECLARE app_hna_combine = i4 WITH protect, constant(70000)
 DECLARE task_run_combine = i4 WITH protect, constant(70000)
 IF (validate(cmb_notify_events->events,"NONE")="NONE")
  FREE RECORD cmb_notify_events
  RECORD cmb_notify_events(
    1 events[*]
      2 event_type = c12
      2 primary_ind = i2
      2 combine_id = f8
      2 parent_table = c50
      2 from_xxx_id = f8
      2 to_xxx_id = f8
      2 encntr_id = f8
      2 reverse_cmb_ind = i2
  ) WITH protect
 ENDIF
 SUBROUTINE (cmb_notify(cmb_notify_req=vc(ref)) =null)
   DECLARE applicationnumber = i4 WITH protect, noconstant(reqinfo->updt_app)
   DECLARE tasknumber = i4 WITH protect, noconstant(reqinfo->updt_task)
   DECLARE notifyemsg = vc WITH protect, noconstant("")
   DECLARE notifyecode = i4 WITH protect, noconstant(0)
   IF ( NOT (check_if_authorized_request(applicationnumber)))
    SET applicationnumber = app_hna_combine
    SET tasknumber = task_run_combine
   ENDIF
   IF (size(cmb_notify_req->events,5) > 0)
    DECLARE ireqid = i4 WITH protect, constant(50002)
    SET stat = tdbexecute(applicationnumber,tasknumber,ireqid,"REC",cmb_notify_req,
     "REC",replyout)
    IF (stat != 0)
     SET notifyecode = error(notifyemsg,1)
     SET serrormessage = "tdbexecute"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = cnvtstring(stat,10)
    ENDIF
   ELSE
    SET serrormessage = "cmb_notify_req list size is zero."
   ENDIF
   IF (textlen(trim(serrormessage,3)) > 0)
    SET reply->status_data.subeventstatus[1].operationname = trim(serrormessage)
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = curprog
   ENDIF
   SET stat = initrec(cmb_notify_req)
   SET reply->status_data.status = "S"
 END ;Subroutine
 SUBROUTINE (transfer_notify_data(seventtype=c12,bprimaryind=i2,dcombineid=f8,sparenttable=c50,
  dfromid=f8,dtoid=f8,dencntrid=f8,cmb_notify_req=vc(ref),breversecmbind=i2(value,0)) =null)
   DECLARE lcount = i4 WITH noconstant(0), protect
   DECLARE listsize = i4 WITH noconstant(0), protect
   SET listsize = size(cmb_notify_req->events,5)
   IF ( NOT (locateval(lcount,1,listsize,dcombineid,cmb_notify_req->events[lcount].combine_id,
    sparenttable,cmb_notify_req->events[lcount].parent_table)))
    SET listsize += 1
    SET stat = alterlist(cmb_notify_req->events,listsize)
    SET cmb_notify_req->events[listsize].event_type = seventtype
    SET cmb_notify_req->events[listsize].primary_ind = bprimaryind
    SET cmb_notify_req->events[listsize].combine_id = dcombineid
    SET cmb_notify_req->events[listsize].parent_table = sparenttable
    SET cmb_notify_req->events[listsize].from_xxx_id = dfromid
    SET cmb_notify_req->events[listsize].to_xxx_id = dtoid
    SET cmb_notify_req->events[listsize].encntr_id = dencntrid
    SET cmb_notify_req->events[listsize].reverse_cmb_ind = breversecmbind
   ENDIF
 END ;Subroutine
 SUBROUTINE (check_if_authorized_request(application=i4) =i2)
   DECLARE app_hna_organization_tool = i4 WITH protect, constant(18000)
   DECLARE app_hna_location_combine = i4 WITH protect, constant(33000)
   DECLARE app_first_net = i4 WITH protect, constant(4250111)
   DECLARE app_hna_combine_old = i4 WITH protect, constant(100102)
   DECLARE app_hna_combine2 = i4 WITH protect, constant(4249915)
   IF (((application=app_hna_organization_tool) OR (((application=app_hna_location_combine) OR (((
   application=app_hna_combine) OR (((application=app_first_net) OR (((application=
   app_hna_combine_old) OR (application=app_hna_combine2)) )) )) )) )) )
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SET dcc_updt_task = 0
 SET dcc_updt_task = reqinfo->updt_task
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 xxx_combine_id[*]
      2 combine_id = f8
      2 parent_table = c50
      2 from_xxx_id = f8
      2 to_xxx_id = f8
      2 encntr_id = f8
    1 error[*]
      2 create_dt_tm = dq8
      2 parent_table = c50
      2 from_id = f8
      2 to_id = f8
      2 encntr_id = f8
      2 error_table = c32
      2 error_type = vc
      2 error_msg = vc
      2 combine_error_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 RECORD rcmbenc(
   1 enc[*]
     2 person_combine_id = f8
     2 from_encntr_id = f8
     2 to_encntr_id = f8
     2 encntr_combine_id = f8
   1 enc_size = i2
   1 warn[*]
     2 person_combine_id = f8
     2 from_id = f8
     2 to_id = f8
     2 encntr_id = f8
     2 msg = vc
   1 warn_size = i2
 )
 RECORD rcmbprsnl(
   1 qual[*]
     2 person_combine_id = f8
     2 from_prsnl_id = f8
     2 to_prsnl_id = f8
     2 prsnl_combine_id = f8
     2 cmb_group_id = f8
   1 size = i2
   1 error[*]
     2 create_dt_tm = dq8
     2 parent_table = c50
     2 from_id = f8
     2 to_id = f8
     2 encntr_id = f8
     2 error_table = c32
     2 error_type = vc
     2 error_msg = vc
 )
 SET dm_debug_cmb = 0
 IF (validate(dm_debug,0) > 0)
  SET dm_debug_cmb = 1
 ENDIF
 DECLARE dm_new_nbr = f8
 DECLARE next_seq_val = f8
 DECLARE dcc_context_obj_ind = i2 WITH protect, noconstant(0)
 DECLARE reverse_cmb_ind = i2 WITH protect, noconstant(0)
 DECLARE seventtype = c12 WITH noconstant("")
 SET rcmbenc->enc_size = 0
 SET rcmbenc->warn_size = 0
 SET rcmbprsnl->size = 0
 SET prsnl_cnt = 0
 SET trace = errorclear
 SET meaning = fillstring(12," ")
 SET error_table = fillstring(32," ")
 SET dm_appl_flag = 0
 SET dcc_emsg = fillstring(132," ")
 SET dcc_ecode = 0
 SET dcc_dummy = 0
 SET init_updt_cnt = 0
 SET dcc_failed = false
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET data_error = 14
 SET general_error = 15
 SET reactivate_error = 16
 SET eff_error = 17
 SET ccl_error = 18
 SET recalc_error = 19
 SET gdpr_error = 20
 SET commit_error = 21
 SET confidentiality_level_error = 22
 SET call_script = fillstring(30," ")
 SET call_script = "DM_CALL_COMBINE"
 SET parent_combine_id = 0
 SET reply_cnt = 0
 SET error_cnt = 0
 IF (validate(child_ind,3)=3)
  SET child_ind = 0
 ENDIF
 IF (validate(request->reverse_cmb_ind))
  SET reverse_cmb_ind = request->reverse_cmb_ind
 ENDIF
 CASE (request->parent_table)
  OF "PERSON":
  OF "ENCOUNTER":
  OF "PRSNL":
  OF "ORGANIZATION":
  OF "LOCATION":
  OF "HEALTH_PLAN":
   IF (dm_debug_cmb=1)
    CALL echo(concat("Combine parent_table: ",request->parent_table))
   ENDIF
  ELSE
   SET error_table = request->parent_table
   SET dcc_failed = general_error
   SET request->error_message = substring(1,132,concat("An invalid combine type was provided: ",
     request->parent_table))
   GO TO dcc_check_error
 ENDCASE
 SELECT INTO "nl:"
  uo.object_name, uo.object_type, uo.status
  FROM user_objects uo
  WHERE uo.object_type="PROCEDURE"
   AND uo.object_name="DM2_CONTEXT_CONTROL"
   AND uo.status="VALID"
  DETAIL
   dcc_context_obj_ind = 1
  WITH nocounter
 ;end select
 SET dcc_ecode = error(dcc_emsg,1)
 IF (dcc_ecode != 0)
  SET error_table = "USER_OBJECTS"
  SET dcc_failed = select_error
  GO TO dcc_check_error
 ENDIF
 IF (dcc_context_obj_ind=1)
  CALL parser(concat("RDB ASIS(^ BEGIN DM2_CONTEXT_CONTROL('COMBINE','",trim(request->parent_table),
    "'); END; ^) GO"),1)
  IF (error(dcc_emsg,1) != 0)
   SET dcc_context_obj_ind = 0
  ENDIF
 ENDIF
 IF ((request->parent_table="PERSON"))
  SET enc_cmb = 0.0
  SET meaning = "ENCNTRCMB"
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE c.cdf_meaning=meaning
    AND c.code_set=327
    AND c.active_ind=true
    AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
    AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
   DETAIL
    enc_cmb = c.code_value
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET dcc_failed = data_error
   SET request->error_message =
   "No active, effective code_value exists for cdf_meaning 'ENCNTRCMB' for code_set 327"
   SET error_table = "CODE_VALUE"
   GO TO dcc_check_error
  ENDIF
  SET prsnl_cmb = 0.0
  SET meaning = "PRSNLCMB"
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE c.cdf_meaning=meaning
    AND c.code_set=327
    AND c.active_ind=true
    AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
    AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
   DETAIL
    prsnl_cmb = c.code_value
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->xxx_combine_id,0)
 SET dm_tot_num = size(request->xxx_combine,5)
 SET dcc_ecode = error(dcc_emsg,1)
 IF (dcc_ecode != 0)
  SET error_table = "size() function"
  SET dcc_failed = ccl_error
  GO TO dcc_check_error
 ENDIF
 IF (dm_tot_num > 0)
  FREE RECORD cmb_drr_request
  RECORD cmb_drr_request(
    1 parent_table = vc
    1 from_xxx_id = f8
    1 to_xxx_id = f8
    1 person_id = f8
  )
  FREE RECORD cmb_drr_reply
  RECORD cmb_drr_reply(
    1 status = c1
    1 message = vc
    1 gdpr_ind = i2
  )
  SET cmb_drr_request->parent_table = request->parent_table
  FOR (dm_x = 1 TO dm_tot_num)
    SET stat = initrec(cmb_drr_request)
    SET stat = initrec(cmb_drr_reply)
    SET cmb_drr_request->from_xxx_id = request->xxx_combine[dm_x].from_xxx_id
    SET cmb_drr_request->to_xxx_id = request->xxx_combine[dm_x].to_xxx_id
    SET cmb_drr_request->person_id = 0.00
    IF ((request->parent_table="PERSON"))
     SELECT INTO "nl:"
      p.person_id
      FROM prsnl p
      WHERE (((p.person_id=cmb_drr_request->from_xxx_id)) OR ((p.person_id=cmb_drr_request->to_xxx_id
      )))
      WITH nocounter
     ;end select
     IF (curqual > 0)
      SET cmb_drr_request->parent_table = "PRSNL"
     ELSE
      SET cmb_drr_request->parent_table = "PERSON"
     ENDIF
    ELSE
     SET cmb_drr_request->parent_table = request->parent_table
    ENDIF
    IF ((request->parent_table="ENCOUNTER"))
     SELECT INTO "nl:"
      e.person_id
      FROM encounter e
      WHERE (e.encntr_id=cmb_drr_request->from_xxx_id)
      DETAIL
       cmb_drr_request->person_id = e.person_id
      WITH nocounter
     ;end select
     IF ((cmb_drr_request->person_id=0.00))
      SET error_table = request->parent_table
      SET dcc_failed = data_error
      SET request->error_message = concat("The PERSON_ID could not be found for ENCOUNTER : ",trim(
        cnvtstring(cmb_drr_request->from_xxx_id)))
      GO TO dcc_check_error
     ENDIF
    ENDIF
    EXECUTE daf_cmb_check_drr_allowed
    IF ((cmb_drr_reply->status != "S"))
     SET error_table = cmb_drr_request->parent_table
     SET dcc_failed = data_error
     SET request->error_message = cmb_drr_reply->message
     GO TO dcc_check_error
    ENDIF
  ENDFOR
  DECLARE daf_cmb_key_column = vc WITH protect, noconstant("")
  IF ((request->parent_table="PERSON"))
   SET daf_cmb_key_column = "PERSON_ID"
  ELSEIF ((request->parent_table="ENCOUNTER"))
   SET daf_cmb_key_column = "ENCNTR_ID"
  ELSEIF ((request->parent_table="PRSNL"))
   SET daf_cmb_key_column = "PERSON_ID"
  ELSEIF ((request->parent_table="LOCATION"))
   SET daf_cmb_key_column = "LOCATION_CD"
  ELSEIF ((request->parent_table="ORGANIZATION"))
   SET daf_cmb_key_column = "ORGANIZATION_ID"
  ELSEIF ((request->parent_table="HEALTH_PLAN"))
   SET daf_cmb_key_column = "HEALTH_PLAN_ID"
  ENDIF
  FOR (dm_x = 1 TO dm_tot_num)
    CALL parser("select into 'nl:' ")
    CALL parser(concat("  t.",daf_cmb_key_column))
    CALL parser(concat("from ",request->parent_table," t"))
    CALL parser(concat("where t.",daf_cmb_key_column," = request->xxx_combine[dm_x]->from_xxx_id"))
    CALL parser("with nocounter go")
    IF (curqual=0)
     SET error_table = request->parent_table
     SET dcc_failed = data_error
     SET request->error_message = concat("Could not find FROM ",trim(request->parent_table)," ID: ",
      trim(cnvtstring(request->xxx_combine[dm_x].from_xxx_id)))
     GO TO dcc_check_error
    ENDIF
    CALL parser("select into 'nl:' ")
    CALL parser(concat("  t.",daf_cmb_key_column))
    CALL parser(concat("from ",request->parent_table," t"))
    CALL parser(concat("where t.",daf_cmb_key_column," = request->xxx_combine[dm_x]->to_xxx_id"))
    CALL parser("with nocounter go")
    IF (curqual=0)
     SET error_table = request->parent_table
     SET dcc_failed = data_error
     SET request->error_message = concat("Could not find TO ",trim(request->parent_table)," ID: ",
      trim(cnvtstring(request->xxx_combine[dm_x].to_xxx_id)))
     GO TO dcc_check_error
    ENDIF
    IF ((request->xxx_combine[dm_x].encntr_id=0.0)
     AND (request->parent_table="PERSON")
     AND isconfidentialitylevelcompatible(request->xxx_combine[dm_x].from_xxx_id,request->
     xxx_combine[dm_x].to_xxx_id)=false)
     SET dcc_failed = confidentiality_level_error
     SET request->error_message = concat("Person ",trim(cnvtstring(request->xxx_combine[dm_x].
        from_xxx_id),3)," and Person ",trim(cnvtstring(request->xxx_combine[dm_x].to_xxx_id),3),
      " cannot be combined due to incompatible confid_level_cd values")
     GO TO dcc_check_error
    ENDIF
  ENDFOR
  SET reqinfo->updt_task = 100102
  IF ((request->cmb_mode != "TESTING")
   AND dm_debug_cmb != 1)
   CASE (cnvtupper(trim(request->parent_table,3)))
    OF "PERSON":
     EXECUTE dm_cmb_upt_exceptions "DM_PCMB*"
     IF ((dcue_upt_exc_reply->status != "S"))
      SET error_table = "dm_cmb_exception"
      SET request->error_message = "Error from dm_cmb_upt_exceptions 'DM_PCMB*' "
      SET dcc_failed = general_error
      GO TO dcc_check_error
     ENDIF
     EXECUTE dm_cmb_upt_exceptions "DM_ECMB*"
     IF ((dcue_upt_exc_reply->status != "S"))
      SET error_table = "Error from dm_cmb_upt_exceptions 'DM_ECMB*' "
      SET dcc_failed = general_error
      GO TO dcc_check_error
     ENDIF
     EXECUTE dm_cmb_upt_exceptions "DM_PRCMB*"
     IF ((dcue_upt_exc_reply->status != "S"))
      SET error_table = "dm_cmb_exception"
      SET request->error_message = "Error from dm_cmb_upt_exceptions 'DM_PRCMB*' "
      SET dcc_failed = general_error
      GO TO dcc_check_error
     ENDIF
    OF "ENCOUNTER":
     EXECUTE dm_cmb_upt_exceptions "DM_ECMB*"
     IF ((dcue_upt_exc_reply->status != "S"))
      SET error_table = "dm_cmb_exception"
      SET request->error_message = "Error from dm_cmb_upt_exceptions 'DM_ECMB*' "
      SET dcc_failed = general_error
      GO TO dcc_check_error
     ENDIF
    OF "LOCATION":
     EXECUTE dm_cmb_upt_exceptions "DM_LCMB*"
     IF ((dcue_upt_exc_reply->status != "S"))
      SET error_table = "dm_cmb_exception"
      SET request->error_message = "Error from dm_cmb_upt_exceptions 'DM_LCMB*' "
      SET dcc_failed = general_error
      GO TO dcc_check_error
     ENDIF
    OF "ORGANIZATION":
     EXECUTE dm_cmb_upt_exceptions "DM_OCMB*"
     IF ((dcue_upt_exc_reply->status != "S"))
      SET error_table = "dm_cmb_exception"
      SET request->error_message = "Error from dm_cmb_upt_exceptions 'DM_OCMB*' "
      SET dcc_failed = general_error
      GO TO dcc_check_error
     ENDIF
   ENDCASE
   EXECUTE dm_cmb_upt_metadata "DM_CMETA*"
   IF ((dcue_upt_exc_reply->status != "S"))
    SET error_table = "dm_cmb_exception"
    SET request->error_message = "Error from dm_cmb_upt_exceptions 'DM_OCMB*' "
    SET dcc_failed = general_error
    GO TO dcc_check_error
   ENDIF
  ENDIF
  CASE (request->parent_table)
   OF "PERSON":
   OF "ENCOUNTER":
    IF (dm_debug_cmb=1)
     CALL echo("Executing dm_combine for request record below...")
     CALL echorecord(request)
    ENDIF
    EXECUTE dm_combine
    IF (dm_debug_cmb=1)
     CALL echo("DM_COMBINE is done...")
    ENDIF
   ELSE
    IF (dm_debug_cmb=1)
     CALL echo("Executing dm_combine2 for request record below...")
     CALL echorecord(request)
    ENDIF
    EXECUTE dm_combine2
    IF (dm_debug_cmb=1)
     CALL echo("DM_COMBINE2 is done...")
    ENDIF
  ENDCASE
  IF ((request->parent_table="PERSON"))
   FOR (dm_x = 1 TO size(request->xxx_combine,5))
    IF ((request->xxx_combine[dm_x].encntr_id > 0.0))
     SET seventtype = "ENCNTRMOVE"
    ELSE
     SET seventtype = "COMBINE"
    ENDIF
    CALL transfer_notify_data(seventtype,evaluate(dm_x,1,1,0),request->xxx_combine[dm_x].
     xxx_combine_id,request->parent_table,request->xxx_combine[dm_x].from_xxx_id,
     request->xxx_combine[dm_x].to_xxx_id,request->xxx_combine[dm_x].encntr_id,cmb_notify_events,
     reverse_cmb_ind)
   ENDFOR
   IF (dm_debug_cmb=1)
    CALL echo("Check for prsnl combine...")
   ENDIF
   IF ((reqinfo->commit_ind=true)
    AND (rcmbprsnl->size > 0)
    AND prsnl_cmb != 0)
    SET stat = alterlist(request->xxx_combine,0)
    SET stat = alterlist(request->xxx_combine_det,0)
    SET prsnl_nbr_to_combine = rcmbprsnl->size
    SET stat = alterlist(request->xxx_combine,prsnl_nbr_to_combine)
    SET request->parent_table = "PRSNL"
    FOR (dm_x = 1 TO prsnl_nbr_to_combine)
      SET request->xxx_combine[dm_x].from_xxx_id = rcmbprsnl->qual[dm_x].from_prsnl_id
      SET request->xxx_combine[dm_x].to_xxx_id = rcmbprsnl->qual[dm_x].to_prsnl_id
      IF ((request->cmb_mode="RE-CMB"))
       IF (dm_debug_cmb=1)
        CALL echo(build("prsnl_combine_id =",rcmbprsnl->qual[dm_x].prsnl_combine_id))
       ENDIF
       SET request->xxx_combine[dm_x].xxx_combine_id = rcmbprsnl->qual[dm_x].prsnl_combine_id
      ENDIF
    ENDFOR
    IF (dm_debug_cmb=1)
     CALL echo("Perform PRSNL COMBINE...")
     CALL echorecord(request)
    ENDIF
    EXECUTE dm_combine2
    FOR (dm_x = 1 TO prsnl_nbr_to_combine)
      IF ((rcmbprsnl->qual[dm_x].prsnl_combine_id != 0))
       IF ((request->cmb_mode != "RE-CMB"))
        CALL add_prsnl_cmb_to_person_cmb_det(dcc_dummy)
       ELSE
        CALL upt_prsnl_cmb_to_person_cmb_det(dcc_dummy)
       ENDIF
      ENDIF
    ENDFOR
    FOR (dm_x = 1 TO size(request->xxx_combine,5))
     IF ((request->xxx_combine[dm_x].encntr_id > 0.0))
      SET seventtype = "ENCNTRMOVE"
     ELSE
      SET seventtype = "COMBINE"
     ENDIF
     CALL transfer_notify_data(seventtype,0,request->xxx_combine[dm_x].xxx_combine_id,request->
      parent_table,request->xxx_combine[dm_x].from_xxx_id,
      request->xxx_combine[dm_x].to_xxx_id,request->xxx_combine[dm_x].encntr_id,cmb_notify_events,
      reverse_cmb_ind)
    ENDFOR
    IF ((request->cmb_mode != "TESTING")
     AND dm_debug_cmb != 1)
     COMMIT
    ENDIF
   ENDIF
   IF (dm_debug_cmb=1)
    CALL echo("Check for auto encntr combine...")
   ENDIF
   IF ((rcmbenc->enc_size > 0))
    IF ((reqinfo->commit_ind=true)
     AND (rcmbenc->enc_size > 0))
     SET dm_appl_flag = request->xxx_combine[1].application_flag
     SET stat = alterlist(request->xxx_combine,0)
     SET stat = alterlist(request->xxx_combine_det,0)
     SET stat = alterlist(request->xxx_combine,rcmbenc->enc_size)
     SET request->parent_table = "ENCOUNTER"
     SET reply_size = 0
     SET reply_size = size(reply->xxx_combine_id,5)
     SET dcc_ecode = error(dcc_emsg,1)
     IF (dcc_ecode != 0)
      SET error_table = " "
      SET dcc_failed = ccl_error
      GO TO dcc_check_error
     ENDIF
     SELECT INTO "nl:"
      d1.seq
      FROM (dummyt d1  WITH seq = value(rcmbenc->enc_size)),
       (dummyt d2  WITH seq = value(reply_size))
      PLAN (d1)
       JOIN (d2
       WHERE (rcmbenc->enc[d1.seq].person_combine_id=reply->xxx_combine_id[d2.seq].combine_id))
      DETAIL
       request->xxx_combine[d1.seq].from_xxx_id = rcmbenc->enc[d1.seq].from_encntr_id, request->
       xxx_combine[d1.seq].to_xxx_id = rcmbenc->enc[d1.seq].to_encntr_id
       CASE (dm_appl_flag)
        OF 1:
         request->xxx_combine[d1.seq].application_flag = 51
        OF 2:
         request->xxx_combine[d1.seq].application_flag = 52
        OF 5:
         request->xxx_combine[d1.seq].application_flag = 55
        OF 10:
         request->xxx_combine[d1.seq].application_flag = 20
        OF 11:
         request->xxx_combine[d1.seq].application_flag = 21
        OF 12:
         request->xxx_combine[d1.seq].application_flag = 22
        OF 30:
         request->xxx_combine[d1.seq].application_flag = 60
       ENDCASE
      WITH nocounter
     ;end select
     IF (dm_debug_cmb=1)
      CALL echo("Perform ENCNTR COMBINE...")
      CALL echorecord(request)
     ENDIF
     EXECUTE dm_combine
     SET reply_cnt = size(reply->xxx_combine_id,5)
     SET dcc_ecode = error(dcc_emsg,1)
     IF (dcc_ecode != 0)
      SET error_table = "size() function"
      SET dcc_failed = ccl_error
      GO TO dcc_check_error
     ENDIF
     FOR (dm_x = 1 TO rcmbenc->enc_size)
      SELECT INTO "nl:"
       d.seq
       FROM (dummyt d  WITH seq = value(reply_cnt))
       PLAN (d
        WHERE (rcmbenc->enc[dm_x].from_encntr_id=reply->xxx_combine_id[d.seq].from_xxx_id)
         AND (rcmbenc->enc[dm_x].to_encntr_id=reply->xxx_combine_id[d.seq].to_xxx_id)
         AND (reply->xxx_combine_id[d.seq].parent_table="ENCOUNTER"))
       DETAIL
        rcmbenc->enc[dm_x].encntr_combine_id = reply->xxx_combine_id[d.seq].combine_id
       WITH nocounter
      ;end select
      IF (curqual=1)
       CALL add_to_person_cmb_det(dcc_dummy)
      ENDIF
     ENDFOR
     FOR (dm_x = 1 TO size(request->xxx_combine,5))
      IF ((request->xxx_combine[dm_x].encntr_id > 0.0))
       SET seventtype = "ENCNTRMOVE"
      ELSE
       SET seventtype = "COMBINE"
      ENDIF
      CALL transfer_notify_data(seventtype,0,request->xxx_combine[dm_x].xxx_combine_id,request->
       parent_table,request->xxx_combine[dm_x].from_xxx_id,
       request->xxx_combine[dm_x].to_xxx_id,request->xxx_combine[dm_x].encntr_id,cmb_notify_events)
     ENDFOR
     IF ((request->cmb_mode != "TESTING")
      AND dm_debug_cmb != 1)
      COMMIT
     ENDIF
     GO TO dcc_end_script
    ELSE
     GO TO dcc_end_script
    ENDIF
   ELSE
    GO TO dcc_end_script
   ENDIF
  ENDIF
  SET dcc_ecode = error(dcc_emsg,1)
  IF (dcc_ecode != 0)
   SET error_table = " "
   SET dcc_failed = ccl_error
   GO TO dcc_check_error
  ENDIF
 ENDIF
#dcc_check_error
 IF (dcc_failed != false)
  IF (dm_debug_cmb=1)
   CALL echo("Error occured in dm_call_combine...")
  ENDIF
  ROLLBACK
  SET error_cnt += 1
  SET stat = alterlist(reply->error,error_cnt)
  SET reqinfo->commit_ind = false
  SET reply->status_data.status = "F"
  SET next_seq_val = 0.0
  SELECT INTO "nl:"
   y = seq(combine_error_seq,nextval)
   FROM dual
   DETAIL
    next_seq_val = cnvtreal(y)
   WITH nocounter
  ;end select
  SET etype = fillstring(50," ")
  IF (dcc_failed=3)
   SET etype = "GEN_NBR_ERROR"
  ELSEIF (dcc_failed=4)
   SET etype = "INSERT_ERROR"
  ELSEIF (dcc_failed=5)
   SET etype = "UPDATE_ERROR"
  ELSEIF (dcc_failed=6)
   SET etype = "REPLACE_ERROR"
  ELSEIF (dcc_failed=7)
   SET etype = "DELETE_ERROR"
  ELSEIF (dcc_failed=8)
   SET etype = "UNDELETE_ERROR"
  ELSEIF (dcc_failed=9)
   SET etype = "REMOVE_ERROR"
  ELSEIF (dcc_failed=10)
   SET etype = "ATTRIBUTE_ERROR"
  ELSEIF (dcc_failed=11)
   SET etype = "LOCK_ERROR"
  ELSEIF (dcc_failed=12)
   SET etype = "NONE_FOUND"
  ELSEIF (dcc_failed=13)
   SET etype = "SELECT_ERROR"
  ELSEIF (dcc_failed=14)
   SET etype = "DATA_ERROR"
  ELSEIF (dcc_failed=15)
   SET etype = "GENERAL_ERROR"
  ELSEIF (dcc_failed=16)
   SET etype = "REACTIVATE_ERROR"
  ELSEIF (dcc_failed=17)
   SET etype = "EFF_ERROR"
  ELSEIF (dcc_failed=18)
   SET etype = "CCL_ERROR"
  ELSEIF (dcc_failed=19)
   SET etype = "RECALC_ERROR"
  ELSEIF (dcc_failed=22)
   SET etype = "CONFIDENTIALITY_LEVEL_ERROR"
  ENDIF
  UPDATE  FROM dm_combine_error dce
   SET dce.calling_script = call_script, dce.operation_type = "DM_CALL_COMBINE", dce.parent_entity =
    request->parent_table,
    dce.combine_id = 0, dce.from_id = request->xxx_combine[1].from_xxx_id, dce.to_id = request->
    xxx_combine[1].to_xxx_id,
    dce.encntr_id = request->xxx_combine[1].encntr_id, dce.error_table = error_table, dce.error_type
     = etype,
    dce.create_dt_tm = cnvtdatetime(sysdate), dce.resolved_ind = false, dce.error_msg = substring(1,
     132,request->error_message),
    dce.combine_mode = request->cmb_mode, dce.transaction_type = request->transaction_type, dce
    .application_flag = request->xxx_combine[1].application_flag,
    dce.updt_id = reqinfo->updt_id, dce.updt_task = reqinfo->updt_task, dce.updt_applctx = reqinfo->
    updt_applctx,
    dce.updt_cnt = (dce.updt_cnt+ 1), dce.updt_dt_tm = cnvtdatetime(sysdate)
   WHERE dce.combine_error_id=next_seq_val
   WITH nocounter
  ;end update
  IF (curqual=0)
   INSERT  FROM dm_combine_error dce
    SET dce.combine_error_id = next_seq_val, dce.calling_script = call_script, dce.operation_type =
     "DM_CALL_COMBINE",
     dce.parent_entity = request->parent_table, dce.combine_id = parent_combine_id, dce.combine_id =
     request->xxx_combine[1].xxx_combine_id,
     dce.from_id = request->xxx_combine[1].from_xxx_id, dce.to_id = request->xxx_combine[1].to_xxx_id,
     dce.encntr_id = request->xxx_combine[1].encntr_id,
     dce.error_table = error_table, dce.error_type = etype, dce.create_dt_tm = cnvtdatetime(sysdate),
     dce.resolved_ind = false, dce.error_msg = substring(1,132,request->error_message), dce
     .combine_mode = request->cmb_mode,
     dce.transaction_type = request->transaction_type, dce.application_flag = request->xxx_combine[1]
     .application_flag, dce.updt_id = reqinfo->updt_id,
     dce.updt_task = reqinfo->updt_task, dce.updt_applctx = reqinfo->updt_applctx, dce.updt_cnt =
     init_updt_cnt,
     dce.updt_dt_tm = cnvtdatetime(sysdate)
    WITH nocounter
   ;end insert
  ENDIF
  SET reply->error[error_cnt].create_dt_tm = cnvtdatetime(sysdate)
  SET reply->error[error_cnt].parent_table = request->parent_table
  SET reply->error[error_cnt].from_id = request->xxx_combine[1].from_xxx_id
  SET reply->error[error_cnt].to_id = request->xxx_combine[1].to_xxx_id
  SET reply->error[error_cnt].encntr_id = request->xxx_combine[1].encntr_id
  SET reply->error[error_cnt].error_table = error_table
  SET reply->error[error_cnt].error_type = etype
  SET reply->error[error_cnt].error_msg = request->error_message
  IF (validate(reply->error[error_cnt].combine_error_id) != 0)
   SET reply->error[error_cnt].combine_error_id = next_seq_val
  ENDIF
  IF (dcc_failed=ccl_error)
   UPDATE  FROM dm_combine_error
    SET error_msg = substring(1,132,dcc_emsg)
    WHERE combine_error_id=next_seq_val
    WITH nocounter
   ;end update
   SET reply->error[error_cnt].error_msg = dcc_emsg
  ENDIF
  COMMIT
 ELSE
  FOR (dm_x = 1 TO size(reply->xxx_combine_id,5))
    IF ((reply->xxx_combine_id[dm_x].encntr_id > 0.0)
     AND (reply->xxx_combine_id[dm_x].parent_table="PERSON"))
     SET seventtype = "ENCNTRMOVE"
    ELSE
     SET seventtype = "COMBINE"
    ENDIF
    IF ( NOT ((((request->parent_table="PERSON")) OR ((request->parent_table="PRSNL"))) ))
     SET reverse_cmb_ind = 0
    ENDIF
    CALL transfer_notify_data(seventtype,evaluate(dm_x,1,1,0),reply->xxx_combine_id[dm_x].combine_id,
     reply->xxx_combine_id[dm_x].parent_table,reply->xxx_combine_id[dm_x].from_xxx_id,
     reply->xxx_combine_id[dm_x].to_xxx_id,reply->xxx_combine_id[dm_x].encntr_id,cmb_notify_events,
     reverse_cmb_ind)
  ENDFOR
  IF (dm_debug_cmb=1)
   CALL echo("No error in dm_call_combine...")
  ENDIF
  SET reqinfo->commit_ind = true
  SET reply->status_data.status = "S"
 ENDIF
#dcc_end_script
 DECLARE csp_error = i4 WITH noconstant(0), protect
 IF ((request->cmb_mode != "TESTING")
  AND dm_debug_cmb != 1)
  IF (dcc_failed=true)
   IF (locateval(csp_error,1,size(reply->error,5),"Uncombine required.",substring(1,19,reply->error[
     csp_error].error_msg)) > 0)
    CALL cmb_notify(cmb_notify_events)
   ENDIF
  ELSE
   CALL cmb_notify(cmb_notify_events)
  ENDIF
 ENDIF
 IF (dcc_context_obj_ind=1)
  CALL parser(concat("RDB ASIS(^ BEGIN DM2_CONTEXT_CONTROL('COMBINE',null); END; ^) GO"),1)
 ENDIF
 SET reqinfo->updt_task = dcc_updt_task
 IF (size(reply->error,5) > 0)
  SET reqinfo->commit_ind = false
  SET reply->status_data.status = "F"
 ENDIF
 IF ((request->cmb_mode != "TESTING")
  AND (request->cmb_mode != "RE-CMB")
  AND size(reply->xxx_combine_id,5) > 0)
  SET dm_eso = 0
  SELECT INTO "nl:"
   d.seq
   FROM dm_info d
   WHERE d.info_domain="ESO"
    AND d.info_name="HOLD_LOGIC"
    AND d.info_number=1
   DETAIL
    dm_eso = 1
   WITH nocounter
  ;end select
  IF (dm_eso=1)
   EXECUTE eso_hold_combine
  ENDIF
 ENDIF
 SUBROUTINE add_to_person_cmb_det(dummy)
   SET dm_new_nbr = 0.0
   SELECT INTO "nl:"
    y = seq(person_combine_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     dm_new_nbr = cnvtreal(y)
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET dcc_failed = gen_nbr_error
    SET request->error_message = concat("Could not get next sequence value from ",person_combine_seq)
    SET error_table = " "
    GO TO dcc_check_error
   ENDIF
   INSERT  FROM person_combine_det p
    SET p.attribute_name = "ENCNTR_COMBINE_ID", p.combine_action_cd = enc_cmb, p.person_combine_id =
     rcmbenc->enc[dm_x].person_combine_id,
     p.person_combine_det_id = dm_new_nbr, p.entity_name = "ENCNTR_COMBINE", p.entity_id = rcmbenc->
     enc[dm_x].encntr_combine_id,
     p.active_ind = 1, p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm =
     cnvtdatetime(sysdate),
     p.active_status_prsnl_id = reqinfo->updt_id, p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(sysdate
      ),
     p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET dcc_failed = insert_error
    SET request->error_message =
    "Could not insert person_combine_det record for auto encntr_combine."
    SET error_table = "PERSON_COMBINE_DET"
    GO TO dcc_check_error
   ENDIF
 END ;Subroutine
 SUBROUTINE add_prsnl_cmb_to_person_cmb_det(dummy)
   SET dm_new_nbr = 0.0
   SELECT INTO "nl:"
    y = seq(person_combine_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     dm_new_nbr = cnvtreal(y)
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET dcc_failed = gen_nbr_error
    SET request->error_message = concat("Could not get next sequence value from ",person_combine_seq)
    SET error_table = " "
    GO TO dcc_check_error
   ENDIF
   INSERT  FROM person_combine_det p
    SET p.attribute_name = "COMBINE_ID", p.combine_action_cd = prsnl_cmb, p.person_combine_id =
     rcmbprsnl->qual[dm_x].person_combine_id,
     p.person_combine_det_id = dm_new_nbr, p.entity_name = "PRSNL_COMBINE", p.entity_id = rcmbprsnl->
     qual[dm_x].prsnl_combine_id,
     p.active_ind = 1, p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm =
     cnvtdatetime(sysdate),
     p.active_status_prsnl_id = reqinfo->updt_id, p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(sysdate
      ),
     p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET dcc_failed = insert_error
    SET request->error_message = "Could not insert person_combine_det record for personnel combine."
    SET error_table = "PERSON_COMBINE_DET"
    GO TO dcc_check_error
   ENDIF
 END ;Subroutine
 SUBROUTINE upt_prsnl_cmb_to_person_cmb_det(dummy)
  UPDATE  FROM person_combine_det pc
   SET pc.updt_task = 66666, pc.updt_dt_tm = cnvtdatetime(sysdate), pc.updt_id = reqinfo->updt_id
   WHERE pc.entity_name="PRSNL_COMBINE"
    AND (pc.entity_id=rcmbprsnl->qual[dm_x].prsnl_combine_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = update_error
   SET request->error_message = concat("Couldn't update person_combine_det table where entity_id = ",
    build(rcmbprsnl->qual[dm_x].prsnl_combine_id))
   GO TO cmb_check_error
  ENDIF
 END ;Subroutine
END GO

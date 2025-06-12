CREATE PROGRAM dm_call_uncombine:dba
 SET dcu_updt_task = 0
 SET dcu_updt_task = reqinfo->updt_task
 IF (validate(dcue_upt_exc_reply->message,"YYY")="YYY"
  AND validate(dcue_upt_exc_reply->message,"zzz")="zzz")
  FREE RECORD dcue_upt_exc_reply
  RECORD dcue_upt_exc_reply(
    1 status = c1
    1 message = c255
    1 error_table = c30
  )
 ENDIF
 IF ((validate(dcrd_reply->err_ind,- (1))=- (1))
  AND (validate(dcrd_reply->err_ind,- (999))=- (999)))
  FREE RECORD dcrd_reply
  RECORD dcrd_reply(
    1 cmb_last_updt = f8
    1 user_last_updt = f8
    1 schema_last_updt = f8
    1 err_ind = i2
    1 erro_msg = c255
  )
 ENDIF
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
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 RECORD rucbenc(
   1 parent_table = c50
   1 ucb[*]
     2 person_combine_id = f8
     2 encntr_combine_id = f8
     2 from_id = f8
     2 to_id = f8
     2 ec_active_ind = i2
   1 enc_size = i2
 )
 RECORD rucbprsnl(
   1 parent_table = c50
   1 ucb[*]
     2 person_combine_id = f8
     2 prsnl_combine_id = f8
     2 from_id = f8
     2 to_id = f8
     2 ucb_group_id = f8
   1 prsnl_size = i2
 )
 RECORD rucbreq(
   1 parent_table = c50
   1 ucb[*]
     2 combine_id = f8
     2 from_id = f8
     2 to_id = f8
     2 encntr_id = f8
   1 req_size = i2
 )
 DECLARE next_seq_val = f8
 DECLARE dcu_context_obj_ind = i2 WITH protect, noconstant(0)
 DECLARE ucb_group_id_prot = f8 WITH protect, noconstant(0)
 DECLARE reverse_cmb_ind = i2 WITH protect, noconstant(0)
 SET trace = errorclear
 SET rucbenc->enc_size = 0
 SET rucbprsnl->prsnl_size = 0
 SET rucbreq->req_size = 0
 SET call_script = fillstring(30," ")
 SET call_script = "DM_CALL_UNCOMBINE"
 SET error_table = fillstring(50," ")
 SET dcu_emsg = fillstring(132," ")
 SET dcu_ecode = 0
 SET meaning = fillstring(12," ")
 SET dm_debug_cmb = 0
 IF (validate(dm_debug,0))
  SET dm_debug_cmb = 1
 ENDIF
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
 SET no_primary_key = 20
 SET gdpr_error = 21
 SET init_updt_cnt = 0
 SET error_cnt = 0
 SET dcu_failed = false
 CASE (request->parent_table)
  OF "PERSON":
  OF "ENCOUNTER":
  OF "PRSNL":
  OF "LOCATION":
  OF "ORGANIZATION":
  OF "HEALTH_PLAN":
   IF (dm_debug_cmb=1)
    CALL echo(concat("Combine parent_table: ",request->parent_table))
   ENDIF
  ELSE
   SET error_table = request->parent_table
   SET dcu_failed = general_error
   SET request->error_message = substring(1,132,concat("An invalid combine type was provided: ",
     request->parent_table))
   GO TO dcu_check_error
 ENDCASE
 SELECT INTO "nl:"
  uo.object_name, uo.object_type, uo.status
  FROM user_objects uo
  WHERE uo.object_type="PROCEDURE"
   AND uo.object_name="DM2_CONTEXT_CONTROL"
   AND uo.status="VALID"
  DETAIL
   dcu_context_obj_ind = 1
  WITH nocounter
 ;end select
 SET dcu_ecode = error(dcu_emsg,1)
 IF (dcu_ecode != 0)
  SET error_table = "USER_OBJECTS"
  SET dcu_failed = select_error
  GO TO dcu_check_error
 ENDIF
 IF (dcu_context_obj_ind=1)
  CALL parser(concat("RDB ASIS(^ BEGIN DM2_CONTEXT_CONTROL('UNCOMBINE','",trim(request->parent_table),
    "'); END; ^) GO"),1)
  IF (error(dcu_emsg,1) != 0)
   SET dcu_context_obj_ind = 0
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
   SET dcu_failed = data_error
   SET request->error_message =
   "No active, effective code_value exists for cdf_meaning 'ENCNTRCMB' for code_set 327"
   SET error_table = "CODE_VALUE"
   GO TO dcu_check_error
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
  IF (curqual=0)
   SET dcu_failed = data_error
   SET request->error_message =
   "No active, effective code_value exists for cdf_meaning 'PRSNLCMB' for code_set 327"
   SET error_table = "CODE_VALUE"
   GO TO dcu_check_error
  ENDIF
 ENDIF
 SET reqinfo->updt_task = 100102
 SET ucb_tot_num = size(request->xxx_uncombine,5)
 IF (ucb_tot_num > 0)
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
  FOR (dm_x = 1 TO ucb_tot_num)
    SET stat = initrec(cmb_drr_request)
    SET stat = initrec(cmb_drr_reply)
    SET cmb_drr_request->from_xxx_id = request->xxx_uncombine[dm_x].from_xxx_id
    SET cmb_drr_request->to_xxx_id = request->xxx_uncombine[dm_x].to_xxx_id
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
      SET dcu_failed = data_error
      SET request->error_message = concat("The PERSON_ID could not be found for ENCOUNTER : ",trim(
        cnvtstring(cmb_drr_request->from_xxx_id)))
      GO TO dcu_check_error
     ENDIF
    ENDIF
    EXECUTE daf_cmb_check_drr_allowed
    IF ((cmb_drr_reply->status != "S"))
     SET error_table = cmb_drr_request->parent_table
     SET dcu_failed = data_error
     SET request->error_message = cmb_drr_reply->message
     GO TO dcu_check_error
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
  FOR (dm_x = 1 TO ucb_tot_num)
    CALL parser("select into 'nl:' ")
    CALL parser(concat("  t.",daf_cmb_key_column))
    CALL parser(concat("from ",request->parent_table," t"))
    CALL parser(concat("where t.",daf_cmb_key_column," = request->xxx_uncombine[dm_x]->from_xxx_id"))
    CALL parser("with nocounter go")
    IF (curqual=0)
     SET error_table = request->parent_table
     SET dcu_failed = data_error
     SET request->error_message = concat("Could not find FROM ",trim(request->parent_table)," ID: ",
      trim(cnvtstring(request->xxx_uncombine[dm_x].from_xxx_id)))
     GO TO dcu_check_error
    ENDIF
    CALL parser("select into 'nl:' ")
    CALL parser(concat("  t.",daf_cmb_key_column))
    CALL parser(concat("from ",request->parent_table," t"))
    CALL parser(concat("where t.",daf_cmb_key_column," = request->xxx_uncombine[dm_x]->to_xxx_id"))
    CALL parser("with nocounter go")
    IF (curqual=0)
     SET error_table = request->parent_table
     SET dcu_failed = data_error
     SET request->error_message = concat("Could not find TO ",trim(request->parent_table)," ID: ",
      trim(cnvtstring(request->xxx_uncombine[dm_x].to_xxx_id)))
     GO TO dcu_check_error
    ENDIF
  ENDFOR
  IF ((request->cmb_mode != "TESTING")
   AND dm_debug_cmb != 1)
   CASE (cnvtupper(trim(request->parent_table,3)))
    OF "PERSON":
     EXECUTE dm_cmb_refresh_dcc
     IF ((dcrd_reply->err_ind=1))
      SET error_table = "refresh dcc"
      SET request->error_message = "Error from dm_cmb_refresh_dcc "
      SET dcu_failed = general_error
      GO TO dcu_check_error
     ENDIF
     EXECUTE dm_cmb_upt_exceptions "DM_PUCB*"
     IF ((dcue_upt_exc_reply->status != "S"))
      SET error_table = "dm_cmb_exception"
      SET request->error_message = "Error from dm_cmb_upt_exceptions 'DM_PUCB*' "
      SET dcu_failed = general_error
      GO TO dcu_check_error
     ENDIF
     EXECUTE dm_cmb_upt_exceptions "DM_EUCB*"
     IF ((dcue_upt_exc_reply->status != "S"))
      SET error_table = "dm_cmb_exception"
      SET request->error_message = "Error from dm_cmb_upt_exceptions 'DM_EUCB*' "
      SET dcu_failed = general_error
      GO TO dcu_check_error
     ENDIF
     EXECUTE dm_cmb_upt_exceptions "DM_PRUCB*"
     IF ((dcue_upt_exc_reply->status != "S"))
      SET error_table = "dm_cmb_exception"
      SET request->error_message = "Error from dm_cmb_upt_exceptions 'DM_PRUCB*' "
      SET dcu_failed = general_error
      GO TO dcu_check_error
     ENDIF
     EXECUTE dm_cmb_upt_exceptions "DM_PCMB*"
     IF ((dcue_upt_exc_reply->status != "S"))
      SET error_table = "dm_cmb_exception"
      SET request->error_message = "Error from dm_cmb_upt_exceptions 'DM_PCMB*' "
      SET dcu_failed = general_error
      GO TO dcu_check_error
     ENDIF
    OF "ENCOUNTER":
     EXECUTE dm_cmb_upt_exceptions "DM_EUCB*"
     IF ((dcue_upt_exc_reply->status != "S"))
      SET error_table = "dm_cmb_exception"
      SET request->error_message = "Error from dm_cmb_upt_exceptions 'DM_EUCB*' "
      SET dcu_failed = general_error
      GO TO dcu_check_error
     ENDIF
    OF "LOCATION":
     EXECUTE dm_cmb_upt_exceptions "DM_LUCB*"
     IF ((dcue_upt_exc_reply->status != "S"))
      SET error_table = "dm_cmb_exception"
      SET request->error_message = "Error from dm_cmb_upt_exceptions 'DM_LUCB*' "
      SET dcu_failed = general_error
      GO TO dcu_check_error
     ENDIF
    OF "ORGANIZATION":
     EXECUTE dm_cmb_upt_exceptions "DM_OUCB*"
     IF ((dcue_upt_exc_reply->status != "S"))
      SET error_table = "dm_cmb_exception"
      SET request->error_message = "Error from dm_cmb_upt_exceptions 'DM_OUCB*' "
      SET dcu_failed = general_error
      GO TO dcu_check_error
     ENDIF
   ENDCASE
  ENDIF
  SET stat = alterlist(rucbreq->ucb,ucb_tot_num)
  SET rucbreq->parent_table = request->parent_table
  SET rucbreq->req_size = ucb_tot_num
  FOR (dm_x = 1 TO rucbreq->req_size)
    SET rucbreq->ucb[dm_x].combine_id = request->xxx_uncombine[dm_x].xxx_combine_id
    SET rucbreq->ucb[dm_x].from_id = request->xxx_uncombine[dm_x].from_xxx_id
    SET rucbreq->ucb[dm_x].to_id = request->xxx_uncombine[dm_x].to_xxx_id
    SET rucbreq->ucb[dm_x].encntr_id = request->xxx_uncombine[dm_x].encntr_id
    IF ((((request->parent_table="PERSON")) OR ((request->parent_table="PRSNL"))) )
     SET reverse_cmb_ind = getreversecombineindicatorforcombineid(rucbreq->ucb[dm_x].combine_id,
      request->parent_table)
    ELSE
     SET reverse_cmb_ind = 0
    ENDIF
    CALL transfer_notify_data("UNCOMBINE",evaluate(dm_x,1,1,0),request->xxx_uncombine[dm_x].
     xxx_combine_id,request->parent_table,request->xxx_uncombine[dm_x].from_xxx_id,
     request->xxx_uncombine[dm_x].to_xxx_id,request->xxx_uncombine[dm_x].encntr_id,cmb_notify_events,
     reverse_cmb_ind)
  ENDFOR
  IF ((rucbreq->parent_table="PERSON")
   AND (rucbreq->ucb[1].encntr_id > 0))
   SET error_table = "REQUEST"
   SET request->error_message = concat("Uncombine of single-encntr person combines not allowed - ",
    "move encntr back with another single-encntr person combine.")
   SET dcu_failed = data_error
   GO TO dcu_check_error
  ENDIF
  IF ((rucbreq->parent_table="PERSON"))
   IF ((request->cmb_mode != "RE-UCB"))
    SELECT INTO "nl:"
     pcd.person_combine_det_id
     FROM person_combine_det pcd,
      combine c,
      (dummyt d  WITH seq = value(ucb_tot_num))
     PLAN (d)
      JOIN (pcd
      WHERE (pcd.person_combine_id=rucbreq->ucb[d.seq].combine_id)
       AND pcd.combine_action_cd=prsnl_cmb
       AND pcd.entity_name="PRSNL_COMBINE"
       AND pcd.active_ind=1)
      JOIN (c
      WHERE c.combine_id=pcd.entity_id
       AND c.active_ind=1)
     DETAIL
      rucbprsnl->prsnl_size += 1, stat = alterlist(rucbprsnl->ucb,rucbprsnl->prsnl_size), rucbprsnl->
      ucb[rucbprsnl->prsnl_size].person_combine_id = rucbreq->ucb[d.seq].combine_id,
      rucbprsnl->ucb[rucbprsnl->prsnl_size].prsnl_combine_id = pcd.entity_id, rucbprsnl->ucb[
      rucbprsnl->prsnl_size].from_id = c.from_id, rucbprsnl->ucb[rucbprsnl->prsnl_size].to_id = c
      .to_id
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     pcd.person_combine_det_id
     FROM person_combine_det pcd,
      combine c,
      (dummyt d  WITH seq = value(ucb_tot_num))
     PLAN (d)
      JOIN (pcd
      WHERE (pcd.person_combine_id=rucbreq->ucb[d.seq].combine_id)
       AND pcd.combine_action_cd=prsnl_cmb
       AND pcd.entity_name="PRSNL_COMBINE")
      JOIN (c
      WHERE c.combine_id=pcd.entity_id)
     DETAIL
      rucbprsnl->prsnl_size += 1, stat = alterlist(rucbprsnl->ucb,rucbprsnl->prsnl_size), rucbprsnl->
      ucb[rucbprsnl->prsnl_size].person_combine_id = rucbreq->ucb[d.seq].combine_id,
      rucbprsnl->ucb[rucbprsnl->prsnl_size].prsnl_combine_id = pcd.entity_id, rucbprsnl->ucb[
      rucbprsnl->prsnl_size].from_id = c.from_id, rucbprsnl->ucb[rucbprsnl->prsnl_size].to_id = c
      .to_id
     WITH nocounter
    ;end select
   ENDIF
   IF ((rucbprsnl->prsnl_size > 0))
    SET stat = alterlist(request->xxx_uncombine,0)
    SET stat = alterlist(request->xxx_combine,0)
    SET stat = alterlist(request->xxx_combine_det,0)
    FOR (dm_y = 1 TO rucbprsnl->prsnl_size)
      SET request->parent_table = "PRSNL"
      SET stat = alterlist(request->xxx_uncombine,1)
      SET request->xxx_uncombine[dm_y].xxx_combine_id = rucbprsnl->ucb[dm_y].prsnl_combine_id
      SET request->xxx_uncombine[dm_y].from_xxx_id = rucbprsnl->ucb[dm_y].from_id
      SET request->xxx_uncombine[dm_y].to_xxx_id = rucbprsnl->ucb[dm_y].to_id
      SET reverse_cmb_ind = getreversecombineindicatorforcombineid(request->xxx_uncombine[dm_y].
       xxx_combine_id,request->parent_table)
      CALL transfer_notify_data("UNCOMBINE",0,request->xxx_uncombine[dm_y].xxx_combine_id,request->
       parent_table,request->xxx_uncombine[dm_y].from_xxx_id,
       request->xxx_uncombine[dm_y].to_xxx_id,request->xxx_uncombine[dm_y].encntr_id,
       cmb_notify_events,reverse_cmb_ind)
      SET ucb_group_id_prot = 0.0
      SELECT INTO "nl:"
       y = seq(combine_seq,nextval)
       FROM dual
       DETAIL
        ucb_group_id_prot = cnvtreal(y)
       WITH nocounter
      ;end select
      SET rucbprsnl->ucb[dm_y].ucb_group_id = ucb_group_id_prot
    ENDFOR
    SET dcu_ecode = error(dcu_emsg,1)
    IF (dcu_ecode != 0)
     SET error_table = " "
     SET dcu_failed = ccl_error
     GO TO dcu_check_error
    ENDIF
    EXECUTE dm_uncombine2
    IF ((reqinfo->commit_ind=true))
     FOR (dm_y = 1 TO rucbprsnl->prsnl_size)
      UPDATE  FROM person_combine_det pcd
       SET pcd.active_ind = false, pcd.active_status_cd = reqdata->inactive_status_cd, pcd.updt_id =
        reqinfo->updt_id,
        pcd.updt_dt_tm = cnvtdatetime(sysdate), pcd.updt_applctx = reqinfo->updt_applctx, pcd
        .updt_cnt = (updt_cnt+ 1),
        pcd.updt_task = reqinfo->updt_task
       WHERE (pcd.person_combine_id=rucbprsnl->ucb[dm_y].person_combine_id)
        AND pcd.combine_action_cd=prsnl_cmb
        AND (pcd.entity_id=rucbprsnl->ucb[dm_y].prsnl_combine_id)
        AND pcd.entity_name="PRSNL_COMBINE"
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET dcu_failed = update_error
       SET request->error_message =
       "Could not update active status of person_combine_det record for prsnl combine."
       SET error_table = "PERSON_COMBINE_DET"
       GO TO dcu_check_error
      ENDIF
     ENDFOR
    ELSE
     GO TO dcu_end_script
    ENDIF
   ENDIF
   SET rucbenc->enc_size = 0
   SET stat = alterlist(rucbenc->ucb,rucbenc->enc_size)
   SELECT INTO "nl:"
    pcd.person_combine_det_id
    FROM person_combine_det pcd,
     encntr_combine ec,
     (dummyt d  WITH seq = value(ucb_tot_num))
    PLAN (d)
     JOIN (pcd
     WHERE (pcd.person_combine_id=rucbreq->ucb[d.seq].combine_id)
      AND pcd.combine_action_cd=enc_cmb
      AND pcd.entity_name="ENCNTR_COMBINE")
     JOIN (ec
     WHERE ec.encntr_combine_id=pcd.entity_id)
    DETAIL
     rucbenc->enc_size += 1, stat = alterlist(rucbenc->ucb,rucbenc->enc_size), rucbenc->ucb[rucbenc->
     enc_size].person_combine_id = rucbreq->ucb[d.seq].combine_id,
     rucbenc->ucb[rucbenc->enc_size].encntr_combine_id = pcd.entity_id, rucbenc->ucb[rucbenc->
     enc_size].from_id = ec.from_encntr_id, rucbenc->ucb[rucbenc->enc_size].to_id = ec.to_encntr_id,
     rucbenc->ucb[rucbenc->enc_size].ec_active_ind = ec.active_ind
    WITH nocounter
   ;end select
   IF ((rucbenc->enc_size > 0))
    FOR (dm_y = 1 TO rucbenc->enc_size)
      IF ((rucbenc->ucb[dm_y].ec_active_ind=1))
       SET stat = alterlist(request->xxx_uncombine,0)
       SET stat = alterlist(request->xxx_combine,0)
       SET stat = alterlist(request->xxx_combine_det,0)
       SET stat = alterlist(request->xxx_uncombine,1)
       SET request->xxx_uncombine[1].xxx_combine_id = rucbenc->ucb[dm_y].encntr_combine_id
       SET request->xxx_uncombine[1].from_xxx_id = rucbenc->ucb[dm_y].from_id
       SET request->xxx_uncombine[1].to_xxx_id = rucbenc->ucb[dm_y].to_id
       SET request->parent_table = "ENCOUNTER"
       SET dcu_ecode = error(dcu_emsg,1)
       IF (dcu_ecode != 0)
        SET error_table = " "
        SET dcu_failed = ccl_error
        GO TO dcu_check_error
       ENDIF
       EXECUTE dm_uncombine
       IF ((reqinfo->commit_ind=true))
        CALL transfer_notify_data("UNCOMBINE",0,request->xxx_uncombine[1].xxx_combine_id,request->
         parent_table,request->xxx_uncombine[1].from_xxx_id,
         request->xxx_uncombine[1].to_xxx_id,request->xxx_uncombine[1].encntr_id,cmb_notify_events)
        UPDATE  FROM person_combine_det pcd
         SET pcd.active_ind = false, pcd.active_status_cd = reqdata->inactive_status_cd, pcd.updt_id
           = reqinfo->updt_id,
          pcd.updt_dt_tm = cnvtdatetime(sysdate), pcd.updt_applctx = reqinfo->updt_applctx, pcd
          .updt_cnt = (updt_cnt+ 1),
          pcd.updt_task = reqinfo->updt_task
         WHERE (pcd.person_combine_id=rucbenc->ucb[dm_y].person_combine_id)
          AND pcd.combine_action_cd=enc_cmb
          AND (pcd.entity_id=rucbenc->ucb[dm_y].encntr_combine_id)
          AND pcd.entity_name="ENCNTR_COMBINE"
        ;end update
        IF (curqual=0)
         SET dcu_failed = update_error
         SET request->error_message =
         "Couldn't update active status of person_combine_det record for auto encntr combine."
         SET error_table = "PERSON_COMBINE_DET"
         GO TO dcu_check_error
        ENDIF
       ELSE
        GO TO dcu_end_script
       ENDIF
      ELSE
       UPDATE  FROM person_combine_det pcd
        SET pcd.active_ind = false, pcd.active_status_cd = reqdata->inactive_status_cd, pcd.updt_id
          = reqinfo->updt_id,
         pcd.updt_dt_tm = cnvtdatetime(sysdate), pcd.updt_applctx = reqinfo->updt_applctx, pcd
         .updt_cnt = (updt_cnt+ 1),
         pcd.updt_task = reqinfo->updt_task
        WHERE (pcd.person_combine_id=rucbenc->ucb[dm_y].person_combine_id)
         AND pcd.combine_action_cd=enc_cmb
         AND (pcd.entity_id=rucbenc->ucb[dm_y].encntr_combine_id)
         AND pcd.entity_name="ENCNTR_COMBINE"
       ;end update
       IF (curqual=0)
        SET dcu_failed = update_error
        SET request->error_message =
        "Couldn't update active status of person_combine_det record for auto encntr combine."
        SET error_table = "PERSON_COMBINE_DET"
        GO TO dcu_check_error
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   FOR (dm_x = 1 TO ucb_tot_num)
     SET stat = alterlist(request->xxx_uncombine,0)
     SET stat = alterlist(request->xxx_combine,0)
     SET stat = alterlist(request->xxx_combine_det,0)
     SET stat = alterlist(request->xxx_uncombine,dm_x)
     SET request->parent_table = rucbreq->parent_table
     SET request->xxx_uncombine[dm_x].xxx_combine_id = rucbreq->ucb[dm_x].combine_id
     SET request->xxx_uncombine[dm_x].from_xxx_id = rucbreq->ucb[dm_x].from_id
     SET request->xxx_uncombine[dm_x].to_xxx_id = rucbreq->ucb[dm_x].to_id
     SET request->xxx_uncombine[dm_x].encntr_id = rucbreq->ucb[dm_x].encntr_id
   ENDFOR
  ENDIF
  SET dcu_ecode = error(dcu_emsg,1)
  IF (dcu_ecode != 0)
   SET error_table = " "
   SET dcu_failed = ccl_error
   GO TO dcu_check_error
  ENDIF
  CASE (request->parent_table)
   OF "PERSON":
   OF "ENCOUNTER":
    EXECUTE dm_uncombine
   ELSE
    EXECUTE dm_uncombine2
  ENDCASE
  IF ((reqinfo->commit_ind=false))
   GO TO dcu_end_script
  ENDIF
  FOR (dm_x = 1 TO size(request->xxx_combine,5))
    CALL transfer_notify_data("ENCNTRMOVE",0,request->xxx_combine[dm_x].xxx_combine_id,"PERSON",
     request->xxx_combine[dm_x].from_xxx_id,
     request->xxx_combine[dm_x].to_xxx_id,request->xxx_combine[dm_x].encntr_id,cmb_notify_events)
  ENDFOR
 ENDIF
 SUBROUTINE (PUBLIC::getreversecombineindicatorforcombineid(combineid=f8,parenttable=c50) =i2 WITH
  protect)
   DECLARE reverse_cmb_ind = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dm_combine_audit dca
    WHERE dca.operation_type="COMBINE"
     AND dca.parent_entity_name=parenttable
     AND dca.parent_entity_id=combineid
     AND dca.log_level=1
    DETAIL
     reverse_cmb_ind = dca.reverse_cmb_ind
    WITH nocounter, maxqual(dca,1)
   ;end select
   SET dcu_ecode = error(dcu_emsg,1)
   IF (dcu_ecode != 0)
    SET error_table = "DM_COMBINE_AUDIT"
    SET dcu_failed = select_error
    GO TO dcu_check_error
   ENDIF
   RETURN(reverse_cmb_ind)
 END ;Subroutine
#dcu_check_error
 IF (dcu_failed != false)
  ROLLBACK
  SET reqinfo->commit_ind = false
  SET reply->status_data.status = "F"
  SET error_cnt += 1
  SET stat = alterlist(reply->error,error_cnt)
  SET next_seq_val = 0.0
  SELECT INTO "nl:"
   y = seq(combine_error_seq,nextval)
   FROM dual
   DETAIL
    next_seq_val = cnvtreal(y)
   WITH nocounter
  ;end select
  SET etype = fillstring(50," ")
  IF (dcu_failed=3)
   SET etype = "GEN_NBR_ERROR"
  ELSEIF (dcu_failed=4)
   SET etype = "INSERT_ERROR"
  ELSEIF (dcu_failed=5)
   SET etype = "UPDATE_ERROR"
  ELSEIF (dcu_failed=6)
   SET etype = "REPLACE_ERROR"
  ELSEIF (dcu_failed=7)
   SET etype = "DELETE_ERROR"
  ELSEIF (dcu_failed=8)
   SET etype = "UNDELETE_ERROR"
  ELSEIF (dcu_failed=9)
   SET etype = "REMOVE_ERROR"
  ELSEIF (dcu_failed=10)
   SET etype = "ATTRIBUTE_ERROR"
  ELSEIF (dcu_failed=11)
   SET etype = "LOCK_ERROR"
  ELSEIF (dcu_failed=12)
   SET etype = "NONE_FOUND"
  ELSEIF (dcu_failed=13)
   SET etype = "SELECT_ERROR"
  ELSEIF (dcu_failed=14)
   SET etype = "DATA_ERROR"
  ELSEIF (dcu_failed=15)
   SET etype = "GENERAL_ERROR"
  ELSEIF (dcu_failed=16)
   SET etype = "REACTIVATE_ERROR"
  ELSEIF (dcu_failed=17)
   SET etype = "EFF_ERROR"
  ELSEIF (dcu_failed=18)
   SET etype = "CCL_ERROR"
  ELSEIF (dcu_failed=19)
   SET etype = "RECALC_ERROR"
  ELSEIF (dcu_failed=20)
   SET etype = "NO_PRIMARY_KEY"
  ENDIF
  UPDATE  FROM dm_combine_error dce
   SET dce.calling_script = call_script, dce.operation_type = "UNCOMBINE", dce.parent_entity =
    rucbreq->parent_table,
    dce.combine_id = rucbreq->ucb[1].combine_id, dce.from_id = rucbreq->ucb[1].from_id, dce.to_id =
    rucbreq->ucb[1].to_id,
    dce.encntr_id = rucbreq->ucb[1].encntr_id, dce.error_table = error_table, dce.error_type = etype,
    dce.create_dt_tm = cnvtdatetime(sysdate), dce.resolved_ind = false, dce.error_msg = substring(1,
     132,request->error_message),
    dce.combine_mode = request->cmb_mode, dce.updt_id = reqinfo->updt_id, dce.updt_task = reqinfo->
    updt_task,
    dce.updt_applctx = reqinfo->updt_applctx, dce.updt_cnt = (dce.updt_cnt+ 1), dce.updt_dt_tm =
    cnvtdatetime(sysdate),
    dce.transaction_type = request->transaction_type, dce.application_flag = request->xxx_uncombine[1
    ].application_flag
   WHERE dce.combine_error_id=next_seq_val
   WITH nocounter
  ;end update
  IF (curqual=0)
   INSERT  FROM dm_combine_error dce
    SET dce.combine_error_id = next_seq_val, dce.calling_script = call_script, dce.operation_type =
     "UNCOMBINE",
     dce.parent_entity = rucbreq->parent_table, dce.combine_id = rucbreq->ucb[1].combine_id, dce
     .from_id = rucbreq->ucb[1].from_id,
     dce.to_id = rucbreq->ucb[1].to_id, dce.encntr_id = rucbreq->ucb[1].encntr_id, dce.error_table =
     error_table,
     dce.error_type = etype, dce.create_dt_tm = cnvtdatetime(sysdate), dce.resolved_ind = false,
     dce.error_msg = substring(1,132,request->error_message), dce.combine_mode = request->cmb_mode,
     dce.updt_id = reqinfo->updt_id,
     dce.updt_task = reqinfo->updt_task, dce.updt_applctx = reqinfo->updt_applctx, dce.updt_cnt =
     init_updt_cnt,
     dce.updt_dt_tm = cnvtdatetime(sysdate), dce.transaction_type = request->transaction_type, dce
     .application_flag = request->xxx_uncombine[1].application_flag
    WITH nocounter
   ;end insert
  ENDIF
  SET reply->error[error_cnt].create_dt_tm = cnvtdatetime(sysdate)
  SET reply->error[error_cnt].from_id = rucbreq->ucb[1].from_id
  SET reply->error[error_cnt].to_id = rucbreq->ucb[1].to_id
  SET reply->error[error_cnt].encntr_id = rucbreq->ucb[1].encntr_id
  SET reply->error[error_cnt].error_table = error_table
  SET reply->error[error_cnt].error_type = etype
  SET reply->error[error_cnt].error_msg = request->error_message
  IF (dcu_failed=ccl_error)
   UPDATE  FROM dm_combine_error
    SET error_msg = substring(1,132,dcu_emsg)
    WHERE combine_error_id=next_seq_val
    WITH nocounter
   ;end update
   SET reply->error[error_cnt].error_msg = dcu_emsg
  ENDIF
  COMMIT
 ELSE
  SET reqinfo->commit_ind = true
  SET reply->status_data.status = "S"
  IF ((request->cmb_mode != "TESTING")
   AND dm_debug_cmb != 1)
   CALL cmb_notify(cmb_notify_events)
  ENDIF
 ENDIF
#dcu_end_script
 IF (dcu_context_obj_ind=1)
  CALL parser(concat("RDB ASIS(^ BEGIN DM2_CONTEXT_CONTROL('UNCOMBINE',null); END; ^) GO"),1)
 ENDIF
 SET reqinfo->updt_task = dcu_updt_task
END GO

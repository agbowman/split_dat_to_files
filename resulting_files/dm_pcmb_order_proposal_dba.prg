CREATE PROGRAM dm_pcmb_order_proposal:dba
 DECLARE program_version = vc WITH private, constant("001")
 IF ((validate(dm_cmb_cust_script->called_by_readme_ind,- (9))=- (9)))
  RECORD dm_cmb_cust_script(
    1 called_by_readme_ind = i2
    1 exc_maint_ind = i2
  )
 ENDIF
 SUBROUTINE (dm_cmb_get_context(dummy=i2) =null)
   SET dm_cmb_cust_script->called_by_readme_ind = 0
   IF (validate(readme_data->status,"b") != "b"
    AND validate(readme_data->message,"CUSTCMBVALIDATE") != "CUSTCMBVALIDATE")
    SET dm_cmb_cust_script->called_by_readme_ind = 1
   ENDIF
   SET dm_cmb_cust_script->exc_maint_ind = 0
   IF ((validate(dcue_context_rec->called_by_dcue_ind,- (11)) != - (11))
    AND (validate(dcue_context_rec->called_by_dcue_ind,- (22)) != - (22)))
    SET dm_cmb_cust_script->exc_maint_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE cust_chk_ccl_def_col(ftbl_name,fcol_name)
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name=cnvtupper(trim(ftbl_name,3))
     AND l.attr_name=cnvtupper(trim(fcol_name,3))
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (dm_cmb_exc_maint_status(s_dcems_status=c1,s_dcems_msg=c255,s_dcems_tname=vc) =null)
   SET dcue_upt_exc_reply->status = s_dcems_status
   SET dcue_upt_exc_reply->message = s_dcems_msg
   SET dcue_upt_exc_reply->error_table = s_dcems_tname
 END ;Subroutine
 IF ((validate(dcem_request->qual[1].single_encntr_ind,- (1))=- (1)))
  FREE RECORD dcem_request
  RECORD dcem_request(
    1 qual[*]
      2 parent_entity = vc
      2 child_entity = vc
      2 op_type = vc
      2 script_name = vc
      2 single_encntr_ind = i2
      2 script_run_order = i4
      2 del_chg_id_ind = i2
      2 delete_row_ind = i2
  )
 ENDIF
 IF (validate(dcem_reply->status,"B")="B")
  FREE RECORD dcem_reply
  RECORD dcem_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 FREE SET order_proposal_group
 RECORD order_proposal_group(
   1 normal_order_proposals[*]
     2 order_proposal_id = f8
   1 originating_encounter_order_proposals[*]
     2 order_proposal_id = f8
 )
 DECLARE current_date_time = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE update_failure_ind = i2 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect
 DECLARE local_debug_ind = i2 WITH protect, noconstant(0)
 DECLARE update_normal_order_proposals(null) = null
 DECLARE update_originating_encounter_order_proposals(null) = null
 IF (validate(dm_debug_cmb,0))
  IF (dm_debug_cmb=1)
   SET local_debug_ind = 1
  ENDIF
 ENDIF
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "ORDER_PROPOSAL"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "dm_pcmb_order_proposal"
  SET dcem_request->qual[1].single_encntr_ind = 1
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 IF ((request->xxx_combine[icombine].encntr_id=0.0))
  CALL log_debug_message(build2("Starting person combine from person id: ",request->xxx_combine[
    icombine].from_xxx_id," into person id: ",request->xxx_combine[icombine].to_xxx_id))
  CALL retrieve_order_proposals_person_combine(request->xxx_combine[icombine].from_xxx_id)
  IF (local_debug_ind=1)
   CALL echorecord(order_proposal_group)
  ENDIF
  CALL update_normal_order_proposals(null)
 ELSE
  CALL log_debug_message(build2("Starting encounter move for encounter id: ",request->xxx_combine[
    icombine].encntr_id," to person id: ",request->xxx_combine[icombine].to_xxx_id))
  CALL retrieve_order_proposals_encounter_move(request->xxx_combine[icombine].from_xxx_id,request->
   xxx_combine[icombine].encntr_id)
  IF (local_debug_ind=1)
   CALL echorecord(order_proposal_group)
  ENDIF
  CALL update_normal_order_proposals(null)
  CALL update_originating_encounter_order_proposals(null)
 ENDIF
 SUBROUTINE (retrieve_order_proposals_person_combine(person_id=f8) =null)
   DECLARE normal_order_proposals_count = i4 WITH protect, noconstant(0)
   DECLARE condition_string = vc WITH protect, noconstant("")
   IF (person_id <= 0.0)
    SET failed = general_error
    SET request->error_message =
    "Logic error. Person_id should be populated for Person Combine workflow."
    GO TO exit_sub
   ENDIF
   SELECT INTO "nl:"
    op.order_proposal_id
    FROM order_proposal op
    PLAN (op
     WHERE op.person_id=person_id)
    DETAIL
     normal_order_proposals_count += 1
     IF (normal_order_proposals_count > size(order_proposal_group->normal_order_proposals,5))
      stat = alterlist(order_proposal_group->normal_order_proposals,(normal_order_proposals_count+ 10
       ))
     ENDIF
     order_proposal_group->normal_order_proposals[normal_order_proposals_count].order_proposal_id =
     op.order_proposal_id
    FOOT REPORT
     stat = alterlist(order_proposal_group->normal_order_proposals,normal_order_proposals_count)
    WITH forupdatewait(o)
   ;end select
 END ;Subroutine
 SUBROUTINE (retrieve_order_proposals_encounter_move(person_id=f8,encounter_id=f8) =null)
   DECLARE originating_encounter_order_proposals_count = i4 WITH protect, noconstant(0)
   DECLARE normal_order_proposals_count = i4 WITH protect, noconstant(0)
   IF (((person_id <= 0.0) OR (encounter_id <= 0.0)) )
    SET failed = general_error
    SET request->error_message =
    "Logic error. Person_id and Encntr_id should be populated for Person Combine workflow."
    GO TO exit_sub
   ENDIF
   SELECT INTO "nl:"
    op.order_proposal_id
    FROM order_proposal op
    PLAN (op
     WHERE ((op.person_id=person_id
      AND op.encntr_id=encounter_id) OR (op.originating_encntr_id=encounter_id)) )
    DETAIL
     IF (op.person_id=person_id
      AND op.encntr_id=encounter_id)
      normal_order_proposals_count += 1
      IF (normal_order_proposals_count > size(order_proposal_group->normal_order_proposals,5))
       stat = alterlist(order_proposal_group->normal_order_proposals,(normal_order_proposals_count+
        10))
      ENDIF
      order_proposal_group->normal_order_proposals[normal_order_proposals_count].order_proposal_id =
      op.order_proposal_id
     ENDIF
     IF (op.encntr_id != op.originating_encntr_id)
      originating_encounter_order_proposals_count += 1
      IF (originating_encounter_order_proposals_count > size(order_proposal_group->
       originating_encounter_order_proposals,5))
       stat = alterlist(order_proposal_group->originating_encounter_order_proposals,(
        originating_encounter_order_proposals_count+ 10))
      ENDIF
      order_proposal_group->originating_encounter_order_proposals[
      originating_encounter_order_proposals_count].order_proposal_id = op.order_proposal_id
     ENDIF
    FOOT REPORT
     stat = alterlist(order_proposal_group->normal_order_proposals,normal_order_proposals_count),
     stat = alterlist(order_proposal_group->originating_encounter_order_proposals,
      originating_encounter_order_proposals_count)
    WITH forupdatewait(o)
   ;end select
 END ;Subroutine
 SUBROUTINE update_normal_order_proposals(null)
   IF (size(order_proposal_group->normal_order_proposals,5)=0)
    RETURN
   ENDIF
   DECLARE normal_order_proposals_cnt = i4 WITH protect, constant(size(order_proposal_group->
     normal_order_proposals,5))
   CALL log_debug_message("starting processing of normal order proposals")
   UPDATE  FROM (dummyt d  WITH seq = value(normal_order_proposals_cnt)),
     order_proposal op
    SET op.updt_cnt = (op.updt_cnt+ 1), op.updt_id = reqinfo->updt_id, op.updt_applctx = reqinfo->
     updt_applctx,
     op.updt_task = reqinfo->updt_task, op.updt_dt_tm = cnvtdatetime(current_date_time), op.person_id
      = request->xxx_combine[icombine].to_xxx_id
    PLAN (d)
     JOIN (op
     WHERE (op.order_proposal_id=order_proposal_group->normal_order_proposals[d.seq].
     order_proposal_id))
    WITH nocounter
   ;end update
   SET stat = alterlist(order_proposal_group->normal_order_proposals,normal_order_proposals_cnt)
   IF (curqual=0)
    SET update_failure_ind = 1
   ELSE
    SET update_failure_ind = 0
   ENDIF
   DECLARE ndx = i4 WITH protect, noconstant(0)
   CALL echo(normal_order_proposals_cnt)
   FOR (ndx = 1 TO normal_order_proposals_cnt)
     SET icombinedet += 1
     SET stat = alterlist(request->xxx_combine_det,icombinedet)
     SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
     SET request->xxx_combine_det[icombinedet].entity_id = order_proposal_group->
     normal_order_proposals[ndx].order_proposal_id
     SET request->xxx_combine_det[icombinedet].entity_name = "ORDER_PROPOSAL"
     SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
     IF (update_failure_ind=1)
      SET failed = update_error
      SET request->error_message = substring(1,132,build2("Could not update pk val=",
        order_proposal_group->normal_order_proposals[ndx].order_proposal_id))
      GO TO exit_sub
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE update_originating_encounter_order_proposals(null)
   IF (size(order_proposal_group->originating_encounter_order_proposals,5)=0)
    RETURN
   ENDIF
   DECLARE originating_encounter_order_proposals_cnt = i4 WITH protect, constant(size(
     order_proposal_group->originating_encounter_order_proposals,5))
   CALL log_debug_message("starting processing of originating encounter order proposals")
   UPDATE  FROM (dummyt d  WITH seq = value(originating_encounter_order_proposals_cnt)),
     order_proposal op
    SET op.updt_cnt = (op.updt_cnt+ 1), op.updt_id = reqinfo->updt_id, op.updt_applctx = reqinfo->
     updt_applctx,
     op.updt_task = reqinfo->updt_task, op.updt_dt_tm = cnvtdatetime(current_date_time), op
     .originating_encntr_id = 0.0
    PLAN (d)
     JOIN (op
     WHERE (op.order_proposal_id=order_proposal_group->originating_encounter_order_proposals[d.seq].
     order_proposal_id))
    WITH nocounter
   ;end update
   SET stat = alterlist(request->xxx_combine_det,originating_encounter_order_proposals_cnt)
 END ;Subroutine
 SUBROUTINE (log_debug_message(debug_message=vc) =null)
   IF (local_debug_ind=1)
    CALL echo(debug_message)
   ENDIF
 END ;Subroutine
#exit_sub
 FREE SET order_proposal_group
END GO

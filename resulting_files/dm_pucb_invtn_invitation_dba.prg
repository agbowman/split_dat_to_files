CREATE PROGRAM dm_pucb_invtn_invitation:dba
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
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "INVTN_INVITATION"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "dm_pucb_invtn_invitation"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 2
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 DECLARE determine_parent_entity(null) = null
 DECLARE determine_scheduled_communication(null) = null
 DECLARE determine_generated_communication(null) = null
 DECLARE cust_ucb_del2(null) = null
 DECLARE cust_ucb_upt(null) = null
 RECORD invitation(
   1 person_id = f8
   1 program_id = f8
   1 parent_entity_name = vc
   1 parent_entity_id = f8
   1 communication_id = f8
   1 generated_comm_dt_tm = dq8
   1 scheduled_communication_id = f8
   1 scheduled_comm_dt_tm = dq8
   1 invitation_id = f8
 )
 SET cust_ucb_dummy = 0
 IF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
  CALL cust_ucb_upt(null)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=del))
  CALL cust_ucb_del2(null)
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  GO TO exit_sub
 ENDIF
 SUBROUTINE cust_ucb_upt(null)
   SELECT INTO "nl:"
    FROM invtn_invitation ii
    WHERE (ii.invitation_id=rchildren->qual1[det_cnt].entity_id)
    DETAIL
     invitation->person_id = request->xxx_uncombine[ucb_cnt].to_xxx_id, invitation->program_id = ii
     .program_id, invitation->parent_entity_name = ii.parent_entity_name,
     invitation->parent_entity_id = ii.parent_entity_id, invitation->communication_id = 0, invitation
     ->generated_comm_dt_tm = null,
     invitation->scheduled_communication_id = 0, invitation->scheduled_comm_dt_tm = null, invitation
     ->invitation_id = rchildren->qual1[det_cnt].entity_id
    WITH forupdatewait(ii)
   ;end select
   IF (curqual=0)
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET stat = determine_parent_entity(null)
   SET stat = determine_scheduled_communication(null)
   SET stat = determine_generated_communication(null)
   UPDATE  FROM invtn_invitation ii
    SET ii.updt_cnt = (ii.updt_cnt+ 1), ii.updt_id = reqinfo->updt_id, ii.updt_applctx = reqinfo->
     updt_applctx,
     ii.updt_task = reqinfo->updt_task, ii.updt_dt_tm = cnvtdatetime(sysdate), ii.person_id =
     invitation->person_id,
     ii.last_updated_by_id = reqinfo->updt_id, ii.last_updated_dt_tm = cnvtdatetime(sysdate), ii
     .parent_entity_id = invitation->parent_entity_id,
     ii.communication_id = invitation->communication_id, ii.generated_comm_dt_tm = cnvtdatetime(
      invitation->generated_comm_dt_tm), ii.scheduled_communication_id = invitation->
     scheduled_communication_id,
     ii.scheduled_comm_dt_tm = cnvtdatetime(invitation->scheduled_comm_dt_tm)
    WHERE (ii.invitation_id=invitation->invitation_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
   FREE SET invitation
 END ;Subroutine
 SUBROUTINE cust_ucb_del2(null)
   UPDATE  FROM invtn_invitation ii
    SET ii.updt_cnt = (ii.updt_cnt+ 1), ii.updt_id = reqinfo->updt_id, ii.updt_applctx = reqinfo->
     updt_applctx,
     ii.updt_task = reqinfo->updt_task, ii.updt_dt_tm = cnvtdatetime(sysdate), ii.last_updated_by_id
      = reqinfo->updt_id,
     ii.last_updated_dt_tm = cnvtdatetime(sysdate), ii.active_ind = 1
    WHERE (ii.invitation_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = reactivate_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SELECT INTO "nl:"
    FROM invtn_invitation ii
    WHERE (ii.person_id=request->xxx_uncombine[ucb_cnt].from_xxx_id)
     AND (ii.program_id=
    (SELECT
     program_id
     FROM invtn_invitation
     WHERE (invitation_id=rchildren->qual1[det_cnt].entity_id)))
    DETAIL
     invitation->person_id = ii.person_id, invitation->program_id = ii.program_id, invitation->
     invitation_id = ii.invitation_id,
     invitation->communication_id = 0, invitation->generated_comm_dt_tm = null, invitation->
     scheduled_communication_id = 0,
     invitation->scheduled_comm_dt_tm = null
    WITH forupdatewait(ii)
   ;end select
   IF (curqual=0)
    SET ucb_failed = reactivate_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET stat = determine_scheduled_communication(null)
   SET stat = determine_generated_communication(null)
   UPDATE  FROM invtn_invitation ii
    SET ii.updt_cnt = (ii.updt_cnt+ 1), ii.updt_id = reqinfo->updt_id, ii.updt_applctx = reqinfo->
     updt_applctx,
     ii.updt_task = reqinfo->updt_task, ii.updt_dt_tm = cnvtdatetime(sysdate), ii.last_updated_by_id
      = reqinfo->updt_id,
     ii.last_updated_dt_tm = cnvtdatetime(sysdate), ii.communication_id = invitation->
     communication_id, ii.generated_comm_dt_tm = cnvtdatetime(invitation->generated_comm_dt_tm),
     ii.scheduled_communication_id = invitation->scheduled_communication_id, ii.scheduled_comm_dt_tm
      = cnvtdatetime(invitation->scheduled_comm_dt_tm)
    WHERE (ii.invitation_id=invitation->invitation_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = reactivate_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE determine_parent_entity(null)
  IF ((invitation->parent_entity_name="HM_RECOMMENDATION"))
   SELECT INTO "nl:"
    FROM hm_recommendation hr
    WHERE (hr.person_id=invitation->person_id)
     AND (hr.expect_id=
    (SELECT
     expect_id
     FROM hm_recommendation
     WHERE (recommendation_id=invitation->parent_entity_id)))
    DETAIL
     invitation->parent_entity_id = hr.recommendation_id
    WITH nocounter
   ;end select
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE determine_scheduled_communication(null)
  SELECT INTO "nl:"
   FROM invtn_communication ic
   WHERE (ic.person_id=invitation->person_id)
    AND (ic.program_id=invitation->program_id)
    AND ic.status_flag=2
    AND ic.scheduled_dt_tm IS NOT null
   ORDER BY ic.scheduled_dt_tm DESC
   DETAIL
    invitation->scheduled_communication_id = ic.communication_id, invitation->scheduled_comm_dt_tm =
    ic.scheduled_dt_tm
   WITH nocounter, maxrec = 1
  ;end select
  RETURN(1)
 END ;Subroutine
 SUBROUTINE determine_generated_communication(null)
  SELECT INTO "nl:"
   FROM invtn_communication ic
   WHERE (ic.person_id=invitation->person_id)
    AND (ic.program_id=invitation->program_id)
    AND ic.status_flag IN (3, 4, 5)
    AND ic.generated_dt_tm IS NOT null
   ORDER BY ic.generated_dt_tm DESC
   DETAIL
    invitation->communication_id = ic.communication_id, invitation->generated_comm_dt_tm = ic
    .generated_dt_tm
   WITH nocounter, maxrec = 1
  ;end select
  RETURN(1)
 END ;Subroutine
#exit_sub
END GO

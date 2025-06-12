CREATE PROGRAM dm_oucb_problem_drr:dba
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
 DECLARE cust_ucb_upt(null) = null
 DECLARE cust_ucb_del2(null) = null
 DECLARE debug_ind = i2
 IF (validate(request->debug_ind))
  SET debug_ind = request->debug_ind
 ELSE
  SET debug_ind = 0
 ENDIF
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  IF (debug_ind=1)
   CALL echo("********DM_OUCB_PROBLEM_DRR - maintaining exception")
  ENDIF
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ORGANIZATION"
  SET dcem_request->qual[1].child_entity = "PROBLEM0859DRR"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_OUCB_PROBLEM_DRR"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 IF (debug_ind=1)
  CALL echo(build("********DM_OUCB_PROBLEM_DRR - FROM_XXX_ID = ",request->xxx_uncombine[ucb_cnt].
    from_xxx_id))
  CALL echo(build("********DM_OUCB_PROBLEM_DRR - TO_XXX_ID = ",request->xxx_uncombine[ucb_cnt].
    to_xxx_id))
  CALL echo(build("********DM_OUCB_PROBLEM_DRR - data_number = ",rchildren->qual1[det_cnt].entity_pk[
    1].data_number))
  CALL echo(build("********DM_OUCB_PROBLEM_DRR - combine_action_cd = ",rchildren->qual1[det_cnt].
    combine_action_cd))
 ENDIF
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
  UPDATE  FROM problem0859drr p1
   SET p1.organization_id = request->xxx_uncombine[ucb_cnt].to_xxx_id, p1.updt_id = reqinfo->updt_id,
    p1.updt_dt_tm = cnvtdatetime(sysdate),
    p1.updt_applctx = reqinfo->updt_applctx, p1.updt_cnt = (updt_cnt+ 1), p1.updt_task = reqinfo->
    updt_task
   WHERE (p1.organization_id=request->xxx_uncombine[ucb_cnt].from_xxx_id)
    AND (p1.problem_id=
   (SELECT
    p2.problem_id
    FROM problem0859drr p2
    WHERE (p2.problem_instance_id=rchildren->qual1[det_cnt].entity_pk[1].data_number)))
   WITH nocounter
  ;end update
  SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE cust_ucb_del2(null)
   UPDATE  FROM problem0859drr p1
    SET p1.updt_id = reqinfo->updt_id, p1.updt_dt_tm = cnvtdatetime(sysdate), p1.updt_applctx =
     reqinfo->updt_applctx,
     p1.updt_cnt = (p1.updt_cnt+ 1), p1.updt_task = reqinfo->updt_task, p1.active_ind = rchildren->
     qual1[det_cnt].prev_active_ind,
     p1.active_status_cd = rchildren->qual1[det_cnt].prev_active_status_cd, p1.active_status_dt_tm =
     cnvtdatetime(sysdate), p1.active_status_prsnl_id = reqinfo->updt_id,
     p1.end_effective_dt_tm = cnvtdatetime(rchildren->qual1[det_cnt].prev_end_eff_dt_tm)
    WHERE (p1.problem_instance_id=rchildren->qual1[det_cnt].entity_pk[1].data_number)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = reactivate_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
#exit_sub
END GO

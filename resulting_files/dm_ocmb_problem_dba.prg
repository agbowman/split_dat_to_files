CREATE PROGRAM dm_ocmb_problem:dba
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
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 pk_col1 = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 person_id = f8
     2 problem_id = f8
     2 end_effective_dt_tm = dq8
   1 to_rec[*]
     2 pk_col1 = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 person_id = f8
     2 problem_id = f8
     2 end_effective_dt_tm = dq8
 )
 DECLARE v_cust_count1 = i4
 DECLARE v_cust_count2 = i4
 DECLARE v_cust_loopcount = i4
 DECLARE conflict_prob_cnt = i4
 DECLARE prob_idx = i4
 DECLARE debug_ind = i2
 SET v_cust_count1 = 0
 SET v_cust_count2 = 0
 SET v_cust_loopcount = 0
 SET conflict_prob_cnt = 0
 SET prob_idx = 0
 IF (validate(request->debug_ind))
  SET debug_ind = request->debug_ind
 ELSE
  SET debug_ind = 0
 ENDIF
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  IF (debug_ind=1)
   CALL echo("********DM_OCMB_PROBLEM - maintaining exception")
  ENDIF
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ORGANIZATION"
  SET dcem_request->qual[1].child_entity = "PROBLEM"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_OCMB_PROBLEM"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 FREE SET conflict_problems
 RECORD conflict_problems(
   1 problems[*]
     2 problem_id = f8
 )
 IF (debug_ind=1)
  CALL echo(build("********DM_OCMB_PROBLEM - from_xxx_id = ",request->xxx_combine[icombine].
    from_xxx_id))
  CALL echo(build("********DM_OCMB_PROBLEM - to_xxx_id = ",request->xxx_combine[icombine].to_xxx_id))
 ENDIF
 SELECT INTO "nl:"
  frm.*
  FROM problem frm
  WHERE (frm.organization_id=request->xxx_combine[icombine].from_xxx_id)
  HEAD REPORT
   v_cust_count1 = 0
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].pk_col1 = frm.problem_instance_id, rreclist->from_rec[
   v_cust_count1].active_ind = frm.active_ind, rreclist->from_rec[v_cust_count1].active_status_cd =
   frm.active_status_cd,
   rreclist->from_rec[v_cust_count1].person_id = frm.person_id, rreclist->from_rec[v_cust_count1].
   problem_id = frm.problem_id, rreclist->from_rec[v_cust_count1].end_effective_dt_tm = frm
   .end_effective_dt_tm
  FOOT REPORT
   stat = alterlist(rreclist->from_rec,v_cust_count1)
  WITH forupdatewait(frm)
 ;end select
 IF (v_cust_count1 > 0)
  SELECT INTO "nl:"
   tu.*
   FROM problem tu
   WHERE (tu.organization_id=request->xxx_combine[icombine].to_xxx_id)
   HEAD REPORT
    v_cust_count2 = 0
   DETAIL
    v_cust_count2 += 1
    IF (mod(v_cust_count2,10)=1)
     stat = alterlist(rreclist->to_rec,(v_cust_count2+ 9))
    ENDIF
    rreclist->to_rec[v_cust_count2].pk_col1 = tu.problem_instance_id, rreclist->to_rec[v_cust_count2]
    .active_ind = tu.active_ind, rreclist->to_rec[v_cust_count2].active_status_cd = tu
    .active_status_cd,
    rreclist->to_rec[v_cust_count2].person_id = tu.person_id, rreclist->to_rec[v_cust_count2].
    problem_id = tu.problem_id, rreclist->to_rec[v_cust_count2].end_effective_dt_tm = tu
    .end_effective_dt_tm
   FOOT REPORT
    stat = alterlist(rreclist->to_rec,v_cust_count2)
   WITH forupdatewait(tu)
  ;end select
  SELECT INTO "nl:"
   FROM pregnancy_instance pi1,
    pregnancy_instance pi2
   PLAN (pi1
    WHERE (pi1.organization_id=request->xxx_combine[icombine].to_xxx_id)
     AND pi1.active_ind=1
     AND pi1.preg_end_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (pi2
    WHERE pi2.person_id=pi1.person_id
     AND (pi2.organization_id=request->xxx_combine[icombine].from_xxx_id)
     AND pi2.active_ind=1
     AND pi2.preg_end_dt_tm=cnvtdatetime("31-DEC-2100"))
   ORDER BY pi2.person_id
   HEAD REPORT
    conflict_prob_cnt = 0
   HEAD pi2.person_id
    conflict_prob_cnt += 1
    IF (mod(conflict_prob_cnt,10)=1)
     stat = alterlist(conflict_problems->problems,(conflict_prob_cnt+ 9))
    ENDIF
    conflict_problems->problems[conflict_prob_cnt].problem_id = pi2.problem_id
   FOOT REPORT
    stat = alterlist(conflict_problems->problems,conflict_prob_cnt)
   WITH nocounter
  ;end select
  IF (debug_ind=1)
   CALL echorecord(rreclist)
   CALL echorecord(conflict_problems)
  ENDIF
  FOR (v_cust_loopcount = 1 TO v_cust_count1)
    IF ((rreclist->from_rec[v_cust_loopcount].active_status_cd != combinedaway))
     SET prob_pos = locateval(prob_idx,1,conflict_prob_cnt,rreclist->from_rec[v_cust_loopcount].
      problem_id,conflict_problems->problems[prob_idx].problem_id)
     IF (prob_pos > 0)
      IF (del_from(rreclist->from_rec[v_cust_loopcount].pk_col1,rreclist->from_rec[v_cust_loopcount].
       active_ind,rreclist->from_rec[v_cust_loopcount].active_status_cd,rreclist->from_rec[
       v_cust_loopcount].end_effective_dt_tm)=0)
       GO TO exit_sub
      ENDIF
     ELSE
      IF (updt_from(rreclist->from_rec[v_cust_loopcount].pk_col1)=0)
       GO TO exit_sub
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE del_from(s_df_pk_id,s_df_prev_act_ind,s_df_prev_act_status,s_df_prev_end_eff_dt_tm)
   UPDATE  FROM problem frm
    SET frm.active_ind = false, frm.active_status_cd = combinedaway, frm.updt_cnt = (frm.updt_cnt+ 1),
     frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task =
     reqinfo->updt_task,
     frm.updt_dt_tm = cnvtdatetime(sysdate), frm.end_effective_dt_tm = cnvtdatetime(sysdate)
    WHERE frm.problem_instance_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PROBLEM"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ORGANIZATION_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_df_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_df_prev_act_status
   SET request->xxx_combine_det[icombinedet].prev_end_eff_dt_tm = s_df_prev_end_eff_dt_tm
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "PROBLEM_INSTANCE_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_df_pk_id
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build("Could not inactivate problem_instance_id=",
      s_df_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE updt_from(s_uf_pk_id)
   UPDATE  FROM problem frm
    SET frm.organization_id = request->xxx_combine[icombine].to_xxx_id, frm.updt_cnt = (frm.updt_cnt
     + 1), frm.updt_id = reqinfo->updt_id,
     frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm =
     cnvtdatetime(sysdate)
    WHERE frm.problem_instance_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = s_uf_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PROBLEM"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ORGANIZATION_ID"
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "PROBLEM_INSTANCE_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_uf_pk_id
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = build("Could not update PROBLEM record with problem_instance_id = ",
     s_uf_pk_id)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SET ecode = 0
 SET emsg = fillstring(132," ")
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
  SET request->error_message = concat(emsg,";",request->error_message)
 ENDIF
#exit_sub
 FREE SET rreclist
END GO

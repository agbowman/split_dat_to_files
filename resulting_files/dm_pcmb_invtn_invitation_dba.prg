CREATE PROGRAM dm_pcmb_invtn_invitation:dba
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
     2 from_id = f8
     2 active_ind = i4
     2 program_id = f8
     2 parent_entity_name = c30
     2 parent_entity_id = f8
     2 communication_id = f8
     2 generated_comm_dt_tm = dq8
     2 assign_dt_tm = dq8
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 program_id = f8
     2 communication_id = f8
     2 generated_comm_dt_tm = dq8
     2 assign_dt_tm = dq8
     2 update_ind = i2
 )
 DECLARE v_cust_count1 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_count2 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH noconstant(0), public
 DECLARE start = i4 WITH noconstant(1), public
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "INVTN_INVITATION"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "dm_pcmb_invtn_invitation"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 2
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 SELECT INTO "nl:"
  frm.*
  FROM invtn_invitation frm
  WHERE (frm.person_id=request->xxx_combine[icombine].from_xxx_id)
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_id = frm.invitation_id, rreclist->from_rec[v_cust_count1].
   active_ind = frm.active_ind, rreclist->from_rec[v_cust_count1].program_id = frm.program_id,
   rreclist->from_rec[v_cust_count1].parent_entity_name = frm.parent_entity_name, rreclist->from_rec[
   v_cust_count1].parent_entity_id = frm.parent_entity_id, rreclist->from_rec[v_cust_count1].
   communication_id = frm.communication_id,
   rreclist->from_rec[v_cust_count1].generated_comm_dt_tm = frm.generated_comm_dt_tm, rreclist->
   from_rec[v_cust_count1].assign_dt_tm = frm.assign_dt_tm
  FOOT REPORT
   stat = alterlist(rreclist->from_rec,v_cust_count1)
  WITH forupdatewait(frm)
 ;end select
 IF (v_cust_count1 > 0)
  SELECT INTO "nl:"
   tu.*
   FROM invtn_invitation tu
   WHERE (tu.person_id=request->xxx_combine[icombine].to_xxx_id)
   ORDER BY tu.program_id
   DETAIL
    v_cust_count2 += 1
    IF (mod(v_cust_count2,10)=1)
     stat = alterlist(rreclist->to_rec,(v_cust_count2+ 9))
    ENDIF
    rreclist->to_rec[v_cust_count2].to_id = tu.invitation_id, rreclist->to_rec[v_cust_count2].
    active_ind = tu.active_ind, rreclist->to_rec[v_cust_count2].program_id = tu.program_id,
    rreclist->to_rec[v_cust_count2].communication_id = tu.communication_id, rreclist->to_rec[
    v_cust_count2].generated_comm_dt_tm = tu.generated_comm_dt_tm, rreclist->to_rec[v_cust_count2].
    assign_dt_tm = tu.assign_dt_tm,
    rreclist->to_rec[v_cust_count2].update_ind = false
   FOOT REPORT
    stat = alterlist(rreclist->to_rec,v_cust_count2)
   WITH forupdatewait(tu)
  ;end select
  FOR (v_cust_loopcount = 1 TO v_cust_count1)
   SET pos = locatevalsort(num,1,v_cust_count2,rreclist->from_rec[v_cust_loopcount].program_id,
    rreclist->to_rec[num].program_id)
   IF (pos > 0)
    IF ((rreclist->from_rec[v_cust_loopcount].generated_comm_dt_tm != rreclist->to_rec[pos].
    generated_comm_dt_tm)
     AND cnvtdatetime(rreclist->from_rec[v_cust_loopcount].generated_comm_dt_tm) > 0)
     IF (datetimediff(rreclist->from_rec[v_cust_loopcount].generated_comm_dt_tm,rreclist->to_rec[pos]
      .generated_comm_dt_tm) >= 0)
      SET rreclist->to_rec[pos].communication_id = rreclist->from_rec[v_cust_loopcount].
      communication_id
      SET rreclist->to_rec[pos].generated_comm_dt_tm = rreclist->from_rec[v_cust_loopcount].
      generated_comm_dt_tm
      SET rreclist->to_rec[pos].update_ind = true
     ENDIF
    ENDIF
    IF (datetimediff(rreclist->from_rec[v_cust_loopcount].assign_dt_tm,rreclist->to_rec[pos].
     assign_dt_tm) > 0)
     SET rreclist->to_rec[pos].assign_dt_tm = rreclist->from_rec[v_cust_loopcount].assign_dt_tm
     SET rreclist->to_rec[pos].update_ind = true
    ENDIF
    SET stat = upt_to(pos)
    SET stat = del_from(rreclist->from_rec[v_cust_loopcount].from_id)
   ELSE
    SET to_parent_entity_id = find_relevant_parent_entity(rreclist->from_rec[v_cust_loopcount].
     parent_entity_name,rreclist->from_rec[v_cust_loopcount].parent_entity_id)
    SET stat = upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
     to_xxx_id,to_parent_entity_id)
   ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE (upt_from(s_uf_pk_id=f8,s_uf_to_fk_id=f8,s_uf_to_pe_id=f8) =i4)
   UPDATE  FROM invtn_invitation ii
    SET ii.updt_cnt = (ii.updt_cnt+ 1), ii.updt_id = reqinfo->updt_id, ii.updt_applctx = reqinfo->
     updt_applctx,
     ii.updt_task = reqinfo->updt_task, ii.updt_dt_tm = cnvtdatetime(sysdate), ii.parent_entity_id =
     s_uf_to_pe_id,
     ii.person_id = s_uf_to_fk_id, ii.last_updated_by_id = reqinfo->updt_id, ii.last_updated_dt_tm =
     cnvtdatetime(sysdate),
     ii.scheduled_communication_id = 0, ii.scheduled_comm_dt_tm = null
    WHERE ii.invitation_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = s_uf_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "INVTN_INVITATION"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",s_uf_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (upt_to(s_ut_to_index_pos=i4) =i4)
   IF ((rreclist->to_rec[s_ut_to_index_pos].update_ind=false))
    RETURN(1)
   ENDIF
   UPDATE  FROM invtn_invitation ii
    SET ii.communication_id = rreclist->to_rec[s_ut_to_index_pos].communication_id, ii
     .generated_comm_dt_tm = cnvtdatetime(rreclist->to_rec[s_ut_to_index_pos].generated_comm_dt_tm),
     ii.assign_dt_tm = cnvtdatetime(rreclist->to_rec[s_ut_to_index_pos].assign_dt_tm),
     ii.updt_cnt = (ii.updt_cnt+ 1), ii.updt_id = reqinfo->updt_id, ii.updt_applctx = reqinfo->
     updt_applctx,
     ii.updt_task = reqinfo->updt_task, ii.updt_dt_tm = cnvtdatetime(sysdate), ii.last_updated_by_id
      = reqinfo->updt_id,
     ii.last_updated_dt_tm = cnvtdatetime(sysdate)
    WHERE (ii.invitation_id=rreclist->to_rec[s_ut_to_index_pos].to_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",rreclist->to_rec[
      s_ut_to_index_pos].to_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (del_from(s_df_pk_id=f8) =i4)
   UPDATE  FROM invtn_invitation ii
    SET ii.active_ind = false, ii.updt_cnt = (ii.updt_cnt+ 1), ii.updt_id = reqinfo->updt_id,
     ii.updt_applctx = reqinfo->updt_applctx, ii.updt_task = reqinfo->updt_task, ii.updt_dt_tm =
     cnvtdatetime(sysdate)
    WHERE ii.invitation_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "INVTN_INVITATION"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = true
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = 0
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build("Could not inactivate pk val=",s_df_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (find_relevant_parent_entity(s_frpe_pe_name=c30,s_frpe_pe_id=f8) =f8)
   DECLARE parent_entity_id = f8 WITH protect, noconstant(s_frpe_pe_id)
   IF (s_frpe_pe_name="HM_RECOMMENDATION")
    SELECT INTO "nl:"
     FROM hm_recommendation hr
     WHERE (hr.person_id=request->xxx_combine[icombine].to_xxx_id)
      AND (hr.expect_id=
     (SELECT
      expect_id
      FROM hm_recommendation
      WHERE recommendation_id=s_frpe_pe_id))
     DETAIL
      parent_entity_id = hr.recommendation_id
     WITH nocounter
    ;end select
   ENDIF
   RETURN(parent_entity_id)
 END ;Subroutine
#exit_sub
 FREE SET rreclist
END GO

CREATE PROGRAM dm_prcmb_cp_pathway:dba
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
     2 active_status_cd = f8
     2 cp_pathway_id = f8
 )
 DECLARE v_cust_count = i4 WITH noconstant(0)
 DECLARE v_cust_loopcount = i4 WITH noconstant(0)
 DECLARE conflict_cp_pathway_cnt = i4 WITH noconstant(0)
 DECLARE activity_idx = i4 WITH noconstant(0)
 DECLARE activity_pos = i4 WITH noconstant(0)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PRSNL"
  SET dcem_request->qual[1].child_entity = "CP_PATHWAY"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PRCMB_CP_PATHWAY"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 FREE SET conflict_cp_pathway
 RECORD conflict_cp_pathway(
   1 cp_pathway[*]
     2 cp_pathway_id = f8
 )
 SELECT INTO "nl:"
  FROM cp_pathway cp,
   cp_pathway cp1
  WHERE (cp.owner_prsnl_id=request->xxx_combine[icombine].from_xxx_id)
   AND (cp1.owner_prsnl_id=request->xxx_combine[icombine].to_xxx_id)
   AND cp1.pathway_name=cp.pathway_name
   AND cp1.pathway_type_cd=cp.pathway_type_cd
  DETAIL
   conflict_cp_pathway_cnt += 1
   IF (mod(conflict_cp_pathway_cnt,10)=1)
    stat = alterlist(conflict_cp_pathway->cp_pathway,(conflict_cp_pathway_cnt+ 9))
   ENDIF
   conflict_cp_pathway->cp_pathway[conflict_cp_pathway_cnt].cp_pathway_id = cp.cp_pathway_id
  WITH nocounter
 ;end select
 SET stat = alterlist(conflict_cp_pathway->cp_pathway,conflict_cp_pathway_cnt)
 SELECT INTO "nl:"
  FROM cp_pathway cp
  WHERE (cp.owner_prsnl_id=request->xxx_combine[icombine].from_xxx_id)
  DETAIL
   v_cust_count += 1
   IF (mod(v_cust_count,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count].cp_pathway_id = cp.cp_pathway_id, rreclist->from_rec[v_cust_count
   ].from_id = cp.owner_prsnl_id, rreclist->from_rec[v_cust_count].active_ind = cp.active_ind,
   rreclist->from_rec[v_cust_count].active_status_cd = cp.active_status_cd
  WITH forupdatewait(frm)
 ;end select
 SET stat = alterlist(rreclist->from_rec,v_cust_count)
 FOR (v_cust_loopcount = 1 TO v_cust_count)
   IF ((rreclist->from_rec[v_cust_loopcount].active_status_cd != combinedaway))
    SET activity_pos = locateval(activity_idx,1,conflict_cp_pathway_cnt,rreclist->from_rec[
     v_cust_loopcount].cp_pathway_id,conflict_cp_pathway->cp_pathway[activity_idx].cp_pathway_id)
    IF (activity_pos > 0)
     IF (del_from(conflict_cp_pathway->cp_pathway[activity_pos].cp_pathway_id,rreclist->from_rec[
      v_cust_loopcount].active_ind,rreclist->from_rec[v_cust_loopcount].active_status_cd)=0)
      GO TO exit_sub
     ENDIF
    ELSE
     IF (upt_from(rreclist->from_rec[v_cust_loopcount].cp_pathway_id,request->xxx_combine[icombine].
      to_xxx_id)=0)
      GO TO exit_sub
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE del_from(s_df_pk_id,s_df_prev_act_ind,s_df_prev_act_status)
   UPDATE  FROM cp_pathway cp
    SET cp.active_ind = false, cp.active_status_cd = combinedaway, cp.updt_cnt = (cp.updt_cnt+ 1),
     cp.updt_id = reqinfo->updt_id, cp.updt_applctx = reqinfo->updt_applctx, cp.updt_task = reqinfo->
     updt_task,
     cp.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE cp.cp_pathway_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "CP_PATHWAY"
   SET request->xxx_combine_det[icombinedet].attribute_name = "CP_PATHWAY_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_df_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_df_prev_act_status
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build("Could not inactivate pk val=",s_df_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE upt_from(s_uf_pk_id,s_uf_to_fk_id)
   UPDATE  FROM cp_pathway cp
    SET cp.updt_cnt = (cp.updt_cnt+ 1), cp.updt_id = reqinfo->updt_id, cp.updt_applctx = reqinfo->
     updt_applctx,
     cp.updt_task = reqinfo->updt_task, cp.updt_dt_tm = cnvtdatetime(sysdate), cp.owner_prsnl_id =
     s_uf_to_fk_id
    WHERE cp.cp_pathway_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = s_uf_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "CP_PATHWAY"
   SET request->xxx_combine_det[icombinedet].attribute_name = "OWNER_PRSNL_ID"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",s_uf_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_sub
 FREE SET conflict_cp_pathway
 FREE SET rreclist
END GO

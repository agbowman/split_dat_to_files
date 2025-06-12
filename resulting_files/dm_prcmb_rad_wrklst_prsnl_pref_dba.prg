CREATE PROGRAM dm_prcmb_rad_wrklst_prsnl_pref:dba
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
     2 prsnl_id = f8
     2 rad_wrklst_def_id = f8
     2 fav_ind = i4
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 prsnl_id = f8
     2 rad_wrklst_def_id = f8
     2 fav_ind = i4
 )
 DECLARE v_cust_count1 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_count2 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount2 = i4 WITH protect, noconstant(0)
 DECLARE to_id_present = i4 WITH protect, noconstant(0)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PRSNL"
  SET dcem_request->qual[1].child_entity = "RAD_WRKLST_PRSNL_PREF"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PRCMB_RAD_WRKLST_PRSNL_PREF"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 SELECT INTO "nl:"
  frm.*
  FROM rad_wrklst_prsnl_pref frm
  WHERE (frm.prsnl_id=request->xxx_combine[icombine].from_xxx_id)
   AND frm.active_ind=1
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_id = frm.rad_wrklst_prsnl_pref_id, rreclist->from_rec[
   v_cust_count1].active_ind = frm.active_ind, rreclist->from_rec[v_cust_count1].active_status_cd =
   frm.active_status_cd,
   rreclist->from_rec[v_cust_count1].rad_wrklst_def_id = frm.rad_wrklst_def_id, rreclist->from_rec[
   v_cust_count1].prsnl_id = frm.prsnl_id, rreclist->from_rec[v_cust_count1].fav_ind = frm.fav_ind
  WITH forupdatewait(frm)
 ;end select
 IF (v_cust_count1 > 0)
  SELECT INTO "nl:"
   tu.*
   FROM rad_wrklst_prsnl_pref tu
   WHERE (tu.prsnl_id=request->xxx_combine[icombine].to_xxx_id)
    AND tu.active_ind=1
   DETAIL
    v_cust_count2 += 1
    IF (mod(v_cust_count2,10)=1)
     stat = alterlist(rreclist->to_rec,(v_cust_count2+ 9))
    ENDIF
    rreclist->to_rec[v_cust_count2].to_id = tu.rad_wrklst_prsnl_pref_id, rreclist->to_rec[
    v_cust_count2].active_ind = tu.active_ind, rreclist->to_rec[v_cust_count2].active_status_cd = tu
    .active_status_cd,
    rreclist->to_rec[v_cust_count2].rad_wrklst_def_id = tu.rad_wrklst_def_id, rreclist->to_rec[
    v_cust_count2].prsnl_id = tu.prsnl_id, rreclist->to_rec[v_cust_count2].fav_ind = tu.fav_ind
   WITH forupdatewait(tu)
  ;end select
  FOR (v_cust_loopcount = 1 TO v_cust_count1)
   SET to_id_present = locateval(v_cust_loopcount2,1,v_cust_count2,rreclist->from_rec[
    v_cust_loopcount].rad_wrklst_def_id,rreclist->to_rec[v_cust_loopcount2].rad_wrklst_def_id)
   IF (to_id_present != 0)
    IF ((((rreclist->from_rec[v_cust_loopcount].fav_ind=rreclist->to_rec[to_id_present].fav_ind)) OR
    ((rreclist->to_rec[to_id_present].fav_ind=1))) )
     IF (del_from(rreclist->from_rec[v_cust_loopcount].from_id,rreclist->from_rec[v_cust_loopcount].
      active_ind,rreclist->from_rec[v_cust_loopcount].active_status_cd)=0)
      GO TO exit_sub
     ENDIF
    ELSE
     IF (del_to(rreclist->to_rec[to_id_present].to_id,rreclist->to_rec[to_id_present].active_ind,
      rreclist->to_rec[to_id_present].active_status_cd)=1)
      IF (upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
       to_xxx_id)=0)
       GO TO exit_sub
      ENDIF
     ELSE
      GO TO exit_sub
     ENDIF
    ENDIF
   ELSE
    IF (upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
     to_xxx_id)=0)
     GO TO exit_sub
    ENDIF
   ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE (del_from(s_df_pk_id=f8,s_df_prev_act_ind=i2,s_df_prev_act_status=f8) =i4)
   UPDATE  FROM rad_wrklst_prsnl_pref frm
    SET frm.active_ind = false, frm.active_status_cd = combinedaway, frm.active_status_dt_tm =
     cnvtdatetime(sysdate),
     frm.active_status_prsnl_id = reqinfo->updt_id, frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id =
     reqinfo->updt_id,
     frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm =
     cnvtdatetime(sysdate)
    WHERE frm.rad_wrklst_prsnl_pref_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "RAD_WRKLST_PRSNL_PREF"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PRSNL_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_df_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_df_prev_act_status
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "RAD_WRKLST_PRSNL_PREF_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_df_pk_id
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = build(
     "DEL_FROM:No values found on the rad_wrklst_prsnl_pref table for rad_wrklst_prsnl_pref_id=",
     s_df_pk_id)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (del_to(s_dt_pk_id=f8,s_dt_prev_act_ind=i2,s_dt_prev_act_status=f8) =i4)
   UPDATE  FROM rad_wrklst_prsnl_pref tu
    SET tu.active_ind = false, tu.active_status_cd = combinedaway, tu.active_status_dt_tm =
     cnvtdatetime(sysdate),
     tu.active_status_prsnl_id = reqinfo->updt_id, tu.updt_cnt = (tu.updt_cnt+ 1), tu.updt_id =
     reqinfo->updt_id,
     tu.updt_applctx = reqinfo->updt_applctx, tu.updt_task = reqinfo->updt_task, tu.updt_dt_tm =
     cnvtdatetime(sysdate)
    WHERE tu.rad_wrklst_prsnl_pref_id=s_dt_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_dt_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "RAD_WRKLST_PRSNL_PREF"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PRSNL_ID"
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "RAD_WRKLST_PRSNL_PREF_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_dt_pk_id
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_dt_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_dt_prev_act_status
   SET request->xxx_combine_det[icombinedet].to_record_ind = 1
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = build(
     "No value in rad_wrklst_prsnl_pref table to inactivate with rad_wrklst_prsnl_pref_id=",
     s_dt_pk_id)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (upt_from(s_uf_pk_id=f8,s_uf_to_fk_id=f8) =i4)
   UPDATE  FROM rad_wrklst_prsnl_pref frm
    SET frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo
     ->updt_applctx,
     frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = cnvtdatetime(sysdate), frm.prsnl_id =
     s_uf_to_fk_id
    WHERE frm.rad_wrklst_prsnl_pref_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_name = "RAD_WRKLST_PRSNL_PREF"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PRSNL_ID"
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "RAD_WRKLST_PRSNL_PREF_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_uf_pk_id
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = build(
     "Couldn't update RAD_WRKLST_PRSNL_PREF record with rad_wrklst_prsnl_pref_id= ",s_uf_pk_id)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SET ecode = 0
 SET emsg = fillstring(132," ")
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
 ENDIF
#exit_sub
 FREE SET rreclist
END GO

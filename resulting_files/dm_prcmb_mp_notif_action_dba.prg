CREATE PROGRAM dm_prcmb_mp_notif_action:dba
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
 IF (validate(dm_cmb_cust_cols->tbl_name,"X")="X"
  AND validate(dm_cmb_cust_cols->tab_name,"Z")="Z")
  RECORD dm_cmb_cust_cols(
    1 tbl_name = vc
    1 updt_std_val_ind = i2
    1 active_std_val_ind = i2
    1 col[*]
      2 col_name = vc
    1 add_col_val[*]
      2 col_name = vc
      2 col_value = vc
    1 where_col_val[*]
      2 col_name = vc
      2 col_value = vc
    1 sub_select_from_tbl = vc
  )
 ENDIF
 IF (validate(dm_cmb_cust_cols2->tbl_name,"X")="X"
  AND validate(dm_cmb_cust_cols2->tab_name,"Z")="Z")
  RECORD dm_cmb_cust_cols2(
    1 tbl_name = vc
    1 updt_std_val_ind = i2
    1 active_std_val_ind = i2
    1 col[*]
      2 col_name = vc
    1 add_col_val[*]
      2 col_name = vc
      2 col_value = vc
    1 where_col_val[*]
      2 col_name = vc
      2 col_value = vc
    1 sub_select_from_tbl = vc
  )
 ENDIF
 IF (validate(dm_err->ecode,- (1)) < 0)
  FREE RECORD dm_err
  RECORD dm_err(
    1 logfile = vc
    1 debug_flag = i2
    1 ecode = i4
    1 emsg = c132
    1 eproc = vc
    1 err_ind = i2
    1 user_action = vc
    1 asterisk_line = c80
    1 tempstr = vc
    1 errfile = vc
    1 errtext = vc
    1 unique_fname = vc
    1 disp_msg_emsg = vc
    1 disp_dcl_err_ind = i2
  )
  SET dm_err->asterisk_line = fillstring(80,"*")
  SET dm_err->ecode = 0
  IF (validate(dm2_debug_flag,- (1)) > 0)
   SET dm_err->debug_flag = dm2_debug_flag
  ELSE
   SET dm_err->debug_flag = 0
  ENDIF
  SET dm_err->err_ind = 0
  SET dm_err->user_action = "NONE"
  SET dm_err->tempstr = " "
  SET dm_err->errfile = "NONE"
  SET dm_err->logfile = "NONE"
  SET dm_err->unique_fname = "NONE"
  SET dm_err->disp_dcl_err_ind = 1
 ENDIF
 SUBROUTINE (check_error(sbr_ceprocess=vc) =i2)
   DECLARE return_val = i4 WITH protect, noconstant(0)
   IF ((dm_err->err_ind=1))
    SET return_val = 1
   ELSE
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->eproc = sbr_ceprocess
     SET dm_err->err_ind = 1
     SET return_val = 1
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 orig_notification_action_id = f8
     2 end_effective_dt_tm = dq8
     2 begin_effective_dt_tm = dq8
     2 detail_id = f8
     2 prev_active_status_cd = f8
   1 to_rec[*]
     2 to_id = f8
     2 orig_notification_action_id = f8
     2 end_effective_dt_tm = dq8
     2 begin_effective_dt_tm = dq8
 )
 DECLARE v_cust_count1 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount1 = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE new_notif_action_id = f8 WITH protect, noconstant(0.0)
 DECLARE org_notif_action_id = f8 WITH protect, noconstant(0.0)
 DECLARE end_eff_flag = i2 WITH protect, noconstant(0)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PRSNL"
  SET dcem_request->qual[1].child_entity = "MP_NOTIFICATION_ACTION"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PRCMB_MP_NOTIF_ACTION"
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
  FROM mp_notification_action frm
  WHERE (frm.action_prsnl_id=request->xxx_combine[icombine].from_xxx_id)
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_id = frm.mp_notification_action_id, rreclist->from_rec[
   v_cust_count1].orig_notification_action_id = frm.orig_mp_notification_action_id, rreclist->
   from_rec[v_cust_count1].begin_effective_dt_tm = frm.begin_effective_dt_tm,
   rreclist->from_rec[v_cust_count1].end_effective_dt_tm = frm.end_effective_dt_tm, rreclist->
   from_rec[v_cust_count1].detail_id = frm.mp_notification_detail_id, rreclist->from_rec[
   v_cust_count1].prev_active_status_cd = frm.active_status_cd
  WITH forupdatewait(frm)
 ;end select
 IF (v_cust_count1 > 0)
  SET stat = alterlist(rreclist->to_rec,1)
  FOR (v_cust_loopcount1 = 1 TO v_cust_count1)
    SELECT INTO "nl:"
     FROM mp_notification_action mna
     WHERE (mna.action_prsnl_id=request->xxx_combine[icombine].to_xxx_id)
      AND (mna.mp_notification_detail_id=rreclist->from_rec[v_cust_loopcount1].detail_id)
      AND mna.end_effective_dt_tm > cnvtdatetime(sysdate)
     DETAIL
      rreclist->to_rec[1].to_id = mna.mp_notification_action_id, rreclist->to_rec[1].
      orig_notification_action_id = mna.orig_mp_notification_action_id, rreclist->to_rec[1].
      begin_effective_dt_tm = mna.begin_effective_dt_tm,
      rreclist->to_rec[1].end_effective_dt_tm = mna.end_effective_dt_tm
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET end_eff_flag = 1
     SET org_notif_action_id = rreclist->to_rec[1].orig_notification_action_id
    ELSE
     SET end_eff_flag = 0
     SET org_notif_action_id = rreclist->from_rec[v_cust_loopcount1].orig_notification_action_id
    ENDIF
    IF (add_to(rreclist->from_rec[v_cust_loopcount1].from_id)=0)
     GO TO exit_sub
    ENDIF
    IF (del_from(rreclist->from_rec[v_cust_loopcount1].from_id,v_cust_loopcount1)=0)
     GO TO exit_sub
    ENDIF
    IF ((rreclist->from_rec[v_cust_loopcount1].end_effective_dt_tm > cnvtdatetime(sysdate))
     AND end_eff_flag > 0)
     IF ((rreclist->from_rec[v_cust_loopcount1].begin_effective_dt_tm > rreclist->to_rec[1].
     begin_effective_dt_tm))
      IF (end_eff(rreclist->to_rec[1].to_id,rreclist->to_rec[1].end_effective_dt_tm)=0)
       GO TO exit_sub
      ENDIF
     ELSE
      IF (end_eff(new_notif_action_id,rreclist->from_rec[v_cust_loopcount1].end_effective_dt_tm)=0)
       GO TO exit_sub
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE (del_from(s_df_pk_id=f8,s_frm_cnt=i4) =i2)
   UPDATE  FROM mp_notification_action mna
    SET mna.active_ind = 0, mna.active_status_cd = combinedaway, mna.active_status_dt_tm =
     cnvtdatetime(sysdate),
     mna.active_status_prsnl_id = reqinfo->updt_id, mna.updt_dt_tm = cnvtdatetime(sysdate), mna
     .updt_id = reqinfo->updt_id,
     mna.updt_applctx = reqinfo->updt_applctx, mna.updt_task = reqinfo->updt_task, mna.updt_cnt = (
     mna.updt_cnt+ 1)
    WHERE mna.mp_notification_action_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "MP_NOTIFICATION_ACTION"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ACTION_PRSNL_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = 1
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = rreclist->from_rec[s_frm_cnt].
   prev_active_status_cd
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "MP_NOTIFICATION_ACTION_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_df_pk_id
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = build(
     "DEL_FROM: No values found on the MP_NOTIFICATION_ACTION table with MP_NOTIFICATION_ACTION_ID = ",
     s_df_pk_id)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (add_to(s_df_pk_id=f8) =i2)
   DECLARE at_acv_size = i4 WITH protect, noconstant(0)
   DECLARE eecv_loop = i4 WITH protect, noconstant(0)
   SET new_notif_action_id = 0.0
   SELECT INTO "nl:"
    y = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     new_notif_action_id = cnvtreal(y)
    WITH nocounter
   ;end select
   SET at_acv_size = size(dm_cmb_cust_cols->add_col_val,5)
   IF (at_acv_size=0)
    SET stat = alterlist(dm_cmb_cust_cols->add_col_val,(at_acv_size+ 3))
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 1)].col_name = "ACTION_PRSNL_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 1)].col_value = build(request->xxx_combine[
     icombine].to_xxx_id)
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 2)].col_name = "MP_NOTIFICATION_ACTION_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 2)].col_value = build(new_notif_action_id)
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 3)].col_name = "ORIG_MP_NOTIFICATION_ACTION_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 3)].col_value = build(org_notif_action_id)
   ELSE
    FOR (eecv_loop = 1 TO at_acv_size)
      CASE (dm_cmb_cust_cols->add_col_val[eecv_loop].col_name)
       OF "ACTION_PRSNL_ID":
        SET dm_cmb_cust_cols->add_col_val[eecv_loop].col_value = build(request->xxx_combine[icombine]
         .to_xxx_id)
       OF "MP_NOTIFICATION_ACTION_ID":
        SET dm_cmb_cust_cols->add_col_val[eecv_loop].col_value = build(new_notif_action_id)
       OF "ORIG_MP_NOTIFICATION_ACTION_ID":
        SET dm_cmb_cust_cols->add_col_val[eecv_loop].col_value = build(org_notif_action_id)
      ENDCASE
    ENDFOR
   ENDIF
   IF (size(dm_cmb_cust_cols->col,5)=0)
    SET dm_cmb_cust_cols->tbl_name = "MP_NOTIFICATION_ACTION"
    SET dm_cmb_cust_cols->sub_select_from_tbl = "MP_NOTIFICATION_ACTION"
    SET dm_cmb_cust_cols->updt_std_val_ind = 1
    EXECUTE dm_cmb_get_cust_cols
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET stat = alterlist(dm_cmb_cust_cols->where_col_val,1)
   SET dm_cmb_cust_cols->where_col_val[1].col_name = "MP_NOTIFICATION_ACTION_ID"
   SET dm_cmb_cust_cols->where_col_val[1].col_value = build(s_df_pk_id)
   EXECUTE dm_cmb_ins_cust_row
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = add
   SET request->xxx_combine_det[icombinedet].entity_name = "MP_NOTIFICATION_ACTION"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ACTION_PRSNL_ID"
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "MP_NOTIFICATION_ACTION_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = new_notif_action_id
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (end_eff(s_uf_pk_id=f8,prev_end_eff_dt_tm=dq8) =i2)
   UPDATE  FROM mp_notification_action mna
    SET mna.end_effective_dt_tm = cnvtdatetime(sysdate), mna.updt_dt_tm = cnvtdatetime(sysdate), mna
     .updt_id = reqinfo->updt_id,
     mna.updt_applctx = reqinfo->updt_applctx, mna.updt_task = reqinfo->updt_task, mna.updt_cnt = (
     mna.updt_cnt+ 1)
    WHERE mna.mp_notification_action_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = eff
   SET request->xxx_combine_det[icombinedet].entity_name = "MP_NOTIFICATION_ACTION"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ACTION_PRSNL_ID"
   SET request->xxx_combine_det[icombinedet].prev_end_eff_dt_tm = prev_end_eff_dt_tm
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "MP_NOTIFICATION_ACTION_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_uf_pk_id
   IF (curqual=0)
    SET failed = eff_error
    SET request->error_message = build(
     "END_EFF: end_effective_dt_tm can not be updated with mp_notification_action_id = ",s_uf_pk_id)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_sub
 FREE SET rreclist
END GO

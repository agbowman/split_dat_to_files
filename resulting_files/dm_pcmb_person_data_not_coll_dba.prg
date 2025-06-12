CREATE PROGRAM dm_pcmb_person_data_not_coll:dba
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
 IF ((validate(dcipht_request->pm_hist_tracking_id,- (9))=- (9)))
  RECORD dcipht_request(
    1 pm_hist_tracking_id = f8
    1 encntr_id = f8
    1 person_id = f8
    1 transaction_type_txt = c3
    1 transaction_reason_txt = c30
  )
 ENDIF
 IF (validate(dcipht_reply->status,"b")="b")
  RECORD dcipht_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 IF ((validate(rev_cmb_request->reverse_ind,- (1))=- (1))
  AND (validate(rev_cmb_request->application_flag,- (999))=- (999)))
  FREE RECORD rev_cmb_request
  RECORD rev_cmb_request(
    1 reverse_ind = i2
    1 application_flag = i4
  )
 ENDIF
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
 )
 FREE SET rhistreclist
 RECORD rhistreclist(
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
 )
 DECLARE v_cust_count1 = i4
 DECLARE v_cust_count2 = i4
 DECLARE v_cust_loopcount = i4
 DECLARE v_cust_loopcount2 = i4
 DECLARE move_person_data_not_coll_ind = i2
 DECLARE v_hist_init_ind = i2
 DECLARE dhistid = f8
 SET v_cust_count1 = 0
 SET v_cust_count2 = 0
 SET v_cust_loopcount = 0
 SET v_cust_loopcount2 = 0
 SET move_person_data_not_coll_ind = 0
 SET v_hist_init_ind = 0
 SET dhistid = 0
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "PERSON_DATA_NOT_COLL"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_PERSON_DATA_NOT_COLL"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 1
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 SELECT INTO "nl:"
  frm.*
  FROM person_data_not_coll frm
  WHERE (frm.person_id=request->xxx_combine[icombine].from_xxx_id)
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_id = frm.person_data_not_coll_id, rreclist->from_rec[
   v_cust_count1].active_ind = frm.active_ind, rreclist->from_rec[v_cust_count1].active_status_cd =
   frm.active_status_cd
  WITH forupdatewait(frm)
 ;end select
 IF (v_cust_count1 > 0)
  SELECT INTO "nl:"
   tu.*
   FROM person_data_not_coll tu
   WHERE (tu.person_id=request->xxx_combine[icombine].to_xxx_id)
   DETAIL
    v_cust_count2 += 1
    IF (mod(v_cust_count2,10)=1)
     stat = alterlist(rreclist->to_rec,(v_cust_count2+ 9))
    ENDIF
    rreclist->to_rec[v_cust_count2].to_id = tu.person_data_not_coll_id, rreclist->to_rec[
    v_cust_count2].active_ind = tu.active_ind, rreclist->to_rec[v_cust_count2].active_status_cd = tu
    .active_status_cd
   WITH forupdatewait(tu)
  ;end select
  FOR (v_cust_loopcount1 = 1 TO v_cust_count1)
   IF ((rreclist->from_rec[v_cust_loopcount1].active_ind=1))
    SET move_person_data_not_coll_ind = 1
    FOR (v_cust_loopcount2 = 1 TO v_cust_count2)
      IF ((rreclist->to_rec[v_cust_loopcount2].active_ind=1))
       SET move_person_data_not_coll_ind = 0
       IF ((rev_cmb_request->reverse_ind=1))
        CALL del_to(rreclist->to_rec[v_cust_loopcount2].to_id,rreclist->to_rec[v_cust_loopcount2].
         active_ind,rreclist->to_rec[v_cust_loopcount2].active_status_cd)
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    SET move_person_data_not_coll_ind = 1
   ENDIF
   IF (move_person_data_not_coll_ind=1)
    CALL upt_from(rreclist->from_rec[v_cust_loopcount1].from_id,request->xxx_combine[icombine].
     to_xxx_id)
   ELSE
    IF ((rev_cmb_request->reverse_ind=1))
     CALL upt_from(rreclist->from_rec[v_cust_loopcount1].from_id,request->xxx_combine[icombine].
      to_xxx_id)
    ELSE
     CALL del_from(rreclist->from_rec[v_cust_loopcount1].from_id,request->xxx_combine[icombine].
      to_xxx_id,rreclist->from_rec[v_cust_loopcount1].active_ind,rreclist->from_rec[v_cust_loopcount1
      ].active_status_cd)
    ENDIF
   ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE del_from(s_df_pk_id,s_df_to_fk_id,s_df_prev_act_ind,s_df_prev_act_status)
   UPDATE  FROM person_data_not_coll frm
    SET frm.active_ind = false, frm.active_status_cd = combinedaway, frm.active_status_dt_tm =
     cnvtdatetime(sysdate),
     frm.active_status_prsnl_id = reqinfo->updt_id, frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id =
     reqinfo->updt_id,
     frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm =
     cnvtdatetime(sysdate),
     frm.person_id = s_df_to_fk_id
    WHERE frm.person_data_not_coll_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PERSON_DATA_NOT_COLL"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_df_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_df_prev_act_status
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build("Could not inactivate pk val=",s_df_pk_id))
    RETURN(0)
   ENDIF
   CALL add_hist(s_df_pk_id)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE del_to(s_df_pk_id,s_df_prev_act_ind,s_df_prev_act_status)
   UPDATE  FROM person_data_not_coll tu
    SET tu.active_ind = false, tu.active_status_cd = combinedaway, tu.active_status_dt_tm =
     cnvtdatetime(sysdate),
     tu.active_status_prsnl_id = reqinfo->updt_id, tu.updt_cnt = (tu.updt_cnt+ 1), tu.updt_id =
     reqinfo->updt_id,
     tu.updt_applctx = reqinfo->updt_applctx, tu.updt_task = reqinfo->updt_task, tu.updt_dt_tm =
     cnvtdatetime(sysdate)
    WHERE tu.person_data_not_coll_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = revdel
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PERSON_DATA_NOT_COLL"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_df_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_df_prev_act_status
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build("Could not inactivate pk val=",s_df_pk_id))
    RETURN(0)
   ENDIF
   CALL add_hist(s_df_pk_id)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE upt_from(s_uf_pk_id,s_uf_to_fk_id)
   UPDATE  FROM person_data_not_coll frm
    SET frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo
     ->updt_applctx,
     frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = cnvtdatetime(sysdate), frm.person_id =
     s_uf_to_fk_id
    WHERE frm.person_data_not_coll_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = s_uf_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PERSON_DATA_NOT_COLL"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",s_uf_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE add_hist(s_at_to_parent_pk_id)
   DECLARE v_hist_at_new_id = f8
   SET v_hist_at_new_id = 0.0
   CALL initialize_hist_id(null)
   IF (dhistid <= 0.0)
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    y = seq(person_seq,nextval)
    FROM dual
    DETAIL
     v_hist_at_new_id = cnvtreal(y)
    WITH nocounter
   ;end select
   SET stat = alterlist(dm_cmb_cust_cols2->add_col_val,5)
   SET dm_cmb_cust_cols2->add_col_val[1].col_name = "PERSON_DATA_NOT_COLL_HIST_ID"
   SET dm_cmb_cust_cols2->add_col_val[1].col_value = build(v_hist_at_new_id)
   SET dm_cmb_cust_cols2->add_col_val[2].col_name = "PM_HIST_TRACKING_ID"
   SET dm_cmb_cust_cols2->add_col_val[2].col_value = build(dhistid)
   SET dm_cmb_cust_cols2->add_col_val[3].col_name = "TRANSACTION_DT_TM"
   SET dm_cmb_cust_cols2->add_col_val[3].col_value = "cnvtdatetime(curdate, curtime3)"
   SET dm_cmb_cust_cols2->add_col_val[4].col_name = "CHANGE_BIT"
   SET dm_cmb_cust_cols2->add_col_val[4].col_value = build(0)
   SET dm_cmb_cust_cols2->add_col_val[5].col_name = "TRACKING_BIT"
   SET dm_cmb_cust_cols2->add_col_val[5].col_value = build(0)
   SET stat = alterlist(dm_cmb_cust_cols2->where_col_val,1)
   SET dm_cmb_cust_cols2->where_col_val[1].col_name = "PERSON_DATA_NOT_COLL_ID"
   SET dm_cmb_cust_cols2->where_col_val[1].col_value = build(s_at_to_parent_pk_id)
   IF (size(dm_cmb_cust_cols2->col,5)=0)
    SET dm_cmb_cust_cols2->tbl_name = "PERSON_DATA_NOT_COLL_HIST"
    SET dm_cmb_cust_cols2->sub_select_from_tbl = "PERSON_DATA_NOT_COLL"
    EXECUTE dm_cmb_get_cust_cols  WITH replace("DM_CMB_CUST_COLS","DM_CMB_CUST_COLS2")
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   EXECUTE dm_cmb_ins_cust_row  WITH replace("DM_CMB_CUST_COLS","DM_CMB_CUST_COLS2")
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE initialize_hist_id(null)
  IF (v_hist_init_ind=0.0)
   SET v_hist_init_ind = 1
   SELECT INTO "nl:"
    y = seq(person_seq,nextval)
    FROM dual
    DETAIL
     dhistid = cnvtreal(y)
    WITH nocounter
   ;end select
   SET dcipht_request->pm_hist_tracking_id = dhistid
   SET dcipht_request->person_id = request->xxx_combine[icombine].to_xxx_id
   SET dcipht_request->transaction_type_txt = "CMB"
   SET dcipht_request->transaction_reason_txt = "DM_PCMB_PERSON_DATA_NOT_COLL"
   EXECUTE dm_cmb_ins_pm_hist_tracking
   IF ((dcipht_reply->status="F"))
    SET failed = insert_error
    SET request->error_message = dcipht_reply->err_msg
    SET dhistid = 0.0
    RETURN(0)
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
#exit_sub
 FREE SET rreclist
END GO

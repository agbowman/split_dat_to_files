CREATE PROGRAM dm_eucb_encntr_inptnt_rehab:dba
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
 DECLARE cust_ucb_upt(dummy) = i4
 DECLARE cust_ucb_del(dummy) = i4
 DECLARE initialize_hist_id(null) = i4
 DECLARE v_hist_init_ind = i2
 DECLARE dhistid = f8
 DECLARE trans_dt_tm = dq8
 SET v_hist_init_ind = 0
 SET dhistid = 0
 SET trans_dt_tm = cnvtdatetime(sysdate)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
  SET dcem_request->qual[1].child_entity = "ENCNTR_INPTNT_REHAB"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_EUCB_ENCNTR_INPTNT_REHAB"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 1
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 IF ((rchildren->qual1[det_cnt].combine_action_cd=del))
  IF (cust_ucb_del(null)=0)
   GO TO exit_sub
  ENDIF
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
  IF (cust_ucb_upt(null)=0)
   GO TO exit_sub
  ENDIF
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  SET request->error_message = substring(1,132,build(
    "Uncombine failed. Invalid combine action for entity=",rchildren->qual1[det_cnt].entity_id))
  GO TO exit_sub
 ENDIF
 SUBROUTINE cust_ucb_del(dummy)
   UPDATE  FROM encntr_inptnt_rehab
    SET active_ind = rchildren->qual1[det_cnt].prev_active_ind, active_status_cd = rchildren->qual1[
     det_cnt].prev_active_status_cd, active_status_dt_tm = cnvtdatetime(trans_dt_tm),
     active_status_prsnl_id = reqinfo->updt_id, updt_id = reqinfo->updt_id, updt_dt_tm = cnvtdatetime
     (trans_dt_tm),
     updt_applctx = reqinfo->updt_applctx, updt_cnt = (updt_cnt+ 1), updt_task = reqinfo->updt_task,
     encntr_id = request->xxx_uncombine[ucb_cnt].to_xxx_id
    WHERE (encntr_inptnt_rehab_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = reactivate_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    SET request->error_message = substring(1,132,build("Uncombine failed to reactivate pk val=",
      rchildren->qual1[det_cnt].entity_id))
    RETURN(0)
   ENDIF
   SET activity_updt_cnt += 1
   IF (add_hist(rchildren->qual1[det_cnt].entity_id)=0)
    SET ucb_failed = insert_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    SET request->error_message = substring(1,132,build(
      "Could not insert history for encntr_inptnt_rehab with pk=",rchildren->qual1[det_cnt].entity_id
      ))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE cust_ucb_upt(dummy)
   UPDATE  FROM encntr_inptnt_rehab
    SET updt_id = reqinfo->updt_id, updt_dt_tm = cnvtdatetime(trans_dt_tm), updt_applctx = reqinfo->
     updt_applctx,
     updt_cnt = (updt_cnt+ 1), updt_task = reqinfo->updt_task, encntr_id = request->xxx_uncombine[
     ucb_cnt].to_xxx_id
    WHERE (encntr_inptnt_rehab_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    SET request->error_message = substring(1,132,build("Uncombine failed to update pk val=",rchildren
      ->qual1[det_cnt].entity_id))
    RETURN(0)
   ENDIF
   SET activity_updt_cnt += 1
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (add_hist(s_at_to_parent_pk_id=f8) =i4)
   DECLARE v_hist_at_new_id = f8
   SET v_hist_at_new_id = 0.0
   CALL initialize_hist_id(null)
   IF (dhistid <= 0.0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    y = seq(encounter_seq,nextval)
    FROM dual
    DETAIL
     v_hist_at_new_id = cnvtreal(y)
    WITH nocounter
   ;end select
   SET stat = alterlist(dm_cmb_cust_cols2->add_col_val,5)
   SET dm_cmb_cust_cols2->add_col_val[1].col_name = "ENCNTR_INPTNT_REHAB_HIST_ID"
   SET dm_cmb_cust_cols2->add_col_val[1].col_value = build(v_hist_at_new_id)
   SET dm_cmb_cust_cols2->add_col_val[2].col_name = "PM_HIST_TRACKING_ID"
   SET dm_cmb_cust_cols2->add_col_val[2].col_value = build(dhistid)
   SET dm_cmb_cust_cols2->add_col_val[3].col_name = "TRANSACTION_DT_TM"
   SET dm_cmb_cust_cols2->add_col_val[3].col_value = "cnvtdatetime(trans_dt_tm)"
   SET dm_cmb_cust_cols2->add_col_val[4].col_name = "CHANGE_BIT"
   SET dm_cmb_cust_cols2->add_col_val[4].col_value = build(0)
   SET dm_cmb_cust_cols2->add_col_val[5].col_name = "TRACKING_BIT"
   SET dm_cmb_cust_cols2->add_col_val[5].col_value = build(0)
   SET stat = alterlist(dm_cmb_cust_cols2->where_col_val,1)
   SET dm_cmb_cust_cols2->where_col_val[1].col_name = "ENCNTR_INPTNT_REHAB_ID"
   SET dm_cmb_cust_cols2->where_col_val[1].col_value = build(s_at_to_parent_pk_id)
   IF (size(dm_cmb_cust_cols2->col,5)=0)
    SET dm_cmb_cust_cols2->tbl_name = "ENCNTR_INPTNT_REHAB_HIST"
    SET dm_cmb_cust_cols2->sub_select_from_tbl = "ENCNTR_INPTNT_REHAB"
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
  IF (v_hist_init_ind=0)
   SET v_hist_init_ind = 1
   SELECT INTO "nl:"
    y = seq(person_seq,nextval)
    FROM dual
    DETAIL
     dhistid = cnvtreal(y)
    WITH nocounter
   ;end select
   SET dcipht_request->pm_hist_tracking_id = dhistid
   SET dcipht_request->encntr_id = request->xxx_uncombine[ucb_cnt].to_xxx_id
   SET dcipht_request->transaction_type_txt = "UCB"
   SET dcipht_request->transaction_reason_txt = "DM_EUCB_ENCNTR_INPTNT_REHAB"
   EXECUTE dm_cmb_ins_pm_hist_tracking
   IF ((dcipht_reply->status="F"))
    SET ucb_failed = insert_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    SET request->error_message = dcipht_reply->err_msg
    SET dhistid = 0.0
    RETURN(0)
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
#exit_sub
END GO

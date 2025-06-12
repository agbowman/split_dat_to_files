CREATE PROGRAM dm_lucb_sch_auto_msg:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c6 WITH private, noconstant("")
 ENDIF
 SET last_mod = "568639"
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
 DECLARE cust_ucb_del(dummy) = null
 DECLARE cust_ucb_upt(dummy) = null
 DECLARE add_history(s_ah_sch_auto_msg_id) = null
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "LOCATION"
  SET dcem_request->qual[1].child_entity = "SCH_AUTO_MSG"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_LUCB_SCH_AUTO_MSG"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 IF ((rchildren->qual1[det_cnt].combine_action_cd=del))
  CALL cust_ucb_del(null)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
  CALL add_history(rchildren->qual1[det_cnt].entity_pk[1].data_number)
  CALL cust_ucb_upt(null)
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  SET request->error_message = build("Invalid combine action code ",rchildren->qual1[det_cnt].
   combine_action_cd)
  GO TO exit_sub
 ENDIF
 SUBROUTINE cust_ucb_del(dummy)
   UPDATE  FROM sch_auto_msg sam
    SET sam.updt_id = reqinfo->updt_id, sam.updt_dt_tm = cnvtdatetime(sysdate), sam.updt_applctx =
     reqinfo->updt_applctx,
     sam.updt_cnt = (updt_cnt+ 1), sam.updt_task = reqinfo->updt_task, sam.end_effective_dt_tm =
     cnvtdatetime("31-DEC-2100"),
     sam.active_ind = rchildren->qual1[det_cnt].prev_active_ind, sam.active_status_cd = rchildren->
     qual1[det_cnt].prev_active_status_cd, sam.active_status_dt_tm = cnvtdatetime(sysdate),
     sam.active_status_prsnl_id = reqinfo->updt_id
    WHERE (sam.sch_auto_msg_id=rchildren->qual1[det_cnt].entity_pk[1].data_number)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = reactivate_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    SET request->error_message = build(
     "Failed to reactivate configuration in SCH_AUTO_MSG with ID - ",rchildren->qual1[det_cnt].
     entity_pk[1].data_number)
    GO TO exit_sub
   ENDIF
   UPDATE  FROM sch_auto_msg_appt_type_r aptr
    SET aptr.updt_id = reqinfo->updt_id, aptr.updt_dt_tm = cnvtdatetime(sysdate), aptr.updt_applctx
      = reqinfo->updt_applctx,
     aptr.updt_cnt = (updt_cnt+ 1), aptr.updt_task = reqinfo->updt_task, aptr.active_ind = 1
    WHERE (aptr.sch_auto_msg_id=rchildren->qual1[det_cnt].entity_pk[1].data_number)
    WITH nocounter
   ;end update
   UPDATE  FROM sch_auto_msg_resource_r resr
    SET resr.updt_id = reqinfo->updt_id, resr.updt_dt_tm = cnvtdatetime(sysdate), resr.updt_applctx
      = reqinfo->updt_applctx,
     resr.updt_cnt = (updt_cnt+ 1), resr.updt_task = reqinfo->updt_task, resr.active_ind = 1
    WHERE (resr.sch_auto_msg_id=rchildren->qual1[det_cnt].entity_pk[1].data_number)
    WITH nocounter
   ;end update
   SET activity_updt_cnt += 3
 END ;Subroutine
 SUBROUTINE cust_ucb_upt(dummy)
   UPDATE  FROM sch_auto_msg sam
    SET sam.updt_id = reqinfo->updt_id, sam.updt_dt_tm = cnvtdatetime(sysdate), sam.updt_applctx =
     reqinfo->updt_applctx,
     sam.updt_cnt = (updt_cnt+ 1), sam.updt_task = reqinfo->updt_task, sam.location_cd = request->
     xxx_uncombine[ucb_cnt].to_xxx_id
    WHERE (sam.location_cd=request->xxx_uncombine[ucb_cnt].from_xxx_id)
     AND (sam.sch_auto_msg_id=rchildren->qual1[det_cnt].entity_pk[1].data_number)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    SET request->error_message = build("Failed to update configuration in SCH_AUTO_MSG with ID - ",
     rchildren->qual1[det_cnt].entity_pk[1].data_number)
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE add_history(s_ah_sch_auto_msg_id)
   DECLARE sch_auto_msg_id = f8
   SELECT INTO "nl:"
    next_seq_num = seq(sched_reference_seq,nextval)
    FROM dual
    DETAIL
     sch_auto_msg_id = cnvtreal(next_seq_num)
    WITH nocounter
   ;end select
   IF (sch_auto_msg_id=0)
    SET ucb_failed = insert_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    SET request->error_message = substring(1,132,
     "Could not add history, value from SCHED_REFERENCE_SEQ sequence was 0")
    GO TO exit_sub
   ENDIF
   SET stat = alterlist(dm_cmb_cust_cols->add_col_val,2)
   SET dm_cmb_cust_cols->add_col_val[1].col_name = "SCH_AUTO_MSG_ID"
   SET dm_cmb_cust_cols->add_col_val[1].col_value = build(sch_auto_msg_id)
   SET dm_cmb_cust_cols->add_col_val[2].col_name = "END_EFFECTIVE_DT_TM"
   SET dm_cmb_cust_cols->add_col_val[2].col_value = "cnvtdatetime(curdate, curtime3)"
   SET stat = alterlist(dm_cmb_cust_cols->where_col_val,1)
   SET dm_cmb_cust_cols->where_col_val[1].col_name = "SCH_AUTO_MSG_ID"
   SET dm_cmb_cust_cols->where_col_val[1].col_value = build(s_ah_sch_auto_msg_id)
   IF (size(dm_cmb_cust_cols->col,5)=0)
    SET dm_cmb_cust_cols->tbl_name = "SCH_AUTO_MSG"
    SET dm_cmb_cust_cols->sub_select_from_tbl = "SCH_AUTO_MSG"
    EXECUTE dm_cmb_get_cust_cols
    IF ((dm_err->err_ind=1))
     SET ucb_failed = insert_error
     SET error_table = rchildren->qual1[det_cnt].entity_name
     SET request->error_message = build("Could not add history for configuration ",request->
      xxx_combine[icombine].from_xxx_id)
     GO TO exit_sub
    ENDIF
   ENDIF
   EXECUTE dm_cmb_ins_cust_row
   IF ((dm_err->err_ind=1))
    SET ucb_failed = insert_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    SET request->error_message = build("Could not add history for configuration ",request->
     xxx_combine[icombine].from_xxx_id)
    GO TO exit_sub
   ENDIF
 END ;Subroutine
#exit_sub
END GO

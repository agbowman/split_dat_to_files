CREATE PROGRAM dm_lcmb_sch_auto_msg:dba
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
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 sch_auto_msg_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 location_cd = f8
     2 automated_message_type_cd = f8
   1 to_rec[*]
     2 sch_auto_msg_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 location_cd = f8
     2 automated_message_type_cd = f8
 )
 DECLARE add_version(s_av_from_index_pos=i4) = f8
 DECLARE v_from_count = i4 WITH protect, noconstant(0)
 DECLARE v_to_count = i4 WITH protect, noconstant(0)
 DECLARE v_from_loopindex = i4 WITH protect, noconstant(0)
 DECLARE v_searchindex = i4 WITH protect, noconstant(0)
 DECLARE c_automated_message_type_cs = i4 WITH protect, constant(4416008)
 DECLARE c_appointment_reminder_cv = f8
 SET stat = uar_get_meaning_by_codeset(c_automated_message_type_cs,nullterm("APPTREMINDER"),1,
  c_appointment_reminder_cv)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "LOCATION"
  SET dcem_request->qual[1].child_entity = "SCH_AUTO_MSG"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_LCMB_SCH_AUTO_MSG"
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
  FROM sch_auto_msg frm
  WHERE (frm.location_cd=request->xxx_combine[icombine].from_xxx_id)
   AND frm.automated_message_type_cd=c_appointment_reminder_cv
   AND frm.end_effective_dt_tm > cnvtdatetime(sysdate)
   AND frm.active_ind=1
  DETAIL
   v_from_count += 1
   IF (mod(v_from_count,10)=1)
    stat = alterlist(rreclist->from_rec,(v_from_count+ 9))
   ENDIF
   rreclist->from_rec[v_from_count].sch_auto_msg_id = frm.sch_auto_msg_id, rreclist->from_rec[
   v_from_count].location_cd = frm.location_cd, rreclist->from_rec[v_from_count].
   automated_message_type_cd = frm.automated_message_type_cd,
   rreclist->from_rec[v_from_count].active_ind = frm.active_ind, rreclist->from_rec[v_from_count].
   active_status_cd = frm.active_status_cd
  FOOT REPORT
   stat = alterlist(rreclist->from_rec,v_from_count)
  WITH forupdatewait(frm)
 ;end select
 IF (v_from_count > 0)
  SELECT INTO "nl:"
   tu.*
   FROM sch_auto_msg tu
   WHERE (tu.location_cd=request->xxx_combine[icombine].to_xxx_id)
    AND tu.automated_message_type_cd=c_appointment_reminder_cv
    AND tu.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND tu.active_ind=1
   DETAIL
    v_to_count += 1
    IF (mod(v_to_count,10)=1)
     stat = alterlist(rreclist->to_rec,(v_to_count+ 9))
    ENDIF
    rreclist->to_rec[v_to_count].sch_auto_msg_id = tu.sch_auto_msg_id, rreclist->to_rec[v_to_count].
    location_cd = tu.location_cd, rreclist->to_rec[v_to_count].automated_message_type_cd = tu
    .automated_message_type_cd,
    rreclist->to_rec[v_to_count].active_ind = tu.active_ind, rreclist->to_rec[v_to_count].
    active_status_cd = tu.active_status_cd
   FOOT REPORT
    stat = alterlist(rreclist->to_rec,v_to_count)
   WITH forupdatewait(tu)
  ;end select
  FOR (v_from_loopindex = 1 TO v_from_count)
   SET pos = locateval(v_searchindex,1,size(rreclist->to_rec,5),rreclist->from_rec[v_from_loopindex].
    automated_message_type_cd,rreclist->to_rec[v_searchindex].automated_message_type_cd)
   IF (pos > 0)
    IF (del_from(rreclist->from_rec[v_from_loopindex].sch_auto_msg_id,rreclist->from_rec[
     v_from_loopindex].active_ind,rreclist->from_rec[v_from_loopindex].active_status_cd)=0)
     GO TO exit_sub
    ENDIF
   ELSE
    IF (((add_history(rreclist->from_rec[v_from_loopindex].sch_auto_msg_id)=0) OR (upt_from(rreclist
     ->from_rec[v_from_loopindex].sch_auto_msg_id,request->xxx_combine[icombine].to_xxx_id)=0)) )
     GO TO exit_sub
    ENDIF
   ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE (del_from(s_df_sch_auto_msg_id=f8,s_df_prev_act_ind=i2,s_df_prev_act_status=f8) =i4)
   UPDATE  FROM sch_auto_msg sam
    SET sam.active_ind = false, sam.active_status_cd = combinedaway, sam.active_status_dt_tm =
     cnvtdatetime(sysdate),
     sam.active_status_prsnl_id = reqinfo->updt_id, sam.updt_cnt = (sam.updt_cnt+ 1), sam.updt_id =
     reqinfo->updt_id,
     sam.updt_applctx = reqinfo->updt_applctx, sam.updt_task = reqinfo->updt_task, sam
     .end_effective_dt_tm = cnvtdatetime(sysdate),
     sam.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE sam.sch_auto_msg_id=s_df_sch_auto_msg_id
     AND sam.active_ind=1
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = build(
     "DEL_FROM: No values found on the sch_auto_msg table with id = ",s_df_sch_auto_msg_id)
    RETURN(0)
   ENDIF
   UPDATE  FROM sch_auto_msg_appt_type_r aptr
    SET aptr.active_ind = false, aptr.updt_cnt = (aptr.updt_cnt+ 1), aptr.updt_id = reqinfo->updt_id,
     aptr.updt_applctx = reqinfo->updt_applctx, aptr.updt_task = reqinfo->updt_task, aptr.updt_dt_tm
      = cnvtdatetime(sysdate)
    WHERE aptr.sch_auto_msg_id=s_df_sch_auto_msg_id
     AND aptr.active_ind=1
    WITH nocounter
   ;end update
   UPDATE  FROM sch_auto_msg_resource_r resr
    SET resr.active_ind = false, resr.updt_cnt = (resr.updt_cnt+ 1), resr.updt_id = reqinfo->updt_id,
     resr.updt_applctx = reqinfo->updt_applctx, resr.updt_task = reqinfo->updt_task, resr.updt_dt_tm
      = cnvtdatetime(sysdate)
    WHERE resr.sch_auto_msg_id=s_df_sch_auto_msg_id
     AND resr.active_ind=1
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_sch_auto_msg_id
   SET request->xxx_combine_det[icombinedet].entity_name = "SCH_AUTO_MSG"
   SET request->xxx_combine_det[icombinedet].attribute_name = "LOCATION_CD"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_df_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_df_prev_act_status
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "SCH_AUTO_MSG_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_df_sch_auto_msg_id
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (upt_from(s_uf_sch_auto_msg_id=f8,s_uf_to_location_cd=f8) =i4)
   UPDATE  FROM sch_auto_msg sam
    SET sam.updt_cnt = (sam.updt_cnt+ 1), sam.updt_id = reqinfo->updt_id, sam.updt_applctx = reqinfo
     ->updt_applctx,
     sam.updt_task = reqinfo->updt_task, sam.updt_dt_tm = cnvtdatetime(sysdate), sam.location_cd =
     s_uf_to_location_cd
    WHERE sam.sch_auto_msg_id=s_uf_sch_auto_msg_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_name = "SCH_AUTO_MSG"
   SET request->xxx_combine_det[icombinedet].attribute_name = "LOCATION_CD"
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "SCH_AUTO_MSG_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_uf_sch_auto_msg_id
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = build("Couldn't update SCH_AUTO_MSG record with SCH_AUTO_MSG_ID = ",
     s_uf_sch_auto_msg_id)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (add_history(s_ah_to_sch_auto_msg_id=f8) =i4)
   DECLARE sch_auto_msg_id = f8
   SELECT INTO "nl:"
    next_seq_num = seq(sched_reference_seq,nextval)
    FROM dual
    DETAIL
     sch_auto_msg_id = cnvtreal(next_seq_num)
    WITH nocounter
   ;end select
   IF (sch_auto_msg_id=0)
    SET failed = insert_error
    SET request->error_message = substring(1,132,
     "Could not add history, value from SCHED_REFERENCE_SEQ sequence was 0")
    RETURN(0)
   ENDIF
   SET stat = alterlist(dm_cmb_cust_cols->add_col_val,2)
   SET dm_cmb_cust_cols->add_col_val[1].col_name = "SCH_AUTO_MSG_ID"
   SET dm_cmb_cust_cols->add_col_val[1].col_value = build(sch_auto_msg_id)
   SET dm_cmb_cust_cols->add_col_val[2].col_name = "END_EFFECTIVE_DT_TM"
   SET dm_cmb_cust_cols->add_col_val[2].col_value = "cnvtdatetime(curdate, curtime3)"
   SET stat = alterlist(dm_cmb_cust_cols->where_col_val,1)
   SET dm_cmb_cust_cols->where_col_val[1].col_name = "SCH_AUTO_MSG_ID"
   SET dm_cmb_cust_cols->where_col_val[1].col_value = build(s_ah_to_sch_auto_msg_id)
   IF (size(dm_cmb_cust_cols->col,5)=0)
    SET dm_cmb_cust_cols->tbl_name = "SCH_AUTO_MSG"
    SET dm_cmb_cust_cols->sub_select_from_tbl = "SCH_AUTO_MSG"
    EXECUTE dm_cmb_get_cust_cols
    IF ((dm_err->err_ind=1))
     SET failed = insert_error
     SET request->error_message = build("ADD_HISTORY: Could not add history for configuration ",
      request->xxx_combine[icombine].from_xxx_id)
     RETURN(0)
    ENDIF
   ENDIF
   EXECUTE dm_cmb_ins_cust_row
   IF ((dm_err->err_ind=1))
    SET failed = insert_error
    SET request->error_message = build("ADD_HISTORY: Could not add history for configuration ",
     request->xxx_combine[icombine].from_xxx_id)
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

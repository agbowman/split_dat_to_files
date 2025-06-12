CREATE PROGRAM dm_pcmb_rc_timeline:dba
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
     2 active_ind = i4
     2 active_status_cd = f8
     2 activity_type_cd = f8
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 activity_type_cd = f8
 ) WITH protect
 DECLARE v_cust_count1 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_count2 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount2 = i4 WITH protect, noconstant(0)
 DECLARE to_id_present = i4 WITH protect, noconstant(0)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "RC_TIMELINE"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_RC_TIMELINE"
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
  FROM rc_timeline rct
  PLAN (rct
   WHERE (rct.parent_entity_id=request->xxx_combine[icombine].from_xxx_id)
    AND rct.parent_entity_name="PERSON"
    AND rct.active_ind=true)
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_id = rct.rc_timeline_id, rreclist->from_rec[v_cust_count1].
   active_ind = rct.active_ind, rreclist->from_rec[v_cust_count1].active_status_cd = rct
   .active_status_cd
  WITH forupdatewait(rct)
 ;end select
 IF (v_cust_count1 > 0)
  FOR (v_cust_loopcount = 1 TO v_cust_count1)
    IF ((rreclist->from_rec[v_cust_loopcount].active_status_cd != combinedaway)
     AND (rreclist->from_rec[v_cust_loopcount].active_ind=true))
     IF (add_to(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].to_xxx_id
      )=0)
      GO TO exit_sub
     ENDIF
     IF (del_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
      to_xxx_id,rreclist->from_rec[v_cust_loopcount].active_ind,rreclist->from_rec[v_cust_loopcount].
      active_status_cd)=0)
      GO TO exit_sub
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE (add_to(s_at_from_pk_id=f8,s_at_to_fk_id=f8) =i4)
   DECLARE v_at_new_id = f8
   SET v_at_new_id = 0.0
   SELECT INTO "nl:"
    y = seq(rc_timeline_seq,nextval)
    FROM dual
    DETAIL
     v_at_new_id = cnvtreal(y)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET failed = insert_error
    SET request->error_message = "Could not generate a new rc_timeline_id"
    RETURN(0)
   ENDIF
   SET dm_cmb_cust_cols->tbl_name = "rc_timeline"
   SET dm_cmb_cust_cols->sub_select_from_tbl = "rc_timeline"
   SET dm_cmb_cust_cols->updt_std_val_ind = 0
   SET stat = alterlist(dm_cmb_cust_cols->col,19)
   SET dm_cmb_cust_cols->col[1].col_name = "comment_clob"
   SET dm_cmb_cust_cols->col[2].col_name = "activity_created_dt_tm"
   SET dm_cmb_cust_cols->col[3].col_name = "activity_created_prsnl_id"
   SET dm_cmb_cust_cols->col[4].col_name = "parent_entity_name"
   SET dm_cmb_cust_cols->col[5].col_name = "activity_type_cd"
   SET dm_cmb_cust_cols->col[6].col_name = "solution_cd"
   SET dm_cmb_cust_cols->col[7].col_name = "priority_nbr"
   SET dm_cmb_cust_cols->col[8].col_name = "applied_to_txt"
   SET dm_cmb_cust_cols->col[9].col_name = "active_ind"
   SET dm_cmb_cust_cols->col[10].col_name = "active_status_dt_tm"
   SET dm_cmb_cust_cols->col[11].col_name = "active_status_prsnl_id"
   SET dm_cmb_cust_cols->col[12].col_name = "active_status_cd"
   SET dm_cmb_cust_cols->col[13].col_name = "description_txt"
   SET dm_cmb_cust_cols->col[14].col_name = "applied_to_cd"
   SET dm_cmb_cust_cols->col[15].col_name = "source_reference_ident"
   SET dm_cmb_cust_cols->col[16].col_name = "updt_id"
   SET dm_cmb_cust_cols->col[17].col_name = "updt_task"
   SET dm_cmb_cust_cols->col[18].col_name = "updt_applctx"
   SET dm_cmb_cust_cols->col[19].col_name = "updt_dt_tm"
   SET stat = alterlist(dm_cmb_cust_cols->add_col_val,3)
   SET dm_cmb_cust_cols->add_col_val[1].col_name = "updt_cnt"
   SET dm_cmb_cust_cols->add_col_val[2].col_name = "parent_entity_id"
   SET dm_cmb_cust_cols->add_col_val[3].col_name = "rc_timeline_id"
   SET at_acv_size = size(dm_cmb_cust_cols->add_col_val,5)
   IF (at_acv_size=0)
    SET stat = alterlist(dm_cmb_cust_cols->add_col_val,(at_acv_size+ 3))
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 1)].col_name = "updt_cnt"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 1)].col_value = build(0.0)
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 2)].col_name = "parent_entity_id"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 2)].col_value = build(s_at_to_fk_id)
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 3)].col_name = "rc_timeline_id"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 3)].col_value = build(v_at_new_id)
   ELSE
    FOR (eecv_loop = 1 TO at_acv_size)
      CASE (dm_cmb_cust_cols->add_col_val[eecv_loop].col_name)
       OF "updt_cnt":
        SET dm_cmb_cust_cols->add_col_val[eecv_loop].col_value = build(0.0)
       OF "parent_entity_id":
        SET dm_cmb_cust_cols->add_col_val[eecv_loop].col_value = build(s_at_to_fk_id)
       OF "rc_timeline_id":
        SET dm_cmb_cust_cols->add_col_val[eecv_loop].col_value = build(v_at_new_id)
      ENDCASE
    ENDFOR
   ENDIF
   SET stat = alterlist(dm_cmb_cust_cols->where_col_val,1)
   SET dm_cmb_cust_cols->where_col_val[1].col_name = "rc_timeline_id"
   SET dm_cmb_cust_cols->where_col_val[1].col_value = build(s_at_from_pk_id)
   IF (size(dm_cmb_cust_cols->col,5)=0)
    SET dm_cmb_cust_cols->tbl_name = "RC_TIMELINE"
    SET dm_cmb_cust_cols->sub_select_from_tbl = "RC_TIMELINE"
    SET dm_cmb_cust_cols->updt_std_val_ind = 1
    EXECUTE dm_cmb_get_cust_cols
    IF ((dm_err->err_ind=1))
     SET failed = data_error
     SET request->error_message = "Error in executing dm_cmb_get_cust_cols"
     RETURN(0)
    ENDIF
   ENDIF
   EXECUTE dm_cmb_ins_cust_row
   IF ((dm_err->err_ind=1))
    SET failed = insert_error
    SET request->error_message = "Error in executing dm_cmb_get_cust_cols"
    RETURN(0)
   ENDIF
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = add
   SET request->xxx_combine_det[icombinedet].entity_id = v_at_new_id
   SET request->xxx_combine_det[icombinedet].entity_name = "RC_TIMELINE"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PARENT_ENTITY_ID"
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (del_from(s_df_pk_id=f8,s_df_to_fk_id=f8,s_df_prev_act_ind=i2,s_df_prev_act_status=f8) =
  i4)
   UPDATE  FROM rc_timeline rct
    SET rct.active_ind = false, rct.active_status_cd = combinedaway, rct.updt_cnt = (rct.updt_cnt+ 1),
     rct.updt_id = reqinfo->updt_id, rct.updt_applctx = reqinfo->updt_applctx, rct.updt_task =
     reqinfo->updt_task,
     rct.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE rct.rc_timeline_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "RC_TIMELINE"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PARENT_ENTITY_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_df_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_df_prev_act_status
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build("Could not inactivate pk val=",s_df_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_sub
 FREE SET rreclist
END GO

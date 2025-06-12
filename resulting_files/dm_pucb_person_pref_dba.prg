CREATE PROGRAM dm_pucb_person_pref:dba
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
 DECLARE cmb_save_col_value(sv_pk_value,sv_col_name,sv_from,sv_to) = i2
 DECLARE cmb_read_col_value(rv_col_name) = i2
 DECLARE cmb_save_column_value(svf_tbl_name,svf_pk_value,svf_col_name,svf_col_type,svf_from,
  svf_to) = i2
 DECLARE cmb_read_column_value(rvf_tbl_name,rvf_pk_value,rvf_rv_col_name) = i2
 RECORD cmb_det_value(
   1 table_name = vc
   1 column_name = vc
   1 column_type = vc
   1 from_value = vc
   1 to_value = vc
 )
 SUBROUTINE cmb_save_col_value(sv_pk_value,sv_col_name,sv_from,sv_to)
  SET sv_return = cmb_save_column_value(rcmblist->custom[maincount3].table_name,sv_pk_value,
   sv_col_name,"",sv_from,
   sv_to)
  RETURN(sv_return)
 END ;Subroutine
 SUBROUTINE cmb_save_column_value(svf_tbl_name,svf_pk_value,svf_col_name,svf_col_type,svf_from,svf_to
  )
   IF (((svf_tbl_name="") OR (svf_tbl_name=" ")) )
    SET svf_tbl_name = rcmblist->custom[maincount3].table_name
   ENDIF
   INSERT  FROM combine_det_value
    SET combine_det_value_id = seq(combine_seq,nextval), combine_id = request->xxx_combine[icombine].
     xxx_combine_id, combine_parent = evaluate(cnvtupper(trim(request->parent_table,3)),"ENCOUNTER",
      "ENCNTR_COMBINE","PERSON","PERSON_COMBINE",
      "COMBINE"),
     parent_entity = request->parent_table, entity_name = cnvtupper(svf_tbl_name), entity_id =
     svf_pk_value,
     column_name = cnvtupper(svf_col_name), column_type = evaluate(svf_col_type,"",null,svf_col_type),
     from_value = svf_from,
     to_value = evaluate(svf_to,"",null,svf_to), updt_cnt = 0, updt_id = reqinfo->updt_id,
     updt_applctx = reqinfo->updt_applctx, updt_task = reqinfo->updt_task, updt_dt_tm = cnvtdatetime(
      sysdate)
    WITH nocounter
   ;end insert
   RETURN(curqual)
 END ;Subroutine
 SUBROUTINE cmb_read_col_value(rv_col_name)
  SET rv_return = cmb_read_column_value(rchildren->qual1[det_cnt].entity_name,rchildren->qual1[
   det_cnt].entity_id,rv_col_name)
  RETURN(rv_return)
 END ;Subroutine
 SUBROUTINE cmb_read_column_value(rv_tbl_name,rv_pk_value,rv_col_name)
   SET cmb_det_value->table_name = ""
   SET cmb_det_value->column_name = ""
   SET cmb_det_value->from_value = ""
   SET cmb_det_value->to_value = ""
   IF (((rv_tbl_name="") OR (rv_tbl_name=" ")) )
    SET rv_tbl_name = rchildren->qual1[det_cnt].entity_name
   ENDIF
   IF (rv_pk_value=0)
    SET rv_pk_value = rchildren->qual1[det_cnt].entity_id
   ENDIF
   SELECT INTO "nl:"
    v.column_name, v.from_value, v.to_value
    FROM combine_det_value v
    WHERE (v.combine_id=request->xxx_uncombine[ucb_cnt].xxx_combine_id)
     AND v.combine_parent=evaluate(cnvtupper(trim(request->parent_table,3)),"ENCOUNTER",
     "ENCNTR_COMBINE","PERSON","PERSON_COMBINE",
     "COMBINE")
     AND (v.parent_entity=request->parent_table)
     AND v.entity_name=cnvtupper(rv_tbl_name)
     AND v.entity_id=rv_pk_value
     AND v.column_name=cnvtupper(rv_col_name)
    DETAIL
     cmb_det_value->table_name = v.entity_name, cmb_det_value->column_name = v.column_name,
     cmb_det_value->column_type = v.column_type,
     cmb_det_value->from_value = v.from_value, cmb_det_value->to_value = v.to_value
    WITH nocounter
   ;end select
   RETURN(curqual)
 END ;Subroutine
 SUBROUTINE (restore_column_values(table_name=vc,parent_table=vc,combine_id=f8,from_id=f8,to_id=f8) =
  i2 WITH protect)
   DECLARE cmb_to_col_list = vc WITH protect, noconstant("")
   DECLARE cmb_cdv_stmt = vc WITH protect, noconstant("")
   DECLARE cmb_val = vc WITH protect, noconstant("")
   DECLARE cmb_idx = i4 WITH protect, noconstant(0)
   FREE RECORD t_restore_record
   RECORD t_restore_record(
     1 available_cols_cnt = i4
     1 available_cols[*]
       2 name = vc
       2 type = vc
       2 value = vc
     1 exclude_cols_cnt = i4
     1 exclude_cols[*]
       2 name = vc
   )
   SELECT INTO "nl:"
    FROM combine_det_value cdv
    WHERE cdv.combine_id=combine_id
     AND cdv.entity_name=table_name
     AND cdv.parent_entity=parent_table
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SELECT INTO "nl:"
     FROM user_tab_cols utc
     WHERE utc.table_name=table_name
      AND ((utc.hidden_column="YES") OR (((utc.virtual_column="YES") OR (utc.column_name=
     "LAST_UTC_TS")) ))
     HEAD REPORT
      t_restore_record->exclude_cols_cnt = 0
     DETAIL
      t_restore_record->exclude_cols_cnt += 1
      IF (mod(t_restore_record->exclude_cols_cnt,10)=1)
       stat = alterlist(t_restore_record->exclude_cols,(t_restore_record->exclude_cols_cnt+ 9))
      ENDIF
      t_restore_record->exclude_cols[t_restore_record->exclude_cols_cnt].name = utc.column_name
     FOOT REPORT
      IF (mod(t_restore_record->exclude_cols_cnt,10) != 0)
       stat = alterlist(t_restore_record->exclude_cols,t_restore_record->exclude_cols_cnt)
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dtable t,
      dtableattr a,
      dtableattrl l
     WHERE t.table_name=table_name
      AND t.table_name=a.table_name
      AND l.structtype="F"
      AND btest(l.stat,11)=0
      AND  NOT (l.attr_name IN ("PERSON_ID", "UPDT*"))
      AND  NOT (expand(cmb_idx,1,t_restore_record->exclude_cols_cnt,l.attr_name,t_restore_record->
      exclude_cols[cmb_idx].name))
     ORDER BY l.attr_name
     HEAD REPORT
      t_restore_record->available_cols_cnt = 0
     DETAIL
      t_restore_record->available_cols_cnt += 1
      IF (mod(t_restore_record->available_cols_cnt,10)=1)
       stat = alterlist(t_restore_record->available_cols,(t_restore_record->available_cols_cnt+ 9))
      ENDIF
      IF ((t_restore_record->available_cols_cnt > 1))
       cmb_to_col_list = concat(cmb_to_col_list,",FRM.",l.attr_name)
      ELSE
       cmb_to_col_list = concat("FRM.",l.attr_name)
      ENDIF
      t_restore_record->available_cols[t_restore_record->available_cols_cnt].name = l.attr_name
      IF (l.type="F")
       t_restore_record->available_cols[t_restore_record->available_cols_cnt].type = "F8"
      ELSEIF (l.type="I")
       t_restore_record->available_cols[t_restore_record->available_cols_cnt].type = "I4"
      ELSEIF (l.type="C")
       IF (btest(l.stat,13))
        t_restore_record->available_cols[t_restore_record->available_cols_cnt].type = "VC"
       ELSE
        t_restore_record->available_cols[t_restore_record->available_cols_cnt].type = build(l.type,l
         .len)
       ENDIF
      ELSEIF (l.type="Q")
       t_restore_record->available_cols[t_restore_record->available_cols_cnt].type = "DQ8"
      ENDIF
     FOOT REPORT
      IF (mod(t_restore_record->available_cols_cnt,10)=0)
       stat = alterlist(t_restore_record->available_cols,t_restore_record->available_cols_cnt)
      ENDIF
     WITH nocounter
    ;end select
    FOR (cmb_idx = 1 TO t_restore_record->available_cols_cnt)
     CALL cmb_read_column_value(table_name,from_id,t_restore_record->available_cols[cmb_idx].name)
     IF (nullval(cmb_det_value->to_value,"!NL!")="!NL!")
      SET t_restore_record->available_cols[cmb_idx].value = ""
     ELSE
      SET t_restore_record->available_cols[cmb_idx].value = cmb_det_value->to_value
     ENDIF
    ENDFOR
    SELECT INTO "nl:"
     FROM all_tab_columns c,
      (dummyt d  WITH seq = value(t_restore_record->available_cols_cnt))
     PLAN (d
      WHERE (t_restore_record->available_cols[d.seq].value=""))
      JOIN (c
      WHERE c.table_name=table_name
       AND (c.column_name=t_restore_record->available_cols[d.seq].name))
     DETAIL
      t_restore_record->available_cols[d.seq].value = c.data_default
     WITH nocounter
    ;end select
    SET cmb_cdv_stmt = concat("UPDATE into ",table_name," FRM "," SET (",cmb_to_col_list,
     ",UPDT_APPLCTX, UPDT_CNT, UPDT_DT_TM, ","UPDT_ID, UPDT_TASK) (","SELECT ")
    FOR (cmb_idx = 1 TO t_restore_record->available_cols_cnt)
     IF ((t_restore_record->available_cols[cmb_idx].type="DQ8"))
      SET cmb_val = concat("cnvtdatetime('",t_restore_record->available_cols[cmb_idx].value,"')")
     ELSEIF ((t_restore_record->available_cols[cmb_idx].type="*C*"))
      SET cmb_val = concat("'",t_restore_record->available_cols[cmb_idx].value,"'")
     ELSE
      SET cmb_val = t_restore_record->available_cols[cmb_idx].value
     ENDIF
     IF (cmb_idx=1)
      SET cmb_cdv_stmt = concat(cmb_cdv_stmt," ",cmb_val)
     ELSE
      SET cmb_cdv_stmt = concat(cmb_cdv_stmt,",",cmb_val)
     ENDIF
    ENDFOR
    SET cmb_cdv_stmt = concat(cmb_cdv_stmt," ,reqinfo->updt_applctx, FRM.updt_cnt + 1, ",
     "cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task "," FROM dual)",
     " WHERE FRM.person_id = ",
     trim(cnvtstring(from_id,19)),".0 WITH NOCOUNTER go")
    CALL parser(cmb_cdv_stmt,1)
    IF (curqual=0)
     FREE RECORD t_restore_record
     RETURN(0)
    ENDIF
   ENDIF
   FREE RECORD t_restore_record
   RETURN(1)
 END ;Subroutine
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
 DECLARE cust_ucb_del2(dummy) = i4
 DECLARE cust_ucb_add(dummy) = i4
 DECLARE initialize_hist_id(null) = i4
 DECLARE v_hist_init_ind = i2 WITH protect, noconstant(0)
 DECLARE dhistid = f8 WITH protect, noconstant(0)
 DECLARE trans_dt_tm = dq8
 DECLARE dppm_col_cnt = i4 WITH protect, noconstant(0)
 DECLARE dppm_to_col_list = vc WITH protect, noconstant("")
 DECLARE dppm_cdv_stmt = vc WITH protect, noconstant("")
 DECLARE dppm_val = vc WITH protect, noconstant("")
 SET trans_dt_tm = cnvtdatetime(sysdate)
 FREE RECORD drpm_ucbcolumns
 RECORD drpm_ucbcolumns(
   1 pers_pat[*]
     2 column_name = vc
     2 column_type = vc
     2 to_value = vc
 )
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "PERSON_PREF"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_PUCB_PERSON_PREF"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 IF ((rchildren->qual1[det_cnt].combine_action_cd=add))
  IF (cust_ucb_add(null)=0)
   GO TO exit_sub
  ENDIF
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=del))
  IF (cust_ucb_del2(null)=0)
   GO TO exit_sub
  ENDIF
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
  IF (cust_ucb_upt(null)=0)
   GO TO exit_sub
  ENDIF
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  GO TO exit_sub
 ENDIF
 SUBROUTINE cust_ucb_del2(dummy)
   UPDATE  FROM person_pref p
    SET p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_applctx = reqinfo
     ->updt_applctx,
     p.updt_cnt = (updt_cnt+ 1), p.updt_task = reqinfo->updt_task, p.active_ind = rchildren->qual1[
     det_cnt].prev_active_ind,
     p.active_status_cd = rchildren->qual1[det_cnt].prev_active_status_cd, p.active_status_dt_tm =
     cnvtdatetime(sysdate), p.active_status_prsnl_id = reqinfo->updt_id
    WHERE (p.person_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = reactivate_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
   IF (add_hist(rchildren->qual1[det_cnt].entity_id)=0)
    SET ucb_failed = insert_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE cust_ucb_add(dummy)
   UPDATE  FROM person_pref p
    SET p.active_ind = false, p.active_status_cd = reqdata->inactive_status_cd, p.active_status_dt_tm
      = cnvtdatetime(sysdate),
     p.active_status_prsnl_id = reqinfo->updt_id, p.updt_id = reqinfo->updt_id, p.updt_dt_tm =
     cnvtdatetime(sysdate),
     p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (updt_cnt+ 1), p.updt_task = reqinfo->
     updt_task
    WHERE (p.person_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = delete_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
   IF (add_hist(rchildren->qual1[det_cnt].entity_id)=0)
    SET ucb_failed = insert_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE cust_ucb_upt(dummy)
   IF ( NOT (restore_column_values("PERSON_PREF",request->parent_table,request->xxx_uncombine[ucb_cnt
    ].xxx_combine_id,request->xxx_uncombine[ucb_cnt].from_xxx_id,request->xxx_uncombine[ucb_cnt].
    to_xxx_id)))
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    RETURN(0)
   ENDIF
   SET activity_updt_cnt += 1
   IF (add_hist(request->xxx_uncombine[ucb_cnt].from_xxx_id)=0)
    SET ucb_failed = insert_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    RETURN(0)
   ENDIF
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
    y = seq(person_seq,nextval)
    FROM dual
    DETAIL
     v_hist_at_new_id = cnvtreal(y)
    WITH nocounter
   ;end select
   SET stat = alterlist(dm_cmb_cust_cols2->add_col_val,4)
   SET dm_cmb_cust_cols2->add_col_val[1].col_name = "PERSON_PREF_HIST_ID"
   SET dm_cmb_cust_cols2->add_col_val[1].col_value = build(v_hist_at_new_id)
   SET dm_cmb_cust_cols2->add_col_val[2].col_name = "PM_HIST_TRACKING_ID"
   SET dm_cmb_cust_cols2->add_col_val[2].col_value = build(dhistid)
   SET dm_cmb_cust_cols2->add_col_val[3].col_name = "CHANGE_BIT"
   SET dm_cmb_cust_cols2->add_col_val[3].col_value = build(0)
   SET dm_cmb_cust_cols2->add_col_val[4].col_name = "TRACKING_BIT"
   SET dm_cmb_cust_cols2->add_col_val[4].col_value = build(0)
   SET stat = alterlist(dm_cmb_cust_cols2->where_col_val,1)
   SET dm_cmb_cust_cols2->where_col_val[1].col_name = "PERSON_ID"
   SET dm_cmb_cust_cols2->where_col_val[1].col_value = build(s_at_to_parent_pk_id)
   IF (size(dm_cmb_cust_cols2->col,5)=0)
    SET dm_cmb_cust_cols2->tbl_name = "PERSON_PREF_HIST"
    SET dm_cmb_cust_cols2->sub_select_from_tbl = "PERSON_PREF"
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
   SET dcipht_request->person_id = request->xxx_uncombine[ucb_cnt].to_xxx_id
   SET dcipht_request->transaction_type_txt = "UCB"
   SET dcipht_request->transaction_reason_txt = "DM_PUCB_PERSON_PREF"
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
 FREE RECORD cmb_det_value
 FREE RECORD drpm_ucbcolumns
 FREE RECORD dcem_request
END GO

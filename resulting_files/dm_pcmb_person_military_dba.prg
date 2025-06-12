CREATE PROGRAM dm_pcmb_person_military:dba
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
 CALL echo("*****dm_cmb_pm_hist_routines.inc - 565951****")
 DECLARE dm_cmb_detect_pm_hist(null) = i4
 SUBROUTINE dm_cmb_detect_pm_hist(null)
   RETURN(1)
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
   1 from_rec[1]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
   1 to_rec[1]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
 )
 DECLARE initialize_hist_id(null) = i4
 DECLARE frm_ind = i2 WITH protect, noconstant(false)
 DECLARE to_ind = i2 WITH protect, noconstant(false)
 DECLARE v_hist_init_ind = i2 WITH protect, noconstant(0)
 DECLARE dhistid = f8 WITH protect, noconstant(0)
 DECLARE v_hist_at_new_id = f8 WITH protect, noconstant(0)
 DECLARE trans_dt_tm = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "PERSON_MILITARY"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_PERSON_MILITARY"
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
  FROM person_military frm
  WHERE (frm.person_id=request->xxx_combine[icombine].from_xxx_id)
   AND frm.active_ind=1
  DETAIL
   frm_ind = true, rreclist->from_rec[1].from_id = frm.person_id, rreclist->from_rec[1].active_ind =
   frm.active_ind,
   rreclist->from_rec[1].active_status_cd = frm.active_status_cd
  WITH forupdatewait(frm)
 ;end select
 IF (frm_ind=true)
  SELECT INTO "nl:"
   tu.*
   FROM person_military tu
   WHERE (tu.person_id=request->xxx_combine[icombine].to_xxx_id)
   DETAIL
    to_ind = true, rreclist->to_rec[1].to_id = tu.person_id, rreclist->to_rec[1].active_ind = tu
    .active_ind,
    rreclist->to_rec[1].active_status_cd = tu.active_status_cd
   WITH forupdatewait(tu)
  ;end select
  IF (to_ind != true)
   IF (add_to(request->xxx_combine[icombine].from_xxx_id,request->xxx_combine[icombine].to_xxx_id)=0)
    GO TO exit_sub
   ENDIF
  ELSE
   IF ((((rev_cmb_request->reverse_ind=1)) OR ((rreclist->to_rec[1].active_ind=0))) )
    IF (upt_to(request->xxx_combine[icombine].to_xxx_id,request->xxx_combine[icombine].from_xxx_id)=0
    )
     GO TO exit_sub
    ENDIF
   ENDIF
  ENDIF
  IF ((rreclist->from_rec[1].active_ind=1))
   IF (del_from(rreclist->from_rec[1].from_id,rreclist->from_rec[1].active_ind,rreclist->from_rec[1].
    active_status_cd)=0)
    GO TO exit_sub
   ENDIF
  ENDIF
 ENDIF
 SUBROUTINE (add_to(s_at_from_pk_id=f8,s_at_to_pk_id=f8) =i4)
   DECLARE at_acv_size = i4 WITH protect, noconstant(0)
   DECLARE eecv_loop = i4 WITH protect, noconstant(0)
   SET at_acv_size = size(dm_cmb_cust_cols->add_col_val,5)
   IF (at_acv_size=0)
    SET stat = alterlist(dm_cmb_cust_cols->add_col_val,(at_acv_size+ 1))
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 1)].col_name = "PERSON_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 1)].col_value = build(s_at_to_pk_id)
   ELSE
    FOR (eecv_loop = 1 TO at_acv_size)
      IF ((dm_cmb_cust_cols->add_col_val[eecv_loop].col_name="PERSON_ID"))
       SET dm_cmb_cust_cols->add_col_val[eecv_loop].col_value = build(s_at_to_pk_id)
      ENDIF
    ENDFOR
   ENDIF
   SET stat = alterlist(dm_cmb_cust_cols->where_col_val,1)
   SET dm_cmb_cust_cols->where_col_val[1].col_name = "PERSON_ID"
   SET dm_cmb_cust_cols->where_col_val[1].col_value = build(s_at_from_pk_id)
   IF (size(dm_cmb_cust_cols->col,5)=0)
    SET dm_cmb_cust_cols->tbl_name = "PERSON_MILITARY"
    SET dm_cmb_cust_cols->sub_select_from_tbl = "PERSON_MILITARY"
    SET dm_cmb_cust_cols->updt_std_val_ind = 1
    EXECUTE dm_cmb_get_cust_cols
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   EXECUTE dm_cmb_ins_cust_row
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = add
   SET request->xxx_combine_det[icombinedet].entity_id = s_at_to_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PERSON_MILITARY"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET v_at_hist_ind = dm_cmb_detect_pm_hist(null)
   IF (v_at_hist_ind=1)
    IF (add_hist(s_at_to_pk_id)=0)
     SET failed = insert_error
     SET request->error_message = substring(1,132,build(
       "Could not insert history for person_military with pk=",s_at_to_pk_id))
     RETURN(0)
    ENDIF
   ELSEIF (v_at_hist_ind=0)
    SET failed = insert_error
    SET request->error_message = substring(1,132,build(
      "Could not insert history for person_military with pk val=",s_at_to_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (del_from(s_df_pk_id=f8,s_df_prev_act_ind=i2,s_df_prev_act_status=f8) =i4)
   UPDATE  FROM person_military frm
    SET frm.active_ind = false, frm.active_status_cd = combinedaway, frm.active_status_dt_tm =
     cnvtdatetime(trans_dt_tm),
     frm.active_status_prsnl_id = reqinfo->updt_id, frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id =
     reqinfo->updt_id,
     frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm =
     cnvtdatetime(trans_dt_tm)
    WHERE frm.person_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PERSON_MILITARY"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_df_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_df_prev_act_status
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build("Could not inactivate pk val=",s_df_pk_id))
    RETURN(0)
   ENDIF
   IF (add_hist(s_df_pk_id)=0)
    SET failed = insert_error
    SET request->error_message = substring(1,132,build(
      "Could not insert history for person_military with pk=",s_df_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (upt_to(s_ut_to_id=f8,s_ut_from_id=f8) =i4)
   FREE SET pp_columns
   RECORD pp_columns(
     1 pers_mil[*]
       2 column_name = vc
       2 column_type = vc
       2 to_value = vc
   )
   DECLARE col_pers_mil = i4 WITH protect, noconstant(0)
   DECLARE updt_col_to = vc
   DECLARE updt_col_from = vc
   DECLARE updt_add_col_name_to = vc
   DECLARE updt_add_col_val_from = vc
   DECLARE updt_comb_det = vc
   SELECT INTO "NL:"
    l.attr_name
    FROM dtable t,
     dtableattr a,
     dtableattrl l
    WHERE t.table_name="PERSON_MILITARY"
     AND t.table_name=a.table_name
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    DETAIL
     CASE (l.attr_name)
      OF "UPDT_DT_TM":
       updt_add_col_name_to = concat(updt_add_col_name_to," TU.UPDT_DT_TM,"),updt_add_col_val_from =
       concat(updt_add_col_val_from," cnvtdatetime(curdate, curtime3),")
      OF "UPDT_TASK":
       updt_add_col_name_to = concat(updt_add_col_name_to," TU.UPDT_TASK,"),updt_add_col_val_from =
       concat(updt_add_col_val_from," reqinfo->updt_task,")
      OF "UPDT_ID":
       updt_add_col_name_to = concat(updt_add_col_name_to," TU.UPDT_ID,"),updt_add_col_val_from =
       concat(updt_add_col_val_from," reqinfo->updt_id,")
      OF "UPDT_CNT":
       updt_add_col_name_to = concat(updt_add_col_name_to," TU.UPDT_CNT,"),updt_add_col_val_from =
       concat(updt_add_col_val_from," FRM.UPDT_CNT + 1,")
      OF "UPDT_APPLCTX":
       updt_add_col_name_to = concat(updt_add_col_name_to," TU.UPDT_APPLCTX,"),updt_add_col_val_from
        = concat(updt_add_col_val_from," reqinfo->updt_applctx,")
      ELSE
       IF (l.attr_name != "PERSON_ID")
        updt_col_to = concat(updt_col_to," TU.",trim(l.attr_name),","), updt_col_from = concat(
         updt_col_from," FRM.",trim(l.attr_name),",")
       ENDIF
       ,col_pers_mil += 1,
       IF (mod(col_pers_mil,100)=1)
        stat = alterlist(pp_columns->pers_mil,(col_pers_mil+ 99))
       ENDIF
       ,pp_columns->pers_mil[col_pers_mil].column_name = l.attr_name,
       IF (l.type="F")
        pp_columns->pers_mil[col_pers_mil].column_type = "F8"
       ELSEIF (l.type="I")
        pp_columns->pers_mil[col_pers_mil].column_type = "I4"
       ELSEIF (l.type="C")
        IF (btest(l.stat,13))
         pp_columns->pers_mil[col_pers_mil].column_type = "VC"
        ELSE
         pp_columns->pers_mil[col_pers_mil].column_type = build(l.type,l.len)
        ENDIF
       ELSEIF (l.type="Q")
        pp_columns->pers_mil[col_pers_mil].column_type = "DQ8"
       ENDIF
     ENDCASE
    FOOT REPORT
     stat = alterlist(pp_columns->pers_mil,col_pers_mil)
    WITH nocounter
   ;end select
   SET updt_comb_det = " SELECT into 'nl:'"
   SET updt_comb_det = concat(updt_comb_det," FROM PERSON_MILITARY p")
   SET updt_comb_det = concat(updt_comb_det," WHERE p.person_id = s_ut_to_id")
   SET updt_comb_det = concat(updt_comb_det," DETAIL")
   FOR (col_cnt2 = 1 TO col_pers_mil)
     IF ((pp_columns->pers_mil[col_cnt2].column_type IN ("C*", "VC*")))
      SET updt_comb_det = concat(updt_comb_det," pp_columns->pers_mil[",trim(cnvtstring(col_cnt2)),
       "]->to_value = p.",pp_columns->pers_mil[col_cnt2].column_name)
     ELSEIF ((pp_columns->pers_mil[col_cnt2].column_type="DQ8"))
      SET updt_comb_det = concat(updt_comb_det," pp_columns->pers_mil[",trim(cnvtstring(col_cnt2)),
       "]->to_value = format(p.",pp_columns->pers_mil[col_cnt2].column_name,
       ",';;Q')")
     ELSE
      SET updt_comb_det = concat(updt_comb_det," pp_columns->pers_mil[",trim(cnvtstring(col_cnt2)),
       "]->to_value = cnvtstring(p.",pp_columns->pers_mil[col_cnt2].column_name,
       ")")
     ENDIF
   ENDFOR
   SET updt_comb_det = concat(updt_comb_det," WITH NOCOUNTER, NOTRIM go")
   CALL parser(updt_comb_det,1)
   FOR (pcp_cols = 1 TO size(pp_columns->pers_mil,5))
    SET log_val_ind = cmb_save_column_value("PERSON_MILITARY",s_ut_to_id,pp_columns->pers_mil[
     pcp_cols].column_name,pp_columns->pers_mil[pcp_cols].column_type,null,
     pp_columns->pers_mil[pcp_cols].to_value)
    IF (log_val_ind=0)
     SET failed = insert_error
     SET request->error_message = substring(1,132,build(
       "Could not insert column value to combine_det_value table for person_military with pk=",
       s_ut_to_id))
     RETURN(0)
    ENDIF
   ENDFOR
   IF (textlen(updt_add_col_name_to)=0)
    SET updt_col_to = substring(0,(textlen(updt_col_to) - 1),updt_col_to)
   ELSE
    SET updt_add_col_name_to = substring(0,(textlen(updt_add_col_name_to) - 1),updt_add_col_name_to)
   ENDIF
   IF (textlen(updt_add_col_val_from)=0)
    SET updt_col_from = substring(0,(textlen(updt_col_from) - 1),updt_col_from)
   ELSE
    SET updt_add_col_val_from = substring(0,(textlen(updt_add_col_val_from) - 1),
     updt_add_col_val_from)
   ENDIF
   SET updt_stmt = concat("UPDATE into PERSON_MILITARY TU SET (",updt_col_to,updt_add_col_name_to,
    ") (SELECT ",updt_col_from,
    updt_add_col_val_from," FROM PERSON_MILITARY FRM WHERE FRM.person_id = s_ut_from_id )",
    " WHERE TU.person_id = s_ut_to_id"," WITH NOCOUNTER, NOTRIM GO")
   CALL parser(updt_stmt,1)
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = s_ut_to_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PERSON_MILITARY"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",s_ut_to_id))
    RETURN(0)
   ENDIF
   IF (add_hist(s_ut_to_id)=0)
    SET failed = insert_error
    SET request->error_message = substring(1,132,build(
      "Could not insert history for person_military with pk=",s_ut_to_id))
    RETURN(0)
   ENDIF
   FREE SET pp_columns
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (add_hist(s_at_to_parent_pk_id=f8) =i4)
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
   SET stat = alterlist(dm_cmb_cust_cols2->add_col_val,5)
   SET dm_cmb_cust_cols2->add_col_val[1].col_name = "PERSON_MILITARY_HIST_ID"
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
   SET dm_cmb_cust_cols2->where_col_val[1].col_name = "PERSON_ID"
   SET dm_cmb_cust_cols2->where_col_val[1].col_value = build(s_at_to_parent_pk_id)
   IF (size(dm_cmb_cust_cols2->col,5)=0)
    SET dm_cmb_cust_cols2->tbl_name = "PERSON_MILITARY_HIST"
    SET dm_cmb_cust_cols2->sub_select_from_tbl = "PERSON_MILITARY"
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
   SET dcipht_request->person_id = request->xxx_combine[icombine].to_xxx_id
   SET dcipht_request->transaction_type_txt = "CMB"
   SET dcipht_request->transaction_reason_txt = "DM_PCMB_PERSON_MILITARY"
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

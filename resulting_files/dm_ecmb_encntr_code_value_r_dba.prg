CREATE PROGRAM dm_ecmb_encntr_code_value_r:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c6 WITH noconstant(" "), private
 ENDIF
 SET last_mod = "548192"
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
 IF ((validate(passive_check_define,- (99))=- (99)))
  DECLARE passive_check_define = i4 WITH constant(1)
  DECLARE column_exists(stable,scolumn) = i4
  SUBROUTINE column_exists(stable,scolumn)
    DECLARE ce_flag = i4
    SET ce_flag = 0
    DECLARE ce_temp = vc WITH noconstant("")
    SET stable = cnvtupper(stable)
    SET scolumn = cnvtupper(scolumn)
    IF (((currev=8
     AND currevminor=2
     AND currevminor2 >= 4) OR (((currev=8
     AND currevminor > 2) OR (currev > 8)) )) )
     SET ce_temp = build('"',stable,".",scolumn,'"')
     SET stat = checkdic(parser(ce_temp),"A",0)
     IF (stat > 0)
      SET ce_flag = 1
     ENDIF
    ELSE
     SELECT INTO "nl:"
      l.attr_name
      FROM dtableattr a,
       dtableattrl l
      WHERE a.table_name=stable
       AND l.attr_name=scolumn
       AND l.structtype="F"
       AND btest(l.stat,11)=0
      DETAIL
       ce_flag = 1
      WITH nocounter
     ;end select
    ENDIF
    RETURN(ce_flag)
  END ;Subroutine
 ENDIF
 FREE RECORD rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_pk_id = f8
     2 from_code_value = f8
   1 pm_hist_tracking_id = f8
 )
 DECLARE v_cust_count1 = i4
 DECLARE v_cust_loopcount = i4
 DECLARE bhistoryschema = i4
 SET v_cust_count1 = 0
 SET v_cust_loopcount = 0
 SET bhistoryschema = column_exists("ENCNTR_CODE_VALUE_R_HIST","ENCNTR_ID")
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
  SET dcem_request->qual[1].child_entity = "ENCNTR_CODE_VALUE_R"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_ECMB_ENCNTR_CODE_VALUE_R"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO end_prog
 ENDIF
 SELECT INTO "nl:"
  frm.*
  FROM encntr_code_value_r frm
  WHERE (frm.encntr_id=request->xxx_combine[icombine].from_xxx_id)
   AND  NOT ( EXISTS (
  (SELECT
   tu.code_value
   FROM encntr_code_value_r tu
   WHERE (tu.encntr_id=request->xxx_combine[icombine].to_xxx_id)
    AND tu.code_value=frm.code_value)))
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_pk_id = frm.encntr_code_value_r_id, rreclist->from_rec[
   v_cust_count1].from_code_value = frm.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(rreclist->from_rec,v_cust_count1)
 IF (v_cust_count1 > 0)
  FOR (v_cust_loopcount = 1 TO v_cust_count1)
    IF (add_to(rreclist->from_rec[v_cust_loopcount].from_pk_id,request->xxx_combine[icombine].
     to_xxx_id)=0)
     GO TO end_prog
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE add_to(s_at_from_ecvr_id,s_at_to_encntr_id)
   DECLARE v_new_ecvr_id = f8
   DECLARE v_new_ecvrh_id = f8
   DECLARE at_acv_size = i4
   DECLARE at_where_size = i4
   SET v_new_ecvr_id = 0.0
   SET v_new_ecvrh_id = 0.0
   SET at_acv_size = 0
   SET at_where_size = 0
   CALL echo("add encntr_code_value_r")
   SELECT INTO "nl:"
    y = seq(encounter_seq,nextval)
    FROM dual
    DETAIL
     v_new_ecvr_id = cnvtreal(y)
    WITH nocounter
   ;end select
   SET at_acv_size = size(dm_cmb_cust_cols->add_col_val,5)
   IF (at_acv_size=0)
    SET stat = alterlist(dm_cmb_cust_cols->add_col_val,(at_acv_size+ 2))
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 1)].col_name = "ENCNTR_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 1)].col_value = build(s_at_to_encntr_id)
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 2)].col_name = "ENCNTR_CODE_VALUE_R_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 2)].col_value = build(v_new_ecvr_id)
   ELSE
    FOR (eecv_loop = 1 TO at_acv_size)
      CASE (dm_cmb_cust_cols->add_col_val[eecv_loop].col_name)
       OF "ENCNTR_ID":
        SET dm_cmb_cust_cols->add_col_val[eecv_loop].col_value = build(s_at_to_encntr_id)
       OF "ENCNTR_CODE_VALUE_R_ID":
        SET dm_cmb_cust_cols->add_col_val[eecv_loop].col_value = build(v_new_ecvr_id)
      ENDCASE
    ENDFOR
   ENDIF
   IF (size(dm_cmb_cust_cols->col,5)=0)
    SET dm_cmb_cust_cols->tbl_name = "ENCNTR_CODE_VALUE_R"
    SET dm_cmb_cust_cols->sub_select_from_tbl = "ENCNTR_CODE_VALUE_R"
    SET dm_cmb_cust_cols->updt_std_val_ind = 1
    EXECUTE dm_cmb_get_cust_cols
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET stat = alterlist(dm_cmb_cust_cols->where_col_val,1)
   SET dm_cmb_cust_cols->where_col_val[1].col_name = "ENCNTR_CODE_VALUE_R_ID"
   SET dm_cmb_cust_cols->where_col_val[1].col_value = build(s_at_from_ecvr_id)
   EXECUTE dm_cmb_ins_cust_row
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = add
   SET request->xxx_combine_det[icombinedet].entity_id = v_new_ecvr_id
   SET request->xxx_combine_det[icombinedet].entity_name = "ENCNTR_CODE_VALUE_R"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
   IF (bhistoryschema=false)
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    y = seq(encounter_seq,nextval)
    FROM dual
    DETAIL
     v_new_ecvrh_id = cnvtreal(y)
    WITH nocounter
   ;end select
   SET at_acv_size = size(dm_cmb_cust_cols2->add_col_val,5)
   IF (at_acv_size=0)
    SET stat = alterlist(dm_cmb_cust_cols2->add_col_val,4)
    SET dm_cmb_cust_cols2->add_col_val[1].col_name = "ENCNTR_CODE_VALUE_R_HIST_ID"
    SET dm_cmb_cust_cols2->add_col_val[1].col_value = build(v_new_ecvrh_id)
    SET dm_cmb_cust_cols2->add_col_val[2].col_name = "ACTIVE_IND"
    SET dm_cmb_cust_cols2->add_col_val[2].col_value = "1"
    SET dm_cmb_cust_cols2->add_col_val[3].col_name = "BEG_EFFECTIVE_DT_TM"
    SET dm_cmb_cust_cols2->add_col_val[3].col_value = "cnvtdatetime(curdate, curtime3)"
    SET dm_cmb_cust_cols2->add_col_val[4].col_name = "END_EFFECTIVE_DT_TM"
    SET dm_cmb_cust_cols2->add_col_val[4].col_value = 'cnvtdatetime("31-DEC-2100")'
   ELSE
    FOR (eecv_loop = 1 TO at_acv_size)
      CASE (dm_cmb_cust_cols2->add_col_val[eecv_loop].col_name)
       OF "ENCNTR_CODE_VALUE_R_HIST_ID":
        SET dm_cmb_cust_cols2->add_col_val[eecv_loop].col_value = build(v_new_ecvrh_id)
       OF "ACTIVE_IND":
        SET dm_cmb_cust_cols2->add_col_val[eecv_loop].col_value = "1"
       OF "BEG_EFFECTIVE_DT_TM":
        SET dm_cmb_cust_cols2->add_col_val[eecv_loop].col_value = "cnvtdatetime(curdate, curtime3)"
       OF "END_EFFECTIVE_DT_TM":
        SET dm_cmb_cust_cols2->add_col_val[eecv_loop].col_value = 'cnvtdatetime("31-DEC-2100")'
      ENDCASE
    ENDFOR
   ENDIF
   SET at_acv_size = size(dm_cmb_cust_cols2->where_col_val,5)
   SET stat = alterlist(dm_cmb_cust_cols2->where_col_val,1)
   SET dm_cmb_cust_cols2->where_col_val[1].col_name = "ENCNTR_CODE_VALUE_R_ID"
   SET dm_cmb_cust_cols2->where_col_val[1].col_value = build(v_new_ecvr_id)
   IF (size(dm_cmb_cust_cols2->col,5)=0)
    SET dm_cmb_cust_cols2->tbl_name = "ENCNTR_CODE_VALUE_R_HIST"
    SET dm_cmb_cust_cols2->sub_select_from_tbl = "ENCNTR_CODE_VALUE_R"
    EXECUTE dm_cmb_get_pm_hist_cols  WITH replace("DM_CMB_CUST_COLS","DM_CMB_CUST_COLS2")
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    EXECUTE dm_cmb_get_common_cols  WITH replace("DM_CMB_CUST_COLS","DM_CMB_CUST_COLS2")
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF ((rreclist->pm_hist_tracking_id > 0.0))
     SET dcipht_request->pm_hist_tracking_id = rreclist->pm_hist_tracking_id
     SET dcipht_request->encntr_id = request->xxx_combine[icombine].to_xxx_id
     SET dcipht_request->transaction_reason_txt = "DM_ECMB_ENCNTR_CODE_VALUE_R"
     SET dcipht_request->transaction_type_txt = "CMB"
     EXECUTE dm_cmb_ins_pm_hist_tracking
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     SET rreclist->pm_hist_tracking_id = 0.0
    ENDIF
   ENDIF
   EXECUTE dm_cmb_ins_cust_row  WITH replace("DM_CMB_CUST_COLS","DM_CMB_CUST_COLS2")
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = add
   SET request->xxx_combine_det[icombinedet].entity_id = v_new_ecvrh_id
   SET request->xxx_combine_det[icombinedet].entity_name = "ENCNTR_CODE_VALUE_R_HIST"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
   RETURN(1)
 END ;Subroutine
#end_prog
 FREE SET rreclist
END GO

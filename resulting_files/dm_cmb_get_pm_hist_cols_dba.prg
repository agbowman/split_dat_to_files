CREATE PROGRAM dm_cmb_get_pm_hist_cols:dba
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
 DECLARE check_error(sbr_ceprocess=vc) = i2
 SUBROUTINE check_error(sbr_ceprocess)
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
 FREE RECORD phc_excl
 RECORD phc_excl(
   1 excl_cnt = i4
   1 qual[*]
     2 column_name = vc
 )
 DECLARE ph_cnt = i4
 DECLARE ph_flag = i4
 DECLARE phc_idx = i4 WITH protect, noconstant(0)
 SET ph_flag = 0
 SET ph_cnt = size(dm_cmb_cust_cols->add_col_val,5)
 SELECT INTO "nl:"
  FROM user_tab_cols u
  WHERE (u.table_name=dm_cmb_cust_cols->tbl_name)
   AND ((u.hidden_column="YES") OR (((u.virtual_column="YES") OR (u.column_name="LAST_UTC_TS")) ))
  HEAD REPORT
   phc_excl->excl_cnt = 0
  DETAIL
   phc_excl->excl_cnt = (phc_excl->excl_cnt+ 1), stat = alterlist(phc_excl->qual,phc_excl->excl_cnt),
   phc_excl->qual[phc_excl->excl_cnt].column_name = u.column_name
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  l.attr_name
  FROM dtable t,
   dtableattr a,
   dtableattrl l
  WHERE (t.table_name=dm_cmb_cust_cols->tbl_name)
   AND t.table_name=a.table_name
   AND l.structtype="F"
   AND btest(l.stat,11)=0
   AND  NOT (expand(phc_idx,1,phc_excl->excl_cnt,l.attr_name,phc_excl->qual[phc_idx].column_name))
  DETAIL
   CASE (l.attr_name)
    OF "TRANSACTION_DT_TM":
     ph_cnt = (ph_cnt+ 1),stat = alterlist(dm_cmb_cust_cols->add_col_val,ph_cnt),dm_cmb_cust_cols->
     add_col_val[ph_cnt].col_name = "TRANSACTION_DT_TM",
     dm_cmb_cust_cols->add_col_val[ph_cnt].col_value = "cnvtdatetime(curdate, curtime3)"
    OF "CHANGE_BIT":
     ph_cnt = (ph_cnt+ 1),stat = alterlist(dm_cmb_cust_cols->add_col_val,ph_cnt),dm_cmb_cust_cols->
     add_col_val[ph_cnt].col_name = "CHANGE_BIT",
     dm_cmb_cust_cols->add_col_val[ph_cnt].col_value = "0"
    OF "TRACKING_BIT":
     ph_cnt = (ph_cnt+ 1),stat = alterlist(dm_cmb_cust_cols->add_col_val,ph_cnt),dm_cmb_cust_cols->
     add_col_val[ph_cnt].col_name = "TRACKING_BIT",
     dm_cmb_cust_cols->add_col_val[ph_cnt].col_value = "1"
    OF "PM_HIST_TRACKING_ID":
     ph_cnt = (ph_cnt+ 1),stat = alterlist(dm_cmb_cust_cols->add_col_val,ph_cnt),dm_cmb_cust_cols->
     add_col_val[ph_cnt].col_name = "PM_HIST_TRACKING_ID",
     ph_flag = ph_cnt
   ENDCASE
  WITH nocounter
 ;end select
 IF (check_error("dm_cmb_get_pm_hist_cols") != 0)
  SET failed = select_error
  SET request->error_message = dm_err->emsg
 ENDIF
 IF (ph_flag > 0)
  SELECT INTO "nl:"
   y = seq(person_seq,nextval)
   FROM dual
   DETAIL
    rreclist->pm_hist_tracking_id = cnvtreal(y)
   WITH nocounter
  ;end select
  SET dm_cmb_cust_cols->add_col_val[ph_flag].col_value = build(rreclist->pm_hist_tracking_id)
 ENDIF
#exit_program
END GO

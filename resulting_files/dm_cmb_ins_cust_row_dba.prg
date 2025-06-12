CREATE PROGRAM dm_cmb_ins_cust_row:dba
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
 FREE RECORD cps_ps
 RECORD cps_ps(
   1 list[*]
     2 statement = vc
 )
 DECLARE cps_cnt = i4
 DECLARE dcic_col_size = i4
 DECLARE dcic_add_col_size = i4
 SET dcic_col_size = 0
 SET dcic_add_col_size = 0
 SET cps_cnt = 0
 SET dcic_col_size = size(dm_cmb_cust_cols->col,5)
 SET dcic_add_col_size = size(dm_cmb_cust_cols->add_col_val,5)
 CALL parser(concat("insert into ",dm_cmb_cust_cols->tbl_name," t ("))
 FOR (dcicr_lp = 1 TO dcic_col_size)
   IF (dcicr_lp=1)
    CALL parser(concat("t.",trim(dm_cmb_cust_cols->col[dcicr_lp].col_name)))
   ELSE
    CALL parser(concat(",t.",trim(dm_cmb_cust_cols->col[dcicr_lp].col_name)))
   ENDIF
 ENDFOR
 FOR (dcicr_lp = 1 TO dcic_add_col_size)
   IF (dcic_col_size > 0)
    CALL parser(concat(", t.",trim(dm_cmb_cust_cols->add_col_val[dcicr_lp].col_name)))
   ELSE
    IF (dcicr_lp=dcic_add_col_size)
     CALL parser(concat(" t.",trim(dm_cmb_cust_cols->add_col_val[dcicr_lp].col_name)))
    ELSE
     CALL parser(concat(" t.",trim(dm_cmb_cust_cols->add_col_val[dcicr_lp].col_name),","))
    ENDIF
   ENDIF
 ENDFOR
 CALL parser(") (select ")
 FOR (dcicr_lp = 1 TO dcic_col_size)
   IF (dcicr_lp=1)
    CALL parser(concat("f.",trim(dm_cmb_cust_cols->col[dcicr_lp].col_name)))
   ELSE
    CALL parser(concat(", f.",trim(dm_cmb_cust_cols->col[dcicr_lp].col_name)))
   ENDIF
 ENDFOR
 FOR (dcicr_lp = 1 TO dcic_add_col_size)
   IF (dcic_col_size > 0)
    CALL parser(concat(",",dm_cmb_cust_cols->add_col_val[dcicr_lp].col_value))
   ELSE
    IF (dcicr_lp=dcic_add_col_size)
     CALL parser(dm_cmb_cust_cols->add_col_val[dcicr_lp].col_value)
    ELSE
     CALL parser(concat(dm_cmb_cust_cols->add_col_val[dcicr_lp].col_value,","))
    ENDIF
   ENDIF
 ENDFOR
 CALL parser(concat("from ",dm_cmb_cust_cols->sub_select_from_tbl," f "))
 FOR (dcicr_lp = 1 TO size(dm_cmb_cust_cols->where_col_val,5))
   IF (dcicr_lp=1)
    CALL parser(build("where f.",trim(dm_cmb_cust_cols->where_col_val[dcicr_lp].col_name)," = ",
      dm_cmb_cust_cols->where_col_val[dcicr_lp].col_value))
   ELSE
    CALL parser(build("and f.",trim(dm_cmb_cust_cols->where_col_val[dcicr_lp].col_name)," = ",
      dm_cmb_cust_cols->where_col_val[dcicr_lp].col_value))
   ENDIF
 ENDFOR
 CALL parser(") with nocounter go")
 SET stat = alterlist(cps_ps->list,cps_cnt)
 IF (check_error(concat("Errors on insert into ",dm_cmb_cust_cols->tbl_name)) != 0)
  SET failed = insert_error
  SET request->error_message = dm_err->emsg
 ENDIF
END GO

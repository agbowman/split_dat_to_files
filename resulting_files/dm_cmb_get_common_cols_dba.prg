CREATE PROGRAM dm_cmb_get_common_cols:dba
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
 FREE RECORD dcg_excl
 RECORD dcg_excl(
   1 excl_cnt = i4
   1 qual[*]
     2 column_name = vc
 )
 DECLARE dcg_col_flag = i2
 DECLARE dcg_add_size = i4
 DECLARE dcg_col_cnt = i4
 DECLARE dcgcc_cnt = i4
 DECLARE dcg_idx = i4 WITH protect, noconstant(0)
 SET dcgcc_cnt = 0
 SET dcg_add_size = 0
 SET dcg_col_flag = 0
 SET dcg_add_size = size(dm_cmb_cust_cols->add_col_val,5)
 SELECT INTO "nl:"
  FROM user_tab_cols u
  WHERE (u.table_name=dm_cmb_cust_cols->tbl_name)
   AND ((u.hidden_column="YES") OR (((u.virtual_column="YES") OR (u.column_name="LAST_UTC_TS")) ))
  HEAD REPORT
   dcg_excl->excl_cnt = 0
  DETAIL
   dcg_excl->excl_cnt = (dcg_excl->excl_cnt+ 1), stat = alterlist(dcg_excl->qual,dcg_excl->excl_cnt),
   dcg_excl->qual[dcg_excl->excl_cnt].column_name = u.column_name
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM dtable t,
   dtableattr a,
   dtableattrl l
  WHERE t.table_name IN (dm_cmb_cust_cols->sub_select_from_tbl, dm_cmb_cust_cols->tbl_name)
   AND t.table_name=a.table_name
   AND l.structtype="F"
   AND btest(l.stat,11)=0
   AND  NOT (expand(dcg_idx,1,dcg_excl->excl_cnt,l.attr_name,dcg_excl->qual[dcg_idx].column_name))
  ORDER BY l.attr_name
  HEAD l.attr_name
   dcg_col_cnt = 0
  DETAIL
   dcg_col_cnt = (dcg_col_cnt+ 1)
  FOOT  l.attr_name
   IF (dcg_col_cnt=2)
    dcg_col_flag = 0
    FOR (dcg_lp = 1 TO dcg_add_size)
      IF ((l.attr_name=dm_cmb_cust_cols->add_col_val[dcg_lp].col_name))
       dcg_col_flag = 1, dcg_lp = dcg_add_size
      ENDIF
    ENDFOR
    IF (dcg_col_flag=0)
     dcgcc_cnt = (dcgcc_cnt+ 1)
     IF (mod(dcgcc_cnt,100)=1)
      stat = alterlist(dm_cmb_cust_cols->col,(dcgcc_cnt+ 99))
     ENDIF
     dm_cmb_cust_cols->col[dcgcc_cnt].col_name = l.attr_name
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(dm_cmb_cust_cols->col,dcgcc_cnt)
  WITH nocounter
 ;end select
 IF (check_error("dm_cmb_get_common_cols") != 0)
  SET failed = select_error
  SET request->error_message = dm_err->emsg
 ENDIF
END GO

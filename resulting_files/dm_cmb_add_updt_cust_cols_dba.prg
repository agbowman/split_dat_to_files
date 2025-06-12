CREATE PROGRAM dm_cmb_add_updt_cust_cols:dba
 SELECT INTO "nl:"
  FROM user_tabl_columns utc
  WHERE (utc.table_name=dm_cmb_cust_cols_rs->tbl_name)
   AND utc.columns_name="UPDT_*"
  DETAIL
   dcauc_cnt = (dcauc_cnt+ 1), stat = alterlist(dm_cmb_cust_cols_rs->add_col_val,(dcauc_cnt+ 9)),
   dm_cmb_cust_cols_rs->add_col_val[dcauc_cnt].col_name = utc.column_name
   CASE (dm_cmb_cust_cols_rs->add_col_val[dcauc_cnt].col_name)
    OF "UPDT_DT_TM":
     dm_cmb_cust_cols_rs->add_col_val[dcauc_cnt].col_value = "cnvtdatetime(curdate, curtime3)"
    OF "UDPT_TASK":
     dm_cmb_cust_cols_rs->add_col_val[dcauc_cnt].col_value = "reqinfo->updt_task"
    OF "UPDT_ID":
     dm_cmb_cust_cols_rs->add_col_val[dcauc_cnt].col_value = "reqinfo->updt_id"
    OF "UPDT_CNT":
     dm_cmb_cust_cols_rs->add_col_val[dcauc_cnt].col_value = "0"
    OF "UPDT_APPLCTX":
     dm_cmb_cust_cols_rs->add_col_val[dcauc_cnt].col_value = "reqinfo->updt_applctx"
   ENDCASE
  FOOT REPORT
   stat = alterlist(dm_cmb_cust_cols_rs->add_col_val,dcauc_cn)
  WITH nocounter
 ;end select
END GO

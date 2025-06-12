CREATE PROGRAM dm2xplan
 IF ((validate(dcr_plan_data->cnt,- (1))=- (1)))
  FREE RECORD dcr_plan_data
  RECORD dcr_plan_data(
    1 cnt = i4
    1 qual[*]
      2 sql_id = vc
      2 env_id = f8
      2 env_name = vc
      2 sql_text_cnt = i4
      2 sql_text[*]
        3 txt = vc
      2 plan_cnt = i4
      2 plans[*]
        3 plan_hash_value = f8
        3 child_number = f8
        3 first_load_dt_tm = dq8
        3 first_gets_exec = f8
        3 last_load_dt_tm = dq8
        3 last_gets_exec = f8
        3 plan_text_cnt = i4
        3 plan_text[*]
          4 txt = vc
  )
 ENDIF
 IF ((validate(dcr_sql->bind_cnt,- (1))=- (1)))
  FREE RECORD dcr_sql
  RECORD dcr_sql(
    1 sqlid = vc
    1 full_txt = vc
    1 instance_id = i4
    1 full_txt_with_binds = vc
    1 bind_cnt = i4
    1 bind[*]
      2 name = vc
      2 datatype = vc
      2 val_str = vc
    1 txt_cnt = i4
    1 txt[*]
      2 sql_txt_with_binds = vc
  )
 ENDIF
 IF ((validate(dcr_hist_vals->hist_cnt,- (1))=- (1)))
  FREE RECORD dcr_hist_vals
  RECORD dcr_hist_vals(
    1 tbl_name = vc
    1 col_name = vc
    1 ccl_data_type = vc
    1 hist_cnt = i4
    1 hist_type = vc
    1 hist[*]
      2 col_val = vc
      2 rows_per_key = f8
  )
 ENDIF
 IF ((validate(dcr_sqlplan->sql_cnt,- (1))=- (1)))
  FREE RECORD dcr_sqlplan
  RECORD dcr_sqlplan(
    1 sql_cnt = i4
    1 mode = vc
    1 output = vc
    1 sql[*]
      2 sqltext = vc
      2 child_cnt = i4
      2 sql_id = vc
      2 child[*]
        3 child_number = i4
        3 plan_hash = f8
        3 users_executing = f8
        3 rows_processed = f8
        3 fetches = f8
        3 parse_calls = f8
        3 actual_rows_processed = f8
        3 sorts = f8
        3 buff = f8
        3 exec = f8
        3 disk = f8
        3 first_time = c19
        3 rat = f8
        3 drat = f8
        3 cpu_time = f8
        3 crat = f8
        3 ela_time = f8
        3 erat = f8
        3 optimizer_mode = vc
        3 optimizer_cost = f8
        3 plan_line_cnt = i4
        3 bind_sensitive = vc
        3 bind_aware = vc
        3 exec_plan[*]
          4 plan_line = vc
        3 obj_cnt = i4
        3 objects[*]
          4 object_name = vc
  )
 ENDIF
 IF ((validate(dcrstrrec->break_str_cnt,- (1))=- (1)))
  FREE RECORD dcrstrrec
  RECORD dcrstrrec(
    1 break_str_cnt = i4
    1 break_str[*]
      2 token = vc
    1 orig_str_cnt = i4
    1 orig_str[*]
      2 str_full = vc
      2 piece_cnt = i4
      2 piece[*]
        3 str = vc
  )
 ENDIF
 IF ((validate(dcr_sql->exec_cnt,- (1))=- (1)))
  FREE RECORD dcr_sql
  RECORD dcr_sql(
    1 sqlid = vc
    1 full_txt = vc
    1 instance_id = i4
    1 exec_cnt = i4
    1 exec_full_txt = vc
    1 exec[*]
      2 sql_txt_exec = vc
    1 full_txt_with_binds = vc
    1 bind_cnt = i4
    1 bind[*]
      2 name = vc
      2 datatype = vc
      2 val_str = vc
      2 data_length = vc
    1 txt_cnt = i4
    1 txt[*]
      2 sql_txt_with_binds = vc
  )
 ENDIF
 IF ((validate(dcrdata->req_cnt,- (1))=- (1)))
  FREE RECORD dcrdata
  RECORD dcrdata(
    1 prompt_mode = vc
    1 destination = vc
    1 cur_env = vc
    1 cur_db = vc
    1 table_criteria = vc
    1 req_cnt = i4
    1 req_list[*]
      2 tbl_name = vc
    1 table_cnt = i4
    1 stat_type = vc
    1 tables[*]
      2 table_name = vc
      2 num_rows = f8
      2 blocks = f8
      2 avg_row_length = i4
      2 sample_size = f8
      2 last_analyzed = dq8
      2 last_analyzed_null_ind = i2
      2 global_stats = vc
      2 user_stats = vc
      2 table_mods_null_ind = i2
      2 inserts = f8
      2 updates = f8
      2 deletes = f8
      2 timestamp = dq8
      2 truncated = vc
      2 index_column_concat = vc
      2 column_cnt = i4
      2 columns[*]
        3 column_name = vc
        3 stat_null_ind = i2
        3 num_distinct = f8
        3 density = f8
        3 num_nulls = f8
        3 num_buckets = i4
        3 sample_size = f8
        3 avg_column_length = i4
        3 global_stats = vc
        3 user_stats = vc
        3 last_analyzed = dq8
        3 lit_column_ind = i2
        3 ccl_data_type = vc
        3 histogram_type = vc
        3 histogram_cnt = i4
        3 histogram[*]
          4 col_val = vc
          4 rows_per_key = f8
      2 index_cnt = i4
      2 indexes[*]
        3 index_name = vc
        3 num_rows = f8
        3 distinct_keys = f8
        3 b_lvl = i4
        3 leaf_blocks = i4
        3 avg_leaf_blocks_per_key = f8
        3 avg_data_blocks_per_key = f8
        3 clustering_factor = f8
        3 sample_size = f8
        3 last_analyzed = dq8
        3 last_analyzed_null_ind = i2
        3 global_stats = vc
        3 user_stats = vc
        3 index_column_cnt = i4
        3 index_columns[*]
          4 column_name = vc
          4 column_position = i2
  )
 ENDIF
 IF ((validate(dcr_sql_txt_ndx,- (1))=- (1))
  AND (validate(dcr_sql_txt_ndx,- (2))=- (2)))
  DECLARE dcr_sql_txt_ndx = i4 WITH protect, noconstant(0)
  DECLARE dcr_sql_id_ndx = i4 WITH protect, noconstant(0)
  DECLARE dcr_plan_data_ndx = i4 WITH protect, noconstant(0)
  DECLARE dcr_dst_curpos = i4 WITH protect, noconstant(0)
  DECLARE dcr_dst_nextpos = i4 WITH protect, noconstant(0)
  DECLARE dcr_dst_work_str = vc WITH protect, noconstant("")
  DECLARE dcr_dst_loop_cnt = i4 WITH protect, noconstant(0)
  DECLARE dcr_dst_break_cnt = i4 WITH protect, noconstant(0)
  DECLARE dcr_dst_sql_cnt = i4 WITH protect, noconstant(0)
  DECLARE dcr_dapt_plan_txt_cnt = i4 WITH protect, noconstant(0)
  DECLARE dcr_dapt_write_txt = i4 WITH protect, noconstant(0)
 ENDIF
 DECLARE dcr_add_sql_txt(dast_sqlid_in=vc,dast_envid_in=f8,dast_sqltxt_in=vc,dast_reset=i2) = i2
 DECLARE dcr_add_sql_id(dasi_sqlid_in=vc,dasi_envid_in=f8,dasi_reset=i2) = i2
 DECLARE dcr_add_plan_txt(dapt_sqlid=vc,dapt_plan_hash=f8,dapt_child_nbr=f8,dapt_envid=f8,
  dapt_plan_txt=vc,
  dapt_reset=i2) = i2
 DECLARE dcr_add_plan_data(dapd_sqlid=vc,dapd_envid=f8,dapd_plan_hash=f8,dapd_first_load=dq8,
  dapd_last_load=dq8,
  dapd_first_gets_exec=f8,dapd_last_gets_exec=f8,dapd_reset=i2) = i2
 DECLARE dcr_add_child_number(dacn_sqlid=vc,dacn_plan_hash=f8,dacn_child_nbr=f8,dacn_envid=f8) = i2
 DECLARE dcr_add_orig_str(dao_str_in=vc,dao_reset=i2) = i2
 DECLARE dcr_add_break_str(dabs_str_in=vc,dabs_reset=i2) = i2
 DECLARE dcr_add_piece(daes_str_in=vc,daes_orig_ndx=i4,daes_reset=i2) = i2
 DECLARE dcr_split_text(null) = i2
 DECLARE dcr_get_plan(dgp_ndx1=i4,dgp_ndx2=i4) = i2
 DECLARE dcr_init_sqlplan(null) = i2
 DECLARE dcr_get_dict_hist_vals(null) = i2
 DECLARE dcr_init_dict_hist_vals(null) = i2
 DECLARE dcr_get_instance_info(dgii_instance_name=vc(ref),dgii_instance_nbr=i4(ref)) = i2
 SUBROUTINE dcr_init_dict_hist_vals(null)
   SET dcr_hist_vals->tbl_name = ""
   SET dcr_hist_vals->col_name = ""
   SET dcr_hist_vals->ccl_data_type = ""
   SET dcr_hist_vals->hist_type = ""
   SET dcr_hist_vals->hist_cnt = 0
   SET stat = alterlist(dcr_hist_vals->hist,dcr_hist_vals->hist_cnt)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_get_dict_hist_vals(null)
   SET dm_err->eproc = concat("Gather HISTOGRAM values for ",dcr_hist_vals->tbl_name,".",
    dcr_hist_vals->col_name)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    h.endpt_val, frequency = (endpoint_number - nullval(prev_number,0.0)), h.histogram
    FROM (
     (
     (SELECT
      endpt_val = evaluate(dcr_hist_vals->ccl_data_type,"DQ8",sqlpassthru(
        "to_char(to_date(trunc(u.endpoint_value),'J'),'DD-MON-YYYY')"),"F8",trim(cnvtstring(u
         .endpoint_value,17,2)),
       "VC",u.endpoint_actual_value), endpoint_number, prev_number = sqlpassthru(
       "lag(endpoint_number,1) over(order by endpoint_number)"),
      uc.histogram
      FROM user_tab_histograms u,
       user_tab_columns uc
      WHERE (u.table_name=dcr_hist_vals->tbl_name)
       AND (u.column_name=dcr_hist_vals->col_name)
       AND u.table_name=uc.table_name
       AND u.column_name=uc.column_name
      ORDER BY (endpoint_number - nullval(prev_number,0.0)) DESC
      WITH sqltype("VC","F8","F8","VC")))
     h)
    HEAD REPORT
     dcr_hist_vals->hist_cnt = 0, dcr_hist_vals->hist_type = h.histogram
    DETAIL
     dcr_hist_vals->hist_cnt = (dcr_hist_vals->hist_cnt+ 1), stat = alterlist(dcr_hist_vals->hist,
      dcr_hist_vals->hist_cnt), dcr_hist_vals->hist[dcr_hist_vals->hist_cnt].col_val = h.endpt_val,
     dcr_hist_vals->hist[dcr_hist_vals->hist_cnt].rows_per_key = frequency
    FOOT REPORT
     stat = alterlist(dcr_hist_vals->hist,dcr_hist_vals->hist_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dcr_hist_vals->hist_type=""))
    SET dcr_hist_vals->hist_type = "NONE"
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcr_hist_vals)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_add_child_number(dacn_sqlid,dacn_plan_hash,dacn_child_nbr,dacn_envid)
   SET dcr_plan_data_ndx = 0
   SET dcr_sql_id_ndx = 0
   IF ((dcr_plan_data->cnt > 0))
    SET dcr_sql_id_ndx = locateval(dcr_sql_id_ndx,1,dcr_plan_data->cnt,dacn_sqlid,dcr_plan_data->
     qual[dcr_sql_id_ndx].sql_id,
     dacn_envid,dcr_plan_data->qual[dcr_sql_id_ndx].env_id)
    IF (dcr_sql_id_ndx > 0
     AND (dcr_plan_data->qual[dcr_sql_id_ndx].plan_cnt > 0))
     SET dcr_plan_data_ndx = locateval(dcr_plan_data_ndx,1,dcr_plan_data->qual[dcr_sql_id_ndx].
      plan_cnt,dacn_plan_hash,dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].
      plan_hash_value)
    ENDIF
   ENDIF
   IF (((dcr_sql_id_ndx=0) OR (dcr_plan_data_ndx=0)) )
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("DACN_SQLID:",dacn_sqlid))
     CALL echo(build("DACN_PLANHASH:",dacn_plan_hash))
     CALL echo(build("DACN_CHILDNUMBER:",dacn_child_nbr))
     CALL echo(build("DACN_ENVID:",dacn_envid))
     CALL echo("No sqlid found or plan_data found")
    ENDIF
   ELSE
    SET dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].child_number = dacn_child_nbr
   ENDIF
 END ;Subroutine
 SUBROUTINE dcr_add_plan_txt(dapt_sqlid,dapt_plan_hash,dapt_child_nbr,dapt_envid,dapt_plan_txt,
  dapt_reset)
   IF ((dm_err->debug_flag > 2))
    CALL echo(build("PlanTextSQLID:",dapt_sqlid))
    CALL echo(build("PlanTextPLANHASH:",dapt_plan_hash))
    CALL echo(build("PlanTextCHILDNUMBER:",dapt_child_nbr))
    CALL echo(build("PlanTextENVID:",dapt_envid))
    CALL echo(build("PlanTextTEXT:",dapt_plan_txt))
    CALL echo(build("PlanTextRESET:",dapt_reset))
   ENDIF
   SET dcr_plan_data_ndx = 0
   SET dcr_sql_id_ndx = 0
   IF ((dcr_plan_data->cnt > 0))
    SET dcr_sql_id_ndx = locateval(dcr_sql_id_ndx,1,dcr_plan_data->cnt,dapt_sqlid,dcr_plan_data->
     qual[dcr_sql_id_ndx].sql_id,
     dapt_envid,dcr_plan_data->qual[dcr_sql_id_ndx].env_id)
    IF (dcr_sql_id_ndx > 0
     AND (dcr_plan_data->qual[dcr_sql_id_ndx].plan_cnt > 0))
     SET dcr_plan_data_ndx = locateval(dcr_plan_data_ndx,1,dcr_plan_data->qual[dcr_sql_id_ndx].
      plan_cnt,dapt_plan_hash,dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].
      plan_hash_value)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echo(build("PlanTextSQLIDNDX:",dcr_sql_id_ndx))
    CALL echo(build("PlanTextPLANDATADX:",dcr_plan_data_ndx))
   ENDIF
   IF (dcr_sql_id_ndx=0
    AND dcr_plan_data_ndx=0)
    IF ((dm_err->debug_flag > 0))
     CALL echo("No sqlid found or plan_hash_value found")
    ENDIF
   ELSE
    IF (dapt_reset=1)
     SET dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].plan_text_cnt = 0
     SET stat = alterlist(dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].plan_text,
      dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].plan_text_cnt)
    ELSE
     SET dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].plan_text_cnt = (dcr_plan_data
     ->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].plan_text_cnt+ 1)
     SET stat = alterlist(dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].plan_text,
      dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].plan_text_cnt)
     SET dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].plan_text[dcr_plan_data->qual[
     dcr_sql_id_ndx].plans[dcr_plan_data_ndx].plan_text_cnt].txt = dapt_plan_txt
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dcr_add_plan_data(dapd_sqlid,dapd_envid,dapd_plan_hash,dapd_first_load,dapd_last_load,
  dapd_first_gets_exec,dapd_last_gets_exec,dapd_reset)
   SET dcr_plan_data_ndx = 0
   IF ((dcr_plan_data->cnt > 0))
    SET dcr_plan_data_ndx = locateval(dcr_plan_data_ndx,1,dcr_plan_data->cnt,dapd_sqlid,dcr_plan_data
     ->qual[dcr_plan_data_ndx].sql_id,
     dapd_envid,dcr_plan_data->qual[dcr_plan_data_ndx].env_id)
   ENDIF
   IF (dapd_reset=1)
    IF (dcr_plan_data_ndx > 0)
     SET dcr_plan_data->qual[dcr_plan_data_ndx].plan_cnt = 0
     SET stat = alterlist(dcr_plan_data->qual[dcr_plan_data_ndx].plans,dcr_plan_data->qual[
      dcr_plan_data_ndx].plan_cnt)
    ENDIF
   ELSE
    IF (dcr_plan_data_ndx > 0)
     SET dcr_plan_data->qual[dcr_plan_data_ndx].plan_cnt = (dcr_plan_data->qual[dcr_plan_data_ndx].
     plan_cnt+ 1)
     SET stat = alterlist(dcr_plan_data->qual[dcr_plan_data_ndx].plans,dcr_plan_data->qual[
      dcr_plan_data_ndx].plan_cnt)
     SET dcr_plan_data->qual[dcr_plan_data_ndx].plans[dcr_plan_data->qual[dcr_plan_data_ndx].plan_cnt
     ].plan_hash_value = dapd_plan_hash
     SET dcr_plan_data->qual[dcr_plan_data_ndx].plans[dcr_plan_data->qual[dcr_plan_data_ndx].plan_cnt
     ].first_load_dt_tm = dapd_first_load
     SET dcr_plan_data->qual[dcr_plan_data_ndx].plans[dcr_plan_data->qual[dcr_plan_data_ndx].plan_cnt
     ].last_load_dt_tm = dapd_last_load
     SET dcr_plan_data->qual[dcr_plan_data_ndx].plans[dcr_plan_data->qual[dcr_plan_data_ndx].plan_cnt
     ].first_gets_exec = dapd_first_gets_exec
     SET dcr_plan_data->qual[dcr_plan_data_ndx].plans[dcr_plan_data->qual[dcr_plan_data_ndx].plan_cnt
     ].last_gets_exec = dapd_last_gets_exec
    ELSE
     IF ((dm_err->debug_flag > 0))
      CALL echo("No sqlid found")
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dcr_add_sql_id(dasi_sqlid_in,dasi_envid_in,dasi_reset)
  SET dcr_sql_id_ndx = 0
  IF (dasi_reset=1)
   SET dcr_plan_data->cnt = 0
   SET stat = alterlist(dcr_plan_data->qual,dcr_plan_data->cnt)
  ELSE
   IF ((dcr_plan_data->cnt > 0))
    SET dcr_sql_id_ndx = locateval(dcr_sql_id_ndx,1,dcr_plan_data->cnt,dasi_sqlid_in,dcr_plan_data->
     qual[dcr_sql_id_ndx].sql_id,
     dasi_envid_in,dcr_plan_data->qual[dcr_sql_id_ndx].env_id)
   ENDIF
   IF (dcr_sql_id_ndx=0)
    SET dcr_plan_data->cnt = (dcr_plan_data->cnt+ 1)
    SET stat = alterlist(dcr_plan_data->qual,dcr_plan_data->cnt)
    SET dcr_sql_id_ndx = dcr_plan_data->cnt
    SET dcr_plan_data->qual[dcr_sql_id_ndx].sql_id = dasi_sqlid_in
    SET dcr_plan_data->qual[dcr_sql_id_ndx].env_id = dasi_envid_in
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE dcr_add_sql_txt(dast_sqlid_in,dast_envid_in,dast_sqltxt_in,dast_reset)
   SET dcr_sql_txt_ndx = 0
   IF ((dm_err->debug_flag > 2))
    CALL echo(build("DAST_SQLID:",dast_sqlid_in))
    CALL echo(build("DAST_ENV:",dast_envid_in))
    CALL echo(build("DAST_SQLTXT:",dast_sqltxt_in))
    CALL echo(build("DAST_RESET:",dast_reset))
   ENDIF
   IF ((dcr_plan_data->cnt > 0))
    SET dcr_sql_txt_ndx = locateval(dcr_sql_txt_ndx,1,dcr_plan_data->cnt,dast_sqlid_in,dcr_plan_data
     ->qual[dcr_sql_txt_ndx].sql_id,
     dast_envid_in,dcr_plan_data->qual[dcr_sql_txt_ndx].env_id)
   ENDIF
   IF (dast_reset=1)
    IF (dcr_sql_txt_ndx > 0)
     SET dcr_plan_data->qual[dcr_sql_txt_ndx].sql_text_cnt = 0
     SET stat = alterlist(dcr_plan_data->qual[dcr_sql_txt_ndx].sql_text,dcr_plan_data->qual[
      dcr_sql_txt_ndx].sql_text_cnt)
    ENDIF
   ELSE
    IF (dcr_sql_txt_ndx > 0)
     SET dcr_plan_data->qual[dcr_sql_txt_ndx].sql_text_cnt = (dcr_plan_data->qual[dcr_sql_txt_ndx].
     sql_text_cnt+ 1)
     SET stat = alterlist(dcr_plan_data->qual[dcr_sql_txt_ndx].sql_text,dcr_plan_data->qual[
      dcr_sql_txt_ndx].sql_text_cnt)
     SET dcr_plan_data->qual[dcr_sql_txt_ndx].sql_text[dcr_plan_data->qual[dcr_sql_txt_ndx].
     sql_text_cnt].txt = dast_sqltxt_in
    ELSE
     IF ((dm_err->debug_flag > 0))
      CALL echo("No sqlid found")
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dcr_add_orig_str(dao_str_in,dao_reset)
   IF (dao_reset=1)
    SET dcrstrrec->orig_str_cnt = 0
    SET stat = alterlist(dcrstrrec->orig_str,dcrstrrec->orig_str_cnt)
   ELSE
    SET dcrstrrec->orig_str_cnt = (dcrstrrec->orig_str_cnt+ 1)
    SET stat = alterlist(dcrstrrec->orig_str,dcrstrrec->orig_str_cnt)
    SET dcrstrrec->orig_str[dcrstrrec->orig_str_cnt].str_full = dao_str_in
   ENDIF
 END ;Subroutine
 SUBROUTINE dcr_add_break_str(dabs_str_in,dabs_reset)
   IF (dabs_reset=1)
    SET dcrstrrec->break_str_cnt = 0
    SET stat = alterlist(dcrstrrec->break_str,dcrstrrec->break_str_cnt)
   ELSE
    SET dcrstrrec->break_str_cnt = (dcrstrrec->break_str_cnt+ 1)
    SET stat = alterlist(dcrstrrec->break_str,dcrstrrec->break_str_cnt)
    SET dcrstrrec->break_str[dcrstrrec->break_str_cnt].token = notrim(dabs_str_in)
   ENDIF
 END ;Subroutine
 SUBROUTINE dcr_add_piece(dap_str_in,dap_orig_ndx,dap_reset)
   IF (dap_reset=1)
    SET dcrstrrec->orig_str[dap_orig_ndx].piece_cnt = 0
    SET stat = alterlist(dcrstrrec->orig_str[dap_orig_ndx].piece,dcrstrrec->orig_str[dap_orig_ndx].
     piece_cnt)
   ELSE
    SET dcrstrrec->orig_str[dap_orig_ndx].piece_cnt = (dcrstrrec->orig_str[dap_orig_ndx].piece_cnt+ 1
    )
    SET stat = alterlist(dcrstrrec->orig_str[dap_orig_ndx].piece,dcrstrrec->orig_str[dap_orig_ndx].
     piece_cnt)
    SET dcrstrrec->orig_str[dap_orig_ndx].piece[dcrstrrec->orig_str[dap_orig_ndx].piece_cnt].str =
    dap_str_in
   ENDIF
 END ;Subroutine
 SUBROUTINE dcr_split_text(null)
   FOR (dcr_dst_sql_cnt = 1 TO dcrstrrec->orig_str_cnt)
     CALL dcr_add_piece("",0,1)
     SET dcr_dst_break_cnt = 0
     SET dcr_dst_loop_cnt = 0
     SET dcr_dst_nextpos = 0
     SET dcr_dst_curpos = 1
     WHILE (dcr_dst_curpos < size(dcrstrrec->orig_str[dcr_dst_sql_cnt].str_full)
      AND dcr_dst_loop_cnt < 200)
       SET dcr_dst_loop_cnt = (dcr_dst_loop_cnt+ 1)
       IF (size(dcrstrrec->orig_str[dcr_dst_sql_cnt].str_full) < 120)
        SET dcr_dst_nextpos = (size(dcrstrrec->orig_str[dcr_dst_sql_cnt].str_full)+ 1)
       ELSE
        SET dcr_dst_work_str = substring(dcr_dst_curpos,120,dcrstrrec->orig_str[dcr_dst_sql_cnt].
         str_full)
        SET dcr_dst_nextpos = 0
        FOR (dcr_dst_break_cnt = 1 TO dcrstrrec->break_str_cnt)
         SET dcr_dst_nextpos = greatest(dcr_dst_nextpos,findstring(dcrstrrec->break_str[
           dcr_dst_break_cnt].token,dcr_dst_work_str,1,1))
         IF ((dm_err->debug_flag > 1))
          CALL echo(concat("Found ",dcrstrrec->break_str[dcr_dst_break_cnt].token," at ",build(
             dcr_dst_nextpos)))
         ENDIF
        ENDFOR
        IF ((dm_err->debug_flag > 1))
         CALL echo(build("PRECurpos:",dcr_dst_curpos,":PRENextpos:",dcr_dst_nextpos))
        ENDIF
        IF (dcr_dst_nextpos > 0)
         IF (((dcr_dst_curpos+ 120) > size(dcrstrrec->orig_str[dcr_dst_sql_cnt].str_full)))
          SET dcr_dst_nextpos = (dcr_dst_curpos+ 120)
         ELSE
          SET dcr_dst_nextpos = (dcr_dst_curpos+ dcr_dst_nextpos)
         ENDIF
        ELSE
         SET dcr_dst_nextpos = (dcr_dst_curpos+ 120)
        ENDIF
       ENDIF
       IF ((dm_err->debug_flag > 1))
        CALL echo(build("Curpos:",dcr_dst_curpos,":Nextpos:",dcr_dst_nextpos))
        CALL echo(dcr_dst_work_str)
        CALL echo(substring(dcr_dst_curpos,(dcr_dst_nextpos - dcr_dst_curpos),dcrstrrec->orig_str[
          dcr_dst_sql_cnt].str_full))
       ENDIF
       CALL dcr_add_piece(substring(dcr_dst_curpos,(dcr_dst_nextpos - dcr_dst_curpos),dcrstrrec->
         orig_str[dcr_dst_sql_cnt].str_full),dcr_dst_sql_cnt,0)
       SET dcr_dst_curpos = dcr_dst_nextpos
     ENDWHILE
   ENDFOR
 END ;Subroutine
 SUBROUTINE dcr_init_sqlplan(null)
   SET stat = alterlist(dcr_sqlplan->sql,0)
   SET dcr_sqlplan->sql_cnt = 0
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_get_plan(dgp_ndx1,dgp_ndx2)
   DECLARE dcp_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcp_cnt2 = i4 WITH protect, noconstant(0)
   DECLARE dcp_start_pt = i4 WITH protect, noconstant(0)
   DECLARE dcp_end_pt = i4 WITH protect, noconstant(0)
   DECLARE dcp_str = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Arrange plan data for reporting.SQL_ID:",dcr_sqlplan->sql[dgp_ndx1].
    sql_id," Child Number: ",trim(cnvtstring(dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].child_number)
     ))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   CALL parser(concat(
     'rdb asis("Insert into shared_txt_gttd (source_entity_txt)(SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR',
     "('",dcr_sqlplan->sql[dgp_ndx1].sql_id,"',",trim(cnvtstring(dcr_sqlplan->sql[dgp_ndx1].child[
       dgp_ndx2].child_number)),
     ",'",dcr_sqlplan->mode,^')))") go^),1)
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "nl"
    FROM shared_txt_gttd s
    HEAD REPORT
     dcp_cnt2 = 0, dcp_cnt = 0, dcp_str = ""
    DETAIL
     IF ((dm_err->debug_flag > 3))
      CALL echo(s.source_entity_txt)
     ENDIF
     dcp_cnt = (dcp_cnt+ 1), stat = alterlist(dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].exec_plan,
      dcp_cnt), dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].exec_plan[dcp_cnt].plan_line = s
     .source_entity_txt,
     dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].plan_line_cnt = dcp_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   ROLLBACK
   SELECT INTO "nl:"
    ratio = (a.buffer_gets/ a.executions), dratio = (a.disk_reads/ a.executions)
    FROM v$sqlarea a
    WHERE (a.sql_id=dcr_sqlplan->sql[dgp_ndx1].sql_id)
     AND (a.plan_hash_value=dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].plan_hash)
     AND a.executions > 0
    DETAIL
     dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].buff = a.buffer_gets, dcr_sqlplan->sql[dgp_ndx1].
     child[dgp_ndx2].exec = a.executions, dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].disk = a
     .disk_reads,
     dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].first_time = a.first_load_time, dcr_sqlplan->sql[
     dgp_ndx1].child[dgp_ndx2].rat = ratio, dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].drat = dratio,
     dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].users_executing = a.users_executing, dcr_sqlplan->
     sql[dgp_ndx1].child[dgp_ndx2].fetches = a.fetches, dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].
     parse_calls = a.parse_calls,
     dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].actual_rows_processed = (a.rows_processed/ a
     .executions), dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].rows_processed = a.rows_processed,
     dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].sorts = a.sorts,
     dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].ela_time = a.elapsed_time, dcr_sqlplan->sql[dgp_ndx1]
     .child[dgp_ndx2].erat = ((a.elapsed_time/ 1000000)/ a.executions), dcr_sqlplan->sql[dgp_ndx1].
     child[dgp_ndx2].cpu_time = validate(a.cpu_time,- (1))
     IF ((dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].cpu_time != - (1)))
      dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].crat = ((a.cpu_time/ 1000000)/ a.executions)
     ENDIF
     dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].optimizer_mode = trim(a.optimizer_mode), dcr_sqlplan
     ->sql[dgp_ndx1].child[dgp_ndx2].optimizer_cost = a.optimizer_cost, dcr_sqlplan->sql[dgp_ndx1].
     child[dgp_ndx2].bind_sensitive = a.is_bind_sensitive,
     dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].bind_aware = a.is_bind_aware
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_get_instance_info(dgii_instance_name,dgii_instance_nbr)
   SET dm_err->eproc = "Retrieve instance info from v$instance"
   SELECT INTO "nl:"
    FROM v$instance vi
    DETAIL
     dgii_instance_name = vi.instance_name, dgii_instance_nbr = vi.instance_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dcparr_output = vc WITH protect, noconstant("")
 DECLARE dcparr_search = vc WITH protect, noconstant("")
 DECLARE dcparr_search_text = vc WITH protect, noconstant("")
 DECLARE dcparr_child = vc WITH protect, noconstant("")
 DECLARE dcparr_mode = vc WITH protect, noconstant("")
 DECLARE dcparr_queries = vc WITH protect, noconstant("")
 DECLARE dcparr_sort = vc WITH protect, noconstant("")
 SET dcparr_output = "MINE"
 SET width = 132
 SET message = window
 CALL clear(1,1)
 CALL text(1,1,"DM2XPLAN")
 CALL text(4,2,"Lookup by SQLID (S) or TEXT (T):")
 CALL text(5,2,"Enter the Search Text          :")
 CALL text(6,2,"Child Number                   :")
 CALL text(7,2,"Mode                           :")
 CALL text(8,2,"Number of Queries              :")
 CALL text(9,2,"Sort Criteria                  :")
 CALL text(10,5,"Sort Criteria Options:")
 CALL text(11,10,"0 = SQL_ID,CHILD_NUMBER")
 CALL text(12,10,"1 = EXECUTIONS")
 CALL text(13,10,"2 = ELAPSED_TIME")
 CALL text(14,10,"3 = BUFFER_GETS")
 CALL text(15,10,"4 = DISK_READS")
 CALL text(16,10,"5 = CPU_TIME")
 CALL text(17,10,"2R = ELAPSED_RATIO")
 CALL text(18,10,"3R = BUFFER_GETS_RATIO")
 CALL text(19,10,"4R = DISK_READS_RATIO")
 CALL text(20,10,"5R = CPU_TIME_RATIO")
 CALL accept(4,36,"A(1);cu","T"
  WHERE curaccept IN ("S", "T"))
 SET dcparr_search = curaccept
 CALL accept(5,36,"p(60);c"," ")
 SET dcparr_search_text = curaccept
 IF (trim(dcparr_search_text,3)=char(42))
  CALL text(21,1,
   "NOTE: You have chosen to search ALL SQL across ALL database instances. This is very costly and can impact "
   )
  CALL text(22,1,
   "system performance. Oracle AWR or Cerner LightsOn reports are better options for Top SQL related inquiries."
   )
  CALL text(23,1,"Would you like to continue?")
  CALL accept(23,30,"A(1);cu","N"
   WHERE curaccept IN ("Y", "N"))
  IF (curaccept="N")
   GO TO exit_script
  ENDIF
 ENDIF
 CALL accept(6,36,"p(5);cu","ALL")
 SET dcparr_child = curaccept
 CALL accept(7,36,"p(50);cu","ALLSTATS LAST +PEEKED_BINDS")
 SET dcparr_mode = curaccept
 CALL accept(8,36,"p(4);cu","25")
 SET dcparr_queries = curaccept
 CALL accept(9,36,"p(2);cu","0"
  WHERE curaccept IN ("0", "1", "2", "3", "4",
  "5", "2R", "3R", "4R", "5R"))
 SET dcparr_sort = curaccept
 SET message = nowindow
 CALL clear(1,1)
 EXECUTE dm2xplan_rpt value(dcparr_output), dcparr_search, dcparr_search_text,
 dcparr_child, dcparr_mode, dcparr_queries,
 dcparr_sort
#exit_script
END GO

CREATE PROGRAM dm_purge_data_child:dba
 DECLARE build_where(i_child_col_str,i_parent_col_str,i_where_sub_str,i_child_where) = vc
 DECLARE build_delete(i_child_table,i_where_str) = vc
 DECLARE build_select(i_child_table,i_where_str) = vc
 DECLARE dpdc_exec_purge(null) = i2
 DECLARE dpdc_run_check(drc_template_nbr=f8) = i2
 DECLARE v_child_col_str = vc
 DECLARE v_cur_tab = i4
 DECLARE v_err_found = i2
 DECLARE v_list_str = vc
 DECLARE v_num_found = i4
 DECLARE v_num_rows = i4
 DECLARE v_num_tabs = i4
 DECLARE v_parent_col_str = vc
 DECLARE v_use_batch_process_ind = i2
 DECLARE v_last_ddl_time = dq8
 DECLARE v_has_purge_index_row = i2
 DECLARE v_purge_row_is_valid = i2
 DECLARE v_is_admin_table_ind = i2
 DECLARE v_admin_db_name = vc
 DECLARE v_has_admin_link = i2
 DECLARE v_temp_table_name = vc
 DECLARE v_temp_proc_name = vc
 DECLARE v_ind_column_cnt = i2
 DECLARE v_table_create_parser = vc
 DECLARE v_ind_col_loop = i2
 DECLARE v_insert_stmt = vc
 DECLARE v_truncate_stmt = vc
 DECLARE v_old_max_rows = i4
 DECLARE v_rowid_collect_start = dq8
 DECLARE v_rowid_collect_runtime = f8
 DECLARE v_oracle_version = i4
 DECLARE dpdc_original_module = vc WITH protect, noconstant("")
 DECLARE dpdc_original_action = vc WITH protect, noconstant("")
 DECLARE v_rows_to_purge_flag = i4
 FREE RECORD b_ind_columns
 RECORD b_ind_columns(
   1 validationfield = c1
   1 columns[*]
     2 columnname = vc
     2 datatype = vc
 )
 DECLARE v_template_tbl_count = i4
 DECLARE v_str = vc
 DECLARE v_tab_ndx = i4
 DECLARE v_tot_child_rows = i4
 DECLARE v_info_char = vc
 IF (dpd_modact_allowed_ind)
  SELECT INTO "nl:"
   vs.module, vs.action
   FROM v$session vs
   WHERE vs.audsid=cnvtreal(currdbhandle)
   HEAD REPORT
    dpdc_original_module = vs.module, dpdc_original_action = vs.action
   WITH nocounter, format
  ;end select
  CALL set_module(concat("DMPURGE:",cnvtstring(jobs->data[job_ndx].template_nbr)),concat("CH:",
    cnvtstring(v_log_id)))
 ENDIF
 SET no_rows = 0
 FREE SET b_request
 RECORD b_request(
   1 max_rows = i4
   1 purge_flag = i2
   1 last_run_date = vc
   1 tokens[*]
     2 token_str = vc
     2 value = vc
 )
 FREE SET b_reply
 RECORD b_reply(
   1 err_msg = vc
   1 err_code = i4
   1 table_name = vc
   1 rows_between_commit = i4
   1 rows_remain_ind = i2
   1 rows[*]
     2 row_id = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET dpo_reply
 RECORD dpo_reply(
   1 owner_name = vc
   1 table_name = vc
   1 cursor_query = vc
   1 fetch_size = i4
   1 max_rows = f8
   1 err_msg = vc
   1 err_code = i4
   1 rows_deleted = f8
   1 delete_time = f8
   1 fetch_time = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET stmt
 RECORD stmt(
   1 tabs[*]
     2 where_str = vc
     2 where_sub_str = vc
     2 parent_table = vc
     2 child_table = vc
     2 purge_type_flag = i2
     2 child_col1 = vc
     2 child_col2 = vc
     2 child_col3 = vc
     2 child_col4 = vc
     2 child_col5 = vc
     2 num_found = f8
     2 stmt = vc
     2 purge_runtime = f8
 )
 SET v_errmsg = fillstring(132," ")
 SET v_err_code = 0
 SET stat = alterlist(b_request->tokens,0)
 SET b_request->max_rows = max_rows
 SET stat = alterlist(b_request->tokens,size(jobs->data[job_ndx].tokens,5))
 FOR (tok_ndx = 1 TO size(jobs->data[job_ndx].tokens,5))
  SET b_request->tokens[tok_ndx].token_str = jobs->data[job_ndx].tokens[tok_ndx].token_str
  SET b_request->tokens[tok_ndx].value = jobs->data[job_ndx].tokens[tok_ndx].value
 ENDFOR
 SET b_request->purge_flag = jobs->data[job_ndx].purge_flag
 IF (validate(request->debug_mode,"Z") != "Z")
  CALL echorecord(b_request)
 ENDIF
 IF (dpdc_run_check(jobs->data[job_ndx].template_nbr)=1)
  SET i18nhandle = 0
  SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
  SET v_errmsg = build(
   "This template job could not be started as it was already running from a different ops job.",
   " Please ensure your purge ops jobs are scheduled far enough apart to avoid overlap.")
  SET v_errmsg = uar_i18ngetmessage(i18nhandle,"COLLISION_ERROR",v_errmsg)
  SET v_err_code = - (1)
  INSERT  FROM dm_purge_job_log jl
   SET jl.log_id = v_log_id, jl.job_id = jobs->data[job_ndx].job_id, jl.purge_flag = jobs->data[
    job_ndx].purge_flag,
    jl.start_dt_tm = cnvtdatetime(v_start_date), jl.end_dt_tm = cnvtdatetime(curdate,curtime3), jl
    .parent_rows = 0,
    jl.child_rows = 0, jl.err_msg = v_errmsg, jl.err_code = v_err_code,
    jl.updt_dt_tm = cnvtdatetime(curdate,curtime3), jl.updt_task = reqinfo->updt_task, jl.updt_cnt =
    0,
    jl.updt_id = reqinfo->updt_id, jl.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  COMMIT
  UPDATE  FROM dm_purge_job pj
   SET pj.last_run_dt_tm = cnvtdatetime(v_start_date), pj.last_run_status_flag = c_sf_failed
   WHERE (pj.job_id=jobs->data[job_ndx].job_id)
  ;end update
  COMMIT
 ELSEIF (dpo_flag=0)
  SET reply->status_data.status = "F"
  IF (dpdc_exec_purge(null)=0)
   CALL echo("Failure in dpdc_exec_purge")
  ENDIF
 ELSE
  SET dpo_reply->status_data.status = "F"
  EXECUTE dm_purge_data_child_dpo
 ENDIF
 IF (dpd_modact_allowed_ind)
  CALL set_module(concat("DMPURGE:",cnvtstring(jobs->data[job_ndx].template_nbr)),concat("CH:",
    cnvtstring(v_log_id)))
 ENDIF
 IF (v_err_found=0
  AND v_err_code=0
  AND (dpo_reply->err_code=0))
  UPDATE  FROM dm_purge_job pj
   SET pj.last_run_dt_tm = cnvtdatetime(v_start_date), pj.last_run_status_flag = c_sf_success
   WHERE (pj.job_id=jobs->data[job_ndx].job_id)
   WITH nocounter
  ;end update
  COMMIT
  SET v_info_char = concat(" deletes completed - ",format(cnvtdatetime(curdate,curtime3),";;q"),";")
  UPDATE  FROM dm_info di
   SET di.info_char = concat(di.info_char,v_info_char)
   WHERE di.info_domain="DM PURGE INFO"
    AND di.info_name=dpd_info_name
    AND di.info_number=dpd_run_id
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 IF (validate(request->debug_mode,"Z") != "Z")
  CALL echo(concat("Look for explain plans in ccluserdir:dm_purge_data_",trim(cnvtstring(jobs->data[
      job_ndx].job_id),3),"_*"))
 ENDIF
 SUBROUTINE build_where(i_child_col_str,i_parent_col_str,i_where_sub_str,i_child_where)
   RETURN(concat(" (",trim(i_child_col_str,3),") in (select ",trim(i_parent_col_str,3)," ",
    trim(i_where_sub_str,3),") ",evaluate(i_child_where," and "," ",i_child_where)))
 END ;Subroutine
 SUBROUTINE build_delete(i_child_table,i_where_str,i_list_str)
   RETURN(concat("delete from ",trim(i_child_table,3)," where ",trim(i_list_str,3)," ",
    trim(i_where_str,3)))
 END ;Subroutine
 SUBROUTINE build_update(i_child_table,i_where_str,i_child_col1,i_child_col2,i_child_col3,
  i_child_col4,i_child_col5,i_list_str)
   DECLARE v_ret_str = vc
   IF (v_use_batch_process_ind=1)
    SET v_ret_str = concat("update ",trim(i_child_table,3)," set ",trim(i_child_col1,3)," = 0 ")
   ELSE
    SET v_ret_str = concat("update from ",trim(i_child_table,3)," set ",trim(i_child_col1,3)," = 0 ")
   ENDIF
   IF (size(trim(i_child_col2,3)) > 0)
    SET v_ret_str = concat(trim(v_ret_str,3),", ",trim(i_child_col2,3)," = 0 ")
   ENDIF
   IF (size(trim(i_child_col3,3)) > 0)
    SET v_ret_str = concat(trim(v_ret_str,3),", ",trim(i_child_col3,3)," = 0 ")
   ENDIF
   IF (size(trim(i_child_col4,3)) > 0)
    SET v_ret_str = concat(trim(v_ret_str,3),", ",trim(i_child_col4,3)," = 0 ")
   ENDIF
   IF (size(trim(i_child_col5,3)) > 0)
    SET v_ret_str = concat(trim(v_ret_str,3),", ",trim(i_child_col5,3)," = 0 ")
   ENDIF
   SET v_ret_str = concat(trim(v_ret_str,3)," where ",trim(i_list_str,3)," ",trim(i_where_str,3))
   RETURN(trim(v_ret_str,3))
 END ;Subroutine
 SUBROUTINE build_select(i_child_table,i_where_str,i_list_str)
   RETURN(concat('select into "nl:" cnt = count(*) from ',trim(i_child_table,3)," where ",trim(
     i_list_str,3)," ",
    trim(i_where_str,3)," detail v_num_found = cnt with nocounter"))
 END ;Subroutine
 SUBROUTINE dpdc_exec_purge(null)
   IF (dpd_modact_allowed_ind)
    CALL set_module(concat("DMPURGE:",cnvtstring(jobs->data[job_ndx].template_nbr)),concat("CHROWID:",
      cnvtstring(v_log_id)))
   ENDIF
   SET reply->status_data.status = "F"
   IF (validate(request->debug_mode,"Z") != "Z")
    CALL echo(concat("execute ",trim(jobs->data[job_ndx].program_str,3),
      " with replace(request,b_request), replace(reply,b_reply) go"))
   ENDIF
   SET v_old_max_rows = b_request->max_rows
   SET b_request->max_rows = (b_request->max_rows+ 1)
   SET v_rowid_collect_start = cnvtdatetime(curdate,curtime3)
   CALL parser(concat("execute ",trim(jobs->data[job_ndx].program_str,3),
     " with replace(request,b_request), replace(reply,b_reply) go"))
   SET v_rowid_collect_runtime = datetimediff(cnvtdatetime(curdate,curtime3),v_rowid_collect_start,4)
   SET v_errmsg = fillstring(132," ")
   SET v_err_code = 0
   SET v_err_code = error(v_errmsg,1)
   SET v_info_char = concat(jobs->data[job_ndx].program_str," completed - ",format(cnvtdatetime(
      curdate,curtime3),";;q")," with rows = ",trim(cnvtstring(size(b_reply->rows,5))),
    "; ")
   UPDATE  FROM dm_info di
    SET di.info_char = concat(di.info_char,v_info_char)
    WHERE di.info_domain="DM PURGE INFO"
     AND di.info_name=dpd_info_name
     AND di.info_number=dpd_run_id
    WITH nocounter
   ;end update
   COMMIT
   IF (size(b_reply->rows,5)=0)
    SET no_rows = 1
   ENDIF
   IF ((((b_reply->status_data.status != "S")
    AND (b_reply->status_data.status != "Z")) OR (v_err_code != 0)) )
    IF ((b_reply->status_data.status != "K"))
     IF ((b_reply->err_code=0))
      IF (v_err_code=0)
       SET v_err_code = - (1)
      ENDIF
     ELSE
      SET v_err_code = b_reply->err_code
      SET v_errmsg = b_reply->err_msg
     ENDIF
     IF (batch_ndx=1)
      INSERT  FROM dm_purge_job_log jl
       SET jl.log_id = v_log_id, jl.job_id = jobs->data[job_ndx].job_id, jl.purge_flag = jobs->data[
        job_ndx].purge_flag,
        jl.start_dt_tm = cnvtdatetime(v_start_date), jl.end_dt_tm = cnvtdatetime(curdate,curtime3),
        jl.parent_table = b_reply->table_name,
        jl.parent_rows = 0, jl.child_rows = 0, jl.err_msg = v_errmsg,
        jl.err_code = v_err_code, jl.updt_dt_tm = cnvtdatetime(curdate,curtime3), jl.updt_task =
        reqinfo->updt_task,
        jl.updt_cnt = 0, jl.updt_id = reqinfo->updt_id, jl.updt_applctx = reqinfo->updt_applctx
      ;end insert
     ELSE
      UPDATE  FROM dm_purge_job_log jl
       SET jl.job_id = jobs->data[job_ndx].job_id, jl.purge_flag = jobs->data[job_ndx].purge_flag, jl
        .start_dt_tm = cnvtdatetime(v_start_date),
        jl.end_dt_tm = cnvtdatetime(curdate,curtime3), jl.parent_table = b_reply->table_name, jl
        .parent_rows = 0,
        jl.child_rows = 0, jl.err_msg = v_errmsg, jl.err_code = v_err_code,
        jl.updt_dt_tm = cnvtdatetime(curdate,curtime3), jl.updt_task = reqinfo->updt_task, jl
        .updt_cnt = 0,
        jl.updt_id = reqinfo->updt_id, jl.updt_applctx = reqinfo->updt_applctx
       WHERE jl.log_id=v_log_id
      ;end update
     ENDIF
     UPDATE  FROM dm_purge_job pj
      SET pj.last_run_dt_tm = cnvtdatetime(v_start_date), pj.last_run_status_flag = c_sf_failed
      WHERE (pj.job_id=jobs->data[job_ndx].job_id)
     ;end update
     SET stat = alterlist(b_reply->rows,0)
     SET no_rows = 1
    ENDIF
   ELSE
    IF (dpd_modact_allowed_ind)
     CALL set_module(concat("DMPURGE:",cnvtstring(jobs->data[job_ndx].template_nbr)),concat("CH:",
       cnvtstring(v_log_id)))
    ENDIF
    IF (size(b_reply->rows,5) > v_old_max_rows)
     SET v_rows_to_purge_flag = 1
     SET stat = alterlist(b_reply->rows,v_old_max_rows)
    ELSEIF ((b_reply->rows_remain_ind=1))
     SET v_rows_to_purge_flag = 2
    ELSE
     SET v_rows_to_purge_flag = 0
    ENDIF
    SET b_request->max_rows = v_old_max_rows
    SET v_purging_sum = (v_purging_sum+ size(b_reply->rows,5))
    IF ((b_reply->rows_between_commit < 1))
     SET b_reply->rows_between_commit = 1
    ENDIF
    SET v_num_rows = size(b_reply->rows,5)
    SET v_num_tabs = 1
    SET v_cur_tab = 1
    SET v_use_batch_process_ind = 0
    SET v_has_purge_index_row = 0
    IF (no_rows=0)
     SET v_template_tbl_count = 0
     SELECT INTO "nl:"
      dpt.parent_table, dpt.child_table
      FROM dm_purge_table dpt
      WHERE (dpt.template_nbr=jobs->data[job_ndx].template_nbr)
       AND (dpt.schema_dt_tm=
      (SELECT
       max(dpt2.schema_dt_tm)
       FROM dm_purge_table dpt2
       WHERE dpt2.template_nbr=dpt.template_nbr))
       AND dpt.purge_type_flag IN (1, 2)
      ORDER BY dpt.parent_table, dpt.child_table
      HEAD dpt.parent_table
       v_template_tbl_count = (v_template_tbl_count+ 1)
      HEAD dpt.child_table
       IF (nullind(dpt.child_table)=0
        AND dpt.child_table > " ")
        v_template_tbl_count = (v_template_tbl_count+ 1)
       ENDIF
      WITH nocounter
     ;end select
     IF (v_template_tbl_count > 1)
      SELECT INTO "nl:"
       FROM dm_purge_table_index dpti
       WHERE (dpti.table_name=b_reply->table_name)
       DETAIL
        v_is_admin_table_ind = dpti.admin_table_ind, v_last_ddl_time = dpti.last_ddl_dt_tm,
        v_has_purge_index_row = 1
       WITH nocounter
      ;end select
      SET stat = alterlist(b_ind_columns->columns,0)
      IF (v_has_purge_index_row=1)
       IF (v_is_admin_table_ind=1)
        SELECT DISTINCT INTO "nl:"
         ds.db_link
         FROM dba_synonyms ds
         WHERE ds.synonym_name="DM_ENVIRONMENT"
         HEAD REPORT
          period_pos = 0
         DETAIL
          period_pos = findstring(".WORLD",ds.db_link), v_admin_db_name = cnvtupper(substring(1,(
            period_pos - 1),ds.db_link)), v_has_admin_link = 1
         WITH nocounter
        ;end select
        IF (v_has_admin_link=1)
         SELECT INTO "nl:"
          FROM (value(concat("USER_OBJECTS@",v_admin_db_name)) uo)
          WHERE (uo.object_name=b_reply->table_name)
           AND uo.object_type="TABLE"
           AND uo.last_ddl_time=cnvtdatetime(v_last_ddl_time)
          DETAIL
           v_purge_row_is_valid = 1
          WITH nocounter
         ;end select
        ENDIF
       ELSE
        SELECT INTO "nl:"
         FROM user_objects uo
         WHERE (uo.object_name=b_reply->table_name)
          AND uo.object_type="TABLE"
          AND uo.last_ddl_time=cnvtdatetime(v_last_ddl_time)
         DETAIL
          v_purge_row_is_valid = 1
         WITH nocounter
        ;end select
       ENDIF
      ENDIF
      IF (v_has_purge_index_row=1
       AND v_purge_row_is_valid=0)
       EXECUTE dm_refresh_purge_indexes value(b_reply->table_name)
       SET v_ind_column_cnt = size(b_ind_columns->columns,5)
      ELSEIF (v_has_purge_index_row=1
       AND v_purge_row_is_valid=1)
       SELECT INTO "nl:"
        FROM dm_purge_table_index dpti
        WHERE (dpti.table_name=b_reply->table_name)
        ORDER BY dpti.precedence_nbr
        DETAIL
         v_ind_column_cnt = (v_ind_column_cnt+ 1), stat = alterlist(b_ind_columns->columns,
          v_ind_column_cnt), b_ind_columns->columns[v_ind_column_cnt].columnname = dpti.column_name,
         b_ind_columns->columns[v_ind_column_cnt].datatype = dpti.data_type
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
    ENDIF
    IF (v_ind_column_cnt > 0)
     SET v_use_batch_process_ind = 1
    ENDIF
    IF (v_use_batch_process_ind=1)
     SET v_temp_table_name = build("dm_prg_tmp_",cnvtstring(jobs->data[job_ndx].template_nbr),"_",
      curtime)
     SET v_table_create_parser = concat("rdb asis(^ create global temporary table ",v_temp_table_name,
      " (")
     SET v_table_create_parser = concat(v_table_create_parser,b_ind_columns->columns[1].columnname,
      " ",b_ind_columns->columns[1].datatype)
     FOR (v_ind_col_loop = 2 TO v_ind_column_cnt)
       SET v_table_create_parser = concat(v_table_create_parser,", ",b_ind_columns->columns[
        v_ind_col_loop].columnname," ",b_ind_columns->columns[v_ind_col_loop].datatype)
     ENDFOR
     SET v_table_create_parser = concat(v_table_create_parser,") on commit preserve rows ^) go")
     IF (validate(request->debug_mode,"Z") != "Z")
      CALL echo(concat("GTMP create table statement: ",v_table_create_parser))
     ENDIF
     CALL parser(v_table_create_parser)
     SET v_temp_proc_name = build("dm_prg_proc_",cnvtstring(jobs->data[job_ndx].template_nbr),"_",
      curtime)
     SET v_insert_stmt = concat("rdb asis(^ create or replace procedure ",v_temp_proc_name,
      "(p_result out number, p_rowid in varchar2) as begin"," execute immediate 'insert into ",
      v_temp_table_name,
      " (",b_ind_columns->columns[1].columnname)
     FOR (v_ind_col_loop = 2 TO v_ind_column_cnt)
       SET v_insert_stmt = concat(v_insert_stmt,", ",b_ind_columns->columns[v_ind_col_loop].
        columnname)
     ENDFOR
     SET v_insert_stmt = concat(v_insert_stmt,") (select ",b_ind_columns->columns[1].columnname)
     FOR (v_ind_col_loop = 2 TO v_ind_column_cnt)
       SET v_insert_stmt = concat(v_insert_stmt,", ",b_ind_columns->columns[v_ind_col_loop].
        columnname)
     ENDFOR
     SET v_insert_stmt = concat(v_insert_stmt," from ",b_reply->table_name,
      " where rowid = CHARTOROWID(:row_id))' using p_rowid;  p_result := SQL%ROWCOUNT; end; ^)go")
     IF (validate(request->debug_mode,"Z") != "Z")
      CALL echo(concat("GTMP insert procedure: ",v_insert_stmt))
     ENDIF
     CALL parser(v_insert_stmt)
     SET v_truncate_stmt = concat("rdb asis(^ truncate table ",v_temp_table_name," ^) go")
    ENDIF
    SET stat = alterlist(stmt->tabs,v_num_tabs)
    SET stmt->tabs[v_num_tabs].child_table = b_reply->table_name
    SET stmt->tabs[v_num_tabs].purge_type_flag = c_ptf_delete
    IF (v_use_batch_process_ind=1)
     SET stmt->tabs[v_num_tabs].where_sub_str = concat("from ",trim(b_reply->table_name,3)," where (",
      b_ind_columns->columns[1].columnname)
     FOR (v_ind_col_loop = 2 TO v_ind_column_cnt)
       SET stmt->tabs[v_num_tabs].where_sub_str = concat(stmt->tabs[v_num_tabs].where_sub_str,",",
        b_ind_columns->columns[v_ind_col_loop].columnname)
     ENDFOR
     SET stmt->tabs[v_num_tabs].where_sub_str = concat(stmt->tabs[v_num_tabs].where_sub_str,
      ") IN (select ",b_ind_columns->columns[1].columnname)
     FOR (v_ind_col_loop = 2 TO v_ind_column_cnt)
       SET stmt->tabs[v_num_tabs].where_sub_str = concat(stmt->tabs[v_num_tabs].where_sub_str,",",
        b_ind_columns->columns[v_ind_col_loop].columnname)
     ENDFOR
     SET stmt->tabs[v_num_tabs].where_sub_str = concat(stmt->tabs[v_num_tabs].where_sub_str," from ",
      v_temp_table_name,")")
     SET stmt->tabs[v_num_tabs].where_str = concat("(",b_ind_columns->columns[1].columnname)
     FOR (v_ind_col_loop = 2 TO v_ind_column_cnt)
       SET stmt->tabs[v_num_tabs].where_str = concat(stmt->tabs[v_num_tabs].where_str,",",
        b_ind_columns->columns[v_ind_col_loop].columnname)
     ENDFOR
     SET stmt->tabs[v_num_tabs].where_str = concat(stmt->tabs[v_num_tabs].where_str,") IN (select ",
      b_ind_columns->columns[1].columnname)
     FOR (v_ind_col_loop = 2 TO v_ind_column_cnt)
       SET stmt->tabs[v_num_tabs].where_str = concat(stmt->tabs[v_num_tabs].where_str,",",
        b_ind_columns->columns[v_ind_col_loop].columnname)
     ENDFOR
     SET stmt->tabs[v_num_tabs].where_str = concat(stmt->tabs[v_num_tabs].where_str," from ",
      v_temp_table_name,")")
    ELSE
     SET stmt->tabs[v_num_tabs].where_sub_str = concat("from ",trim(b_reply->table_name,3),
      " where rowid = ':rowid:'")
     SET stmt->tabs[v_num_tabs].where_str = "rowid = ':rowid:'"
    ENDIF
    IF (validate(request->debug_mode,"Z") != "Z")
     CALL echo("WHERE clause to be used by children tables:")
     CALL echo(stmt->tabs[v_num_tabs].where_sub_str)
     CALL echo(" ")
     CALL echo("WHERE clause to be used by this table:")
     CALL echo(stmt->tabs[v_num_tabs].where_str)
     IF (v_use_batch_process_ind=1)
      CALL echo("DEBUG: Batch processing is in use")
     ELSE
      CALL echo("DEBUG: ROWID purging is in use")
     ENDIF
    ENDIF
    WHILE (v_num_tabs >= v_cur_tab)
     SELECT INTO "nl:"
      pt.parent_table, pt.child_table, pt.child_table,
      pt.purge_type_flag, child_where = concat(" and ",trim(pt.child_where,3)), pt.parent_col1,
      pt.child_col1, parent_col2 = concat(",",trim(pt.parent_col2,3)), child_col2 = concat(",",trim(
        pt.child_col2,3)),
      parent_col3 = concat(",",trim(pt.parent_col3,3)), child_col3 = concat(",",trim(pt.child_col3,3)
       ), parent_col4 = concat(",",trim(pt.parent_col4,3)),
      child_col4 = concat(",",trim(pt.child_col4,3)), parent_col5 = concat(",",trim(pt.parent_col5,3)
       ), child_col5 = concat(",",trim(pt.child_col5,3))
      FROM dm_purge_table pt
      WHERE (pt.parent_table=stmt->tabs[v_cur_tab].child_table)
       AND (pt.template_nbr=jobs->data[job_ndx].template_nbr)
       AND pt.child_table > " "
       AND (pt.schema_dt_tm=
      (SELECT
       max(pt1.schema_dt_tm)
       FROM dm_purge_table pt1
       WHERE pt1.template_nbr=pt.template_nbr))
       AND pt.purge_type_flag IN (1, 2)
      DETAIL
       v_num_tabs = (v_num_tabs+ 1), stat = alterlist(stmt->tabs,v_num_tabs), v_parent_col_str =
       concat(trim(pt.parent_col1,3),evaluate(parent_col2,","," ",trim(parent_col2,3)),evaluate(
         parent_col3,","," ",trim(parent_col3,3)),evaluate(parent_col4,","," ",trim(parent_col4,3)),
        evaluate(parent_col5,","," ",trim(parent_col5,3))),
       v_child_col_str = concat(trim(pt.child_col1,3),evaluate(child_col2,","," ",trim(child_col2,3)),
        evaluate(child_col3,","," ",trim(child_col3,3)),evaluate(child_col4,","," ",trim(child_col4,3
          )),evaluate(child_col5,","," ",trim(child_col5,3)))
       IF (pt.purge_type_flag=c_ptf_update)
        stmt->tabs[v_num_tabs].child_col1 = pt.child_col1, stmt->tabs[v_num_tabs].child_col2 = pt
        .child_col2, stmt->tabs[v_num_tabs].child_col3 = pt.child_col3,
        stmt->tabs[v_num_tabs].child_col4 = pt.child_col4, stmt->tabs[v_num_tabs].child_col5 = pt
        .child_col5
       ENDIF
       stmt->tabs[v_num_tabs].where_str = build_where(trim(v_child_col_str,3),trim(v_parent_col_str,3
         ),stmt->tabs[v_cur_tab].where_sub_str,child_where)
       IF (v_use_batch_process_ind=1)
        stmt->tabs[v_num_tabs].where_sub_str = concat(" from ",trim(pt.child_table,3)," where ",trim(
          stmt->tabs[v_num_tabs].where_str,3))
       ELSE
        stmt->tabs[v_num_tabs].where_sub_str = concat(" from ",trim(pt.child_table,3)," where list ",
         trim(stmt->tabs[v_num_tabs].where_str,3))
       ENDIF
       stmt->tabs[v_num_tabs].parent_table = pt.parent_table, stmt->tabs[v_num_tabs].child_table = pt
       .child_table, stmt->tabs[v_num_tabs].purge_type_flag = pt.purge_type_flag
      WITH nocounter
     ;end select
     SET v_cur_tab = (v_cur_tab+ 1)
    ENDWHILE
    FOR (tab_ndx = 1 TO size(stmt->tabs,5))
     IF (((tab_ndx=1) OR (v_use_batch_process_ind=1)) )
      SET v_list_str = " "
     ELSE
      SET v_list_str = "list"
     ENDIF
     IF ((stmt->tabs[tab_ndx].purge_type_flag=c_ptf_delete))
      SET stmt->tabs[tab_ndx].stmt = build_delete(trim(stmt->tabs[tab_ndx].child_table,3),trim(stmt->
        tabs[tab_ndx].where_str,3),trim(v_list_str,3))
     ELSEIF ((stmt->tabs[tab_ndx].purge_type_flag=c_ptf_update))
      SET stmt->tabs[tab_ndx].stmt = build_update(trim(stmt->tabs[tab_ndx].child_table,3),trim(stmt->
        tabs[tab_ndx].where_str,3),trim(stmt->tabs[tab_ndx].child_col1,3),trim(stmt->tabs[tab_ndx].
        child_col2,3),trim(stmt->tabs[tab_ndx].child_col3,3),
       trim(stmt->tabs[tab_ndx].child_col4,3),trim(stmt->tabs[tab_ndx].child_col5,3),trim(v_list_str,
        3))
     ENDIF
    ENDFOR
    SET v_tot_child_rows = 0
    SET v_err_found = 0
    IF (validate(request->debug_mode,"Z") != "Z")
     IF ((request->debug_mode="ONEROW"))
      SET v_num_rows = 1
     ENDIF
    ENDIF
    SET parser_child->next_row_to_purge = 1
    WHILE ((parser_child->next_row_to_purge <= v_num_rows))
      IF (v_use_batch_process_ind=1)
       IF (dpd_modact_allowed_ind)
        CALL set_module(concat("DMPURGE:",cnvtstring(jobs->data[job_ndx].template_nbr)),concat(
          "CHDBAT:",cnvtstring(v_log_id)))
       ENDIF
       EXECUTE dm_purge_data_child_batch  WITH replace("ROW_DATA","B_REPLY"), replace("TAB_LIST",
        "STMT")
      ELSE
       IF (dpd_modact_allowed_ind)
        CALL set_module(concat("DMPURGE:",cnvtstring(jobs->data[job_ndx].template_nbr)),concat(
          "CHPAR:",cnvtstring(v_log_id)))
       ENDIF
       EXECUTE dm_purge_data_child_parser  WITH replace("ROW_DATA","B_REPLY"), replace("TAB_LIST",
        "STMT")
      ENDIF
    ENDWHILE
    IF (dpd_modact_allowed_ind)
     CALL set_module(concat("DMPURGE:",cnvtstring(jobs->data[job_ndx].template_nbr)),concat("CH:",
       cnvtstring(v_log_id)))
    ENDIF
    IF (v_err_found=0)
     IF (v_rows_to_purge_flag=1)
      SET v_errmsg = concat(
       "There are additional rows remaining that can be purged.  If you have not already, and you ",
       "have sufficient resources, you may want to schedule additional purge jobs in order to purge ",
       "these remaining rows.")
      SET i18nhandle = 0
      SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
      SET v_errmsg = uar_i18ngetmessage(i18nhandle,"ROWSPURGEFLAG1",v_errmsg)
      SET b_reply->err_msg = v_errmsg
     ELSEIF (v_rows_to_purge_flag=2)
      SET v_errmsg = concat(
       "There are additional rows remaining that can be purged, but not all of the requested rows ",
       "could be purged at this time.  No errors have occurred.  You may want to schedule additional ",
       "purge jobs in order to purge these remaining rows.")
      SET i18nhandle = 0
      SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
      SET v_errmsg = uar_i18ngetmessage(i18nhandle,"ROWSPURGEFLAG2",v_errmsg)
      SET b_reply->err_msg = v_errmsg
     ENDIF
     IF (batch_ndx=1)
      INSERT  FROM dm_purge_job_log jl
       SET jl.log_id = v_log_id, jl.job_id = jobs->data[job_ndx].job_id, jl.purge_flag = jobs->data[
        job_ndx].purge_flag,
        jl.start_dt_tm = cnvtdatetime(v_start_date), jl.end_dt_tm = cnvtdatetime(curdate,curtime3),
        jl.parent_table = b_reply->table_name,
        jl.parent_rows = stmt->tabs[1].num_found, jl.child_rows = v_tot_child_rows, jl.err_msg =
        b_reply->err_msg,
        jl.err_code = 0, jl.updt_dt_tm = cnvtdatetime(curdate,curtime3), jl.updt_task = reqinfo->
        updt_task,
        jl.updt_cnt = 0, jl.updt_id = reqinfo->updt_id, jl.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      COMMIT
      INSERT  FROM dm_purge_job_log_timing jlt
       SET jlt.job_log_timing_id = seq(dm_clinical_seq,nextval), jlt.log_id = v_log_id, jlt.value_key
         = v_logging_rowid_key,
        jlt.value_nbr = v_rowid_collect_runtime, jlt.updt_applctx = reqinfo->updt_applctx, jlt
        .updt_cnt = 0,
        jlt.updt_dt_tm = cnvtdatetime(curdate,curtime3), jlt.updt_id = reqinfo->updt_id, jlt
        .updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      COMMIT
     ELSE
      UPDATE  FROM dm_purge_job_log jl
       SET jl.job_id = jobs->data[job_ndx].job_id, jl.purge_flag = jobs->data[job_ndx].purge_flag, jl
        .start_dt_tm = cnvtdatetime(v_start_date),
        jl.end_dt_tm = cnvtdatetime(curdate,curtime3), jl.parent_table = b_reply->table_name, jl
        .parent_rows = (jl.parent_rows+ stmt->tabs[1].num_found),
        jl.child_rows = (jl.child_rows+ v_tot_child_rows), jl.err_msg = b_reply->err_msg, jl.err_code
         = 0,
        jl.updt_dt_tm = cnvtdatetime(curdate,curtime3), jl.updt_task = reqinfo->updt_task, jl
        .updt_cnt = 0,
        jl.updt_id = reqinfo->updt_id, jl.updt_applctx = reqinfo->updt_applctx
       WHERE jl.log_id=v_log_id
       WITH nocounter
      ;end update
      COMMIT
      UPDATE  FROM dm_purge_job_log_timing jlt
       SET jlt.value_nbr = (jlt.value_nbr+ v_rowid_collect_runtime), jlt.updt_applctx = reqinfo->
        updt_applctx, jlt.updt_cnt = (jlt.updt_cnt+ 1),
        jlt.updt_dt_tm = cnvtdatetime(curdate,curtime3), jlt.updt_id = reqinfo->updt_id, jlt
        .updt_task = reqinfo->updt_task
       WHERE jlt.log_id=v_log_id
        AND jlt.value_key=v_logging_rowid_key
       WITH nocounter
      ;end update
      COMMIT
     ENDIF
     IF ((jobs->data[job_ndx].purge_flag != c_audit))
      FOR (tab_ndx = 1 TO size(stmt->tabs,5))
        UPDATE  FROM dm_purge_job_log_tab jlt
         SET jlt.num_rows = (jlt.num_rows+ stmt->tabs[tab_ndx].num_found), jlt.updt_dt_tm =
          cnvtdatetime(curdate,curtime3), jlt.updt_task = reqinfo->updt_task,
          jlt.updt_cnt = (jlt.updt_cnt+ 1), jlt.updt_id = reqinfo->updt_id, jlt.updt_applctx =
          reqinfo->updt_applctx
         WHERE jlt.log_id=v_log_id
          AND (jlt.table_name=stmt->tabs[tab_ndx].child_table)
        ;end update
        IF (curqual=0)
         INSERT  FROM dm_purge_job_log_tab jlt
          SET jlt.log_id = v_log_id, jlt.table_name = stmt->tabs[tab_ndx].child_table, jlt.purge_flag
            = jobs->data[job_ndx].purge_flag,
           jlt.job_id = jobs->data[job_ndx].job_id, jlt.num_rows = stmt->tabs[tab_ndx].num_found, jlt
           .updt_dt_tm = cnvtdatetime(curdate,curtime3),
           jlt.updt_task = reqinfo->updt_task, jlt.updt_cnt = 0, jlt.updt_id = reqinfo->updt_id,
           jlt.updt_applctx = reqinfo->updt_applctx
         ;end insert
        ENDIF
        COMMIT
        UPDATE  FROM dm_purge_job_log_timing jlt
         SET jlt.value_nbr = (jlt.value_nbr+ stmt->tabs[tab_ndx].purge_runtime), jlt.updt_applctx =
          reqinfo->updt_applctx, jlt.updt_cnt = (jlt.updt_cnt+ 1),
          jlt.updt_dt_tm = cnvtdatetime(curdate,curtime3), jlt.updt_id = reqinfo->updt_id, jlt
          .updt_task = reqinfo->updt_task
         WHERE jlt.log_id=v_log_id
          AND jlt.value_key=concat(v_logging_purge_prefix,stmt->tabs[tab_ndx].child_table)
         WITH nocounter
        ;end update
        IF (curqual=0)
         INSERT  FROM dm_purge_job_log_timing jlt
          SET jlt.job_log_timing_id = seq(dm_clinical_seq,nextval), jlt.log_id = v_log_id, jlt
           .value_key = concat(v_logging_purge_prefix,stmt->tabs[tab_ndx].child_table),
           jlt.value_nbr = stmt->tabs[tab_ndx].purge_runtime, jlt.updt_applctx = reqinfo->
           updt_applctx, jlt.updt_cnt = 0,
           jlt.updt_dt_tm = cnvtdatetime(curdate,curtime3), jlt.updt_id = reqinfo->updt_id, jlt
           .updt_task = reqinfo->updt_task
          WITH nocounter
         ;end insert
        ENDIF
        COMMIT
      ENDFOR
     ENDIF
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpdc_run_check(drc_template_nbr)
   DECLARE drc_run_ind = i2 WITH noconstant(0)
   DECLARE drc_run_appl_id = f8 WITH noconstant(0.0)
   DECLARE drc_cnt = i4 WITH noconstant(0)
   DECLARE drc_search_str = vc WITH protect, constant(build2("*; template_nbr = ",trim(cnvtstring(
       drc_template_nbr),7),".*"))
   FREE RECORD drc_sess_ids
   RECORD drc_sess_ids(
     1 list[*]
       2 session_id = f8
   )
   IF (validate(request->debug_mode,"Z") != "Z")
    CALL echo(build("Checking if template ",drc_template_nbr,
      " is currently running outside of this session: ",currdbhandle,"."))
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM PURGE INFO"
     AND di.info_char=patstring(drc_search_str)
     AND di.info_long_id != cnvtreal(currdbhandle)
     AND di.info_long_id > 0.0
    DETAIL
     drc_cnt = (drc_cnt+ 1)
     IF (mod(drc_cnt,10)=1)
      stat = alterlist(drc_sess_ids->list,(drc_cnt+ 9))
     ENDIF
     drc_sess_ids->list[drc_cnt].session_id = di.info_long_id, drc_run_appl_id = di.info_long_id
    WITH nocounter
   ;end select
   SET stat = alterlist(drc_sess_ids->list,drc_cnt)
   IF (size(drc_sess_ids->list,5) > 0)
    IF (validate(request->debug_mode,"Z") != "Z")
     CALL echo(build("Found potential  active run rows for ",drc_template_nbr,
       ". Checking if sessions are still active."))
    ENDIF
    DECLARE idx = i4 WITH protect, noconstant(0)
    SET drc_cnt = 0
    SELECT INTO "nl:"
     FROM gv$session g
     WHERE expand(idx,1,size(drc_sess_ids->list,5),g.audsid,drc_sess_ids->list[idx].session_id)
      AND g.audsid > 0
     WITH nocounter
    ;end select
    IF (curqual > 0)
     IF (validate(request->debug_mode,"Z") != "Z")
      CALL echo(build("Found active run row for ",drc_template_nbr,"."))
     ENDIF
     SET drc_run_ind = 1
    ELSE
     UPDATE  FROM dm_info di
      SET di.info_long_id = 0.0
      WHERE di.info_domain="DM PURGE INFO"
       AND di.info_char=patstring(drc_search_str)
       AND di.info_long_id != cnvtreal(currdbhandle)
       AND di.info_long_id > 0.0
      WITH nocounter
     ;end update
     COMMIT
    ENDIF
   ENDIF
   RETURN(drc_run_ind)
 END ;Subroutine
#exit_script
 FREE RECORD b_ind_columns
 IF (v_use_batch_process_ind=1)
  SELECT INTO "nl:"
   FROM product_component_version p
   WHERE cnvtupper(p.product)="ORACLE*"
   DETAIL
    v_oracle_version = cnvtint(substring(1,findstring(".",p.version,1,0),p.version))
   WITH nocounter
  ;end select
  IF ((jobs->data[job_ndx].purge_flag != c_audit))
   CALL parser(v_truncate_stmt)
  ENDIF
  IF (v_oracle_version >= 10)
   CALL parser(concat("rdb asis(^ drop table ",v_temp_table_name," purge ^) go"))
  ELSE
   CALL parser(concat("rdb asis(^ drop table ",v_temp_table_name," ^) go"))
  ENDIF
  IF (validate(request->debug_mode,"Z") != "Z")
   CALL echo(concat("rdb asis(^ drop procedure ",v_temp_proc_name," ^) go"))
  ENDIF
  CALL parser(concat("rdb asis(^ drop procedure ",v_temp_proc_name," ^) go"))
 ENDIF
 IF (dpd_modact_allowed_ind)
  CALL set_module(dpdc_original_module,dpdc_original_action)
 ENDIF
END GO

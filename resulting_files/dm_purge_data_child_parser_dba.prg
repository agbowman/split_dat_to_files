CREATE PROGRAM dm_purge_data_child_parser:dba
 DECLARE output_plan(i_statement_id=vc,i_file=vc,i_debug_str=vc) = null
 DECLARE sbr_fetch_starting_id(null) = f8
 DECLARE sbr_update_starting_id(sbr_newid=f8) = null
 DECLARE sbr_delete_starting_id(null) = null
 DECLARE sbr_getrowidnotexists(sbr_whereclause=vc,sbr_tablealias=vc) = vc
 SUBROUTINE output_plan(i_statement_id,i_file,i_debug_str)
   CALL echo(i_file)
   SELECT INTO value(i_file)
    x = substring(1,100,i_debug_str)
    FROM dual
    DETAIL
     x
    WITH maxcol = 130
   ;end select
   FOR (i = 2 TO ceil((size(i_debug_str)/ 100.0)))
     SELECT INTO value(i_file)
      x = substring((1+ ((i - 1) * 100)),100,i_debug_str)
      FROM dual
      DETAIL
       x
      WITH maxcol = 130, append
     ;end select
   ENDFOR
   SELECT INTO value(i_file)
    x = fillstring(100,"=")
    FROM dual
    DETAIL
     x
    WITH maxcol = 130, append
   ;end select
   SELECT INTO value(i_file)
    dm_ind = nullind(dm.index_name), p.statement_id, p.id,
    p.parent_id, p.position, p.operation,
    p.options, p.object_name, dm.table_name,
    dm.index_name, dm.column_position, dm.uniqueness,
    colname = substring(1,30,dm.column_name)
    FROM plan_table p,
     dm_user_ind_columns dm
    PLAN (p
     WHERE p.statement_id=patstring(i_statement_id))
     JOIN (dm
     WHERE outerjoin(p.object_name)=dm.index_name)
    ORDER BY p.statement_id, p.id, dm.index_name,
     dm.column_position
    HEAD REPORT
     indent = 0, line = fillstring(100,"=")
    HEAD p.statement_id
     "PLAN STATEMENT FOR ", p.statement_id, row + 1,
     line, row + 1, indent = 0
    HEAD p.id
     indent = (indent+ 1), col 0, p.id"#####",
     col + 1, col + indent, indent"###",
     ")", p.operation, col + 1,
     p.options, col + 1, p.object_name,
     col + 1
    DETAIL
     IF (dm_ind=0)
      IF (dm.column_position=1)
       row + 1, col + (indent+ 10), ">>>",
       col + 1, dm.uniqueness, col + 1
      ELSE
       ","
      ENDIF
      CALL print(trim(colname))
     ENDIF
    FOOT  p.id
     row + 1
    WITH nocounter, maxrow = 1, noformfeed,
     maxcol = 400, append
   ;end select
 END ;Subroutine
 SUBROUTINE sbr_fetch_starting_id(null)
   DECLARE sbr_startingid = f8 WITH protect, noconstant(1.0)
   DECLARE sbr_infoname = vc WITH protect, noconstant("")
   IF (batch_ndx=1)
    RETURN(1.0)
   ENDIF
   SET sbr_infoname = concat(trim(cnvtstring(jobs->data[job_ndx].template_nbr),3)," - ",trim(
     cnvtstring(v_log_id),3))
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM PURGE RESUME"
     AND di.info_name=sbr_infoname
    DETAIL
     sbr_startingid = di.info_long_id
    WITH nocounter
   ;end select
   RETURN(sbr_startingid)
 END ;Subroutine
 SUBROUTINE sbr_update_starting_id(sbr_newid)
   DECLARE sbr_infoname = vc WITH protect, noconstant("")
   SET sbr_infoname = concat(trim(cnvtstring(jobs->data[job_ndx].template_nbr),3)," - ",trim(
     cnvtstring(v_log_id),3))
   UPDATE  FROM dm_info di
    SET di.info_long_id = sbr_newid, di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     di.updt_cnt = (di.updt_cnt+ 1), di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
    WHERE di.info_domain="DM PURGE RESUME"
     AND di.info_name=sbr_infoname
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM PURGE RESUME", di.info_name = sbr_infoname, di.info_long_id = sbr_newid,
      di.info_date = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx, di
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      di.updt_cnt = 0, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ENDIF
   COMMIT
 END ;Subroutine
 SUBROUTINE sbr_delete_starting_id(null)
   DECLARE sbr_infoname = vc WITH protect, noconstant("")
   SET sbr_infoname = concat(trim(cnvtstring(jobs->data[job_ndx].template_nbr),3)," - ",trim(
     cnvtstring(v_log_id),3))
   DELETE  FROM dm_info di
    WHERE di.info_domain="DM PURGE RESUME"
     AND di.info_name=sbr_infoname
    WITH nocounter
   ;end delete
   COMMIT
 END ;Subroutine
 SUBROUTINE sbr_getrowidnotexists(sbr_whereclause,sbr_tablealias)
   IF ((jobs->data[job_ndx].purge_flag != c_audit))
    RETURN(sbr_whereclause)
   ENDIF
   DECLARE sbr_newwhereclause = vc WITH protect, noconstant("")
   SET sbr_newwhereclause = concat(sbr_whereclause,
    " and NOT EXISTS (select rowidtbl.purge_table_rowid ","from dm_purge_rowid_list_gttp rowidtbl ",
    "where rowidtbl.purge_table_rowid = ",sbr_tablealias,
    ".rowid)")
   RETURN(sbr_newwhereclause)
 END ;Subroutine
 DECLARE dpdcp_loop_cnt = i4 WITH noconstant(1), protect
 DECLARE dpdcp_purge_start = dq8 WITH protect, noconstant(0.0)
 DECLARE dpdcp_purge_runtime = f8 WITH protect, noconstant(0.0)
 DECLARE v_debug_str = vc WITH protect, noconstant("")
 DECLARE v_statement_id = vc WITH protect, noconstant("")
 DECLARE v_file = vc WITH protect, noconstant("")
 DECLARE dpdcp_row_id = vc WITH protect, noconstant("")
 DECLARE output_plan(i_statement_id=vc,i_file=vc,i_debug_str=vc) = null
 WHILE ((dpdcp_loop_cnt <= parser_child->max_parser_cnt)
  AND (parser_child->next_row_to_purge <= v_num_rows))
   SET v_tab_ndx = size(tab_list->tabs,5)
   WHILE (v_tab_ndx >= 1)
     SET dpdcp_purge_start = cnvtdatetime(curdate,curtime3)
     SET v_num_found = 0
     IF ((jobs->data[job_ndx].purge_flag=c_audit))
      IF (validate(request->debug_mode,"Z") != "Z")
       SET v_debug_str = tab_list->tabs[v_tab_ndx].stmt
       SET v_statement_id = concat(curuser,"*")
       SET v_file = concat("dm_purge_data_",trim(cnvtstring(jobs->data[job_ndx].job_id),3),"_",trim(
         cnvtstring(v_tab_ndx),3),".txt")
       DELETE  FROM plan_table p
        WHERE p.statement_id=patstring(v_statement_id)
       ;end delete
       CALL echo(concat(trim(v_debug_str,3)," with test, rdbplan go"))
       CALL parser(concat(trim(v_debug_str,3)," with test, rdbplan go"))
       CALL output_plan(v_statement_id,v_file,v_debug_str)
      ENDIF
      IF (v_tab_ndx=1)
       SET v_num_found = 1
      ELSE
       SET v_num_found = 0
      ENDIF
     ELSE
      SET dpdcp_row_id = trim(row_data->rows[parser_child->next_row_to_purge].row_id,3)
      SET v_str = replace(trim(tab_list->tabs[v_tab_ndx].stmt,3),"':rowid:'","dpdcp_row_id",0)
      IF (validate(request->debug_mode,"Z") != "Z")
       CALL echo(concat("Generated query: ",trim(v_str,3)," go"))
      ENDIF
      CALL parser(concat(trim(v_str,3)," go"))
      SET v_num_found = curqual
      SET dpdcp_purge_runtime = datetimediff(cnvtdatetime(curdate,curtime3),dpdcp_purge_start,4)
      SET tab_list->tabs[v_tab_ndx].purge_runtime = (tab_list->tabs[v_tab_ndx].purge_runtime+
      dpdcp_purge_runtime)
     ENDIF
     SET v_errmsg = fillstring(132," ")
     SET v_err_code = 0
     SET v_err_code = error(v_errmsg,1)
     IF (v_err_code != 0)
      GO TO handle_error
     ELSE
      SET tab_list->tabs[v_tab_ndx].num_found = (tab_list->tabs[v_tab_ndx].num_found+ v_num_found)
      IF (v_tab_ndx != 1)
       SET v_tot_child_rows = (v_tot_child_rows+ v_num_found)
      ENDIF
      SET v_tab_ndx = (v_tab_ndx - 1)
     ENDIF
   ENDWHILE
   IF ((jobs->data[job_ndx].purge_flag != c_audit)
    AND v_err_found=0
    AND mod(parser_child->next_row_to_purge,row_data->rows_between_commit)=0)
    COMMIT
   ENDIF
   SET dpdcp_loop_cnt = (dpdcp_loop_cnt+ 1)
   SET parser_child->next_row_to_purge = (parser_child->next_row_to_purge+ 1)
 ENDWHILE
 IF ((jobs->data[job_ndx].purge_flag=c_audit)
  AND (parser_child->next_row_to_purge >= v_num_rows))
  INSERT  FROM dm_purge_rowid_list_gttp gt,
    (dummyt d  WITH seq = value(v_num_rows))
   SET gt.purge_table_rowid = row_data->rows[d.seq].row_id
   PLAN (d)
    JOIN (gt)
   WITH nocounter
  ;end insert
  SET v_errmsg = fillstring(132," ")
  SET v_err_code = 0
  SET v_err_code = error(v_errmsg,1)
  IF (v_err_code != 0)
   GO TO handle_error
  ELSE
   COMMIT
  ENDIF
 ENDIF
 GO TO exit_script
#handle_error
 SET tab_list->tabs[1].num_found = (parser_child->next_row_to_purge - 1)
 SET parser_child->next_row_to_purge = (v_num_rows+ 1)
 SET v_num_rows_remaining = 0
 SET v_tab_ndx = 0
 SET v_err_found = 1
 ROLLBACK
 IF (batch_ndx=1)
  INSERT  FROM dm_purge_job_log jl
   SET jl.log_id = v_log_id, jl.job_id = jobs->data[job_ndx].job_id, jl.purge_flag = jobs->data[
    job_ndx].purge_flag,
    jl.start_dt_tm = cnvtdatetime(v_start_date), jl.end_dt_tm = cnvtdatetime(curdate,curtime3), jl
    .parent_table = row_data->table_name,
    jl.parent_rows = tab_list->tabs[1].num_found, jl.child_rows = v_tot_child_rows, jl.err_msg =
    v_errmsg,
    jl.err_code = v_err_code, jl.updt_dt_tm = cnvtdatetime(curdate,curtime3), jl.updt_task = reqinfo
    ->updt_task,
    jl.updt_cnt = 0, jl.updt_id = reqinfo->updt_id, jl.updt_applctx = reqinfo->updt_applctx
  ;end insert
 ELSE
  UPDATE  FROM dm_purge_job_log jl
   SET jl.job_id = jobs->data[job_ndx].job_id, jl.purge_flag = jobs->data[job_ndx].purge_flag, jl
    .start_dt_tm = cnvtdatetime(v_start_date),
    jl.end_dt_tm = cnvtdatetime(curdate,curtime3), jl.parent_table = row_data->table_name, jl
    .parent_rows = (jl.parent_rows+ tab_list->tabs[1].num_found),
    jl.child_rows = (jl.child_rows+ v_tot_child_rows), jl.err_msg = v_errmsg, jl.err_code =
    v_err_code,
    jl.updt_dt_tm = cnvtdatetime(curdate,curtime3), jl.updt_task = reqinfo->updt_task, jl.updt_cnt =
    0,
    jl.updt_id = reqinfo->updt_id, jl.updt_applctx = reqinfo->updt_applctx
   WHERE jl.log_id=v_log_id
  ;end update
 ENDIF
 IF ((jobs->data[job_ndx].purge_flag != c_audit))
  FOR (tab_ndx = 1 TO size(tab_list->tabs,5))
    UPDATE  FROM dm_purge_job_log_tab jlt
     SET jlt.num_rows = (jlt.num_rows+ tab_list->tabs[tab_ndx].num_found), jlt.updt_dt_tm =
      cnvtdatetime(curdate,curtime3), jlt.updt_task = reqinfo->updt_task,
      jlt.updt_cnt = (jlt.updt_cnt+ 1), jlt.updt_id = reqinfo->updt_id, jlt.updt_applctx = reqinfo->
      updt_applctx
     WHERE jlt.log_id=v_log_id
      AND (jlt.table_name=tab_list->tabs[tab_ndx].child_table)
    ;end update
    IF (curqual=0)
     INSERT  FROM dm_purge_job_log_tab jlt
      SET jlt.log_id = v_log_id, jlt.table_name = tab_list->tabs[tab_ndx].child_table, jlt.purge_flag
        = jobs->data[job_ndx].purge_flag,
       jlt.job_id = jobs->data[job_ndx].job_id, jlt.num_rows = tab_list->tabs[tab_ndx].num_found, jlt
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       jlt.updt_task = reqinfo->updt_task, jlt.updt_cnt = 0, jlt.updt_id = reqinfo->updt_id,
       jlt.updt_applctx = reqinfo->updt_applctx
     ;end insert
    ENDIF
    UPDATE  FROM dm_purge_job_log_timing jlt
     SET jlt.value_nbr = (jlt.value_nbr+ tab_list->tabs[tab_ndx].purge_runtime), jlt.updt_applctx =
      reqinfo->updt_applctx, jlt.updt_cnt = (jlt.updt_cnt+ 1),
      jlt.updt_dt_tm = cnvtdatetime(curdate,curtime3), jlt.updt_id = reqinfo->updt_id, jlt.updt_task
       = reqinfo->updt_task
     WHERE jlt.log_id=v_log_id
      AND jlt.value_key=concat(v_logging_purge_prefix,tab_list->tabs[tab_ndx].child_table)
     WITH nocounter
    ;end update
    IF (curqual=0)
     INSERT  FROM dm_purge_job_log_timing jlt
      SET jlt.job_log_timing_id = seq(dm_clinical_seq,nextval), jlt.log_id = v_log_id, jlt.value_key
        = concat(v_logging_purge_prefix,tab_list->tabs[tab_ndx].child_table),
       jlt.value_nbr = tab_list->tabs[tab_ndx].purge_runtime, jlt.updt_applctx = reqinfo->
       updt_applctx, jlt.updt_cnt = 0,
       jlt.updt_dt_tm = cnvtdatetime(curdate,curtime3), jlt.updt_id = reqinfo->updt_id, jlt.updt_task
        = reqinfo->updt_task
      WITH nocounter
     ;end insert
    ENDIF
  ENDFOR
  UPDATE  FROM dm_purge_job pj
   SET pj.last_run_dt_tm = cnvtdatetime(v_start_date), pj.last_run_status_flag = c_sf_failed
   WHERE (pj.job_id=jobs->data[job_ndx].job_id)
  ;end update
  COMMIT
 ENDIF
#exit_script
END GO

CREATE PROGRAM dm_dm_plan_rows:dba
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
 IF (validate(dpavc_version_domain,"Z")="Z")
  DECLARE dpavc_version_domain = vc WITH protect, constant("DM PURGE")
 ENDIF
 IF (validate(dpavc_version_name,"Z")="Z")
  DECLARE dpavc_version_name = vc WITH protect, constant("PURGE ARCHITECTURE VERSION")
 ENDIF
 DECLARE sbr_get_purge_archi_version(null) = f8
 SUBROUTINE sbr_get_purge_archi_version(null)
   DECLARE sgpav_version = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    di.info_number
    FROM dm_info di
    WHERE di.info_domain="DM PURGE"
     AND di.info_name="PURGE ARCHITECTURE VERSION"
    DETAIL
     sgpav_version = di.info_number
    WITH nocounter
   ;end select
   RETURN(sgpav_version)
 END ;Subroutine
 DECLARE c_mod = c10 WITH noconstant("DM_PRG_PLAN 002")
 DECLARE v_days_to_keep = i4 WITH noconstant(- (1))
 DECLARE v_days_between = i4 WITH noconstant(- (1))
 DECLARE v_days_to_keep_min = i4 WITH noconstant(14)
 DECLARE v_days_between_min = i4 WITH noconstant(1)
 DECLARE v_tablename = vc WITH noconstant("DM_PLAN")
 DECLARE v_errmsg2 = vc WITH noconstant(" ")
 DECLARE v_err_code2 = i2 WITH noconstant(0)
 DECLARE v_cnt = i2 WITH noconstant(0)
 DECLARE v_ndx = i2 WITH noconstant(0)
 DECLARE v_num_days = i2 WITH noconstant(0)
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE h = i4 WITH noconstant(0)
 DECLARE v_rows = i2 WITH noconstant(0)
 DECLARE v_table_exists_flag = i2 WITH noconstant(0)
 DECLARE v_user_tables = i2 WITH constant(2)
 DECLARE v_archi_version = f8 WITH protect, noconstant(sbr_get_purge_archi_version(null))
 DECLARE v_parser_stmt = vc WITH protect, noconstant("")
 IF (0=validate(true,0)
  AND 1=validate(true,1))
  DECLARE true = i2 WITH constant(1)
 ENDIF
 IF (0=validate(false,0)
  AND 1=validate(false,1))
  DECLARE false = i2 WITH constant(0)
 ENDIF
 SET reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SELECT INTO nl
  u.table_name
  FROM user_tables u
  WHERE u.table_name=v_tablename
  DETAIL
   v_table_exists_flag = v_user_tables
  WITH nocounter
 ;end select
 IF (v_table_exists_flag=v_user_tables)
  IF (checkdic(v_tablename,"T",0)=0)
   SET reply->err_code = 0
   SET reply->status_data.status = "S"
   SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"INF_TABLEEXISTANCE",
    "The table %1 does not exist in this environment.","s",nullterm(v_tablename))
   GO TO end_program
  ENDIF
 ENDIF
 SET v_cnt = size(request->tokens,5)
 FOR (v_ndx = 1 TO v_cnt)
   IF ((request->tokens[v_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = ceil(cnvtreal(request->tokens[v_ndx].value))
   ELSEIF ((request->tokens[v_ndx].token_str="DAYSBETWEEN"))
    SET v_days_between = ceil(cnvtreal(request->tokens[v_ndx].value))
   ENDIF
 ENDFOR
 IF ((v_days_to_keep != - (1))
  AND v_days_to_keep < v_days_to_keep_min)
  SET reply->status_data.status = "F"
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"ERR_DAYSTOKEEPMIN",
   "You must keep at least %1 days worth of data.  You entered %2 days or did not enter any value.",
   "ii",v_days_to_keep_min,
   v_days_to_keep)
  GO TO end_program
 ELSEIF ((v_days_between != - (1))
  AND v_days_between < v_days_between_min)
  SET reply->status_data.status = "F"
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"ERR_DAYSBETWEENMIN",
   "You must have at least %1 day/days between runs.  You entered %2 days or did not enter any value.",
   "ii",v_days_between_min,
   v_days_between)
  GO TO end_program
 ELSE
  SET v_num_days = floor(datetimediff(cnvtdatetime(curdate,curtime3),cnvtdatetime(cnvtdate2(substring
      (1,8,request->last_run_date),"YYYYMMDD"),cnvtint(substring(9,6,request->last_run_date)))))
  IF (v_num_days > 0
   AND v_num_days < v_days_between)
   SET reply->status_data.status = "K"
   GO TO end_program
  ELSE
   SET reply->table_name = v_tablename
   SET reply->rows_between_commit = minval(request->max_rows,10000)
   SET v_rows = 0
   IF (v_archi_version >= 2.0)
    SET v_parser_stmt = sbr_getrowidnotexists("dp.sql_stmt_id > 0","dp")
   ELSE
    SET v_parser_stmt = "dp.sql_stmt_id > 0"
   ENDIF
   SELECT INTO "nl:"
    dp.rowid
    FROM dm_plan dp
    WHERE dp.schema_date < cnvtdatetime((curdate - v_days_to_keep),curtime3)
     AND parser(v_parser_stmt)
    DETAIL
     v_rows = (v_rows+ 1)
     IF (mod(v_rows,50)=1)
      stat = alterlist(reply->rows,(v_rows+ 49))
     ENDIF
     reply->rows[v_rows].row_id = dp.rowid
    FOOT REPORT
     stat = alterlist(reply->rows,v_rows)
    WITH nocounter, maxqual(dp,value(request->max_rows))
   ;end select
   SET v_err_code2 = error(v_errmsg2,1)
   IF (v_err_code2=0)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "F"
    SET reply->err_code = v_err_code2
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"ERR_COLLECT",
     "Failed in row collection: %1","s",nullterm(v_errmsg2))
   ENDIF
  ENDIF
 ENDIF
#end_program
END GO

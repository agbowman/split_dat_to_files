CREATE PROGRAM dm_refchg_rtable_reset_rows:dba
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
 SET reply->status_data.status = "F"
 DECLARE v_days_to_keep = i4 WITH protect, noconstant(- (1))
 DECLARE v_token_idx = i4 WITH protect, noconstant(0)
 DECLARE v_rows = i4 WITH protect, noconstant(0)
 DECLARE v_errmsg2 = vc WITH protect, noconstant("")
 DECLARE v_err_code2 = i4 WITH protect, noconstant(0)
 DECLARE v_cur_env_id = f8 WITH protect, noconstant(0.0)
 DECLARE v_open_event_dt_tm = dq8 WITH protect, noconstant(0.0)
 DECLARE v_purge_dt_tm = dq8 WITH protect, noconstant(0.0)
 DECLARE v_parser_stmt = vc WITH protect, noconstant("")
 DECLARE v_archi_version = f8 WITH protect, noconstant(sbr_get_purge_archi_version(null))
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->table_name = "DM_REFCHG_RTABLE_RESET"
 SET reply->rows_between_commit = minval(10000,request->max_rows)
 FOR (v_token_idx = 1 TO size(request->tokens,5))
   IF ((request->tokens[v_token_idx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = ceil(cnvtreal(request->tokens[v_token_idx].value))
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 30)
  SET reply->status_data.status = "F"
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"DAYSTOKEEP",
   "You must keep at least 30 days worth of data.  You entered %1 days or did not enter any value.",
   "i",v_days_to_keep)
  GO TO exit_program
 ELSE
  SELECT INTO "NL:"
   FROM dm_info d
   WHERE d.info_name="DM_ENV_ID"
    AND d.info_domain="DATA MANAGEMENT"
   DETAIL
    v_cur_env_id = d.info_number
   WITH nocounter
  ;end select
  SET v_err_code2 = error(v_errmsg2,0)
  IF (v_err_code2 > 0)
   SET reply->status_data.status = "F"
   SET reply->err_code = v_err_code2
   SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"CURENVERROR",
    "Failed to retrieve current environment_id: %1","s",nullterm(v_errmsg2))
   GO TO exit_program
  ENDIF
  IF (v_cur_env_id <= 0)
   SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"CURENVVALIDERROR",
    "Current environment_id is invalid: %1","d",v_cur_env_id)
   GO TO exit_program
  ENDIF
  SELECT INTO "NL:"
   x = max(drel.event_dt_tm)
   FROM dm_rdds_event_log drel
   WHERE drel.rdds_event="Begin Reference Data Sync"
    AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
    AND drel.cur_environment_id=v_cur_env_id
    AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
   (SELECT
    drel2.cur_environment_id, drel2.paired_environment_id, drel2.event_reason
    FROM dm_rdds_event_log drel2
    WHERE drel2.cur_environment_id=v_cur_env_id
     AND drel2.rdds_event="End Reference Data Sync"
     AND drel2.rdds_event_key="ENDREFERENCEDATASYNC")))
   DETAIL
    v_open_event_dt_tm = cnvtdatetime(x)
   WITH nocounter
  ;end select
  SET v_err_code2 = error(v_errmsg2,0)
  IF (v_err_code2 > 0)
   SET reply->status_data.status = "F"
   SET reply->err_code = v_err_code2
   SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"OPENEVENTERROR",
    "Failed to retrieve open event date and time: %1","s",nullterm(v_errmsg2))
   GO TO exit_program
  ENDIF
  IF (v_open_event_dt_tm > 0.00)
   SET v_purge_dt_tm = cnvtdatetime(v_open_event_dt_tm)
  ELSE
   SET v_purge_dt_tm = cnvtdatetime((curdate - v_days_to_keep),curtime3)
  ENDIF
  IF (v_archi_version >= 2.0)
   SET v_parser_stmt = sbr_getrowidnotexists("drrr.dm_refchg_rtable_reset_id+0 > 0","drrr")
  ELSE
   SET v_parser_stmt = "drrr.dm_refchg_rtable_reset_id+0 > 0"
  ENDIF
  SELECT INTO "nl:"
   drrr.rowid
   FROM dm_refchg_rtable_reset drrr
   WHERE drrr.updt_dt_tm < cnvtdatetime(v_purge_dt_tm)
    AND parser(v_parser_stmt)
   DETAIL
    v_rows = (v_rows+ 1)
    IF (mod(v_rows,50)=1)
     stat = alterlist(reply->rows,(v_rows+ 49))
    ENDIF
    reply->rows[v_rows].row_id = drrr.rowid
   FOOT REPORT
    stat = alterlist(reply->rows,v_rows)
   WITH nocounter, maxqual(drrr,value(request->max_rows))
  ;end select
  SET v_err_code2 = error(v_errmsg2,0)
  IF (v_err_code2 > 0)
   SET reply->status_data.status = "F"
   SET reply->err_code = v_err_code2
   SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR",
    "Failed in row collection: %1","s",nullterm(v_errmsg2))
   GO TO exit_program
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#exit_program
END GO

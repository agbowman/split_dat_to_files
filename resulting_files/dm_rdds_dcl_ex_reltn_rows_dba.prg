CREATE PROGRAM dm_rdds_dcl_ex_reltn_rows:dba
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
 DECLARE v_err_code2 = i4 WITH protect, noconstant(0)
 DECLARE v_errmsg2 = vc WITH protect, noconstant("")
 DECLARE v_env_id = f8 WITH protect, noconstant(0.0)
 DECLARE v_dm_info_dt = f8 WITH protect, noconstant(0.0)
 DECLARE v_dm_info_number = f8 WITH protect, noconstant(0.0)
 DECLARE v_loop = i4 WITH protect, noconstant(0)
 DECLARE v_idx2 = i4 WITH protect, noconstant(0)
 DECLARE v_idx = i4 WITH protect, noconstant(0)
 DECLARE v_rows = i4 WITH protect, noconstant(0)
 DECLARE v_max = i4 WITH protect, noconstant(0)
 DECLARE v_archi_version = f8 WITH protect, noconstant(sbr_get_purge_archi_version(null))
 DECLARE v_parser_stmt = vc WITH protect, noconstant("")
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->table_name = "DM_CHG_LOG"
 SET reply->rows_between_commit = minval(request->max_rows,10000)
 SET reply->status_data.status = "F"
 FREE RECORD d_types
 RECORD d_types(
   1 cnt = i4
   1 qual[*]
     2 type = vc
 ) WITH protect
 FREE RECORD d_envs
 RECORD d_envs(
   1 cnt = i4
   1 qual[*]
     2 env_id = f8
     2 close_event_dt = f8
 ) WITH protect
 SET v_max = request->max_rows
 SELECT INTO "nl:"
  b.environment_id
  FROM dm_info a,
   dm_environment b
  WHERE a.info_name="DM_ENV_ID"
   AND a.info_domain="DATA MANAGEMENT"
   AND a.info_number=b.environment_id
  DETAIL
   v_env_id = b.environment_id
  WITH nocounter
 ;end select
 SET v_err_code2 = error(v_errmsg2,1)
 IF (v_err_code2 != 0)
  SET reply->status_data.status = "F"
  SET reply->err_code = v_err_code2
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"ENVIDERROR",
   "Error obtaining environment ID: %1","s",nullterm(v_errmsg2))
  GO TO exit_main
 ELSEIF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"NOENVID",
   "Fatal Error: current environment ID not found")
  GO TO exit_main
 ENDIF
 SELECT INTO "nl:"
  der.child_env_id
  FROM dm_env_reltn der
  WHERE der.parent_env_id=v_env_id
   AND der.relationship_type="REFERENCE MERGE"
  HEAD REPORT
   d_envs->cnt = 0
  DETAIL
   d_envs->cnt = (d_envs->cnt+ 1), stat = alterlist(d_envs->qual,d_envs->cnt), d_envs->qual[d_envs->
   cnt].env_id = der.child_env_id
  WITH nocounter
 ;end select
 SET v_err_code2 = error(v_errmsg2,1)
 IF (v_err_code2 != 0)
  SET reply->status_data.status = "F"
  SET reply->err_code = v_err_code2
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"CHILDENVERROR",
   "Error obtaining child environment IDs: %1","s",nullterm(v_errmsg2))
  GO TO exit_main
 ENDIF
 IF ((d_envs->cnt=0))
  SET reply->status_data.status = "S"
  SET reply->err_code = 0
  GO TO exit_main
 ENDIF
 SELECT INTO "nl:"
  di.info_char
  FROM dm_info di
  WHERE di.info_domain="RDDS CONFIGURATION"
   AND di.info_name="DCL_PURGE_TYPES*"
  HEAD REPORT
   d_types->cnt = 0
  DETAIL
   d_types->cnt = (d_types->cnt+ 1), stat = alterlist(d_types->qual,d_types->cnt), d_types->qual[
   d_types->cnt].type = di.info_char
  WITH nocounter
 ;end select
 SET v_err_code2 = error(v_errmsg2,1)
 IF (v_err_code2 != 0)
  SET reply->status_data.status = "F"
  SET reply->err_code = v_err_code2
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"PURGETYPEERR",
   "Error obtaining list of purgeable types: %1","s",nullterm(v_errmsg2))
  GO TO exit_main
 ENDIF
 IF ((d_types->cnt=0))
  SET reply->status_data.status = "S"
  SET reply->err_code = 0
  GO TO exit_main
 ENDIF
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="RDDS CONFIGURATION"
   AND di.info_name="DCL_PURGE_TIME"
  DETAIL
   v_dm_info_number = di.info_number
  WITH nocounter
 ;end select
 SET v_err_code2 = error(v_errmsg2,1)
 IF (v_err_code2 != 0)
  SET reply->status_data.status = "F"
  SET reply->err_code = v_err_code2
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"PURGETIMEERR",
   "Error obtaining the maximum age of driver row: %1","s",nullterm(v_errmsg2))
  GO TO exit_main
 ENDIF
 IF (v_dm_info_number < 150.0)
  SET v_dm_info_number = 150.0
 ENDIF
 FOR (v_loop = 1 TO d_envs->cnt)
   SELECT INTO "nl:"
    y = max(drel.event_dt_tm)
    FROM dm_rdds_event_log drel
    WHERE drel.rdds_event_key="ENDREFERENCEDATASYNC"
     AND drel.paired_environment_id=v_env_id
     AND (drel.cur_environment_id=d_envs->qual[v_loop].env_id)
     AND drel.event_dt_tm <= cnvtdatetime((curdate - 30),0)
     AND drel.event_dt_tm >= cnvtdatetime((curdate - v_dm_info_number),0)
    DETAIL
     d_envs->qual[v_loop].close_event_dt = y
    WITH nocounter
   ;end select
   SET v_err_code2 = error(v_errmsg2,1)
   IF (v_err_code2 != 0)
    SET reply->status_data.status = "F"
    SET reply->err_code = v_err_code2
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"DRIVERROWERR",
     "Error obtaining driver row for environment %1: %2","ds",d_envs->qual[v_loop].env_id,
     nullterm(v_errmsg2))
    GO TO exit_main
   ELSEIF ((d_envs->qual[v_loop].close_event_dt=0))
    SET d_envs->qual[v_loop].close_event_dt = cnvtdatetime((curdate - v_dm_info_number),0)
   ENDIF
 ENDFOR
 IF (v_archi_version >= 2.0)
  SET v_parser_stmt = sbr_getrowidnotexists(
   "dcl.updt_dt_tm <= cnvtdatetime(d_envs->qual[v_loop].close_event_dt)","dcl")
 ELSE
  SET v_parser_stmt = "dcl.updt_dt_tm <= cnvtdatetime(d_envs->qual[v_loop].close_event_dt)"
 ENDIF
 SET v_loop = 1
 WHILE ((v_loop <= d_envs->cnt)
  AND v_max > 0)
   SELECT INTO "nl:"
    dcl.rowid
    FROM dm_chg_log dcl
    WHERE (dcl.target_env_id=d_envs->qual[v_loop].env_id)
     AND expand(v_idx,1,d_types->cnt,dcl.log_type,d_types->qual[v_idx].type)
     AND parser(v_parser_stmt)
    DETAIL
     v_rows = (v_rows+ 1)
     IF (mod(v_rows,500)=1)
      stat = alterlist(reply->rows,(v_rows+ 499))
     ENDIF
     reply->rows[v_rows].row_id = dcl.rowid
    WITH nocounter, maxqual(dcl,value(v_max))
   ;end select
   SET v_err_code2 = error(v_errmsg2,1)
   IF (v_err_code2 != 0)
    SET reply->status_data.status = "F"
    SET reply->err_code = v_err_code2
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERR",
     "Error collecting rows for environment %1: %2","ds",d_envs->qual[v_loop].env_id,
     nullterm(v_errmsg2))
    GO TO exit_main
   ENDIF
   SET v_max = (request->max_rows - v_rows)
   SET v_loop = (v_loop+ 1)
 ENDWHILE
 SET stat = alterlist(reply->rows,v_rows)
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#exit_main
 FREE RECORD d_types
 FREE RECORD d_envs
END GO

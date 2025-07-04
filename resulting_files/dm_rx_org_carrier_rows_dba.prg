CREATE PROGRAM dm_rx_org_carrier_rows:dba
 SET reply->status_data.status = "F"
 DECLARE v_days_to_keep = i4 WITH protect, noconstant(0.0)
 DECLARE v_errmsg = vc WITH protect, noconstant("")
 DECLARE v_err_code = i4 WITH noconstant(0)
 DECLARE data_status_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE org_type_cd = f8 WITH constant(uar_get_code_by("MEANING",278,"PBM"))
 DECLARE row_cnt = i4 WITH noconstant(0.0)
 DECLARE v_batch_size = f8 WITH protect, noconstant(50000.0)
 DECLARE v_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE v_cur_min_id = f8 WITH protect, noconstant(1.0)
 DECLARE v_cur_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE v_rows_left = i4 WITH protect, noconstant(request->max_rows)
 DECLARE v_rows = i4 WITH protect, noconstant(0)
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->table_name = "ORGANIZATION"
 SET reply->rows_between_commit = 50
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 14)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s1",
   "You must keep at least 14 days worth of data.  You entered %1 days or did not enter any value.",
   "i",v_days_to_keep)
  GO TO exit_script
 ENDIF
 IF (batch_ndx=1)
  SELECT INTO "nl:"
   minval = min(org.organization_id)
   FROM organization org
   WHERE org.organization_id > 0
   DETAIL
    v_cur_min_id = maxval(cnvtreal(minval),1.0)
   WITH nocounter
  ;end select
 ELSE
  SET v_cur_min_id = sbr_fetch_starting_id(null)
 ENDIF
 SELECT INTO "nl:"
  maxval = max(org.organization_id)
  FROM organization org
  DETAIL
   v_max_id = cnvtreal(maxval)
  WITH nocounter
 ;end select
 SET v_cur_max_id = (v_cur_min_id+ (v_batch_size - 1))
 WHILE (v_cur_min_id <= v_max_id
  AND v_rows_left > 0)
   SELECT INTO "nl:"
    org.rowid
    FROM organization org,
     org_type_reltn otr
    WHERE parser(sbr_getrowidnotexists("org.data_status_cd = data_status_cd","org"))
     AND org.organization_id BETWEEN v_cur_min_id AND v_cur_max_id
     AND org.beg_effective_dt_tm < cnvtdatetime((curdate - v_days_to_keep),curtime3)
     AND otr.organization_id=org.organization_id
     AND otr.org_type_cd=org_type_cd
     AND  NOT ( EXISTS (
    (SELECT
     opr.organization_id
     FROM org_plan_reltn opr
     WHERE opr.organization_id=org.organization_id)))
    DETAIL
     v_rows = (v_rows+ 1)
     IF (mod(v_rows,50)=1)
      stat = alterlist(reply->rows,(v_rows+ 49))
     ENDIF
     reply->rows[v_rows].row_id = org.rowid
    WITH nocounter, maxqual(org,value(v_rows_left))
   ;end select
   SET v_err_code = error(v_errmsg,1)
   IF (v_err_code != 0)
    SET reply->err_code = v_err_code
    SET reply->status_data.status = "F"
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s2","Failed in row collection: %1","s",
     nullterm(v_errmsg))
    GO TO exit_script
   ENDIF
   CALL sbr_update_starting_id(v_cur_min_id)
   SET v_cur_min_id = (v_cur_max_id+ 1)
   SET v_cur_max_id = (v_cur_min_id+ (v_batch_size - 1))
   SET v_rows_left = (request->max_rows - v_rows)
 ENDWHILE
 SET stat = alterlist(reply->rows,v_rows)
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#exit_script
END GO

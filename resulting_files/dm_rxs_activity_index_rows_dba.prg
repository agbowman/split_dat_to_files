CREATE PROGRAM dm_rxs_activity_index_rows:dba
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
 DECLARE success = i2 WITH protect, constant(1)
 DECLARE fail = i2 WITH protect, constant(0)
 DECLARE overallstatus = i2 WITH protect, noconstant(0)
 DECLARE getactivities(null) = i2 WITH protect
 SET overallstatus = getactivities(null)
 GO TO exit_script
 SUBROUTINE getactivities(null)
   DECLARE v_days_to_keep = i4 WITH noconstant(- (1))
   DECLARE v_errmsg2 = c132
   DECLARE v_err_code2 = i4 WITH noconstant(0)
   DECLARE token_idx = i4 WITH protect, noconstant(0)
   DECLARE starttime = f8 WITH protect, noconstant(0.0)
   DECLARE row_cnt = i4 WITH protect, noconstant(0)
   DECLARE i18nhandle = i4 WITH protect, noconstant(0)
   CALL echo("getActivities started ...")
   SET starttime = curtime3
   SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
   SET reply->table_name = "RXS_ACTIVITY_INDEX"
   SET reply->rows_between_commit = 50
   SET reply->status_data.status = "F"
   FOR (token_idx = 1 TO size(request->tokens,5))
     IF (cnvtupper(request->tokens[token_idx].token_str)="DAYSTOKEEP")
      SET v_days_to_keep = ceil(cnvtreal(cnvtupper(request->tokens[token_idx].value)))
     ENDIF
   ENDFOR
   IF (v_days_to_keep < 120)
    SET reply->err_code = - (1)
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"DAYSTOKEEP",
     "You must keep at least 120 day's worth of data. You entered %1 days or did not enter any value.",
     "i",v_days_to_keep)
    RETURN(fail)
   ELSE
    SELECT INTO "nl:"
     rai.rowid
     FROM rxs_activity_index rai
     WHERE ((rai.rxs_activity_index_id > 0.0) OR (rai.rxs_activity_index_id < 0.0))
      AND parser(sbr_getrowidnotexists(
       "rai.activity_dt_tm < cnvtdatetime(curdate - v_days_to_keep,curtime3)","rai"))
     HEAD REPORT
      row_cnt = 0
     DETAIL
      row_cnt = (row_cnt+ 1)
      IF (mod(row_cnt,50)=1)
       stat = alterlist(reply->rows,(row_cnt+ 49))
      ENDIF
      reply->rows[row_cnt].row_id = rai.rowid
     FOOT REPORT
      stat = alterlist(reply->rows,row_cnt)
     WITH nocounter, maxqual(rai,value(request->max_rows))
    ;end select
    SET v_errmsg2 = fillstring(132," ")
    SET v_err_code2 = 0
    SET v_err_code2 = error(v_errmsg2,1)
    IF (v_err_code2 != 0)
     SET reply->err_code = v_err_code2
     SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR",
      "Failed in row collection: %1","s",nullterm(v_errmsg2))
     RETURN(fail)
    ENDIF
   ENDIF
   CALL echo(build("getActivities ended. Elapsed Time: ",((curtime3 - starttime)/ 100)," seconds."))
   RETURN(success)
 END ;Subroutine
#exit_script
 IF (overallstatus=success)
  SET reply->err_code = 0
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echo("Mod Date: 04/13/2010 Last Mod: 000")
END GO

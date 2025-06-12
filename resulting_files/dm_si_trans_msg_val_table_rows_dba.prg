CREATE PROGRAM dm_si_trans_msg_val_table_rows:dba
 DECLARE sbr_fetch_starting_id(null) = f8
 DECLARE sbr_delete_starting_id(null) = null
 SUBROUTINE (output_plan(i_statement_id=vc,i_file=vc,i_debug_str=vc) =null)
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
     WHERE (dm.index_name= Outerjoin(p.object_name)) )
    ORDER BY p.statement_id, p.id, dm.index_name,
     dm.column_position
    HEAD REPORT
     indent = 0, line = fillstring(100,"=")
    HEAD p.statement_id
     "PLAN STATEMENT FOR ", p.statement_id, row + 1,
     line, row + 1, indent = 0
    HEAD p.id
     indent += 1, col 0, p.id"#####",
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
 SUBROUTINE (sbr_update_starting_id(sbr_newid=f8) =null)
   DECLARE sbr_infoname = vc WITH protect, noconstant("")
   SET sbr_infoname = concat(trim(cnvtstring(jobs->data[job_ndx].template_nbr),3)," - ",trim(
     cnvtstring(v_log_id),3))
   UPDATE  FROM dm_info di
    SET di.info_long_id = sbr_newid, di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm =
     cnvtdatetime(sysdate),
     di.updt_cnt = (di.updt_cnt+ 1), di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
    WHERE di.info_domain="DM PURGE RESUME"
     AND di.info_name=sbr_infoname
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM PURGE RESUME", di.info_name = sbr_infoname, di.info_long_id = sbr_newid,
      di.info_date = cnvtdatetime(sysdate), di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm =
      cnvtdatetime(sysdate),
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
 SUBROUTINE (sbr_getrowidnotexists(sbr_whereclause=vc,sbr_tablealias=vc) =vc)
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
 SET reply->status_data.status = "F"
 SET reply->table_name = "SI_TRANSACTION_SET"
 SET reply->rows_between_commit = 100
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE v_days_to_keep = i4 WITH protect, noconstant(- (1))
 DECLARE v_token_idx = i4 WITH protect, noconstant(0)
 DECLARE v_batch_size = f8 WITH protect, noconstant(50000.0)
 DECLARE v_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE v_cur_min_id = f8 WITH protect, noconstant(1.0)
 DECLARE v_next_min_id = f8 WITH protect, noconstant(1.0)
 DECLARE v_cur_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE v_rows_left = i4 WITH protect, noconstant(request->max_rows)
 DECLARE v_rows = i4 WITH protect, noconstant(0)
 DECLARE v_errcode2 = i4 WITH protect, noconstant(0)
 DECLARE v_errmsg2 = vc WITH protect, noconstant("")
 FOR (v_token_idx = 1 TO size(request->tokens,5))
   IF ((request->tokens[v_token_idx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = ceil(cnvtreal(request->tokens[v_token_idx].value))
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 1)
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s1",
   "Days to keep cannot be less than 1.  You entered %1 days.","i",v_days_to_keep)
  GO TO exit_script
 ENDIF
 IF (batch_ndx=1)
  SELECT INTO "nl:"
   minval = min(ts.si_transaction_set_id)
   FROM si_transaction_set ts
   WHERE ts.si_transaction_set_id > 0
    AND ts.parent_si_transaction_set_id=0
    AND ((ts.txn_set_type_txt="VALIDATEBAT") OR (ts.txn_set_type_txt="MSGVALIDATE"))
    AND ts.txn_set_status_txt != "IN_PROGRESS"
    AND ts.txn_set_status_txt != "SCHEDULED"
   DETAIL
    v_cur_min_id = maxval(cnvtreal(minval),1.0)
   WITH nocounter
  ;end select
 ELSE
  SET v_next_min_id = sbr_fetch_starting_id(null)
  SELECT INTO "nl:"
   minval = min(ts.si_transaction_set_id)
   FROM si_transaction_set ts
   WHERE ts.parent_si_transaction_set_id=0
    AND ((ts.txn_set_type_txt="VALIDATEBAT") OR (ts.txn_set_type_txt="MSGVALIDATE"))
    AND ts.txn_set_status_txt != "IN_PROGRESS"
    AND ts.txn_set_status_txt != "SCHEDULED"
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM si_transaction_set ts2
    WHERE ts2.parent_si_transaction_set_id=ts.si_transaction_set_id)))
    AND parser(sbr_getrowidnotexists("ts.si_transaction_set_id > 0","ts"))
   DETAIL
    v_cur_min_id = minval(cnvtreal(minval),v_next_min_id)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  maxval = max(ts.si_transaction_set_id)
  FROM si_transaction_set ts
  DETAIL
   v_max_id = cnvtreal(maxval)
  WITH nocounter
 ;end select
 SET v_cur_max_id = (v_cur_min_id+ (v_batch_size - 1))
 WHILE (v_cur_min_id <= v_max_id
  AND v_rows_left > 0)
   SELECT INTO "nl:"
    ts.rowid
    FROM si_transaction_set ts
    WHERE ((ts.txn_set_type_txt="VALIDATEBAT") OR (ts.txn_set_type_txt="MSGVALIDATE"))
     AND ts.si_transaction_set_id BETWEEN v_cur_min_id AND v_cur_max_id
     AND ((ts.parent_si_transaction_set_id > 0) OR (ts.parent_si_transaction_set_id=0
     AND ts.txn_set_status_txt != "IN_PROGRESS"
     AND ts.txn_set_status_txt != "SCHEDULED"
     AND  NOT ( EXISTS (
    (SELECT
     1
     FROM si_transaction_set ts2
     WHERE ts2.parent_si_transaction_set_id=ts.si_transaction_set_id)))))
     AND parser(sbr_getrowidnotexists(
      "ts.start_dt_tm < cnvtdatetime(curdate - v_days_to_keep,curtime3)","ts"))
    DETAIL
     v_rows += 1
     IF (mod(v_rows,100)=1)
      stat = alterlist(reply->rows,(v_rows+ 99))
     ENDIF
     reply->rows[v_rows].row_id = ts.rowid
    WITH nocounter, maxqual(ts,value(v_rows_left))
   ;end select
   SET v_errcode2 = error(v_errmsg2,1)
   IF (v_errcode2 != 0)
    SET reply->err_code = v_errcode2
    SET reply->status_data.status = "F"
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s2","Failed in row collection: %1","s",
     nullterm(v_errmsg2))
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

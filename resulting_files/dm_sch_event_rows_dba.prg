CREATE PROGRAM dm_sch_event_rows:dba
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
 DECLARE purge_script_choosen = i4 WITH protect, noconstant(0)
 DECLARE i_ndx = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  a.updt_cnt
  FROM sch_pref a
  PLAN (a
   WHERE a.pref_type_meaning="EVTPURGSWTCH"
    AND a.parent_table="SYSTEM"
    AND a.parent_id=0.0
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   purge_script_choosen = a.pref_value
  WITH nocounter
 ;end select
 IF (((purge_script_choosen=1) OR (purge_script_choosen=3)) )
  FREE SET dm_sch_event_rows2_request
  RECORD dm_sch_event_rows2_request(
    1 max_rows = i4
    1 purge_flag = i2
    1 last_run_date = vc
    1 tokens[*]
      2 token_str = vc
      2 value = vc
  )
  FREE SET dm_sch_event_rows2_reply
  RECORD dm_sch_event_rows2_reply(
    1 err_msg = vc
    1 err_code = i4
    1 table_name = vc
    1 rows_between_commit = i4
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
  SET dm_sch_event_rows2_request->max_rows = request->max_rows
  SET dm_sch_event_rows2_request->purge_flag = request->purge_flag
  SET dm_sch_event_rows2_request->last_run_date = request->last_run_date
  SET stat = alterlist(dm_sch_event_rows2_request->tokens,size(request->tokens,5))
  FOR (i_ndx = 1 TO size(request->tokens,5))
   SET dm_sch_event_rows2_request->tokens[i_ndx].token_str = request->tokens[i_ndx].token_str
   SET dm_sch_event_rows2_request->tokens[i_ndx].value = request->tokens[i_ndx].value
  ENDFOR
  EXECUTE dm_sch_event_rows2
  SET reply->err_msg = dm_sch_event_rows2_reply->err_msg
  SET reply->err_code = dm_sch_event_rows2_reply->err_code
  SET reply->table_name = dm_sch_event_rows2_reply->table_name
  SET reply->rows_between_commit = dm_sch_event_rows2_reply->rows_between_commit
  SET stat = alterlist(reply->rows,size(dm_sch_event_rows2_reply->rows,5))
  FOR (i_ndx = 1 TO size(dm_sch_event_rows2_reply->rows,5))
    SET reply->rows[i_ndx].row_id = dm_sch_event_rows2_reply->rows[i_ndx].row_id
  ENDFOR
  SET reply->status_data.status = dm_sch_event_rows2_reply->status_data.status
  GO TO exit_script
 ENDIF
 FREE RECORD t_recur_rec
 RECORD t_recur_rec(
   1 qual_cnt = i4
   1 qual[*]
     2 sch_event_id = f8
     2 ignoreind = i2
     2 row_id = vc
     2 child_qual_cnt = i4
     2 child_qual[*]
       3 row_id = vc
 )
 FREE RECORD t_prot_rec
 RECORD t_prot_rec(
   1 qual_cnt = i4
   1 qual[*]
     2 protocol_parent_id = f8
     2 ignoreind = i2
     2 row_id = vc
     2 child_qual_cnt = i4
     2 child_qual[*]
       3 protocol_parent_id = f8
       3 row_id = vc
 )
 FREE RECORD t_single_rec
 RECORD t_single_rec(
   1 qual_cnt = i4
   1 qual[*]
     2 row_id = vc
 )
 FREE RECORD t_recsize_rec
 RECORD t_recsize_rec(
   1 qual_cnt = i4
   1 qual[*]
     2 rec_index = i4
     2 rec_size = i4
 )
 DECLARE g_minimum_keep_days = f8 WITH protect, constant(60.0)
 DECLARE purge_dt_tm = q8 WITH protect, noconstant(0.0)
 DECLARE nsize = i4 WITH protect, constant(100)
 DECLARE v_days_to_keep = i4 WITH protect, noconstant(- (1))
 DECLARE v_row_cnt = i4 WITH protect, noconstant(0)
 DECLARE iforcount = i4 WITH protect, noconstant(0)
 DECLARE iforcount2 = i4 WITH protect, noconstant(0)
 DECLARE tok_ndx = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(0)
 DECLARE dummytseqval = i4 WITH protect, noconstant(0)
 DECLARE temp_rec_idx = i4 WITH protect, noconstant(0)
 DECLARE lval_idx = i4 WITH protect, noconstant(0)
 DECLARE expand_idx = i4 WITH protect, noconstant(0)
 DECLARE batchsize = f8 WITH protect, noconstant(50000.0)
 DECLARE maxid = f8 WITH protect, noconstant(0.0)
 DECLARE curminid = f8 WITH protect, noconstant(1.0)
 DECLARE curmaxid = f8 WITH protect, noconstant(0.0)
 DECLARE rowsleft = i4 WITH protect, noconstant(request->max_rows)
 DECLARE doupdateind = i2 WITH protect, noconstant(0)
 DECLARE sort_min = i4 WITH protect, noconstant(0)
 DECLARE sort_temp_idx = i4 WITH protect, noconstant(0)
 DECLARE sort_temp_size = i4 WITH protect, noconstant(0)
 DECLARE sort_temp_parent_id = f8 WITH protect, noconstant(0.0)
 DECLARE sort_temp_id = f8 WITH protect, noconstant(0.0)
 DECLARE sort_temp_rowid = vc WITH protect, noconstant("")
 DECLARE v_row_qualifies_ind = i2 WITH protect, noconstant(1)
 DECLARE orphan_maxrows = i4 WITH protect, noconstant((request->max_rows - 1))
 DECLARE standalone_copy_ind = i2 WITH protect, noconstant(0)
 DECLARE v_errmsg2 = vc WITH protect, noconstant("")
 DECLARE v_err_code2 = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE min_empty_batch_cnt = i4 WITH protect, constant(10)
 DECLARE empty_batch_cnt = i4 WITH protect, noconstant(0)
 DECLARE empty_batch_cnt_max = i4 WITH protect, noconstant(10)
 DECLARE batch_is_empty = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  a.updt_cnt
  FROM sch_pref a
  PLAN (a
   WHERE a.pref_type_meaning="BATCHPURGMAX"
    AND a.parent_table="SYSTEM"
    AND a.parent_id=0.0
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   empty_batch_cnt_max = a.pref_value
  WITH nocounter
 ;end select
 IF (empty_batch_cnt_max != 0
  AND empty_batch_cnt_max < min_empty_batch_cnt)
  SET empty_batch_cnt_max = min_empty_batch_cnt
 ENDIF
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ENDIF
 ENDFOR
 IF (v_days_to_keep < g_minimum_keep_days)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"KEEPDAYS",
   "You must keep at least %1 days' worth of data.  You entered %2 days or did not enter any value.",
   "di",g_minimum_keep_days,
   v_days_to_keep)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET reply->table_name = "SCH_EVENT"
 SET reply->rows_between_commit = 50
 SET purge_dt_tm = cnvtdatetime((curdate - v_days_to_keep),curtime3)
 IF (batch_ndx=1)
  SELECT INTO "nl:"
   seqval = min(se.sch_event_id)
   FROM sch_event se
   WHERE se.sch_event_id > 0
   DETAIL
    curminid = maxval(cnvtreal(seqval),1.0)
   WITH nocounter
  ;end select
 ELSE
  SET curminid = sbr_fetch_starting_id(null)
 ENDIF
 SELECT INTO "nl:"
  seqval = max(se.sch_event_id)
  FROM sch_event se
  DETAIL
   maxid = cnvtreal(seqval)
  WITH nocounter
 ;end select
 SET curmaxid = (curminid+ (batchsize - 1))
 WHILE (curminid <= maxid
  AND rowsleft > 0)
   SET batch_is_empty = 1
   SET t_recur_rec->qual_cnt = 0
   SET stat = alterlist(t_recur_rec->qual,0)
   SET t_prot_rec->qual_cnt = 0
   SET stat = alterlist(t_prot_rec->qual,0)
   SET t_single_rec->qual_cnt = 0
   SET stat = alterlist(t_single_rec->qual,0)
   SET t_recsize_rec->qual_cnt = 0
   SET stat = alterlist(t_recsize_rec->qual,0)
   SELECT INTO "nl:"
    FROM sch_event se
    WHERE parser(sbr_getrowidnotexists("se.sch_event_id between curMinID and curMaxID","se"))
     AND se.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND ((se.recur_parent_id=0
     AND se.protocol_parent_id=0
     AND se.protocol_type_flag != 3) OR (((se.recur_type_flag=1) OR (se.protocol_type_flag=3)) ))
     AND  EXISTS (
    (SELECT
     sa.sch_appt_id
     FROM sch_appt sa
     WHERE sa.sch_event_id=se.sch_event_id
      AND sa.state_meaning != "RESCHEDULED"
      AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
      AND  EXISTS (
     (SELECT
      sb.booking_id
      FROM sch_booking sb
      WHERE sb.booking_id=sa.booking_id
       AND sb.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
       AND sb.beg_dt_tm < cnvtdatetime(purge_dt_tm)))))
    DETAIL
     IF (se.recur_parent_id=0
      AND se.protocol_parent_id=0
      AND se.protocol_type_flag != 3)
      t_single_rec->qual_cnt = (t_single_rec->qual_cnt+ 1)
      IF (mod(t_single_rec->qual_cnt,100)=1)
       stat = alterlist(t_single_rec->qual,(t_single_rec->qual_cnt+ 99))
      ENDIF
      t_single_rec->qual[t_single_rec->qual_cnt].row_id = se.rowid, batch_is_empty = 0
     ELSEIF (se.recur_type_flag=1)
      t_recur_rec->qual_cnt = (t_recur_rec->qual_cnt+ 1)
      IF (mod(t_recur_rec->qual_cnt,100)=1)
       stat = alterlist(t_recur_rec->qual,(t_recur_rec->qual_cnt+ 99))
      ENDIF
      t_recur_rec->qual[t_recur_rec->qual_cnt].sch_event_id = se.sch_event_id, t_recur_rec->qual[
      t_recur_rec->qual_cnt].row_id = se.rowid, batch_is_empty = 0
     ELSEIF (se.protocol_type_flag=3)
      IF (locateval(lval_idx,1,t_prot_rec->qual_cnt,se.protocol_parent_id,t_prot_rec->qual[lval_idx].
       protocol_parent_id)=0)
       t_prot_rec->qual_cnt = (t_prot_rec->qual_cnt+ 1)
       IF (mod(t_prot_rec->qual_cnt,100)=1)
        stat = alterlist(t_prot_rec->qual,(t_prot_rec->qual_cnt+ 99))
       ENDIF
       t_prot_rec->qual[t_prot_rec->qual_cnt].protocol_parent_id = se.protocol_parent_id
      ENDIF
      batch_is_empty = 0
     ENDIF
    WITH nocounter, maxqual(se,value(rowsleft))
   ;end select
   SET v_err_code2 = error(v_errmsg2,1)
   IF (v_err_code2 > 0)
    SET reply->err_code = v_err_code2
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s1",
     "Failed during initial events query: %1","s",nullterm(v_errmsg2))
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   SET stat = alterlist(t_recur_rec->qual,t_recur_rec->qual_cnt)
   SET stat = alterlist(t_prot_rec->qual,t_prot_rec->qual_cnt)
   SET stat = alterlist(t_single_rec->qual,t_single_rec->qual_cnt)
   IF ((t_recur_rec->qual_cnt > 0))
    SET dummytseqval = ceil((cnvtreal(t_recur_rec->qual_cnt)/ cnvtreal(nsize)))
    SET nstart = 1
    SELECT INTO "nl:"
     se.rowid
     FROM sch_event se,
      sch_appt sa,
      (dummyt d  WITH seq = value(dummytseqval))
     PLAN (d
      WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
      JOIN (se
      WHERE expand(expand_idx,nstart,minval((nstart+ (nsize - 1)),t_recur_rec->qual_cnt),se
       .recur_parent_id,t_recur_rec->qual[expand_idx].sch_event_id)
       AND parser(sbr_getrowidnotexists("se.recur_type_flag +0 = 2","se"))
       AND ((se.protocol_parent_id+ 0)=0)
       AND ((se.sch_event_id+ 0) > 0)
       AND se.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
      JOIN (sa
      WHERE sa.sch_event_id=se.sch_event_id
       AND sa.state_meaning != "RESCHEDULED"
       AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     DETAIL
      index = locateval(lval_idx,1,t_recur_rec->qual_cnt,se.recur_parent_id,t_recur_rec->qual[
       lval_idx].sch_event_id)
      IF ((t_recur_rec->qual[index].ignoreind=0)
       AND sa.beg_dt_tm >= cnvtdatetime(purge_dt_tm))
       t_recur_rec->qual[index].ignoreind = 1, t_recur_rec->qual[index].child_qual_cnt = 0, stat =
       alterlist(t_recur_rec->qual[index].child_qual,0)
      ELSEIF ((t_recur_rec->qual[index].ignoreind=0))
       t_recur_rec->qual[index].child_qual_cnt = (t_recur_rec->qual[index].child_qual_cnt+ 1), stat
        = alterlist(t_recur_rec->qual[index].child_qual,t_recur_rec->qual[index].child_qual_cnt),
       t_recur_rec->qual[index].child_qual[t_recur_rec->qual[index].child_qual_cnt].row_id = se.rowid
      ENDIF
     WITH nocounter
    ;end select
    SET v_err_code2 = error(v_errmsg2,1)
    IF (v_err_code2 > 0)
     SET reply->err_code = v_err_code2
     SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s2",
      "Failed during recurring events query: %1","s",nullterm(v_errmsg2))
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
    FOR (iforcount = 1 TO t_recur_rec->qual_cnt)
      IF ((t_recur_rec->qual[iforcount].ignoreind=0))
       SET t_recsize_rec->qual_cnt = (t_recsize_rec->qual_cnt+ 1)
       IF (mod(t_recsize_rec->qual_cnt,100)=1)
        SET stat = alterlist(t_recsize_rec->qual,(t_recsize_rec->qual_cnt+ 99))
       ENDIF
       SET t_recsize_rec->qual[t_recsize_rec->qual_cnt].rec_index = iforcount
       SET t_recsize_rec->qual[t_recsize_rec->qual_cnt].rec_size = t_recur_rec->qual[iforcount].
       child_qual_cnt
      ENDIF
    ENDFOR
    SET stat = alterlist(t_recsize_rec->qual,t_recsize_rec->qual_cnt)
    FOR (iforcount = 1 TO (t_recsize_rec->qual_cnt - 1))
      SET sort_min = iforcount
      FOR (iforcount2 = (iforcount+ 1) TO t_recsize_rec->qual_cnt)
        IF ((t_recsize_rec->qual[iforcount2].rec_size > t_recsize_rec->qual[sort_min].rec_size))
         SET sort_min = iforcount2
        ENDIF
      ENDFOR
      IF (iforcount != sort_min)
       SET sort_temp_idx = t_recsize_rec->qual[iforcount].rec_index
       SET sort_temp_size = t_recsize_rec->qual[iforcount].rec_size
       SET t_recsize_rec->qual[iforcount].rec_index = t_recsize_rec->qual[sort_min].rec_index
       SET t_recsize_rec->qual[iforcount].rec_size = t_recsize_rec->qual[sort_min].rec_size
       SET t_recsize_rec->qual[sort_min].rec_index = sort_temp_idx
       SET t_recsize_rec->qual[sort_min].rec_size = sort_temp_size
      ENDIF
    ENDFOR
    FOR (iforcount = 1 TO t_recsize_rec->qual_cnt)
     SET temp_rec_idx = t_recsize_rec->qual[iforcount].rec_index
     IF ((((v_row_cnt+ t_recsize_rec->qual[iforcount].rec_size)+ 1) <= orphan_maxrows))
      SET v_row_cnt = (v_row_cnt+ 1)
      IF (mod(v_row_cnt,100)=1)
       SET stat = alterlist(reply->rows,(v_row_cnt+ 99))
      ENDIF
      SET reply->rows[v_row_cnt].row_id = t_recur_rec->qual[temp_rec_idx].row_id
      FOR (iforcount2 = 1 TO t_recur_rec->qual[temp_rec_idx].child_qual_cnt)
        SET v_row_cnt = (v_row_cnt+ 1)
        IF (mod(v_row_cnt,100)=1)
         SET stat = alterlist(reply->rows,(v_row_cnt+ 99))
        ENDIF
        SET reply->rows[v_row_cnt].row_id = t_recur_rec->qual[temp_rec_idx].child_qual[iforcount2].
        row_id
      ENDFOR
     ELSE
      SET iforcount2 = 1
      WHILE ((iforcount2 <= t_recur_rec->qual[temp_rec_idx].child_qual_cnt)
       AND (v_row_cnt <= request->max_rows))
        SET v_row_cnt = (v_row_cnt+ 1)
        IF (mod(v_row_cnt,100)=1)
         SET stat = alterlist(reply->rows,(v_row_cnt+ 99))
        ENDIF
        SET reply->rows[v_row_cnt].row_id = t_recur_rec->qual[temp_rec_idx].child_qual[iforcount2].
        row_id
        SET iforcount2 = (iforcount2+ 1)
      ENDWHILE
      IF (v_row_cnt=orphan_maxrows)
       SET v_row_cnt = (v_row_cnt+ 1)
       SET stat = alterlist(reply->rows,v_row_cnt)
       SET reply->rows[v_row_cnt].row_id = t_recur_rec->qual[iforcount].row_id
      ENDIF
      GO TO success_exit
     ENDIF
    ENDFOR
    SET t_recur_rec->qual_cnt = 0
    SET stat = alterlist(t_recur_rec->qual,0)
    SET t_recsize_rec->qual_cnt = 0
    SET stat = alterlist(t_recsize_rec->qual,0)
    IF (((v_row_cnt+ t_single_rec->qual_cnt) >= request->max_rows))
     SET iforcount = 1
     WHILE ((iforcount <= t_single_rec->qual_cnt)
      AND (v_row_cnt <= request->max_rows))
       SET v_row_cnt = (v_row_cnt+ 1)
       IF (mod(v_row_cnt,100)=1)
        SET stat = alterlist(reply->rows,(v_row_cnt+ 99))
       ENDIF
       SET reply->rows[v_row_cnt].row_id = t_single_rec->qual[iforcount].row_id
       SET iforcount = (iforcount+ 1)
     ENDWHILE
     GO TO success_exit
    ENDIF
   ENDIF
   IF ((t_prot_rec->qual_cnt > 0))
    SET dummytseqval = ceil((cnvtreal(t_prot_rec->qual_cnt)/ cnvtreal(nsize)))
    SET nstart = 1
    SELECT INTO "nl:"
     se2.rowid, se.rowid
     FROM sch_event se2,
      sch_event se,
      sch_appt sa,
      (dummyt d  WITH seq = value(dummytseqval))
     PLAN (d
      WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
      JOIN (se2
      WHERE expand(expand_idx,nstart,minval((nstart+ (nsize - 1)),t_prot_rec->qual_cnt),se2
       .sch_event_id,t_prot_rec->qual[expand_idx].protocol_parent_id)
       AND ((se2.protocol_type_flag+ 0)=1)
       AND ((se2.recur_parent_id+ 0)=0)
       AND se2.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
      JOIN (se
      WHERE parser(sbr_getrowidnotexists("se.protocol_parent_id = se2.sch_event_id","se"))
       AND ((se.protocol_type_flag+ 0)=3)
       AND ((se.recur_parent_id+ 0)=0)
       AND ((se.sch_event_id+ 0) > 0)
       AND se.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
      JOIN (sa
      WHERE sa.sch_event_id=se.sch_event_id
       AND sa.state_meaning != "RESCHEDULED"
       AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     DETAIL
      index = locateval(lval_idx,1,t_prot_rec->qual_cnt,se2.sch_event_id,t_prot_rec->qual[lval_idx].
       protocol_parent_id)
      IF ((t_prot_rec->qual[index].ignoreind=0)
       AND sa.beg_dt_tm >= cnvtdatetime(purge_dt_tm))
       t_prot_rec->qual[index].ignoreind = 1, t_prot_rec->qual[index].child_qual_cnt = 0, stat =
       alterlist(t_prot_rec->qual[index].child_qual,0)
      ELSEIF ((t_prot_rec->qual[index].ignoreind=0))
       t_prot_rec->qual[index].row_id = se2.rowid, t_prot_rec->qual[index].child_qual_cnt = (
       t_prot_rec->qual[index].child_qual_cnt+ 1), stat = alterlist(t_prot_rec->qual[index].
        child_qual,t_prot_rec->qual[index].child_qual_cnt),
       t_prot_rec->qual[index].child_qual[t_prot_rec->qual[index].child_qual_cnt].row_id = se.rowid
      ENDIF
     WITH nocounter
    ;end select
    SET v_err_code2 = error(v_errmsg2,1)
    IF (v_err_code2 > 0)
     SET reply->err_code = v_err_code2
     SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s3",
      "Failed during protocol events query: %1","s",nullterm(v_errmsg2))
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
    FOR (iforcount = 1 TO t_prot_rec->qual_cnt)
      IF ((t_prot_rec->qual[iforcount].ignoreind=0))
       SET t_recsize_rec->qual_cnt = (t_recsize_rec->qual_cnt+ 1)
       IF (mod(t_recsize_rec->qual_cnt,100)=1)
        SET stat = alterlist(t_recsize_rec->qual,(t_recsize_rec->qual_cnt+ 99))
       ENDIF
       SET t_recsize_rec->qual[t_recsize_rec->qual_cnt].rec_index = iforcount
       SET t_recsize_rec->qual[t_recsize_rec->qual_cnt].rec_size = t_prot_rec->qual[iforcount].
       child_qual_cnt
      ENDIF
    ENDFOR
    SET stat = alterlist(t_recsize_rec->qual,t_recsize_rec->qual_cnt)
    FOR (iforcount = 1 TO (t_recsize_rec->qual_cnt - 1))
      SET sort_min = iforcount
      FOR (iforcount2 = (iforcount+ 1) TO t_recsize_rec->qual_cnt)
        IF ((t_recsize_rec->qual[iforcount2].rec_size > t_recsize_rec->qual[sort_min].rec_size))
         SET sort_min = iforcount2
        ENDIF
      ENDFOR
      IF (iforcount != sort_min)
       SET sort_temp_idx = t_recsize_rec->qual[iforcount].rec_index
       SET sort_temp_size = t_recsize_rec->qual[iforcount].rec_size
       SET t_recsize_rec->qual[iforcount].rec_index = t_recsize_rec->qual[sort_min].rec_index
       SET t_recsize_rec->qual[iforcount].rec_size = t_recsize_rec->qual[sort_min].rec_size
       SET t_recsize_rec->qual[sort_min].rec_index = sort_temp_idx
       SET t_recsize_rec->qual[sort_min].rec_size = sort_temp_size
      ENDIF
    ENDFOR
    FOR (iforcount = 1 TO t_recsize_rec->qual_cnt)
     SET temp_rec_idx = t_recsize_rec->qual[iforcount].rec_index
     IF ((((v_row_cnt+ t_recsize_rec->qual[iforcount].rec_size)+ 1) <= orphan_maxrows))
      IF ((t_prot_rec->qual[temp_rec_idx].row_id > " "))
       SET v_row_cnt = (v_row_cnt+ 1)
       IF (mod(v_row_cnt,100)=1)
        SET stat = alterlist(reply->rows,(v_row_cnt+ 99))
       ENDIF
       SET reply->rows[v_row_cnt].row_id = t_prot_rec->qual[temp_rec_idx].row_id
       FOR (iforcount2 = 1 TO t_prot_rec->qual[temp_rec_idx].child_qual_cnt)
         SET v_row_cnt = (v_row_cnt+ 1)
         IF (mod(v_row_cnt,100)=1)
          SET stat = alterlist(reply->rows,(v_row_cnt+ 99))
         ENDIF
         SET reply->rows[v_row_cnt].row_id = t_prot_rec->qual[temp_rec_idx].child_qual[iforcount2].
         row_id
       ENDFOR
      ENDIF
     ELSE
      SET reply->rows_remain_ind = 1
      SET iforcount2 = 1
      WHILE ((iforcount2 <= (t_prot_rec->qual[iforcount].child_qual_cnt - 1))
       AND (v_row_cnt <= request->max_rows))
        SET v_row_cnt = (v_row_cnt+ 1)
        IF (mod(v_row_cnt,100)=1)
         SET stat = alterlist(reply->rows,(v_row_cnt+ 99))
        ENDIF
        SET reply->rows[v_row_cnt].row_id = t_prot_rec->qual[iforcount].child_qual[iforcount2].row_id
        SET iforcount2 = (iforcount2+ 1)
      ENDWHILE
      IF (v_row_cnt=orphan_maxrows)
       IF ((iforcount < t_recsize_rec->qual_cnt))
        SET temp_rec_idx = t_recsize_rec->qual[(iforcount+ 1)].rec_size
        SET v_row_cnt = (v_row_cnt+ 1)
        SET stat = alterlist(reply->rows,v_row_cnt)
        SET reply->rows[v_row_cnt].row_id = t_prot_rec->qual[temp_rec_idx].child_qual[1].row_id
       ENDIF
      ENDIF
      GO TO success_exit
     ENDIF
    ENDFOR
    SET t_prot_rec->qual_cnt = 0
    SET stat = alterlist(t_prot_rec->qual,0)
    SET t_recsize_rec->qual_cnt = 0
    SET stat = alterlist(t_recsize_rec->qual,0)
    SET doupdateind = 0
    IF (((v_row_cnt+ t_single_rec->qual_cnt) <= request->max_rows))
     SET doupdateind = 1
     CALL sbr_update_starting_id(curminid)
    ENDIF
    SET iforcount = 1
    WHILE ((iforcount <= t_single_rec->qual_cnt)
     AND (v_row_cnt <= request->max_rows))
      SET v_row_cnt = (v_row_cnt+ 1)
      IF (mod(v_row_cnt,100)=1)
       SET stat = alterlist(reply->rows,(v_row_cnt+ 99))
      ENDIF
      SET reply->rows[v_row_cnt].row_id = t_single_rec->qual[iforcount].row_id
      SET iforcount = (iforcount+ 1)
    ENDWHILE
   ELSEIF ((t_prot_rec->qual_cnt=0)
    AND (t_single_rec->qual_cnt > 0))
    SET iforcount = 1
    WHILE ((iforcount <= t_single_rec->qual_cnt)
     AND (v_row_cnt <= request->max_rows))
      SET v_row_cnt = (v_row_cnt+ 1)
      IF (mod(v_row_cnt,100)=1)
       SET stat = alterlist(reply->rows,(v_row_cnt+ 99))
      ENDIF
      SET reply->rows[v_row_cnt].row_id = t_single_rec->qual[iforcount].row_id
      SET iforcount = (iforcount+ 1)
    ENDWHILE
   ENDIF
   SET curminid = (curmaxid+ 1)
   SELECT INTO "nl:"
    seqval = min(se.sch_event_id)
    FROM sch_event se
    WHERE se.sch_event_id > curmaxid
    DETAIL
     IF (cnvtreal(seqval) > 0)
      curminid = cnvtreal(seqval)
     ENDIF
    WITH nocounter
   ;end select
   SET curmaxid = (curminid+ (batchsize - 1))
   SET rowsleft = (request->max_rows - v_row_cnt)
   IF (empty_batch_cnt_max != 0)
    IF (batch_is_empty=0)
     SET empty_batch_cnt = 0
    ELSE
     SET empty_batch_cnt = (empty_batch_cnt+ 1)
    ENDIF
    IF (empty_batch_cnt >= empty_batch_cnt_max)
     SET rowsleft = 0
     IF (purge_script_choosen=0)
      EXECUTE sch_utl_system_pref "EVTPURGSWTCH", 1
     ENDIF
    ENDIF
   ENDIF
 ENDWHILE
#success_exit
 SET stat = alterlist(reply->rows,v_row_cnt)
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#exit_script
 IF (purge_script_choosen != 1
  AND purge_script_choosen != 3)
  FREE RECORD t_recur_rec
  FREE RECORD t_prot_rec
  FREE RECORD t_single_rec
  FREE RECORD t_recsize_rec
 ENDIF
END GO

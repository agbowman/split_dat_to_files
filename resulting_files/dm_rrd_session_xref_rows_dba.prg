CREATE PROGRAM dm_rrd_session_xref_rows:dba
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
 DECLARE v_days_to_keep = i4 WITH noconstant(1000)
 DECLARE v_errmsg2 = vc WITH noconstant("")
 DECLARE v_err_code2 = i4 WITH noconstant(0)
 DECLARE batchsize = f8 WITH protect, noconstant(50000.0)
 DECLARE maxid = f8 WITH protect, noconstant(0.0)
 DECLARE curminid = f8 WITH protect, noconstant(1.0)
 DECLARE curmaxid = f8 WITH protect, noconstant(0.0)
 DECLARE rowsleft = i4 WITH protect, noconstant(request->max_rows)
 DECLARE rows = i4 WITH protect, noconstant(0)
 SET reply->table_name = "SESSION_XREF"
 SET reply->rows_between_commit = 50
 SELECT INTO "nl:"
  r.sess_purge_days
  FROM rrddefaults r
  WHERE ((r.rrddefaults_id+ 0) > 0)
  DETAIL
   v_days_to_keep = ceil(cnvtreal(r.sess_purge_days))
  WITH nocounter
 ;end select
 IF (batch_ndx=1)
  SELECT INTO "nl:"
   seqval = min(xr.output_handle_id)
   FROM session_xref xr
   WHERE xr.output_handle_id > 0
   DETAIL
    curminid = maxval(cnvtreal(seqval),1.0)
   WITH nocounter
  ;end select
 ELSE
  SET curminid = sbr_fetch_starting_id(null)
 ENDIF
 SELECT INTO "nl:"
  seqval = max(xr.output_handle_id)
  FROM session_xref xr
  DETAIL
   maxid = cnvtreal(seqval)
  WITH nocounter
 ;end select
 SET curmaxid = (curminid+ (batchsize - 1))
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 WHILE (curminid <= maxid
  AND rowsleft > 0)
   SELECT INTO "nl:"
    xr.rowid
    FROM session_xref xr
    WHERE parser(sbr_getrowidnotexists("xr.output_handle_id between curMinID and curMaxID","xr"))
     AND xr.session_num > 0
     AND  EXISTS (
    (SELECT
     s.session_num
     FROM session_log s
     WHERE s.session_num=xr.session_num
      AND s.qualifier=1
      AND s.sess_dt_tm < cnvtdatetime((curdate - v_days_to_keep),curtime3)))
    DETAIL
     rows += 1
     IF (mod(rows,100)=1)
      stat = alterlist(reply->rows,(rows+ 99))
     ENDIF
     reply->rows[rows].row_id = xr.rowid
    WITH nocounter, maxqual(xr,value(rowsleft))
   ;end select
   SET v_err_code2 = error(v_errmsg2,1)
   IF (v_err_code2 != 0)
    SET reply->err_code = v_err_code2
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR",
     "Failed in row collection: %1","s",nullterm(v_errmsg2))
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   CALL sbr_update_starting_id(curminid)
   SET curminid = (curmaxid+ 1)
   SET curmaxid = (curminid+ (batchsize - 1))
   SET rowsleft = (request->max_rows - rows)
 ENDWHILE
 IF ((request->purge_flag IN (c_del_high_log, c_del_dtl_log))
  AND batch_ndx=1)
  DECLARE v_xmit_cd = f8 WITH protect, noconstant(uar_get_code_by(nullterm("MEANING"),2209,nullterm(
     "XMITTED")))
  DECLARE v_error_cd = f8 WITH protect, noconstant(uar_get_code_by(nullterm("MEANING"),2209,nullterm(
     "ERROR")))
  DECLARE v_cancel_cd = f8 WITH protect, noconstant(uar_get_code_by(nullterm("MEANING"),2209,nullterm
    ("CANCELLED")))
  IF (v_xmit_cd=0.0)
   SET reply->err_code = - (1)
   SET reply->status_data.status = "F"
   SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"XMITTED",
    "Unable to find CDF meaning 'XMITTED' in code set 2209")
   GO TO exit_script
  ELSEIF (v_error_cd=0.0)
   SET reply->err_code = - (1)
   SET reply->status_data.status = "F"
   SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"ERROR",
    "Unable to find CDF meaning 'ERROR' in code set 2209")
   GO TO exit_script
  ELSEIF (v_cancel_cd=0.0)
   SET reply->err_code = - (1)
   SET reply->status_data.status = "F"
   SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"CANCELLED",
    "Unable to find CDF meaning 'CANCELLED' in code set 2209")
   GO TO exit_script
  ENDIF
  INSERT  FROM report_queue_deletes r
   (r.output_handle_id, r.updt_cnt, r.updt_id,
   r.updt_dt_tm, r.updt_applctx, r.updt_task,
   r.server)(SELECT
    r.output_handle_id, 0, reqinfo->updt_id,
    cnvtdatetime(sysdate), reqinfo->updt_applctx, reqinfo->updt_task,
    " "
    FROM report_queue r
    WHERE r.updt_dt_tm < cnvtdatetime((curdate - v_days_to_keep),curtime3)
     AND ((r.transmission_status_cd+ 0) IN (v_xmit_cd, v_error_cd, v_cancel_cd))
     AND ((r.output_handle_id+ 0) > 0)
     AND  NOT ( EXISTS (
    (SELECT
     d.output_handle_id
     FROM report_queue_deletes d
     WHERE d.output_handle_id=r.output_handle_id))))
   WITH nocounter
  ;end insert
  SET v_err_code2 = error(v_errmsg2,1)
  IF (v_err_code2=0)
   COMMIT
  ELSE
   ROLLBACK
   SET reply->err_code = v_err_code2
   SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"INSERTERROR",
    "Failed inserting old reports for purging: %1","s",nullterm(v_errmsg2))
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->rows,rows)
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#exit_script
END GO

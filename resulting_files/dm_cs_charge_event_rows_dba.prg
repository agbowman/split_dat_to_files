CREATE PROGRAM dm_cs_charge_event_rows:dba
 DECLARE dm_cs_charge_event_rows = vc WITH private, noconstant("448740.FT.007")
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
 SET c_df = "YYYYMMDDHHMMSScc;;d"
 SET c_del_high_log = 1
 SET c_del_dtl_log = 2
 SET c_audit = 3
 SET c_ptf_delete = 1
 SET c_ptf_update = 2
 SET c_active = 1
 SET c_inactive = 2
 SET c_tmpl_changed = 3
 SET c_sf_success = 1
 SET c_sf_failed = 2
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->table_name = "CHARGE_EVENT"
 SET reply->rows_between_commit = 500
 SET reply->status_data.status = "F"
 DECLARE code_set = i4 WITH public, noconstant(0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE completed_cd = f8 WITH public, noconstant(0.0)
 DECLARE cancelled_cd = f8 WITH public, noconstant(0.0)
 DECLARE ordered_cd = f8 WITH public, noconstant(0.0)
 DECLARE ddiscontinued_cd = f8 WITH public, noconstant(0.0)
 DECLARE ddeleted_cd = f8 WITH public, noconstant(0.0)
 DECLARE dtransfercancel_cd = f8 WITH public, noconstant(0.0)
 DECLARE dvoided_cd = f8 WITH public, noconstant(0.0)
 DECLARE dfuture_cd = f8 WITH public, noconstant(0.0)
 DECLARE dinprocess_cd = f8 WITH public, noconstant(0.0)
 DECLARE dmedstudent_cd = f8 WITH public, noconstant(0.0)
 DECLARE dpending_cd = f8 WITH public, noconstant(0.0)
 DECLARE dpendingrev_cd = f8 WITH public, noconstant(0.0)
 DECLARE sbr_get_min_date(null) = dq8
 DECLARE batchsize = i2 WITH protect, noconstant(7)
 DECLARE maxdate = dq8 WITH protect
 DECLARE curmindate = dq8 WITH protect
 DECLARE curmaxdate = dq8 WITH protect
 DECLARE rowsleft = i4 WITH protect, noconstant(request->max_rows)
 DECLARE v_rows = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE v_errmsg2 = c132 WITH noconstant(fillstring(132," "))
 DECLARE v_err_code2 = i4 WITH noconstant(0)
 SET code_set = 6004
 SET cdf_meaning = "COMPLETED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,completed_cd)
 IF (stat != 0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"COMPLETED",
   "Unable to find code_value for CDF meaning 'COMPLETED' in codeset 6004")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET code_set = 6004
 SET cdf_meaning = "CANCELED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,cancelled_cd)
 IF (stat != 0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"CANCELED",
   "Unable to find code_value for CDF meaning 'CANCELED' in codeset 6004")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET code_set = 6004
 SET cdf_meaning = "ORDERED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,ordered_cd)
 IF (stat != 0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"ORDERED",
   "Unable to find code_value for CDF meaning 'ORDERED' in codeset 6004")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET code_set = 6004
 SET cdf_meaning = "DISCONTINUED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,ddiscontinued_cd)
 IF (stat != 0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"DISCONTINUED",
   "Unable to find code_value for CDF meaning 'DISCONTINUED' in codeset 6004")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET code_set = 6004
 SET cdf_meaning = "DELETED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,ddeleted_cd)
 IF (stat != 0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"DELETED",
   "Unable to find code_value for CDF meaning 'DELETED' in codeset 6004")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET code_set = 6004
 SET cdf_meaning = "TRANS/CANCEL"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,dtransfercancel_cd)
 IF (stat != 0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"TRANS/CANCEL",
   "Unable to find code_value for CDF meaning 'TRANS/CANCEL' in codeset 6004")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET code_set = 6004
 SET cdf_meaning = "VOIDEDWRSLT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,dvoided_cd)
 IF (stat != 0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"VOIDEDWRSLT",
   "Unable to find code_value for CDF meaning 'VOIDEDWRSLT' in codeset 6004")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET code_set = 6004
 SET cdf_meaning = "FUTURE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,dfuture_cd)
 IF (stat != 0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"FUTURE",
   "Unable to find code_value for CDF meaning 'FUTURE' in codeset 6004")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET code_set = 6004
 SET cdf_meaning = "INPROCESS"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,dinprocess_cd)
 IF (stat != 0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"INPROCESS",
   "Unable to find code_value for CDF meaning 'INPROCESS' in codeset 6004")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET code_set = 6004
 SET cdf_meaning = "MEDSTUDENT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,dmedstudent_cd)
 IF (stat != 0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"MEDSTUDENT",
   "Unable to find code_value for CDF meaning 'MEDSTUDENT' in codeset 6004")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET code_set = 6004
 SET cdf_meaning = "PENDING"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,dpending_cd)
 IF (stat != 0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"PENDING",
   "Unable to find code_value for CDF meaning 'PENDING' in codeset 6004")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET code_set = 6004
 SET cdf_meaning = "PENDING REV"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,dpendingrev_cd)
 IF (stat != 0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"PENDING REV",
   "Unable to find code_value for CDF meaning 'PENDING REV' in codeset 6004")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 DECLARE days_to_keep = i4 WITH protect, noconstant(- (1))
 DECLARE retention_mode = i4 WITH protect, noconstant(- (1))
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF (cnvtupper(request->tokens[tok_ndx].token_str)="DAYSTOKEEP")
    SET days_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ELSEIF (cnvtupper(request->tokens[tok_ndx].token_str)="RETENTIONMODE")
    SET retention_mode = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ENDIF
 ENDFOR
 IF (days_to_keep < 1)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"DAYSTOKEEP",
   "You must keep at least 1 day worth of data.  You entered %1 days or did not enter any value.",
   "i",days_to_keep)
 ELSEIF (((retention_mode < 0) OR (retention_mode > 1)) )
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"RETENTIONMODE",
   "You must enter a data evaluation mode flag of 0 or 1.  You entered %1 or did not enter any value.",
   "i",retention_mode)
 ELSE
  IF (batch_ndx=1)
   SET curmindate = sbr_get_min_date(null)
  ELSE
   SET curmindate = sbr_fetch_starting_id(null)
  ENDIF
  SET maxdate = cnvtdatetime((curdate - days_to_keep),curtime3)
  SET curmaxdate = minval(maxdate,datetimeadd(curmindate,batchsize))
  WHILE (curmindate <= maxdate
   AND rowsleft > 0)
    IF (retention_mode=1
     AND rowsleft > 0)
     SELECT INTO "nl:"
      FROM (
       (
       (SELECT
        ce.rowid, ce.charge_event_id, ce.order_id,
        o.order_status_cd
        FROM charge_event ce,
         orders o
        WHERE ce.updt_dt_tm >= cnvtdatetime(curmindate)
         AND ce.updt_dt_tm <= cnvtdatetime(curmaxdate)
         AND parser(sbr_getrowidnotexists("ce.charge_event_id > 0","ce"))
         AND ce.order_id != 0
         AND o.order_id=ce.order_id
         AND o.order_status_cd IN (completed_cd, cancelled_cd, ddiscontinued_cd, ddeleted_cd,
        dtransfercancel_cd,
        dvoided_cd)
        WITH sqltype("VC","F8","F8","F8")))
       a)
      WHERE  NOT ( EXISTS (
      (SELECT
       c.charge_event_id
       FROM charge c
       WHERE c.charge_event_id=a.charge_event_id
        AND c.process_flg IN (0, 1, 2, 3, 4,
       8, 100))))
       AND  NOT ( EXISTS (
      (SELECT
       oa.order_id
       FROM order_action oa
       WHERE oa.order_id=a.order_id
        AND oa.order_status_cd=a.order_status_cd
        AND oa.action_dt_tm > cnvtdatetime((curdate - days_to_keep),curtime3))))
      DETAIL
       v_rows = (v_rows+ 1)
       IF (mod(v_rows,100)=1)
        stat = alterlist(reply->rows,(v_rows+ 99))
       ENDIF
       reply->rows[v_rows].row_id = a.rowid
      WITH nocounter, maxqual(a,value(rowsleft))
     ;end select
     SET v_err_code2 = error(v_errmsg2,0)
     IF (v_err_code2 != 0)
      SET reply->err_code = v_err_code2
      SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR2",
       "Failed in row collection: %1","s",nullterm(v_errmsg2))
      GO TO exit_script
     ENDIF
     SET rowsleft = (request->max_rows - v_rows)
    ENDIF
    IF (rowsleft > 0)
     SELECT INTO "nl:"
      FROM charge_event ce
      WHERE ce.updt_dt_tm >= cnvtdatetime(curmindate)
       AND ce.updt_dt_tm <= cnvtdatetime(curmaxdate)
       AND parser(sbr_getrowidnotexists("ce.charge_event_id > 0","ce"))
       AND  NOT ( EXISTS (
      (SELECT
       c.charge_item_id
       FROM charge c
       WHERE c.charge_event_id=ce.charge_event_id)))
       AND  NOT ( EXISTS (
      (SELECT
       o.order_id
       FROM orders o
       WHERE o.order_id=ce.order_id
        AND ce.order_id > 0
        AND o.order_status_cd IN (ordered_cd, dfuture_cd, dinprocess_cd, dmedstudent_cd, dpending_cd,
       dpendingrev_cd))))
      HEAD REPORT
       dup_check = 0
      DETAIL
       IF (retention_mode=1)
        dup_check = locateval(num,1,size(reply->rows,5),ce.rowid,reply->rows[num].row_id)
       ENDIF
       IF (dup_check=0)
        v_rows = (v_rows+ 1)
        IF (mod(v_rows,100)=1)
         stat = alterlist(reply->rows,(v_rows+ 99))
        ENDIF
        reply->rows[v_rows].row_id = ce.rowid
       ENDIF
      WITH nocounter, maxqual(ce,value(rowsleft))
     ;end select
     SET v_err_code2 = error(v_errmsg2,0)
     IF (v_err_code2 != 0)
      SET reply->err_code = v_err_code2
      SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR1",
       "Failed in row collection: %1","s",nullterm(v_errmsg2))
      GO TO exit_script
     ENDIF
     SET rowsleft = (request->max_rows - v_rows)
    ENDIF
    CALL sbr_update_starting_id(curmindate)
    SET curmindate = cnvtlookahead("1,S",curmaxdate)
    SET curmaxdate = minval(maxdate,datetimeadd(curmindate,batchsize))
  ENDWHILE
  SET stat = alterlist(reply->rows,v_rows)
  IF (validate(cs_purge_dbg,"N")="Y")
   CALL echorecord(reply)
  ENDIF
  IF ((request->purge_flag=c_audit))
   IF (size(reply->rows,5) > 0)
    UPDATE  FROM charge_event ce,
      (dummyt d  WITH seq = value(size(reply->rows,5)))
     SET ce.updt_task = 951270.0
     PLAN (d)
      JOIN (ce
      WHERE (ce.rowid=reply->rows[d.seq].row_id))
     WITH nocounter
    ;end update
    SET v_err_code2 = error(v_errmsg2,0)
    IF (v_err_code2 != 0)
     SET reply->err_code = v_err_code2
     SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"UPDATEERROR",
      "Failed to update charge event row: %1","s",nullterm(v_errmsg2))
     ROLLBACK
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
   ENDIF
  ENDIF
  SET reply->status_data.status = "S"
  SET reply->err_code = 0
 ENDIF
 SUBROUTINE sbr_get_min_date(null)
   DECLARE zerorowdate = dq8
   DECLARE mindate = dq8
   SELECT INTO "nl:"
    seqval = min(ce.updt_dt_tm)
    FROM charge_event ce
    WHERE ce.charge_event_id=0.0
    DETAIL
     zerorowdate = seqval
    WITH nocounter
   ;end select
   SET v_err_code2 = error(v_errmsg2,0)
   IF (v_err_code2 != 0)
    SET reply->err_code = v_err_code2
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"SELECTERROR1",
     "Failed to select zero row date:%1","s",nullterm(v_errmsg2))
    GO TO exit_script
   ENDIF
   UPDATE  FROM charge_event ce
    SET ce.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE ce.charge_event_id=0.0
    WITH nocounter
   ;end update
   SET v_err_code2 = error(v_errmsg2,0)
   IF (v_err_code2 != 0)
    SET reply->err_code = v_err_code2
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"UPDATEERROR1",
     "Failed to set ce.updt_dt_tm to curdate:%1","s",nullterm(v_errmsg2))
    ROLLBACK
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   SELECT INTO "nl:"
    seqval = min(ce.updt_dt_tm)
    FROM charge_event ce
    DETAIL
     mindate = seqval
    WITH nocounter
   ;end select
   SET v_err_code2 = error(v_errmsg2,0)
   IF (v_err_code2 != 0)
    SET reply->err_code = v_err_code2
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"SELECTERROR2",
     "Failed to select zero row date:%1","s",nullterm(v_errmsg2))
    GO TO exit_script
   ENDIF
   UPDATE  FROM charge_event ce
    SET ce.updt_dt_tm = cnvtdatetime(zerorowdate)
    WHERE ce.charge_event_id=0.0
    WITH nocounter
   ;end update
   SET v_err_code2 = error(v_errmsg2,0)
   IF (v_err_code2 != 0)
    SET reply->err_code = v_err_code2
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"UPDATEERROR2",
     "Failed to set ce.updt_dt_tm to original date:%1","s",nullterm(v_errmsg2))
    ROLLBACK
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   RETURN(mindate)
 END ;Subroutine
#exit_script
END GO

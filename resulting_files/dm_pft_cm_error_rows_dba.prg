CREATE PROGRAM dm_pft_cm_error_rows:dba
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
 SET reply->table_name = "PFT_CM_ERROR"
 SET reply->rows_between_commit = 100
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE v_days_to_keep = i4 WITH protect, noconstant(- (1))
 DECLARE v_token_idx = i4 WITH protect, noconstant(0)
 DECLARE batchsize = f8 WITH protect, noconstant(50000.0)
 DECLARE maxid = f8 WITH protect, noconstant(0.0)
 DECLARE curminid = f8 WITH protect, noconstant(1.0)
 DECLARE curmaxid = f8 WITH protect, noconstant(0.0)
 DECLARE rowsleft = i4 WITH protect, noconstant(request->max_rows)
 DECLARE rowcnt = i4 WITH protect, noconstant(0)
 DECLARE v_errcode2 = i4 WITH protect, noconstant(0)
 DECLARE v_errmsg2 = vc WITH protect, noconstant("")
 FOR (v_token_idx = 1 TO size(request->tokens,5))
   IF ((request->tokens[v_token_idx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = ceil(cnvtreal(request->tokens[v_token_idx].value))
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 731)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s1",
   "You must keep at least 731 days' worth of data. You entered %1 days or did not enter any value.",
   "i",v_days_to_keep)
  GO TO exit_script
 ENDIF
 IF (batch_ndx=1)
  SELECT INTO "nl:"
   minval = min(pce.pft_cm_error_id)
   FROM pft_cm_error pce
   WHERE pce.pft_cm_error_id > 0
   DETAIL
    curminid = maxval(cnvtreal(minval),1.0)
   WITH nocounter
  ;end select
 ELSE
  SET curminid = sbr_fetch_starting_id(null)
 ENDIF
 SELECT INTO "nl:"
  maxval = max(pce.pft_cm_error_id)
  FROM pft_cm_error pce
  DETAIL
   maxid = cnvtreal(maxval)
  WITH nocounter
 ;end select
 SET curmaxid = (curminid+ (batchsize - 1))
 WHILE (curminid <= maxid
  AND rowsleft > 0)
   SELECT INTO "nl:"
    pce.rowid
    FROM pft_cm_error pce
    WHERE pce.pft_cm_error_id BETWEEN curminid AND curmaxid
     AND parser(sbr_getrowidnotexists("pce.pft_cm_error_id != 0","pce"))
     AND updt_dt_tm <= cnvtdatetime((curdate - v_days_to_keep),curtime3)
    DETAIL
     rowcnt += 1
     IF (mod(rowcnt,100)=1)
      stat = alterlist(reply->rows,(rowcnt+ 99))
     ENDIF
     reply->rows[rowcnt].row_id = pce.rowid
    WITH nocounter, maxqual(pce,value(rowsleft))
   ;end select
   SET v_errcode2 = error(v_errmsg2,1)
   IF (v_errcode2 != 0)
    SET reply->err_code = v_errcode2
    SET reply->status_data.status = "F"
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s2","Failed in row collection: %1","s",
     nullterm(v_errmsg2))
    GO TO exit_script
   ENDIF
   CALL sbr_update_starting_id(curminid)
   SET curminid = (curmaxid+ 1)
   SET curmaxid = (curminid+ (batchsize - 1))
   SET rowsleft = (request->max_rows - rowcnt)
 ENDWHILE
 SET stat = alterlist(reply->rows,rowcnt)
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#exit_script
END GO

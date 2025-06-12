CREATE PROGRAM dm_disp_generator_audit_rows:dba
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
 SET reply->status_data.status = "F"
 SET reply->table_name = "RX_DISPENSE_GENERATOR_AUDIT"
 SET reply->rows_between_commit = minval(100,request->max_rows)
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE daystokeep = i4 WITH protect, noconstant(- (1))
 DECLARE tokenindex = i4 WITH protect, noconstant(0)
 DECLARE batchsize = f8 WITH protect, constant(50000.0)
 DECLARE maximumid = f8 WITH protect, noconstant(0.0)
 DECLARE batchlowerboundid = f8 WITH protect, noconstant(1.0)
 DECLARE batchupperboundid = f8 WITH protect, noconstant(0.0)
 DECLARE rowsleft = i4 WITH protect, noconstant(request->max_rows)
 DECLARE errorcode = i4 WITH protect, noconstant(0)
 DECLARE errormessage = c123 WITH protect, noconstant("")
 FOR (tokenindex = 1 TO size(request->tokens,5))
   IF ((request->tokens[tokenindex].token_str="DAYSTOKEEP"))
    SET daystokeep = ceil(cnvtreal(request->tokens[tokenindex].value))
   ENDIF
 ENDFOR
 IF (daystokeep < 10)
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"INVALID_DAYSTOKEEP",
   "You must keep at least 10 days worth of data.  You entered %1 or did not enter any value.","i",
   daystokeep)
  GO TO exit_script
 ENDIF
 IF (batch_ndx=1)
  SELECT INTO "nl:"
   minimumvalue = min(rdga.rx_dispense_generator_audit_id)
   FROM rx_dispense_generator_audit rdga
   WHERE rdga.rx_dispense_generator_audit_id > 0.0
   DETAIL
    batchlowerboundid = maxval(cnvtreal(minimumvalue),1.0)
   WITH nocounter
  ;end select
 ELSE
  SET batchlowerboundid = sbr_fetch_starting_id(null)
 ENDIF
 SELECT INTO "nl:"
  maximumvalue = max(rdga.rx_dispense_generator_audit_id)
  FROM rx_dispense_generator_audit rdga
  DETAIL
   maximumid = cnvtreal(maximumvalue)
  WITH nocounter
 ;end select
 SET batchupperboundid = (batchlowerboundid+ (batchsize - 1))
 DECLARE recordcount = i4 WITH protect, noconstant(0)
 WHILE (batchlowerboundid <= maximumid
  AND rowsleft > 0)
   SELECT INTO "nl:"
    rdga.rx_dispense_generator_audit_id
    FROM rx_dispense_generator_audit rdga
    WHERE rdga.rx_dispense_generator_audit_id > 0
     AND parser(sbr_getrowidnotexists(
      "rdga.rx_dispense_generator_audit_id between batchLowerBoundId and batchUpperBoundId","rdga"))
     AND rdga.updt_dt_tm <= cnvtdatetime((curdate - daystokeep),235959)
    DETAIL
     recordcount = (recordcount+ 1)
     IF (mod(recordcount,100)=1)
      stat = alterlist(reply->rows,(recordcount+ 99))
     ENDIF
     reply->rows[recordcount].row_id = rdga.rowid
    WITH nocounter, maxqual(rdga,value(rowsleft))
   ;end select
   SET errorcode = error(errormessage,1)
   IF (errorcode != 0)
    SET reply->err_code = errorcode
    SET reply->status_data.status = "F"
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR",
     "Failed in row collection: %1","s",nullterm(errormessage))
    GO TO exit_script
   ENDIF
   CALL sbr_update_starting_id(batchlowerboundid)
   SET batchlowerboundid = (batchupperboundid+ 1)
   SET batchupperboundid = (batchlowerboundid+ (batchsize - 1))
   SET rowsleft = (request->max_rows - recordcount)
 ENDWHILE
 SET stat = alterlist(reply->rows,recordcount)
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#exit_script
END GO

CREATE PROGRAM dm_si_oen_skipped_msgs_rows:dba
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
 DECLARE idaystokeep = i4 WITH protect, noconstant(30)
 DECLARE icnt = i4 WITH protect, noconstant(0)
 DECLARE icnt2 = i4 WITH protect, noconstant(0)
 DECLARE v_errmsg2 = vc WITH protect, noconstant("")
 DECLARE v_err_code2 = i4 WITH protect, noconstant(0)
 DECLARE v_days_back = dq8 WITH protect, noconstant(0.0)
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 FREE RECORD trigger_row_upd
 RECORD trigger_row_upd(
   1 qual_cnt = i4
   1 qual[*]
     2 trigger_id = f8
 )
 SET reply->status_data.status = "F"
 SET reply->table_name = "SI_OEN_SKIPPED_MSGS"
 SET reply->rows_between_commit = 1000
 FOR (icnt = 1 TO size(request->tokens,5))
   IF ((request->tokens[icnt].token_str="DAYSTOKEEP"))
    SET idaystokeep = ceil(cnvtreal(request->tokens[icnt].value))
   ENDIF
 ENDFOR
 IF (idaystokeep < 30)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s2",
   "DAYSTOKEEP value should be greater than or equal to 30. You entered %1.","i",idaystokeep)
  GO TO exit_script
 ENDIF
 SET v_days_back = cnvtlookbehind(build(idaystokeep,",D"))
 SET icnt = 0
 SELECT INTO "nl:"
  sosm.trigger_id
  FROM si_oen_skipped_msgs sosm
  WHERE parser(sbr_getrowidnotexists("sosm.skipped_dt_tm < cnvtdatetime(v_days_back)","sosm"))
   AND ((sosm.si_oen_skipped_msgs_id+ 0) > 0.0)
  DETAIL
   icnt += 1
   IF (mod(icnt,100)=1)
    stat = alterlist(reply->rows,(icnt+ 99))
   ENDIF
   reply->rows[icnt].row_id = sosm.rowid
   IF (sosm.trigger_id > 0.0)
    icnt2 += 1
    IF (mod(icnt2,100)=1)
     stat = alterlist(trigger_row_upd->qual,(icnt2+ 99))
    ENDIF
    trigger_row_upd->qual[icnt2].trigger_id = sosm.trigger_id
   ENDIF
  WITH nocounter, maxqual(sosm,value(request->max_rows))
 ;end select
 SET v_errcode2 = error(v_errmsg2,1)
 IF (v_errcode2 != 0)
  SET reply->err_code = v_errcode2
  SET reply->status_data.status = "F"
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s2","Failed in row collection: %1","s",
   nullterm(v_errmsg2))
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->rows,icnt)
 SET stat = alterlist(trigger_row_upd->qual,icnt2)
 SET trigger_row_upd->qual_cnt = icnt2
 IF ((request->purge_flag != c_audit)
  AND (trigger_row_upd->qual_cnt > 0))
  UPDATE  FROM cqm_oeninterface_tr_1 cot,
    (dummyt d  WITH seq = value(trigger_row_upd->qual_cnt))
   SET cot.process_status_flag = 70, cot.updt_dt_tm = cnvtdatetime(sysdate), cot.updt_id = reqinfo->
    updt_id,
    cot.updt_task = reqinfo->updt_task, cot.updt_cnt = (cot.updt_cnt+ 1), cot.updt_applctx = reqinfo
    ->updt_applctx
   PLAN (d
    WHERE (trigger_row_upd->qual[d.seq].trigger_id > 0))
    JOIN (cot
    WHERE (cot.trigger_id=trigger_row_upd->qual[d.seq].trigger_id)
     AND cot.process_status_flag=1170)
   WITH nocounter
  ;end update
  SET v_errcode2 = error(v_errmsg2,0)
  IF (v_errcode2 != 0)
   SET reply->err_code = v_errcode2
   SET reply->status_data.status = "F"
   SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s2",
    "Failed to update cqm_oeninterface_tr_1 rows: %1","s",nullterm(v_errmsg2))
   ROLLBACK
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#exit_script
 FREE RECORD trigger_row_upd
END GO

CREATE PROGRAM dm_prefdir_entrydata_rows:dba
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
 SET reply->table_name = "PREFDIR_ENTRYDATA"
 SET reply->rows_between_commit = 50
 DECLARE startpos = i4 WITH protect, constant(11)
 DECLARE disch_cd = f8 WITH protect, noconstant(0.0)
 DECLARE encntr_cnt = i4 WITH protect, noconstant(0)
 DECLARE match_cnt = i4 WITH protect, noconstant(0)
 DECLARE list_idx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE id_cnt = i4 WITH protect, noconstant(0)
 DECLARE total_row_cnt = i4 WITH protect, noconstant(0)
 DECLARE id_idx = i4 WITH protect, noconstant(0)
 DECLARE last_idx = i4 WITH protect, noconstant(0)
 DECLARE temp_size = i4 WITH protect, noconstant(0)
 DECLARE children_exist = i2 WITH protect, noconstant(1)
 DECLARE orphan_maxrows = i4 WITH protect, noconstant((request->max_rows - 1))
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET stat = uar_get_meaning_by_codeset(261,"DISCHARGED",1,disch_cd)
 IF (disch_cd=0.0)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"DISCHARGED",
   "Unable to find CDF meaning 'DISCHARGED' in code set 261")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 FREE RECORD encntr_list
 RECORD encntr_list(
   1 qual[*]
     2 entry_id = f8
     2 dist_name = vc
     2 encntr_id = f8
     2 rowid = vc
 )
 FREE RECORD reply_temp
 RECORD reply_temp(
   1 rows[*]
     2 row_id = vc
     2 entry_id = f8
 )
 FREE RECORD encntr_root
 RECORD encntr_root(
   1 list_0[*]
     2 entry_id = f8
     2 rowid = vc
 )
 SELECT INTO "nl:"
  FROM prefdir_entrydata pe
  WHERE pe.parent_id IN (
  (SELECT
   pe2.entry_id
   FROM prefdir_entrydata pe2
   WHERE pe2.dist_name_short="prefcontext=encounter,prefroot=prefroot"))
  HEAD REPORT
   encntr_cnt = 0
  DETAIL
   encntr_cnt += 1
   IF (mod(encntr_cnt,10)=1)
    stat = alterlist(encntr_list->qual,(encntr_cnt+ 9))
   ENDIF
   encntr_list->qual[encntr_cnt].entry_id = pe.entry_id, encntr_list->qual[encntr_cnt].dist_name =
   trim(pe.dist_name), encntr_list->qual[encntr_cnt].rowid = pe.rowid
  FOOT REPORT
   stat = alterlist(encntr_list->qual,encntr_cnt)
  WITH nocounter
 ;end select
 IF (encntr_cnt > 0)
  FOR (list_idx = 1 TO encntr_cnt)
   SET pos = findstring(",prefcontext=encounter",encntr_list->qual[list_idx].dist_name,0)
   SET encntr_list->qual[list_idx].encntr_id = cnvtreal(substring(startpos,(pos - startpos),
     encntr_list->qual[list_idx].dist_name))
  ENDFOR
  SELECT INTO "nl:"
   FROM encounter e,
    (dummyt d  WITH seq = value(encntr_cnt))
   PLAN (d)
    JOIN (e
    WHERE (e.encntr_id=encntr_list->qual[d.seq].encntr_id)
     AND ((e.encntr_status_cd=disch_cd) OR (e.active_ind=0)) )
   HEAD REPORT
    match_cnt = 0
   DETAIL
    match_cnt += 1
    IF (mod(match_cnt,10)=1)
     stat = alterlist(encntr_root->list_0,(match_cnt+ 9))
    ENDIF
    encntr_root->list_0[match_cnt].entry_id = encntr_list->qual[d.seq].entry_id, encntr_root->list_0[
    match_cnt].rowid = encntr_list->qual[d.seq].rowid
   FOOT REPORT
    stat = alterlist(encntr_root->list_0,match_cnt)
   WITH nocounter
  ;end select
  FREE RECORD encntr_list
  FOR (list_idx = 1 TO match_cnt)
    SET stat = alterlist(reply_temp->rows,1)
    SET reply_temp->rows[1].row_id = encntr_root->list_0[list_idx].rowid
    SET reply_temp->rows[1].entry_id = encntr_root->list_0[list_idx].entry_id
    SET children_exist = 1
    SET last_idx = 0
    SET id_cnt = 1
    SET stat = alterlist(reply_temp->rows,10)
    WHILE (children_exist=1)
      SET start_idx = last_idx
      SET temp_size = id_cnt
      SET children_exist = 0
      SELECT INTO "nl:"
       FROM prefdir_entrydata pe,
        (dummyt d  WITH seq = value(temp_size))
       PLAN (d
        WHERE d.seq > start_idx
         AND (reply_temp->rows[d.seq].entry_id > 0.0))
        JOIN (pe
        WHERE parser(sbr_getrowidnotexists("pe.parent_id = reply_temp->rows[d.seq].entry_id","pe")))
       HEAD REPORT
        children_exist = 1
       DETAIL
        last_idx = d.seq, id_cnt += 1
        IF (mod(id_cnt,10)=1)
         stat = alterlist(reply_temp->rows,(id_cnt+ 9))
        ENDIF
        reply_temp->rows[id_cnt].entry_id = pe.entry_id, reply_temp->rows[id_cnt].row_id = pe.rowid
       WITH nocounter
      ;end select
      SET reply->err_code = error(reply->err_msg,1)
      IF ((reply->err_code > 0))
       SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR",
        "Failed in building tree for root ID %1: %2","ds",encntr_root->list_0[list_idx].entry_id,
        nullterm(reply->err_msg))
       SET reply->status_data.status = "F"
       GO TO exit_script
      ENDIF
    ENDWHILE
    IF (((id_cnt+ total_row_cnt) >= orphan_maxrows))
     SET id_idx = id_cnt
     WHILE (id_idx > 0
      AND (total_row_cnt <= request->max_rows))
       SET total_row_cnt += 1
       IF (mod(total_row_cnt,100)=1)
        SET stat = alterlist(reply->rows,(total_row_cnt+ 99))
       ENDIF
       SET reply->rows[total_row_cnt].row_id = reply_temp->rows[id_idx].row_id
       SET id_idx -= 1
     ENDWHILE
     GO TO finish_script
    ELSE
     FOR (id_idx = 1 TO id_cnt)
       SET total_row_cnt += 1
       IF (mod(total_row_cnt,100)=1)
        SET stat = alterlist(reply->rows,(total_row_cnt+ 99))
       ENDIF
       SET reply->rows[total_row_cnt].row_id = reply_temp->rows[id_idx].row_id
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
#finish_script
 SET stat = alterlist(reply->rows,total_row_cnt)
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#exit_script
 FREE RECORD reply_temp
 FREE RECORD encntr_root
 FREE RECORD encntr_list
END GO

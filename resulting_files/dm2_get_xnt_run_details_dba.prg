CREATE PROGRAM dm2_get_xnt_run_details:dba
 DECLARE dphc_active_flag = vc WITH protect, constant("ACTIVE_FLAG")
 DECLARE dphc_purge_flag = vc WITH protect, constant("PURGE_FLAG")
 DECLARE dphc_max_rows = vc WITH protect, constant("MAX_ROWS")
 DECLARE dphc_jobname = vc WITH protect, constant("JOBNAME")
 DECLARE dphc_new_token = vc WITH protect, constant("NEW TOKEN")
 DECLARE dphc_del_token = vc WITH protect, constant("DEL TOKEN")
 DECLARE dphc_token_change = vc WITH protect, constant("TOKEN")
 IF ((validate(dph_history->data_cnt,- (1))=- (1)))
  RECORD dph_history(
    1 job_id = f8
    1 data_cnt = i4
    1 data[*]
      2 change_type = vc
      2 old_value_float = f8
      2 new_value_float = f8
      2 old_value_char = vc
      2 new_value_char = vc
      2 token_name = vc
  )
 ENDIF
 DECLARE dm2_purge_sethistoryjobid(sbr_jobid=f8) = null
 DECLARE dm2_purge_addhistoryrec(sbr_changetype=vc,sbr_oldvalue=f8,sbr_newvalue=f8,sbr_tokenstr=vc)
  = null
 DECLARE dm2_purge_addhistoryrecchar(sbr_changetype=vc,sbr_oldvalue=vc,sbr_newvalue=vc,sbr_tokenstr=
  vc) = null
 DECLARE dm2_purge_addmaxrowshistory(sbr_oldvalue=f8,sbr_newvalue=f8) = null
 DECLARE dm2_purge_addpurgeflaghistory(sbr_oldvalue=f8,sbr_newvalue=f8) = null
 DECLARE dm2_purge_addactiveflaghistory(sbr_oldvalue=f8,sbr_newvalue=f8) = null
 DECLARE dm2_purge_addnewtokenhistory(sbr_newvalue=f8,sbr_tokenstr=vc) = null
 DECLARE dm2_purge_addnewtokenhistorychar(sbr_newvalue=vc,sbr_tokenstr=vc) = null
 DECLARE dm2_purge_adddeletetokenhistory(sbr_oldvalue=f8,sbr_tokenstr=vc) = null
 DECLARE dm2_purge_adddeletetokenhistorychar(sbr_oldvalue=vc,sbr_tokenstr=vc) = null
 DECLARE dm2_purge_addtokenchangehistory(sbr_oldvalue=f8,sbr_newvalue=f8,sbr_tokenstr=vc) = null
 DECLARE dm2_purge_addtokenchangehistorychar(sbr_oldvalue=vc,sbr_newvalue=vc,sbr_tokenstr=vc) = null
 DECLARE dm2_purge_inserthistory(null) = null
 DECLARE dm2_purge_cleanup(null) = null
 SUBROUTINE dm2_purge_sethistoryjobid(sbr_jobid)
   SET dph_history->job_id = sbr_jobid
 END ;Subroutine
 SUBROUTINE dm2_purge_addhistoryrec(sbr_changetype,sbr_oldvalue,sbr_newvalue,sbr_tokenstr)
   SET dph_history->data_cnt = (dph_history->data_cnt+ 1)
   SET stat = alterlist(dph_history->data,dph_history->data_cnt)
   SET dph_history->data[dph_history->data_cnt].change_type = cnvtupper(sbr_changetype)
   SET dph_history->data[dph_history->data_cnt].old_value_float = sbr_oldvalue
   SET dph_history->data[dph_history->data_cnt].new_value_float = sbr_newvalue
   SET dph_history->data[dph_history->data_cnt].old_value_char = cnvtstring(sbr_oldvalue)
   SET dph_history->data[dph_history->data_cnt].new_value_char = cnvtstring(sbr_newvalue)
   SET dph_history->data[dph_history->data_cnt].token_name = cnvtupper(sbr_tokenstr)
 END ;Subroutine
 SUBROUTINE dm2_purge_addhistoryrecchar(sbr_changetype,sbr_oldvalue,sbr_newvalue,sbr_tokenstr)
   SET dph_history->data_cnt = (dph_history->data_cnt+ 1)
   SET stat = alterlist(dph_history->data,dph_history->data_cnt)
   SET dph_history->data[dph_history->data_cnt].change_type = cnvtupper(sbr_changetype)
   SET dph_history->data[dph_history->data_cnt].old_value_float = cnvtreal(sbr_oldvalue)
   SET dph_history->data[dph_history->data_cnt].new_value_float = cnvtreal(sbr_newvalue)
   SET dph_history->data[dph_history->data_cnt].old_value_char = sbr_oldvalue
   SET dph_history->data[dph_history->data_cnt].new_value_char = sbr_newvalue
   SET dph_history->data[dph_history->data_cnt].token_name = cnvtupper(sbr_tokenstr)
 END ;Subroutine
 SUBROUTINE dm2_purge_addmaxrowshistory(sbr_oldvalue,sbr_newvalue)
   CALL dm2_purge_addhistoryrec(dphc_max_rows,sbr_oldvalue,sbr_newvalue," ")
 END ;Subroutine
 SUBROUTINE dm2_purge_addpurgeflaghistory(sbr_oldvalue,sbr_newvalue)
   CALL dm2_purge_addhistoryrec(dphc_purge_flag,sbr_oldvalue,sbr_newvalue," ")
 END ;Subroutine
 SUBROUTINE dm2_purge_addactiveflaghistory(sbr_oldvalue,sbr_newvalue)
   CALL dm2_purge_addhistoryrec(dphc_active_flag,sbr_oldvalue,sbr_newvalue," ")
 END ;Subroutine
 SUBROUTINE dm2_purge_addnewtokenhistory(sbr_newvalue,sbr_tokenstr)
   CALL dm2_purge_addhistoryrec(dphc_new_token,0.0,sbr_newvalue,sbr_tokenstr)
 END ;Subroutine
 SUBROUTINE dm2_purge_addnewtokenhistorychar(sbr_newvalue,sbr_tokenstr)
   CALL dm2_purge_addhistoryrecchar(dphc_new_token,"",sbr_newvalue,sbr_tokenstr)
 END ;Subroutine
 SUBROUTINE dm2_purge_adddeletetokenhistory(sbr_oldvalue,sbr_tokenstr)
   CALL dm2_purge_addhistoryrec(dphc_del_token,sbr_oldvalue,0.0,sbr_tokenstr)
 END ;Subroutine
 SUBROUTINE dm2_purge_adddeletetokenhistorychar(sbr_oldvalue,sbr_tokenstr)
   CALL dm2_purge_addhistoryrecchar(dphc_del_token,sbr_oldvalue,"0.0",sbr_tokenstr)
 END ;Subroutine
 SUBROUTINE dm2_purge_addtokenchangehistory(sbr_oldvalue,sbr_newvalue,sbr_tokenstr)
   CALL dm2_purge_addhistoryrec(dphc_token_change,sbr_oldvalue,sbr_newvalue,sbr_tokenstr)
 END ;Subroutine
 SUBROUTINE dm2_purge_addtokenchangehistorychar(sbr_oldvalue,sbr_newvalue,sbr_tokenstr)
   CALL dm2_purge_addhistoryrecchar(dphc_token_change,sbr_oldvalue,sbr_newvalue,sbr_tokenstr)
 END ;Subroutine
 SUBROUTINE dm2_purge_inserthistory(null)
  DECLARE sbr_updtdttm = dq8 WITH protect, noconstant(0.0)
  IF ((dph_history->data_cnt > 0))
   SET sbr_updtdttm = cnvtdatetime(curdate,curtime3)
   INSERT  FROM dm_purge_history dph,
     (dummyt d  WITH seq = value(dph_history->data_cnt))
    SET dph.dm_purge_history_id = seq(dm_clinical_seq,nextval), dph.job_id = dph_history->job_id, dph
     .change_type = dph_history->data[d.seq].change_type,
     dph.old_value = dph_history->data[d.seq].old_value_float, dph.new_value = dph_history->data[d
     .seq].new_value_float, dph.old_token_string_value = dph_history->data[d.seq].old_value_char,
     dph.new_token_string_value = dph_history->data[d.seq].new_value_char, dph.token_str =
     dph_history->data[d.seq].token_name, dph.updt_id = reqinfo->updt_id,
     dph.updt_dt_tm = cnvtdatetime(sbr_updtdttm), dph.updt_task = reqinfo->updt_task, dph
     .updt_applctx = reqinfo->updt_applctx,
     dph.updt_cnt = 0
    PLAN (d)
     JOIN (dph)
    WITH nocounter
   ;end insert
  ENDIF
 END ;Subroutine
 SUBROUTINE dm2_purge_cleanup(null)
   FREE RECORD dph_history
 END ;Subroutine
 IF ((validate(request->job_id,- (1))=- (1)))
  RECORD request(
    1 job_id = f8
  )
 ENDIF
 IF (validate(reply->validationfield,"Z")="Z")
  RECORD reply(
    1 validationfield = c1
    1 run_cnt = i4
    1 runs[*]
      2 begin_dt_tm = dq8
      2 end_dt_tm = dq8
      2 status = vc
      2 err_msg = vc
      2 total_rows_extracted = i4
      2 table_cnt = i4
      2 tables[*]
        3 table_name = vc
        3 rows_extracted = i4
        3 tablespace_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD dgxrd_logids
 RECORD dgxrd_logids(
   1 log_id_cnt = i4
   1 list[*]
     2 extract_status = vc
     2 log_id = f8
 )
 FREE RECORD dgxrd_tables
 RECORD dgxrd_tables(
   1 table_cnt = i4
   1 list[*]
     2 table_name = vc
     2 tablespace_name = vc
 )
 SET reply->status_data.status = "F"
 DECLARE dgxrd_errmsg = vc WITH protect, noconstant("")
 DECLARE dgxrd_loop = i4 WITH protect, noconstant(0)
 DECLARE dgxrd_table_loop = i4 WITH protect, noconstant(0)
 DECLARE dgxrd_lval_idx = i4 WITH protect, noconstant(0)
 DECLARE dgxrd_table_idx = i4 WITH protect, noconstant(0)
 DECLARE dgxrd_i18nhandle = i4 WITH protect, noconstant(0)
 SET stat = uar_i18nlocalizationinit(dgxrd_i18nhandle,curprog,"",curcclrev)
 IF ((request->job_id <= 0))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "validationg job id"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = curprog
  SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(dgxrd_i18nhandle,
   "BADJOB","Invalid job ID: %1","d",request->job_id)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_xnt_job_log dxjl,
   dm_xnt_job_log_dtl dxjld
  PLAN (dxjl
   WHERE (dxjl.job_id=request->job_id))
   JOIN (dxjld
   WHERE dxjld.dm_xnt_job_log_id=outerjoin(dxjl.dm_xnt_job_log_id))
  DETAIL
   reply->run_cnt = (reply->run_cnt+ 1)
   IF (mod(reply->run_cnt,100)=1)
    stat = alterlist(reply->runs,(reply->run_cnt+ 99)), stat = alterlist(dgxrd_logids->list,(reply->
     run_cnt+ 99))
   ENDIF
   dgxrd_logids->list[reply->run_cnt].log_id = dxjld.dm_xnt_job_log_dtl_id, dgxrd_logids->list[reply
   ->run_cnt].extract_status = dxjld.extract_status, reply->runs[reply->run_cnt].begin_dt_tm = dxjl
   .start_dt_tm,
   reply->runs[reply->run_cnt].end_dt_tm = dxjl.end_dt_tm, reply->runs[reply->run_cnt].status = dxjl
   .status, reply->runs[reply->run_cnt].err_msg = dxjl.error_msg,
   reply->runs[reply->run_cnt].total_rows_extracted = dxjl.total_rows
  FOOT REPORT
   stat = alterlist(reply->runs,reply->run_cnt), stat = alterlist(dgxrd_logids->list,reply->run_cnt)
  WITH nocounter
 ;end select
 IF (error(dgxrd_errmsg,0) != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "fetching logs"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = curprog
  SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(dgxrd_i18nhandle,
   "LOGERROR","Failed to fetch run logs: %1","s",dgxrd_errmsg)
  GO TO exit_script
 ENDIF
 IF ((reply->run_cnt > 0))
  SELECT INTO "nl:"
   FROM dm_xnt_job_log_cnt dxjlc,
    (dummyt d  WITH seq = value(reply->run_cnt))
   PLAN (d
    WHERE (dgxrd_logids->list[d.seq].log_id > 0))
    JOIN (dxjlc
    WHERE (dxjlc.dm_xnt_job_log_dtl_id=dgxrd_logids->list[d.seq].log_id))
   DETAIL
    reply->runs[d.seq].table_cnt = (reply->runs[d.seq].table_cnt+ 1), stat = alterlist(reply->runs[d
     .seq].tables,reply->runs[d.seq].table_cnt), reply->runs[d.seq].tables[reply->runs[d.seq].
    table_cnt].table_name = dxjlc.table_name
    IF ((dgxrd_logids->list[d.seq].extract_status="SUCCESS"))
     reply->runs[d.seq].tables[reply->runs[d.seq].table_cnt].rows_extracted = dxjlc.rows_extracted
    ELSE
     reply->runs[d.seq].tables[reply->runs[d.seq].table_cnt].rows_extracted = 0
    ENDIF
    IF (locateval(dgxrd_lval_idx,1,dgxrd_tables->table_cnt,dxjlc.table_name,dgxrd_tables->list[
     dgxrd_lval_idx].table_name)=0)
     dgxrd_tables->table_cnt = (dgxrd_tables->table_cnt+ 1), stat = alterlist(dgxrd_tables->list,
      dgxrd_tables->table_cnt), dgxrd_tables->list[dgxrd_tables->table_cnt].table_name = dxjlc
     .table_name
    ENDIF
   WITH nocounter
  ;end select
  IF (error(dgxrd_errmsg,0) != 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "fetching logs"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = curprog
   SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(dgxrd_i18nhandle,
    "DTLERROR","Failed to fetch run details: %1","s",dgxrd_errmsg)
   GO TO exit_script
  ENDIF
  IF ((dgxrd_tables->table_cnt > 0))
   SELECT INTO "nl:"
    FROM user_tables ut,
     (dummyt d  WITH seq = value(dgxrd_tables->table_cnt))
    PLAN (d)
     JOIN (ut
     WHERE (ut.table_name=dgxrd_tables->list[d.seq].table_name))
    DETAIL
     dgxrd_tables->list[d.seq].tablespace_name = ut.tablespace_name
    WITH nocounter
   ;end select
   IF (error(dgxrd_errmsg,0) != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "fetching logs"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = curprog
    SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(
     dgxrd_i18nhandle,"TBLERROR","Failed to fetch table details: %1","s",dgxrd_errmsg)
    GO TO exit_script
   ENDIF
   FOR (dgxrd_loop = 1 TO reply->run_cnt)
     FOR (dgxrd_table_loop = 1 TO reply->runs[dgxrd_loop].table_cnt)
      SET dgxrd_table_idx = locateval(dgxrd_lval_idx,1,dgxrd_tables->table_cnt,reply->runs[dgxrd_loop
       ].tables[dgxrd_table_loop].table_name,dgxrd_tables->list[dgxrd_lval_idx].table_name)
      IF (dgxrd_table_idx > 0)
       SET reply->runs[dgxrd_loop].tables[dgxrd_table_loop].tablespace_name = dgxrd_tables->list[
       dgxrd_table_idx].tablespace_name
      ENDIF
     ENDFOR
   ENDFOR
   IF (error(dgxrd_errmsg,0) != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "fetching logs"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = curprog
    SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(
     dgxrd_i18nhandle,"TBLDTLERR","Failed to copy table details: %1","s",dgxrd_errmsg)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 FREE RECORD dgxrd_logids
 FREE RECORD dgxrd_tables
END GO

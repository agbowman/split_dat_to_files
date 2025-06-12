CREATE PROGRAM dm2_get_purge_run_details:dba
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
 IF ((validate(request->log_id,- (1.0))=- (1.0)))
  RECORD request(
    1 log_id = f8
  )
 ENDIF
 IF ((validate(reply->qual_cnt,- (1))=- (1)))
  RECORD reply(
    1 table_cnt = i4
    1 index_cnt = i4
    1 has_rowid_lookup_ind = i2
    1 rowid_lookup_tm = f8
    1 tables[*]
      2 table_name = vc
      2 has_purge_time_ind = i2
      2 purge_time = f8
      2 has_rows_deleted_ind = i2
      2 rows_deleted = i4
    1 indexes[*]
      2 index_name = vc
      2 has_coalesce_ind = i2
      2 coalesce_time = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE dgprd_errmsg = vc WITH protect, noconstant("")
 DECLARE dgprd_table_name = vc WITH protect, noconstant("")
 DECLARE dgprd_table_idx = i4 WITH protect, noconstant(0)
 DECLARE dgprd_index_name = vc WITH protect, noconstant("")
 DECLARE dgprd_lval_idx = i4 WITH protect, noconstant(0)
 DECLARE dgprd_purge_flag = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM dm_purge_job_log dpjl
  WHERE (dpjl.log_id=request->log_id)
  DETAIL
   dgprd_purge_flag = dpjl.purge_flag
   IF (dpjl.purge_flag=c_del_high_log)
    reply->table_cnt = 1, stat = alterlist(reply->tables,1), reply->tables[1].table_name = dpjl
    .parent_table,
    reply->tables[1].has_rows_deleted_ind = 1, reply->tables[1].rows_deleted = dpjl.parent_rows
   ENDIF
  WITH nocounter
 ;end select
 IF (dgprd_purge_flag=c_del_dtl_log)
  SELECT INTO "nl:"
   FROM dm_purge_job_log_tab dpjlt
   WHERE (dpjlt.log_id=request->log_id)
   DETAIL
    reply->table_cnt = (reply->table_cnt+ 1), stat = alterlist(reply->tables,reply->table_cnt), reply
    ->tables[reply->table_cnt].table_name = dpjlt.table_name,
    reply->tables[reply->table_cnt].has_rows_deleted_ind = 1, reply->tables[reply->table_cnt].
    rows_deleted = dpjlt.num_rows
   WITH nocounter
  ;end select
 ENDIF
 IF (error(dgprd_errmsg,0) > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "fetching table row counts"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = curprog
  SET reply->status_data.subeventstatus[1].targetobjectvalue = dgprd_errmsg
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_purge_job_log_timing dpjlt
  WHERE (dpjlt.log_id=request->log_id)
  DETAIL
   IF (dpjlt.value_key="ROWID_LOOKUP_TM")
    reply->has_rowid_lookup_ind = 1, reply->rowid_lookup_tm = dpjlt.value_nbr
   ELSEIF (dpjlt.value_key=patstring("TBL_TM_*"))
    dgprd_table_name = substring(8,(textlen(dpjlt.value_key) - 7),dpjlt.value_key), dgprd_table_idx
     = locateval(dgprd_lval_idx,1,reply->table_cnt,dgprd_table_name,reply->tables[dgprd_lval_idx].
     table_name)
    IF (dgprd_table_idx > 0)
     reply->tables[dgprd_table_idx].table_name = dgprd_table_name, reply->tables[dgprd_table_idx].
     has_purge_time_ind = 1, reply->tables[dgprd_table_idx].purge_time = dpjlt.value_nbr
    ENDIF
   ELSEIF (dpjlt.value_key=patstring("IDX_TM_*"))
    dgprd_index_name = substring(8,(textlen(dpjlt.value_key) - 7),dpjlt.value_key), reply->index_cnt
     = (reply->index_cnt+ 1), stat = alterlist(reply->indexes,reply->index_cnt),
    reply->indexes[reply->index_cnt].has_coalesce_ind = 1, reply->indexes[reply->index_cnt].
    coalesce_time = dpjlt.value_nbr, reply->indexes[reply->index_cnt].index_name = dgprd_index_name
   ENDIF
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO

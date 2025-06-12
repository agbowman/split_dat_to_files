CREATE PROGRAM dm_purge_get_log:dba
 FREE SET reply
 RECORD reply(
   1 data[*]
     2 log_id = f8
     2 purge_flag = i4
     2 start_date = vc
     2 end_date = vc
     2 parent_table = vc
     2 parent_rows = f8
     2 child_rows = f8
     2 err_msg = vc
     2 err_code = f8
     2 status_flag = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
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
 SET v_log_cnt = 0
 SELECT INTO "nl:"
  pl.log_id, start_date = format(pl.start_dt_tm,c_df), end_date = format(pl.end_dt_tm,c_df),
  pl.parent_table, pl.parent_rows, pl.child_rows,
  pl.err_msg, pl.err_code
  FROM dm_purge_job_log pl
  WHERE (pl.job_id=request->job_id)
  ORDER BY pl.start_dt_tm DESC
  DETAIL
   v_log_cnt = (v_log_cnt+ 1), stat = alterlist(reply->data,v_log_cnt), reply->data[v_log_cnt].log_id
    = pl.log_id,
   reply->data[v_log_cnt].start_date = start_date, reply->data[v_log_cnt].end_date = end_date, reply
   ->data[v_log_cnt].parent_table = pl.parent_table,
   reply->data[v_log_cnt].parent_rows = pl.parent_rows, reply->data[v_log_cnt].child_rows = pl
   .child_rows, reply->data[v_log_cnt].err_msg = pl.err_msg,
   reply->data[v_log_cnt].err_code = pl.err_code
   IF (pl.err_code=0)
    reply->data[v_log_cnt].status_flag = c_sf_success
   ELSE
    reply->data[v_log_cnt].status_flag = c_sf_failed
   ENDIF
   reply->data[v_log_cnt].purge_flag = pl.purge_flag
  WITH nocounter
 ;end select
 IF (size(reply->data,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

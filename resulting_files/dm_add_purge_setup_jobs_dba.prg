CREATE PROGRAM dm_add_purge_setup_jobs:dba
 RECORD reply(
   1 purge_setup_job_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET next_seq_val = 0
 SELECT INTO "nl:"
  y = seq(dm_purge_setup_job_seq,nextval)
  FROM dual
  DETAIL
   next_seq_val = cnvtreal(y), reply->purge_setup_job_id = next_seq_val
  WITH nocounter
 ;end select
 INSERT  FROM dm_purge_setup_job dpsj
  SET dpsj.purge_setup_job_id = next_seq_val, dpsj.job_id = request->job_id, dpsj.active_ind =
   request->active_ind,
   dpsj.frequency = request->frequency, dpsj.log_mode = request->log_mode, dpsj.beg_effective_dt_tm
    = cnvtdatetime(curdate,curtime3),
   dpsj.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), dpsj.last_start_dt_tm = cnvtdatetime(
    curdate,curtime3)
  WITH nocounter
 ;end insert
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
END GO

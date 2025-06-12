CREATE PROGRAM dm_add_purge_setup_job_tokens:dba
 RECORD reply(
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
 SET y = 0.0
 SELECT INTO "nl:"
  y = seq(dm_purge_setup_job_token_seq,nextval)
  FROM dual
  DETAIL
   next_seq_val = cnvtreal(y)
  WITH nocounter
 ;end select
 INSERT  FROM dm_purge_setup_job_tokens dps
  SET dps.token = request->token, dps.purge_setup_job_id = request->purge_setup_job_id, dps
   .active_ind = request->active_ind,
   dps.token_value = request->token_value, dps.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   dps.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
  WITH nocounter
 ;end insert
 SET reply->status_data.status = "S"
 COMMIT
END GO

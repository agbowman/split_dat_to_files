CREATE PROGRAM dm_add_purge_jobs:dba
 RECORD reply(
   1 job_id = f8
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
  y = seq(purge_job_seq,nextval)
  FROM dual
  DETAIL
   next_seq_val = cnvtreal(y), reply->job_id = next_seq_val
  WITH nocounter
 ;end select
 INSERT  FROM dm_purge_job dpj
  SET dpj.job_id = next_seq_val, dpj.active_ind = request->active_ind, dpj.description = request->
   description,
   dpj.parent_table = request->parent_table, dpj.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
   dpj.from_clause = request->from_clause,
   dpj.where_clause = request->where_clause
  WITH nocounter
 ;end insert
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
END GO

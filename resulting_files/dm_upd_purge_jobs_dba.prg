CREATE PROGRAM dm_upd_purge_jobs:dba
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
 UPDATE  FROM dm_purge_job dpj
  SET dpj.active_ind = request->active_ind, dpj.description = request->description, dpj.parent_table
    = request->parent_table,
   dpj.from_clause = request->from_clause, dpj.where_clause = request->where_clause
  WHERE (dpj.job_id=request->job_id)
  WITH nocounter
 ;end update
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
END GO

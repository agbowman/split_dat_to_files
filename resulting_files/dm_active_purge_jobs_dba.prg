CREATE PROGRAM dm_active_purge_jobs:dba
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
  SET dpj.active_ind = 1
  WHERE (dpj.job_id=request->job_id)
  WITH nocounter
 ;end update
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
END GO

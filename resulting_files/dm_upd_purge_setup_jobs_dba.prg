CREATE PROGRAM dm_upd_purge_setup_jobs:dba
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
 UPDATE  FROM dm_purge_setup_job dpsj
  SET dpsj.active_ind = request->active_ind, dpsj.frequency = request->frequency
  WHERE (dpsj.purge_setup_job_id=request->purge_setup_job_id)
  WITH nocounter
 ;end update
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
END GO

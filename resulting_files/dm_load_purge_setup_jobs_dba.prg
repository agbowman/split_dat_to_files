CREATE PROGRAM dm_load_purge_setup_jobs:dba
 RECORD reply(
   1 qual[*]
     2 purge_setup_job_id = f8
     2 description = c100
     2 active_ind = i2
     2 job_id = f8
     2 frequency = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET index = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  psj.purge_setup_job_id, pj.description, psj.active_ind,
  psj.job_id, psj.frequency
  FROM dm_purge_setup_job psj,
   dm_purge_job pj
  PLAN (psj)
   JOIN (pj
   WHERE pj.job_id=psj.job_id)
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].purge_setup_job_id =
   psj.purge_setup_job_id,
   reply->qual[index].description = pj.description, reply->qual[index].active_ind = psj.active_ind,
   reply->qual[index].job_id = psj.job_id,
   reply->qual[index].frequency = psj.frequency
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ENDIF
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO

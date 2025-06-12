CREATE PROGRAM dm_add_purge_job_tokens:dba
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
 INSERT  FROM dm_purge_job_tokens dps
  SET dps.token = request->token, dps.job_id = request->job_id, dps.description = request->
   description,
   dps.data_type = request->data_type, dps.default_text = request->default_text, dps.default_value =
   request->default_value
  WITH nocounter
 ;end insert
 SET reply->status_data.status = "S"
 COMMIT
END GO

CREATE PROGRAM dm_get_purge_setup_job_tokens:dba
 RECORD reply(
   1 qual[*]
     2 purge_setup_job_id = f8
     2 description = c100
     2 token = c30
     2 token_value = c40
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
  dpjt.token, dpjt.token_value, djt.description
  FROM dm_purge_setup_job_tokens dpjt,
   dm_purge_job_tokens djt
  WHERE (dpjt.purge_setup_job_id=request->purge_setup_job_id)
   AND dpjt.token=djt.token
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].purge_setup_job_id =
   request->purge_setup_job_id,
   reply->qual[index].description = djt.description, reply->qual[index].token = dpjt.token, reply->
   qual[index].token_value = dpjt.token_value
  WITH nocounter
 ;end select
 IF (index > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO

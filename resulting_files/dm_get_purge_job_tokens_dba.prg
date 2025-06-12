CREATE PROGRAM dm_get_purge_job_tokens:dba
 RECORD reply(
   1 qual[*]
     2 job_id = f8
     2 token = c30
     2 description = c100
     2 data_type = c9
     2 default_text = c100
     2 default_value = c40
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
  dpjt.token, dpjt.decsription, dpjt.data_type,
  dpjt.default_text, dpjt.default_value
  FROM dm_purge_job_tokens dpjt
  WHERE (dpjt.job_id=request->job_id)
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].job_id = request->
   job_id,
   reply->qual[index].token = dpjt.token, reply->qual[index].description = dpjt.description, reply->
   qual[index].data_type = dpjt.data_type,
   reply->qual[index].default_text = dpjt.default_text, reply->qual[index].default_value = dpjt
   .default_value
  WITH nocounter
 ;end select
 IF (index > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO

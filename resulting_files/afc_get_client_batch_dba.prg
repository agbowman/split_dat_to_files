CREATE PROGRAM afc_get_client_batch:dba
 RECORD reply(
   1 client_batch_qual = i2
   1 client_batch[*]
     2 client_batch_id = f8
     2 batch_cd = f8
     2 client_id = f8
     2 client_name = c50
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET stat = alterlist(reply->client_batch,count1)
 SELECT INTO "nl:"
  c.client_batch_id
  FROM client_batch c
  WHERE (c.batch_cd=request->batch_cd)
   AND c.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->client_batch,count1), reply->client_batch[count1].
   client_batch_id = c.client_batch_id,
   reply->client_batch[count1].batch_cd = c.batch_cd, reply->client_batch[count1].client_id = c
   .client_id, reply->client_batch[count1].client_name = c.client_name
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->client_batch,count1)
 SET reply->client_batch_qual = count1
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CLIENT_BATCH"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

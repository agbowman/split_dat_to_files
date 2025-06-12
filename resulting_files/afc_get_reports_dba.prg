CREATE PROGRAM afc_get_reports:dba
 RECORD reply(
   1 client_batch_qual = i2
   1 client_batch[*]
     2 client_batch_id = f8
     2 batch_cd = f8
     2 client_id = f8
     2 client_name = c50
     2 key1 = c200
   1 status_data
     2 status = c1
     2 subevenstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  *
  FROM client_batch cb
  WHERE cb.batch_cd IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=15569
    AND cdf_meaning="CSREPORT"))
   AND cb.active_ind=1
  DETAIL
   count = (count+ 1), stat = alterlist(reply->client_batch,count), reply->client_batch[count].
   client_batch_id = cb.client_batch_id,
   reply->client_batch[count].batch_cd = cb.batch_cd, reply->client_batch[count].client_id = cb
   .client_id, reply->client_batch[count].client_name = cb.client_name,
   reply->client_batch[count].key1 = cb.key1
  WITH nocounter
 ;end select
 SET reply->client_batch_qual = count
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CLIENT_BATCH"
  SET reply->status_data.status = "Z"
 ENDIF
END GO

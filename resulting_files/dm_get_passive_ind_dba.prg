CREATE PROGRAM dm_get_passive_ind:dba
 RECORD reply(
   1 passive_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  d.info_number
  FROM dm_info d
  WHERE d.info_name="DOMAIN_PASSIVITY_CHECK"
  DETAIL
   reply->passive_ind = d.info_number
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO

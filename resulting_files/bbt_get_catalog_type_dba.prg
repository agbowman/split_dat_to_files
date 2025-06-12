CREATE PROGRAM bbt_get_catalog_type:dba
 RECORD reply(
   1 catalog_type = vc
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
  s.*
  FROM service_directory s,
   code_value c
  PLAN (c
   WHERE c.code_set=1635)
   JOIN (s
   WHERE c.code_value=s.bb_processing_cd
    AND (request->catalog_cd=s.catalog_cd))
  DETAIL
   IF (c.cdf_meaning="PRODUCT ABO")
    reply->catalog_type = "0"
   ELSEIF (c.cdf_meaning="PATIENT ABO")
    reply->catalog_type = "1"
   ELSEIF (c.cdf_meaning="ABSC CI")
    reply->catalog_type = "3"
   ELSE
    reply->catalog_type = "2"
   ENDIF
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#stop
END GO

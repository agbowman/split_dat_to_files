CREATE PROGRAM dcp_check_duplicate_regimen
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 duplicate = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE searchstring = vc
 SET searchstring = cnvtupper(trim(request->regimen_name,3))
 SET reply->duplicate = 0
 SET reply->status_data.status = "F"
 SELECT DISTINCT INTO "nl:"
  FROM regimen_cat_synonym rc
  WHERE rc.synonym_key=searchstring
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->duplicate = 1
 ENDIF
 SET reply->status_data.status = "S"
END GO

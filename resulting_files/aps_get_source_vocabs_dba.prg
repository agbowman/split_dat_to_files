CREATE PROGRAM aps_get_source_vocabs:dba
 RECORD reply(
   1 qual[10]
     2 code_value = f8
     2 code_value_display = c40
     2 code_value_description = vc
     2 code_value_meaning = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=400
   AND cv.active_ind=1
   AND ((cv.cdf_meaning IN ("SNMI95", "SNM2", "SNMCT")
   AND (reqinfo->updt_app=200016)) OR (cv.cdf_meaning IN ("SNMI95", "SNM2", "SNMCT", "APINTERNAL",
  "ANATOMIC PAT")
   AND (reqinfo->updt_app != 200016)))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alter(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].code_value = cv.code_value, reply->qual[cnt].code_value_display = cv.display,
   reply->qual[cnt].code_value_description = cv.description,
   reply->qual[cnt].code_value_meaning = cv.cdf_meaning
  FOOT REPORT
   stat = alter(reply->qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

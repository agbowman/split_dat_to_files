CREATE PROGRAM dm_get_criteria_type:dba
 RECORD reply(
   1 archive_criteria = f8
   1 purge_criteria = f8
   1 parent_archive = f8
   1 parent_purge = f8
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
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=18249
   AND cdf_meaning="*"
  DETAIL
   IF (cv.cdf_meaning="A*")
    reply->archive_criteria = cv.code_value
   ENDIF
   IF (cv.cdf_meaning="P*")
    reply->purge_criteria = cv.code_value
   ENDIF
   IF (cv.cdf_meaning="CPARENTARCH")
    reply->parent_archive = cv.code_value
   ENDIF
   IF (cv.cdf_meaning="CPARENTPURGE")
    reply->parent_purge = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO

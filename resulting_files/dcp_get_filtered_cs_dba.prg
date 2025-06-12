CREATE PROGRAM dcp_get_filtered_cs:dba
 RECORD reply(
   1 codeset[*]
     2 code_value = f8
     2 display = c40
     2 cdf_meaning = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE reccnt = i4
 SET reccnt = 0
 SELECT INTO "nl:"
  cv.code_value, cv.display, cv.cdf_meaning,
  cve.field_value
  FROM code_value cv,
   code_value_extension cve
  PLAN (cv
   WHERE (cv.code_set=request->code_set)
    AND cv.active_ind=1)
   JOIN (cve
   WHERE cve.code_value=cv.code_value
    AND (trim(cve.field_value)=request->field_value))
  ORDER BY cv.display
  HEAD REPORT
   reccnt = 0
  DETAIL
   reccnt = (reccnt+ 1)
   IF (reccnt > size(reply->codeset,5))
    stat = alterlist(reply->codeset,(reccnt+ 10))
   ENDIF
   reply->codeset[reccnt].code_value = cv.code_value, reply->codeset[reccnt].display = cv.display,
   reply->codeset[reccnt].cdf_meaning = cv.cdf_meaning
  FOOT REPORT
   stat = alterlist(reply->codeset,reccnt)
  WITH nocounter
 ;end select
 CALL echorecord(reply)
 IF (reccnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

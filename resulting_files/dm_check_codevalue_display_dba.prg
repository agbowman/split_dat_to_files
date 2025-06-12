CREATE PROGRAM dm_check_codevalue_display:dba
 RECORD reply(
   1 check = i4
   1 code_set = f8
   1 display = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "nl:"
  cv.code_value, cv.display, cv.code_set
  FROM code_value cv
  WHERE (code_value=request->code_value)
  DETAIL
   IF ((cv.display=request->display)
    AND (cv.code_set=request->code_set))
    reply->check = 1
   ELSE
    reply->check = 0
   ENDIF
   reply->code_set = cv.code_set, reply->display = cv.display
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO

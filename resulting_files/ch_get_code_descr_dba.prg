CREATE PROGRAM ch_get_code_descr:dba
 RECORD reply(
   1 qual[*]
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET number_to_get = 0
 SET number_to_get = size(request->qual,5)
 FOR (z = 1 TO number_to_get)
   SELECT INTO "nl:"
    c.description
    FROM code_value c
    WHERE (c.code_value=request->qual[z].code_value)
     AND (c.cdf_meaning=request->qual[z].cdf_meaning)
    HEAD REPORT
     count = 0
    DETAIL
     count = (count+ 1)
     IF (mod(count,10)=1)
      stat = alterlist(reply->qual,(count+ 10))
     ENDIF
     reply->qual[count].description = c.description,
     CALL echo(build("Description:  ",reply->qual[count].description))
    WITH nocounter
   ;end select
 ENDFOR
 SET stat = alterlist(reply->qual,count)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

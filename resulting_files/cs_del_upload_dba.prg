CREATE PROGRAM cs_del_upload:dba
 RECORD internal(
   1 qual[1]
     2 status = i1
 )
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 exception_data[1]
      2 code_value = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET number_to_del = size(request->qual,5)
 SET number_of_ext = 0
 SET number_of_csext = 0
 SET count1 = 0
 SET code_value = 0.0
 SET x = 1
 SET stat = alter(internal->qual,number_to_del)
 DELETE  FROM code_value_extension cve,
   (dummyt d1  WITH seq = value(number_to_del))
  SET cve.seq = 1
  PLAN (d1)
   JOIN (cve
   WHERE (cve.code_set=request->code_set)
    AND (cve.code_value=request->qual[d1.seq].code_value))
  WITH nocounter
 ;end delete
 DELETE  FROM code_value_alias cva,
   (dummyt d1  WITH seq = value(number_to_del))
  SET cva.seq = 1
  PLAN (d1)
   JOIN (cva
   WHERE (cva.code_set=request->code_set)
    AND (cva.code_value=request->qual[d1.seq].code_value))
  WITH nocounter
 ;end delete
 DELETE  FROM code_value cv,
   (dummyt d1  WITH seq = value(number_to_del))
  SET cv.seq = 1
  PLAN (d1)
   JOIN (cv
   WHERE (cv.code_set=request->code_set)
    AND (cv.code_value=request->qual[d1.seq].code_value))
  WITH nocounter, status(internal->qual[d1.seq].status)
 ;end delete
 COMMIT
 IF (curqual != number_to_del)
  FOR (x = 1 TO number_to_del)
    IF ((internal->qual[x].status=0))
     SET count1 = (count1+ 1)
     IF (count1 > 1)
      SET stat = alter(reply->exception_data,count1)
     ENDIF
     SET reply->exception_data[count1].code_value = request->qual[x].code_value
    ENDIF
  ENDFOR
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

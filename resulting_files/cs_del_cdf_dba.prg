CREATE PROGRAM cs_del_cdf:dba
 RECORD reply(
   1 exception_data[1]
     2 code_set = i4
     2 cdf_meaning = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD internal(
   1 qual[1]
     2 status = i1
 )
 SET reply->status_data.status = "F"
 SET number_to_del = size(request->qual,5)
 SET stat = alter(internal->qual,number_to_del)
 SET failures = 0
 DELETE  FROM common_data_foundation c,
   (dummyt d  WITH seq = value(number_to_del))
  SET c.seq = 1
  PLAN (d)
   JOIN (c
   WHERE (c.code_set=request->qual[d.seq].code_set)
    AND (c.cdf_meaning=request->qual[d.seq].cdf_meaning))
  WITH nocounter, status(internal->qual[d.seq].status)
 ;end delete
 COMMIT
 IF (curqual != number_to_del)
  FOR (x = 1 TO number_to_del)
    IF ((internal->qual[x].status=0))
     SET failures = (failures+ 1)
     IF (failures > 1)
      SET stat = alter(reply->exception_data,failures)
     ENDIF
     SET reply->exception_data[failures].code_set = request->qual[x].code_set
     SET reply->exception_data[failures].cdf_meaning = request->qual[x].cdf_meaning
    ENDIF
  ENDFOR
 ENDIF
 IF (failures=0)
  SET reply->status_data.status = "S"
 ENDIF
END GO

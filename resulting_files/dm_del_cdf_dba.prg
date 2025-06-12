CREATE PROGRAM dm_del_cdf:dba
 RECORD reply(
   1 qual[*]
     2 code_set = i4
     2 cdf_meaning = c12
     2 status = c2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET number_to_del = size(request->qual,5)
 SET stat = alterlist(reply->qual,number_to_del)
 SET failures = 0
 SET x = 0
 FOR (x = 1 TO number_to_del)
   SELECT INTO "nl:"
    c.code_value
    FROM code_value c
    WHERE (c.code_set=request->code_set)
     AND c.cdf_meaning=trim(request->qual[x].cdf_meaning)
    WITH nocounter
   ;end select
   IF (curqual=0)
    DELETE  FROM common_data_foundation c
     WHERE (c.code_set=request->code_set)
      AND (c.cdf_meaning=request->qual[x].cdf_meaning)
     WITH nocounter
    ;end delete
    IF (curqual > 0)
     SET reply->qual[x].status = "S"
     SET reply->qual[x].cdf_meaning = request->qual[x].cdf_meaning
    ELSE
     SET reply->qual[x].status = "D"
     SET reply->qual[x].cdf_meaning = request->qual[x].cdf_meaning
    ENDIF
   ELSE
    SET reply->qual[x].status = "A"
    SET reply->qual[x].cdf_meaning = request->qual[x].cdf_meaning
   ENDIF
   COMMIT
 ENDFOR
 SET reply->status_data.status = "S"
END GO

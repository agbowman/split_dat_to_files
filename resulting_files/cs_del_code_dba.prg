CREATE PROGRAM cs_del_code:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
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
 SET number_to_delete = size(request->qual,5)
 SET failures = 0
 FOR (y = 1 TO number_to_delete)
   DELETE  FROM code_value_alias c
    WHERE (c.code_value=request->qual[y].code_value)
    WITH nocounter
   ;end delete
   DELETE  FROM code_value_extension c
    WHERE (c.code_value=request->qual[y].code_value)
    WITH nocounter
   ;end delete
   DELETE  FROM code_domain_filter_display c
    WHERE (c.code_value=request->qual[y].code_value)
    WITH nocounter
   ;end delete
   DELETE  FROM code_value c
    WHERE (c.code_set=request->code_set)
     AND (c.code_value=request->qual[y].code_value)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    ROLLBACK
    SET failures = (failures+ 1)
    IF (failures > 1)
     SET stat = alter(reply->status_data.subeventstatus,failures)
    ENDIF
    SET reply->status_data.subeventstatus[failures].operationstatus = "F"
    SET reply->status_data.subeventstatus[failures].targetobjectvalue = cnvtstring(request->qual[y].
     code_value)
   ELSE
    COMMIT
   ENDIF
 ENDFOR
 IF (failures=0)
  SET reply->status_data.status = "S"
 ENDIF
END GO

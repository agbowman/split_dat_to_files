CREATE PROGRAM cs_delete_code_value_alias:dba
 DELETE  FROM code_value_alias c
  PLAN (c
   WHERE (c.code_set=request->qual[x].code_set)
    AND (c.contributor_source_cd=request->qual[x].contributor_source_cd)
    AND  $1
    AND c.alias=trim(request->qual[x].alias)
    AND (c.code_value=request->qual[x].code_value))
  WITH nocounter
 ;end delete
 COMMIT
 IF (curqual=0)
  SET failures = (failures+ 1)
  IF (failures > 1)
   SET stat = alter(reply->exception_data,failures)
  ENDIF
  SET reply->exception_data[failures].code_set = request->qual[x].code_set
  SET reply->exception_data[failures].contributor_source_cd = request->qual[x].contributor_source_cd
  SET reply->exception_data[failures].alias_type_meaning = request->qual[x].alias_type_meaning
  SET reply->exception_data[failures].alias = request->qual[x].alias
  SET reply->exception_data[failures].code_value = request->qual[x].code_value
 ENDIF
END GO

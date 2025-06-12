CREATE PROGRAM cs_del_code_value_alias:dba
 RECORD reply(
   1 exception_data[1]
     2 code_set = i4
     2 contributor_source_cd = f8
     2 alias_type_meaning = c12
     2 alias = c50
     2 code_value = f8
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
 SET failures = 0
 FOR (x = 1 TO number_to_del)
   EXECUTE cs_delete_code_value_alias parser(
    IF (size(trim(request->qual[x].alias_type_meaning))=0) "c.alias_type_meaning = NULL"
    ELSE "c.alias_type_meaning = trim(request->qual[x]->alias_type_meaning)"
    ENDIF
    )
 ENDFOR
 IF (failures=0)
  SET reply->status_data.status = "S"
 ENDIF
END GO

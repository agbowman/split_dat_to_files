CREATE PROGRAM dm_del_code_alias:dba
 RECORD reply(
   1 qual[1]
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
 SET cva_count = 0
 SET cva_count2 = 0
 SELECT INTO "nl:"
  count(c.alias)
  FROM code_value_alias c
  WHERE (c.code_set=request->code_set)
  DETAIL
   cva_count = (cva_count+ 1)
  WITH nocounter
 ;end select
 FOR (x = 1 TO number_to_del)
   DELETE  FROM code_value_alias c
    WHERE (c.code_set=request->code_set)
     AND (c.code_value=request->qual[x].code_value)
     AND (c.contributor_source_cd=request->qual[x].contributor_source_cd)
     AND (c.alias=request->qual[x].alias)
    WITH nocounter
   ;end delete
   SELECT INTO "nl:"
    count(c.alias)
    FROM code_value_alias c
    WHERE (c.code_set=request->code_set)
    DETAIL
     cva_count2 = (cva_count2+ 1)
    WITH nocounter
   ;end select
   COMMIT
 ENDFOR
 SET reply->status_data.status = "S"
 COMMIT
END GO

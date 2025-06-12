CREATE PROGRAM cs_rpl_code_value_alias:dba
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
 SET number_to_rpl = size(request->qual,5)
 SET failures = 0
 SET x = 1
#start_loop
 FOR (x = x TO number_to_rpl)
   IF (trim(request->qual[x].alias_type_meaning) != null)
    DELETE  FROM code_value_alias c
     WHERE (c.code_set=request->qual[x].code_set)
      AND (c.contributor_source_cd=request->qual[x].contributor_source_cd)
      AND (c.alias_type_meaning=request->qual[x].alias_type_meaning)
      AND (c.alias=request->qual[x].alias)
      AND (c.code_value=request->qual[x].code_value)
     WITH nocounter
    ;end delete
   ELSE
    DELETE  FROM code_value_alias c
     WHERE (c.code_set=request->qual[x].code_set)
      AND (c.contributor_source_cd=request->qual[x].contributor_source_cd)
      AND (c.alias=request->qual[x].alias)
      AND (c.code_value=request->qual[x].code_value)
     WITH nocounter
    ;end delete
   ENDIF
   IF (curqual=0)
    GO TO next_item
   ENDIF
   INSERT  FROM code_value_alias c
    SET c.code_set = request->qual[x].new_code_set, c.contributor_source_cd = request->qual[x].
     new_contributor_source_cd, c.alias_type_meaning =
     IF (trim(request->qual[x].new_alias_type_meaning) > " ") request->qual[x].new_alias_type_meaning
     ELSE null
     ENDIF
     ,
     c.alias = request->qual[x].new_alias, c.code_value = request->qual[x].new_code_value, c
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_cnt = 0,
     c.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    GO TO next_item
   ENDIF
   COMMIT
 ENDFOR
 GO TO exit_script
#next_item
 ROLLBACK
 SET failures = (failures+ 1)
 IF (failures > 1)
  SET stat = alter(reply->exception_qual,failures)
 ENDIF
 SET reply->exception_data[failures].code_set = request->qual[x].code_set
 SET reply->exception_data[failures].contributor_source_cd = request->qual[x].contributor_source_cd
 SET reply->exception_data[failures].alias_type_meaning = request->qual[x].alias_type_meaning
 SET reply->exception_data[failures].alias = request->qual[x].alias
 SET reply->exception_data[failures].code_value = request->qual[x].code_value
 SET x = (x+ 1)
 GO TO start_loop
#exit_script
 IF (failures=0)
  SET reply->status_data.status = "S"
 ENDIF
END GO

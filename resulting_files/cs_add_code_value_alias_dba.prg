CREATE PROGRAM cs_add_code_value_alias:dba
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
 RECORD internal(
   1 qual[1]
     2 status = i1
 )
 SET reply->status_data.status = "F"
 SET number_to_add = size(request->qual,5)
 SET stat = alter(internal->qual,number_to_add)
 SET failures = 0
 INSERT  FROM code_value_alias c,
   (dummyt d  WITH seq = value(number_to_add))
  SET c.seq = 1, c.code_set = request->qual[d.seq].code_set, c.contributor_source_cd = request->qual[
   d.seq].contributor_source_cd,
   c.alias_type_meaning =
   IF (trim(request->qual[d.seq].alias_type_meaning) > " ") request->qual[d.seq].alias_type_meaning
   ELSE null
   ENDIF
   , c.alias = request->qual[d.seq].alias, c.code_value = request->qual[d.seq].code_value,
   c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo
   ->updt_task,
   c.updt_cnt = 0, c.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (c)
  WITH nocounter, status(internal->qual[d.seq].status)
 ;end insert
 COMMIT
 IF (curqual != number_to_add)
  FOR (x = 1 TO number_to_add)
    IF ((internal->qual[x].status=0))
     SET failures = (failures+ 1)
     IF (failures > 1)
      SET stat = alter(reply->exception_data,failures)
     ENDIF
     SET reply->exception_data[failures].code_set = request->qual[x].code_set
     SET reply->exception_data[failures].contributor_source_cd = request->qual[x].
     contributor_source_cd
     SET reply->exception_data[failures].alias_type_meaning = request->qual[x].alias_type_meaning
     SET reply->exception_data[failures].alias = request->qual[x].alias
     SET reply->exception_data[failures].code_value = request->qual[x].code_value
    ENDIF
  ENDFOR
 ENDIF
 IF (failures=0)
  SET reply->status_data.status = "S"
 ENDIF
END GO

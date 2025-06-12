CREATE PROGRAM cs_add_cvextensions:dba
 RECORD reply(
   1 exception_qual[1]
     2 code_set = i4
     2 code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD internal(
   1 qual[1]
     2 status = i1
 )
 SET reply->status_data.status = "F"
 SET failures = 0
 SET number_to_add = size(request->qual,5)
 SET stat = alter(internal->qual,number_to_add)
 INSERT  FROM code_value_extension c,
   (dummyt d  WITH seq = value(number_to_add))
  SET c.code_set = request->code_set, c.field_name = request->qual[d.seq].field_name, c.code_value =
   request->qual[d.seq].code_value,
   c.field_type = request->qual[d.seq].field_type, c.field_value = request->qual[d.seq].field_value,
   c.updt_task = reqinfo->updt_task,
   c.updt_id = reqinfo->updt_id, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   c.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (c
   WHERE (c.code_set=request->code_set)
    AND (c.field_name=request->qual[d.seq].field_name))
  WITH nocounter, outerjoin = d, dontexist,
  status(internal->qual[d.seq].status)
 ;end insert
 COMMIT
 IF (curqual != number_to_add)
  FOR (x = 1 TO number_to_add)
    IF ((internal->qual[x].status=0))
     SET failures = (failures+ 1)
     SET stat = alter(reply->exception_qual,failures)
     SET reply->exception_qual[failures].code_set = request->code_set
     SET reply->exception_qual[failures].code_value = request->qual[x].code_value
    ENDIF
  ENDFOR
 ENDIF
 IF (failures=0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VAL_EXT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to Insert"
 ENDIF
END GO

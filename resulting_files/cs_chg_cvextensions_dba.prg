CREATE PROGRAM cs_chg_cvextensions:dba
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
 SET reply->status_data.status = "F"
 SET failures = 0
 SET failed = "F"
 SET cur_updt_cnt = 0
 SET number_to_chg = size(request->qual,5)
 SET x = 1
#start_loop
 FOR (x = x TO number_to_chg)
   SELECT INTO "nl:"
    c.*
    FROM code_value_extension c
    WHERE (c.code_set=request->code_set)
     AND (c.code_value=request->qual[x].code_value)
     AND (c.field_name=request->qual[x].field_name)
    DETAIL
     cur_updt_cnt = c.updt_cnt
    WITH nocounter, forupdate(c)
   ;end select
   IF (curqual=0)
    GO TO next_item
   ENDIF
   IF ((cur_updt_cnt != request->qual[x].updt_cnt))
    SET failed = "T"
    GO TO next_item
   ENDIF
   UPDATE  FROM code_value_extension c
    SET c.field_type = request->qual[x].field_type, c.field_value = request->qual[x].field_value, c
     .updt_task = reqinfo->updt_task,
     c.updt_id = reqinfo->updt_id, c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     c.updt_applctx = reqinfo->updt_applctx
    WHERE (c.code_set=request->code_set)
     AND (c.code_value=request->qual[x].code_value)
     AND (c.field_name=request->qual[x].field_name)
    WITH nocounter
   ;end update
   IF (curqual=0)
    GO TO next_item
   ELSE
    COMMIT
   ENDIF
 ENDFOR
 GO TO exit_script
#next_item
 ROLLBACK
 SET failures = (failures+ 1)
 IF (failures > 1)
  SET stat = alter(reply->exception_qual,failures)
 ENDIF
 SET reply->exception_qual[failures].code_set = request->code_set
 SET reply->exception_qual[failures].code_value = request->qual[x].code_value
 SET x = (x+ 1)
 GO TO start_loop
#exit_script
 IF (failures=0)
  SET reply->status_data.status = "S"
 ELSE
  IF (failed="F")
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
  ELSE
   SET reply->status_data.subeventstatus[1].operationstatus = "C"
  ENDIF
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VAL_EXT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to Update"
 ENDIF
END GO

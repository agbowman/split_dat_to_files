CREATE PROGRAM dm_ins_upd_cv_extension:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 field_name = c32
     2 status = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET cur_updt_cnt = 0
 SET number_to_update = size(request->qual,5)
 SET stat = alterlist(reply->qual,number_to_update)
 SET failures = 0
 SET x = 1
#start_loop
 FOR (x = 1 TO number_to_update)
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
   IF (curqual > 0)
    IF ((cur_updt_cnt != request->qual[x].updt_cnt))
     SET reply->qual[x].code_value = request->qual[x].code_value
     SET reply->qual[x].field_name = request->qual[x].field_name
     SET reply->qual[x].status = "A"
    ELSE
     UPDATE  FROM code_value_extension c
      SET c.field_value = request->qual[x].field_value, c.updt_applctx = reqinfo->updt_applctx, c
       .updt_cnt = (c.updt_cnt+ 1),
       c.updt_task = reqinfo->updt_task, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id =
       reqinfo->updt_id
      WHERE (c.code_set=request->code_set)
       AND (c.code_value=request->qual[x].code_value)
       AND (c.field_name=request->qual[x].field_name)
      WITH nocounter
     ;end update
     IF (curqual > 0)
      SET reply->qual[x].code_value = request->qual[x].code_value
      SET reply->qual[x].field_name = request->qual[x].field_name
      SET reply->qual[x].status = "S"
     ELSE
      SET reply->qual[x].code_value = request->qual[x].code_value
      SET reply->qual[x].field_name = request->qual[x].field_name
      SET reply->qual[x].status = "U"
     ENDIF
    ENDIF
   ELSE
    INSERT  FROM code_value_extension c
     SET c.code_set = request->code_set, c.code_value = request->qual[x].code_value, c.field_name =
      request->qual[x].field_name,
      c.field_type = request->qual[x].field_type, c.field_value = request->qual[x].field_value, c
      .updt_task = reqinfo->updt_task,
      c.updt_id = reqinfo->updt_id, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      c.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     SET reply->qual[x].code_value = request->qual[x].code_value
     SET reply->qual[x].field_name = request->qual[x].field_name
     SET reply->qual[x].status = "S"
    ELSE
     SET reply->qual[x].code_value = request->qual[x].code_value
     SET reply->qual[x].field_name = request->qual[x].field_name
     SET reply->qual[x].status = "I"
    ENDIF
   ENDIF
   COMMIT
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 COMMIT
END GO

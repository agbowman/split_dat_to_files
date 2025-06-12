CREATE PROGRAM cs_chg_csextension:dba
 RECORD reply(
   1 exception_data[1]
     2 field_name = c32
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
 SET failures = 0
 SET x = 1
#start_loop
 FOR (x = x TO number_to_update)
   SELECT INTO "nl:"
    c.*
    FROM code_set_extension c
    WHERE (c.code_set=request->code_set)
     AND (c.field_name=request->qual[x].field_name)
    DETAIL
     cur_updt_cnt = c.updt_cnt
    WITH nocounter, forupdate(c)
   ;end select
   IF ((cur_updt_cnt != request->qual[x].updt_cnt))
    GO TO next_item
   ENDIF
   UPDATE  FROM code_set_extension c
    SET c.field_seq = request->qual[x].field_seq, c.field_type = request->qual[x].field_type, c
     .field_len = request->qual[x].field_len,
     c.field_prompt = request->qual[x].field_prompt, c.field_in_mask = request->qual[x].field_in_mask,
     c.field_out_mask = request->qual[x].field_out_mask,
     c.validation_condition = request->qual[x].validation_condition, c.validation_code_set = request
     ->qual[x].validation_code_set, c.action_field = request->qual[x].action_field,
     c.field_default = request->qual[x].field_default, c.field_help = request->qual[x].field_help, c
     .updt_task = reqinfo->updt_task,
     c.updt_id = reqinfo->updt_id, c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     c.updt_applctx = reqinfo->updt_applctx
    WHERE (c.code_set=request->code_set)
     AND (c.field_name=request->qual[x].field_name)
    WITH nocounter
   ;end update
   IF (curqual=0)
    GO TO next_item
   ENDIF
   COMMIT
 ENDFOR
 GO TO exit_script
#next_item
 ROLLBACK
 SET failures = (failures+ 1)
 SET stat = alter(reply->exception_data,failures)
 SET reply->exception_data[failures].field_name = request->qual[x].field_name
 SET x = (x+ 1)
 GO TO start_loop
#exit_script
 IF (failures=0)
  SET reply->status_data.status = "S"
 ENDIF
END GO

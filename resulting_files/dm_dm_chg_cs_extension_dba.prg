CREATE PROGRAM dm_dm_chg_cs_extension:dba
 RECORD reply(
   1 qual[*]
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
 SET cv_updt = 0
 FOR (x = 1 TO number_to_update)
   INSERT  FROM dm_adm_code_set_extension c
    SET c.code_set = request->qual[x].code_set, c.schema_date = cnvtdatetime(request->schema_date), c
     .field_name = request->qual[x].field_name,
     c.field_seq = request->qual[x].field_seq, c.field_type = request->qual[x].field_type, c
     .field_len = request->qual[x].field_len,
     c.field_prompt = request->qual[x].field_prompt, c.field_in_mask = request->qual[x].field_in_mask,
     c.field_out_mask = request->qual[x].field_out_mask,
     c.validation_condition = request->qual[x].valid_condition, c.validation_code_set = request->
     qual[x].valid_code_set, c.action_field = request->qual[x].action_field,
     c.field_default = request->qual[x].field_default, c.field_help = request->qual[x].field_help, c
     .updt_task = reqinfo->updt_task,
     c.updt_id = reqinfo->updt_id, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     c.updt_applctx = reqinfo->updt_applctx, c.delete_ind = request->qual[x].delete_ind
    WITH nocounter
   ;end insert
   IF (curqual > 0)
    SET reply->qual[x].field_name = request->qual[x].field_name
    SET reply->qual[x].status = "S"
    UPDATE  FROM dm_adm_code_value_set cvs
     SET cvs.extension_ind = 1, cvs.schema_date = cnvtdatetime(request->schema_date)
     WHERE (cvs.code_set=request->qual[x].code_set)
      AND datetimediff(cvs.schema_date,cnvtdatetime(request->schema_date))=0
     WITH nocounter
    ;end update
    COMMIT
   ELSE
    SET reply->qual[x].field_name = request->qual[x].field_name
    SET reply->qual[x].status = "I"
   ENDIF
   SET cv_updt = 0
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 COMMIT
END GO

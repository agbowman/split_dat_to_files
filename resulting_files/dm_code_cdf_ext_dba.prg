CREATE PROGRAM dm_code_cdf_ext:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "f"
 UPDATE  FROM code_cdf_ext cse
  SET cse.updt_id = reqinfo->updt_id, cse.updt_cnt = (cse.updt_cnt+ 1), cse.updt_task = reqinfo->
   updt_task,
   cse.updt_applctx = reqinfo->updt_applctx, cse.updt_dt_tm = cnvtdatetime(curdate,curtime3), cse
   .field_seq = request->field_seq,
   cse.field_type = request->field_type, cse.field_len = request->field_len, cse.field_prompt =
   request->field_prompt,
   cse.field_in_mask = request->field_in_mask, cse.field_out_mask = request->field_out_mask, cse
   .val_condition = request->val_condition,
   cse.val_code_set = request->val_code_set, cse.action_field = request->action_field, cse
   .field_default = request->field_default,
   cse.field_help = request->field_help, cse.field_value = request->field_value
  WHERE (cse.field_name=request->field_name)
   AND (cse.code_set=request->code_set)
   AND (cse.cdf_meaning=request->cdf_meaning)
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM code_cdf_ext cse
   SET cse.code_set = request->code_set, cse.cdf_meaning = request->cdf_meaning, cse.field_name =
    request->field_name,
    cse.updt_id = reqinfo->updt_id, cse.updt_cnt = 0, cse.updt_task = reqinfo->updt_task,
    cse.updt_applctx = reqinfo->updt_applctx, cse.updt_dt_tm = cnvtdatetime(curdate,curtime3), cse
    .field_seq = request->field_seq,
    cse.field_type = request->field_type, cse.field_len = request->field_len, cse.field_prompt =
    request->field_prompt,
    cse.field_in_mask = request->field_in_mask, cse.field_out_mask = request->field_out_mask, cse
    .val_condition = request->val_condition,
    cse.val_code_set = request->val_code_set, cse.action_field = request->action_field, cse
    .field_default = request->field_default,
    cse.field_help = request->field_help, cse.field_value = request->field_value
   WITH nocounter
  ;end insert
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO

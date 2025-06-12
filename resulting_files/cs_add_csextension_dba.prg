CREATE PROGRAM cs_add_csextension:dba
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
 RECORD internal(
   1 qual[1]
     2 code_value = f8
 )
 SET reply->status_data.status = "F"
 SET failures = 0
 SET number_to_add = size(request->qual,5)
 SET number_of_values = 0
 SET x = 1
#start_loop
 FOR (x = 1 TO number_to_add)
   INSERT  FROM code_set_extension c
    SET c.code_set = request->code_set, c.field_name = request->qual[x].field_name, c.field_seq =
     request->qual[x].field_seq,
     c.field_type = request->qual[x].field_type, c.field_len = request->qual[x].field_len, c
     .field_prompt = request->qual[x].field_prompt,
     c.field_in_mask = request->qual[x].field_in_mask, c.field_out_mask = request->qual[x].
     field_out_mask, c.validation_condition = request->qual[x].validation_condition,
     c.validation_code_set = request->qual[x].validation_code_set, c.action_field = request->qual[x].
     action_field, c.field_default = request->qual[x].field_default,
     c.field_help = request->qual[x].field_help, c.updt_task = reqinfo->updt_task, c.updt_id =
     reqinfo->updt_id,
     c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    GO TO next_item
   ENDIF
   SELECT INTO "nl:"
    cs.*
    FROM code_value_set cs
    WHERE (cs.code_set=request->code_set)
    WITH nocounter, forupdate(cs)
   ;end select
   IF (curqual=0)
    GO TO next_item
   ENDIF
   UPDATE  FROM code_value_set cs
    SET cs.extension_ind = 1
    WHERE (cs.code_set=request->code_set)
    WITH nocounter
   ;end update
   IF (curqual=0)
    GO TO next_item
   ENDIF
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE (cv.code_set=request->code_set)
    HEAD REPORT
     number_of_values = 0
    DETAIL
     number_of_values = (number_of_values+ 1)
     IF (mod(number_of_values,10)=2)
      stat = alter(internal->qual,(number_of_values+ 9))
     ENDIF
     internal->qual[number_of_values].code_value = cv.code_value
    WITH nocounter
   ;end select
   IF (number_of_values > 0)
    SET stat = alter(internal->qual,number_of_values)
    INSERT  FROM code_value_extension cve,
      (dummyt d  WITH seq = value(number_of_values))
     SET cve.code_set = request->code_set, cve.field_name = request->qual[x].field_name, cve
      .code_value = internal->qual[d.seq].code_value,
      cve.field_type = request->qual[x].field_type, cve.field_value =
      IF ((request->qual[x].field_type=1)) "0"
      ELSEIF ((request->qual[x].field_type=2)) " "
      ENDIF
      , cve.updt_task = reqinfo->updt_task,
      cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 0, cve.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      cve.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (cve)
     WITH nocounter
    ;end insert
    IF (curqual != number_of_values)
     GO TO next_item
    ENDIF
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
#exit_script
 IF (failures=0)
  SET reply->status_data.status = "S"
 ENDIF
END GO

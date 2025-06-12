CREATE PROGRAM dm_ins_upd_cs_extension:dba
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
#start_loop
 FOR (x = 1 TO number_to_update)
   SELECT INTO "nl:"
    c.*
    FROM code_set_extension c
    WHERE (c.code_set=request->code_set)
     AND c.field_name=trim(request->qual[x].old_field_name)
    DETAIL
     cur_updt_cnt = c.updt_cnt
    WITH nocounter, forupdate(c)
   ;end select
   IF (curqual > 0)
    IF ((cur_updt_cnt != request->qual[x].updt_cnt))
     SET reply->qual[x].field_name = trim(request->qual[x].old_field_name)
     SET reply->qual[x].status = "A"
     SET cv_updt = 0
    ELSE
     IF (trim(request->qual[x].field_name) != trim(request->qual[x].old_field_name))
      INSERT  FROM code_set_extension c
       SET c.code_set = request->code_set, c.field_name = request->qual[x].field_name, c.field_seq =
        request->qual[x].field_seq,
        c.field_type = request->qual[x].field_type, c.field_len = request->qual[x].field_len, c
        .field_prompt = trim(request->qual[x].field_prompt),
        c.field_in_mask = trim(request->qual[x].field_in_mask), c.field_out_mask = trim(request->
         qual[x].field_out_mask), c.validation_condition = trim(request->qual[x].valid_condition),
        c.validation_code_set = request->qual[x].valid_code_set, c.action_field = trim(request->qual[
         x].action_field), c.field_default = request->qual[x].field_default,
        c.field_help = trim(request->qual[x].field_help), c.updt_task = reqinfo->updt_task, c.updt_id
         = reqinfo->updt_id,
        c.updt_cnt = (cur_updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_applctx
         = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual > 0)
       SELECT INTO "nl:"
        c.*
        FROM code_value_extension c
        WHERE (c.code_set=request->code_set)
         AND c.field_name=trim(request->qual[x].old_field_name)
        DETAIL
         cur_updt_cnt = c.updt_cnt
        WITH nocounter, forupdate(c)
       ;end select
       IF (curqual > 0)
        INSERT  FROM code_value_extension
         (code_value, field_name, code_set,
         updt_applctx, updt_dt_tm, updt_id,
         field_type, field_value, updt_cnt,
         updt_task)(SELECT
          code_value, trim(request->qual[x].field_name), request->code_set,
          reqinfo->updt_applctx, cnvtdatetime(curdate,curtime3), reqinfo->updt_id,
          request->qual[x].field_type, field_value, updt_cnt,
          reqinfo->updt_task
          FROM code_value_extension
          WHERE (code_set=request->code_set)
           AND field_name=trim(request->qual[x].old_field_name))
         WITH nocounter
        ;end insert
        IF (curqual > 0)
         DELETE  FROM code_value_extension cve
          WHERE code_set=14034
           AND field_name=trim(request->qual[x].old_field_name)
          WITH nocounter
         ;end delete
         DELETE  FROM code_set_extension cvs
          WHERE code_set=14034
           AND field_name=trim(request->qual[x].old_field_name)
          WITH nocounter
         ;end delete
        ENDIF
       ENDIF
      ENDIF
      SET cv_updt = 1
     ELSE
      UPDATE  FROM code_set_extension c
       SET c.field_seq = request->qual[x].field_seq, c.field_type = request->qual[x].field_type, c
        .field_len = request->qual[x].field_len,
        c.field_prompt = trim(request->qual[x].field_prompt), c.field_in_mask = trim(request->qual[x]
         .field_in_mask), c.field_out_mask = trim(request->qual[x].field_out_mask),
        c.validation_condition = trim(request->qual[x].valid_condition), c.validation_code_set =
        request->qual[x].valid_code_set, c.action_field = trim(request->qual[x].action_field),
        c.field_default = request->qual[x].field_default, c.field_help = trim(request->qual[x].
         field_help), c.updt_task = reqinfo->updt_task,
        c.updt_id = reqinfo->updt_id, c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        c.updt_applctx = reqinfo->updt_applctx
       WHERE (c.code_set=request->code_set)
        AND c.field_name=trim(request->qual[x].old_field_name)
       WITH nocounter
      ;end update
      IF (curqual > 0)
       SET reply->qual[x].field_name = request->qual[x].field_name
       SET reply->qual[x].status = "S"
       IF ((request->qual[x].field_type != request->qual[x].old_field_type))
        SELECT INTO "nl:"
         c.*
         FROM code_value_extension c
         WHERE (c.code_set=request->code_set)
          AND c.field_name=trim(request->qual[x].field_name)
         DETAIL
          cur_updt_cnt = c.updt_cnt
         WITH nocounter, forupdate(c)
        ;end select
        UPDATE  FROM code_value_extension cve
         SET cve.field_type = request->qual[x].field_type, cve.updt_cnt = (cve.updt_cnt+ 1)
         WHERE (cve.code_set=request->code_set)
          AND cve.field_name=trim(request->qual[x].field_name)
         WITH nocounter
        ;end update
       ENDIF
       SET cv_updt = 1
      ELSE
       SET reply->qual[x].field_name = request->qual[x].field_name
       SET reply->qual[x].status = "U"
       SET cv_updt = 0
      ENDIF
     ENDIF
    ENDIF
   ELSE
    INSERT  FROM code_set_extension c
     SET c.code_set = request->code_set, c.field_name = request->qual[x].field_name, c.field_seq =
      request->qual[x].field_seq,
      c.field_type = request->qual[x].field_type, c.field_len = request->qual[x].field_len, c
      .field_prompt = request->qual[x].field_prompt,
      c.field_in_mask = request->qual[x].field_in_mask, c.field_out_mask = request->qual[x].
      field_out_mask, c.validation_condition = request->qual[x].valid_condition,
      c.validation_code_set = request->qual[x].valid_code_set, c.action_field = request->qual[x].
      action_field, c.field_default = request->qual[x].field_default,
      c.field_help = request->qual[x].field_help, c.updt_task = reqinfo->updt_task, c.updt_id =
      reqinfo->updt_id,
      c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_applctx = reqinfo->
      updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     SET reply->qual[x].field_name = request->qual[x].field_name
     SET reply->qual[x].status = "S"
    ELSE
     SET reply->qual[x].field_name = request->qual[x].field_name
     SET reply->qual[x].status = "I"
    ENDIF
    SET cv_updt = 0
   ENDIF
   IF (cv_updt=1)
    SELECT INTO "nl:"
     cs.*
     FROM code_value_set cs
     WHERE (cs.code_set=request->code_set)
     WITH nocounter, forupdate(cs)
    ;end select
    UPDATE  FROM code_value_set cs
     SET cs.extension_ind = 1
     WHERE (cs.code_set=request->code_set)
     WITH nocounter
    ;end update
    COMMIT
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 COMMIT
END GO

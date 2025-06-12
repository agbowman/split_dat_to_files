CREATE PROGRAM dm_dm_insert_cv_extension:dba
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
 SET dm_display = fillstring(40," ")
 SET dm_display_key = fillstring(40," ")
 SET dm_cdf_meaning = fillstring(12," ")
 SET dm_active_ind = 0
 SET dm_code_value = 0.00
 SET display_dup_ind = 0
 SET display_key_dup_ind = 0
 SET cdf_meaning_dup_ind = 0
 SET active_ind_dup_ind = 0
 IF ((request->dm_mode=1))
  DELETE  FROM dm_code_value_extension
   WHERE (code_set=request->code_set)
   WITH nocounter
  ;end delete
 ENDIF
 SELECT INTO "nl:"
  cvs.display_key_dup_ind, cvs.cdf_meaning_dup_ind, cvs.active_ind_dup_ind,
  cvs.display_dup_ind
  FROM dm_code_value_set cvs
  WHERE (cvs.code_set=request->code_set)
  DETAIL
   display_key_dup_ind = cvs.display_key_dup_ind, cdf_meaning_dup_ind = cvs.cdf_meaning_dup_ind,
   active_ind_dup_ind = cvs.active_ind_dup_ind,
   display_dup_ind = cvs.display_dup_ind
  WITH nocounter
 ;end select
#start_loop
 FOR (x = 1 TO number_to_update)
   SET dm_display = request->qual[x].display
   SET dm_display_key = cnvtupper(cvntalphanum(request->qual[x].display_key))
   SET dm_cdf_meaning = request->qual[x].cdf_meaning
   SET dm_active_ind = request->qual[x].active_ind
   SET parser_buffer[18] = fillstring(132," ")
   SET parser_number = 0
   SET new_code_value = 0.00
   SET parser_buffer[1] = 'select into "nl:" c.*'
   SET parser_buffer[2] = "from dm_code_value c"
   SET parser_buffer[3] = "where c.code_set = request->code_set"
   SET parser_number = 3
   IF (display_key_dup_ind=1)
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = "  and c.display_key = dm_display_key"
   ENDIF
   IF (display_dup_ind=1)
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = "  and c.display = dm_display"
   ENDIF
   IF (cdf_meaning_dup_ind=1)
    IF (trim(dm_cdf_meaning) > "")
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = "  and c.cdf_meaning = dm_cdf_meaning"
    ELSE
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = "  and c.cdf_meaning = NULL"
    ENDIF
   ENDIF
   IF (active_ind_dup_ind=1)
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = "  and c.active_ind = dm_active_ind"
   ENDIF
   IF (display_dup_ind=0
    AND display_key_dup_ind=0
    AND cdf_meaning_dup_ind=0
    AND active_ind_dup_ind=0)
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = "  and c.display = dm_display"
   ENDIF
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = "detail"
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = "  dm_code_value = c.code_value"
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = "with nocounter go"
   FOR (z = 1 TO parser_number)
     CALL parser(parser_buffer[z],1)
   ENDFOR
   IF (curqual > 0)
    SELECT INTO "nl:"
     c.*
     FROM dm_code_value_extension c
     WHERE (c.code_set=request->code_set)
      AND c.code_value=dm_code_value
      AND (c.field_name=request->qual[x].field_name)
     DETAIL
      cur_updt_cnt = c.updt_cnt
     WITH nocounter, forupdate(c)
    ;end select
    IF (curqual > 0)
     UPDATE  FROM dm_code_value_extension c
      SET c.field_value = request->qual[x].field_value, c.updt_applctx = reqinfo->updt_applctx, c
       .updt_cnt = (c.updt_cnt+ 1),
       c.updt_task = reqinfo->updt_task, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id =
       reqinfo->updt_id
      WHERE (c.code_set=request->code_set)
       AND c.code_value=dm_code_value
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
    ELSE
     INSERT  FROM dm_code_value_extension c
      (c.code_set, c.code_value, c.field_name,
      c.field_type, c.field_value, c.updt_task,
      c.updt_id, c.updt_cnt, c.updt_dt_tm,
      c.updt_applctx)(SELECT
       request->code_set, dm_code_value, cse.field_name,
       request->qual[x].field_type, request->qual[x].field_value, reqinfo->updt_task,
       reqinfo->updt_id, 0, cnvtdatetime(curdate,curtime3),
       reqinfo->updt_applctx
       FROM dm_code_set_extension cse
       WHERE cse.field_name=trim(request->qual[x].field_name)
        AND (cse.code_set=request->code_set))
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
   ELSE
    SET reply->qual[x].code_value = request->qual[x].code_value
    SET reply->qual[x].field_name = request->qual[x].field_name
    SET reply->qual[x].status = "X"
   ENDIF
   COMMIT
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 COMMIT
END GO

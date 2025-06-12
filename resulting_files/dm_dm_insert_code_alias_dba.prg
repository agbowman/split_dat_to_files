CREATE PROGRAM dm_dm_insert_code_alias:dba
 RECORD reply(
   1 qual[*]
     2 status = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET x = 0
 SET z = 0
 SET reply->status_data.status = "F"
 SET qual_size = size(request->qual,5)
 SET cur_updt_cnt = 0
 SET stat = alterlist(reply->qual,qual_size)
 SET contrib_source_cd = 0.00
 SET dm_display = fillstring(40," ")
 SET dm_display_key = fillstring(40," ")
 SET dm_cdf_meaning = fillstring(12," ")
 SET dm_active_ind = 0
 SET display_dup_ind = 0
 SET display_key_dup_ind = 0
 SET active_ind_dup_ind = 0
 SET cdf_meaning_dup_ind = 0
 IF ((request->dm_mode=1))
  DELETE  FROM dm_code_value_alias c
   WHERE (c.code_set=request->code_set)
   WITH nocounter
  ;end delete
 ENDIF
 COMMIT
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
#startloop
 FOR (x = 1 TO qual_size)
   SET dm_display = request->display
   SET dm_display_key = cnvtupper(cnvtalphanum(request->qual[x].display))
   SET dm_cdf_meaning = request->qual[x].cdf_meaning
   SET dm_active_ind = request->qual[x].active_ind
   SET parser_buffer[20] = fillstring(132," ")
   SET parser_number = 0
   SET dm_code_value = 0.00
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
    IF (trim(dm_cdf_meaning) > " ")
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
     c.code_value
     FROM dm_code_value c
     WHERE c.code_set=72
      AND c.display=trim(request->qual[x].contributor_source_disp)
     DETAIL
      contrib_source_cd = c.code_value
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SELECT INTO "nl:"
      c.*
      FROM dm_code_value_alias c
      WHERE (c.code_set=request->code_set)
       AND (c.alias=request->qual[x].alias)
       AND c.code_value=dm_code_value
       AND c.contributor_source_cd=contrib_source_cd
      DETAIL
       cur_updt_cnt = c.updt_cnt
      WITH nocounter, forupdate(c)
     ;end select
     IF (curqual > 0)
      UPDATE  FROM dm_code_value_alias cva
       SET cva.alias_type_meaning = request->qual[x].alias_type_meaning, cva.updt_cnt = (cva.updt_cnt
        + 1), cva.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        cva.updt_id = reqinfo->updt_id, cva.updt_task = reqinfo->updt_task, cva.updt_applctx =
        reqinfo->updt_applctx
       WHERE (cva.code_set=request->code_set)
        AND (cva.alias=(request->qual[x] - alias))
        AND cva.code_value=dm_code_value
        AND cva.contributor_source_cd=contrib_source_cd
       WITH nocounter
      ;end update
      SET reply->qual[x].status = "S"
     ELSE
      INSERT  FROM dm_code_value_alias cva
       SET cva.alias_type_meaning = request->qual[x].alias_type_meaning, cva.alias = request->qual[x]
        .alias, cva.contributor_source_cd = contrib_source_cd,
        cva.code_set = request->code_set, cva.code_value = dm_code_value, cva.updt_cnt = 0,
        cva.updt_dt_tm = cnvtdatetime(curdate,curtime3), cva.updt_id = reqinfo->updt_id, cva
        .updt_task = reqinfo->updt_task,
        cva.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
     ENDIF
     SET reply->qual[x].status = "S"
    ELSE
     SET reply->qual[x].status = "C"
    ENDIF
   ELSE
    SET reply->qual[x].status = "X"
   ENDIF
   COMMIT
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
END GO

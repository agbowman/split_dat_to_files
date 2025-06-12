CREATE PROGRAM cs_chg_code:dba
 RECORD reply(
   1 qual[1]
     2 code_value = f8
     2 disp_key = c40
     2 recstatus = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET number_to_change = size(request->qual,5)
 SET number_of_ext = 0
 SET failed = "F"
 SET failures = 0
 SET cur_updt_cnt = 0
 SET ext_updt_cnt = 0
 SET dup = 0
 SET dupes = 0
 SET x = 1
 SET cnt = 1
 SET authentic_cd = 0.00
 SET unauthentic_cd = 0.00
 SET authcnt = 0
 SET display_key_dup_ind = 0
 SET cdf_meaning_dup_ind = 0
 SET active_ind_dup_ind = 0
 SET display_dup_ind = 0
 SET chg_access_ind = 0
 SELECT INTO "nl:"
  c.code_value, c.cdf_meaning
  FROM code_value c
  WHERE c.code_set=8
   AND c.cdf_meaning IN ("AUTH", "UNAUTH")
  ORDER BY c.cdf_meaning
  DETAIL
   IF (authcnt=0)
    authentic_cd = c.code_value, authcnt = 1
   ELSE
    unauthentic_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET failed = "F"
 SELECT INTO "nl:"
  cvs.display_key_dup_ind, cvs.cdf_meaning_dup_ind, cvs.active_ind_dup_ind,
  cvs.display_dup_ind, cvs.chg_access_ind
  FROM code_value_set cvs
  WHERE (cvs.code_set=request->code_set)
  DETAIL
   display_key_dup_ind = cvs.display_key_dup_ind, cdf_meaning_dup_ind = cvs.cdf_meaning_dup_ind,
   active_ind_dup_ind = cvs.active_ind_dup_ind,
   display_dup_ind = cvs.display_dup_ind, chg_access_ind = cvs.chg_access_ind
  WITH nocounter
 ;end select
#start_loop
 FOR (x = x TO number_to_change)
   SET dup = 0
   SET request_array = 1
   IF (request_array=0)
    SET parser_buffer[12] = fillstring(132," ")
    SET parser_number = 0
    SET new_code_value = 0.0
    SET parser_buffer[1] = 'select into "nl:" c.*'
    SET parser_buffer[2] = "from code_value c"
    SET parser_buffer[3] = "where c.code_set = request->code_set"
    SET parser_number = 3
    IF (display_key_dup_ind=1)
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = "  and c.display_key = display_key"
    ENDIF
    IF (display_dup_ind=1)
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = "  and c.display = request->display"
    ENDIF
    IF (cdf_meaning_dup_ind=1)
     IF ((request->cdf_meaning > " "))
      SET parser_number = (parser_number+ 1)
      SET parser_buffer[parser_number] = "  and c.cdf_meaning = request->cdf_meaning"
     ELSE
      SET parser_number = (parser_number+ 1)
      SET parser_buffer[parser_number] = "  and c.cdf_meaning = NULL"
     ENDIF
    ENDIF
    IF (active_ind_dup_ind=1)
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = "  and c.active_ind = request->active_ind"
    ENDIF
    IF (display_dup_ind=0
     AND display_key_dup_ind=0
     AND cdf_meaning_dup_ind=0
     AND active_ind_dup_ind=0)
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = "  and c.display = request->display"
    ENDIF
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = "detail"
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = "  new_code_value = c.code_value"
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = "with nocounter go"
   ELSE
    SET parser_buffer[12] = fillstring(132," ")
    SET parser_number = 0
    SET new_code_value = 0.0
    SET parser_buffer[1] = 'select into "nl:" c.*'
    SET parser_buffer[2] = "from code_value c"
    SET parser_buffer[3] = "where c.code_set = request->code_set"
    SET parser_number = 3
    IF (display_key_dup_ind=1)
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = "  and c.display_key = request->qual[x]->display_key"
    ENDIF
    IF (display_dup_ind=1)
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = "  and c.display = request->qual[x]->display"
    ENDIF
    IF (cdf_meaning_dup_ind=1)
     IF ((request->qual[x].cdf_meaning > ""))
      SET parser_number = (parser_number+ 1)
      SET parser_buffer[parser_number] = "  and c.cdf_meaning = request->qual[x]->cdf_meaning"
     ELSE
      SET parser_number = (parser_number+ 1)
      SET parser_buffer[parser_number] = "  and c.cdf_meaning = NULL"
     ENDIF
    ENDIF
    IF (active_ind_dup_ind=1)
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = "  and c.active_ind = request->qual[x]->active_ind"
    ENDIF
    IF (display_dup_ind=0
     AND display_key_dup_ind=0
     AND cdf_meaning_dup_ind=0
     AND active_ind_dup_ind=0)
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = "  and c.display = request->qual[x]->display"
    ENDIF
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = "detail"
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = "  new_code_value = c.code_value"
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = "with nocounter go"
   ENDIF
   FOR (z = 1 TO parser_number)
     CALL parser(parser_buffer[z],1)
   ENDFOR
   IF (curqual > 0)
    SET dupes = (dupes+ 1)
    IF (dupes > failures)
     SET stat = alter(reply->qual,dupes)
    ELSE
     SET dupes = (failures+ 1)
     SET stat = alter(reply->qual,dupes)
    ENDIF
    SET dup = 1
    IF ((new_code_value != request->qual[x].code_value))
     SET reply->qual[dupes].code_value = request->qual[x].code_value
     SET reply->qual[dupes].disp_key = request->qual[x].display_key
     SET reply->qual[dupes].recstatus = "X"
     GO TO next_code
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    c.*
    FROM code_value c
    WHERE (c.code_value=request->qual[x].code_value)
     AND (c.code_set=request->code_set)
    DETAIL
     cur_updt_cnt = c.updt_cnt
    WITH nocounter, forupdate(c)
   ;end select
   IF (curqual=0)
    GO TO next_code
   ENDIF
   IF ((cur_updt_cnt != request->qual[x].updt_cnt))
    SET failed = "T"
    GO TO next_code
   ENDIF
   UPDATE  FROM code_value c
    SET c.cdf_meaning =
     IF ((request->qual[x].cdf_meaning > " ")) request->qual[x].cdf_meaning
     ELSE null
     ENDIF
     , c.display = request->qual[x].display, c.display_key = trim(cnvtupper(cnvtalphanum(request->
        qual[x].display))),
     c.description = request->qual[x].description, c.definition = request->qual[x].definition, c
     .collation_seq = request->qual[x].collation_seq,
     c.active_ind = request->qual[x].active_ind, c.active_type_cd =
     IF ((request->qual[x].active_ind=1)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , c.data_status_cd =
     IF ((request->qual[x].authentic_ind=1)) authentic_cd
     ELSE unauthentic_cd
     ENDIF
     ,
     c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c.updt_cnt+
     1),
     c.updt_task = reqinfo->updt_task, c.active_dt_tm =
     IF ((request->qual[x].active_ind=1)) cnvtdatetime(curdate,curtime3)
     ELSE c.active_dt_tm
     ENDIF
     , c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     c.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3), c.end_effective_dt_tm = cnvtdatetime(
      "31-dec-2100 00:00:00.00"), c.inactive_dt_tm =
     IF ((request->qual[x].active_ind=0)) cnvtdatetime(curdate,curtime3)
     ELSE c.inactive_dt_tm
     ENDIF
    WHERE (c.code_value=request->qual[x].code_value)
     AND (c.code_set=request->code_set)
   ;end update
   IF (curqual=0)
    GO TO next_code
   ENDIF
   SET number_of_ext = request->qual[x].extension_cnt
   SET failed = "F"
   FOR (y = 1 TO number_of_ext)
    SELECT INTO "nl:"
     cve.*
     FROM code_value_extension cve
     WHERE (cve.code_set=request->code_set)
      AND (cve.code_value=request->qual[x].code_value)
      AND (cve.field_name=request->qual[x].extension_data[y].field_name)
     DETAIL
      ext_updt_cnt = cve.updt_cnt
     WITH nocounter, forupdate(cve)
    ;end select
    IF (curqual=0)
     INSERT  FROM code_value_extension cve
      SET cve.code_set = request->code_set, cve.code_value = request->qual[x].code_value, cve
       .field_name = request->qual[x].extension_data[y].field_name,
       cve.field_type = request->qual[x].extension_data[y].field_type, cve.field_value = request->
       qual[x].extension_data[y].field_value, cve.updt_id = reqinfo->updt_id,
       cve.updt_task = reqinfo->updt_task, cve.updt_applctx = reqinfo->updt_applctx, cve.updt_cnt = 1,
       cve.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
     IF (curqual=0)
      GO TO next_code
     ENDIF
    ELSE
     IF ((ext_updt_cnt != request->qual[x].extension_data[y].updt_cnt))
      SET failed = "T"
      GO TO next_code
     ENDIF
     UPDATE  FROM code_value_extension cve
      SET cve.field_type = request->qual[x].extension_data[y].field_type, cve.field_value = request->
       qual[x].extension_data[y].field_value, cve.updt_id = reqinfo->updt_id,
       cve.updt_task = reqinfo->updt_task, cve.updt_applctx = reqinfo->updt_applctx, cve.updt_cnt = (
       ext_updt_cnt+ 1),
       cve.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (cve.code_set=request->code_set)
       AND (cve.code_value=request->qual[x].code_value)
       AND (cve.field_name=request->qual[x].extension_data[y].field_name)
      WITH nocounter
     ;end update
     IF (curqual=0)
      GO TO next_code
     ENDIF
    ENDIF
   ENDFOR
   COMMIT
 ENDFOR
 GO TO exit_script
#next_code
 IF (dup != 1)
  SET failures = (failures+ 1)
  IF (failures > dupes)
   SET stat = alter(reply->status_data.subeventstatus,failures)
  ELSE
   SET failures = (dupes+ 1)
   SET stat = alter(reply->status_data.subeventstatus,failures)
  ENDIF
  IF (failed="F")
   SET reply->status_data.subeventstatus[failures].operationstatus = "F"
  ELSE
   SET reply->status_data.subeventstatus[failures].operationstatus = "C"
  ENDIF
  SET reply->status_data.subeventstatus[failures].targetobjectvalue = cnvtstring(request->qual[x].
   code_value)
  ROLLBACK
 ENDIF
 SET x = (x+ 1)
 GO TO start_loop
#exit_script
 IF (failures=0)
  SET reply->status_data.status = "S"
 ENDIF
END GO

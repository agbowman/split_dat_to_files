CREATE PROGRAM bbt_cs_add_code:dba
 RECORD internal(
   1 qual[1]
     2 field_name = c32
     2 field_type = i4
 )
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[1]
      2 code_value = f8
      2 display_key = c40
      2 rec_status = c1
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET number_to_add = size(request->qual,5)
 SET number_of_ext = 0
 SET number_of_csext = 0
 SET stat = alter(reply->qual,number_to_add)
 SET failures = 0
 SET count1 = 0
 SET dupes = 0
 SET code_value = 0.0
 SET y = 1
 SET next_code = 0.0
 SET display_key_dup_ind = 0
 SET cdf_meaning_dup_ind = 0
 SET primary_ind_dup_ind = 0
 SET active_ind_dup_ind = 0
 SET display_dup_ind = 0
 SET add_access_ind = 0
 SET authentic_cd = 0.00
 SET dup = 0
 SET unauthentic_cd = 0.00
 SET authcnt = 0
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
 SELECT INTO "nl:"
  cse.field_name, cse.field_type
  FROM code_set_extension cse
  WHERE (cse.code_set=request->code_set)
  DETAIL
   number_of_csext = (number_of_csext+ 1), stat = alter(internal->qual,number_of_csext), internal->
   qual[number_of_csext].field_name = cse.field_name,
   internal->qual[number_of_csext].field_type = cse.field_type
  WITH nocounter
 ;end select
#start_loop
 FOR (y = y TO number_to_add)
   SET dup = 0
   SET parser_buffer[15] = fillstring(132," ")
   SET parser_number = 0
   SET new_code_value = 0
   SET parser_buffer[1] = 'select into "nl:" c.*'
   SET parser_buffer[2] = "from code_value c"
   SET parser_buffer[3] = "where c.code_set = request->code_set"
   SET parser_number = 3
   IF (display_key_dup_ind=1)
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = "  and c.display_key = request->qual[y]->display_key"
   ENDIF
   IF (display_dup_ind=1)
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = "  and c.display = request->qual[y]->display"
   ENDIF
   IF (cdf_meaning_dup_ind=1)
    IF ((request->qual[y].cdf_meaning > ""))
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = "  and c.cdf_meaning = request->qual[y]->cdf_meaning"
    ELSE
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = "  and c.cdf_meaning = NULL"
    ENDIF
   ENDIF
   IF (primary_ind_dup_ind=1)
    SET parser_number = (parser_number+ 1)
   ENDIF
   IF (active_ind_dup_ind=1)
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = "  and c.active_ind = request->qual[y]->active_ind"
   ENDIF
   IF (display_dup_ind=0
    AND display_key_dup_ind=0
    AND cdf_meaning_dup_ind=0
    AND primary_ind_dup_ind=0
    AND active_ind_dup_ind=0)
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = "  and c.display = request->qual[y]->display"
   ENDIF
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = "detail"
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = "  new_code_value = c.code_value"
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = "with nocounter go"
   FOR (z = 1 TO parser_number)
     CALL parser(parser_buffer[z],1)
   ENDFOR
   IF (curqual > 0)
    SET reply->qual[y].display_key = request->qual[y].display_key
    SET reply->qual[y].rec_status = "D"
    SET dup = 1
    GO TO get_next_code
   ENDIF
   EXECUTE cpm_next_code
   INSERT  FROM code_value c
    SET c.code_value = next_code, c.code_set = request->code_set, c.cdf_meaning =
     IF ((request->qual[y].cdf_meaning > " ")) request->qual[y].cdf_meaning
     ELSE null
     ENDIF
     ,
     c.display = request->qual[y].display, c.display_key = trim(cnvtupper(cnvtalphanum(request->qual[
        y].display))), c.description = request->qual[y].description,
     c.definition = request->qual[y].definition, c.collation_seq = request->qual[y].collation_seq, c
     .active_ind = request->qual[y].active_ind,
     c.active_type_cd =
     IF ((request->qual[y].active_ind=1)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , c.data_status_cd =
     IF ((request->qual[y].authentic_ind=1)) authentic_cd
     ELSE unauthentic_cd
     ENDIF
     , c.active_dt_tm =
     IF ((request->qual[y].active_ind=1)) cnvtdatetime(curdate,curtime3)
     ELSE null
     ENDIF
     ,
     c.inactive_dt_tm =
     IF ((request->qual[y].active_ind=0)) cnvtdatetime(curdate,curtime3)
     ELSE null
     ENDIF
     , c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id,
     c.updt_cnt = 0, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx,
     c.begin_effective_dt_tm = cnvtdatetime(request->qual[y].begin_effective_dt_tm), c
     .end_effective_dt_tm = cnvtdatetime(request->qual[y].end_effective_dt_tm)
    WITH nocounter
   ;end insert
   SET count1 = (count1+ 1)
   IF (curqual=0)
    GO TO get_next_code
   ELSE
    SET reply->qual[count1].code_value = next_code
    SET reply->qual[count1].display_key = request->qual[y].display_key
   ENDIF
   IF ((request->qual[y].extension_cnt > 0))
    SET number_of_ext = request->qual[y].extension_cnt
    INSERT  FROM code_value_extension cve,
      (dummyt d  WITH seq = value(number_of_ext))
     SET cve.code_set = request->code_set, cve.code_value = next_code, cve.field_name = request->
      qual[y].extension_data[d.seq].field_name,
      cve.field_type = request->qual[y].extension_data[d.seq].field_type, cve.field_value = request->
      qual[y].extension_data[d.seq].field_value, cve.updt_cnt = 0,
      cve.updt_id = reqinfo->updt_id, cve.updt_task = reqinfo->updt_task, cve.updt_applctx = reqinfo
      ->updt_applctx,
      cve.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (d)
      JOIN (cve
      WHERE (cve.code_set=request->code_set)
       AND cve.code_value=next_code
       AND (cve.field_name=request->qual[y].extension_data[d.seq].field_name))
     WITH nocounter, outerjoin = d, dontexist
    ;end insert
    IF (curqual != number_of_ext)
     SET reply->qual[y].rec_status = "E"
     GO TO get_next_code
    ENDIF
   ELSE
    SET number_of_ext = number_of_csext
    FOR (x = 1 TO number_of_ext)
     INSERT  FROM code_value_extension cve
      SET cve.code_set = request->code_set, cve.code_value = next_code, cve.field_name = internal->
       qual[x].field_name,
       cve.field_type = internal->qual[x].field_type, cve.field_value =
       IF ((internal->qual[x].field_type=1)) "0"
       ELSEIF ((internal->qual[x].field_type=2)) " "
       ENDIF
       , cve.updt_cnt = 0,
       cve.updt_id = reqinfo->updt_id, cve.updt_task = reqinfo->updt_task, cve.updt_applctx = reqinfo
       ->updt_applctx,
       cve.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (cve.code_set=request->code_set)
       AND cve.code_value=next_code
       AND (cve.field_name=internal->qual[x].field_name)
      WITH nocounter, outerjoin = d, dontexist
     ;end insert
     IF (curqual=0)
      SET reply->qual[y].rec_status = "S"
      GO TO get_next_code
     ENDIF
    ENDFOR
   ENDIF
   COMMIT
 ENDFOR
 GO TO exit_script
#get_next_code
 IF (dup != 1)
  SET failures = (failures+ 1)
  SET reply->qual[count1].code_value = 0.0
  SET reply->qual[count1].display_key = request->qual[y].display_key
  ROLLBACK
 ENDIF
 SET y = (y+ 1)
 GO TO start_loop
#exit_script
 IF (failures=0)
  SET reply->status_data.status = "S"
 ELSEIF (failures > 0
  AND failures != number_to_add)
  SET reply->status_data.status = "P"
 ENDIF
END GO

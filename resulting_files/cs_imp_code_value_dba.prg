CREATE PROGRAM cs_imp_code_value:dba
 RECORD reply(
   1 cv_code_set = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET display_key = cnvtupper(cnvtalphanum(request->display))
 SET display_key_dup_ind = 0
 SET cdf_meaning_dup_ind = 0
 SET active_ind_dup_ind = 0
 SET display_dup_ind = 0
 SET updt_id = reqinfo->updt_id
 SET updt_task = reqinfo->updt_task
 SET updt_applctx = reqinfo->updt_applctx
 SET cv_code_set = 0.00
 SET act_type_cd = 0.00
 SET authentic_cd = 0.00
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
 IF ((request->importsource=1))
  GO TO code_val_exist
 ELSE
  IF ((request->code_value=0))
   GO TO code_val_exist
  ELSE
   SELECT INTO "nl:"
    cv.code_set
    FROM code_value cv
    WHERE (cv.code_value=request->code_value)
    DETAIL
     cv_code_set = cv.code_set
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "A"
    GO TO exit_script
   ELSE
    IF ((cv_code_set != request->code_set))
     SET reply->status_data.status = "B"
     SET reply->cv_code_set = cv_code_set
     GO TO exit_script
    ELSE
     SET new_code_value = request->code_value
     GO TO update_insert
    ENDIF
   ENDIF
  ENDIF
 ENDIF
#code_val_exist
 SELECT
  IF ((request->active_ind=1))
   WHERE cv.cdf_meaning="ACTIVE"
    AND cv.code_set=48
  ELSE
   WHERE cv.cdf_meaning="INACTIVE"
    AND cv.code_set=48
  ENDIF
  INTO "nl:"
  cv.code_value
  FROM code_value cv
  DETAIL
   act_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cvs.display_dup_ind, cvs.display_key_dup_ind, cvs.cdf_meaning_dup_ind,
  cvs.active_ind_dup_ind
  FROM code_value_set cvs
  WHERE (cvs.code_set=request->code_set)
  DETAIL
   display_key_dup_ind = cvs.display_key_dup_ind, cdf_meaning_dup_ind = cvs.cdf_meaning_dup_ind,
   active_ind_dup_ind = cvs.active_ind_dup_ind,
   display_dup_ind = cvs.display_dup_ind
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "X"
  GO TO exit_script
 ENDIF
 SET parser_buffer[15] = fillstring(132," ")
 SET parser_number = 0
 SET new_code_value = 0
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
 FOR (z = 1 TO parser_number)
   CALL parser(parser_buffer[z],1)
 ENDFOR
#update_insert
 IF (curqual=0)
  SELECT INTO "nl:"
   xyz = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    new_code_value = cnvtreal(xyz)
   WITH format, nocounter
  ;end select
  INSERT  FROM code_value c
   SET c.code_value = new_code_value, c.code_set = request->code_set, c.cdf_meaning =
    IF ((request->cdf_meaning > " ")) request->cdf_meaning
    ELSE null
    ENDIF
    ,
    c.display = request->display, c.display_key = display_key, c.description = request->description,
    c.definition = request->definition, c.collation_seq = request->collation_seq, c.active_type_cd =
    act_type_cd,
    c.active_ind = request->active_ind, c.data_status_cd = authentic_cd, c.updt_dt_tm = cnvtdatetime(
     curdate,curtime),
    c.updt_id = updt_id, c.updt_cnt = 0, c.updt_task = updt_task,
    c.updt_applctx = updt_applctx
   WITH nocounter
  ;end insert
  SET reply->status_data.status = "S"
 ELSE
  IF ((request->importmode=1))
   UPDATE  FROM code_value c
    SET c.code_set = request->code_set, c.cdf_meaning =
     IF ((request->cdf_meaning > " ")) request->cdf_meaning
     ELSE null
     ENDIF
     , c.display = request->display,
     c.display_key = display_key, c.description = request->description, c.definition = request->
     definition,
     c.collation_seq = request->collation_seq, c.active_type_cd = act_type_cd, c.active_ind = request
     ->active_ind,
     c.data_status_cd = authentic_cd, c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_id =
     updt_id,
     c.updt_cnt = 0, c.updt_task = updt_task, c.updt_applctx = updt_applctx
    WHERE c.code_value=new_code_value
    WITH nocounter
   ;end update
   SET reply->status_data.status = "U"
  ELSE
   SET reply->status_data.status = "K"
  ENDIF
 ENDIF
#exit_script
 COMMIT
END GO

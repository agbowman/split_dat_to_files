CREATE PROGRAM cs_imp_code_alias:dba
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
 SET cv_code_set = 0.00
 SET new_code_value = 0.00
 SET reply->status_data.status = "F"
 SET jump = 0
 SET count = 0
 SET cv_code_val = 0.00
 SET cva_code_val = 0.00
 SET cva_alias = " "
 SET cva_alias_type_meaning = " "
 SET cva_source = 0.00
 SET contrib_source_cd = 0.00
 SET display_key_dup_ind = 0
 SET display_key = cnvtupper(cnvtalphanum(request->display))
 SET cdf_meaning_dup_ind = 0
 SET active_ind_dup_ind = 0
 SET display_dup_ind = 0
 SET updt_id = reqinfo->updt_id
 SET updt_task = reqinfo->updt_task
 SET updt_cnt = 0
 SET updt_applctx = reqinfo->updt_applctx
 SET cva_updt_cnt = 0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=73
   AND (cv.display=request->contributor_source_disp)
  DETAIL
   contrib_source_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "E"
  GO TO exit_script
 ENDIF
 SELECT
  IF ((request->alias_type_meaning > " "))
   WHERE (request->alias_type_meaning=cva.alias_type_meaning)
    AND (request->alias=cva.alias)
    AND contrib_source_cd=cva.contributor_source_cd
    AND (request->code_set=cva.code_set)
  ELSE
   WHERE (request->alias=cva.alias)
    AND contrib_source_cd=cva.contributor_source_cd
    AND (request->code_set=cva.code_set)
  ENDIF
  INTO "nl:"
  cva.code_value, cva.alias, cva.alias_type_meaning,
  cva.updt_cnt, cva.contributor_source_cd
  FROM code_value_alias cva
  DETAIL
   cva_code_val = cva.code_value, cva_alias = cva.alias, cva_updt_cnt = cva.updt_cnt,
   cva_alias_meaning = cva.alias_type_meaning, cva_source = cva.contributor_source_cd
  WITH nocounter, forupdate(cva)
 ;end select
 SET alias_found = curqual
 IF (alias_found > 0
  AND (request->code_value > 0))
  SET reply->status_data.status = "K"
  IF ((request->code_value != cva_code_val))
   IF ((request->alias_type_meaning > " "))
    UPDATE  FROM code_value_alias cva
     SET cva.alias_type_meaning = request->alias_type_meaning, cva.alias = request->alias, cva
      .contributor_source_cd = contrib_source_cd,
      cva.code_set = request->code_set, cva.code_value = request->code_value, cva.updt_cnt = (
      cva_updt_cnt+ 1),
      cva.updt_dt_tm = cnvtdatetime(curdate,curtime3), cva.updt_id = updt_id, cva.updt_task =
      updt_task,
      cva.updt_applctx = updt_applctx
     WHERE cva.alias_type_meaning=cva_alias_meaning
      AND (request->alias=cva.alias)
      AND contrib_source_cd=cva.contributor_source_cd
      AND (request->code_set=cva.code_set)
     WITH nocounter
    ;end update
   ELSE
    UPDATE  FROM code_value_alias cva
     SET cva.alias_type_meaning = request->alias_type_meaning, cva.alias = request->alias, cva
      .contributor_source_cd = contrib_source_cd,
      cva.code_set = request->code_set, cva.code_value = request->code_value, cva.updt_cnt = (
      cva_updt_cnt+ 1),
      cva.updt_dt_tm = cnvtdatetime(curdate,curtime3), cva.updt_id = updt_id, cva.updt_task =
      updt_task,
      cva.updt_applctx = updt_applctx
     WHERE (request->alias=cva.alias)
      AND contrib_source_cd=cva.contributor_source_cd
      AND (request->code_set=cva.code_set)
     WITH nocounter
    ;end update
   ENDIF
  ENDIF
  GO TO exit_script
 ENDIF
 IF (alias_found=0
  AND (request->importsource=0)
  AND (request->code_value=0))
  SET reply->status_data.status = "V"
  GO TO exit_script
 ENDIF
 IF (alias_found=0
  AND (request->importsource=0)
  AND (request->code_value != 0))
  SELECT INTO "nl:"
   cv.code_set, cv.code_value
   FROM code_value cv
   WHERE (request->code_value=cv.code_value)
   DETAIL
    cv_code_set = cv.code_set, cv_code_val = cv.code_value
   WITH nocounter
  ;end select
  IF (curqual=1
   AND (cv_code_set=request->code_set))
   SET new_code_value = cv_code_val
   GO TO 1000_new_alias_existing_cv
  ELSEIF (curqual=0)
   SET reply->status_data.status = "A"
  ELSE
   SET reply->status_data.status = "B"
   SET reply->cv_code_set = cv_code_set
  ENDIF
  GO TO exit_script
 ENDIF
 IF (alias_found=0
  AND (request->importsource=1))
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
   SET parser_buffer[parser_number] = "  and c.active_ind = request->cvactive_ind"
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
  SET parser_buffer[parser_number] = "  cv_code_val = c.code_value"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "with nocounter go"
  FOR (z = 1 TO parser_number)
    CALL parser(parser_buffer[z],1)
  ENDFOR
  IF (curqual=0)
   SET reply->status_data.status = "C"
  ELSE
   GO TO 1000_new_alias_existing_cv
  ENDIF
  GO TO exit_script
 ENDIF
#1000_new_alias_existing_cv
 INSERT  FROM code_value_alias cva
  SET cva.alias_type_meaning = request->alias_type_meaning, cva.alias = request->alias, cva
   .contributor_source_cd = contrib_source_cd,
   cva.code_set = request->code_set, cva.code_value = cv_code_val, cva.updt_cnt = 0,
   cva.updt_dt_tm = cnvtdatetime(curdate,curtime3), cva.updt_id = updt_id, cva.updt_task = updt_task,
   cva.updt_applctx = updt_applctx
  WITH nocounter
 ;end insert
 SET reply->status_data.status = "S"
 GO TO exit_script
#1099_new_alias_existing_cv_exit
#exit_script
 COMMIT
END GO

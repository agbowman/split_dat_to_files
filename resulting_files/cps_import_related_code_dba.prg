CREATE PROGRAM cps_import_related_code:dba
 DECLARE commit_flag = i2 WITH public, noconstant(0)
 IF (validate(readme_data,"0")="0")
  IF ( NOT (validate(readme_data,0)))
   FREE SET readme_data
   RECORD readme_data(
     1 ocd = i4
     1 readme_id = f8
     1 instance = i4
     1 readme_type = vc
     1 description = vc
     1 script = vc
     1 check_script = vc
     1 data_file = vc
     1 par_file = vc
     1 blocks = i4
     1 log_rowid = vc
     1 status = vc
     1 message = c255
     1 options = vc
     1 driver = vc
     1 batch_dt_tm = dq8
   )
  ENDIF
  SET commit_flag = 1
 ENDIF
 SET readme_data->status = "F"
 SET log_file = concat("cps_imp_",cnvtlower(trim(requestin->list_0[1].source_vocab_mean)),
  "_related_code.log")
 SET rvar = 0
 SELECT INTO value(log_file)
  rvar
  HEAD REPORT
   row + 1, "CPS_IMPORT_RELATED_CODE  :begin >", curtime"hh:mm:ss;;m",
   col + 2, curdate"dd-mmm-yyyy;;d"
  DETAIL
   col 0
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
 SET dup_found = 0
 SET nbr_overlaps = 0
 SET error_line = fillstring(125," ")
 SET qual = size(requestin->list_0,5)
 SET x = 1
#start_loop
 IF (x > qual)
  GO TO exit_script
 ENDIF
 FOR (x = x TO qual)
   SET source_vocab_cd = 0.0
   SET code_set = 400
   SET code_value = 0.0
   IF ((requestin->list_0[x].source_vocab_mean != " "))
    SET cdf_meaning = cnvtupper(substring(1,12,requestin->list_0[x].source_vocab_mean))
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.cdf_meaning=cdf_meaning
      AND cv.code_set=code_set
     DETAIL
      code_value = cv.code_value
     WITH nocounter
    ;end select
    SET source_vocab_cd = code_value
    IF (code_value < 1)
     SET error_line = concat("  ERROR> Failed to find cdf_meaning ",trim(cdf_meaning)," in code_set ",
      trim(cnvtstring(code_set)))
     SET reqinfo->commit_ind = 3
     CALL error_handling(error_line)
     GO TO exit_script
    ENDIF
   ELSE
    SET error_line = concat("  ERROR> source_vocab_mean must be > blank")
    SET reqinfo->commit_ind = 3
    CALL error_handling(error_line)
    GO TO exit_script
   ENDIF
   SET related_vocab_cd = 0.0
   SET code_set = 400
   SET code_value = 0.0
   IF ((requestin->list_0[x].related_vocab_mean != " "))
    SET cdf_meaning = cnvtupper(substring(1,12,requestin->list_0[x].related_vocab_mean))
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.cdf_meaning=cdf_meaning
      AND cv.code_set=code_set
     DETAIL
      code_value = cv.code_value
     WITH nocounter
    ;end select
    SET related_vocab_cd = code_value
    IF (code_value < 1)
     SET error_line = concat("  ERROR> Failed to find cdf_meaning ",trim(cdf_meaning)," in code_set ",
      trim(cnvtstring(code_set)))
     SET reqinfo->commit_ind = 3
     CALL error_handling(error_line)
     GO TO exit_script
    ENDIF
   ELSE
    SET error_line = concat("  ERROR> related_vocab_mean must be > blank")
    SET reqinfo->commit_ind = 3
    CALL error_handling(error_line)
    GO TO exit_script
   ENDIF
   SET active_status_cd = 0.0
   SET code_set = 48
   SET code_value = 0.0
   SET cdf_meaning = "ACTIVE"
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.cdf_meaning=cdf_meaning
     AND cv.code_set=code_set
    DETAIL
     code_value = cv.code_value
    WITH nocounter
   ;end select
   SET active_status_cd = code_value
   IF (code_value < 1)
    SET error_line = concat("  ERROR> Failed to find cdf_meaning ",trim(cdf_meaning)," in code_set ",
     trim(cnvtstring(code_set)))
    SET reqinfo->commit_ind = 3
    CALL error_handling(error_line)
    GO TO exit_script
   ENDIF
   SET next_code = 0.0
   SET vocab_id = 0.0
   EXECUTE cps_next_nom_seq
   SET vocab_id = next_code
   SET overlap_dates = 0
   SET dup_found = false
   SET nbr_overlaps = false
   SET vocab_rel_code_id = 0.0
   SELECT INTO "nl:"
    v.source_identifier
    FROM vocab_related_code v
    WHERE v.source_vocab_cd=source_vocab_cd
     AND (v.source_identifier=requestin->list_0[x].source_identifier)
     AND v.related_vocab_cd=related_vocab_cd
     AND (v.related_identifier=requestin->list_0[x].related_identifier)
    DETAIL
     IF (v.beg_effective_dt_tm=cnvtdatetime(requestin->list_0[x].beg_effective_dt_tm)
      AND v.end_effective_dt_tm=cnvtdatetime(requestin->list_0[x].end_effective_dt_tm))
      dup_found = true
     ELSE
      IF (((v.beg_effective_dt_tm <= cnvtdatetime(requestin->list_0[x].beg_effective_dt_tm)
       AND v.end_effective_dt_tm >= cnvtdatetime(requestin->list_0[x].beg_effective_dt_tm)) OR (((v
      .beg_effective_dt_tm <= cnvtdatetime(requestin->list_0[x].end_effective_dt_tm)
       AND v.end_effective_dt_tm >= cnvtdatetime(requestin->list_0[x].end_effective_dt_tm)) OR (v
      .beg_effective_dt_tm >= cnvtdatetime(requestin->list_0[x].beg_effective_dt_tm)
       AND v.end_effective_dt_tm <= cnvtdatetime(requestin->list_0[x].end_effective_dt_tm))) )) )
       nbr_overlaps = (nbr_overlaps+ 1), vocab_rel_code_id = v.vocab_rel_code_id
       IF (nbr_overlaps > 1)
        overlap_dates = true
       ENDIF
      ENDIF
     ENDIF
    WITH check
   ;end select
   IF (dup_found=true)
    GO TO increment_item
   ENDIF
   IF (nbr_overlaps > 0)
    IF (overlap_dates=true)
     SET error_line = concat("  WARNING> Overlapping effective dates for source_vocab:",trim(
       cnvtstring(source_vocab_cd))," source_id: ",trim(requestin->list_0[x].source_identifier),
      " related_vocab: ",
      trim(cnvtstring(related_vocab_cd))," related_id: ",trim(requestin->list_0[x].related_identifier
       ))
     CALL error_handling(error_line)
     GO TO increment_item
    ELSE
     UPDATE  FROM vocab_related_code v
      SET v.end_effective_dt_tm = cnvtdatetime(concat(trim(requestin->list_0[x].end_effective_dt_tm),
         " 23:59:59")), v.active_ind = 1, v.updt_cnt = (v.updt_cnt+ 1),
       v.updt_dt_tm = cnvtdatetime(curdate,curtime3), v.updt_id = 0.0, v.updt_task = reqinfo->
       updt_task,
       v.updt_applctx = 0
      WHERE v.vocab_rel_code_id=vocab_rel_code_id
      WITH check
     ;end update
     IF (curqual=0)
      SET error_line = concat("  ERROR> Failed to update source_vocab:",trim(source_vocab_cd),
       " source_identifier: ",trim(requestin->list_0[x].source_identifier)," related_vocab: ",
       trim(related_vocab_cd)," related_identifier: ",trim(requestin->list_0[x].related_identifier))
      CALL error_handling(error_line)
     ENDIF
    ENDIF
   ELSE
    INSERT  FROM vocab_related_code v
     SET v.vocab_rel_code_id = vocab_id, v.source_vocab_cd = source_vocab_cd, v.source_identifier =
      requestin->list_0[x].source_identifier,
      v.related_vocab_cd = related_vocab_cd, v.related_identifier = requestin->list_0[x].
      related_identifier, v.active_ind = 1,
      v.active_status_cd = active_status_cd, v.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      v.active_status_prsnl_id = 0,
      v.beg_effective_dt_tm = cnvtdatetime(requestin->list_0[x].beg_effective_dt_tm), v
      .end_effective_dt_tm = cnvtdatetime(concat(trim(requestin->list_0[x].end_effective_dt_tm),
        " 23:59:59")), v.updt_cnt = 0,
      v.updt_dt_tm = cnvtdatetime(curdate,curtime3), v.updt_id = 0, v.updt_task = reqinfo->updt_task,
      v.updt_applctx = 0
     WITH nocounter
    ;end insert
   ENDIF
   COMMIT
 ENDFOR
 GO TO exit_script
 SUBROUTINE error_handling(the_output)
   SELECT INTO value(log_file)
    rvar
    HEAD REPORT
     col 5, the_output
    DETAIL
     col 0
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
#increment_item
 SET x = (x+ 1)
 GO TO start_loop
#next_item
 ROLLBACK
 SET x = (x+ 1)
 GO TO start_loop
#exit_script
 SELECT INTO value(log_file)
  rvar
  HEAD REPORT
   IF ((reqinfo->commit_ind=3))
    success_ind = "FAILURE"
   ELSE
    success_ind = "SUCCESS"
   ENDIF
   col 0, "End   : ", success_ind,
   " ", curtime"hh:mm:ss;;m", col + 2,
   curdate"dd-mmm-yyyy;;d"
  DETAIL
   col 0
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
 IF ((reqinfo->commit_ind=3))
  SET readme_data->status = "F"
  SET readme_data->message = "Data insert failed."
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Data inserted successfully."
 ENDIF
 EXECUTE dm_readme_status
END GO

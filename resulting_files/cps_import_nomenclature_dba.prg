CREATE PROGRAM cps_import_nomenclature:dba
 RECORD reqinfo(
   1 commit_ind = i2
   1 updt_id = f8
   1 position_cd = f8
   1 updt_app = i4
   1 updt_task = i4
   1 updt_req = i4
   1 updt_applctx = i4
 )
 SET reqinfo->updt_id = 0
 SET reqinfo->updt_app = 13000
 SET reqinfo->updt_task = 0
 SET reqinfo->updt_req = 0
 SET reqinfo->updt_applctx = 0
 FREE SET err_log
 RECORD err_log(
   1 msg_qual = i4
   1 msg[*]
     2 err_msg = vc
 )
 SET msg_knt = 0
 SET err_log->msg_qual = msg_knt
 SET err_level = 0
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET nbr_recs = size(requestin->list_0,5)
 SET x = 1
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0.0
 SET code_value = 0.0
 SET msg = fillstring(125," ")
 SET errmsg = fillstring(132," ")
 SET row_commit = false
 SET updt_version = false
 SET valid_string = false
 SET db_ver_dt_tm = fillstring(20," ")
 SET db_version = fillstring(20," ")
 SET log_file = fillstring(30," ")
 SET dvar = 0
 SET source_vocab_mean = fillstring(12," ")
 SET import_vocab = fillstring(12," ")
 SET axis = fillstring(12," ")
 SET active_status_cd = 0.0
 SET contr_sys_cd = 0.0
 SET language_cd = 0.0
 SET concept_source_cd = 0.0
 SET principle_type_cd = 0.0
 SET string_source_cd = 0.0
 SET source_vocab_cd = 0.0
 SET vocab_axis_cd = 0.0
 SET string_status_cd = 0.0
 SET data_status_cd = 0.0
 SET term_source_cd = 0.0
 SET term_id = 0.0
 SET next_code = 0.0
 SET nomen_id = 0.0
 SET source_string_ind = false
 SET source_ident_ind = false
 SET parser_buffer[100] = fillstring(100," ")
 SELECT INTO "nl:"
  FROM dba_tab_columns d
  WHERE d.table_name="NOMENCLATURE"
   AND d.column_name="SOURCE_STRING_KEYCAP"
  DETAIL
   source_string_ind = true
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dba_tab_columns d
  WHERE d.table_name="NOMENCLATURE"
   AND d.column_name="SOURCE_IDENTIFIER_KEYCAP"
  DETAIL
   source_ident_ind = true
  WITH nocounter
 ;end select
 SET a_dup = true
 SET a_pure_dup = true
 FREE SET nomen_list
 RECORD nomen_list(
   1 srcstr = vc
   1 qual_knt = i4
   1 qual[*]
     2 id = f8
 )
 SET tnomen_id = 0.0
 SET tactive_ind = 0
 SET tbeg_dt_tm = 0.0
 DECLARE tmp_nomen_id = f8 WITH public, noconstant(0.0)
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_IMPORT_NOMENCLATURE begin : ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 IF ((requestin->list_0[x].source_vocabulary_mean="UPDATE"))
  SET import_vocab = cnvtupper(substring(1,12,requestin->list_0[x].concept_source_mean))
 ELSE
  SET import_vocab = cnvtupper(substring(1,12,requestin->list_0[x].source_vocabulary_mean))
 ENDIF
 SET log_file = concat("CPS_IMP_NOMEN.LOG")
 SET source_vocab_cd = 0.0
 SET code_value = 0.0
 SET code_set = 400
 SET cdf_meaning = cnvtupper(trim(requestin->list_0[x].source_vocabulary_mean))
 EXECUTE cpm_get_cd_for_cdf
 SET source_vocab_cd = code_value
 IF ((requestin->list_0[x].version > " "))
  SET import_version = trim(requestin->list_0[x].version)
  SET year_minus1 = trim(cnvtstring((cnvtint(import_version) - 1)))
  IF ( NOT (cnvtint(year_minus1) <= 2100
   AND cnvtint(year_minus1) >= 1700))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to convert version correctly import",
    " version : ",import_version," year_minus1 : ",trim(year_minus1))
   SET err_level = 2
   SET reqinfo->commit_ind = 3
   GO TO exit_script
  ENDIF
  SET end_eff_dt_tm = concat("31-DEC-",year_minus1," 23:59:59")
 ELSE
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("  ERROR> version must be > blank")
  SET err_level = 2
  SET reqinfo->commit_ind = 3
  GO TO exit_script
 ENDIF
 IF (x=nbr_recs
  AND cnvtupper(trim(requestin->list_0[x].source_vocabulary_mean))="UPDATE")
  SET updt_version = true
  GO TO exit_script
 ENDIF
 IF (nbr_recs >= 1
  AND cnvtupper(trim(requestin->list_0[x].source_vocabulary_mean))="UPDATE")
  SET source_vocab_cd = 0.0
  SET code_value = 0.0
  SET code_set = 400
  SET cdf_meaning = cnvtupper(trim(requestin->list_0[x].source_vocabulary_mean))
  EXECUTE cpm_get_cd_for_cdf
  SET source_vocab_cd = code_value
  IF (code_value < 1)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat(
    "  ERROR> Failed to find import vocabulary cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(
     cnvtstring(code_set)))
   SET err_level = 2
   SET reqinfo->commit_ind = 3
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   c.code_value
   FROM code_value_extension c
   PLAN (c
    WHERE c.code_value=source_vocab_cd
     AND c.code_set=code_set
     AND c.field_name="VERSION")
   HEAD REPORT
    db_version = c.field_value, db_ver_dt_tm = format(cnvtdatetime(c.updt_dt_tm),"dd-mmm-yyyy hh:mm")
   WITH nocounter, maxqual(c,1)
  ;end select
  IF (curqual > 0)
   IF (cnvtreal(db_version) >= cnvtreal(import_version))
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("  WARNING> Import version <= current version")
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("    current version : ",trim(requestin->list_0[x].
      concept_source_mean),"  v",trim(db_version),"  ",
     trim(db_ver_dt_tm))
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("    import version  : ",trim(requestin->list_0[x].
      concept_source_mean),"  v",import_version)
    SET err_level = 1
    SET reqinfo->commit_ind = 3
    GO TO exit_script
   ENDIF
  ENDIF
  SET x = (x+ 1)
 ENDIF
 SET active_status_cd = 0.0
 SET code_value = 0.0
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET active_status_cd = code_value
 IF (code_value < 1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to find cdf_meaning ",trim(cdf_meaning),
   " in code_set ",trim(cnvtstring(code_set)))
  SET err_level = 2
  SET reqinfo->commit_ind = 3
  GO TO exit_script
 ENDIF
 SET language_cd = 0.0
 IF ((requestin->list_0[x].language_mean > " ")
  AND (requestin->list_0[x].language_mean != "ENG"))
  SET cdf_meaning = cnvtupper(substring(1,12,requestin->list_0[x].language_mean))
 ELSE
  SET cdf_meaning = "ENG"
 ENDIF
 SET code_value = 0
 SET code_set = 36
 EXECUTE cpm_get_cd_for_cdf
 SET language_cd = code_value
 IF (code_value < 1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to find cdf_meaning ",trim(cdf_meaning),
   " in code_set ",trim(cnvtstring(code_set)))
  SET err_level = 2
  SET reqinfo->commit_ind = 3
  GO TO exit_script
 ENDIF
#begin_loop
 IF (x > nbr_recs)
  GO TO exit_script
 ENDIF
 FOR (x = x TO nbr_recs)
   IF (x=nbr_recs
    AND cnvtupper(trim(requestin->list_0[x].source_vocabulary_mean))="UPDATE")
    SET updt_version = true
    GO TO exit_script
   ENDIF
   IF ((requestin->list_0[x].source_string > " "))
    SET valid_string = true
   ELSE
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("  WARNING> source_string must be > blank")
    SET err_level = 1
    GO TO increment_item
   ENDIF
   SET source_vocab_cd = 0.0
   SET code_value = 0.0
   SET code_set = 400
   SET cdf_meaning = cnvtupper(trim(requestin->list_0[x].source_vocabulary_mean))
   EXECUTE cpm_get_cd_for_cdf
   SET source_vocab_cd = code_value
   IF (code_value < 1)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat(
     "  ERROR> Failed to find import vocabulary cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(
      cnvtstring(code_set)))
    SET err_level = 2
    SET reqinfo->commit_ind = 3
    GO TO exit_script
   ENDIF
   SET principle_type_cd = 0.0
   SET code_value = 0.0
   SET code_set = 401
   IF ((requestin->list_0[x].principle_type_mean != " "))
    SET cdf_meaning = cnvtupper(substring(1,12,requestin->list_0[x].principle_type_mean))
   ELSE
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("Error > Principle Type meaning should be > blank")
    SET err_level = 2
    SET reqinfo->commit_ind = 3
    GO TO exit_script
   ENDIF
   EXECUTE cpm_get_cd_for_cdf
   SET principle_type_cd = code_value
   IF (code_value < 1)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to find cdf_meaning ",trim(
      cdf_meaning)," in code_set ",trim(cnvtstring(code_set)))
    SET err_level = 2
    SET reqinfo->commit_ind = 3
    GO TO exit_script
   ENDIF
   SET contr_sys_cd = 0.0
   SET contributor_system_mean = cnvtupper(requestin->list_0[x].contributor_system_mean)
   IF ((requestin->list_0[x].contributor_system_mean != " "))
    SET code_value = 0.0
    SET code_set = 89
    SET cdf_meaning = cnvtupper(substring(1,12,requestin->list_0[x].contributor_system_mean))
    EXECUTE cpm_get_cd_for_cdf
    SET contr_sys_cd = code_value
    IF (code_value < 1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to find cdf_meaning ",trim(
       cdf_meaning)," in code_set ",trim(cnvtstring(code_set)))
     SET err_level = 2
     SET reqinfo->commit_ind = 3
     GO TO exit_script
    ENDIF
   ELSE
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("  ERROR> contributor_system_mean must be > blank")
    SET err_level = 2
    SET reqinfo->commit_ind = 3
    GO TO exit_script
   ENDIF
   IF (cnvtint(requestin->list_0[x].primary_vterm_ind)=1)
    UPDATE  FROM nomenclature n
     SET n.primary_vterm_ind = 1, n.updt_cnt = (n.updt_cnt+ 1), n.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->
      updt_applctx
     PLAN (n
      WHERE n.source_vocabulary_cd=source_vocab_cd
       AND (n.source_identifier=requestin->list_0[x].source_identifier)
       AND (n.source_string=requestin->list_0[x].source_string)
       AND n.principle_type_cd=principle_type_cd
       AND n.primary_vterm_ind IN (0, null))
     WITH nocounter
    ;end update
    UPDATE  FROM nomenclature n
     SET n.primary_vterm_ind = 0, n.updt_cnt = (n.updt_cnt+ 1), n.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->
      updt_applctx
     PLAN (n
      WHERE (n.source_identifier=requestin->list_0[x].source_identifier)
       AND (n.source_string != requestin->list_0[x].source_string)
       AND n.source_vocabulary_cd=source_vocab_cd
       AND n.end_effective_dt_tm > cnvtdatetime("30-DEC-2100")
       AND n.active_ind=1
       AND n.primary_vterm_ind IN (null, 0))
     WITH nocounter
    ;end update
   ELSE
    UPDATE  FROM nomenclature n
     SET n.primary_vterm_ind = 0, n.updt_cnt = (n.updt_cnt+ 1), n.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->
      updt_applctx
     PLAN (n
      WHERE (n.source_string=requestin->list_0[x].source_string)
       AND (n.source_identifier=requestin->list_0[x].source_identifier)
       AND n.source_vocabulary_cd=source_vocab_cd
       AND n.primary_vterm_ind IN (null, 1))
     WITH nocounter
    ;end update
   ENDIF
   SET vocab_axis_cd = 0.0
   IF ((requestin->list_0[x].vocab_axis_mean != " "))
    SET code_value = 0.0
    SET code_set = 15849
    SET display_key = cnvtupper(substring(1,40,requestin->list_0[x].vocab_axis_mean))
    SELECT INTO "nl:"
     c.code_value
     FROM code_value c
     WHERE c.code_set=code_set
      AND c.display_key=cnvtupper(display_key)
      AND c.active_ind=1
      AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     HEAD REPORT
      code_value = c.code_value
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET code_value = 0
    ENDIF
    SET vocab_axis_cd = code_value
    IF (code_value < 1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("  WARNING> Failed to find display_key ",trim(
       display_key)," in code_set ",trim(cnvtstring(code_set)))
     SET err_level = 1
    ENDIF
   ENDIF
   SET string_status_cd = 0.0
   IF ((requestin->list_0[x].string_status_mean != " "))
    SET code_value = 0.0
    SET code_set = 12103
    SET cdf_meaning = cnvtupper(substring(1,12,requestin->list_0[x].string_status_mean))
    EXECUTE cpm_get_cd_for_cdf
    SET string_status_cd = code_value
    IF (code_value < 1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("  WARNING> Failed to find cdf_meaning ",trim(
       cdf_meaning)," in code_set ",trim(cnvtstring(code_set)))
     SET err_level = 1
    ENDIF
   ENDIF
   SET data_status_cd = 0.0
   IF ((requestin->list_0[x].data_status_mean != " "))
    SET code_value = 0.0
    SET code_set = 8
    SET cdf_meaning = cnvtupper(substring(1,12,requestin->list_0[x].data_status_mean))
    EXECUTE cpm_get_cd_for_cdf
    SET data_status_cd = code_value
    IF (code_value < 1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("  WARNING> Failed to find cdf_meaning ",trim(
       cdf_meaning)," in code_set ",trim(cnvtstring(code_set)))
     SET err_level = 1
    ENDIF
   ENDIF
   SET string_source_cd = 0.0
   SET code_value = 0.0
   SET code_set = 12100
   IF ((requestin->list_0[x].string_source_mean != " "))
    SET cdf_meaning = cnvtupper(substring(1,12,requestin->list_0[x].string_source_mean))
    EXECUTE cpm_get_cd_for_cdf
    SET string_source_cd = code_value
    IF (code_value < 1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to find cdf_meaning ",trim(
       cdf_meaning)," in code_set ",trim(cnvtstring(code_set)))
     SET err_level = 2
     SET reqinfo->commit_ind = 3
     GO TO exit_script
    ENDIF
   ELSE
    IF ((requestin->list_0[x].string_identifier > " "))
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("  ERROR> string_source_mean must be > blank  : ",
      "String_Identifier = ",requestin->list_0[x].string_identifier)
     SET err_level = 2
     SET reqinfo->commit_ind = 3
     GO TO exit_script
    ENDIF
   ENDIF
   SET concept_source_cd = 0.0
   SET code_set = 12100
   SET cdf_meaning = fillstring(12," ")
   IF ((requestin->list_0[x].concept_source_mean != " "))
    SET code_value = 0.0
    SET cdf_meaning = cnvtupper(substring(1,12,requestin->list_0[x].concept_source_mean))
    EXECUTE cpm_get_cd_for_cdf
    SET concept_source_cd = code_value
    IF (code_value < 1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("  WARNING> Failed to find cdf_meaning ",trim(
       cdf_meaning)," in code_set ",trim(cnvtstring(code_set)))
     SET err_level = 1
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].concept_identifier != " "))
    IF (concept_source_cd < 1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("  WARNING> Failed to find cdf_meaning ",trim(
       cdf_meaning)," in code_set ",trim(cnvtstring(code_set))," : ",
      trim(requestin->list_0[x].concept_identifier)," ",trim(requestin->list_0[x].source_identifier),
      " ",trim(requestin->list_0[x].string_identifier))
     SET err_level = 1
    ENDIF
    SELECT INTO "nl:"
     c.concept_identifier
     FROM concept c
     PLAN (c
      WHERE (c.concept_identifier=requestin->list_0[x].concept_identifier)
       AND c.concept_source_cd=concept_source_cd)
     WITH nocounter, maxqual(c,1)
    ;end select
    IF (curqual < 1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("  WARNING> Failed to find the ",
      "concept_identifier on the concept table ",trim(requestin->list_0[x].concept_identifier)," ",
      trim(requestin->list_0[x].source_identifier),
      " ",trim(requestin->list_0[x].string_identifier))
     SET err_level = 1
    ENDIF
   ENDIF
   UPDATE  FROM nomenclature n
    SET n.vocab_axis_cd = vocab_axis_cd, n.string_identifier = requestin->list_0[x].string_identifier,
     n.string_status_cd = string_status_cd,
     n.string_source_cd = string_source_cd, n.language_cd = language_cd, n.concept_identifier = trim(
      requestin->list_0[x].concept_identifier),
     n.concept_source_cd = concept_source_cd, n.beg_effective_dt_tm =
     IF ((requestin->list_0[x].beg_effective_dt_tm != " ")) cnvtdatetime(requestin->list_0[x].
       beg_effective_dt_tm)
     ENDIF
     , n.end_effective_dt_tm = cnvtdatetime("31-Dec-2100 23:59:59"),
     n.mnemonic =
     IF ((requestin->list_0[x].mnemonic != " ")) substring(1,25,requestin->list_0[x].mnemonic)
     ELSE " "
     ENDIF
     , n.short_string =
     IF ((requestin->list_0[x].short_string != " ")) substring(1,60,requestin->list_0[x].short_string
       )
     ELSE " "
     ENDIF
     , n.contributor_system_cd = contr_sys_cd,
     n.data_status_cd = data_status_cd, n.updt_cnt = (n.updt_cnt+ 1), n.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->
     updt_applctx
    PLAN (n
     WHERE n.source_vocabulary_cd=source_vocab_cd
      AND (n.source_identifier=requestin->list_0[x].source_identifier)
      AND (n.source_string=requestin->list_0[x].source_string)
      AND n.principle_type_cd=principle_type_cd
      AND ((n.vocab_axis_cd != vocab_axis_cd) OR ((((n.string_identifier != requestin->list_0[x].
     string_identifier)) OR (((n.string_status_cd != string_status_cd) OR (((n.language_cd !=
     language_cd) OR (((n.concept_identifier != trim(requestin->list_0[x].concept_identifier)) OR (((
     n.concept_source_cd != concept_source_cd) OR (((n.beg_effective_dt_tm != cnvtdatetime(requestin
      ->list_0[x].beg_effective_dt_tm)
      AND (requestin->list_0[x].beg_effective_dt_tm != " ")) OR (((n.end_effective_dt_tm <
     cnvtdatetime("31-dec-2100")) OR ((((n.mnemonic != requestin->list_0[x].mnemonic)) OR ((((n
     .short_string != requestin->list_0[x].short_string)) OR (((n.contributor_system_cd !=
     contr_sys_cd) OR (n.data_status_cd != data_status_cd)) )) )) )) )) )) )) )) )) )) )) )
    WITH nocounter
   ;end update
   SET tnomen_id = 0.0
   SET tactive_ind = 1
   SET tbeg_dt_tm = 0.0
   CALL chk_nomen_dup(source_vocab_cd,requestin->list_0[x].source_identifier,requestin->list_0[x].
    source_string,principle_type_cd)
   IF (a_pure_dup=true)
    SELECT INTO "nl:"
     n.nomenclature_id
     FROM (dummyt d  WITH seq = value(nomen_list->qual_knt)),
      nomenclature n
     PLAN (d
      WHERE d.seq > 0)
      JOIN (n
      WHERE (n.nomenclature_id=nomen_list->qual[d.seq].id))
     HEAD REPORT
      tnomen_id = n.nomenclature_id, tactive_ind = n.active_ind
     DETAIL
      dvar = 0
     WITH nocounter
    ;end select
    IF (tactive_ind=0)
     IF ((requestin->list_0[x].beg_effective_dt_tm != " "))
      SET tbeg_dt_tm = cnvtdatetime(requestin->list_0[x].beg_effective_dt_tm)
     ELSE
      SET tbeg_dt_tm = cnvtdatetime(curdate,curtime3)
     ENDIF
     CALL activate_nomen_item(tnomen_id,tbeg_dt_tm,requestin->list_0[x].primary_vterm_ind)
     IF (curqual != 1)
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to activate nomenclature item",
       " Nomenclature_Id = ",trim(cnvtstring(tnomen_id)))
      SET errcode = error(errmsg,1)
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = errmsg
      SET err_level = 2
      SET reqinfo->commit_ind = 3
      GO TO exit_script
     ELSE
      GO TO increment_item
     ENDIF
    ELSE
     GO TO increment_item
    ENDIF
   ELSEIF (import_vocab="MUL.MMDC")
    FREE SET multum_list
    RECORD multum_list(
      1 qual_knt = i4
      1 qual[*]
        2 id = f8
        2 inact_string = vc
    )
    SET multum_list->qual_knt = 0
    SET errcode = error(errmsg,1)
    SET knt1 = 0
    SELECT INTO "nl:"
     n.nomenclature_id
     FROM nomenclature n
     PLAN (n
      WHERE n.source_identifier=cnvtupper(requestin->list_0[x].source_identifier)
       AND n.source_vocabulary_cd=source_vocab_cd
       AND n.principle_type_cd=principle_type_cd
       AND (n.source_string != requestin->list_0[x].source_string))
     HEAD REPORT
      knt1 = 0, stat = alterlist(multum_list->qual,10)
     DETAIL
      knt1 = (knt1+ 1)
      IF (mod(knt1,10)=1
       AND knt1 != 1)
       stat = alterlist(multum_list->qual,(knt1+ 9))
      ENDIF
      multum_list->qual[knt1].id = n.nomenclature_id, multum_list->qual[knt1].inact_string = concat(
       substring(1,250,requestin->list_0[x].source_string)," ",trim(cnvtstring(knt1)))
     FOOT REPORT
      multum_list->qual_knt = knt1, stat = alterlist(multum_list->qual,knt1)
     WITH nocounter, orahint("index(n XAK2NOMENCLATURE)")
    ;end select
    IF (curqual > 0)
     IF ((multum_list->qual_knt > 1))
      SET update_knt = (multum_list->qual_knt - 1)
      IF (source_string_ind)
       UPDATE  FROM nomenclature n,
         (dummyt d  WITH seq = value(update_knt))
        SET n.source_string = trim(multum_list->qual[d.seq].inact_string), n.source_string_keycap =
         cnvtupper(requestin->list_0[x].source_string), n.active_ind = 0,
         n.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_cnt = (n.updt_cnt+ 1), n
         .updt_dt_tm = cnvtdatetime(curdate,curtime3),
         n.updt_id = 0.0, n.updt_task = 0.0, n.updt_applctx = 0.0
        PLAN (d
         WHERE d.seq > 0)
         JOIN (n
         WHERE (n.nomenclature_id=multum_list->qual[d.seq].id))
        WITH nocounter
       ;end update
      ELSE
       UPDATE  FROM nomenclature n,
         (dummyt d  WITH seq = value(update_knt))
        SET n.source_string = trim(multum_list->qual[d.seq].inact_string), n.active_ind = 0, n
         .end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
         n.updt_cnt = (n.updt_cnt+ 1), n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = 0.0,
         n.updt_task = 0.0, n.updt_applctx = 0.0
        PLAN (d
         WHERE d.seq > 0)
         JOIN (n
         WHERE (n.nomenclature_id=multum_list->qual[d.seq].id))
        WITH nocounter
       ;end update
      ENDIF
      IF (curqual != update_knt)
       SET msg_knt = (msg_knt+ 1)
       SET stat = alterlist(err_log->msg,msg_knt)
       SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Updating Multum source_string :",
        " Source_Vocabulary = ",trim(import_vocab)," Source_Identifier = ",trim(cnvtupper(requestin->
          list_0[x].source_identifier)),
        " Principle_Type = ",trim(cdf_meaning))
       SET errcode = error(errmsg,1)
       SET msg_knt = (msg_knt+ 1)
       SET stat = alterlist(err_log->msg,msg_knt)
       SET err_log->msg[msg_knt].err_msg = errmsg
       SET err_level = 2
       SET reqinfo->commit_ind = 3
       GO TO exit_script
      ELSE
       SET msg_knt = (msg_knt+ 1)
       SET stat = alterlist(err_log->msg,msg_knt)
       SET err_log->msg[msg_knt].err_msg = concat("  INFO> Updated multiple Multum ",
        "source_strings :"," Source_Vocabulary = ",trim(import_vocab)," Source_Identifier = ",
        trim(cnvtupper(requestin->list_0[x].source_identifier))," Principle_Type = ",trim(cdf_meaning
         ))
      ENDIF
     ENDIF
     SELECT INTO "nl:"
      FROM nomenclature n
      WHERE n.source_string=trim(requestin->list_0[x].source_string)
       AND n.source_identifier=cnvtupper(requestin->list_0[x].source_identifier)
       AND n.source_vocabulary_cd=source_vocab_cd
       AND n.principle_type_cd=principle_type_cd
      DETAIL
       tmp_nomen_id = n.nomenclature_id
      WITH nocounter
     ;end select
     IF (curqual > 0)
      IF (source_string_ind)
       UPDATE  FROM nomenclature n
        SET n.source_string_keycap = cnvtupper(requestin->list_0[x].source_string), n.active_ind = 1,
         n.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         n.updt_cnt = (n.updt_cnt+ 1), n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = 0.0,
         n.updt_task = 0.0, n.updt_applctx = 0.0
        WHERE n.nomenclature_id=tmp_nomen_id
        WITH nocounter
       ;end update
      ELSE
       UPDATE  FROM nomenclature n
        SET n.active_ind = 1, n.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), n.updt_cnt = (n
         .updt_cnt+ 1),
         n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = 0.0, n.updt_task = 0.0,
         n.updt_applctx = 0.0
        WHERE n.nomenclature_id=tmp_nomen_id
        WITH nocounter
       ;end update
      ENDIF
     ELSE
      IF (source_string_ind)
       UPDATE  FROM nomenclature n
        SET n.source_string = requestin->list_0[x].source_string, n.source_string_keycap = cnvtupper(
          requestin->list_0[x].source_string), n.active_ind = 1,
         n.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), n.updt_cnt = (n.updt_cnt+ 1), n
         .updt_dt_tm = cnvtdatetime(curdate,curtime3),
         n.updt_id = 0.0, n.updt_task = 0.0, n.updt_applctx = 0.0
        WHERE (n.nomenclature_id=multum_list->qual[knt1].id)
        WITH nocounter
       ;end update
      ELSE
       UPDATE  FROM nomenclature n
        SET n.source_string = requestin->list_0[x].source_string, n.active_ind = 1, n
         .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         n.updt_cnt = (n.updt_cnt+ 1), n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = 0.0,
         n.updt_task = 0.0, n.updt_applctx = 0.0
        WHERE (n.nomenclature_id=multum_list->qual[knt1].id)
        WITH nocounter
       ;end update
      ENDIF
     ENDIF
     IF (curqual < 1)
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Updating Multum source_string :",
       " Source_Vocabulary = ",trim(import_vocab)," Source_Identifier = ",trim(cnvtupper(requestin->
         list_0[x].source_identifier)),
       " Principle_Type = ",trim(cdf_meaning))
      SET errcode = error(errmsg,1)
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = errmsg
      SET err_level = 2
      SET reqinfo->commit_ind = 3
      GO TO exit_script
     ENDIF
     FOR (j = 1 TO multum_list->qual_knt)
       SET nomen_id = multum_list->qual[j].id
       EXECUTE cps_ens_normalized_index nomen_id
       IF (curqual < 1)
        SET msg_knt = (msg_knt+ 1)
        SET stat = alterlist(err_log->msg,msg_knt)
        SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to normalize string :",
         " nomenclature_id = ",trim(cnvtstring(nomen_id)))
        SET errcode = error(errmsg,1)
        SET msg_knt = (msg_knt+ 1)
        SET stat = alterlist(err_log->msg,msg_knt)
        SET err_log->msg[msg_knt].err_msg = errmsg
        SET err_level = 2
        SET reqinfo->commit_ind = 3
        GO TO exit_script
       ENDIF
     ENDFOR
     GO TO increment_item
    ELSE
     SET errcode = error(errmsg,1)
     IF (errcode > 0)
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed select for Multum version :",
       " Source_Vocabulary = ",trim(import_vocab)," Source_Identifier = ",trim(cnvtupper(requestin->
         list_0[x].source_identifier)),
       " Principle_Type = ",trim(cdf_meaning))
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = errmsg
      SET err_level = 2
      SET reqinfo->commit_ind = 3
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   SET next_code = 0.0
   SET nomen_id = 0.0
   EXECUTE cps_next_nom_seq
   IF (curqual > 0)
    SET nomen_id = next_code
   ELSE
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to gernerate a new nomenclature_id")
    SET errcode = error(errmsg,1)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET err_level = 2
    SET reqinfo->commit_ind = 3
    GO TO exit_script
   ENDIF
   CALL echo("inserting")
   INSERT  FROM nomenclature n
    SET n.nomenclature_id = nomen_id, n.principle_type_cd = principle_type_cd, n.updt_cnt = 0,
     n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = 0.0, n.updt_task = 0.0,
     n.updt_applctx = 0.0, n.active_ind = 1, n.active_status_cd = active_status_cd,
     n.active_status_dt_tm = cnvtdatetime(curdate,curtime3), n.active_status_prsnl_id = 0.0, n
     .beg_effective_dt_tm =
     IF ((requestin->list_0[x].beg_effective_dt_tm != " ")) cnvtdatetime(requestin->list_0[x].
       beg_effective_dt_tm)
     ELSE cnvtdatetime(curdate,curtime3)
     ENDIF
     ,
     n.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), n.contributor_system_cd = contr_sys_cd, n
     .source_string = requestin->list_0[x].source_string,
     n.source_identifier =
     IF ((requestin->list_0[x].source_identifier != " ")) requestin->list_0[x].source_identifier
     ELSE " "
     ENDIF
     , n.string_identifier =
     IF ((requestin->list_0[x].string_identifier != " ")) requestin->list_0[x].string_identifier
     ELSE " "
     ENDIF
     , n.string_status_cd = string_status_cd,
     n.term_id =
     IF (term_id != 0) term_id
     ELSE 0
     ENDIF
     , n.language_cd = language_cd, n.source_vocabulary_cd = source_vocab_cd,
     n.nom_ver_grp_id = nomen_id, n.data_status_cd = data_status_cd, n.data_status_prsnl_id = 0.0,
     n.data_status_dt_tm =
     IF (data_status_cd > 0) cnvtdatetime(curdate,curtime3)
     ELSE null
     ENDIF
     , n.short_string =
     IF ((requestin->list_0[x].short_string != " ")) substring(1,60,requestin->list_0[x].short_string
       )
     ELSE " "
     ENDIF
     , n.mnemonic =
     IF ((requestin->list_0[x].mnemonic != " ")) substring(1,25,requestin->list_0[x].mnemonic)
     ELSE " "
     ENDIF
     ,
     n.concept_identifier =
     IF ((requestin->list_0[x].concept_identifier != " ")) requestin->list_0[x].concept_identifier
     ELSE " "
     ENDIF
     , n.concept_source_cd = concept_source_cd, n.string_source_cd = string_source_cd,
     n.vocab_axis_cd = vocab_axis_cd, n.primary_vterm_ind =
     IF ((requestin->list_0[x].primary_vterm_ind != " ")) cnvtint(requestin->list_0[x].
       primary_vterm_ind)
     ELSE 0
     ENDIF
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat(
     "  ERROR> Failed to insert item into nomenclature table : ",trim(requestin->list_0[x].
      source_identifier)," ",trim(requestin->list_0[x].string_identifier)," ",
     trim(requestin->list_0[x].concept_identifier))
    SET errcode = error(errmsg,1)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET err_level = 2
    SET reqinfo->commit_ind = 3
    GO TO exit_script
   ELSE
    CALL update_new_fields(x,nomen_id)
    EXECUTE cps_ens_normalized_index nomen_id
    IF (curqual < 1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to normalize string :",
      " nomenclature_id = ",trim(cnvtstring(nomen_id)))
     SET errcode = error(errmsg,1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = errmsg
     SET err_level = 2
     SET reqinfo->commit_ind = 3
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
#increment_item
 SET x = (x+ 1)
 GO TO begin_loop
#exit_script
 COMMIT
 IF (updt_version=true)
  SELECT INTO "nl:"
   c.code_set
   FROM code_set_extension c
   PLAN (c
    WHERE c.code_set=400
     AND c.field_name="VERSION")
   WITH nocounter, maxqual(c,1)
  ;end select
  IF (curqual < 1)
   INSERT  FROM code_set_extension c
    SET c.code_set = 400, c.field_name = "VERSION", c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     c.updt_cnt = 0, c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task,
     c.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed insert into code_set_extension table"
     )
    SET errcode = error(errmsg,1)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET err_level = 2
    SET reqinfo->commit_ind = 3
    GO TO write_log_file
   ENDIF
  ENDIF
  IF (source_vocab_cd < 1)
   IF ((requestin->list_0[nbr_recs].source_vocabulary_mean != "UPDATE"))
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Could NOT determine the vocabulary ",
     "for this import")
    SET err_level = 2
    SET reqinfo->commit_ind = 3
    GO TO write_log_file
   ENDIF
   IF ((requestin->list_0[nbr_recs].concept_source_mean != " "))
    SET source_vocab_cd = 0.0
    SET code_value = 0.0
    SET code_set = 400
    SET cdf_meaning = cnvtupper(trim(requestin->list_0[nbr_recs].concept_source_mean))
    EXECUTE cpm_get_cd_for_cdf
    SET source_vocab_cd = code_value
    IF (code_value < 1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to find cdf_meaning ",trim(
       cdf_meaning)," in code_set ",trim(cnvtstring(code_set)),
      "  for updating the code_value_extension table")
     SET err_level = 2
     SET reqinfo->commit_ind = 3
     GO TO write_log_file
    ENDIF
   ELSE
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("  ERROR> concept_source_mean must be > blank on ",
     "the last row of the nomenclature CSV file")
    SET err_level = 2
    SET reqinfo->commit_ind = 3
    GO TO write_log_file
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   c.code_value
   FROM code_value_extension c
   PLAN (c
    WHERE c.code_value=source_vocab_cd
     AND c.code_set=code_set
     AND c.field_name="VERSION")
   HEAD REPORT
    db_version = c.field_value, db_ver_dt_tm = format(cnvtdatetime(c.updt_dt_tm),"dd-mmm-yyyy hh:mm")
   WITH nocounter, maxqual(c,1)
  ;end select
  IF (curqual > 0)
   IF (cnvtreal(db_version) >= cnvtreal(import_version))
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat(
     "  ERROR> Import version <= current version on the last ",
     "row of the import CSV file.  Versioning needs to be updated ","manually.")
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("    current version : ",trim(requestin->list_0[
      nbr_recs].concept_source_mean),"  v",trim(db_version),"  ",
     trim(db_ver_dt_tm))
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("    import version  : ",trim(requestin->list_0[
      nbr_recs].concept_source_mean),"  v",import_version)
    SET err_level = 2
    SET reqinfo->commit_ind = 3
    GO TO write_log_file
   ENDIF
  ENDIF
  UPDATE  FROM code_value_extension c
   SET c.field_value = import_version, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = (c
    .updt_cnt+ 1)
   WHERE c.code_value=source_vocab_cd
    AND c.code_set=400
    AND c.field_name="VERSION"
  ;end update
  IF (curqual < 1)
   INSERT  FROM code_value_extension c
    SET c.code_value = source_vocab_cd, c.field_name = "VERSION", c.code_set = 400,
     c.field_value = import_version, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = 0,
     c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to add version info to ",
     "code_value_extension table.  Versioning needs to be updated ","manually.")
    SET err_level = 2
    SET reqinfo->commit_ind = 3
    GO TO write_log_file
   ENDIF
  ENDIF
 ENDIF
#write_log_file
 COMMIT
 IF (err_level=2)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("End   : FAILURE ",format(cnvtdatetime(curdate,curtime3),
    "dd-mmm-yyyy hh:mm:ss;;d"))
 ELSEIF (err_level=1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("End   : WARNING ",format(cnvtdatetime(curdate,curtime3),
    "dd-mmm-yyyy hh:mm:ss;;d"))
 ELSE
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("End   : SUCCESS ",format(cnvtdatetime(curdate,curtime3),
    "dd-mmm-yyyy hh:mm:ss;;d"))
 ENDIF
 CALL error_logging(dvar)
 GO TO end_program
 SUBROUTINE activate_nomen_item(l_id,l_beg_dt_tm,pvt_ind)
   UPDATE  FROM nomenclature n
    SET n.active_ind = 1, n.beg_effective_dt_tm = cnvtdatetime(l_beg_dt_tm), n.end_effective_dt_tm =
     cnvtdatetime("31-dec-2100 23:59:59"),
     n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_cnt = (n.updt_cnt+ 1), n.updt_id = reqinfo
     ->updt_id,
     n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->updt_applctx
    PLAN (n
     WHERE n.nomenclature_id=l_id)
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE chk_nomen_dup(tsrc_vocab_cd,tsrc_ident,tsrc_string,tprin_type_cd)
   SET cap_src_string = cnvtupper(tsrc_string)
   SET a_pure_dup = false
   SET a_dup = false
   SELECT
    IF (tsrc_ident > " ")
     PLAN (n
      WHERE n.source_vocabulary_cd=tsrc_vocab_cd
       AND n.source_identifier=tsrc_ident
       AND ((n.source_string=tsrc_string) OR (cnvtupper(n.source_string)=cap_src_string))
       AND n.principle_type_cd=tprin_type_cd)
    ELSE
     PLAN (n
      WHERE n.source_vocabulary_cd=tsrc_vocab_cd
       AND n.source_identifier <= " "
       AND ((n.source_string=tsrc_string) OR (cnvtupper(n.source_string)=cap_src_string))
       AND n.principle_type_cd=tprin_type_cd)
    ENDIF
    INTO "nl:"
    n.nomenclature_id, n.beg_effective_dt_tm
    FROM nomenclature n
    ORDER BY cnvtdatetime(n.beg_effective_dt_tm) DESC
    HEAD REPORT
     knt = 0, stat = alterlist(nomen_list->qual,10)
    DETAIL
     knt = (knt+ 1)
     IF (mod(knt,10)=1
      AND knt != 1)
      stat = alterlist(nomen_list->qual,(knt+ 9))
     ENDIF
     nomen_list->qual[knt].id = n.nomenclature_id, a_dup = true, nomen_list->srcstr = n.source_string
     IF (n.source_string=tsrc_string)
      a_pure_dup = true
     ENDIF
    FOOT REPORT
     nomen_list->qual_knt = knt, stat = alterlist(nomen_list->qual,knt)
    WITH nocounter, orahint("index(n XAK6NOMENCLATURE) ")
   ;end select
 END ;Subroutine
 SUBROUTINE error_logging(lvar)
  SET err_log->msg_qual = msg_knt
  SELECT INTO value(log_file)
   out_string = substring(1,132,err_log->msg[d.seq].err_msg)
   FROM (dummyt d  WITH seq = value(err_log->msg_qual))
   PLAN (d
    WHERE d.seq > 0)
   DETAIL
    row + 1, col 0, out_string
   WITH nocounter, append, format = variable,
    noformfeed, maxrow = value((msg_knt+ 1)), maxcol = 150
  ;end select
 END ;Subroutine
 SUBROUTINE update_new_fields(aidx,tnomen_id)
   DECLARE tsource_string = vc WITH public, noconstant(" ")
   DECLARE tsource_ident = vc WITH public, noconstant(" ")
   SET tsource_string = requestin->list_0[aidx].source_string
   SET tsource_ident = requestin->list_0[aidx].source_identifier
   SET xx = initarray(parser_buffer,fillstring(100," "))
   SET buffer_cnt = 0
   SET buffer_cnt = (buffer_cnt+ 1)
   SET parser_buffer[buffer_cnt] = "update into nomenclature n set"
   IF (source_string_ind)
    SET buffer_cnt = (buffer_cnt+ 1)
    SET parser_buffer[buffer_cnt] = concat("n.source_string_keycap = ","cnvtupper(tsource_string)")
   ENDIF
   IF (source_ident_ind)
    SET buffer_cnt = (buffer_cnt+ 1)
    IF (source_string_ind)
     SET parser_buffer[buffer_cnt] = concat(",n.source_identifier_keycap = ",
      "cnvtupper(tsource_ident)")
    ELSE
     SET parser_buffer[buffer_cnt] = concat("n.source_identifier_keycap = ",
      "cnvtupper(tsource_ident)")
    ENDIF
   ENDIF
   SET buffer_cnt = (buffer_cnt+ 1)
   SET parser_buffer[buffer_cnt] = "where n.nomenclature_id = tnomen_id go"
   IF (((source_string_ind) OR (source_ident_ind)) )
    FOR (buf_x = 1 TO buffer_cnt)
     CALL echo(parser_buffer[buf_x])
     CALL parser(parser_buffer[buf_x])
    ENDFOR
   ENDIF
 END ;Subroutine
#end_program
END GO

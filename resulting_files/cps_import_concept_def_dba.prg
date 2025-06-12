CREATE PROGRAM cps_import_concept_def:dba
 RECORD reqinfo(
   1 commit_ind = i2
   1 updt_id = f8
   1 position_cd = f8
   1 updt_app = i4
   1 updt_task = i4
   1 updt_req = i4
   1 updt_applctx = i4
 )
 RECORD err_log(
   1 msg_qual = i4
   1 msg[*]
     2 err_msg = vc
 )
 SET true = 1
 SET false = 0
 SET log_file = fillstring(30," ")
 SET msg_knt = 0
 SET err_log->msg_qual = msg_knt
 SET err_level = 0
 SET dvar = 0
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0.0
 SET code_value = 0.0
 SET active_cd = 0.0
 SET source_vocab_cd = 0.0
 SET concept_source_cd = 0.0
 SET next_code = 0.0
 SET concept_id = 0.0
 SET db_version = fillstring(20," ")
 SET db_ver_dt_tm = fillstring(20," ")
 SET nbr_concepts = size(requestin->list_0,5)
 SET i = 1
 SET new_def = false
 SET def_knt = 0
 SET log_file = concat("CPS_IMP_",trim(cnvtupper(substring(1,6,cnvtalphanum(requestin->list_0[1].
      import_vocab)))),"_CONCEPT_DEF.LOG")
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_IMPORT_CONCEPT_DEF begin : ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 IF (nbr_concepts >= 1)
  SET code_value = 0.0
  SET code_set = 400
  SET cdf_meaning = cnvtupper(trim(requestin->list_0[i].import_vocab))
  EXECUTE cpm_get_cd_for_cdf
  SET source_vocab_cd = code_value
  IF (code_value < 1)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat(
    "  WARNING> Failed to find import vocabulary cdf_meaning ",trim(cdf_meaning)," in code_set ",trim
    (cnvtstring(code_set)))
   SET err_level = 1
   SET log_file = "CPS_IMP__CONCEPT_DEF.LOG"
  ENDIF
  IF (source_vocab_cd > 0)
   SELECT INTO "nl:"
    c.code_value
    FROM code_value_extension c
    PLAN (c
     WHERE c.code_value=source_vocab_cd
      AND c.field_name="VERSION")
    HEAD REPORT
     db_version = c.field_value, db_ver_dt_tm = format(cnvtdatetime(c.updt_dt_tm),"dd-mmm-yyyy hh:mm"
      )
    WITH nocounter, maxqual(c,1)
   ;end select
  ENDIF
  IF (db_version > " "
   AND (requestin->list_0[i].version > " "))
   IF (cnvtreal(db_version) >= cnvtreal(requestin->list_0[i].version))
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("  WARNING> Import version <= current version")
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("    current version : ",trim(requestin->list_0[i].
      import_vocab),"  v",trim(db_version),"  ",
     trim(db_ver_dt_tm))
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("    import version  : ",trim(requestin->list_0[i].
      import_vocab),"  v",trim(requestin->list_0[i].version))
    SET err_level = 1
    SET reqinfo->commit_ind = 3
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET code_value = 0.0
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET active_cd = code_value
 IF (code_value < 1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to find active status cdf_meaning ",
   trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set)))
  SET err_level = 2
  SET reqinfo->commit_ind = 3
  GO TO exit_script
 ENDIF
#begin_loop
 IF (i > nbr_concepts)
  GO TO exit_script
 ENDIF
 FOR (i = i TO nbr_concepts)
   SET concept_source_cd = 0.0
   SET code_value = 0.0
   SET code_set = 12100
   IF ((requestin->list_0[i].concept_source_mean != " "))
    SET cdf_meaning = cnvtupper(substring(1,12,requestin->list_0[i].concept_source_mean))
   ELSE
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("  ERROR> concept_source_mean must be > blank")
    SET err_level = 2
    SET reqinfo->commit_ind = 3
    GO TO exit_script
   ENDIF
   EXECUTE cpm_get_cd_for_cdf
   SET concept_source_cd = code_value
   IF (code_value < 1)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to find concept source cdf_meaning ",
     trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set)))
    SET err_level = 2
    SET reqinfo->commit_ind = 3
    GO TO exit_script
   ENDIF
   IF ((requestin->list_0[i].concept_identifier > " "))
    SELECT INTO "nl:"
     c.concept_identifier
     FROM concept c
     WHERE (c.concept_identifier=requestin->list_0[i].concept_identifier)
      AND c.concept_source_cd=concept_source_cd
     WITH nocounter, maxqual(c,1)
    ;end select
    IF (curqual < 1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("  ERROR> concept_identifier NOT on concept table : ",
      trim(requestin->list_0[i].concept_identifier)," ",trim(requestin->list_0[i].concept_source_mean
       )," ",
      trim(requestin->list_0[i].source_vocabulary_mean)," ",trim(substring(1,30,requestin->list_0[i].
        definition)))
     SET err_level = 2
     SET reqinfo->commit_ind = 3
     GO TO exit_script
    ENDIF
   ELSE
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("  ERROR> concept_identifier must be > blank")
    SET err_level = 2
    SET reqinfo->commit_ind = 3
    GO TO exit_script
   ENDIF
   SET new_def = false
   SELECT INTO "nl:"
    c.concept_definition_id
    FROM concept_definition c
    PLAN (c
     WHERE c.concept_source_cd=concept_source_cd
      AND (c.concept_identifier=requestin->list_0[i].concept_identifier)
      AND c.source_vocabulary_cd=source_vocab_cd
      AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    HEAD REPORT
     def_knt = 0
    DETAIL
     IF ((c.definition != requestin->list_0[i].definition))
      def_knt = (def_knt+ 1), new_def = true
     ENDIF
    WITH check, nocounter
   ;end select
   IF (curqual > 0
    AND new_def=false)
    GO TO increment_item
   ELSEIF (curqual > 0
    AND new_def=true)
    UPDATE  FROM concept_definition c
     SET c.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), c.active_ind = 0, c.updt_cnt = (c
      .updt_cnt+ 1),
      c.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE c.concept_source_cd=concept_source_cd
      AND (c.concept_identifier=requestin->list_0[i].concept_identifier)
      AND c.source_vocabulary_cd=source_vocab_cd
      AND (c.definition != requestin->list_0[i].definition)
      AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     WITH check, nocounter
    ;end update
    IF (curqual != def_knt)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("  ERROR> failed to update previous versions : ",trim
      (requestin->list_0[i].concept_identifier)," ",trim(requestin->list_0[i].concept_source_mean),
      " ",
      trim(requestin->list_0[i].source_vocabulary_mean)," ",trim(substring(1,30,requestin->list_0[i].
        definition)))
     SET errcode = error(errmsg,1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = errmsg
     SET err_level = 2
     SET reqinfo->commit_ind = 3
     GO TO exit_script
    ENDIF
   ENDIF
   SET next_code = 0.0
   SET concept_id = 0.0
   EXECUTE cps_next_nom_seq
   IF (curqual < 1)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat(
     "  ERROR> failed to generate new concept_definition_id")
    SET errcode = error(errmsg,1)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET err_level = 2
    SET reqinfo->commit_ind = 3
    GO TO exit_script
   ELSE
    SET concept_id = next_code
   ENDIF
   INSERT  FROM concept_definition c
    SET c.concept_definition_id = concept_id, c.definition = requestin->list_0[i].definition, c
     .source_vocabulary_cd = source_vocab_cd,
     c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = 0.0,
     c.updt_task = 0.0, c.updt_applctx = 0.0, c.active_ind = 1,
     c.active_status_cd = active_cd, c.active_status_dt_tm = cnvtdatetime(curdate,curtime3), c
     .active_status_prsnl_id = 0.0,
     c.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), c.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100"), c.concept_identifier = requestin->list_0[i].concept_identifier,
     c.concept_source_cd = concept_source_cd
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("  ERROR> failed to insert data : ",trim(requestin->
      list_0[i].concept_identifier)," ",trim(requestin->list_0[i].concept_source_mean)," ",
     trim(requestin->list_0[i].source_vocabulary_mean)," ",trim(substring(1,30,requestin->list_0[i].
       definition)))
    SET errcode = error(errmsg,1)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET err_level = 2
    SET reqinfo->commit_ind = 3
    GO TO exit_script
   ENDIF
 ENDFOR
 GO TO exit_script
#increment_item
 SET i = (i+ 1)
 GO TO begin_loop
#exit_script
 COMMIT
 IF (i=1
  AND nbr_concepts=1
  AND  NOT ((requestin->list_0[i].concept_identifier > " ")))
  SET err_level = 0
 ENDIF
 IF (err_level=2)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_IMPORT_CONCEPT_DEF   end :FAILURE ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ELSEIF (err_level=1
  AND (reqinfo->commit_ind=3))
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_IMPORT_CONCEPT_DEF   end :PREVIOU ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ELSEIF (err_level=1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_IMPORT_CONCEPT_DEF   end :WARNING ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ELSE
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_IMPORT_CONCEPT_DEF   end :SUCCESS ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ENDIF
 SET err_log->msg_qual = msg_knt
 CALL error_logging(dvar)
 GO TO end_program
 SUBROUTINE error_logging(lvar)
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
#end_program
END GO

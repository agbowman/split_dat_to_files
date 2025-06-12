CREATE PROGRAM cps_import_concept:dba
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
 SET log_file = fillstring(30," ")
 SET msg_knt = 0
 SET err_log->msg_qual = msg_knt
 SET err_level = 0
 SET dvar = 0
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET nbr_concepts = size(requestin->list_0,5)
 SET i = 1
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0.0
 SET code_value = 0.0
 SET source_vocab_cd = 0.0
 SET active_cd = 0.0
 SET concept_source_cd = 0.0
 SET review_status_cd = 0.0
 SET data_status_cd = 0.0
 DECLARE concept_ident = vc WITH noconstant(" ")
 SET db_version = fillstring(20," ")
 SET db_ver_dt_tm = fillstring(20," ")
 SET log_file = concat("CPS_IMP_CONCEPT.LOG")
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_IMPORT_CONCEPT begin : ",format(cnvtdatetime(curdate,
    curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SET code_value = 0.0
 IF ((requestin->list_0[i].version > " ")
  AND (requestin->list_0[i].import_vocab > " "))
  SET year_minus1 = trim(cnvtstring((cnvtint(requestin->list_0[i].version) - 1)))
  IF ( NOT (cnvtint(year_minus1) <= 2100
   AND cnvtint(year_minus1) >= 1700))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to convert version correctly import",
    " version : ",trim(requestin->list_0[i].version)," year_minus1 : ",trim(year_minus1))
   SET err_level = 2
   SET reqinfo->commit_ind = 3
   GO TO exit_script
  ENDIF
  SET end_eff_dt_tm = concat("31-DEC-",year_minus1," 23:59:59")
  IF (trim(cnvtupper(requestin->list_0[i].import_vocab))="ICD9")
   SET beg_eff_dt_tm = concat("01-OCT-",year_minus1," 00:00:00")
  ELSE
   SET beg_eff_dt_tm = concat("01-JAN-",trim(requestin->list_0[i].version)," 00:00:00")
  ENDIF
 ELSE
  SET beg_eff_dt_tm = format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("  WARNING> Vesion should be > blank")
  SET err_level = 1
 ENDIF
 IF (nbr_concepts >= 1
  AND source_vocab_cd > 0)
  SELECT INTO "nl:"
   c.code_value
   FROM code_value_extension c
   PLAN (c
    WHERE c.code_value=source_vocab_cd
     AND c.field_name="VERSION")
   HEAD REPORT
    db_version = c.field_value, db_ver_dt_tm = format(cnvtdatetime(c.updt_dt_tm),"dd-mmm-yyyy hh:mm")
   WITH nocounter, maxqual(c,1)
  ;end select
  IF (curqual > 0
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
 SET code_value = 0.0
 SET code_set = 12100
 IF ((requestin->list_0[i].concept_source_mean > " "))
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
  SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to find concept_source_mean ",trim(
    cdf_meaning)," in code_set ",trim(cnvtstring(code_set)))
  SET err_level = 2
  SET reqinfo->commit_ind = 3
  GO TO exit_script
 ENDIF
 UPDATE  FROM concept a
  SET a.concept_source_cd = value(uar_get_code_by("MEANING",12100,"MUL.MMDC"))
  WHERE a.cki="MUL.MMDC!*"
  WITH nocounter
 ;end update
 UPDATE  FROM concept a
  SET a.concept_source_cd = value(uar_get_code_by("MEANING",12100,"MUL.DRUG"))
  WHERE a.cki="MUL.DRUG!*"
  WITH nocounter
 ;end update
 UPDATE  FROM concept a
  SET a.concept_source_cd = value(uar_get_code_by("MEANING",12100,"MUL.ALGCAT"))
  WHERE a.cki="MUL.ALGCAT!*"
  WITH nocounter
 ;end update
 COMMIT
#begin_loop
 IF (i > nbr_concepts)
  GO TO exit_script
 ENDIF
 FOR (i = i TO nbr_concepts)
   IF ((requestin->list_0[i].concept_identifier > " "))
    SET concept_ident = trim(requestin->list_0[i].concept_identifier)
    SELECT INTO "nl:"
     c.concept_identifier
     FROM concept c
     PLAN (c
      WHERE c.concept_identifier=concept_ident
       AND c.cki=concat(trim(requestin->list_0[i].concept_source_mean),"!",trim(requestin->list_0[i].
        concept_identifier)))
     WITH nocounter, maxqual(c,1)
    ;end select
    IF (curqual > 0)
     CALL echo("found item")
     CALL echo("found item")
     SELECT INTO "nl:"
      c.concept_identifier
      FROM concept c
      PLAN (c
       WHERE c.concept_identifier=concept_ident
        AND c.cki=concat(trim(requestin->list_0[i].concept_source_mean),"!",trim(requestin->list_0[i]
         .concept_identifier))
        AND c.active_ind=cnvtint(requestin->list_0[i].active_ind)
        AND c.beg_effective_dt_tm=cnvtdatetime(requestin->list_0[i].beg_effective_dt_tm)
        AND c.end_effective_dt_tm=cnvtdatetime(requestin->list_0[i].end_effective_dt_tm))
      WITH check
     ;end select
     IF (curqual=0)
      CALL echo("upd found item")
      CALL echo("upd found item")
      UPDATE  FROM concept c
       SET c.active_ind = cnvtint(requestin->list_0[i].active_ind), c.beg_effective_dt_tm =
        cnvtdatetime(requestin->list_0[i].beg_effective_dt_tm), c.end_effective_dt_tm = cnvtdatetime(
         requestin->list_0[i].end_effective_dt_tm),
        c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = 0,
        c.updt_task = 0, c.updt_applctx = 0
       WHERE c.concept_identifier=concept_ident
        AND c.cki=concat(trim(requestin->list_0[i].concept_source_mean),"!",trim(requestin->list_0[i]
         .concept_identifier))
       WITH check
      ;end update
     ENDIF
     GO TO increment_item
    ENDIF
    CALL echo("didnt find item")
    SET concept_ident = trim(concept_ident)
    SET review_status_cd = 0.0
    IF ((requestin->list_0[i].review_status_mean != " "))
     SET code_value = 0.0
     SET code_set = 12101
     SET cdf_meaning = cnvtupper(substring(1,12,requestin->list_0[i].review_status_mean))
     EXECUTE cpm_get_cd_for_cdf
     SET review_status_cd = code_value
     IF (code_value < 1)
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = concat(
       "  WARNING> Failed to find review status cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(
        cnvtstring(code_set)))
      SET err_level = 1
     ENDIF
    ENDIF
    SET data_status_cd = 0.0
    IF ((requestin->list_0[i].data_status_mean != " "))
     SET code_value = 0.0
     SET code_set = 8
     SET cdf_meaning = cnvtupper(substring(1,12,requestin->list_0[i].data_status_mean))
     EXECUTE cpm_get_cd_for_cdf
     SET data_status_cd = code_value
     IF (code_value < 1)
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = concat("  WARNING> Failed to find data status cdf_meaning ",
       trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set)))
      SET err_level = 1
     ENDIF
    ENDIF
    SET cki = fillstring(255," ")
    SET cki = concat(trim(requestin->list_0[i].concept_source_mean),"!",trim(requestin->list_0[i].
      concept_identifier))
    INSERT  FROM concept c
     SET c.concept_identifier = trim(concept_ident), c.concept_source_cd =
      IF ((requestin->list_0[i].concept_source_mean="MUL.MMDC")) value(uar_get_code_by("MEANING",
         12100,"MUL.MMDC"))
      ELSEIF ((requestin->list_0[i].concept_source_mean="MUL.DRUG")) value(uar_get_code_by("MEANING",
         12100,"MUL.DRUG"))
      ELSEIF ((requestin->list_0[i].concept_source_mean="MUL.ALGCAT")) value(uar_get_code_by(
         "MEANING",12100,"MUL.ALGCAT"))
      ENDIF
      , c.concept_name = requestin->list_0[i].concept_name,
      c.cki = cki, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      c.updt_id = 0.0, c.updt_task = 0.0, c.updt_applctx = 0.0,
      c.active_ind = cnvtint(requestin->list_0[i].active_ind), c.active_status_cd = active_cd, c
      .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      c.active_status_prsnl_id = 0.0, c.beg_effective_dt_tm = cnvtdatetime(requestin->list_0[i].
       beg_effective_dt_tm), c.end_effective_dt_tm = cnvtdatetime(requestin->list_0[i].
       end_effective_dt_tm),
      c.review_status_cd = review_status_cd, c.data_status_cd = data_status_cd, c.data_status_dt_tm
       =
      IF (data_status_cd > 0) cnvtdatetime(curdate,curtime3)
      ELSE cnvtdatetime("31-DEC-2100")
      ENDIF
      ,
      c.data_status_prsnl_id = 0.0
     WITH check, nocounter
    ;end insert
    IF (curqual != 1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to insert data ",trim(requestin->
       list_0[i].concept_identifier)," ",trim(requestin->list_0[i].concept_source_mean))
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

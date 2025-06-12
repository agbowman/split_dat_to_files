CREATE PROGRAM cps_import_term:dba
 RECORD reqinfo(
   1 commit_ind = i2
   1 updt_id = f8
   1 position_cd = f8
   1 updt_app = i4
   1 updt_task = i4
   1 updt_req = i4
   1 updt_applctx = i4
 )
 SET qual = size(requestin->list_0,5)
 SET x = 1
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0.0
 SET code_value = 0.0
 SET error_line = fillstring(125," ")
 SET errmsg = fillstring(132," ")
 SET version_dt_tm = fillstring(20," ")
 SET last_version = fillstring(100," ")
 SET rvar = 0
 SELECT INTO "CPS_IMP_TERM.LOG"
  rvar
  HEAD REPORT
   row + 1, "CPS_IMPORT_TERM  :begin >", curtime"hh:mm:ss;;m",
   col + 2, curdate"dd-mmm-yyyy;;d"
  DETAIL
   col 0
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
 IF (qual >= 1
  AND cnvtupper(trim(requestin->list_0[x].term_identifier))="UPDATE")
  SET code_set = 400
  SET cdf_meaning = cnvtupper(trim(requestin->list_0[x].concept_source_mean))
  EXECUTE cpm_get_cd_for_cdf
  SET vocab_chk_cd = code_value
  SELECT INTO "nl:"
   c.code_value
   FROM code_value_extension c
   PLAN (c
    WHERE c.code_value=vocab_chk_cd
     AND c.field_name="VERSION"
     AND c.code_set=code_set)
   HEAD REPORT
    last_version = c.field_value, version_dt_tm = format(c.updt_dt_tm,"dd-mmm-yyyy hh:mm;;d")
   WITH nocounter, maxqual(c,1)
  ;end select
  IF (curqual < 1)
   SET error_line = "ERROR >: Failed to find versioning information in CODE_VALUE_EXTENSION table"
   CALL error_handling(error_line)
  ELSEIF (cnvtreal(last_version) >= cnvtreal(requestin->list_0[x].concept_identifier))
   SET error_line = "ERROR >: Attempting to import a previous version  IMPORT TERMINATED"
   CALL error_handling(error_line)
   SET error_line = concat("   Current version  :",trim(requestin->list_0[x].concept_source_mean),
    "   v",trim(last_version),"   ",
    trim(version_dt_tm))
   CALL error_handling(error_line)
   SET error_line = concat("   Import version   :",trim(requestin->list_0[x].concept_source_mean),
    "   v",trim(requestin->list_0[x].concept_identifier))
   CALL error_handling(error_line)
   SET reqinfo->commit_ind = 3
   GO TO exit_script
  ENDIF
  SET x = (x+ 1)
 ENDIF
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET active_status_cd = code_value
 SET active_mean = "ACTIVE"
 IF (code_value=0)
  SET error_line = trim(concat("ERROR >CODE_VALUE = 0  : code_set = ",trim(cnvtstring(code_set)),
    " cdf_meaning = ",trim(cdf_meaning)))
  CALL error_handling(error_line)
 ENDIF
#start_loop
 IF (x > qual)
  GO TO exit_script
 ENDIF
 FOR (x = x TO qual)
   SET cdf_meaning = fillstring(12," ")
   SET code_set = 0.0
   SET code_value = 0.0
   SET term_status_cd = 0.0
   IF ((requestin->list_0[x].term_status_mean != " "))
    SET code_set = 12102
    SET code_value = 0.0
    SET cdf_meaning = cnvtupper(substring(1,12,requestin->list_0[x].term_status_mean))
    EXECUTE cpm_get_cd_for_cdf
    SET term_status_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("ERROR >CODE_VALUE = 0  : code_set = ",trim(cnvtstring(code_set)),
       " cdf_meaning = ",trim(cdf_meaning)))
     CALL error_handling(error_line)
     SET error_line = trim(concat("   ",trim(requestin->list_0[x].term_identifier)," ",trim(requestin
        ->list_0[x].term_status_mean)," ",
       trim(requestin->list_0[x].concept_identifier)," ",trim(requestin->list_0[x].
        concept_source_mean)," ",trim(requestin->list_0[x].term_source_mean)))
    ENDIF
   ENDIF
   SET concept_source_cd = 0.0
   IF ((requestin->list_0[x].concept_source_mean != " "))
    SET code_set = 12100
    SET code_value = 0.0
    SET cdf_meaning = cnvtupper(substring(1,12,requestin->list_0[x].concept_source_mean))
    EXECUTE cpm_get_cd_for_cdf
    SET concept_source_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("ERROR >CODE_VALUE = 0  : code_set = ",trim(cnvtstring(code_set)),
       " cdf_meaning = ",trim(cdf_meaning)))
     CALL error_handling(error_line)
     SET error_line = trim(concat("   ",trim(requestin->list_0[x].term_identifier)," ",trim(requestin
        ->list_0[x].term_status_mean)," ",
       trim(requestin->list_0[x].concept_identifier)," ",trim(requestin->list_0[x].
        concept_source_mean)," ",trim(requestin->list_0[x].term_source_mean)))
    ENDIF
   ENDIF
   SET term_source_cd = 0.0
   IF ((requestin->list_0[x].term_source_mean != " "))
    SET code_set = 12100
    SET code_value = 0.0
    SET cdf_meaning = cnvtupper(substring(1,12,requestin->list_0[x].term_source_mean))
    EXECUTE cpm_get_cd_for_cdf
    SET term_source_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("ERROR >CODE_VALUE = 0  : code_set = ",trim(cnvtstring(code_set)),
       " cdf_meaning = ",trim(cdf_meaning)))
     CALL error_handling(error_line)
     SET error_line = trim(concat("   ",trim(requestin->list_0[x].term_identifier)," ",trim(requestin
        ->list_0[x].term_status_mean)," ",
       trim(requestin->list_0[x].concept_identifier)," ",trim(requestin->list_0[x].
        concept_source_mean)," ",trim(requestin->list_0[x].term_source_mean)))
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].concept_identifier > " "))
    SELECT INTO "nl:"
     c.concept_identifier
     FROM concept c
     PLAN (c
      WHERE (c.concept_identifier=requestin->list_0[x].concept_identifier)
       AND c.concept_source_cd=concept_source_cd)
     WITH check, nocounter
    ;end select
    IF (curqual=0)
     SET error_line = trim(concat("ERROR >INVALID CONCEPT IDENTIFIER  : ",trim(requestin->list_0[x].
        term_identifier)," ",trim(requestin->list_0[x].term_status_mean)," ",
       trim(requestin->list_0[x].concept_identifier)," ",trim(requestin->list_0[x].
        concept_source_mean)," ",trim(requestin->list_0[x].term_source_mean)))
     GO TO increment_item
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    t.term_identifier
    FROM term t
    PLAN (t
     WHERE (t.concept_identifier=requestin->list_0[x].concept_identifier)
      AND t.concept_source_cd=concept_source_cd
      AND (t.term_identifier=requestin->list_0[x].term_identifier)
      AND t.term_source_cd=term_source_cd
      AND t.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    WITH check, nocounter
   ;end select
   IF (curqual > 0)
    SET error_line = trim(concat("ERROR >DUPLICATE TERM IDENTIFIER  : ",trim(requestin->list_0[x].
       term_identifier)," ",trim(requestin->list_0[x].term_status_mean)," ",
      trim(requestin->list_0[x].concept_identifier)," ",trim(requestin->list_0[x].concept_source_mean
       )," ",trim(requestin->list_0[x].term_source_mean)))
    CALL echo("exists")
    GO TO increment_item
   ENDIF
   SET next_code = 0.0
   SET term_id = 0.0
   EXECUTE cps_next_nom_seq
   IF (curqual < 0)
    SET error_line = trim(concat("ERROR >GENERATING TERM_ID  : ",trim(requestin->list_0[x].
       term_identifier)," ",trim(requestin->list_0[x].term_status_mean)," ",
      trim(requestin->list_0[x].concept_identifier)," ",trim(requestin->list_0[x].concept_source_mean
       )," ",trim(requestin->list_0[x].term_source_mean)))
    SET reqinfo->commit_ind = 3
    GO TO exit_script
    CALL echo("error in generating new id")
   ELSE
    SET term_id = next_code
   ENDIF
   CALL echo(build("built term_id = ",term_id))
   INSERT  FROM term t
    SET t.term_id = term_id, t.term_identifier = requestin->list_0[x].term_identifier, t
     .term_status_cd = term_status_cd,
     t.updt_cnt = 0, t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_id = 0.0,
     t.updt_task = 0.0, t.updt_applctx = 0.0, t.active_ind = 1,
     t.active_status_cd = active_status_cd, t.active_status_dt_tm = cnvtdatetime(curdate,curtime3), t
     .active_status_prsnl_id = 0.0,
     t.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), t.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100"), t.concept_identifier = requestin->list_0[x].concept_identifier,
     t.concept_source_cd = concept_source_cd, t.term_source_cd = term_source_cd
    WITH nocounter
   ;end insert
   IF (curqual <= 0)
    SET error_line = trim(concat("ERROR >FAILED TO INSERT  : ",trim(requestin->list_0[x].
       term_identifier)," ",trim(requestin->list_0[x].term_status_mean)," ",
      trim(requestin->list_0[x].concept_identifier)," ",trim(requestin->list_0[x].concept_source_mean
       )," ",trim(requestin->list_0[x].term_source_mean)))
    CALL error_handling(error_line)
    SET errcode = error(errmsg,1)
    SET error_line = substring(1,125,errmsg)
    CALL error_handling(error_line)
    SET reqinfo->commit_ind = 3
    GO TO exit_script
   ELSE
    CALL echo(build("Success - term_id = ",term_id))
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE error_handling(the_output)
   SELECT INTO "CPS_IMP_TERM.LOG"
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
 COMMIT
 SELECT INTO "CPS_IMP_TERM.LOG"
  rvar
  HEAD REPORT
   col 0, "CPS_IMPORT_TERM  :end   >", curtime"hh:mm:ss;;m",
   col + 2, curdate"dd-mmm-yyyy;;d"
  DETAIL
   col 0
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
END GO

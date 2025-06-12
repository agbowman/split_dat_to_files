CREATE PROGRAM cps_imp_scd_pattern:dba
 RECORD term_list(
   1 index[*]
     2 id = f8
 )
 SET nbr_of_terms = 0
 SET qual = size(requestin->list_0,5)
 SET x = 1
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0.0
 SET code_value = 0.0
 SET pattern_type_cd = 0.0
 SET scr_pattern_id = 0
 SET error_line = fillstring(120," ")
 SET log_file_name = build("SCD_IMP_PATTERN_",format(curdate,"yymmdd;;d"),".log")
 SET errmsg = fillstring(132," ")
 SET true = 1
 SET false = 0
 SET continue = true
 SET rvar = 0
 SELECT INTO value(log_file_name)
  rvar
  HEAD REPORT
   row + 1, "SCD_PATTERN_IMPORT: begin >", curtime"hh:mm:ss;;m",
   col + 2, curdate"dd-mmm-yyyy;;d"
  DETAIL
   col 0
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
#start_loop
 IF (x > qual)
  GO TO exit_script
 ENDIF
 FOR (x = x TO qual)
   SET scr_pattern_id = cnvtint(trim(requestin->list_0[x].scr_pattern_id))
   IF (cnvtupper(trim(requestin->list_0[x].function))="A")
    SELECT INTO "nl:"
     s.scr_pattern_id
     FROM scr_pattern s
     WHERE s.scr_pattern_id=scr_pattern_id
     WITH nocounter, maxqual(s,1)
    ;end select
    IF (curqual=1)
     SET error_line = trim(concat("WARNING >SCR_PATTERN_ID EXIST  : scr_pattern_id = ",trim(requestin
        ->list_0[x].scr_pattern_id)))
     CALL error_handling(error_line)
     SET continue = true
     CALL delete_entries(continue)
    ENDIF
    SET pattern_type_cd = 0.0
    IF ((requestin->list_0[x].pattern_type_mean > " "))
     SET code_set = 14409
     SET cdf_meaning = substring(1,12,requestin->list_0[x].pattern_type_mean)
     EXECUTE cpm_get_cd_for_cdf
     SET pattern_type_cd = code_value
     IF (code_value=0)
      SET error_line = trim(concat("ERROR >CODE_VALUE = 0  : code_set = ",trim(cnvtstring(code_set)),
        " cdf_meaning = ",trim(cdf_meaning)))
      CALL error_handling(error_line)
      GO TO increment_item
     ENDIF
    ENDIF
    SET active_status_cd = 0.0
    SET code_set = 48
    SET cdf_meaning = "ACTIVE"
    EXECUTE cpm_get_cd_for_cdf
    SET active_status_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("ERROR >CODE_VALUE = 0  : code_set = ",trim(cnvtstring(code_set)),
       " cdf_meaning = ",trim(cdf_meaning)))
     CALL error_handling(error_line)
     GO TO exit_script
    ENDIF
    INSERT  FROM scr_pattern s
     SET s.scr_pattern_id = scr_pattern_id, s.cki_source = requestin->list_0[x].cki_source, s
      .cki_identifier = requestin->list_0[x].cki_identifier,
      s.display = requestin->list_0[x].display, s.display_key = cnvtupper(cnvtalphanum(trim(requestin
         ->list_0[x].display))), s.definition = requestin->list_0[x].definition,
      s.pattern_type_cd = pattern_type_cd, s.active_ind = 1, s.active_status_cd = active_status_cd,
      s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.active_status_prsnl_id = 0, s
      .updt_cnt = 0,
      s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = 0, s.updt_task = 0,
      s.updt_applctx = 0
     WITH nocounter
    ;end insert
    IF (curqual != 1)
     SET error_line = trim(concat("ERROR >FAILED TO INSERT IN SCR_PATTERN TABLE  : scr_pattern_id = ",
       trim(requestin->list_0[x].scr_pattern_id)))
     CALL error_handling(error_line)
     SET errcode = error(errmsg,1)
     CALL error_handling(concat("  ",substring(1,126,errmsg)))
     GO TO next_item
    ENDIF
   ELSEIF ((requestin->list_0[x].function="D"))
    SET continue = true
    CALL delete_entries(continue)
   ELSE
    SET error_line = trim(concat("ERROR >INVALID FUNCTION  : function = ",trim(requestin->list_0[x].
       function)))
    CALL error_handling(error_line)
   ENDIF
   COMMIT
 ENDFOR
 GO TO exit_script
 SUBROUTINE error_handling(the_output)
   SELECT INTO value(log_file_name)
    rvar
    HEAD REPORT
     col 2, the_output
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
 SUBROUTINE delete_entries(adummy)
   SET pattern_type_cd = 0.0
   IF ((requestin->list_0[x].pattern_type_mean != " "))
    SET code_set = 14409
    SET code_value = 0.0
    SET cdf_meaning = substring(1,12,requestin->list_0[x].pattern_type_mean)
    EXECUTE cpm_get_cd_for_cdf
    SET pattern_type_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("WARNING >INVALID PATTERN_TYPE_MEAN  : code_set = ",trim(cnvtstring
        (code_set))," cdf_meaning = ",trim(cdf_meaning),"  : scr_pattern_id = ",
       trim(requestin->list_0[x].scr_pattern_id)))
     CALL error_handling(error_line)
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    s.scr_pattern_id
    FROM scr_pattern s
    WHERE s.scr_pattern_id=scr_pattern_id
     AND trim(s.cki_source)=trim(requestin->list_0[x].cki_source)
     AND trim(s.cki_identifier)=trim(requestin->list_0[x].cki_identifier)
    WITH nocounter, maxqual(s,1)
   ;end select
   IF (curqual != 1)
    SET error_line = trim(concat("ERROR >INVALID SCR_PATTERN_ID  : scr_pattern_id = ",trim(requestin
       ->list_0[x].scr_pattern_id),"  cki_source = ",trim(requestin->list_0[x].cki_source),
      "  cki_identifier = ",
      trim(requestin->list_0[x].cki_identifier)))
    CALL error_handling(error_line)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    t.scr_term_id
    FROM scr_term_hier t
    WHERE t.scr_pattern_id=scr_pattern_id
     AND t.scr_term_id=t.scr_term_hier_id
    HEAD REPORT
     knt = 0, stat = alterlist(term_list->index,10)
    DETAIL
     knt = (knt+ 1)
     IF (mod(knt,10)=1
      AND knt != 1)
      stat = alterlist(term_list->index,(knt+ 9))
     ENDIF
     term_list->index[knt].id = t.scr_term_id
    FOOT REPORT
     stat = alterlist(term_list->index,knt)
    WITH nocounter
   ;end select
   UPDATE  FROM scr_term_hier s
    SET s.source_term_hier_id = 0, s.parent_term_hier_id = 0
    WHERE s.scr_pattern_id=scr_pattern_id
    WITH nocounter
   ;end update
   IF (curqual < 1)
    SET error_line = trim(concat("WARNING >NO ENTRIES IN TERM_HIER FOR  : scr_pattern_id = ",trim(
       requestin->list_0[x].scr_pattern_id)))
    CALL error_handling(error_line)
   ELSE
    DELETE  FROM scr_term_hier s
     WHERE s.scr_pattern_id=scr_pattern_id
     WITH nocounter
    ;end delete
    SET nbr_of_terms = size(term_list->index,5)
    IF (nbr_of_terms > 0)
     DELETE  FROM scr_term_text s,
       (dummyt d  WITH seq = value(nbr_of_terms))
      SET d.seq = 1
      PLAN (d)
       JOIN (s
       WHERE (s.scr_term_id=term_list->index[d.seq].id))
      WITH nocounter
     ;end delete
     IF (curqual < 1)
      SET error_line = trim(concat("WARNING >NO ENTRIES IN SCR_TERM_TEXT  : scr_pattern_id = ",trim(
         requestin->list_0[x].scr_pattern_id)))
      CALL error_handling(error_line)
     ELSE
      COMMIT
     ENDIF
     SET nbr_of_terms = size(term_list->index,5)
     DELETE  FROM scr_term_definition s,
       (dummyt d  WITH seq = value(nbr_of_terms))
      SET d.seq = 1
      PLAN (d)
       JOIN (s
       WHERE (s.scr_term_def_id=term_list->index[d.seq].id))
      WITH nocounter
     ;end delete
     IF (curqual < 1)
      SET error_line = trim(concat("WARNING >NO ENTRIES IN SCR_TERM_DEFINITION  : scr_pattern_id = ",
        trim(requestin->list_0[x].scr_pattern_id)))
      CALL error_handling(error_line)
     ELSE
      COMMIT
     ENDIF
     SET nbr_of_terms = size(term_list->index,5)
     DELETE  FROM scr_term s,
       (dummyt d  WITH seq = value(nbr_of_terms))
      SET d.seq = 1
      PLAN (d)
       JOIN (s
       WHERE (s.scr_term_id=term_list->index[d.seq].id))
      WITH nocounter
     ;end delete
     IF (curqual < 1)
      SET error_line = trim(concat("WARNING >NO ENTRIES IN SCR_TERM  : scr_pattern_id = ",trim(
         requestin->list_0[x].scr_pattern_id)))
      CALL error_handling(error_line)
     ELSE
      COMMIT
     ENDIF
    ELSE
     SET error_line = trim(concat("WARNING >NO TERMS IN TERM_HIER  : scr_pattern_id = ",trim(
        requestin->list_0[x].scr_pattern_id)))
     CALL error_handling(error_line)
    ENDIF
   ENDIF
   DELETE  FROM scr_pattern_indication s
    WHERE s.scr_pattern_id=scr_pattern_id
    WITH nocounter
   ;end delete
   IF (curqual < 1)
    SET error_line = trim(concat("WARNING >NO ENTRIES IN SCR_PATTERN_INDICATION  : scr_pattern_id = ",
      trim(requestin->list_0[x].scr_pattern_id)))
    CALL error_handling(error_line)
   ELSE
    COMMIT
   ENDIF
   DELETE  FROM scr_paragraph s
    WHERE s.scr_pattern_id=scr_pattern_id
    WITH nocounter
   ;end delete
   IF (curqual < 1)
    SET error_line = trim(concat("WARNING >NO ENTRIES IN SCR_PARAGRAPH  : scr_pattern_id = ",trim(
       requestin->list_0[x].scr_pattern_id)))
    CALL error_handling(error_line)
   ELSE
    COMMIT
   ENDIF
   DELETE  FROM scr_sentence s
    WHERE s.scr_pattern_id=scr_pattern_id
    WITH nocounter
   ;end delete
   IF (curqual < 1)
    SET error_line = trim(concat("WARNING >NO ENTRIES IN SCR_SENTENCE  : scr_pattern_id = ",trim(
       requestin->list_0[x].scr_pattern_id)))
    CALL error_handling(error_line)
   ELSE
    COMMIT
   ENDIF
   DELETE  FROM scr_pattern s
    WHERE s.scr_pattern_id=scr_pattern_id
    WITH nocounter
   ;end delete
   IF (curqual != 1)
    SET error_line = trim(concat("WARNING >NO ENTRIES IN SCR_PATTERN  : scr_pattern_id = ",trim(
       requestin->list_0[x].scr_pattern_id)))
    CALL error_handling(error_line)
   ELSE
    COMMIT
   ENDIF
 END ;Subroutine
#exit_script
 SELECT INTO value(log_file_name)
  rvar
  HEAD REPORT
   col 0, "SCD_IMPORT_PATTERN  :end   >", curtime"hh:mm:ss;;m",
   col + 2, curdate"dd-mmm-yyyy;;d"
  DETAIL
   col 0
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
END GO

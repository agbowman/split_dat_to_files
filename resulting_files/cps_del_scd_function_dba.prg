CREATE PROGRAM cps_del_scd_function:dba
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
 SET error_line = fillstring(120," ")
 SET true = 1
 SET false = 0
 SET continue = true
 SET rvar = 0
 SELECT INTO "SCD_DEL_FUNCTION.LOG"
  rvar
  HEAD REPORT
   row + 1, "SCD_DEL_FUNCTION  :begin >", curtime"hh:mm:ss;;m",
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
   IF (cnvtupper(trim(requestin->list_0[x].function))="D")
    SET continue = true
    CALL delete_entries(continue)
   ELSE
    SET error_line = trim(concat("ERROR >INVALID FUNCTION  : function = ",trim(requestin->list_0[x].
       function)))
    CALL error_handling(error_line)
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE error_handling(the_output)
   SELECT INTO "SCD_DEL_FUNCTION.LOG"
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
    SET cdf_meaning = cnvtupper(substring(1,12,requestin->list_0[x].pattern_type_mean))
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
    WHERE s.scr_pattern_id=cnvtint(trim(requestin->list_0[x].scr_pattern_id))
     AND cnvtupper(trim(s.cki_source))=cnvtupper(trim(requestin->list_0[x].cki_source))
     AND cnvtupper(trim(s.cki_identifier))=cnvtupper(trim(requestin->list_0[x].cki_identifier))
    WITH nocounter, maxqual(s,1)
   ;end select
   IF (curqual != 1)
    SET error_line = trim(concat("ERROR >INVALIDE SCR_PATTERN_ID  : scr_pattern_id = ",trim(requestin
       ->list_0[x].scr_pattern_id)))
    CALL error_handling(error_line)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    t.scr_term_id
    FROM scr_term_hier t
    WHERE t.scr_pattern_id=cnvtint(trim(requestin->list_0[x].scr_pattern_id))
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
   IF (curqual < 1)
    SET error_line = trim(concat("ERROR >NO TERM_ID'S IN TERM_HIER  : scr_pattern_id = ",trim(
       requestin->list_0[x].scr_pattern_id)))
    CALL error_handling(error_line)
   ELSE
    SET nbr_of_terms = size(term_list->index,5)
    UPDATE  FROM scr_term_hier s,
      (dummyt d  WITH seq = value(nbr_of_terms))
     SET s.source_term_hier_id = 0, s.parent_term_hier_id = 0
     PLAN (d)
      JOIN (s
      WHERE (s.scr_term_id=term_list->index[d.seq].id))
     WITH nocounter
    ;end update
    IF (curqual != nbr_of_terms)
     SET error_line = trim(concat("ERROR >BREAKING HIER CONSTRAINTS  : scr_pattern_id = ",trim(
        requestin->list_0[x].scr_pattern_id)))
     CALL error_handling(error_line)
    ELSE
     SET nbr_of_terms = size(term_list->index,5)
     DELETE  FROM scr_term_hier s
      WHERE s.scr_pattern_id=cnvtint(trim(requestin->list_0[x].scr_pattern_id))
      WITH nocounter
     ;end delete
     IF (curqual != nbr_of_terms)
      SET error_line = trim(concat(
        "WARNING >DELETE IN SCR_TERM_HIER SCR_PATTERN_ID  : scr_pattern_id = ",trim(requestin->
         list_0[x].scr_pattern_id)))
      CALL error_handling(error_line)
     ELSE
      COMMIT
     ENDIF
     SET nbr_of_terms = size(term_list->index,5)
     DELETE  FROM scr_term_text s,
       (dummyt d  WITH seq = value(nbr_of_terms))
      SET d.seq = 1
      PLAN (d)
       JOIN (s
       WHERE (s.scr_term_id=term_list->index[d.seq].id))
      WITH nocounter
     ;end delete
     IF (curqual != nbr_of_terms)
      SET error_line = trim(concat(
        "WARNING >DELETE IN SCR_TERM_TEXT SCR_PATTERN_ID  : scr_pattern_id = ",trim(requestin->
         list_0[x].scr_pattern_id)))
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
     IF (curqual != nbr_of_terms)
      SET error_line = trim(concat(
        "WARNING >DELETE IN SCR_TERM_DEFINITION SCR_PATTERN_ID  : scr_pattern_id = ",trim(requestin->
         list_0[x].scr_pattern_id)))
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
     IF (curqual != nbr_of_terms)
      SET error_line = trim(concat("WARNING >DELETE IN SCR_TERM SCR_PATTERN_ID  : scr_pattern_id = ",
        trim(requestin->list_0[x].scr_pattern_id)))
      CALL error_handling(error_line)
     ELSE
      COMMIT
     ENDIF
    ENDIF
   ENDIF
   DELETE  FROM scr_pattern_indication s
    WHERE s.scr_pattern_id=cnvtint(trim(requestin->list_0[x].scr_pattern_id))
    WITH nocounter
   ;end delete
   IF (curqual < 1)
    SET error_line = trim(concat(
      "WARNING >DELETE IN SCR_PATTERN_INDICATION SCR_PATTERN_ID  : scr_pattern_id = ",trim(requestin
       ->list_0[x].scr_pattern_id)))
    CALL error_handling(error_line)
   ELSE
    COMMIT
   ENDIF
   DELETE  FROM scr_pattern_hier_explode s
    WHERE s.scr_pattern_id=cnvtint(trim(requestin->list_0[x].scr_pattern_id))
    WITH nocounter
   ;end delete
   IF (curqual < 1)
    SET error_line = trim(concat(
      "WARNING >DELETE IN SCR_PATTERN_HIER_EXPLODE SCR_PATTERN_ID  : scr_pattern_id = ",trim(
       requestin->list_0[x].scr_pattern_id)))
    CALL error_handling(error_line)
   ELSE
    COMMIT
   ENDIF
   DELETE  FROM scr_paragraph s
    WHERE s.scr_pattern_id=cnvtint(trim(requestin->list_0[x].scr_pattern_id))
    WITH nocounter
   ;end delete
   IF (curqual < 1)
    SET error_line = trim(concat(
      "WARNING >DELETE IN SCR_PARAGRAPH SCR_PATTERN_ID  : scr_pattern_id = ",trim(requestin->list_0[x
       ].scr_pattern_id)))
    CALL error_handling(error_line)
   ELSE
    COMMIT
   ENDIF
   DELETE  FROM scr_sentence s
    WHERE s.scr_pattern_id=cnvtint(trim(requestin->list_0[x].scr_pattern_id))
    WITH nocounter
   ;end delete
   IF (curqual < 1)
    SET error_line = trim(concat(
      "WARNING >DELETE IN SCR_SENTENCE SCR_PATTERN_ID  : scr_pattern_id = ",trim(requestin->list_0[x]
       .scr_pattern_id)))
    CALL error_handling(error_line)
   ELSE
    COMMIT
   ENDIF
   DELETE  FROM scr_paragraph_type s
    WHERE cnvtupper(trim(s.cki_source))=cnvtupper(trim(requestin->list_0[x].cki_source))
     AND cnvtupper(trim(s.cki_identifier))=cnvtupper(trim(requestin->list_0[x].cki_identifier))
    WITH nocounter
   ;end delete
   IF (curqual < 1)
    SET error_line = trim(concat(
      "WARNING >DELETE IN SCR_PARAGRAPH_TYPE SCR_PATTERN_ID  : scr_pattern_id = ",trim(requestin->
       list_0[x].scr_pattern_id)))
    CALL error_handling(error_line)
   ELSE
    COMMIT
   ENDIF
   DELETE  FROM scr_pattern s
    WHERE s.scr_pattern_id=cnvtint(trim(requestin->list_0[x].scr_pattern_id))
    WITH nocounter
   ;end delete
   IF (curqual != 1)
    SET error_line = trim(concat("WARNING >DELETE IN SCR_PATTERN SCR_PATTERN_ID  : scr_pattern_id = ",
      trim(requestin->list_0[x].scr_pattern_id)))
    CALL error_handling(error_line)
   ELSE
    COMMIT
   ENDIF
 END ;Subroutine
#end_of_delete
 GO TO increment_iterm
#exit_script
 SELECT INTO "SCD_DEL_FUNCTION.LOG"
  rvar
  HEAD REPORT
   col 0, "SCD_DEL_FUNCTION    :end   >", curtime"hh:mm:ss;;m",
   col + 2, curdate"dd-mmm-yyyy;;d"
  DETAIL
   col 0
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
END GO

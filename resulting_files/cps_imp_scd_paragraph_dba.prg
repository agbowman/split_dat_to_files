CREATE PROGRAM cps_imp_scd_paragraph:dba
 SET qual = size(requestin->list_0,5)
 SET x = 1
 SET error_line = fillstring(120," ")
 SET rvar = 0
 SET log_file_name = build("SCD_IMP_PARAGRAPH_",format(curdate,"yymmdd;;d"),".log")
 SET errmsg = fillstring(132," ")
 SELECT INTO value(log_file_name)
  rvar
  HEAD REPORT
   row + 1, "SCD_PARAGRAPH_IMPORT: begin >", curtime"hh:mm:ss;;m",
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
   SELECT INTO "NL:"
    s.scr_pattern_id
    FROM scr_pattern s
    WHERE s.scr_pattern_id=cnvtint(trim(requestin->list_0[x].scr_pattern_id))
     AND trim(s.cki_source)=trim(requestin->list_0[x].scr_pattern_cki_source)
     AND trim(s.cki_identifier)=trim(requestin->list_0[x].scr_pattern_cki_identifier)
    WITH nocounter, maxqual(s,1)
   ;end select
   IF (curqual != 1)
    SET error_line = trim(concat("ERROR >NO SUCH PATTERN IN SCR_PATTERN : scr_pattern_id = ",trim(
       requestin->list_0[x].scr_pattern_id)))
    CALL error_handling(error_line)
    SET error_line = trim(concat("  scr_pattern_cki_source = ",trim(requestin->list_0[x].
       scr_pattern_cki_source),"  scr_pattern_cki_ident = ",trim(requestin->list_0[x].
       scr_pattern_cki_identifier)))
    CALL error_handling(error_line)
    GO TO increment_item
   ENDIF
   SET scr_paragraph_type_id = 0.0
   IF ((requestin->list_0[x].paragraph_type_cki_source > " ")
    AND (requestin->list_0[x].paragraph_type_cki_identifier > " "))
    SELECT INTO "NL:"
     s.scr_paragraph_type_id
     FROM scr_paragraph_type s
     WHERE (s.cki_source=requestin->list_0[x].paragraph_type_cki_source)
      AND (s.cki_identifier=requestin->list_0[x].paragraph_type_cki_identifier)
     DETAIL
      scr_paragraph_type_id = s.scr_paragraph_type_id
     WITH nocounter, maxqual(s,1)
    ;end select
    IF (curqual != 1)
     SET error_line = trim(concat("ERROR >FAILED TO GET paragraph_type_id : scr_pattern_id = ",trim(
        requestin->list_0[x].scr_pattern_id)))
     CALL error_handling(error_line)
     SET error_line = trim(concat("  paragraph_type_cki_source = ",trim(requestin->list_0[x].
        paragraph_type_cki_source),"  paragraph_type_cki_ident = ",trim(requestin->list_0[x].
        paragraph_type_cki_identifier)))
     CALL error_handling(error_line)
     GO TO increment_item
    ENDIF
   ENDIF
   SELECT INTO "NL:"
    scr_pattern_id
    FROM scr_paragraph s
    WHERE (s.scr_pattern_id=requestin->list_0[x].scr_pattern_id)
     AND s.scr_paragraph_type_id=scr_paragraph_type_id
    WITH nocounter, maxqual(s,1)
   ;end select
   IF (curqual=1)
    SET error_line = trim(concat("ERROR > DUPLICATE PARAGRAPH : scr_pattern_id = ",trim(requestin->
       list_0[x].scr_pattern_id)))
    CALL error_handling(error_line)
    SET error_line = trim(concat("  paragraph_type_cki_source = ",trim(requestin->list_0[x].
       paragraph_type_cki_source),"  paragraph_type_cki_ident = ",trim(requestin->list_0[x].
       paragraph_type_cki_identifier)))
    CALL error_handling(error_line)
    GO TO increment_item
   ENDIF
   INSERT  FROM scr_paragraph s
    SET s.scr_pattern_id = cnvtint(trim(requestin->list_0[x].scr_pattern_id)), s
     .scr_paragraph_type_id = scr_paragraph_type_id, s.sequence_number = cnvtint(trim(requestin->
       list_0[x].sequence_number))
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET error_line = trim(concat("ERROR >FAILED TO INSERT IN PARAGRAPH TABLE  : scr_pattern_id = ",
      trim(requestin->list_0[x].scr_pattern_id)))
    CALL error_handling(error_line)
    SET errcode = error(errmsg,1)
    CALL error_handling(concat("  ",substring(1,126,errmsg)))
    GO TO next_item
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
#exit_script
 SELECT INTO value(log_file_name)
  rvar
  HEAD REPORT
   col 0, "SCD_IMPORT_PARAGRAPH  :end   >", curtime"hh:mm:ss;;m",
   col + 2, curdate"dd-mmm-yyyy;;d"
  DETAIL
   col 0
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
END GO

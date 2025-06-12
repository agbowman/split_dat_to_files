CREATE PROGRAM cps_imp_scd_term_def:dba
 SET qual = size(requestin->list_0,5)
 SET x = 1
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0.0
 SET code_value = 0.0
 SET scr_term_def_type_cd = 0.0
 SET error_line = fillstring(120," ")
 SET rvar = 0
 SELECT INTO "SCD_IMP_TERM_DEF.LOG"
  rvar
  HEAD REPORT
   row + 1, "SCD_IMPORT_TERM_DEF  :begin >", curtime"hh:mm:ss;;m",
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
   SET scr_term_def_type_cd = 0.0
   IF ((requestin->list_0[x].scr_term_def_type_mean != " "))
    SET code_set = 14709
    SET code_value = 0.0
    SET cdf_meaning = substring(1,12,requestin->list_0[x].scr_term_def_type_mean)
    EXECUTE cpm_get_cd_for_cdf
    SET scr_term_def_type_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("WARNING >INVALID TERM_DEF_TYPE_MEAN  : code_set = ",trim(
        cnvtstring(code_set))," cdf_meaning = ",trim(cdf_meaning),"  : scr_term_def_id = ",
       trim(requestin->list_0[x].scr_term_def_id)))
     CALL error_handling(error_line)
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    t.scr_term_id
    FROM scr_term t
    WHERE t.scr_term_id=cnvtint(requestin->list_0[x].scr_term_def_id)
    WITH nocounter, maxqual(t,1)
   ;end select
   IF (curqual < 1)
    SET error_line = trim(concat("ERROR >NONEXSISTANT SCR_TERM_DEF_ID  : scr_term_def_id = ",trim(
       requestin->list_0[x].scr_term_def_id)))
    CALL error_handling(error_line)
    GO TO increment_item
   ENDIF
   INSERT  FROM scr_term_definition t
    SET t.scr_term_def_id = cnvtint(trim(requestin->list_0[x].scr_term_def_id)), t
     .scr_term_def_type_cd = scr_term_def_type_cd, t.scr_term_def_key = requestin->list_0[x].
     scr_term_def_key,
     t.fkey_id = cnvtint(trim(requestin->list_0[x].fkey_id)), t.fkey_entity_name = cnvtupper(
      requestin->list_0[x].fkey_entity_name), t.def_text = requestin->list_0[x].def_text
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET error_line = trim(concat(
      "ERROR >FAILED TO INSERT IN SCR_TERM_DEFINITION TABLE  : scr_term_def_id = ",trim(requestin->
       list_0[x].scr_term_def_id)))
    CALL error_handling(error_line)
    GO TO next_item
   ENDIF
   COMMIT
 ENDFOR
 GO TO exit_script
 SUBROUTINE error_handling(the_output)
   SELECT INTO "SCD_IMP_TERM_DEF.LOG"
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
 SELECT INTO "SCD_IMP_TERM_DEF.LOG"
  rvar
  HEAD REPORT
   col 0, "SCD_IMPORT_TERM_DEF  :end   >", curtime"hh:mm:ss;;m",
   col + 2, curdate"dd-mmm-yyyy;;d"
  DETAIL
   col 0
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
END GO

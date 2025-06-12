CREATE PROGRAM cps_imp_scd_term_hier:dba
 SET qual = size(requestin->list_0,5)
 SET x = 1
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0.0
 SET code_value = 0.0
 SET recommended_cd = 0.0
 SET dependency_cd = 0.0
 SET default_cd = 0.0
 SET error_line = fillstring(120," ")
 SET log_file_name = build("SCD_IMP_TERM_HIER_",format(curdate,"yymmdd;;d"),".log")
 SET errmsg = fillstring(132," ")
 SET rvar = 0
 SELECT INTO value(log_file_name)
  rvar
  HEAD REPORT
   row + 1, "SCD_IMPORT_TERM_HIER  :begin >", curtime"hh:mm:ss;;m",
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
   SET recommended_cd = 0.0
   IF ((requestin->list_0[x].recommended_mean != " "))
    SET code_set = 14417
    SET code_value = 0.0
    SET cdf_meaning = substring(1,12,requestin->list_0[x].recommended_mean)
    EXECUTE cpm_get_cd_for_cdf
    SET recommended_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("WARNING >INVALID RECOMMENDED_MEAN  : code_set = ",trim(cnvtstring(
         code_set))," cdf_meaning = ",trim(cdf_meaning),"  : scr_term_hier_id = ",
       trim(requestin->list_0[x].scr_term_hier_id)))
     CALL error_handling(error_line)
    ENDIF
   ENDIF
   SET dependency_cd = 0.0
   IF ((requestin->list_0[x].dependency_mean != " "))
    SET code_set = 14422
    SET code_value = 0.0
    SET cdf_meaning = substring(1,12,requestin->list_0[x].dependency_mean)
    EXECUTE cpm_get_cd_for_cdf
    SET dependency_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("WARNING >INVALID DEPENDENCY_MEAN  : code_set = ",trim(cnvtstring(
         code_set))," cdf_meaning = ",trim(cdf_meaning),"  : scr_term_hier_id = ",
       trim(requestin->list_0[x].scr_term_hier_id)))
     CALL error_handling(error_line)
    ENDIF
   ENDIF
   SET default_cd = 0.0
   IF ((requestin->list_0[x].default_mean != " "))
    SET code_set = 14418
    SET code_value = 0.0
    SET cdf_meaning = substring(1,12,requestin->list_0[x].default_mean)
    EXECUTE cpm_get_cd_for_cdf
    SET default_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("WARNING >INVALID DEFAULT_MEAN  : code_set = ",trim(cnvtstring(
         code_set))," cdf_meaning = ",trim(cdf_meaning),"  : scr_term_hier_id = ",
       trim(requestin->list_0[x].scr_term_hier_id)))
     CALL error_handling(error_line)
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    s.scr_sentence_id
    FROM scr_sentence s
    WHERE s.scr_sentence_id=cnvtint(trim(requestin->list_0[x].scr_sentence_id))
    WITH nocounter, maxqual(s,1)
   ;end select
   IF (curqual < 1)
    SET error_line = trim(concat("ERROR >NONEXISTENT SCR_SENTENCE_ID  : scr_sentence_id = ",trim(
       requestin->list_0[x].scr_sentence_id)))
    CALL error_handling(error_line)
    GO TO increment_item
   ENDIF
   SELECT INTO "nl:"
    t.scr_term_hier_id
    FROM scr_term_hier t
    WHERE t.scr_term_hier_id=cnvtint(trim(requestin->list_0[x].scr_term_hier_id))
    WITH nocounter, maxqual(t,1)
   ;end select
   IF (curqual=1)
    SET error_line = trim(concat("ERROR >DUPLICATE SCR_TERM_HIER_ID  : scr_term_hier_id = ",trim(
       requestin->list_0[x].scr_term_hier_id)))
    CALL error_handling(error_line)
    GO TO increment_item
   ENDIF
   INSERT  FROM scr_term_hier t
    SET t.scr_term_hier_id = cnvtint(trim(requestin->list_0[x].scr_term_hier_id)), t.cki_source =
     requestin->list_0[x].cki_source, t.cki_identifier = requestin->list_0[x].cki_identifier,
     t.scr_sentence_id = cnvtint(trim(requestin->list_0[x].scr_sentence_id)), t.scr_term_id = cnvtint
     (trim(requestin->list_0[x].scr_term_id)), t.parent_term_hier_id = cnvtint(trim(requestin->
       list_0[x].parent_term_hier_id)),
     t.sequence_number = cnvtint(trim(requestin->list_0[x].sequence_number)), t.scr_pattern_id =
     cnvtint(trim(requestin->list_0[x].scr_pattern_id)), t.recommended_cd = recommended_cd,
     t.dependency_group = cnvtint(trim(requestin->list_0[x].dependency_group)), t.dependency_cd =
     dependency_cd, t.default_cd = default_cd,
     t.source_term_hier_id = cnvtint(trim(requestin->list_0[x].source_term_hier_id)), t.updt_dt_tm =
     cnvtdatetime(curdate,curtime3), t.updt_id = 0,
     t.updt_task = 0, t.updt_applctx = 0
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET error_line = trim(concat(
      "ERROR >FAILED TO INSERT IN SCR_TERM_HIER TABLE  : scr_term_hier_id = ",trim(requestin->list_0[
       x].scr_term_hier_id)))
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
   col 0, "SCD_IMPORT_TERM_HIER  :end   >", curtime"hh:mm:ss;;m",
   col + 2, curdate"dd-mmm-yyyy;;d"
  DETAIL
   col 0
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
END GO

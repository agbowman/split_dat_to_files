CREATE PROGRAM cps_imp_scd_sentence:dba
 SET qual = size(requestin->list_0,5)
 SET x = 1
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0.0
 SET code_value = 0.0
 SET sentence_topic_cd = 0.0
 SET sentence_class_cd = 0.0
 SET text_format_rule_cd = 0.0
 SET recommended_cd = 0.0
 SET default_cd = 0.0
 SET scr_paragraph_type_id = 0.0
 SET error_line = fillstring(120," ")
 SET log_file_name = build("SCD_IMP_SENTENCE_",format(curdate,"yymmdd;;d"),".log")
 SET errmsg = fillstring(132," ")
 SET rvar = 0
 SELECT INTO value(log_file_name)
  rvar
  HEAD REPORT
   row + 1, "SCD_IMPORT_SENTENCE  :begin >", curtime"hh:mm:ss;;m",
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
   SET sentence_topic_cd = 0.0
   IF ((requestin->list_0[x].sentence_topic_mean != " "))
    SET code_set = 14412
    SET code_value = 0.0
    SET cdf_meaning = substring(1,12,requestin->list_0[x].sentence_topic_mean)
    EXECUTE cpm_get_cd_for_cdf
    SET sentence_topic_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("WARNING >INVALID SENT_TOPIC_MEAN  : code_set = ",trim(cnvtstring(
         code_set))," cdf_meaning = ",trim(cdf_meaning),"  : scr_sentence_id = ",
       trim(requestin->list_0[x].scr_sentence_id)))
     CALL error_handling(error_line)
    ENDIF
   ENDIF
   SET sentence_class_cd = 0.0
   IF ((requestin->list_0[x].sentence_class_mean != " "))
    SET code_set = 14411
    SET code_value = 0.0
    SET cdf_meaning = substring(1,12,requestin->list_0[x].sentence_class_mean)
    EXECUTE cpm_get_cd_for_cdf
    SET sentence_class_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("WARNING >INVALID SENT_CLASS_MEAN  : code_set = ",trim(cnvtstring(
         code_set))," cdf_meaning = ",trim(cdf_meaning),"  : scr_sentence_id = ",
       trim(requestin->list_0[x].scr_sentence_id)))
     CALL error_handling(error_line)
    ENDIF
   ENDIF
   SET text_format_rule_cd = 0.0
   IF ((requestin->list_0[x].text_format_rule_mean != " "))
    SET code_set = 14419
    SET code_value = 0.0
    SET cdf_meaning = substring(1,12,requestin->list_0[x].text_format_rule_mean)
    EXECUTE cpm_get_cd_for_cdf
    SET text_format_rule_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("WARNING >INVALID FORMAT_RULE_MEAN  : code_set = ",trim(cnvtstring(
         code_set))," cdf_meaning = ",trim(cdf_meaning),"  : scr_sentence_id = ",
       trim(requestin->list_0[x].scr_sentence_id)))
     CALL error_handling(error_line)
    ENDIF
   ENDIF
   SET recommended_cd = 0.0
   IF ((requestin->list_0[x].recommended_mean != " "))
    SET code_set = 14417
    SET code_value = 0.0
    SET cdf_meaning = substring(1,12,requestin->list_0[x].recommended_mean)
    EXECUTE cpm_get_cd_for_cdf
    SET recommended_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("WARNING >INVALID RECOMMENDED_MEAN  : code_set = ",trim(cnvtstring(
         code_set))," cdf_meaning = ",trim(cdf_meaning),"  : scr_sentence_id = ",
       trim(requestin->list_0[x].scr_sentence_id)))
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
         code_set))," cdf_meaning = ",trim(cdf_meaning),"  : scr_sentence_id = ",
       trim(requestin->list_0[x].scr_sentence_id)))
     CALL error_handling(error_line)
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    s.scr_pattern_id
    FROM scr_pattern s
    WHERE s.scr_pattern_id=cnvtint(trim(requestin->list_0[x].scr_pattern_id))
     AND trim(s.cki_source)=trim(requestin->list_0[x].scr_pattern_cki_source)
     AND trim(s.cki_identifier)=trim(requestin->list_0[x].scr_pattern_cki_identifier)
    WITH nocounter, maxqual(s,1)
   ;end select
   IF (curqual != 1)
    SET error_line = trim(concat("ERROR >NONEXISTENT SCR_PATTERN_ID  : scr_sentence_id = ",trim(
       requestin->list_0[x].scr_sentence_id)))
    CALL error_handling(error_line)
    SET error_line = trim(concat("   scr_pattern_id = ",trim(requestin->list_0[x].scr_pattern_id)))
    CALL error_handling(error_line)
    GO TO increment_item
   ENDIF
   IF ((requestin->list_0[x].paragraph_type_cki_source > " ")
    AND (requestin->list_0[x].paragraph_type_cki_identifier > " "))
    SELECT INTO "nl:"
     s.scr_paragraph_type_id
     FROM scr_paragraph_type s
     WHERE trim(s.cki_source)=trim(requestin->list_0[x].paragraph_type_cki_source)
      AND trim(s.cki_identifier)=trim(requestin->list_0[x].paragraph_type_cki_identifier)
     DETAIL
      scr_paragraph_type_id = s.scr_paragraph_type_id
     WITH nocounter, maxqual(s,1)
    ;end select
    IF (curqual != 1)
     SET error_line = trim(concat("ERROR >INVALID PARAGRAPH TYPE  : scr_sentence_id = ",trim(
        requestin->list_0[x].scr_sentence_id)))
     CALL error_handling(error_line)
     SET error_line = trim(concat("  PARAGRAPH_TYPE_CKI_SOURCE = ",trim(requestin->list_0[x].
        paragraph_type_cki_source),"  PARAGRAPH_TYPE_CKI_IDENT = ",trim(requestin->list_0[x].
        paragraph_type_cki_identifier)))
     CALL error_handling(error_line)
     GO TO increment_item
    ENDIF
   ELSE
    SET scr_paragraph_type_id = 0
   ENDIF
   SELECT INTO "nl:"
    s.scr_paragraph_type_id, s.scr_pattern_id
    FROM scr_paragraph s
    WHERE s.scr_paragraph_type_id=scr_paragraph_type_id
     AND s.scr_pattern_id=cnvtint(trim(requestin->list_0[x].scr_pattern_id))
    WITH nocounter, maxqual(s,1)
   ;end select
   IF (curqual != 1)
    SET error_line = trim(concat("ERROR >INVALID PARAGRAPH  : scr_sentence_id = ",trim(requestin->
       list_0[x].scr_sentence_id)))
    CALL error_handling(error_line)
    SET error_line = trim(concat("  scr_paragraph_type_id = ",trim(cnvtstring(scr_paragraph_type_id,
        20,1,l))))
    CALL error_handling(error_line)
    GO TO increment_item
   ENDIF
   SELECT INTO "nl:"
    s.scr_sentence_id
    FROM scr_sentence s
    WHERE s.scr_sentence_id=cnvtint(trim(requestin->list_0[x].scr_sentence_id))
    WITH nocounter, maxqual(s,1)
   ;end select
   IF (curqual=1)
    SET error_line = trim(concat("ERROR >DUPLICATE SENTENCE  : scr_sentence_id = ",trim(requestin->
       list_0[x].scr_sentence_id)))
    CALL error_handling(error_line)
    GO TO increment_item
   ENDIF
   INSERT  FROM scr_sentence t
    SET t.scr_sentence_id = cnvtint(trim(requestin->list_0[x].scr_sentence_id)), t
     .scr_paragraph_type_id = scr_paragraph_type_id, t.canonical_sentence_pattern_id = cnvtint(trim(
       requestin->list_0[x].canonical_sentence_pattern_id)),
     t.sequence_number = cnvtint(trim(requestin->list_0[x].sequence_number)), t.sentence_topic_cd =
     sentence_topic_cd, t.sentence_class_cd = sentence_class_cd,
     t.text_format_rule_cd = text_format_rule_cd, t.recommended_cd = recommended_cd, t.default_cd =
     default_cd,
     t.scr_pattern_id = cnvtint(trim(requestin->list_0[x].scr_pattern_id)), t.updt_dt_tm =
     cnvtdatetime(curdate,curtime3), t.updt_id = 0,
     t.updt_task = 0, t.updt_applctx = 0
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET error_line = trim(concat(
      "ERROR >FAILED TO INSERT IN SCR_SENTENCE TABLE  : scr_sentence_id = ",trim(requestin->list_0[x]
       .scr_sentence_id)))
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
   col 0, "SCD_IMPORT_SENTENCE  :end   >", curtime"hh:mm:ss;;m",
   col + 2, curdate"dd-mmm-yyyy;;d"
  DETAIL
   col 0
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
END GO

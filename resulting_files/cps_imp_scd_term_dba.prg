CREATE PROGRAM cps_imp_scd_term:dba
 SET qual = size(requestin->list_0,5)
 SET x = 1
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0.0
 SET code_value = 0.0
 SET active_status_cd = 0.0
 SET term_type_cd = 0.0
 SET state_logic_cd = 0.0
 SET repeat_cd = 0.0
 SET store_cd = 0.0
 SET visible_cd = 0.0
 SET eligibility_check_cd = 0.0
 SET language_cd = 0.0
 SET text_negation_rule_cd = 0.0
 SET text_format_rule_cd = 0.0
 SET error_line = fillstring(120," ")
 SET young_date = 0.0
 SET old_date = 0.0
 SET log_file_name = build("SCD_IMP_TERM_",format(curdate,"yymmdd;;d"),".log")
 SET errmsg = fillstring(132," ")
 SET rvar = 0
 SELECT INTO value(log_file_name)
  rvar
  HEAD REPORT
   row + 1, "SCD_IMPORT_TERM  :begin >", curtime"hh:mm:ss;;m",
   col + 2, curdate"dd-mmm-yyyy;;d"
  DETAIL
   col 0
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
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
   SET term_type_cd = 0.0
   IF ((requestin->list_0[x].term_type_mean != " "))
    SET code_set = 14413
    SET code_value = 0.0
    SET cdf_meaning = substring(1,12,requestin->list_0[x].term_type_mean)
    EXECUTE cpm_get_cd_for_cdf
    SET term_type_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("WARNING >INVALID TERM_TYPE_MEAN  : code_set = ",trim(cnvtstring(
         code_set))," cdf_meaning = ",trim(cdf_meaning),"  : scr_term_id = ",
       trim(requestin->list_0[x].scr_term_id)))
     CALL error_handling(error_line)
    ENDIF
   ENDIF
   SET state_logic_cd = 0.0
   IF ((requestin->list_0[x].state_logic_mean != " "))
    SET code_set = 14416
    SET code_value = 0.0
    SET cdf_meaning = substring(1,12,requestin->list_0[x].state_logic_mean)
    EXECUTE cpm_get_cd_for_cdf
    SET state_logic_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("WARNING >INVALID STATE_LOGIC_MEAN  : code_set = ",trim(cnvtstring(
         code_set))," cdf_meaning = ",trim(cdf_meaning),"  : scr_term_id = ",
       trim(requestin->list_0[x].scr_term_id)))
     CALL error_handling(error_line)
    ENDIF
   ENDIF
   SET repeat_cd = 0.0
   IF ((requestin->list_0[x].repeat_mean != " "))
    SET code_set = 14421
    SET code_value = 0.0
    SET cdf_meaning = substring(1,12,requestin->list_0[x].repeat_mean)
    EXECUTE cpm_get_cd_for_cdf
    SET repeat_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("WARNING >INVALID REPEAT_MEAN  : code_set = ",trim(cnvtstring(
         code_set))," cdf_meaning = ",trim(cdf_meaning),"  : scr_term_id = ",
       trim(requestin->list_0[x].scr_term_id)))
     CALL error_handling(error_line)
    ENDIF
   ENDIF
   SET store_cd = 0.0
   IF ((requestin->list_0[x].store_mean != " "))
    SET code_set = 14414
    SET code_value = 0.0
    SET cdf_meaning = substring(1,12,requestin->list_0[x].store_mean)
    EXECUTE cpm_get_cd_for_cdf
    SET store_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("WARNING >INVALID STORE_MEAN  : code_set = ",trim(cnvtstring(
         code_set))," cdf_meaning = ",trim(cdf_meaning),"  : scr_term_id = ",
       trim(requestin->list_0[x].scr_term_id)))
     CALL error_handling(error_line)
    ENDIF
   ENDIF
   SET visible_cd = 0.0
   IF ((requestin->list_0[x].visible_mean != " "))
    SET code_set = 14450
    SET code_value = 0.0
    SET cdf_meaning = substring(1,12,requestin->list_0[x].visible_mean)
    EXECUTE cpm_get_cd_for_cdf
    SET visible_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("WARNING >INVALID VISIBLE_MEAN  : code_set = ",trim(cnvtstring(
         code_set))," cdf_meaning = ",trim(cdf_meaning),"  : scr_term_id = ",
       trim(requestin->list_0[x].scr_term_id)))
     CALL error_handling(error_line)
    ENDIF
   ENDIF
   SET eligibility_check_cd = 0.0
   IF ((requestin->list_0[x].eligibility_check_mean != " "))
    SET code_set = 14449
    SET code_value = 0.0
    SET cdf_meaning = substring(1,12,requestin->list_0[x].eligibility_check_mean)
    EXECUTE cpm_get_cd_for_cdf
    SET eligibility_check_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("WARNING >INVALID ELIGIBILITY_CHECK_MEAN  : code_set = ",trim(
        cnvtstring(code_set))," cdf_meaning = ",trim(cdf_meaning),"  : scr_term_id = ",
       trim(requestin->list_0[x].scr_term_id)))
     CALL error_handling(error_line)
    ENDIF
   ENDIF
   SET language_cd = 0.0
   IF ((requestin->list_0[x].language_mean > " "))
    SET cdf_meaning = substring(1,12,requestin->list_0[x].language_mean)
   ELSE
    SET cdf_meaning = "ENG"
   ENDIF
   SET code_set = 36
   SET code_value = 0.0
   EXECUTE cpm_get_cd_for_cdf
   SET language_cd = code_value
   IF (code_value=0)
    SET error_line = trim(concat("WARNING >INVALID LANGUAGE_MEAN  : code_set = ",trim(cnvtstring(
        code_set))," cdf_meaning = ",trim(cdf_meaning),"  : scr_term_id = ",
      trim(requestin->list_0[x].scr_term_id)))
    CALL error_handling(error_line)
   ENDIF
   SET text_negation_rule_cd = 0.0
   IF ((requestin->list_0[x].text_negation_rule_mean != " "))
    SET code_set = 14420
    SET code_value = 0.0
    SET cdf_meaning = substring(1,12,requestin->list_0[x].text_negation_rule_mean)
    EXECUTE cpm_get_cd_for_cdf
    SET text_negation_rule_cd = code_value
    IF (code_value=0)
     SET error_line = trim(concat("WARNING >INVALID TEXT_NEGATION_RULE_MEAN  : code_set = ",trim(
        cnvtstring(code_set))," cdf_meaning = ",trim(cdf_meaning),"  : scr_term_id = ",
       trim(requestin->list_0[x].scr_term_id)))
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
     SET error_line = trim(concat("WARNING >INVALID TEXT_FORMAT_RULE_MEAN  : code_set = ",trim(
        cnvtstring(code_set))," cdf_meaning = ",trim(cdf_meaning),"  : scr_term_id = ",
       trim(requestin->list_0[x].scr_term_id)))
     CALL error_handling(error_line)
    ENDIF
   ENDIF
   SET young_date = 0.0
   IF ((requestin->list_0[x].youngest_age > " "))
    SET young_date = cnvtreal(trim(requestin->list_0[x].youngest_age))
   ENDIF
   SET old_date = 0.0
   IF ((requestin->list_0[x].oldest_age > " "))
    SET old_date = cnvtreal(trim(requestin->list_0[x].oldest_age))
   ENDIF
   INSERT  FROM scr_term t
    SET t.active_ind = 1, t.active_status_cd = active_status_cd, t.active_status_dt_tm = cnvtdatetime
     (curdate,curtime3),
     t.active_status_prsnl_id = 0.0, t.eligibility_check_cd = eligibility_check_cd, t.oldest_age =
     old_date,
     t.repeat_cd = repeat_cd, t.restrict_to_sex = substring(1,12,requestin->list_0[x].restrict_to_sex
      ), t.scr_term_def_id = cnvtint(trim(requestin->list_0[x].scr_term_def_id)),
     t.scr_term_id = cnvtint(trim(requestin->list_0[x].scr_term_id)), t.state_logic_cd =
     state_logic_cd, t.store_cd = store_cd,
     t.term_type_cd = term_type_cd, t.updt_applctx = 0, t.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     t.updt_id = 0, t.updt_task = 0, t.visible_cd = visible_cd,
     t.youngest_age = young_date
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET error_line = trim(concat("ERROR >FAILED TO INSERT IN SCR_TERM TABLE  : scr_term_id = ",trim(
       requestin->list_0[x].scr_term_id)))
    CALL error_handling(error_line)
    SET errcode = error(errmsg,1)
    CALL error_handling(concat("  ",substring(1,126,errmsg)))
    GO TO next_item
   ENDIF
   INSERT  FROM scr_term_text tt
    SET tt.definition = requestin->list_0[x].definition, tt.display = substring(1,39,requestin->
      list_0[x].display), tt.external_reference_info = requestin->list_0[x].external_reference_info,
     tt.language_cd = language_cd, tt.scr_term_id = cnvtint(trim(requestin->list_0[x].scr_term_id)),
     tt.text_format_rule_cd = text_format_rule_cd,
     tt.text_negation_rule_cd = text_negation_rule_cd, tt.text_representation = requestin->list_0[x].
     text_representation
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET error_line = trim(concat("ERROR >FAILED TO INSERT IN SCR_TERM_TEXT TABLE  : scr_term_id = ",
      trim(requestin->list_0[x].scr_term_id)))
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
   col 0, "SCD_IMPORT_TERM  :end   >", curtime"hh:mm:ss;;m",
   col + 2, curdate"dd-mmm-yyyy;;d"
  DETAIL
   col 0
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
END GO

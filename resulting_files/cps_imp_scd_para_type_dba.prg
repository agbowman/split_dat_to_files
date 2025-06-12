CREATE PROGRAM cps_imp_scd_para_type:dba
 DECLARE paragraph_class_cd = f8 WITH public, noconstant(0.0)
 DECLARE text_format_rule_cd = f8 WITH public, noconstant(0.0)
 DECLARE canonical_pattern_id = f8 WITH public, noconstant(0.0)
 DECLARE default_cd = f8 WITH public, noconstant(0.0)
 DECLARE active_status_cd = f8 WITH public, noconstant(0.0)
 DECLARE action_type_freetext_cd = f8 WITH public, noconstant(0.0)
 DECLARE action_type_dictation_cd = f8 WITH public, noconstant(0.0)
 DECLARE action_type_copyforward_cd = f8 WITH public, noconstant(0.0)
 DECLARE action_type_nocopyforward_cd = f8 WITH public, noconstant(0.0)
 DECLARE default_entry_action_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE copy_forward_action_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE existing_action_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE existing_action_id = f8 WITH public, noconstant(0.0)
 SET qual = size(requestin->list_0,5)
 SET x = 1
 SET error_line = fillstring(120," ")
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0.0
 DECLARE code_value = f8 WITH public, noconstant(0.0)
 DECLARE scr_paragraph_type_id = f8 WITH public, noconstant(0.0)
 DECLARE tscr_paragraph_type_id = f8 WITH public, noconstant(0.0)
 DECLARE scr_action_id = f8 WITH public, noconstant(0.0)
 SET tupdt_cnt = 0
 SET tupdt_dt_tm = cnvtdatetime(curdate,curtime3)
 SET action_code_set = 31337
 SET action_type_freetext_cd = 0.0
 SET code_set = action_code_set
 SET cdf_meaning = "DEFFREETEXT"
 SET stat = scdgetcdforcdf(code_set,cdf_meaning)
 SET action_type_freetext_cd = code_value
 SET action_type_dictation_cd = 0.0
 SET code_set = action_code_set
 SET cdf_meaning = "DICTATION"
 SET stat = scdgetcdforcdf(code_set,cdf_meaning)
 SET action_type_dictation_cd = code_value
 SET action_type_copyforward_cd = 0.0
 SET code_set = action_code_set
 SET cdf_meaning = "COPYPARA"
 SET stat = scdgetcdforcdf(code_set,cdf_meaning)
 SET action_type_copyforward_cd = code_value
 SET action_type_nopcopyforward_cd = 0.0
 SET code_set = action_code_set
 SET cdf_meaning = "NOCOPYPARA"
 SET stat = scdgetcdforcdf(code_set,cdf_meaning)
 SET action_type_nocopyforward_cd = code_value
 SET log_file_name = build("SCD_IMP_PARA_TYPE_",format(curdate,"yymmdd;;d"),".log")
 SET errmsg = fillstring(132," ")
 SET rvar = 0
 SELECT INTO value(log_file_name)
  rvar
  HEAD REPORT
   row + 1, "SCR Paragraph Type Import begin >", curtime"hh:mm:ss;;m",
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
   SET paragraph_class_cd = 0.0
   IF ((requestin->list_0[x].paragraph_class_mean > " "))
    SET code_set = 14410
    SET cdf_meaning = requestin->list_0[x].paragraph_class_mean
    SET stat = scdgetcdforcdf(code_set,cdf_meaning)
    SET paragraph_class_cd = code_value
   ENDIF
   SET text_format_rule_cd = 0.0
   IF ((requestin->list_0[x].text_format_rule_mean > " "))
    SET code_set = 14419
    SET cdf_meaning = requestin->list_0[x].text_format_rule_mean
    SET stat = scdgetcdforcdf(code_set,cdf_meaning)
    SET text_format_rule_cd = code_value
   ENDIF
   SET default_cd = 0.0
   IF ((requestin->list_0[x].default_mean > " "))
    SET code_set = 14418
    SET cdf_meaning = requestin->list_0[x].default_mean
    SET stat = scdgetcdforcdf(code_set,cdf_meaning)
    SET default_cd = code_value
   ENDIF
   SET active_status_cd = 0.0
   SET code_set = 48
   SET cdf_meaning = requestin->list_0[x].active_status_mean
   SET stat = scdgetcdforcdf(code_set,cdf_meaning)
   SET active_status_cd = code_value
   SET canonical_pattern_id = 0.0
   IF ((requestin->list_0[x].canonical_pattern_cki_source > " ")
    AND (requestin->list_0[x].canonical_pattern_cki_ident > " "))
    SELECT INTO "NL:"
     FROM scr_pattern s
     PLAN (s
      WHERE (requestin->list_0[x].canonical_pattern_cki_source=s.cki_source)
       AND (requestin->list_0[x].canonical_pattern_cki_ident=s.cki_identifier))
     DETAIL
      canonical_pattern_id = s.scr_pattern_id
     WITH nocounter
    ;end select
   ENDIF
   SET default_entry_action_type_cd = 0.0
   IF (validate(requestin->list_0[x].default_entry_flag,"k") != "k")
    IF ((requestin->list_0[x].default_entry_flag="1"))
     SET default_entry_action_type_cd = action_type_freetext_cd
    ELSEIF ((requestin->list_0[x].default_entry_flag="2"))
     SET default_entry_action_type_cd = action_type_dictation_cd
    ELSE
     SET default_entry_action_type_cd = 0.0
    ENDIF
   ENDIF
   SET copy_forward_action_type_cd = 0.0
   IF (validate(requestin->list_0[x].copy_forward_flag,"k") != "k")
    IF ((requestin->list_0[x].copy_forward_flag="0"))
     SET copy_forward_action_type_cd = action_type_nocopyforward_cd
    ELSEIF ((requestin->list_0[x].copy_forward_flag="1"))
     SET copy_forward_action_type_cd = action_type_copyforward_cd
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    s.scr_paragraph_type_id
    FROM scr_paragraph_type s
    WHERE trim(s.cki_source)=trim(requestin->list_0[x].cki_source)
     AND trim(s.cki_identifier)=trim(requestin->list_0[x].cki_identifier)
    DETAIL
     tscr_paragraph_type_id = s.scr_paragraph_type_id, tupdt_cnt = s.updt_cnt, tupdt_dt_tm = s
     .updt_dt_tm
    WITH nocounter, maxqual(s,2)
   ;end select
   IF (curqual > 1)
    SET error_line = trim(concat("ERROR >MULTIPLE ROWS(>1) cki_source = ",trim(requestin->list_0[x].
       cki_source),"  cki_identifier = ",trim(requestin->list_0[x].cki_identifier)))
    CALL error_handling(error_line)
    GO TO increment_item
   ELSEIF (curqual=1)
    UPDATE  FROM scr_paragraph_type s
     SET s.cki_source =
      IF ((requestin->list_0[x].new_cki_source > " ")) requestin->list_0[x].new_cki_source
      ELSE requestin->list_0[x].cki_source
      ENDIF
      , s.cki_identifier =
      IF ((requestin->list_0[x].new_cki_identifier > " ")) requestin->list_0[x].new_cki_identifier
      ELSE requestin->list_0[x].cki_identifier
      ENDIF
      , s.display = requestin->list_0[x].display,
      s.display_key = cnvtupper(cnvtalphanum(trim(requestin->list_0[x].display))), s.description =
      requestin->list_0[x].description, s.paragraph_class_cd = paragraph_class_cd,
      s.text_format_rule_cd = text_format_rule_cd, s.canonical_pattern_id = canonical_pattern_id, s
      .sequence_number = cnvtint(trim(requestin->list_0[x].sequence_number)),
      s.default_cd = default_cd, s.active_ind = 1, s.active_status_cd = active_status_cd,
      s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.active_status_prsnl_id = 0, s
      .updt_cnt = (s.updt_cnt+ 1),
      s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = 0, s.updt_task = 0,
      s.updt_applctx = 0
     PLAN (s
      WHERE trim(s.cki_source)=trim(requestin->list_0[x].cki_source)
       AND trim(s.cki_identifier)=trim(requestin->list_0[x].cki_identifier))
     WITH nocounter
    ;end update
    IF (curqual != 1)
     SET error_line = trim(concat("ERROR >FAILED TO UPDATE  : scr_paragraph_type_id = ",trim(
        requestin->list_0[x].scr_paragraph_type_id)))
     CALL error_handling(error_line)
     SET errcode = error(errmsg,1)
     SET error_line = concat("  ",substring(1,100,errmsg))
     CALL error_handling(error_line)
     GO TO next_item
    ENDIF
    SELECT INTO "nl:"
     a.scr_action_cd, a.scr_action_id
     FROM scr_action a
     WHERE a.parent_entity_id=tscr_paragraph_type_id
      AND a.parent_entity_name="SCR_PARAGRAPH_TYPE"
      AND ((a.scr_action_cd=action_type_freetext_cd) OR (a.scr_action_cd=action_type_dictation_cd))
     HEAD REPORT
      existing_action_type_cd = a.scr_action_cd, existing_action_id = a.scr_action_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET existing_action_type_cd = 0
     SET existing_action_id = 0
    ENDIF
    IF (existing_action_type_cd != default_entry_action_type_cd)
     IF (existing_action_type_cd=0
      AND default_entry_action_type_cd > 0)
      SET stat = addaction(tscr_paragraph_type_id,default_entry_action_type_cd)
     ELSEIF (existing_action_type_cd > 0)
      IF (default_entry_action_type_cd > 0)
       UPDATE  FROM scr_action a
        SET a.scr_action_cd = default_entry_action_type_cd
        WHERE a.scr_action_id=existing_action_id
        WITH nocounter
       ;end update
      ELSE
       DELETE  FROM scr_action a
        WHERE a.scr_action_id=existing_action_id
       ;end delete
      ENDIF
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     a.scr_action_cd, a.scr_action_id
     FROM scr_action a
     WHERE a.parent_entity_id=tscr_paragraph_type_id
      AND a.parent_entity_name="SCR_PARAGRAPH_TYPE"
      AND ((a.scr_action_cd=action_type_copyforward_cd) OR (a.scr_action_cd=
     action_type_nocopyforward_cd))
     HEAD REPORT
      existing_action_type_cd = a.scr_action_cd, existing_action_id = a.scr_action_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET existing_action_type_cd = 0
     SET existing_action_id = 0
    ENDIF
    IF (existing_action_type_cd != copy_forward_action_type_cd)
     IF (existing_action_type_cd=0
      AND copy_forward_action_type_cd > 0)
      SET stat = addaction(tscr_paragraph_type_id,copy_forward_action_type_cd)
     ELSEIF (existing_action_type_cd > 0)
      IF (copy_forward_action_type_cd > 0)
       UPDATE  FROM scr_action a
        SET a.scr_action_cd = copy_forward_action_type_cd
        WHERE a.scr_action_id=existing_action_id
        WITH nocounter
       ;end update
      ELSE
       DELETE  FROM scr_action a
        WHERE a.scr_action_id=existing_action_id
       ;end delete
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SELECT INTO "nl:"
     nextseqnum = seq(scd_seq,nextval)"######################;rp0"
     FROM dual
     DETAIL
      scr_paragraph_type_id = cnvtreal(nextseqnum)
     WITH format, nocounter
    ;end select
    IF (curqual=0)
     SET error_line = "FAILED TO GENERATE ID TERMINATING IMPORT"
     CALL error_handling(error_line)
     GO TO exit_script
    ENDIF
    INSERT  FROM scr_paragraph_type s
     SET s.scr_paragraph_type_id = scr_paragraph_type_id, s.cki_source = requestin->list_0[x].
      cki_source, s.cki_identifier = requestin->list_0[x].cki_identifier,
      s.display = requestin->list_0[x].display, s.display_key = cnvtupper(cnvtalphanum(trim(requestin
         ->list_0[x].display))), s.description = requestin->list_0[x].description,
      s.paragraph_class_cd = paragraph_class_cd, s.text_format_rule_cd = text_format_rule_cd, s
      .canonical_pattern_id = canonical_pattern_id,
      s.sequence_number = cnvtint(trim(requestin->list_0[x].sequence_number)), s.default_cd =
      default_cd, s.active_ind = 1,
      s.active_status_cd = active_status_cd, s.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      s.active_status_prsnl_id = 0,
      s.updt_cnt = 0, s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = 0,
      s.updt_task = 0, s.updt_applctx = 0
     WITH nocounter
    ;end insert
    IF (curqual <= 0)
     SET error_line = trim(concat("ERROR >FAILED TO INSERT  : cki_source = ",trim(requestin->list_0[x
        ].cki_source),"  cki_ident = ",trim(requestin->list_0[x].cki_identifier)))
     CALL error_handling(error_line)
     SET errcode = error(errmsg,1)
     CALL error_handling(concat("  ",substring(1,126,errmsg)))
     GO TO next_item
    ENDIF
    IF (default_entry_action_type_cd > 0)
     SET stat = addaction(scr_paragraph_type_id,default_entry_action_type_cd)
    ENDIF
    IF (copy_forward_action_type_cd > 0)
     SET stat = addaction(scr_paragraph_type_id,copy_forward_action_type_cd)
    ENDIF
   ENDIF
   COMMIT
 ENDFOR
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
 SUBROUTINE scdgetcdforcdf(code_set2,cdf_meaning2)
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE c.code_set=code_set2
    AND c.cdf_meaning=cnvtupper(cdf_meaning2)
    AND c.active_ind=1
    AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   HEAD REPORT
    code_value = c.code_value
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET code_value = 0
  ENDIF
 END ;Subroutine
 SUBROUTINE addaction(paragraph_type_id,add_action_type_cd)
   SELECT INTO "nl:"
    nextseqnum = seq(scd_seq,nextval)"######################;rp0"
    FROM dual
    DETAIL
     scr_action_id = cnvtreal(nextseqnum)
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET error_line = "FAILED TO GENERATE ID TERMINATING IMPORT"
    CALL error_handling(error_line)
    GO TO exit_script
   ENDIF
   INSERT  FROM scr_action a
    SET a.scr_action_id = scr_action_id, a.scr_action_cd = add_action_type_cd, a.parent_entity_id =
     cnvtreal(paragraph_type_id),
     a.parent_entity_name = "SCR_PARAGRAPH_TYPE", a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
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
   "SCR Paragraph Type Import   end >", curtime"hh:mm:ss;;m", col + 2,
   curdate"dd-mmm-yyyy;;d"
  DETAIL
   col 0
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
END GO

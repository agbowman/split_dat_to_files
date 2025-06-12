CREATE PROGRAM dd_cda_configuration_pmt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select reference template id from DD_REF_TEMPLATE table:" = "",
  "Select CDA type code from codeset 4002926:" = 0,
  "Select eligibility type from eligible hospital(CCN) and eligible provider(EP):" = 0
  WITH outdev, ref_template_id, soc_type_cd,
  eligibile_type
 FREE RECORD requestin
 RECORD requestin(
   1 user_id = f8
   1 config_values[*]
     2 facility_cd = f8
     2 nurse_unit_cd = f8
     2 note_type_id = f8
     2 position_cd = f8
     2 soc_type_cd = f8
     2 name = vc
     2 values[*]
       3 config_value = vc
     2 del_ind = i2
 )
 DECLARE app_num = i4 WITH protect, constant(3202004)
 DECLARE task_num = i4 WITH protect, constant(3202004)
 DECLARE req_num = i4 WITH protect, constant(969598)
 DECLARE ep_ref_template = vc WITH protect, constant("eprov system ref template")
 DECLARE eh_ref_template = vc WITH protect, constant("ehosp system ref template")
 DECLARE status = c1 WITH protect, noconstant("F")
 DECLARE message = vc WITH protect, noconstant("")
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE cda_count = i4 WITH protect, noconstant(1)
 DECLARE et_count = i4 WITH protect, noconstant(1)
 DECLARE index = i4 WITH protect, noconstant(1)
 DECLARE line = c80 WITH protect, constant(fillstring(79,"-"))
 DECLARE ref_template = vc WITH protect, noconstant
 DECLARE cur_user = vc WITH protect, noconstant("")
 DECLARE t_str = vc WITH protect, noconstant("")
 DECLARE ep_ind = i2 WITH protect, noconstant(0)
 DECLARE eh_ind = i2 WITH protect, noconstant(0)
 DECLARE populate_eligible_type(multiple=i2) = none WITH protect
 DECLARE populate_cda_type(multiple=i2) = none WITH protect
 SET stat = alterlist(requestin->config_values,10)
 IF (substring(1,1,reflect(parameter(parameter2( $SOC_TYPE_CD),0)))="L")
  WHILE (reflect(parameter(parameter2( $SOC_TYPE_CD),cda_count)) > " ")
   IF (substring(1,1,reflect(parameter(parameter2( $ELIGIBILE_TYPE),0)))="L")
    SET et_count = 1
    WHILE (reflect(parameter(parameter2( $ELIGIBILE_TYPE),et_count)) > " ")
      CALL populate_cda_type(1)
      CALL populate_eligible_type(1)
      SET index = (index+ 1)
      IF (mod(index,10)=1)
       SET stat = alterlist(requestin->config_values,(index+ 9))
      ENDIF
    ENDWHILE
   ELSE
    CALL populate_cda_type(1)
    CALL populate_eligible_type(0)
    SET index = (index+ 1)
    IF (mod(index,10)=1)
     SET stat = alterlist(requestin->config_values,(index+ 9))
    ENDIF
   ENDIF
   SET cda_count = (cda_count+ 1)
  ENDWHILE
 ELSE
  IF (substring(1,1,reflect(parameter(parameter2( $ELIGIBILE_TYPE),0)))="L")
   WHILE (reflect(parameter(parameter2( $ELIGIBILE_TYPE),et_count)) > " ")
     CALL populate_cda_type(0)
     CALL populate_eligible_type(1)
     SET index = (index+ 1)
     IF (mod(index,10)=1)
      SET stat = alterlist(requestin->config_values,(index+ 9))
     ENDIF
   ENDWHILE
  ELSE
   CALL populate_cda_type(0)
   CALL populate_eligible_type(0)
   SET index = (index+ 1)
   IF (mod(index,10)=1)
    SET stat = alterlist(requestin->config_values,(index+ 9))
   ENDIF
  ENDIF
 ENDIF
 SET stat = alterlist(requestin->config_values,(index - 1))
 SET stat = tdbexecute(app_num,task_num,req_num,"REC",requestin,
  "REC",replyout)
 IF (stat != 0)
  SET status = "F"
  SET message = concat(build("Error - tdbexecute for request 969598 failed with status of: ",stat),
   error_msg)
  GO TO exit_script
 ENDIF
 SET err_code = error(error_msg,1)
 IF (err_code > 0)
  SET status = "F"
  SET message = concat("Error - Failed to insert preference:",error_msg)
  GO TO exit_script
 ELSE
  SET status = "S"
  SET message = "Success: Preferences saved successfully."
  GO TO exit_script
 ENDIF
 SUBROUTINE populate_eligible_type(multiple)
  IF (multiple=1)
   IF (cnvtint(parameter(parameter2( $ELIGIBILE_TYPE),et_count))=1)
    SET eh_ind = 1
    SET requestin->config_values[index].name = eh_ref_template
   ELSEIF (cnvtint(parameter(parameter2( $ELIGIBILE_TYPE),et_count))=2)
    SET ep_ind = 1
    SET requestin->config_values[index].name = ep_ref_template
   ELSE
    SET status = "F"
    SET message = "Eligible Type is not valid."
    GO TO exit_script
   ENDIF
  ELSE
   IF (( $ELIGIBILE_TYPE=1))
    SET eh_ind = 1
    SET requestin->config_values[index].name = eh_ref_template
   ELSEIF (( $ELIGIBILE_TYPE=2))
    SET ep_ind = 1
    SET requestin->config_values[index].name = ep_ref_template
   ELSE
    SET status = "F"
    SET message = "Eligible Type is not valid."
    GO TO exit_script
   ENDIF
  ENDIF
  SET et_count = (et_count+ 1)
 END ;Subroutine
 SUBROUTINE populate_cda_type(multiple)
   IF (multiple=1)
    SET requestin->config_values[index].soc_type_cd = cnvtreal(parameter(parameter2( $SOC_TYPE_CD),
      cda_count))
   ELSE
    SET requestin->config_values[index].soc_type_cd =  $SOC_TYPE_CD
   ENDIF
   SET stat = alterlist(requestin->config_values[index].values,1)
   SET requestin->config_values[index].values[1].config_value = cnvtstring( $REF_TEMPLATE_ID)
   IF ((((requestin->config_values[index].soc_type_cd <= 0.0)) OR (cnvtreal( $REF_TEMPLATE_ID) <= 0.0
   )) )
    SET status = "F"
    SET message = "CDA Type or Reference Template ID is not valid."
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 IF ((reqinfo->updt_id != 0.0))
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE (p.person_id=reqinfo->updt_id)
   DETAIL
    cur_user = concat(trim(p.name_first)," ",trim(p.name_last))
   WITH nocounter
  ;end select
 ELSE
  SET cur_user = trim(curuser)
 ENDIF
 IF (status="F")
  SELECT INTO  $OUTDEV
   soc_type = requestin->config_values[d.seq].soc_type_cd
   FROM (dummyt d  WITH seq = value(size(requestin->config_values,5)))
   PLAN (d
    WHERE (requestin->config_values[d.seq].soc_type_cd != 0.0))
   ORDER BY requestin->config_values[d.seq].soc_type_cd
   HEAD REPORT
    col 0, line, row + 1,
    CALL center("CDA CONFIGURATION",1,79), row + 1, col 0,
    line, row + 2, t_str = build("Date: ",format(cnvtdatetime(curdate,curtime3),
      "@SHORTDATETIMENOSEC;;q")),
    col 50, t_str, row + 1,
    t_str = build("User:",substring(1,39,cur_user)), col 50, t_str,
    row + 1, col 0, requestin->config_values[d.seq].name,
    row + 1, col 0, requestin->config_values[d.seq].soc_type_cd,
    row + 1, col 0, requestin->config_values[d.seq].values[1].config_value,
    row + 1
   FOOT REPORT
    row + 1, col 0, "PREFERENCES COULD NOT BE SAVED",
    row + 2, col 0, message,
    row + 1, row + 1, col 0,
    line
   WITH maxrec = 100, maxcol = 300, maxrow = 500,
    dio = 08, noheading, format = pcformat
  ;end select
 ELSE
  SELECT INTO "nl:"
   d.title_txt
   FROM dd_ref_template d
   WHERE d.dd_ref_template_id=cnvtreal( $REF_TEMPLATE_ID)
   DETAIL
    ref_template = substring(1,70,d.title_txt)
   WITH nocounter
  ;end select
  SELECT INTO  $OUTDEV
   soc_type = requestin->config_values[d.seq].soc_type_cd
   FROM (dummyt d  WITH seq = value(size(requestin->config_values,5)))
   PLAN (d
    WHERE (requestin->config_values[d.seq].soc_type_cd != 0.0))
   ORDER BY requestin->config_values[d.seq].soc_type_cd
   HEAD REPORT
    col 0, line, row + 1,
    CALL center("CDA CONFIGURATION",1,79), row + 1, col 0,
    line, row + 2, t_str = build("Date: ",format(cnvtdatetime(curdate,curtime3),
      "@SHORTDATETIMENOSEC;;q")),
    col 50, t_str, row + 1,
    t_str = build("User:",substring(1,39,cur_user)), col 50, t_str,
    row + 2, col 0, "PREFERENCES SAVED SUCCESSFULLY",
    row + 3, col 0, "Context: summary of care type",
    row + 1, col 0, "Section: physician documentation",
    row + 1
   HEAD PAGE
    row + 1, col 0, "CDA Type(s):"
   HEAD soc_type
    t_str = uar_get_code_display(requestin->config_values[d.seq].soc_type_cd), col 15, t_str,
    row + 1
   FOOT REPORT
    row + 1, col 0, "Eligibility Type:"
    IF (eh_ind=1)
     col 18, "Eligible Hospital", row + 1
    ENDIF
    IF (ep_ind=1)
     col 18, "Eligible Provider", row + 1
    ENDIF
    row + 1, col 0, "Reference Template:",
    col 20, ref_template, row + 2,
    col 0, line
   WITH maxrec = 100, maxcol = 300, maxrow = 500,
    dio = 08, noheading, format = pcformat
  ;end select
 ENDIF
END GO

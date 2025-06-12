CREATE PROGRAM bed_imp_correspondence_rules:dba
 FREE SET temp
 RECORD temp(
   1 flex_num = i4
   1 flex[*]
     2 sch_flex_id = i4
     2 sequence = i4
     2 mnemonic = vc
     2 description = vc
     2 error_string = vc
     2 action_flag = i2
     2 row = i4
     2 encounter_facility_cnt = i4
     2 pt_deceased_ind_cnt = i2
     2 encounter_type_cnt = i4
     2 pt_age_cnt = i4
     2 scheduling_action_cnt = i4
     2 waitlist_reason_cnt = i4
     2 post_document_cnt = i4
     2 waitlist_priority_cnt = i4
     2 waitlist_status_code_cnt = i4
     2 admit_booking_code_cnt = i4
     2 medical_service_cnt = i4
     2 not_medical_service_cnt = i4
     2 appt_type_cnt = i4
     2 not_appt_type_cnt = i4
     2 scheduling_reason_cnt = i4
     2 encounter_facility[*]
       3 factiliy_disp = vc
       3 facility_cd = f8
       3 error_string = vc
       3 row = i4
     2 pt_deceased[*]
       3 pt_deceased = vc
       3 pt_deceased_ind = i2
       3 error_string = vc
       3 row = i4
     2 encounter_type[*]
       3 encounter_type = vc
       3 encounter_type_cd = f8
       3 encounter_type_mean = vc
       3 error_string = vc
       3 row = i4
     2 medical_service[*]
       3 medical_service = vc
       3 medical_service_cd = f8
       3 medical_service_mean = vc
       3 error_string = vc
       3 row = i4
     2 not_medical_service[*]
       3 medical_service = vc
       3 medical_service_cd = f8
       3 medical_service_mean = vc
       3 error_string = vc
       3 row = i4
     2 appt_type[*]
       3 appt_type = vc
       3 appt_type_parent_cd = f8
       3 appt_type_display_cd = f8
       3 error_string = vc
       3 row = i4
     2 not_appt_type[*]
       3 appt_type = vc
       3 appt_type_parent_cd = f8
       3 appt_type_display_cd = f8
       3 error_string = vc
       3 row = i4
     2 pt_age[*]
       3 operand = vc
       3 operand_cd = f8
       3 operand_mean = vc
       3 pt_age = vc
       3 offset = vc
       3 offset_cd = f8
       3 offset_mean = vc
       3 error_string = vc
       3 row = i4
     2 scheduling_action[*]
       3 scheduling_action = vc
       3 scheduling_action_cd = f8
       3 scheduling_action_mean = vc
       3 error_string = vc
       3 row = i4
     2 waitlist_reason[*]
       3 waitlist_reason = vc
       3 waitlist_reason_cd = f8
       3 waitlist_reason_mean = vc
       3 error_string = vc
       3 row = i4
     2 scheduling_reason[*]
       3 scheduling_reason = vc
       3 scheduling_reason_cd = f8
       3 scheduling_reason_mean = vc
       3 error_string = vc
       3 row = i4
     2 post_document[*]
       3 post_document_name = vc
       3 post_document_ind = i2
       3 post_document_cd = f8
       3 error_string = vc
       3 row = i4
     2 waitlist_priority[*]
       3 waitlist_priority = vc
       3 waitlist_priority_cd = f8
       3 waitlist_priority_mean = vc
       3 error_string = vc
       3 row = i4
     2 waitlist_status_code[*]
       3 waitlist_status_code = vc
       3 waitlist_status_code_cd = f8
       3 waitlist_status_code_mean = vc
       3 error_string = vc
       3 row = i4
     2 admit_booking_code[*]
       3 admit_booking_code = vc
       3 admit_booking_code_cd = f8
       3 admit_booking_code_mean = vc
       3 error_string = vc
       3 row = i4
 )
 FREE SET str_data
 RECORD str_data(
   1 str_qual = c1
 )
 FREE SET request
 RECORD request(
   1 call_echo_ind = i2
   1 num = i4
   1 qual[*]
     2 sch_flex_id = f8
 )
 SET request->call_echo_ind = 0
 DECLARE error_msg = vc
 DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE end_dt_tm = dq8 WITH constant(cnvtdatetime("31-dec-2100 00:00:00"))
 SET write_mode = 0
 IF ((tempreq->insert_ind="Y"))
  SET write_mode = 1
 ENDIF
 SET active_cd = get_code_value(48,"ACTIVE")
 SET flex_type_cd = get_code_value(16162,"ERMPOSTDOC")
 SET flex_orient_cd = get_code_value(16163,"INFIX")
 SET lparan_token_cd = get_code_value(16160,"LPARAN")
 SET rparan_token_cd = get_code_value(16160,"RPARAN")
 SET equal_token_cd = get_code_value(16160,"EQUAL")
 SET notequal_token_cd = get_code_value(16160,"NOTEQUAL")
 SET t_encntrfac_cd = get_code_value(16160,"T_ENCNTRFAC")
 SET d_encntrfac_cd = get_code_value(16160,"D_ENCNTRFAC")
 SET t_enctype_cd = get_code_value(16160,"T_ENCTYPE")
 SET d_enctype_cd = get_code_value(16160,"D_ENCTYPE")
 SET t_ptagemin_cd = get_code_value(16160,"T_PTAGEMIN")
 SET t_schaction_cd = get_code_value(16160,"T_SCHACTION")
 SET d_schaction_cd = get_code_value(16160,"D_SCHACTION")
 SET t_wlreasnchg_cd = get_code_value(16160,"T_WLREASNCHG")
 SET d_wlreasnchg_cd = get_code_value(16160,"D_WLREASNCHG")
 SET d_schreason_cd = get_code_value(16160,"D_SCHREASON")
 SET t_schreason_cd = get_code_value(16160,"T_SCHREASON")
 SET t_medsvc_cd = get_code_value(16160,"T_MEDSVC")
 SET d_medsvc_cd = get_code_value(16160,"D_MEDSVC")
 SET t_appttype_cd = get_code_value(16160,"T_APPTTYPE")
 SET d_appttype_cd = get_code_value(16160,"D_APPTTYPE")
 SET t_postdocind_cd = get_code_value(16160,"T_POSTDOCIND")
 SET t_priority_cd = get_code_value(16160,"T_PRIORITY")
 SET d_priority_cd = get_code_value(16160,"D_PRIORITY")
 SET t_perdead_cd = get_code_value(16160,"T_PERDEAD")
 SET l_dateoff_cd = get_code_value(16160,"L_DATEOFF")
 SET t_waitlsstcd_cd = get_code_value(16160,"T_WAITLSSTCD")
 SET d_waitlsstcd_cd = get_code_value(16160,"D_WAITLSSTCD")
 SET t_admitbkcd_cd = get_code_value(16160,"T_ADMITBKCD")
 SET d_admitbkcd_cd = get_code_value(16160,"D_ADMITBKCD")
 SET or_token_cd = get_code_value(16160,"OR")
 SET and_token_cd = get_code_value(16160,"AND")
 SET l_true_token_cd = get_code_value(16160,"L_TRUE")
 SET l_false_token_cd = get_code_value(16160,"L_FALSE")
 SET operator_type_cd = get_code_value(16161,"OPERATOR")
 SET operand_type_cd = get_code_value(16161,"OPERAND")
 SET datasource_type_cd = get_code_value(16161,"DATASOURCE")
 SET double_type_cd = get_code_value(16131,"DOUBLE")
 SET date_type_cd = get_code_value(16131,"DATE")
 SET hardcoded_cd = get_code_value(16164,"HARDCODED")
 SET codevalue_cd = get_code_value(16149,"CODEVALUE")
 SET wlreasnchg_data_cd = get_code_value(16149,"WLREASNCHG")
 SET literal_type_cd = get_code_value(16161,"LITERAL")
 SET literal_eval_cd = get_code_value(16164,"LITERAL")
 SET units_eval_cd = get_code_value(16164,"UNITS")
 SET age_eval_cd = get_code_value(16164,"AGE")
 SET datasource_eval_cd = get_code_value(16164,"DATASOURCE")
 SET facility_data_source_cd = get_code_value(16149,"FACILITY")
 SET schaction_data_source_cd = get_code_value(16149,"SCHACTION")
 SET schreason_data_cd = get_code_value(16149,"SCHREASON")
 SET waitlsstcd_data_cd = get_code_value(16149,"WAITLSSTCD")
 SET admitbkcd_data_cd = get_code_value(16149,"ADMITBKCD")
 SET appt_type_ds_cd = get_code_value(16149,"APPTTYPE")
 SET numrows = size(requestin->list_0,5)
 IF (numrows=0)
  SET error_msg = "No rows to process"
  GO TO exit_script
 ENDIF
 IF (flex_type_cd=0)
  SET error_msg = "Flex type of: ERM Post Document Type not defined!"
  GO TO exit_script
 ENDIF
 SET title = validate(log_title_set,"Correspondence Flex Rule Upload Log")
 SET name = validate(log_name_set,"bed_correspondence_rules.log")
 SET status = validate(log_col_set,"STATUS")
 SET alt_mode = validate(alt_mode_set,0)
 SET alt_detail = validate(alt_detail_set,0)
 CALL logstart(title,name)
 FOR (i = 1 TO numrows)
   SET rec = 0
   FOR (ii = 1 TO temp->flex_num)
     IF (cnvtupper(temp->flex[ii].mnemonic)=cnvtupper(requestin->list_0[i].mnemonic))
      SET rec = ii
     ENDIF
   ENDFOR
   IF (rec=0)
    SET temp->flex_num = (temp->flex_num+ 1)
    SET stat = alterlist(temp->flex,temp->flex_num)
    SET rec = temp->flex_num
    SET temp->flex[rec].row = i
    SET temp->flex[rec].mnemonic = requestin->list_0[i].mnemonic
    SET temp->flex[rec].description = requestin->list_0[i].description
    SELECT INTO "NL:"
     FROM sch_flex_string s
     WHERE cnvtupper(s.mnemonic)=cnvtupper(temp->flex[rec].mnemonic)
      AND s.active_ind=1
      AND s.flex_type_cd=flex_type_cd
     DETAIL
      temp->flex[rec].sch_flex_id = s.sch_flex_id, request->num = (request->num+ 1), stat = alterlist
      (request->qual,request->num),
      request->qual[request->num].sch_flex_id = s.sch_flex_id
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET error_string = "Flex Rule exists. Overwriting"
     SET temp->flex[rec].action_flag = 2
    ELSE
     SET temp->flex[rec].action_flag = 1
    ENDIF
    IF ((requestin->list_0[i].mnemonic=" "))
     SET error_string = "Flex Rule is null!"
     SET action_flag = 0
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].encounter_facility_disp > " "))
    SET temp->flex[rec].encounter_facility_cnt = (temp->flex[rec].encounter_facility_cnt+ 1)
    SET stat = alterlist(temp->flex[rec].encounter_facility,temp->flex[rec].encounter_facility_cnt)
    SET temp->flex[rec].encounter_facility[temp->flex[rec].encounter_facility_cnt].factiliy_disp =
    requestin->list_0[i].encounter_facility_disp
    SET temp->flex[rec].encounter_facility[temp->flex[rec].encounter_facility_cnt].row = i
    SELECT INTO "NL:"
     FROM code_value c
     WHERE c.code_set=220
      AND c.cdf_meaning="FACILITY"
      AND cnvtupper(c.display)=cnvtupper(requestin->list_0[i].encounter_facility_disp)
     DETAIL
      temp->flex[rec].encounter_facility[temp->flex[rec].encounter_facility_cnt].facility_cd = c
      .code_value, temp->flex[rec].encounter_facility[temp->flex[rec].encounter_facility_cnt].
      factiliy_disp = c.display
     WITH nocounter
    ;end select
    IF ((temp->flex[rec].encounter_facility[temp->flex[rec].encounter_facility_cnt].facility_cd=0))
     SET temp->flex[rec].encounter_facility[temp->flex[rec].encounter_facility_cnt].error_string =
     "Invalid display from CS 220"
     SET temp->flex[rec].action_flag = 0
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].pt_deceased_ind > " "))
    SET temp->flex[rec].pt_deceased_ind_cnt = (temp->flex[rec].pt_deceased_ind_cnt+ 1)
    SET stat = alterlist(temp->flex[rec].pt_deceased,temp->flex[rec].pt_deceased_ind_cnt)
    SET temp->flex[rec].pt_deceased[temp->flex[rec].pt_deceased_ind_cnt].row = i
    SET temp->flex[rec].pt_deceased[temp->flex[rec].pt_deceased_ind_cnt].pt_deceased = requestin->
    list_0[i].pt_deceased_ind
    IF ((temp->flex[rec].pt_deceased_ind_cnt > 1))
     SET temp->flex[rec].pt_deceased[temp->flex[rec].pt_deceased_ind_cnt].error_string =
     "Already Defined"
    ELSE
     IF (cnvtupper(requestin->list_0[i].pt_deceased_ind)="TRUE")
      SET temp->flex[rec].pt_deceased[temp->flex[rec].pt_deceased_ind_cnt].pt_deceased_ind = 1
     ELSE
      SET temp->flex[rec].pt_deceased[temp->flex[rec].pt_deceased_ind_cnt].pt_deceased_ind = 0
     ENDIF
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].encounter_type > " "))
    SET temp->flex[rec].encounter_type_cnt = (temp->flex[rec].encounter_type_cnt+ 1)
    SET stat = alterlist(temp->flex[rec].encounter_type,temp->flex[rec].encounter_type_cnt)
    SET temp->flex[rec].encounter_type[temp->flex[rec].encounter_type_cnt].encounter_type = requestin
    ->list_0[i].encounter_type
    SET temp->flex[rec].encounter_type[temp->flex[rec].encounter_type_cnt].row = i
    SELECT INTO "NL:"
     FROM code_value c
     WHERE c.code_set=71
      AND c.active_ind=1
      AND cnvtupper(c.display)=cnvtupper(requestin->list_0[i].encounter_type)
     DETAIL
      temp->flex[rec].encounter_type[temp->flex[rec].encounter_type_cnt].encounter_type_cd = c
      .code_value, temp->flex[rec].encounter_type[temp->flex[rec].encounter_type_cnt].encounter_type
       = c.display, temp->flex[rec].encounter_type[temp->flex[rec].encounter_type_cnt].
      encounter_type_mean = c.cdf_meaning
     WITH nocounter
    ;end select
    IF ((temp->flex[rec].encounter_type[temp->flex[rec].encounter_type_cnt].encounter_type_cd=0))
     SET temp->flex[rec].encounter_type[temp->flex[rec].encounter_type_cnt].error_string =
     "Invalid display from CS 71"
     SET temp->flex[rec].action_flag = 0
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].medical_service > " "))
    SET temp->flex[rec].medical_service_cnt = (temp->flex[rec].medical_service_cnt+ 1)
    SET stat = alterlist(temp->flex[rec].medical_service,temp->flex[rec].medical_service_cnt)
    SET temp->flex[rec].medical_service[temp->flex[rec].medical_service_cnt].medical_service =
    requestin->list_0[i].medical_service
    SET temp->flex[rec].medical_service[temp->flex[rec].medical_service_cnt].row = i
    SELECT INTO "NL:"
     FROM code_value c
     WHERE c.code_set=34
      AND c.active_ind=1
      AND cnvtupper(c.display)=cnvtupper(requestin->list_0[i].medical_service)
     DETAIL
      temp->flex[rec].medical_service[temp->flex[rec].medical_service_cnt].medical_service_cd = c
      .code_value, temp->flex[rec].medical_service[temp->flex[rec].medical_service_cnt].
      medical_service = c.display, temp->flex[rec].medical_service[temp->flex[rec].
      medical_service_cnt].medical_service_mean = c.cdf_meaning
     WITH nocounter
    ;end select
    IF ((temp->flex[rec].medical_service[temp->flex[rec].medical_service_cnt].medical_service_cd=0))
     SET temp->flex[rec].medical_service[temp->flex[rec].medical_service_cnt].error_string =
     "Invalid display from CS 34"
     SET temp->flex[rec].action_flag = 0
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].not_medical_service > " "))
    SET temp->flex[rec].not_medical_service_cnt = (temp->flex[rec].not_medical_service_cnt+ 1)
    SET stat = alterlist(temp->flex[rec].not_medical_service,temp->flex[rec].not_medical_service_cnt)
    SET temp->flex[rec].not_medical_service[temp->flex[rec].not_medical_service_cnt].medical_service
     = requestin->list_0[i].not_medical_service
    SET temp->flex[rec].not_medical_service[temp->flex[rec].not_medical_service_cnt].row = i
    SELECT INTO "NL:"
     FROM code_value c
     WHERE c.code_set=34
      AND c.active_ind=1
      AND cnvtupper(c.display)=cnvtupper(requestin->list_0[i].not_medical_service)
     DETAIL
      temp->flex[rec].not_medical_service[temp->flex[rec].not_medical_service_cnt].medical_service_cd
       = c.code_value, temp->flex[rec].not_medical_service[temp->flex[rec].not_medical_service_cnt].
      medical_service = c.display, temp->flex[rec].not_medical_service[temp->flex[rec].
      not_medical_service_cnt].medical_service_mean = c.cdf_meaning
     WITH nocounter
    ;end select
    IF ((temp->flex[rec].not_medical_service[temp->flex[rec].not_medical_service_cnt].
    medical_service_cd=0))
     SET temp->flex[rec].not_medical_service[temp->flex[rec].not_medical_service_cnt].error_string =
     "Invalid display from CS 34"
     SET temp->flex[rec].action_flag = 0
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].appt_type > " "))
    SET temp->flex[rec].appt_type_cnt = (temp->flex[rec].appt_type_cnt+ 1)
    SET stat = alterlist(temp->flex[rec].appt_type,temp->flex[rec].appt_type_cnt)
    SET temp->flex[rec].appt_type[temp->flex[rec].appt_type_cnt].appt_type = requestin->list_0[i].
    appt_type
    SET temp->flex[rec].appt_type[temp->flex[rec].appt_type].row = i
    SELECT INTO "NL:"
     FROM code_value c
     WHERE c.code_set=14230
      AND c.active_ind=1
      AND cnvtupper(c.display)=cnvtupper(requestin->list_0[i].appt_type)
     DETAIL
      temp->flex[rec].appt_type[temp->flex[rec].appt_type_cnt].appt_type_parent_cd = c.code_value,
      temp->flex[rec].appt_type[temp->flex[rec].appt_type_cnt].appt_type = c.display
     WITH nocounter
    ;end select
    IF ((temp->flex[rec].appt_type[temp->flex[rec].appt_type_cnt].appt_type_parent_cd=0))
     SET temp->flex[rec].appt_type[temp->flex[rec].appt_type_cnt].error_string =
     "Invalid display from CS 14230"
     SET temp->flex[rec].action_flag = 0
    ENDIF
    SELECT INTO "NL:"
     FROM code_value c
     WHERE c.code_set=14249
      AND c.active_ind=1
      AND cnvtupper(c.display)=cnvtupper(requestin->list_0[i].appt_type)
     DETAIL
      temp->flex[rec].appt_type[temp->flex[rec].appt_type_cnt].appt_type_display_cd = c.code_value
     WITH nocounter
    ;end select
    IF ((temp->flex[rec].appt_type[temp->flex[rec].appt_type_cnt].appt_type_display_cd=0))
     SET temp->flex[rec].appt_type[temp->flex[rec].appt_type_cnt].error_string =
     "Invalid display from CS 14249"
     SET temp->flex[rec].action_flag = 0
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].not_appt_type > " "))
    SET temp->flex[rec].not_appt_type_cnt = (temp->flex[rec].not_appt_type_cnt+ 1)
    SET stat = alterlist(temp->flex[rec].not_appt_type,temp->flex[rec].not_appt_type_cnt)
    SET temp->flex[rec].not_appt_type[temp->flex[rec].not_appt_type_cnt].appt_type = requestin->
    list_0[i].not_appt_type
    SET temp->flex[rec].not_appt_type[temp->flex[rec].not_appt_type_cnt].row = i
    SELECT INTO "NL:"
     FROM code_value c
     WHERE c.code_set=14230
      AND c.active_ind=1
      AND cnvtupper(c.display)=cnvtupper(requestin->list_0[i].not_appt_type)
     DETAIL
      temp->flex[rec].not_appt_type[temp->flex[rec].not_appt_type_cnt].appt_type_parent_cd = c
      .code_value, temp->flex[rec].not_appt_type[temp->flex[rec].not_appt_type_cnt].appt_type = c
      .display
     WITH nocounter
    ;end select
    IF ((temp->flex[rec].not_appt_type[temp->flex[rec].not_appt_type_cnt].appt_type_parent_cd=0))
     SET temp->flex[rec].not_appt_type[temp->flex[rec].not_appt_type_cnt].error_string =
     "Invalid display from CS 14230"
     SET temp->flex[rec].action_flag = 0
    ENDIF
    SELECT INTO "NL:"
     FROM code_value c
     WHERE c.code_set=14249
      AND c.active_ind=1
      AND cnvtupper(c.display)=cnvtupper(requestin->list_0[i].not_appt_type)
     DETAIL
      temp->flex[rec].not_appt_type[temp->flex[rec].not_appt_type_cnt].appt_type_display_cd = c
      .code_value
     WITH nocounter
    ;end select
    IF ((temp->flex[rec].not_appt_type[temp->flex[rec].appt_type_cnt].appt_type_display_cd=0))
     SET temp->flex[rec].not_appt_type[temp->flex[rec].appt_type_cnt].error_string =
     "Invalid display from CS 14249"
     SET temp->flex[rec].action_flag = 0
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].pt_age > " "))
    SET temp->flex[rec].pt_age_cnt = (temp->flex[rec].pt_age_cnt+ 1)
    SET stat = alterlist(temp->flex[rec].pt_age,temp->flex[rec].pt_age_cnt)
    SET temp->flex[rec].pt_age[temp->flex[rec].pt_age_cnt].offset = requestin->list_0[i].
    pt_age_offset
    SET temp->flex[rec].pt_age[temp->flex[rec].pt_age_cnt].operand = requestin->list_0[i].
    pt_age_operand
    SET temp->flex[rec].pt_age[temp->flex[rec].pt_age_cnt].pt_age = requestin->list_0[i].pt_age
    SET temp->flex[rec].pt_age[temp->flex[rec].pt_age_cnt].row = i
    SELECT INTO "NL:"
     FROM code_value c
     WHERE c.code_set=16160
      AND c.active_ind=1
      AND (c.display=requestin->list_0[i].pt_age_operand)
     DETAIL
      temp->flex[rec].pt_age[temp->flex[rec].pt_age_cnt].operand_cd = c.code_value, temp->flex[rec].
      pt_age[temp->flex[rec].pt_age_cnt].operand_mean = c.cdf_meaning
     WITH nocounter
    ;end select
    IF ((temp->flex[rec].pt_age[temp->flex[rec].pt_age_cnt].operand_cd=0))
     SET temp->flex[rec].pt_age[temp->flex[rec].pt_age_cnt].error_string =
     "Invalid display from CS 16160"
     SET temp->flex[rec].action_flag = 0
    ENDIF
    SELECT INTO "NL:"
     FROM code_value c
     WHERE c.code_set=54
      AND c.active_ind=1
      AND c.cdf_meaning IN ("WEEKS", "DAYS", "MINUTES", "HOURS")
      AND cnvtupper(c.display)=cnvtupper(requestin->list_0[i].pt_age_offset)
     DETAIL
      temp->flex[rec].pt_age[temp->flex[rec].pt_age_cnt].offset = c.display, temp->flex[rec].pt_age[
      temp->flex[rec].pt_age_cnt].offset_cd = c.code_value, temp->flex[rec].pt_age[temp->flex[rec].
      pt_age_cnt].offset_mean = c.cdf_meaning
     WITH nocounter
    ;end select
    IF ((temp->flex[rec].pt_age[temp->flex[rec].pt_age_cnt].offset_cd=0))
     SET temp->flex[rec].pt_age[temp->flex[rec].pt_age_cnt].error_string =
     "Invalid display from CS 54"
     SET temp->flex[rec].action_flag = 0
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].scheduling_action > " "))
    SET temp->flex[rec].scheduling_action_cnt = (temp->flex[rec].scheduling_action_cnt+ 1)
    SET stat = alterlist(temp->flex[rec].scheduling_action,temp->flex[rec].scheduling_action_cnt)
    SET temp->flex[rec].scheduling_action[temp->flex[rec].scheduling_action_cnt].scheduling_action =
    requestin->list_0[i].scheduling_action
    SET temp->flex[rec].scheduling_action[temp->flex[rec].scheduling_action_cnt].row = i
    SELECT INTO "NL:"
     FROM code_value c
     WHERE c.code_set=14232
      AND c.active_ind=1
      AND cnvtupper(c.display)=cnvtupper(requestin->list_0[i].scheduling_action)
     DETAIL
      temp->flex[rec].scheduling_action[temp->flex[rec].scheduling_action_cnt].scheduling_action = c
      .display, temp->flex[rec].scheduling_action[temp->flex[rec].scheduling_action_cnt].
      scheduling_action_cd = c.code_value, temp->flex[rec].scheduling_action[temp->flex[rec].
      scheduling_action_cnt].scheduling_action_mean = c.cdf_meaning
     WITH nocounter
    ;end select
    IF ((temp->flex[rec].scheduling_action[temp->flex[rec].scheduling_action_cnt].
    scheduling_action_cd=0))
     SET temp->flex[rec].scheduling_action[temp->flex[rec].scheduling_action_cnt].error_string =
     "Invalid display from CS 14232"
     SET temp->flex[rec].action_flag = 0
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].waitlist_reason_for_change > " "))
    SET temp->flex[rec].waitlist_reason_cnt = (temp->flex[rec].waitlist_reason_cnt+ 1)
    SET stat = alterlist(temp->flex[rec].waitlist_reason,temp->flex[rec].waitlist_reason_cnt)
    SET temp->flex[rec].waitlist_reason[temp->flex[rec].waitlist_reason_cnt].waitlist_reason =
    requestin->list_0[i].waitlist_reason_for_change
    SET temp->flex[rec].waitlist_reason[temp->flex[rec].waitlist_reason_cnt].row = i
    SELECT INTO "NL:"
     FROM code_value c
     WHERE c.code_set=14774
      AND c.active_ind=1
      AND cnvtupper(c.display)=cnvtupper(requestin->list_0[i].waitlist_reason_for_change)
     DETAIL
      temp->flex[rec].waitlist_reason[temp->flex[rec].waitlist_reason_cnt].waitlist_reason = c
      .display, temp->flex[rec].waitlist_reason[temp->flex[rec].waitlist_reason_cnt].
      waitlist_reason_cd = c.code_value, temp->flex[rec].waitlist_reason[temp->flex[rec].
      waitlist_reason_cnt].waitlist_reason_mean = c.cdf_meaning
     WITH nocounter
    ;end select
    IF ((temp->flex[rec].waitlist_reason[temp->flex[rec].waitlist_reason_cnt].waitlist_reason_cd=0))
     SET temp->flex[rec].waitlist_reason[temp->flex[rec].waitlist_reason_cnt].error_string =
     "Invalid display from CS 14774"
     SET temp->flex[rec].action_flag = 0
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].scheduling_reason_for_change > " "))
    SET temp->flex[rec].scheduling_reason_cnt = (temp->flex[rec].scheduling_reason_cnt+ 1)
    SET stat = alterlist(temp->flex[rec].scheduling_reason,temp->flex[rec].scheduling_reason_cnt)
    SET temp->flex[rec].scheduling_reason[temp->flex[rec].scheduling_reason_cnt].scheduling_reason =
    requestin->list_0[i].scheduling_reason_for_change
    SET temp->flex[rec].scheduling_reason[temp->flex[rec].scheduling_reason_cnt].row = i
    SELECT INTO "NL:"
     FROM code_value c
     WHERE c.code_set=14229
      AND c.active_ind=1
      AND cnvtupper(c.display)=cnvtupper(requestin->list_0[i].scheduling_reason_for_change)
     DETAIL
      temp->flex[rec].scheduling_reason[temp->flex[rec].scheduling_reason_cnt].scheduling_reason = c
      .display, temp->flex[rec].scheduling_reason[temp->flex[rec].scheduling_reason_cnt].
      scheduling_reason_cd = c.code_value, temp->flex[rec].scheduling_reason[temp->flex[rec].
      scheduling_reason_cnt].scheduling_reason_mean = c.cdf_meaning
     WITH nocounter
    ;end select
    IF ((temp->flex[rec].scheduling_reason[temp->flex[rec].scheduling_reason_cnt].
    scheduling_reason_cd=0))
     SET temp->flex[rec].scheduling_reason[temp->flex[rec].scheduling_reason_cnt].error_string =
     "Invalid display from CS 14229"
     SET temp->flex[rec].action_flag = 0
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].post_document_name > " "))
    SET temp->flex[rec].post_document_cnt = (temp->flex[rec].post_document_cnt+ 1)
    SET stat = alterlist(temp->flex[rec].post_document,temp->flex[rec].post_document_cnt)
    SET temp->flex[rec].post_document[temp->flex[rec].post_document_cnt].post_document_name =
    requestin->list_0[i].post_document_name
    SET temp->flex[rec].post_document[temp->flex[rec].post_document_cnt].row = i
    SELECT INTO "NL:"
     FROM code_value c
     WHERE c.code_set=4000422
      AND c.active_ind=1
      AND cnvtupper(c.display)=cnvtupper(requestin->list_0[i].post_document_name)
     DETAIL
      temp->flex[rec].post_document[temp->flex[rec].post_document_cnt].post_document_name = build(c
       .display," Indicator"), temp->flex[rec].post_document[temp->flex[rec].post_document_cnt].
      post_document_cd = c.code_value
     WITH nocounter
    ;end select
    IF ((temp->flex[rec].post_document[temp->flex[rec].post_document_cnt].post_document_cd=0))
     SET temp->flex[rec].post_document[temp->flex[rec].post_document_cnt].error_string =
     "Invalid display from CS 4000422"
     SET temp->flex[rec].action_flag = 0
    ENDIF
    IF ((requestin->list_0[i].post_document_ind="TRUE"))
     SET temp->flex[rec].post_document[temp->flex[rec].post_document_cnt].post_document_ind = 1
    ELSE
     SET temp->flex[rec].post_document[temp->flex[rec].post_document_cnt].post_document_ind = 0
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].waitlist_priority > " "))
    SET temp->flex[rec].waitlist_priority_cnt = (temp->flex[rec].waitlist_priority_cnt+ 1)
    SET stat = alterlist(temp->flex[rec].waitlist_priority,temp->flex[rec].waitlist_priority_cnt)
    SET temp->flex[rec].waitlist_priority[temp->flex[rec].waitlist_priority_cnt].waitlist_priority =
    requestin->list_0[i].waitlist_priority
    SET temp->flex[rec].waitlist_priority[temp->flex[rec].waitlist_priority_cnt].row = i
    SELECT INTO "NL:"
     FROM code_value c
     WHERE c.code_set=14776
      AND c.active_ind=1
      AND cnvtupper(c.display)=cnvtupper(requestin->list_0[i].waitlist_priority)
     DETAIL
      temp->flex[rec].waitlist_priority[temp->flex[rec].waitlist_priority_cnt].waitlist_priority = c
      .display, temp->flex[rec].waitlist_priority[temp->flex[rec].waitlist_priority_cnt].
      waitlist_priority_cd = c.code_value, temp->flex[rec].waitlist_priority[temp->flex[rec].
      waitlist_priority_cnt].waitlist_priority_mean = c.cdf_meaning
     WITH nocounter
    ;end select
    IF ((temp->flex[rec].waitlist_priority[temp->flex[rec].waitlist_priority_cnt].
    waitlist_priority_cd=0))
     SET temp->flex[rec].waitlist_priority[temp->flex[rec].waitlist_priority_cnt].error_string =
     "Invalid display from CS 14776"
     SET temp->flex[rec].action_flag = 0
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].waitlist_status_code > " "))
    SET temp->flex[rec].waitlist_status_code_cnt = (temp->flex[rec].waitlist_status_code_cnt+ 1)
    SET stat = alterlist(temp->flex[rec].waitlist_status_code,temp->flex[rec].
     waitlist_status_code_cnt)
    SET temp->flex[rec].waitlist_status_code[temp->flex[rec].waitlist_status_code_cnt].
    waitlist_status_code = requestin->list_0[i].waitlist_status_code
    SET temp->flex[rec].waitlist_status_code[temp->flex[rec].waitlist_status_code_cnt].row = i
    SELECT INTO "NL:"
     FROM code_value c
     WHERE c.code_set=14778
      AND c.active_ind=1
      AND cnvtupper(c.display)=cnvtupper(requestin->list_0[i].waitlist_status_code)
     DETAIL
      temp->flex[rec].waitlist_status_code[temp->flex[rec].waitlist_status_code_cnt].
      waitlist_status_code = c.display, temp->flex[rec].waitlist_status_code[temp->flex[rec].
      waitlist_status_code_cnt].waitlist_status_code_cd = c.code_value, temp->flex[rec].
      waitlist_status_code[temp->flex[rec].waitlist_status_code_cnt].waitlist_status_code_mean = c
      .cdf_meaning
     WITH nocounter
    ;end select
    IF ((temp->flex[rec].waitlist_status_code[temp->flex[rec].waitlist_status_code_cnt].
    waitlist_status_code_cd=0))
     SET temp->flex[rec].waitlist_status_code[temp->flex[rec].waitlist_status_code_cnt].error_string
      = "Invalid display from CS 14778"
     SET temp->flex[rec].action_flag = 0
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].admit_booking_code > " "))
    SET temp->flex[rec].admit_booking_code_cnt = (temp->flex[rec].admit_booking_code_cnt+ 1)
    SET stat = alterlist(temp->flex[rec].admit_booking_code,temp->flex[rec].admit_booking_code_cnt)
    SET temp->flex[rec].admit_booking_code[temp->flex[rec].admit_booking_code_cnt].admit_booking_code
     = requestin->list_0[i].admit_booking_code
    SET temp->flex[rec].admit_booking_code[temp->flex[rec].admit_booking_code_cnt].row = i
    SELECT INTO "NL:"
     FROM code_value c
     WHERE c.code_set=30381
      AND c.active_ind=1
      AND cnvtupper(c.display)=cnvtupper(requestin->list_0[i].admit_booking_code)
     DETAIL
      temp->flex[rec].admit_booking_code[temp->flex[rec].admit_booking_code_cnt].admit_booking_code
       = c.display, temp->flex[rec].admit_booking_code[temp->flex[rec].admit_booking_code_cnt].
      admit_booking_code_cd = c.code_value, temp->flex[rec].admit_booking_code[temp->flex[rec].
      admit_booking_code_cnt].admit_booking_code_mean = c.cdf_meaning
     WITH nocounter
    ;end select
    IF ((temp->flex[rec].admit_booking_code[temp->flex[rec].admit_booking_code_cnt].
    admit_booking_code_cd=0))
     SET temp->flex[rec].admit_booking_code[temp->flex[rec].admit_booking_code_cnt].error_string =
     "Invalid display from CS 30381"
     SET temp->flex[rec].action_flag = 0
    ENDIF
   ENDIF
 ENDFOR
 CALL echo(temp->flex_num)
 IF (write_mode=1)
  FOR (i = 1 TO temp->flex_num)
    IF ((temp->flex[i].action_flag=1))
     SET request->num = (request->num+ 1)
     SET stat = alterlist(request->qual,request->num)
     SELECT INTO "NL:"
      nextseqnum = seq(sch_flex_seq,nextval)"##################;RP0"
      FROM dual
      DETAIL
       temp->flex[i].sch_flex_id = nextseqnum, request->qual[request->num].sch_flex_id = nextseqnum
      WITH nocounter, format
     ;end select
    ENDIF
  ENDFOR
  IF ((request->num > 0))
   INSERT  FROM sch_flex_string s,
     (dummyt d  WITH seq = temp->flex_num)
    SET s.seq = 1, s.sch_flex_id = temp->flex[d.seq].sch_flex_id, s.version_dt_tm = cnvtdatetime(
      "31-DEC-2100 00:00:00.00"),
     s.mnemonic = temp->flex[d.seq].mnemonic, s.mnemonic_key = cnvtupper(temp->flex[d.seq].mnemonic),
     s.description = temp->flex[d.seq].description,
     s.info_sch_text_id = 0.0, s.flex_type_cd = flex_type_cd, s.flex_type_meaning = "ERMPOSTDOC",
     s.null_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), s.candidate_id = seq(sch_candidate_seq,
      nextval), s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), s.active_ind = 1, s
     .active_status_cd = active_cd,
     s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.active_status_prsnl_id = 0, s
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     s.updt_applctx = 0, s.updt_id = 0, s.updt_cnt = 0,
     s.updt_task = 0
    PLAN (d
     WHERE (temp->flex[d.seq].action_flag=1))
     JOIN (s)
    WITH nocounter
   ;end insert
  ENDIF
  FOR (i = 1 TO temp->flex_num)
    IF ((temp->flex[i].action_flag=2))
     DELETE  FROM sch_flex_list s
      WHERE (s.sch_flex_id=temp->flex[i].sch_flex_id)
      WITH nocounter
     ;end delete
    ENDIF
  ENDFOR
  FOR (i = 1 TO temp->flex_num)
    IF ((temp->flex[i].action_flag > 0))
     IF ((temp->flex[i].scheduling_reason_cnt > 0))
      IF ((temp->flex[i].scheduling_reason_cnt > 1))
       CALL addflex("LPARAN",i,ii)
      ENDIF
      FOR (ii = 1 TO temp->flex[i].scheduling_reason_cnt)
        IF (ii > 1)
         CALL addflex("OR",i,ii)
        ENDIF
        CALL addflex("T_SCHREASON",i,ii)
        CALL addflex("EQUAL",i,ii)
        CALL addflex("D_SCHREASON",i,ii)
      ENDFOR
      IF ((temp->flex[i].scheduling_reason_cnt > 1))
       CALL addflex("RPARAN",i,ii)
      ENDIF
      IF (maxval(temp->flex[i].admit_booking_code_cnt,temp->flex[i].encounter_type_cnt,temp->flex[i].
       waitlist_reason_cnt,temp->flex[i].post_document_cnt,temp->flex[i].pt_age_cnt,
       temp->flex[i].pt_deceased_ind_cnt,temp->flex[i].scheduling_action_cnt,temp->flex[i].
       waitlist_priority_cnt,temp->flex[i].waitlist_status_code_cnt,temp->flex[i].
       encounter_facility_cnt,
       temp->flex[i].medical_service_cnt,temp->flex[i].not_medical_service_cnt,temp->flex[i].
       not_appt_type_cnt,temp->flex[i].appt_type_cnt) > 0)
       CALL addflex("AND",i,ii)
      ENDIF
     ENDIF
     IF ((temp->flex[i].medical_service_cnt > 0))
      IF ((temp->flex[i].medical_service_cnt > 1))
       CALL addflex("LPARAN",i,ii)
      ENDIF
      FOR (ii = 1 TO temp->flex[i].medical_service_cnt)
        IF (ii > 1)
         CALL addflex("OR",i,ii)
        ENDIF
        CALL addflex("T_MEDSVC",i,ii)
        CALL addflex("EQUAL",i,ii)
        CALL addflex("D_MEDSVC",i,ii)
      ENDFOR
      IF ((temp->flex[i].medical_service_cnt > 1))
       CALL addflex("RPARAN",i,ii)
      ENDIF
      IF (maxval(temp->flex[i].admit_booking_code_cnt,temp->flex[i].encounter_type_cnt,temp->flex[i].
       waitlist_reason_cnt,temp->flex[i].post_document_cnt,temp->flex[i].pt_age_cnt,
       temp->flex[i].pt_deceased_ind_cnt,temp->flex[i].scheduling_action_cnt,temp->flex[i].
       waitlist_priority_cnt,temp->flex[i].waitlist_status_code_cnt,temp->flex[i].
       encounter_facility_cnt,
       temp->flex[i].not_medical_service_cnt,temp->flex[i].not_appt_type_cnt,temp->flex[i].
       appt_type_cnt) > 0)
       CALL addflex("AND",i,ii)
      ENDIF
     ENDIF
     IF ((temp->flex[i].not_medical_service_cnt > 0))
      IF ((temp->flex[i].not_medical_service_cnt > 1))
       CALL addflex("LPARAN",i,ii)
      ENDIF
      FOR (ii = 1 TO temp->flex[i].not_medical_service_cnt)
        IF (ii > 1)
         CALL addflex("AND",i,ii)
        ENDIF
        CALL addflex("T_MEDSVC",i,ii)
        CALL addflex("NOTEQUAL",i,ii)
        CALL addflex("D_MEDSVC",i,ii)
      ENDFOR
      IF ((temp->flex[i].not_medical_service_cnt > 1))
       CALL addflex("RPARAN",i,ii)
      ENDIF
      IF (maxval(temp->flex[i].admit_booking_code_cnt,temp->flex[i].encounter_type_cnt,temp->flex[i].
       waitlist_reason_cnt,temp->flex[i].post_document_cnt,temp->flex[i].pt_age_cnt,
       temp->flex[i].pt_deceased_ind_cnt,temp->flex[i].scheduling_action_cnt,temp->flex[i].
       waitlist_priority_cnt,temp->flex[i].waitlist_status_code_cnt,temp->flex[i].
       encounter_facility_cnt,
       temp->flex[i].not_appt_type_cnt,temp->flex[i].appt_type_cnt) > 0)
       CALL addflex("AND",i,ii)
      ENDIF
     ENDIF
     IF ((temp->flex[i].appt_type_cnt > 0))
      IF ((temp->flex[i].appt_type_cnt > 1))
       CALL addflex("LPARAN",i,ii)
      ENDIF
      FOR (ii = 1 TO temp->flex[i].appt_type_cnt)
        IF (ii > 1)
         CALL addflex("OR",i,ii)
        ENDIF
        CALL addflex("T_APPTTYPE",i,ii)
        CALL addflex("EQUAL",i,ii)
        CALL addflex("D_APPTTYPE",i,ii)
      ENDFOR
      IF ((temp->flex[i].appt_type_cnt > 1))
       CALL addflex("RPARAN",i,ii)
      ENDIF
      IF (maxval(temp->flex[i].admit_booking_code_cnt,temp->flex[i].encounter_type_cnt,temp->flex[i].
       waitlist_reason_cnt,temp->flex[i].post_document_cnt,temp->flex[i].pt_age_cnt,
       temp->flex[i].pt_deceased_ind_cnt,temp->flex[i].scheduling_action_cnt,temp->flex[i].
       waitlist_priority_cnt,temp->flex[i].waitlist_status_code_cnt,temp->flex[i].
       encounter_facility_cnt,
       temp->flex[i].not_appt_type_cnt) > 0)
       CALL addflex("AND",i,ii)
      ENDIF
     ENDIF
     IF ((temp->flex[i].not_appt_type_cnt > 0))
      IF ((temp->flex[i].not_appt_type_cnt > 1))
       CALL addflex("LPARAN",i,ii)
      ENDIF
      FOR (ii = 1 TO temp->flex[i].not_appt_type_cnt)
        IF (ii > 1)
         CALL addflex("AND",i,ii)
        ENDIF
        CALL addflex("T_APPTTYPE",i,ii)
        CALL addflex("NOTEQUAL",i,ii)
        CALL addflex("D_APPTTYPE",i,ii)
      ENDFOR
      IF ((temp->flex[i].not_appt_type_cnt > 1))
       CALL addflex("RPARAN",i,ii)
      ENDIF
      IF (maxval(temp->flex[i].admit_booking_code_cnt,temp->flex[i].encounter_type_cnt,temp->flex[i].
       waitlist_reason_cnt,temp->flex[i].post_document_cnt,temp->flex[i].pt_age_cnt,
       temp->flex[i].pt_deceased_ind_cnt,temp->flex[i].scheduling_action_cnt,temp->flex[i].
       waitlist_priority_cnt,temp->flex[i].waitlist_status_code_cnt,temp->flex[i].
       encounter_facility_cnt) > 0)
       CALL addflex("AND",i,ii)
      ENDIF
     ENDIF
     IF ((temp->flex[i].encounter_facility_cnt > 0))
      IF ((temp->flex[i].encounter_facility_cnt > 1))
       CALL addflex("LPARAN",i,ii)
      ENDIF
      FOR (ii = 1 TO temp->flex[i].encounter_facility_cnt)
        IF (ii > 1)
         CALL addflex("OR",i,ii)
        ENDIF
        CALL addflex("T_ENCNTRFAC",i,ii)
        CALL addflex("EQUAL",i,ii)
        CALL addflex("D_ENCNTRFAC",i,ii)
      ENDFOR
      IF ((temp->flex[i].encounter_facility_cnt > 1))
       CALL addflex("RPARAN",i,ii)
      ENDIF
      IF (maxval(temp->flex[i].admit_booking_code_cnt,temp->flex[i].encounter_type_cnt,temp->flex[i].
       waitlist_reason_cnt,temp->flex[i].post_document_cnt,temp->flex[i].pt_age_cnt,
       temp->flex[i].pt_deceased_ind_cnt,temp->flex[i].scheduling_action_cnt,temp->flex[i].
       waitlist_priority_cnt,temp->flex[i].waitlist_status_code_cnt) > 0)
       CALL addflex("AND",i,ii)
      ENDIF
     ENDIF
     IF ((temp->flex[i].pt_deceased_ind_cnt > 0))
      IF ((temp->flex[i].pt_deceased_ind_cnt > 1))
       CALL addflex("LPARAN",i,ii)
      ENDIF
      FOR (ii = 1 TO temp->flex[i].pt_deceased_ind_cnt)
        IF (ii > 1)
         CALL addflex("OR",i,ii)
        ENDIF
        CALL addflex("T_PERDEAD",i,ii)
        CALL addflex("EQUAL",i,ii)
        IF ((temp->flex[i].pt_deceased[ii].pt_deceased_ind=1))
         CALL addflex("L_TRUE",i,ii)
        ELSE
         CALL addflex("L_FALSE",i,ii)
        ENDIF
      ENDFOR
      IF ((temp->flex[i].pt_deceased_ind_cnt > 1))
       CALL addflex("RPARAN",i,ii)
      ENDIF
      IF (maxval(temp->flex[i].admit_booking_code_cnt,temp->flex[i].encounter_type_cnt,temp->flex[i].
       waitlist_reason_cnt,temp->flex[i].post_document_cnt,temp->flex[i].pt_age_cnt,
       temp->flex[i].scheduling_action_cnt,temp->flex[i].waitlist_priority_cnt,temp->flex[i].
       waitlist_status_code_cnt) > 0)
       CALL addflex("AND",i,ii)
      ENDIF
     ENDIF
     IF ((temp->flex[i].encounter_type_cnt > 0))
      IF ((temp->flex[i].encounter_type_cnt > 1))
       CALL addflex("LPARAN",i,ii)
      ENDIF
      FOR (ii = 1 TO temp->flex[i].encounter_type_cnt)
        IF (ii > 1)
         CALL addflex("OR",i,ii)
        ENDIF
        CALL addflex("T_ENCTYPE",i,ii)
        CALL addflex("EQUAL",i,ii)
        CALL addflex("D_ENCTYPE",i,ii)
      ENDFOR
      IF ((temp->flex[i].encounter_type_cnt > 1))
       CALL addflex("RPARAN",i,ii)
      ENDIF
      IF (maxval(temp->flex[i].admit_booking_code_cnt,temp->flex[i].waitlist_reason_cnt,temp->flex[i]
       .post_document_cnt,temp->flex[i].pt_age_cnt,temp->flex[i].scheduling_action_cnt,
       temp->flex[i].waitlist_priority_cnt,temp->flex[i].waitlist_status_code_cnt) > 0)
       CALL addflex("AND",i,ii)
      ENDIF
     ENDIF
     IF ((temp->flex[i].pt_age_cnt > 0))
      IF ((temp->flex[i].pt_age_cnt > 1))
       CALL addflex("LPARAN",i,ii)
      ENDIF
      FOR (ii = 1 TO temp->flex[i].pt_age_cnt)
        IF (ii > 1)
         CALL addflex("OR",i,ii)
        ENDIF
        CALL addflex("T_PTAGEMIN",i,ii)
        CALL addflex("PTAGEOPER",i,ii)
        CALL addflex("L_DATEOFF",i,ii)
      ENDFOR
      IF ((temp->flex[i].pt_age_cnt > 1))
       CALL addflex("RPARAN",i,ii)
      ENDIF
      IF (maxval(temp->flex[i].admit_booking_code_cnt,temp->flex[i].waitlist_reason_cnt,temp->flex[i]
       .post_document_cnt,temp->flex[i].scheduling_action_cnt,temp->flex[i].waitlist_priority_cnt,
       temp->flex[i].waitlist_status_code_cnt) > 0)
       CALL addflex("AND",i,ii)
      ENDIF
     ENDIF
     IF ((temp->flex[i].scheduling_action_cnt > 0))
      IF ((temp->flex[i].scheduling_action_cnt > 1))
       CALL addflex("LPARAN",i,ii)
      ENDIF
      FOR (ii = 1 TO temp->flex[i].scheduling_action_cnt)
        IF (ii > 1)
         CALL addflex("OR",i,ii)
        ENDIF
        CALL addflex("T_SCHACTION",i,ii)
        CALL addflex("EQUAL",i,ii)
        CALL addflex("D_SCHACTION",i,ii)
      ENDFOR
      IF ((temp->flex[i].scheduling_action_cnt > 1))
       CALL addflex("RPARAN",i,ii)
      ENDIF
      IF (maxval(temp->flex[i].admit_booking_code_cnt,temp->flex[i].waitlist_reason_cnt,temp->flex[i]
       .post_document_cnt,temp->flex[i].waitlist_priority_cnt,temp->flex[i].waitlist_status_code_cnt)
       > 0)
       CALL addflex("AND",i,ii)
      ENDIF
     ENDIF
     IF ((temp->flex[i].waitlist_reason_cnt > 0))
      IF ((temp->flex[i].waitlist_reason_cnt > 1))
       CALL addflex("LPARAN",i,ii)
      ENDIF
      FOR (ii = 1 TO temp->flex[i].waitlist_reason_cnt)
        IF (ii > 1)
         CALL addflex("OR",i,ii)
        ENDIF
        CALL addflex("T_WLREASNCHG",i,ii)
        CALL addflex("EQUAL",i,ii)
        CALL addflex("D_WLREASNCHG",i,ii)
      ENDFOR
      IF ((temp->flex[i].waitlist_reason_cnt > 1))
       CALL addflex("RPARAN",i,ii)
      ENDIF
      IF (maxval(temp->flex[i].admit_booking_code_cnt,temp->flex[i].post_document_cnt,temp->flex[i].
       waitlist_priority_cnt,temp->flex[i].waitlist_status_code_cnt) > 0)
       CALL addflex("AND",i,ii)
      ENDIF
     ENDIF
     IF ((temp->flex[i].post_document_cnt > 0))
      IF ((temp->flex[i].post_document_cnt > 1))
       CALL addflex("LPARAN",i,ii)
      ENDIF
      FOR (ii = 1 TO temp->flex[i].post_document_cnt)
        IF (ii > 1)
         CALL addflex("OR",i,ii)
        ENDIF
        CALL addflex("T_POSTDOCIND",i,ii)
        CALL addflex("EQUAL",i,ii)
        IF ((temp->flex[i].post_document[ii].post_document_ind=1))
         CALL addflex("L_TRUE",i,ii)
        ELSE
         CALL addflex("L_FALSE",i,ii)
        ENDIF
      ENDFOR
      IF ((temp->flex[i].post_document_cnt > 1))
       CALL addflex("RPARAN",i,ii)
      ENDIF
      IF (maxval(temp->flex[i].admit_booking_code_cnt,temp->flex[i].waitlist_priority_cnt,temp->flex[
       i].waitlist_status_code_cnt) > 0)
       CALL addflex("AND",i,ii)
      ENDIF
     ENDIF
     IF ((temp->flex[i].waitlist_priority_cnt > 0))
      IF ((temp->flex[i].waitlist_priority_cnt > 1))
       CALL addflex("LPARAN",i,ii)
      ENDIF
      FOR (ii = 1 TO temp->flex[i].waitlist_priority_cnt)
        IF (ii > 1)
         CALL addflex("OR",i,ii)
        ENDIF
        CALL addflex("T_PRIORITY",i,ii)
        CALL addflex("EQUAL",i,ii)
        CALL addflex("D_PRIORITY",i,ii)
      ENDFOR
      IF ((temp->flex[i].waitlist_priority_cnt > 1))
       CALL addflex("RPARAN",i,ii)
      ENDIF
      IF (maxval(temp->flex[i].admit_booking_code_cnt,temp->flex[i].waitlist_status_code_cnt) > 0)
       CALL addflex("AND",i,ii)
      ENDIF
     ENDIF
     IF ((temp->flex[i].waitlist_status_code_cnt > 0))
      IF ((temp->flex[i].waitlist_status_code_cnt > 1))
       CALL addflex("LPARAN",i,ii)
      ENDIF
      FOR (ii = 1 TO temp->flex[i].waitlist_status_code_cnt)
        IF (ii > 1)
         CALL addflex("OR",i,ii)
        ENDIF
        CALL addflex("T_WAITLSSTCD",i,ii)
        CALL addflex("EQUAL",i,ii)
        CALL addflex("D_WAITLSSTCD",i,ii)
      ENDFOR
      IF ((temp->flex[i].waitlist_status_code_cnt > 1))
       CALL addflex("RPARAN",i,ii)
      ENDIF
      IF ((temp->flex[i].admit_booking_code_cnt > 0))
       CALL addflex("AND",i,ii)
      ENDIF
     ENDIF
     IF ((temp->flex[i].admit_booking_code_cnt > 0))
      IF ((temp->flex[i].admit_booking_code_cnt > 1))
       CALL addflex("LPARAN",i,ii)
      ENDIF
      FOR (ii = 1 TO temp->flex[i].admit_booking_code_cnt)
        IF (ii > 1)
         CALL addflex("OR",i,ii)
        ENDIF
        CALL addflex("T_ADMITBKCD",i,ii)
        CALL addflex("EQUAL",i,ii)
        CALL addflex("D_ADMITBKCD",i,ii)
      ENDFOR
      IF ((temp->flex[i].admit_booking_code_cnt > 1))
       CALL addflex("RPARAN",i,ii)
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
  EXECUTE sch_flex_postfix
 ENDIF
 SELECT INTO value(name)
  FROM (dummyt d  WITH seq = temp->flex_num)
  DETAIL
   col 8, temp->flex[d.seq].row"#####", col 20,
   temp->flex[d.seq].mnemonic, col 73, temp->flex[d.seq].sch_flex_id
   IF ((temp->flex[d.seq].action_flag=1))
    IF ((tempreq->insert_ind="Y"))
     col 90, "Added"
    ELSE
     col 90, "Verified"
    ENDIF
   ELSEIF ((temp->flex[d.seq].action_flag=2))
    IF ((tempreq->insert_ind="Y"))
     col 90, "Updated"
    ELSE
     col 90, "Verified"
    ENDIF
   ELSE
    col 90, "Error", col 100,
    temp->flex[d.seq].error_string
   ENDIF
   row + 1
   FOR (i = 1 TO temp->flex[d.seq].admit_booking_code_cnt)
     col 8, temp->flex[d.seq].admit_booking_code[i].row"#####", col 40,
     "Admit Booking Code", col 64, "=",
     col 73, temp->flex[d.seq].admit_booking_code[i].admit_booking_code, col 100,
     temp->flex[d.seq].admit_booking_code[i].error_string, row + 1
   ENDFOR
   FOR (i = 1 TO temp->flex[d.seq].encounter_facility_cnt)
     col 8, temp->flex[d.seq].encounter_facility[i].row"#####", col 40,
     "Encounter Facility", col 64, "=",
     col 73, temp->flex[d.seq].encounter_facility[i].factiliy_disp, col 100,
     temp->flex[d.seq].encounter_facility[i].error_string, row + 1
   ENDFOR
   FOR (i = 1 TO temp->flex[d.seq].encounter_type_cnt)
     col 8, temp->flex[d.seq].encounter_type[i].row"#####", col 40,
     "Encounter Type", col 64, "=",
     col 73, temp->flex[d.seq].encounter_type[i].encounter_type, col 100,
     temp->flex[d.seq].encounter_type[i].error_string, row + 1
   ENDFOR
   FOR (i = 1 TO temp->flex[d.seq].medical_service_cnt)
     col 8, temp->flex[d.seq].medical_service[i].row"#####", col 40,
     "Medical Service", col 64, "=",
     col 73, temp->flex[d.seq].medical_service[i].medical_service, col 100,
     temp->flex[d.seq].medical_service[i].error_string, row + 1
   ENDFOR
   FOR (i = 1 TO temp->flex[d.seq].post_document_cnt)
     col 8, temp->flex[d.seq].post_document[i].row"#####", col 40,
     temp->flex[d.seq].post_document[i].post_document_name, col 64, "="
     IF ((temp->flex[d.seq].post_document[i].post_document_ind=1))
      col 73, "TRUE"
     ELSE
      col 73, "FALSE"
     ENDIF
     col 100, temp->flex[d.seq].post_document[i].error_string, row + 1
   ENDFOR
   FOR (i = 1 TO temp->flex[d.seq].pt_age_cnt)
     col 8, temp->flex[d.seq].pt_age[i].row"#####", col 40,
     "Patient Age", col 64, temp->flex[d.seq].pt_age[i].operand,
     col 67, temp->flex[d.seq].pt_age[i].pt_age, col 73,
     temp->flex[d.seq].pt_age[i].offset, col 100, temp->flex[d.seq].pt_age[i].error_string,
     row + 1
   ENDFOR
   FOR (i = 1 TO temp->flex[d.seq].pt_deceased_ind_cnt)
     col 8, temp->flex[d.seq].pt_deceased[i].row"#####", col 40,
     "Person deceased Ind", col 64, "="
     IF ((temp->flex[d.seq].pt_deceased[i].pt_deceased_ind=1))
      col 73, "TRUE"
     ELSE
      col 73, "FALSE"
     ENDIF
     col 100, temp->flex[d.seq].pt_deceased[i].error_string, row + 1
   ENDFOR
   FOR (i = 1 TO temp->flex[d.seq].scheduling_action_cnt)
     col 8, temp->flex[d.seq].scheduling_action[i].row"#####", col 40,
     "Scheduling Action", col 64, "=",
     col 73, temp->flex[d.seq].scheduling_action[i].scheduling_action, col 100,
     temp->flex[d.seq].scheduling_action[i].error_string, row + 1
   ENDFOR
   FOR (i = 1 TO temp->flex[d.seq].waitlist_priority_cnt)
     col 8, temp->flex[d.seq].waitlist_priority[i].row"#####", col 40,
     "Waitlist Priority", col 64, "=",
     col 73, temp->flex[d.seq].waitlist_priority[i].waitlist_priority, col 100,
     temp->flex[d.seq].waitlist_priority[i].error_string, row + 1
   ENDFOR
   FOR (i = 1 TO temp->flex[d.seq].waitlist_reason_cnt)
     col 8, temp->flex[d.seq].waitlist_reason[i].row"#####", col 40,
     "Waitlist Reason", col 64, "=",
     col 73, temp->flex[d.seq].waitlist_reason[i].waitlist_reason, col 100,
     temp->flex[d.seq].waitlist_reason[i].error_string, row + 1
   ENDFOR
   FOR (i = 1 TO temp->flex[d.seq].scheduling_reason_cnt)
     col 8, temp->flex[d.seq].scheduling_reason[i].row"#####", col 40,
     "Scheduling Reason", col 64, "=",
     col 73, temp->flex[d.seq].scheduling_reason[i].scheduling_reason, col 100,
     temp->flex[d.seq].scheduling_reason[i].error_string, row + 1
   ENDFOR
   FOR (i = 1 TO temp->flex[d.seq].waitlist_status_code_cnt)
     col 8, temp->flex[d.seq].waitlist_status_code[i].row"#####", col 40,
     "Waitlist Code", col 64, "=",
     col 73, temp->flex[d.seq].waitlist_status_code[i].waitlist_status_code, col 100,
     temp->flex[d.seq].waitlist_status_code[i].error_string, row + 1
   ENDFOR
   row + 1
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
#exit_script
 RETURN
 SUBROUTINE addflex(xtype,xtempnum,xminortempnum)
   DECLARE token_cd = f8
   DECLARE token_mean = vc
   DECLARE token_type_cd = f8
   DECLARE token_type_mean = vc
   DECLARE precedence = i4
   DECLARE data_type_cd = f8
   DECLARE data_type_mean = vc
   DECLARE flex_eval_cd = f8
   DECLARE flex_eval_mean = vc
   DECLARE string_value = vc
   DECLARE dynamic_text = vc
   DECLARE double_value = f8
   DECLARE data_source_cd = f8
   DECLARE data_source_mean = vc
   DECLARE parent_id = f8
   DECLARE parent_table = vc
   DECLARE parent_mean = vc
   DECLARE display_id = f8
   DECLARE display_table = vc
   DECLARE display_mean = vc
   DECLARE filter_table = vc
   DECLARE filter_id = f8
   DECLARE offset_units = i4
   DECLARE offset_units_cd = f8
   DECLARE offset_units_mean = vc
   IF (xtype="LPARAN")
    SET token_cd = lparan_token_cd
    SET token_mean = "LPARAN"
    SET token_type_cd = operator_type_cd
    SET token_type_mean = "OPERATOR"
    SET precedence = 10
   ELSEIF (xtype="RPARAN")
    SET token_cd = rparan_token_cd
    SET token_mean = "RPARAN"
    SET token_type_cd = operator_type_cd
    SET token_type_mean = "OPERATOR"
    SET precedence = 10
   ELSEIF (xtype="EQUAL")
    SET token_cd = equal_token_cd
    SET token_mean = "EQUAL"
    SET token_type_cd = operator_type_cd
    SET token_type_mean = "OPERATOR"
    SET precedence = 4
   ELSEIF (xtype="NOTEQUAL")
    SET token_cd = notequal_token_cd
    SET token_mean = "NOTEQUAL"
    SET token_type_cd = operator_type_cd
    SET token_type_mean = "OPERATOR"
    SET precedence = 4
   ELSEIF (xtype="OR")
    SET token_cd = or_token_cd
    SET token_mean = "OR"
    SET token_type_cd = operator_type_cd
    SET token_type_mean = "OPERATOR"
    SET precedence = 1
   ELSEIF (xtype="AND")
    SET token_cd = and_token_cd
    SET token_mean = "AND"
    SET token_type_cd = operator_type_cd
    SET token_type_mean = "OPERATOR"
    SET precedence = 1
   ELSEIF (xtype="L_TRUE")
    SET token_cd = l_true_token_cd
    SET token_mean = "L_TRUE"
    SET token_type_cd = operator_type_cd
    SET token_type_mean = "OPERATOR"
    SET token_type_cd = literal_type_cd
    SET token_type_mean = "LITERAL"
    SET flex_eval_cd = literal_eval_cd
    SET flex_eval_mean = "LITERAL"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET double_value = 1
    SET precedence = 0
   ELSEIF (xtype="L_FALSE")
    SET token_cd = l_false_token_cd
    SET token_mean = "L_FALSE"
    SET token_type_cd = operator_type_cd
    SET token_type_mean = "OPERATOR"
    SET token_type_cd = literal_type_cd
    SET token_type_mean = "LITERAL"
    SET flex_eval_cd = literal_eval_cd
    SET flex_eval_mean = "LITERAL"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET double_value = 0
    SET precedence = 0
   ELSEIF (xtype="T_ENCNTRFAC")
    SET token_cd = t_encntrfac_cd
    SET token_mean = "T_ENCNTRFAC"
    SET token_type_cd = operand_type_cd
    SET token_type_mean = "OPERAND"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = hardcoded_cd
    SET flex_eval_mean = "HARDCODED"
    SET precedence = 0
    SET dynamic_text = "SCH_GETF_FLEX_CODEVALUE"
    SET data_source_cd = codevalue_cd
    SET data_source_mean = "CODEVALUE"
   ELSEIF (xtype="T_PERDEAD")
    SET token_cd = t_perdead_cd
    SET token_mean = "T_PERDEAD"
    SET token_type_cd = operand_type_cd
    SET token_type_mean = "OPERAND"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = hardcoded_cd
    SET flex_eval_mean = "HARDCODED"
   ELSEIF (xtype="D_ENCNTRFAC")
    SET token_cd = d_encntrfac_cd
    SET token_mean = "D_ENCNTRFAC"
    SET token_type_cd = datasource_type_cd
    SET token_type_mean = "DATASOURCE"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = datasource_eval_cd
    SET flex_eval_mean = "DATASOURCE"
    SET precedence = 0
    SET dynamic_text = "SCH_GETF_FLEX_FACILITY"
    SET string_value = temp->flex[xtempnum].encounter_facility[xminortempnum].factiliy_disp
    SET data_source_cd = facility_data_source_cd
    SET data_source_mean = "FACILITY"
    SET parent_id = temp->flex[xtempnum].encounter_facility[xminortempnum].facility_cd
    SET parent_mean = "FACILITY"
    SET parent_table = "CODE_VALUE"
    SET display_id = temp->flex[xtempnum].encounter_facility[xminortempnum].facility_cd
    SET display_mean = "FACILITY"
    SET display_table = "CODE_VALUE"
   ELSEIF (xtype="T_ENCTYPE")
    SET token_cd = t_enctype_cd
    SET token_mean = "T_ENCTYPE"
    SET token_type_cd = operand_type_cd
    SET token_type_mean = "OPERAND"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = hardcoded_cd
    SET flex_eval_mean = "HARDCODED"
    SET precedence = 0
   ELSEIF (xtype="D_ENCTYPE")
    SET token_cd = d_enctype_cd
    SET token_mean = "D_ENCTYPE"
    SET token_type_cd = datasource_type_cd
    SET token_type_mean = "DATASOURCE"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = datasource_eval_cd
    SET flex_eval_mean = "DATASOURCE"
    SET precedence = 0
    SET dynamic_text = "SCH_GETF_FLEX_CODEVALUE"
    SET string_value = temp->flex[xtempnum].encounter_type[xminortempnum].encounter_type
    SET data_source_cd = codevalue_cd
    SET data_source_mean = "CODEVALUE"
    SET parent_id = temp->flex[xtempnum].encounter_type[xminortempnum].encounter_type_cd
    SET parent_table = "CODE_VALUE"
    SET display_id = temp->flex[xtempnum].encounter_type[xminortempnum].encounter_type_cd
    SET display_table = "CODE_VALUE"
    SET parent_mean = temp->flex[xtempnum].encounter_type[xminortempnum].encounter_type_mean
    SET display_mean = temp->flex[xtempnum].encounter_type[xminortempnum].encounter_type_mean
   ELSEIF (xtype="T_MEDSVC")
    SET token_cd = t_medsvc_cd
    SET token_mean = "T_MEDSVC"
    SET token_type_cd = operand_type_cd
    SET token_type_mean = "OPERAND"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = hardcoded_cd
    SET flex_eval_mean = "HARDCODED"
    SET precedence = 0
   ELSEIF (xtype="D_MEDSVC")
    SET token_cd = d_medsvc_cd
    SET token_mean = "D_MEDSVC"
    SET token_type_cd = datasource_type_cd
    SET token_type_mean = "DATASOURCE"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = datasource_eval_cd
    SET flex_eval_mean = "DATASOURCE"
    SET precedence = 0
    SET dynamic_text = "SCH_GETF_FLEX_CODEVALUE"
    SET string_value = temp->flex[xtempnum].medical_service[xminortempnum].medical_service
    SET data_source_cd = codevalue_cd
    SET data_source_mean = "CODEVALUE"
    SET parent_id = temp->flex[xtempnum].medical_service[xminortempnum].medical_service_cd
    SET parent_table = "CODE_VALUE"
    SET display_id = temp->flex[xtempnum].medical_service[xminortempnum].medical_service_cd
    SET display_table = "CODE_VALUE"
    SET parent_mean = temp->flex[xtempnum].medical_service[xminortempnum].medical_service_mean
    SET display_mean = temp->flex[xtempnum].medical_service[xminortempnum].medical_service_mean
   ELSEIF (xtype="T_APPTTYPE")
    SET token_cd = t_appttype_cd
    SET token_mean = "T_APPTTYPE"
    SET token_type_cd = operand_type_cd
    SET token_type_mean = "OPERAND"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = hardcoded_cd
    SET flex_eval_mean = "HARDCODED"
    SET precedence = 0
   ELSEIF (xtype="D_APPTTYPE")
    SET token_cd = d_appttype_cd
    SET token_mean = "D_APPTTYPE"
    SET token_type_cd = datasource_type_cd
    SET token_type_mean = "DATASOURCE"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = datasource_eval_cd
    SET flex_eval_mean = "DATASOURCE"
    SET precedence = 0
    SET dynamic_text = "SCH_GETF_FLEX_APPTTYPE"
    SET string_value = temp->flex[xtempnum].appt_type[xminortempnum].appt_type
    SET data_source_cd = appt_type_ds_cd
    SET data_source_mean = "APPTTYPE"
    SET parent_id = temp->flex[xtempnum].appt_type[xminortempnum].appt_type_parent_cd
    SET parent_table = "CODE_VALUE"
    SET display_id = temp->flex[xtempnum].appt_type[xminortempnum].appt_type_display_cd
    SET display_table = "CODE_VALUE"
   ELSEIF (xtype="T_PTAGEMIN")
    SET token_cd = t_ptagemin_cd
    SET token_mean = "T_PTAGEMIN"
    SET token_type_cd = operand_type_cd
    SET token_type_mean = "OPERAND"
    SET data_type_cd = date_type_cd
    SET data_type_mean = "DATE"
    SET flex_eval_cd = age_eval_cd
    SET flex_eval_mean = "AGE"
   ELSEIF (xtype="PTAGEOPER")
    SET token_cd = temp->flex[xtempnum].pt_age[xminortempnum].operand_cd
    SET token_mean = temp->flex[xtempnum].pt_age[xminortempnum].operand_mean
    SET token_type_cd = operator_type_cd
    SET token_type_mean = "OPERATOR"
    SET precedence = 5
   ELSEIF (xtype="L_DATEOFF")
    SET token_cd = l_dateoff_cd
    SET token_mean = "L_DATEOFF"
    SET token_type_cd = literal_type_cd
    SET token_type_mean = "LITERAL"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = units_eval_cd
    SET flex_eval_mean = "UNITS"
    SET double_value = cnvtreal(temp->flex[xtempnum].pt_age[xminortempnum].pt_age)
    SET string_value = temp->flex[xtempnum].pt_age[xminortempnum].pt_age
    SET offset_units = cnvtreal(temp->flex[xtempnum].pt_age[xminortempnum].pt_age)
    SET offset_units_cd = temp->flex[xtempnum].pt_age[xminortempnum].offset_cd
    SET offset_units_mean = temp->flex[xtempnum].pt_age[xminortempnum].offset_mean
   ELSEIF (xtype="T_SCHACTION")
    SET token_cd = t_schaction_cd
    SET token_mean = "T_SCHACTION"
    SET token_type_cd = operand_type_cd
    SET token_type_mean = "OPERAND"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = hardcoded_cd
    SET flex_eval_mean = "HARDCODED"
    SET precedence = 0
    SET dynamic_text = "SCH_GETF_FLEX_CODEVALUE"
    SET data_source_cd = codevalue_cd
    SET data_source_mean = "CODEVALUE"
   ELSEIF (xtype="D_SCHACTION")
    SET token_cd = d_schaction_cd
    SET token_mean = "D_SCHACTION"
    SET token_type_cd = datasource_type_cd
    SET token_type_mean = "DATASOURCE"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = datasource_eval_cd
    SET flex_eval_mean = "DATASOURCE"
    SET precedence = 0
    SET dynamic_text = "SCH_GETF_FLEX_CODEVALUE"
    SET string_value = temp->flex[xtempnum].scheduling_action[xminortempnum].scheduling_action
    SET data_source_cd = schaction_data_source_cd
    SET data_source_mean = "SCHACTION"
    SET parent_id = temp->flex[xtempnum].scheduling_action[xminortempnum].scheduling_action_cd
    SET parent_mean = temp->flex[xtempnum].scheduling_action[xminortempnum].scheduling_action_mean
    SET parent_table = "CODE_VALUE"
    SET display_id = temp->flex[xtempnum].scheduling_action[xminortempnum].scheduling_action_cd
    SET display_mean = temp->flex[xtempnum].scheduling_action[xminortempnum].scheduling_action_mean
    SET display_table = "CODE_VALUE"
   ELSEIF (xtype="T_WLREASNCHG")
    SET token_cd = t_wlreasnchg_cd
    SET token_mean = "T_WLREASNCHG"
    SET token_type_cd = operand_type_cd
    SET token_type_mean = "OPERAND"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = hardcoded_cd
    SET flex_eval_mean = "HARDCODED"
    SET precedence = 0
    SET dynamic_text = "SCH_GETF_FLEX_CODEVALUE"
    SET data_source_cd = codevalue_cd
    SET data_source_mean = "CODEVALUE"
   ELSEIF (xtype="D_WLREASNCHG")
    SET token_cd = d_wlreasnchg_cd
    SET token_mean = "D_WLREASNCHG"
    SET token_type_cd = datasource_type_cd
    SET token_type_mean = "DATASOURCE"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = datasource_eval_cd
    SET flex_eval_mean = "DATASOURCE"
    SET precedence = 0
    SET dynamic_text = "SCH_GETF_FLEX_CODEVALUE"
    SET string_value = temp->flex[xtempnum].waitlist_reason[xminortempnum].waitlist_reason
    SET data_source_cd = wlreasnchg_data_cd
    SET data_source_mean = "WLREASNCHG"
    SET parent_id = temp->flex[xtempnum].waitlist_reason[xminortempnum].waitlist_reason_cd
    SET parent_mean = temp->flex[xtempnum].waitlist_reason[xminortempnum].waitlist_reason_mean
    SET parent_table = "CODE_VALUE"
    SET display_id = temp->flex[xtempnum].waitlist_reason[xminortempnum].waitlist_reason_cd
    SET display_mean = temp->flex[xtempnum].waitlist_reason[xminortempnum].waitlist_reason_mean
    SET display_table = "CODE_VALUE"
   ELSEIF (xtype="T_SCHREASON")
    SET token_cd = t_schreason_cd
    SET token_mean = "T_SCHREASON"
    SET token_type_cd = operand_type_cd
    SET token_type_mean = "OPERAND"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = hardcoded_cd
    SET flex_eval_mean = "HARDCODED"
    SET precedence = 0
    SET dynamic_text = "SCH_GETF_FLEX_CODEVALUE"
    SET data_source_cd = codevalue_cd
    SET data_source_mean = "CODEVALUE"
   ELSEIF (xtype="D_SCHREASON")
    SET token_cd = d_schreason_cd
    SET token_mean = "D_SCHREASON"
    SET token_type_cd = datasource_type_cd
    SET token_type_mean = "DATASOURCE"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = datasource_eval_cd
    SET flex_eval_mean = "DATASOURCE"
    SET precedence = 0
    SET dynamic_text = "SCH_GETF_FLEX_CODEVALUE"
    SET string_value = temp->flex[xtempnum].scheduling_reason[xminortempnum].scheduling_reason
    SET data_source_cd = schreason_data_cd
    SET data_source_mean = "SCHREASON"
    SET parent_id = temp->flex[xtempnum].scheduling_reason[xminortempnum].scheduling_reason_cd
    SET parent_mean = temp->flex[xtempnum].scheduling_reason[xminortempnum].scheduling_reason_mean
    SET parent_table = "CODE_VALUE"
    SET display_id = temp->flex[xtempnum].scheduling_reason[xminortempnum].scheduling_reason_cd
    SET display_mean = temp->flex[xtempnum].scheduling_reason[xminortempnum].scheduling_reason_mean
    SET display_table = "CODE_VALUE"
   ELSEIF (xtype="T_POSTDOCIND")
    SET token_cd = t_postdocind_cd
    SET token_mean = "T_POSTDOCIND"
    SET token_type_cd = operand_type_cd
    SET token_type_mean = "OPERAND"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = hardcoded_cd
    SET flex_eval_mean = "HARDCODED"
    SET precedence = 0
    SET dynamic_text = "SCH_GETF_FLEX_CODEVALUE"
    SET string_value = temp->flex[xtempnum].post_document[xminortempnum].post_document_name
    SET double_value = temp->flex[xtempnum].post_document[xminortempnum].post_document_cd
    SET data_source_cd = codevalue_cd
    SET data_source_mean = "CODEVALUE"
    SET filter_table = "CODE_VALUE"
    SET filter_id = temp->flex[xtempnum].post_document[xminortempnum].post_document_cd
   ELSEIF (xtype="T_PRIORITY")
    SET token_cd = t_priority_cd
    SET token_mean = "T_PRIORITY"
    SET token_type_cd = operand_type_cd
    SET token_type_mean = "OPERAND"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = hardcoded_cd
    SET flex_eval_mean = "HARDCODED"
    SET precedence = 0
   ELSEIF (xtype="D_PRIORITY")
    SET token_cd = d_priority_cd
    SET token_mean = "D_PRIORITY"
    SET token_type_cd = datasource_type_cd
    SET token_type_mean = "DATASOURCE"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = datasource_eval_cd
    SET flex_eval_mean = "DATASOURCE"
    SET precedence = 0
    SET dynamic_text = "SCH_GETF_FLEX_CODEVALUE"
    SET string_value = temp->flex[xtempnum].waitlist_priority[xminortempnum].waitlist_priority
    SET data_source_cd = codevalue_cd
    SET data_source_mean = "CODEVALUE"
    SET parent_id = temp->flex[xtempnum].waitlist_priority[xminortempnum].waitlist_priority_cd
    SET parent_mean = temp->flex[xtempnum].waitlist_priority[xminortempnum].waitlist_priority_mean
    SET parent_table = "CODE_VALUE"
    SET display_id = temp->flex[xtempnum].waitlist_priority[xminortempnum].waitlist_priority_cd
    SET display_mean = temp->flex[xtempnum].waitlist_priority[xminortempnum].waitlist_priority_mean
    SET display_table = "CODE_VALUE"
   ELSEIF (xtype="T_WAITLSSTCD")
    SET token_cd = t_waitlsstcd_cd
    SET token_mean = "T_WAITLSSTCD"
    SET token_type_cd = operand_type_cd
    SET token_type_mean = "OPERAND"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = hardcoded_cd
    SET flex_eval_mean = "HARDCODED"
    SET precedence = 0
    SET dynamic_text = "SCH_GETF_FLEX_CODEVALUE"
    SET data_source_cd = codevalue_cd
    SET data_source_mean = "CODEVALUE"
   ELSEIF (xtype="D_WAITLSSTCD")
    SET token_cd = d_waitlsstcd_cd
    SET token_mean = "D_WAITLSSTCD"
    SET token_type_cd = datasource_type_cd
    SET token_type_mean = "DATASOURCE"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = datasource_eval_cd
    SET flex_eval_mean = "DATASOURCE"
    SET precedence = 0
    SET dynamic_text = "SCH_GETF_FLEX_CODEVALUE"
    SET string_value = temp->flex[xtempnum].waitlist_status_code[xminortempnum].waitlist_status_code
    SET data_source_cd = waitlsstcd_data_cd
    SET data_source_mean = "WAITLSSTCD"
    SET parent_id = temp->flex[xtempnum].waitlist_status_code[xminortempnum].waitlist_status_code_cd
    SET parent_mean = temp->flex[xtempnum].waitlist_status_code[xminortempnum].
    waitlist_status_code_mean
    SET parent_table = "CODE_VALUE"
    SET display_id = temp->flex[xtempnum].waitlist_status_code[xminortempnum].waitlist_status_code_cd
    SET display_mean = temp->flex[xtempnum].waitlist_status_code[xminortempnum].
    waitlist_status_code_mean
    SET display_table = "CODE_VALUE"
   ELSEIF (xtype="T_ADMITBKCD")
    SET token_cd = t_admitbkcd_cd
    SET token_mean = "T_ADMITBKCD"
    SET token_type_cd = operand_type_cd
    SET token_type_mean = "OPERAND"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = hardcoded_cd
    SET flex_eval_mean = "HARDCODED"
    SET precedence = 0
    SET dynamic_text = "SCH_GETF_FLEX_CODEVALUE"
    SET data_source_cd = codevalue_cd
    SET data_source_mean = "CODEVALUE"
   ELSEIF (xtype="D_ADMITBKCD")
    SET token_cd = d_admitbkcd_cd
    SET token_mean = "D_ADMITBKCD"
    SET token_type_cd = datasource_type_cd
    SET token_type_mean = "DATASOURCE"
    SET data_type_cd = double_type_cd
    SET data_type_mean = "DOUBLE"
    SET flex_eval_cd = datasource_eval_cd
    SET flex_eval_mean = "DATASOURCE"
    SET precedence = 0
    SET dynamic_text = "SCH_GETF_FLEX_CODEVALUE"
    SET string_value = temp->flex[xtempnum].admit_booking_code[xminortempnum].admit_booking_code
    SET data_source_cd = admitbkcd_data_cd
    SET data_source_mean = "ADMITBKCD"
    SET parent_id = temp->flex[xtempnum].admit_booking_code[xminortempnum].admit_booking_code_cd
    SET parent_mean = temp->flex[xtempnum].admit_booking_code[xminortempnum].admit_booking_code_mean
    SET parent_table = "CODE_VALUE"
    SET display_id = temp->flex[xtempnum].admit_booking_code[xminortempnum].admit_booking_code_cd
    SET display_mean = temp->flex[xtempnum].admit_booking_code[xminortempnum].admit_booking_code_mean
    SET display_table = "CODE_VALUE"
   ENDIF
   INSERT  FROM sch_flex_list s
    SET s.seq = 1, s.sch_flex_id = temp->flex[xtempnum].sch_flex_id, s.flex_orient_cd =
     flex_orient_cd,
     s.seq_nbr = temp->flex[xtempnum].sequence, s.version_dt_tm = cnvtdatetime(
      "31-DEC-2100 00:00:00.00"), s.flex_orient_meaning = "INFIX",
     s.flex_token_cd = token_cd, s.flex_token_meaning = token_mean, s.token_type_cd = token_type_cd,
     s.token_type_meaning = token_type_mean, s.data_type_cd = data_type_cd, s.data_type_meaning =
     data_type_mean,
     s.flex_eval_cd = flex_eval_cd, s.flex_eval_meaning = flex_eval_mean, s.precedence = precedence,
     s.string_value = string_value, s.dynamic_text = dynamic_text, s.oe_field_id = 0.0,
     s.double_value = double_value, s.null_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), s
     .candidate_id = seq(sch_candidate_seq,nextval),
     s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100 00:00:00.00"), s.active_ind = 1,
     s.active_status_cd = active_cd, s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s
     .active_status_prsnl_id = 0,
     s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_applctx = 0, s.updt_id = 0,
     s.updt_cnt = 0, s.updt_task = 0, s.data_source_cd = data_source_cd,
     s.data_source_meaning = data_source_mean, s.parent_id = parent_id, s.parent_table = parent_table,
     s.parent_meaning = parent_mean, s.display_id = display_id, s.display_table = display_table,
     s.display_meaning = display_mean, s.font_size = 0, s.bold = 0,
     s.italic = 0, s.strikethru = 0, s.underline = 0,
     s.offset_units = offset_units, s.offset_units_cd = offset_units_cd, s.offset_units_meaning =
     offset_units_mean,
     s.filter_table = filter_table, s.filter_id = filter_id
    WITH nocounter
   ;end insert
   SET temp->flex[xtempnum].sequence = (temp->flex[xtempnum].sequence+ 1)
   RETURN
 END ;Subroutine
 SUBROUTINE logstart(xtitle,xname)
   DECLARE dir_name = vc
   SET dir_name = "ccluserdir:"
   SET log_name = concat(trim(dir_name),xname)
   SET logvar = 0
   SELECT INTO value(log_name)
    logvar
    HEAD REPORT
     begin_dt_tm"dd-mmm-yyyy;;d", "-", begin_dt_tm"hh:mm:ss;;m",
     col + 1, xtitle, row + 1
    DETAIL
     row + 2, col 10, "ROW",
     col 20, "RULE NAME", col 40,
     "TOKEN", col 60, "OPERATOR",
     col 73, "VALUE", col 90,
     "STATUS", col 100, "ERROR"
    WITH nocounter, format = variable, noformfeed,
     maxcol = 132, maxrow = 1
   ;end select
   RETURN
 END ;Subroutine
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
END GO

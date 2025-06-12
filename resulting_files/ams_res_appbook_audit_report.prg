CREATE PROGRAM ams_res_appbook_audit_report
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Entity Name" = ""
  WITH outdev, ename
 IF (validate(action_none,- (1)) != 0)
  DECLARE action_none = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(action_add,- (1)) != 1)
  DECLARE action_add = i2 WITH protect, noconstant(1)
 ENDIF
 IF (validate(action_chg,- (1)) != 2)
  DECLARE action_chg = i2 WITH protect, noconstant(2)
 ENDIF
 IF (validate(action_del,- (1)) != 3)
  DECLARE action_del = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(action_get,- (1)) != 4)
  DECLARE action_get = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(action_ina,- (1)) != 5)
  DECLARE action_ina = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(action_act,- (1)) != 6)
  DECLARE action_act = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(action_temp,- (1)) != 999)
  DECLARE action_temp = i2 WITH protect, noconstant(999)
 ENDIF
 IF (validate(true,- (1)) != 1)
  DECLARE true = i2 WITH protect, noconstant(1)
 ENDIF
 IF (validate(false,- (1)) != 0)
  DECLARE false = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(gen_nbr_error,- (1)) != 3)
  DECLARE gen_nbr_error = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(insert_error,- (1)) != 4)
  DECLARE insert_error = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(update_error,- (1)) != 5)
  DECLARE update_error = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(replace_error,- (1)) != 6)
  DECLARE replace_error = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(delete_error,- (1)) != 7)
  DECLARE delete_error = i2 WITH protect, noconstant(7)
 ENDIF
 IF (validate(undelete_error,- (1)) != 8)
  DECLARE undelete_error = i2 WITH protect, noconstant(8)
 ENDIF
 IF (validate(remove_error,- (1)) != 9)
  DECLARE remove_error = i2 WITH protect, noconstant(9)
 ENDIF
 IF (validate(attribute_error,- (1)) != 10)
  DECLARE attribute_error = i2 WITH protect, noconstant(10)
 ENDIF
 IF (validate(lock_error,- (1)) != 11)
  DECLARE lock_error = i2 WITH protect, noconstant(11)
 ENDIF
 IF (validate(none_found,- (1)) != 12)
  DECLARE none_found = i2 WITH protect, noconstant(12)
 ENDIF
 IF (validate(select_error,- (1)) != 13)
  DECLARE select_error = i2 WITH protect, noconstant(13)
 ENDIF
 IF (validate(update_cnt_error,- (1)) != 14)
  DECLARE update_cnt_error = i2 WITH protect, noconstant(14)
 ENDIF
 IF (validate(not_found,- (1)) != 15)
  DECLARE not_found = i2 WITH protect, noconstant(15)
 ENDIF
 IF (validate(version_insert_error,- (1)) != 16)
  DECLARE version_insert_error = i2 WITH protect, noconstant(16)
 ENDIF
 IF (validate(inactivate_error,- (1)) != 17)
  DECLARE inactivate_error = i2 WITH protect, noconstant(17)
 ENDIF
 IF (validate(activate_error,- (1)) != 18)
  DECLARE activate_error = i2 WITH protect, noconstant(18)
 ENDIF
 IF (validate(version_delete_error,- (1)) != 19)
  DECLARE version_delete_error = i2 WITH protect, noconstant(19)
 ENDIF
 IF (validate(uar_error,- (1)) != 20)
  DECLARE uar_error = i2 WITH protect, noconstant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 IF (validate(failed,- (1)) != 0)
  DECLARE failed = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH protect, noconstant("")
 ELSE
  SET table_name = fillstring(100," ")
 ENDIF
 IF (validate(call_echo_ind,- (1)) != 0)
  DECLARE call_echo_ind = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(i_version,- (1)) != 0)
  DECLARE i_version = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(program_name,"ZZZ")="ZZZ")
  DECLARE program_name = vc WITH protect, noconstant(fillstring(30," "))
 ENDIF
 IF (validate(sch_security_id,- (1)) != 0)
  DECLARE sch_security_id = f8 WITH protect, noconstant(0.0)
 ENDIF
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 IF (validate(schuar_def,999)=999)
  CALL echo("Declaring schuar_def")
  DECLARE schuar_def = i2 WITH persist
  SET schuar_def = 1
  DECLARE uar_sch_check_security(sec_type_cd=f8(ref),parent1_id=f8(ref),parent2_id=f8(ref),parent3_id
   =f8(ref),sec_id=f8(ref),
   user_id=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix = "libshrschuar.a(libshrschuar.o)",
  uar = "uar_sch_check_security",
  persist
  DECLARE uar_sch_security_insert(user_id=f8(ref),sec_type_cd=f8(ref),parent1_id=f8(ref),parent2_id=
   f8(ref),parent3_id=f8(ref),
   sec_id=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix = "libshrschuar.a(libshrschuar.o)",
  uar = "uar_sch_security_insert",
  persist
  DECLARE uar_sch_security_perform() = i4 WITH image_axp = "shrschuar", image_aix =
  "libshrschuar.a(libshrschuar.o)", uar = "uar_sch_security_perform",
  persist
  DECLARE uar_sch_check_security_ex(user_id=f8(ref),sec_type_cd=f8(ref),parent1_id=f8(ref),parent2_id
   =f8(ref),parent3_id=f8(ref),
   sec_id=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix = "libshrschuar.a(libshrschuar.o)",
  uar = "uar_sch_check_security_ex",
  persist
  DECLARE uar_sch_check_security_ex2(user_id=f8(ref),sec_type_cd=f8(ref),parent1_id=f8(ref),
   parent2_id=f8(ref),parent3_id=f8(ref),
   sec_id=f8(ref),position_cd=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix =
  "libshrschuar.a(libshrschuar.o)", uar = "uar_sch_check_security_ex2",
  persist
  DECLARE uar_sch_security_insert_ex2(user_id=f8(ref),sec_type_cd=f8(ref),parent1_id=f8(ref),
   parent2_id=f8(ref),parent3_id=f8(ref),
   sec_id=f8(ref),position_cd=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix =
  "libshrschuar.a(libshrschuar.o)", uar = "uar_sch_security_insert_ex2",
  persist
 ENDIF
 IF ( NOT (validate(format_text_request,0)))
  RECORD format_text_request(
    1 call_echo_ind = i2
    1 raw_text = vc
    1 temp_str = vc
    1 chars_per_line = i4
  )
 ENDIF
 IF ( NOT (validate(format_text_reply,0)))
  RECORD format_text_reply(
    1 beg_index = i4
    1 end_index = i4
    1 temp_index = i4
    1 qual_alloc = i4
    1 qual_cnt = i4
    1 qual[*]
      2 text_string = vc
  )
 ENDIF
 SET format_text_reply->qual_cnt = 0
 SET format_text_reply->qual_alloc = 0
 FREE SET t_record
 RECORD t_record(
   1 entity_id = f8
   1 file_name = vc
   1 printed_by_id = f8
   1 printed_by_name = vc
   1 printed_by_size = i4
   1 qual_cnt = i4
   1 qual[*]
     2 disp_scheme_id = f8
     2 mnemonic = vc
     2 description = vc
     2 info_sch_text_id = f8
     2 comments = vc
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_name = vc
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_desc = vc
     2 active_status_size = i4
     2 active_dt_tm = dq8
     2 active_prsnl_id = f8
     2 active_prsnl_name = vc
     2 max_active_size = i4
     2 appt_book_qual_cnt = i4
     2 appt_book_qual[*]
       3 appt_book_id = f8
       3 mnemonic = c30
       3 active_status_cd = f8
       3 active_status_desc = c30
       3 active_status_size = i4
     2 appt_state_qual_cnt = i4
     2 appt_state_qual[*]
       3 sch_state_cd = f8
       3 mnemonic = c30
       3 active_status_cd = f8
       3 active_status_desc = c30
       3 active_status_size = i4
     2 def_slot_qual_cnt = i4
     2 def_slot_qual[*]
       3 def_slot_id = f8
       3 mnemonic = c30
       3 active_status_cd = f8
       3 active_status_desc = c30
       3 active_status_size = i4
     2 slot_type_qual_cnt = i4
     2 slot_type_qual[*]
       3 slot_type_id = f8
       3 mnemonic = c30
       3 active_status_cd = f8
       3 active_status_desc = c30
       3 active_status_size = i4
   1 field_start_column = i4
   1 field_column_size = i4
   1 report_left_margin = i4
   1 report_right_margin = i4
   1 report_size = i4
   1 max_prompt_size = i4
   1 prompt_qual_cnt = i4
   1 prompt_qual[*]
     2 prompt_string = c40
     2 prompt_size = i4
   1 blank_line = c132
   1 dash_line = c132
 )
 SET t_record->file_name =  $1
 SET t_record->entity_id = cnvtreal( $2)
 SET t_record->qual_cnt = 0
 SET t_record->prompt_qual_cnt = 0
 SET t_record->report_left_margin = 0
 SET t_record->report_right_margin = 132
 SET t_record->report_size = ((t_record->report_right_margin - t_record->report_left_margin) - 1)
 SET t_record->max_prompt_size = 0
 SET t_record->blank_line = fillstring(132," ")
 SET t_record->dash_line = fillstring(132,"-")
 SET t_record->printed_by_id = reqinfo->updt_id
 IF ((t_record->printed_by_id > 0))
  SELECT INTO "nl:"
   a.name_full_formatted
   FROM prsnl p
   PLAN (p
    WHERE (p.person_id=t_record->printed_by_id))
   DETAIL
    t_record->printed_by_name = p.name_full_formatted
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET t_record->printed_by_name = concat("Person ",trim(format(t_record->printed_by_id,";l;i")),
    " not found")
  ENDIF
 ELSE
  SET t_record->printed_by_name = "UNKNOWN"
 ENDIF
 SET t_record->printed_by_size = size(trim(t_record->printed_by_name))
 IF ( NOT (validate(generic_print_request,0)))
  RECORD generic_print_request(
    1 call_echo_ind = i2
    1 file_name = c30
    1 lines_per_page = i4
    1 grouping_ind = i2
    1 char_per_line = i4
    1 page_num_string = vc
    1 continue_string = vc
    1 end_report_string = vc
    1 header_qual_cnt = i4
    1 header_qual[*]
      2 header_string = vc
      2 header_type_flag = i2
    1 footer_qual_cnt = i4
    1 footer_qual[*]
      2 footer_string = vc
      2 footer_type_flag = i2
    1 data_qual_cnt = i4
    1 data_qual[*]
      2 data_string = vc
      2 beg_group_ind = i2
      2 lines_in_group = i4
      2 skip_separator_ind = i2
    1 separator_qual_cnt = i4
    1 separator_qual[*]
      2 separator_string = vc
  )
 ENDIF
 IF ( NOT (validate(generic_print_reply,0)))
  RECORD generic_print_reply(
    1 status = i2
  )
 ENDIF
 SET generic_print_request->header_qual_cnt = 0
 SET stat = alterlist(generic_print_request->header_qual,generic_print_request->header_qual_cnt)
 SET generic_print_request->footer_qual_cnt = 0
 SET stat = alterlist(generic_print_request->footer_qual,generic_print_request->footer_qual_cnt)
 SET generic_print_request->data_qual_cnt = 0
 SET stat = alterlist(generic_print_request->data_qual,generic_print_request->data_qual_cnt)
 SET generic_print_request->separator_qual_cnt = 0
 SET stat = alterlist(generic_print_request->separator_qual,generic_print_request->separator_qual_cnt
  )
 SET generic_print_request->page_num_string = "Page: ###"
 CALL center_page_num(1)
 SET generic_print_request->continue_string = "<* Continued *>"
 CALL center_continue(1)
 SET generic_print_request->end_report_string = "<* End of Report *>"
 CALL center_end_report(1)
 CALL inc_header(1)
 SET generic_print_request->header_qual[generic_print_request->header_qual_cnt].header_string =
 concat("AS OF: ",format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME"))
 CALL right_header(1)
 SET stat = movestring("BY:",1,generic_print_request->header_qual[generic_print_request->
  header_qual_cnt].header_string,1,3)
 SET stat = movestring(t_record->printed_by_name,1,generic_print_request->header_qual[
  generic_print_request->header_qual_cnt].header_string,5,t_record->printed_by_size)
 CALL inc_header(1)
 SET generic_print_request->header_qual[generic_print_request->header_qual_cnt].header_string =
 "Database Audit Report"
 CALL center_header(1)
 CALL inc_header(1)
 SET generic_print_request->header_qual[generic_print_request->header_qual_cnt].header_string =
 "Disp Scheme  Listing"
 CALL center_header(1)
 CALL inc_header(1)
 SET generic_print_request->header_qual[generic_print_request->header_qual_cnt].header_string = " "
 CALL inc_header(1)
 SET generic_print_request->header_qual[generic_print_request->header_qual_cnt].header_string =
 substring(1,t_record->report_size,fillstring(132,"="))
 CALL inc_footer(1)
 SET generic_print_request->footer_qual[generic_print_request->footer_qual_cnt].footer_string = " "
 SET generic_print_request->footer_qual[generic_print_request->footer_qual_cnt].footer_type_flag = 2
 CALL inc_footer(1)
 SET generic_print_request->footer_qual[generic_print_request->footer_qual_cnt].footer_string = " "
 SET generic_print_request->footer_qual[generic_print_request->footer_qual_cnt].footer_type_flag = 1
 CALL inc_separator(1)
 SET generic_print_request->separator_qual[generic_print_request->separator_qual_cnt].
 separator_string = substring(1,t_record->report_size,fillstring(132,"-"))
 CALL inc_prompt(1)
 SET t_record->prompt_qual[t_record->prompt_qual_cnt].prompt_string = "Mnemonic:"
 CALL inc_prompt(1)
 SET t_record->prompt_qual[t_record->prompt_qual_cnt].prompt_string = "Description:"
 CALL inc_prompt(1)
 SET t_record->prompt_qual[t_record->prompt_qual_cnt].prompt_string = "Comments:"
 CALL inc_prompt(1)
 SET t_record->prompt_qual[t_record->prompt_qual_cnt].prompt_string = "Active Status:"
 CALL inc_prompt(1)
 SET t_record->prompt_qual[t_record->prompt_qual_cnt].prompt_string = "Last Update:"
 CALL inc_prompt(1)
 SET t_record->prompt_qual[t_record->prompt_qual_cnt].prompt_string = "Appt Books:"
 CALL inc_prompt(1)
 SET t_record->prompt_qual[t_record->prompt_qual_cnt].prompt_string = "Appt States:"
 CALL inc_prompt(1)
 SET t_record->prompt_qual[t_record->prompt_qual_cnt].prompt_string = "Def Slots:"
 CALL inc_prompt(1)
 SET t_record->prompt_qual[t_record->prompt_qual_cnt].prompt_string = "Slot Types:"
 CALL sync_prompt(1)
 FOR (i = 1 TO t_record->prompt_qual_cnt)
  SET t_record->prompt_qual[i].prompt_size = size(trim(t_record->prompt_qual[i].prompt_string))
  IF ((t_record->prompt_qual[i].prompt_size > t_record->max_prompt_size))
   SET t_record->max_prompt_size = t_record->prompt_qual[i].prompt_size
  ENDIF
 ENDFOR
 SET t_record->max_prompt_size = (t_record->max_prompt_size+ 1)
 SET t_record->field_start_column = ((t_record->report_left_margin+ t_record->max_prompt_size)+ 1)
 SET t_record->field_column_size = (t_record->report_right_margin - t_record->field_start_column)
 SET entity = evaluate(t_record->entity_id,0.0,"a.disp_scheme_id > 0",
  "a.disp_scheme_id = t_record->entity_id")
 SELECT INTO "nl:"
  a.disp_scheme_id
  FROM sch_disp_scheme a,
   long_text_reference l
  PLAN (a
   WHERE parser(entity)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (l
   WHERE l.long_text_id=a.info_sch_text_id)
  HEAD REPORT
   t_record->qual_cnt = 0
  DETAIL
   t_record->qual_cnt = (t_record->qual_cnt+ 1)
   IF (mod(t_record->qual_cnt,100)=1)
    stat = alterlist(t_record->qual,(t_record->qual_cnt+ 99))
   ENDIF
   t_record->qual[t_record->qual_cnt].disp_scheme_id = a.disp_scheme_id, t_record->qual[t_record->
   qual_cnt].mnemonic = a.mnemonic, t_record->qual[t_record->qual_cnt].description = a.description,
   t_record->qual[t_record->qual_cnt].info_sch_text_id = a.info_sch_text_id
   IF (a.info_sch_text_id > 0)
    t_record->qual[t_record->qual_cnt].comments = l.long_text
   ELSE
    t_record->qual[t_record->qual_cnt].comments = ""
   ENDIF
   t_record->qual[t_record->qual_cnt].updt_dt_tm = a.updt_dt_tm, t_record->qual[t_record->qual_cnt].
   updt_id = a.updt_id
   IF ((t_record->qual[t_record->qual_cnt].updt_id > 0))
    t_record->qual[t_record->qual_cnt].updt_name = concat("Person ",trim(format(t_record->qual[
       t_record->qual_cnt].updt_id,";l;i"))," not found")
   ELSE
    t_record->qual[t_record->qual_cnt].updt_name = "NOT ASSOCIATED"
   ENDIF
   t_record->qual[t_record->qual_cnt].active_ind = a.active_ind, t_record->qual[t_record->qual_cnt].
   active_status_cd = a.active_status_cd
   IF ((t_record->qual[t_record->qual_cnt].active_status_cd > 0))
    t_record->qual[t_record->qual_cnt].active_status_desc = uar_get_code_display(a.active_status_cd)
    IF ((t_record->qual[t_record->qual_cnt].active_status_desc <= " "))
     t_record->qual[t_record->qual_cnt].active_status_desc = concat("Code_value ",trim(format(
        t_record->qual[t_record->qual_cnt].active_status_cd,";l;i"))," not found")
    ENDIF
   ELSE
    t_record->qual[t_record->qual_cnt].active_status_desc = "NOT ASSOCIATED"
   ENDIF
   t_record->qual[t_record->qual_cnt].active_status_size = size(trim(t_record->qual[t_record->
     qual_cnt].active_status_desc)), t_record->qual[t_record->qual_cnt].active_dt_tm = a
   .active_status_dt_tm, t_record->qual[t_record->qual_cnt].active_prsnl_id = a
   .active_status_prsnl_id
   IF ((t_record->qual[t_record->qual_cnt].active_prsnl_id > 0))
    t_record->qual[t_record->qual_cnt].active_prsnl_name = concat("Person ",trim(format(t_record->
       qual[t_record->qual_cnt].active_prsnl_id,";l;i"))," not found")
   ELSE
    t_record->qual[t_record->qual_cnt].active_prsnl_name = "NOT ASSOCIATED"
   ENDIF
   t_record->qual[t_record->qual_cnt].appt_book_qual_cnt = 0, t_record->qual[t_record->qual_cnt].
   appt_state_qual_cnt = 0, t_record->qual[t_record->qual_cnt].def_slot_qual_cnt = 0,
   t_record->qual[t_record->qual_cnt].slot_type_qual_cnt = 0, t_record->qual[t_record->qual_cnt].
   max_active_size = 0
  WITH nocounter
 ;end select
 IF ((t_record->qual_cnt=0))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  a.name_full_formatted
  FROM (dummyt d  WITH seq = value(t_record->qual_cnt)),
   prsnl a
  PLAN (d
   WHERE (t_record->qual[d.seq].updt_id > 0))
   JOIN (a
   WHERE (a.person_id=t_record->qual[d.seq].updt_id))
  DETAIL
   t_record->qual[d.seq].updt_name = a.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.name_full_formatted
  FROM (dummyt d  WITH seq = value(t_record->qual_cnt)),
   prsnl a
  PLAN (d
   WHERE (t_record->qual[d.seq].active_prsnl_id > 0))
   JOIN (a
   WHERE (a.person_id=t_record->qual[d.seq].active_prsnl_id))
  DETAIL
   t_record->qual[d.seq].active_prsnl_name = a.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  b.mnemonic
  FROM (dummyt d  WITH seq = value(t_record->qual_cnt)),
   sch_appt_book b
  PLAN (d)
   JOIN (b
   WHERE (b.disp_scheme_id=t_record->qual[d.seq].disp_scheme_id)
    AND b.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  ORDER BY d.seq, b.mnemonic_key
  HEAD d.seq
   t_record->qual[d.seq].appt_book_qual_cnt = 0
  DETAIL
   t_record->qual[d.seq].appt_book_qual_cnt = (t_record->qual[d.seq].appt_book_qual_cnt+ 1)
   IF (mod(t_record->qual[d.seq].appt_book_qual_cnt,10)=1)
    stat = alterlist(t_record->qual[d.seq].appt_book_qual,(t_record->qual[d.seq].appt_book_qual_cnt+
     9))
   ENDIF
   t_record->qual[d.seq].appt_book_qual[t_record->qual[d.seq].appt_book_qual_cnt].appt_book_id = b
   .appt_book_id, t_record->qual[d.seq].appt_book_qual[t_record->qual[d.seq].appt_book_qual_cnt].
   mnemonic = b.mnemonic, t_record->qual[d.seq].appt_book_qual[t_record->qual[d.seq].
   appt_book_qual_cnt].active_status_cd = b.active_status_cd
   IF ((t_record->qual[d.seq].appt_book_qual[t_record->qual[d.seq].appt_book_qual_cnt].
   active_status_cd > 0))
    t_record->qual[d.seq].appt_book_qual[t_record->qual[d.seq].appt_book_qual_cnt].active_status_desc
     = uar_get_code_display(b.active_status_cd)
    IF ((t_record->qual[d.seq].appt_book_qual[t_record->qual[d.seq].appt_book_qual_cnt].
    active_status_desc <= " "))
     t_record->qual[d.seq].appt_book_qual[t_record->qual[d.seq].appt_book_qual_cnt].
     active_status_desc = concat("Code_value  ",trim(format(t_record->qual[d.seq].appt_book_qual[
        t_record->qual[d.seq].appt_book_qual_cnt].active_status_cd,";l;i"))," not found")
    ENDIF
   ELSE
    t_record->qual[d.seq].appt_book_qual[t_record->qual[d.seq].appt_book_qual_cnt].active_status_desc
     = "NOT ASSOCIATED"
   ENDIF
   t_record->qual[d.seq].appt_book_qual[t_record->qual[d.seq].appt_book_qual_cnt].active_status_size
    = size(trim(t_record->qual[d.seq].appt_book_qual[t_record->qual[d.seq].appt_book_qual_cnt].
     active_status_desc))
   IF ((t_record->qual[d.seq].appt_book_qual[t_record->qual[d.seq].appt_book_qual_cnt].
   active_status_size > t_record->qual[d.seq].max_active_size))
    t_record->qual[d.seq].max_active_size = t_record->qual[d.seq].appt_book_qual[t_record->qual[d.seq
    ].appt_book_qual_cnt].active_status_size
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.mnemonic
  FROM (dummyt d  WITH seq = value(t_record->qual_cnt)),
   sch_appt_state a
  PLAN (d)
   JOIN (a
   WHERE (a.disp_scheme_id=t_record->qual[d.seq].disp_scheme_id)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  ORDER BY d.seq
  HEAD d.seq
   t_record->qual[d.seq].appt_state_qual_cnt = 0
  DETAIL
   t_record->qual[d.seq].appt_state_qual_cnt = (t_record->qual[d.seq].appt_state_qual_cnt+ 1)
   IF (mod(t_record->qual[d.seq].appt_state_qual_cnt,10)=1)
    stat = alterlist(t_record->qual[d.seq].appt_state_qual,(t_record->qual[d.seq].appt_state_qual_cnt
     + 9))
   ENDIF
   t_record->qual[d.seq].appt_state_qual[t_record->qual[d.seq].appt_state_qual_cnt].sch_state_cd = a
   .sch_state_cd
   IF ((t_record->qual[d.seq].appt_state_qual[t_record->qual[d.seq].appt_state_qual_cnt].sch_state_cd
    > 0))
    t_record->qual[d.seq].appt_state_qual[t_record->qual[d.seq].appt_state_qual_cnt].mnemonic =
    uar_get_code_display(a.sch_state_cd)
    IF ((t_record->qual[d.seq].appt_state_qual[t_record->qual[d.seq].appt_state_qual_cnt].mnemonic
     <= " "))
     t_record->qual[d.seq].appt_state_qual[t_record->qual[d.seq].appt_state_qual_cnt].mnemonic =
     concat("Code_value  ",trim(format(t_record->qual[d.seq].appt_state_qual[t_record->qual[d.seq].
        appt_state_qual_cnt].sch_state_cd,";l;i"))," not found")
    ENDIF
   ELSE
    t_record->qual[d.seq].appt_state_qual[t_record->qual[d.seq].appt_state_qual_cnt].mnemonic =
    "NOT ASSOCIATED"
   ENDIF
   t_record->qual[d.seq].appt_state_qual[t_record->qual[d.seq].appt_state_qual_cnt].active_status_cd
    = a.active_status_cd
   IF ((t_record->qual[d.seq].appt_state_qual[t_record->qual[d.seq].appt_state_qual_cnt].
   active_status_cd > 0))
    t_record->qual[d.seq].appt_state_qual[t_record->qual[d.seq].appt_state_qual_cnt].
    active_status_desc = uar_get_code_display(a.active_status_cd)
    IF ((t_record->qual[d.seq].appt_state_qual[t_record->qual[d.seq].appt_state_qual_cnt].
    active_status_desc <= " "))
     t_record->qual[d.seq].appt_state_qual[t_record->qual[d.seq].appt_state_qual_cnt].
     active_status_desc = concat("Code_value  ",trim(format(t_record->qual[d.seq].appt_state_qual[
        t_record->qual[d.seq].appt_state_qual_cnt].active_status_cd,";l;i"))," not found")
    ENDIF
   ELSE
    t_record->qual[d.seq].appt_state_qual[t_record->qual[d.seq].appt_state_qual_cnt].
    active_status_desc = "NOT ASSOCIATED"
   ENDIF
   t_record->qual[d.seq].appt_state_qual[t_record->qual[d.seq].appt_state_qual_cnt].
   active_status_size = size(trim(t_record->qual[d.seq].appt_state_qual[t_record->qual[d.seq].
     appt_state_qual_cnt].active_status_desc))
   IF ((t_record->qual[d.seq].appt_state_qual[t_record->qual[d.seq].appt_state_qual_cnt].
   active_status_size > t_record->qual[d.seq].max_active_size))
    t_record->qual[d.seq].max_active_size = t_record->qual[d.seq].appt_state_qual[t_record->qual[d
    .seq].appt_state_qual_cnt].active_status_size
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.def_slot_id
  FROM (dummyt d  WITH seq = value(t_record->qual_cnt)),
   sch_def_slot a
  PLAN (d)
   JOIN (a
   WHERE (a.slot_scheme_id=t_record->qual[d.seq].disp_scheme_id)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  ORDER BY d.seq
  HEAD d.seq
   t_record->qual[d.seq].def_slot_qual_cnt = 0
  DETAIL
   t_record->qual[d.seq].def_slot_qual_cnt = (t_record->qual[d.seq].def_slot_qual_cnt+ 1)
   IF (mod(t_record->qual[d.seq].def_slot_qual_cnt,10)=1)
    stat = alterlist(t_record->qual[d.seq].def_slot_qual,(t_record->qual[d.seq].def_slot_qual_cnt+ 9)
     )
   ENDIF
   t_record->qual[d.seq].def_slot_qual[t_record->qual[d.seq].def_slot_qual_cnt].def_slot_id = a
   .def_slot_id, t_record->qual[d.seq].def_slot_qual[t_record->qual[d.seq].def_slot_qual_cnt].
   mnemonic = a.slot_mnemonic, t_record->qual[d.seq].def_slot_qual[t_record->qual[d.seq].
   def_slot_qual_cnt].active_status_cd = a.active_status_cd
   IF ((t_record->qual[d.seq].def_slot_qual[t_record->qual[d.seq].def_slot_qual_cnt].active_status_cd
    > 0))
    t_record->qual[d.seq].def_slot_qual[t_record->qual[d.seq].def_slot_qual_cnt].active_status_desc
     = uar_get_code_display(a.active_status_cd)
    IF ((t_record->qual[d.seq].def_slot_qual[t_record->qual[d.seq].def_slot_qual_cnt].
    active_status_desc <= " "))
     t_record->qual[d.seq].def_slot_qual[t_record->qual[d.seq].def_slot_qual_cnt].active_status_desc
      = concat("Code_value  ",trim(format(t_record->qual[d.seq].def_slot_qual[t_record->qual[d.seq].
        def_slot_qual_cnt].active_status_cd,";l;i"))," not found")
    ENDIF
   ELSE
    t_record->qual[d.seq].def_slot_qual[t_record->qual[d.seq].def_slot_qual_cnt].active_status_desc
     = "NOT ASSOCIATED"
   ENDIF
   t_record->qual[d.seq].def_slot_qual[t_record->qual[d.seq].def_slot_qual_cnt].active_status_size =
   size(trim(t_record->qual[d.seq].def_slot_qual[t_record->qual[d.seq].def_slot_qual_cnt].
     active_status_desc))
   IF ((t_record->qual[d.seq].def_slot_qual[t_record->qual[d.seq].def_slot_qual_cnt].
   active_status_size > t_record->qual[d.seq].max_active_size))
    t_record->qual[d.seq].max_active_size = t_record->qual[d.seq].def_slot_qual[t_record->qual[d.seq]
    .def_slot_qual_cnt].active_status_size
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.slot_type_id
  FROM (dummyt d  WITH seq = value(t_record->qual_cnt)),
   sch_slot_type a
  PLAN (d)
   JOIN (a
   WHERE (a.disp_scheme_id=t_record->qual[d.seq].disp_scheme_id)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  ORDER BY d.seq, a.mnemonic_key
  HEAD d.seq
   t_record->qual[d.seq].slot_type_qual_cnt = 0
  DETAIL
   t_record->qual[d.seq].slot_type_qual_cnt = (t_record->qual[d.seq].slot_type_qual_cnt+ 1)
   IF (mod(t_record->qual[d.seq].slot_type_qual_cnt,10)=1)
    stat = alterlist(t_record->qual[d.seq].slot_type_qual,(t_record->qual[d.seq].slot_type_qual_cnt+
     9))
   ENDIF
   t_record->qual[d.seq].slot_type_qual[t_record->qual[d.seq].slot_type_qual_cnt].slot_type_id = a
   .slot_type_id, t_record->qual[d.seq].slot_type_qual[t_record->qual[d.seq].slot_type_qual_cnt].
   mnemonic = a.mnemonic, t_record->qual[d.seq].slot_type_qual[t_record->qual[d.seq].
   slot_type_qual_cnt].active_status_cd = a.active_status_cd
   IF ((t_record->qual[d.seq].slot_type_qual[t_record->qual[d.seq].slot_type_qual_cnt].
   active_status_cd > 0))
    t_record->qual[d.seq].slot_type_qual[t_record->qual[d.seq].slot_type_qual_cnt].active_status_desc
     = uar_get_code_display(a.active_status_cd)
    IF ((t_record->qual[d.seq].slot_type_qual[t_record->qual[d.seq].slot_type_qual_cnt].
    active_status_desc <= " "))
     t_record->qual[d.seq].slot_type_qual[t_record->qual[d.seq].slot_type_qual_cnt].
     active_status_desc = concat("Code_value  ",trim(format(t_record->qual[d.seq].slot_type_qual[
        t_record->qual[d.seq].slot_type_qual_cnt].active_status_cd,";l;i"))," not found")
    ENDIF
   ELSE
    t_record->qual[d.seq].slot_type_qual[t_record->qual[d.seq].slot_type_qual_cnt].active_status_desc
     = "NOT ASSOCIATED"
   ENDIF
   t_record->qual[d.seq].slot_type_qual[t_record->qual[d.seq].slot_type_qual_cnt].active_status_size
    = size(trim(t_record->qual[d.seq].slot_type_qual[t_record->qual[d.seq].slot_type_qual_cnt].
     active_status_desc))
   IF ((t_record->qual[d.seq].slot_type_qual[t_record->qual[d.seq].slot_type_qual_cnt].
   active_status_size > t_record->qual[d.seq].max_active_size))
    t_record->qual[d.seq].max_active_size = t_record->qual[d.seq].slot_type_qual[t_record->qual[d.seq
    ].slot_type_qual_cnt].active_status_size
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("t_record->qual_cnt = ",t_record->qual_cnt))
 FOR (i = 1 TO t_record->qual_cnt)
   CALL echo(build("   t_record->qual[",i,"]->disp_scheme_id = ",t_record->qual[i].disp_scheme_id))
   CALL echo(build("   t_record->qual[",i,"]->mnemonic = ",t_record->qual[i].mnemonic))
   CALL echo(build("   t_record->qual[",i,"]->description = ",t_record->qual[i].description))
   CALL echo(build("   t_record->qual[",i,"]->info_sch_text_id = ",t_record->qual[i].info_sch_text_id
     ))
   CALL echo(build("   t_record->qual[",i,"]->comments = ",t_record->qual[i].comments))
   CALL echo(build("   t_record->qual[",i,"]->updt_dt_tm = ",format(t_record->qual[i].updt_dt_tm,
      ";;q")))
   CALL echo(build("   t_record->qual[",i,"]->updt_id = ",t_record->qual[i].updt_id))
   CALL echo(build("   t_record->qual[",i,"]->updt_name = ",t_record->qual[i].updt_name))
   CALL echo(build("   t_record->qual[",i,"]->active_ind = ",t_record->qual[i].active_ind))
   CALL echo(build("   t_record->qual[",i,"]->active_status_cd = ",t_record->qual[i].active_status_cd
     ))
   CALL echo(build("   t_record->qual[",i,"]->active_status_desc = ",t_record->qual[i].
     active_status_desc))
   CALL echo(build("   t_record->qual[",i,"]->active_dt_tm = ",format(t_record->qual[i].active_dt_tm,
      ";;q")))
   CALL echo(build("   t_record->qual[",i,"]->active_prsnl_id = ",t_record->qual[i].active_prsnl_id))
   CALL echo(build("   t_record->qual[",i,"]->active_prsnl_name = ",t_record->qual[i].
     active_prsnl_name))
   CALL echo(build("   t_record->qual[",i,"]->max_active_size = ",t_record->qual[i].max_active_size))
   CALL echo(build("   t_record->qual[",i,"]->appt_book_qual_cnt = ",t_record->qual[i].
     appt_book_qual_cnt))
   FOR (j = 1 TO t_record->qual[i].appt_book_qual_cnt)
     CALL echo(build("   t_record->qual[",i,",",j,"]->appt_book_id = ",
       t_record->qual[i].appt_book_qual[j].appt_book_id))
     CALL echo(build("   t_record->qual[",i,",",j,"]->mnemonic = ",
       t_record->qual[i].appt_book_qual[j].mnemonic))
     CALL echo(build("   t_record->qual[",i,",",j,"]->active_status_cd = ",
       t_record->qual[i].appt_book_qual[j].active_status_cd))
     CALL echo(build("   t_record->qual[",i,",",j,"]->active_status_desc = ",
       t_record->qual[i].appt_book_qual[j].active_status_desc))
   ENDFOR
   CALL echo(build("   t_record->qual[",i,"]->appt_state_qual_cnt = ",t_record->qual[i].
     appt_state_qual_cnt))
   FOR (j = 1 TO t_record->qual[i].appt_state_qual_cnt)
     CALL echo(build("   t_record->qual[",i,",",j,"]->sch_state_cd = ",
       t_record->qual[i].appt_state_qual[j].sch_state_cd))
     CALL echo(build("   t_record->qual[",i,",",j,"]->mnemonic = ",
       t_record->qual[i].appt_state_qual[j].mnemonic))
     CALL echo(build("   t_record->qual[",i,",",j,"]->active_status_cd = ",
       t_record->qual[i].appt_state_qual[j].active_status_cd))
     CALL echo(build("   t_record->qual[",i,",",j,"]->active_status_desc = ",
       t_record->qual[i].appt_state_qual[j].active_status_desc))
   ENDFOR
   CALL echo(build("   t_record->qual[",i,"]->def_slot_qual_cnt = ",t_record->qual[i].
     def_slot_qual_cnt))
   FOR (j = 1 TO t_record->qual[i].def_slot_qual_cnt)
     CALL echo(build("   t_record->qual[",i,",",j,"]->def_slot_id = ",
       t_record->qual[i].def_slot_qual[j].def_slot_id))
     CALL echo(build("   t_record->qual[",i,",",j,"]->mnemonic = ",
       t_record->qual[i].def_slot_qual[j].mnemonic))
     CALL echo(build("   t_record->qual[",i,",",j,"]->active_status_cd = ",
       t_record->qual[i].def_slot_qual[j].active_status_cd))
     CALL echo(build("   t_record->qual[",i,",",j,"]->active_status_desc = ",
       t_record->qual[i].def_slot_qual[j].active_status_desc))
   ENDFOR
   CALL echo(build("   t_record->qual[",i,"]->slot_type_qual_cnt = ",t_record->qual[i].
     slot_type_qual_cnt))
   FOR (j = 1 TO t_record->qual[i].slot_type_qual_cnt)
     CALL echo(build("   t_record->qual[",i,",",j,"]->slot_type_id = ",
       t_record->qual[i].slot_type_qual[j].slot_type_id))
     CALL echo(build("   t_record->qual[",i,",",j,"]->mnemonic = ",
       t_record->qual[i].slot_type_qual[j].mnemonic))
     CALL echo(build("   t_record->qual[",i,",",j,"]->active_status_cd = ",
       t_record->qual[i].slot_type_qual[j].active_status_cd))
     CALL echo(build("   t_record->qual[",i,",",j,"]->active_status_desc = ",
       t_record->qual[i].slot_type_qual[j].active_status_desc))
   ENDFOR
   CALL echo(" ")
 ENDFOR
 FOR (i = 1 TO t_record->qual_cnt)
   SET format_text_request->raw_text = t_record->qual[i].mnemonic
   SET format_text_request->chars_per_line = t_record->field_column_size
   CALL format_text(1)
   FOR (j = 1 TO format_text_reply->qual_cnt)
    CALL inc_data(1)
    IF (j > 1)
     SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat(
      substring(1,t_record->max_prompt_size,t_record->blank_line),trim(format_text_reply->qual[j].
       text_string))
    ELSE
     SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat(
      substring(1,t_record->max_prompt_size,t_record->prompt_qual[1].prompt_string),trim(
       format_text_reply->qual[j].text_string))
     SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].beg_group_ind = 1
    ENDIF
   ENDFOR
   SET format_text_request->raw_text = t_record->qual[i].description
   SET format_text_request->chars_per_line = t_record->field_column_size
   CALL format_text(1)
   FOR (j = 1 TO format_text_reply->qual_cnt)
    CALL inc_data(1)
    IF (j > 1)
     SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat(
      substring(1,t_record->max_prompt_size,t_record->blank_line),trim(format_text_reply->qual[j].
       text_string))
    ELSE
     SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat(
      substring(1,t_record->max_prompt_size,t_record->prompt_qual[2].prompt_string),trim(
       format_text_reply->qual[j].text_string))
    ENDIF
   ENDFOR
   SET format_text_request->raw_text = t_record->qual[i].comments
   SET format_text_request->chars_per_line = t_record->field_column_size
   CALL format_text(1)
   FOR (j = 1 TO format_text_reply->qual_cnt)
    CALL inc_data(1)
    IF (j > 1)
     SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat(
      substring(1,t_record->max_prompt_size,t_record->blank_line),trim(format_text_reply->qual[j].
       text_string))
    ELSE
     SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat(
      substring(1,t_record->max_prompt_size,t_record->prompt_qual[3].prompt_string),trim(
       format_text_reply->qual[j].text_string))
    ENDIF
   ENDFOR
   CALL inc_data(1)
   SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat(
    substring(1,t_record->max_prompt_size,t_record->prompt_qual[4].prompt_string),t_record->qual[i].
    active_status_desc,"  ",format(t_record->qual[i].active_dt_tm,"@MEDIUMDATETIME"),"  ",
    t_record->qual[i].active_prsnl_name)
   CALL inc_data(1)
   SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat(
    substring(1,t_record->max_prompt_size,t_record->prompt_qual[5].prompt_string),substring(1,
     t_record->qual[i].active_status_size,t_record->blank_line),"  ",format(t_record->qual[i].
     updt_dt_tm,"@MEDIUMDATETIME"),"  ",
    t_record->qual[i].updt_name)
   CALL inc_data(1)
   SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat(
    substring(1,t_record->max_prompt_size,t_record->prompt_qual[6].prompt_string),evaluate(t_record->
     qual[i].appt_book_qual_cnt,0,"NOT ASSOCIATED",concat("Mnemonic                           Status",
      substring(1,maxval(0,(t_record->qual[i].max_active_size - 6)),t_record->blank_line))))
   FOR (i_book = 1 TO t_record->qual[i].appt_book_qual_cnt)
     IF (i_book=1)
      CALL inc_data(1)
      SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat
      (substring(1,t_record->max_prompt_size,t_record->blank_line),
       "------------------------------     ",substring(1,maxval(6,t_record->qual[i].max_active_size),
        t_record->dash_line))
     ENDIF
     CALL inc_data(1)
     SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat(
      substring(1,t_record->max_prompt_size,t_record->blank_line),t_record->qual[i].appt_book_qual[
      i_book].mnemonic,"     ",substring(1,t_record->qual[i].max_active_size,t_record->qual[i].
       appt_book_qual[i_book].active_status_desc))
   ENDFOR
   IF ((t_record->qual[i].appt_book_qual_cnt > 0)
    AND (t_record->qual[i].appt_state_qual_cnt > 0))
    CALL inc_data(1)
    SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = " "
   ENDIF
   CALL inc_data(1)
   SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat(
    substring(1,t_record->max_prompt_size,t_record->prompt_qual[7].prompt_string),evaluate(t_record->
     qual[i].appt_state_qual_cnt,0,"NOT ASSOCIATED",concat(
      "Mnemonic                           Status",substring(1,maxval(0,(t_record->qual[i].
        max_active_size - 6)),t_record->blank_line))))
   FOR (i_default = 1 TO t_record->qual[i].appt_state_qual_cnt)
     IF (i_default=1)
      CALL inc_data(1)
      SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat
      (substring(1,t_record->max_prompt_size,t_record->blank_line),
       "------------------------------     ",substring(1,maxval(6,t_record->qual[i].max_active_size),
        t_record->dash_line))
     ENDIF
     CALL inc_data(1)
     SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat(
      substring(1,t_record->max_prompt_size,t_record->blank_line),t_record->qual[i].appt_state_qual[
      i_default].mnemonic,"     ",substring(1,t_record->qual[i].max_active_size,t_record->qual[i].
       appt_state_qual[i_default].active_status_desc),"     ")
   ENDFOR
   IF ((t_record->qual[i].def_slot_qual_cnt > 0)
    AND (t_record->qual[i].appt_state_qual_cnt > 0))
    CALL inc_data(1)
    SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = " "
   ENDIF
   CALL inc_data(1)
   SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat(
    substring(1,t_record->max_prompt_size,t_record->prompt_qual[8].prompt_string),evaluate(t_record->
     qual[i].def_slot_qual_cnt,0,"NOT ASSOCIATED",concat("Mnemonic                           Status",
      substring(1,maxval(0,(t_record->qual[i].max_active_size - 6)),t_record->blank_line))))
   FOR (i_def_slot = 1 TO t_record->qual[i].def_slot_qual_cnt)
     IF (i_def_slot=1)
      CALL inc_data(1)
      SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat
      (substring(1,t_record->max_prompt_size,t_record->blank_line),
       "------------------------------     ",substring(1,maxval(6,t_record->qual[i].max_active_size),
        t_record->dash_line))
     ENDIF
     CALL inc_data(1)
     SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat(
      substring(1,t_record->max_prompt_size,t_record->blank_line),t_record->qual[i].def_slot_qual[
      i_def_slot].mnemonic,"     ",substring(1,t_record->qual[i].max_active_size,t_record->qual[i].
       def_slot_qual[i_def_slot].active_status_desc))
   ENDFOR
   IF ((t_record->qual[i].def_slot_qual_cnt > 0)
    AND (t_record->qual[i].slot_type_qual_cnt > 0))
    CALL inc_data(1)
    SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = " "
   ENDIF
   CALL inc_data(1)
   SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat(
    substring(1,t_record->max_prompt_size,t_record->prompt_qual[9].prompt_string),evaluate(t_record->
     qual[i].slot_type_qual_cnt,0,"NOT ASSOCIATED",concat("Mnemonic                           Status",
      substring(1,maxval(0,(t_record->qual[i].max_active_size - 6)),t_record->blank_line))))
   FOR (i_slot_type = 1 TO t_record->qual[i].slot_type_qual_cnt)
     IF (i_slot_type=1)
      CALL inc_data(1)
      SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat
      (substring(1,t_record->max_prompt_size,t_record->blank_line),
       "------------------------------     ",substring(1,maxval(6,t_record->qual[i].max_active_size),
        t_record->dash_line))
     ENDIF
     CALL inc_data(1)
     SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat(
      substring(1,t_record->max_prompt_size,t_record->blank_line),t_record->qual[i].slot_type_qual[
      i_slot_type].mnemonic,"     ",substring(1,t_record->qual[i].max_active_size,t_record->qual[i].
       slot_type_qual[i_slot_type].active_status_desc))
   ENDFOR
 ENDFOR
 IF (mod(generic_print_request->data_qual_cnt,10) != 0)
  SET stat = alterlist(generic_print_request->data_qual,generic_print_request->data_qual_cnt)
 ENDIF
 SET generic_print_request->call_echo_ind = 0
 SET generic_print_request->file_name = t_record->file_name
 SET generic_print_request->lines_per_page = 0
 SET generic_print_request->grouping_ind = 1
 SET generic_print_request->char_per_line = 0
 CALL sync_header(1)
 CALL sync_footer(1)
 CALL sync_data(1)
 CALL sync_separator(1)
 FREE SET t_generic_print
 RECORD t_generic_print(
   1 page_num_beg = i4
   1 page_num_digits = i4
   1 header_beg_line = i4
   1 header_end_line = i4
   1 footer_beg_line = i4
   1 footer_end_line = i4
   1 data_beg_line = i4
   1 data_end_line = i4
   1 nbr_data_lines = i4
   1 beg_index = i4
   1 skip_separator_ind = i2
   1 header_ind = i2
 )
 IF ((generic_print_request->lines_per_page <= 0))
  SET generic_print_request->lines_per_page = 60
 ENDIF
 IF ((generic_print_request->char_per_line <= 0))
  SET generic_print_request->char_per_line = 132
 ENDIF
 SET t_generic_print->page_num_beg = 0
 SET t_generic_print->page_num_digits = 0
 IF ((generic_print_request->page_num_string > " "))
  FOR (i = 1 TO size(trim(generic_print_request->page_num_string)))
    IF (substring(i,1,generic_print_request->page_num_string)="#")
     IF ((t_generic_print->page_num_beg=0))
      SET t_generic_print->page_num_beg = i
      SET t_generic_print->page_num_digits = 1
     ELSE
      SET t_generic_print->page_num_digits = (t_generic_print->page_num_digits+ 1)
     ENDIF
    ELSE
     IF ((t_generic_print->page_num_beg > 0))
      SET i = (size(trim(generic_print_request->page_num_string))+ 1)
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SET t_generic_print->header_beg_line = 0
 SET t_generic_print->header_end_line = (t_generic_print->header_beg_line+ generic_print_request->
 header_qual_cnt)
 SET t_generic_print->footer_beg_line = (generic_print_request->lines_per_page -
 generic_print_request->footer_qual_cnt)
 SET t_generic_print->footer_end_line = (t_generic_print->footer_beg_line+ generic_print_request->
 footer_qual_cnt)
 SET t_generic_print->data_beg_line = generic_print_request->header_qual_cnt
 SET t_generic_print->nbr_data_lines = ((generic_print_request->lines_per_page -
 generic_print_request->footer_qual_cnt) - generic_print_request->header_qual_cnt)
 SET t_generic_print->data_end_line = ((t_generic_print->data_beg_line+ t_generic_print->
 nbr_data_lines) - 1)
 IF (call_echo_ind)
  CALL echo(build("t_generic_print->header_beg_line = ",t_generic_print->header_beg_line))
  CALL echo(build("t_generic_print->header_end_line = ",t_generic_print->header_end_line))
  CALL echo(build("t_generic_print->footer_beg_line = ",t_generic_print->footer_beg_line))
  CALL echo(build("t_generic_print->footer_end_line = ",t_generic_print->footer_end_line))
  CALL echo(build("t_generic_print->data_beg_line = ",t_generic_print->data_beg_line))
  CALL echo(build("t_generic_print->data_end_line = ",t_generic_print->data_end_line))
  CALL echo(build("t_generic_print->nbr_data_lines = ",t_generic_print->nbr_data_lines))
  CALL echo(build("t_generic_print->beg_index = ",t_generic_print->beg_index))
  CALL echo(build("t_generic_print->skip_separator_ind = ",t_generic_print->skip_separator_ind))
 ENDIF
 IF ((generic_print_request->grouping_ind=1))
  IF ((generic_print_request->data_qual_cnt > 0))
   SET generic_print_request->data_qual[1].beg_group_ind = 1
   SET t_generic_print->beg_index = 1
   FOR (i_data = 2 TO generic_print_request->data_qual_cnt)
    IF (((i_data - t_generic_print->beg_index) >= t_generic_print->nbr_data_lines))
     SET generic_print_request->data_qual[i_data].beg_group_ind = 1
     SET generic_print_request->data_qual[t_generic_print->beg_index].skip_separator_ind = true
    ENDIF
    IF ((generic_print_request->data_qual[i_data].beg_group_ind=1))
     SET generic_print_request->data_qual[t_generic_print->beg_index].lines_in_group = (i_data -
     t_generic_print->beg_index)
     SET t_generic_print->beg_index = i_data
    ENDIF
   ENDFOR
   SET generic_print_request->data_qual[t_generic_print->beg_index].lines_in_group = ((
   generic_print_request->data_qual_cnt - t_generic_print->beg_index)+ 1)
  ENDIF
 ELSE
  FOR (i_data = 1 TO generic_print_request->data_qual_cnt)
   SET generic_print_request->data_qual[i_data].beg_group_ind = 1
   SET generic_print_request->data_qual[i_data].lines_in_group = 1
  ENDFOR
 ENDIF
 IF ((generic_print_request->char_per_line <= 132))
  SELECT INTO value( $OUTDEV)
   d.seq
   FROM dummyt d
   WHERE d.seq=1
   HEAD PAGE
    IF ((generic_print_request->header_qual_cnt > 0))
     row t_generic_print->header_beg_line
     FOR (i_head = 1 TO generic_print_request->header_qual_cnt)
      IF (i_head > 1)
       row + 1
      ENDIF
      ,
      CASE (generic_print_request->header_qual[i_head].header_type_flag)
       OF 1:
        stat = movestring(format(curpage,";l;i"),1,generic_print_request->page_num_string,
         t_generic_print->page_num_beg,t_generic_print->page_num_digits),col 0,generic_print_request
        ->page_num_string
       OF 3:
        col 0,generic_print_request->end_report_string
       ELSE
        col 0,generic_print_request->header_qual[i_head].header_string
      ENDCASE
     ENDFOR
    ENDIF
    IF ((generic_print_request->header_qual_cnt=0))
     t_generic_print->header_ind = 1
    ELSE
     t_generic_print->header_ind = 0
    ENDIF
   DETAIL
    FOR (i_data = 1 TO generic_print_request->data_qual_cnt)
      IF ((generic_print_request->data_qual[i_data].beg_group_ind=1))
       IF ((row > ((t_generic_print->data_end_line - generic_print_request->data_qual[i_data].
       lines_in_group) - evaluate(generic_print_request->data_qual[i_data].skip_separator_ind,1,0,
        generic_print_request->separator_qual_cnt))))
        BREAK
       ENDIF
       t_generic_print->beg_index = ((i_data+ generic_print_request->data_qual[i_data].lines_in_group
       ) - 1), t_generic_print->skip_separator_ind = generic_print_request->data_qual[i_data].
       skip_separator_ind
      ENDIF
      IF ((t_generic_print->header_ind=1))
       t_generic_print->header_ind = 0
      ELSE
       row + 1
      ENDIF
      col 0, generic_print_request->data_qual[i_data].data_string
      IF ((i_data=t_generic_print->beg_index)
       AND (t_generic_print->skip_separator_ind != 1))
       FOR (i_separator = 1 TO generic_print_request->separator_qual_cnt)
         IF ((row >= t_generic_print->data_end_line))
          BREAK
         ENDIF
         row + 1, col 0, generic_print_request->separator_qual[i_separator].separator_string
       ENDFOR
      ENDIF
    ENDFOR
   FOOT PAGE
    IF ((generic_print_request->footer_qual_cnt > 0))
     row t_generic_print->footer_beg_line
     FOR (i_foot = 1 TO generic_print_request->footer_qual_cnt)
      IF (i_foot > 1)
       row + 1
      ENDIF
      ,
      CASE (generic_print_request->footer_qual[i_foot].footer_type_flag)
       OF 1:
        stat = movestring(format(curpage,";l;i"),1,generic_print_request->page_num_string,
         t_generic_print->page_num_beg,t_generic_print->page_num_digits),col 0,generic_print_request
        ->page_num_string
       OF 2:
        IF ((i_data >= generic_print_request->data_qual_cnt))
         col 0, generic_print_request->end_report_string
        ELSE
         col 0, generic_print_request->continue_string
        ENDIF
       ELSE
        col 0,generic_print_request->footer_qual[i_foot].footer_string
      ENDCASE
     ENDFOR
    ENDIF
   WITH nocounter, compress, formfeed = post,
    maxcol = value(generic_print_request->char_per_line)
  ;end select
 ELSE
  SELECT INTO value(generic_print_request->file_name)
   d.seq
   FROM dummyt d
   WHERE d.seq=1
   HEAD PAGE
    IF ((generic_print_request->header_qual_cnt > 0))
     row t_generic_print->header_beg_line
     FOR (i_head = 1 TO generic_print_request->header_qual_cnt)
      IF (i_head > 1)
       row + 1
      ENDIF
      ,
      CASE (generic_print_request->header_qual[i_head].header_type_flag)
       OF 1:
        stat = movestring(format(curpage,";l;i"),1,generic_print_request->page_num_string,
         t_generic_print->page_num_beg,t_generic_print->page_num_digits),col 0,generic_print_request
        ->page_num_string
       OF 3:
        col 0,generic_print_request->end_report_string
       ELSE
        col 0,generic_print_request->header_qual[i_head].header_string
      ENDCASE
     ENDFOR
    ENDIF
    IF ((generic_print_request->header_qual_cnt=0))
     t_generic_print->header_ind = 1
    ELSE
     t_generic_print->header_ind = 0
    ENDIF
   DETAIL
    FOR (i_data = 1 TO generic_print_request->data_qual_cnt)
      IF ((generic_print_request->data_qual[i_data].beg_group_ind=1))
       IF ((row > ((t_generic_print->data_end_line - generic_print_request->data_qual[i_data].
       lines_in_group) - evaluate(generic_print_request->data_qual[i_data].skip_separator_ind,1,0,
        generic_print_request->separator_qual_cnt))))
        BREAK
       ENDIF
       t_generic_print->beg_index = ((i_data+ generic_print_request->data_qual[i_data].lines_in_group
       ) - 1), t_generic_print->skip_separator_ind = generic_print_request->data_qual[i_data].
       skip_separator_ind
      ENDIF
      IF ((t_generic_print->header_ind=1))
       t_generic_print->header_ind = 0
      ELSE
       row + 1
      ENDIF
      col 0, generic_print_request->data_qual[i_data].data_string
      IF ((i_data=t_generic_print->beg_index)
       AND (t_generic_print->skip_separator_ind != 1))
       FOR (i_separator = 1 TO generic_print_request->separator_qual_cnt)
         IF ((row >= t_generic_print->data_end_line))
          BREAK
         ENDIF
         row + 1, col 0, generic_print_request->separator_qual[i_separator].separator_string
       ENDFOR
      ENDIF
    ENDFOR
   FOOT PAGE
    IF ((generic_print_request->footer_qual_cnt > 0))
     row t_generic_print->footer_beg_line
     FOR (i_foot = 1 TO generic_print_request->footer_qual_cnt)
      IF (i_foot > 1)
       row + 1
      ENDIF
      ,
      CASE (generic_print_request->footer_qual[i_foot].footer_type_flag)
       OF 1:
        stat = movestring(format(curpage,";l;i"),1,generic_print_request->page_num_string,
         t_generic_print->page_num_beg,t_generic_print->page_num_digits),col 0,generic_print_request
        ->page_num_string
       OF 2:
        IF ((i_data >= generic_print_request->data_qual_cnt))
         col 0, generic_print_request->end_report_string
        ELSE
         col 0, generic_print_request->continue_string
        ENDIF
       ELSE
        col 0,generic_print_request->footer_qual[i_foot].footer_string
      ENDCASE
     ENDFOR
    ENDIF
   WITH nocounter, compress, landscape,
    formfeed = post, maxcol = value(generic_print_request->char_per_line)
  ;end select
 ENDIF
 FREE SET t_record
 GO TO exit_script
#subroutines
 SUBROUTINE format_text(null_index)
   SET format_text_request->raw_text = trim(format_text_request->raw_text,3)
   SET text_length = textlen(format_text_request->raw_text)
   SET format_text_request->temp_str = " "
   FOR (j_text = 1 TO text_length)
     SET temp_char = substring(j_text,1,format_text_request->raw_text)
     IF (temp_char=" ")
      SET temp_char = "^"
     ENDIF
     SET t_number = ichar(temp_char)
     IF (t_number != 10
      AND t_number != 13)
      SET format_text_request->temp_str = concat(format_text_request->temp_str,temp_char)
     ENDIF
     IF (t_number=13)
      SET format_text_request->temp_str = concat(format_text_request->temp_str,"^")
     ENDIF
   ENDFOR
   SET format_text_request->temp_str = replace(format_text_request->temp_str,"^"," ",0)
   SET format_text_request->raw_text = format_text_request->temp_str
   SET format_text_reply->beg_index = 0
   SET format_text_reply->end_index = 0
   SET format_text_reply->qual_cnt = 0
   SET text_len = textlen(format_text_request->raw_text)
   IF ((text_len > format_text_request->chars_per_line))
    WHILE ((text_len > format_text_request->chars_per_line))
      SET wrap_ind = 0
      SET format_text_reply->beg_index = 1
      WHILE (wrap_ind=0)
        SET format_text_reply->end_index = findstring(" ",format_text_request->raw_text,
         format_text_reply->beg_index)
        IF ((format_text_reply->end_index=0))
         SET format_text_reply->end_index = (format_text_request->chars_per_line+ 10)
        ENDIF
        IF ((format_text_reply->beg_index=1)
         AND (format_text_reply->end_index > format_text_request->chars_per_line))
         SET format_text_reply->qual_cnt = (format_text_reply->qual_cnt+ 1)
         IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
          SET format_text_reply->qual_alloc = (format_text_reply->qual_alloc+ 10)
          SET stat = alterlist(format_text_reply->qual,format_text_reply->qual_alloc)
         ENDIF
         SET format_text_reply->qual[format_text_reply->qual_cnt].text_string = substring(1,
          format_text_request->chars_per_line,format_text_request->raw_text)
         SET format_text_request->raw_text = substring((format_text_request->chars_per_line+ 1),(
          text_len - format_text_request->chars_per_line),format_text_request->raw_text)
         SET wrap_ind = 1
        ELSEIF ((format_text_reply->end_index > format_text_request->chars_per_line))
         SET format_text_reply->qual_cnt = (format_text_reply->qual_cnt+ 1)
         IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
          SET format_text_reply->qual_alloc = (format_text_reply->qual_alloc+ 10)
          SET stat = alterlist(format_text_reply->qual,format_text_reply->qual_alloc)
         ENDIF
         SET format_text_reply->qual[format_text_reply->qual_cnt].text_string = substring(1,(
          format_text_reply->beg_index - 1),format_text_request->raw_text)
         SET format_text_request->raw_text = substring(format_text_reply->beg_index,((text_len -
          format_text_reply->beg_index)+ 1),format_text_request->raw_text)
         SET wrap_ind = 1
        ENDIF
        SET format_text_reply->beg_index = (format_text_reply->end_index+ 1)
      ENDWHILE
      SET text_len = textlen(format_text_request->raw_text)
    ENDWHILE
    SET format_text_reply->qual_cnt = (format_text_reply->qual_cnt+ 1)
    IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
     SET format_text_reply->qual_alloc = (format_text_reply->qual_alloc+ 10)
     SET stat = alterlist(format_text_reply->qual,format_text_reply->qual_alloc)
    ENDIF
    SET format_text_reply->qual[format_text_reply->qual_cnt].text_string = format_text_request->
    raw_text
   ELSE
    SET format_text_reply->qual_cnt = (format_text_reply->qual_cnt+ 1)
    IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
     SET format_text_reply->qual_alloc = (format_text_reply->qual_alloc+ 10)
     SET stat = alterlist(format_text_reply->qual,format_text_reply->qual_alloc)
    ENDIF
    SET format_text_reply->qual[format_text_reply->qual_cnt].text_string = format_text_request->
    raw_text
   ENDIF
 END ;Subroutine
 SUBROUTINE inc_format_text(null_index)
  SET format_text_reply->qual_cnt = (format_text_reply->qual_cnt+ 1)
  IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
   SET format_text_reply->qual_alloc = (format_text_reply->qual_alloc+ 10)
   SET stat = alterlist(format_text_reply->qual,format_text_reply->qual_alloc)
  ENDIF
 END ;Subroutine
 SUBROUTINE inc_prompt(null_index)
  SET t_record->prompt_qual_cnt = (t_record->prompt_qual_cnt+ 1)
  IF (mod(t_record->prompt_qual_cnt,10)=1)
   SET stat = alterlist(t_record->prompt_qual,(t_record->prompt_qual_cnt+ 9))
  ENDIF
 END ;Subroutine
 SUBROUTINE sync_prompt(null_index)
   IF (mod(t_record->prompt_qual_cnt,10) != 0)
    SET stat = alterlist(t_record->prompt_qual,t_record->prompt_qual_cnt)
   ENDIF
 END ;Subroutine
 SUBROUTINE center_page_num(null_index)
   SET generic_print_request->page_num_string = concat(substring(1,((t_record->report_size - size(
      trim(generic_print_request->page_num_string)))/ 2),t_record->blank_line),generic_print_request
    ->page_num_string)
 END ;Subroutine
 SUBROUTINE right_page_num(null_index)
   SET generic_print_request->page_num_string = concat(substring(1,(t_record->report_size - size(trim
      (generic_print_request->page_num_string))),t_record->blank_line),generic_print_request->
    page_num_string)
 END ;Subroutine
 SUBROUTINE left_page_num(null_index)
   SET generic_print_request->page_num_string = trim(generic_print_request->page_num_string,2)
 END ;Subroutine
 SUBROUTINE center_continue(null_index)
   SET generic_print_request->continue_string = concat(substring(1,((t_record->report_size - size(
      trim(generic_print_request->continue_string)))/ 2),t_record->blank_line),generic_print_request
    ->continue_string)
 END ;Subroutine
 SUBROUTINE right_continue(null_index)
   SET generic_print_request->continue_string = concat(substring(1,(t_record->report_size - size(trim
      (generic_print_request->continue_string))),t_record->blank_line),generic_print_request->
    continue_string)
 END ;Subroutine
 SUBROUTINE left_continue(null_index)
   SET generic_print_request->continue_string = trim(generic_print_request->continue_string,2)
 END ;Subroutine
 SUBROUTINE center_end_report(null_index)
   SET generic_print_request->end_report_string = concat(substring(1,((t_record->report_size - size(
      trim(generic_print_request->end_report_string)))/ 2),t_record->blank_line),
    generic_print_request->end_report_string)
 END ;Subroutine
 SUBROUTINE right_end_report(null_index)
   SET generic_print_request->end_report_string = concat(substring(1,(t_record->report_size - size(
      trim(generic_print_request->end_report_string))),t_record->blank_line),generic_print_request->
    end_report_string)
 END ;Subroutine
 SUBROUTINE left_end_report(null_index)
   SET generic_print_request->end_report_string = trim(generic_print_request->end_report_string,2)
 END ;Subroutine
 SUBROUTINE inc_data(null_index)
   SET generic_print_request->data_qual_cnt = (generic_print_request->data_qual_cnt+ 1)
   IF (mod(generic_print_request->data_qual_cnt,10)=1)
    SET stat = alterlist(generic_print_request->data_qual,(generic_print_request->data_qual_cnt+ 9))
   ENDIF
   SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].beg_group_ind = 0
   SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].lines_in_group = 0
 END ;Subroutine
 SUBROUTINE inc_header(null_index)
   SET generic_print_request->header_qual_cnt = (generic_print_request->header_qual_cnt+ 1)
   IF (mod(generic_print_request->header_qual_cnt,10)=1)
    SET stat = alterlist(generic_print_request->header_qual,(generic_print_request->header_qual_cnt+
     9))
   ENDIF
   SET generic_print_request->header_qual[generic_print_request->header_qual_cnt].header_type_flag =
   0
 END ;Subroutine
 SUBROUTINE inc_footer(null_index)
   SET generic_print_request->footer_qual_cnt = (generic_print_request->footer_qual_cnt+ 1)
   IF (mod(generic_print_request->footer_qual_cnt,10)=1)
    SET stat = alterlist(generic_print_request->footer_qual,(generic_print_request->footer_qual_cnt+
     9))
   ENDIF
   SET generic_print_request->footer_qual[generic_print_request->footer_qual_cnt].footer_type_flag =
   0
 END ;Subroutine
 SUBROUTINE inc_separator(null_index)
  SET generic_print_request->separator_qual_cnt = (generic_print_request->separator_qual_cnt+ 1)
  IF (mod(generic_print_request->separator_qual_cnt,10)=1)
   SET stat = alterlist(generic_print_request->separator_qual,(generic_print_request->
    separator_qual_cnt+ 9))
  ENDIF
 END ;Subroutine
 SUBROUTINE sync_data(null_index)
   IF (mod(generic_print_request->data_qual_cnt,10) != 0)
    SET stat = alterlist(generic_print_request->data_qual,generic_print_request->data_qual_cnt)
   ENDIF
 END ;Subroutine
 SUBROUTINE sync_header(null_index)
   IF (mod(generic_print_request->header_qual_cnt,10) != 0)
    SET stat = alterlist(generic_print_request->header_qual,generic_print_request->header_qual_cnt)
   ENDIF
 END ;Subroutine
 SUBROUTINE sync_footer(null_index)
   IF (mod(generic_print_request->footer_qual_cnt,10) != 0)
    SET stat = alterlist(generic_print_request->footer_qual,generic_print_request->footer_qual_cnt)
   ENDIF
 END ;Subroutine
 SUBROUTINE sync_separator(null_index)
   IF (mod(generic_print_request->separator_qual_cnt,10) != 0)
    SET stat = alterlist(generic_print_request->separator_qual,generic_print_request->
     separator_qual_cnt)
   ENDIF
 END ;Subroutine
 SUBROUTINE center_header(null_index)
   SET generic_print_request->header_qual[generic_print_request->header_qual_cnt].header_string =
   concat(substring(1,((t_record->report_size - size(trim(generic_print_request->header_qual[
       generic_print_request->header_qual_cnt].header_string)))/ 2),t_record->blank_line),
    generic_print_request->header_qual[generic_print_request->header_qual_cnt].header_string)
 END ;Subroutine
 SUBROUTINE center_footer(null_index)
   SET generic_print_request->footer_qual[generic_print_request->footer_qual_cnt].footer_string =
   concat(substring(1,((t_record->report_size - size(trim(generic_print_request->footer_qual[
       generic_print_request->footer_qual_cnt].footer_string)))/ 2),t_record->blank_line),
    generic_print_request->footer_qual[generic_print_request->footer_qual_cnt].footer_string)
 END ;Subroutine
 SUBROUTINE center_data(null_index)
   SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat(
    substring(1,((t_record->report_size - size(trim(generic_print_request->data_qual[
       generic_print_request->data_qual_cnt].data_string)))/ 2),t_record->blank_line),
    generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string)
 END ;Subroutine
 SUBROUTINE center_separator(null_index)
   SET generic_print_request->separator_qual[generic_print_request->separator_qual_cnt].
   separator_string = concat(substring(1,((t_record->report_size - size(trim(generic_print_request->
       separator_qual[generic_print_request->separator_qual_cnt].separator_string)))/ 2),t_record->
     blank_line),generic_print_request->separator_qual[generic_print_request->separator_qual_cnt].
    separator_string)
 END ;Subroutine
 SUBROUTINE right_header(null_index)
   SET generic_print_request->header_qual[generic_print_request->header_qual_cnt].header_string =
   concat(substring(1,(t_record->report_size - size(trim(generic_print_request->header_qual[
       generic_print_request->header_qual_cnt].header_string))),t_record->blank_line),
    generic_print_request->header_qual[generic_print_request->header_qual_cnt].header_string)
 END ;Subroutine
 SUBROUTINE right_footer(null_index)
   SET generic_print_request->footer_qual[generic_print_request->footer_qual_cnt].footer_string =
   concat(substring(1,(t_record->report_size - size(trim(generic_print_request->footer_qual[
       generic_print_request->footer_qual_cnt].footer_string))),t_record->blank_line),
    generic_print_request->footer_qual[generic_print_request->footer_qual_cnt].footer_string)
 END ;Subroutine
 SUBROUTINE right_data(null_index)
   SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = concat(
    substring(1,(t_record->report_size - size(trim(generic_print_request->data_qual[
       generic_print_request->data_qual_cnt].data_string))),t_record->blank_line),
    generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string)
 END ;Subroutine
 SUBROUTINE right_separator(null_index)
   SET generic_print_request->separator_qual[generic_print_request->separator_qual_cnt].
   separator_string = concat(substring(1,(t_record->report_size - size(trim(generic_print_request->
       separator_qual[generic_print_request->separator_qual_cnt].separator_string))),t_record->
     blank_line),generic_print_request->separator_qual[generic_print_request->separator_qual_cnt].
    separator_string)
 END ;Subroutine
 SUBROUTINE left_header(null_index)
   SET generic_print_request->header_qual[generic_print_request->header_qual_cnt].header_string =
   trim(generic_print_request->header_qual[generic_print_request->header_qual_cnt].header_string,2)
 END ;Subroutine
 SUBROUTINE left_footer(null_index)
   SET generic_print_request->footer_qual[generic_print_request->footer_qual_cnt].footer_string =
   trim(generic_print_request->footer_qual[generic_print_request->footer_qual_cnt].footer_string,2)
 END ;Subroutine
 SUBROUTINE left_data(null_index)
   SET generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string = trim(
    generic_print_request->data_qual[generic_print_request->data_qual_cnt].data_string,2)
 END ;Subroutine
 SUBROUTINE left_separator(null_index)
   SET generic_print_request->separator_qual[generic_print_request->separator_qual_cnt].
   separator_string = trim(generic_print_request->separator_qual[generic_print_request->
    separator_qual_cnt].separator_string,2)
 END ;Subroutine
#exit_script
END GO

CREATE PROGRAM bhs_sch_inqa_req_wqm_personly:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c6 WITH private, noconstant("")
 ENDIF
 SET last_mod = "592375 - BHS"
 DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 SUBROUTINE (loadcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET table_name = build("ERROR-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG[",curprog,
       "]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      CALL echo(build("INFO-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
        '"',",",option_flag,") not found, CURPROG[",curprog,
        "]"))
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE[",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
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
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE i18nhandle = w8 WITH public, noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
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
         SET format_text_reply->qual_cnt += 1
         IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
          SET format_text_reply->qual_alloc += 10
          SET stat = alterlist(format_text_reply->qual,format_text_reply->qual_alloc)
         ENDIF
         SET format_text_reply->qual[format_text_reply->qual_cnt].text_string = substring(1,
          format_text_request->chars_per_line,format_text_request->raw_text)
         SET format_text_request->raw_text = substring((format_text_request->chars_per_line+ 1),(
          text_len - format_text_request->chars_per_line),format_text_request->raw_text)
         SET wrap_ind = 1
        ELSEIF ((format_text_reply->end_index > format_text_request->chars_per_line))
         SET format_text_reply->qual_cnt += 1
         IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
          SET format_text_reply->qual_alloc += 10
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
    SET format_text_reply->qual_cnt += 1
    IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
     SET format_text_reply->qual_alloc += 10
     SET stat = alterlist(format_text_reply->qual,format_text_reply->qual_alloc)
    ENDIF
    SET format_text_reply->qual[format_text_reply->qual_cnt].text_string = format_text_request->
    raw_text
   ELSE
    SET format_text_reply->qual_cnt += 1
    IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
     SET format_text_reply->qual_alloc += 10
     SET stat = alterlist(format_text_reply->qual,format_text_reply->qual_alloc)
    ENDIF
    SET format_text_reply->qual[format_text_reply->qual_cnt].text_string = format_text_request->
    raw_text
   ENDIF
 END ;Subroutine
 SUBROUTINE inc_format_text(null_index)
  SET format_text_reply->qual_cnt += 1
  IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
   SET format_text_reply->qual_alloc += 10
   SET stat = alterlist(format_text_reply->qual,format_text_reply->qual_alloc)
  ENDIF
 END ;Subroutine
 IF ( NOT (validate(get_atgroup_exp_request,0)))
  RECORD get_atgroup_exp_request(
    1 security_ind = i2
    1 call_echo_ind = i2
    1 qual[*]
      2 sch_object_id = f8
      2 duplicate_ind = i2
  )
 ENDIF
 IF ( NOT (validate(get_atgroup_exp_reply,0)))
  RECORD get_atgroup_exp_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 sch_object_id = f8
      2 qual_cnt = i4
      2 qual[*]
        3 appt_type_cd = f8
  )
 ENDIF
 IF ( NOT (validate(get_locgroup_exp_request,0)))
  RECORD get_locgroup_exp_request(
    1 security_ind = i2
    1 call_echo_ind = i2
    1 qual[*]
      2 sch_object_id = f8
      2 duplicate_ind = i2
  )
 ENDIF
 IF ( NOT (validate(get_locgroup_exp_reply,0)))
  RECORD get_locgroup_exp_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 sch_object_id = f8
      2 qual_cnt = i4
      2 qual[*]
        3 location_cd = f8
  )
 ENDIF
 IF ( NOT (validate(get_res_group_exp_request,0)))
  RECORD get_res_group_exp_request(
    1 security_ind = i2
    1 call_echo_ind = i2
    1 qual[*]
      2 res_group_id = f8
      2 duplicate_ind = i2
  )
 ENDIF
 IF ( NOT (validate(get_res_group_exp_reply,0)))
  RECORD get_res_group_exp_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 res_group_id = f8
      2 qual_cnt = i4
      2 qual[*]
        3 resource_cd = f8
        3 mnemonic = vc
        3 description = vc
        3 quota = i4
        3 person_id = f8
        3 id_disp = vc
        3 res_type_flag = i2
        3 active_ind = i2
  )
 ENDIF
 IF ( NOT (validate(get_slot_group_exp_request,0)))
  RECORD get_slot_group_exp_request(
    1 security_ind = i2
    1 call_echo_ind = i2
    1 qual[*]
      2 slot_group_id = f8
      2 duplicate_ind = i2
  )
 ENDIF
 IF ( NOT (validate(get_slot_group_exp_reply,0)))
  RECORD get_slot_group_exp_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 slot_group_id = f8
      2 qual_cnt = i4
      2 qual[*]
        3 slot_type_id = f8
  )
 ENDIF
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 SUBROUTINE (getcodevalue(code_set=i4,cdf_meaning=c12,code_variable=f8(ref)) =f8)
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_variable)
  IF (((stat != 0) OR (code_variable <= 0)) )
   CALL echo(build("Invalid select on CODE_SET (",code_set,"), CDF_MEANING(",cdf_meaning,1,
     code_variable,")"))
   SET failed = uar_error
   GO TO exit_script
  ENDIF
 END ;Subroutine
 DECLARE t_index = i4 WITH noconstant(0)
 RECORD reply(
   1 attr_qual_cnt = i4
   1 attr_qual[*]
     2 attr_name = c31
     2 attr_label = c60
     2 attr_type = c8
     2 attr_def_seq = i4
     2 attr_alt_sort_column = vc
   1 query_qual_cnt = i4
   1 query_qual[*]
     2 hide#schentryid = f8
     2 hide#scheventid = f8
     2 hide#scheduleid = f8
     2 hide#scheduleseq = i4
     2 hide#reqactionid = f8
     2 hide#actionid = f8
     2 hide#schapptid = f8
     2 hide#statemeaning = c12
     2 hide#latestdttm = dq8
     2 hide#reqmadedttm = dq8
     2 hide#entrystatemeaning = c12
     2 hide#reqactionmeaning = c12
     2 hide#encounterid = f8
     2 hide#personid = f8
     2 hide#bitmask = i4
     2 hide#orderid = f8
     2 hide#blobhandle = vc
     2 hide#wqmworkitemid = f8
     2 hide#wqmdocumenttypecd = f8
     2 hide#wqmitemscript = i4
     2 hide#wqmupdtcnt = i4
     2 hide#cdipendingdocumentid = f8
     2 hide#documenttypedisplay = vc
     2 hide#sendinglocationcd = f8
     2 hide#orderingphysicianid = f8
     2 hide#statuscd = f8
     2 orders = vc
     2 earliest_dt_tm = dq8
     2 req_action_display = vc
     2 appt_type_display = vc
     2 person_name = vc
     2 dob = dq8
     2 sex = vc
     2 home_phone = vc
     2 mrn = vc
     2 ordering_physician = vc
     2 document_source = vc
     2 images = vc
     2 created_dt_tm = dq8
     2 contact_count = i4
     2 last_contact_comment = vc
     2 ordered_as_mnemonic = vc
     2 cmt = vc
     2 order_cmt = c12
     2 stat = c12
     2 inpatient = vc
     2 isolation_type = vc
     2 pref_agreement_status = vc
     2 auto_dial = vc
     2 ordering_provider = vc
     2 order_date = dq8
     2 order_loc = vc
     2 protocol_cmt = vc
     2 scheduled_dt_tm = dq8
     2 address = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 total_items_found = i4
 ) WITH persistscript
 RECORD sch_inqa_reply(
   1 attr_qual_cnt = i4
   1 attr_qual[*]
     2 attr_name = c31
     2 attr_label = c60
     2 attr_type = c8
     2 attr_def_seq = i4
     2 attr_alt_sort_column = vc
   1 query_qual_cnt = i4
   1 query_qual[*]
     2 hide#schentryid = f8
     2 hide#scheventid = f8
     2 hide#scheduleid = f8
     2 hide#scheduleseq = i4
     2 hide#reqactionid = f8
     2 hide#actionid = f8
     2 hide#schapptid = f8
     2 hide#statemeaning = c12
     2 hide#latestdttm = dq8
     2 hide#reqmadedttm = dq8
     2 hide#entrystatemeaning = c12
     2 hide#reqactionmeaning = c12
     2 hide#encounterid = f8
     2 hide#personid = f8
     2 hide#bitmask = i4
     2 hide#orderid = f8
     2 hide#blobhandle = vc
     2 hide#wqmworkitemid = f8
     2 hide#wqmdocumenttypecd = f8
     2 hide#wqmitemscript = i4
     2 hide#wqmupdtcnt = i4
     2 hide#cdipendingdocumentid = f8
     2 hide#documenttypedisplay = vc
     2 hide#sendinglocationcd = f8
     2 hide#orderingphysicianid = f8
     2 hide#statuscd = f8
     2 orders = vc
     2 earliest_dt_tm = dq8
     2 req_action_display = vc
     2 appt_type_display = vc
     2 person_name = vc
     2 dob = dq8
     2 sex = vc
     2 home_phone = vc
     2 mrn = vc
     2 ordering_physician = vc
     2 document_source = vc
     2 images = vc
     2 created_dt_tm = dq8
     2 contact_count = i4
     2 last_contact_comment = vc
     2 display_items = i2
     2 contact_comment_prsnl_id = f8
     2 contact_comment_timestamp = dq8
     2 follow_up_date_timestamp = dq8
     2 ordered_as_mnemonic = vc
     2 cmt = vc
     2 order_cmt = c12
     2 stat = c12
     2 inpatient = vc
     2 isolation_type = vc
     2 pref_agreement_status = vc
     2 auto_dial = vc
     2 no_contact_flag = i4
     2 ordering_provider = vc
     2 order_date = dq8
     2 order_loc = vc
     2 protocol_cmt = vc
     2 scheduled_dt_tm = dq8
     2 address = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 DECLARE pending_state_cd = f8 WITH public, constant(loadcodevalue(23018,"PENDING",0))
 DECLARE home_phone_cd = f8 WITH public, constant(loadcodevalue(43,"HOME",0))
 DECLARE mrn_cd = f8 WITH public, constant(loadcodevalue(4,"MRN",0))
 DECLARE order_type_cd = f8 WITH public, constant(loadcodevalue(16110,"ORDER",0))
 DECLARE order_action_cd = f8 WITH public, constant(loadcodevalue(6003,"ORDER",0))
 DECLARE modify_action_cd = f8 WITH public, constant(loadcodevalue(6003,"MODIFY",0))
 DECLARE collection_action_cd = f8 WITH public, constant(loadcodevalue(6003,"COLLECTION",0))
 DECLARE renew_action_cd = f8 WITH public, constant(loadcodevalue(6003,"RENEW",0))
 DECLARE activate_action_cd = f8 WITH public, constant(loadcodevalue(6003,"ACTIVATE",0))
 DECLARE futuredc_action_cd = f8 WITH public, constant(loadcodevalue(6003,"FUTUREDC",0))
 DECLARE resume_renew_action_cd = f8 WITH public, constant(loadcodevalue(6003,"RESUME/RENEW",0))
 DECLARE ordcomment_cd = f8 WITH public, constant(loadcodevalue(14,"ORD COMMENT",0))
 DECLARE mf_addr_type_cd = f8 WITH public, constant(loadcodevalue(212,"HOME",0))
 DECLARE stat_cd = f8 WITH public, constant(loadcodevalue(1304,"STAT",0))
 DECLARE wqm_req_action_cd = f8 WITH public, constant(loadcodevalue(14232,"SCHEDULE",0))
 DECLARE priority_id = f8 WITH protect, constant(127)
 DECLARE tempcontactcomment = vc WITH public, noconstant("")
 DECLARE tempcontactcmtprsnlid = f8 WITH public, noconstant(0)
 DECLARE lastcontactcomment = vc WITH public, noconstant("")
 DECLARE predefinedcommentcd = f8 WITH public, noconstant(0.0)
 DECLARE predefinedcomment = vc WITH public, noconstant("")
 DECLARE isolation_ind = f8 WITH protect, constant(12)
 DECLARE inpatient_cd = f8 WITH public, constant(loadcodevalue(69,"INPATIENT",0))
 DECLARE scheduleitemsfound = i4
 DECLARE numwqmitems = i4
 DECLARE physician_index = i4 WITH noconstant(1)
 DECLARE appt_index = i4 WITH noconstant(1)
 DECLARE modality_index = i4 WITH noconstant(1)
 DECLARE retrieve_scheduling_items = i2 WITH noconstant(0)
 DECLARE retrieve_wqm_items = i2 WITH noconstant(0)
 DECLARE record_index = i4 WITH noconstant(0)
 DECLARE pref_value = f8 WITH public, noconstant(0.0)
 DECLARE pref_type_code = f8 WITH public, noconstant(0.0)
 DECLARE auto_dial_max_pref_value = f8 WITH public, noconstant(0.0)
 DECLARE follow_up_date_text = vc WITH constant(uar_i18ngetmessage(i18nhandle,"key1",
   "Follow-up date - "))
 DECLARE follow_up_date_timestamp = dq8 WITH public
 DECLARE default_ord_phy_index = i4 WITH noconstant(1)
 DECLARE providerset_ord_phy_index = i4 WITH noconstant(1)
 DECLARE providerset_default = i4
 DECLARE ordphy_matched = i4
 SET sch_inqa_reply->attr_qual_cnt = 58
 SET stat = alterlist(sch_inqa_reply->attr_qual,sch_inqa_reply->attr_qual_cnt)
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#schentryid"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#SCHENTRYID"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "f8"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#scheventid"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#SCHEVENTID"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "f8"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#scheduleid"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#SCHEDULEID"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "f8"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#scheduleseq"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#SCHEDULESEQ"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "i4"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#reqactionid"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#REQACTIONID"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "f8"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#actionid"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#ACTIONID"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "f8"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#schapptid"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#SCHAPPTID"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "f8"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#statemeaning"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#STATEMEANING"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "c12"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#latestdttm"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#LATESTDTTM"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "dq8"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#reqmadedttm"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#REQMADEDTTM"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "dq8"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#entrystatemeaning"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#ENTRYSTATEMEANING"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#reqactionmeaning"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#REQACTIONMEANING"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#encounterid"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#ENCOUNTERID"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "f8"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#personid"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#PERSONID"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "f8"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#bitmask"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#BITMASK"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "i4"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#orderid"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#ORDERID"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "f8"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#blobhandle"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#BLOBHANDLE"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#wqmworkitemid"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#WQMWORKITEMID"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "f8"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#wqmdocumenttypecd"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#WQMDOCUMENTTYPECD"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "f8"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#wqmitemscript"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#WQMITEMSCRIPT"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "i4"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#wqmupdtcnt"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#WQMUPDTCNT"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "i4"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#cdipendingdocumentid"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#CDIPENDINGDOCUMENTID"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "f8"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#documenttypedisplay"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#DOCUMENTTYPEDISPLAY"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#sendinglocationcd"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#SENDINGLOCATIONCD"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "f8"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#orderingphysicianid"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#ORDERINGPHYSICIANID"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "f8"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "hide#statuscd"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = "HIDE#STATUSCD"
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "f8"
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "req_action_display"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Action","Action")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 1
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "person_name"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Person Name",
  "Person Name")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 2
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "mrn"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"MRN","MRN")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 3
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "dob"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"DOB","DOB")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "dq8"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 4
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "home_phone"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Patient Phone",
  "Patient Phone")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 5
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "appt_type_display"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,
  "Appointment Type/Modality","Appointment Type/Modality")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 6
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "created_dt_tm"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Request Date",
  "Request Date")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "dq8"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 7
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "orders"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Order details",
  "Order details")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 8
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "ordering_physician"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,
  "Ordering Physician","Ordering Physician")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 9
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "document_source"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Document Source",
  "Document Source")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 10
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "images"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Images","Images")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 11
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "contact_count"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Contact Count",
  "Contact Count")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "i4"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 12
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "last_contact_comment"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,
  "Last Contact Comment","Last Contact Comment")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 13
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "ordered_as_mnemonic"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Ordered As",
  "Ordered As")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 14
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "cmt"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Comments",
  "Comments")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 15
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "order_cmt"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"OC","OC")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "c12"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 16
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "stat"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Stat","Stat")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "c12"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 17
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "inpatient"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Inpatient",
  "Inpatient")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 18
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "isolation_type"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,
  "Isolation Display","Isolation Display")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 19
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "ordering_provider"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,
  "Ordering Provider","Ordering Provider")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 20
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "order_date"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Order Date",
  "Order Date")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "dq8"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 21
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "order_loc"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Order Location",
  "Order Location")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 22
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "protocol_cmt"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Protocol Comment",
  "Protocol Comment")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 23
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "earliest_dt_tm"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Earliest Date",
  "Earliest Date")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "dq8"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 24
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "scheduled_dt_tm"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Scheduled Dt/Tm",
  "Scheduled Dt/Tm")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "dq8"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 25
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "address"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Town","Town")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 26
 DECLARE getallprsnlfromschprovdset(null) = i2
 DECLARE copyschinqreptoreply(null) = i2
 DECLARE prov_agreement_pref = vc
 DECLARE display_pref_agreement_status = i2 WITH noconstant(false)
 SELECT
  sp.pref_string
  FROM sch_pref sp
  WHERE sp.pref_type_meaning="PPAENCTRTYPE"
  DETAIL
   prov_agreement_pref = sp.pref_string
  WITH nocounter
 ;end select
 IF (textlen(trim(prov_agreement_pref)) > 0)
  SET display_pref_agreement_status = true
 ENDIF
 IF (display_pref_agreement_status)
  SET t_index += 1
  SET sch_inqa_reply->attr_qual[t_index].attr_name = "pref_agreement_status"
  SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,
   "Provider Agreement","Provider Agreement")
  SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
  SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 27
 ENDIF
 SET t_index += 1
 SET sch_inqa_reply->attr_qual[t_index].attr_name = "auto_dial"
 SET sch_inqa_reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Auto Dial",
  "Auto Dial")
 SET sch_inqa_reply->attr_qual[t_index].attr_type = "vc"
 SET sch_inqa_reply->attr_qual[t_index].attr_def_seq = 28
 SET sch_inqa_reply->attr_qual_cnt = t_index
 SET stat = alterlist(sch_inqa_reply->attr_qual,t_index)
 SET pref_type_code = 0.0
 SET stat = uar_get_meaning_by_codeset(23010,"AUTODIALMAX",1,pref_type_code)
 IF (pref_type_code > 0.0)
  SELECT INTO "nl:"
   a.pref_id
   FROM sch_pref a
   PLAN (a
    WHERE a.pref_type_cd=pref_type_code
     AND a.parent_table="SYSTEM"
     AND a.parent_id=0
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   DETAIL
    IF (size(trim(a.pref_string)) > 0)
     auto_dial_max_pref_value = cnvtint(a.pref_string)
    ELSE
     auto_dial_max_pref_value = 3.0
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SET auto_dial_max_pref_value = 3.0
 ENDIF
 SET sch_inqa_reply->query_qual_cnt = 0
 SET stat = alterlist(sch_inqa_reply->query_qual,sch_inqa_reply->query_qual_cnt)
 RECORD t_record(
   1 person_id = f8
   1 queue_id = f8
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 max_order_cnt = i4
   1 event_qual[*]
     2 protocol_parent_id = f8
     2 order_qual_cnt = i4
     2 order_qual[*]
       3 order_id = f8
       3 description = vc
       3 order_seq_nbr = i4
   1 wqmitem_id = f8
   1 view_id = f8
   1 ord_physician_ids[*]
     2 ord_physician_id = f8
   1 appt_type_cds[*]
     2 appt_type_cd = f8
   1 modality_cds[*]
     2 modality_cd = f8
   1 appt_group_cd = f8
 )
 FREE RECORD wqmitemsuserquereq
 RECORD wqmitemsuserquereq(
   1 view_id = f8
   1 queue_ids[*]
     2 queue_id = f8
   1 ignore_inprocess_flag = i4
   1 max_results = i4
   1 exclude_witems_with_no_parent = i4
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 modality_cds[*]
     2 modality_cd = f8
   1 ord_physician_ids[*]
     2 ord_physician_id = f8
 )
 FREE RECORD wqmitemsuserquerep
 RECORD wqmitemsuserquerep(
   1 work_items[*]
     2 work_item_id = f8
     2 clarify_reason_cd = f8
     2 clarify_reason_display = vc
     2 comment_id = f8
     2 comment_text = vc
     2 create_dt_tm = dq8
     2 owner_prsnl_id = f8
     2 owner_prsnl_name = vc
     2 priority_cd = f8
     2 priority_display = vc
     2 status_cd = f8
     2 status_display = vc
     2 cdi_pending_document_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 service_dt_tm = dq8
     2 document_type_cd = f8
     2 document_type_display = vc
     2 document_type_codeset = i4
     2 subject = vc
     2 capture_location = vc
     2 sending_location_cd = f8
     2 sending_location_display = vc
     2 blob_handle = vc
     2 update_count = i4
     2 category_cd = f8
     2 category_display = vc
     2 ordering_provider_id = f8
     2 ordering_provider_name = vc
     2 contact_attempt_count = i4
     2 contact_made_today_flag = i2
     2 pref_agreement_status_display = vc
     2 free_text_attributes[*]
       3 attribute_type_cd = f8
       3 attribute_type_display = vc
       3 attribute_value = vc
     2 work_item_actions[*]
       3 work_item_action_id = f8
       3 work_item_id = f8
       3 action_prsnl_id = f8
       3 comment = vc
       3 work_item_action_type_flag = i2
       3 work_item_action_dt_time = dq8
       3 file_name = vc
       3 output_dest_cd = f8
       3 fax_status_cd = f8
       3 predefined_comment_cd = f8
       3 predefined_comment_display = vc
       3 follow_up_dt_tm = dq8
     2 code_attributes[*]
       3 attribute_type_cd = f8
       3 attribute_value_cds[*]
         4 value_cd = f8
     2 auto_dial_ind = i4
   1 work_item_count = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD providersetordphyrec
 RECORD providersetordphyrec(
   1 providerset_ord_physician_ids[*]
     2 providerset_ord_physician_id = f8
 )
 FREE RECORD defaultordphyrec
 RECORD defaultordphyrec(
   1 default_ord_physician_ids[*]
     2 default_ord_physician_id = f8
 )
 FREE RECORD provagreeinforeq
 RECORD provagreeinforeq(
   1 agreement_items[*]
     2 wqm_item_id = f8
     2 sch_event_id = f8
     2 prsnl_id = f8
     2 encounters[*]
       3 encounter_id = f8
       3 encounter_type_cd = f8
     2 facilities[*]
       3 facility_id = f8
       3 organization_id = f8
     2 modalities[*]
       3 modality_cd = f8
       3 catalog_type_cd = f8
       3 activity_type_cd = f8
       3 activity_sub_type_cd = f8
     2 orders[*]
       3 order_id = f8
       3 catalog_cd = f8
       3 catalog_type_cd = f8
       3 activity_type_cd = f8
       3 activity_sub_type_cd = f8
 )
 FREE RECORD provagreeinforep
 RECORD provagreeinforep(
   1 agreement_statuses[*]
     2 pref_agreement_status_cd = f8
     2 pref_agreement_status_display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (request->call_echo_ind)
  CALL echo("Checking the input fields...")
 ENDIF
 CALL alterlist(t_record->ord_physician_ids,size(request->qual,5))
 CALL alterlist(t_record->appt_type_cds,size(request->qual,5))
 CALL alterlist(t_record->modality_cds,size(request->qual,5))
 FOR (i_input = 1 TO size(request->qual,5))
   CASE (request->qual[i_input].oe_field_meaning)
    OF "PERSON":
     SET t_record->person_id = request->qual[i_input].oe_field_value
    OF "QUEUE":
     SET t_record->queue_id = request->qual[i_input].oe_field_value
    OF "BEGDTTM":
     SET t_record->beg_dt_tm = request->qual[i_input].oe_field_dt_tm_value
    OF "ENDDTTM":
     SET t_record->end_dt_tm = request->qual[i_input].oe_field_dt_tm_value
    OF "WQMVIEWS":
     SET t_record->view_id = request->qual[i_input].oe_field_value
    OF "SCHORDPHYS":
     IF ((request->qual[i_input].oe_field_value != 0))
      SET t_record->ord_physician_ids[physician_index].ord_physician_id = request->qual[i_input].
      oe_field_value
      SET physician_index += 1
     ENDIF
    OF "APPTTYPEMULT":
     IF ((request->qual[i_input].oe_field_value != 0))
      SET t_record->appt_type_cds[appt_index].appt_type_cd = request->qual[i_input].oe_field_value
      SET appt_index += 1
     ENDIF
    OF "MODALITY":
     IF ((request->qual[i_input].oe_field_value != 0))
      SET t_record->modality_cds[modality_index].modality_cd = request->qual[i_input].oe_field_value
      SET modality_index += 1
     ENDIF
    OF "ATGROUP":
     SET t_record->appt_group_cd = request->qual[i_input].oe_field_value
    OF "PROVIDERSET":
     IF ((request->qual[i_input].oe_field_display_value="<Default>"))
      SET providerset_default = 1
      CALL getallprsnlfromschprovdset(null)
     ELSEIF (textlen(trim(request->qual[i_input].oe_field_display_value)) > 0)
      SELECT
       pgr.person_id
       FROM prsnl_group pg,
        prsnl_group_reltn pgr
       PLAN (pg
        WHERE (pg.prsnl_group_name=request->qual[i_input].oe_field_display_value))
        JOIN (pgr
        WHERE pgr.prsnl_group_id=pg.prsnl_group_id
         AND pgr.active_ind=1)
       DETAIL
        IF (mod(providerset_ord_phy_index,10)=1)
         stat = alterlist(providersetordphyrec->providerset_ord_physician_ids,(
          providerset_ord_phy_index+ 9))
        ENDIF
        providersetordphyrec->providerset_ord_physician_ids[providerset_ord_phy_index].
        providerset_ord_physician_id = pgr.person_id, providerset_ord_phy_index += 1
       WITH nocounter
      ;end select
      CALL alterlist(providersetordphyrec->providerset_ord_physician_ids,(providerset_ord_phy_index
        - 1))
     ENDIF
   ENDCASE
 ENDFOR
 SET listsize = size(request->qual,5)
 IF ((t_record->appt_group_cd > 0))
  IF (appt_index=1)
   SET appt_index = 0
  ENDIF
  SELECT INTO "nl:"
   sa.child_id
   FROM sch_assoc sa
   PLAN (sa
    WHERE (sa.parent_id=t_record->appt_group_cd)
     AND sa.data_source_meaning="APPTTYPE")
   DETAIL
    appt_index += 1
    IF (mod(size(t_record->appt_type_cds,5),listsize)=1)
     stat = alterlist(t_record->appt_type_cds,(appt_index+ listsize))
    ENDIF
    t_record->appt_type_cds[appt_index].appt_type_cd = sa.child_id
   WITH nocounter
  ;end select
 ENDIF
 CALL alterlist(t_record->ord_physician_ids,(physician_index - 1))
 CALL alterlist(t_record->appt_type_cds,(appt_index - 1))
 CALL alterlist(t_record->modality_cds,(modality_index - 1))
 IF (appt_index=1
  AND modality_index=1)
  SET retrieve_scheduling_items = 1
  SET retrieve_wqm_items = 1
 ELSE
  IF (appt_index > 1)
   SET retrieve_scheduling_items = 1
  ENDIF
  IF (modality_index > 1)
   SET retrieve_wqm_items = 1
  ENDIF
 ENDIF
 SET listsize = size(t_record->appt_type_cds,5)
 IF (retrieve_scheduling_items)
  SELECT INTO "nl:"
   a.person_id
   FROM sch_entry a,
    sch_event_action ea,
    sch_event e
   PLAN (a
    WHERE (a.person_id=t_record->person_id)
     AND a.entry_state_cd=pending_state_cd
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (ea
    WHERE ea.sch_action_id=a.sch_action_id
     AND ea.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (e
    WHERE e.sch_event_id=ea.sch_event_id
     AND e.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   ORDER BY a.sch_action_id
   HEAD REPORT
    sch_inqa_reply->query_qual_cnt = 0
   HEAD a.sch_action_id
    sch_inqa_reply->query_qual_cnt += 1
    IF (mod(sch_inqa_reply->query_qual_cnt,100)=1)
     stat = alterlist(sch_inqa_reply->query_qual,(sch_inqa_reply->query_qual_cnt+ 99)), stat =
     alterlist(t_record->event_qual,(sch_inqa_reply->query_qual_cnt+ 99))
    ENDIF
    sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#schentryid = a.sch_entry_id,
    sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#scheventid = a.sch_event_id,
    sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#scheduleid = a.schedule_id,
    sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#scheduleseq = e.schedule_seq,
    sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#reqactionid = a.sch_action_id,
    sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#actionid = ea.req_action_id,
    sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#schapptid = a.sch_appt_id,
    sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#statemeaning = e.sch_meaning,
    sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#latestdttm = cnvtdatetime(a
     .latest_dt_tm),
    sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#reqmadedttm = cnvtdatetime(a
     .request_made_dt_tm), sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].
    hide#entrystatemeaning = a.entry_state_meaning, sch_inqa_reply->query_qual[sch_inqa_reply->
    query_qual_cnt].hide#reqactionmeaning = a.req_action_meaning,
    sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#encounterid = a.encntr_id,
    sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#personid = a.person_id,
    sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#bitmask = 0,
    sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#wqmitemscript = 1, sch_inqa_reply
    ->query_qual[sch_inqa_reply->query_qual_cnt].no_contact_flag = a.no_contact_flag, sch_inqa_reply
    ->query_qual[sch_inqa_reply->query_qual_cnt].display_items = 1
    IF (a.earliest_dt_tm > cnvtdatetime("01-JAN-1800 00:00:00.00"))
     sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].earliest_dt_tm = cnvtdatetime(a
      .earliest_dt_tm)
    ELSE
     sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].earliest_dt_tm = 0
    ENDIF
    sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].created_dt_tm = a.request_made_dt_tm,
    sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].req_action_display =
    uar_get_code_display(ea.req_action_cd), sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt
    ].appt_type_display = uar_get_code_display(e.appt_synonym_cd),
    sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].person_name = "", sch_inqa_reply->
    query_qual[sch_inqa_reply->query_qual_cnt].sex = ""
    IF (e.protocol_type_flag=1)
     t_record->event_qual[sch_inqa_reply->query_qual_cnt].protocol_parent_id = e.sch_event_id
    ENDIF
   FOOT REPORT
    IF (mod(sch_inqa_reply->query_qual_cnt,100) != 0)
     stat = alterlist(sch_inqa_reply->query_qual,sch_inqa_reply->query_qual_cnt), stat = alterlist(
      t_record->event_qual,sch_inqa_reply->query_qual_cnt)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((sch_inqa_reply->query_qual_cnt > 0))
  SELECT INTO "nl:"
   d.seq
   FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
    sch_event e,
    sch_event_attach a
   PLAN (d
    WHERE (t_record->event_qual[d.seq].protocol_parent_id > 0))
    JOIN (e
    WHERE (e.protocol_parent_id=t_record->event_qual[d.seq].protocol_parent_id)
     AND  NOT (e.sch_meaning IN ("CANCELED", "NOSHOW"))
     AND e.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (a
    WHERE a.sch_event_id=e.sch_event_id
     AND a.attach_type_cd=order_type_cd
     AND (a.beg_schedule_seq <= sch_inqa_reply->query_qual[d.seq].hide#scheduleseq)
     AND (a.end_schedule_seq >= sch_inqa_reply->query_qual[d.seq].hide#scheduleseq)
     AND  NOT (a.order_status_meaning IN ("CANCELED", "COMPLETED", "DISCONTINUED"))
     AND a.state_meaning != "REMOVED"
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND a.active_ind=1)
   ORDER BY d.seq, e.protocol_seq_nbr, a.order_seq_nbr
   HEAD d.seq
    t_record->event_qual[d.seq].order_qual_cnt = 0
   DETAIL
    t_record->event_qual[d.seq].order_qual_cnt += 1
    IF (mod(t_record->event_qual[d.seq].order_qual_cnt,10)=1)
     stat = alterlist(t_record->event_qual[d.seq].order_qual,(t_record->event_qual[d.seq].
      order_qual_cnt+ 9))
    ENDIF
    t_record->event_qual[d.seq].order_qual[t_record->event_qual[d.seq].order_qual_cnt].order_id = a
    .order_id, t_record->event_qual[d.seq].order_qual[t_record->event_qual[d.seq].order_qual_cnt].
    description = a.description, t_record->event_qual[d.seq].order_qual[t_record->event_qual[d.seq].
    order_qual_cnt].order_seq_nbr = a.order_seq_nbr
   FOOT  d.seq
    IF (mod(t_record->event_qual[d.seq].order_qual_cnt,10) != 0)
     stat = alterlist(t_record->event_qual[d.seq].order_qual,t_record->event_qual[d.seq].
      order_qual_cnt)
    ENDIF
    IF ((t_record->event_qual[d.seq].order_qual_cnt > t_record->max_order_cnt))
     t_record->max_order_cnt = t_record->event_qual[d.seq].order_qual_cnt
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   d.seq
   FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
    sch_event_attach a
   PLAN (d
    WHERE (t_record->event_qual[d.seq].protocol_parent_id <= 0))
    JOIN (a
    WHERE (a.sch_event_id=sch_inqa_reply->query_qual[d.seq].hide#scheventid)
     AND a.attach_type_cd=order_type_cd
     AND (a.beg_schedule_seq <= sch_inqa_reply->query_qual[d.seq].hide#scheduleseq)
     AND (a.end_schedule_seq >= sch_inqa_reply->query_qual[d.seq].hide#scheduleseq)
     AND  NOT (a.order_status_meaning IN ("CANCELED", "COMPLETED", "DISCONTINUED"))
     AND a.state_meaning != "REMOVED"
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND a.active_ind=1)
   ORDER BY d.seq, a.order_seq_nbr
   HEAD d.seq
    t_record->event_qual[d.seq].order_qual_cnt = 0
   DETAIL
    t_record->event_qual[d.seq].order_qual_cnt += 1
    IF (mod(t_record->event_qual[d.seq].order_qual_cnt,10)=1)
     stat = alterlist(t_record->event_qual[d.seq].order_qual,(t_record->event_qual[d.seq].
      order_qual_cnt+ 9))
    ENDIF
    t_record->event_qual[d.seq].order_qual[t_record->event_qual[d.seq].order_qual_cnt].order_id = a
    .order_id, t_record->event_qual[d.seq].order_qual[t_record->event_qual[d.seq].order_qual_cnt].
    description = a.description, t_record->event_qual[d.seq].order_qual[t_record->event_qual[d.seq].
    order_qual_cnt].order_seq_nbr = a.order_seq_nbr
    IF (request->call_echo_ind)
     CALL echo(build("PROTOCOL_PARENT_ID[",t_record->event_qual[d.seq].protocol_parent_id,
      "] SCH_EVENT_ID[",a.sch_event_id,"] ORDER_ID[",
      a.order_id,"]"))
    ENDIF
   FOOT  d.seq
    IF (mod(t_record->event_qual[d.seq].order_qual_cnt,10) != 0)
     stat = alterlist(t_record->event_qual[d.seq].order_qual,t_record->event_qual[d.seq].
      order_qual_cnt)
    ENDIF
    IF ((t_record->event_qual[d.seq].order_qual_cnt > t_record->max_order_cnt))
     t_record->max_order_cnt = t_record->event_qual[d.seq].order_qual_cnt
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((t_record->max_order_cnt > 0))
  SET act_seq = 0
  SELECT INTO "nl:"
   t_order_seq_nbr = t_record->event_qual[d.seq].order_qual[d2.seq].order_seq_nbr, od_exists =
   evaluate(nullind(od.order_id),1,0,1)
   FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
    (dummyt d2  WITH seq = value(t_record->max_order_cnt)),
    orders o,
    order_action oa,
    (left JOIN order_detail od ON od.order_id=oa.order_id
     AND od.action_sequence=oa.action_sequence
     AND ((od.oe_field_meaning_id=priority_id) OR (od.oe_field_meaning_id=isolation_ind)) ),
    (left JOIN order_detail od2 ON od2.order_id=oa.order_id
     AND od2.action_sequence=oa.action_sequence
     AND od2.oe_field_meaning="ORDERLOC"),
    (left JOIN prsnl p ON p.person_id=oa.order_provider_id)
   PLAN (d)
    JOIN (d2
    WHERE (d2.seq <= t_record->event_qual[d.seq].order_qual_cnt))
    JOIN (o
    WHERE (o.order_id=t_record->event_qual[d.seq].order_qual[d2.seq].order_id))
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND ((oa.action_type_cd=order_action_cd) OR (((oa.action_type_cd=modify_action_cd) OR (((oa
    .action_type_cd=activate_action_cd) OR (((oa.action_type_cd=futuredc_action_cd) OR (((oa
    .action_type_cd=renew_action_cd) OR (((oa.action_type_cd=resume_renew_action_cd) OR (oa
    .action_type_cd=collection_action_cd)) )) )) )) )) ))
     AND oa.action_rejected_ind=0)
    JOIN (od)
    JOIN (od2)
    JOIN (p)
   ORDER BY d.seq, d2.seq, o.order_id,
    od.oe_field_id, od.action_sequence DESC, od2.action_sequence DESC
   HEAD d.seq
    t_index = 0
   HEAD d2.seq
    t_index = 0
   HEAD o.order_id
    sch_inqa_reply->query_qual[d.seq].hide#orderid = t_record->event_qual[d.seq].order_qual[d2.seq].
    order_id, sch_inqa_reply->query_qual[d.seq].order_date = o.orig_order_dt_tm, sch_inqa_reply->
    query_qual[d.seq].ordering_provider = substring(1,100,p.name_full_formatted)
    IF ((sch_inqa_reply->query_qual[d.seq].ordered_as_mnemonic <= " "))
     sch_inqa_reply->query_qual[d.seq].ordered_as_mnemonic = trim(uar_get_code_display(o.catalog_cd))
    ELSE
     sch_inqa_reply->query_qual[d.seq].ordered_as_mnemonic = concat(sch_inqa_reply->query_qual[d.seq]
      .ordered_as_mnemonic,"; ",trim(uar_get_code_display(o.catalog_cd)))
    ENDIF
    sch_inqa_reply->query_qual[d.seq].document_source = uar_get_code_display(o.contributor_system_cd)
    IF ((sch_inqa_reply->query_qual[d.seq].orders <= " "))
     sch_inqa_reply->query_qual[d.seq].orders = o.order_detail_display_line
    ENDIF
    IF (o.orig_ord_as_flag=4)
     sch_inqa_reply->query_qual[d.seq].inpatient = uar_i18ngetmessage(i18nhandle,"Yes","Yes")
    ENDIF
   HEAD od.oe_field_id
    act_seq = od.action_sequence, flag = 1
   HEAD od.action_sequence
    IF (act_seq != od.action_sequence)
     flag = 0
    ENDIF
   DETAIL
    IF (flag=1
     AND od_exists=1)
     IF (od.oe_field_value=stat_cd)
      sch_inqa_reply->query_qual[d.seq].stat = uar_i18ngetmessage(i18nhandle,"Yes","Yes")
     ELSEIF (od.oe_field_meaning_id=isolation_ind)
      sch_inqa_reply->query_qual[d.seq].isolation_type = od.oe_field_display_value
     ENDIF
    ENDIF
    IF (size(sch_inqa_reply->query_qual[d.seq].order_loc)=0)
     sch_inqa_reply->query_qual[d.seq].order_loc = od2.oe_field_display_value
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   oc.order_id, oc.action_sequence, oc.comment_type_cd
   FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
    (dummyt d2  WITH seq = value(t_record->max_order_cnt)),
    order_comment oc
   PLAN (d
    WHERE (t_record->event_qual[d.seq].order_qual_cnt > 0))
    JOIN (d2
    WHERE (d2.seq <= t_record->event_qual[d.seq].order_qual_cnt))
    JOIN (oc
    WHERE (oc.order_id=t_record->event_qual[d.seq].order_qual[d2.seq].order_id)
     AND oc.comment_type_cd=ordcomment_cd)
   HEAD d.seq
    sch_inqa_reply->query_qual[d.seq].order_cmt = uar_i18ngetmessage(i18nhandle,"Yes","Yes")
   WITH nocounter
  ;end select
 ENDIF
 IF ((sch_inqa_reply->query_qual_cnt > 0))
  SELECT INTO "nl:"
   sed.oe_field_display_value
   FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
    sch_event_detail sed
   PLAN (d
    WHERE (sch_inqa_reply->query_qual[d.seq].hide#scheventid > 0))
    JOIN (sed
    WHERE (sed.sch_event_id= Outerjoin(sch_inqa_reply->query_qual[d.seq].hide#scheventid))
     AND (sed.oe_field_meaning= Outerjoin("SCHORDPHYS"))
     AND (sed.version_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
     AND (sed.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
     AND (sed.active_ind= Outerjoin(1)) )
   ORDER BY d.seq
   DETAIL
    sch_inqa_reply->query_qual[d.seq].ordering_physician = sed.oe_field_display_value, sch_inqa_reply
    ->query_qual[d.seq].hide#orderingphysicianid = sed.oe_field_value
   WITH nocounter
  ;end select
  IF (display_pref_agreement_status)
   SET stat = alterlist(provagreeinforeq->agreement_items,sch_inqa_reply->query_qual_cnt)
   FOR (i = 1 TO size(provagreeinforeq->agreement_items,5))
     SET provagreeinforeq->agreement_items[i].sch_event_id = sch_inqa_reply->query_qual[i].
     hide#scheventid
     SET provagreeinforeq->agreement_items[i].prsnl_id = sch_inqa_reply->query_qual[i].
     hide#orderingphysicianid
     IF ((sch_inqa_reply->query_qual[i].hide#encounterid > 0))
      SET stat = alterlist(provagreeinforeq->agreement_items[i].encounters,1)
      SET provagreeinforeq->agreement_items[i].encounters[1].encounter_id = sch_inqa_reply->
      query_qual[i].hide#encounterid
     ENDIF
     SET stat = alterlist(provagreeinforeq->agreement_items[i].orders,t_record->event_qual[i].
      order_qual_cnt)
     FOR (j = 1 TO t_record->event_qual[i].order_qual_cnt)
       SET provagreeinforeq->agreement_items[i].orders[j].order_id = t_record->event_qual[i].
       order_qual[j].order_id
     ENDFOR
   ENDFOR
   EXECUTE sch_get_prov_agree_query_info  WITH replace("REQUEST",provagreeinforeq), replace("REPLY",
    provagreeinforep)
   IF ((provagreeinforep->status_data.status="S"))
    FOR (i = 1 TO size(provagreeinforep->agreement_statuses,5))
      SET sch_inqa_reply->query_qual[i].pref_agreement_status = provagreeinforep->agreement_statuses[
      i].pref_agreement_status_display
    ENDFOR
   ENDIF
  ENDIF
 ENDIF
 SET stat = alterlist(wqmitemsuserquereq->queue_ids,1)
 SET wqmitemsuserquereq->view_id = t_record->view_id
 SET wqmitemsuserquereq->max_results = 250
 SET wqmitemsuserquereq->ignore_inprocess_flag = 1
 SET providersetphylistsize = size(providersetordphyrec->providerset_ord_physician_ids,5)
 IF (providersetphylistsize > 0)
  SET t_recphylistsize = size(t_record->ord_physician_ids,5)
  SET stat = alterlist(t_record->ord_physician_ids,(t_recphylistsize+ providersetphylistsize))
  SET stat = movereclist(providersetordphyrec->providerset_ord_physician_ids,t_record->
   ord_physician_ids,1,0,providersetphylistsize,
   true)
  SET stat = alterlist(t_record->ord_physician_ids,(t_recphylistsize+ providersetphylistsize))
 ENDIF
 SET physicianlistsize = size(t_record->ord_physician_ids,5)
 SET modalitylistsize = size(t_record->modality_cds,5)
 IF (physicianlistsize > 0)
  SET stat = alterlist(wqmitemsuserquereq->ord_physician_ids,physicianlistsize)
  SET stat = movereclist(t_record->ord_physician_ids,wqmitemsuserquereq->ord_physician_ids,1,0,
   physicianlistsize,
   true)
  SET stat = alterlist(wqmitemsuserquereq->ord_physician_ids,physicianlistsize)
 ENDIF
 IF (modalitylistsize > 0)
  SET stat = alterlist(wqmitemsuserquereq->modality_cds,modalitylistsize)
  SET stat = movereclist(t_record->modality_cds,wqmitemsuserquereq->modality_cds,1,0,modalitylistsize,
   true)
  SET stat = alterlist(wqmitemsuserquereq->modality_cds,modalitylistsize)
 ENDIF
 SET wqmitemsuserquereq->beg_dt_tm = t_record->beg_dt_tm
 SET wqmitemsuserquereq->end_dt_tm = t_record->end_dt_tm
 IF ((t_record->view_id > 0)
  AND retrieve_wqm_items)
  EXECUTE sch_get_workitems_user_queues  WITH replace("REQUEST",wqmitemsuserquereq), replace("REPLY",
   wqmitemsuserquerep)
 ENDIF
 SET listsize = size(wqmitemsuserquerep->work_items,5)
 SET stat = alterlist(sch_inqa_reply->query_qual,(sch_inqa_reply->query_qual_cnt+ listsize))
 SET numwqmitems = wqmitemsuserquerep->work_item_count
 FOR (i = 1 TO listsize)
   SET sch_inqa_reply->query_qual_cnt += 1
   SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#wqmworkitemid =
   wqmitemsuserquerep->work_items[i].work_item_id
   SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].document_source =
   wqmitemsuserquerep->work_items[i].sending_location_display
   SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].created_dt_tm = wqmitemsuserquerep
   ->work_items[i].create_dt_tm
   IF ((wqmitemsuserquerep->work_items[i].parent_entity_name="PERSON"))
    SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#personid = wqmitemsuserquerep
    ->work_items[i].parent_entity_id
   ELSE
    SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#encounterid =
    wqmitemsuserquerep->work_items[i].parent_entity_id
   ENDIF
   SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#blobhandle =
   wqmitemsuserquerep->work_items[i].blob_handle
   IF ((sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#blobhandle != ""))
    SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].images = "Y"
   ENDIF
   IF ((wqmitemsuserquerep->work_items[i].auto_dial_ind=0))
    SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].no_contact_flag = 1
   ELSE
    SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].no_contact_flag = 0
   ENDIF
   SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].appt_type_display =
   wqmitemsuserquerep->work_items[i].category_display
   SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].req_action_display =
   uar_get_code_display(wqm_req_action_cd)
   SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#wqmdocumenttypecd =
   wqmitemsuserquerep->work_items[i].document_type_cd
   SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].orders = ""
   SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].ordering_physician =
   wqmitemsuserquerep->work_items[i].ordering_provider_name
   SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#wqmitemscript = 1
   SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#wqmupdtcnt =
   wqmitemsuserquerep->work_items[i].update_count
   SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].display_items = wqmitemsuserquerep
   ->work_items[i].contact_made_today_flag
   SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].contact_count = wqmitemsuserquerep
   ->work_items[i].contact_attempt_count
   SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#cdipendingdocumentid =
   wqmitemsuserquerep->work_items[i].cdi_pending_document_id
   SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#documenttypedisplay =
   wqmitemsuserquerep->work_items[i].document_type_display
   SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#sendinglocationcd =
   wqmitemsuserquerep->work_items[i].sending_location_cd
   SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#orderingphysicianid =
   wqmitemsuserquerep->work_items[i].ordering_provider_id
   SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].pref_agreement_status =
   wqmitemsuserquerep->work_items[i].pref_agreement_status_display
   SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].hide#statuscd = wqmitemsuserquerep
   ->work_items[i].status_cd
   SET prioritymeaning = uar_get_code_meaning(wqmitemsuserquerep->work_items[i].priority_cd)
   IF (prioritymeaning="STAT")
    SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].stat = uar_i18ngetmessage(
     i18nhandle,"Yes","Yes")
   ENDIF
   SET workitemactionlist = size(wqmitemsuserquerep->work_items[i].work_item_actions,5)
   SET tempactionlistdtm = cnvtdatetime(curdate,0000)
   SET contactcommentfoundind = 0
   SET tempcontactcomment = ""
   FOR (j = 1 TO workitemactionlist)
     IF ((wqmitemsuserquerep->work_items[i].work_item_actions[j].work_item_action_type_flag=0))
      IF (contactcommentfoundind=0)
       SET tempcontactcomment = wqmitemsuserquerep->work_items[i].work_item_actions[j].comment
       SET tempactionlistdtm = cnvtdatetime(wqmitemsuserquerep->work_items[i].work_item_actions[j].
        work_item_action_dt_time)
       SET tempcontactcmtprsnlid = wqmitemsuserquerep->work_items[i].work_item_actions[j].
       action_prsnl_id
       SET predefinedcomment = wqmitemsuserquerep->work_items[i].work_item_actions[j].
       predefined_comment_display
       SET predefinedcommentcd = wqmitemsuserquerep->work_items[i].work_item_actions[j].
       predefined_comment_cd
       SET contactcommentfoundind = 1
       IF (pref_value > 0.0)
        SET follow_up_date_timestamp = wqmitemsuserquerep->work_items[i].work_item_actions[j].
        follow_up_dt_tm
       ENDIF
      ELSE
       IF (cnvtdatetime(wqmitemsuserquerep->work_items[i].work_item_actions[j].
        work_item_action_dt_time) > cnvtdatetime(tempactionlistdtm))
        SET tempcontactcomment = wqmitemsuserquerep->work_items[i].work_item_actions[j].comment
        SET tempactionlistdtm = cnvtdatetime(wqmitemsuserquerep->work_items[i].work_item_actions[j].
         work_item_action_dt_time)
        SET tempcontactcmtprsnlid = wqmitemsuserquerep->work_items[i].work_item_actions[j].
        action_prsnl_id
        SET predefinedcomment = wqmitemsuserquerep->work_items[i].work_item_actions[j].
        predefined_comment_display
        SET predefinedcommentcd = wqmitemsuserquerep->work_items[i].work_item_actions[j].
        predefined_comment_cd
        IF (pref_value > 0.0)
         SET follow_up_date_timestamp = wqmitemsuserquerep->work_items[i].work_item_actions[j].
         follow_up_dt_tm
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (contactcommentfoundind=1)
    IF (predefinedcommentcd > 0)
     SET lastcontactcomment = predefinedcomment
     IF (size(tempcontactcomment,1) > 0)
      SET lastcontactcomment = build2(trim(predefinedcomment),". ",trim(tempcontactcomment))
     ENDIF
    ELSE
     SET lastcontactcomment = tempcontactcomment
    ENDIF
    SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].last_contact_comment =
    lastcontactcomment
    SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].contact_comment_prsnl_id =
    tempcontactcmtprsnlid
    SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].contact_comment_timestamp =
    tempactionlistdtm
    IF (pref_value > 0.0
     AND follow_up_date_timestamp > 0)
     SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].follow_up_date_timestamp =
     follow_up_date_timestamp
    ENDIF
   ELSE
    SET sch_inqa_reply->query_qual[sch_inqa_reply->query_qual_cnt].contact_comment_prsnl_id = 0.0
   ENDIF
 ENDFOR
 IF ((sch_inqa_reply->query_qual_cnt > 0))
  SELECT INTO "nl:"
   p.person_id
   FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
    person p
   PLAN (d
    WHERE (sch_inqa_reply->query_qual[d.seq].hide#personid > 0))
    JOIN (p
    WHERE (p.person_id=sch_inqa_reply->query_qual[d.seq].hide#personid))
   ORDER BY d.seq
   DETAIL
    sch_inqa_reply->query_qual[d.seq].person_name = p.name_full_formatted, sch_inqa_reply->
    query_qual[d.seq].dob = p.birth_dt_tm, sch_inqa_reply->query_qual[d.seq].sex =
    uar_get_code_display(p.sex_cd)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   p.person_id
   FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
    person p,
    encounter e
   PLAN (d
    WHERE (sch_inqa_reply->query_qual[d.seq].hide#personid=0.0)
     AND (sch_inqa_reply->query_qual[d.seq].hide#encounterid > 0))
    JOIN (e
    WHERE (e.encntr_id=sch_inqa_reply->query_qual[d.seq].hide#encounterid))
    JOIN (p
    WHERE p.person_id=e.person_id)
   ORDER BY d.seq
   DETAIL
    sch_inqa_reply->query_qual[d.seq].hide#personid = p.person_id, sch_inqa_reply->query_qual[d.seq].
    person_name = p.name_full_formatted, sch_inqa_reply->query_qual[d.seq].dob = p.birth_dt_tm,
    sch_inqa_reply->query_qual[d.seq].sex = uar_get_code_display(p.sex_cd)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   e.encounter_id
   FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
    encounter e
   PLAN (d
    WHERE (sch_inqa_reply->query_qual[d.seq].hide#encounterid > 0))
    JOIN (e
    WHERE (e.encntr_id=sch_inqa_reply->query_qual[d.seq].hide#encounterid))
   ORDER BY d.seq
   DETAIL
    IF (e.encntr_type_class_cd=inpatient_cd)
     sch_inqa_reply->query_qual[d.seq].inpatient = uar_i18ngetmessage(i18nhandle,"Yes","Yes")
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   ph.phone_id
   FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
    phone ph
   PLAN (d
    WHERE (sch_inqa_reply->query_qual[d.seq].hide#personid > 0))
    JOIN (ph
    WHERE (ph.parent_entity_id=sch_inqa_reply->query_qual[d.seq].hide#personid)
     AND ph.parent_entity_name="PERSON"
     AND ph.phone_id != 0
     AND ph.phone_type_cd=home_phone_cd
     AND ph.active_ind=1
     AND ph.phone_type_seq=1
     AND ph.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ph.end_effective_dt_tm >= cnvtdatetime(sysdate))
   ORDER BY d.seq
   DETAIL
    sch_inqa_reply->query_qual[d.seq].home_phone = cnvtphone(cnvtalphanum(ph.phone_num),ph
     .phone_format_cd)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   addr.city
   FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
    address addr
   PLAN (d
    WHERE (sch_inqa_reply->query_qual[d.seq].hide#personid > 0))
    JOIN (addr
    WHERE (addr.parent_entity_id=sch_inqa_reply->query_qual[d.seq].hide#personid)
     AND addr.parent_entity_name="PERSON"
     AND addr.address_type_cd=mf_addr_type_cd
     AND addr.address_id != 0
     AND addr.active_ind=1)
   ORDER BY d.seq
   DETAIL
    sch_inqa_reply->query_qual[d.seq].address = addr.city
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   sed.oe_field_display_value
   FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
    sch_event_detail sed
   PLAN (d
    WHERE (sch_inqa_reply->query_qual[d.seq].hide#scheventid > 0))
    JOIN (sed
    WHERE (sed.sch_event_id= Outerjoin(sch_inqa_reply->query_qual[d.seq].hide#scheventid))
     AND (sed.oe_field_meaning= Outerjoin("SCHORDPHYS"))
     AND (sed.version_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
     AND (sed.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
     AND (sed.active_ind= Outerjoin(1)) )
   ORDER BY d.seq
   DETAIL
    sch_inqa_reply->query_qual[d.seq].ordering_physician = sed.oe_field_display_value, sch_inqa_reply
    ->query_qual[d.seq].hide#orderingphysicianid = sed.oe_field_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   pa.alias
   FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
    person_alias pa
   PLAN (d
    WHERE (sch_inqa_reply->query_qual[d.seq].hide#personid > 0))
    JOIN (pa
    WHERE (pa.person_id=sch_inqa_reply->query_qual[d.seq].hide#personid)
     AND pa.person_id != 0
     AND pa.person_alias_type_cd=mrn_cd
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND pa.end_effective_dt_tm >= cnvtdatetime(sysdate))
   ORDER BY d.seq
   DETAIL
    sch_inqa_reply->query_qual[d.seq].mrn = substring(1,20,cnvtalias(pa.alias,pa.alias_pool_cd))
   WITH nocounter
  ;end select
  CALL echo(build("cnt[",sch_inqa_reply->query_qual_cnt,"]"))
  SELECT INTO "nl:"
   t_sort = evaluate(a.role_meaning,"PATIENT",2,a.primary_role_ind), a.updt_cnt
   FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
    sch_appt a
   PLAN (d
    WHERE (sch_inqa_reply->query_qual[d.seq].hide#scheventid > 0)
     AND (sch_inqa_reply->query_qual[d.seq].hide#scheduleid > 0))
    JOIN (a
    WHERE (a.sch_event_id=sch_inqa_reply->query_qual[d.seq].hide#scheventid)
     AND (a.schedule_id=sch_inqa_reply->query_qual[d.seq].hide#scheduleid)
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   ORDER BY d.seq, t_sort
   DETAIL
    sch_inqa_reply->query_qual[d.seq].hide#bitmask = a.bit_mask, sch_inqa_reply->query_qual[d.seq].
    scheduled_dt_tm = cnvtdatetime(a.beg_dt_tm)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   a.updt_cnt
   FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
    sch_event_comm a,
    long_text lt
   PLAN (d
    WHERE (sch_inqa_reply->query_qual[d.seq].hide#scheventid > 0))
    JOIN (a
    WHERE (a.sch_event_id=sch_inqa_reply->query_qual[d.seq].hide#scheventid)
     AND a.sch_action_id IN (sch_inqa_reply->query_qual[d.seq].hide#reqactionid, sch_inqa_reply->
    query_qual[d.seq].hide#actionid)
     AND a.text_type_meaning="ACTION"
     AND a.sub_text_meaning="ACTION"
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (lt
    WHERE lt.long_text_id=a.text_id)
   DETAIL
    sch_inqa_reply->query_qual[d.seq].cmt = trim(lt.long_text)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
    rad_protocol_act rpa
   PLAN (d
    WHERE (sch_inqa_reply->query_qual[d.seq].hide#scheventid > 0))
    JOIN (rpa
    WHERE (rpa.order_id=sch_inqa_reply->query_qual[d.seq].hide#orderid))
   ORDER BY d.seq, rpa.last_updt_dt_tm DESC
   HEAD d.seq
    null, sch_inqa_reply->query_qual[d.seq].protocol_cmt = trim(rpa.comment_txt)
   WITH nocounter
  ;end select
  SET pref_type_code = 0.0
  SET stat = uar_get_meaning_by_codeset(23010,"CNTCTFUPDTTM",1,pref_type_code)
  IF (pref_type_code > 0.0)
   SELECT INTO "nl:"
    a.pref_id
    FROM sch_pref a
    PLAN (a
     WHERE a.pref_type_cd=pref_type_code
      AND a.parent_table="SYSTEM"
      AND a.parent_id=0
      AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    DETAIL
     pref_value = a.pref_value
    WITH nocounter
   ;end select
  ELSE
   SET pref_value = 0.0
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
    sch_event_action sea,
    sch_event_comm sec,
    long_text lt,
    prsnl pr
   PLAN (d
    WHERE (sch_inqa_reply->query_qual[d.seq].hide#scheventid > 0))
    JOIN (sea
    WHERE (sea.sch_event_id=sch_inqa_reply->query_qual[d.seq].hide#scheventid)
     AND sea.action_meaning="CONTACT")
    JOIN (sec
    WHERE (sec.sch_action_id= Outerjoin(sea.sch_action_id))
     AND (sec.sch_event_id= Outerjoin(sch_inqa_reply->query_qual[d.seq].hide#scheventid))
     AND (sec.text_type_meaning= Outerjoin("ACTION"))
     AND (sec.active_ind= Outerjoin(1)) )
    JOIN (lt
    WHERE (lt.long_text_id= Outerjoin(sec.text_id))
     AND (lt.active_ind= Outerjoin(1)) )
    JOIN (pr
    WHERE (pr.person_id= Outerjoin(lt.updt_id)) )
   ORDER BY sea.updt_dt_tm
   DETAIL
    IF (lt.long_text_id > 0)
     sch_inqa_reply->query_qual[d.seq].last_contact_comment = lt.long_text, sch_inqa_reply->
     query_qual[d.seq].contact_comment_timestamp = lt.updt_dt_tm, sch_inqa_reply->query_qual[d.seq].
     contact_comment_prsnl_id = pr.person_id,
     sch_inqa_reply->query_qual[d.seq].follow_up_date_timestamp = sea.contact_follow_up_dt_tm
    ELSE
     sch_inqa_reply->query_qual[d.seq].last_contact_comment = trim("")
    ENDIF
    sch_inqa_reply->query_qual[d.seq].contact_count += 1, sch_inqa_reply->query_qual[d.seq].
    follow_up_date_timestamp = sea.contact_follow_up_dt_tm
   WITH nocounter
  ;end select
  IF (pref_value > 0.0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
     sch_event_action sea
    PLAN (d
     WHERE (sch_inqa_reply->query_qual[d.seq].hide#scheventid > 0))
     JOIN (sea
     WHERE (sea.sch_event_id=sch_inqa_reply->query_qual[d.seq].hide#scheventid))
    ORDER BY sea.contact_follow_up_dt_tm DESC
    DETAIL
     IF (sea.action_meaning="CONTACT"
      AND sea.contact_follow_up_dt_tm > cnvtdatetime(curdate,235959))
      sch_inqa_reply->query_qual[d.seq].display_items = 0
     ENDIF
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
     sch_event_action sea
    PLAN (d
     WHERE (sch_inqa_reply->query_qual[d.seq].hide#scheventid > 0))
     JOIN (sea
     WHERE (sea.sch_event_id=sch_inqa_reply->query_qual[d.seq].hide#scheventid)
      AND sea.action_meaning="CONTACT"
      AND sea.perform_dt_tm BETWEEN cnvtdatetime(curdate,0000) AND cnvtdatetime(curdate,235959))
    ORDER BY sea.perform_dt_tm DESC
    DETAIL
     sch_inqa_reply->query_qual[d.seq].display_items = 0
    WITH nocounter
   ;end select
  ENDIF
  IF (pref_value > 0.0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
     prsnl p
    PLAN (d
     WHERE (((sch_inqa_reply->query_qual[d.seq].contact_comment_prsnl_id > 0)) OR ((sch_inqa_reply->
     query_qual[d.seq].follow_up_date_timestamp > 0))) )
     JOIN (p
     WHERE (p.person_id=sch_inqa_reply->query_qual[d.seq].contact_comment_prsnl_id))
    DETAIL
     IF (size(sch_inqa_reply->query_qual[d.seq].last_contact_comment,1) > 0)
      IF ((sch_inqa_reply->query_qual[d.seq].follow_up_date_timestamp > 0))
       sch_inqa_reply->query_qual[d.seq].last_contact_comment = build2(trim(sch_inqa_reply->
         query_qual[d.seq].last_contact_comment)," (",trim(p.username)," - ",format(sch_inqa_reply->
         query_qual[d.seq].contact_comment_timestamp,"@SHORTDATETIME"),
        ")",", ",follow_up_date_text,format(sch_inqa_reply->query_qual[d.seq].
         follow_up_date_timestamp,"@SHORTDATETIME"))
      ELSE
       sch_inqa_reply->query_qual[d.seq].last_contact_comment = build2(trim(sch_inqa_reply->
         query_qual[d.seq].last_contact_comment)," (",trim(p.username)," - ",format(sch_inqa_reply->
         query_qual[d.seq].contact_comment_timestamp,"@SHORTDATETIME"),
        ")")
      ENDIF
     ELSEIF ((sch_inqa_reply->query_qual[d.seq].follow_up_date_timestamp > 0))
      sch_inqa_reply->query_qual[d.seq].last_contact_comment = build2(follow_up_date_text,format(
        sch_inqa_reply->query_qual[d.seq].follow_up_date_timestamp,"@SHORTDATETIME"))
     ENDIF
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt)),
     prsnl p
    PLAN (d
     WHERE (sch_inqa_reply->query_qual[d.seq].contact_comment_prsnl_id > 0)
      AND size(sch_inqa_reply->query_qual[d.seq].last_contact_comment,1) > 0)
     JOIN (p
     WHERE (p.person_id=sch_inqa_reply->query_qual[d.seq].contact_comment_prsnl_id))
    DETAIL
     sch_inqa_reply->query_qual[d.seq].last_contact_comment = build2(trim(sch_inqa_reply->query_qual[
       d.seq].last_contact_comment)," (",trim(p.username)," - ",format(sch_inqa_reply->query_qual[d
       .seq].contact_comment_timestamp,"@SHORTDATETIME"),
      ")")
    WITH nocounter
   ;end select
  ENDIF
  SET reply->query_qual_cnt = 0
  SET stat = alterlist(reply->query_qual,56)
  SET reply->attr_qual_cnt = sch_inqa_reply->attr_qual_cnt
  SET stat = alterlist(reply->attr_qual,reply->attr_qual_cnt)
  SET stat = moverec(sch_inqa_reply->attr_qual,reply->attr_qual)
  SET listsize = size(t_record->ord_physician_ids,5)
  SET record_index = 0
  IF (providerset_default=1)
   CALL copyschinqreptoreply(null)
  ELSE
   SELECT INTO "n1:"
    FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt))
    PLAN (d
     WHERE (((sch_inqa_reply->query_qual[d.seq].hide#scheventid > 0)) OR ((sch_inqa_reply->
     query_qual[d.seq].hide#wqmworkitemid > 0)))
      AND (sch_inqa_reply->query_qual[d.seq].display_items=1)
      AND ((listsize=0) OR ((((sch_inqa_reply->query_qual[d.seq].hide#wqmworkitemid > 0)) OR (expand(
      record_index,1,listsize,sch_inqa_reply->query_qual[d.seq].hide#orderingphysicianid,t_record->
      ord_physician_ids[record_index].ord_physician_id))) )) )
    ORDER BY sch_inqa_reply->query_qual[d.seq].created_dt_tm
    DETAIL
     reply->query_qual_cnt += 1
     IF (mod(reply->query_qual_cnt,100)=1)
      stat = alterlist(reply->query_qual,(reply->query_qual_cnt+ 99))
     ENDIF
     IF ((sch_inqa_reply->query_qual[d.seq].hide#scheventid > 0))
      scheduleitemsfound += 1
     ENDIF
     reply->query_qual[reply->query_qual_cnt].hide#schentryid = sch_inqa_reply->query_qual[d.seq].
     hide#schentryid, reply->query_qual[reply->query_qual_cnt].hide#scheduleseq = sch_inqa_reply->
     query_qual[d.seq].hide#scheduleseq, reply->query_qual[reply->query_qual_cnt].hide#reqactionid =
     sch_inqa_reply->query_qual[d.seq].hide#reqactionid,
     reply->query_qual[reply->query_qual_cnt].hide#actionid = sch_inqa_reply->query_qual[d.seq].
     hide#actionid, reply->query_qual[reply->query_qual_cnt].hide#schapptid = sch_inqa_reply->
     query_qual[d.seq].hide#schapptid, reply->query_qual[reply->query_qual_cnt].hide#statemeaning =
     sch_inqa_reply->query_qual[d.seq].hide#statemeaning,
     reply->query_qual[reply->query_qual_cnt].hide#latestdttm = sch_inqa_reply->query_qual[d.seq].
     hide#latestdttm, reply->query_qual[reply->query_qual_cnt].hide#reqmadedttm = sch_inqa_reply->
     query_qual[d.seq].hide#reqmadedttm, reply->query_qual[reply->query_qual_cnt].
     hide#entrystatemeaning = sch_inqa_reply->query_qual[d.seq].hide#entrystatemeaning,
     reply->query_qual[reply->query_qual_cnt].hide#reqactionmeaning = sch_inqa_reply->query_qual[d
     .seq].hide#reqactionmeaning, reply->query_qual[reply->query_qual_cnt].hide#encounterid =
     sch_inqa_reply->query_qual[d.seq].hide#encounterid, reply->query_qual[reply->query_qual_cnt].
     hide#personid = sch_inqa_reply->query_qual[d.seq].hide#personid,
     reply->query_qual[reply->query_qual_cnt].hide#bitmask = sch_inqa_reply->query_qual[d.seq].
     hide#bitmask, reply->query_qual[reply->query_qual_cnt].hide#blobhandle = sch_inqa_reply->
     query_qual[d.seq].hide#blobhandle, reply->query_qual[reply->query_qual_cnt].hide#orderid =
     sch_inqa_reply->query_qual[d.seq].hide#orderid,
     reply->query_qual[reply->query_qual_cnt].hide#scheduleid = sch_inqa_reply->query_qual[d.seq].
     hide#scheduleid, reply->query_qual[reply->query_qual_cnt].hide#scheventid = sch_inqa_reply->
     query_qual[d.seq].hide#scheventid, reply->query_qual[reply->query_qual_cnt].
     hide#wqmdocumenttypecd = sch_inqa_reply->query_qual[d.seq].hide#wqmdocumenttypecd,
     reply->query_qual[reply->query_qual_cnt].hide#wqmupdtcnt = sch_inqa_reply->query_qual[d.seq].
     hide#wqmupdtcnt, reply->query_qual[reply->query_qual_cnt].hide#wqmworkitemid = sch_inqa_reply->
     query_qual[d.seq].hide#wqmworkitemid, reply->query_qual[reply->query_qual_cnt].
     hide#wqmitemscript = sch_inqa_reply->query_qual[d.seq].hide#wqmitemscript,
     reply->query_qual[reply->query_qual_cnt].hide#cdipendingdocumentid = sch_inqa_reply->query_qual[
     d.seq].hide#cdipendingdocumentid, reply->query_qual[reply->query_qual_cnt].
     hide#documenttypedisplay = sch_inqa_reply->query_qual[d.seq].hide#documenttypedisplay, reply->
     query_qual[reply->query_qual_cnt].hide#sendinglocationcd = sch_inqa_reply->query_qual[d.seq].
     hide#sendinglocationcd,
     reply->query_qual[reply->query_qual_cnt].hide#orderingphysicianid = sch_inqa_reply->query_qual[d
     .seq].hide#orderingphysicianid, reply->query_qual[reply->query_qual_cnt].hide#statuscd =
     sch_inqa_reply->query_qual[d.seq].hide#statuscd, reply->query_qual[reply->query_qual_cnt].
     appt_type_display = sch_inqa_reply->query_qual[d.seq].appt_type_display,
     reply->query_qual[reply->query_qual_cnt].contact_count = sch_inqa_reply->query_qual[d.seq].
     contact_count, reply->query_qual[reply->query_qual_cnt].last_contact_comment = sch_inqa_reply->
     query_qual[d.seq].last_contact_comment, reply->query_qual[reply->query_qual_cnt].created_dt_tm
      = sch_inqa_reply->query_qual[d.seq].created_dt_tm,
     reply->query_qual[reply->query_qual_cnt].dob = sch_inqa_reply->query_qual[d.seq].dob, reply->
     query_qual[reply->query_qual_cnt].document_source = sch_inqa_reply->query_qual[d.seq].
     document_source, reply->query_qual[reply->query_qual_cnt].earliest_dt_tm = sch_inqa_reply->
     query_qual[d.seq].earliest_dt_tm,
     reply->query_qual[reply->query_qual_cnt].images = sch_inqa_reply->query_qual[d.seq].images,
     reply->query_qual[reply->query_qual_cnt].home_phone = sch_inqa_reply->query_qual[d.seq].
     home_phone, reply->query_qual[reply->query_qual_cnt].mrn = sch_inqa_reply->query_qual[d.seq].mrn,
     reply->query_qual[reply->query_qual_cnt].ordering_physician = sch_inqa_reply->query_qual[d.seq].
     ordering_physician, reply->query_qual[reply->query_qual_cnt].orders = sch_inqa_reply->
     query_qual[d.seq].orders, reply->query_qual[reply->query_qual_cnt].person_name = sch_inqa_reply
     ->query_qual[d.seq].person_name,
     reply->query_qual[reply->query_qual_cnt].req_action_display = sch_inqa_reply->query_qual[d.seq].
     req_action_display, reply->query_qual[reply->query_qual_cnt].sex = sch_inqa_reply->query_qual[d
     .seq].sex, reply->query_qual[reply->query_qual_cnt].ordered_as_mnemonic = sch_inqa_reply->
     query_qual[d.seq].ordered_as_mnemonic,
     reply->query_qual[reply->query_qual_cnt].cmt = sch_inqa_reply->query_qual[d.seq].cmt, reply->
     query_qual[reply->query_qual_cnt].order_cmt = sch_inqa_reply->query_qual[d.seq].order_cmt, reply
     ->query_qual[reply->query_qual_cnt].stat = sch_inqa_reply->query_qual[d.seq].stat,
     reply->query_qual[reply->query_qual_cnt].inpatient = sch_inqa_reply->query_qual[d.seq].inpatient,
     reply->query_qual[reply->query_qual_cnt].isolation_type = sch_inqa_reply->query_qual[d.seq].
     isolation_type, reply->query_qual[reply->query_qual_cnt].pref_agreement_status = sch_inqa_reply
     ->query_qual[d.seq].pref_agreement_status
     IF ((((sch_inqa_reply->query_qual[d.seq].no_contact_flag=1)) OR ((sch_inqa_reply->query_qual[d
     .seq].contact_count >= auto_dial_max_pref_value))) )
      reply->query_qual[reply->query_qual_cnt].auto_dial = uar_i18ngetmessage(i18nhandle,"No","No")
     ELSE
      reply->query_qual[reply->query_qual_cnt].auto_dial = uar_i18ngetmessage(i18nhandle,"Yes","Yes")
     ENDIF
     reply->query_qual[reply->query_qual_cnt].order_date = sch_inqa_reply->query_qual[d.seq].
     order_date, reply->query_qual[reply->query_qual_cnt].order_loc = sch_inqa_reply->query_qual[d
     .seq].order_loc, reply->query_qual[reply->query_qual_cnt].ordering_provider = sch_inqa_reply->
     query_qual[d.seq].ordering_provider,
     reply->query_qual[reply->query_qual_cnt].protocol_cmt = sch_inqa_reply->query_qual[d.seq].
     protocol_cmt, reply->query_qual[reply->query_qual_cnt].scheduled_dt_tm = sch_inqa_reply->
     query_qual[d.seq].scheduled_dt_tm, reply->query_qual[reply->query_qual_cnt].address =
     sch_inqa_reply->query_qual[d.seq].address
    WITH nocounter
   ;end select
  ENDIF
  SET reply->total_items_found = (scheduleitemsfound+ numwqmitems)
  SET stat = alterlist(reply->query_qual,reply->query_qual_cnt)
  SET stat = alterlist(reply->attr_qual,reply->attr_qual_cnt)
 ENDIF
 SUBROUTINE getallprsnlfromschprovdset(null)
   DECLARE prsnlgroupclasscd = f8 WITH public, noconstant(0.0)
   SET cdf_meaning = "PROVIDERSET"
   CALL getcodevalue(19189,cdf_meaning,prsnlgroupclasscd)
   SELECT DISTINCT
    pgr.person_id
    FROM prsnl_group pg,
     prsnl_group_reltn pgr
    PLAN (pg
     WHERE pg.prsnl_group_class_cd=prsnlgroupclasscd)
     JOIN (pgr
     WHERE pgr.prsnl_group_id=pg.prsnl_group_id
      AND pgr.active_ind=1)
    DETAIL
     IF (mod(default_ord_phy_index,10)=1)
      stat = alterlist(defaultordphyrec->default_ord_physician_ids,(default_ord_phy_index+ 9))
     ENDIF
     defaultordphyrec->default_ord_physician_ids[default_ord_phy_index].default_ord_physician_id =
     pgr.person_id, default_ord_phy_index += 1
    WITH nocounter
   ;end select
   CALL alterlist(defaultordphyrec->default_ord_physician_ids,(default_ord_phy_index - 1))
 END ;Subroutine
 SUBROUTINE copyschinqreptoreply(null)
   SET ordphylistsize = size(t_record->ord_physician_ids,5)
   SET stat = alterlist(t_record->ord_physician_ids,ordphylistsize)
   SET defaultordphysize = size(defaultordphyrec->default_ord_physician_ids,5)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(sch_inqa_reply->query_qual_cnt))
    PLAN (d
     WHERE (((sch_inqa_reply->query_qual[d.seq].hide#scheventid > 0)) OR ((sch_inqa_reply->
     query_qual[d.seq].hide#wqmworkitemid > 0)))
      AND (sch_inqa_reply->query_qual[d.seq].display_items=1))
    ORDER BY sch_inqa_reply->query_qual[d.seq].created_dt_tm
    DETAIL
     ordphy_matched = 0
     IF ((sch_inqa_reply->query_qual[d.seq].hide#wqmworkitemid=0))
      FOR (j = 1 TO defaultordphysize)
        IF ((((sch_inqa_reply->query_qual[d.seq].hide#orderingphysicianid=0)) OR ((sch_inqa_reply->
        query_qual[d.seq].hide#orderingphysicianid=defaultordphyrec->default_ord_physician_ids[j].
        default_ord_physician_id))) )
         ordphy_matched = 1
        ENDIF
      ENDFOR
      IF (ordphy_matched=1
       AND ordphylistsize=1
       AND (sch_inqa_reply->query_qual[d.seq].hide#orderingphysicianid=t_record->ord_physician_ids[1]
      .ord_physician_id))
       ordphy_matched = 0
      ENDIF
     ENDIF
     IF (ordphy_matched != 1)
      reply->query_qual_cnt += 1
      IF (mod(reply->query_qual_cnt,100)=1)
       stat = alterlist(reply->query_qual,(reply->query_qual_cnt+ 99))
      ENDIF
      IF ((sch_inqa_reply->query_qual[d.seq].hide#scheventid > 0))
       scheduleitemsfound += 1
      ENDIF
      reply->query_qual[reply->query_qual_cnt].hide#schentryid = sch_inqa_reply->query_qual[d.seq].
      hide#schentryid, reply->query_qual[reply->query_qual_cnt].hide#scheduleseq = sch_inqa_reply->
      query_qual[d.seq].hide#scheduleseq, reply->query_qual[reply->query_qual_cnt].hide#reqactionid
       = sch_inqa_reply->query_qual[d.seq].hide#reqactionid,
      reply->query_qual[reply->query_qual_cnt].hide#actionid = sch_inqa_reply->query_qual[d.seq].
      hide#actionid, reply->query_qual[reply->query_qual_cnt].hide#schapptid = sch_inqa_reply->
      query_qual[d.seq].hide#schapptid, reply->query_qual[reply->query_qual_cnt].hide#statemeaning =
      sch_inqa_reply->query_qual[d.seq].hide#statemeaning,
      reply->query_qual[reply->query_qual_cnt].hide#latestdttm = sch_inqa_reply->query_qual[d.seq].
      hide#latestdttm, reply->query_qual[reply->query_qual_cnt].hide#reqmadedttm = sch_inqa_reply->
      query_qual[d.seq].hide#reqmadedttm, reply->query_qual[reply->query_qual_cnt].
      hide#entrystatemeaning = sch_inqa_reply->query_qual[d.seq].hide#entrystatemeaning,
      reply->query_qual[reply->query_qual_cnt].hide#reqactionmeaning = sch_inqa_reply->query_qual[d
      .seq].hide#reqactionmeaning, reply->query_qual[reply->query_qual_cnt].hide#encounterid =
      sch_inqa_reply->query_qual[d.seq].hide#encounterid, reply->query_qual[reply->query_qual_cnt].
      hide#personid = sch_inqa_reply->query_qual[d.seq].hide#personid,
      reply->query_qual[reply->query_qual_cnt].hide#bitmask = sch_inqa_reply->query_qual[d.seq].
      hide#bitmask, reply->query_qual[reply->query_qual_cnt].hide#blobhandle = sch_inqa_reply->
      query_qual[d.seq].hide#blobhandle, reply->query_qual[reply->query_qual_cnt].hide#orderid =
      sch_inqa_reply->query_qual[d.seq].hide#orderid,
      reply->query_qual[reply->query_qual_cnt].hide#scheduleid = sch_inqa_reply->query_qual[d.seq].
      hide#scheduleid, reply->query_qual[reply->query_qual_cnt].hide#scheventid = sch_inqa_reply->
      query_qual[d.seq].hide#scheventid, reply->query_qual[reply->query_qual_cnt].
      hide#wqmdocumenttypecd = sch_inqa_reply->query_qual[d.seq].hide#wqmdocumenttypecd,
      reply->query_qual[reply->query_qual_cnt].hide#wqmupdtcnt = sch_inqa_reply->query_qual[d.seq].
      hide#wqmupdtcnt, reply->query_qual[reply->query_qual_cnt].hide#wqmworkitemid = sch_inqa_reply->
      query_qual[d.seq].hide#wqmworkitemid, reply->query_qual[reply->query_qual_cnt].
      hide#wqmitemscript = sch_inqa_reply->query_qual[d.seq].hide#wqmitemscript,
      reply->query_qual[reply->query_qual_cnt].hide#cdipendingdocumentid = sch_inqa_reply->
      query_qual[d.seq].hide#cdipendingdocumentid, reply->query_qual[reply->query_qual_cnt].
      hide#documenttypedisplay = sch_inqa_reply->query_qual[d.seq].hide#documenttypedisplay, reply->
      query_qual[reply->query_qual_cnt].hide#sendinglocationcd = sch_inqa_reply->query_qual[d.seq].
      hide#sendinglocationcd,
      reply->query_qual[reply->query_qual_cnt].hide#orderingphysicianid = sch_inqa_reply->query_qual[
      d.seq].hide#orderingphysicianid, reply->query_qual[reply->query_qual_cnt].hide#statuscd =
      sch_inqa_reply->query_qual[d.seq].hide#statuscd, reply->query_qual[reply->query_qual_cnt].
      appt_type_display = sch_inqa_reply->query_qual[d.seq].appt_type_display,
      reply->query_qual[reply->query_qual_cnt].contact_count = sch_inqa_reply->query_qual[d.seq].
      contact_count, reply->query_qual[reply->query_qual_cnt].last_contact_comment = sch_inqa_reply->
      query_qual[d.seq].last_contact_comment, reply->query_qual[reply->query_qual_cnt].created_dt_tm
       = sch_inqa_reply->query_qual[d.seq].created_dt_tm,
      reply->query_qual[reply->query_qual_cnt].dob = sch_inqa_reply->query_qual[d.seq].dob, reply->
      query_qual[reply->query_qual_cnt].document_source = sch_inqa_reply->query_qual[d.seq].
      document_source, reply->query_qual[reply->query_qual_cnt].earliest_dt_tm = sch_inqa_reply->
      query_qual[d.seq].earliest_dt_tm,
      reply->query_qual[reply->query_qual_cnt].images = sch_inqa_reply->query_qual[d.seq].images,
      reply->query_qual[reply->query_qual_cnt].home_phone = sch_inqa_reply->query_qual[d.seq].
      home_phone, reply->query_qual[reply->query_qual_cnt].mrn = sch_inqa_reply->query_qual[d.seq].
      mrn,
      reply->query_qual[reply->query_qual_cnt].ordering_physician = sch_inqa_reply->query_qual[d.seq]
      .ordering_physician, reply->query_qual[reply->query_qual_cnt].orders = sch_inqa_reply->
      query_qual[d.seq].orders, reply->query_qual[reply->query_qual_cnt].person_name = sch_inqa_reply
      ->query_qual[d.seq].person_name,
      reply->query_qual[reply->query_qual_cnt].req_action_display = sch_inqa_reply->query_qual[d.seq]
      .req_action_display, reply->query_qual[reply->query_qual_cnt].sex = sch_inqa_reply->query_qual[
      d.seq].sex, reply->query_qual[reply->query_qual_cnt].ordered_as_mnemonic = sch_inqa_reply->
      query_qual[d.seq].ordered_as_mnemonic,
      reply->query_qual[reply->query_qual_cnt].cmt = sch_inqa_reply->query_qual[d.seq].cmt, reply->
      query_qual[reply->query_qual_cnt].order_cmt = sch_inqa_reply->query_qual[d.seq].order_cmt,
      reply->query_qual[reply->query_qual_cnt].stat = sch_inqa_reply->query_qual[d.seq].stat,
      reply->query_qual[reply->query_qual_cnt].inpatient = sch_inqa_reply->query_qual[d.seq].
      inpatient, reply->query_qual[reply->query_qual_cnt].isolation_type = sch_inqa_reply->
      query_qual[d.seq].isolation_type, reply->query_qual[reply->query_qual_cnt].
      pref_agreement_status = sch_inqa_reply->query_qual[d.seq].pref_agreement_status
      IF ((((sch_inqa_reply->query_qual[d.seq].no_contact_flag=1)) OR ((sch_inqa_reply->query_qual[d
      .seq].contact_count >= auto_dial_max_pref_value))) )
       reply->query_qual[reply->query_qual_cnt].auto_dial = uar_i18ngetmessage(i18nhandle,"No","No")
      ELSE
       reply->query_qual[reply->query_qual_cnt].auto_dial = uar_i18ngetmessage(i18nhandle,"Yes","Yes"
        )
      ENDIF
      reply->query_qual[reply->query_qual_cnt].order_date = sch_inqa_reply->query_qual[d.seq].
      order_date, reply->query_qual[reply->query_qual_cnt].order_loc = sch_inqa_reply->query_qual[d
      .seq].order_loc, reply->query_qual[reply->query_qual_cnt].ordering_provider = sch_inqa_reply->
      query_qual[d.seq].ordering_provider
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 IF (request->call_echo_ind)
  CALL echorecord(sch_inqa_reply)
  CALL echorecord(reply)
 ENDIF
END GO

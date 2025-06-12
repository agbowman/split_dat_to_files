CREATE PROGRAM bhs_sch_inqa_loc_uk_appt_list:dba
 DECLARE loadcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) = f8
 DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 SUBROUTINE loadcodevalue(code_set,cdf_meaning,option_flag)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET table_name = build("ERROR-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      CALL echo(build("INFO-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
        '"',",",option_flag,") not found, CURPROG [",curprog,
        "]"))
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
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
  "uar_i18ngethijridate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nbuildfullformatname",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_getarabictime",
  persist
 ENDIF
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
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
 IF ((validate(bpm_wait_time_calc,- (9))=- (9)))
  DECLARE bpm_wait_time_calc = i2 WITH constant(true)
  DECLARE suspend_cd = f8 WITH noconstant(0.0)
  DECLARE status_cd = f8 WITH noconstant(0.0)
  DECLARE adj_waiting_time = f8 WITH noconstant(0.0)
  DECLARE adj_waiting_start_dt_tm = f8 WITH noconstant(0.0)
  DECLARE waiting_end_dt_tm = f8 WITH noconstant(0.0)
  DECLARE suspended_days = f8 WITH noconstant(0.0)
  DECLARE status_dt_tm = f8 WITH noconstant(0.0)
  DECLARE currentdate = f8 WITH noconstant(0.0)
  DECLARE waiting_start_dt = f8 WITH noconstant(0.0)
  DECLARE adj_waiting_time_formatted = vc WITH noconstant("")
  DECLARE waiting_time_formatted = vc WITH noconstant("")
  DECLARE d_waiting_time_in_days = f8 WITH noconstant(0.0)
  SET stat = uar_get_meaning_by_codeset(14778,"SUSPEND",1,suspend_cd)
  SET stat = uar_get_meaning_by_codeset(207902,"WLWTNGDAYS",1,d_waiting_time_in_days)
  DECLARE dadjtemp = f8 WITH noconstant(0.0)
  DECLARE dadjtemp2 = f8 WITH noconstant(0.0)
  DECLARE waitlistcalc(itemp=i2) = null
  DECLARE formatreturnvalue(days=i4) = vc
  SUBROUTINE formatreturnvalue(days)
    DECLARE wait_days = i4 WITH noconstant(0)
    DECLARE wait_weeks = i4 WITH noconstant(0)
    DECLARE returnval = vc WITH noconstant("")
    IF (d_waiting_time_in_days > 0)
     SET returnval = build(days,"d")
    ELSE
     SET wait_weeks = (days/ 7)
     SET wait_days = mod(days,7)
     SET returnval = build(wait_weeks,"w ",wait_days,"d")
    ENDIF
    RETURN(returnval)
  END ;Subroutine
  SUBROUTINE waitlistcalc(itemp)
    SET adj_waiting_time = 0.0
    IF (((cnvtdatetime(adj_waiting_start_dt_tm)=0) OR (cnvtdatetime(adj_waiting_start_dt_tm)=null)) )
     SET adj_waiting_time = 0.0
    ELSE
     DECLARE dttempcalc = f8 WITH noconstant(0.0)
     DECLARE dttempcalc2 = f8 WITH noconstant(0.0)
     DECLARE ddiffcalccd = f8 WITH noconstant(0.0)
     SET stat = uar_get_meaning_by_codeset(207902,"WLDAYSONLY",1,ddiffcalccd)
     SET currentdate = cnvtdatetime(curdate,curtime3)
     IF (status_cd=suspend_cd)
      IF (status_dt_tm > 0
       AND waiting_end_dt_tm > 0
       AND adj_waiting_start_dt_tm > 0)
       IF (cnvtdatetime(status_dt_tm) >= cnvtdatetime(waiting_end_dt_tm))
        IF (ddiffcalccd > 0)
         SET dttempcalc = cnvtdatetime(cnvtdate(waiting_end_dt_tm),0)
         SET dttempcalc2 = cnvtdatetime(cnvtdate(adj_waiting_start_dt_tm),0)
         SET dadjtemp = datetimediff(cnvtdatetime(dttempcalc),cnvtdatetime(dttempcalc2))
        ELSE
         SET dadjtemp = datetimediff(cnvtdatetime(waiting_end_dt_tm),cnvtdatetime(
           adj_waiting_start_dt_tm),1)
         SET dadjtemp = ceil(dadjtemp)
        ENDIF
        SET adj_waiting_time = dadjtemp
        IF (adj_waiting_time > 0)
         SET adj_waiting_time = (dadjtemp - suspended_days)
        ENDIF
       ELSEIF (cnvtdatetime(status_dt_tm) < cnvtdatetime(waiting_end_dt_tm))
        IF (ddiffcalccd > 0)
         SET dttempcalc = cnvtdatetime(cnvtdate(waiting_end_dt_tm),0)
         SET dttempcalc2 = cnvtdatetime(cnvtdate(adj_waiting_start_dt_tm),0)
         SET dadjtemp = datetimediff(cnvtdatetime(dttempcalc),cnvtdatetime(dttempcalc2))
        ELSE
         SET dadjtemp = datetimediff(cnvtdatetime(waiting_end_dt_tm),cnvtdatetime(
           adj_waiting_start_dt_tm),1)
         SET dadjtemp = ceil(dadjtemp)
        ENDIF
        SET adj_waiting_time = dadjtemp
        IF (adj_waiting_time > 0)
         SET adj_waiting_time = (dadjtemp - suspended_days)
        ENDIF
       ENDIF
      ELSEIF (status_dt_tm > 0
       AND adj_waiting_start_dt_tm > 0
       AND waiting_end_dt_tm=0)
       IF (ddiffcalccd > 0)
        SET dttempcalc2 = cnvtdatetime(cnvtdate(adj_waiting_start_dt_tm),0)
        SET dadjtemp = datetimediff(cnvtdatetime(curdate,0),cnvtdatetime(dttempcalc2))
       ELSE
        SET dadjtemp = datetimediff(cnvtdatetime(currentdate),cnvtdatetime(adj_waiting_start_dt_tm),1
         )
        SET dadjtemp = ceil(dadjtemp)
       ENDIF
       SET adj_waiting_time = dadjtemp
       IF (adj_waiting_time > 0)
        SET adj_waiting_time = (dadjtemp - suspended_days)
       ENDIF
      ENDIF
     ELSE
      IF (waiting_end_dt_tm > 0
       AND adj_waiting_start_dt_tm > 0)
       IF (ddiffcalccd > 0)
        SET dttempcalc = cnvtdatetime(cnvtdate(waiting_end_dt_tm),0)
        SET dttempcalc2 = cnvtdatetime(cnvtdate(adj_waiting_start_dt_tm),0)
        SET dadjtemp = datetimediff(cnvtdatetime(dttempcalc),cnvtdatetime(dttempcalc2))
       ELSE
        SET dadjtemp = datetimediff(cnvtdatetime(waiting_end_dt_tm),cnvtdatetime(
          adj_waiting_start_dt_tm),1)
        SET dadjtemp = ceil(dadjtemp)
       ENDIF
       SET adj_waiting_time = dadjtemp
       IF (adj_waiting_time > 0)
        SET adj_waiting_time = (dadjtemp - suspended_days)
       ENDIF
      ELSEIF (adj_waiting_start_dt_tm > 0)
       IF (ddiffcalccd > 0)
        SET dttempcalc2 = cnvtdatetime(cnvtdate(adj_waiting_start_dt_tm),0)
        SET dadjtemp = datetimediff(cnvtdatetime(curdate,0),cnvtdatetime(dttempcalc2))
       ELSE
        SET dadjtemp = datetimediff(cnvtdatetime(currentdate),cnvtdatetime(adj_waiting_start_dt_tm),1
         )
        SET dadjtemp = ceil(dadjtemp)
       ENDIF
       SET adj_waiting_time = dadjtemp
       IF (adj_waiting_time > 0)
        SET adj_waiting_time = (dadjtemp - suspended_days)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF (adj_waiting_time < 0)
     SET adj_waiting_time = 0.0
    ENDIF
  END ;Subroutine
 ENDIF
 DECLARE t_index = i4 WITH noconstant(0)
 DECLARE i_input = i4 WITH noconstant(0)
 DECLARE j_input = i4 WITH noconstant(0)
 DECLARE utc2 = i2 WITH noconstant(0)
 DECLARE dttemp1 = f8 WITH noconstant(0.0)
 DECLARE dttemp2 = f8 WITH noconstant(0.0)
 DECLARE ddiffcd = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(207902,"WLDAYSONLY",1,ddiffcd)
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
     2 hide#scheventid = f8
     2 hide#scheduleid = f8
     2 hide#scheduleseq = i4
     2 hide#actionid = f8
     2 hide#schapptid = f8
     2 hide#statemeaning = c12
     2 hide#earliestdttm = dq8
     2 hide#encounterid = f8
     2 hide#personid = f8
     2 hide#bitmask = i4
     2 cmt = c12
     2 orders = vc
     2 scheduled_dt_tm = dq8
     2 appt_type_display = vc
     2 appt_status = vc
     2 appt_dur = i4
     2 person_name = vc
     2 dob = dq8
     2 birth_tz = i4
     2 sex = vc
     2 specialty = vc
     2 episode_type = vc
     2 service_category = vc
     2 home_phone = vc
     2 bus_phone = vc
     2 consultant = vc
     2 referred_by = vc
     2 admin_category = vc
     2 priority_type = vc
     2 referral_recieved_dt_tm = dq8
     2 referral_requested_dt_tm = dq8
     2 referral_reason = vc
     2 availability = vc
     2 appt_loc_display = vc
     2 mrn = vc
     2 address = vc
     2 booking_system_type = vc
     2 guaranteed_by_dt_tm = dq8
     2 waiting_time = i4
     2 waiting_time_str = vc
     2 adj_waiting_time = i4
     2 adj_waiting_time_str = vc
     2 commissioner_code = vc
     2 commissioner = vc
     2 status_cd = f8
     2 adj_waiting_start_dt_tm = f8
     2 waiting_end_dt_tm = f8
     2 suspended_days = f8
     2 status_dt_tm = f8
     2 waiting_start_dt_tm = f8
     2 encounter_type = vc
     2 encounter_status = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 DECLARE consultant_type_cd = f8 WITH public, constant(loadcodevalue(333,"ATTENDDOC",0))
 DECLARE referring_type_cd = f8 WITH public, constant(loadcodevalue(333,"REFERDOC",0))
 DECLARE home_phone_cd = f8 WITH public, constant(loadcodevalue(43,"HOME",0))
 DECLARE bus_phone_cd = f8 WITH public, constant(loadcodevalue(43,"BUSINESS",0))
 DECLARE en_mrn_cd = f8 WITH public, constant(loadcodevalue(319,"MRN",0))
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
 DECLARE addr_type_cd = f8 WITH public, constant(loadcodevalue(212,"HOME",0))
 DECLARE location_type_cd = f8 WITH public, constant(loadcodevalue(14509,"APPOINTMENT",0))
 DECLARE stat_cd = f8 WITH public, constant(loadcodevalue(1304,"STAT",0))
 DECLARE nhs_org_alias_cd = f8 WITH public, noconstant(loadcodevalue(334,"NHSORGALIAS",0))
 DECLARE commissioner_cd = f8 WITH public, noconstant(loadcodevalue(352,"COMMISSIONER",0))
 DECLARE dttoday = dq8 WITH public, noconstant(0.0)
 SET reply->attr_qual_cnt = 42
 SET stat = alterlist(reply->attr_qual,reply->attr_qual_cnt)
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "hide#scheventid"
 SET reply->attr_qual[t_index].attr_label = "HIDE#SCHEVENTID"
 SET reply->attr_qual[t_index].attr_type = "f8"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "hide#scheduleid"
 SET reply->attr_qual[t_index].attr_label = "HIDE#SCHEDULEID"
 SET reply->attr_qual[t_index].attr_type = "f8"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "hide#scheduleseq"
 SET reply->attr_qual[t_index].attr_label = "HIDE#SCHEDULESEQ"
 SET reply->attr_qual[t_index].attr_type = "i4"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "hide#actionid"
 SET reply->attr_qual[t_index].attr_label = "HIDE#ACTIONID"
 SET reply->attr_qual[t_index].attr_type = "f8"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "hide#schapptid"
 SET reply->attr_qual[t_index].attr_label = "HIDE#SCHAPPTID"
 SET reply->attr_qual[t_index].attr_type = "f8"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "hide#statemeaning"
 SET reply->attr_qual[t_index].attr_label = "HIDE#STATEMEANING"
 SET reply->attr_qual[t_index].attr_type = "c12"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "hide#earliestdttm"
 SET reply->attr_qual[t_index].attr_label = "HIDE#EARLIESTDTTM"
 SET reply->attr_qual[t_index].attr_type = "dq8"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "hide#encounterid"
 SET reply->attr_qual[t_index].attr_label = "HIDE#ENCOUNTERID"
 SET reply->attr_qual[t_index].attr_type = "f8"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "hide#personid"
 SET reply->attr_qual[t_index].attr_label = "HIDE#PERSONID"
 SET reply->attr_qual[t_index].attr_type = "f8"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "hide#bitmask"
 SET reply->attr_qual[t_index].attr_label = "HIDE#BITMASK"
 SET reply->attr_qual[t_index].attr_type = "i4"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "cmt"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"C","C")
 SET reply->attr_qual[t_index].attr_type = "c12"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "orders"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Orders","Orders")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "scheduled_dt_tm"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Scheduled Dt/Tm",
  "Scheduled Dt/Tm")
 SET reply->attr_qual[t_index].attr_type = "dq8"
 SET reply->attr_qual[t_index].attr_def_seq = 13
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "person_name"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Person Name","Person Name"
  )
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET reply->attr_qual[t_index].attr_def_seq = 9
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "appt_type_display"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Appt Type","Appt Type")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET reply->attr_qual[t_index].attr_def_seq = 10
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "appt_status"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Appt Status","Appt Status"
  )
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET reply->attr_qual[t_index].attr_def_seq = 11
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "dob"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"DOB","DOB")
 SET reply->attr_qual[t_index].attr_type = "dq8"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "sex"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Sex","Sex")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "episode_type"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Visit Type","Visit Type")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "service_category"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Service Category",
  "Service Category")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET reply->attr_qual[t_index].attr_def_seq = 4
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "home_phone"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Phone (H)","Phone (H)")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "bus_phone"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Phone (W)","Phone (W)")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "address"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Town","Town")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET reply->attr_qual[t_index].attr_def_seq = 1
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "consultant"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Consultant","Consultant")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET reply->attr_qual[t_index].attr_def_seq = 7
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "referred_by"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Referred By","Referred By"
  )
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "admin_category"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Admin Category",
  "Admin Category")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET reply->attr_qual[t_index].attr_def_seq = 3
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "priority_type"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Priority","Priority")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET reply->attr_qual[t_index].attr_def_seq = 2
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "referral_recieved_dt_tm"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Date Referral Received",
  "Date Referral Received")
 SET reply->attr_qual[t_index].attr_type = "dq8"
 SET reply->attr_qual[t_index].attr_def_seq = 5
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "referral_requested_dt_tm"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Date Referral Requested",
  "Date Referral Requested")
 SET reply->attr_qual[t_index].attr_type = "dq8"
 SET reply->attr_qual[t_index].attr_def_seq = 6
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "referral_reason"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Referral Reason",
  "Referral Reason")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "availability"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Availability",
  "Availability")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "appt_loc_display"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Appt Location",
  "Appt Location")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET reply->attr_qual[t_index].attr_def_seq = 8
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "mrn"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"MRN","MRN")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "booking_system_type"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Booking System Type",
  "Booking System Type")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "guaranteed_by_dt_tm"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Guaranteed By",
  "Guaranteed By")
 SET reply->attr_qual[t_index].attr_type = "dq8"
 SET reply->attr_qual[t_index].attr_def_seq = 14
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "waiting_time_str"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Waiting Time",
  "Waiting Time")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET reply->attr_qual[t_index].attr_def_seq = 15
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "adj_waiting_time_str"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Adjusted Waiting Time",
  "Adjusted Waiting Time")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "appt_dur"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Duration","Duration")
 SET reply->attr_qual[t_index].attr_type = "i4"
 SET reply->attr_qual[t_index].attr_def_seq = 12
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "commissioner"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Commissioner",
  "Commissioner")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "commissioner_code"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Commissioner Code",
  "Commissioner Code")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "encounter_type"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Encounter Type",
  "Encounter Type")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "encounter_status"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Encounter Status",
  "Encounter Status")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET reply->query_qual_cnt = 0
 SET stat = alterlist(reply->query_qual,reply->query_qual_cnt)
 RECORD t_record(
   1 queue_id = f8
   1 person_id = f8
   1 resource_cd = f8
   1 location_cd = f8
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 atgroup_id = f8
   1 locgroup_id = f8
   1 res_group_id = f8
   1 slot_group_id = f8
   1 appt_type_cd = f8
   1 title = vc
   1 appttype_qual_cnt = i4
   1 appttype_qual[*]
     2 appt_type_cd = f8
   1 location_qual_cnt = i4
   1 location_qual[*]
     2 location_cd = f8
   1 resource_qual_cnt = i4
   1 resource_qual[*]
     2 resource_cd = f8
     2 person_id = f8
   1 slot_qual_cnt = i4
   1 slot_qual[*]
     2 slot_type_id = f8
   1 max_order_cnt = i4
   1 event_qual[*]
     2 protocol_parent_id = f8
     2 order_qual_cnt = i4
     2 order_qual[*]
       3 order_id = f8
       3 description = vc
       3 order_seq_nbr = i4
   1 consultant_id = f8
 )
 IF (request->call_echo_ind)
  CALL echo("Checking the input fields...")
 ENDIF
 FOR (i_input = 1 TO size(request->qual,5))
   IF ((request->qual[i_input].oe_field_meaning_id=0))
    CASE (request->qual[i_input].oe_field_meaning)
     OF "QUEUE":
      SET t_record->queue_id = request->qual[i_input].oe_field_value
     OF "PERSON":
      SET t_record->person_id = request->qual[i_input].oe_field_value
     OF "RESOURCE":
      SET t_record->resource_cd = request->qual[i_input].oe_field_value
     OF "LOCATION":
      SET t_record->location_cd = request->qual[i_input].oe_field_value
     OF "BEGDTTM":
      SET t_record->beg_dt_tm = request->qual[i_input].oe_field_dt_tm_value
     OF "ENDDTTM":
      SET t_record->end_dt_tm = request->qual[i_input].oe_field_dt_tm_value
     OF "ATGROUP":
      SET t_record->atgroup_id = request->qual[i_input].oe_field_value
     OF "LOCGROUP":
      SET t_record->locgroup_id = request->qual[i_input].oe_field_value
     OF "RESGROUP":
      SET t_record->res_group_id = request->qual[i_input].oe_field_value
     OF "SLOTGROUP":
      SET t_record->slot_group_id = request->qual[i_input].oe_field_value
     OF "TITLE":
      SET t_record->title = request->qual[i_input].oe_field_display_value
     OF "APPTTYPE":
      SET t_record->appt_type_cd = request->qual[i_input].oe_field_value
    ENDCASE
   ELSE
    CASE (request->qual[i_input].oe_field_meaning)
     OF "CONSULTDOC":
      SET t_record->consultant_id = request->qual[i_input].oe_field_value
    ENDCASE
   ENDIF
 ENDFOR
 IF ((t_record->atgroup_id > 0))
  SET get_atgroup_exp_request->call_echo_ind = 0
  SET get_atgroup_exp_request->security_ind = 1
  SET get_atgroup_exp_reply->qual_cnt = 1
  SET stat = alterlist(get_atgroup_exp_request->qual,get_atgroup_exp_reply->qual_cnt)
  SET get_atgroup_exp_request->qual[get_atgroup_exp_reply->qual_cnt].sch_object_id = t_record->
  atgroup_id
  SET get_atgroup_exp_request->qual[get_atgroup_exp_reply->qual_cnt].duplicate_ind = 1
  EXECUTE sch_get_atgroup_exp
  FOR (i_input = 1 TO get_atgroup_exp_reply->qual_cnt)
    SET t_record->appttype_qual_cnt = get_atgroup_exp_reply->qual[i_input].qual_cnt
    SET stat = alterlist(t_record->appttype_qual,t_record->appttype_qual_cnt)
    FOR (j_input = 1 TO t_record->appttype_qual_cnt)
      SET t_record->appttype_qual[j_input].appt_type_cd = get_atgroup_exp_reply->qual[i_input].qual[
      j_input].appt_type_cd
    ENDFOR
  ENDFOR
 ELSE
  SET t_record->appttype_qual_cnt = 0
 ENDIF
 IF ((t_record->locgroup_id > 0))
  SET get_locgroup_exp_request->call_echo_ind = 0
  SET get_locgroup_exp_request->security_ind = 1
  SET get_locgroup_exp_reply->qual_cnt = 1
  SET stat = alterlist(get_locgroup_exp_request->qual,get_locgroup_exp_reply->qual_cnt)
  SET get_locgroup_exp_request->qual[get_locgroup_exp_reply->qual_cnt].sch_object_id = t_record->
  locgroup_id
  SET get_locgroup_exp_request->qual[get_locgroup_exp_reply->qual_cnt].duplicate_ind = 1
  EXECUTE sch_get_locgroup_exp
  FOR (i_input = 1 TO get_locgroup_exp_reply->qual_cnt)
    SET t_record->location_qual_cnt = get_locgroup_exp_reply->qual[i_input].qual_cnt
    SET stat = alterlist(t_record->location_qual,t_record->location_qual_cnt)
    FOR (j_input = 1 TO t_record->location_qual_cnt)
      SET t_record->location_qual[j_input].location_cd = get_locgroup_exp_reply->qual[i_input].qual[
      j_input].location_cd
    ENDFOR
  ENDFOR
 ELSE
  SET t_record->location_qual_cnt = 0
 ENDIF
 IF ((t_record->res_group_id > 0))
  SET get_res_group_exp_request->call_echo_ind = 0
  SET get_res_group_exp_request->security_ind = 1
  SET get_res_group_exp_reply->qual_cnt = 1
  SET stat = alterlist(get_res_group_exp_request->qual,get_res_group_exp_reply->qual_cnt)
  SET get_res_group_exp_request->qual[get_res_group_exp_reply->qual_cnt].res_group_id = t_record->
  res_group_id
  SET get_res_group_exp_request->qual[get_res_group_exp_reply->qual_cnt].duplicate_ind = 1
  EXECUTE sch_get_res_group_exp
  FOR (i_input = 1 TO get_res_group_exp_reply->qual_cnt)
    SET t_record->resource_qual_cnt = get_res_group_exp_reply->qual[i_input].qual_cnt
    SET stat = alterlist(t_record->resource_qual,t_record->resource_qual_cnt)
    FOR (j_input = 1 TO t_record->resource_qual_cnt)
      SET t_record->resource_qual[j_input].resource_cd = get_res_group_exp_reply->qual[i_input].qual[
      j_input].resource_cd
    ENDFOR
  ENDFOR
 ELSE
  SET t_record->resource_qual_cnt = 0
 ENDIF
 IF ((t_record->slot_group_id > 0))
  SET get_slot_group_exp_request->call_echo_ind = 0
  SET get_slot_group_exp_request->security_ind = 1
  SET get_slot_group_exp_reply->qual_cnt = 1
  SET stat = alterlist(get_slot_group_exp_request->qual,get_slot_group_exp_reply->qual_cnt)
  SET get_slot_group_exp_request->qual[get_slot_group_exp_reply->qual_cnt].slot_group_id = t_record->
  slot_group_id
  SET get_slot_group_exp_request->qual[get_slot_group_exp_reply->qual_cnt].duplicate_ind = 1
  EXECUTE sch_get_slot_group_exp
  FOR (i_input = 1 TO get_slot_group_exp_reply->qual_cnt)
    SET t_record->slot_qual_cnt = get_slot_group_exp_reply->qual[i_input].qual_cnt
    SET stat = alterlist(t_record->slot_qual,t_record->slot_qual_cnt)
    FOR (j_input = 1 TO t_record->slot_qual_cnt)
      SET t_record->slot_qual[j_input].slot_type_id = get_slot_group_exp_reply->qual[i_input].qual[
      j_input].slot_type_id
    ENDFOR
  ENDFOR
 ELSE
  SET t_record->slot_qual_cnt = 0
 ENDIF
 IF ((t_record->resource_qual_cnt > 0))
  SELECT INTO "nl:"
   a.person_id, d.seq
   FROM (dummyt d  WITH seq = value(t_record->resource_qual_cnt)),
    sch_resource a
   PLAN (d)
    JOIN (a
    WHERE (a.resource_cd=t_record->resource_qual[d.seq].resource_cd)
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   DETAIL
    t_record->resource_qual[d.seq].person_id = a.person_id
   WITH nocounter
  ;end select
 ENDIF
 SET utc2 = evaluate(validate(curtimezoneapp,0),0,0,1)
 SELECT
  IF ((t_record->consultant_id > 0.0))
   epr_exists = 1, epr2_exists = evaluate(nullind(epr2.encntr_prsnl_reltn_id),1,0,1), a.queue_id
   FROM sch_location sl,
    sch_appt a,
    sch_event e,
    person p,
    encounter enc,
    encntr_prsnl_reltn epr,
    encntr_prsnl_reltn epr2,
    prsnl pnl,
    prsnl pnl2
   PLAN (a
    WHERE a.beg_dt_tm < cnvtdatetime(t_record->end_dt_tm)
     AND a.end_dt_tm > cnvtdatetime(t_record->beg_dt_tm)
     AND a.sch_event_id > 0
     AND a.person_id > 0
     AND a.role_meaning="PATIENT"
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (sl
    WHERE sl.schedule_id=a.schedule_id
     AND sl.location_type_cd=location_type_cd
     AND ((sl.location_cd+ 0)=t_record->location_cd)
     AND sl.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (e
    WHERE e.sch_event_id=a.sch_event_id
     AND e.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (p
    WHERE p.person_id=a.person_id)
    JOIN (enc
    WHERE enc.encntr_id=a.encntr_id)
    JOIN (epr
    WHERE epr.encntr_id=enc.encntr_id
     AND ((epr.prsnl_person_id+ 0)=t_record->consultant_id)
     AND epr.encntr_prsnl_r_cd=consultant_type_cd
     AND epr.encntr_id != 0
     AND epr.active_ind=1)
    JOIN (pnl
    WHERE pnl.person_id=epr.prsnl_person_id
     AND pnl.active_ind=1)
    JOIN (epr2
    WHERE epr2.encntr_id=outerjoin(enc.encntr_id)
     AND epr2.encntr_prsnl_r_cd=outerjoin(referring_type_cd)
     AND epr2.encntr_id != outerjoin(0)
     AND epr2.active_ind=outerjoin(1))
    JOIN (pnl2
    WHERE pnl2.person_id=outerjoin(epr2.prsnl_person_id)
     AND pnl2.active_ind=outerjoin(1))
   ORDER BY cnvtdatetime(a.beg_dt_tm)
  ELSE
   epr_exists = evaluate(nullind(epr.encntr_prsnl_reltn_id),1,0,1), epr2_exists = evaluate(nullind(
     epr2.encntr_prsnl_reltn_id),1,0,1), a.queue_id
   FROM sch_location sl,
    sch_appt a,
    sch_event e,
    person p,
    encounter enc,
    encntr_prsnl_reltn epr,
    encntr_prsnl_reltn epr2,
    prsnl pnl,
    prsnl pnl2
   PLAN (a
    WHERE a.beg_dt_tm < cnvtdatetime(t_record->end_dt_tm)
     AND a.end_dt_tm > cnvtdatetime(t_record->beg_dt_tm)
     AND a.sch_event_id > 0
     AND a.person_id > 0
     AND a.role_meaning="PATIENT"
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (sl
    WHERE sl.schedule_id=a.schedule_id
     AND sl.location_type_cd=location_type_cd
     AND ((sl.location_cd+ 0)=t_record->location_cd)
     AND sl.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (e
    WHERE e.sch_event_id=a.sch_event_id
     AND e.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (p
    WHERE p.person_id=a.person_id)
    JOIN (enc
    WHERE enc.encntr_id=a.encntr_id)
    JOIN (epr
    WHERE epr.encntr_id=outerjoin(enc.encntr_id)
     AND epr.encntr_prsnl_r_cd=outerjoin(consultant_type_cd)
     AND epr.encntr_id != outerjoin(0)
     AND epr.active_ind=outerjoin(1))
    JOIN (pnl
    WHERE pnl.person_id=outerjoin(epr.prsnl_person_id)
     AND pnl.active_ind=outerjoin(1))
    JOIN (epr2
    WHERE epr2.encntr_id=outerjoin(enc.encntr_id)
     AND epr2.encntr_prsnl_r_cd=outerjoin(referring_type_cd)
     AND epr2.encntr_id != outerjoin(0)
     AND epr2.active_ind=outerjoin(1))
    JOIN (pnl2
    WHERE pnl2.person_id=outerjoin(epr2.prsnl_person_id)
     AND pnl2.active_ind=outerjoin(1))
   ORDER BY cnvtdatetime(a.beg_dt_tm)
  ENDIF
  INTO "nl:"
  HEAD REPORT
   reply->query_qual_cnt = 0
  DETAIL
   reply->query_qual_cnt = (reply->query_qual_cnt+ 1)
   IF (mod(reply->query_qual_cnt,100)=1)
    stat = alterlist(reply->query_qual,(reply->query_qual_cnt+ 99)), stat = alterlist(t_record->
     event_qual,(reply->query_qual_cnt+ 99))
   ENDIF
   reply->query_qual[reply->query_qual_cnt].hide#scheventid = a.sch_event_id, reply->query_qual[reply
   ->query_qual_cnt].hide#scheduleid = a.schedule_id, reply->query_qual[reply->query_qual_cnt].
   hide#scheduleseq = e.schedule_seq,
   reply->query_qual[reply->query_qual_cnt].hide#schapptid = a.sch_appt_id, reply->query_qual[reply->
   query_qual_cnt].hide#statemeaning = a.state_meaning, reply->query_qual[reply->query_qual_cnt].
   hide#encounterid = a.encntr_id,
   reply->query_qual[reply->query_qual_cnt].hide#personid = a.person_id, reply->query_qual[reply->
   query_qual_cnt].hide#bitmask = 0, reply->query_qual[reply->query_qual_cnt].appt_type_display =
   uar_get_code_display(e.appt_synonym_cd),
   reply->query_qual[reply->query_qual_cnt].appt_status = uar_get_code_display(a.sch_state_cd), reply
   ->query_qual[reply->query_qual_cnt].encounter_type = uar_get_code_display(enc.encntr_type_cd),
   reply->query_qual[reply->query_qual_cnt].encounter_status = uar_get_code_display(enc
    .encntr_status_cd)
   IF (a.person_id > 0)
    reply->query_qual[reply->query_qual_cnt].person_name = p.name_full_formatted
    IF (utc2)
     reply->query_qual[reply->query_qual_cnt].birth_tz = p.birth_tz
    ENDIF
    reply->query_qual[reply->query_qual_cnt].dob = p.birth_dt_tm, reply->query_qual[reply->
    query_qual_cnt].sex = uar_get_code_display(p.sex_cd)
   ELSE
    reply->query_qual[reply->query_qual_cnt].person_name = "", reply->query_qual[reply->
    query_qual_cnt].sex = ""
   ENDIF
   IF (e.protocol_type_flag=1)
    t_record->event_qual[reply->query_qual_cnt].protocol_parent_id = e.sch_event_id
   ENDIF
   reply->query_qual[reply->query_qual_cnt].episode_type = uar_get_code_display(enc.encntr_type_cd),
   reply->query_qual[reply->query_qual_cnt].service_category = uar_get_code_display(enc
    .service_category_cd)
   IF (epr_exists)
    reply->query_qual[reply->query_qual_cnt].consultant = pnl.name_full_formatted
   ENDIF
   IF (epr2_exists)
    reply->query_qual[reply->query_qual_cnt].referred_by = pnl2.name_full_formatted
   ENDIF
  FOOT REPORT
   IF (mod(reply->query_qual_cnt,100) != 0)
    stat = alterlist(reply->query_qual,reply->query_qual_cnt), stat = alterlist(t_record->event_qual,
     reply->query_qual_cnt)
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->query_qual_cnt <= 0))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ph.phone_id
  FROM (dummyt d  WITH seq = value(reply->query_qual_cnt)),
   phone ph
  PLAN (d
   WHERE (reply->query_qual[d.seq].hide#personid > 0))
   JOIN (ph
   WHERE (ph.parent_entity_id=reply->query_qual[d.seq].hide#personid)
    AND ph.parent_entity_name="PERSON"
    AND ph.phone_id != 0
    AND ph.phone_type_cd=home_phone_cd
    AND ph.active_ind=1
    AND ph.phone_type_seq=1
    AND ph.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ph.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq
  DETAIL
   reply->query_qual[d.seq].home_phone = cnvtphone(cnvtalphanum(ph.phone_num),ph.phone_format_cd)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ph.phone_id
  FROM (dummyt d  WITH seq = value(reply->query_qual_cnt)),
   phone ph
  PLAN (d
   WHERE (reply->query_qual[d.seq].hide#personid > 0))
   JOIN (ph
   WHERE (ph.parent_entity_id=reply->query_qual[d.seq].hide#personid)
    AND ph.parent_entity_name="PERSON"
    AND ph.phone_id != 0
    AND ph.phone_type_cd=bus_phone_cd
    AND ph.active_ind=1
    AND ph.phone_type_seq=1
    AND ph.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ph.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq
  DETAIL
   reply->query_qual[d.seq].bus_phone = cnvtphone(cnvtalphanum(ph.phone_num),ph.phone_format_cd)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  addr.city
  FROM (dummyt d  WITH seq = value(reply->query_qual_cnt)),
   address addr
  PLAN (d
   WHERE (reply->query_qual[d.seq].hide#personid > 0))
   JOIN (addr
   WHERE (addr.parent_entity_id=reply->query_qual[d.seq].hide#personid)
    AND addr.parent_entity_name="PERSON"
    AND addr.address_type_cd=addr_type_cd
    AND addr.address_id != 0
    AND addr.active_ind=1)
  ORDER BY d.seq
  DETAIL
   reply->query_qual[d.seq].address = addr.city
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ena.alias
  FROM (dummyt d  WITH seq = value(reply->query_qual_cnt)),
   encntr_alias ena
  PLAN (d
   WHERE (reply->query_qual[d.seq].hide#personid > 0)
    AND (reply->query_qual[d.seq].hide#encounterid > 0))
   JOIN (ena
   WHERE (ena.encntr_id=reply->query_qual[d.seq].hide#encounterid)
    AND ena.encntr_id != 0
    AND ena.encntr_alias_type_cd=en_mrn_cd
    AND ena.active_ind=1
    AND ena.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ena.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq
  DETAIL
   reply->query_qual[d.seq].mrn = substring(1,20,cnvtalias(ena.alias,ena.alias_pool_cd))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  wl.pm_wait_list_id
  FROM (dummyt d  WITH seq = value(reply->query_qual_cnt)),
   pm_wait_list wl
  PLAN (d
   WHERE (reply->query_qual[d.seq].hide#personid > 0)
    AND (reply->query_qual[d.seq].hide#encounterid > 0))
   JOIN (wl
   WHERE (wl.person_id=reply->query_qual[d.seq].hide#personid)
    AND ((wl.encntr_id+ 0)=reply->query_qual[d.seq].hide#encounterid)
    AND wl.active_ind=1)
  ORDER BY d.seq
  DETAIL
   reply->query_qual[d.seq].admin_category = uar_get_code_display(wl.admit_category_cd), reply->
   query_qual[d.seq].priority_type = uar_get_code_display(wl.urgency_cd), reply->query_qual[d.seq].
   referral_recieved_dt_tm = wl.status_dt_tm,
   reply->query_qual[d.seq].availability = uar_get_code_display(wl.stand_by_cd), reply->query_qual[d
   .seq].referral_requested_dt_tm = wl.referral_dt_tm, reply->query_qual[d.seq].referral_reason =
   uar_get_code_display(wl.referral_reason_cd),
   reply->query_qual[d.seq].booking_system_type = uar_get_code_display(wl.admit_booking_cd), reply->
   query_qual[d.seq].guaranteed_by_dt_tm = wl.admit_guaranteed_dt_tm, reply->query_qual[d.seq].
   status_cd = wl.status_cd,
   reply->query_qual[d.seq].adj_waiting_start_dt_tm = wl.adj_waiting_start_dt_tm, reply->query_qual[d
   .seq].waiting_end_dt_tm = wl.waiting_end_dt_tm, reply->query_qual[d.seq].suspended_days = wl
   .suspended_days,
   reply->query_qual[d.seq].status_dt_tm = wl.status_dt_tm, reply->query_qual[d.seq].
   waiting_start_dt_tm = wl.waiting_start_dt_tm
  WITH nocounter
 ;end select
 SET dttoday = cnvtdatetime((curdate+ 1),0)
 SELECT INTO "nl:"
  wl.pm_wait_list_id
  FROM (dummyt d  WITH seq = value(reply->query_qual_cnt)),
   pm_wait_list wl,
   pm_wait_list_status wls
  PLAN (d
   WHERE (reply->query_qual[d.seq].hide#personid > 0)
    AND (reply->query_qual[d.seq].hide#encounterid > 0))
   JOIN (wl
   WHERE (wl.person_id=reply->query_qual[d.seq].hide#personid)
    AND ((wl.encntr_id+ 0)=reply->query_qual[d.seq].hide#encounterid)
    AND wl.last_dna_dt_tm != null
    AND wl.active_ind=1)
   JOIN (wls
   WHERE wls.pm_wait_list_id=wl.pm_wait_list_id
    AND wls.status_cd=suspend_cd
    AND wls.status_dt_tm < cnvtdatetime(curdate,curtime3)
    AND wls.status_end_dt_tm > wl.last_dna_dt_tm
    AND wls.active_ind=1)
  ORDER BY d.seq, cnvtdatetime(wls.status_end_dt_tm)
  HEAD d.seq
   dtstatusstart = 0.0, dtstatusend = 0.0, lsuspenddays = 0
  DETAIL
   IF (cnvtdatetime(wl.last_dna_dt_tm) > 0
    AND cnvtdatetime(wl.last_dna_dt_tm) < dttoday)
    dtstatusstart = cnvtdatetime(wls.status_dt_tm), dtstatusend = cnvtdatetime(wls.status_end_dt_tm)
    IF (cnvtdatetime(wl.last_dna_dt_tm) > dtstatusstart
     AND dtstatusstart > 0)
     IF (dtstatusend > cnvtdatetime(curdate,curtime3))
      lsuspenddays = (lsuspenddays+ datetimediff(cnvtdatetime(curdate,curtime3),cnvtdatetime(wl
        .last_dna_dt_tm)))
     ELSE
      lsuspenddays = (lsuspenddays+ datetimediff(cnvtdatetime(dtstatusend),cnvtdatetime(wl
        .last_dna_dt_tm)))
     ENDIF
    ELSE
     IF (dtstatusend > cnvtdatetime(curdate,curtime3))
      lsuspenddays = (lsuspenddays+ datetimediff(cnvtdatetime(curdate,curtime3),cnvtdatetime(
        dtstatusstart)))
     ELSE
      lsuspenddays = (lsuspenddays+ datetimediff(cnvtdatetime(wls.status_end_dt_tm),cnvtdatetime(
        dtstatusstart)))
     ENDIF
    ENDIF
   ELSE
    lsuspenddays = reply->query_qual[d.seq].suspended_days
   ENDIF
  FOOT  d.seq
   reply->query_qual[d.seq].suspended_days = lsuspenddays
  WITH nocounter
 ;end select
 FOR (input_i = 1 TO size(reply->query_qual,5))
   SET status_cd = reply->query_qual[input_i].status_cd
   SET adj_waiting_start_dt_tm = reply->query_qual[input_i].adj_waiting_start_dt_tm
   SET waiting_end_dt_tm = reply->query_qual[input_i].waiting_end_dt_tm
   SET suspended_days = reply->query_qual[input_i].suspended_days
   SET status_dt_tm = reply->query_qual[input_i].status_dt_tm
   CALL waitlistcalc(1)
   SET reply->query_qual[input_i].adj_waiting_time = adj_waiting_time
   IF ((reply->query_qual[input_i].waiting_start_dt_tm > 0))
    SET waiting_start_dt = cnvtdatetime(format(reply->query_qual[input_i].waiting_start_dt_tm,
      "DD-MMM-YYYY;;D"))
    IF (((waiting_end_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")) OR (waiting_end_dt_tm=0)) )
     IF (ddiffcd > 0)
      SET dttemp1 = cnvtdatetime(cnvtdate(waiting_start_dt),0)
      SET dttemp2 = datetimediff(cnvtdatetime(curdate,0),dttemp1)
     ELSE
      SET dttemp2 = datetimediff(cnvtdatetime(curdate,curtime3),cnvtdatetime(waiting_start_dt),1)
     ENDIF
     SET reply->query_qual[input_i].waiting_time = abs(dttemp2)
    ELSE
     IF (ddiffcd > 0)
      SET dttemp1 = cnvtdatetime(cnvtdate(waiting_start_dt),0)
      SET dttemp2 = datetimediff(cnvtdatetime(waiting_end_dt_tm),dttemp1)
     ELSE
      SET dttemp2 = datetimediff(cnvtdatetime(waiting_end_dt_tm),cnvtdatetime(waiting_start_dt),1)
     ENDIF
     SET reply->query_qual[input_i].waiting_time = abs(dttemp2)
    ENDIF
   ENDIF
   SET reply->query_qual[input_i].adj_waiting_time_str = formatreturnvalue(reply->query_qual[input_i]
    .adj_waiting_time)
   SET reply->query_qual[input_i].waiting_time_str = formatreturnvalue(reply->query_qual[input_i].
    waiting_time)
 ENDFOR
 SELECT INTO "nl:"
  pa_exists = evaluate(nullind(pa.alias_pool_cd),1,0,1)
  FROM (dummyt d  WITH seq = value(reply->query_qual_cnt)),
   sch_location sl,
   location l,
   org_alias_pool_reltn oapr,
   person_alias pa
  PLAN (d
   WHERE (reply->query_qual[d.seq].hide#scheduleid > 0))
   JOIN (sl
   WHERE (sl.schedule_id=reply->query_qual[d.seq].hide#scheduleid))
   JOIN (l
   WHERE l.location_cd=sl.location_cd)
   JOIN (oapr
   WHERE oapr.organization_id=outerjoin(l.organization_id)
    AND oapr.alias_entity_name=outerjoin("PERSON_ALIAS")
    AND oapr.alias_entity_alias_type_cd=outerjoin(mrn_cd)
    AND oapr.active_ind=outerjoin(1))
   JOIN (pa
   WHERE pa.person_id=outerjoin(reply->query_qual[d.seq].hide#personid)
    AND pa.alias_pool_cd=outerjoin(oapr.alias_pool_cd)
    AND pa.person_alias_type_cd=outerjoin(mrn_cd)
    AND pa.active_ind=outerjoin(1)
    AND pa.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY d.seq
  DETAIL
   reply->query_qual[d.seq].appt_loc_display = uar_get_code_display(l.location_cd)
   IF (pa_exists=1
    AND (reply->query_qual[d.seq].mrn < " "))
    reply->query_qual[d.seq].mrn = substring(1,20,cnvtalias(pa.alias,pa.alias_pool_cd))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  t_sort = evaluate(a.role_meaning,"PATIENT",2,a.primary_role_ind), a.updt_cnt
  FROM (dummyt d  WITH seq = value(reply->query_qual_cnt)),
   sch_appt a
  PLAN (d
   WHERE (reply->query_qual[d.seq].hide#scheventid > 0)
    AND (reply->query_qual[d.seq].hide#scheduleid > 0))
   JOIN (a
   WHERE (a.sch_event_id=reply->query_qual[d.seq].hide#scheventid)
    AND (a.schedule_id=reply->query_qual[d.seq].hide#scheduleid)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  ORDER BY d.seq, t_sort
  DETAIL
   reply->query_qual[d.seq].hide#bitmask = a.bit_mask, reply->query_qual[d.seq].scheduled_dt_tm =
   cnvtdatetime(a.beg_dt_tm), reply->query_qual[d.seq].appt_dur = a.duration
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.updt_cnt
  FROM (dummyt d  WITH seq = value(reply->query_qual_cnt)),
   sch_event_comm a
  PLAN (d
   WHERE (reply->query_qual[d.seq].hide#scheventid > 0)
    AND (reply->query_qual[d.seq].hide#scheduleid > 0))
   JOIN (a
   WHERE (a.sch_event_id=reply->query_qual[d.seq].hide#scheventid)
    AND (a.sch_action_id=reply->query_qual[d.seq].hide#actionid)
    AND a.text_type_meaning="ACTION"
    AND a.sub_text_meaning="ACTION"
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   reply->query_qual[d.seq].cmt = uar_i18ngetmessage(i18nhandle,"Yes","Yes")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(reply->query_qual_cnt)),
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
    AND (a.beg_schedule_seq <= reply->query_qual[d.seq].hide#scheduleseq)
    AND (a.end_schedule_seq >= reply->query_qual[d.seq].hide#scheduleseq)
    AND  NOT (a.order_status_meaning IN ("CANCELED", "COMPLETED", "DISCONTINUED"))
    AND a.state_meaning != "REMOVED"
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND a.active_ind=1)
  ORDER BY d.seq, e.protocol_seq_nbr, a.order_seq_nbr
  HEAD d.seq
   t_record->event_qual[d.seq].order_qual_cnt = 0
  DETAIL
   t_record->event_qual[d.seq].order_qual_cnt = (t_record->event_qual[d.seq].order_qual_cnt+ 1)
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
  FROM (dummyt d  WITH seq = value(reply->query_qual_cnt)),
   sch_event_attach a
  PLAN (d
   WHERE (t_record->event_qual[d.seq].protocol_parent_id <= 0))
   JOIN (a
   WHERE (a.sch_event_id=reply->query_qual[d.seq].hide#scheventid)
    AND a.attach_type_cd=order_type_cd
    AND (a.beg_schedule_seq <= reply->query_qual[d.seq].hide#scheduleseq)
    AND (a.end_schedule_seq >= reply->query_qual[d.seq].hide#scheduleseq)
    AND  NOT (a.order_status_meaning IN ("CANCELED", "COMPLETED", "DISCONTINUED"))
    AND a.state_meaning != "REMOVED"
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND a.active_ind=1)
  ORDER BY d.seq, a.order_seq_nbr
  HEAD d.seq
   t_record->event_qual[d.seq].order_qual_cnt = 0
  DETAIL
   t_record->event_qual[d.seq].order_qual_cnt = (t_record->event_qual[d.seq].order_qual_cnt+ 1)
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
     "] SCH_EVENT_ID [",a.sch_event_id,"] ORDER_ID [",
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
 IF ((t_record->max_order_cnt > 0))
  SET act_seq = 0
  SELECT INTO "nl:"
   t_order_seq_nbr = t_record->event_qual[d.seq].order_qual[d2.seq].order_seq_nbr, od_exists =
   evaluate(nullind(od.order_id),1,0,1)
   FROM (dummyt d  WITH seq = value(reply->query_qual_cnt)),
    (dummyt d2  WITH seq = value(t_record->max_order_cnt)),
    orders o,
    order_action oa,
    order_detail od
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
    JOIN (od
    WHERE od.order_id=outerjoin(oa.order_id)
     AND od.action_sequence=outerjoin(oa.action_sequence)
     AND od.oe_field_meaning_id=outerjoin(127))
   ORDER BY d.seq, d2.seq, o.order_id,
    od.oe_field_id, od.action_sequence DESC
   HEAD d.seq
    t_index = 0
   HEAD d2.seq
    t_index = 0
   HEAD o.order_id
    IF ((reply->query_qual[d.seq].orders <= " "))
     reply->query_qual[d.seq].orders = t_record->event_qual[d.seq].order_qual[d2.seq].description
    ENDIF
   HEAD od.oe_field_id
    act_seq = od.action_sequence, flag = 1
   HEAD od.action_sequence
    IF (act_seq != od.action_sequence)
     flag = 0
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  null_a = nullind(a.organization_alias_id)
  FROM (dummyt d  WITH seq = value(reply->query_qual_cnt)),
   encntr_org_reltn eor,
   organization o,
   organization_alias a
  PLAN (d
   WHERE (reply->query_qual[d.seq].hide#encounterid > 0))
   JOIN (eor
   WHERE (eor.encntr_id=reply->query_qual[d.seq].hide#encounterid)
    AND eor.active_ind=1
    AND eor.encntr_org_reltn_cd=commissioner_cd)
   JOIN (o
   WHERE o.organization_id=eor.organization_id
    AND o.active_ind=1)
   JOIN (a
   WHERE a.organization_id=outerjoin(o.organization_id)
    AND a.active_ind=outerjoin(1)
    AND a.org_alias_type_cd=outerjoin(nhs_org_alias_cd)
    AND a.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND a.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  HEAD d.seq
   reply->query_qual[d.seq].commissioner = trim(o.org_name)
   IF (null_a=0
    AND a.organization_alias_id > 0)
    reply->query_qual[d.seq].commissioner_code = a.alias
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 IF (failed=false)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  IF (failed != true)
   CASE (failed)
    OF select_error:
     SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    ELSE
     SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   ENDCASE
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  ENDIF
 ENDIF
 IF (request->call_echo_ind)
  CALL echorecord(reply)
  CALL echorecord(t_record)
 ENDIF
END GO

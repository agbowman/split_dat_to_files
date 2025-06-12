CREATE PROGRAM cl_clinic_signoff_loc:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH noconstant(" "), private
 ENDIF
 SET last_mod = "162725"
 SET action_none = 0
 SET action_add = 1
 SET action_chg = 2
 SET action_del = 3
 SET action_get = 4
 SET action_ina = 5
 SET action_act = 6
 SET action_temp = 999
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  SET true = 1
 ENDIF
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  SET false = 0
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET update_cnt_error = 14
 SET not_found = 15
 SET version_insert_error = 16
 SET inactivate_error = 17
 SET activate_error = 18
 SET version_delete_error = 19
 SET uar_error = 20
 SET failed = false
 SET table_name = fillstring(50," ")
 SET call_echo_ind = false
 SET i_version = 0
 SET program_name = fillstring(30," ")
 SET sch_security_id = 0.0
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
     2 hide#statemeaning = vc
     2 hide#encounterid = f8
     2 hide#personid = f8
     2 hide#bitmask = i4
     2 hide#waittimesort = i4
     2 beg_dt_tm = dq8
     2 duration = i4
     2 state_display = vc
     2 appt_synonym_free = vc
     2 resource_display = vc
     2 active_status_dt_tm = dq8
     2 person_name = vc
     2 patseen_dt_tm = dq8
     2 wait_time = vc
     2 pat_cancels = i4
     2 noshows = i4
     2 org_cancels = i4
     2 last_dna_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 SET reply->attr_qual_cnt = 19
 DECLARE t_index = i4 WITH noconstant(0)
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
 SET reply->attr_qual[t_index].attr_name = "hide#statemeaning"
 SET reply->attr_qual[t_index].attr_label = "HIDE#STATEMEANING"
 SET reply->attr_qual[t_index].attr_type = "vc"
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
 SET reply->attr_qual[t_index].attr_name = "person_name"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"PATIENT","PATIENT")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "APPT_SYNONYM_FREE"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"APPOINTMENT TYPE",
  "APPOINTMENT TYPE")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "beg_dt_tm"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"APPOINTMENT DATE TIME",
  "APPOINTMENT DATE TIME")
 SET reply->attr_qual[t_index].attr_type = "dq8"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "duration"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"DURATION","DURATION")
 SET reply->attr_qual[t_index].attr_type = "i4"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "state_display"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"STATUS","STATUS")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "resource_display"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"PHYSICIAN OR RESOURCE",
  "PHYSICIAN OR RESOURCE")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "ACTIVE_STATUS_DT_TM"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"BOOKING DATE",
  "BOOKING DATE")
 SET reply->attr_qual[t_index].attr_type = "dq8"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "wait_time"
 SET reply->attr_qual[t_index].attr_label = uar_i18ngetmessage(i18nhandle,"Wait Time (min)",
  "Wait Time (min)")
 SET reply->attr_qual[t_index].attr_type = "vc"
 SET reply->attr_qual[t_index].attr_alt_sort_column = "HIDE#WAITTIMESORT"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "hide#waittimesort"
 SET reply->attr_qual[t_index].attr_label = "HIDE#WAITTIMESORT"
 SET reply->attr_qual[t_index].attr_type = "i4"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "last_dna_dt_tm"
 SET reply->attr_qual[t_index].attr_label = "Last DNA Date"
 SET reply->attr_qual[t_index].attr_type = "dq8"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "org_cancels"
 SET reply->attr_qual[t_index].attr_label = "Org. Cancels"
 SET reply->attr_qual[t_index].attr_type = "i4"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "pat_cancels"
 SET reply->attr_qual[t_index].attr_label = "Patient Cancels"
 SET reply->attr_qual[t_index].attr_type = "i4"
 SET t_index = (t_index+ 1)
 SET reply->attr_qual[t_index].attr_name = "noshows"
 SET reply->attr_qual[t_index].attr_label = "DNAs"
 SET reply->attr_qual[t_index].attr_type = "i4"
 SET stat = alterlist(reply->query_qual,reply->query_qual_cnt)
 FREE SET t_record
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
   1 user_defined = vc
   1 pending_state_cd = f8
   1 pending_state_meaning = c12
   1 resch_action_cd = f8
   1 resch_action_meaning = c12
   1 deferred_cd = f8
   1 deferred_meaning = c12
   1 removed_cd = f8
   1 removed_meaning = c12
   1 scheduled_cd = f8
   1 scheduled_meaning = c12
 )
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
 SET t_record->pending_state_cd = 0.0
 SET t_record->pending_state_meaning = fillstring(12," ")
 SET t_record->pending_state_meaning = "PENDING"
 SET stat = uar_get_meaning_by_codeset(23018,t_record->pending_state_meaning,1,t_record->
  pending_state_cd)
 CALL echo(build("UAR_GET_MEANING_BY_CODESET(23018,",t_record->pending_state_meaning,",1,",t_record->
   pending_state_cd,")"))
 IF (((stat != 0) OR ((t_record->pending_state_cd <= 0))) )
  IF (call_echo_ind)
   CALL echo(build("stat = ",stat))
   CALL echo(build("t_record->pending_state_cd = ",t_record->pending_state_cd))
   CALL echo(build("Invalid select on CODE_SET (23018), CDF_MEANING(",t_record->pending_state_meaning,
     ")"))
  ENDIF
  GO TO exit_script
 ENDIF
 SET t_record->resch_action_cd = 0.0
 SET t_record->resch_action_meaning = fillstring(12," ")
 SET t_record->resch_action_meaning = "RESCHEDULE"
 SET stat = uar_get_meaning_by_codeset(14232,t_record->resch_action_meaning,1,t_record->
  resch_action_cd)
 CALL echo(build("UAR_GET_MEANING_BY_CODESET(14232,",t_record->resch_action_meaning,",1,",t_record->
   resch_action_cd,")"))
 IF (((stat != 0) OR ((t_record->resch_action_cd <= 0))) )
  IF (call_echo_ind)
   CALL echo(build("stat = ",stat))
   CALL echo(build("t_record->resch_action_cd = ",t_record->resch_action_cd))
   CALL echo(build("Invalid select on CODE_SET (14232), CDF_MEANING(",t_record->resch_action_meaning,
     ")"))
  ENDIF
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  a.sch_event_id, pn.name_full_formatted, e.appt_synonym_free,
  a.beg_dt_tm, a.duration, a.state_meaning,
  pr.name_full_formatted, uar_get_code_display(enc.encntr_type_cd)
  FROM sch_appt a2,
   sch_appt a,
   sch_event e,
   prsnl pr,
   sch_event_disp ed,
   sch_event_patient ep,
   pm_wait_list wl,
   person pn,
   encounter enc
  PLAN (a2
   WHERE (a2.appt_location_cd=t_record->location_cd)
    AND a2.beg_dt_tm < cnvtdatetime(t_record->end_dt_tm)
    AND a2.end_dt_tm > cnvtdatetime(t_record->beg_dt_tm)
    AND a2.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND a2.state_meaning IN ("CONFIRMED", "CHECKED IN", "CANCELED", "NOSHOW", "CHECKED OUT")
    AND a2.primary_role_ind=1)
   JOIN (a
   WHERE a.sch_event_id=a2.sch_event_id
    AND a.schedule_id=a2.schedule_id
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND a.active_ind=1
    AND a.role_meaning="PATIENT"
    AND (a.sch_event_id !=
   (SELECT
    se.sch_event_id
    FROM sch_entry se,
     sch_appt sa
    WHERE se.sch_event_id=a.sch_event_id
     AND (se.entry_state_cd=t_record->pending_state_cd)
     AND (se.req_action_cd=t_record->resch_action_cd)
     AND se.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND se.active_ind=1
     AND sa.sch_event_id=se.sch_event_id
     AND sa.state_meaning IN ("NOSHOW", "CANCELED", "CHECKED OUT")
     AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND sa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND sa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND sa.active_ind=1))
    AND (a.sch_event_id !=
   (SELECT
    sa2.sch_event_id
    FROM sch_appt sa2,
     sch_event_action sea,
     code_value cv
    WHERE sa2.sch_appt_id=a.sch_appt_id
     AND sa2.state_meaning="CANCELED"
     AND sa2.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND sa2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND sa2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND sa2.active_ind=1
     AND sea.sch_event_id=sa2.sch_event_id
     AND sea.action_meaning="CANCEL"
     AND cv.code_value=sea.sch_reason_cd
     AND cv.definition IN ("PATREMOVE", "GPREMOVE", "ADMINREMOVE", "HOSPREMOVE")))
    AND (a.sch_event_id !=
   (SELECT
    sa3.sch_event_id
    FROM sch_appt sa3,
     sch_event_detail sed
    WHERE sa3.sch_appt_id=a.sch_appt_id
     AND sa3.state_meaning="CANCELED"
     AND sa3.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND sa3.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND sa3.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND sa3.active_ind=1
     AND sed.sch_event_id=sa3.sch_event_id
     AND sed.oe_field_meaning="SCHOUTCOMEATTEND"
     AND sed.oe_field_value=679625))
    AND (a.sch_event_id !=
   (SELECT
    sa4.sch_event_id
    FROM sch_appt sa4,
     sch_event_detail sed
    WHERE sa4.sch_appt_id=a.sch_appt_id
     AND sa4.state_meaning="CHECKED OUT"
     AND sa4.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND sa4.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND sa4.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND sa4.active_ind=1
     AND sed.sch_event_id=sa4.sch_event_id
     AND sed.oe_field_meaning="SCHOUTCOMEATTEND"
     AND sed.oe_field_value=679625)))
   JOIN (wl
   WHERE wl.encntr_id=outerjoin(a.encntr_id)
    AND wl.sch_event_id=outerjoin(a.sch_event_id)
    AND wl.active_ind=outerjoin(1)
    AND wl.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND wl.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (e
   WHERE e.sch_event_id=a.sch_event_id)
   JOIN (pr
   WHERE pr.person_id=e.req_prsnl_id)
   JOIN (ed
   WHERE ed.sch_event_id=e.sch_event_id
    AND ed.schedule_id=a.schedule_id
    AND ed.disp_field_id IN (5, 36))
   JOIN (ep
   WHERE ep.sch_event_id=e.sch_event_id
    AND ep.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (pn
   WHERE pn.person_id=ep.person_id)
   JOIN (enc
   WHERE enc.encntr_id=ep.encntr_id)
  ORDER BY cnvtdatetime(a.beg_dt_tm)
  HEAD REPORT
   reply->query_qual_cnt = 0
  HEAD a.schedule_id
   reply->query_qual_cnt = (reply->query_qual_cnt+ 1)
   IF (mod(reply->query_qual_cnt,100)=1)
    stat = alterlist(reply->query_qual,(reply->query_qual_cnt+ 99))
   ENDIF
  DETAIL
   CASE (ed.disp_field_id)
    OF 5:
     reply->query_qual[reply->query_qual_cnt].resource_display = ed.disp_display
    OF 36:
     reply->query_qual[reply->query_qual_cnt].patseen_dt_tm = cnvtdatetime(ed.disp_dt_tm),reply->
     query_qual[reply->query_qual_cnt].wait_time = cnvtstring(datetimediff(ed.disp_dt_tm,a.beg_dt_tm,
       4)),reply->query_qual[reply->query_qual_cnt].hide#waittimesort = datetimediff(ed.disp_dt_tm,a
      .beg_dt_tm,4)
   ENDCASE
  FOOT  a.schedule_id
   reply->query_qual[reply->query_qual_cnt].beg_dt_tm = cnvtdatetime(a.beg_dt_tm), reply->query_qual[
   reply->query_qual_cnt].duration = a.duration, reply->query_qual[reply->query_qual_cnt].
   state_display = uar_get_code_display(a.sch_state_cd),
   reply->query_qual[reply->query_qual_cnt].appt_synonym_free = e.appt_synonym_free, reply->
   query_qual[reply->query_qual_cnt].active_status_dt_tm = cnvtdatetime(ep.active_status_dt_tm),
   reply->query_qual[reply->query_qual_cnt].last_dna_dt_tm = cnvtdatetime(wl.last_dna_dt_tm),
   reply->query_qual[reply->query_qual_cnt].person_name = pn.name_full_formatted, reply->query_qual[
   reply->query_qual_cnt].hide#scheventid = a.sch_event_id, reply->query_qual[reply->query_qual_cnt].
   hide#scheduleid = a.schedule_id,
   reply->query_qual[reply->query_qual_cnt].hide#statemeaning = a.state_meaning, reply->query_qual[
   reply->query_qual_cnt].hide#encounterid = a.encntr_id, reply->query_qual[reply->query_qual_cnt].
   hide#personid = a.person_id,
   reply->query_qual[reply->query_qual_cnt].hide#bitmask = a.bit_mask
  FOOT REPORT
   IF (mod(reply->query_qual_cnt,100) != 0)
    stat = alterlist(reply->query_qual,reply->query_qual_cnt)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply->query_qual,5))),
   sch_event_action a
  PLAN (d)
   JOIN (a
   WHERE (a.sch_event_id=reply->query_qual[d.seq].hide#scheventid)
    AND a.active_ind=1)
  ORDER BY a.sch_event_id
  FOOT  a.sch_event_id
   reply->query_qual[d.seq].noshows = count(a.sch_action_id
    WHERE a.reason_meaning="NOSHOW")
  WITH ncounter
 ;end select
 SELECT INTO "nl:"
  a.sch_event_id
  FROM (dummyt d  WITH seq = value(size(reply->query_qual,5))),
   sch_event_action a
  PLAN (d)
   JOIN (a
   WHERE (a.sch_event_id=reply->query_qual[d.seq].hide#scheventid)
    AND a.action_meaning="CANCEL"
    AND a.reason_meaning IN ("HOSPDEFER", "PATDEFER")
    AND a.active_ind=1)
  ORDER BY a.sch_event_id
  DETAIL
   IF (a.reason_meaning="HOSPDEFER")
    reply->query_qual[d.seq].org_cancels = (reply->query_qual[d.seq].org_cancels+ 1)
   ELSEIF (a.reason_meaning="PATDEFER")
    reply->query_qual[d.seq].pat_cancels = (reply->query_qual[d.seq].pat_cancels+ 1)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply->query_qual,5))),
   sch_event_action a
  PLAN (d)
   JOIN (a
   WHERE (a.sch_event_id=reply->query_qual[d.seq].hide#scheventid)
    AND a.action_meaning="RESCHEDULE"
    AND a.active_ind=1
    AND  NOT (a.schedule_id IN (
   (SELECT
    a2.schedule_id
    FROM sch_event_action a2
    WHERE a2.schedule_id=a.schedule_id
     AND a2.action_dt_tm < a.action_dt_tm
     AND a2.sch_event_id=a.sch_event_id
     AND a2.action_meaning IN ("NOSHOW", "CANCEL")))))
  ORDER BY a.sch_event_id
  DETAIL
   IF (a.reason_meaning="HOSPDEFER")
    reply->query_qual[d.seq].org_cancels = (reply->query_qual[d.seq].org_cancels+ 1)
   ELSEIF (a.reason_meaning="PATDEFER")
    reply->query_qual[d.seq].pat_cancels = (reply->query_qual[d.seq].pat_cancels+ 1)
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
 ENDIF
END GO

CREATE PROGRAM bhs_rptstd_cancel_appt_notify:dba
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
 DECLARE s_format_utc_date(date,tz_index,option) = vc
 SUBROUTINE s_format_utc_date(date,tz_index,option)
   IF (curutc)
    IF (tz_index > 0)
     RETURN(format(datetimezone(date,tz_index),option))
    ELSE
     RETURN(format(datetimezone(date,curtimezonesys),option))
    ENDIF
   ELSE
    RETURN(format(date,option))
   ENDIF
 END ;Subroutine
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
 FREE SET t_report
 RECORD t_report(
   1 sch_event_id = f8
   1 schedule_id = f8
   1 primary_resource = vc
   1 schedule_seq = i4
   1 appt_date = dq8
   1 appt_time = dq8
   1 appt_type_cd = f8
   1 appt_type_disp = vc
   1 appt_synonym_cd = f8
   1 appt_synonym_free = vc
   1 primary_synonym = vc
   1 oe_format_id = f8
   1 order_sentence_id = f8
   1 sch_state_cd = f8
   1 state_meaning = vc
   1 sch_state_disp = vc
   1 res_list_id = f8
   1 appt_location_cd = f8
   1 detail_qual_cnt = i4
   1 detail_qual[*]
     2 oe_field_id = f8
     2 oe_field_disp = vc
     2 oe_field_value = f8
     2 oe_field_display_value = vc
     2 oe_field_dt_tm_value = dq8
     2 oe_field_meaning_id = f8
     2 oe_field_meaning = vc
     2 field_seq = i4
     2 field_type_flag = i2
   1 comment_qual_cnt = i4
   1 comment_qual[*]
     2 text_type_cd = f8
     2 text_type_meaning = vc
     2 text_type_disp = vc
     2 sub_text_cd = f8
     2 sub_text_meaning = vc
     2 sub_text_disp = vc
     2 text_id = f8
     2 text = vc
   1 patient_qual_cnt = i4
   1 patient_qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 name = vc
     2 sex = vc
     2 mrn = vc
     2 age = vc
     2 birth_dt_tm = dq8
     2 birth_formatted = vc
     2 phone = vc
     2 candidate_id = f8
   1 location_qual_cnt = i4
   1 location_qual[*]
     2 location_type_cd = f8
     2 location_type_meaning = vc
     2 location_type_disp = vc
     2 location_cd = f8
     2 location_disp = vc
   1 attach_qual_cnt = i4
   1 attach_qual[*]
     2 sch_attach_id = f8
     2 attach_type_cd = f8
     2 attach_type_meaning = vc
     2 attach_type_disp = vc
     2 order_id = f8
     2 person_id = f8
     2 mnemonic = vc
     2 mnemonic_line_cnt = i4
     2 mnemonic_line_qual[*]
       3 mnemonic_line_text = vc
     2 order_detail_display_line = vc
     2 display_line_cnt = i4
     2 display_line_qual[*]
       3 line_text = vc
   1 appt_qual_cnt = i4
   1 appt_qual[*]
     2 sch_appt_id = f8
     2 resource_cd = f8
     2 resource_disp = vc
     2 person_id = f8
     2 booking_id = f8
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
     2 duration = i4
     2 sch_state_cd = f8
     2 sch_state_disp = vc
     2 state_meaning = vc
     2 sch_role_cd = f8
     2 sch_role_disp = vc
     2 role_meaning = vc
     2 role_description = vc
     2 role_seq = i4
     2 primary_role_ind = i2
 )
 DECLARE getcodevalue_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE mrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE en_mrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE home_cd = f8 WITH public, noconstant(0.0)
 DECLARE getcodevalue(code_set=i4,cdf_meaning=c12,code_variable=f8(ref)) = f8
 DECLARE t_event_ind = i2 WITH public, noconstant(1)
 DECLARE t_schedule_ind = i2 WITH public, noconstant(1)
 DECLARE t_detail_ind = i2 WITH public, noconstant(1)
 DECLARE t_comment_ind = i2 WITH public, noconstant(1)
 DECLARE t_patient_ind = i2 WITH public, noconstant(1)
 DECLARE t_location_ind = i2 WITH public, noconstant(1)
 DECLARE t_appt_ind = i2 WITH public, noconstant(1)
 DECLARE t_attach_ind = i2 WITH public, noconstant(1)
 DECLARE t_time = vc
 DECLARE t_string = vc
 DECLARE t_string2 = vc
 DECLARE t_start = i4
 DECLARE t_len = i4
 DECLARE shortername = c80 WITH protect, noconstant(fillstring(80," "))
 SET getcodevalue_meaning = "MRN"
 CALL getcodevalue(4,getcodevalue_meaning,mrn_cd)
 CALL getcodevalue(319,getcodevalue_meaning,en_mrn_cd)
 SET getcodevalue_meaning = "HOME"
 CALL getcodevalue(43,getcodevalue_meaning,home_cd)
 SET t_event_ind = true
 SET t_schedule_ind = true
 SET t_detail_ind = true
 SET t_comment_ind = true
 SET t_patient_ind = true
 SET t_location_ind = true
 SET t_appt_ind = true
 SET t_attach_ind = true
 SET t_report->sch_event_id = cnvtreal( $2)
 SET t_report->schedule_id = cnvtreal( $3)
 SELECT INTO "nl:"
  ed.updt_cnt, a.updt_cnt
  FROM sch_event_disp ed,
   sch_appt a
  PLAN (ed
   WHERE (ed.sch_event_id=t_report->sch_event_id)
    AND (ed.schedule_id=t_report->schedule_id)
    AND ed.disp_field_id=5
    AND ed.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (a
   WHERE a.candidate_id=ed.parent_id
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   t_report->primary_resource = trim(ed.disp_display,3), t_report->appt_date = cnvtdate(a.beg_dt_tm),
   t_report->appt_time = a.beg_dt_tm,
   t_report->appt_location_cd = a.appt_location_cd
  WITH nocounter
 ;end select
 IF (t_event_ind)
  SELECT INTO "nl:"
   a.updt_cnt, a.appt_type_cd, a.sch_state_cd,
   b.updt_cnt
   FROM sch_event a,
    sch_appt_syn b
   PLAN (a
    WHERE a.sch_event_id=cnvtreal( $2)
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (b
    WHERE b.appt_type_cd=a.appt_type_cd
     AND b.primary_ind=1
     AND b.active_ind=1
     AND b.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   DETAIL
    t_report->appt_type_cd = a.appt_type_cd, t_report->appt_type_disp = uar_get_code_display(a
     .appt_type_cd), t_report->appt_synonym_cd = a.appt_synonym_cd,
    t_report->appt_synonym_free = a.appt_synonym_free, t_report->oe_format_id = a.oe_format_id,
    t_report->order_sentence_id = a.order_sentence_id,
    t_report->sch_state_cd = a.sch_state_cd, t_report->state_meaning = a.sch_meaning, t_report->
    sch_state_disp = uar_get_code_display(a.sch_state_cd),
    t_report->primary_synonym = trim(uar_get_code_display(b.appt_synonym_cd),3)
   WITH nocounter
  ;end select
 ENDIF
 IF (t_schedule_ind)
  SELECT INTO "nl:"
   a.updt_cnt
   FROM sch_schedule a
   WHERE a.sch_event_id=cnvtreal( $2)
    AND a.schedule_id=cnvtreal( $3)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
   DETAIL
    t_report->schedule_seq = a.schedule_seq, t_report->res_list_id = a.res_list_id
   WITH nocounter
  ;end select
 ENDIF
 IF (t_detail_ind)
  SELECT INTO "nl:"
   a.updt_cnt, b.updt_cnt
   FROM sch_event_detail a,
    order_entry_fields b
   PLAN (a
    WHERE a.sch_event_id=cnvtreal( $2)
     AND a.sch_action_id=0
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (b
    WHERE b.oe_field_id=a.oe_field_id)
   DETAIL
    t_report->detail_qual_cnt = (t_report->detail_qual_cnt+ 1)
    IF (mod(t_report->detail_qual_cnt,10)=1)
     stat = alterlist(t_report->detail_qual,(t_report->detail_qual_cnt+ 9))
    ENDIF
    t_report->detail_qual[t_report->detail_qual_cnt].oe_field_id = a.oe_field_id, t_report->
    detail_qual[t_report->detail_qual_cnt].oe_field_disp = b.description, t_report->detail_qual[
    t_report->detail_qual_cnt].field_type_flag = b.field_type_flag,
    t_report->detail_qual[t_report->detail_qual_cnt].oe_field_value = a.oe_field_value, t_report->
    detail_qual[t_report->detail_qual_cnt].oe_field_display_value = a.oe_field_display_value,
    t_report->detail_qual[t_report->detail_qual_cnt].oe_field_dt_tm_value = a.oe_field_dt_tm_value,
    t_report->detail_qual[t_report->detail_qual_cnt].oe_field_meaning_id = a.oe_field_meaning_id,
    t_report->detail_qual[t_report->detail_qual_cnt].oe_field_meaning = a.oe_field_meaning, t_report
    ->detail_qual[t_report->detail_qual_cnt].field_seq = a.seq_nbr
   WITH nocounter
  ;end select
 ENDIF
 IF (mod(t_report->detail_qual_cnt,10) != 0)
  SET stat = alterlist(t_report->detail_qual,t_report->detail_qual_cnt)
 ENDIF
 IF (t_comment_ind)
  SELECT INTO "nl:"
   a.updt_cnt, a.sub_text_cd, a.text_type_cd,
   l.updt_cnt
   FROM sch_event_comm a,
    long_text l
   PLAN (a
    WHERE a.sch_event_id=cnvtreal( $2)
     AND a.sch_action_id=0
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (l
    WHERE l.long_text_id=a.text_id)
   ORDER BY a.text_type_cd
   DETAIL
    t_report->comment_qual_cnt = (t_report->comment_qual_cnt+ 1)
    IF (mod(t_report->comment_qual_cnt,10)=1)
     stat = alterlist(t_report->comment_qual,(t_report->comment_qual_cnt+ 9))
    ENDIF
    t_report->comment_qual[t_report->comment_qual_cnt].text_type_cd = a.text_type_cd, t_report->
    comment_qual[t_report->comment_qual_cnt].text_type_meaning = a.text_type_meaning, t_report->
    comment_qual[t_report->comment_qual_cnt].text_type_disp = uar_get_code_display(a.text_type_cd),
    t_report->comment_qual[t_report->comment_qual_cnt].sub_text_cd = a.sub_text_cd, t_report->
    comment_qual[t_report->comment_qual_cnt].sub_text_meaning = a.sub_text_meaning, t_report->
    comment_qual[t_report->comment_qual_cnt].sub_text_disp = uar_get_code_display(a.sub_text_cd),
    t_report->comment_qual[t_report->comment_qual_cnt].text_id = a.text_id
    IF (l.long_text_id > 0)
     t_report->comment_qual[t_report->comment_qual_cnt].text = trim(l.long_text)
    ENDIF
   WITH nocounter
  ;end select
  IF (mod(t_report->comment_qual_cnt,10) != 0)
   SET stat = alterlist(t_report->comment_qual,t_report->comment_qual_cnt)
  ENDIF
 ENDIF
 IF (t_patient_ind)
  SELECT INTO "nl:"
   a.updt_cnt, p.updt_cnt, sex_disp = uar_get_code_display(p.sex_cd),
   ena_exist = decode(ena.seq,1,0), oapr_exist = decode(oapr.seq,1,0), home_phone = decode(ph.seq,
    substring(1,15,ph.phone_num)," ")
   FROM sch_event_patient a,
    person p,
    dummyt d,
    encntr_alias ena,
    location l,
    dummyt d1,
    org_alias_pool_reltn oapr,
    person_alias pa,
    dummyt d2,
    phone ph
   PLAN (a
    WHERE a.sch_event_id=cnvtreal( $2)
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (p
    WHERE p.person_id=a.person_id)
    JOIN (l
    WHERE (l.location_cd=t_report->appt_location_cd))
    JOIN (d
    WHERE d.seq=1)
    JOIN (ena
    WHERE ena.encntr_id=a.encntr_id
     AND ena.encntr_id > 0
     AND ena.encntr_alias_type_cd=en_mrn_cd
     AND ena.active_ind=1
     AND ena.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ena.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (oapr
    WHERE oapr.organization_id=l.organization_id
     AND oapr.alias_entity_name="PERSON_ALIAS"
     AND oapr.alias_entity_alias_type_cd=mrn_cd
     AND oapr.active_ind=1)
    JOIN (pa
    WHERE pa.person_id=p.person_id
     AND pa.alias_pool_cd=oapr.alias_pool_cd
     AND pa.person_alias_type_cd=mrn_cd
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (ph
    WHERE ph.parent_entity_id=p.person_id
     AND ph.parent_entity_name="PERSON"
     AND ph.phone_id != 0
     AND ph.phone_type_cd=home_cd
     AND ph.active_ind=1)
   ORDER BY p.person_id
   HEAD p.person_id
    t_report->patient_qual_cnt = (t_report->patient_qual_cnt+ 1)
    IF (mod(t_report->patient_qual_cnt,10)=1)
     stat = alterlist(t_report->patient_qual,(t_report->patient_qual_cnt+ 9))
    ENDIF
    t_report->patient_qual[t_report->patient_qual_cnt].person_id = a.person_id, t_report->
    patient_qual[t_report->patient_qual_cnt].encntr_id = a.encntr_id, t_report->patient_qual[t_report
    ->patient_qual_cnt].name = p.name_full_formatted,
    t_report->patient_qual[t_report->patient_qual_cnt].sex = sex_disp
    IF (ena_exist
     AND ena.encntr_id > 0)
     t_report->patient_qual[t_report->patient_qual_cnt].mrn = substring(1,20,cnvtalias(ena.alias,ena
       .alias_pool_cd))
    ELSEIF (oapr_exist)
     t_report->patient_qual[t_report->patient_qual_cnt].mrn = substring(1,20,cnvtalias(pa.alias,pa
       .alias_pool_cd))
    ELSE
     t_report->patient_qual[t_report->patient_qual_cnt].mrn = ""
    ENDIF
    t_report->patient_qual[t_report->patient_qual_cnt].birth_dt_tm = p.birth_dt_tm, t_report->
    patient_qual[t_report->patient_qual_cnt].birth_formatted = s_format_utc_date(p.birth_dt_tm,
     validate(p.birth_tz,0),"@SHORTDATE;4;D"), t_report->patient_qual[t_report->patient_qual_cnt].age
     = cnvtage(cnvtdate(p.birth_dt_tm),1),
    t_report->patient_qual[t_report->patient_qual_cnt].candidate_id = a.candidate_id, t_report->
    patient_qual[t_report->patient_qual_cnt].phone = home_phone
   FOOT  p.person_id
    null
   WITH nocounter, outerjoin = d, outerjoin = d1,
    outerjoin = d2, dontcare = ena, dontcare = oapr,
    dontcare = ph
  ;end select
  IF (mod(t_report->patient_qual_cnt,10) != 0)
   SET stat = alterlist(t_report->patient_qual,t_report->patient_qual_cnt)
  ENDIF
 ENDIF
 IF (t_location_ind)
  SELECT INTO "nl:"
   a.updt_cnt
   FROM sch_location a
   WHERE a.schedule_id=cnvtreal( $3)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
   DETAIL
    t_report->location_qual_cnt = (t_report->location_qual_cnt+ 1)
    IF (mod(t_report->location_qual_cnt,10)=1)
     stat = alterlist(t_report->location_qual,(t_report->location_qual_cnt+ 9))
    ENDIF
    t_report->location_qual[t_report->location_qual_cnt].location_type_cd = a.location_type_cd,
    t_report->location_qual[t_report->location_qual_cnt].location_type_meaning = a
    .location_type_meaning, t_report->location_qual[t_report->location_qual_cnt].location_type_disp
     = uar_get_code_display(a.location_type_cd),
    t_report->location_qual[t_report->location_qual_cnt].location_cd = a.location_cd, t_report->
    location_qual[t_report->location_qual_cnt].location_disp = uar_get_code_display(a.location_cd)
   WITH nocounter
  ;end select
  IF (mod(t_report->location_qual_cnt,10) != 0)
   SET stat = alterlist(t_report->location_qual,t_report->location_qual_cnt)
  ENDIF
 ENDIF
 IF (t_attach_ind)
  SELECT INTO "nl:"
   a.updt_cnt
   FROM sch_event_attach a,
    orders o
   PLAN (a
    WHERE a.sch_event_id=cnvtreal( $2)
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND a.attach_type_meaning="ORDER")
    JOIN (o
    WHERE o.order_id=a.order_id)
   DETAIL
    t_report->attach_qual_cnt = (t_report->attach_qual_cnt+ 1)
    IF (mod(t_report->attach_qual_cnt,10)=1)
     stat = alterlist(t_report->attach_qual,(t_report->attach_qual_cnt+ 9))
    ENDIF
    t_report->attach_qual[t_report->attach_qual_cnt].sch_attach_id = a.sch_attach_id, t_report->
    attach_qual[t_report->attach_qual_cnt].attach_type_cd = a.attach_type_cd, t_report->attach_qual[
    t_report->attach_qual_cnt].attach_type_meaning = a.attach_type_meaning,
    t_report->attach_qual[t_report->attach_qual_cnt].attach_type_disp = uar_get_code_display(a
     .attach_type_cd), t_report->attach_qual[t_report->attach_qual_cnt].order_id = a.order_id,
    t_report->attach_qual[t_report->attach_qual_cnt].person_id = o.person_id,
    t_report->attach_qual[t_report->attach_qual_cnt].mnemonic = o.order_mnemonic, t_report->
    attach_qual[t_report->attach_qual_cnt].order_detail_display_line = o.order_detail_display_line
   WITH nocounter
  ;end select
  IF (mod(t_report->attach_qual_cnt,10) != 0)
   SET stat = alterlist(t_report->attach_qual,t_report->attach_qual_cnt)
  ENDIF
  FOR (j = 1 TO t_report->attach_qual_cnt)
    IF (textlen(t_report->attach_qual[j].mnemonic) > 80)
     SET format_text_request->raw_text = t_report->attach_qual[j].mnemonic
     SET format_text_request->chars_per_line = 80
     CALL format_text(1)
     SET t_report->attach_qual[j].mnemonic_line_cnt = format_text_reply->qual_cnt
     SET stat = alterlist(t_report->attach_qual[j].mnemonic_line_qual,format_text_reply->qual_cnt)
     FOR (i = 1 TO format_text_reply->qual_cnt)
       SET t_report->attach_qual[j].mnemonic_line_qual[i].mnemonic_line_text = format_text_reply->
       qual[i].text_string
     ENDFOR
    ENDIF
    SET format_text_request->raw_text = t_report->attach_qual[j].order_detail_display_line
    SET format_text_request->chars_per_line = 80
    CALL format_text(1)
    SET t_report->attach_qual[j].display_line_cnt = format_text_reply->qual_cnt
    SET stat = alterlist(t_report->attach_qual[j].display_line_qual,format_text_reply->qual_cnt)
    FOR (k = 1 TO format_text_reply->qual_cnt)
      SET t_report->attach_qual[j].display_line_qual[k].line_text = format_text_reply->qual[k].
      text_string
    ENDFOR
  ENDFOR
 ENDIF
 IF (t_appt_ind)
  SELECT INTO "nl:"
   a.updt_cnt
   FROM sch_appt a
   WHERE a.sch_event_id=cnvtreal( $2)
    AND a.schedule_id=cnvtreal( $3)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
   DETAIL
    t_report->appt_qual_cnt = (t_report->appt_qual_cnt+ 1)
    IF (mod(t_report->appt_qual_cnt,10)=1)
     stat = alterlist(t_report->appt_qual,(t_report->appt_qual_cnt+ 9))
    ENDIF
    t_report->appt_qual[t_report->appt_qual_cnt].sch_appt_id = a.sch_appt_id, t_report->appt_qual[
    t_report->appt_qual_cnt].resource_cd = a.resource_cd, t_report->appt_qual[t_report->appt_qual_cnt
    ].person_id = a.person_id,
    t_report->appt_qual[t_report->appt_qual_cnt].resource_disp = uar_get_code_display(a.resource_cd),
    t_report->appt_qual[t_report->appt_qual_cnt].booking_id = a.booking_id, t_report->appt_qual[
    t_report->appt_qual_cnt].beg_dt_tm = a.beg_dt_tm,
    t_report->appt_qual[t_report->appt_qual_cnt].end_dt_tm = a.end_dt_tm, t_report->appt_qual[
    t_report->appt_qual_cnt].sch_state_cd = a.sch_state_cd, t_report->appt_qual[t_report->
    appt_qual_cnt].sch_state_disp = uar_get_code_display(a.sch_state_cd),
    t_report->appt_qual[t_report->appt_qual_cnt].duration = a.duration, t_report->appt_qual[t_report
    ->appt_qual_cnt].state_meaning = a.state_meaning, t_report->appt_qual[t_report->appt_qual_cnt].
    sch_role_cd = a.sch_role_cd,
    t_report->appt_qual[t_report->appt_qual_cnt].role_meaning = a.role_meaning, t_report->appt_qual[
    t_report->appt_qual_cnt].role_description = a.role_description, t_report->appt_qual[t_report->
    appt_qual_cnt].role_seq = a.role_seq,
    t_report->appt_qual[t_report->appt_qual_cnt].primary_role_ind = a.primary_role_ind
   WITH nocounter
  ;end select
  IF (mod(t_report->appt_qual_cnt,10) != 0)
   SET stat = alterlist(t_report->appt_qual,t_report->appt_qual_cnt)
  ENDIF
 ENDIF
 FREE SET temp
 RECORD temp(
   1 qual_cnt = i4
   1 qual[*]
     2 temp_string = vc
     2 temp_string2 = vc
     2 break_line_nbr = i4
     2 break_pos = i4
     2 text_cnt = i4
     2 text_qual[*]
       3 text_string = vc
 )
 CALL echo(t_report->detail_qual_cnt)
 SET temp->qual_cnt = t_report->detail_qual_cnt
 SET stat = alterlist(temp->qual,temp->qual_cnt)
 FOR (j = 1 TO temp->qual_cnt)
   CASE (t_report->detail_qual[j].field_type_flag)
    OF 0:
     IF ((t_report->detail_qual[j].oe_field_disp IN ("Diagnosis:", "Procedure:")))
      SET temp->qual[j].temp_string = concat(trim(t_report->detail_qual[j].oe_field_disp),": ")
      SET temp->qual[j].temp_string2 = trim(t_report->detail_qual[j].oe_field_display_value)
     ELSE
      SET temp->qual[j].temp_string = concat(trim(t_report->detail_qual[j].oe_field_disp),": ")
      SET temp->qual[j].temp_string2 = t_report->detail_qual[j].oe_field_display_value
     ENDIF
    OF 1:
     SET temp->qual[j].temp_string = concat(trim(t_report->detail_qual[j].oe_field_disp),": ")
     SET temp->qual[j].temp_string2 = format(t_report->detail_qual[j].oe_field_value,";l;i")
    OF 2:
     SET temp->qual[j].temp_string = concat(trim(t_report->detail_qual[j].oe_field_disp),": ")
     SET temp->qual[j].temp_string2 = format(t_report->detail_qual[j].oe_field_value,";l;f")
    OF 3:
     SET temp->qual[j].temp_string = concat(trim(t_report->detail_qual[j].oe_field_disp),": ")
     SET temp->qual[j].temp_string2 = format(t_report->detail_qual[j].oe_field_dt_tm_value,
      "@SHORTDATE")
    OF 4:
     SET temp->qual[j].temp_string = concat(trim(t_report->detail_qual[j].oe_field_disp),": ")
     SET temp->qual[j].temp_string2 = format(t_report->detail_qual[j].oe_field_dt_tm_value,
      "@TIMENOSECONDS")
    OF 5:
     SET temp->qual[j].temp_string = concat(trim(t_report->detail_qual[j].oe_field_disp),": ")
     SET temp->qual[j].temp_string2 = format(t_report->detail_qual[j].oe_field_dt_tm_value,
      "@SHORTDATETIME")
    OF 6:
     SET temp->qual[j].temp_string = concat(trim(t_report->detail_qual[j].oe_field_disp),": ")
     SET temp->qual[j].temp_string2 = t_report->detail_qual[j].oe_field_display_value
    OF 7:
     SET temp->qual[j].temp_string = concat(trim(t_report->detail_qual[j].oe_field_disp),": ")
     SET temp->qual[j].temp_string2 = evaluate(t_report->detail_qual[j].oe_field_value,1.0,"Yes","No"
      )
    OF 8:
     SET temp->qual[j].temp_string = concat(trim(t_report->detail_qual[j].oe_field_disp),": ")
     SET temp->qual[j].temp_string2 = t_report->detail_qual[j].oe_field_display_value
    ELSE
     SET temp->qual[j].temp_string = concat(trim(t_report->detail_qual[j].oe_field_disp),": ")
     SET temp->qual[j].temp_string2 = t_report->detail_qual[j].oe_field_display_value
   ENDCASE
 ENDFOR
 FOR (j = 1 TO temp->qual_cnt)
   SET format_text_request->raw_text = temp->qual[j].temp_string
   SET format_text_request->chars_per_line = 75
   CALL format_text(1)
   SET temp->qual[j].text_cnt = format_text_reply->qual_cnt
   SET stat = alterlist(temp->qual[j].text_qual,format_text_reply->qual_cnt)
   FOR (k = 1 TO format_text_reply->qual_cnt)
     SET temp->qual[j].text_qual[k].text_string = format_text_reply->qual[k].text_string
   ENDFOR
   SET temp->qual[j].break_line_nbr = temp->qual[j].text_cnt
   SET temp->qual[j].break_pos = (textlen(temp->qual[j].text_qual[temp->qual[j].text_cnt].text_string
    )+ 1)
   SET format_text_request->raw_text = concat(temp->qual[j].text_qual[temp->qual[j].text_cnt].
    text_string," ",temp->qual[j].temp_string2)
   SET format_text_request->chars_per_line = 75
   CALL format_text(1)
   SET temp->qual[j].text_cnt = ((temp->qual[j].text_cnt+ format_text_reply->qual_cnt) - 1)
   SET stat = alterlist(temp->qual[j].text_qual,temp->qual[j].text_cnt)
   FOR (k = 1 TO format_text_reply->qual_cnt)
     SET temp->qual[j].text_qual[((k+ temp->qual[j].break_line_nbr) - 1)].text_string =
     format_text_reply->qual[k].text_string
   ENDFOR
 ENDFOR
 SET line = fillstring(128,"-")
 SET sline = fillstring(10,"+")
 SET line1 = fillstring(128,"=")
 SELECT INTO  $1
  d.seq
  FROM dummyt d
  HEAD REPORT
   y_pos = 0, "{F/4}{CPI/8}{LPI/4}", "{POS/180/60}{B}Same-Day Cancel Notification",
   row + 1, "{F/4}{CPI/12}{LPI/6}", "{POS/30/30}",
   curdate"@SHORTDATE", "{POS/540/30}", curtime"@TIMENOSECONDS;;MTIME",
   row + 1
  HEAD PAGE
   "{POS/280/750}Page ", curpage"###"
  DETAIL
   t_time = format(t_report->appt_time,"@TIMENOSECONDS"), format_text_request->chars_per_line = 90,
   CALL format_text(1),
   y_pos = 80, row + 1
   FOR (i = 1 TO format_text_reply->qual_cnt)
     x_pos = 100, y_pos = (y_pos+ 12), "{F/4}{CPI/12}{LPI/6}{B}"
     IF (y_pos >= 720)
      y_pos = 30, BREAK
     ENDIF
     CALL print(calcpos(x_pos,y_pos)), format_text_reply->qual[i].text_string, row + 1
   ENDFOR
   y_pos = (y_pos+ 12), line100 = substring(1,95,line)
   IF (y_pos >= 720)
    y_pos = 30, BREAK
   ENDIF
   CALL print(calcpos(30,y_pos)), line100, row + 1
   FOR (k = 1 TO t_report->patient_qual_cnt)
     shortername = substring(1,80,t_report->patient_qual[k].name), y_pos = (y_pos+ 24)
     IF (y_pos >= 720)
      y_pos = 30, BREAK
     ENDIF
     CALL print(calcpos(30,y_pos)), "{CPI/10}{LPI/5}{B}Patient Name: {ENDB}", shortername,
     row + 1, y_pos = (y_pos+ 15)
     IF (y_pos >= 720)
      y_pos = 30, BREAK
     ENDIF
     CALL print(calcpos(300,y_pos)), "{CPI/10}{LPI/5}{B}Medical Record Number: {ENDB}", t_report->
     patient_qual[k].mrn,
     row + 1, y_pos = (y_pos+ 15)
     IF (y_pos >= 720)
      y_pos = 30, BREAK
     ENDIF
     CALL print(calcpos(300,y_pos)), "{CPI/10}{LPI/5}{B}Sex: {ENDB}", t_report->patient_qual[k].sex,
     row + 1, y_pos = (y_pos+ 15)
     IF (y_pos >= 720)
      y_pos = 30, BREAK
     ENDIF
     CALL print(calcpos(300,y_pos)), "{CPI/10}{LPI/5}{B}Date of Birth: {ENDB}", t_report->
     patient_qual[k].birth_formatted,
     row + 1, y_pos = (y_pos+ 15), t_report->patient_qual[k].phone = cnvtalphanum(t_report->
      patient_qual[k].phone)
     IF (size(trim(t_report->patient_qual[k].phone)) > 7)
      IF (y_pos >= 720)
       y_pos = 30, BREAK
      ENDIF
      CALL print(calcpos(300,y_pos)), "{CPI/10}{LPI/5}{B}Phone Number: {ENDB}", t_report->
      patient_qual[k].phone"(###)###-####"
     ELSE
      IF (y_pos >= 720)
       y_pos = 30, BREAK
      ENDIF
      CALL print(calcpos(300,y_pos)), "{CPI/10}{LPI/5}{B}Phone Number: {ENDB}", t_report->
      patient_qual[k].phone"###-####"
     ENDIF
     row + 1, y_pos = (y_pos+ 24)
   ENDFOR
   y_pos = (y_pos+ 6)
   IF (y_pos >= 720)
    y_pos = 30, BREAK
   ENDIF
   "{CPI/12}{LPI/6}",
   CALL print(calcpos(30,y_pos)), line100,
   row + 1, y_pos = (y_pos+ 36)
   IF (y_pos >= 720)
    y_pos = 30, BREAK
   ENDIF
   CALL print(calcpos(30,y_pos)), "{CPI/8}{LPI/4}{B}Appointment Information", row + 1,
   y_pos = (y_pos+ 24)
   IF (y_pos >= 720)
    y_pos = 30, BREAK
   ENDIF
   CALL print(calcpos(30,y_pos)), "{CPI/10}{LPI/5}{B}Appointment Type: {ENDB}", t_report->
   appt_type_disp,
   row + 1, y_pos = (y_pos+ 15)
   IF (y_pos >= 720)
    y_pos = 30, BREAK
   ENDIF
   CALL print(calcpos(30,y_pos)), "{CPI/10}{LPI/5}{B}Appointment Date: {ENDB}", t_report->appt_date
   "@SHORTDATE",
   row + 1, y_pos = (y_pos+ 15)
   IF (y_pos >= 720)
    y_pos = 30, BREAK
   ENDIF
   CALL print(calcpos(30,y_pos)), "{CPI/10}{LPI/5}{B}Primary Resource: {ENDB}", t_report->
   primary_resource,
   row + 1, y_pos = (y_pos+ 15)
   IF (y_pos >= 720)
    y_pos = 30, BREAK
   ENDIF
   CALL print(calcpos(30,y_pos)), "{CPI/10}{LPI/5}{B}Current Status: {ENDB}", t_report->
   sch_state_disp,
   row + 1, y_pos = (y_pos+ 24)
   IF (y_pos >= 720)
    y_pos = 30, BREAK
   ENDIF
   "{CPI/12}{LPI/6}",
   CALL print(calcpos(30,y_pos)), line100,
   row + 1
   IF (t_report->attach_qual_cnt)
    y_pos = (y_pos+ 36)
    IF (y_pos >= 720)
     y_pos = 30, BREAK
    ENDIF
    CALL print(calcpos(30,y_pos)), "{CPI/8}{LPI/4}{B}Order Information", row + 1,
    y_pos = (y_pos+ 24)
    FOR (j = 1 TO t_report->attach_qual_cnt)
      IF (y_pos >= 720)
       y_pos = 30, BREAK
      ENDIF
      IF ((t_report->attach_qual[j].mnemonic_line_cnt > 0))
       CALL print(calcpos(30,y_pos)), "{CPI/10}{LPI/5}{B}Order: {ENDB}", t_report->attach_qual[j].
       mnemonic_line_qual[1].mnemonic_line_text,
       row + 1, y_pos = (y_pos+ 15)
       IF ((t_report->attach_qual[j].mnemonic_line_cnt > 1))
        FOR (idx = 2 TO t_report->attach_qual[j].mnemonic_line_cnt)
          IF (y_pos >= 720)
           y_pos = 30, BREAK
          ENDIF
          CALL print(calcpos(60,y_pos)), "{CPI/10}{LPI/5}", t_report->attach_qual[j].
          mnemonic_line_qual[idx].mnemonic_line_text,
          row + 1, y_pos = (y_pos+ 15)
        ENDFOR
       ENDIF
      ELSE
       CALL print(calcpos(30,y_pos)), "{CPI/10}{LPI/5}{B}Order: {ENDB}", t_report->attach_qual[j].
       mnemonic,
       row + 1, y_pos = (y_pos+ 15)
       IF (y_pos >= 720)
        y_pos = 30, BREAK
       ENDIF
      ENDIF
      CALL print(calcpos(30,y_pos)), "{CPI/10}{LPI/5}{B}Order Details: {ENDB}", t_report->
      attach_qual[j].display_line_qual[1].line_text,
      row + 1, y_pos = (y_pos+ 12)
      IF ((t_report->attach_qual[j].display_line_cnt > 1))
       FOR (k = 2 TO t_report->attach_qual[j].display_line_cnt)
         IF (y_pos >= 720)
          y_pos = 30, BREAK
         ENDIF
         CALL print(calcpos(100,y_pos)), "{CPI/10}{LPI/5}", t_report->attach_qual[j].
         display_line_qual[k].line_text,
         row + 1, y_pos = (y_pos+ 12)
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
  WITH dio = postscript, formfeed = post
 ;end select
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
 SUBROUTINE getcodevalue(code_set,cdf_meaning,code_variable)
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_variable)
  IF (((stat != 0) OR (code_variable <= 0)) )
   CALL echo(build("Invalid select on CODE_SET (",code_set,"),  CDF_MEANING(",cdf_meaning,")"))
   GO TO exit_script
  ENDIF
 END ;Subroutine
END GO

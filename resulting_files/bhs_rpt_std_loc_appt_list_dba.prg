CREATE PROGRAM bhs_rpt_std_loc_appt_list:dba
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
 DECLARE dash_line = c129 WITH public, constant(fillstring(128,"-"))
 DECLARE getcodevalue_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE mrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE en_mrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE ssn_cd = f8 WITH public, noconstant(0.0)
 DECLARE home_cd = f8 WITH public, noconstant(0.0)
 DECLARE business_cd = f8 WITH public, noconstant(0.0)
 DECLARE location_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE getcodevalue(code_set=i4,cdf_meaning=c12,code_variable=f8(ref)) = f8
 FREE SET t_record
 RECORD t_record(
   1 t_ind = i4
   1 t_temp = vc
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 appt_location_cd = f8
 )
 SET t_record->t_ind = (findstring(" = ", $4,1)+ 3)
 SET t_record->appt_location_cd = cnvtreal(substring(t_record->t_ind,((size(trim( $4)) - t_record->
   t_ind)+ 1), $4))
 SET t_record->t_ind = (findstring(char(34), $3,1)+ 1)
 SET t_record->beg_dt_tm = cnvtdatetime(substring(t_record->t_ind,23, $3))
 SET t_record->t_ind = (findstring(char(34), $2,1)+ 1)
 SET t_record->end_dt_tm = cnvtdatetime(substring(t_record->t_ind,23, $2))
 SET getcodevalue_meaning = "MRN"
 CALL getcodevalue(4,getcodevalue_meaning,mrn_cd)
 CALL getcodevalue(319,getcodevalue_meaning,en_mrn_cd)
 SET getcodevalue_meaning = "SSN"
 CALL getcodevalue(4,getcodevalue_meaning,ssn_cd)
 SET getcodevalue_meaning = "HOME"
 CALL getcodevalue(43,getcodevalue_meaning,home_cd)
 SET getcodevalue_meaning = "BUSINESS"
 CALL getcodevalue(43,getcodevalue_meaning,business_cd)
 SET getcodevalue_meaning = "APPOINTMENT"
 CALL getcodevalue(14509,getcodevalue_meaning,location_type_cd)
 SELECT INTO  $1
  loc_name = uar_get_code_display(t_record->appt_location_cd), date = a.beg_dt_tm, date_8 = format(a
   .beg_dt_tm,"YYYYMMDD;;D"),
  appt_type = substring(1,20,e.appt_synonym_free), name = substring(1,22,cnvtupper(p
    .name_full_formatted)), ssn = substring(1,11,cnvtalias(pa2.alias,pa2.alias_pool_cd)),
  home_ext = substring(1,6,ph.extension), business_ext = substring(1,6,ph2.extension), state =
  uar_get_code_display(a.sch_state_cd),
  ena_exist = decode(ena.seq,1,0), oapr_exist = decode(oapr.seq,1,0), en_mrn = substring(1,20,
   cnvtalias(ena.alias,ena.alias_pool_cd)),
  mrn = substring(1,20,cnvtalias(pa.alias,pa.alias_pool_cd))
  FROM sch_appt a,
   sch_location sl,
   sch_event e,
   sch_event_patient ep,
   person p,
   dummyt d,
   encntr_alias ena,
   location l,
   dummyt d1,
   org_alias_pool_reltn oapr,
   person_alias pa,
   dummyt d2,
   person_alias pa2,
   dummyt d3,
   phone ph,
   dummyt d4,
   phone ph2
  PLAN (a
   WHERE a.appt_location_cd BETWEEN t_record->appt_location_cd AND t_record->appt_location_cd
    AND a.beg_dt_tm BETWEEN cnvtdatetime(t_record->beg_dt_tm) AND cnvtdatetime(t_record->end_dt_tm)
    AND a.sch_event_id > 0
    AND a.role_meaning="PATIENT"
    AND a.state_meaning IN ("CONFIRMED", "CHECKED IN", "CHECKED OUT", "SCHEDULED")
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND a.active_ind=1)
   JOIN (sl
   WHERE sl.schedule_id=a.schedule_id
    AND ((sl.location_type_cd+ 0)=location_type_cd)
    AND ((sl.location_cd+ 0)=t_record->appt_location_cd)
    AND sl.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (e
   WHERE e.sch_event_id=a.sch_event_id)
   JOIN (ep
   WHERE ep.sch_event_id=e.sch_event_id
    AND ep.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (p
   WHERE p.person_id=ep.person_id)
   JOIN (l
   WHERE l.location_cd=a.appt_location_cd)
   JOIN (d
   WHERE d.seq=1)
   JOIN (ena
   WHERE ena.encntr_id=ep.encntr_id
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
    AND oapr.alias_entity_alias_type_cd=mrn_cd)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.alias_pool_cd=oapr.alias_pool_cd
    AND pa.person_alias_type_cd=mrn_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (pa2
   WHERE pa2.person_id=p.person_id
    AND pa2.person_alias_type_cd=ssn_cd
    AND pa2.active_ind=1)
   JOIN (d3
   WHERE d3.seq=1)
   JOIN (ph
   WHERE ph.parent_entity_id=p.person_id
    AND ph.parent_entity_name="PERSON"
    AND ph.phone_id != 0
    AND ph.phone_type_cd=home_cd
    AND ph.active_ind=1
    AND ph.phone_type_seq=1
    AND ph.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ph.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d4
   WHERE d4.seq=1)
   JOIN (ph2
   WHERE ph2.parent_entity_id=p.person_id
    AND ph2.parent_entity_name="PERSON"
    AND ph2.phone_id != 0
    AND ph2.phone_type_cd=business_cd
    AND ph2.active_ind=1
    AND ph2.phone_type_seq=1
    AND ph2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ph2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY cnvtdatetime(a.beg_dt_tm), a.sch_appt_id, p.person_id
  HEAD REPORT
   generic_ind = 0
  HEAD PAGE
   col 43, "S C H E D U L I N G   M A N A G E M E N T", row + 1,
   t_var = ((128 - size(trim( $5)))/ 2), col t_var,  $5,
   row + 1, t_var = ((128 - (25+ size(trim(loc_name))))/ 2), col 0,
   loc_name, row + 1, row + 1,
   col 0, "Cnt Apt Date Time    Appt Type            MRN                  ",
   "Name                   State                   Home/Work Ph   Ext.",
   row + 1, col 0, dash_line,
   row + 1, t_date = fillstring(8," "), t_count = 0
  HEAD a.sch_appt_id
   null
  HEAD p.person_id
   IF (ph.phone_num > " ")
    home = cnvtphone(cnvtalphanum(ph.phone_num),ph.phone_format_cd)
   ELSE
    home = ""
   ENDIF
   IF (ph2.phone_num > " ")
    business = cnvtphone(cnvtalphanum(ph2.phone_num),ph2.phone_format_cd)
   ELSE
    business = ""
   ENDIF
   generic_ind = 1, t_count = (t_count+ 1), col 0,
   t_count"###;r;i"
   IF (t_date != date_8)
    col 4, date"@SHORTDATE", t_date = date_8
   ENDIF
   col 13, date"@TIMENOSECONDS"
   IF (cnvtint(format(date,"HHMM;;MTIME")) < 1200)
    col 18, "am"
   ELSE
    col 18, "pm"
   ENDIF
   col 21, appt_type
   IF (ena_exist
    AND ena.encntr_id > 0)
    col 42, en_mrn
   ELSEIF (oapr_exist)
    col 42, mrn
   ELSE
    col 42, " "
   ENDIF
   col 63, name, col 86,
   state
   IF (home > " "
    AND home != "(000) 000-0000")
    col 110, home"##############"
   ENDIF
   IF (home_ext > " ")
    col 125, home_ext
   ENDIF
   row + 1
   IF (business > " "
    AND business != "(000) 000-0000")
    col 110, business"##############"
   ENDIF
   IF (business_ext > " ")
    col 125, business_ext
   ENDIF
   IF (row > 54)
    row + 1, BREAK
   ELSE
    row + 2
   ENDIF
  FOOT  p.person_id
   null
  FOOT  a.sch_appt_id
   null
  FOOT PAGE
   col 0, dash_line, row + 1,
   col 0, curdate"@WEEKDAYNAME", ", ",
   curdate"@LONGDATE", col 110, "Page: ",
   curpage";l;i"
  WITH nullreport, nocounter, compress,
   outerjoin = d, outerjoin = d1, outerjoin = d2,
   outerjoin = d3, outerjoin = d4, dontcare = ena,
   dontcare = oapr, dontcare = pa2, dontcare = ph,
   dontcare = ph2
 ;end select
 SUBROUTINE getcodevalue(code_set,cdf_meaning,code_variable)
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_variable)
  IF (((stat != 0) OR (code_variable <= 0)) )
   CALL echo(build("Invalid select on CODE_SET (",code_set,"),  CDF_MEANING(",cdf_meaning,")"))
   GO TO exit_script
  ENDIF
 END ;Subroutine
#exit_script
END GO

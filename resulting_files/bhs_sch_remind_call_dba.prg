CREATE PROGRAM bhs_sch_remind_call:dba
 DECLARE mf_paecsc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,
   "PREOPERATIVEEVALUATIONCSC"))
 DECLARE mf_current_name_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"CURRENT"))
 DECLARE mf_schedappt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",73,"SCHEDAPPT"))
 DECLARE mf_phone_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE mf_interplang_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "INTERPRETERLANGUAGE"))
 DECLARE ms_loc_dir = vc WITH protect, constant(logical("ccluserdir"))
 DECLARE mf_cs43_cell_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2510010055"))
 DECLARE ms_weekday = vc WITH protect, noconstant(trim(format(curdate,"@WEEKDAYNAME"),3))
 DECLARE ms_file = vc WITH protect, constant(build(logical("bhscust"),
   "/ftp/bhs_sch_remind_call/sn_reminder_call_",trim(cnvtstring(rand(0),20),3),"_",format(
    cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;d"),
   ".dat"))
 CALL echo(ms_file)
 DECLARE mf_start_date = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_date = f8 WITH protect, noconstant(0.0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ms_str = vc WITH protect, noconstant("")
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ms_ftp_path = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_host = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_username = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_password = vc WITH protect, noconstant(" ")
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 CALL echo(ms_weekday)
 FREE RECORD rem
 RECORD rem(
   1 cnt = i4
   1 qual[*]
     2 f_person_id = f8
     2 ms_first_name = vc
     2 ms_last_name = vc
     2 mf_sch_event_id = f8
     2 ms_phone_num = vc
     2 ms_lang = vc
     2 ms_location_name = vc
     2 mf_location_number = f8
     2 ms_provider_number = vc
     2 ms_appt_dt_tm = vc
     2 mf_department_number = f8
     2 ms_visit_type = vc
     2 ms_visit_type_sch_alias = vc
 )
 IF (ms_weekday IN ("Saturday", "Sunday"))
  CALL echo("EXIT, SHOULD NOT RUN")
  GO TO exit_script
 ELSEIF (ms_weekday IN ("Monday", "Tuesday"))
  SET mf_start_date = cnvtdatetime((curdate+ 3),000000)
  SET mf_stop_date = cnvtdatetime((curdate+ 3),235959)
 ELSEIF (ms_weekday IN ("Wednesday"))
  SET mf_start_date = cnvtdatetime((curdate+ 3),000000)
  SET mf_stop_date = cnvtdatetime((curdate+ 5),235959)
 ELSEIF (ms_weekday IN ("Thursday", "Friday"))
  SET mf_start_date = cnvtdatetime((curdate+ 5),000000)
  SET mf_stop_date = cnvtdatetime((curdate+ 5),235959)
 ENDIF
 CALL echo(format(mf_start_date,";;q"))
 CALL echo(format(mf_stop_date,";;q"))
 SELECT INTO "nl:"
  FROM sch_appt sa,
   person_name pn,
   sch_event se,
   code_value_outbound cvo,
   phone ph,
   sch_event_detail sed
  PLAN (sa
   WHERE sa.appt_location_cd=mf_paecsc_cd
    AND sa.beg_dt_tm >= cnvtdatetime(mf_start_date)
    AND sa.beg_dt_tm <= cnvtdatetime(mf_stop_date)
    AND sa.role_meaning="PATIENT"
    AND sa.active_ind=1
    AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND sa.state_meaning IN ("CONFIRMED", "SCHEDULED"))
   JOIN (se
   WHERE se.sch_event_id=sa.sch_event_id)
   JOIN (pn
   WHERE pn.person_id=sa.person_id
    AND pn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pn.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND pn.active_ind=1
    AND pn.name_type_cd=mf_current_name_cd)
   JOIN (cvo
   WHERE (cvo.code_value= Outerjoin(se.appt_type_cd))
    AND (cvo.contributor_source_cd= Outerjoin(mf_schedappt_cd)) )
   JOIN (ph
   WHERE ph.parent_entity_id=sa.person_id
    AND ph.parent_entity_name="PERSON"
    AND ph.phone_type_cd IN (mf_phone_home_cd)
    AND ph.phone_type_seq=1
    AND ph.active_ind=1
    AND ph.end_effective_dt_tm > sysdate)
   JOIN (sed
   WHERE (sed.sch_event_id= Outerjoin(se.sch_event_id))
    AND (sed.version_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
    AND (sed.active_ind= Outerjoin(1))
    AND (sed.oe_field_id= Outerjoin(mf_interplang_cd)) )
  ORDER BY sa.sch_event_id
  HEAD REPORT
   rem->cnt = 0
  HEAD sa.sch_event_id
   IF (size(trim(replace(replace(replace(trim(ph.phone_num,3),")",""),"(",""),"-",""),3)) > 0
    AND replace(replace(replace(trim(ph.phone_num,3),")",""),"(",""),"-","") != "0000000000")
    rem->cnt += 1, stat = alterlist(rem->qual,rem->cnt), rem->qual[rem->cnt].ms_first_name = trim(pn
     .name_first,3),
    rem->qual[rem->cnt].ms_last_name = trim(pn.name_last,3), rem->qual[rem->cnt].mf_department_number
     = sa.appt_location_cd, rem->qual[rem->cnt].mf_location_number = sa.appt_location_cd,
    rem->qual[rem->cnt].mf_sch_event_id = sa.sch_event_id, rem->qual[rem->cnt].ms_location_name =
    trim(uar_get_code_display(sa.appt_location_cd),3), rem->qual[rem->cnt].ms_provider_number = "542",
    rem->qual[rem->cnt].ms_appt_dt_tm = trim(format(sa.beg_dt_tm,"YYYY-MM-DD HH:MM ;;q"),3), rem->
    qual[rem->cnt].ms_visit_type = trim(uar_get_code_display(se.appt_type_cd),3), rem->qual[rem->cnt]
    .ms_visit_type_sch_alias = trim(cvo.alias,3),
    rem->qual[rem->cnt].ms_phone_num = replace(replace(replace(trim(ph.phone_num,3),")",""),"(",""),
     "-","")
    IF (sed.oe_field_display_value="Spanish")
     rem->qual[rem->cnt].ms_lang = "Spanish"
    ELSE
     rem->qual[rem->cnt].ms_lang = "English"
    ENDIF
    rem->qual[rem->cnt].f_person_id = sa.person_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM sch_appt sa,
   person_name pn,
   sch_event se,
   code_value_outbound cvo,
   phone ph,
   sch_event_detail sed
  PLAN (sa
   WHERE sa.appt_location_cd=mf_paecsc_cd
    AND  NOT (expand(ml_idx2,1,rem->cnt,sa.person_id,rem->qual[ml_idx2].f_person_id))
    AND sa.beg_dt_tm >= cnvtdatetime(mf_start_date)
    AND sa.beg_dt_tm <= cnvtdatetime(mf_stop_date)
    AND sa.role_meaning="PATIENT"
    AND sa.active_ind=1
    AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND sa.state_meaning IN ("CONFIRMED", "SCHEDULED"))
   JOIN (se
   WHERE se.sch_event_id=sa.sch_event_id)
   JOIN (pn
   WHERE pn.person_id=sa.person_id
    AND pn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pn.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND pn.active_ind=1
    AND pn.name_type_cd=mf_current_name_cd)
   JOIN (cvo
   WHERE (cvo.code_value= Outerjoin(se.appt_type_cd))
    AND (cvo.contributor_source_cd= Outerjoin(mf_schedappt_cd)) )
   JOIN (ph
   WHERE ph.parent_entity_id=sa.person_id
    AND ph.parent_entity_name="PERSON"
    AND ph.phone_type_cd IN (mf_cs43_cell_cd)
    AND ph.phone_type_seq=1
    AND ph.active_ind=1
    AND ph.end_effective_dt_tm > sysdate)
   JOIN (sed
   WHERE (sed.sch_event_id= Outerjoin(se.sch_event_id))
    AND (sed.version_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
    AND (sed.active_ind= Outerjoin(1))
    AND (sed.oe_field_id= Outerjoin(mf_interplang_cd)) )
  ORDER BY sa.sch_event_id
  HEAD sa.sch_event_id
   IF (size(trim(replace(replace(replace(trim(ph.phone_num,3),")",""),"(",""),"-",""),3)) > 0
    AND replace(replace(replace(trim(ph.phone_num,3),")",""),"(",""),"-","") != "0000000000")
    rem->cnt += 1, stat = alterlist(rem->qual,rem->cnt), rem->qual[rem->cnt].ms_first_name = trim(pn
     .name_first,3),
    rem->qual[rem->cnt].ms_last_name = trim(pn.name_last,3), rem->qual[rem->cnt].mf_department_number
     = sa.appt_location_cd, rem->qual[rem->cnt].mf_location_number = sa.appt_location_cd,
    rem->qual[rem->cnt].mf_sch_event_id = sa.sch_event_id, rem->qual[rem->cnt].ms_location_name =
    trim(uar_get_code_display(sa.appt_location_cd),3), rem->qual[rem->cnt].ms_provider_number = "542",
    rem->qual[rem->cnt].ms_appt_dt_tm = trim(format(sa.beg_dt_tm,"YYYY-MM-DD HH:MM ;;q"),3), rem->
    qual[rem->cnt].ms_visit_type = trim(uar_get_code_display(se.appt_type_cd),3), rem->qual[rem->cnt]
    .ms_visit_type_sch_alias = trim(cvo.alias,3),
    rem->qual[rem->cnt].ms_phone_num = replace(replace(replace(trim(ph.phone_num,3),")",""),"(",""),
     "-","")
    IF (sed.oe_field_display_value="Spanish")
     rem->qual[rem->cnt].ms_lang = "Spanish"
    ELSE
     rem->qual[rem->cnt].ms_lang = "English"
    ENDIF
    rem->qual[rem->cnt].f_person_id = sa.person_id
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF ((rem->cnt > 0))
  SELECT INTO value(ms_file)
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    FOR (ml_idx = 1 TO rem->cnt)
      ms_str = concat(rem->qual[ml_idx].ms_phone_num,"|",rem->qual[ml_idx].ms_lang,"|",trim(
        cnvtstring(rem->qual[ml_idx].mf_sch_event_id,20),3),
       "|",rem->qual[ml_idx].ms_first_name,"|",rem->qual[ml_idx].ms_last_name,"|",
       rem->qual[ml_idx].ms_location_name,"|",trim(cnvtstring(rem->qual[ml_idx].mf_location_number,20
         ),3),"|","|",
       "|","|","|",rem->qual[ml_idx].ms_provider_number,"|",
       "|",rem->qual[ml_idx].ms_appt_dt_tm,"|",rem->qual[ml_idx].ms_visit_type,"|",
       rem->qual[ml_idx].ms_visit_type_sch_alias,"|","|","|",trim(cnvtstring(rem->qual[ml_idx].
         mf_department_number,20),3),
       "|","|","|","|","|",
       "|","|","|","|","|",
       "|","|","|","|","|",
       "|","|"),
      CALL print(ms_str), row + 1
    ENDFOR
   WITH nocounter, maxcol = 200, format,
    noheading
  ;end select
  SET ms_dclcom = concat(
   "$cust_script/bhs_sftp_file.ksh ciscoreftp@transfer.baystatehealth.org:/reminders"," ",ms_file)
  CALL echo(ms_dclcom)
  CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
  SET ms_dclcom = concat("cp ",ms_file," ",trim(logical("BHSCUST"),3),"/surginet/reminder/",
   ms_file)
  CALL echo(ms_dclcom)
  CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 ENDIF
#exit_script
END GO

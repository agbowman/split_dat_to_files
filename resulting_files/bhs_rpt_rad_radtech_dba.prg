CREATE PROGRAM bhs_rpt_rad_radtech:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Appt Start Date:" = "CURDATE",
  "Appt End Date:" = "CURDATE",
  "Appointment Location:" = 0
  WITH outdev, ms_start_date, ms_end_date,
  mf_appt_loc
 DECLARE mf_begin_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_START_DATE,
    "DD-MMM-YYYY"),0))
 DECLARE mf_end_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_END_DATE,"DD-MMM-YYYY"),
   235959))
 DECLARE mf_ea_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_ea_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 FREE RECORD s_data
 RECORD s_data(
   1 l_cnt = i4
   1 qual[*]
     2 f_sch_event_id = f8
     2 f_appt_id = f8
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 f_appt_date = f8
     2 f_pat_dob = f8
     2 s_appt_status = vc
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_appt_type = vc
     2 s_appt_loc = vc
     2 s_rad_name = vc
     2 s_tech_name = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM sch_appt sa,
   sch_event se,
   encntr_alias ea1,
   encntr_alias ea2,
   person p,
   sch_event_detail sed,
   oe_format_fields off
  PLAN (sa
   WHERE (sa.appt_location_cd= $MF_APPT_LOC)
    AND sa.beg_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND sa.role_meaning="PATIENT"
    AND sa.state_meaning IN ("CONFIRMED", "CHECKED IN", "CHECKED OUT", "SCHEDULED", "PENDING")
    AND sa.sch_event_id != 0
    AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND sa.active_ind=1)
   JOIN (se
   WHERE se.sch_event_id=sa.sch_event_id)
   JOIN (ea1
   WHERE (ea1.encntr_id= Outerjoin(sa.encntr_id))
    AND (ea1.encntr_alias_type_cd= Outerjoin(mf_ea_mrn_cd))
    AND (ea1.active_ind= Outerjoin(1))
    AND (ea1.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(sa.encntr_id))
    AND (ea2.encntr_alias_type_cd= Outerjoin(mf_ea_fin_cd))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   JOIN (p
   WHERE p.person_id=sa.person_id)
   JOIN (sed
   WHERE sed.sch_event_id=se.sch_event_id
    AND sed.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (off
   WHERE off.oe_field_id=sed.oe_field_id
    AND off.label_text IN ("Preferred Radiologist", "Preferred Tech"))
  ORDER BY sa.beg_dt_tm, sa.sch_event_id
  HEAD REPORT
   s_data->l_cnt = 0
  HEAD sa.sch_event_id
   s_data->l_cnt += 1, stat = alterlist(s_data->qual,s_data->l_cnt), s_data->qual[s_data->l_cnt].
   f_appt_id = sa.sch_appt_id,
   s_data->qual[s_data->l_cnt].f_encntr_id = sa.encntr_id, s_data->qual[s_data->l_cnt].f_person_id =
   sa.person_id, s_data->qual[s_data->l_cnt].f_pat_dob = cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p
     .birth_tz),1),
   s_data->qual[s_data->l_cnt].f_sch_event_id = sa.sch_event_id, s_data->qual[s_data->l_cnt].
   s_appt_loc = uar_get_code_display(sa.appt_location_cd), s_data->qual[s_data->l_cnt].s_appt_type =
   uar_get_code_display(se.appt_type_cd),
   s_data->qual[s_data->l_cnt].s_fin = trim(ea2.alias,3), s_data->qual[s_data->l_cnt].s_mrn = trim(
    ea1.alias,3), s_data->qual[s_data->l_cnt].s_appt_status = uar_get_code_display(se.sch_state_cd),
   s_data->qual[s_data->l_cnt].s_pat_name = p.name_full_formatted, s_data->qual[s_data->l_cnt].
   f_appt_date = sa.beg_dt_tm
  DETAIL
   IF (off.label_text="Preferred Radiologist")
    s_data->qual[s_data->l_cnt].s_rad_name = sed.oe_field_display_value
   ENDIF
   IF (off.label_text="Preferred Tech")
    s_data->qual[s_data->l_cnt].s_tech_name = sed.oe_field_display_value
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(s_data)
 IF ((s_data->l_cnt > 0))
  SELECT INTO  $OUTDEV
   patient_name = trim(substring(1,100,s_data->qual[d.seq].s_pat_name)), dob = format(cnvtdatetime(
     s_data->qual[d.seq].f_pat_dob),"MM/DD/YYYY;;q"), appt_loc = trim(substring(1,100,s_data->qual[d
     .seq].s_appt_loc)),
   appt_date = format(cnvtdatetime(s_data->qual[d.seq].f_appt_date),"MM/DD/YYYY hh:mm:ss;;d"),
   appt_type = trim(substring(1,100,s_data->qual[d.seq].s_appt_type)), pref_radiologist = trim(
    substring(1,100,s_data->qual[d.seq].s_rad_name)),
   pref_tech = trim(substring(1,100,s_data->qual[d.seq].s_tech_name))
   FROM (dummyt d  WITH seq = s_data->l_cnt)
   PLAN (d
    WHERE d.seq > 0)
   WITH nocounter, maxcol = 20000, format,
    separator = " ", memsort
  ;end select
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Report finished successfully. No appointments qualified.", col 0,
    "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08
  ;end select
 ENDIF
#exit_script
END GO

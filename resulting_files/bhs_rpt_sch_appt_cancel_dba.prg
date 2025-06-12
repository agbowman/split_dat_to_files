CREATE PROGRAM bhs_rpt_sch_appt_cancel:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Appointment Location:" = 0,
  "Auto-Cancel Only:" = "0"
  WITH outdev, ms_start_dt, ms_end_dt,
  mf_appt_loc, ms_auto_cancel
 DECLARE ms_parse_reason_str = vc WITH protect, noconstant("")
 DECLARE mf_begin_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_START_DT,
    "DD-MMM-YYYY"),0))
 DECLARE mf_end_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_END_DT,"DD-MMM-YYYY"),
   235959))
 DECLARE mf_app_canceled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14233,"CANCELED"))
 DECLARE mf_patient_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14250,"PATIENT"))
 DECLARE mf_action_cancel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14232,"CANCEL"))
 DECLARE mf_ea_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_autocanceled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14229,
   "AUTOCANCELED"))
 IF (( $MS_AUTO_CANCEL="1"))
  SET ms_parse_reason_str = concat(" sea.sch_reason_cd = ",cnvtstring(mf_autocanceled_cd,20))
 ELSE
  SET ms_parse_reason_str = " 1 = 1 "
 ENDIF
 SELECT DISTINCT INTO  $OUTDEV
  appt_date = sa.beg_dt_tm"@SHORTDATETIME", fin_number = substring(1,30,ea.alias), patient_name = per
  .name_full_formatted,
  patient_dob = format(cnvtdatetimeutc(datetimezone(per.birth_dt_tm,per.birth_tz),1),"MM/DD/YYYY;;q"),
  appt_location = uar_get_code_display(sa.appt_location_cd), appt_type = uar_get_code_display(se
   .appt_type_cd),
  action_date = sea.perform_dt_tm"@SHORTDATETIME", cancel_reason = uar_get_code_display(sea
   .sch_reason_cd), prsnl_name = pr.name_full_formatted
  FROM sch_appt sa,
   sch_event se,
   sch_event_action sea,
   encntr_alias ea,
   person per,
   prsnl pr
  PLAN (sa
   WHERE sa.beg_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND (sa.appt_location_cd= $MF_APPT_LOC)
    AND sa.sch_role_cd=mf_patient_cd
    AND sa.role_meaning="PATIENT")
   JOIN (se
   WHERE sa.sch_event_id=se.sch_event_id
    AND se.sch_state_cd=mf_app_canceled_cd
    AND se.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (sea
   WHERE sea.sch_event_id=sa.sch_event_id
    AND sea.sch_action_cd=mf_action_cancel_cd
    AND parser(ms_parse_reason_str))
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(sa.encntr_id))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_ea_fin_cd)) )
   JOIN (per
   WHERE per.person_id=sa.person_id)
   JOIN (pr
   WHERE (pr.person_id= Outerjoin(sea.action_prsnl_id)) )
  ORDER BY appt_location, appt_date, patient_name
  WITH nocounter, separator = " ", format
 ;end select
END GO

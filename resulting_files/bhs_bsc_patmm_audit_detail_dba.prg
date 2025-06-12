CREATE PROGRAM bhs_bsc_patmm_audit_detail:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Starting date(dd-mmm-yyyy)" = "CURDATE",
  "Ending date(dd-mmm-yyyy):" = "CURDATE",
  "Facility:" = 673936.00,
  "Nurse unit(s):" = value(*),
  "Display per:" = 2,
  "Email:" = ""
  WITH outdev, ms_start_date, ms_end_date,
  mf_facility, mf_nurse_unit, ml_display_type,
  ms_email
 FREE RECORD audit_request
 RECORD audit_request(
   1 unit_cnt = i4
   1 unit[*]
     2 nurse_unit_cd = f8
 ) WITH protect
 EXECUTE bhs_sys_stand_subroutine
 DECLARE mn_display_ind = i4 WITH protect, constant( $ML_DISPLAY_TYPE)
 DECLARE mf_fac_cd = f8 WITH protect, constant( $MF_FACILITY)
 DECLARE ms_start_dt_tm = vc WITH protect, constant(concat(trim( $MS_START_DATE)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $MS_END_DATE)," 23:59:59"))
 DECLARE ms_dashline = vc WITH protect, constant(fillstring(131,"-"))
 DECLARE ms_totalline = vc WITH protect, constant(fillstring(130,"-"))
 DECLARE ms_emails = vc WITH protect, constant(trim( $MS_EMAIL))
 DECLARE ms_filename = vc WITH protect, constant(concat("pcapm_",format(cnvtdatetime(curdate,curtime),
    "MM_DD_YY_HH_MM;;D"),".csv"))
 DECLARE mf_patmismatch = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,"PATMISMATCH"))
 DECLARE mf_cmrn = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_facility_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE mf_building_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"BUILDING"))
 DECLARE mf_nurseunit_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"NURSEUNIT"))
 DECLARE mf_ambulatory_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"AMBULATORY"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE ms_output = vc WITH protect, noconstant(trim( $OUTDEV))
 DECLARE ms_expected_name = vc WITH protect, noconstant("")
 DECLARE ms_identified_name = vc WITH protect, noconstant("")
 DECLARE ms_alert = vc WITH protect, noconstant("")
 DECLARE ms_username = vc WITH protect, noconstant("")
 DECLARE ms_position = vc WITH protect, noconstant("")
 DECLARE ms_nurse_unit = vc WITH protect, noconstant("")
 DECLARE ms_expected_mrn = vc WITH protect, noconstant("")
 DECLARE ms_identified_mrn = vc WITH protect, noconstant("")
 DECLARE ms_alert_time = vc WITH protect, noconstant("")
 DECLARE ms_med_name = vc WITH protect, noconstant("")
 DECLARE ms_display = vc WITH protect, noconstant("")
 DECLARE ms_status = vc WITH protect, noconstant("")
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_expand = i4 WITH protect, noconstant(0)
 DECLARE ml_total_alert = i4 WITH protect, noconstant(0)
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE mn_any_ind = i2 WITH protect, noconstant(0)
 IF (((trim( $MS_START_DATE)="") OR (trim( $MS_END_DATE)="")) )
  SET ms_status = "ERROR"
  SET ms_error = "Begin Date and End Date are required."
  GO TO exit_script
 ELSEIF (cnvtdatetime(ms_start_dt_tm) > cnvtdatetime(ms_end_dt_tm))
  SET ms_status = "ERROR"
  SET ms_error = "Begin Date must be less than End Date."
  GO TO exit_script
 ENDIF
 IF (size(ms_emails,3) > 0)
  IF (mn_display_ind != 3)
   SET ms_status = "ERROR"
   SET ms_error = concat(ms_error,'Only "CSV" display type supports email function.',
    'Please delete email or choose "CSV" display type.')
   GO TO exit_script
  ENDIF
  IF (findstring("@",ms_emails) > 0)
   SET mn_email_ind = 1
   SET ms_output = ms_filename
  ELSE
   SET ms_status = "ERROR"
   SET ms_error = concat(ms_error,
    'Invalid email recipients list. Email should contain at least one "@" character.')
   GO TO exit_script
  ENDIF
 ENDIF
 IF (mn_display_ind=3
  AND mn_email_ind != 1)
  SET ms_status = "ERROR"
  SET ms_error = concat(ms_error,"CSV display type requires an email. Please enter an email.")
  GO TO exit_script
 ENDIF
 IF (substring(1,1,reflect(parameter(5,0)))="C")
  SET mn_any_ind = 1
 ENDIF
 IF (mn_any_ind=1)
  SELECT INTO "nl:"
   FROM location l1,
    location_group lg1,
    location l2,
    location_group lg2,
    location l3,
    code_value cv
   PLAN (l1
    WHERE l1.location_type_cd=mf_facility_cd
     AND l1.location_cd=mf_fac_cd
     AND l1.active_ind=1
     AND l1.active_status_cd=mf_active_cd
     AND l1.data_status_cd=mf_auth_cd)
    JOIN (lg1
    WHERE lg1.parent_loc_cd=l1.location_cd
     AND lg1.root_loc_cd=0
     AND lg1.active_ind=1
     AND lg1.active_status_cd=mf_active_cd)
    JOIN (l2
    WHERE l2.location_cd=lg1.child_loc_cd
     AND l2.location_type_cd=mf_building_cd
     AND l2.active_ind=1
     AND l2.active_status_cd=mf_active_cd
     AND l2.data_status_cd=mf_auth_cd)
    JOIN (lg2
    WHERE lg2.parent_loc_cd=l2.location_cd
     AND lg2.root_loc_cd=0
     AND lg2.active_ind=1
     AND lg2.active_status_cd=mf_active_cd)
    JOIN (l3
    WHERE l3.location_cd=lg2.child_loc_cd
     AND l3.location_type_cd IN (mf_nurseunit_cd, mf_ambulatory_cd)
     AND l3.active_ind=1
     AND l3.active_status_cd=mf_active_cd
     AND l3.data_status_cd=mf_auth_cd)
    JOIN (cv
    WHERE cv.code_value=l3.location_cd
     AND cv.code_set=220
     AND cv.data_status_cd=mf_auth_cd
     AND cv.active_ind=1)
   ORDER BY cv.display_key
   HEAD REPORT
    ml_cnt = 0
   DETAIL
    ml_cnt = (ml_cnt+ 1)
    IF (mod(ml_cnt,10)=1)
     CALL alterlist(audit_request->unit,(ml_cnt+ 9))
    ENDIF
    audit_request->unit[ml_cnt].nurse_unit_cd = cv.code_value
   FOOT REPORT
    CALL alterlist(audit_request->unit,ml_cnt), audit_request->unit_cnt = ml_cnt
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE (cv.code_value= $MF_NURSE_UNIT)
     AND cv.code_set=220
     AND cv.data_status_cd=mf_auth_cd
     AND cv.active_ind=1)
   ORDER BY cv.display
   HEAD REPORT
    ml_cnt = 0
   DETAIL
    ml_cnt = (ml_cnt+ 1)
    IF (mod(ml_cnt,10)=1)
     CALL alterlist(audit_request->unit,(ml_cnt+ 9))
    ENDIF
    audit_request->unit[ml_cnt].nurse_unit_cd = cv.code_value
   FOOT REPORT
    CALL alterlist(audit_request->unit,ml_cnt), audit_request->unit_cnt = ml_cnt
   WITH nocounter
  ;end select
 ENDIF
 IF (mn_display_ind IN (0, 1, 2))
  SELECT
   IF (mn_display_ind=2)
    ORDER BY pers1.name_last_key, pers1.name_first_key, pers1.person_id,
     cnvtdatetime(maa.event_dt_tm), maa.prsnl_id
   ELSEIF (mn_display_ind=0)
    ORDER BY p.name_last_key, p.name_first_key, p.person_id,
     cnvtdatetime(maa.event_dt_tm), maa.prsnl_id
   ELSEIF (mn_display_ind=1)
    ORDER BY cnvtdatetime(maa.event_dt_tm), maa.prsnl_id
   ELSE
   ENDIF
   INTO value(ms_output)
   FROM med_admin_alert maa,
    med_admin_pt_error mape,
    prsnl p,
    person pers1,
    person pers2,
    person_alias pa,
    person_alias pa1,
    dummyt d,
    dummyt d1
   PLAN (maa
    WHERE maa.alert_type_cd=mf_patmismatch
     AND maa.event_dt_tm BETWEEN cnvtdatetime(ms_start_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
     AND maa.nurse_unit_cd > 0.00
     AND expand(ml_expand,1,size(audit_request->unit,5),maa.nurse_unit_cd,audit_request->unit[
     ml_expand].nurse_unit_cd))
    JOIN (p
    WHERE p.person_id=maa.prsnl_id)
    JOIN (mape
    WHERE mape.med_admin_alert_id=maa.med_admin_alert_id)
    JOIN (pers1
    WHERE pers1.person_id=mape.expected_pt_id)
    JOIN (pa
    WHERE pa.person_id=pers1.person_id
     AND pa.person_alias_type_cd=mf_cmrn)
    JOIN (pers2
    WHERE pers2.person_id=mape.identified_pt_id)
    JOIN (pa1
    WHERE pa1.person_id=pers2.person_id
     AND pa1.person_alias_type_cd=mf_cmrn)
    JOIN (d1)
    JOIN (d)
   HEAD REPORT
    ml_total_alert = 0, col + 0
   HEAD PAGE
    IF (ms_output != "MINE")
     col 00, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
    ENDIF
    col 00, "Date Range: ", ms_display = concat(ms_start_dt_tm," - ",ms_end_dt_tm),
    col 12, ms_display, col 122,
    "Page: ", curpage"###", row + 1,
    ms_display = concat("Facility: ",trim(uar_get_code_display(mf_fac_cd),3)), col 00, ms_display,
    col 96, "Run Date: ", curdate"MM/DD/YYYY;;D",
    " Time: ", curtime"HH:MM;;S", row + 1,
    ms_display = ""
    IF (mn_any_ind=1)
     ms_display = "Nurse Units: All"
    ELSEIF ((audit_request->unit_cnt > 1))
     ms_display = concat("Nurse Units: ",trim(uar_get_code_display(audit_request->unit[1].
        nurse_unit_cd),3))
     FOR (ml_cnt = 2 TO audit_request->unit_cnt)
       ms_display = concat(ms_display,", ",trim(uar_get_code_display(audit_request->unit[ml_cnt].
          nurse_unit_cd),3))
     ENDFOR
    ELSEIF ((audit_request->unit_cnt=1))
     ms_display = concat("Nurse Unit: ",trim(uar_get_code_display(audit_request->unit[1].
        nurse_unit_cd),3))
    ELSE
     ms_display = "Nurse Unit:"
    ENDIF
    IF (size(ms_display,3) > 130)
     ms_display = build2(substring(1,126,ms_display)," ...")
    ENDIF
    col 00, ms_display
    IF (mn_any_ind=0
     AND (audit_request->unit_cnt > 1))
     row + 1
    ENDIF
    CALL center("Point of Care Audit Patient Mismatch Report",1,131)
    IF (mn_display_ind=2)
     col 102, "Display per: Expected Patient", row + 1,
     col 00, ms_dashline, row + 1,
     col 00, "Legend", col 07,
     "(Pos = Position)", row + 1, col 00,
     "Alert", col 15, "Expected",
     col 36, "Expected", col 52,
     "Nurse", col 68, "Identified",
     col 89, "Identified", col 105,
     "User", row + 1, col 00,
     "date/time", col 15, "Patient Name",
     col 36, "MRN", col 52,
     "Unit", col 68, "Patient Name",
     col 89, "MRN", col 105,
     "Name", col 125, "Pos",
     row + 1
    ELSEIF (mn_display_ind=0)
     col 114, "Display per: User", row + 1,
     col 00, ms_dashline, row + 1,
     col 00, "Legend", col 07,
     "(Pos = Position)", row + 1, col 00,
     "User", col 20, "Alert",
     col 35, "Expected", col 56,
     "Expected", col 72, "Nurse",
     col 88, "Identified", col 109,
     "Identified", row + 1, col 00,
     "Name", col 20, "date/time",
     col 35, "Patient Name", col 56,
     "MRN", col 72, "Unit",
     col 88, "Patient Name", col 109,
     "MRN", col 125, "Pos",
     row + 1
    ELSEIF (mn_display_ind=1)
     col 109, "Display per: Date/Time", row + 1,
     col 00, ms_dashline, row + 1,
     col 00, "Legend", col 07,
     "(Pos = Position)", row + 1, col 00,
     "Alert", col 15, "Expected",
     col 36, "Expected", col 52,
     "Nurse", col 68, "Identified",
     col 89, "Identified", col 105,
     "User", row + 1, col 00,
     "date/time", col 15, "Patient Name",
     col 36, "MRN", col 52,
     "Unit", col 68, "Patient Name",
     col 89, "MRN", col 105,
     "Name", col 125, "Pos",
     row + 1
    ENDIF
    col 00, ms_totalline, row + 1
   HEAD mape.med_admin_pt_error_id
    col + 0
   DETAIL
    x = 0
   FOOT  mape.med_admin_pt_error_id
    IF (row=42)
     BREAK
    ENDIF
    ms_expected_name = "", ms_identified_name = "", ms_alert = "",
    ms_username = "", ms_position = "", ms_nurse_unit = "",
    ms_expected_mrn = "", ms_identified_mrn = "", ml_total_alert = (ml_total_alert+ 1),
    ms_alert = trim(uar_get_code_display(maa.alert_type_cd)), ms_alert_time = format(maa.event_dt_tm,
     "mm/dd/yy hh:mm"), ms_expected_name = trim(replace(pers1.name_full_formatted,","," -",0),3),
    ms_identified_name = trim(replace(pers2.name_full_formatted,","," -",0),3), ms_username = trim(
     replace(p.name_full_formatted,","," -",0),3), ms_position = trim(uar_get_code_display(maa
      .position_cd)),
    ms_nurse_unit = trim(replace(uar_get_code_display(maa.nurse_unit_cd),","," ",0),3),
    ms_expected_mrn = trim(cnvtalias(pa.alias,pa.alias_pool_cd)), ms_identified_mrn = trim(cnvtalias(
      pa1.alias,pa1.alias_pool_cd))
    IF (mn_display_ind=2)
     ms_display = substring(1,14,ms_alert_time), col 00, ms_display,
     ms_display = substring(1,20,ms_expected_name), col 15, ms_display,
     ms_display = substring(1,15,ms_expected_mrn), col 36, ms_display,
     ms_display = substring(1,15,ms_nurse_unit), col 52, ms_display,
     ms_display = substring(1,20,ms_identified_name), col 68, ms_display,
     ms_display = substring(1,15,ms_identified_mrn), col 89, ms_display,
     ms_display = substring(1,19,ms_username), col 105, ms_display,
     ms_display = substring(1,5,ms_position), col 125, ms_display
    ELSEIF (mn_display_ind=0)
     ms_display = substring(1,19,ms_username), col 00, ms_display,
     ms_display = substring(1,14,ms_alert_time), col 20, ms_display,
     ms_display = substring(1,20,ms_expected_name), col 35, ms_display,
     ms_display = substring(1,15,ms_expected_mrn), col 56, ms_display,
     ms_display = substring(1,15,ms_nurse_unit), col 72, ms_display,
     ms_display = substring(1,20,ms_identified_name), col 88, ms_display,
     ms_display = substring(1,15,ms_identified_mrn), col 109, ms_display,
     ms_display = substring(1,5,ms_position), col 125, ms_display
    ELSEIF (mn_display_ind=1)
     ms_display = substring(1,14,ms_alert_time), col 00, ms_display,
     ms_display = substring(1,20,ms_expected_name), col 15, ms_display,
     ms_display = substring(1,15,ms_expected_mrn), col 36, ms_display,
     ms_display = substring(1,15,ms_nurse_unit), col 52, ms_display,
     ms_display = substring(1,20,ms_identified_name), col 68, ms_display,
     ms_display = substring(1,15,ms_identified_mrn), col 89, ms_display,
     ms_display = substring(1,19,ms_username), col 105, ms_display,
     ms_display = substring(1,5,ms_position), col 125, ms_display
    ENDIF
    row + 1
   FOOT PAGE
    col 0, "Page:", col + 2,
    curpage
   FOOT REPORT
    row + 1, col 00, "Total Alerts: ",
    col + 2, ml_total_alert, row + 1
   WITH nocounter, outerjoin = d, outerjoin = d1,
    dio = postscript, maxrow = 45, expand = 1
  ;end select
 ELSEIF (mn_display_ind=3)
  SELECT INTO value(ms_output)
   FROM med_admin_alert maa,
    med_admin_pt_error mape,
    prsnl p,
    med_admin_event mae,
    orders o,
    person pers1,
    person pers2,
    person_alias pa,
    person_alias pa1,
    org_alias_pool_reltn oap,
    location l,
    dummyt d,
    dummyt d1
   PLAN (maa
    WHERE maa.alert_type_cd=mf_patmismatch
     AND maa.event_dt_tm BETWEEN cnvtdatetime(ms_start_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
     AND maa.nurse_unit_cd > 0.00
     AND expand(ml_expand,1,size(audit_request->unit,5),maa.nurse_unit_cd,audit_request->unit[
     ml_expand].nurse_unit_cd))
    JOIN (l
    WHERE l.location_cd=maa.nurse_unit_cd)
    JOIN (oap
    WHERE oap.organization_id=l.organization_id
     AND oap.alias_entity_name="PERSON_ALIAS"
     AND oap.alias_entity_alias_type_cd=mf_cmrn)
    JOIN (p
    WHERE p.person_id=maa.prsnl_id)
    JOIN (mae
    WHERE mae.med_admin_event_id=outerjoin(maa.med_admin_event_id))
    JOIN (o
    WHERE o.order_id=outerjoin(mae.order_id))
    JOIN (mape
    WHERE mape.med_admin_alert_id=maa.med_admin_alert_id)
    JOIN (pers1
    WHERE pers1.person_id=mape.expected_pt_id)
    JOIN (d1)
    JOIN (pa
    WHERE pa.person_id=pers1.person_id
     AND pa.person_alias_type_cd=mf_cmrn
     AND pa.alias_pool_cd=oap.alias_pool_cd
     AND pa.alias_pool_cd > 0.0)
    JOIN (pers2
    WHERE pers2.person_id=mape.identified_pt_id)
    JOIN (d)
    JOIN (pa1
    WHERE pa1.person_id=pers2.person_id
     AND pa1.person_alias_type_cd=mf_cmrn
     AND pa1.alias_pool_cd=oap.alias_pool_cd
     AND pa1.alias_pool_cd > 0.0)
   ORDER BY cnvtdatetime(maa.event_dt_tm), maa.prsnl_id, mape.med_admin_pt_error_id
   HEAD REPORT
    ml_total_alert = 0, "Alert,", "Alert date/time,",
    "Expected Patient Name,", "Expected MRN,", "Nurse Unit,",
    "Identified Patient Name,", "Identified MRN,", "User,",
    "Position,", "Med Name", row + 1
   HEAD mape.med_admin_pt_error_id
    ms_expected_mrn = "", ms_identified_mrn = ""
   DETAIL
    IF (pa.alias_pool_cd > 0.0)
     ms_expected_mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
    ENDIF
    IF (pa1.alias_pool_cd > 0.0)
     ms_identified_mrn = cnvtalias(pa1.alias,pa1.alias_pool_cd)
    ENDIF
   FOOT  mape.med_admin_pt_error_id
    ms_expected_name = "", ms_identified_name = "", ms_alert = "",
    ms_username = "", ms_position = "", ms_nurse_unit = "",
    ms_med_name = "", ml_total_alert = (ml_total_alert+ 1), ms_alert = trim(uar_get_code_display(maa
      .alert_type_cd)),
    ms_alert_time = format(maa.event_dt_tm,"mm/dd/yy hh:mm"), ms_expected_name = trim(replace(pers1
      .name_full_formatted,","," -",0),3), ms_identified_name = trim(replace(pers2
      .name_full_formatted,","," -",0),3),
    ms_username = trim(replace(p.name_full_formatted,","," -",0),3), ms_position = trim(
     uar_get_code_display(maa.position_cd)), ms_nurse_unit = trim(replace(uar_get_code_display(maa
       .nurse_unit_cd),","," ",0),3),
    ms_med_name = trim(o.order_mnemonic,3), ms_alert, ",",
    ms_alert_time, ",", ms_expected_name,
    ",", ms_expected_mrn, ",",
    ms_nurse_unit, ",", ms_identified_name,
    ",", ms_identified_mrn, ",",
    ms_username, ",", ms_position,
    ",", ms_med_name, row + 1
   FOOT REPORT
    row + 1, "Total Alerts: ", ml_total_alert,
    row + 1
   WITH nocounter, outerjoin = d, outerjoin = d1,
    maxcol = 200, expand = 1
  ;end select
 ENDIF
 IF (curqual=0)
  SET ms_status = "ERROR"
  SET ms_error = build2(ms_error,"No Data found for this date range: ",ms_start_dt_tm," - ",
   ms_end_dt_tm)
  GO TO exit_script
 ENDIF
 IF (mn_email_ind=1)
  CALL emailfile(ms_output,ms_output,ms_emails,build2("PCAPM Report - ",format(cnvtdatetime(curdate,
      curtime),"MM/DD/YY HH:MM:SS;;D")),1)
  SET ms_status = "SUCCESS - EMAIL"
  SET ms_error = concat(ms_error,"File has been emailed to: ",ms_emails)
  GO TO exit_script
 ENDIF
 IF (((ms_status != "ERROR") OR (ms_status != "SUCCESS - EMAIL")) )
  SET ms_status = "SUCCESS"
 ENDIF
#exit_script
 IF (ms_status != "SUCCESS")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    col 0, "{PS/792 0 translate 90 rotate/}", "{F/1}{CPI/7}",
    CALL print(calcpos(10,10)),
    "Point of Care Audit Patient Mismatch Report - BSC_PATMISMATCH_AUDIT_DETAIL", "{F/1}{CPI/10}",
    CALL print(calcpos(10,30)), ms_error
   WITH dio = postscript, maxrow = 300, maxcol = 300
  ;end select
 ENDIF
 FREE RECORD audit_request
END GO

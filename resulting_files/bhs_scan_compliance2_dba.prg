CREATE PROGRAM bhs_scan_compliance2:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Starting date(mm/dd/yyyy):" = "CURDATE",
  "Ending date(mm/dd/yyyy):" = "CURDATE",
  "Facility:" = 673936.00,
  "Nurse_unit(s):" = value(*)
  WITH outdev, ms_beg_dt, ms_end_dt,
  mf_facility, mf_nurse_unit
 FREE RECORD audit_request
 RECORD audit_request(
   1 report_name = vc
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 facility_cd = f8
   1 unit_cnt = i4
   1 display_ind = i2
   1 unit[*]
     2 nurse_unit_cd = f8
 ) WITH protect
 FREE RECORD aunit
 RECORD aunit(
   1 l_cnt = i4
   1 list[*]
     2 s_unit_display_key = vc
 ) WITH protect
 DECLARE mf_notgiven = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,"NOTGIVEN"))
 DECLARE mf_notdone = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,"NOTDONE"))
 DECLARE mf_notadministered = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,
   "TASKPURGED"))
 DECLARE mf_facility_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE mf_building_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"BUILDING"))
 DECLARE mf_nurseunit_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"NURSEUNIT"))
 DECLARE mf_ambulatory_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"AMBULATORY"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_dba_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,"DBA"))
 DECLARE ms_title = vc WITH protect, constant("Point of Care Audit Scan Compliance Report")
 DECLARE ms_dashline = vc WITH protect, constant(fillstring(131,"-"))
 DECLARE ms_total_line = vc WITH protect, constant(fillstring(130,"-"))
 DECLARE ms_nurse_unit = vc WITH protect, noconstant("")
 DECLARE ms_username = vc WITH protect, noconstant("")
 DECLARE ms_position = vc WITH protect, noconstant("")
 DECLARE ml_pospt_compliance_total = i4 WITH protect, noconstant(0)
 DECLARE ml_posmed_compliance_total = i4 WITH protect, noconstant(0)
 DECLARE ml_pt_compliance_totalevents = i4 WITH protect, noconstant(0)
 DECLARE ml_med_compliance_totalevents = i4 WITH protect, noconstant(0)
 DECLARE mf_compliance_pt_percent = f8 WITH protect, noconstant(0.0)
 DECLARE mf_compliance_med_percent = f8 WITH protect, noconstant(0.0)
 DECLARE ml_selected_pat = i4 WITH protect, noconstant(0)
 DECLARE ml_selected_med = i4 WITH protect, noconstant(0)
 DECLARE ml_pt_scanned = i4 WITH protect, noconstant(0)
 DECLARE ml_pt_selected = i4 WITH protect, noconstant(0)
 DECLARE mf_pt_percent = f8 WITH protect, noconstant(0.0)
 DECLARE ml_med_scanned = i4 WITH protect, noconstant(0)
 DECLARE ml_med_selected = i4 WITH protect, noconstant(0)
 DECLARE mf_med_percent = f8 WITH protect, noconstant(0.0)
 DECLARE ml_pt_total = i4 WITH protect, noconstant(0)
 DECLARE ml_med_total = i4 WITH protect, noconstant(0)
 DECLARE ml_pu_pt_scanned = i4 WITH protect, noconstant(0)
 DECLARE ml_pu_pt_selected = i4 WITH protect, noconstant(0)
 DECLARE mf_pu_pt_percent = f8 WITH protect, noconstant(0.0)
 DECLARE ml_pu_med_scanned = i4 WITH protect, noconstant(0)
 DECLARE ml_pu_med_selected = i4 WITH protect, noconstant(0)
 DECLARE mf_pu_med_percent = f8 WITH protect, noconstant(0.0)
 DECLARE ml_pu_pt_total = i4 WITH protect, noconstant(0)
 DECLARE ml_pu_med_total = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_expand_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_size = i4 WITH protect, noconstant(0)
 DECLARE ml_bucket_size = i4 WITH protect, noconstant(0)
 DECLARE ml_total = i4 WITH protect, noconstant(0)
 DECLARE ml_start = i4 WITH protect, noconstant(0)
 DECLARE ml_buckets = i4 WITH protect, noconstant(0)
 DECLARE mn_nall = i2 WITH protect, noconstant(0)
 DECLARE ms_display = vc WITH protect, noconstant("")
 DECLARE mc_any_status = c1 WITH protect, noconstant("")
 SET audit_request->report_name = "BSC_SCAN_COMPLIANCE_REPORT"
 SET audit_request->facility_cd =  $MF_FACILITY
 SET audit_request->start_dt_tm = cnvtdatetime(cnvtdate(cnvtalphanum( $MS_BEG_DT)),0)
 SET audit_request->end_dt_tm = cnvtdatetime(cnvtdate(cnvtalphanum( $MS_END_DT)),235959)
 SET mc_any_status = substring(1,1,reflect(parameter(5,0)))
 SELECT INTO "nl:"
  FROM dm_info au
  WHERE au.info_domain="BHS_AMBULATORY_UNIT"
  HEAD REPORT
   aunit->l_cnt = 0
  DETAIL
   aunit->l_cnt = (aunit->l_cnt+ 1), stat = alterlist(aunit->list,aunit->l_cnt), aunit->list[aunit->
   l_cnt].s_unit_display_key = au.info_name
  WITH nocounter
 ;end select
 IF (mc_any_status="C")
  SET mn_nall = 1
  SELECT INTO "nl:"
   FROM location l1,
    code_value cv,
    location_group lg1,
    location l2,
    location_group lg2,
    location l3,
    code_value cv1
   PLAN (l1
    WHERE l1.location_type_cd=mf_facility_cd
     AND l1.location_cd IN ( $MF_FACILITY)
     AND l1.active_ind=1
     AND l1.active_status_cd=mf_active_cd
     AND l1.data_status_cd=mf_auth_cd)
    JOIN (cv
    WHERE cv.code_value=l1.location_cd
     AND cv.active_ind=1
     AND cv.data_status_cd=mf_auth_cd)
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
    JOIN (cv1
    WHERE cv1.code_value=l3.location_cd
     AND cv1.data_status_cd=mf_auth_cd
     AND cv1.code_set=220
     AND cv1.active_ind=1
     AND ((cv1.cdf_meaning="NURSEUNIT") OR (cv1.cdf_meaning="AMBULATORY"
     AND expand(ml_expand_cnt,1,aunit->l_cnt,cv1.display_key,aunit->list[ml_expand_cnt].
     s_unit_display_key))) )
   HEAD REPORT
    ml_cnt = 0
   DETAIL
    ml_cnt = (ml_cnt+ 1)
    IF (mod(ml_cnt,10)=1)
     CALL alterlist(audit_request->unit,(ml_cnt+ 9))
    ENDIF
    audit_request->unit[ml_cnt].nurse_unit_cd = l3.location_cd
   FOOT REPORT
    CALL alterlist(audit_request->unit,ml_cnt), audit_request->unit_cnt = ml_cnt
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE (cv.code_value= $MF_NURSE_UNIT))
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
 SET ml_size = audit_request->unit_cnt
 SET ml_bucket_size = 20
 SET ml_total = (ceil((cnvtreal(ml_size)/ ml_bucket_size)) * ml_bucket_size)
 SET ml_start = 1
 SET ml_buckets = value((1+ ((ml_total - 1)/ ml_bucket_size)))
 CALL alterlist(audit_request->unit,ml_total)
 SET ml_cnt = 0
 FOR (ml_cnt = (ml_size+ 1) TO ml_total)
   SET audit_request->unit[ml_cnt].nurse_unit_cd = audit_request->unit[ml_size].nurse_unit_cd
 ENDFOR
 SELECT INTO  $OUTDEV
  FROM (dummyt d  WITH seq = ml_buckets),
   med_admin_event mae,
   prsnl p,
   clinical_event ce,
   encntr_loc_hist elh
  PLAN (d
   WHERE initarray(ml_start,evaluate(d.seq,1,1,(ml_start+ ml_bucket_size))))
   JOIN (mae
   WHERE mae.beg_dt_tm >= cnvtdatetime(audit_request->start_dt_tm)
    AND mae.end_dt_tm <= cnvtdatetime(audit_request->end_dt_tm)
    AND mae.event_type_cd > 0.00
    AND  NOT (mae.event_type_cd IN (mf_notadministered, mf_notgiven, mf_notdone))
    AND expand(ml_expand_cnt,ml_start,((ml_start+ ml_bucket_size) - 1),mae.nurse_unit_cd,
    audit_request->unit[ml_expand_cnt].nurse_unit_cd)
    AND mae.prsnl_id > 0.00)
   JOIN (ce
   WHERE ce.event_id=mae.event_id)
   JOIN (elh
   WHERE elh.encntr_id=ce.encntr_id
    AND elh.beg_effective_dt_tm <= mae.beg_dt_tm
    AND elh.end_effective_dt_tm >= mae.beg_dt_tm
    AND elh.loc_nurse_unit_cd=mae.nurse_unit_cd
    AND elh.active_ind=1)
   JOIN (p
   WHERE p.person_id=mae.prsnl_id
    AND p.position_cd != mf_dba_cd)
  ORDER BY p.name_full_formatted, mae.prsnl_id, uar_get_code_display(mae.nurse_unit_cd),
   mae.nurse_unit_cd
  HEAD REPORT
   ml_pospt_compliance_total = 0, ml_posmed_compliance_total = 0, ml_pt_compliance_totalevents = 0,
   ml_med_compliance_totalevents = 0, mf_compliance_pt_percent = 0.0, mf_compliance_med_percent = 0.0,
   ml_selected_pat = 0, ml_selected_med = 0
  HEAD PAGE
   IF (( $OUTDEV != "MINE"))
    col 0, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
   ENDIF
   col 0, "Date Range: ", ms_display = ""
   IF ((audit_request->start_dt_tm > 0))
    ms_display = format(audit_request->start_dt_tm,"mm/dd/yyyy;;d")
   ENDIF
   IF ((audit_request->end_dt_tm > 0))
    ms_display = build2(ms_display," - ",format(audit_request->end_dt_tm,"mm/dd/yyyy;;d"))
   ENDIF
   IF (textlen(ms_display) > 0)
    col 12, ms_display
   ENDIF
   col 122, "Page: ", curpage"###",
   row + 1, ms_display = concat("Facility: ",trim(uar_get_code_display( $MF_FACILITY),3)), col 0,
   ms_display, col 96, "Run Date: ",
   curdate"mm/dd/yyyy;;d", " Time: ", curtime"hh:mm;;s",
   row + 1, ms_display = ""
   IF (mn_nall=1)
    ms_display = "Nurse Units: All"
   ELSEIF ((audit_request->unit_cnt > 1))
    ms_display = concat("Nurse Units: ",trim(uar_get_code_display(audit_request->unit[1].
       nurse_unit_cd),3))
    FOR (ml_cnt = 2 TO audit_request->unit_cnt)
      ms_display = concat(ms_display,", ",trim(uar_get_code_display(audit_request->unit[ml_cnt].
         nurse_unit_cd),3))
    ENDFOR
   ELSEIF ((audit_request->unit_cnt=1))
    ms_display = concat("Nurse Unit: ",trim(uar_get_code_display(audit_request->unit[1].nurse_unit_cd
       ),3))
   ELSE
    ms_display = "Nurse Unit: Unknown/Error"
   ENDIF
   col 0, ms_display
   IF (mn_nall=0
    AND (audit_request->unit_cnt > 1))
    row + 1
   ENDIF
   CALL center(ms_title,1,131), col 109, "Display per: Date/Time",
   row + 1, col 00, ms_dashline,
   row + 1, col 00, "Legend",
   col 07, "(Pos = Position)", row + 1,
   col 00, "User", col 37,
   "Nurse", col 63, "Scan",
   col 74, "Select", col 85,
   "Patient", col 96, "Scan",
   col 107, "Select", col 118,
   "Med", row + 1, col 00,
   "Name", col 26, "Pos",
   col 37, "Unit", col 63,
   "Pts", col 74, "Pts",
   col 85, "Compl", col 96,
   "Meds", col 107, "Meds",
   col 118, "Compl", row + 1,
   col 00, ms_total_line, row + 1
  HEAD mae.prsnl_id
   ml_cnt = 0, ml_pu_pt_scanned = 0, ml_pu_pt_selected = 0,
   mf_pu_pt_percent = 0.0, ml_pu_med_scanned = 0, ml_pu_med_selected = 0,
   mf_pu_med_percent = 0.0, ml_pu_pt_total = 0, ml_pu_med_total = 0
  HEAD mae.nurse_unit_cd
   ml_cnt = (ml_cnt+ 1)
   IF (row > 41)
    BREAK
   ENDIF
   ml_pt_scanned = 0, ml_pt_selected = 0, mf_pt_percent = 0.0,
   ml_med_scanned = 0, ml_med_selected = 0, mf_med_percent = 0.0,
   ml_pt_total = 0, ml_med_total = 0, ms_nurse_unit = "",
   ms_position = ""
  HEAD mae.med_admin_event_id
   IF (row > 41)
    BREAK
   ENDIF
   IF (mae.event_id != 0)
    ml_med_total = (ml_med_total+ 1)
    IF (mae.positive_med_ident_ind=1)
     ml_med_scanned = (ml_med_scanned+ 1)
    ELSE
     ml_med_selected = (ml_med_selected+ 1)
    ENDIF
   ENDIF
   ml_pt_total = (ml_pt_total+ 1)
   IF (mae.positive_patient_ident_ind=1)
    ml_pt_scanned = (ml_pt_scanned+ 1)
   ELSE
    ml_pt_selected = (ml_pt_selected+ 1)
   ENDIF
  FOOT  mae.nurse_unit_cd
   ml_pu_pt_total = (ml_pt_total+ ml_pu_pt_total), ml_pu_med_total = (ml_med_total+ ml_pu_med_total),
   ml_pu_pt_scanned = (ml_pu_pt_scanned+ ml_pt_scanned),
   ml_pu_med_scanned = (ml_pu_med_scanned+ ml_med_scanned), ml_pu_pt_selected = (ml_pu_pt_selected+
   ml_pt_selected), ml_pu_med_selected = (ml_pu_med_selected+ ml_med_selected),
   ms_nurse_unit = trim(replace(uar_get_code_display(mae.nurse_unit_cd),","," ",0),3), ms_position =
   trim(replace(uar_get_code_display(mae.position_cd),","," ",0),3), mf_pt_percent = ((cnvtreal(
    ml_pt_scanned)/ cnvtreal(ml_pt_total)) * 100),
   mf_med_percent = ((cnvtreal(ml_med_scanned)/ cnvtreal(ml_med_total)) * 100), ms_username = trim(p
    .name_full_formatted,3), ms_display = substring(1,25,ms_username),
   col 00, ms_display, ms_display = substring(1,10,ms_position),
   col 26, ms_display, ms_display = substring(1,25,ms_nurse_unit),
   col 37, ms_display, ms_display = trim(build2(ml_pt_scanned),3),
   col 63, ms_display, ms_display = trim(build2(ml_pt_selected),3),
   col 74, ms_display, ms_display = trim(build2(mf_pt_percent,"%"),3),
   col 85, ms_display, ms_display = trim(build2(ml_med_scanned),3),
   col 96, ms_display, ms_display = trim(build2(ml_med_selected),3),
   col 107, ms_display, ms_display = trim(build2(mf_med_percent,"%"),3),
   col 118, ms_display, row + 1
  FOOT  mae.prsnl_id
   ml_pt_compliance_totalevents = (ml_pu_pt_total+ ml_pt_compliance_totalevents),
   ml_med_compliance_totalevents = (ml_pu_med_total+ ml_med_compliance_totalevents),
   ml_pospt_compliance_total = (ml_pospt_compliance_total+ ml_pu_pt_scanned),
   ml_posmed_compliance_total = (ml_posmed_compliance_total+ ml_pu_med_scanned), mf_pu_pt_percent = (
   (cnvtreal(ml_pu_pt_scanned)/ cnvtreal(ml_pu_pt_total)) * 100), mf_pu_med_percent = ((cnvtreal(
    ml_pu_med_scanned)/ cnvtreal(ml_pu_med_total)) * 100)
   IF (ml_cnt > 1)
    ms_display = substring(1,25,ms_username), col 00, ms_display,
    ms_display = substring(1,10,ms_position), col 26, ms_display,
    ms_display = "Total--------------------", col 37, ms_display,
    ms_display = trim(build2(ml_pu_pt_scanned),3), col 63, ms_display,
    ms_display = trim(build2(ml_pu_pt_selected),3), col 74, ms_display,
    ms_display = trim(build2(mf_pu_pt_percent,"%"),3), col 85, ms_display,
    ms_display = trim(build2(ml_pu_med_scanned),3), col 96, ms_display,
    ms_display = trim(build2(ml_pu_med_selected),3), col 107, ms_display,
    ms_display = trim(build2(mf_pu_med_percent,"%"),3), col 118, ms_display,
    row + 1
   ENDIF
  FOOT PAGE
   row 44, col 0, "Page:",
   col + 2, curpage
  FOOT REPORT
   mf_compliance_pt_percent = ((cnvtreal(ml_pospt_compliance_total)/ cnvtreal(
    ml_pt_compliance_totalevents)) * 100), mf_compliance_med_percent = ((cnvtreal(
    ml_posmed_compliance_total)/ cnvtreal(ml_med_compliance_totalevents)) * 100), ml_selected_pat = (
   ml_pt_compliance_totalevents - ml_pospt_compliance_total),
   ml_selected_med = (ml_med_compliance_totalevents - ml_posmed_compliance_total), row 43, col 00,
   "Totals/Averages:", ms_display = trim(build2(ml_pospt_compliance_total),3), col 63,
   ms_display, ms_display = trim(build2(ml_selected_pat),3), col 74,
   ms_display, ms_display = trim(build2(mf_compliance_pt_percent,"%"),3), col 85,
   ms_display, ms_display = trim(build2(ml_posmed_compliance_total),3), col 96,
   ms_display, ms_display = trim(build2(ml_selected_med),3), col 107,
   ms_display, ms_display = trim(build2(mf_compliance_med_percent,"%"),3), col 118,
   ms_display
  WITH nocounter, dio = postscript, maxrow = 45
 ;end select
 FREE RECORD audit_request
 SET last_mod = "011 12/18/17 ML012560 Modified prompts only - BWH and BMLH nurse unit lists"
END GO

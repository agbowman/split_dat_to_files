CREATE PROGRAM bhs_nrs_meds_recon_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Organization" = 0,
  "Select Nursing Unit /s" = 0,
  "Enter Start Date" = curdate,
  "Enter End Date" = curdate
  WITH outdev, org, nur,
  st_dt, en_dt
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET mrn_cd = uar_get_code_by("DISPLAYKEY",319,"MRN")
 SET fnbr_cd = uar_get_code_by("DISPLAYKEY",319,"FINNBR")
 SET attend_cd = uar_get_code_by("DISPLAYKEY",333,"ATTENDINGPHYSICIAN")
 SET activity_cd = uar_get_code_by("DISPLAYKEY",106,"RNTORN")
 SET catalog_cd = uar_get_code_by("DISPLAYKEY",200,"COMPLETEMEDRECONCILIATIONADMIT")
 SET catalog_type_cd = uar_get_code_by("DISPLAYKEY",6000,"PATIENTCARE")
 SET status_cd = uar_get_code_by("DISPLAYKEY",6004,"COMPLETED")
 SET status_cd2 = uar_get_code_by("DISPLAYKEY",6004,"ORDERED")
 SET daystay_cd = uar_get_code_by("DISPLAYKEY",71,"DAYSTAY")
 SET inpat_cd = uar_get_code_by("DISPLAYKEY",71,"INPATIENT")
 SET observation_cd = uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")
 SET auth_ver_cd = uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED")
 SET home_med_recon_cd = uar_get_code_by("DISPLAYKEY",72,"HOMEMEDICATIONREVIEW")
 SET complete_cd = uar_get_code_by("DISPLAYKEY",6004,"COMPLETED")
 SET perform_cd = uar_get_code_by("DISPLAYKEY",21,"PERFORM")
 SET st_dt = curdate
 SET en_dt = curdate
 SET c_lt_24 = 0
 SET c_mt_24 = 0
 SET not_c = 0
 SET all_c = 0.00
 SET all_c2 = 0
 SET comp = 0
 SET per_c_lt_24 = 0.00
 SET per_c_mt_24 = 0.00
 SET per_not_c = 0.00
 SET per_comp = 0.00
 DECLARE unknown_ind = vc
 SET org_name = fillstring(40," ")
 SELECT INTO "nl:"
  l.location_cd, org.org_name, l.organization_id,
  org.organization_id
  FROM location l,
   organization org
  PLAN (l
   WHERE (l.location_cd= $ORG))
   JOIN (org
   WHERE org.organization_id=l.organization_id)
  DETAIL
   org_name = trim(org.org_name)
  WITH nocounter
 ;end select
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT DISTINCT INTO  $OUTDEV
  fin = cnvtalias(ea.alias,ea.alias_pool_cd), nurse = trim(uar_get_code_display(e.loc_nurse_unit_cd)),
  admit_dt = e.reg_dt_tm"mm/dd/yy hh:mm;;d",
  complete_dt =
  IF (ce.verified_dt_tm > null) format(ce.verified_dt_tm,"mm/dd/yy hh:mm;;d")
  ELSE " "
  ENDIF
  , mrn = cnvtalias(ea1.alias,ea1.alias_pool_cd), name = trim(p.name_full_formatted),
  attend_dr = trim(p1.name_full_formatted), loc_dt2 = e.reg_dt_tm"mm/dd/yy hh:mm;;d", loc_dt = elh
  .updt_dt_tm"mm/dd/yy hh:mm;;d",
  loc = trim(uar_get_code_display(elh.loc_nurse_unit_cd)), signed_within_24 =
  IF (datetimediff(ce.verified_dt_tm,e.reg_dt_tm,3) <= 24
   AND ce.result_status_cd=auth_ver_cd
   AND ((ce.result_val="No*") OR (ce.result_val="Reviewed*")) ) "Y"
  ELSEIF (datetimediff(ce.verified_dt_tm,e.reg_dt_tm,3) <= 24
   AND ce.result_status_cd=auth_ver_cd
   AND ((ce.result_val="Other*") OR (ce.result_val="Unknown*")) ) "N"
  ELSEIF (datetimediff(ce.verified_dt_tm,e.reg_dt_tm,3) > 24
   AND ce.result_status_cd=auth_ver_cd) "N"
  ELSE " "
  ENDIF
  , complete_dt = ce.verified_dt_tm"@SHORTDATETIME",
  status =
  IF (ce.verified_dt_tm > null) "completed"
  ELSE "not completed"
  ENDIF
  , e.encntr_id, ce.verified_dt_tm
  FROM encntr_domain ed,
   dummyt d1,
   encounter e,
   encntr_loc_hist elh,
   encntr_alias ea,
   encntr_alias ea1,
   person p,
   clinical_event ce,
   encntr_prsnl_reltn ep,
   person p1
  PLAN (ed
   WHERE (ed.loc_nurse_unit_cd= $NUR)
    AND ed.end_effective_dt_tm=cnvtdatetime(cnvtdate(12312100),0000)
    AND ed.loc_building_cd > 0
    AND ((ed.loc_facility_cd+ 0)= $ORG)
    AND ed.loc_room_cd > 0)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND ((e.reg_dt_tm+ 0) BETWEEN cnvtdatetime(cnvtdate( $ST_DT),0000) AND cnvtdatetime(cnvtdate(
      $EN_DT),235959))
    AND (e.loc_nurse_unit_cd= $NUR))
   JOIN (ea
   WHERE ea.encntr_id=ed.encntr_id
    AND ((ea.encntr_alias_type_cd+ 0)=fnbr_cd))
   JOIN (ea1
   WHERE ea1.encntr_id=ed.encntr_id
    AND ((ea1.encntr_alias_type_cd+ 0)=mrn_cd))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ep
   WHERE ep.encntr_id=ed.encntr_id
    AND ((ep.active_ind+ 0)=1)
    AND ((ep.encntr_prsnl_r_cd+ 0)=attend_cd)
    AND ((ep.expiration_ind+ 0)=0)
    AND ((ep.end_effective_dt_tm+ 0)=cnvtdatetime(cnvtdate(12312100),0000)))
   JOIN (p1
   WHERE p1.person_id=ep.prsnl_person_id)
   JOIN (ce
   WHERE ce.encntr_id=outerjoin(e.encntr_id)
    AND ce.event_cd=outerjoin(home_med_recon_cd)
    AND ce.result_status_cd=outerjoin(auth_ver_cd))
   JOIN (d1)
   JOIN (elh
   WHERE ((elh.encntr_id=e.encntr_id
    AND ((elh.end_effective_dt_tm+ 0) < cnvtdatetime(cnvtdate(12312100),0000))
    AND ((elh.encntr_type_cd+ 0) IN (daystay_cd, inpat_cd, observation_cd))
    AND ((elh.updt_cnt+ 0) > 0)) OR (elh.encntr_id=e.encntr_id
    AND elh.loc_nurse_unit_cd=e.loc_nurse_unit_cd
    AND elh.end_effective_dt_tm=cnvtdatetime(cnvtdate(12312100),0000)
    AND ((elh.encntr_type_cd+ 0) IN (daystay_cd, inpat_cd, observation_cd))
    AND ((elh.updt_cnt+ 0)=0))) )
  ORDER BY nurse, e.encntr_id, status
  HEAD REPORT
   y_pos = 18, printpsheader = 0, col 0,
   "{PS/792 0 translate 90 rotate/}", row + 1,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
  HEAD PAGE
   y_pos = 36
   IF (printpsheader)
    col 0, "{PS/792 0 translate 90 rotate/}", row + 1
   ENDIF
   printpsheader = 1, row + 1, "{F/5}{CPI/14}",
   CALL print(calcpos(325,(y_pos+ 0))), "Home Medication Review Report", row + 1,
   row + 1,
   CALL print(calcpos(342,(y_pos+ 18))), org_name,
   row + 1, row + 1,
   CALL print(calcpos(52,(y_pos+ 36))),
   "Report Date:", row + 1,
   CALL print(calcpos(124,(y_pos+ 36))),
   curdate, st_dt2 = build("Audit From...",format(cnvtdate( $ST_DT),"mm/dd/yy;;d"),"  To...    ",
    format(cnvtdate( $EN_DT),"mm/dd/yy;;d")), row + 1,
   CALL print(calcpos(324,(y_pos+ 36))), st_dt2, row + 1,
   CALL print(calcpos(648,(y_pos+ 36))), "Page:", row + 1,
   CALL print(calcpos(666,(y_pos+ 36))), curpage, row + 1,
   row + 1,
   CALL print(calcpos(52,(y_pos+ 54))), "Report Time:",
   row + 1,
   CALL print(calcpos(124,(y_pos+ 54))), curtime,
   row + 1,
   CALL print(calcpos(630,(y_pos+ 56))), "Med Review",
   CALL print(calcpos(630,(y_pos+ 64))), "Date/Time",
   CALL print(calcpos(690,(y_pos+ 56))),
   "Med Review",
   CALL print(calcpos(690,(y_pos+ 64))), "Completed",
   row + 1,
   CALL print(calcpos(52,(y_pos+ 72))), "Attending",
   CALL print(calcpos(120,(y_pos+ 72))), "Nurse Unit",
   CALL print(calcpos(178,(y_pos+ 72))),
   "Patient",
   CALL print(calcpos(315,(y_pos+ 72))), "IP Admit Time",
   CALL print(calcpos(395,(y_pos+ 72))), "Admit Loc",
   CALL print(calcpos(455,(y_pos+ 72))),
   "Unit Admit Time",
   CALL print(calcpos(530,(y_pos+ 72))), "Accnt Num",
   CALL print(calcpos(585,(y_pos+ 72))), "MRN",
   CALL print(calcpos(630,(y_pos+ 72))),
   "Completed",
   CALL print(calcpos(690,(y_pos+ 72))), "in 24 Hrs",
   row + 1,
   CALL print(calcpos(740,(y_pos+ 56))), "Unable",
   CALL print(calcpos(740,(y_pos+ 64))), "to Obtain/",
   CALL print(calcpos(740,(y_pos+ 72))),
   "Other", row + 1, y_val = ((792 - y_pos) - 103),
   "{PS/newpath 2 setlinewidth   36 ", y_val, " moveto  780 ",
   y_val, " lineto stroke 36 ", y_val,
   " moveto/}", row + 1, y_pos = (y_pos+ 106)
  HEAD nurse
   IF (((y_pos+ 67) >= 612))
    y_pos = 0, BREAK
   ENDIF
   row + 1, "{F/5}{CPI/14}", row + 1,
   CALL print(calcpos(124,(y_pos+ 0))), "{U}", nurse,
   row + 1, row + 1, y_pos = (y_pos+ 11)
  DETAIL
   IF (((y_pos+ 67) >= 612))
    y_pos = 0, BREAK
   ENDIF
   row + 1, "{F/4}{CPI/14}", row + 1,
   CALL print(calcpos(30,(y_pos+ 0))), attend_dr, row + 1,
   CALL print(calcpos(160,(y_pos+ 0))), name, row + 1,
   CALL print(calcpos(312,(y_pos+ 0))), admit_dt, row + 1,
   CALL print(calcpos(395,(y_pos+ 0))), loc
   IF (elh.loc_nurse_unit_cd=e.loc_nurse_unit_cd)
    row + 1,
    CALL print(calcpos(465,(y_pos+ 0))), loc_dt2
   ELSE
    row + 1,
    CALL print(calcpos(465,(y_pos+ 0))), loc_dt
   ENDIF
   IF (((ce.result_val="Unknown*") OR (ce.result_val="Other*")) )
    unknown_ind = "Y"
   ELSE
    unknown_ind = "N"
   ENDIF
   row + 1,
   CALL print(calcpos(534,(y_pos+ 0))), fin,
   row + 1,
   CALL print(calcpos(586,(y_pos+ 0))), mrn,
   row + 1,
   CALL print(calcpos(628,(y_pos+ 0))), complete_dt,
   row + 1,
   CALL print(calcpos(710,(y_pos+ 0))), signed_within_24,
   row + 1,
   CALL print(calcpos(750,(y_pos+ 0))), unknown_ind,
   y_pos = (y_pos+ 13)
  FOOT  nurse
   IF (((y_pos+ 152) >= 612))
    y_pos = 0, BREAK
   ELSE
    y_pos = (y_pos+ 12)
   ENDIF
   c_lt_24 = count(ce.event_id
    WHERE ce.result_status_cd=auth_ver_cd
     AND datetimediff(ce.verified_dt_tm,e.reg_dt_tm,3) <= 24), c_mt_24 = count(ce.event_id
    WHERE ce.result_status_cd=auth_ver_cd
     AND datetimediff(ce.verified_dt_tm,e.reg_dt_tm,3) > 24), comp = count(ce.event_id
    WHERE ce.result_status_cd=auth_ver_cd),
   not_c = count(ce.event_id
    WHERE ce.result_status_cd != auth_ver_cd), all_c = count(ce.event_id), all_c2 = count(ce.event_id
    ),
   per_c_lt_24 = (((c_lt_24 * 100)/ (all_c * 100)) * 100), per_c_mt_24 = (((c_mt_24 * 100)/ (all_c *
   100)) * 100), per_not_c = (((not_c * 100)/ (all_c * 100)) * 100),
   per_comp = (((comp * 100)/ (all_c * 100)) * 100), row + 1, "{F/5}{CPI/14}",
   CALL print(calcpos(306,(y_pos+ 0))), "Totals for", row + 1,
   CALL print(calcpos(360,(y_pos+ 0))), nurse, row + 1,
   row + 1,
   CALL print(calcpos(216,(y_pos+ 9))), "Total Completed Within 24 Hrs",
   row + 1,
   CALL print(calcpos(414,(y_pos+ 9))), c_lt_24,
   row + 1,
   CALL print(calcpos(450,(y_pos+ 9))), per_c_lt_24,
   " %", row + 1, row + 1,
   CALL print(calcpos(216,(y_pos+ 18))), "Total Completed Greater than 24 Hrs", row + 1,
   CALL print(calcpos(414,(y_pos+ 18))), c_mt_24, row + 1,
   CALL print(calcpos(450,(y_pos+ 18))), per_c_mt_24, " %",
   row + 1, row + 1,
   CALL print(calcpos(216,(y_pos+ 27))),
   "Total Completed", row + 1,
   CALL print(calcpos(414,(y_pos+ 27))),
   comp, row + 1,
   CALL print(calcpos(450,(y_pos+ 27))),
   per_comp, " %", row + 1,
   row + 1,
   CALL print(calcpos(216,(y_pos+ 36))), "Total Not Completed",
   row + 1,
   CALL print(calcpos(414,(y_pos+ 36))), not_c,
   row + 1,
   CALL print(calcpos(450,(y_pos+ 36))), per_not_c,
   " %", row + 1, y_val = ((792 - y_pos) - 62),
   "{PS/newpath 2 setlinewidth  216 ", y_val, " moveto  574 ",
   y_val, " lineto stroke 216 ", y_val,
   " moveto/}", row + 1, row + 1,
   CALL print(calcpos(216,(y_pos+ 54))), "Total Patients", row + 1,
   CALL print(calcpos(350,(y_pos+ 54))), nurse, row + 1,
   CALL print(calcpos(414,(y_pos+ 54))), all_c2, y_pos = (y_pos+ 114)
  FOOT REPORT
   IF (all_c2 >= 1)
    IF (((y_pos+ 152) >= 612))
     y_pos = 0, BREAK
    ELSE
     y_pos = (y_pos+ 36)
    ENDIF
    c_lt_24 = count(ce.event_id
     WHERE ce.result_status_cd=auth_ver_cd
      AND datetimediff(ce.verified_dt_tm,e.reg_dt_tm,3) <= 24), c_mt_24 = count(ce.event_id
     WHERE ce.result_status_cd=auth_ver_cd
      AND datetimediff(ce.verified_dt_tm,e.reg_dt_tm,3) > 24), comp = count(ce.event_id
     WHERE ce.result_status_cd=auth_ver_cd),
    not_c = count(ce.event_id
     WHERE ce.result_status_cd != auth_ver_cd), all_c = count(ce.event_id), all_c2 = count(ce
     .event_id),
    per_c_lt_24 = (((c_lt_24 * 100)/ (all_c * 100)) * 100), per_c_mt_24 = (((c_mt_24 * 100)/ (all_c
     * 100)) * 100), per_not_c = (((not_c * 100)/ (all_c * 100)) * 100),
    per_comp = (((comp * 100)/ (all_c * 100)) * 100), row + 1, "{F/5}{CPI/14}",
    CALL print(calcpos(342,(y_pos+ 0))), "Totals for All Nursing Units", row + 1,
    row + 1,
    CALL print(calcpos(216,(y_pos+ 18))), "Total Completed Within 24 Hrs",
    row + 1,
    CALL print(calcpos(414,(y_pos+ 18))), c_lt_24,
    row + 1,
    CALL print(calcpos(450,(y_pos+ 18))), per_c_lt_24,
    " %", row + 1, row + 1,
    CALL print(calcpos(216,(y_pos+ 36))), "Total Completed Greater than 24 Hrs", row + 1,
    CALL print(calcpos(414,(y_pos+ 36))), c_mt_24, row + 1,
    CALL print(calcpos(450,(y_pos+ 36))), per_c_mt_24, " %",
    row + 1, row + 1,
    CALL print(calcpos(216,(y_pos+ 54))),
    "Total Completed", row + 1,
    CALL print(calcpos(414,(y_pos+ 54))),
    comp, row + 1,
    CALL print(calcpos(450,(y_pos+ 54))),
    per_comp, " %", row + 1,
    row + 1,
    CALL print(calcpos(216,(y_pos+ 72))), "Total Not Completed",
    row + 1,
    CALL print(calcpos(414,(y_pos+ 72))), not_c,
    row + 1,
    CALL print(calcpos(450,(y_pos+ 72))), per_not_c,
    " %", row + 1, row + 1,
    y_val = ((792 - y_pos) - 100), "{PS/newpath 2 setlinewidth  216 ", y_val,
    " moveto  574 ", y_val, " lineto stroke 216 ",
    y_val, " moveto/}", row + 1,
    row + 1,
    CALL print(calcpos(216,(y_pos+ 90))), "Total Patients All Nursing Units",
    row + 1,
    CALL print(calcpos(414,(y_pos+ 90))), all_c2,
    row + 1, "{F/5}{CPI/18}", row + 1,
    CALL print(calcpos(216,(y_pos+ 160))), "Object: ", curprog,
    BREAK
   ELSE
    row + 1, "{F/5}{CPI/18}",
    CALL print(calcpos(342,(y_pos+ 0))),
    "No Patients Qualify for Report", row + 1,
    CALL print(calcpos(216,(y_pos+ 160))),
    "Object: ", curprog, row + 1
   ENDIF
  WITH maxcol = 400, maxrow = 1000, landscape,
   dio = 08, noheading, format = variable,
   time = value(maxsecs), nullreport, outerjoin = d1
 ;end select
END GO

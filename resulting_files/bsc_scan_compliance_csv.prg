CREATE PROGRAM bsc_scan_compliance_csv
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE i18n_sdaterange = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DATE_RANGE","Date Range"),3))
 DECLARE i18n_spage = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PAGE","Page"
    ),3))
 DECLARE i18n_sfacility = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_FACILITY","Facility"),3))
 DECLARE i18n_srundatetime = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_RUN_DATE","Run Date/Time"),3))
 DECLARE i18n_snurseunit = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NURSE_UNIT","Nurse Unit"),3))
 DECLARE i18n_snurseunits = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NURSE_UNITS","Nurse Units"),3))
 DECLARE i18n_sall = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ALL","All"),3
   ))
 DECLARE i18n_sunknownerror = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_UNKNOWN_ERROR","Unknown/Error"),3))
 DECLARE i18n_stitle = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_TITLE",
    "Point of Care Audit Scan Compliance Report"),3))
 DECLARE i18n_sdisplayper = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DISPLAY_PER","Display per"),3))
 DECLARE i18n_slegend = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_LEGEND",
    "Legend"),3))
 DECLARE i18n_spos = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_POS","Pos"),3
   ))
 DECLARE i18n_sposition = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_POSITION","Position"),3))
 DECLARE i18n_suser = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_USER","User"
    ),3))
 DECLARE i18n_snurse = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NURSE",
    "Nurse"),3))
 DECLARE i18n_sscanned = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_SCANNED",
    "Scanned"),3))
 DECLARE i18n_sselected = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_SELECTED","Selected"),3))
 DECLARE i18n_spatient = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PATIENT",
    "Patient"),3))
 DECLARE i18n_smed = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_MED","Med"),3
   ))
 DECLARE i18n_sname = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NAME","Name"
    ),3))
 DECLARE i18n_sunit = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_UNIT","Unit"
    ),3))
 DECLARE i18n_spts = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PTS","Pts"),3
   ))
 DECLARE i18n_scompl = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_COMPL",
    "Compl"),3))
 DECLARE i18n_smeds = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_MEDS","Meds"
    ),3))
 DECLARE i18n_stotal = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_TOTAL",
    "Total"),3))
 DECLARE i18n_stotalsaverages = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_TOTALS_AVERAGES","Totals/Averages"),3))
 DECLARE i18n_snoresultsqualified = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NO_RESULTS_QUALIFIED","No Results Qualified"),3))
 DECLARE i18n_sreport = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_REPORT",
    "Report"),3))
 DECLARE i18n_scompliance = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_COMPLIANCE","Compliance %"),3))
 DECLARE i18n_smedication = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_MEDICATION","Medication"),3))
 DECLARE i18n_sfrom = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_FROM","From"
    ),3))
 DECLARE i18n_sto = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_TO","To"),3))
 SET modify = predeclare
 SELECT INTO value(coutput)
  FROM med_admin_event mae,
   clinical_event ce,
   prsnl p
  PLAN (mae
   WHERE mae.med_admin_event_id > 0
    AND mae.beg_dt_tm >= cnvtdatetime(audit_request->start_dt_tm)
    AND mae.end_dt_tm <= cnvtdatetime(audit_request->end_dt_tm)
    AND mae.nurse_unit_cd > 0.00
    AND mae.event_type_cd != cnotadministred
    AND mae.event_type_cd != cnotgiven
    AND parser(snue_clause))
   JOIN (p
   WHERE p.person_id=mae.prsnl_id)
   JOIN (ce
   WHERE ce.event_reltn_cd=cchild
    AND ce.result_status_cd != cnotdone
    AND ((mae.event_id=ce.parent_event_id) OR (mae.event_id=ce.event_id))
    AND mae.event_type_cd > 0.00)
  ORDER BY p.name_full_formatted, mae.prsnl_id, uar_get_code_display(mae.nurse_unit_cd),
   mae.nurse_unit_cd, mae.med_admin_event_id
  HEAD REPORT
   posptcompliancetotal = 0, posmedcompliancetotal = 0, ptcompliancetotalevents = 0,
   medcompliancetotalevents = 0, complianceptpercent = 0.0, compliancemedpercent = 0.0,
   totalselectedpat = 0, totalselectedmed = 0, sdisplay = ""
   IF ((audit_request->start_dt_tm > 0))
    sdisplay = format(audit_request->start_dt_tm,"@SHORTDATE;;Q")
   ENDIF
   i18n_sfrom, ":,", sdisplay,
   ",", ",", i18n_sfacility,
   ":,", sdisplay = uar_get_code_display(audit_request->facility_cd), sdisplay,
   row + 1
   IF ((audit_request->end_dt_tm > 0))
    sdisplay = format(audit_request->end_dt_tm,"@SHORTDATE;;Q")
   ENDIF
   i18n_sto, ":,", sdisplay,
   ",", ",", i18n_snurseunits,
   ":,", snurse_units, row + 1,
   i18n_suser, ",", ",",
   i18n_snurse, ",", i18n_sscanned,
   ",", i18n_sselected, ",",
   i18n_spatient, ",", i18n_sscanned,
   ",", i18n_sselected, ",",
   i18n_smedication, ",", row + 1,
   i18n_sname, ",", i18n_sposition,
   ",", i18n_sunit, ",",
   i18n_spts, ",", i18n_spts,
   ",", i18n_scompliance, ",",
   i18n_smeds, ",", i18n_smeds,
   ",", i18n_scompliance, ",",
   row + 1
  HEAD mae.prsnl_id
   lcnt = 0, totalptscannedpu = 0, totalptselectedpu = 0,
   totalptpercentpu = 0.0, totalmedscannedpu = 0, totalmedselectedpu = 0,
   totalmedpercentpu = 0.0, pttotalpu = 0, medtotalpu = 0
  HEAD mae.nurse_unit_cd
   lcnt = (lcnt+ 1), totalptscanned = 0, totalptselected = 0,
   totalptpercent = 0.0, totalmedscanned = 0, totalmedselected = 0,
   totalmedpercent = 0.0, pttotal = 0, medtotal = 0,
   nurseunit = "", position = ""
  HEAD mae.med_admin_event_id
   IF (mae.event_id != 0)
    medtotal = (medtotal+ 1.0)
    IF (mae.positive_med_ident_ind=1)
     totalmedscanned = (totalmedscanned+ 1.0)
    ELSE
     totalmedselected = (totalmedselected+ 1.0)
    ENDIF
   ENDIF
   pttotal = (pttotal+ 1.0)
   IF (mae.positive_patient_ident_ind=1)
    totalptscanned = (totalptscanned+ 1.0)
   ELSE
    totalptselected = (totalptselected+ 1.0)
   ENDIF
  DETAIL
   col + 0
  FOOT  mae.med_admin_event_id
   col + 0
  FOOT  mae.nurse_unit_cd
   pttotalpu = (pttotal+ pttotalpu), medtotalpu = (medtotal+ medtotalpu), totalptscannedpu = (
   totalptscannedpu+ totalptscanned),
   totalmedscannedpu = (totalmedscannedpu+ totalmedscanned), totalptselectedpu = (totalptselectedpu+
   totalptselected), totalmedselectedpu = (totalmedselectedpu+ totalmedselected),
   nurseunit = trim(replace(uar_get_code_display(mae.nurse_unit_cd),","," ",0),3), position = trim(
    replace(uar_get_code_display(mae.position_cd),","," ",0),3), username = trim(replace(p
     .name_full_formatted,",","-",0),3),
   username, ",", position,
   ",", nurseunit, ",",
   totalptpercent = ((cnvtreal(totalptscanned)/ cnvtreal(pttotal)) * 100.00), totalmedpercent = ((
   cnvtreal(totalmedscanned)/ cnvtreal(medtotal)) * 100.00), totalptscanned,
   ",", totalptselected, ",",
   totalptpercent, " %", ",",
   totalmedscanned, ",", totalmedselected,
   ",", totalmedpercent, " %",
   ",", row + 1
  FOOT  mae.prsnl_id
   ptcompliancetotalevents = (pttotalpu+ ptcompliancetotalevents), medcompliancetotalevents = (
   medtotalpu+ medcompliancetotalevents), posptcompliancetotal = (posptcompliancetotal+
   totalptscannedpu),
   posmedcompliancetotal = (posmedcompliancetotal+ totalmedscannedpu), totalptpercentpu = ((cnvtreal(
    totalptscannedpu)/ cnvtreal(pttotalpu)) * 100.00), totalmedpercentpu = ((cnvtreal(
    totalmedscannedpu)/ cnvtreal(medtotalpu)) * 100.00)
   IF (lcnt > 1)
    nurseunit = i18n_stotal, "--------------------", username,
    ",", position, ",",
    nurseunit, ",", totalptscannedpu,
    ",", totalptselectedpu, ",",
    totalptpercentpu, " %", ",",
    totalmedscannedpu, ",", totalmedselectedpu,
    ",", totalmedpercentpu, " %",
    ",", row + 1
   ENDIF
  FOOT REPORT
   complianceptpercent = ((cnvtreal(posptcompliancetotal)/ cnvtreal(ptcompliancetotalevents)) *
   100.00), compliancemedpercent = ((cnvtreal(posmedcompliancetotal)/ cnvtreal(
    medcompliancetotalevents)) * 100.00), totalselectedpat = (ptcompliancetotalevents -
   posptcompliancetotal),
   totalselectedmed = (medcompliancetotalevents - posmedcompliancetotal), row + 1, ",",
   ",", i18n_stotalsaverages, ":,",
   posptcompliancetotal, ",", totalselectedpat,
   ",", complianceptpercent, " %",
   ",", posmedcompliancetotal, ",",
   totalselectedmed, ",", compliancemedpercent,
   " %", ","
  WITH nocounter, pcformat, maxcol = value(lnurse_units_length)
 ;end select
 IF (curqual=0)
  SELECT INTO value(coutput)
   FROM (dummyt d  WITH seq = 1)
   ORDER BY d.seq
   HEAD REPORT
    sdisplay = ""
    IF ((audit_request->start_dt_tm > 0))
     sdisplay = format(audit_request->start_dt_tm,"@SHORTDATE;;Q")
    ENDIF
    i18n_sfrom, ":,", sdisplay,
    ",", ",", i18n_sfacility,
    ":,", sdisplay = uar_get_code_display(cnvtreal(audit_request->facility_cd)), sdisplay,
    row + 1
    IF ((audit_request->end_dt_tm > 0))
     sdisplay = format(audit_request->end_dt_tm,"@SHORTDATE;;Q")
    ENDIF
    i18n_sto, ":,", sdisplay,
    ",", ",", i18n_snurseunits,
    ":,", snurse_units, row + 1,
    ",", ",", ",",
    ",", ",", ",",
    "*****", i18n_snoresultsqualified, " *****"
   WITH nocounter, maxcol = value(lnurse_units_length)
  ;end select
 ENDIF
 CALL echo(build("output file = ccluserdir:",coutput))
 SET last_mod = "005"
 SET mod_date = "04/12/2017"
 SET modify = nopredeclare
END GO

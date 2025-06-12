CREATE PROGRAM bsc_patmm_audit_detail_csv:dba
 SET modify = predeclare
 SET modify = predeclare
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
    "Point of Care Audit Patient Mismatch Report"),3))
 DECLARE i18n_sdisplayper = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DISPLAY_PER","Display per"),3))
 DECLARE i18n_sexpectedpatient = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_EXPECTED_PATIENT","Expected Patient"),3))
 DECLARE i18n_slegend = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_LEGEND",
    "Legend"),3))
 DECLARE i18n_spos = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_POS","Pos"),3
   ))
 DECLARE i18n_sposition = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_POSITION","Position"),3))
 DECLARE i18n_salert = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ALERT",
    "Alert"),3))
 DECLARE i18n_sexpected = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_EXPECTED","Expected"),3))
 DECLARE i18n_snurse = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NURSE",
    "Nurse"),3))
 DECLARE i18n_sidentified = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_IDENTIFIED","Identified"),3))
 DECLARE i18n_suser = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_USER","User"
    ),3))
 DECLARE i18n_sdatetime = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DATE_TIME","Date/Time"),3))
 DECLARE i18n_spatientname = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_PATIENTNAME","Patient Name"),3))
 DECLARE i18n_smrn = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_MRN","MRN"),3
   ))
 DECLARE i18n_sunit = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_UNIT","Unit"
    ),3))
 DECLARE i18n_sname = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NAME","Name"
    ),3))
 DECLARE i18n_stotalalerts = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_TOTAL_ALERTS","Total Alerts"),3))
 DECLARE i18n_snoresultsqualified = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NO_RESULTS_QUALIFIED","No Results Qualified"),3))
 DECLARE i18n_smedname = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_MED_NAME",
    "Med Name"),3))
 DECLARE i18n_salertdatetime = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ALERT_DTTM","Alert date/time"),3))
 DECLARE i18n_sexppatname = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_EXP_PATNAME","Expected Patient Name"),3))
 DECLARE i18n_sexpmrn = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_EXP_MRN",
    "Expected MRN"),3))
 DECLARE i18n_sidentpatname = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_IDENT_PATNAME","Identified Patient Name"),3))
 DECLARE i18n_sidentmrn = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_IDENT_MRN","Identified MRN"),3))
 DECLARE i18n_sfrom = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_FROM","From"
    ),3))
 DECLARE i18n_sto = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_TO","To"),3))
 SELECT INTO value(coutput)
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
   WHERE maa.alert_type_cd IN (cpatmismatch)
    AND maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
    audit_request->end_dt_tm)
    AND maa.nurse_unit_cd > 0.00
    AND parser(snua_clause))
   JOIN (l
   WHERE l.location_cd=maa.nurse_unit_cd)
   JOIN (oap
   WHERE oap.organization_id=l.organization_id
    AND oap.alias_entity_name="PERSON_ALIAS"
    AND oap.alias_entity_alias_type_cd=cpatmrn)
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
    AND pa.person_alias_type_cd=cpatmrn
    AND pa.alias_pool_cd=oap.alias_pool_cd
    AND pa.alias_pool_cd > 0.0)
   JOIN (pers2
   WHERE pers2.person_id=mape.identified_pt_id)
   JOIN (d)
   JOIN (pa1
   WHERE pa1.person_id=pers2.person_id
    AND pa1.person_alias_type_cd=cpatmrn
    AND pa1.alias_pool_cd=oap.alias_pool_cd
    AND pa1.alias_pool_cd > 0.0)
  ORDER BY cnvtdatetime(maa.event_dt_tm), maa.prsnl_id, mape.med_admin_pt_error_id
  HEAD REPORT
   totalalert = 0, i18n_salert, ",",
   i18n_salertdatetime, ",", i18n_sexppatname,
   ",", i18n_sexpmrn, ",",
   i18n_snurseunit, ",", i18n_sidentpatname,
   ",", i18n_sidentmrn, ",",
   i18n_suser, ",", i18n_sposition,
   ",", i18n_smedname, row + 1
  HEAD mape.med_admin_pt_error_id
   expectedmrn = "", identifiedmrn = ""
  DETAIL
   x = 0
   IF (pa.alias_pool_cd > 0.0)
    expectedmrn = cnvtalias(pa.alias,pa.alias_pool_cd)
   ENDIF
   IF (pa1.alias_pool_cd > 0.0)
    identifiedmrn = cnvtalias(pa1.alias,pa1.alias_pool_cd)
   ENDIF
  FOOT  mape.med_admin_pt_error_id
   expectedname = "", identifiedname = "", alert = "",
   username = "", position = "", nurseunit = "",
   smedname = "", totalalert = (totalalert+ 1), alert = uar_get_code_display(maa.alert_type_cd),
   alert_time = format(maa.event_dt_tm,"@SHORTDATE;;Q"), expectedname = trim(replace(pers1
     .name_full_formatted,",","-",0),3), identifiedname = trim(replace(pers2.name_full_formatted,",",
     "-",0),3),
   username = trim(replace(p.name_full_formatted,",","-",0),3), position = uar_get_code_display(maa
    .position_cd), nurseunit = trim(replace(uar_get_code_display(maa.nurse_unit_cd),","," ",0),3),
   smedname = trim(o.order_mnemonic,3), alert, ",",
   alert_time, ",", expectedname,
   ",", expectedmrn, ",",
   nurseunit, ",", identifiedname,
   ",", identifiedmrn, ",",
   username, ",", position,
   ",", smedname, row + 1
  FOOT REPORT
   row + 1, i18n_stotalalerts, ",",
   totalalert, row + 1
  WITH nocounter, outerjoin = d, outerjoin = d1,
   maxcol = value(lnurse_units_length)
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
    "*****", i18n_snoresultsqualified, "*****"
   WITH nocounter, maxcol = value(lnurse_units_length)
  ;end select
 ENDIF
 SET last_mod = "004"
 SET mod_date = "04/12/2017"
 SET modify = nopredeclare
END GO

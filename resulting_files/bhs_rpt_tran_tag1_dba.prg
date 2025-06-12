CREATE PROGRAM bhs_rpt_tran_tag1:dba
 PROMPT
  "Hidden OutputDev:" = "MINE",
  "Facility:" = 0,
  "Nurse Unit :" = 0,
  "Begin dt/tm:" = "SYSDATE",
  "End dt/tm" = "SYSDATE",
  "Email Address:" = "",
  "Form Type:" = "TRANSFUSIONTAGFORM",
  "Print Unit Totals:" = 1
  WITH outdev, facility, nurseunit,
  bdate, edate, emailadd,
  formtype, printtotals
 EXECUTE bhs_sys_stand_subroutine
 SET beg_date_qual = cnvtdatetime( $BDATE)
 SET end_date_qual = cnvtdatetime( $EDATE)
 IF (cnvtupper( $BDATE) IN ("DAY"))
  SET beg_date_qual = cnvtdatetime((curdate - 1),0)
  SET end_date_qual = cnvtdatetime((curdate - 1),0)
 ELSEIF (datetimediff(end_date_qual,beg_date_qual) > 31)
  CALL echo("Date range > 31")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is larger than 31 days.", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_program
 ELSEIF (datetimediff(end_date_qual,beg_date_qual) < 0)
  CALL echo("Date range < 0")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is incorrect", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08
  ;end select
  GO TO exit_program
 ENDIF
 IF (findstring("@", $EMAILADD) > 0)
  SET emailind = 1
  SET var_output = "trans_qual_stat_report.csv"
  SET filedelimiter1 = '"'
  SET filedelimiter2 = ","
 ELSE
  SET emailind = 0
  SET var_output =  $OUTDEV
  SET filedelimiter1 = ""
  SET filedelimiter2 = ""
 ENDIF
 FREE RECORD forms
 RECORD forms(
   1 nurseunit[*]
     2 s_nurseunitname = vc
     2 f_nurseunit_cd = f8
     2 patientslist[*]
       3 f_encntr_id = f8
       3 f_person_id = f8
       3 s_person_name = vc
       3 s_finnbr = vc
       3 forminstanceslist[*]
         4 formname = vc
         4 s_performed_on = vc
         4 f_parent_event_id = f8
         4 s_nursesdocumented = vc
         4 s_consentsignedcurrentornotapplicable = vc
         4 s_transfusionstarttime = vc
         4 s_temperaturestart = vc
         4 s_temperatureroutestart = vc
         4 s_pulseratestart = vc
         4 s_respiratoryratestart = vc
         4 s_systolicbloodpressurestart = vc
         4 s_diastolicbloodpressurestart = vc
         4 s_oxygensaturationstart = vc
         4 s_transfusionstartplus15min = vc
         4 s_temperature15min = vc
         4 s_temperatureroute15min = vc
         4 s_pulserate15min = vc
         4 s_respiratoryrate15min = vc
         4 s_systolicbloodpressure15min = vc
         4 s_diastolicbloodpressure15min = vc
         4 s_oxygensaturation15min = vc
         4 s_transfusionendtime = vc
         4 s_temperatureend = vc
         4 s_temperaturerouteend = vc
         4 s_pulserateend = vc
         4 s_respiratoryrateend = vc
         4 s_systolicbloodpressureend = vc
         4 s_diastolicbloodpressureend = vc
         4 s_oxygensaturationend = vc
         4 s_volumeinfusedautotransfusion = vc
         4 s_albuminvol = vc
         4 s_cryoprecipitate = vc
         4 sfactorviia = vc
         4 s_factorviiivol = vc
         4 s_factorixcomplex = vc
         4 s_factorixvol = vc
         4 s_ffp = vc
         4 s_granulocytes = vc
         4 s_ivig = vc
         4 s_platelets = vc
         4 s_rbcvol = vc
         4 s_rhimmuneglobulin = vc
         4 s_bloodproductamountinfused = vc
         4 s_transfusionreactiondescription = vc
         4 s_incompliance = vc
         4 s_originalnurse = vc
         4 s_nursestatementofattestation = vc
         4 transfusiontime = vc
 ) WITH protect
 DECLARE ms_facility_name = vc
 DECLARE ms_nursingunit_name = vc
 DECLARE mf_transfusiontagform = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TRANSFUSIONTAGFORM")), protect
 DECLARE autotransfusionbloodrecoveryform = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "AUTOTRANSFUSIONBLOODRECOVERYFORM")), protect
 DECLARE mf_consentsignedcurrentornotapplicable = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "CONSENTSIGNEDCURRENTORNOTAPPLICABLE")), protect
 DECLARE transfusiondataverification = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TRANSFUSIONDATAVERIFICATION")), protect
 DECLARE autotransfusiondataverification = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "AUTOTRANSFUSIONDATAVERIFICATION")), protect
 DECLARE mf_transfusionstarttime = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TRANSFUSIONSTARTTIME")), protect
 DECLARE autotransfusionstarttime = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "AUTOTRANSFUSIONSTARTTIME")), protect
 DECLARE mf_temperaturestart = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"TEMPERATURESTART")
  ), protect
 DECLARE temperaturestartautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TEMPERATURESTARTAUTOTRANSFUSION")), protect
 DECLARE mf_temperatureroutestart = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TEMPERATUREROUTESTART")), protect
 DECLARE temperatureroutestartautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TEMPERATUREROUTESTARTAUTOTRANSFUSION")), protect
 DECLARE mf_pulseratestart = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"PULSERATESTART")),
 protect
 DECLARE pulseratestartautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "PULSERATESTARTAUTOTRANSFUSION")), protect
 DECLARE mf_respiratoryratestart = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "RESPIRATORYRATESTART")), protect
 DECLARE respiratoryratestartautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "RESPIRATORYRATESTARTAUTOTRANSFUSION")), protect
 DECLARE mf_systolicbloodpressurestart = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURESTART")), protect
 DECLARE sbpstartautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "SBPSTARTAUTOTRANSFUSION")), protect
 DECLARE mf_diastolicbloodpressurestart = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURESTART")), protect
 DECLARE dbpstartautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "DBPSTARTAUTOTRANSFUSION")), protect
 DECLARE mf_oxygensaturationstart = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "OXYGENSATURATIONSTART")), protect
 DECLARE oxygensatstartautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "OXYGENSATSTARTAUTOTRANSFUSION")), protect
 DECLARE mf_transfusionstartplus15min = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TRANSFUSIONSTARTPLUS15MIN")), protect
 DECLARE autotransfusionstartplus15min = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "AUTOTRANSFUSIONSTARTPLUS15MIN")), protect
 DECLARE mf_temperature15min = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"TEMPERATURE15MIN")
  ), protect
 DECLARE temperature15minautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TEMPERATURE15MINAUTOTRANSFUSION")), protect
 DECLARE mf_temperatureroute15min = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TEMPERATUREROUTE15MIN")), protect
 DECLARE temperatureroute15minautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TEMPERATUREROUTE15MINAUTOTRANSFUSION")), protect
 DECLARE mf_pulserate15min = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"PULSERATE15MIN")),
 protect
 DECLARE pulserate15minautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "PULSERATE15MINAUTOTRANSFUSION")), protect
 DECLARE mf_respiratoryrate15min = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "RESPIRATORYRATE15MIN")), protect
 DECLARE respiratoryrate15minautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "RESPIRATORYRATE15MINAUTOTRANSFUSION")), protect
 DECLARE mf_systolicbloodpressure15min = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE15MIN")), protect
 DECLARE sbp15minautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "SBP15MINAUTOTRANSFUSION")), protect
 DECLARE mf_diastolicbloodpressure15min = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE15MIN")), protect
 DECLARE dbp15minautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "DBP15MINAUTOTRANSFUSION")), protect
 DECLARE mf_oxygensaturation15min = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "OXYGENSATURATION15MIN")), protect
 DECLARE oxygensat15minautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "OXYGENSAT15MINAUTOTRANSFUSION")), protect
 DECLARE mf_transfusionendtime = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TRANSFUSIONENDTIME")), protect
 DECLARE autotransfusionstoptime = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "AUTOTRANSFUSIONSTOPTIME")), protect
 DECLARE mf_temperatureend = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"TEMPERATUREEND")),
 protect
 DECLARE temperatureendautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TEMPERATUREENDAUTOTRANSFUSION")), protect
 DECLARE mf_temperaturerouteend = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TEMPERATUREROUTEEND")), protect
 DECLARE temperaturerouteendautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TEMPERATUREROUTEENDAUTOTRANSFUSION")), protect
 DECLARE mf_pulserateend = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"PULSERATEEND")),
 protect
 DECLARE pulserateendautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "PULSERATEENDAUTOTRANSFUSION")), protect
 DECLARE mf_respiratoryrateend = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "RESPIRATORYRATEEND")), protect
 DECLARE respiratoryrateendautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "RESPIRATORYRATEENDAUTOTRANSFUSION")), protect
 DECLARE mf_systolicbloodpressureend = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSUREEND")), protect
 DECLARE sbpendautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "SBPENDAUTOTRANSFUSION")), protect
 DECLARE mf_diastolicbloodpressureend = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSUREEND")), protect
 DECLARE dbpendautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "DBPENDAUTOTRANSFUSION")), protect
 DECLARE mf_oxygensaturationend = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "OXYGENSATURATIONEND")), protect
 DECLARE oxygensatendautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "OXYGENSATENDAUTOTRANSFUSION")), protect
 DECLARE volumeinfusedautotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "VOLUMEINFUSEDAUTOTRANSFUSION")), protect
 DECLARE mf_albuminvol = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"ALBUMINVOL")), protect
 DECLARE mf_cryoprecipitate = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"CRYOPRECIPITATE")),
 protect
 DECLARE mf_factorviia = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"FACTORVIIA")), protect
 DECLARE mf_factorviiivol = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"FACTORVIIIVOL")),
 protect
 DECLARE mf_factorixcomplex = f8
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE code_set=72
   AND display_key="FACTORIXCOMPLEX"
   AND display="Factor IX Complex"
   AND active_ind=1
  DETAIL
   mf_factorixcomplex = cv.code_value
  WITH nocounter
 ;end select
 DECLARE mf_factorixvol = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"FACTORIXVOL")), protect
 DECLARE mf_ffp = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"FFP")), protect
 DECLARE mf_granulocytes = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"GRANULOCYTES")),
 protect
 DECLARE mf_ivig = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"IVIG")), protect
 DECLARE mf_platelets = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"PLATELETS")), protect
 DECLARE mf_rbcvol = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"RBCVOL")), protect
 DECLARE mf_rhimmuneglobulin = f8 WITH constant(validatecodevalue("DISPLAY",72,"Rh Immune Globulin")),
 protect
 DECLARE mf_bloodproductamountinfused = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "BLOODPRODUCTAMOUNTINFUSED")), protect
 DECLARE mf_transfusionreactiondescription = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TRANSFUSIONREACTIONDESCRIPTION")), protect
 DECLARE mf_nurseattestationwitnessed = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "NURSEATTESTATIONWITNESSED")), protect
 DECLARE mf_nursestatementofattestation = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "NURSESTATEMENTOFATTESTATION")), protect
 DECLARE transfusiontime = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"TRANSFUSIONTIME")),
 protect
 DECLARE mf_finnbr = f8 WITH constant(validatecodevalue("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE line1 = vc WITH noconstant(" ")
 DECLARE nurseunit = vc WITH noconstant(" ")
 DECLARE patientname = vc WITH noconstant(" ")
 DECLARE finnumber = vc WITH noconstant(" ")
 DECLARE formname = vc WITH noconstant(" ")
 DECLARE allnursesthatdocumentedontheform = vc WITH noconstant(" ")
 DECLARE consentsignedcurrentdta = vc WITH noconstant(" ")
 DECLARE transfusionstarttime = vc WITH noconstant(" ")
 DECLARE temperaturestart = vc WITH noconstant(" ")
 DECLARE temperatureroutestart = vc WITH noconstant(" ")
 DECLARE pulseratestart = vc WITH noconstant(" ")
 DECLARE respiratoryratestart = vc WITH noconstant(" ")
 DECLARE systolicbloodpressurestart = vc WITH noconstant(" ")
 DECLARE diastolicbloodpressurestart = vc WITH noconstant(" ")
 DECLARE oxygensaturationstart = vc WITH noconstant(" ")
 DECLARE transfusionstartplus15min = vc WITH noconstant(" ")
 DECLARE temperature15min = vc WITH noconstant(" ")
 DECLARE temperatureroute15min = vc WITH noconstant(" ")
 DECLARE pulserate15min = vc WITH noconstant(" ")
 DECLARE respiratoryrate15min = vc WITH noconstant(" ")
 DECLARE systolicbloodpressure15min = vc WITH noconstant(" ")
 DECLARE diastolicbloodpressure15min = vc WITH noconstant(" ")
 DECLARE oxygensaturation15min = vc WITH noconstant(" ")
 DECLARE transfusionendtime = vc WITH noconstant(" ")
 DECLARE temperatureend = vc WITH noconstant(" ")
 DECLARE temperaturerouteend = vc WITH noconstant(" ")
 DECLARE pulserateend = vc WITH noconstant(" ")
 DECLARE respiratoryrateend = vc WITH noconstant(" ")
 DECLARE systolicbloodpressureend = vc WITH noconstant(" ")
 DECLARE diastolicbloodpressureend = vc WITH noconstant(" ")
 DECLARE oxygensaturationend = vc WITH noconstant(" ")
 DECLARE albuminvo = vc WITH noconstant(" ")
 DECLARE cryoprecipitate = vc WITH noconstant(" ")
 DECLARE factorviia = vc WITH noconstant(" ")
 DECLARE factorviiivol = vc WITH noconstant(" ")
 DECLARE factorixcomplex = vc WITH noconstant(" ")
 DECLARE factorixvol = vc WITH noconstant(" ")
 DECLARE ffp = vc WITH noconstant(" ")
 DECLARE granulocytes = vc WITH noconstant(" ")
 DECLARE ivig = vc WITH noconstant(" ")
 DECLARE platelets = vc WITH noconstant(" ")
 DECLARE rbcvol = vc WITH noconstant(" ")
 DECLARE rhimmuneglobulin = vc WITH noconstant(" ")
 DECLARE bloodproductamountinfused = vc WITH noconstant(" ")
 DECLARE transfusionreactiondescription = vc WITH noconstant(" ")
 DECLARE incompliance = vc WITH noconstant(" ")
 DECLARE originalnurse = vc WITH noconstant(" ")
 DECLARE nursestatementofattestation = vc WITH noconstant(" ")
 DECLARE performed_on = vc WITH noconstant(" ")
 DECLARE volumeinfused = vc WITH noconstant(" ")
 DECLARE nurseunitcd = f8 WITH noconstant(0.0)
 DECLARE s_nurses = vc WITH noconstant(" ")
 CALL echo(reflect( $NURSEUNIT))
 IF (reflect( $NURSEUNIT) IN ("F8", "I4"))
  SET nurseunitcd =  $NURSEUNIT
 ELSE
  SET nurseunitcd = 99999999
 ENDIF
 SELECT INTO "NL:"
  nurse_unit = uar_get_code_display(el.loc_nurse_unit_cd), p.name_full_formatted
  FROM dcp_forms_ref dfr,
   dcp_forms_activity dfa,
   encntr_alias ea,
   person p,
   encntr_loc_hist el,
   encounter e
  PLAN (dfr
   WHERE dfr.end_effective_dt_tm >= cnvtdatetime(beg_date_qual)
    AND dfr.beg_effective_dt_tm <= cnvtdatetime(end_date_qual)
    AND dfr.definition IN ("Transfusion Tag Form - BHS", "Autotransfusion/Blood Recovery Form - BHS")
   )
   JOIN (dfa
   WHERE dfa.dcp_forms_ref_id=dfr.dcp_forms_ref_id
    AND dfa.updt_dt_tm >= cnvtdatetime(beg_date_qual))
   JOIN (ea
   WHERE ea.encntr_id=dfa.encntr_id
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=mf_finnbr)
   JOIN (el
   WHERE el.encntr_id=ea.encntr_id
    AND el.active_ind=1
    AND (( NOT (nurseunitcd IN (99999999, 0))
    AND el.loc_nurse_unit_cd=nurseunitcd) OR (((nurseunitcd=0
    AND (el.loc_facility_cd= $FACILITY)) OR (nurseunitcd=99999999
    AND (el.loc_facility_cd= $FACILITY))) ))
    AND el.end_effective_dt_tm >= cnvtdatetime(beg_date_qual)
    AND el.beg_effective_dt_tm <= cnvtdatetime(end_date_qual))
   JOIN (e
   WHERE e.encntr_id=el.encntr_id)
   JOIN (p
   WHERE e.person_id=p.person_id
    AND p.active_ind=1)
  ORDER BY nurse_unit, p.name_full_formatted
  HEAD REPORT
   i_nurseunit_cnt = 0, i_patient_cnt = 0, ms_facility_name = uar_get_code_display(el.loc_facility_cd
    ),
   ms_nursingunit_name = uar_get_code_display(el.loc_nurse_unit_cd)
  HEAD nurse_unit
   i_patient_cnt = 0, i_nurseunit_cnt = (i_nurseunit_cnt+ 1), stat = alterlist(forms->nurseunit,
    i_nurseunit_cnt),
   forms->nurseunit[i_nurseunit_cnt].s_nurseunitname = trim(uar_get_code_display(el.loc_nurse_unit_cd
     ),3), forms->nurseunit[i_nurseunit_cnt].f_nurseunit_cd = el.loc_nurse_unit_cd
  HEAD el.encntr_id
   IF (dfa.beg_activity_dt_tm BETWEEN el.beg_effective_dt_tm AND el.end_effective_dt_tm)
    i_patient_cnt = (i_patient_cnt+ 1)
    IF (i_patient_cnt > size(forms->nurseunit[i_nurseunit_cnt].patientslist,5))
     stat = alterlist(forms->nurseunit[i_nurseunit_cnt].patientslist,(i_patient_cnt+ 10))
    ENDIF
    forms->nurseunit[i_nurseunit_cnt].patientslist[i_patient_cnt].f_encntr_id = el.encntr_id, forms->
    nurseunit[i_nurseunit_cnt].patientslist[i_patient_cnt].f_person_id = e.person_id, forms->
    nurseunit[i_nurseunit_cnt].patientslist[i_patient_cnt].s_person_name = p.name_full_formatted,
    forms->nurseunit[i_nurseunit_cnt].patientslist[i_patient_cnt].s_finnbr = check(trim(ea.alias,3))
   ENDIF
  FOOT  nurse_unit
   stat = alterlist(forms->nurseunit[i_nurseunit_cnt].patientslist,i_patient_cnt)
   IF (size(forms->nurseunit[i_nurseunit_cnt].patientslist,5) <= 0)
    i_nurseunit_cnt = (i_nurseunit_cnt - 1), stat = alterlist(forms->nurseunit,i_nurseunit_cnt)
   ELSE
    stat = alterlist(forms->nurseunit[i_nurseunit_cnt].patientslist,i_patient_cnt)
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(forms)
 IF (curqual=0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = concat("No patients were found for the selected time frame/unit"), col 0,
    "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08
  ;end select
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  unit = forms->nurseunit[d.seq].s_nurseunitname, name = substring(1,50,trim(forms->nurseunit[d.seq].
    patientslist[d1.seq].s_person_name,3)), ce.parent_event_id,
  ce2.event_cd
  FROM (dummyt d  WITH seq = value(size(forms->nurseunit,5))),
   dummyt d1,
   clinical_event ce,
   clinical_event ce1,
   clinical_event ce2,
   clinical_event ce3,
   dummyt d2,
   ce_date_result cedr,
   prsnl pr
  PLAN (d
   WHERE maxrec(d1,size(forms->nurseunit[d.seq].patientslist,5)))
   JOIN (d1)
   JOIN (ce
   WHERE (ce.encntr_id=forms->nurseunit[d.seq].patientslist[d1.seq].f_encntr_id)
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce.result_status_cd IN (mf_modified_cd, mf_auth_cd, mf_altered_cd)
    AND ((((ce.event_cd+ 0)=mf_transfusiontagform)
    AND ( $FORMTYPE IN ("TRANSFUSIONTAGFORM", "BOTH"))) OR (ce.event_cd=
   autotransfusionbloodrecoveryform
    AND ( $FORMTYPE IN ("AUTOTRANSFUSIONBLOODRECOVERYFORM", "BOTH"))
    AND ((ce.performed_dt_tm+ 0) BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual))
   )) )
   JOIN (ce1
   WHERE ce1.parent_event_id=ce.event_id
    AND ce1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce1.result_status_cd IN (mf_modified_cd, mf_auth_cd, mf_altered_cd))
   JOIN (ce2
   WHERE ce2.parent_event_id=ce1.event_id
    AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce2.result_status_cd IN (mf_modified_cd, mf_auth_cd, mf_altered_cd)
    AND ce2.event_cd IN (transfusiondataverification, autotransfusiondataverification,
   mf_transfusionstarttime, mf_temperaturestart, mf_temperatureroutestart,
   mf_pulseratestart, mf_respiratoryratestart, mf_systolicbloodpressurestart,
   mf_diastolicbloodpressurestart, mf_oxygensaturationstart,
   autotransfusionstarttime, temperaturestartautotransfusion, temperatureroutestartautotransfusion,
   pulseratestartautotransfusion, respiratoryratestartautotransfusion,
   sbpstartautotransfusion, dbpstartautotransfusion, oxygensatstartautotransfusion,
   mf_transfusionstartplus15min, mf_temperature15min,
   mf_temperatureroute15min, mf_pulserate15min, mf_respiratoryrate15min,
   mf_systolicbloodpressure15min, mf_diastolicbloodpressure15min,
   mf_oxygensaturation15min, autotransfusionstartplus15min, temperature15minautotransfusion,
   temperatureroute15minautotransfusion, pulserate15minautotransfusion,
   respiratoryrate15minautotransfusion, sbp15minautotransfusion, dbp15minautotransfusion,
   oxygensat15minautotransfusion, mf_transfusionendtime,
   mf_temperatureend, mf_temperaturerouteend, mf_pulserateend, mf_respiratoryrateend,
   mf_systolicbloodpressureend,
   mf_diastolicbloodpressureend, mf_oxygensaturationend, autotransfusionstoptime,
   temperatureendautotransfusion, temperaturerouteendautotransfusion,
   pulserateendautotransfusion, respiratoryrateendautotransfusion, sbpendautotransfusion,
   dbpendautotransfusion, oxygensatendautotransfusion,
   mf_albuminvol, mf_cryoprecipitate, mf_factorviia, mf_factorviiivol, mf_factorixcomplex,
   mf_factorixvol, mf_ffp, mf_granulocytes, mf_ivig, mf_platelets,
   mf_rbcvol, mf_rhimmuneglobulin, mf_bloodproductamountinfused, volumeinfusedautotransfusion,
   mf_transfusionreactiondescription,
   mf_nursestatementofattestation, transfusiontime))
   JOIN (pr
   WHERE pr.person_id=ce2.performed_prsnl_id)
   JOIN (cedr
   WHERE cedr.event_id=outerjoin(ce2.event_id))
   JOIN (d2)
   JOIN (ce3
   WHERE ce3.parent_event_id=ce2.event_id
    AND ce3.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce3.result_status_cd IN (mf_modified_cd, mf_auth_cd, mf_altered_cd)
    AND ce3.event_cd IN (mf_consentsignedcurrentornotapplicable))
  ORDER BY unit, name, ce.parent_event_id,
   ce2.event_cd DESC
  HEAD REPORT
   stat = 0, totformscomplete = 0.0, totformsincomplete = 0.0,
   tottotalforms = 0.0
  HEAD unit
   totalforms = 0.0, formscomplete = 0.0, formsincomplete = 0.0,
   unitcomplince = 0.0
  HEAD name
   i_instance_cnt = 0, i_consent_cnt = 0, i_vital_cnt = 0,
   i_infused_cnt = 0, i_reaction_cnt = 0, i_witness_cnt = 0,
   i_calcvalues_cnt = 0
  HEAD ce.parent_event_id
   i_trandta_cnt = 0, i_consent_cnt = 0, i_vital_cnt = 0,
   i_infused_cnt = 0, i_reaction_cnt = 0, i_witness_cnt = 0,
   i_calcvalues_cnt = 0, i_instance_cnt = (i_instance_cnt+ 1),
   CALL echo(build("WHY:",i_instance_cnt)),
   CALL echo(build("Who:",name)),
   CALL echo(build("Who2:",forms->nurseunit[d.seq].patientslist[d1.seq].s_person_name)),
   CALL echo(build("where:",unit)),
   CALL echo(forms->nurseunit[d.seq].f_nurseunit_cd), stat = alterlist(forms->nurseunit[d.seq].
    patientslist[d1.seq].forminstanceslist[i_instance_cnt],i_instance_cnt), forms->nurseunit[d.seq].
   patientslist[d1.seq].forminstanceslist[i_instance_cnt].f_parent_event_id = ce.parent_event_id,
   forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].formname =
   uar_get_code_display(ce.event_cd), forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[
   i_instance_cnt].s_performed_on = build(format(ce.performed_dt_tm,";;q"))
  HEAD ce2.event_cd
   IF (ce2.event_cd=mf_nursestatementofattestation)
    s_tran_result = build2(trim(ce2.event_tag)," (",trim(pr.name_full_formatted),")")
   ELSEIF (cedr.event_id > 0)
    s_tran_result = format(cnvtdatetime(cedr.result_dt_tm),";;q")
   ELSE
    s_tran_result = build2(trim(ce2.event_tag)," ",trim(uar_get_code_display(ce2.result_units_cd)))
   ENDIF
   IF (ce3.event_cd=mf_consentsignedcurrentornotapplicable)
    CALL echo("mf_CONSENTSIGNEDCURRENTORNOTAPPLICABLE"), forms->nurseunit[d.seq].patientslist[d1.seq]
    .forminstanceslist[i_instance_cnt].s_consentsignedcurrentornotapplicable = ce3.event_tag,
    i_consent_cnt = (i_consent_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_transfusionstarttime, autotransfusionstarttime))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_transfusionstarttime = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_temperaturestart, temperaturestartautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_temperaturestart
     = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_temperatureroutestart, temperatureroutestartautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_temperatureroutestart = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_pulseratestart, pulseratestartautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_pulseratestart
     = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_respiratoryratestart, respiratoryratestartautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_respiratoryratestart = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_systolicbloodpressurestart, sbpstartautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_systolicbloodpressurestart = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_diastolicbloodpressurestart, dbpstartautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_diastolicbloodpressurestart = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_oxygensaturationstart, oxygensatstartautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_oxygensaturationstart = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_transfusionstartplus15min, autotransfusionstartplus15min))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_transfusionstartplus15min = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_temperature15min, temperature15minautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_temperature15min
     = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_temperatureroute15min, temperatureroute15minautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_temperatureroute15min = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_pulserate15min, pulserate15minautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_pulserate15min
     = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_respiratoryrate15min, respiratoryrate15minautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_respiratoryrate15min = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_systolicbloodpressure15min, sbp15minautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_systolicbloodpressure15min = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_diastolicbloodpressure15min, dbp15minautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_diastolicbloodpressure15min = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_oxygensaturation15min, oxygensat15minautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_oxygensaturation15min = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_transfusionendtime, autotransfusionstoptime))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_transfusionendtime = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_temperatureend, temperatureendautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_temperatureend
     = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_temperaturerouteend, temperaturerouteendautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_temperaturerouteend = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_pulserateend, pulserateendautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_pulserateend =
    s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_respiratoryrateend, respiratoryrateendautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_respiratoryrateend = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_systolicbloodpressureend, sbpendautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_systolicbloodpressureend = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_diastolicbloodpressureend, dbpendautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_diastolicbloodpressureend = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_oxygensaturationend, oxygensatendautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_oxygensaturationend = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=volumeinfusedautotransfusion)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_volumeinfusedautotransfusion = s_tran_result, i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_albuminvol)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_albuminvol =
    s_tran_result, i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_cryoprecipitate)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_cryoprecipitate
     = s_tran_result
   ELSEIF (ce2.event_cd=mf_factorviia)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].sfactorviia =
    s_tran_result, i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_factorviiivol)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_factorviiivol =
    s_tran_result, i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_factorixcomplex)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_factorixcomplex
     = s_tran_result, i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_factorixvol)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_factorixvol =
    s_tran_result, i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_ffp)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_ffp =
    s_tran_result, i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_granulocytes)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_granulocytes =
    s_tran_result, i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_ivig)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_ivig =
    s_tran_result, i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_platelets)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_platelets =
    s_tran_result, i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_rbcvol)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_rbcvol =
    s_tran_result, i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_rhimmuneglobulin)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_rhimmuneglobulin
     = s_tran_result, i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_bloodproductamountinfused)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_bloodproductamountinfused = s_tran_result, i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_transfusionreactiondescription)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_transfusionreactiondescription = s_tran_result, i_reaction_cnt = (i_reaction_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_nursestatementofattestation)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_nursestatementofattestation = s_tran_result, i_witness_cnt = 1
   ELSEIF (ce2.event_cd=transfusiontime)
    temptime = replace(s_tran_result,"min",""),
    CALL echo(build("EE",cnvtint(temptime))),
    CALL echo(build("EE",temptime)),
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].transfusiontime =
    s_tran_result
    IF (cnvtint(temptime) > 0
     AND cnvtint(temptime) < 240)
     i_calcvalues_cnt = 1
    ENDIF
   ENDIF
  FOOT  ce2.event_cd
   stat = 0
  FOOT  ce.parent_event_id
   CALL echo(build("i_consent_cnt:",i_consent_cnt)),
   CALL echo(build("i_vital_cnt:",i_vital_cnt)),
   CALL echo(build("i_reaction_cnt:",i_reaction_cnt)),
   CALL echo(build("i_witness_cnt:",i_witness_cnt)),
   CALL echo(build("i_calcValues_cnt:",i_calcvalues_cnt))
   IF (i_consent_cnt=1
    AND i_vital_cnt=24
    AND i_infused_cnt > 0
    AND i_reaction_cnt=1
    AND i_witness_cnt=1
    AND i_calcvalues_cnt > 0)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_incompliance =
    "Yes", formscomplete = (formscomplete+ 1)
   ELSE
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_incompliance =
    "No", formsincomplete = (formsincomplete+ 1)
   ENDIF
   totalforms = (totalforms+ 1),
   CALL echo(build(totalforms))
  FOOT  name
   stat = 0
  FOOT  unit
   tottotalforms = (tottotalforms+ totalforms), totformscomplete = (totformscomplete+ formscomplete),
   totformsincomplete = (totformsincomplete+ formsincomplete)
   IF (( $PRINTTOTALS=1))
    tempcntpat = (size(forms->nurseunit[d.seq].patientslist,5)+ 1), stat = alterlist(forms->
     nurseunit[d.seq].patientslist,tempcntpat), tempcntform = (size(forms->nurseunit[d.seq].
     patientslist[tempcntpat].forminstanceslist,5)+ 1),
    stat = alterlist(forms->nurseunit[d.seq].patientslist[tempcntpat].forminstanceslist,tempcntform),
    forms->nurseunit[d.seq].patientslist[tempcntpat].s_person_name = "_", forms->nurseunit[d.seq].
    patientslist[tempcntpat].forminstanceslist[tempcntform].formname = "Total # of Forms",
    forms->nurseunit[d.seq].patientslist[tempcntpat].forminstanceslist[tempcntform].s_performed_on =
    cnvtstring(totalforms), forms->nurseunit[d.seq].patientslist[tempcntpat].forminstanceslist[
    tempcntform].s_consentsignedcurrentornotapplicable = "# complete", forms->nurseunit[d.seq].
    patientslist[tempcntpat].forminstanceslist[tempcntform].s_transfusionstarttime = concat(build(
      formscomplete)," / ",format(((formscomplete/ totalforms) * 100),"###.##"),"%"),
    forms->nurseunit[d.seq].patientslist[tempcntpat].forminstanceslist[tempcntform].
    s_temperaturestart = "# incomplete", forms->nurseunit[d.seq].patientslist[tempcntpat].
    forminstanceslist[tempcntform].s_temperatureroutestart = concat(build(formsincomplete)," / ",
     format(((formsincomplete/ totalforms) * 100),"###.##"),"%"), stat = alterlist(forms->nurseunit[
     d.seq].patientslist,(tempcntpat+ 1)),
    forms->nurseunit[d.seq].patientslist[(tempcntpat+ 1)].s_person_name = "__", stat = alterlist(
     forms->nurseunit[d.seq].patientslist[tempcntpat].forminstanceslist,(tempcntform+ 1))
   ENDIF
  FOOT REPORT
   IF ( NOT (reflect( $NURSEUNIT)="F8"))
    tempcntnurse = (size(forms->nurseunit,5)+ 1), stat = alterlist(forms->nurseunit,tempcntnurse),
    tempcntpat = (size(forms->nurseunit[tempcntnurse].patientslist,5)+ 1),
    stat = alterlist(forms->nurseunit[tempcntnurse].patientslist,tempcntpat), tempcntform = (size(
     forms->nurseunit[tempcntnurse].patientslist[tempcntpat].forminstanceslist,5)+ 1), stat =
    alterlist(forms->nurseunit[tempcntnurse].patientslist[tempcntpat].forminstanceslist,tempcntform),
    forms->nurseunit[tempcntnurse].patientslist[tempcntpat].s_person_name = "_", forms->nurseunit[
    tempcntnurse].patientslist[tempcntpat].s_finnbr = "HOSPITAL TOTALS:", forms->nurseunit[
    tempcntnurse].patientslist[tempcntpat].forminstanceslist[tempcntform].formname =
    "Total # of Forms",
    forms->nurseunit[tempcntnurse].patientslist[tempcntpat].forminstanceslist[tempcntform].
    s_performed_on = cnvtstring(tottotalforms), forms->nurseunit[tempcntnurse].patientslist[
    tempcntpat].forminstanceslist[tempcntform].s_consentsignedcurrentornotapplicable = "# complete",
    forms->nurseunit[tempcntnurse].patientslist[tempcntpat].forminstanceslist[tempcntform].
    s_transfusionstarttime = concat(build(totformscomplete)," / ",format(((totformscomplete/
      tottotalforms) * 100),"###.##"),"%"),
    forms->nurseunit[tempcntnurse].patientslist[tempcntpat].forminstanceslist[tempcntform].
    s_temperaturestart = "# incomplete", forms->nurseunit[tempcntnurse].patientslist[tempcntpat].
    forminstanceslist[tempcntform].s_temperatureroutestart = concat(build(totformsincomplete)," / ",
     format(((totformsincomplete/ tottotalforms) * 100),"###.##"),"%")
   ENDIF
  WITH nocounter, outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  ce.parent_event_id, ce.performed_dt_tm
  FROM (dummyt d  WITH seq = value(size(forms->nurseunit,5))),
   dummyt d1,
   dummyt d2,
   clinical_event ce,
   prsnl p
  PLAN (d
   WHERE maxrec(d1,size(forms->nurseunit[d.seq].patientslist,5)))
   JOIN (d1
   WHERE maxrec(d2,size(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist,5)))
   JOIN (d2)
   JOIN (ce
   WHERE (ce.encntr_id=forms->nurseunit[d.seq].patientslist[d1.seq].f_encntr_id)
    AND (ce.parent_event_id=forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].
   f_parent_event_id)
    AND ce.result_status_cd IN (mf_modified_cd, mf_auth_cd, mf_altered_cd))
   JOIN (p
   WHERE ce.performed_prsnl_id=p.person_id)
  ORDER BY ce.parent_event_id, ce.performed_dt_tm
  HEAD REPORT
   s_nurses = " "
  HEAD ce.parent_event_id
   i_first = 0, s_nurses = " "
  DETAIL
   IF (i_first=0)
    s_nurses = trim(p.name_full_formatted), forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_originalnurse = trim(p.name_full_formatted,3)
   ENDIF
   IF (i_first=1)
    IF (findstring(trim(p.name_full_formatted),s_nurses,1,1)=0)
     s_nurses = concat(s_nurses,",",trim(p.name_full_formatted))
    ENDIF
   ENDIF
   i_first = 1
  FOOT  ce.parent_event_id
   forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_nursesdocumented =
   s_nurses,
   CALL echo(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].f_parent_event_id
   ),
   CALL echo(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].
   s_nursesdocumented)
  WITH nocounter
 ;end select
 CALL echorecord(forms)
 SELECT INTO value(trim(var_output))
  nurseunit =
  IF ((forms->nurseunit[d.seq].patientslist[d1.seq].s_person_name IN ("_*"))) " "
  ELSE substring(1,30,trim(forms->nurseunit[d.seq].s_nurseunitname))
  ENDIF
  , patientname =
  IF ((forms->nurseunit[d.seq].patientslist[d1.seq].s_person_name IN ("_*"))) " "
  ELSE substring(1,30,trim(forms->nurseunit[d.seq].patientslist[d1.seq].s_person_name))
  ENDIF
  , finnumber = substring(1,20,trim(build2(forms->nurseunit[d.seq].patientslist[d1.seq].s_finnbr))),
  formname = substring(1,40,trim(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2
    .seq].formname)), performed_on = substring(1,25,forms->nurseunit[d.seq].patientslist[d1.seq].
   forminstanceslist[d2.seq].s_performed_on), allnursesthatdocumentedontheform = substring(1,100,trim
   (forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_nursesdocumented)),
  consentsignedcurrentdta = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_consentsignedcurrentornotapplicable)), transfusionstarttime =
  substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].
    s_transfusionstarttime)), temperaturestart = substring(1,25,trim(forms->nurseunit[d.seq].
    patientslist[d1.seq].forminstanceslist[d2.seq].s_temperaturestart)),
  temperatureroutestart = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_temperatureroutestart)), pulseratestart = substring(1,25,trim(forms->
    nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_pulseratestart)),
  respiratoryratestart = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_respiratoryratestart)),
  systolicbloodpressurestart = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_systolicbloodpressurestart)), diastolicbloodpressurestart = substring
  (1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].
    s_diastolicbloodpressurestart)), oxygensaturationstart = substring(1,25,trim(forms->nurseunit[d
    .seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_oxygensaturationstart)),
  transfusionstartplus15min = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_transfusionstartplus15min)), temperature15min = substring(1,25,trim(
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_temperature15min)),
  temperatureroute15min = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_temperatureroute15min)),
  pulserate15min = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_pulserate15min)), respiratoryrate15min = substring(1,25,trim(forms->
    nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_respiratoryrate15min)),
  systolicbloodpressure15min = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_systolicbloodpressure15min)),
  diastolicbloodpressure15min = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_diastolicbloodpressure15min)), oxygensaturation15min = substring(1,25,
   trim(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].
    s_oxygensaturation15min)), transfusionendtime = substring(1,25,trim(forms->nurseunit[d.seq].
    patientslist[d1.seq].forminstanceslist[d2.seq].s_transfusionendtime)),
  temperatureend = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_temperatureend)), temperaturerouteend = substring(1,25,trim(forms->
    nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_temperaturerouteend)),
  pulserateend = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[
    d2.seq].s_pulserateend)),
  respiratoryrateend = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_respiratoryrateend)), systolicbloodpressureend = substring(1,25,trim(
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_systolicbloodpressureend
    )), diastolicbloodpressureend = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_diastolicbloodpressureend)),
  oxygensaturationend = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_oxygensaturationend)), albuminvo = substring(1,25,trim(forms->
    nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_albuminvol)), cryoprecipitate
   = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].
    s_cryoprecipitate)),
  factorviia = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2
    .seq].sfactorviia)), factorviiivol = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1
    .seq].forminstanceslist[d2.seq].s_factorviiivol)), factorixcomplex = substring(1,25,trim(forms->
    nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_factorixcomplex)),
  factorixvol = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2
    .seq].s_factorixvol)), ffp = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_ffp)), granulocytes = substring(1,25,trim(forms->nurseunit[d.seq].
    patientslist[d1.seq].forminstanceslist[d2.seq].s_granulocytes)),
  ivig = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].
    s_ivig)), platelets = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_platelets)), rbcvol = substring(1,25,trim(forms->nurseunit[d.seq].
    patientslist[d1.seq].forminstanceslist[d2.seq].s_rbcvol)),
  rhimmuneglobulin = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_rhimmuneglobulin)), bloodproductamountinfused = substring(1,25,trim(
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].
    s_bloodproductamountinfused)), transfusiontime = substring(1,10,trim(forms->nurseunit[d.seq].
    patientslist[d1.seq].forminstanceslist[d2.seq].transfusiontime)),
  transfusionreactiondescription = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_transfusionreactiondescription)), incompliance = substring(1,25,trim(
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_incompliance)),
  originalnurse = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[
    d2.seq].s_originalnurse)),
  nursestatementofattestation = substring(1,50,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_nursestatementofattestation))
  FROM (dummyt d  WITH seq = size(forms->nurseunit,5)),
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1)
  PLAN (d
   WHERE maxrec(d1,size(forms->nurseunit[d.seq].patientslist,5)))
   JOIN (d1
   WHERE maxrec(d2,size(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist,5))
    AND size(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist,3) > 0)
   JOIN (d2)
  WITH nocounter, format, pcformat(value(filedelimiter1),value(filedelimiter2)),
   time = 300
 ;end select
 IF (emailind=1)
  CALL emailfile(var_output,var_output, $EMAILADD,concat("Transfusion Quality Stat Report - ",format(
     cnvtdatetime(curdate,curtime),";;q")," - ",curprog),0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = concat("File has been emailed to: ", $EMAILADD), col 0, "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08
  ;end select
 ENDIF
#exit_program
END GO

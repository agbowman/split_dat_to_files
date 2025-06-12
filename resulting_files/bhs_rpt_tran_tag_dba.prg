CREATE PROGRAM bhs_rpt_tran_tag:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility:" = 673936.00,
  "Nurse Unit :" = 0,
  "Begin dt/tm:" = "CURDATE",
  "End dt/tm" = "CURDATE",
  "Email Address:" = "",
  "Form Type:" = "TRANSFUSIONTAGFORM",
  "Print Unit Totals:" = 1
  WITH outdev, facility, nurseunit,
  bdate, edate, emailadd,
  formtype, printtotals
 EXECUTE bhs_sys_stand_subroutine
 DECLARE mf_iftransfusiontimeis241minexplain = f8 WITH protect, constant(validatecodevalue(
   "DISPLAYKEY",72,"IFTRANSFUSIONTIMEIS241MINEXPLAIN"))
 DECLARE mf_factorunitofmeasure = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "FACTORUNITOFMEASURE"))
 DECLARE mf_factordosegiven = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "FACTORDOSEGIVEN"))
 DECLARE mf_transfusiontimetocompletion = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "TRANSFUSIONTIMETOCOMPLETION"))
 DECLARE mf_bloodproductcomment = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "BLOODPRODUCTCOMMENT"))
 DECLARE mf_transfusiontagform = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "TRANSFUSIONTAGFORM"))
 DECLARE autotransfusionbloodrecoveryform = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",
   72,"AUTOTRANSFUSIONBLOODRECOVERYFORM"))
 DECLARE mf_consentsignedcurrentornotapplicable = f8 WITH protect, constant(validatecodevalue(
   "DISPLAYKEY",72,"CONSENTSIGNEDCURRENTORNOTAPPLICABLE"))
 DECLARE autotransfusiondataverification = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",
   72,"AUTOTRANSFUSIONDATAVERIFICATION"))
 DECLARE transfusiondataverification = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "TRANSFUSIONDATAVERIFICATION"))
 DECLARE mf_transfusionstarttime = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "TRANSFUSIONSTARTTIME"))
 DECLARE autotransfusionstarttime = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "AUTOTRANSFUSIONSTARTTIME"))
 DECLARE mf_temperaturestart = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "TEMPERATURESTART"))
 DECLARE mf_temperatureroutestart = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "TEMPERATUREROUTESTART"))
 DECLARE mf_pulseratestart = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "PULSERATESTART"))
 DECLARE mf_respiratoryratestart = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "RESPIRATORYRATESTART"))
 DECLARE mf_systolicbloodpressurestart = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURESTART"))
 DECLARE sbpstartautotransfusion = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "SBPSTARTAUTOTRANSFUSION"))
 DECLARE mf_diastolicbloodpressurestart = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURESTART"))
 DECLARE dbpstartautotransfusion = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "DBPSTARTAUTOTRANSFUSION"))
 DECLARE mf_oxygensaturationstart = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "OXYGENSATURATIONSTART"))
 DECLARE temperaturestartautotransfusion = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",
   72,"TEMPERATURESTARTAUTOTRANSFUSION"))
 DECLARE temperatureroutestartautotransfusion = f8 WITH protect, constant(validatecodevalue(
   "DISPLAYKEY",72,"TEMPERATUREROUTESTARTAUTOTRANSFUSION"))
 DECLARE pulseratestartautotransfusion = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "PULSERATESTARTAUTOTRANSFUSION"))
 DECLARE respiratoryratestartautotransfusion = f8 WITH protect, constant(validatecodevalue(
   "DISPLAYKEY",72,"RESPIRATORYRATESTARTAUTOTRANSFUSION"))
 DECLARE oxygensatstartautotransfusion = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "OXYGENSATSTARTAUTOTRANSFUSION"))
 DECLARE mf_transfusionstartplus15min = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "TRANSFUSIONSTARTPLUS15MIN"))
 DECLARE mf_temperature15min = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "TEMPERATURE15MIN"))
 DECLARE mf_temperatureroute15min = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "TEMPERATUREROUTE15MIN"))
 DECLARE mf_pulserate15min = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "PULSERATE15MIN"))
 DECLARE mf_respiratoryrate15min = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "RESPIRATORYRATE15MIN"))
 DECLARE mf_systolicbloodpressure15min = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE15MIN"))
 DECLARE sbp15minautotransfusion = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "SBP15MINAUTOTRANSFUSION"))
 DECLARE dbp15minautotransfusion = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "DBP15MINAUTOTRANSFUSION"))
 DECLARE mf_oxygensaturation15min = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "OXYGENSATURATION15MIN"))
 DECLARE autotransfusionstartplus15min = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "AUTOTRANSFUSIONSTARTPLUS15MIN"))
 DECLARE temperature15minautotransfusion = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",
   72,"TEMPERATURE15MINAUTOTRANSFUSION"))
 DECLARE temperatureroute15minautotransfusion = f8 WITH protect, constant(validatecodevalue(
   "DISPLAYKEY",72,"TEMPERATUREROUTE15MINAUTOTRANSFUSION"))
 DECLARE pulserate15minautotransfusion = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "PULSERATE15MINAUTOTRANSFUSION"))
 DECLARE respiratoryrate15minautotransfusion = f8 WITH protect, constant(validatecodevalue(
   "DISPLAYKEY",72,"RESPIRATORYRATE15MINAUTOTRANSFUSION"))
 DECLARE mf_diastolicbloodpressure15min = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE15MIN"))
 DECLARE oxygensat15minautotransfusion = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "OXYGENSAT15MINAUTOTRANSFUSION"))
 DECLARE mf_transfusionendtime = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "TRANSFUSIONENDTIME"))
 DECLARE autotransfusionstoptime = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "AUTOTRANSFUSIONSTOPTIME"))
 DECLARE mf_temperatureend = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "TEMPERATUREEND"))
 DECLARE mf_temperaturerouteend = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "TEMPERATUREROUTEEND"))
 DECLARE mf_pulserateend = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,"PULSERATEEND"
   ))
 DECLARE mf_respiratoryrateend = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "RESPIRATORYRATEEND"))
 DECLARE mf_systolicbloodpressureend = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSUREEND"))
 DECLARE sbpendautotransfusion = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "SBPENDAUTOTRANSFUSION"))
 DECLARE mf_diastolicbloodpressureend = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSUREEND"))
 DECLARE dbpendautotransfusion = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "DBPENDAUTOTRANSFUSION"))
 DECLARE mf_oxygensaturationend = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "OXYGENSATURATIONEND"))
 DECLARE oxygensatendautotransfusion = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "OXYGENSATENDAUTOTRANSFUSION"))
 DECLARE temperatureendautotransfusion = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "TEMPERATUREENDAUTOTRANSFUSION"))
 DECLARE temperaturerouteendautotransfusion = f8 WITH protect, constant(validatecodevalue(
   "DISPLAYKEY",72,"TEMPERATUREROUTEENDAUTOTRANSFUSION"))
 DECLARE pulserateendautotransfusion = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "PULSERATEENDAUTOTRANSFUSION"))
 DECLARE respiratoryrateendautotransfusion = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",
   72,"RESPIRATORYRATEENDAUTOTRANSFUSION"))
 DECLARE volumeinfusedautotransfusion = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "VOLUMEINFUSEDAUTOTRANSFUSION"))
 DECLARE mf_bloodproducttransfused = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "BLOODPRODUCTTRANSFUSED"))
 DECLARE mf_albuminvol = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,"ALBUMINVOL"))
 DECLARE mf_cryoprecipitate = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "CRYOPRECIPITATE"))
 DECLARE mf_factorviianovoseven = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "FACTORVIIA"))
 DECLARE mf_factorviiihumanhumatepvol = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "FACTORVIIIVOL"))
 DECLARE mf_3factorprothrombincomplexconcentrate = f8 WITH protect, constant(validatecodevalue(
   "DISPLAY",72,"factor IX complex"))
 DECLARE mf_factorixrecombinant = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "FACTORIXVOL"))
 DECLARE mf_ffp = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,"FFP"))
 DECLARE mf_granulocytes = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,"GRANULOCYTES"
   ))
 DECLARE mf_ivig = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,"IVIG"))
 DECLARE mf_platelets = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,"PLATELETS"))
 DECLARE mf_rbcvol = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,"RBCVOL"))
 DECLARE mf_rhimmuneglobuliniv = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "RHIMMUNEGLOBULINIV"))
 DECLARE mf_rhimmuneglobulinim = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "RHIMMUNEGLOBULINIM"))
 DECLARE mf_bloodproductamountinfused = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "BLOODPRODUCTAMOUNTINFUSED"))
 DECLARE mf_transfusionreactiondescription = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",
   72,"TRANSFUSIONREACTIONDESCRIPTION"))
 DECLARE mf_nurseattestationwitnessed = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "NURSEATTESTATIONWITNESSED"))
 DECLARE mf_nursestatementofattestation = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "NURSESTATEMENTOFATTESTATION"))
 DECLARE transfusiontime = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "TRANSFUSIONTIME"))
 DECLARE mf_finnbr = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(validatecodevalue("MEANING",8,"ALTERED"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(validatecodevalue("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(validatecodevalue("MEANING",8,"MODIFIED"))
 DECLARE mf_unit_id_lot_num_adtnl_unit_cd = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",
   72,"UNITIDNUMBERLOTNUMBER2"))
 DECLARE mf_unit_id_lot_num_cd = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "UNITIDNUMBERLOTNUMBER"))
 DECLARE mf_red_cell_bag_lot_num_cd = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "REDCELLBAGLOTNUMBER"))
 DECLARE mf_bptrans_witreqd_cd = f8 WITH protect, constant(validatecodevalue("DESCRIPTION",72,
   "Blood Products Transfused-RN Wit Reqd"))
 DECLARE mf_bptrans_witnotreqd_cd = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "BLOODPRODUCTSTRANSFUSEDRNWITNOTREQD"))
 DECLARE ms_email_list = vc WITH protect, noconstant( $EMAILADD)
 DECLARE ms_facility_name = vc WITH protect, noconstant(" ")
 DECLARE ms_nursingunit_name = vc WITH protect, noconstant(" ")
 DECLARE line1 = vc WITH protect, noconstant(" ")
 DECLARE nurseunit = vc WITH protect, noconstant(" ")
 DECLARE patientname = vc WITH protect, noconstant(" ")
 DECLARE finnumber = vc WITH protect, noconstant(" ")
 DECLARE formname = vc WITH protect, noconstant(" ")
 DECLARE allnursesthatdocumentedontheform = vc WITH protect, noconstant(" ")
 DECLARE consentsignedcurrentdta = vc WITH protect, noconstant(" ")
 DECLARE transfusionstarttime = vc WITH protect, noconstant(" ")
 DECLARE temperaturestart = vc WITH protect, noconstant(" ")
 DECLARE temperatureroutestart = vc WITH protect, noconstant(" ")
 DECLARE pulseratestart = vc WITH protect, noconstant(" ")
 DECLARE respiratoryratestart = vc WITH protect, noconstant(" ")
 DECLARE systolicbloodpressurestart = vc WITH protect, noconstant(" ")
 DECLARE diastolicbloodpressurestart = vc WITH protect, noconstant(" ")
 DECLARE oxygensaturationstart = vc WITH protect, noconstant(" ")
 DECLARE transfusionstartplus15min = vc WITH protect, noconstant(" ")
 DECLARE temperature15min = vc WITH protect, noconstant(" ")
 DECLARE temperatureroute15min = vc WITH protect, noconstant(" ")
 DECLARE pulserate15min = vc WITH protect, noconstant(" ")
 DECLARE respiratoryrate15min = vc WITH protect, noconstant(" ")
 DECLARE systolicbloodpressure15min = vc WITH protect, noconstant(" ")
 DECLARE diastolicbloodpressure15min = vc WITH protect, noconstant(" ")
 DECLARE oxygensaturation15min = vc WITH protect, noconstant(" ")
 DECLARE transfusionendtime = vc WITH protect, noconstant(" ")
 DECLARE temperatureend = vc WITH protect, noconstant(" ")
 DECLARE temperaturerouteend = vc WITH protect, noconstant(" ")
 DECLARE pulserateend = vc WITH protect, noconstant(" ")
 DECLARE respiratoryrateend = vc WITH protect, noconstant(" ")
 DECLARE systolicbloodpressureend = vc WITH protect, noconstant(" ")
 DECLARE diastolicbloodpressureend = vc WITH protect, noconstant(" ")
 DECLARE oxygensaturationend = vc WITH protect, noconstant(" ")
 DECLARE bloodproducttransfused = vc WITH protect, noconstant(" ")
 DECLARE albuminvo = vc WITH protect, noconstant(" ")
 DECLARE cryoprecipitate = vc WITH protect, noconstant(" ")
 DECLARE factorviianovoseven = vc WITH protect, noconstant(" ")
 DECLARE factorviiihumanvol = vc WITH protect, noconstant(" ")
 DECLARE 3factorprothrombincomplexconcentrate = vc WITH protect, noconstant(" ")
 DECLARE factorixrecombinant = vc WITH protect, noconstant(" ")
 DECLARE ffp = vc WITH protect, noconstant(" ")
 DECLARE granulocytes = vc WITH protect, noconstant(" ")
 DECLARE ivig = vc WITH protect, noconstant(" ")
 DECLARE platelets = vc WITH protect, noconstant(" ")
 DECLARE rbcvol = vc WITH protect, noconstant(" ")
 DECLARE rhimmuneglobulinim = vc WITH protect, noconstant(" ")
 DECLARE rhimmuneglobuliniv = vc WITH protect, noconstant(" ")
 DECLARE bloodproductamountinfused = vc WITH protect, noconstant(" ")
 DECLARE transfusionreactiondescription = vc WITH protect, noconstant(" ")
 DECLARE incompliance = vc WITH protect, noconstant(" ")
 DECLARE originalnurse = vc WITH protect, noconstant(" ")
 DECLARE nursestatementofattestation = vc WITH protect, noconstant(" ")
 DECLARE performed_on = vc WITH protect, noconstant(" ")
 DECLARE volumeinfused = vc WITH protect, noconstant(" ")
 DECLARE ms_data_type = vc WITH protect, noconstant(" ")
 DECLARE ms_fac = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_tmp_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_bmc = f8 WITH protect, noconstant(0)
 DECLARE mf_bfmc = f8 WITH protect, noconstant(0)
 DECLARE nurseunitcd = f8 WITH protect, noconstant(0)
 DECLARE md_begin = dq8 WITH protect, noconstant(0)
 DECLARE md_end = dq8 WITH protect, noconstant(0)
 DECLARE mf_istransfusiontime241minutes = f8 WITH protect, noconstant(0)
 DECLARE unit_cnt = i4 WITH noconstant(0)
 DECLARE patient_cnt = i4 WITH noconstant(0)
 FREE RECORD nunit
 RECORD nunit(
   1 l_cnt = i4
   1 list[*]
     2 f_unit_cd = f8
     2 s_unit_name = vc
 ) WITH protect
 FREE RECORD aunit
 RECORD aunit(
   1 l_cnt = i4
   1 list[*]
     2 s_unit_display_key = vc
 ) WITH protect
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
         4 s_bloodproductcomment = vc
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
         4 s_bloodproducttransfused = vc
         4 s_albuminvol = vc
         4 s_cryoprecipitate = vc
         4 s_factorviianovoseven = vc
         4 s_factorviiihumanhumatepvol = vc
         4 s_3factorprothrombincomplexconcentrate = vc
         4 s_factorixrecombinant = vc
         4 s_ffp = vc
         4 s_granulocytes = vc
         4 s_ivig = vc
         4 s_platelets = vc
         4 s_rbcvol = vc
         4 s_rhimmuneglobulinim = vc
         4 s_rhimmuneglobuliniv = vc
         4 s_bloodproductamountinfused = vc
         4 s_volumeinfusedautotransfusion = vc
         4 s_transfusionreactiondescription = vc
         4 s_incompliance = vc
         4 s_originalnurse = vc
         4 s_nursestatementofattestation = vc
         4 s_unit_id_lot_num = vc
         4 s_unit_id_lot_num_adtnl_unit = vc
         4 s_red_cell_bag_lot_num = vc
         4 transfusiontime = vc
         4 s_factorunitofmeasure = vc
         4 s_factordosegiven = vc
         4 s_istransfusiontime241minutes = vc
         4 s_iftransfusiontimeis241minexplain = vc
         4 s_transfusiontimetocompletion = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=72
    AND cv.active_ind=1
    AND cv.display_key="ISTRANSFUSIONTIME241MINUTES"
    AND cv.display="Is Transfusion Time > 241 minutes?")
  DETAIL
   mf_istransfusiontime241minutes = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=220
   AND c.cdf_meaning="FACILITY"
   AND c.display_key IN ("BFMC", "BMC")
   AND c.active_ind=1
   AND c.data_status_cd=25
  DETAIL
   IF (c.display_key="BMC")
    mf_bmc = c.code_value
   ELSEIF (c.display_key="BFMC")
    mf_bfmc = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (( $BDATE="OPSJOB"))
  SET md_begin = cnvtdatetime((curdate - 7),000000)
  SET md_end = cnvtdatetime(curdate,235959)
 ELSEIF (( $BDATE="M"))
  SET md_begin = cnvtlookbehind("1,M",cnvtdatetime(curdate,000000))
  SET md_end = cnvtlookbehind("1,M",cnvtdatetime((curdate+ 13),235959))
 ELSE
  SET md_begin = cnvtdatetime(cnvtdate2( $BDATE,"DD-MMM-YYYY"),000000)
  SET md_end = cnvtdatetime(cnvtdate2( $EDATE,"DD-MMM-YYYY"),235959)
 ENDIF
 IF (datetimediff(md_end,md_begin) > 31)
  CALL echo("Date range > 31")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is larger than 31 days.", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,18)), msg1, row + 2,
    msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_program
 ELSEIF (datetimediff(md_end,md_begin) < 0)
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
 IF (((findstring("@", $EMAILADD) > 0) OR (( $EMAILADD="OPSJOB"))) )
  SET emailind = 1
  SET var_output = "trans_qual_stat_report.csv"
  SET filedelimiter1 = '"'
  SET filedelimiter2 = ","
  IF (( $EMAILADD="OPSJOB")
   AND ( $BDATE="OPSJOB"))
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="BHS_RPT_TRAN_TAG"
     AND di.info_char="W"
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt += 1
     IF (cnt=1)
      ms_email_list = trim(di.info_name)
     ELSE
      ms_email_list = concat(ms_email_list,", ",trim(di.info_name))
     ENDIF
    WITH nocounter
   ;end select
  ELSEIF (( $EMAILADD="OPSJOB")
   AND ( $BDATE="M"))
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="BHS_RPT_TRAN_TAG"
     AND di.info_char="M"
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt += 1
     IF (cnt=1)
      ms_email_list = trim(di.info_name)
     ELSE
      ms_email_list = concat(ms_email_list,", ",trim(di.info_name))
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SET emailind = 0
  SET var_output =  $OUTDEV
  SET filedelimiter1 = ""
  SET filedelimiter2 = ""
 ENDIF
 CALL echo(ms_email_list)
 SELECT INTO "nl:"
  FROM dm_info au
  WHERE au.info_domain="BHS_AMBULATORY_UNIT"
  HEAD REPORT
   aunit->l_cnt = 0
  DETAIL
   aunit->l_cnt += 1, stat = alterlist(aunit->list,aunit->l_cnt), aunit->list[aunit->l_cnt].
   s_unit_display_key = au.info_name
  WITH nocounter
 ;end select
 SET ms_data_type = reflect(parameter(2,0))
 IF (substring(1,2,ms_data_type)="C1")
  SET ms_fac = "el.loc_facility_cd in ("
  SELECT INTO "nl:"
   FROM code_value c
   WHERE c.code_set=220
    AND c.cdf_meaning="FACILITY"
    AND c.display_key IN ("CTRCACARE", "BFMC", "BFMCINPTPSYCH", "BMLH", "BMC",
   "BMCINPTPSYCH", "BWH", "BWHINPTPSYCH")
    AND c.active_ind=1
    AND c.data_status_cd=25
   DETAIL
    ml_tmp_cnt += 1
    IF (ml_tmp_cnt=1)
     ms_fac = build2(ms_fac,trim(cnvtstring(c.code_value)))
    ELSE
     ms_fac = build2(ms_fac,", ",trim(cnvtstring(c.code_value)))
    ENDIF
   WITH nocounter
  ;end select
  SET ms_fac = concat(ms_fac,")")
 ELSEIF (substring(1,1,ms_data_type)="C")
  IF (trim( $FACILITY)="BMC")
   SET ms_fac = concat("el.loc_facility_cd = ",trim(cnvtstring(mf_bmc)))
  ELSEIF (trim( $FACILITY)="BFMC")
   SET ms_fac = concat("el.loc_facility_cd = ",trim(cnvtstring(mf_bfmc)))
  ENDIF
 ELSE
  SET ms_fac = concat("el.loc_facility_cd = ",trim(cnvtstring( $FACILITY)))
 ENDIF
 IF (substring(1,1,reflect(parameter(3,0)))="C")
  SET nurseunitcd = 0
 ELSE
  SET nurseunitcd = 1
  SELECT INTO "nl:"
   FROM code_value cv,
    code_value cv1
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.cdf_meaning="FACILITY"
     AND cv.display_key IN ("CTRCACARE", "BFMC", "BFMCINPTPSYCH", "BMLH", "BMC",
    "BMCINPTPSYCH", "BWH", "BWHINPTPSYCH")
     AND cv.active_ind=1
     AND cv.inactive_dt_tm=null)
    JOIN (cv1
    WHERE (cv1.code_value= $NURSEUNIT)
     AND cv1.code_set=220
     AND cv1.active_ind=1
     AND ((cv1.cdf_meaning="NURSEUNIT") OR (((cv1.cdf_meaning="AMBULATORY"
     AND expand(ml_cnt,1,aunit->l_cnt,cv1.display_key,aunit->list[ml_cnt].s_unit_display_key)) OR (((
    cv1.cdf_meaning="AMBULATORY"
     AND cv1.display_key="BFMCONCOLOGY"
     AND cv.display_key="BFMC") OR (cv1.cdf_meaning="AMBULATORY"
     AND cv1.display_key="S15MED"
     AND cv.display_key="BMC")) )) )) )
   ORDER BY cv1.display
   HEAD REPORT
    nunit->l_cnt = 0
   DETAIL
    nunit->l_cnt += 1, stat = alterlist(nunit->list,nunit->l_cnt), nunit->list[nunit->l_cnt].
    f_unit_cd = cv1.code_value,
    nunit->list[nunit->l_cnt].s_unit_name = cv1.display
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  nurse_unit = uar_get_code_display(el.loc_nurse_unit_cd)
  FROM dcp_forms_ref dfr,
   dcp_forms_activity dfa,
   encntr_alias ea,
   person p,
   encntr_loc_hist el,
   encounter e
  PLAN (dfr
   WHERE dfr.end_effective_dt_tm >= cnvtdatetime(md_begin)
    AND dfr.beg_effective_dt_tm <= cnvtdatetime(md_end)
    AND dfr.definition IN ("Transfusion Tag Form - BHS", "Autotransfusion/Blood Recovery Form - BHS")
   )
   JOIN (dfa
   WHERE dfa.dcp_forms_ref_id=dfr.dcp_forms_ref_id
    AND dfa.updt_dt_tm >= cnvtdatetime(md_begin))
   JOIN (ea
   WHERE ea.encntr_id=dfa.encntr_id
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=mf_finnbr)
   JOIN (el
   WHERE el.encntr_id=ea.encntr_id
    AND el.active_ind=1
    AND el.end_effective_dt_tm >= dfa.version_dt_tm
    AND el.beg_effective_dt_tm <= dfa.version_dt_tm
    AND ((nurseunitcd=1
    AND expand(ml_cnt,1,nunit->l_cnt,el.loc_nurse_unit_cd,nunit->list[ml_cnt].f_unit_cd)) OR (
   nurseunitcd=0
    AND parser(ms_fac))) )
   JOIN (e
   WHERE e.encntr_id=el.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
  ORDER BY nurse_unit, el.encntr_id, p.name_full_formatted
  HEAD REPORT
   i_nurseunit_cnt = 0, i_patient_cnt = 0, ms_facility_name = uar_get_code_display(el.loc_facility_cd
    ),
   ms_nursingunit_name = uar_get_code_display(el.loc_nurse_unit_cd)
  HEAD nurse_unit
   i_patient_cnt = 0, i_nurseunit_cnt += 1,
   CALL alterlist(forms->nurseunit,i_nurseunit_cnt),
   forms->nurseunit[i_nurseunit_cnt].s_nurseunitname = trim(uar_get_code_display(el.loc_nurse_unit_cd
     ),3), forms->nurseunit[i_nurseunit_cnt].f_nurseunit_cd = el.loc_nurse_unit_cd
  HEAD el.encntr_id
   IF (dfa.beg_activity_dt_tm BETWEEN el.beg_effective_dt_tm AND el.end_effective_dt_tm)
    i_patient_cnt += 1
    IF (i_patient_cnt > size(forms->nurseunit[i_nurseunit_cnt].patientslist,5))
     CALL alterlist(forms->nurseunit[i_nurseunit_cnt].patientslist,(i_patient_cnt+ 10))
    ENDIF
    forms->nurseunit[i_nurseunit_cnt].patientslist[i_patient_cnt].f_encntr_id = el.encntr_id, forms->
    nurseunit[i_nurseunit_cnt].patientslist[i_patient_cnt].f_person_id = e.person_id, forms->
    nurseunit[i_nurseunit_cnt].patientslist[i_patient_cnt].s_person_name = p.name_full_formatted,
    forms->nurseunit[i_nurseunit_cnt].patientslist[i_patient_cnt].s_finnbr = check(trim(ea.alias,3))
   ENDIF
  FOOT  nurse_unit
   CALL alterlist(forms->nurseunit[i_nurseunit_cnt].patientslist,i_patient_cnt)
   IF (size(forms->nurseunit[i_nurseunit_cnt].patientslist,5) <= 0)
    i_nurseunit_cnt -= 1,
    CALL alterlist(forms->nurseunit,i_nurseunit_cnt)
   ELSE
    CALL alterlist(forms->nurseunit[i_nurseunit_cnt].patientslist,i_patient_cnt)
   ENDIF
  WITH nocounter
 ;end select
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
  d.seq, name = substring(1,50,trim(forms->nurseunit[d.seq].patientslist[d1.seq].s_person_name,3)),
  ce.parent_event_id,
  ce2.event_cd
  FROM (dummyt d  WITH seq = value(size(forms->nurseunit,5))),
   dummyt d1,
   dummyt d2,
   clinical_event ce,
   clinical_event ce1,
   clinical_event ce2,
   clinical_event ce3,
   ce_date_result cedr,
   prsnl pr
  PLAN (d
   WHERE maxrec(d1,size(forms->nurseunit[d.seq].patientslist,5)))
   JOIN (d1)
   JOIN (ce
   WHERE (ce.encntr_id=forms->nurseunit[d.seq].patientslist[d1.seq].f_encntr_id)
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(md_begin) AND cnvtdatetime(md_end)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce.result_status_cd IN (mf_modified_cd, mf_auth_cd, mf_altered_cd)
    AND ((ce.performed_dt_tm+ 0) BETWEEN cnvtdatetime(md_begin) AND cnvtdatetime(md_end))
    AND ((((ce.event_cd+ 0)=mf_transfusiontagform)
    AND ( $FORMTYPE IN ("TRANSFUSIONTAGFORM", "BOTH"))) OR (ce.event_cd=
   autotransfusionbloodrecoveryform
    AND ( $FORMTYPE IN ("AUTOTRANSFUSIONBLOODRECOVERYFORM", "BOTH")))) )
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
   mf_bloodproducttransfused, mf_albuminvol, mf_cryoprecipitate, mf_factorviianovoseven,
   mf_factorviiihumanhumatepvol,
   mf_3factorprothrombincomplexconcentrate, mf_factorixrecombinant, mf_ffp, mf_granulocytes, mf_ivig,
   mf_platelets, mf_rbcvol, mf_rhimmuneglobuliniv, mf_rhimmuneglobulinim,
   mf_bloodproductamountinfused,
   volumeinfusedautotransfusion, mf_transfusionreactiondescription, mf_nursestatementofattestation,
   transfusiontime, mf_bloodproductcomment,
   mf_unit_id_lot_num_cd, mf_unit_id_lot_num_adtnl_unit_cd, mf_red_cell_bag_lot_num_cd,
   mf_factorunitofmeasure, mf_factordosegiven,
   mf_iftransfusiontimeis241minexplain, mf_istransfusiontime241minutes,
   mf_transfusiontimetocompletion, mf_bptrans_witreqd_cd, mf_bptrans_witnotreqd_cd))
   JOIN (pr
   WHERE pr.person_id=ce2.performed_prsnl_id)
   JOIN (cedr
   WHERE (cedr.event_id= Outerjoin(ce2.event_id)) )
   JOIN (d2)
   JOIN (ce3
   WHERE ce3.parent_event_id=ce2.event_id
    AND ce3.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce3.result_status_cd IN (mf_modified_cd, mf_auth_cd, mf_altered_cd)
    AND ce3.event_cd IN (mf_consentsignedcurrentornotapplicable))
  ORDER BY d.seq, name, ce.parent_event_id,
   ce2.event_cd DESC
  HEAD REPORT
   totformscomplete = 0.0, totformsincomplete = 0.0, tottotalforms = 0.0
  HEAD d.seq
   totalforms = 0.0, formscomplete = 0.0, formsincomplete = 0.0,
   unitcomplince = 0.0
  HEAD name
   i_instance_cnt = 0, i_consent_cnt = 0, i_vital_cnt = 0,
   i_infused_cnt = 0, i_reaction_cnt = 0, i_witness_cnt = 0,
   i_calcvalues_cnt = 0
  HEAD ce.parent_event_id
   i_trandta_cnt = 0, i_consent_cnt = 0, i_vital_cnt = 0,
   i_infused_cnt = 0, i_reaction_cnt = 0, i_witness_cnt = 0,
   i_calcvalues_cnt = 0, i_instance_cnt += 1,
   CALL alterlist(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist,i_instance_cnt),
   forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].f_parent_event_id
    = ce.parent_event_id, forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[
   i_instance_cnt].formname = uar_get_code_display(ce.event_cd), forms->nurseunit[d.seq].
   patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_performed_on = build(format(ce
     .performed_dt_tm,";;q"))
  HEAD ce2.event_cd
   IF (ce2.event_cd=mf_nursestatementofattestation)
    s_tran_result = build2(trim(ce2.event_tag)," (",trim(pr.name_full_formatted),")")
   ELSEIF (cedr.event_id > 0)
    s_tran_result = format(cnvtdatetime(cedr.result_dt_tm),";;q")
   ELSE
    s_tran_result = build2(trim(ce2.event_tag)," ",trim(uar_get_code_display(ce2.result_units_cd)))
   ENDIF
   IF (ce3.event_cd=mf_consentsignedcurrentornotapplicable)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_consentsignedcurrentornotapplicable = ce3.event_tag, i_consent_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_transfusionstarttime, autotransfusionstarttime))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_transfusionstarttime = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_temperaturestart, temperaturestartautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_temperaturestart
     = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_temperatureroutestart, temperatureroutestartautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_temperatureroutestart = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_pulseratestart, pulseratestartautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_pulseratestart
     = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_respiratoryratestart, respiratoryratestartautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_respiratoryratestart = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_systolicbloodpressurestart, sbpstartautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_systolicbloodpressurestart = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_diastolicbloodpressurestart, dbpstartautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_diastolicbloodpressurestart = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_oxygensaturationstart, oxygensatstartautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_oxygensaturationstart = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_transfusionstartplus15min, autotransfusionstartplus15min))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_transfusionstartplus15min = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_temperature15min, temperature15minautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_temperature15min
     = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_temperatureroute15min, temperatureroute15minautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_temperatureroute15min = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_pulserate15min, pulserate15minautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_pulserate15min
     = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_respiratoryrate15min, respiratoryrate15minautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_respiratoryrate15min = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_systolicbloodpressure15min, sbp15minautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_systolicbloodpressure15min = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_diastolicbloodpressure15min, dbp15minautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_diastolicbloodpressure15min = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_oxygensaturation15min, oxygensat15minautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_oxygensaturation15min = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_transfusionendtime, autotransfusionstoptime))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_transfusionendtime = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_temperatureend, temperatureendautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_temperatureend
     = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_temperaturerouteend, temperaturerouteendautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_temperaturerouteend = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_pulserateend, pulserateendautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_pulserateend =
    s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_respiratoryrateend, respiratoryrateendautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_respiratoryrateend = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_systolicbloodpressureend, sbpendautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_systolicbloodpressureend = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_diastolicbloodpressureend, dbpendautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_diastolicbloodpressureend = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_oxygensaturationend, oxygensatendautotransfusion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_oxygensaturationend = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_bloodproducttransfused, mf_bptrans_witreqd_cd,
   mf_bptrans_witnotreqd_cd))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_bloodproducttransfused = s_tran_result
   ELSEIF (ce2.event_cd=mf_albuminvol)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_albuminvol =
    s_tran_result, i_infused_cnt += 1
   ELSEIF (ce2.event_cd=mf_cryoprecipitate)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_cryoprecipitate
     = s_tran_result, i_infused_cnt += 1
   ELSEIF (ce2.event_cd=mf_factorviianovoseven)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_factorviianovoseven = s_tran_result, i_infused_cnt += 1
   ELSEIF (ce2.event_cd=mf_factorviiihumanhumatepvol)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_factorviiihumanhumatepvol = s_tran_result, i_infused_cnt += 1
   ELSEIF (ce2.event_cd=mf_3factorprothrombincomplexconcentrate)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_3factorprothrombincomplexconcentrate = s_tran_result, i_infused_cnt += 1
   ELSEIF (ce2.event_cd=mf_factorixrecombinant)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_factorixrecombinant = s_tran_result, i_infused_cnt += 1
   ELSEIF (ce2.event_cd=mf_ffp)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_ffp =
    s_tran_result, i_infused_cnt += 1
   ELSEIF (ce2.event_cd=mf_granulocytes)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_granulocytes =
    s_tran_result, i_infused_cnt += 1
   ELSEIF (ce2.event_cd=mf_ivig)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_ivig =
    s_tran_result, i_infused_cnt += 1
   ELSEIF (ce2.event_cd=mf_platelets)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_platelets =
    s_tran_result, i_infused_cnt += 1
   ELSEIF (ce2.event_cd=mf_rbcvol)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_rbcvol =
    s_tran_result, i_infused_cnt += 1
   ELSEIF (ce2.event_cd=mf_rhimmuneglobulinim)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_rhimmuneglobulinim = s_tran_result, i_infused_cnt += 1
   ELSEIF (ce2.event_cd=mf_rhimmuneglobuliniv)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_rhimmuneglobuliniv = s_tran_result, i_infused_cnt += 1
   ELSEIF (ce2.event_cd=volumeinfusedautotransfusion)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_volumeinfusedautotransfusion = s_tran_result, i_infused_cnt += 1
   ELSEIF (ce2.event_cd=mf_bloodproductamountinfused)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_bloodproductamountinfused = s_tran_result, i_infused_cnt += 1
   ELSEIF (ce2.event_cd=mf_transfusionreactiondescription)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_transfusionreactiondescription = s_tran_result, i_reaction_cnt += 1
   ELSEIF (ce2.event_cd=mf_nursestatementofattestation)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_nursestatementofattestation = s_tran_result, i_witness_cnt = 1
   ELSEIF (ce2.event_cd=transfusiontime)
    temptime = replace(s_tran_result,"min",""), forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[i_instance_cnt].transfusiontime = s_tran_result
    IF (cnvtint(temptime) > 0
     AND cnvtint(temptime) <= 240)
     i_calcvalues_cnt = 1
    ENDIF
   ELSEIF (ce2.event_cd IN (mf_bloodproductcomment))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_bloodproductcomment = ce2.result_val
   ENDIF
   IF (ce2.event_cd IN (mf_unit_id_lot_num_cd))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_unit_id_lot_num
     = trim(ce2.result_val,4)
   ELSEIF (ce2.event_cd IN (mf_unit_id_lot_num_adtnl_unit_cd))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_unit_id_lot_num_adtnl_unit = trim(ce2.result_val,4)
   ELSEIF (ce2.event_cd IN (mf_red_cell_bag_lot_num_cd))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_red_cell_bag_lot_num = trim(ce2.result_val,4)
   ELSEIF (ce2.event_cd IN (mf_factorunitofmeasure))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_factorunitofmeasure = trim(ce2.result_val,3)
   ELSEIF (ce2.event_cd IN (mf_factordosegiven))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_factordosegiven
     = trim(ce2.result_val,3)
   ELSEIF (ce2.event_cd IN (mf_iftransfusiontimeis241minexplain))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_iftransfusiontimeis241minexplain = trim(ce2.result_val,3)
   ELSEIF (ce2.event_cd IN (mf_istransfusiontime241minutes))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_istransfusiontime241minutes = trim(ce2.result_val,3)
   ELSEIF (ce2.event_cd IN (mf_transfusiontimetocompletion))
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].
    s_transfusiontimetocompletion = concat(trim(ce2.result_val,3)," ",trim(uar_get_code_display(ce2
       .result_units_cd),3))
   ENDIF
  FOOT  ce2.event_cd
   stat = 0
  FOOT  ce.parent_event_id
   IF (i_consent_cnt=1
    AND i_vital_cnt=24
    AND i_infused_cnt > 0
    AND i_reaction_cnt=1
    AND i_witness_cnt=1
    AND i_calcvalues_cnt > 0)
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_incompliance =
    "Yes", formscomplete += 1
   ELSE
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[i_instance_cnt].s_incompliance =
    "No", formsincomplete += 1
   ENDIF
   totalforms += 1,
   CALL echo(build(totalforms))
  FOOT  name
   stat = 0
  FOOT  d.seq
   tottotalforms += totalforms, totformscomplete += formscomplete, totformsincomplete +=
   formsincomplete
   IF (( $PRINTTOTALS=1))
    tempcntpat = (size(forms->nurseunit[d.seq].patientslist,5)+ 1),
    CALL alterlist(forms->nurseunit[d.seq].patientslist,tempcntpat), tempcntform = (size(forms->
     nurseunit[d.seq].patientslist[tempcntpat].forminstanceslist,5)+ 1),
    CALL alterlist(forms->nurseunit[d.seq].patientslist[tempcntpat].forminstanceslist,tempcntform),
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
     format(((formsincomplete/ totalforms) * 100),"###.##"),"%"),
    CALL alterlist(forms->nurseunit[d.seq].patientslist,(tempcntpat+ 1)),
    forms->nurseunit[d.seq].patientslist[(tempcntpat+ 1)].s_person_name = "__",
    CALL alterlist(forms->nurseunit[d.seq].patientslist[tempcntpat].forminstanceslist,(tempcntform+ 1
    ))
   ENDIF
  FOOT REPORT
   IF ( NOT (reflect( $NURSEUNIT)="F8"))
    tempcntnurse = (size(forms->nurseunit,5)+ 1),
    CALL alterlist(forms->nurseunit,tempcntnurse), tempcntpat = (size(forms->nurseunit[tempcntnurse].
     patientslist,5)+ 1),
    CALL alterlist(forms->nurseunit[tempcntnurse].patientslist,tempcntpat), tempcntform = (size(forms
     ->nurseunit[tempcntnurse].patientslist[tempcntpat].forminstanceslist,5)+ 1),
    CALL alterlist(forms->nurseunit[tempcntnurse].patientslist[tempcntpat].forminstanceslist,
    tempcntform),
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
   WHERE p.person_id=ce.performed_prsnl_id)
  ORDER BY ce.parent_event_id, ce.performed_dt_tm
  HEAD REPORT
   s_nurses = substring(1,100," ")
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
   s_nurses
  WITH nocounter
 ;end select
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
    forminstanceslist[d2.seq].s_oxygensaturationend)), bloodproducttransfused = substring(1,100,trim(
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_bloodproducttransfused)),
  albumin = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq
    ].s_albuminvol)),
  cryoprecipitate = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_cryoprecipitate)), factorviianovoseven = substring(1,25,trim(forms->
    nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_factorviianovoseven)),
  factorviii = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2
    .seq].s_factorviiihumanhumatepvol)),
  3factorprothrombincomplexconcentrate = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1
    .seq].forminstanceslist[d2.seq].s_3factorprothrombincomplexconcentrate)), factorixrecombinant =
  substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].
    s_factorixrecombinant)), factorunitofmeasure = substring(1,25,trim(forms->nurseunit[d.seq].
    patientslist[d1.seq].forminstanceslist[d2.seq].s_factorunitofmeasure)),
  factordosegiven = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_factordosegiven)), ffp = substring(1,25,trim(forms->nurseunit[d.seq].
    patientslist[d1.seq].forminstanceslist[d2.seq].s_ffp)), granulocytes = substring(1,25,trim(forms
    ->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_granulocytes)),
  ivig = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].
    s_ivig)), platelets = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_platelets)), redbloodcell = substring(1,25,trim(forms->nurseunit[d
    .seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_rbcvol)),
  rhimmuneglobulinim = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_rhimmuneglobulinim)), rhimmuneglobuliniv = substring(1,25,trim(forms
    ->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_rhimmuneglobuliniv)),
  otherbloodproduct = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_bloodproductamountinfused)),
  transfusiontime = substring(1,10,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].transfusiontime)), transfusiontimetocompletion = substring(1,25,trim(
    forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].
    s_transfusiontimetocompletion)), istransfusiontime241minutes = substring(1,25,trim(forms->
    nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_istransfusiontime241minutes)),
  iftransfusiontime241minexplain = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_iftransfusiontimeis241minexplain)), transfusionreactiondescription =
  substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].
    s_transfusionreactiondescription)), incompliance = substring(1,25,trim(forms->nurseunit[d.seq].
    patientslist[d1.seq].forminstanceslist[d2.seq].s_incompliance)),
  originalnurse = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[
    d2.seq].s_originalnurse)), nursestatementofattestation = substring(1,50,trim(forms->nurseunit[d
    .seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_nursestatementofattestation)),
  blood_product_commment = substring(1,60,trim(replace(replace(forms->nurseunit[d.seq].patientslist[
      d1.seq].forminstanceslist[d2.seq].s_bloodproductcomment,char(13)," "),char(10)," "),3)),
  volume_infused = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_volumeinfusedautotransfusion)), unit_id_lot_num = substring(1,25,trim
   (forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_unit_id_lot_num)),
  unit_id_lot_num_adtnl_unit = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_unit_id_lot_num_adtnl_unit)),
  red_cell_bag_lot_num = substring(1,25,trim(forms->nurseunit[d.seq].patientslist[d1.seq].
    forminstanceslist[d2.seq].s_red_cell_bag_lot_num))
  FROM (dummyt d  WITH seq = size(forms->nurseunit,5)),
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1)
  PLAN (d
   WHERE maxrec(d1,size(forms->nurseunit[d.seq].patientslist,5)))
   JOIN (d1
   WHERE maxrec(d2,size(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist,5))
    AND size(forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist,3) > 0)
   JOIN (d2
   WHERE  NOT ((forms->nurseunit[d.seq].patientslist[d1.seq].forminstanceslist[d2.seq].s_performed_on
    IN ("", " ", null))))
  WITH nocounter, format, pcformat(value(filedelimiter1),value(filedelimiter2)),
   time = 300
 ;end select
 IF (emailind=1)
  CALL emailfile(var_output,var_output,ms_email_list,concat("Transfusion Quality Stat Report - ",
    format(cnvtdatetime(curdate,curtime),";;q")," - ",curprog),0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = concat("File has been emailed to: ",ms_email_list), col 0,
    "{PS/792 0 translate 90 rotate/}",
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,18)),
    msg1
   WITH dio = 08
  ;end select
 ENDIF
#exit_program
END GO

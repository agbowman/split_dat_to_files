CREATE PROGRAM bhs_rpt_tran_bld_new:dba
 PROMPT
  "Hidden OutputDev:" = "MINE",
  "Facility:" = 0,
  "Begin dt/tm:" = "SYSDATE",
  "End dt/tm" = "SYSDATE",
  "Form Type:" = "TRANSFUSIONTAGFORM",
  "FTP files" = 1
  WITH outdev, facility, bdate,
  edate, formtype, ftpfiles
 DECLARE additionalunitdocumentation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "ADDITIONALUNITDOCUMENTATION")), protect
 DECLARE primaryeventid = f8 WITH constant(uar_get_code_by("DISPLAYKEY",18189,"PRIMARYEVENTID")),
 protect
 DECLARE pharmacy = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY")), protect
 DECLARE laboratory = f8 WITH constant(uar_get_code_by("DISPLAYKEY",93,"LABORATORY")), protect
 DECLARE lab_cbcwdifferential = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"CBCWDIFFERENTIAL")
  ), protect
 DECLARE lab_bun = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"BUN")), protect
 DECLARE lab_inr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"INR")), protect
 DECLARE lab_fibrinogen = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"FIBRINOGEN")), protect
 DECLARE lab_creatine = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"CREATINE")), protect
 DECLARE lab_creactiveprotein = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"CREACTIVEPROTEIN")
  ), protect
 DECLARE lab_btypenatriureticpeptide = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "BTYPENATRIURETICPEPTIDE")), protect
 DECLARE lab_troponintquant = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"TROPONINTQUANT")),
 protect
 DECLARE valid_end_date = vc WITH noconstant('"XXX"'), protect
 DECLARE valid_start_date = vc WITH noconstant('"XXX"'), protect
 DECLARE end_date_qual = dq8 WITH protect
 DECLARE beg_date_qual = dq8 WITH protect
 DECLARE smokingcessation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"SMOKINGCESSATION")),
 protect
 DECLARE active_dx_prob = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE admitting = f8 WITH constant(uar_get_code_by("DISPLAYKEY",17,"ADMITTING")), protect
 DECLARE admittingphysician = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,"ADMITTINGPHYSICIAN")
  ), protect
 DECLARE rh = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"RH")), protect
 DECLARE abo = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABO")), protect
 DECLARE bloodtype = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"BLOODTYPE")), protect
 DECLARE rhtestonly1 = f8 WITH constant(709363), protect
 DECLARE rhtestonly2 = f8 WITH constant(2821152), protect
 EXECUTE bhs_sys_stand_subroutine
 SET beg_date_qual = cnvtdatetime( $BDATE)
 SET end_date_qual = cnvtdatetime( $EDATE)
 IF (cnvtupper( $BDATE) IN ("DAY"))
  SET beg_date_qual = cnvtdatetime((curdate - 1),0)
  SET end_date_qual = cnvtdatetime((curdate - 1),0)
 ELSEIF (datetimediff(end_date_qual,beg_date_qual) > 31)
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
 IF (( $FTPFILES=1))
  SET emailind = 1
  CALL echo(format(cnvtdatetime(curdate,curtime),"@SHORTDATETIME"))
  SET from_day = day(cnvtdatetime( $BDATE))
  SET from_month = month(cnvtdatetime( $BDATE))
  SET from_year = substring(3,2,build(year(cnvtdatetime( $BDATE))))
  SET day1 = day(curdate)
  SET name_fac = cnvtlower(substring(1,6,replace(trim(uar_get_code_display(cnvtreal( $FACILITY)))," ",
     "_",0)))
  CALL echo(build("name_fac = ",name_fac))
  SET month1 = month(curdate)
  CALL echo(day1)
  SET time1 = format(curtime,"HHMM;;M")
  SET var_output = build(name_fac,"_","forms_",from_month,"_",
   from_day,"_",from_year,"_",time1,
   ".csv")
  CALL echo(build("var_output = ",var_output))
  SET var_output1 = build(name_fac,"_","labs_",from_month,"_",
   from_day,"_",from_year,"_",time1,
   ".csv")
  SET var_output3 = build(name_fac,"_","pre_meds",from_month,"_",
   from_day,"_",from_year,"_",time1,
   ".csv")
  SET filedelimiter1 = '"'
  SET filedelimiter2 = ","
 ELSE
  SET var_output =  $OUTDEV
  SET filedelimiter1 = '"'
  SET filedelimiter2 = " "
 ENDIF
 FREE RECORD forms
 RECORD forms(
   1 patientslist[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_person_name = vc
     2 s_finnbr = vc
     2 age = vc
     2 mrn = vc
     2 admit_date = vc
     2 discharge_date = vc
     2 patient_type = vc
     2 admitting_dr = vc
     2 facility = vc
     2 location = vc
     2 admit_diag = vc
     2 service = vc
     2 primary_provider = vc
     2 allergies = vc
     2 beg_unit = dq8
     2 end_unit = dq8
     2 problems = vc
     2 txfuse_ords[*]
       3 order_name = vc
     2 forminstanceslist[*]
       3 formname = vc
       3 abo = vc
       3 form_number = f8
       3 s_nurseunitname = vc
       3 f_nurseunit_cd = f8
       3 lab_orders[*]
         4 ese_event_set_disp = vc
         4 catalog_disp = vc
         4 result_name = vc
         4 result_val = vc
         4 result_unit = vc
         4 event_end_dt_tm = vc
       3 s_performed_on = vc
       3 d_performed_dt_tm = dq8
       3 f_parent_event_id = f8
       3 order_id = f8
       3 order_name_w_phys = vc
       3 med_by_class[*]
         4 meds_category = vc
         4 order_name = vc
       3 pre_meds[*]
         4 order_name = vc
         4 meds_category = vc
         4 date_time_given = vc
         4 order_id = f8
       3 weight = vc
       3 bmi = vc
       3 s_nursesdocumented = vc
       3 smokingcessation = vc
       3 pre_total_intake = f8
       3 pre_total_output = f8
       3 pre_balance = f8
       3 total_intake = f8
       3 total_output = f8
       3 balance = f8
       3 post_total_intake = f8
       3 post_total_output = f8
       3 post_balance = f8
       3 s_consentsignedcurrentornotapplicable = vc
       3 s_transfusionstarttime = vc
       3 d_transfusionstarttime = dq8
       3 valid_transfusionstarttime = vc
       3 s_temperaturestart = vc
       3 s_temperatureroutestart = vc
       3 s_pulseratestart = vc
       3 s_respiratoryratestart = vc
       3 s_systolicbloodpressurestart = vc
       3 s_diastolicbloodpressurestart = vc
       3 s_oxygensaturationstart = vc
       3 s_transfusionstartplus15min = vc
       3 s_temperature15min = vc
       3 s_temperatureroute15min = vc
       3 s_pulserate15min = vc
       3 s_respiratoryrate15min = vc
       3 s_systolicbloodpressure15min = vc
       3 s_diastolicbloodpressure15min = vc
       3 s_oxygensaturation15min = vc
       3 s_transfusionendtime = vc
       3 valid_transfusionendtime = vc
       3 d_transfusionendtime = dq8
       3 s_temperatureend = vc
       3 s_temperaturerouteend = vc
       3 s_pulserateend = vc
       3 s_respiratoryrateend = vc
       3 s_systolicbloodpressureend = vc
       3 s_diastolicbloodpressureend = vc
       3 s_oxygensaturationend = vc
       3 s_volumeinfusedautotransfusion = vc
       3 s_albuminvol = vc
       3 s_cryoprecipitate = vc
       3 sfactorviia = vc
       3 s_factorviiivol = vc
       3 s_factorixcomplex = vc
       3 s_factorixvol = vc
       3 s_ffp = vc
       3 s_granulocytes = vc
       3 s_ivig = vc
       3 s_platelets = vc
       3 s_rbcvol = vc
       3 s_rhimmuneglobulin = vc
       3 s_bloodproductamountinfused = vc
       3 s_transfusionreactiondescription = vc
       3 s_incompliance = vc
       3 s_originalnurse = vc
       3 s_nursestatementofattestation = vc
       3 transfusioncompatibilityresult = vc
       3 unitidnumberlotnumber = vc
       3 diastolicbloodpressuredelta1_calc = vc
       3 diastolicbloodpressuredelta2_calc = vc
       3 meanarterialpressure15min_calc = vc
       3 meanarterialpressuredelta1_calc = vc
       3 meanarterialpressuredelta2_calc = vc
       3 meanarterialpressureend_calc = vc
       3 meanarterialpressurestart_calc = vc
       3 oxygensaturationdelta1_calc = vc
       3 oxygensaturationdelta2_calc = vc
       3 pulsepressure15min_calc = vc
       3 pulsepressuredelta1_calc = vc
       3 pulsepressuredelta2_calc = vc
       3 pulsepressureend_calc = vc
       3 pulsepressurestart_calc = vc
       3 pulseratedelta1_calc = vc
       3 pulseratedelta2_calc = vc
       3 respiratoryratedelta1_calc = vc
       3 respiratoryratedelta2_calc = vc
       3 systolicbloodpressuredelta1_calc = vc
       3 systolicbloodpressuredelta2_calc = vc
       3 temperaturedelta1_calc = vc
       3 temperaturedelta2_calc = vc
       3 transfusionratecryoprecipitate_calc = vc
       3 transfusionrateffp_calc = vc
       3 transfusionrateivig_calc = vc
       3 transfusionrateplatelets_calc = vc
       3 transfusionraterbcs_calc = vc
       3 transfusiontime_calc = vc
       3 additional_unit_documentation = vc
 ) WITH protect
 DECLARE weight = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT")), protect
 DECLARE bodymassindex = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"BODYMASSINDEX")), protect
 DECLARE transfusioncompatibilityresult = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TRANSFUSIONCOMPATIBILITYRESULT")), protect
 DECLARE unitidnumberlotnumber = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "UNITIDNUMBERLOTNUMBER")), protect
 DECLARE attendingphysician = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,"ATTENDINGPHYSICIAN")
  ), protect
 DECLARE active_allergy = f8 WITH constant(uar_get_code_by("DISPLAYKEY",12025,"ACTIVE")), protect
 DECLARE mrn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"MRN")), protect
 DECLARE finnbr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE ms_facility_name = vc
 DECLARE ms_nursingunit_name = vc
 DECLARE ordered = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE temperaturedelta1_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEMPERATUREDELTA1")), protect
 DECLARE temperaturedelta2_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEMPERATUREDELTA2")), protect
 DECLARE pulseratedelta1_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATEDELTA1")),
 protect
 DECLARE pulseratedelta2_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATEDELTA2")),
 protect
 DECLARE respiratoryratedelta1_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPIRATORYRATEDELTA1")), protect
 DECLARE respiratoryratedelta2_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPIRATORYRATEDELTA2")), protect
 DECLARE systolicbloodpressuredelta1_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSUREDELTA1")), protect
 DECLARE systolicbloodpressuredelta2_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSUREDELTA2")), protect
 DECLARE diastolicbloodpressuredelta1_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSUREDELTA1")), protect
 DECLARE diastolicbloodpressuredelta2_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSUREDELTA2")), protect
 DECLARE oxygensaturationdelta1_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OXYGENSATURATIONDELTA1")), protect
 DECLARE oxygensaturationdelta2_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OXYGENSATURATIONDELTA2")), protect
 DECLARE pulsepressurestart_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSEPRESSURESTART")), protect
 DECLARE pulsepressure15min_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSEPRESSURE15MIN")), protect
 DECLARE pulsepressuredelta1_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSEPRESSUREDELTA1")), protect
 DECLARE pulsepressuredelta2_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSEPRESSUREDELTA2")), protect
 DECLARE meanarterialpressure15min_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MEANARTERIALPRESSURE15MIN")), protect
 DECLARE meanarterialpressuredelta1_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MEANARTERIALPRESSUREDELTA1")), protect
 DECLARE meanarterialpressureend_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MEANARTERIALPRESSUREEND")), protect
 DECLARE meanarterialpressuredelta2_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MEANARTERIALPRESSUREDELTA2")), protect
 DECLARE pulsepressureend_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PULSEPRESSUREEND")
  ), protect
 DECLARE meanarterialpressurestart_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MEANARTERIALPRESSURESTART")), protect
 DECLARE transfusionraterbcs_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TRANSFUSIONRATERBCS")), protect
 DECLARE transfusionratecryoprecipitate_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TRANSFUSIONRATECRYOPRECIPITATE")), protect
 DECLARE transfusionrateffp_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TRANSFUSIONRATEFFP")), protect
 DECLARE transfusionrateivig_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TRANSFUSIONRATEIVIG")), protect
 DECLARE transfusionrateplatelets_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TRANSFUSIONRATEPLATELETS")), protect
 DECLARE transfusiontime_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TRANSFUSIONTIME")),
 protect
 DECLARE temperaturedelta2autotransfusion_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEMPERATUREDELTA2AUTOTRANSFUSION")), protect
 DECLARE temperaturedelta1autotransfusion_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEMPERATUREDELTA1AUTOTRANSFUSION")), protect
 DECLARE pulseratedelta1autotransfusion_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSERATEDELTA1AUTOTRANSFUSION")), protect
 DECLARE pulseratedelta2autotransfusion_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSERATEDELTA2AUTOTRANSFUSION")), protect
 DECLARE respiratoryratedelta1autotransfusion_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPIRATORYRATEDELTA1AUTOTRANSFUSION")), protect
 DECLARE respiratoryratedelta2autotransfusion_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPIRATORYRATEDELTA2AUTOTRANSFUSION")), protect
 DECLARE pulsepressuredelta2autotransfusion_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSEPRESSUREDELTA2AUTOTRANSFUSION")), protect
 DECLARE pulsepressurestartautotransfusion_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSEPRESSURESTARTAUTOTRANSFUSION")), protect
 DECLARE pulsepressure15minautotransfusion_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSEPRESSURE15MINAUTOTRANSFUSION")), protect
 DECLARE pulsepressuredelta1autotransfusion_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSEPRESSUREDELTA1AUTOTRANSFUSION")), protect
 DECLARE pulsepressureendautotransfusion_calc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSEPRESSUREENDAUTOTRANSFUSION")), protect
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
 DECLARE facilitycd = f8 WITH noconstant(0.0)
 CALL echo(reflect( $FACILITY))
 IF (reflect( $FACILITY)="F8")
  SET facilitycd =  $FACILITY
 ELSE
  SET facilitycd = 99999999
 ENDIF
 CALL echo(build("Nurse=",facilitycd))
 SET starttime = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  nurse_unit = uar_get_code_display(el.loc_nurse_unit_cd), e.reason_for_visit, facility =
  uar_get_code_display(el.loc_facility_cd),
  encntr_type = uar_get_code_display(el.encntr_type_cd), plan_name = uar_get_code_display(e
   .financial_class_cd), med_service = uar_get_code_display(e.med_service_cd)
  FROM dcp_forms_ref dfr,
   dcp_forms_activity dfa,
   encntr_alias ea,
   encntr_alias ea1,
   person p,
   encntr_loc_hist el,
   encounter e,
   dcp_forms_activity_comp dfac
  PLAN (dfr
   WHERE dfr.end_effective_dt_tm >= cnvtdatetime(beg_date_qual)
    AND dfr.beg_effective_dt_tm <= cnvtdatetime(end_date_qual)
    AND dfr.definition IN ("Transfusion Tag Form - BHS", "Autotransfusion/Blood Recovery Form - BHS")
   )
   JOIN (dfa
   WHERE dfa.dcp_forms_ref_id=dfr.dcp_forms_ref_id
    AND dfa.updt_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual))
   JOIN (dfac
   WHERE dfac.dcp_forms_activity_id=dfa.dcp_forms_activity_id
    AND dfac.component_cd=primaryeventid
    AND dfac.parent_entity_name="CLINICAL_EVENT")
   JOIN (ea
   WHERE ea.encntr_id=dfa.encntr_id
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=mf_finnbr)
   JOIN (ea1
   WHERE ea1.encntr_id=dfa.encntr_id
    AND ea1.active_ind=1
    AND ea1.encntr_alias_type_cd=mrn)
   JOIN (el
   WHERE el.encntr_id=ea.encntr_id
    AND el.active_ind=1
    AND ((facilitycd != 99999999
    AND el.loc_facility_cd=facilitycd) OR (facilitycd=99999999))
    AND el.end_effective_dt_tm >= dfa.form_dt_tm
    AND el.beg_effective_dt_tm <= dfa.form_dt_tm)
   JOIN (e
   WHERE e.encntr_id=el.encntr_id)
   JOIN (p
   WHERE e.person_id=p.person_id
    AND p.active_ind=1)
  ORDER BY el.encntr_id, dfac.parent_entity_id
  HEAD REPORT
   i_patient_cnt = 0, ms_facility_name = uar_get_code_display(el.loc_facility_cd),
   ms_nursingunit_name = uar_get_code_display(el.loc_nurse_unit_cd),
   stat = alterlist(forms->patientslist,10), i_form_cnt = 0
  HEAD el.encntr_id
   i_patient_cnt = (i_patient_cnt+ 1)
   IF (mod(i_patient_cnt,10)=1)
    stat = alterlist(forms->patientslist,(i_patient_cnt+ 9))
   ENDIF
   CALL echo(build("dfa.task_id %%% = ",dfa.task_id)), forms->patientslist[i_patient_cnt].
   f_encntr_id = el.encntr_id, forms->patientslist[i_patient_cnt].f_person_id = e.person_id,
   forms->patientslist[i_patient_cnt].s_person_name = concat(trim(p.name_first,3)," ",trim(p
     .name_last,3)), forms->patientslist[i_patient_cnt].s_finnbr = check(trim(ea.alias,3)), forms->
   patientslist[i_patient_cnt].mrn = check(trim(ea1.alias,3)),
   forms->patientslist[i_patient_cnt].facility = facility, forms->patientslist[i_patient_cnt].
   patient_type = encntr_type, forms->patientslist[i_patient_cnt].location = nurse_unit,
   forms->patientslist[i_patient_cnt].age = trim(cnvtage(p.birth_dt_tm),3), forms->patientslist[
   i_patient_cnt].admit_date = format(e.reg_dt_tm,"mm/dd/yy hh:mm;;d"), forms->patientslist[
   i_patient_cnt].discharge_date = format(e.disch_dt_tm,"mm/dd/yy hh:mm;;d"),
   forms->patientslist[i_patient_cnt].service = trim(med_service,3), forms->patientslist[
   i_patient_cnt].primary_provider = trim(plan_name,3), forms->patientslist[i_patient_cnt].beg_unit
    = el.beg_effective_dt_tm,
   forms->patientslist[i_patient_cnt].end_unit = el.end_effective_dt_tm, forms->patientslist[
   i_patient_cnt].problems = "No Data", stat = alterlist(forms->patientslist[i_patient_cnt].
    forminstanceslist,10),
   i_form_cnt = 0
  HEAD dfac.parent_entity_id
   i_form_cnt = (i_form_cnt+ 1),
   CALL echo(build("i_form_cnt =",i_form_cnt)), stat = alterlist(forms->patientslist[i_patient_cnt].
    forminstanceslist,i_form_cnt),
   forms->patientslist[i_patient_cnt].forminstanceslist[i_form_cnt].f_parent_event_id = dfac
   .parent_entity_id, forms->patientslist[i_patient_cnt].forminstanceslist[i_form_cnt].
   s_nurseunitname = trim(uar_get_code_display(el.loc_nurse_unit_cd),3), forms->patientslist[
   i_patient_cnt].forminstanceslist[i_form_cnt].f_nurseunit_cd = el.loc_nurse_unit_cd,
   forms->patientslist[i_patient_cnt].forminstanceslist[i_form_cnt].additional_unit_documentation =
   "No", current_enctr = el.encntr_id, forms->patientslist[i_patient_cnt].forminstanceslist[
   i_form_cnt].abo = "No Data"
  FOOT  dfac.parent_entity_id
   row + 0
  FOOT  el.encntr_id
   row + 0
  FOOT PAGE
   stat = alterlist(forms->patientslist,i_patient_cnt)
  WITH nocounter
 ;end select
 SET endtime = cnvtdatetime(curdate,curtime3)
 CALL echo("##################")
 SET selecttime1 = datetimediff(cnvtdatetime(endtime),cnvtdatetime(starttime),5)
 CALL echo(build("selecttime1 = ",selecttime1))
 CALL echorecord(forms)
 CALL echo("location effective date")
 SET starttime = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  patientslist_f_encntr_id = forms->patientslist[d1.seq].f_encntr_id
  FROM (dummyt d1  WITH seq = value(size(forms->patientslist,5))),
   encntr_prsnl_reltn epr,
   prsnl prn
  PLAN (d1)
   JOIN (epr
   WHERE (forms->patientslist[d1.seq].f_encntr_id=epr.encntr_id)
    AND epr.encntr_prsnl_r_cd=admittingphysician)
   JOIN (prn
   WHERE prn.person_id=epr.prsnl_person_id)
  DETAIL
   forms->patientslist[d1.seq].admitting_dr = concat(trim(prn.name_first,3)," ",trim(prn.name_last,3)
    )
  WITH nocounter
 ;end select
 SET endtime = cnvtdatetime(curdate,curtime3)
 SET selecttime1 = datetimediff(cnvtdatetime(endtime),cnvtdatetime(starttime),5)
 CALL echo(build("selecttime2 = ",selecttime1))
 SET starttime = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(forms->patientslist,5))),
   allergy a,
   nomenclature n
  PLAN (d1)
   JOIN (a
   WHERE (a.person_id=forms->patientslist[d1.seq].f_person_id)
    AND a.active_status_cd=active_dx_prob)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
  DETAIL
   IF ((forms->patientslist[d1.seq].allergies=null))
    forms->patientslist[d1.seq].allergies = trim(n.source_string,3)
   ELSE
    forms->patientslist[d1.seq].allergies = concat(trim(forms->patientslist[d1.seq].allergies,3),", ",
     trim(n.source_string,3))
   ENDIF
  WITH nocounter
 ;end select
 SET endtime = cnvtdatetime(curdate,curtime3)
 SET selecttime3 = datetimediff(cnvtdatetime(endtime),cnvtdatetime(starttime),5)
 CALL echo(build("selecttime3 = ",selecttime3))
 SET starttime = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(forms->patientslist,5))),
   diagnosis dx,
   nomenclature n
  PLAN (d1)
   JOIN (dx
   WHERE (dx.encntr_id=forms->patientslist[d1.seq].f_encntr_id)
    AND dx.diag_type_cd=admitting
    AND dx.active_status_cd=active_dx_prob)
   JOIN (n
   WHERE dx.nomenclature_id=n.nomenclature_id)
  DETAIL
   IF ((forms->patientslist[d1.seq].admit_diag=null))
    forms->patientslist[d1.seq].admit_diag = trim(n.source_string,3)
   ELSE
    forms->patientslist[d1.seq].admit_diag = concat(trim(forms->patientslist[d1.seq].admit_diag,3),
     ", ",trim(n.source_string,3))
   ENDIF
  WITH nocounter
 ;end select
 SET endtime = cnvtdatetime(curdate,curtime3)
 SET selecttime4 = datetimediff(cnvtdatetime(endtime),cnvtdatetime(starttime),5)
 CALL echo(build("selecttime4 = ",selecttime4))
 SET starttime = cnvtdatetime(curdate,curtime3)
 SET prob_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(forms->patientslist,5))),
   problem p,
   nomenclature n
  PLAN (d1)
   JOIN (p
   WHERE (p.person_id=forms->patientslist[d1.seq].f_person_id)
    AND p.active_status_cd=active_dx_prob)
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id
    AND n.nomenclature_id > 0)
  ORDER BY d1.seq
  HEAD d1.seq
   prob_cnt = 0
  DETAIL
   prob_cnt = (prob_cnt+ 1)
   IF (prob_cnt=1)
    forms->patientslist[d1.seq].problems = trim(n.source_string,3)
   ELSE
    forms->patientslist[d1.seq].problems = concat(trim(forms->patientslist[d1.seq].problems,3),", ",
     trim(n.source_string,3))
   ENDIF
  WITH nocounter
 ;end select
 SET endtime = cnvtdatetime(curdate,curtime3)
 SET selecttime5 = datetimediff(cnvtdatetime(endtime),cnvtdatetime(starttime),5)
 CALL echo(build("selecttime5 = ",selecttime5))
 SET starttime = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  nurseunit = uar_get_code_display(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
   f_nurseunit_cd), name = forms->patientslist[d1.seq].s_person_name, ce.parent_event_id,
  ce2.event_cd
  FROM (dummyt d1  WITH seq = value(size(forms->patientslist,5))),
   (dummyt d2  WITH seq = 1),
   clinical_event ce,
   clinical_event ce1,
   clinical_event ce2,
   dummyt d3,
   clinical_event ce3,
   ce_date_result cedr,
   prsnl pr
  PLAN (d1
   WHERE maxrec(d2,size(forms->patientslist[d1.seq].forminstanceslist,5)))
   JOIN (d2)
   JOIN (ce
   WHERE (forms->patientslist[d1.seq].forminstanceslist[d2.seq].f_parent_event_id=ce.parent_event_id)
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
    AND ce2.event_cd IN (transfusiondataverification, transfusioncompatibilityresult,
   unitidnumberlotnumber, mf_transfusionstarttime, mf_temperaturestart,
   mf_temperatureroutestart, mf_pulseratestart, mf_respiratoryratestart,
   mf_systolicbloodpressurestart, mf_diastolicbloodpressurestart,
   mf_oxygensaturationstart, autotransfusionstarttime, temperaturestartautotransfusion,
   temperatureroutestartautotransfusion, pulseratestartautotransfusion,
   respiratoryratestartautotransfusion, sbpstartautotransfusion, dbpstartautotransfusion,
   oxygensatstartautotransfusion, mf_transfusionstartplus15min,
   mf_temperature15min, mf_temperatureroute15min, mf_pulserate15min, mf_respiratoryrate15min,
   mf_systolicbloodpressure15min,
   mf_diastolicbloodpressure15min, mf_oxygensaturation15min, autotransfusionstartplus15min,
   temperature15minautotransfusion, temperatureroute15minautotransfusion,
   pulserate15minautotransfusion, respiratoryrate15minautotransfusion, sbp15minautotransfusion,
   dbp15minautotransfusion, oxygensat15minautotransfusion,
   mf_transfusionendtime, mf_temperatureend, mf_temperaturerouteend, mf_pulserateend,
   mf_respiratoryrateend,
   mf_systolicbloodpressureend, mf_diastolicbloodpressureend, mf_oxygensaturationend,
   autotransfusionstoptime, temperatureendautotransfusion,
   temperaturerouteendautotransfusion, pulserateendautotransfusion, respiratoryrateendautotransfusion,
   sbpendautotransfusion, dbpendautotransfusion,
   oxygensatendautotransfusion, mf_albuminvol, mf_cryoprecipitate, mf_factorviia, mf_factorviiivol,
   mf_factorixcomplex, mf_factorixvol, mf_ffp, mf_granulocytes, mf_ivig,
   mf_platelets, mf_rbcvol, mf_rhimmuneglobulin, mf_bloodproductamountinfused,
   volumeinfusedautotransfusion,
   mf_transfusionreactiondescription, mf_nursestatementofattestation,
   diastolicbloodpressuredelta1_calc, diastolicbloodpressuredelta2_calc,
   meanarterialpressure15min_calc,
   meanarterialpressuredelta1_calc, meanarterialpressuredelta2_calc, meanarterialpressureend_calc,
   meanarterialpressurestart_calc, oxygensaturationdelta1_calc,
   oxygensaturationdelta2_calc, pulsepressure15min_calc, pulsepressure15minautotransfusion_calc,
   pulsepressuredelta1_calc, pulsepressuredelta1autotransfusion_calc,
   pulsepressuredelta2_calc, pulsepressuredelta2autotransfusion_calc, pulsepressureend_calc,
   pulsepressureendautotransfusion_calc, pulsepressurestart_calc,
   pulsepressurestartautotransfusion_calc, pulseratedelta1_calc, pulseratedelta1autotransfusion_calc,
   pulseratedelta2_calc, pulseratedelta2autotransfusion_calc,
   respiratoryratedelta1_calc, respiratoryratedelta1autotransfusion_calc, respiratoryratedelta2_calc,
   respiratoryratedelta2autotransfusion_calc, systolicbloodpressuredelta1_calc,
   systolicbloodpressuredelta2_calc, temperaturedelta1_calc, temperaturedelta1autotransfusion_calc,
   temperaturedelta2_calc, temperaturedelta2autotransfusion_calc,
   transfusionratecryoprecipitate_calc, transfusionrateffp_calc, transfusionrateivig_calc,
   transfusionrateplatelets_calc, transfusionraterbcs_calc,
   transfusiontime_calc, additionalunitdocumentation))
   JOIN (pr
   WHERE pr.person_id=ce2.performed_prsnl_id)
   JOIN (cedr
   WHERE cedr.event_id=outerjoin(ce2.event_id))
   JOIN (d3)
   JOIN (ce3
   WHERE ce3.parent_event_id=ce2.event_id
    AND ce3.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce3.result_status_cd IN (mf_modified_cd, mf_auth_cd, mf_altered_cd)
    AND ce3.event_cd IN (mf_consentsignedcurrentornotapplicable))
  ORDER BY d1.seq, d2.seq, ce2.event_cd DESC
  HEAD REPORT
   stat = 0, totformscomplete = 0.0, totformsincomplete = 0.0,
   tottotalforms = 0.0
  HEAD d1.seq
   totalforms = 0.0, formscomplete = 0.0, formsincomplete = 0.0,
   unitcomplince = 0.0, i_instance_cnt = 0, i_consent_cnt = 0,
   i_vital_cnt = 0, i_infused_cnt = 0, i_reaction_cnt = 0,
   i_witness_cnt = 0
  HEAD d2.seq
   CALL echo(build("head ce.parent_event_id = ",ce.parent_event_id)), i_trandta_cnt = 0,
   i_consent_cnt = 0,
   i_vital_cnt = 0, i_infused_cnt = 0, i_reaction_cnt = 0,
   i_witness_cnt = 0, forms->patientslist[d1.seq].forminstanceslist[d2.seq].f_parent_event_id = ce
   .parent_event_id, forms->patientslist[d1.seq].forminstanceslist[d2.seq].order_id = ce.order_id,
   forms->patientslist[d1.seq].forminstanceslist[d2.seq].formname = uar_get_code_display(ce.event_cd),
   forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_performed_on = build(format(ce
     .performed_dt_tm,";;q"),"_",ce.parent_event_id), forms->patientslist[d1.seq].forminstanceslist[
   d2.seq].d_performed_dt_tm = ce.performed_dt_tm,
   forms->patientslist[d1.seq].forminstanceslist[d2.seq].weight = "No weight available",
   CALL echo(build("check1"))
  HEAD ce2.event_cd
   IF (ce2.event_cd=mf_nursestatementofattestation)
    s_tran_result = build2(trim(ce2.event_tag)," (",trim(pr.name_full_formatted),")")
   ELSEIF (cedr.event_id > 0)
    s_tran_result = format(cnvtdatetime(cedr.result_dt_tm),";;q")
   ELSE
    s_tran_result = build2(trim(ce2.event_tag)," ",trim(uar_get_code_display(ce2.result_units_cd)))
   ENDIF
   IF (ce3.event_cd=mf_consentsignedcurrentornotapplicable)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_consentsignedcurrentornotapplicable = ce3
    .event_tag, i_consent_cnt = (i_consent_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_transfusionstarttime, autotransfusionstarttime))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_transfusionstarttime = format(
     cnvtdatetime(s_tran_result),"mm/dd/yy hh:mm;;d"), forms->patientslist[d1.seq].forminstanceslist[
    d2.seq].d_transfusionstarttime = cnvtdatetime(s_tran_result), i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_temperaturestart, temperaturestartautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_temperaturestart = s_tran_result,
    i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_temperatureroutestart, temperatureroutestartautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_temperatureroutestart = s_tran_result,
    i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_pulseratestart, pulseratestartautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_pulseratestart = s_tran_result,
    i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_respiratoryratestart, respiratoryratestartautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_respiratoryratestart = s_tran_result,
    i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_systolicbloodpressurestart, sbpstartautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_systolicbloodpressurestart =
    s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_diastolicbloodpressurestart, dbpstartautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_diastolicbloodpressurestart =
    s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_oxygensaturationstart, oxygensatstartautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_oxygensaturationstart = s_tran_result,
    i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_transfusionstartplus15min, autotransfusionstartplus15min))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_transfusionstartplus15min = format(
     cnvtdatetime(s_tran_result),"mm/dd/yy hh:mm;;d"), i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_temperature15min, temperature15minautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_temperature15min = s_tran_result,
    i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_temperatureroute15min, temperatureroute15minautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_temperatureroute15min = s_tran_result,
    i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_pulserate15min, pulserate15minautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_pulserate15min = s_tran_result,
    i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_respiratoryrate15min, respiratoryrate15minautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_respiratoryrate15min = s_tran_result,
    i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_systolicbloodpressure15min, sbp15minautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_systolicbloodpressure15min =
    s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_diastolicbloodpressure15min, dbp15minautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_diastolicbloodpressure15min =
    s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_oxygensaturation15min, oxygensat15minautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_oxygensaturation15min = s_tran_result,
    i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_transfusionendtime, autotransfusionstoptime))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_transfusionendtime = format(cnvtdatetime(
      s_tran_result),"mm/dd/yy hh:mm;;d"), forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    d_transfusionendtime = cnvtdatetime(s_tran_result), i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_temperatureend, temperatureendautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_temperatureend = s_tran_result,
    i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_temperaturerouteend, temperaturerouteendautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_temperaturerouteend = s_tran_result,
    i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_pulserateend, pulserateendautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_pulserateend = s_tran_result, i_vital_cnt
     = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_respiratoryrateend, respiratoryrateendautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_respiratoryrateend = s_tran_result,
    i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_systolicbloodpressureend, sbpendautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_systolicbloodpressureend = s_tran_result,
    i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_diastolicbloodpressureend, dbpendautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_diastolicbloodpressureend = s_tran_result,
    i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_oxygensaturationend, oxygensatendautotransfusion))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_oxygensaturationend = s_tran_result,
    i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=volumeinfusedautotransfusion)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_volumeinfusedautotransfusion =
    s_tran_result, i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_albuminvol)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_albuminvol = s_tran_result, i_infused_cnt
     = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_cryoprecipitate)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_cryoprecipitate = s_tran_result,
    i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_factorviia)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].sfactorviia = s_tran_result, i_infused_cnt
     = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_factorviiivol)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_factorviiivol = s_tran_result,
    i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_factorixcomplex)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_factorixcomplex = s_tran_result,
    i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_factorixvol)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_factorixvol = s_tran_result,
    i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_ffp)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_ffp = s_tran_result, i_infused_cnt = (
    i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_granulocytes)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_granulocytes = s_tran_result,
    i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_ivig)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_ivig = s_tran_result, i_infused_cnt = (
    i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_platelets)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_platelets = s_tran_result, i_infused_cnt
     = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_rbcvol)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_rbcvol = s_tran_result, i_infused_cnt = (
    i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_rhimmuneglobulin)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_rhimmuneglobulin = s_tran_result,
    i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_bloodproductamountinfused)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_bloodproductamountinfused = s_tran_result,
    i_infused_cnt = (i_infused_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_transfusionreactiondescription)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_transfusionreactiondescription =
    s_tran_result, i_reaction_cnt = (i_reaction_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_nursestatementofattestation)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_nursestatementofattestation =
    s_tran_result, i_witness_cnt = 1
   ELSEIF (ce2.event_cd=transfusioncompatibilityresult)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].transfusioncompatibilityresult =
    s_tran_result
   ELSEIF (ce2.event_cd=unitidnumberlotnumber)
    IF (findstring("=",ce2.result_val,1,0)=1)
     forms->patientslist[d1.seq].forminstanceslist[d2.seq].unitidnumberlotnumber = build2('"',trim(
       ce2.result_val,3))
    ELSE
     forms->patientslist[d1.seq].forminstanceslist[d2.seq].unitidnumberlotnumber = build2(trim(ce2
       .result_val))
    ENDIF
    CALL echo(build("s_tran_result = ",s_tran_result)),
    CALL echo(build("ce2.result_val = ",ce2.result_val))
   ELSEIF (ce2.event_cd=diastolicbloodpressuredelta1_calc)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].diastolicbloodpressuredelta1_calc =
    s_tran_result
   ELSEIF (ce2.event_cd=diastolicbloodpressuredelta2_calc)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].diastolicbloodpressuredelta2_calc =
    s_tran_result
   ELSEIF (ce2.event_cd=meanarterialpressure15min_calc)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].meanarterialpressure15min_calc =
    s_tran_result
   ELSEIF (ce2.event_cd=meanarterialpressuredelta1_calc)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].meanarterialpressuredelta1_calc =
    s_tran_result
   ELSEIF (ce2.event_cd=meanarterialpressuredelta2_calc)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].meanarterialpressuredelta2_calc =
    s_tran_result
   ELSEIF (ce2.event_cd=meanarterialpressureend_calc)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].meanarterialpressureend_calc =
    s_tran_result
   ELSEIF (ce2.event_cd=meanarterialpressurestart_calc)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].meanarterialpressurestart_calc =
    s_tran_result
   ELSEIF (ce2.event_cd=oxygensaturationdelta1_calc)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].oxygensaturationdelta1_calc = s_tran_result
   ELSEIF (ce2.event_cd=oxygensaturationdelta2_calc)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].oxygensaturationdelta2_calc = s_tran_result
   ELSEIF (ce2.event_cd IN (pulsepressure15min_calc, pulsepressure15minautotransfusion_calc))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].pulsepressure15min_calc = s_tran_result
   ELSEIF (ce2.event_cd IN (pulsepressuredelta1_calc, pulsepressuredelta1autotransfusion_calc))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].pulsepressuredelta1_calc = s_tran_result
   ELSEIF (ce2.event_cd IN (pulsepressuredelta2_calc, pulsepressuredelta2autotransfusion_calc))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].pulsepressuredelta2_calc = s_tran_result
   ELSEIF (ce2.event_cd IN (pulsepressureend_calc, pulsepressureendautotransfusion_calc))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].pulsepressureend_calc = s_tran_result
   ELSEIF (ce2.event_cd IN (pulsepressurestart_calc, pulsepressurestartautotransfusion_calc))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].pulsepressurestart_calc = s_tran_result
   ELSEIF (ce2.event_cd IN (pulseratedelta1_calc, pulseratedelta1autotransfusion_calc))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].pulseratedelta1_calc = s_tran_result
   ELSEIF (ce2.event_cd IN (pulsepressuredelta2_calc, pulsepressuredelta2autotransfusion_calc))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].pulseratedelta2_calc = s_tran_result
   ELSEIF (ce2.event_cd IN (respiratoryratedelta1_calc, respiratoryratedelta1autotransfusion_calc))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].respiratoryratedelta1_calc = s_tran_result
   ELSEIF (ce2.event_cd IN (respiratoryratedelta2_calc, respiratoryratedelta2autotransfusion_calc))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].respiratoryratedelta2_calc = s_tran_result
   ELSEIF (ce2.event_cd=systolicbloodpressuredelta1_calc)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].systolicbloodpressuredelta1_calc =
    s_tran_result
   ELSEIF (ce2.event_cd=systolicbloodpressuredelta2_calc)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].systolicbloodpressuredelta2_calc =
    s_tran_result
   ELSEIF (ce2.event_cd IN (temperaturedelta1_calc, temperaturedelta1autotransfusion_calc))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].temperaturedelta1_calc = s_tran_result
   ELSEIF (ce2.event_cd IN (temperaturedelta2_calc, temperaturedelta2autotransfusion_calc))
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].temperaturedelta2_calc = s_tran_result
   ELSEIF (ce2.event_cd=transfusionratecryoprecipitate_calc)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].transfusionratecryoprecipitate_calc =
    s_tran_result
   ELSEIF (ce2.event_cd=transfusionrateffp_calc)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].transfusionrateffp_calc = s_tran_result
   ELSEIF (ce2.event_cd=transfusionrateivig_calc)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].transfusionrateivig_calc = s_tran_result
   ELSEIF (ce2.event_cd=transfusionrateplatelets_calc)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].transfusionrateplatelets_calc =
    s_tran_result
   ELSEIF (ce2.event_cd=transfusionraterbcs_calc)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].transfusionraterbcs_calc = s_tran_result
   ELSEIF (ce2.event_cd=transfusiontime_calc)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].transfusiontime_calc = s_tran_result
   ELSEIF (ce2.event_cd=additionalunitdocumentation)
    CALL echo(build("UPPI=",s_tran_result)), forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    additional_unit_documentation = s_tran_result
   ENDIF
  FOOT  ce2.event_cd
   stat = 0
  FOOT  d2.seq
   IF (i_consent_cnt=1
    AND i_vital_cnt=24
    AND i_infused_cnt > 0
    AND i_reaction_cnt=1
    AND i_witness_cnt=1)
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_incompliance = "Yes", formscomplete = (
    formscomplete+ 1)
   ELSE
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_incompliance = "No", formsincomplete = (
    formsincomplete+ 1)
   ENDIF
   totalforms = (totalforms+ 1), old_d1seq = d1.seq
  FOOT  d1.seq
   i_instance_cnt = 0
  WITH nocounter, outerjoin = d3
 ;end select
 SET endtime = cnvtdatetime(curdate,curtime3)
 SET selecttime6 = datetimediff(cnvtdatetime(endtime),cnvtdatetime(starttime),5)
 CALL echo(build("selecttime6 = ",selecttime6))
 SET starttime = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  event_id = forms->patientslist[d1.seq].forminstanceslist[d2.seq].f_parent_event_id, o_catalog_disp
   = uar_get_code_display(o.catalog_cd), event_name = cnvtupper(uar_get_code_display(ce.event_cd)),
  ce.result_val, ce_result_units = uar_get_code_display(ce.result_units_cd), result_status =
  uar_get_code_display(ce.result_status_cd),
  ce.event_end_dt_tm
  FROM (dummyt d1  WITH seq = value(size(forms->patientslist,5))),
   (dummyt d2  WITH seq = 1),
   orders o,
   clinical_event ce
  PLAN (d1
   WHERE maxrec(d2,size(forms->patientslist[d1.seq].forminstanceslist,5)))
   JOIN (d2)
   JOIN (o
   WHERE (o.person_id=forms->patientslist[d1.seq].f_person_id)
    AND o.catalog_cd IN (lab_bun, lab_inr, lab_btypenatriureticpeptide, lab_cbcwdifferential,
   lab_creactiveprotein,
   lab_troponintquant))
   JOIN (ce
   WHERE ce.order_id=o.order_id
    AND ((ce.view_level+ 0)=1)
    AND ((ce.publish_flag+ 0)=1)
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ((ce.event_end_dt_tm+ 0) BETWEEN cnvtdatetime(datetimeadd(forms->patientslist[d1.seq].
     forminstanceslist[d2.seq].d_transfusionstarttime,- ((720/ 1440.0)))) AND cnvtdatetime(
    datetimeadd(forms->patientslist[d1.seq].forminstanceslist[d2.seq].d_transfusionstarttime,(180/
     1440.0))))
    AND ce.result_status_cd IN (mf_modified_cd, mf_auth_cd, mf_altered_cd)
    AND ce.result_val > " ")
  ORDER BY d1.seq, d2.seq, o_catalog_disp,
   ce.event_end_dt_tm DESC
  HEAD d1.seq
   null
  HEAD d2.seq
   stat = alterlist(forms->patientslist[d1.seq].forminstanceslist[d2.seq].lab_orders,10), cnt_lab = 0
  DETAIL
   cnt_lab = (cnt_lab+ 1)
   IF (mod(cnt_lab,10)=1
    AND cnt_lab > 1)
    stat = alterlist(forms->patientslist[d1.seq].forminstanceslist[d2.seq].lab_orders,(cnt_lab+ 9))
   ENDIF
   forms->patientslist[d1.seq].forminstanceslist[d2.seq].lab_orders[cnt_lab].catalog_disp =
   o_catalog_disp, forms->patientslist[d1.seq].forminstanceslist[d2.seq].lab_orders[cnt_lab].
   result_name = event_name, forms->patientslist[d1.seq].forminstanceslist[d2.seq].lab_orders[cnt_lab
   ].result_val = ce.result_val,
   forms->patientslist[d1.seq].forminstanceslist[d2.seq].lab_orders[cnt_lab].result_unit =
   ce_result_units, forms->patientslist[d1.seq].forminstanceslist[d2.seq].lab_orders[cnt_lab].
   event_end_dt_tm = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d")
  FOOT  d2.seq
   stat = alterlist(forms->patientslist[d1.seq].forminstanceslist[d2.seq].lab_orders,cnt_lab),
   cnt_lab = 0
  WITH nocounter
 ;end select
 SET endtime = cnvtdatetime(curdate,curtime3)
 SET selecttime1 = datetimediff(cnvtdatetime(endtime),cnvtdatetime(starttime),5)
 CALL echo(build("selecttime labs = ",selecttime1))
 SET starttime = cnvtdatetime(curdate,curtime3)
 SET analgesics = "58"
 SET miscellaneousanalgesics = "59"
 SET narcoticanalgesics = "60"
 SET nonsteroidalantiinflammatoryagents = "61"
 SET analgesiccombinations = "63"
 SET narcoticanalgesiccombinations = "191"
 SELECT INTO "nl:"
  pre_med_event = forms->patientslist[d1.seq].forminstanceslist[d2.seq].f_parent_event_id, order_name
   = build(o.order_mnemonic,"(",o.hna_order_mnemonic,")")
  FROM (dummyt d1  WITH seq = value(size(forms->patientslist,5))),
   (dummyt d2  WITH seq = 1),
   orders o,
   clinical_event ce,
   ce_med_result cmr,
   alt_sel_list asl,
   alt_sel_cat a
  PLAN (d1
   WHERE maxrec(d2,size(forms->patientslist[d1.seq].forminstanceslist,5)))
   JOIN (d2)
   JOIN (o
   WHERE (forms->patientslist[d1.seq].f_person_id=o.person_id)
    AND ((o.catalog_type_cd+ 0)=pharmacy)
    AND ((o.template_order_flag+ 0) IN (0, 1, 2, 3))
    AND ((o.clin_relevant_updt_dt_tm+ 0) <= sysdate))
   JOIN (ce
   WHERE ce.encntr_id=o.encntr_id
    AND ce.order_id=o.order_id
    AND ((ce.view_level+ 0)=1)
    AND ((ce.event_end_dt_tm+ 0) <= cnvtdatetime(forms->patientslist[d1.seq].forminstanceslist[d2.seq
    ].d_transfusionendtime))
    AND ((ce.valid_until_dt_tm+ 0) > sysdate))
   JOIN (cmr
   WHERE cmr.event_id=ce.event_id
    AND cmr.admin_start_dt_tm BETWEEN cnvtlookbehind("1,D",cnvtdatetime(forms->patientslist[d1.seq].
     forminstanceslist[d2.seq].d_transfusionendtime)) AND cnvtdatetime(forms->patientslist[d1.seq].
    forminstanceslist[d2.seq].d_transfusionendtime))
   JOIN (asl
   WHERE asl.synonym_id=cmr.synonym_id
    AND asl.synonym_id > 0)
   JOIN (a
   WHERE asl.alt_sel_category_id=a.alt_sel_category_id
    AND ((a.ahfs_ind+ 0)=1)
    AND cnvtupper(a.short_description) IN (analgesics, miscellaneousanalgesics, narcoticanalgesics,
   nonsteroidalantiinflammatoryagents, analgesiccombinations,
   narcoticanalgesiccombinations))
  ORDER BY d1.seq, d2.seq, ce.event_id
  HEAD d1.seq
   null
  HEAD d2.seq
   cnt_pre_meds = 0, stat = alterlist(forms->patientslist[d1.seq].forminstanceslist[d2.seq].pre_meds,
    10)
  HEAD ce.event_id
   cnt_pre_meds = (cnt_pre_meds+ 1)
   IF (mod(cnt_pre_meds,10)=1
    AND cnt_pre_meds > 1)
    stat = alterlist(forms->patientslist[d1.seq].forminstanceslist[d2.seq].pre_meds,(cnt_pre_meds+ 9)
     )
   ENDIF
   forms->patientslist[d1.seq].forminstanceslist[d2.seq].pre_meds[cnt_pre_meds].order_name =
   order_name, forms->patientslist[d1.seq].forminstanceslist[d2.seq].pre_meds[cnt_pre_meds].
   meds_category = a.long_description, forms->patientslist[d1.seq].forminstanceslist[d2.seq].
   pre_meds[cnt_pre_meds].order_id = o.order_id,
   forms->patientslist[d1.seq].forminstanceslist[d2.seq].pre_meds[cnt_pre_meds].date_time_given =
   format(cmr.admin_start_dt_tm,"mm/dd/yy hh:mm;;d")
  FOOT  d2.seq
   stat = alterlist(forms->patientslist[d1.seq].forminstanceslist[d2.seq].pre_meds,cnt_pre_meds),
   cnt_pre_meds = 0
  WITH nocounter
 ;end select
 SET endtime = cnvtdatetime(curdate,curtime3)
 CALL echo(build("selecttime presmeds = ",datetimediff(cnvtdatetime(endtime),cnvtdatetime(starttime),
    5)))
 SELECT INTO "nl:"
  ce_result_units_disp = uar_get_code_display(ce.result_units_cd)
  FROM (dummyt d1  WITH seq = value(size(forms->patientslist,5))),
   (dummyt d2  WITH seq = 1),
   clinical_event ce
  PLAN (d1
   WHERE maxrec(d2,size(forms->patientslist[d1.seq].forminstanceslist,5)))
   JOIN (d2)
   JOIN (ce
   WHERE (ce.encntr_id=forms->patientslist[d1.seq].f_encntr_id)
    AND ce.event_end_dt_tm <= cnvtdatetime(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    d_performed_dt_tm)
    AND ce.event_cd=weight
    AND ce.result_status_cd IN (mf_modified_cd, mf_auth_cd, mf_altered_cd)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime))
  ORDER BY ce.encntr_id, ce.event_end_dt_tm DESC
  DETAIL
   forms->patientslist[d1.seq].forminstanceslist[d2.seq].weight = concat(substring(1,(findstring(".",
      ce.result_val,1,0)+ 2),ce.result_val)," ",trim(ce_result_units_disp,3)," ",format(ce
     .event_end_dt_tm,";;q"))
  WITH nocounter
 ;end select
 CALL echo("Get BMI")
 SET starttime = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(forms->patientslist,5))),
   (dummyt d2  WITH seq = 1),
   clinical_event ce
  PLAN (d1
   WHERE maxrec(d2,size(forms->patientslist[d1.seq].forminstanceslist,5)))
   JOIN (d2)
   JOIN (ce
   WHERE (ce.encntr_id=forms->patientslist[d1.seq].f_encntr_id)
    AND ce.event_end_dt_tm <= cnvtdatetime(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    d_performed_dt_tm)
    AND ce.event_cd=bodymassindex
    AND ce.result_status_cd IN (mf_modified_cd, mf_auth_cd, mf_altered_cd)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime))
  ORDER BY ce.encntr_id, ce.event_end_dt_tm DESC
  DETAIL
   forms->patientslist[d1.seq].forminstanceslist[d2.seq].bmi = substring(1,findstring(".",ce
     .result_val,1,0),ce.result_val)
  WITH nocounter
 ;end select
 SET endtime = cnvtdatetime(curdate,curtime3)
 CALL echo(build("selecttime1 = ",datetimediff(cnvtdatetime(endtime),cnvtdatetime(starttime),5)))
 CALL echo("Get smoking cessation,ABO")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(forms->patientslist,5))),
   (dummyt d2  WITH seq = 1),
   clinical_event ce
  PLAN (d1
   WHERE maxrec(d2,size(forms->patientslist[d1.seq].forminstanceslist,5)))
   JOIN (d2)
   JOIN (ce
   WHERE (ce.encntr_id=forms->patientslist[d1.seq].f_encntr_id)
    AND ce.event_end_dt_tm <= cnvtdatetime(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    d_performed_dt_tm)
    AND ce.event_cd IN (smokingcessation, rh, abo, bloodtype, rhtestonly1,
   rhtestonly2)
    AND ce.result_status_cd IN (mf_modified_cd, mf_auth_cd, mf_altered_cd)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ((ce.view_level+ 0)=1)
    AND ((ce.publish_flag+ 0)=1)
    AND ce.result_val > " ")
  ORDER BY d1.seq, d2.seq, ce.event_end_dt_tm DESC,
   ce.event_cd
  HEAD REPORT
   cnt_smoke = 0, cnt_abo = 0
  HEAD d1.seq
   null
  HEAD d2.seq
   cnt_smoke = 0, cnt_abo = 0
  DETAIL
   IF (ce.event_cd=smokingcessation)
    cnt_smoke = (cnt_smoke+ 1)
    IF (cnt_smoke=1)
     forms->patientslist[d1.seq].forminstanceslist[d2.seq].smokingcessation = trim(ce.result_val,3)
    ENDIF
   ELSEIF (ce.event_cd IN (rh, abo, bloodtype, rhtestonly1, rhtestonly2))
    cnt_abo = (cnt_abo+ 1)
    IF (cnt_abo=1)
     forms->patientslist[d1.seq].forminstanceslist[d2.seq].abo = concat(trim(uar_get_code_display(ce
        .event_cd)),": ",trim(ce.result_val)," ",trim(uar_get_code_display(ce.result_units_cd)),
      trim(format(cnvtdatetime(ce.event_end_dt_tm),"DD-MMM_YY HH:MM:SS;;q")))
    ENDIF
   ENDIF
  FOOT REPORT
   cnt_smoke = 0, cnt_abo = 0
  WITH nocounter
 ;end select
 SET endtime = cnvtdatetime(curdate,curtime3)
 CALL echo(build("selecttime  smoking/abo = ",datetimediff(cnvtdatetime(endtime),cnvtdatetime(
     starttime),5)))
 CALL echorecord(forms)
 SET starttime = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  ce.performed_prsnl_id
  FROM (dummyt d1  WITH seq = value(size(forms->patientslist,5))),
   (dummyt d2  WITH seq = 1),
   clinical_event ce,
   prsnl p
  PLAN (d1
   WHERE maxrec(d2,size(forms->patientslist[d1.seq].forminstanceslist,5)))
   JOIN (d2)
   JOIN (ce
   WHERE (ce.encntr_id=forms->patientslist[d1.seq].f_encntr_id)
    AND (ce.parent_event_id=forms->patientslist[d1.seq].forminstanceslist[d2.seq].f_parent_event_id)
    AND ce.result_status_cd IN (mf_modified_cd, mf_auth_cd, mf_altered_cd))
   JOIN (p
   WHERE ce.performed_prsnl_id=p.person_id)
  ORDER BY ce.parent_event_id, ce.performed_dt_tm
  HEAD REPORT
   s_nurses = fillstring(100," ")
  HEAD ce.parent_event_id
   i_first = 0, s_nurses = fillstring(100," ")
  DETAIL
   IF (i_first=0)
    s_nurses = trim(p.name_full_formatted), forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    s_originalnurse = trim(p.name_full_formatted),
    CALL echo(build("BOB:",p.name_full_formatted,":",p.person_id,":",
     ce.parent_event_id))
   ENDIF
   IF (i_first=1)
    IF (findstring(trim(p.name_full_formatted),s_nurses,1,1)=0)
     s_nurses = build(s_nurses,",",trim(p.name_full_formatted))
    ENDIF
   ENDIF
   i_first = 1
  FOOT  ce.parent_event_id
   forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_nursesdocumented = s_nurses
  WITH nocounter
 ;end select
 SET endtime = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(forms->patientslist,5))),
   (dummyt d2  WITH seq = 1),
   orders o,
   order_action oa,
   prsnl pr
  PLAN (d1
   WHERE maxrec(d2,size(forms->patientslist[d1.seq].forminstanceslist,5)))
   JOIN (d2)
   JOIN (o
   WHERE (o.order_id=forms->patientslist[d1.seq].forminstanceslist[d2.seq].order_id))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=1)
   JOIN (pr
   WHERE pr.person_id=oa.order_provider_id
    AND pr.physician_ind=1)
  DETAIL
   forms->patientslist[d1.seq].forminstanceslist[d2.seq].order_name_w_phys = concat(trim(o
     .order_mnemonic,3),", ",trim(pr.name_first,3)," ",trim(pr.name_last,3),
    trim(format(o.orig_order_dt_tm,"SHORTDATETIME"),3))
  WITH nocounter
 ;end select
 FREE RECORD dlrec
 RECORD dlrec(
   1 encntr_total = i4
   1 seq[*]
     2 encntr_id = f8
     2 person_id = f8
     2 start_date = dq8
     2 end_date = dq8
     2 total_intake = f8
     2 total_output = f8
     2 balance = f8
     2 total_vitals = i4
     2 vitals[*]
       3 temp_result = vc
       3 temp_range = vc
       3 systolic_bp_result = vc
       3 systolic_bp_range = vc
       3 diastolic_bp_result = vc
       3 diastolic_bp_range = vc
       3 resp_rate_result = vc
       3 resp_rate_range = vc
       3 pulse_result = vc
       3 pulse_range = vc
       3 o2_sat_result = vc
       3 o2_sat_range = vc
       3 liters_per_min = vc
       3 mode_of_delivery = vc
     2 weights[*]
       3 weight_dt_tm = vc
       3 weight_value = vc
       3 weight_unit = vc
     2 weight_tot_unit = vc
     2 weight_change = f8
     2 weight_up_down = c5
     2 total_titrate_cnt = i4
     2 titrate[*]
       3 12_io_line = vc
       3 12_io_total = vc
       3 24_io_line = vc
       3 24_io_total = vc
     2 total_io = i4
     2 io[*]
       3 type = vc
       3 hour_range = vc
       3 io_line = vc
     2 intake_line_cnt = i4
     2 intake_line[*]
       3 column1 = vc
       3 column2 = vc
     2 output_line_cnt = i4
     2 output_line[*]
       3 column1 = vc
       3 column2 = vc
 ) WITH persistscript
 EXECUTE bhs_incl_get_io_by_given_range
 SET valid_start_date = "NO"
 SET valid_end_date = "NO"
 SET starttime = cnvtdatetime(curdate,curtime3)
 FOR (pat_cnt = 1 TO size(forms->patientslist,5))
   FOR (form_cnt = 1 TO size(forms->patientslist[pat_cnt].forminstanceslist,5))
     IF ((forms->patientslist[pat_cnt].forminstanceslist[form_cnt].d_transfusionstarttime != null)
      AND (forms->patientslist[pat_cnt].forminstanceslist[form_cnt].d_transfusionstarttime != 0)
      AND cnvtdatetime(forms->patientslist[pat_cnt].forminstanceslist[form_cnt].
      d_transfusionstarttime) < cnvtdatetime(forms->patientslist[pat_cnt].forminstanceslist[form_cnt]
      .d_transfusionendtime))
      SET forms->patientslist[pat_cnt].forminstanceslist[form_cnt].valid_transfusionstarttime = trim(
       "YES",3)
     ENDIF
   ENDFOR
 ENDFOR
 CALL echo("get pre trans")
 FOR (pat_cnt = 1 TO size(forms->patientslist,5))
   FOR (form_cnt = 1 TO size(forms->patientslist[pat_cnt].forminstanceslist,5))
     IF ((forms->patientslist[pat_cnt].forminstanceslist[form_cnt].d_transfusionendtime != null)
      AND (forms->patientslist[pat_cnt].forminstanceslist[form_cnt].d_transfusionendtime != 0)
      AND cnvtdatetime(forms->patientslist[pat_cnt].forminstanceslist[form_cnt].d_transfusionendtime)
      >= cnvtdatetime(datetimeadd(beg_date_qual,- ((720/ 1440.0))))
      AND cnvtdatetime(forms->patientslist[pat_cnt].forminstanceslist[form_cnt].d_transfusionendtime)
      <= cnvtdatetime(datetimeadd(end_date_qual,(720/ 1440.0))))
      SET forms->patientslist[pat_cnt].forminstanceslist[form_cnt].valid_transfusionendtime = trim(
       "YES",3)
     ENDIF
   ENDFOR
 ENDFOR
 SET endtime = cnvtdatetime(curdate,curtime3)
 CALL echo("get IO 12 prior to start of transfusion")
 SET starttime = cnvtdatetime(curdate,curtime3)
 FOR (pat_cnt = 1 TO size(forms->patientslist,5))
   FOR (form_cnt = 1 TO size(forms->patientslist[pat_cnt].forminstanceslist,5))
     IF ((forms->patientslist[pat_cnt].forminstanceslist[form_cnt].valid_transfusionstarttime="YES"))
      SET starte_time = datetimeadd(cnvtdatetime(forms->patientslist[pat_cnt].forminstanceslist[
        form_cnt].d_transfusionstarttime),- ((720/ 1440.0)))
      SET ende_time = cnvtdatetime(forms->patientslist[pat_cnt].forminstanceslist[form_cnt].
       d_transfusionstarttime)
      SET stat = initrec(dlrec)
      SET stat = alterlist(dlrec->seq,1)
      SET dlrec->encntr_total = 1
      SET dlrec->seq[1].encntr_id = forms->patientslist[pat_cnt].f_encntr_id
      SET dlrec->seq[1].person_id = forms->patientslist[pat_cnt].f_person_id
      SET dlrec->seq[1].start_date = datetimeadd(cnvtdatetime(forms->patientslist[pat_cnt].
        forminstanceslist[form_cnt].d_transfusionstarttime),- ((720/ 1440.0)))
      SET dlrec->seq[1].end_date = datetimeadd(cnvtdatetime(forms->patientslist[pat_cnt].
        forminstanceslist[form_cnt].d_transfusionstarttime),- ((0.0167/ 1440.0)))
      CALL echo("get IO")
      CALL get_io(0)
      SET forms->patientslist[pat_cnt].forminstanceslist[form_cnt].pre_total_intake = dlrec->seq[1].
      total_intake
      SET forms->patientslist[pat_cnt].forminstanceslist[form_cnt].pre_total_output = dlrec->seq[1].
      total_output
      SET forms->patientslist[pat_cnt].forminstanceslist[form_cnt].pre_balance = dlrec->seq[1].
      balance
     ENDIF
   ENDFOR
   CALL echo("end get IO 12 prior to start of transfusion")
   CALL echo("get pre trans")
 ENDFOR
 SET endtime = cnvtdatetime(curdate,curtime3)
 CALL echo("get IO 12 prior to start of transfusion")
 SET starttime = cnvtdatetime(curdate,curtime3)
 FOR (pat_cnt = 1 TO size(forms->patientslist,5))
   FOR (form_cnt = 1 TO size(forms->patientslist[pat_cnt].forminstanceslist,5))
    IF ((forms->patientslist[pat_cnt].forminstanceslist[form_cnt].valid_transfusionendtime="YES"))
     SET stat = initrec(dlrec)
     SET stat = alterlist(dlrec->seq,1)
     SET dlrec->encntr_total = 1
     SET dlrec->seq[1].encntr_id = forms->patientslist[pat_cnt].f_encntr_id
     SET dlrec->seq[1].person_id = forms->patientslist[pat_cnt].f_person_id
     SET dlrec->seq[1].start_date = datetimeadd(cnvtdatetime(forms->patientslist[pat_cnt].
       forminstanceslist[form_cnt].d_transfusionendtime),(0.0167/ 1440.0))
     SET dlrec->seq[1].end_date = datetimeadd(cnvtdatetime(forms->patientslist[pat_cnt].
       forminstanceslist[form_cnt].d_transfusionendtime),(720/ 1440.0))
     CALL echo("get IO")
     CALL get_io(0)
     SET forms->patientslist[pat_cnt].forminstanceslist[form_cnt].post_total_intake = dlrec->seq[1].
     total_intake
     SET forms->patientslist[pat_cnt].forminstanceslist[form_cnt].post_total_output = dlrec->seq[1].
     total_output
     SET forms->patientslist[pat_cnt].forminstanceslist[form_cnt].post_balance = dlrec->seq[1].
     balance
    ENDIF
    CALL echo("Post Transfusion")
   ENDFOR
 ENDFOR
 CALL echo("End get IO 12 after transfusion")
 SET endtime = cnvtdatetime(curdate,curtime3)
 CALL echo(build("selecttime post start = ",datetimediff(cnvtdatetime(endtime),cnvtdatetime(starttime
     ),5)))
 CALL echo("get io during transfusion")
 SET starttime = cnvtdatetime(curdate,curtime3)
 SET starttime = cnvtdatetime(curdate,curtime3)
 FOR (pat_cnt = 1 TO size(forms->patientslist,5))
   FOR (form_cnt = 1 TO size(forms->patientslist[pat_cnt].forminstanceslist,5))
    IF ((forms->patientslist[pat_cnt].forminstanceslist[form_cnt].valid_transfusionendtime="YES")
     AND (forms->patientslist[pat_cnt].forminstanceslist[form_cnt].valid_transfusionstarttime="YES"))
     SET starte_time = cnvtdatetime(forms->patientslist[pat_cnt].forminstanceslist[form_cnt].
      d_transfusionstarttime)
     SET ende_time = cnvtdatetime(forms->patientslist[pat_cnt].forminstanceslist[form_cnt].
      d_transfusionendtime)
     SET stat = initrec(dlrec)
     SET stat = alterlist(dlrec->seq,1)
     SET dlrec->encntr_total = 1
     SET dlrec->seq[1].encntr_id = forms->patientslist[pat_cnt].f_encntr_id
     SET dlrec->seq[1].person_id = forms->patientslist[pat_cnt].f_person_id
     SET dlrec->seq[1].start_date = cnvtdatetime(forms->patientslist[pat_cnt].forminstanceslist[
      form_cnt].d_transfusionstarttime)
     SET dlrec->seq[1].end_date = cnvtdatetime(forms->patientslist[pat_cnt].forminstanceslist[
      form_cnt].d_transfusionendtime)
     CALL echo("get IO")
     CALL get_io(0)
     SET forms->patientslist[pat_cnt].forminstanceslist[form_cnt].total_intake = dlrec->seq[1].
     total_intake
     SET forms->patientslist[pat_cnt].forminstanceslist[form_cnt].total_output = dlrec->seq[1].
     total_output
     SET forms->patientslist[pat_cnt].forminstanceslist[form_cnt].balance = dlrec->seq[1].balance
    ENDIF
    CALL echo("io during transfusion")
   ENDFOR
 ENDFOR
 SET endtime = cnvtdatetime(curdate,curtime3)
 CALL echo("End get io during transfusion")
 SELECT INTO value(trim(var_output))
  event_id = forms->patientslist[d1.seq].forminstanceslist[d2.seq].f_parent_event_id, account_number
   = substring(1,20,trim(forms->patientslist[d1.seq].s_finnbr)), age = forms->patientslist[d1.seq].
  age,
  facilty = forms->patientslist[d1.seq].facility, nurseunit =
  IF ((forms->patientslist[d1.seq].s_person_name IN ("_*"))) " "
  ELSE substring(1,30,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_nurseunitname))
  ENDIF
  , encounter_type = substring(1,30,trim(forms->patientslist[d1.seq].patient_type)),
  medical_record_number = forms->patientslist[d1.seq].mrn, admit_date = substring(1,30,trim(forms->
    patientslist[d1.seq].admit_date)), discharge_date = forms->patientslist[d1.seq].discharge_date,
  admitting_md = substring(1,30,trim(forms->patientslist[d1.seq].admitting_dr)), admit_diagnosis =
  forms->patientslist[d1.seq].admit_diag, problem_list = substring(1,300,trim(forms->patientslist[d1
    .seq].problems)),
  service = substring(1,30,trim(forms->patientslist[d1.seq].service)), primary_provider = substring(1,
   30,trim(forms->patientslist[d1.seq].primary_provider)), weight = substring(1,30,trim(forms->
    patientslist[d1.seq].forminstanceslist[d2.seq].weight)),
  bmi = forms->patientslist[d1.seq].forminstanceslist[d2.seq].bmi, abo_result = substring(1,30,trim(
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].abo)), compatiblity_result = substring(1,30,
   trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].transfusioncompatibilityresult)),
  unit_id_lot_number = substring(1,40,trim(replace(replace(forms->patientslist[d1.seq].
      forminstanceslist[d2.seq].unitidnumberlotnumber,char(13)," "),char(10)," "))), smoke_cessation
   = substring(1,100,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].smokingcessation)),
  transfusion_order = substring(1,150,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    order_name_w_phys)),
  formname = substring(1,40,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].formname)),
  performed_on = substring(1,25,forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_performed_on),
  allnursesthatdocumentedontheform = substring(1,100,trim(forms->patientslist[d1.seq].
    forminstanceslist[d2.seq].s_nursesdocumented)),
  consentsignedcurrentdta = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq]
    .s_consentsignedcurrentornotapplicable)), io_intake_12hrs_prior = forms->patientslist[d1.seq].
  forminstanceslist[d2.seq].pre_total_intake, io_output_12hrs_prior = forms->patientslist[d1.seq].
  forminstanceslist[d2.seq].pre_total_output,
  io_balance_12hrs_prior = forms->patientslist[d1.seq].forminstanceslist[d2.seq].pre_balance,
  io_intake_during_txfuse = forms->patientslist[d1.seq].forminstanceslist[d2.seq].total_intake,
  io_output_during_txfuse = forms->patientslist[d1.seq].forminstanceslist[d2.seq].total_output,
  io_balance_during_txfuse = forms->patientslist[d1.seq].forminstanceslist[d2.seq].balance,
  io_intake_12hrs_post = forms->patientslist[d1.seq].forminstanceslist[d2.seq].post_total_intake,
  io_output_12hrs_post = forms->patientslist[d1.seq].forminstanceslist[d2.seq].post_total_output,
  io_balance_12hrs_post = forms->patientslist[d1.seq].forminstanceslist[d2.seq].post_balance,
  valid_start = trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].valid_transfusionstarttime
   ), transfusionstarttime = substring(1,30,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq
    ].s_transfusionstarttime)),
  temperaturestart = substring(1,30,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    s_temperaturestart)), temperatureroutestart = substring(1,25,trim(forms->patientslist[d1.seq].
    forminstanceslist[d2.seq].s_temperatureroutestart)), pulseratestart = substring(1,25,trim(forms->
    patientslist[d1.seq].forminstanceslist[d2.seq].s_pulseratestart)),
  respiratoryratestart = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    s_respiratoryratestart)), systolicbloodpressurestart = substring(1,25,trim(forms->patientslist[d1
    .seq].forminstanceslist[d2.seq].s_systolicbloodpressurestart)), diastolicbloodpressurestart =
  substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    s_diastolicbloodpressurestart)),
  oxygensaturationstart = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    s_oxygensaturationstart)), transfusionstartplus15min = substring(1,30,trim(forms->patientslist[d1
    .seq].forminstanceslist[d2.seq].s_transfusionstartplus15min)), temperature15min = substring(1,25,
   trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_temperature15min)),
  temperatureroute15min = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    s_temperatureroute15min)), pulserate15min = substring(1,25,trim(forms->patientslist[d1.seq].
    forminstanceslist[d2.seq].s_pulserate15min)), respiratoryrate15min = substring(1,25,trim(forms->
    patientslist[d1.seq].forminstanceslist[d2.seq].s_respiratoryrate15min)),
  systolicbloodpressure15min = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2
    .seq].s_systolicbloodpressure15min)), diastolicbloodpressure15min = substring(1,25,trim(forms->
    patientslist[d1.seq].forminstanceslist[d2.seq].s_diastolicbloodpressure15min)),
  oxygensaturation15min = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    s_oxygensaturation15min)),
  transfusionendtime = substring(1,30,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    s_transfusionendtime)), valid_end = trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
   valid_transfusionstarttime), temperatureend = substring(1,25,trim(forms->patientslist[d1.seq].
    forminstanceslist[d2.seq].s_temperatureend)),
  temperaturerouteend = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    s_temperaturerouteend)), pulserateend = substring(1,25,trim(forms->patientslist[d1.seq].
    forminstanceslist[d2.seq].s_pulserateend)), respiratoryrateend = substring(1,25,trim(forms->
    patientslist[d1.seq].forminstanceslist[d2.seq].s_respiratoryrateend)),
  systolicbloodpressureend = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq
    ].s_systolicbloodpressureend)), diastolicbloodpressureend = substring(1,25,trim(forms->
    patientslist[d1.seq].forminstanceslist[d2.seq].s_diastolicbloodpressureend)), oxygensaturationend
   = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_oxygensaturationend)
   ),
  albuminvo = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_albuminvol)
   ), cryoprecipitate = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    s_cryoprecipitate)), factorviia = substring(1,25,trim(forms->patientslist[d1.seq].
    forminstanceslist[d2.seq].sfactorviia)),
  factorviiivol = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    s_factorviiivol)), factorixcomplex = substring(1,25,trim(forms->patientslist[d1.seq].
    forminstanceslist[d2.seq].s_factorixcomplex)), factorixvol = substring(1,25,trim(forms->
    patientslist[d1.seq].forminstanceslist[d2.seq].s_factorixvol)),
  ffp = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_ffp)),
  granulocytes = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    s_granulocytes)), ivig = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq
    ].s_ivig)),
  platelets = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_platelets)),
  rbcvol = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_rbcvol)),
  rhimmuneglobulin = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    s_rhimmuneglobulin)),
  bloodproductamountinfused = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2
    .seq].s_bloodproductamountinfused)), transfusionreactiondescription = substring(1,25,trim(forms->
    patientslist[d1.seq].forminstanceslist[d2.seq].s_transfusionreactiondescription)),
  diastolicbloodpressuredelta1 = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2
    .seq].diastolicbloodpressuredelta1_calc)),
  diastolicbloodpressuredelta2 = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2
    .seq].diastolicbloodpressuredelta2_calc)), meanarterialpressure15min = substring(1,25,trim(forms
    ->patientslist[d1.seq].forminstanceslist[d2.seq].meanarterialpressure15min_calc)),
  meanarterialpressuredelta1 = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2
    .seq].meanarterialpressuredelta1_calc)),
  meanarterialpressuredelta2 = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2
    .seq].meanarterialpressuredelta2_calc)), meanarterialpressureend = substring(1,25,trim(forms->
    patientslist[d1.seq].forminstanceslist[d2.seq].meanarterialpressureend_calc)),
  meanarterialpressurestart = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2
    .seq].meanarterialpressurestart_calc)),
  oxygensaturationdelta1 = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    oxygensaturationdelta1_calc)), oxygensaturationdelta2 = substring(1,25,trim(forms->patientslist[
    d1.seq].forminstanceslist[d2.seq].oxygensaturationdelta2_calc)), pulsepressure15min = substring(1,
   25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].pulsepressure15min_calc)),
  pulsepressuredelta1 = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    pulsepressuredelta1_calc)), pulsepressuredelta2 = substring(1,25,trim(forms->patientslist[d1.seq]
    .forminstanceslist[d2.seq].pulsepressuredelta2_calc)), pulsepressureend = substring(1,25,trim(
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].pulsepressureend_calc)),
  pulsepressurestart = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    pulsepressurestart_calc)), pulseratedelta1 = substring(1,25,trim(forms->patientslist[d1.seq].
    forminstanceslist[d2.seq].pulseratedelta1_calc)), pulseratedelta2 = substring(1,25,trim(forms->
    patientslist[d1.seq].forminstanceslist[d2.seq].pulseratedelta2_calc)),
  respiratoryratedelta1 = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    respiratoryratedelta1_calc)), respiratoryratedelta2 = substring(1,25,trim(forms->patientslist[d1
    .seq].forminstanceslist[d2.seq].respiratoryratedelta2_calc)), systolicbloodpressuredelta1 =
  substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    systolicbloodpressuredelta1_calc)),
  systolicbloodpressuredelta2 = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2
    .seq].systolicbloodpressuredelta2_calc)), temperaturedelta1 = substring(1,25,trim(forms->
    patientslist[d1.seq].forminstanceslist[d2.seq].temperaturedelta1_calc)), temperaturedelta2 =
  substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].temperaturedelta2_calc)),
  transfusionratecryoprecipitate = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[
    d2.seq].transfusionratecryoprecipitate_calc)), transfusionrateffp = substring(1,25,trim(forms->
    patientslist[d1.seq].forminstanceslist[d2.seq].transfusionrateffp_calc)), transfusionrateivig =
  substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].transfusionrateivig_calc)
   ),
  transfusionrateplatelets = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq
    ].transfusionrateplatelets_calc)), transfusionraterbcs = substring(1,25,trim(forms->patientslist[
    d1.seq].forminstanceslist[d2.seq].transfusionraterbcs_calc)), transfusiontime = substring(1,25,
   trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].transfusiontime_calc)),
  incompliance = substring(1,25,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
    s_incompliance)), originalnurse = substring(1,25,trim(forms->patientslist[d1.seq].
    forminstanceslist[d2.seq].s_originalnurse)), nursestatementofattestation = substring(1,50,trim(
    forms->patientslist[d1.seq].forminstanceslist[d2.seq].s_nursestatementofattestation)),
  additionalunitdocumentation = trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
   additional_unit_documentation)
  FROM (dummyt d1  WITH seq = value(size(forms->patientslist,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(forms->patientslist[d1.seq].forminstanceslist,5))
    AND size(forms->patientslist[d1.seq].forminstanceslist,3) > 0)
   JOIN (d2)
  WITH nocounter, format, pcformat(value(filedelimiter1),value(filedelimiter2))
 ;end select
 IF (( $FTPFILES=1))
  SELECT INTO value(trim(var_output1))
   event_id = forms->patientslist[d1.seq].forminstanceslist[d2.seq].f_parent_event_id, lab_order =
   substring(1,30,forms->patientslist[d1.seq].forminstanceslist[d2.seq].lab_orders[d3.seq].
    catalog_disp), result_name = substring(1,30,forms->patientslist[d1.seq].forminstanceslist[d2.seq]
    .lab_orders[d3.seq].result_name),
   result_value = substring(1,30,forms->patientslist[d1.seq].forminstanceslist[d2.seq].lab_orders[d3
    .seq].result_val), result_unit = substring(1,30,forms->patientslist[d1.seq].forminstanceslist[d2
    .seq].lab_orders[d3.seq].result_unit), result_time = substring(1,30,trim(forms->patientslist[d1
     .seq].forminstanceslist[d2.seq].lab_orders[d3.seq].event_end_dt_tm))
   FROM (dummyt d1  WITH seq = value(size(forms->patientslist,5))),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(forms->patientslist[d1.seq].forminstanceslist,5)))
    JOIN (d2
    WHERE maxrec(d3,size(forms->patientslist[d1.seq].forminstanceslist[d2.seq].lab_orders,5)))
    JOIN (d3)
   WITH nocounter, format, pcformat(value(filedelimiter1),value(filedelimiter2)),
    time = 300
  ;end select
  SELECT INTO value(trim(var_output3))
   event_id = forms->patientslist[d1.seq].forminstanceslist[d2.seq].f_parent_event_id,
   pre_med_category = substring(1,40,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].
     pre_meds[d3.seq].meds_category)), pre_med_order = substring(1,100,trim(forms->patientslist[d1
     .seq].forminstanceslist[d2.seq].pre_meds[d3.seq].order_name)),
   time_given = substring(1,100,trim(forms->patientslist[d1.seq].forminstanceslist[d2.seq].pre_meds[
     d3.seq].date_time_given))
   FROM (dummyt d1  WITH seq = value(size(forms->patientslist,5))),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(forms->patientslist[d1.seq].forminstanceslist,5)))
    JOIN (d2
    WHERE maxrec(d3,size(forms->patientslist[d1.seq].forminstanceslist[d2.seq].pre_meds,5)))
    JOIN (d3)
   ORDER BY pre_med_category, pre_med_order
   WITH nocounter, format, pcformat(value(filedelimiter1),value(filedelimiter2))
  ;end select
 ENDIF
 IF (( $FTPFILES=1))
  CALL echo("Send FILES")
  SET filenamein = var_output
  CALL echo(build("fileNameIn =",filenamein))
  SET dclcom = concat("$cust_script/bhs_ftp_file.ksh ",filenamein,
   " 172.17.10.5 'bhs\cisftp' C!sftp01 Biovigilance2")
  SET status = 0
  SET len = size(trim(dclcom))
  CALL dcl(dclcom,len,status)
  CALL echo(status)
  SET stat = remove(var_output)
  CALL echo("Send FILES 2")
  SET filenamein = var_output1
  SET dclcom = concat("$cust_script/bhs_ftp_file.ksh ",filenamein,
   " 172.17.10.5 'bhs\cisftp' C!sftp01 Biovigilance2")
  SET status = 0
  SET len = size(trim(dclcom))
  CALL dcl(dclcom,len,status)
  SET stat = remove(var_output1)
  CALL echo("Send FILES 4")
  SET filenamein = var_output3
  SET dclcom = concat("$cust_script/bhs_ftp_file.ksh ",filenamein,
   " 172.17.10.5 'bhs\cisftp' C!sftp01 Biovigilance2")
  SET status = 0
  SET len = size(trim(dclcom))
  CALL dcl(dclcom,len,status)
  SET stat = remove(var_output3)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = concat("Files have been ftped  to share "), col 0, "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08
  ;end select
 ENDIF
#exit_program
 CALL echorecord(forms)
END GO

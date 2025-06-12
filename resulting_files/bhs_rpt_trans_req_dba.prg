CREATE PROGRAM bhs_rpt_trans_req:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "FIN:" = "0",
  "Form:" = 0,
  "orderingPhy:" = ""
  WITH outdev, fin, form,
  orderingphy
 DECLARE mrn_var = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE dbpdelta2autotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DBPDELTA2AUTOTRANSFUSION")), protect
 DECLARE dbpdelta1autotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DBPDELTA1AUTOTRANSFUSION")), protect
 DECLARE oxygensatdelta2autotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OXYGENSATDELTA2AUTOTRANSFUSION")), protect
 DECLARE oxygensatdelta1autotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OXYGENSATDELTA1AUTOTRANSFUSION")), protect
 DECLARE sbpdelta2autotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SBPDELTA2AUTOTRANSFUSION")), protect
 DECLARE sbpdelta1autotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SBPDELTA1AUTOTRANSFUSION")), protect
 DECLARE mapdelta2autotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MAPDELTA2AUTOTRANSFUSION")), protect
 DECLARE mapdelta1autotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MAPDELTA1AUTOTRANSFUSION")), protect
 DECLARE temperaturedelta2autotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEMPERATUREDELTA2AUTOTRANSFUSION")), protect
 DECLARE temperaturedelta1autotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEMPERATUREDELTA1AUTOTRANSFUSION")), protect
 DECLARE pulseratedelta2autotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSERATEDELTA2AUTOTRANSFUSION")), protect
 DECLARE pulseratedelta1autotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSERATEDELTA1AUTOTRANSFUSION")), protect
 DECLARE bloodproducttransfused = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "BLOODPRODUCTTRANSFUSED")), protect
 DECLARE mapendautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MAPENDAUTOTRANSFUSION")), protect
 DECLARE map15minautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MAP15MINAUTOTRANSFUSION")), protect
 DECLARE mapstartautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MAPSTARTAUTOTRANSFUSION")), protect
 DECLARE respiratoryratedelta2autotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPIRATORYRATEDELTA2AUTOTRANSFUSION")), protect
 DECLARE respiratoryratedelta1autotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPIRATORYRATEDELTA1AUTOTRANSFUSION")), protect
 DECLARE pulsepressure15minautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSEPRESSURE15MINAUTOTRANSFUSION")), protect
 DECLARE pulsepressureendautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSEPRESSUREENDAUTOTRANSFUSION")), protect
 DECLARE pulsepressuredelta1autotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSEPRESSUREDELTA1AUTOTRANSFUSION")), protect
 DECLARE pulsepressurestartautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSEPRESSURESTARTAUTOTRANSFUSION")), protect
 DECLARE pulsepressuredelta2autotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSEPRESSUREDELTA2AUTOTRANSFUSION")), protect
 DECLARE cur_page = i4 WITH protect
 DECLARE unitidnumberlotnumber = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "UNITIDNUMBERLOTNUMBER")), protect
 DECLARE transfusionrateplatelets = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TRANSFUSIONRATEPLATELETS")), protect
 DECLARE transfusionrateivig = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TRANSFUSIONRATEIVIG"
   )), protect
 DECLARE transfusionrateffp = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TRANSFUSIONRATEFFP")),
 protect
 DECLARE transfusionratecryoprecipitate = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TRANSFUSIONRATECRYOPRECIPITATE")), protect
 DECLARE transfusionratealbumin = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TRANSFUSIONRATEALBUMIN")), protect
 DECLARE transfusionraterbcs = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TRANSFUSIONRATERBCS"
   )), protect
 DECLARE transfusionadministrationequipment = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TRANSFUSIONADMINISTRATIONEQUIPMENT")), protect
 DECLARE pulseratedelta2 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATEDELTA2")),
 protect
 DECLARE pulseratedelta1 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATEDELTA1")),
 protect
 DECLARE oxygensaturationdelta2 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OXYGENSATURATIONDELTA2")), protect
 DECLARE oxygensaturationdelta1 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OXYGENSATURATIONDELTA1")), protect
 DECLARE diastolicbloodpressuredelta2 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSUREDELTA2")), protect
 DECLARE diastolicbloodpressuredelta1 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSUREDELTA1")), protect
 DECLARE systolicbloodpressuredelta2 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSUREDELTA2")), protect
 DECLARE systolicbloodpressuredelta1 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSUREDELTA1")), protect
 DECLARE temperaturedelta2 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TEMPERATUREDELTA2")),
 protect
 DECLARE temperaturedelta1 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TEMPERATUREDELTA1")),
 protect
 DECLARE respiratoryratedelta2 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPIRATORYRATEDELTA2")), protect
 DECLARE respiratoryratedelta1 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPIRATORYRATEDELTA1")), protect
 DECLARE meanarterialpressuredelta2 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MEANARTERIALPRESSUREDELTA2")), protect
 DECLARE meanarterialpressuredelta1 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MEANARTERIALPRESSUREDELTA1")), protect
 DECLARE meanarterialpressureend = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MEANARTERIALPRESSUREEND")), protect
 DECLARE meanarterialpressure15min = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MEANARTERIALPRESSURE15MIN")), protect
 DECLARE meanarterialpressurestart = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MEANARTERIALPRESSURESTART")), protect
 DECLARE pulsepressuredelta2 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PULSEPRESSUREDELTA2"
   )), protect
 DECLARE pulsepressureend = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PULSEPRESSUREEND")),
 protect
 DECLARE pulsepressurestart = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PULSEPRESSURESTART")),
 protect
 DECLARE pulsepressuredelta1 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PULSEPRESSUREDELTA1"
   )), protect
 DECLARE pulsepressure15min = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PULSEPRESSURE15MIN")),
 protect
 CALL echo("Inside bhs_rpt_home_care_discharge")
 DECLARE times = dq8
 DECLARE timet = dq8
 SET times = cnvtdatetime(sysdate)
 CALL echo(build("TIME:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(times),5)))
 SET timet = cnvtdatetime(sysdate)
 DECLARE errmsg = vc WITH noconstant(" ")
 IF (validate(link_clineventid) <= 0)
  SET link_clineventid = 0
 ENDIF
 SET formeventid = 0.0
 SET outputdev =  $OUTDEV
 SET retval = 0
 DECLARE log_message = vc WITH noconstant(" ")
 DECLARE encntr_id = f8
 DECLARE becont = i4
 DECLARE tempox = vc WITH noconstant(" ")
 CALL echo("declare constants")
 DECLARE cmrn = f8 WITH constant(uar_get_code_by("MEANING",4,"CMRN")), protect
 DECLARE finnbr = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mrn = f8 WITH constant(uar_get_code_by("DESCRIPTION",4,"Medical Record Number")), protect
 DECLARE orderdoc = f8 WITH constant(uar_get_code_by("MEANING",333,"ORDERDOC")), protect
 DECLARE ordered = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE canceled = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"CANCELED")), protect
 DECLARE deleted = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"DELETED")), protect
 DECLARE incomplete = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"INCOMPLETE")), protect
 DECLARE orderedaction = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER")), protect
 DECLARE altered = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE modified = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE auth = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE primary = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6011,"PRIMARY")), protect
 DECLARE admit = f8 WITH constant(uar_get_code_by("MEANING",17,"ADMIT")), protect
 DECLARE transfusiontagform = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TRANSFUSIONTAGFORM")),
 protect
 DECLARE autotransfusionbloodrecoveryform = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "AUTOTRANSFUSIONBLOODRECOVERYFORM")), protect
 CALL echo(build("TIME:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(times),5)))
 SET times = cnvtdatetime(sysdate)
 DECLARE eos_per = f8 WITH constant(uar_get_code_by("DESCRIPTION",72,"Eos %")), protect
 DECLARE baso_per = f8 WITH constant(uar_get_code_by("DESCRIPTION",72,"Baso %")), protect
 DECLARE mono_per = f8 WITH constant(uar_get_code_by("DESCRIPTION",72,"Mono %")), protect
 DECLARE neut_per = f8 WITH constant(uar_get_code_by("DESCRIPTION",72,"Neut %")), protect
 DECLARE lymph_per = f8 WITH constant(uar_get_code_by("DESCRIPTION",72,"Lymph %")), protect
 DECLARE igm = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"IGM")), protect
 DECLARE iga = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"IGA")), protect
 DECLARE complementc3 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"COMPLEMENTC3")), protect
 DECLARE complementc4 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"COMPLEMENTC4")), protect
 DECLARE ldh = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"LDH")), protect
 DECLARE cbc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"CBC")), protect
 DECLARE inr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"INR")), protect
 DECLARE fibrinogen = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"FIBRINOGEN")), protect
 DECLARE ntprobnp = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"NTPROBNP")), protect
 DECLARE ptt = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PTT")), protect
 DECLARE reticcount = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"RETICCOUNT")), protect
 DECLARE rh = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"RH")), protect
 DECLARE abo = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABO")), protect
 DECLARE bloodtype = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"BLOODTYPE")), protect
 DECLARE antibodyscreen = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ANTIBODYSCREEN")),
 protect
 DECLARE pmhtroponintemplate = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PMHTROPONINTEMPLATE"
   )), protect
 DECLARE troponini = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TROPONINI")), protect
 DECLARE troponintquant = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TROPONINTQUANT")),
 protect
 DECLARE troponint1 = f8 WITH constant(709363), protect
 DECLARE troponint2 = f8 WITH constant(2821152), protect
 DECLARE rhtestonly1 = f8 WITH constant(709363), protect
 DECLARE rhtestonly2 = f8 WITH constant(2821152), protect
 DECLARE nucleatedrbcautomated = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "NUCLEATEDRBCAUTOMATED")), protect
 DECLARE wbcmorphology = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"WBCMORPHOLOGY")), protect
 DECLARE wbc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"WBC")), protect
 DECLARE smearreview = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"SMEARREVIEW")), protect
 DECLARE rdw = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"RDW")), protect
 DECLARE rbcmorphology = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"RBCMORPHOLOGY")), protect
 DECLARE rbc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"RBC")), protect
 DECLARE plateletestimate = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PLATELETESTIMATE")),
 protect
 DECLARE promyelocyte = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PROMYELOCYTE")), protect
 DECLARE plateletcount = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PLATELETCOUNT")), protect
 DECLARE plasmacell = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PLASMACELL")), protect
 DECLARE plateletcomment = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PLATELETCOMMENT")),
 protect
 DECLARE abspromyelocyte = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABSPROMYELOCYTE")),
 protect
 DECLARE abscellother = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABSCELLOTHER")), protect
 DECLARE absneut = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABSNEUT")), protect
 DECLARE absmyelocyte = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABSMYELOCYTE")), protect
 DECLARE absmono = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABSMONO")), protect
 DECLARE absmetamyelocyte = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABSMETAMYELOCYTE")),
 protect
 DECLARE abslymph = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABSLYMPH")), protect
 DECLARE neut = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"NEUT")), protect
 DECLARE abseo = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABSEO")), protect
 DECLARE absblast = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABSBLAST")), protect
 DECLARE absbaso = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABSBASO")), protect
 DECLARE absband = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABSBAND")), protect
 DECLARE myelocytes = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MYELOCYTES")), protect
 DECLARE metamyelocyte = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"METAMYELOCYTE")), protect
 DECLARE mcv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MCV")), protect
 DECLARE mchc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MCHC")), protect
 DECLARE mch = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MCH")), protect
 DECLARE band = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"BAND")), protect
 DECLARE lymph = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"LYMPH")), protect
 DECLARE mpv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MPV")), protect
 DECLARE mono = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MONO")), protect
 DECLARE hgb = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"HGB")), protect
 DECLARE hct = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"HCT")), protect
 DECLARE cellother = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"CELLOTHER")), protect
 DECLARE blasts = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"BLASTS")), protect
 DECLARE atypicallymph = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ATYPICALLYMPH")), protect
 CALL echo(build("TIME72:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(times),5)))
 SET times = cnvtdatetime(sysdate)
 DECLARE mf_transfusionstarttime = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TRANSFUSIONSTARTTIME")), protect
 DECLARE autotransfusionstarttime = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "AUTOTRANSFUSIONSTARTTIME")), protect
 DECLARE mf_temperaturestart = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TEMPERATURESTART")),
 protect
 DECLARE temperaturestartautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEMPERATURESTARTAUTOTRANSFUSION")), protect
 DECLARE mf_temperatureroutestart = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEMPERATUREROUTESTART")), protect
 DECLARE temperatureroutestartautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEMPERATUREROUTESTARTAUTOTRANSFUSION")), protect
 DECLARE mf_pulseratestart = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATESTART")),
 protect
 DECLARE pulseratestartautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSERATESTARTAUTOTRANSFUSION")), protect
 DECLARE mf_respiratoryratestart = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPIRATORYRATESTART")), protect
 DECLARE respiratoryratestartautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPIRATORYRATESTARTAUTOTRANSFUSION")), protect
 DECLARE mf_systolicbloodpressurestart = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURESTART")), protect
 DECLARE sbpstartautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SBPSTARTAUTOTRANSFUSION")), protect
 DECLARE mf_diastolicbloodpressurestart = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURESTART")), protect
 DECLARE dbpstartautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DBPSTARTAUTOTRANSFUSION")), protect
 DECLARE mf_oxygensaturationstart = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OXYGENSATURATIONSTART")), protect
 DECLARE oxygensatstartautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OXYGENSATSTARTAUTOTRANSFUSION")), protect
 CALL echo(build("TIME:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(times),5)))
 SET times = cnvtdatetime(sysdate)
 DECLARE mf_transfusionstartplus15min = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TRANSFUSIONSTARTPLUS15MIN")), protect
 DECLARE autotransfusionstartplus15min = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "AUTOTRANSFUSIONSTARTPLUS15MIN")), protect
 DECLARE mf_temperature15min = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TEMPERATURE15MIN")),
 protect
 DECLARE temperature15minautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEMPERATURE15MINAUTOTRANSFUSION")), protect
 DECLARE mf_temperatureroute15min = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEMPERATUREROUTE15MIN")), protect
 DECLARE temperatureroute15minautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEMPERATUREROUTE15MINAUTOTRANSFUSION")), protect
 DECLARE mf_pulserate15min = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATE15MIN")),
 protect
 DECLARE pulserate15minautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSERATE15MINAUTOTRANSFUSION")), protect
 DECLARE mf_respiratoryrate15min = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPIRATORYRATE15MIN")), protect
 DECLARE respiratoryrate15minautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPIRATORYRATE15MINAUTOTRANSFUSION")), protect
 DECLARE mf_systolicbloodpressure15min = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE15MIN")), protect
 DECLARE sbp15minautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SBP15MINAUTOTRANSFUSION")), protect
 DECLARE mf_diastolicbloodpressure15min = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE15MIN")), protect
 DECLARE dbp15minautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DBP15MINAUTOTRANSFUSION")), protect
 DECLARE mf_oxygensaturation15min = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OXYGENSATURATION15MIN")), protect
 DECLARE oxygensat15minautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OXYGENSAT15MINAUTOTRANSFUSION")), protect
 CALL echo(build("TIME:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(times),5)))
 SET times = cnvtdatetime(sysdate)
 DECLARE mf_transfusionendtime = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TRANSFUSIONENDTIME")), protect
 DECLARE autotransfusionstoptime = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "AUTOTRANSFUSIONSTOPTIME")), protect
 DECLARE mf_temperatureend = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TEMPERATUREEND")),
 protect
 DECLARE temperatureendautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEMPERATUREENDAUTOTRANSFUSION")), protect
 DECLARE mf_temperaturerouteend = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEMPERATUREROUTEEND")), protect
 DECLARE temperaturerouteendautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEMPERATUREROUTEENDAUTOTRANSFUSION")), protect
 DECLARE mf_pulserateend = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATEEND")), protect
 DECLARE pulserateendautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PULSERATEENDAUTOTRANSFUSION")), protect
 DECLARE mf_respiratoryrateend = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPIRATORYRATEEND")), protect
 DECLARE respiratoryrateendautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPIRATORYRATEENDAUTOTRANSFUSION")), protect
 DECLARE mf_systolicbloodpressureend = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSUREEND")), protect
 DECLARE sbpendautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SBPENDAUTOTRANSFUSION")), protect
 DECLARE mf_diastolicbloodpressureend = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSUREEND")), protect
 DECLARE dbpendautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DBPENDAUTOTRANSFUSION")), protect
 DECLARE mf_oxygensaturationend = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OXYGENSATURATIONEND")), protect
 DECLARE oxygensatendautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OXYGENSATENDAUTOTRANSFUSION")), protect
 DECLARE volumeinfusedautotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "VOLUMEINFUSEDAUTOTRANSFUSION")), protect
 DECLARE mf_albuminvol = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ALBUMINVOL")), protect
 DECLARE mf_cryoprecipitate = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"CRYOPRECIPITATE")),
 protect
 DECLARE mf_factorviia = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"FACTORVIIA")), protect
 DECLARE mf_factorviiivol = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"FACTORVIIIVOL")),
 protect
 DECLARE mf_factorixcomplex = f8
 CALL echo(build("TIME:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(times),5)))
 SET times = cnvtdatetime(sysdate)
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
 CALL echo(build("TIME:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(times),5)))
 SET times = cnvtdatetime(sysdate)
 DECLARE mf_factorixvol = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"FACTORIXVOL")), protect
 DECLARE mf_ffp = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"FFP")), protect
 DECLARE mf_granulocytes = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"GRANULOCYTES")), protect
 DECLARE mf_ivig = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"IVIG")), protect
 DECLARE mf_platelets = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PLATELETS")), protect
 DECLARE mf_rbcvol = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"RBCVOL")), protect
 DECLARE mf_rhimmuneglobulinivvol = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "RHIMMUNEGLOBULINIV")), protect
 DECLARE mf_rhimmuneglobulinimvol = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "RHIMMUNEGLOBULINIM")), protect
 DECLARE mf_bloodproductamountinfused = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "BLOODPRODUCTAMOUNTINFUSED")), protect
 DECLARE mf_transfusionreactiondescription = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TRANSFUSIONREACTIONDESCRIPTION")), protect
 DECLARE previousreactiontotransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PREVIOUSREACTIONTOTRANSFUSION")), protect
 DECLARE bloodtransfusionreaction = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "BLOODTRANSFUSIONREACTION")), protect
 FREE RECORD info
 RECORD info(
   1 person_id = f8
   1 name = vc
   1 sex = vc
   1 dob = vc
   1 mrn = vc
   1 fin = vc
   1 orderingphy = vc
   1 lastnurseunit = vc
   1 triggeringformname = vc
   1 admitdx = vc
   1 problems = vc
   1 formname = vc
   1 formdttm = vc
   1 form_eventid = vc
   1 previousreactionq = vc
   1 previousreaction = vc
   1 previous_dt_tm = vc
   1 labs = vc
   1 labsval = vc
   1 labsdttm = vc
   1 intake = vc
   1 weight = vc
   1 meds = vc
   1 medsdttm = vc
   1 medsstatus = vc
   1 oxygen = vc
   1 oxygendttm = vc
   1 oxygenstatus = vc
   1 aborh = vc
   1 aborhval = vc
   1 aborhdttm = vc
   1 antibody = vc
   1 antibodyval = vc
   1 antibodydttm = vc
   1 unitidnumberlotnumber = vc
   1 bloodproducttransfused = vc
   1 transfusionstarttime = vc
   1 temperaturestart = vc
   1 temperatureroutestart = vc
   1 pulseratestart = vc
   1 respiratoryratestart = vc
   1 systolicbloodpressurestart = vc
   1 diastolicbloodpressurestart = vc
   1 oxygensaturationstart = vc
   1 transfusionstartplus15min = vc
   1 temperature15min = vc
   1 temperatureroute15min = vc
   1 pulserate15min = vc
   1 respiratoryrate15min = vc
   1 systolicbloodpressure15min = vc
   1 diastolicbloodpressure15min = vc
   1 oxygensaturation15min = vc
   1 transfusionendtime = vc
   1 temperatureend = vc
   1 temperaturerouteend = vc
   1 pulserateend = vc
   1 respiratoryrateend = vc
   1 systolicbloodpressureend = vc
   1 diastolicbloodpressureend = vc
   1 oxygensaturationend = vc
   1 pp_start = vc
   1 pp_15min = vc
   1 pp_end = vc
   1 map_start = vc
   1 map_15min = vc
   1 map_end = vc
   1 rr_delta1 = vc
   1 rr_delta2 = vc
   1 temp_delta1 = vc
   1 temp_delta2 = vc
   1 sbp_delta1 = vc
   1 sbp_delta2 = vc
   1 pulse_delta1 = vc
   1 pulse_delta2 = vc
   1 o2_sat_delta1 = vc
   1 o2_sat_delta2 = vc
   1 pp_delta1 = vc
   1 pp_delta2 = vc
   1 map_delta1 = vc
   1 map_delta2 = vc
   1 dbp_delta1 = vc
   1 dbp_delta2 = vc
   1 item_infused = vc
   1 amountinfused = vc
   1 rate_infused = vc
   1 other_item_infused = vc
   1 other_infused = vc
   1 factorviiavol = vc
   1 rhimmuneglobulinivvol = vc
   1 rhimmuneglobulinimvol = vc
   1 rbcvol = vc
   1 plateletsvol = vc
   1 ivigvol = vc
   1 granulocytesvol = vc
   1 ffpvol = vc
   1 cryoprecipitatevol = vc
   1 factorviiivol = vc
   1 factorixvol = vc
   1 factorixcomplexvol = vc
   1 albuminvol = vc
   1 infusion_pump_used = vc
   1 infusion_rate = vc
   1 transfusionrateplatelets = vc
   1 transfusionrateivig = vc
   1 transfusionrateffp = vc
   1 transfusionratecryoprecipitate = vc
   1 transfusionratealbumin = vc
   1 transfusionraterbcs = vc
   1 transfusionreactiondescription = vc
   1 transfusionadministrationequipment = vc
 )
 SET info->name = "(No data available)"
 SET info->dob = "(No data available)"
 SET info->mrn = "(No data available)"
 SET info->fin = "(No data available)"
 SET info->orderingphy = "(No data available)"
 SET info->lastnurseunit = "(No data available)"
 SET info->admitdx = "(No data available)"
 SET info->problems = "(No data available)"
 SET info->formname = "(No data available)"
 SET info->previousreactionq = "(No data available)"
 SET info->labs = "(No data available)"
 SET info->intake = "(No data available)"
 SET info->weight = "(No data available)"
 SET info->meds = "(No data available)"
 SET info->oxygen = "(No data available)"
 SET info->aborh = "(No data available)"
 SET info->antibody = "(No data available)"
 SET info->transfusionreactiondescription = "(No data available)"
 CALL echo(build("link_clineventid",link_clineventid))
 IF (textlen(trim( $ORDERINGPHY,3)) > 0)
  SET info->orderingphy =  $ORDERINGPHY
 ENDIF
 CALL echo(build("TIME:Afteralldeclares:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(times),5)))
 SET times = cnvtdatetime(sysdate)
 IF (( $FORM=99))
  SELECT INTO "nl:"
   FROM clinical_event ce,
    clinical_event ce1,
    clinical_event ce2
   PLAN (ce
    WHERE ce.clinical_event_id=link_clineventid
     AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
     AND ce.result_status_cd IN (altered, modified, auth))
    JOIN (ce1
    WHERE ce1.event_id=ce.parent_event_id
     AND ce1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
     AND ce1.result_status_cd IN (altered, modified, auth))
    JOIN (ce2
    WHERE ce2.event_id=ce1.parent_event_id
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
     AND ce2.result_status_cd IN (altered, modified, auth))
   DETAIL
    formeventid = ce2.parent_event_id
   WITH nocounter
  ;end select
 ELSE
  SET link_clineventid = 0
  SET formeventid =  $FORM
 ENDIF
 IF (( $FIN="99"))
  SET encntr_id = link_encntrid
 ELSE
  CALL echo("Get Encounter from FIN")
  SELECT INTO "NL:"
   FROM encntr_alias ea
   WHERE (ea.alias= $FIN)
    AND ea.active_ind=1
   HEAD ea.encntr_id
    encntr_id = ea.encntr_id
   WITH nocounter
  ;end select
 ENDIF
 IF (encntr_id <= 0)
  CALL echo("encntr failed")
  IF (( $FIN="99"))
   SET errmsg = build("Failed to find Encounter - Rule Execution","encntr_id:",encntr_id)
  ENDIF
  GO TO exit_program
 ENDIF
 CALL echo(build("TIME:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(times),5)))
 SET times = cnvtdatetime(sysdate)
 CALL echo(build("load patient demographics (FIN):", $FIN))
 SELECT INTO "nl:"
  p_sex_disp = uar_get_code_display(p.sex_cd)
  FROM encounter e,
   person p,
   encntr_alias ea,
   encntr_alias ea1
  PLAN (e
   WHERE e.encntr_id=encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=finnbr
    AND ea.active_ind=1)
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.encntr_alias_type_cd=mrn_var
    AND ea1.active_ind=1)
  DETAIL
   info->person_id = p.person_id, info->sex = trim(p_sex_disp,3), info->name = concat(trim(p
     .name_last,3),", ",trim(p.name_first,3)),
   info->dob = format(p.birth_dt_tm,"DD-MMM-YY HH:MM:SS;;q"), info->mrn = trim(ea1.alias,3), info->
   fin = trim(ea.alias,3),
   info->lastnurseunit = uar_get_code_display(e.loc_nurse_unit_cd)
  WITH format, separator = " "
 ;end select
 CALL echo(build("TIME:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(times),5)))
 SET times = cnvtdatetime(sysdate)
 CALL echo("load admitting DX")
 SELECT INTO "NL:"
  d.beg_effective_dt_tm
  FROM diagnosis d
  WHERE d.encntr_id=encntr_id
   AND ((d.active_ind+ 0)=1)
   AND cnvtdatetime(sysdate) BETWEEN d.beg_effective_dt_tm AND d.end_effective_dt_tm
   AND ((d.diag_type_cd+ 0) IN (admit))
  ORDER BY d.beg_effective_dt_tm
  HEAD REPORT
   stat = 0, cnt = 0, info->admitdx = " "
  DETAIL
   cnt += 1
   IF (cnt > 1)
    info->admitdx = concat(info->admitdx,char(10))
   ENDIF
   info->admitdx = concat(info->admitdx,d.diagnosis_display)
  WITH nocounter, orahint("index(d xie1diagnosis)")
 ;end select
 CALL echo(build("TIME:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(times),5)))
 SET times = cnvtdatetime(sysdate)
 CALL echo("load Problems")
 SELECT INTO "NL:"
  p.beg_effective_dt_tm, p.problem_id
  FROM problem p
  WHERE (p.person_id=info->person_id)
   AND p.active_ind=1
   AND cnvtdatetime(sysdate) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm
   AND p.data_status_cd IN (altered, modified, auth)
  ORDER BY p.beg_effective_dt_tm
  HEAD REPORT
   stat = 0, cnt = 0, info->problems = " ",
   detailhj, cnt += 1
   IF (cnt > 1)
    info->problems = concat(trim(info->problems,3),char(10))
   ENDIF
   info->problems = concat(info->problems,trim(p.annotated_display,3))
  WITH nocounter
 ;end select
 CALL echo(build("TIME:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(times),5)))
 SET times = cnvtdatetime(sysdate)
 CALL echo("load instances of powerForms and DTAs")
 SELECT
  ce.event_end_dt_tm, ce.encntr_id, ce.result_status_cd,
  ce.event_cd
  FROM clinical_event ce,
   clinical_event ce1,
   clinical_event ce2
  PLAN (ce
   WHERE ce.encntr_id=encntr_id
    AND ce.event_cd IN (transfusiontagform, autotransfusionbloodrecoveryform)
    AND ce.result_status_cd IN (altered, modified, auth)
    AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate))
   JOIN (ce1
   WHERE ce1.parent_event_id=ce.event_id)
   JOIN (ce2
   WHERE ce1.event_id=ce2.parent_event_id
    AND ce2.event_cd=bloodproducttransfused
    AND ce2.event_tag IN ("Albumin", "IVIG"))
  ORDER BY ce.event_end_dt_tm DESC
  HEAD REPORT
   frmcnt = 0, info->formname = " "
  DETAIL
   frmcnt += 1
   IF (frmcnt > 1)
    info->formname = concat(info->formname,char(10)), info->formdttm = concat(info->formdttm,char(10)
     )
   ENDIF
   info->formdttm = concat(info->formdttm,format(cnvtdatetime(ce.event_end_dt_tm),
     "DD-MMM_YY HH:MM:SS;;q")), info->formname = concat(info->formname,uar_get_code_display(ce
     .event_cd))
  WITH nocounter
 ;end select
 CALL echo(build("TIME:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(times),5)))
 SET times = cnvtdatetime(sysdate)
 CALL echo("load labs")
 SELECT
  ce.event_end_dt_tm, ce.encntr_id
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.encntr_id=encntr_id
    AND ((ce.event_cd+ 0) IN (hgb, hct, wbc, eos_per, baso_per,
   mono_per, neut_per, lymph_per, plateletcount, igm,
   iga, complementc3, complementc4, inr, fibrinogen,
   ntprobnp, rh, abo, bloodtype, rhtestonly1,
   rhtestonly2, antibodyscreen))
    AND ce.result_status_cd IN (altered, modified, auth)
    AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate)
    AND ((ce.view_level+ 0)=1)
    AND ((ce.publish_flag+ 0)=1)
    AND ce.result_val > " ")
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  HEAD REPORT
   cnt = 0, cnt2 = 0, cnt3 = 0
  DETAIL
   IF (ce.event_cd IN (hgb, hct, wbc, eos_per, baso_per,
   mono_per, neut_per, lymph_per, plateletcount, igm,
   iga, complementc3, complementc4, inr, fibrinogen,
   ntprobnp)
    AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime3))
    cnt += 1
    IF (cnt=1)
     info->labs = " "
    ELSE
     info->labs = concat(info->labs,char(10)), info->labsval = concat(info->labsval,char(10)), info->
     labsdttm = concat(info->labsdttm,char(10))
    ENDIF
    info->labsdttm = concat(info->labsdttm,format(cnvtdatetime(ce.event_end_dt_tm),
      "DD-MMM_YY HH:MM:SS;;q")), info->labs = concat(info->labs,trim(uar_get_code_display(ce.event_cd
       ),3)), info->labsval = concat(info->labsval,trim(ce.result_val,3)," ",trim(
      uar_get_code_display(ce.result_units_cd),3))
   ELSEIF (ce.event_cd IN (rh, abo, bloodtype, rhtestonly1, rhtestonly2))
    cnt2 += 1
    IF (cnt2=1)
     info->aborh = " ", info->aborh = uar_get_code_display(ce.event_cd), info->aborhval = concat(ce
      .result_val," ",uar_get_code_display(ce.result_units_cd)),
     info->aborhdttm = format(cnvtdatetime(ce.event_end_dt_tm),"DD-MMM_YY HH:MM:SS;;q")
    ENDIF
   ELSEIF (ce.event_cd IN (antibodyscreen))
    cnt3 += 1
    IF (cnt3=1)
     info->antibody = " ", info->antibodydttm = concat(info->antibodydttm,format(cnvtdatetime(ce
        .event_end_dt_tm),"DD-MMM_YY HH:MM:SS;;q")), info->antibody = concat(info->antibody,
      uar_get_code_display(ce.event_cd)),
     info->antibodyval = concat(info->antibodyval,ce.result_val," ",uar_get_code_display(ce
       .result_units_cd))
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("TIME:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(times),5)))
 SET times = cnvtdatetime(sysdate)
 CALL echo("load IO and Vitals")
 FREE RECORD dlrec
 RECORD dlrec(
   1 encntr_total = i4
   1 seq[*]
     2 encntr_id = f8
     2 person_id = f8
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
 )
 EXECUTE bhs_incl_rounds_get_vital_io
 SET dlrec->encntr_total = 1
 SET stat = alterlist(dlrec->seq,1)
 SET dlrec->seq[1].encntr_id = encntr_id
 SET dlrec->seq[1].person_id = info->person_id
 CALL echo("get IO")
 CALL get_io(0)
 CALL echo("get vitals")
 CALL get_vitals(0)
 FOR (x = 1 TO size(dlrec->seq[1].io,5))
   IF ((dlrec->seq[1].io[x].hour_range="12")
    AND (dlrec->seq[1].io[x].type="I"))
    IF (x=1)
     SET info->intake = " "
    ELSE
     SET info->intake = concat(info->intake,char(10))
    ENDIF
    SET info->intake = concat(info->intake,dlrec->seq[1].io[x].io_line)
   ENDIF
 ENDFOR
 IF (size(dlrec->seq[1].weights,5) > 0)
  SET info->weight = concat(dlrec->seq[1].weights[1].weight_value,dlrec->seq[1].weights[1].
   weight_unit,"  ",dlrec->seq[1].weights[1].weight_dt_tm)
 ENDIF
 CALL echorecord(info)
 CALL echo(build("TIME:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(times),5)))
 SET times = cnvtdatetime(sysdate)
 CALL echo("load Med orders")
 SELECT INTO "nl:"
  oi.catalog_cd, o.orig_order_dt_tm
  FROM order_catalog_synonym ocs,
   order_ingredient oi,
   orders o
  PLAN (ocs
   WHERE ocs.mnemonic_key_cap IN ("ONDANSETRON", "ONDANSETRON HYDROCHLORIDE", "DIPHENHYDRAMINE",
   "DIPHENHYDRAMINE HYDROCHLORIDE", "PROMETHAZINE",
   "PROCHLORPERAZINE", "FAMOTIDINE", "EPINEPHRINE", "CALCIUM GLUCONATE 10% IV", "CALCIUM GLUCONATE",
   "CALCIUM CARBONATE", "MEPERIDINE", "LORAZEPAM", "HYDROCORTISONE", "FUROSEMIDE",
   "CIMETIDINE", "ACETAMINOPHEN")
    AND ocs.mnemonic_type_cd=primary)
   JOIN (o
   WHERE o.encntr_id=encntr_id
    AND ((o.order_status_cd IN (ordered)) OR ( NOT (o.order_status_cd IN (canceled, deleted,
   incomplete))
    AND o.status_dt_tm >= cnvtdatetime(sysdate))) )
   JOIN (oi
   WHERE oi.order_id=o.order_id
    AND oi.catalog_cd=ocs.catalog_cd
    AND oi.action_sequence IN (
   (SELECT
    oa.action_sequence
    FROM order_action oa
    WHERE oa.order_id=o.order_id
     AND oa.action_type_cd=orderedaction)))
  ORDER BY oi.catalog_cd, o.orig_order_dt_tm DESC
  HEAD REPORT
   cnt = 0
  HEAD oi.catalog_cd
   orderadded = o.order_id, cnt += 1
   IF (cnt=1)
    info->meds = " "
   ELSE
    info->meds = concat(info->meds,char(10)), info->medsdttm = concat(info->medsdttm,char(10)), info
    ->medsstatus = concat(info->medsstatus,char(10))
   ENDIF
   info->medsdttm = concat(info->medsdttm,format(cnvtdatetime(o.orig_order_dt_tm),
     "DD-MMM_YY HH:MM:SS;;q")), info->meds = concat(info->meds,
    IF (textlen(o.order_mnemonic) > 90) concat(substring(1,90,o.order_mnemonic),"...")
    ELSE o.order_mnemonic
    ENDIF
    ), info->medsstatus = concat(info->medsstatus,uar_get_code_display(o.order_status_cd)),
   CALL echo(o.order_id)
  HEAD o.orig_order_dt_tm
   stat = 0
  DETAIL
   IF (o.order_status_cd=ordered
    AND o.order_id != orderadded)
    cnt += 1, info->meds = concat(info->meds,char(10)), info->medsdttm = concat(info->medsdttm,char(
      10)),
    info->medsstatus = concat(info->medsstatus,char(10)), info->medsdttm = concat(info->medsdttm,
     format(cnvtdatetime(o.orig_order_dt_tm),"DD-MMM_YY HH:MM:SS;;q")), info->meds = concat(info->
     meds,
     IF (textlen(o.order_mnemonic) > 90) concat(substring(1,90,o.order_mnemonic),"...")
     ELSE o.order_mnemonic
     ENDIF
     ),
    info->medsstatus = concat(info->medsstatus,uar_get_code_display(o.order_status_cd))
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("TIME:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(times),5)))
 SET times = cnvtdatetime(sysdate)
 CALL echo("load O2 orders")
 SELECT INTO "nl:"
  o.orig_order_dt_tm, o.order_id
  FROM order_catalog_synonym ocs,
   orders o,
   order_detail od,
   order_entry_fields oef1,
   dummyt d
  PLAN (ocs
   WHERE ocs.mnemonic_key_cap IN ("OXYGEN VIA*", "VENTILATOR*")
    AND ocs.mnemonic_type_cd=primary)
   JOIN (o
   WHERE o.encntr_id=encntr_id
    AND o.catalog_cd=ocs.catalog_cd
    AND  NOT (o.order_status_cd IN (canceled, deleted, incomplete)))
   JOIN (d)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id IN (
   (SELECT
    oef.oe_field_id
    FROM order_entry_fields oef
    WHERE oef.oe_field_id=od.oe_field_id
     AND cnvtupper(oef.description) IN ("*FIO2*", "*LITER*"))))
   JOIN (oef1
   WHERE oef1.oe_field_id=od.oe_field_id)
  ORDER BY o.orig_order_dt_tm DESC, o.order_id
  HEAD REPORT
   cnt = 0
  HEAD o.order_id
   cnt += 1
   IF (cnt=1)
    info->oxygen = " "
   ELSE
    info->oxygen = concat(info->oxygen,char(10)), info->oxygendttm = concat(info->oxygendttm,char(10)
     ), info->oxygenstatus = concat(info->oxygenstatus,char(10))
   ENDIF
   info->oxygendttm = concat(info->oxygendttm,format(cnvtdatetime(o.orig_order_dt_tm),
     "DD-MMM_YY HH:MM:SS;;q")), tempox = concat(trim(o.order_mnemonic,3)," - ",trim(oef1.description,
     3)," ",trim(od.oe_field_display_value,3)), info->oxygen = concat(info->oxygen,
    IF (textlen(tempox) > 90) concat(substring(1,90,o.order_mnemonic),"...")
    ELSE tempox
    ENDIF
    ),
   info->oxygenstatus = concat(info->oxygenstatus,uar_get_code_display(o.order_status_cd))
  WITH outerjoin = d
 ;end select
 CALL echo(build("TIME:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(times),5)))
 SET times = cnvtdatetime(sysdate)
 CALL echo("load trans form DTAS")
 SELECT INTO "nl:"
  FROM clinical_event ce,
   clinical_event ce1,
   clinical_event ce2,
   prsnl pr
  PLAN (ce
   WHERE ce.event_id=formeventid
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce.result_status_cd IN (altered, modified, auth))
   JOIN (ce1
   WHERE ce1.parent_event_id=ce.event_id
    AND ce1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce1.result_status_cd IN (altered, modified, auth))
   JOIN (ce2
   WHERE ce2.parent_event_id=ce1.event_id
    AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce2.result_status_cd IN (altered, modified, auth)
    AND ce2.event_cd IN (unitidnumberlotnumber, mf_transfusionstarttime, mf_temperaturestart,
   mf_temperatureroutestart, mf_pulseratestart,
   mf_respiratoryratestart, mf_systolicbloodpressurestart, mf_diastolicbloodpressurestart,
   mf_oxygensaturationstart, autotransfusionstarttime,
   temperaturestartautotransfusion, temperatureroutestartautotransfusion,
   pulseratestartautotransfusion, respiratoryratestartautotransfusion, sbpstartautotransfusion,
   dbpstartautotransfusion, oxygensatstartautotransfusion, mf_transfusionstartplus15min,
   mf_temperature15min, mf_temperatureroute15min,
   mf_pulserate15min, mf_respiratoryrate15min, mf_systolicbloodpressure15min,
   mf_diastolicbloodpressure15min, mf_oxygensaturation15min,
   autotransfusionstartplus15min, temperature15minautotransfusion,
   temperatureroute15minautotransfusion, pulserate15minautotransfusion,
   respiratoryrate15minautotransfusion,
   sbp15minautotransfusion, dbp15minautotransfusion, oxygensat15minautotransfusion,
   mf_transfusionendtime, mf_temperatureend,
   mf_temperaturerouteend, mf_pulserateend, mf_respiratoryrateend, mf_systolicbloodpressureend,
   mf_diastolicbloodpressureend,
   mf_oxygensaturationend, autotransfusionstoptime, temperatureendautotransfusion,
   temperaturerouteendautotransfusion, pulserateendautotransfusion,
   respiratoryrateendautotransfusion, sbpendautotransfusion, dbpendautotransfusion,
   oxygensatendautotransfusion, pulseratedelta2,
   pulseratedelta1, oxygensaturationdelta2, oxygensaturationdelta1, diastolicbloodpressuredelta2,
   diastolicbloodpressuredelta1,
   systolicbloodpressuredelta2, systolicbloodpressuredelta1, temperaturedelta2, temperaturedelta1,
   respiratoryratedelta2,
   respiratoryratedelta1, meanarterialpressuredelta2, meanarterialpressuredelta1,
   meanarterialpressureend, meanarterialpressure15min,
   meanarterialpressurestart, pulsepressuredelta2, pulsepressureend, pulsepressurestart,
   pulsepressuredelta1,
   pulsepressure15min, respiratoryratedelta1autotransfusion, respiratoryratedelta2autotransfusion,
   pulsepressure15minautotransfusion, pulsepressureendautotransfusion,
   pulsepressuredelta1autotransfusion, pulsepressurestartautotransfusion,
   pulsepressuredelta2autotransfusion, mapendautotransfusion, map15minautotransfusion,
   mapstartautotransfusion, bloodproducttransfused, temperaturedelta2autotransfusion,
   temperaturedelta1autotransfusion, pulseratedelta2autotransfusion,
   pulseratedelta1autotransfusion, mapdelta1autotransfusion, mapdelta2autotransfusion,
   sbpdelta1autotransfusion, sbpdelta2autotransfusion,
   oxygensatdelta1autotransfusion, oxygensatdelta2autotransfusion, dbpdelta1autotransfusion,
   dbpdelta2autotransfusion, volumeinfusedautotransfusion,
   mf_albuminvol, mf_cryoprecipitate, mf_factorviia, mf_factorviiivol, mf_factorixcomplex,
   mf_factorixvol, mf_ffp, mf_granulocytes, mf_ivig, mf_platelets,
   mf_rbcvol, mf_rhimmuneglobulinivvol, mf_rhimmuneglobulinimvol, mf_bloodproductamountinfused,
   transfusionrateplatelets,
   transfusionrateivig, transfusionrateffp, transfusionratecryoprecipitate, transfusionratealbumin,
   transfusionraterbcs,
   transfusionadministrationequipment, mf_transfusionreactiondescription))
   JOIN (pr
   WHERE pr.person_id=ce2.performed_prsnl_id)
  ORDER BY ce.encntr_id, ce.parent_event_id, ce1.parent_event_id,
   ce2.event_cd, ce2.event_end_dt_tm DESC
  HEAD REPORT
   info->triggeringformname = uar_get_code_display(ce.event_cd)
  HEAD ce.encntr_id
   i_instance_cnt = 0, i_consent_cnt = 0, i_vital_cnt = 0,
   i_infused_cnt = 0, i_reaction_cnt = 0
  HEAD ce.parent_event_id
   i_trandta_cnt = 0, i_consent_cnt = 0, i_vital_cnt = 0,
   i_infused_cnt = 0, i_reaction_cnt = 0, i_instance_cnt += 1
  HEAD ce2.event_cd
   s_tran_result = build2(trim(ce2.event_tag)," ",trim(uar_get_code_display(ce2.result_units_cd)))
   IF (ce2.event_cd IN (mf_transfusionstarttime, autotransfusionstarttime))
    ready_time = concat(format(cnvtdate2(substring(3,8,ce2.event_tag),"yyyymmdd"),"DD-MMM-YYYY;;D"),
     " ",format(cnvttime(cnvtmin(cnvtint(substring(11,6,ce2.event_tag)),2)),"HH:MM:SS;;M")), info->
    transfusionstarttime = ready_time, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_temperaturestart, temperaturestartautotransfusion))
    info->temperaturestart = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_temperatureroutestart, temperatureroutestartautotransfusion))
    info->temperatureroutestart = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_pulseratestart, pulseratestartautotransfusion))
    info->pulseratestart = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_respiratoryratestart, respiratoryratestartautotransfusion))
    info->respiratoryratestart = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_systolicbloodpressurestart, sbpstartautotransfusion))
    info->systolicbloodpressurestart = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_diastolicbloodpressurestart, dbpstartautotransfusion))
    info->diastolicbloodpressurestart = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_oxygensaturationstart, oxygensatstartautotransfusion))
    info->oxygensaturationstart = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (pulsepressurestart, pulsepressurestartautotransfusion))
    i_vital_cnt += 1, info->pp_start = s_tran_result
   ELSEIF (ce2.event_cd IN (meanarterialpressurestart, mapstartautotransfusion))
    i_vital_cnt += 1, info->map_start = s_tran_result
   ELSEIF (ce2.event_cd IN (bloodproducttransfused))
    i_vital_cnt += 1, info->bloodproducttransfused = s_tran_result
   ELSEIF (ce2.event_cd IN (mf_transfusionstartplus15min, autotransfusionstartplus15min))
    ready_time = concat(format(cnvtdate2(substring(3,8,ce2.event_tag),"yyyymmdd"),"DD-MMM-YYYY;;D"),
     " ",format(cnvttime(cnvtmin(cnvtint(substring(11,6,ce2.event_tag)),2)),"HH:MM:SS;;M")), info->
    transfusionstartplus15min = ready_time, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_temperature15min, temperature15minautotransfusion))
    info->temperature15min = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_temperatureroute15min, temperatureroute15minautotransfusion))
    info->temperatureroute15min = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_pulserate15min, pulserate15minautotransfusion))
    info->pulserate15min = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_respiratoryrate15min, respiratoryrate15minautotransfusion))
    info->respiratoryrate15min = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_systolicbloodpressure15min, sbp15minautotransfusion))
    info->systolicbloodpressure15min = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_diastolicbloodpressure15min, dbp15minautotransfusion))
    info->diastolicbloodpressure15min = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_oxygensaturation15min, oxygensat15minautotransfusion))
    info->oxygensaturation15min = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (pulsepressure15min, pulsepressure15minautotransfusion))
    i_vital_cnt += 1, info->pp_15min = s_tran_result
   ELSEIF (ce2.event_cd IN (meanarterialpressure15min, map15minautotransfusion))
    i_vital_cnt += 1, info->map_15min = s_tran_result
   ELSEIF (ce2.event_cd IN (mf_transfusionendtime, autotransfusionstoptime))
    ready_time = concat(format(cnvtdate2(substring(3,8,ce2.event_tag),"yyyymmdd"),"DD-MMM-YYYY;;D"),
     " ",format(cnvttime(cnvtmin(cnvtint(substring(11,6,ce2.event_tag)),2)),"HH:MM:SS;;M")), info->
    transfusionendtime = ready_time, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_temperatureend, temperatureendautotransfusion))
    info->temperatureend = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_temperaturerouteend, temperaturerouteendautotransfusion))
    info->temperaturerouteend = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_pulserateend, pulserateendautotransfusion))
    info->pulserateend = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_respiratoryrateend, respiratoryrateendautotransfusion))
    info->respiratoryrateend = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_systolicbloodpressureend, sbpendautotransfusion))
    info->systolicbloodpressureend = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_diastolicbloodpressureend, dbpendautotransfusion))
    info->diastolicbloodpressureend = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_oxygensaturationend, oxygensatendautotransfusion))
    info->oxygensaturationend = s_tran_result, i_vital_cnt += 1, meanarterialpressure15min
   ELSEIF (ce2.event_cd IN (mf_oxygensaturation15min, oxygensat15minautotransfusion))
    info->oxygensaturation15min = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (pulsepressureend, pulsepressureendautotransfusion))
    i_vital_cnt += 1, info->pp_end = s_tran_result
   ELSEIF (ce2.event_cd IN (meanarterialpressureend, mapendautotransfusion))
    i_vital_cnt += 1, info->map_end = s_tran_result
   ELSEIF (ce2.event_cd IN (pulseratedelta1, pulseratedelta1autotransfusion))
    info->pulse_delta1 = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (oxygensaturationdelta1, oxygensatdelta1autotransfusion))
    info->o2_sat_delta1 = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (diastolicbloodpressuredelta1, dbpdelta1autotransfusion))
    info->dbp_delta1 = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (temperaturedelta1, temperaturedelta1autotransfusion))
    info->temp_delta1 = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (respiratoryratedelta1, respiratoryratedelta1autotransfusion))
    info->rr_delta1 = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (meanarterialpressuredelta1, mapdelta1autotransfusion))
    info->map_delta1 = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (pulsepressuredelta1, pulsepressuredelta1autotransfusion))
    info->pp_delta1 = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (systolicbloodpressuredelta1, sbpdelta1autotransfusion))
    info->sbp_delta1 = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (pulseratedelta2, pulseratedelta2autotransfusion))
    info->pulse_delta2 = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (oxygensaturationdelta2, oxygensatdelta2autotransfusion))
    info->o2_sat_delta2 = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (diastolicbloodpressuredelta2, dbpdelta2autotransfusion))
    info->dbp_delta2 = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (temperaturedelta2, temperaturedelta2autotransfusion))
    info->temp_delta2 = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (respiratoryratedelta2, respiratoryratedelta2autotransfusion))
    info->rr_delta2 = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (meanarterialpressuredelta2, mapdelta2autotransfusion))
    info->map_delta2 = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (pulsepressuredelta2, pulsepressuredelta2autotransfusion))
    info->pp_delta2 = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (systolicbloodpressuredelta2, sbpdelta2autotransfusion))
    info->sbp_delta2 = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (volumeinfusedautotransfusion))
    info->amountinfused = concat(trim(uar_get_code_display(ce2.event_cd),3),": ",s_tran_result," "),
    i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_albuminvol))
    info->item_infused = uar_get_code_display(ce2.event_cd), info->amountinfused = s_tran_result,
    i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_cryoprecipitate))
    info->item_infused = uar_get_code_display(ce2.event_cd), info->amountinfused = s_tran_result,
    i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_factorviia))
    info->item_infused = uar_get_code_display(ce2.event_cd), info->amountinfused = s_tran_result,
    i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_factorviiivol))
    info->item_infused = uar_get_code_display(ce2.event_cd), info->amountinfused = s_tran_result,
    i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_factorixcomplex))
    info->item_infused = uar_get_code_display(ce2.event_cd), info->amountinfused = s_tran_result,
    i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_factorixvol))
    info->item_infused = uar_get_code_display(ce2.event_cd), info->amountinfused = s_tran_result,
    i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_ffp))
    info->item_infused = uar_get_code_display(ce2.event_cd), info->amountinfused = s_tran_result,
    i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_granulocytes))
    info->item_infused = uar_get_code_display(ce2.event_cd), info->amountinfused = s_tran_result,
    i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_ivig))
    info->item_infused = uar_get_code_display(ce2.event_cd), info->amountinfused = s_tran_result,
    i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_platelets))
    info->plateletsvol = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_rbcvol))
    info->item_infused = uar_get_code_display(ce2.event_cd), info->amountinfused = s_tran_result,
    i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_rhimmuneglobulinivvol))
    info->item_infused = uar_get_code_display(ce2.event_cd), info->amountinfused = s_tran_result,
    i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_rhimmuneglobulinimvol))
    info->item_infused = uar_get_code_display(ce2.event_cd), info->amountinfused = s_tran_result,
    i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (mf_bloodproductamountinfused))
    info->other_item_infused = uar_get_code_display(ce2.event_cd), info->other_infused = concat(
     "Other Blood Product Volume Transfused: ",s_tran_result), i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (transfusionratealbumin))
    info->rate_infused = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (transfusionratecryoprecipitate))
    info->rate_infused = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (transfusionrateffp))
    info->rate_infused = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (transfusionrateivig))
    info->rate_infused = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (transfusionrateplatelets))
    info->rate_infused = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (transfusionraterbcs))
    info->rate_infused = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (systolicbloodpressuredelta2))
    info->sbp_delta2 = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd IN (transfusionadministrationequipment))
    info->transfusionadministrationequipment = s_tran_result, i_vital_cnt += 1
   ELSEIF (ce2.event_cd=mf_transfusionreactiondescription)
    info->transfusionreactiondescription = s_tran_result, i_reaction_cnt += 1
   ELSEIF (ce2.event_cd=unitidnumberlotnumber)
    info->unitidnumberlotnumber = s_tran_result, i_reaction_cnt += 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("TIME:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(times),5)))
 SET times = cnvtdatetime(sysdate)
 CALL echorecord(info)
 CALL echo("Print report")
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant(""), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _remadmitdxfld = i4 WITH noconstant(1), protect
 DECLARE _remproblemsfld = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontadmitdxsec = i2 WITH noconstant(0), protect
 DECLARE _remantibodydttm = i4 WITH noconstant(1), protect
 DECLARE _remabofld4 = i4 WITH noconstant(1), protect
 DECLARE _remabofld6 = i4 WITH noconstant(1), protect
 DECLARE _remabodttm = i4 WITH noconstant(1), protect
 DECLARE _remabofld = i4 WITH noconstant(1), protect
 DECLARE _remabofldval = i4 WITH noconstant(1), protect
 DECLARE _bcontproblemsec = i2 WITH noconstant(0), protect
 DECLARE _remformfld = i4 WITH noconstant(1), protect
 DECLARE _remformdttm = i4 WITH noconstant(1), protect
 DECLARE _bcontformssec = i2 WITH noconstant(0), protect
 DECLARE _remlabs = i4 WITH noconstant(1), protect
 DECLARE _remlabsdatetm = i4 WITH noconstant(1), protect
 DECLARE _remlabval = i4 WITH noconstant(1), protect
 DECLARE _bcontlabssec = i2 WITH noconstant(0), protect
 DECLARE _remweightfld = i4 WITH noconstant(1), protect
 DECLARE _remintakefld = i4 WITH noconstant(1), protect
 DECLARE _bcontreactioninfosec = i2 WITH noconstant(0), protect
 DECLARE _remmedsfld = i4 WITH noconstant(1), protect
 DECLARE _remmedsdttmfld = i4 WITH noconstant(1), protect
 DECLARE _remmedsstatusfld = i4 WITH noconstant(1), protect
 DECLARE _bcontmedssec = i2 WITH noconstant(0), protect
 DECLARE _remmedsfld = i4 WITH noconstant(1), protect
 DECLARE _remmedsdttmfld = i4 WITH noconstant(1), protect
 DECLARE _remmedsstatusfld = i4 WITH noconstant(1), protect
 DECLARE _bconto2sec = i2 WITH noconstant(0), protect
 DECLARE _remmedsfld = i4 WITH noconstant(1), protect
 DECLARE _bcontvitalssec = i2 WITH noconstant(0), protect
 DECLARE _times8bu0 = i4 WITH noconstant(0), protect
 DECLARE _times8b0 = i4 WITH noconstant(0), protect
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times200 = i4 WITH noconstant(0), protect
 DECLARE _pen7s0c8421504 = i4 WITH noconstant(0), protect
 DECLARE _pen0s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen2s1c0 = i4 WITH noconstant(0), protect
 DECLARE _pen1s3c0 = i4 WITH noconstant(0), protect
 DECLARE _pen5s2c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c8421504 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen28s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE (finalizereport(ssendreport=vc) =null WITH protect)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value(ssendreport) WITH deleted
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant(0), protect
   DECLARE _errcnt = i2 WITH noconstant(0), protect
   SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
   WHILE (_errorfound=rpt_errorfound
    AND _errcnt < 512)
     SET _errcnt += 1
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE (headsec(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headsecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headsecabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.670000), private
   IF (cur_page > 1)
    DECLARE __fieldname4 = vc WITH noconstant(build2(trim(info->mrn,3),char(0))), protect
   ENDIF
   DECLARE __datetime = vc WITH noconstant(build2(format(cnvtdatetime(sysdate),";;q"),char(0))),
   protect
   DECLARE __fieldname1 = vc WITH noconstant(build2(info->triggeringformname,char(0))), protect
   IF (cur_page > 1)
    DECLARE __fieldname2 = vc WITH noconstant(build2(info->name,char(0))), protect
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.479)
    SET rptsd->m_x = (offsetx+ 6.063)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (cur_page > 1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname4)
    ENDIF
    SET rptsd->m_flags = 516
    SET rptsd->m_y = (offsety+ 0.479)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.188
    IF (cur_page > 1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    ENDIF
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.323)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 4.000
    SET rptsd->m_height = 0.177
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__datetime)
    SET rptsd->m_y = (offsety+ 0.469)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 2.938
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname1)
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.344
    SET _dummyfont = uar_rptsetfont(_hreport,_times200)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Preliminary Investigation of Suspected Reaction to Human Blood Product",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.479)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.885
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    IF (cur_page > 1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname2)
    ENDIF
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (linesec(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = linesecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (linesecabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen5s2c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.036),(offsetx+ 7.500),(offsety+
     0.036))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (patientsec(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patientsecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (patientsecabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.900000), private
   DECLARE __fieldname0 = vc WITH noconstant(build2(info->name,char(0))), protect
   DECLARE __fieldname20 = vc WITH noconstant(build2(info->dob,char(0))), protect
   DECLARE __fieldname22 = vc WITH noconstant(build2(info->mrn,char(0))), protect
   DECLARE __fieldname26 = vc WITH noconstant(build2(info->orderingphy,char(0))), protect
   DECLARE __fieldname28 = vc WITH noconstant(build2(info->lastnurseunit,char(0))), protect
   DECLARE __fieldname3 = vc WITH noconstant(build2(info->fin,char(0))), protect
   DECLARE __fieldname4 = vc WITH noconstant(build2(info->unitidnumberlotnumber,char(0))), protect
   DECLARE __fieldname9 = vc WITH noconstant(build2(info->sex,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.688
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname0)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.271)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Birthdate:",char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Nurse Unit:",char(0)))
    SET rptsd->m_y = (offsety+ 0.271)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Ordering Phy:",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.948
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.271)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname20)
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname22)
    SET rptsd->m_y = (offsety+ 0.271)
    SET rptsd->m_x = (offsetx+ 5.063)
    SET rptsd->m_width = 2.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname26)
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 5.063)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname28)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.698
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ACCT:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname3)
    SET rptsd->m_y = (offsety+ 0.479)
    SET rptsd->m_x = (offsetx+ 5.063)
    SET rptsd->m_width = 2.177
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname4)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.479)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Unit ID Number/Lot:",char(0)))
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Gender:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 5.063)
    SET rptsd->m_width = 1.813
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname9)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (admitdxsec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = admitdxsecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (admitdxsecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_admitdxfld = f8 WITH noconstant(0.0), private
   DECLARE drawheight_problemsfld = f8 WITH noconstant(0.0), private
   DECLARE __admitdxfld = vc WITH noconstant(build2(info->admitdx,char(0))), protect
   DECLARE __problemsfld = vc WITH noconstant(build2(info->problems,char(0))), protect
   IF (bcontinue=0)
    SET _remadmitdxfld = 1
    SET _remproblemsfld = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.188
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremadmitdxfld = _remadmitdxfld
   IF (_remadmitdxfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remadmitdxfld,((size(
        __admitdxfld) - _remadmitdxfld)+ 1),__admitdxfld)))
    SET drawheight_admitdxfld = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remadmitdxfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remadmitdxfld,((size(__admitdxfld) -
       _remadmitdxfld)+ 1),__admitdxfld)))))
     SET _remadmitdxfld += rptsd->m_drawlength
    ELSE
     SET _remadmitdxfld = 0
    ENDIF
    SET growsum += _remadmitdxfld
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.438)
   SET rptsd->m_width = 3.188
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremproblemsfld = _remproblemsfld
   IF (_remproblemsfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remproblemsfld,((size(
        __problemsfld) - _remproblemsfld)+ 1),__problemsfld)))
    SET drawheight_problemsfld = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remproblemsfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remproblemsfld,((size(__problemsfld) -
       _remproblemsfld)+ 1),__problemsfld)))))
     SET _remproblemsfld += rptsd->m_drawlength
    ELSE
     SET _remproblemsfld = 0
    ENDIF
    SET growsum += _remproblemsfld
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.948
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Admit Diagnosis:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.188
   SET rptsd->m_height = drawheight_admitdxfld
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   IF (ncalc=rpt_render
    AND _holdremadmitdxfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremadmitdxfld,((size(
        __admitdxfld) - _holdremadmitdxfld)+ 1),__admitdxfld)))
   ELSE
    SET _remadmitdxfld = _holdremadmitdxfld
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.438)
   SET rptsd->m_width = 0.948
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Problems:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.438)
   SET rptsd->m_width = 3.188
   SET rptsd->m_height = drawheight_problemsfld
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   IF (ncalc=rpt_render
    AND _holdremproblemsfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremproblemsfld,((size
       (__problemsfld) - _holdremproblemsfld)+ 1),__problemsfld)))
   ELSE
    SET _remproblemsfld = _holdremproblemsfld
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (problemsec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = problemsecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (problemsecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_antibodydttm = f8 WITH noconstant(0.0), private
   DECLARE drawheight_abofld4 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_abofld6 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_abodttm = f8 WITH noconstant(0.0), private
   DECLARE drawheight_abofld = f8 WITH noconstant(0.0), private
   DECLARE drawheight_abofldval = f8 WITH noconstant(0.0), private
   DECLARE __antibodydttm = vc WITH noconstant(build2(info->antibodydttm,char(0))), protect
   DECLARE __abofld4 = vc WITH noconstant(build2(info->antibody,char(0))), protect
   DECLARE __abofld6 = vc WITH noconstant(build2(info->antibodyval,char(0))), protect
   DECLARE __abodttm = vc WITH noconstant(build2(info->aborhdttm,char(0))), protect
   DECLARE __abofld = vc WITH noconstant(build2(info->aborh,char(0))), protect
   DECLARE __abofldval = vc WITH noconstant(build2(info->aborhval,char(0))), protect
   IF (bcontinue=0)
    SET _remantibodydttm = 1
    SET _remabofld4 = 1
    SET _remabofld6 = 1
    SET _remabodttm = 1
    SET _remabofld = 1
    SET _remabofldval = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremantibodydttm = _remantibodydttm
   IF (_remantibodydttm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remantibodydttm,((size(
        __antibodydttm) - _remantibodydttm)+ 1),__antibodydttm)))
    SET drawheight_antibodydttm = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remantibodydttm = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remantibodydttm,((size(__antibodydttm) -
       _remantibodydttm)+ 1),__antibodydttm)))))
     SET _remantibodydttm += rptsd->m_drawlength
    ELSE
     SET _remantibodydttm = 0
    ENDIF
    SET growsum += _remantibodydttm
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremabofld4 = _remabofld4
   IF (_remabofld4 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remabofld4,((size(
        __abofld4) - _remabofld4)+ 1),__abofld4)))
    SET drawheight_abofld4 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remabofld4 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remabofld4,((size(__abofld4) -
       _remabofld4)+ 1),__abofld4)))))
     SET _remabofld4 += rptsd->m_drawlength
    ELSE
     SET _remabofld4 = 0
    ENDIF
    SET growsum += _remabofld4
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.938)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremabofld6 = _remabofld6
   IF (_remabofld6 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remabofld6,((size(
        __abofld6) - _remabofld6)+ 1),__abofld6)))
    SET drawheight_abofld6 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remabofld6 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remabofld6,((size(__abofld6) -
       _remabofld6)+ 1),__abofld6)))))
     SET _remabofld6 += rptsd->m_drawlength
    ELSE
     SET _remabofld6 = 0
    ENDIF
    SET growsum += _remabofld6
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.063)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremabodttm = _remabodttm
   IF (_remabodttm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remabodttm,((size(
        __abodttm) - _remabodttm)+ 1),__abodttm)))
    SET drawheight_abodttm = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remabodttm = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remabodttm,((size(__abodttm) -
       _remabodttm)+ 1),__abodttm)))))
     SET _remabodttm += rptsd->m_drawlength
    ELSE
     SET _remabodttm = 0
    ENDIF
    SET growsum += _remabodttm
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremabofld = _remabofld
   IF (_remabofld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remabofld,((size(__abofld
        ) - _remabofld)+ 1),__abofld)))
    SET drawheight_abofld = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remabofld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remabofld,((size(__abofld) - _remabofld)
       + 1),__abofld)))))
     SET _remabofld += rptsd->m_drawlength
    ELSE
     SET _remabofld = 0
    ENDIF
    SET growsum += _remabofld
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.063)
   SET rptsd->m_width = 1.313
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremabofldval = _remabofldval
   IF (_remabofldval > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remabofldval,((size(
        __abofldval) - _remabofldval)+ 1),__abofldval)))
    SET drawheight_abofldval = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remabofldval = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remabofldval,((size(__abofldval) -
       _remabofldval)+ 1),__abofldval)))))
     SET _remabofldval += rptsd->m_drawlength
    ELSE
     SET _remabofldval = 0
    ENDIF
    SET growsum += _remabofldval
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Antibody:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = drawheight_antibodydttm
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   IF (ncalc=rpt_render
    AND _holdremantibodydttm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremantibodydttm,((
       size(__antibodydttm) - _holdremantibodydttm)+ 1),__antibodydttm)))
   ELSE
    SET _remantibodydttm = _holdremantibodydttm
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = drawheight_abofld4
   IF (ncalc=rpt_render
    AND _holdremabofld4 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremabofld4,((size(
        __abofld4) - _holdremabofld4)+ 1),__abofld4)))
   ELSE
    SET _remabofld4 = _holdremabofld4
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.938)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_abofld6
   IF (ncalc=rpt_render
    AND _holdremabofld6 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremabofld6,((size(
        __abofld6) - _holdremabofld6)+ 1),__abofld6)))
   ELSE
    SET _remabofld6 = _holdremabofld6
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.063)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = drawheight_abodttm
   IF (ncalc=rpt_render
    AND _holdremabodttm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremabodttm,((size(
        __abodttm) - _holdremabodttm)+ 1),__abodttm)))
   ELSE
    SET _remabodttm = _holdremabodttm
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = drawheight_abofld
   IF (ncalc=rpt_render
    AND _holdremabofld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremabofld,((size(
        __abofld) - _holdremabofld)+ 1),__abofld)))
   ELSE
    SET _remabofld = _holdremabofld
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.063)
   SET rptsd->m_width = 1.313
   SET rptsd->m_height = drawheight_abofldval
   IF (ncalc=rpt_render
    AND _holdremabofldval > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremabofldval,((size(
        __abofldval) - _holdremabofldval)+ 1),__abofldval)))
   ELSE
    SET _remabofldval = _holdremabofldval
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ABO/Rh:",char(0)))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (formssec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = formssecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (formssecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_formfld = f8 WITH noconstant(0.0), private
   DECLARE drawheight_formdttm = f8 WITH noconstant(0.0), private
   DECLARE __formfld = vc WITH noconstant(build2(info->formname,char(0))), protect
   DECLARE __formdttm = vc WITH noconstant(build2(info->formdttm,char(0))), protect
   IF (bcontinue=0)
    SET _remformfld = 1
    SET _remformdttm = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.094)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.188
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremformfld = _remformfld
   IF (_remformfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remformfld,((size(
        __formfld) - _remformfld)+ 1),__formfld)))
    SET drawheight_formfld = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remformfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remformfld,((size(__formfld) -
       _remformfld)+ 1),__formfld)))))
     SET _remformfld += rptsd->m_drawlength
    ELSE
     SET _remformfld = 0
    ENDIF
    SET growsum += _remformfld
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremformdttm = _remformdttm
   IF (_remformdttm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remformdttm,((size(
        __formdttm) - _remformdttm)+ 1),__formdttm)))
    SET drawheight_formdttm = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remformdttm = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remformdttm,((size(__formdttm) -
       _remformdttm)+ 1),__formdttm)))))
     SET _remformdttm += rptsd->m_drawlength
    ELSE
     SET _remformdttm = 0
    ENDIF
    SET growsum += _remformdttm
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Hemotherapy Chronology:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.094)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.188
   SET rptsd->m_height = drawheight_formfld
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   IF (ncalc=rpt_render
    AND _holdremformfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremformfld,((size(
        __formfld) - _holdremformfld)+ 1),__formfld)))
   ELSE
    SET _remformfld = _holdremformfld
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_formdttm
   IF (ncalc=rpt_render
    AND _holdremformdttm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremformdttm,((size(
        __formdttm) - _holdremformdttm)+ 1),__formdttm)))
   ELSE
    SET _remformdttm = _holdremformdttm
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (reactionsec(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = reactionsecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (reactionsecabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.010)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.198
    SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Previous Reaction to Transfusion:",
      char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Yes / No",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.177)
    SET rptsd->m_width = 1.271
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Reaction:",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.115)
    SET rptsd->m_width = 1.135
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("date/time:",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (labssec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = labssecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (labssecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.310000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_labs = f8 WITH noconstant(0.0), private
   DECLARE drawheight_labsdatetm = f8 WITH noconstant(0.0), private
   DECLARE drawheight_labval = f8 WITH noconstant(0.0), private
   DECLARE __labs = vc WITH noconstant(build2(info->labs,char(0))), protect
   DECLARE __labsdatetm = vc WITH noconstant(build2(info->labsdttm,char(0))), protect
   DECLARE __labval = vc WITH noconstant(build2(info->labsval,char(0))), protect
   IF (bcontinue=0)
    SET _remlabs = 1
    SET _remlabsdatetm = 1
    SET _remlabval = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabs = _remlabs
   IF (_remlabs > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabs,((size(__labs) -
       _remlabs)+ 1),__labs)))
    SET drawheight_labs = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabs = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabs,((size(__labs) - _remlabs)+ 1),
       __labs)))))
     SET _remlabs += rptsd->m_drawlength
    ELSE
     SET _remlabs = 0
    ENDIF
    SET growsum += _remlabs
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.313
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabsdatetm = _remlabsdatetm
   IF (_remlabsdatetm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabsdatetm,((size(
        __labsdatetm) - _remlabsdatetm)+ 1),__labsdatetm)))
    SET drawheight_labsdatetm = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabsdatetm = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabsdatetm,((size(__labsdatetm) -
       _remlabsdatetm)+ 1),__labsdatetm)))))
     SET _remlabsdatetm += rptsd->m_drawlength
    ELSE
     SET _remlabsdatetm = 0
    ENDIF
    SET growsum += _remlabsdatetm
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabval = _remlabval
   IF (_remlabval > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabval,((size(__labval
        ) - _remlabval)+ 1),__labval)))
    SET drawheight_labval = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabval = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabval,((size(__labval) - _remlabval)
       + 1),__labval)))))
     SET _remlabval += rptsd->m_drawlength
    ELSE
     SET _remlabval = 0
    ENDIF
    SET growsum += _remlabval
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.448
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Labs:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.125
   SET rptsd->m_height = drawheight_labs
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   IF (ncalc=rpt_render
    AND _holdremlabs > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabs,((size(__labs
        ) - _holdremlabs)+ 1),__labs)))
   ELSE
    SET _remlabs = _holdremlabs
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.313
   SET rptsd->m_height = drawheight_labsdatetm
   IF (ncalc=rpt_render
    AND _holdremlabsdatetm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabsdatetm,((size(
        __labsdatetm) - _holdremlabsdatetm)+ 1),__labsdatetm)))
   ELSE
    SET _remlabsdatetm = _holdremlabsdatetm
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = drawheight_labval
   IF (ncalc=rpt_render
    AND _holdremlabval > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabval,((size(
        __labval) - _holdremlabval)+ 1),__labval)))
   ELSE
    SET _remlabval = _holdremlabval
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (reactioninfosec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = reactioninfosecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (reactioninfosecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.420000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_weightfld = f8 WITH noconstant(0.0), private
   DECLARE drawheight_intakefld = f8 WITH noconstant(0.0), private
   DECLARE __weightfld = vc WITH noconstant(build2(info->weight,char(0))), protect
   DECLARE __intakefld = vc WITH noconstant(build2(info->intake,char(0))), protect
   IF (bcontinue=0)
    SET _remweightfld = 1
    SET _remintakefld = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.438)
   SET rptsd->m_width = 5.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremweightfld = _remweightfld
   IF (_remweightfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remweightfld,((size(
        __weightfld) - _remweightfld)+ 1),__weightfld)))
    SET drawheight_weightfld = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remweightfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remweightfld,((size(__weightfld) -
       _remweightfld)+ 1),__weightfld)))))
     SET _remweightfld += rptsd->m_drawlength
    ELSE
     SET _remweightfld = 0
    ENDIF
    SET growsum += _remweightfld
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.563)
   SET rptsd->m_width = 5.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremintakefld = _remintakefld
   IF (_remintakefld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remintakefld,((size(
        __intakefld) - _remintakefld)+ 1),__intakefld)))
    SET drawheight_intakefld = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remintakefld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remintakefld,((size(__intakefld) -
       _remintakefld)+ 1),__intakefld)))))
     SET _remintakefld += rptsd->m_drawlength
    ELSE
     SET _remintakefld = 0
    ENDIF
    SET growsum += _remintakefld
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Reaction Information:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.438)
   SET rptsd->m_width = 5.125
   SET rptsd->m_height = drawheight_weightfld
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   IF (ncalc=rpt_render
    AND _holdremweightfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremweightfld,((size(
        __weightfld) - _holdremweightfld)+ 1),__weightfld)))
   ELSE
    SET _remweightfld = _holdremweightfld
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.125)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.448
   SET rptsd->m_height = 0.198
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Weight:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.563)
   SET rptsd->m_width = 5.000
   SET rptsd->m_height = drawheight_intakefld
   IF (ncalc=rpt_render
    AND _holdremintakefld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremintakefld,((size(
        __intakefld) - _holdremintakefld)+ 1),__intakefld)))
   ELSE
    SET _remintakefld = _holdremintakefld
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.250)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.823
   SET rptsd->m_height = 0.125
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Intake 12h:",char(0)))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (medssec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = medssecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (medssecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_medsfld = f8 WITH noconstant(0.0), private
   DECLARE drawheight_medsdttmfld = f8 WITH noconstant(0.0), private
   DECLARE drawheight_medsstatusfld = f8 WITH noconstant(0.0), private
   DECLARE __medsfld = vc WITH noconstant(build2(info->meds,char(0))), protect
   DECLARE __medsdttmfld = vc WITH noconstant(build2(info->medsdttm,char(0))), protect
   DECLARE __medsstatusfld = vc WITH noconstant(build2(info->medsstatus,char(0))), protect
   IF (bcontinue=0)
    SET _remmedsfld = 1
    SET _remmedsdttmfld = 1
    SET _remmedsstatusfld = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 4.938
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremmedsfld = _remmedsfld
   IF (_remmedsfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmedsfld,((size(
        __medsfld) - _remmedsfld)+ 1),__medsfld)))
    SET drawheight_medsfld = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmedsfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmedsfld,((size(__medsfld) -
       _remmedsfld)+ 1),__medsfld)))))
     SET _remmedsfld += rptsd->m_drawlength
    ELSE
     SET _remmedsfld = 0
    ENDIF
    SET growsum += _remmedsfld
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremmedsdttmfld = _remmedsdttmfld
   IF (_remmedsdttmfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmedsdttmfld,((size(
        __medsdttmfld) - _remmedsdttmfld)+ 1),__medsdttmfld)))
    SET drawheight_medsdttmfld = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmedsdttmfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmedsdttmfld,((size(__medsdttmfld) -
       _remmedsdttmfld)+ 1),__medsdttmfld)))))
     SET _remmedsdttmfld += rptsd->m_drawlength
    ELSE
     SET _remmedsdttmfld = 0
    ENDIF
    SET growsum += _remmedsdttmfld
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.063)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremmedsstatusfld = _remmedsstatusfld
   IF (_remmedsstatusfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmedsstatusfld,((size(
        __medsstatusfld) - _remmedsstatusfld)+ 1),__medsstatusfld)))
    SET drawheight_medsstatusfld = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmedsstatusfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmedsstatusfld,((size(__medsstatusfld)
        - _remmedsstatusfld)+ 1),__medsstatusfld)))))
     SET _remmedsstatusfld += rptsd->m_drawlength
    ELSE
     SET _remmedsstatusfld = 0
    ENDIF
    SET growsum += _remmedsstatusfld
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Medications:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 4.938
   SET rptsd->m_height = drawheight_medsfld
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   IF (ncalc=rpt_render
    AND _holdremmedsfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedsfld,((size(
        __medsfld) - _holdremmedsfld)+ 1),__medsfld)))
   ELSE
    SET _remmedsfld = _holdremmedsfld
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = drawheight_medsdttmfld
   IF (ncalc=rpt_render
    AND _holdremmedsdttmfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedsdttmfld,((size
       (__medsdttmfld) - _holdremmedsdttmfld)+ 1),__medsdttmfld)))
   ELSE
    SET _remmedsdttmfld = _holdremmedsdttmfld
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.063)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_medsstatusfld
   IF (ncalc=rpt_render
    AND _holdremmedsstatusfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedsstatusfld,((
       size(__medsstatusfld) - _holdremmedsstatusfld)+ 1),__medsstatusfld)))
   ELSE
    SET _remmedsstatusfld = _holdremmedsstatusfld
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (o2sec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = o2secabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (o2secabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect
  )
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_medsfld = f8 WITH noconstant(0.0), private
   DECLARE drawheight_medsdttmfld = f8 WITH noconstant(0.0), private
   DECLARE drawheight_medsstatusfld = f8 WITH noconstant(0.0), private
   DECLARE __medsfld = vc WITH noconstant(build2(info->oxygen,char(0))), protect
   DECLARE __medsdttmfld = vc WITH noconstant(build2(info->oxygendttm,char(0))), protect
   DECLARE __medsstatusfld = vc WITH noconstant(build2(info->oxygenstatus,char(0))), protect
   IF (bcontinue=0)
    SET _remmedsfld = 1
    SET _remmedsdttmfld = 1
    SET _remmedsstatusfld = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 4.938
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremmedsfld = _remmedsfld
   IF (_remmedsfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmedsfld,((size(
        __medsfld) - _remmedsfld)+ 1),__medsfld)))
    SET drawheight_medsfld = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmedsfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmedsfld,((size(__medsfld) -
       _remmedsfld)+ 1),__medsfld)))))
     SET _remmedsfld += rptsd->m_drawlength
    ELSE
     SET _remmedsfld = 0
    ENDIF
    SET growsum += _remmedsfld
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremmedsdttmfld = _remmedsdttmfld
   IF (_remmedsdttmfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmedsdttmfld,((size(
        __medsdttmfld) - _remmedsdttmfld)+ 1),__medsdttmfld)))
    SET drawheight_medsdttmfld = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmedsdttmfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmedsdttmfld,((size(__medsdttmfld) -
       _remmedsdttmfld)+ 1),__medsdttmfld)))))
     SET _remmedsdttmfld += rptsd->m_drawlength
    ELSE
     SET _remmedsdttmfld = 0
    ENDIF
    SET growsum += _remmedsdttmfld
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.063)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremmedsstatusfld = _remmedsstatusfld
   IF (_remmedsstatusfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmedsstatusfld,((size(
        __medsstatusfld) - _remmedsstatusfld)+ 1),__medsstatusfld)))
    SET drawheight_medsstatusfld = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmedsstatusfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmedsstatusfld,((size(__medsstatusfld)
        - _remmedsstatusfld)+ 1),__medsstatusfld)))))
     SET _remmedsstatusfld += rptsd->m_drawlength
    ELSE
     SET _remmedsstatusfld = 0
    ENDIF
    SET growsum += _remmedsstatusfld
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 4.375
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Supplemental oxygen use:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 4.938
   SET rptsd->m_height = drawheight_medsfld
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   IF (ncalc=rpt_render
    AND _holdremmedsfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedsfld,((size(
        __medsfld) - _holdremmedsfld)+ 1),__medsfld)))
   ELSE
    SET _remmedsfld = _holdremmedsfld
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = drawheight_medsdttmfld
   IF (ncalc=rpt_render
    AND _holdremmedsdttmfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedsdttmfld,((size
       (__medsdttmfld) - _holdremmedsdttmfld)+ 1),__medsdttmfld)))
   ELSE
    SET _remmedsdttmfld = _holdremmedsdttmfld
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.063)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_medsstatusfld
   IF (ncalc=rpt_render
    AND _holdremmedsstatusfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedsstatusfld,((
       size(__medsstatusfld) - _holdremmedsstatusfld)+ 1),__medsstatusfld)))
   ELSE
    SET _remmedsstatusfld = _holdremmedsstatusfld
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (vitalssec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = vitalssecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerowabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerowabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.188020), private
   DECLARE __cellname26 = vc WITH noconstant(build(info->transfusionstarttime,char(0))), protect
   DECLARE __cellname27 = vc WITH noconstant(build(info->temperaturestart,char(0))), protect
   DECLARE __cellname28 = vc WITH noconstant(build(info->temperatureroutestart,char(0))), protect
   DECLARE __cellname29 = vc WITH noconstant(build(info->pulseratestart,char(0))), protect
   DECLARE __cellname0 = vc WITH noconstant(build(info->pp_start,char(0))), protect
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.156
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times8bu0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen2s1c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Transfusion start:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.156)
   SET rptsd->m_width = 1.031
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname26)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.188)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Temp:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.563)
   SET rptsd->m_width = 0.812
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname27)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.375)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Temp Route:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname28)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.750)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Pulse:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.312)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname29)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.062)
   SET rptsd->m_width = 0.437
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("PP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.500)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname0)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.156),offsety,(offsetx+ 1.156),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.188),offsety,(offsetx+ 2.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.563),offsety,(offsetx+ 2.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.375),offsety,(offsetx+ 3.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.000),offsety,(offsetx+ 4.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.750),offsety,(offsetx+ 4.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.312),offsety,(offsetx+ 5.312),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.062),offsety,(offsetx+ 6.062),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.500),offsety,(offsetx+ 6.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow1(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow1abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.188020), private
   DECLARE __cellname30 = vc WITH noconstant(build(info->respiratoryratestart,char(0))), protect
   DECLARE __cellname31 = vc WITH noconstant(build(info->systolicbloodpressurestart,char(0))),
   protect
   DECLARE __cellname32 = vc WITH noconstant(build(info->diastolicbloodpressurestart,char(0))),
   protect
   DECLARE __cellname33 = vc WITH noconstant(build(info->oxygensaturationstart,char(0))), protect
   DECLARE __cellname3 = vc WITH noconstant(build(info->map_start,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.156
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.156)
   SET rptsd->m_width = 0.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("RR:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.156)
   SET rptsd->m_width = 0.406
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("RR:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.563)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname30)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.188)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("SBP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.563)
   SET rptsd->m_width = 0.812
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname31)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.375)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("DBP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname32)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.750)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("O2 Sat:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.313)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname33)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.062)
   SET rptsd->m_width = 0.437
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("MAP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.500)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname3)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.156),offsety,(offsetx+ 1.156),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.156),offsety,(offsetx+ 1.156),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.563),offsety,(offsetx+ 1.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.188),offsety,(offsetx+ 2.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.563),offsety,(offsetx+ 2.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.375),offsety,(offsetx+ 3.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.000),offsety,(offsetx+ 4.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.750),offsety,(offsetx+ 4.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.313),offsety,(offsetx+ 5.313),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.062),offsety,(offsetx+ 6.062),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.500),offsety,(offsetx+ 6.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow8(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow8abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow8abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.198472), private
   DECLARE __cellname302 = vc WITH noconstant(build(info->transfusionstartplus15min,char(0))),
   protect
   DECLARE __cellname304 = vc WITH noconstant(build(info->temperature15min,char(0))), protect
   DECLARE __cellname306 = vc WITH noconstant(build(info->temperatureroutestart,char(0))), protect
   DECLARE __cellname308 = vc WITH noconstant(build(info->pulserate15min,char(0))), protect
   DECLARE __cellname9 = vc WITH noconstant(build(info->pp_15min,char(0))), protect
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.156
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times8bu0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s3c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Transfusion 15 min:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.156)
   SET rptsd->m_width = 1.031
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname302)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.188)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Temp:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.563)
   SET rptsd->m_width = 0.812
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname304)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.375)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Temp Route:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname306)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.750)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Pulse:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.312)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname308)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.062)
   SET rptsd->m_width = 0.437
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("PP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.500)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname9)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.156),offsety,(offsetx+ 1.156),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.188),offsety,(offsetx+ 2.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.563),offsety,(offsetx+ 2.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.375),offsety,(offsetx+ 3.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.000),offsety,(offsetx+ 4.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.750),offsety,(offsetx+ 4.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.312),offsety,(offsetx+ 5.312),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.062),offsety,(offsetx+ 6.062),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.500),offsety,(offsetx+ 6.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow9(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow9abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow9abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.177576), private
   DECLARE __cellname310 = vc WITH noconstant(build(info->respiratoryrate15min,char(0))), protect
   DECLARE __cellname312 = vc WITH noconstant(build(info->systolicbloodpressure15min,char(0))),
   protect
   DECLARE __cellname314 = vc WITH noconstant(build(info->diastolicbloodpressure15min,char(0))),
   protect
   DECLARE __cellname316 = vc WITH noconstant(build(info->oxygensaturation15min,char(0))), protect
   DECLARE __cellname11 = vc WITH noconstant(build(info->map_15min,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.156
   SET rptsd->m_height = 0.178
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.156)
   SET rptsd->m_width = 0.000
   SET rptsd->m_height = 0.178
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("RR:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.156)
   SET rptsd->m_width = 0.406
   SET rptsd->m_height = 0.178
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("RR:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.563)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.178
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname310)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.188)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.178
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("SBP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.563)
   SET rptsd->m_width = 0.812
   SET rptsd->m_height = 0.178
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname312)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.375)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.178
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("DBP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.178
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname314)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.750)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = 0.178
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("O2 Sat:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.313)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.178
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname316)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.062)
   SET rptsd->m_width = 0.437
   SET rptsd->m_height = 0.178
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("MAP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.500)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.178
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname11)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.156),offsety,(offsetx+ 1.156),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.156),offsety,(offsetx+ 1.156),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.563),offsety,(offsetx+ 1.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.188),offsety,(offsetx+ 2.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.563),offsety,(offsetx+ 2.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.375),offsety,(offsetx+ 3.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.000),offsety,(offsetx+ 4.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.750),offsety,(offsetx+ 4.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.313),offsety,(offsetx+ 5.313),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.062),offsety,(offsetx+ 6.062),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.500),offsety,(offsetx+ 6.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow4(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow4abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow4abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.194466), private
   DECLARE __cellname42 = vc WITH noconstant(build(info->transfusionendtime,char(0))), protect
   DECLARE __cellname43 = vc WITH noconstant(build(info->temperatureend,char(0))), protect
   DECLARE __cellname44 = vc WITH noconstant(build(info->temperaturerouteend,char(0))), protect
   DECLARE __cellname45 = vc WITH noconstant(build(info->pulserateend,char(0))), protect
   DECLARE __cellname18 = vc WITH noconstant(build(info->pp_end,char(0))), protect
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.156
   SET rptsd->m_height = 0.194
   SET _dummyfont = uar_rptsetfont(_hreport,_times8bu0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s3c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Transfusion end",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.156)
   SET rptsd->m_width = 1.031
   SET rptsd->m_height = 0.194
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname42)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.188)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.194
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Temp:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.563)
   SET rptsd->m_width = 0.812
   SET rptsd->m_height = 0.194
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname43)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.375)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.194
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Temp Route:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.194
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname44)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.750)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = 0.194
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Pulse:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.312)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.194
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname45)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.062)
   SET rptsd->m_width = 0.437
   SET rptsd->m_height = 0.194
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("PP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.500)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.194
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname18)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.156),offsety,(offsetx+ 1.156),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.188),offsety,(offsetx+ 2.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.563),offsety,(offsetx+ 2.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.375),offsety,(offsetx+ 3.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.000),offsety,(offsetx+ 4.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.750),offsety,(offsetx+ 4.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.312),offsety,(offsetx+ 5.312),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.062),offsety,(offsetx+ 6.062),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.500),offsety,(offsetx+ 6.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow5(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow5abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow5abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.189309), private
   DECLARE __cellname46 = vc WITH noconstant(build(info->respiratoryrateend,char(0))), protect
   DECLARE __cellname47 = vc WITH noconstant(build(info->systolicbloodpressureend,char(0))), protect
   DECLARE __cellname48 = vc WITH noconstant(build(info->diastolicbloodpressureend,char(0))), protect
   DECLARE __cellname49 = vc WITH noconstant(build(info->oxygensaturationend,char(0))), protect
   DECLARE __cellname19 = vc WITH noconstant(build(info->map_end,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.156
   SET rptsd->m_height = 0.189
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.156)
   SET rptsd->m_width = 0.000
   SET rptsd->m_height = 0.189
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("RR:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.156)
   SET rptsd->m_width = 0.406
   SET rptsd->m_height = 0.189
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("RR:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.563)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.189
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname46)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.188)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.189
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("SBP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.563)
   SET rptsd->m_width = 0.812
   SET rptsd->m_height = 0.189
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname47)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.375)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.189
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("DBP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.189
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname48)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.750)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = 0.189
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("O2 Sat:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.313)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.189
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname49)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.062)
   SET rptsd->m_width = 0.437
   SET rptsd->m_height = 0.189
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("MAP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.500)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.189
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname19)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.156),offsety,(offsetx+ 1.156),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.156),offsety,(offsetx+ 1.156),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.563),offsety,(offsetx+ 1.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.188),offsety,(offsetx+ 2.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.563),offsety,(offsetx+ 2.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.375),offsety,(offsetx+ 3.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.000),offsety,(offsetx+ 4.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.750),offsety,(offsetx+ 4.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.313),offsety,(offsetx+ 5.313),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.062),offsety,(offsetx+ 6.062),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.500),offsety,(offsetx+ 6.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow6(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow6abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow6abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.156685), private
   DECLARE __cellname74 = vc WITH noconstant(build(info->temp_delta1,char(0))), protect
   DECLARE __cellname78 = vc WITH noconstant(build(info->pulse_delta1,char(0))), protect
   DECLARE __cellname80 = vc WITH noconstant(build(info->pp_delta1,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.156
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Transfusion Delta 1",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.156)
   SET rptsd->m_width = 0.000
   SET rptsd->m_height = 0.157
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.156)
   SET rptsd->m_width = 0.406
   SET rptsd->m_height = 0.157
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.563)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.188)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Temp:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.563)
   SET rptsd->m_width = 0.812
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname74)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.375)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.750)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Pulse:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.313)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname78)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.062)
   SET rptsd->m_width = 0.437
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("PP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.500)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname80)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.156),offsety,(offsetx+ 1.156),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.156),offsety,(offsetx+ 1.156),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.563),offsety,(offsetx+ 1.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.188),offsety,(offsetx+ 2.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.563),offsety,(offsetx+ 2.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.375),offsety,(offsetx+ 3.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.000),offsety,(offsetx+ 4.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.750),offsety,(offsetx+ 4.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.313),offsety,(offsetx+ 5.313),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.062),offsety,(offsetx+ 6.062),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.500),offsety,(offsetx+ 6.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow10(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow10abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow10abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.162742), private
   DECLARE __cellname84 = vc WITH noconstant(build(info->rr_delta1,char(0))), protect
   DECLARE __cellname87 = vc WITH noconstant(build(info->sbp_delta1,char(0))), protect
   DECLARE __cellname89 = vc WITH noconstant(build(info->dbp_delta1,char(0))), protect
   DECLARE __cellname91 = vc WITH noconstant(build(info->o2_sat_delta1,char(0))), protect
   DECLARE __cellname93 = vc WITH noconstant(build(info->map_delta1,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.156
   SET rptsd->m_height = 0.163
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.156)
   SET rptsd->m_width = 0.000
   SET rptsd->m_height = 0.163
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.156)
   SET rptsd->m_width = 0.406
   SET rptsd->m_height = 0.163
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("RR:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.563)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.163
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname84)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.188)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.163
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("SBP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.563)
   SET rptsd->m_width = 0.812
   SET rptsd->m_height = 0.163
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname87)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.375)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.163
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("DBP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.163
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname89)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.750)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = 0.163
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("O2 Sat:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.313)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.163
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname91)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.062)
   SET rptsd->m_width = 0.437
   SET rptsd->m_height = 0.163
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("MAP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.500)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.163
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname93)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.156),offsety,(offsetx+ 1.156),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.156),offsety,(offsetx+ 1.156),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.563),offsety,(offsetx+ 1.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.188),offsety,(offsetx+ 2.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.563),offsety,(offsetx+ 2.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.375),offsety,(offsetx+ 3.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.000),offsety,(offsetx+ 4.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.750),offsety,(offsetx+ 4.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.313),offsety,(offsetx+ 5.313),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.062),offsety,(offsetx+ 6.062),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.500),offsety,(offsetx+ 6.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow2(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow2abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow2abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.156685), private
   DECLARE __cellname111 = vc WITH noconstant(build(info->temp_delta2,char(0))), protect
   DECLARE __cellname115 = vc WITH noconstant(build(info->pulse_delta2,char(0))), protect
   DECLARE __cellname117 = vc WITH noconstant(build(info->pp_delta2,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.156
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Transfusion Delta 2",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.156)
   SET rptsd->m_width = 0.000
   SET rptsd->m_height = 0.157
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.156)
   SET rptsd->m_width = 0.406
   SET rptsd->m_height = 0.157
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.563)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.188)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Temp:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.563)
   SET rptsd->m_width = 0.812
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname111)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.375)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.750)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Pulse:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.313)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname115)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.062)
   SET rptsd->m_width = 0.437
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("PP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.500)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname117)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.156),offsety,(offsetx+ 1.156),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.156),offsety,(offsetx+ 1.156),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.563),offsety,(offsetx+ 1.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.188),offsety,(offsetx+ 2.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.563),offsety,(offsetx+ 2.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.375),offsety,(offsetx+ 3.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.000),offsety,(offsetx+ 4.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.750),offsety,(offsetx+ 4.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.313),offsety,(offsetx+ 5.313),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.062),offsety,(offsetx+ 6.062),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.500),offsety,(offsetx+ 6.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow3(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow3abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow3abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.156685), private
   DECLARE __cellname121 = vc WITH noconstant(build(info->rr_delta2,char(0))), protect
   DECLARE __cellname125 = vc WITH noconstant(build(info->sbp_delta2,char(0))), protect
   DECLARE __cellname127 = vc WITH noconstant(build(info->dbp_delta2,char(0))), protect
   DECLARE __cellname129 = vc WITH noconstant(build(info->o2_sat_delta2,char(0))), protect
   DECLARE __cellname133 = vc WITH noconstant(build(info->map_delta2,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.156
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.156)
   SET rptsd->m_width = 0.000
   SET rptsd->m_height = 0.157
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.156)
   SET rptsd->m_width = 0.406
   SET rptsd->m_height = 0.157
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("RR:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.563)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname121)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.188)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("SBP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.563)
   SET rptsd->m_width = 0.812
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname125)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.375)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("DBP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname127)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.750)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("O2 Sat:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.313)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname129)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.062)
   SET rptsd->m_width = 0.437
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("MAP:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.500)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname133)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.156),offsety,(offsetx+ 1.156),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.156),offsety,(offsetx+ 1.156),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.563),offsety,(offsetx+ 1.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.188),offsety,(offsetx+ 2.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.563),offsety,(offsetx+ 2.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.375),offsety,(offsetx+ 3.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.000),offsety,(offsetx+ 4.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.750),offsety,(offsetx+ 4.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.313),offsety,(offsetx+ 5.313),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.062),offsety,(offsetx+ 6.062),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.500),offsety,(offsetx+ 6.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow39(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow39abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow39abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.167533), private
   DECLARE __cellname203 = vc WITH noconstant(build(info->transfusionadministrationequipment,char(0))
    ), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.937
   SET rptsd->m_height = 0.168
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Transfusion Administration Equipment:",
      char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.937)
   SET rptsd->m_width = 5.563
   SET rptsd->m_height = 0.168
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname203)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.937),offsety,(offsetx+ 1.937),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow13(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow13abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow13abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.156685), private
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = rpt_sdtopborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.500
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Volumes",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.157
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((info->rate_infused > " "))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Transfusion Rate",char(0)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.625)
   SET rptsd->m_width = 2.875
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.500),offsety,(offsetx+ 3.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.625),offsety,(offsetx+ 4.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow25(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow25abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow25abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.156685), private
   DECLARE __cellname163 = vc WITH noconstant(build(info->amountinfused,char(0))), protect
   DECLARE __cellname204 = vc WITH noconstant(build(info->rate_infused,char(0))), protect
   SET rptsd->m_flags = 64
   SET rptsd->m_borders = rpt_sdtopborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.500
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen7s0c8421504)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname163)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.157
   SET _dummypen = uar_rptsetpen(_hreport,_pen7s0c8421504)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname204)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.625)
   SET rptsd->m_width = 2.875
   SET rptsd->m_height = 0.157
   SET _dummypen = uar_rptsetpen(_hreport,_pen7s0c8421504)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.500),offsety,(offsetx+ 3.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.625),offsety,(offsetx+ 4.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow27(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow27abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow27abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.156685), private
   DECLARE __cellname167 = vc WITH noconstant(build(info->other_infused,char(0))), protect
   SET rptsd->m_flags = 64
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.500
   SET rptsd->m_height = 0.157
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c8421504)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname167)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.000
   SET rptsd->m_height = 0.157
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c8421504)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.500),offsety,(offsetx+ 3.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (vitalssecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(2.750000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_medsfld = f8 WITH noconstant(0.0), private
   DECLARE __medsfld = vc WITH noconstant(build2(info->transfusionreactiondescription,char(0))),
   protect
   IF (bcontinue=0)
    SET _remmedsfld = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 2.563)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.750)
   SET rptsd->m_width = 4.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremmedsfld = _remmedsfld
   IF (_remmedsfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmedsfld,((size(
        __medsfld) - _remmedsfld)+ 1),__medsfld)))
    SET drawheight_medsfld = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmedsfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmedsfld,((size(__medsfld) -
       _remmedsfld)+ 1),__medsfld)))))
     SET _remmedsfld += rptsd->m_drawlength
    ELSE
     SET _remmedsfld = 0
    ENDIF
    SET growsum += _remmedsfld
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET _yoffset = (offsety+ 0.125)
   SET _fholdoffsety = (_yoffset - offsety)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.125)
    SET holdheight = 0
    SET maxheight_tablerow = 0.000
    SET holdheight += tablerow(rpt_render)
    SET holdheight += tablerow1(rpt_render)
    SET holdheight += tablerow8(rpt_render)
    SET holdheight += tablerow9(rpt_render)
    SET holdheight += tablerow4(rpt_render)
    SET holdheight += tablerow5(rpt_render)
    SET holdheight += tablerow6(rpt_render)
    SET holdheight += tablerow10(rpt_render)
    SET holdheight += tablerow2(rpt_render)
    SET holdheight += tablerow3(rpt_render)
    SET holdheight += tablerow39(rpt_render)
    SET holdheight += tablerow13(rpt_render)
    SET holdheight += tablerow25(rpt_render)
    SET holdheight += tablerow27(rpt_render)
    SET _yoffset = offsety
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_y = (offsety+ 2.563)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.313
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Signs and Symptoms of Suspected Transfusion Reaction:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 2.563)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.750)
   SET rptsd->m_width = 4.750
   SET rptsd->m_height = drawheight_medsfld
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   IF (ncalc=rpt_render
    AND _holdremmedsfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedsfld,((size(
        __medsfld) - _holdremmedsfld)+ 1),__medsfld)))
   ELSE
    SET _remmedsfld = _holdremmedsfld
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (staticsec3(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = staticsec3abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (staticsec3abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(4.310000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_double
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 4.313
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "Additional Reaction Information: ",_crlf,
       "Physician Notified: __________________________________________ Notified Date/Time: _____________________",
       _crlf,
       "Reported By: _______________________________________________ Reported Date/Time: ____________________",
       _crlf,
       "Treatment (if any, including respiratory treatment) ________________________________________________________",
       _crlf,
       "Premedication (if any) _______________________________________________________________________________",
       _crlf,
       "Any blood products given in the two hours before the time of the reaction: _____ (if yes, list in blood product ",
       "information)",_crlf,
       "Volume of non-blood IV fluid given in the two hours before the start of the transfusion: _______________________",
       "____",
       _crlf,
       "Volume of non-blood IV fluid given during the transfusion of the implicated product: ___________________________",
       "__",_crlf,
       "Any diuretic given within two hours of transfusion:  ___________________________ Yes (if yes, specify)   _______",
       "_ No",_crlf,
       "Infusion Rate on blood order: _________________________________________________________________________",
       _crlf,
       "History of prior suspected/confirmed transfusion reactions: _________________________________________________",
       _crlf,
       "Previous Antibody History: __________________________________________________________________________",
       _crlf,
       "Transfusion History: ________________________________________________________________________________",
       _crlf,
       "RBC prior to this Date: ________ Yes    ________ No     Other Non-Red Cell Transfusions: ________ Yes   _______ ",
       "No",_crlf,
       "Other information: ___________________________________________________________________________________",
       _crlf,
       "_________________________________________________________________________________________________"
       ),char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (staticsectoin04(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = staticsectoin04abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow11(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow11abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow11abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.322916), private
   SET rptsd->m_flags = 20
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.243
   SET rptsd->m_height = 0.316
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Blood Product Code",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.257)
   SET rptsd->m_width = 1.337
   SET rptsd->m_height = 0.316
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Unit ID Number/Lot",char(0)))
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.601)
   SET rptsd->m_width = 0.983
   SET rptsd->m_height = 0.316
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("ABO/Rh",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.590)
   SET rptsd->m_width = 1.410
   SET rptsd->m_height = 0.316
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Date/Time Issued",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.007)
   SET rptsd->m_width = 1.180
   SET rptsd->m_height = 0.316
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Date of Collection",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.194)
   SET rptsd->m_width = 1.306
   SET rptsd->m_height = 0.316
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Age of Product at Issue",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.250),offsety,(offsetx+ 1.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.594),offsety,(offsetx+ 2.594),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.583),offsety,(offsetx+ 3.583),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.000),offsety,(offsetx+ 5.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.188),offsety,(offsetx+ 6.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow12(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow12abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow12abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.208333), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.243
   SET rptsd->m_height = 0.201
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.257)
   SET rptsd->m_width = 1.337
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.601)
   SET rptsd->m_width = 0.983
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.590)
   SET rptsd->m_width = 1.410
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.007)
   SET rptsd->m_width = 1.180
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.194)
   SET rptsd->m_width = 1.306
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.250),offsety,(offsetx+ 1.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.594),offsety,(offsetx+ 2.594),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.583),offsety,(offsetx+ 3.583),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.000),offsety,(offsetx+ 5.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.188),offsety,(offsetx+ 6.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow15(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow15abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow15abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.208333), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.243
   SET rptsd->m_height = 0.201
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.257)
   SET rptsd->m_width = 1.337
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.601)
   SET rptsd->m_width = 0.983
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.590)
   SET rptsd->m_width = 1.410
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.007)
   SET rptsd->m_width = 1.180
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.194)
   SET rptsd->m_width = 1.306
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.250),offsety,(offsetx+ 1.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.594),offsety,(offsetx+ 2.594),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.583),offsety,(offsetx+ 3.583),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.000),offsety,(offsetx+ 5.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.188),offsety,(offsetx+ 6.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow16(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow16abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow16abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.208333), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.243
   SET rptsd->m_height = 0.201
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.257)
   SET rptsd->m_width = 1.337
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.601)
   SET rptsd->m_width = 0.983
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.590)
   SET rptsd->m_width = 1.410
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.007)
   SET rptsd->m_width = 1.180
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.194)
   SET rptsd->m_width = 1.306
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.250),offsety,(offsetx+ 1.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.594),offsety,(offsetx+ 2.594),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.583),offsety,(offsetx+ 3.583),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.000),offsety,(offsetx+ 5.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.188),offsety,(offsetx+ 6.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow17(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow17abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow17abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.208333), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.243
   SET rptsd->m_height = 0.201
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.257)
   SET rptsd->m_width = 1.337
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.601)
   SET rptsd->m_width = 0.983
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.590)
   SET rptsd->m_width = 1.410
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.007)
   SET rptsd->m_width = 1.180
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.194)
   SET rptsd->m_width = 1.306
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.250),offsety,(offsetx+ 1.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.594),offsety,(offsetx+ 2.594),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.583),offsety,(offsetx+ 3.583),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.000),offsety,(offsetx+ 5.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.188),offsety,(offsetx+ 6.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow18(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow18abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow18abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.218752), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.243
   SET rptsd->m_height = 0.212
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.257)
   SET rptsd->m_width = 1.337
   SET rptsd->m_height = 0.212
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.601)
   SET rptsd->m_width = 0.983
   SET rptsd->m_height = 0.212
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.590)
   SET rptsd->m_width = 1.410
   SET rptsd->m_height = 0.212
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.007)
   SET rptsd->m_width = 1.180
   SET rptsd->m_height = 0.212
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.194)
   SET rptsd->m_width = 1.306
   SET rptsd->m_height = 0.212
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.250),offsety,(offsetx+ 1.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.594),offsety,(offsetx+ 2.594),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.583),offsety,(offsetx+ 3.583),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.000),offsety,(offsetx+ 5.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.188),offsety,(offsetx+ 6.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow19(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow19abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow19abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 5.493
   SET rptsd->m_height = 0.243
   SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Group & Rh Testing",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.507)
   SET rptsd->m_width = 1.993
   SET rptsd->m_height = 0.243
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Antibody Screen Testing",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.500),offsety,(offsetx+ 5.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow20(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow20abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow20abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.333333), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.180
   SET rptsd->m_height = 0.326
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.194)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.326
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("A",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.632)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.326
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("B",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.069)
   SET rptsd->m_width = 0.514
   SET rptsd->m_height = 0.326
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("D",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.590)
   SET rptsd->m_width = 0.597
   SET rptsd->m_height = 0.326
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Du",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.194)
   SET rptsd->m_width = 0.555
   SET rptsd->m_height = 0.326
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("cc",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = - (0.006)
   SET rptsd->m_height = 0.326
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = - (0.006)
   SET rptsd->m_height = 0.326
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.326
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("A1",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.194)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.326
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("B",char(0)))
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.632)
   SET rptsd->m_width = 0.868
   SET rptsd->m_height = 0.326
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("ABO/Rh Interpretation",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.507)
   SET rptsd->m_width = 0.368
   SET rptsd->m_height = 0.326
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("I   AHG",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.882)
   SET rptsd->m_width = 0.368
   SET rptsd->m_height = 0.326
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("II AHG",char(0)))
   ENDIF
   SET rptsd->m_flags = 1040
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.257)
   SET rptsd->m_width = 0.681
   SET rptsd->m_height = 0.326
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("INT.",char(0)))
   ENDIF
   SET rptsd->m_flags = 1024
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.944)
   SET rptsd->m_width = 0.555
   SET rptsd->m_height = 0.326
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Tech",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.187),offsety,(offsetx+ 1.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.625),offsety,(offsetx+ 1.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.062),offsety,(offsetx+ 2.062),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.583),offsety,(offsetx+ 2.583),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.187),offsety,(offsetx+ 3.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.187),offsety,(offsetx+ 4.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.625),offsety,(offsetx+ 4.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.500),offsety,(offsetx+ 5.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.875),offsety,(offsetx+ 5.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.250),offsety,(offsetx+ 6.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.938),offsety,(offsetx+ 6.938),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow21(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow21abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow21abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.208333), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.180
   SET rptsd->m_height = 0.201
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("PRE-Trans Spec.",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.194)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.632)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.069)
   SET rptsd->m_width = 0.514
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.590)
   SET rptsd->m_width = 0.597
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.194)
   SET rptsd->m_width = 0.555
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = - (0.006)
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = - (0.006)
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.194)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.632)
   SET rptsd->m_width = 0.868
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.507)
   SET rptsd->m_width = 0.368
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.882)
   SET rptsd->m_width = 0.368
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.257)
   SET rptsd->m_width = 0.680
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.944)
   SET rptsd->m_width = 0.556
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.187),offsety,(offsetx+ 1.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.625),offsety,(offsetx+ 1.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.062),offsety,(offsetx+ 2.062),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.583),offsety,(offsetx+ 2.583),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.187),offsety,(offsetx+ 3.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.187),offsety,(offsetx+ 4.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.625),offsety,(offsetx+ 4.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.500),offsety,(offsetx+ 5.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.875),offsety,(offsetx+ 5.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.250),offsety,(offsetx+ 6.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.937),offsety,(offsetx+ 6.937),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow22(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow22abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow22abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.208333), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.180
   SET rptsd->m_height = 0.201
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("POST-Trans Spec.",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.194)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.632)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.069)
   SET rptsd->m_width = 0.514
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.590)
   SET rptsd->m_width = 0.597
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.194)
   SET rptsd->m_width = 0.555
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = - (0.006)
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = - (0.006)
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.194)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.632)
   SET rptsd->m_width = 0.868
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.507)
   SET rptsd->m_width = 0.368
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.882)
   SET rptsd->m_width = 0.368
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.257)
   SET rptsd->m_width = 0.680
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.944)
   SET rptsd->m_width = 0.556
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.187),offsety,(offsetx+ 1.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.625),offsety,(offsetx+ 1.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.062),offsety,(offsetx+ 2.062),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.583),offsety,(offsetx+ 2.583),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.187),offsety,(offsetx+ 3.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.187),offsety,(offsetx+ 4.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.625),offsety,(offsetx+ 4.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.500),offsety,(offsetx+ 5.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.875),offsety,(offsetx+ 5.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.250),offsety,(offsetx+ 6.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.937),offsety,(offsetx+ 6.937),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow24(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow24abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow24abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.197917), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.180
   SET rptsd->m_height = 0.191
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Donor#",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.194)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.632)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.069)
   SET rptsd->m_width = 0.514
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.590)
   SET rptsd->m_width = 0.597
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.194)
   SET rptsd->m_width = 0.555
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = - (0.006)
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = - (0.006)
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.194)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.632)
   SET rptsd->m_width = 0.868
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.507)
   SET rptsd->m_width = 0.368
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.882)
   SET rptsd->m_width = 0.368
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.257)
   SET rptsd->m_width = 0.680
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.944)
   SET rptsd->m_width = 0.556
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.187),offsety,(offsetx+ 1.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.625),offsety,(offsetx+ 1.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.062),offsety,(offsetx+ 2.062),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.583),offsety,(offsetx+ 2.583),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.187),offsety,(offsetx+ 3.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.187),offsety,(offsetx+ 4.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.625),offsety,(offsetx+ 4.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.500),offsety,(offsetx+ 5.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.875),offsety,(offsetx+ 5.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.250),offsety,(offsetx+ 6.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.937),offsety,(offsetx+ 6.937),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow40(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow40abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow40abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.208333), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.180
   SET rptsd->m_height = 0.201
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Donor#",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.194)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.632)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.069)
   SET rptsd->m_width = 0.514
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.590)
   SET rptsd->m_width = 0.597
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.194)
   SET rptsd->m_width = 0.555
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = - (0.006)
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = - (0.006)
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.194)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.632)
   SET rptsd->m_width = 0.868
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.507)
   SET rptsd->m_width = 0.368
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.882)
   SET rptsd->m_width = 0.368
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.257)
   SET rptsd->m_width = 0.680
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.944)
   SET rptsd->m_width = 0.556
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.187),offsety,(offsetx+ 1.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.625),offsety,(offsetx+ 1.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.062),offsety,(offsetx+ 2.062),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.583),offsety,(offsetx+ 2.583),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.187),offsety,(offsetx+ 3.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.187),offsety,(offsetx+ 4.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.625),offsety,(offsetx+ 4.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.500),offsety,(offsetx+ 5.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.875),offsety,(offsetx+ 5.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.250),offsety,(offsetx+ 6.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.937),offsety,(offsetx+ 6.937),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow41(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow41abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow41abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.180
   SET rptsd->m_height = 0.180
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Donor#",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.194)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.180
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.632)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.180
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.069)
   SET rptsd->m_width = 0.514
   SET rptsd->m_height = 0.180
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.590)
   SET rptsd->m_width = 0.597
   SET rptsd->m_height = 0.180
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.194)
   SET rptsd->m_width = 0.555
   SET rptsd->m_height = 0.180
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = - (0.006)
   SET rptsd->m_height = 0.180
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = - (0.006)
   SET rptsd->m_height = 0.180
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.180
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.194)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.180
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.632)
   SET rptsd->m_width = 0.868
   SET rptsd->m_height = 0.180
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.507)
   SET rptsd->m_width = 0.368
   SET rptsd->m_height = 0.180
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.882)
   SET rptsd->m_width = 0.368
   SET rptsd->m_height = 0.180
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.257)
   SET rptsd->m_width = 0.680
   SET rptsd->m_height = 0.180
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.944)
   SET rptsd->m_width = 0.556
   SET rptsd->m_height = 0.180
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.187),offsety,(offsetx+ 1.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.625),offsety,(offsetx+ 1.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.062),offsety,(offsetx+ 2.062),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.583),offsety,(offsetx+ 2.583),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.187),offsety,(offsetx+ 3.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.187),offsety,(offsetx+ 4.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.625),offsety,(offsetx+ 4.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.500),offsety,(offsetx+ 5.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.875),offsety,(offsetx+ 5.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.250),offsety,(offsetx+ 6.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.937),offsety,(offsetx+ 6.937),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow42(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow42abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow42abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.208333), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.180
   SET rptsd->m_height = 0.201
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Donor#",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.194)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.632)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.069)
   SET rptsd->m_width = 0.514
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.590)
   SET rptsd->m_width = 0.597
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.194)
   SET rptsd->m_width = 0.555
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = - (0.006)
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = - (0.006)
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.194)
   SET rptsd->m_width = 0.430
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.632)
   SET rptsd->m_width = 0.868
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.507)
   SET rptsd->m_width = 0.368
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.882)
   SET rptsd->m_width = 0.368
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.257)
   SET rptsd->m_width = 0.680
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.944)
   SET rptsd->m_width = 0.556
   SET rptsd->m_height = 0.201
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.187),offsety,(offsetx+ 1.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.625),offsety,(offsetx+ 1.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.062),offsety,(offsetx+ 2.062),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.583),offsety,(offsetx+ 2.583),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.187),offsety,(offsetx+ 3.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.187),offsety,(offsetx+ 4.187),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.625),offsety,(offsetx+ 4.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.500),offsety,(offsetx+ 5.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.875),offsety,(offsetx+ 5.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.250),offsety,(offsetx+ 6.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.937),offsety,(offsetx+ 6.937),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow43(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow43abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow43abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.406250), private
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.257)
   SET rptsd->m_width = 2.229
   SET rptsd->m_height = 0.399
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("DAT Breakdown Test",char(0)))
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.493)
   SET rptsd->m_width = 1.007
   SET rptsd->m_height = 0.399
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Complement Conrtrol",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),offsety,(offsetx+ 4.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.486),offsety,(offsetx+ 6.486),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow44(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow44abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow44abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.257)
   SET rptsd->m_width = 0.607
   SET rptsd->m_height = 0.181
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.871)
   SET rptsd->m_width = 0.534
   SET rptsd->m_height = 0.181
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Poly",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.411)
   SET rptsd->m_width = 0.589
   SET rptsd->m_height = 0.181
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("IgG",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.007)
   SET rptsd->m_width = 0.479
   SET rptsd->m_height = 0.181
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("C3d",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.493)
   SET rptsd->m_width = 0.601
   SET rptsd->m_height = 0.181
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("CC",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 7.101)
   SET rptsd->m_width = 0.399
   SET rptsd->m_height = 0.181
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("SAL",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),offsety,(offsetx+ 4.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.864),offsety,(offsetx+ 4.864),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.404),offsety,(offsetx+ 5.404),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.000),offsety,(offsetx+ 6.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.486),offsety,(offsetx+ 6.486),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.094),offsety,(offsetx+ 7.094),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow45(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow45abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow45abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.197917), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.257)
   SET rptsd->m_width = 0.607
   SET rptsd->m_height = 0.191
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("PRE",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.871)
   SET rptsd->m_width = 0.534
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.411)
   SET rptsd->m_width = 0.589
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.007)
   SET rptsd->m_width = 0.479
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.493)
   SET rptsd->m_width = 0.601
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 7.101)
   SET rptsd->m_width = 0.399
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),offsety,(offsetx+ 4.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.864),offsety,(offsetx+ 4.864),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.404),offsety,(offsetx+ 5.404),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.000),offsety,(offsetx+ 6.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.486),offsety,(offsetx+ 6.486),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.094),offsety,(offsetx+ 7.094),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow46(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow46abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow46abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.197917), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.257)
   SET rptsd->m_width = 0.607
   SET rptsd->m_height = 0.191
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("POST",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.871)
   SET rptsd->m_width = 0.534
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.411)
   SET rptsd->m_width = 0.589
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.007)
   SET rptsd->m_width = 0.479
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.493)
   SET rptsd->m_width = 0.601
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 7.101)
   SET rptsd->m_width = 0.399
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),offsety,(offsetx+ 4.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.864),offsety,(offsetx+ 4.864),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.404),offsety,(offsetx+ 5.404),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.000),offsety,(offsetx+ 6.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.486),offsety,(offsetx+ 6.486),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.094),offsety,(offsetx+ 7.094),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow49(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow49abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow49abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.197917), private
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.257)
   SET rptsd->m_width = 3.243
   SET rptsd->m_height = 0.191
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Specimen Hemolysis",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),offsety,(offsetx+ 4.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow50(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow50abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow50abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.197917), private
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.257)
   SET rptsd->m_width = 1.555
   SET rptsd->m_height = 0.191
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("PRE-Trans Spec.",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.819)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("POST-Trans Spec.",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),offsety,(offsetx+ 4.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.812),offsety,(offsetx+ 5.812),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow47(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow47abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow47abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.218746), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.257)
   SET rptsd->m_width = 1.555
   SET rptsd->m_height = 0.212
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.819)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.212
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),offsety,(offsetx+ 4.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.812),offsety,(offsetx+ 5.812),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow51(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow51abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow51abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.270834), private
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 4.181
   SET rptsd->m_height = 0.264
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Crossmatch Test",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.188),offsety,(offsetx+ 4.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 4.188),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 4.188),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow48(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow48abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow48abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.218750), private
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 2.076
   SET rptsd->m_height = 0.212
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("PRE-Transfusion Specimen",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.090)
   SET rptsd->m_width = 2.097
   SET rptsd->m_height = 0.212
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("POST-Transfusion Specimen",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.083),offsety,(offsetx+ 2.083),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.188),offsety,(offsetx+ 4.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 4.188),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 4.188),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow52(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow52abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow52abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.197916), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 0.493
   SET rptsd->m_height = 0.191
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Donor#",char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.507)
   SET rptsd->m_width = 0.368
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("I.S.",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.882)
   SET rptsd->m_width = 0.493
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("AGT",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.382)
   SET rptsd->m_width = 0.556
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("INT",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.944)
   SET rptsd->m_width = 0.555
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("I.S.",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.507)
   SET rptsd->m_width = 0.618
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("AGT",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.132)
   SET rptsd->m_width = 0.618
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("INT",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = 0.431
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Tech",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.500),offsety,(offsetx+ 0.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.875),offsety,(offsetx+ 0.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),offsety,(offsetx+ 1.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.937),offsety,(offsetx+ 1.937),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.500),offsety,(offsetx+ 2.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.125),offsety,(offsetx+ 3.125),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.188),offsety,(offsetx+ 4.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 4.188),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 4.188),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow53(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow53abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow53abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 0.493
   SET rptsd->m_height = 0.181
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.507)
   SET rptsd->m_width = 0.368
   SET rptsd->m_height = 0.181
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.882)
   SET rptsd->m_width = 0.493
   SET rptsd->m_height = 0.181
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.382)
   SET rptsd->m_width = 0.556
   SET rptsd->m_height = 0.181
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.944)
   SET rptsd->m_width = 0.555
   SET rptsd->m_height = 0.181
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.507)
   SET rptsd->m_width = 0.618
   SET rptsd->m_height = 0.181
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.132)
   SET rptsd->m_width = 0.618
   SET rptsd->m_height = 0.181
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = 0.431
   SET rptsd->m_height = 0.181
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.500),offsety,(offsetx+ 0.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.875),offsety,(offsetx+ 0.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),offsety,(offsetx+ 1.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.937),offsety,(offsetx+ 1.937),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.500),offsety,(offsetx+ 2.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.125),offsety,(offsetx+ 3.125),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.188),offsety,(offsetx+ 4.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 4.188),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 4.188),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow54(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow54abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow54abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.197916), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 0.493
   SET rptsd->m_height = 0.191
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.507)
   SET rptsd->m_width = 0.368
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.882)
   SET rptsd->m_width = 0.493
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.382)
   SET rptsd->m_width = 0.556
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.944)
   SET rptsd->m_width = 0.555
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.507)
   SET rptsd->m_width = 0.618
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.132)
   SET rptsd->m_width = 0.618
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = 0.431
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.500),offsety,(offsetx+ 0.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.875),offsety,(offsetx+ 0.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),offsety,(offsetx+ 1.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.937),offsety,(offsetx+ 1.937),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.500),offsety,(offsetx+ 2.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.125),offsety,(offsetx+ 3.125),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.188),offsety,(offsetx+ 4.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 4.188),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 4.188),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow55(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow55abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow55abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.197916), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 0.493
   SET rptsd->m_height = 0.191
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.507)
   SET rptsd->m_width = 0.368
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.882)
   SET rptsd->m_width = 0.493
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.382)
   SET rptsd->m_width = 0.556
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.944)
   SET rptsd->m_width = 0.555
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.507)
   SET rptsd->m_width = 0.618
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.132)
   SET rptsd->m_width = 0.618
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = 0.431
   SET rptsd->m_height = 0.191
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.500),offsety,(offsetx+ 0.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.875),offsety,(offsetx+ 0.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),offsety,(offsetx+ 1.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.937),offsety,(offsetx+ 1.937),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.500),offsety,(offsetx+ 2.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.125),offsety,(offsetx+ 3.125),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.188),offsety,(offsetx+ 4.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 4.188),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 4.188),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow56(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow56abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow56abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.229168), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 0.493
   SET rptsd->m_height = 0.222
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.507)
   SET rptsd->m_width = 0.368
   SET rptsd->m_height = 0.222
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.882)
   SET rptsd->m_width = 0.493
   SET rptsd->m_height = 0.222
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.382)
   SET rptsd->m_width = 0.556
   SET rptsd->m_height = 0.222
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.944)
   SET rptsd->m_width = 0.555
   SET rptsd->m_height = 0.222
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.507)
   SET rptsd->m_width = 0.618
   SET rptsd->m_height = 0.222
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.132)
   SET rptsd->m_width = 0.618
   SET rptsd->m_height = 0.222
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.757)
   SET rptsd->m_width = 0.431
   SET rptsd->m_height = 0.222
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.500),offsety,(offsetx+ 0.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.875),offsety,(offsetx+ 0.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),offsety,(offsetx+ 1.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.937),offsety,(offsetx+ 1.937),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.500),offsety,(offsetx+ 2.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.125),offsety,(offsetx+ 3.125),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.188),offsety,(offsetx+ 4.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 4.188),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 4.188),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (staticsectoin04abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(6.310000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _yoffset = (offsety+ 0.188)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.188)
     SET holdheight = 0
     SET holdheight += tablerow11(rpt_render)
     SET holdheight += tablerow12(rpt_render)
     SET holdheight += tablerow15(rpt_render)
     SET holdheight += tablerow16(rpt_render)
     SET holdheight += tablerow17(rpt_render)
     SET holdheight += tablerow18(rpt_render)
     SET _yoffset = offsety
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.646
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Blood Product Information:",char(0)))
    SET rptsd->m_y = (offsety+ 1.938)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.510
    SET rptsd->m_height = 0.552
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "Clerical Check: _________________________________________________________________________________________    ",
       _crlf,
       "Assessment of Infusion Practice: ___________________________________________________________________________",
       _crlf,
       "Conclusion of Serological Investigation: ______________________________________________________________________"
       ),char(0)))
    SET rptsd->m_flags = 260
    SET rptsd->m_y = (offsety+ 2.563)
    SET rptsd->m_x = (offsetx+ - (0.010))
    SET rptsd->m_width = 3.135
    SET rptsd->m_height = 0.219
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Laboratory Investigation:",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.688)
    SET rptsd->m_x = (offsetx+ - (0.010))
    SET rptsd->m_width = 3.760
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Summary of Diagnostic Investigation:",
      char(0)))
    SET _yoffset = (offsety+ 2.750)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 2.750)
     SET holdheight = 0
     SET holdheight += tablerow19(rpt_render)
     SET holdheight += tablerow20(rpt_render)
     SET holdheight += tablerow21(rpt_render)
     SET holdheight += tablerow22(rpt_render)
     SET holdheight += tablerow24(rpt_render)
     SET holdheight += tablerow40(rpt_render)
     SET holdheight += tablerow41(rpt_render)
     SET holdheight += tablerow42(rpt_render)
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ 4.688)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 4.688)
     SET holdheight = 0
     SET holdheight += tablerow43(rpt_render)
     SET holdheight += tablerow44(rpt_render)
     SET holdheight += tablerow45(rpt_render)
     SET holdheight += tablerow46(rpt_render)
     SET holdheight += tablerow49(rpt_render)
     SET holdheight += tablerow50(rpt_render)
     SET holdheight += tablerow47(rpt_render)
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ 4.688)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 4.688)
     SET holdheight = 0
     SET holdheight += tablerow51(rpt_render)
     SET holdheight += tablerow48(rpt_render)
     SET holdheight += tablerow52(rpt_render)
     SET holdheight += tablerow53(rpt_render)
     SET holdheight += tablerow54(rpt_render)
     SET holdheight += tablerow55(rpt_render)
     SET holdheight += tablerow56(rpt_render)
     SET _yoffset = offsety
    ENDIF
    SET _dummypen = uar_rptsetpen(_hreport,_pen28s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 2.568),(offsetx+ 7.500),(offsety+
     2.568))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 1.630),(offsetx+ 7.500),(offsety+
     1.630))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (layoutsection1(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = layoutsection1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (layoutsection1abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(2.590000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 1.875)
    SET rptsd->m_x = (offsetx+ 2.375)
    SET rptsd->m_width = 4.125
    SET rptsd->m_height = 0.188
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "___________________________________ Date/Time: ____________",char(0)))
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 1.625)
    SET rptsd->m_width = 6.375
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "____________________________________________________________________________________",char(0))
     )
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 1.188)
    SET rptsd->m_width = 5.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      " Instruction entered: _________ Yes ___________   NA     TRX entered: ______ Yes ______NA",
      char(0)))
    SET rptsd->m_y = (offsety+ 1.063)
    SET rptsd->m_x = (offsetx+ 1.938)
    SET rptsd->m_width = 3.563
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      " Discarded in computer? ____________Yes    _________ NA ",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Suspected Bacterial Contamination:",
      char(0)))
    SET rptsd->m_y = (offsety+ 2.188)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.479
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "BRL:  Yes _____   No _____ Charges: _______________________________________________________________    "
       ),char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen28s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.495),(offsetx+ 7.500),(offsety+
     0.495))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.208
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Additional Tests/Comments:",char(0)))
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.094
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Remaining Aliquots/Products:  Placed on Quarantine Shelf? _________ Yes   __________NA",char(0
       )))
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 5.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Bags sent to Microbiology: _________ Yes       ___________ No     ____________ NA",char(0)))
    SET rptsd->m_y = (offsety+ 1.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.813
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Remaining Aliquots/Products:",char(0)
      ))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 2.125)
    SET rptsd->m_width = 3.188
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      " _________ Yes (complete below)      ___________ No",char(0)))
    SET rptsd->m_y = (offsety+ 1.688)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.094
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Implicated unit(s) Transfused with reaction in computer: _______ Yes _______ NA   Tech: ______ Date:_______",
      char(0)))
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Computer Entries:",char(0)))
    SET rptsd->m_flags = 1028
    SET rptsd->m_y = (offsety+ 1.875)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "TMS Medical Staff Notified (if indicated): ",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen28s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 2.120),(offsetx+ 7.490),(offsety+
     2.120))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 2.375)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Reviewed by: ___________________________________________ Date: ___________________________________",
      char(0)))
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ - (0.010))
    SET rptsd->m_width = 5.885
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Patients Post Plasma Sample Frozen: __________ Yes   ___________ No    _______________ NA",
      char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.875
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "___________________________________________________________________________________________________________",
      char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footsec(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footsecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footsecabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.250
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_RPT_TRANS_REQ"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 20
   SET rptfont->m_bold = rpt_off
   SET _times200 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_on
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_off
   SET _times80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET _times8b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_underline = rpt_on
   SET _times8bu0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.005
   SET rptpen->m_penstyle = 2
   SET _pen5s2c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.000
   SET rptpen->m_penstyle = 0
   SET _pen0s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.002
   SET rptpen->m_penstyle = 1
   SET _pen2s1c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.001
   SET rptpen->m_penstyle = 3
   SET _pen1s3c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.007
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_gray
   SET _pen7s0c8421504 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET _pen14s0c8421504 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.028
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen28s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET cur_page = 1
 SET d0 = initializereport(0)
 SET d0 = headsec(rpt_render)
 SET d0 = linesec(rpt_render)
 SET d0 = patientsec(rpt_render)
 SET d0 = linesec(rpt_render)
 SET d0 = admitdxsec(rpt_render,8.5,becont)
 IF (((_yoffset+ problemsec(rpt_calcheight,8.5,becont)) > 10))
  SET d0 = pgbreak(1)
 ENDIF
 SET d0 = linesec(rpt_render)
 SET d0 = problemsec(rpt_render,8.5,becont)
 IF (((_yoffset+ formssec(rpt_calcheight,8.5,becont)) > 10))
  SET d0 = pgbreak(1)
 ENDIF
 SET d0 = linesec(rpt_render)
 SET d0 = formssec(rpt_render,8.5,becont)
 IF (((_yoffset+ labssec(rpt_calcheight,8.5,becont)) > 10))
  SET d0 = pgbreak(1)
 ENDIF
 SET d0 = linesec(rpt_render)
 SET d0 = labssec(rpt_render,8.5,becont)
 IF (((_yoffset+ reactioninfosec(rpt_calcheight,8.5,becont)) > 10))
  SET d0 = pgbreak(1)
 ENDIF
 SET d0 = linesec(rpt_render)
 SET d0 = reactioninfosec(rpt_render,8.5,becont)
 IF ((((_yoffset+ medssec(rpt_calcheight,8.5,becont))+ o2sec(rpt_calcheight,8.5,becont)) > 10))
  SET d0 = pgbreak(1)
 ENDIF
 SET d0 = linesec(rpt_render)
 SET d0 = medssec(rpt_render,8.5,becont)
 SET d0 = linesec(rpt_render)
 SET d0 = o2sec(rpt_render,8.5,becont)
 IF (((_yoffset+ vitalssec(rpt_calcheight,8.5,becont)) > 10.6))
  SET d0 = pgbreak(1)
 ENDIF
 IF ((info->bloodproducttransfused > " "))
  SET info->amountinfused = concat(trim(info->bloodproducttransfused,3)," Volume Transfused: ",info->
   amountinfused)
 ENDIF
 SET d0 = linesec(rpt_render)
 SET d0 = vitalssec(rpt_render,8.5,becont)
 IF (((_yoffset+ staticsec3(rpt_calcheight)) > 10.5))
  SET d0 = pgbreak(1)
 ENDIF
 SET d0 = linesec(rpt_render)
 SET d0 = staticsec3(rpt_render)
 SET d0 = pgbreak(1)
 SET d0 = staticsectoin04(rpt_render)
 SET d0 = layoutsection1(rpt_render)
 SET d0 = linesec(rpt_render)
 SET d0 = footsec(rpt_render)
 SET d0 = finalizereport(value(outputdev))
 SUBROUTINE pgbreak(dummy)
   CALL echo("Page break")
   SET d0 = linesec(rpt_render)
   SET cur_page += 1
   SET d0 = footsec(rpt_render)
   SET d0 = pagebreak(dummy)
   SET d0 = headsec(rpt_render)
 END ;Subroutine
 SUBROUTINE uar_get_code_by(type,codeset,val)
   SET codeval = 0.0
   SET codeval = uar_get_code_by(value(type),codeset,value(val))
   IF (codeval <= 0)
    SET errmsg = concat("failed finding code_val - type: ",type," codeset:",build(codeset)," val:",
     val)
    GO TO exit_program
   ELSE
    CALL echo(concat("type: ",type," codeset:",build(codeset)," val:",
      val," Code_value=",cnvtstring(codeval)))
   ENDIF
   RETURN(codeval)
 END ;Subroutine
 CALL echo(build("TIME:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(times),5)))
 SET times = cnvtdatetime(sysdate)
#exit_program
 CALL echo(build("TotalTIME:",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(timet),5)))
 IF (textlen(trim(errmsg,3)) > 0)
  CALL echo(errmsg)
  SELECT INTO value(outputdev)
   FROM dummyt
   HEAD REPORT
    msg1 = errmsg, col 0, "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/12}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08, mine, time = 5
  ;end select
  SET log_message = errmsg
  IF (validate(reqinfo->updt_id) > 0
   AND (reqinfo->updt_id > 0))
   SET euser = build(reqinfo->updt_id)
  ELSE
   SET euser = curuser
  ENDIF
  SET esubject = concat(trim(curnode,3)," - ",trim(curprog,3),"- userID:",trim(euser,3),
   " - Code Value error")
  CALL uar_send_mail("core.cis@bhs.org",esubject,errmsg,"discernCCL@bhs.org",5,
   "IPM.NOTE")
  SET log_message = build("ERROR:",errmsg,"_printer:", $OUTDEV," For patient Encntr: ",
   encntr_id," clin Event: ",link_clineventid," FORM eventId: ",formeventid)
 ELSE
  SET log_message = build("Req printed to:",outputdev," For patient Encntr: ",encntr_id,
   " clin Event: ",
   link_clineventid," FORM eventId: ",formeventid)
  SET retval = 100
 ENDIF
 CALL echorecord(info)
END GO

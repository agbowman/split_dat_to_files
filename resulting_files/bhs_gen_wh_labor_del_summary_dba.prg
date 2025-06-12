CREATE PROGRAM bhs_gen_wh_labor_del_summary:dba
 DECLARE nv_cnt = i4 WITH protect, noconstant(0)
 SET nv_cnt = request->nv_cnt
 DECLARE stand_alone_ind = i4 WITH protect, noconstant(0)
 IF (nv_cnt=0)
  SET stand_alone_ind = 1
 ENDIF
 IF (validate(preg_summary_flag)=0)
  SET stand_alone_ind = 1
  IF (validate(i18nuar_def,999)=999)
   CALL echo("declaring i18nuar_def")
   DECLARE i18nuar_def = i2 WITH persist
   SET i18nuar_def = 1
   DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
   DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
   DECLARE uar_i18nbuildmessage() = vc WITH persist
   DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
   c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
   "uar_i18nGetHijriDate",
   persist
   DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
    stitle=vc(ref),
    sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
   "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
   persist
   DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
   "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
   persist
  ENDIF
  IF ( NOT (validate(i18nhandle)))
   DECLARE i18nhandle = i4 WITH protect, noconstant(0)
  ENDIF
  SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
  SET reply->text = concat(reply->text,rhead)
 ELSE
  SET stand_alone_ind = 0
 ENDIF
 DECLARE whorgsecpref = i2 WITH protect, noconstant(0)
 DECLARE prsnl_override_flag = i2 WITH protect, noconstant(0)
 DECLARE preg_org_sec_ind = i4 WITH noconstant(0), public
 DECLARE os_idx = i4 WITH noconstant(0)
 IF (validate(antepartum_run_ind)=0)
  DECLARE antepartum_run_ind = i4 WITH public, noconstant(0)
 ENDIF
 IF ( NOT (validate(whsecuritydisclaim)))
  DECLARE whsecuritydisclaim = vc WITH public, constant(uar_i18ngetmessage(i18nhandle,"cap99",
    "(Report contains only data from encounters at associated organizations)"))
 ENDIF
 IF ( NOT (validate(preg_sec_orgs)))
  FREE RECORD preg_sec_orgs
  RECORD preg_sec_orgs(
    1 qual[*]
      2 org_id = f8
      2 confid_level = i4
  )
 ENDIF
 DECLARE getpreferences() = i2 WITH protect
 DECLARE getorgsecurity() = null WITH protect
 DECLARE loadorganizationsecuritylist() = null
 IF (validate(honor_org_security_flag)=0)
  DECLARE honor_org_security_flag = i2 WITH public, noconstant(0)
  SET whorgsecpref = getpreferences(null)
  CALL getorgsecurity(null)
  SET prsnl_override_flag = getpersonneloverride(request->person[1].person_id,reqinfo->updt_id)
  IF (prsnl_override_flag=0)
   IF (preg_org_sec_ind=1
    AND whorgsecpref=1)
    SET honor_org_security_flag = 1
   ENDIF
  ENDIF
 ENDIF
 IF ( NOT (validate(rhead,0)))
  SET rhead = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}"
  SET rhead_colors1 = "{\colortbl;\red0\green0\blue0;\red255\green255\blue255;"
  SET rhead_colors2 = "\red99\green99\blue99;\red22\green107\blue178;"
  SET rhead_colors3 = "\red0\green0\blue255;\red123\green193\blue67;\red255\green0\blue0;}"
  SET reol = "\par "
  SET rtab = "\tab "
  SET wr = "\plain \f0 \fs16 \cb2 "
  SET wr11 = "\plain \f0 \fs11 \cb2 "
  SET wr18 = "\plain \f0 \fs18 \cb2 "
  SET wr20 = "\plain \f0 \fs20 \cb2 "
  SET wu = "\plain \f0 \fs16 \ul \cb2 "
  SET wb = "\plain \f0 \fs16 \b \cb2 "
  SET wbu = "\plain \f0 \fs16 \b \ul \cb2 "
  SET wi = "\plain \f0 \fs16 \i \cb2 "
  SET ws = "\plain \f0 \fs16 \strike \cb2"
  SET wb2 = "\plain \f0 \fs18 \b \cb2 "
  SET wb18 = "\plain \f0 \fs18 \b \cb2 "
  SET wb20 = "\plain \f0 \fs20 \b \cb2 "
  SET rsechead = "\plain \f0 \fs28 \b \ul \cb2 "
  SET rsubsechead = "\plain \f0 \fs22 \b \cb2 "
  SET rsecline = "\plain \f0 \fs20 \b \cb2 "
  SET hi = "\pard\fi-2340\li2340 "
  SET rtfeof = "}"
  SET wbuf26 = "\plain \f0 \fs26 \b \ul \cb2 "
  SET wbuf30 = "\plain \f0 \fs30 \b \ul \cb2 "
  SET rpard = "\pard "
  SET rtitle = "\plain \f0 \fs36 \b \cb2 "
  SET rpatname = "\plain \f0 \fs38 \b \cb2 "
  SET rtabstop1 = "\tx300"
  SET rtabstopnd = "\tx400"
  SET wsd = "\plain \f0 \fs13 \cb2 "
  SET wsb = "\plain \f0 \fs13 \b \cb2 "
  SET wrs = "\plain \f0 \fs14 \cb2 "
  SET wbs = "\plain \f0 \fs14 \b \cb2 "
  DECLARE snot_documented = vc WITH public, constant("--")
  SET color0 = "\cf0 "
  SET colorgrey = "\cf3 "
  SET colornavy = "\cf4 "
  SET colorblue = "\cf5 "
  SET colorgreen = "\cf6 "
  SET colorred = "\cf7 "
  SET row_start = "\trowd"
  SET row_end = "\row"
  SET cell_start = "\intbl "
  SET cell_end = "\cell"
  SET cell_text_center = "\qc "
  SET cell_text_left = "\ql "
  SET cell_border_top = "\clbrdrt\brdrt\brdrw1"
  SET cell_border_left = "\clbrdrl\brdrl\brdrw1"
  SET cell_border_bottom = "\clbrdrb\brdrb\brdrw1"
  SET cell_border_right = "\clbrdrr\brdrr\brdrw1"
  SET cell_border_top_left = "\clbrdrt\brdrt\brdrw1\clbrdrl\brdrl\brdrw1"
  SET block_start = "{"
  SET block_end = "}"
 ENDIF
 FREE RECORD ld_request
 RECORD ld_request(
   1 person_cnt = i2
   1 person[1]
     2 person_id = f8
     2 person_name = vc
     2 person_dob = vc
     2 pregnancy_list[*]
       3 pregnancy_id = f8
       3 onset_dt_tm = dq8
       3 onset_date_formatted = vc
       3 problem_id = f8
   1 visit_cnt = i2
   1 visit[1]
     2 encntr_id = f8
   1 prsnl_cnt = i2
 )
 SET ld_request->person[1].person_id = request->person[1].person_id
 DECLARE ev1_cnt = i4 WITH protect, noconstant(0)
 DECLARE ev2_cnt = i4 WITH protect, noconstant(0)
 DECLARE ev3_cnt = i4 WITH protect, noconstant(0)
 DECLARE ev4_cnt = i4 WITH protect, noconstant(0)
 DECLARE ev5_cnt = i4 WITH protect, noconstant(0)
 DECLARE ev6_cnt = i4 WITH protect, noconstant(0)
 DECLARE ev7_cnt = i4 WITH protect, noconstant(0)
 DECLARE bereave_ind = i4 WITH protect, noconstant(0)
 DECLARE bereave_event_id = f8 WITH protect, noconstant(0.0)
 DECLARE event_seq = i4 WITH protect, noconstant(0)
 DECLARE dhrs = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2743"))
 DECLARE dmin = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2742"))
 DECLARE auth = f8 WITH public, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE altered = f8 WITH public, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE modified = f8 WITH public, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE problemlistcaption = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sec1",
   "Problem List"))
 DECLARE membranestatuscaption = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sec2",
   "Membrane Status Information"))
 DECLARE laborinfocaption = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sec3",
   "Labor Information"))
 DECLARE fetalmonitorcaption = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sec4",
   "Fetal Monitoring"))
 DECLARE deliveryinfocaption = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sec5",
   "Delivery Information"))
 DECLARE neonatalinfocaption = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sec6",
   "Neonatal Information"))
 DECLARE infantdatacaption = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sec7",
   "Infant Data"))
 DECLARE fetalneonatalcaption = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sec8",
   "Fetal Neonatal Bereavement"))
 DECLARE mf_anesthesiaob_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",72,
   "ANESTHESIAOB"))
 FREE RECORD rtf
 RECORD rtf(
   1 mother[1]
     2 section[2]
       3 section_name = vc
       3 event[*]
         4 event_label = vc
         4 result_val = vc
         4 event_cd = f8
       3 baby[*]
         4 label_id = f8
         4 seq_nbr = f8
         4 label_name = vc
         4 event[*]
           5 event_label = vc
           5 result_val = vc
           5 event_cd = f8
   1 baby[*]
     2 label_id = f8
     2 seq_nbr = f8
     2 label_name = vc
     2 section[5]
       3 section_name = vc
       3 event[*]
         4 event_label = vc
         4 result_val = vc
         4 event_cd = f8
 )
 FREE RECORD ce
 RECORD ce(
   1 rec[*]
     2 event_cd = f8
   1 cnt = i4
 )
 FREE RECORD concept_cki
 RECORD concept_cki(
   1 rec[99]
     2 concept_cki = vc
     2 display = vc
     2 f_code_value = f8
 )
 FREE RECORD allresult
 RECORD allresult(
   1 rec[*]
     2 label_name = c100
     2 concept_cki = vc
     2 cki = vc
     2 result_val = vc
     2 units_flag = i4
     2 display = vc
     2 f_event_cd = f8
 )
 DECLARE geteventcodes(null) = null WITH protect
 DECLARE loaddata(null) = null WITH protect
 DECLARE checkbereavement(null) = null WITH protect
 DECLARE loadsectionnames(null) = null WITH protect
 DECLARE loadlabeldisplay(null) = null WITH protect
 DECLARE l_cki_cnt = i4 WITH protect, noconstant(0)
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Delivery Type:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY",72,"Delivery Type:")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "VBAC:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"VBAC")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Reason for C-Section:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"REASONFORCSECTION")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "C-Section Priority:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"CSECTIONPRIORITY")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Decision for C-Section:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "DECISIONFORCSECTION")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Incision Time for C-Section:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "INCISIONTIMEFORCSECTION")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Decision to Incision time:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "DECISIONTOINCISIONTIME")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Date, Time of birth:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY",72,"Date, Time of Birth:")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Birth Position:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"BIRTHPOSITION")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Foot of bed removed:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"FOOTOFBEDREMOVED")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Anesthesia OB:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"ANESTHESIAOB")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Delayed Cord Clamping:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "DELAYEDCORDCLAMPING")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Reason for No Delayed Cord Clamping:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "REASONFORNODELAYEDCORDCLAMPING")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Placenta Delivery Date/Time:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "PLACENTADELIVERYDATETIME")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Placenta Delivery Method:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "PLACENTADELIVERYMETHOD")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Placenta Appearance:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"PLACENTAAPPEARANCE"
  )
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Placenta to Pathology:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "PLACENTATOPATHOLOGY")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Attending Provider:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"ATTENDINGPROVIDER")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Delivery Physician:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"DELIVERYPHYSICIAN")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Delivery CNM:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"DELIVERYCNM")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Assistant Provider #1:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"ASSISTANTPROVIDER1"
  )
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Assistant Provider #2:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"ASSISTANTPROVIDER2"
  )
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Delivery RN #1:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"DELIVERYRN1")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Delivery RN #2:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"DELIVERYRN2")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Anesthesiology Resident:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "ANESTHESIOLOGISTRESIDENT")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Anesthesiology Attending:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "ANESTHESIOLOGISTATTENDING")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Other Delivery Clinicians:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "OTHERDELIVERYCLINICIANS")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Pediatrician:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY",72,"Pediatrician:")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "NICU Team Called:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"NICUTEAMCALLED")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Time NICU Team Called:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"TIMENICUTEAMCALLED"
  )
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "ROM Date, Time:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"ROMDATETIME")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "ROM to Delivery Total Time:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "ROMTODELIVERYTOTALTIME")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "2nd Stage, Length of Labor:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "2NDSTAGELENGTHOFLABOR")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "3rd Stage, Length of Labor:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "3RDSTAGELENGTHOFLABOR")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Fetal monitoring:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"MONITORINGMETHOD")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Neonate Outcome:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"NEONATEOUTCOME")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Fetal Position:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY",72,"Fetal Position:")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Birth Weight:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY",72,"Birth Weight:")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Apgar Score 1 minute:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"APGARSCORE1MINUTE")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Apgar Score 5 minute:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"APGARSCORE5MINUTE")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Apgar Score 10 minute:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"APGARSCORE10MINUTE"
  )
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Transferred To:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY",72,"Transferred To:")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Umbilical Cord Description:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY",72,
  "Umbilical Cord Description:")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Nuchal cord times:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"NUCHALCORDTIMES")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Nuchal cord tension:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"NUCHALCORDTENSION")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Nuchal cord Intervention:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "NUCHALCORDINTERVENTION")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Cord Blood pH drawn:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"CORDBLOODPHDRAWN")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Cord blood sent to lab:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"CORDBLOODSENTTOLAB"
  )
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Cord blood banking:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"CORDBLOODBANKING")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Fetal Complications:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY",72,"Fetal Complications:")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Birth Complications:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY",72,"Birth Complications:")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Shoulder dystocia interventions:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "SHOULDERDYSTOCIAINTERVENTIONS")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Anterior Shoulder:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"ANTERIORSHOULDER")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Head to Body Time, Shoulder Dystocia:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "HEADTOBODYTIMESHOULDERDYSTOCIA")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Gender:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY",72,"Gender:")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Operative delivery:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"OPERATIVEDELIVERY")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Reasons for operative delivery:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "REASONFOROPERATIVEDELIVERY")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Vacuum type:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"VACUUMTYPE")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Number of contractions vacuum used:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "NUMBEROFCONTRACTIONSVACUUMUSED")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Number of vacuum detachments:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "NUMBEROFVACUUMDETACHMENTS")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Fetal position at vacuum application:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "FETALPOSITIONATVACUUMAPPLICATION")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Fetal station at vacuum application:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "FETALSTATIONATVACUUMAPPLICATION")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Vacuum consent obtained:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "VACUUMCONSENTOBTAINED")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Forceps type:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"FORCEPSTYPE")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Number of contractions forceps used:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "NUMBEROFCONTRACTIONSFORCEPSUSED")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Fetal position at forceps application:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "FETALPOSITIONATFORCEPSAPPLICATION")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Fetal station at forceps application:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "FETALSTATIONATFORCEPSAPPLICATION")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Forceps consent obtained:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "FORCEPSCONSENTOBTAINED")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Labor Onset, Date/Time:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY",72,"Labor Onset, Date/Time"
  )
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "1st Stage, Length of Labor:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "1STSTAGELENGTHOFLABOR")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Labor Onset Methods:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"LABORONSETMETHODS")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Induction Methods:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"INDUCTIONMETHODS")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Augmentation Methods:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "AUGMENTATIONMETHODS")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Gestational Age at Delivery:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "EGAATDOCUMENTEDDATETIME")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Anesthesia OB:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"ANESTHESIAOB")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Estimated Blood Loss:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"ESTIMATEDBLOODLOSS"
  )
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Obstetrical Laceration:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "OBSTETRICALLACERATION")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Perineal Laceration:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"PERINEALLACERATION"
  )
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Perineal Laceration Repair:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "PERINEALLACERATIONREPAIR")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Vaginal Laceration:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"VAGINALLACERATION")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Vaginal Laceration Repair:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "VAGINALLACERATIONREPAIR")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Labial Laceration:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"LABIALLACERATION")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Labial Laceration Repair:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "LABIALACERATIONREPAIR")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Periurethral Laceration:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "PERIURETHRALLACERATION")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Periurethral Laceration Repair:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "PERIURETHRALLACERATIONREPAIR")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Cervical Laceration:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"CERVICALLACERATION"
  )
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Cervical Laceration Repair:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "CERVICALLACERATIONREPAIR")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Laceration/Episiotomy:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "LACERATIONEPISIOTOMY")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Type of Laceration:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"TYPEOFLACERATION")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Location of Laceration:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "LOCATIONOFLACERATION")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Degree of Laceration:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY",72,"Degree of Laceration:")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Laceration Repair:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"LACERATIONREPAIR")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Type of Episiotomy:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"TYPEOFEPISIOTOMY")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Episiotomy Repair:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"EPISIOTOMYREPAIR")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Episiotomy Performed:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "EPISIOTOMYPERFORMED")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Anesthesia for Repair:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "ANESTHESIAFORREPAIR")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Delivery Complications:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "DELIVERYCOMPLICATIONS")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Blood Loss(ml):"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,"BLOODLOSS")
 SET l_cki_cnt += 1
 SET concept_cki->rec[l_cki_cnt].display = "Blood Loss - Quantitative:"
 SET concept_cki->rec[l_cki_cnt].f_code_value = uar_get_code_by("DISPLAY_KEY",72,
  "BLOODLOSSQUANTITATIVE")
 DECLARE female_cd_57 = f8 WITH public, constant(uar_get_code_by("MEANING",57,"FEMALE"))
 DECLARE valid_gender = i2
 DECLARE boldline = vc WITH public, constant(fillstring(140,"-"))
 DECLARE print_section_header = i2
 DECLARE modifiedcaption = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap124",
   " (Modified)"))
 DECLARE deliverycaption = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap125",
   "Delivery Summary"))
 DECLARE invalidgender = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap126",
   "    INVALID GENDER!"))
 DECLARE pregnotactivated = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap127",
   "  Pregnancy unable to be activated."))
 DECLARE noactivepreg = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap128",
   "    No active pregnancy found."))
 DECLARE captions_genview_title = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap129",
   "Labor and Delivery Summary"))
 DECLARE nodatacaption = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap130",
   "No labor/delivery information has been documented"))
 SELECT INTO "nl:"
  pat_gender = uar_get_code_display(p.sex_cd), p.sex_cd
  FROM person p
  PLAN (p
   WHERE (p.person_id=ld_request->person[1].person_id))
  HEAD REPORT
   IF (p.sex_cd=female_cd_57)
    valid_gender = 1
   ELSEIF (p.sex_cd != female_cd_57)
    valid_gender = 0
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  temp_dt_tm =
  IF (pr.onset_dt_tm != null) pr.onset_dt_tm
  ELSE pr.beg_effective_dt_tm
  ENDIF
  FROM pregnancy_instance pi,
   problem pr,
   person p
  PLAN (pi
   WHERE (pi.person_id=ld_request->person[1].person_id)
    AND pi.active_ind=1
    AND pi.historical_ind=0
    AND pi.preg_end_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (pr
   WHERE pr.problem_id=pi.problem_id
    AND pr.active_ind=1)
   JOIN (p
   WHERE p.person_id=pi.person_id)
  ORDER BY temp_dt_tm DESC
  HEAD REPORT
   stat = alterlist(ld_request->pregnancy_list,1), ld_request->person[1].pregnancy_list[1].
   onset_date_formatted = format(temp_dt_tm,"YYYYMMDD;;d"), ld_request->person[1].pregnancy_list[1].
   onset_dt_tm = temp_dt_tm,
   ld_request->person[1].pregnancy_list[1].problem_id = pi.problem_id, ld_request->person[1].
   pregnancy_list[1].pregnancy_id = pi.pregnancy_id, ld_request->person[1].person_name = trim(
    substring(1,50,p.name_full_formatted)),
   ld_request->person[1].person_dob = format(p.birth_dt_tm,"MM/DD/YY;;d")
  WITH nocounter
 ;end select
 IF (validate(debug_ind,0)=1)
  CALL echorecord(ld_request)
 ENDIF
 IF (stand_alone_ind=1)
  IF (valid_gender=0
   AND curqual=0)
   SET reply->text = concat(reply->text,rhead,createmessagertf(concat(colorred,invalidgender,color0,
      pregnotactivated,color0)))
   GO TO exit_script
  ELSEIF (valid_gender=1
   AND curqual=0)
   SET reply->text = concat(reply->text,rhead,createmessagertf(concat(color0,noactivepreg)))
   GO TO exit_script
  ELSE
   SET reply->text = concat(reply->text,rhead,rhead_colors1,rhead_colors2,rhead_colors3)
  ENDIF
 ELSE
  IF (valid_gender=0
   AND curqual=0)
   SET reply->text = concat(reply->text,createmessagertf(concat(colorred,invalidgender,color0,
      pregnotactivated,color0)))
   GO TO exit_script
  ELSEIF (valid_gender=1
   AND curqual=0)
   SET reply->text = concat(reply->text,createmessagertf(concat(color0,noactivepreg)))
   GO TO exit_script
  ELSE
   SET reply->text = concat(reply->text,rhead_colors1,rhead_colors2,rhead_colors3)
  ENDIF
 ENDIF
 IF (stand_alone_ind=1)
  IF (honor_org_security_flag=1)
   SET reply->text = concat(reply->text,reol,colorgrey,whsecuritydisclaim,wr,
    reol)
  ENDIF
 ENDIF
 CALL geteventcodes(null)
 IF ((ce->cnt=0))
  SET reply->text = concat(reply->text,rsechead,colornavy,deliverycaption,wr,
   reol,rpard,rtabstopnd,reol,rtab,
   nodatacaption,reol,reol)
  GO TO exit_script
 ENDIF
 CALL loaddata(null)
 IF (curqual=0)
  SET reply->text = concat(reply->text,rsechead,colornavy,deliverycaption,wr,
   reol,rpard,rtabstopnd,reol,rtab,
   nodatacaption,reol,reol)
  GO TO exit_script
 ENDIF
 CALL loadsectionnames(null)
 CALL loadlabeldisplay(null)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx3 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx4 = i4 WITH protect, noconstant(0)
 FOR (ml_idx1 = 1 TO size(concept_cki->rec,5))
   FOR (ml_idx2 = 1 TO size(rtf->baby,5))
     FOR (ml_idx3 = 1 TO size(allresult->rec,5))
       IF ((concept_cki->rec[ml_idx1].f_code_value=allresult->rec[ml_idx3].f_event_cd))
        FOR (ml_idx4 = 1 TO size(rtf->mother[1].section[1].event,5))
          IF ((rtf->mother[1].section[1].event[ml_idx4].event_cd=concept_cki->rec[ml_idx1].
          f_code_value))
           SET rtf->mother[1].section[1].event[ml_idx4].result_val = allresult->rec[ml_idx3].
           result_val
          ENDIF
        ENDFOR
        FOR (ml_idx4 = 1 TO size(rtf->mother[1].section[1].baby[ml_idx2].event,5))
          IF ((rtf->mother[1].section[1].baby[ml_idx2].event[ml_idx4].event_cd=concept_cki->rec[
          ml_idx1].f_code_value)
           AND (rtf->mother[1].section[1].baby[ml_idx2].label_name=allresult->rec[ml_idx3].label_name
          ))
           SET rtf->mother[1].section[1].baby[ml_idx2].event[ml_idx4].result_val = allresult->rec[
           ml_idx3].result_val
          ENDIF
        ENDFOR
        FOR (ml_idx4 = 1 TO size(rtf->mother[1].section[2].event,5))
          IF ((rtf->mother[1].section[2].event[ml_idx4].event_cd=concept_cki->rec[ml_idx1].
          f_code_value))
           SET rtf->mother[1].section[2].event[ml_idx4].result_val = allresult->rec[ml_idx3].
           result_val
          ENDIF
        ENDFOR
        IF ((rtf->baby[ml_idx2].label_name=allresult->rec[ml_idx3].label_name))
         FOR (ml_idx4 = 1 TO size(rtf->baby[ml_idx2].section[1].event,5))
           IF ((rtf->baby[ml_idx2].section[1].event[ml_idx4].event_cd=concept_cki->rec[ml_idx1].
           f_code_value))
            SET rtf->baby[ml_idx2].section[1].event[ml_idx4].result_val = allresult->rec[ml_idx3].
            result_val
           ENDIF
         ENDFOR
         FOR (ml_idx4 = 1 TO size(rtf->baby[ml_idx2].section[2].event,5))
           IF ((rtf->baby[ml_idx2].section[2].event[ml_idx4].event_cd=concept_cki->rec[ml_idx1].
           f_code_value))
            SET rtf->baby[ml_idx2].section[2].event[ml_idx4].result_val = allresult->rec[ml_idx3].
            result_val
           ENDIF
         ENDFOR
         FOR (ml_idx4 = 1 TO size(rtf->baby[ml_idx2].section[3].event,5))
           IF ((rtf->baby[ml_idx2].section[3].event[ml_idx4].event_cd=concept_cki->rec[ml_idx1].
           f_code_value))
            SET rtf->baby[ml_idx2].section[3].event[ml_idx4].result_val = allresult->rec[ml_idx3].
            result_val
           ENDIF
         ENDFOR
         FOR (ml_idx4 = 1 TO size(rtf->baby[ml_idx2].section[4].event,5))
           IF ((rtf->baby[ml_idx2].section[4].event[ml_idx4].event_cd=concept_cki->rec[ml_idx1].
           f_code_value))
            SET rtf->baby[ml_idx2].section[4].event[ml_idx4].result_val = allresult->rec[ml_idx3].
            result_val
           ENDIF
         ENDFOR
         FOR (ml_idx4 = 1 TO size(rtf->baby[ml_idx2].section[5].event,5))
           IF ((rtf->baby[ml_idx2].section[5].event[ml_idx4].event_cd=concept_cki->rec[ml_idx1].
           f_code_value))
            SET rtf->baby[ml_idx2].section[5].event[ml_idx4].result_val = allresult->rec[ml_idx3].
            result_val
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 SET reply->text = concat(reply->text,rsechead,colornavy,deliverycaption,wr,
  reol)
 SET reply->text = concat(reply->text,"\tx200\tx500\tx800\tx3000")
 SET reply->text = concat(reply->text,"\tx1000")
 SET reply->text = concat(reply->text,rsubsechead,colorgrey,"Maternal Information",wr,
  reol)
 DECLARE print_baby_label = i4 WITH protect, noconstant(0)
 FOR (section_idx = 1 TO size(rtf->mother[1].section,5))
   SET print_section_header = 1
   FOR (event_idx = 1 TO size(rtf->mother[1].section[section_idx].event,5))
     IF (size(trim(rtf->mother[1].section[section_idx].event[event_idx].result_val,3)) > 0)
      IF (print_section_header=1)
       SET reply->text = concat(reply->text,rtab,wu,rtf->mother[1].section[section_idx].section_name,
        wr,
        reol)
       SET print_section_header = 0
      ENDIF
      SET reply->text = concat(reply->text,rtab,rtab,wr,colorgrey,
       rtf->mother[1].section[section_idx].event[event_idx].event_label,"  ",wr,rtf->mother[1].
       section[section_idx].event[event_idx].result_val,reol)
     ENDIF
   ENDFOR
   FOR (baby_idx = 1 TO size(rtf->mother[1].section[section_idx].baby,5))
    SET print_baby_label = 1
    FOR (event_idx = 1 TO size(rtf->mother[1].section[section_idx].baby[baby_idx].event,5))
      IF (size(trim(rtf->mother[1].section[section_idx].baby[baby_idx].event[event_idx].result_val))
       > 0)
       IF (print_section_header=1)
        SET reply->text = concat(reply->text,rtab,wu,rtf->mother[1].section[section_idx].section_name,
         wr,
         reol)
        SET print_section_header = 0
       ENDIF
       IF (print_baby_label=1)
        SET reply->text = concat(reply->text,rtab,rtab,wu,rtf->mother[1].section[section_idx].baby[
         baby_idx].label_name,
         wr,reol)
        SET print_baby_label = 0
       ENDIF
       SET reply->text = concat(reply->text,rtab,rtab,rtab,wr,
        colorgrey,rtf->mother[1].section[section_idx].baby[baby_idx].event[event_idx].event_label,
        "  ",wr,rtf->mother[1].section[section_idx].baby[baby_idx].event[event_idx].result_val,
        reol)
      ENDIF
    ENDFOR
   ENDFOR
 ENDFOR
 SET reply->text = concat(reply->text,reol,reol)
 FOR (baby_idx = 1 TO size(rtf->baby,5))
   SET reply->text = concat(reply->text,rsubsechead,colorgrey,rtf->baby[baby_idx].label_name,wr,
    reol)
   FOR (section_idx = 1 TO size(rtf->baby[baby_idx].section,5))
    SET print_section_header = 1
    FOR (event_idx = 1 TO size(rtf->baby[baby_idx].section[section_idx].event,5))
      IF (trim(rtf->baby[baby_idx].section[section_idx].event[event_idx].result_val) != "")
       IF (print_section_header)
        SET reply->text = concat(reply->text,rtab,wu,trim(rtf->baby[baby_idx].section[section_idx].
          section_name),wr,
         reol)
        SET print_section_header = 0
       ENDIF
       SET reply->text = concat(reply->text,rtab,rtab,wr,colorgrey,
        rtf->baby[baby_idx].section[section_idx].event[event_idx].event_label,"  ",wr,rtf->baby[
        baby_idx].section[section_idx].event[event_idx].result_val,reol)
      ENDIF
    ENDFOR
   ENDFOR
   SET reply->text = concat(reply->text,reol,reol)
 ENDFOR
 IF (stand_alone_ind=0)
  IF (honor_org_security_flag=1)
   SET reply->text = concat(reply->text,reol,colorred,whsecuritydisclaim,wr,
    reol)
  ENDIF
 ENDIF
 SUBROUTINE (getpersonneloverride(person_id=f8(val),prsnl_id=f8(val)) =i2 WITH protect)
   CALL echo(build("person_id=",person_id))
   CALL echo(build("prsnl_id=",prsnl_id))
   DECLARE override_ind = i2 WITH protect, noconstant(0)
   IF (((person_id <= 0.0) OR (prsnl_id <= 0.0)) )
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM person_prsnl_reltn ppr,
     code_value_extension cve
    PLAN (ppr
     WHERE ppr.prsnl_person_id=prsnl_id
      AND ppr.active_ind=1
      AND ((ppr.person_id+ 0)=person_id)
      AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (cve
     WHERE cve.code_value=ppr.person_prsnl_r_cd
      AND cve.code_set=331
      AND ((cve.field_value="1") OR (cve.field_value="2"))
      AND cve.field_name="Override")
    DETAIL
     override_ind = 1
    WITH nocounter
   ;end select
   RETURN(override_ind)
 END ;Subroutine
 SUBROUTINE getpreferences(null)
   DECLARE powerchart_app_number = i4 WITH protect, constant(600005)
   DECLARE spreferencename = vc WITH protect, constant("PREGNANCY_SMART_TMPLT_ORG_SEC")
   DECLARE prefvalue = vc WITH noconstant("0"), protect
   SELECT INTO "nl:"
    FROM app_prefs ap,
     name_value_prefs nvp
    PLAN (ap
     WHERE ap.prsnl_id=0.0
      AND ap.position_cd=0.0
      AND ap.application_number=powerchart_app_number)
     JOIN (nvp
     WHERE nvp.parent_entity_name="APP_PREFS"
      AND nvp.parent_entity_id=ap.app_prefs_id
      AND trim(nvp.pvc_name,3)=cnvtupper(spreferencename))
    DETAIL
     prefvalue = nvp.pvc_value
    WITH nocounter
   ;end select
   RETURN(cnvtint(prefvalue))
 END ;Subroutine
 SUBROUTINE getorgsecurity(null)
   SELECT INTO "nl:"
    FROM dm_info d1
    WHERE d1.info_domain="SECURITY"
     AND d1.info_name="SEC_ORG_RELTN"
     AND d1.info_number=1
    DETAIL
     preg_org_sec_ind = 1
    WITH nocounter
   ;end select
   CALL echo(build("org_sec_ind=",preg_org_sec_ind))
   IF (preg_org_sec_ind=1)
    CALL loadorganizationsecuritylist(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE loadorganizationsecuritylist(null)
   DECLARE org_cnt = i2 WITH noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (validate(sac_org)=1)
    FREE RECORD sac_org
   ENDIF
   RECORD sac_org(
     1 organizations[*]
       2 organization_id = f8
       2 confid_cd = f8
       2 confid_level = i4
   )
   EXECUTE secrtl
   DECLARE orgcnt = i4 WITH protected, noconstant(0)
   DECLARE secstat = i2
   DECLARE logontype = i4 WITH protect, noconstant(- (1))
   DECLARE confid_cd = f8 WITH protected, noconstant(0.0)
   DECLARE role_profile_org_id = f8 WITH protected, noconstant(0.0)
   CALL uar_secgetclientlogontype(logontype)
   CALL echo(build("logontype:",logontype))
   IF (logontype=0)
    SELECT DISTINCT INTO "nl:"
     FROM prsnl_org_reltn por,
      organization o,
      prsnl p
     PLAN (p
      WHERE (p.person_id=reqinfo->updt_id))
      JOIN (por
      WHERE por.person_id=p.person_id
       AND por.active_ind=1
       AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (o
      WHERE por.organization_id=o.organization_id)
     DETAIL
      orgcnt += 1
      IF (mod(orgcnt,10)=1)
       secstat = alterlist(sac_org->organizations,(orgcnt+ 9))
      ENDIF
      sac_org->organizations[orgcnt].organization_id = por.organization_id, sac_org->organizations[
      orgcnt].confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd),
      sac_org->organizations[orgcnt].confid_level =
      IF (confid_cd > 0) confid_cd
      ELSE 0
      ENDIF
     WITH nocounter
    ;end select
    SET secstat = alterlist(sac_org->organizations,orgcnt)
   ENDIF
   IF (logontype=1)
    CALL echo("entered into nhs logon")
    DECLARE hprop = i4 WITH protect, noconstant(0)
    DECLARE tmpstat = i2
    DECLARE spropname = vc
    DECLARE sroleprofile = vc
    SET hprop = uar_srvcreateproperty()
    SET tmpstat = uar_secgetclientattributesext(5,hprop)
    SET spropname = uar_srvfirstproperty(hprop)
    SET sroleprofile = uar_srvgetpropertyptr(hprop,nullterm(spropname))
    CALL echo(sroleprofile)
    DECLARE nhstrustchild_org_org_reltn_cd = f8
    SET nhstrustchild_org_org_reltn_cd = uar_get_code_by("MEANING",369,"NHSTRUSTCHLD")
    SELECT INTO "nl:"
     FROM prsnl_org_reltn_type prt,
      prsnl_org_reltn por,
      organization o
     PLAN (prt
      WHERE prt.role_profile=sroleprofile
       AND prt.active_ind=1
       AND prt.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND prt.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (o
      WHERE o.organization_id=prt.organization_id)
      JOIN (por
      WHERE (por.organization_id= Outerjoin(prt.organization_id))
       AND (por.person_id= Outerjoin(prt.prsnl_id))
       AND (por.active_ind= Outerjoin(1))
       AND (por.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
       AND (por.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
     ORDER BY por.prsnl_org_reltn_id
     DETAIL
      orgcnt = 1, stat = alterlist(sac_org->organizations,1), sac_org->organizations[1].
      organization_id = prt.organization_id,
      role_profile_org_id = sac_org->organizations[orgcnt].organization_id, sac_org->organizations[1]
      .confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd),
      sac_org->organizations[1].confid_level =
      IF (confid_cd > 0) confid_cd
      ELSE 0
      ENDIF
     WITH maxrec = 1
    ;end select
    SELECT INTO "nl:"
     FROM prsnl_org_reltn por
     PLAN (por
      WHERE (por.person_id=reqinfo->updt_id)
       AND por.active_ind=1
       AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
     HEAD REPORT
      IF (orgcnt > 0)
       stat = alterlist(sac_org->organizations,10)
      ENDIF
     DETAIL
      IF (role_profile_org_id != por.organization_id)
       orgcnt += 1
       IF (mod(orgcnt,10)=1)
        stat = alterlist(sac_org->organizations,(orgcnt+ 9))
       ENDIF
       sac_org->organizations[orgcnt].organization_id = por.organization_id, sac_org->organizations[
       orgcnt].confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd
        ),
       sac_org->organizations[orgcnt].confid_level =
       IF (confid_cd > 0) confid_cd
       ELSE 0
       ENDIF
      ENDIF
     FOOT REPORT
      stat = alterlist(sac_org->organizations,orgcnt)
     WITH nocounter
    ;end select
    CALL uar_srvdestroyhandle(hprop)
   ENDIF
   SET org_cnt = size(sac_org->organizations,5)
   CALL echo(build("org_cnt: ",org_cnt))
   SET stat = alterlist(preg_sec_orgs->qual,(org_cnt+ 1))
   FOR (count = 1 TO org_cnt)
    SET preg_sec_orgs->qual[count].org_id = sac_org->organizations[count].organization_id
    SET preg_sec_orgs->qual[count].confid_level = sac_org->organizations[count].confid_level
   ENDFOR
   SET preg_sec_orgs->qual[(org_cnt+ 1)].org_id = 0.00
   SET preg_sec_orgs->qual[(org_cnt+ 1)].confid_level = 0
   CALL echorecord(preg_sec_orgs)
 END ;Subroutine
 SUBROUTINE geteventcodes(null)
   SELECT INTO "nl:"
    FROM code_value cv,
     (dummyt d1  WITH seq = size(concept_cki->rec,5))
    PLAN (d1)
     JOIN (cv
     WHERE (cv.code_value=concept_cki->rec[d1.seq].f_code_value)
      AND cv.code_set=72
      AND cv.active_ind=1)
    HEAD REPORT
     ec_cnt = 0
    DETAIL
     ec_cnt += 1, stat = alterlist(ce->rec,ec_cnt), ce->rec[ec_cnt].event_cd = cv.code_value
    FOOT REPORT
     ce->cnt = ec_cnt
    WITH nocounter
   ;end select
   CALL echorecord(concept_cki)
   CALL echorecord(ce)
 END ;Subroutine
 SUBROUTINE checkbereavement(null)
   SELECT INTO "nl:"
    FROM ce_coded_result cr,
     nomenclature n
    PLAN (cr
     WHERE cr.event_id=bereave_event_id
      AND cr.valid_until_dt_tm > cnvtdatetime(sysdate))
     JOIN (n
     WHERE n.nomenclature_id=cr.nomenclature_id
      AND n.active_ind=1
      AND n.concept_cki IN ("CERNER!ASYr9AEYvUr1YoRlCqIGfQ", "CERNER!ASYr9AEYvUr1YoRuCqIGfQ"))
    DETAIL
     bereave_ind = 1
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE loaddata(null)
   DECLARE piecestr = vc WITH noconstant("")
   DECLARE notfnd = vc WITH constant("<not_found>")
   DECLARE numidx = i4 WITH noconstant(1)
   DECLARE nondupstr = vc WITH noconstant("")
   IF (validate(debug_ind,0)=1)
    CALL echo(build("onset_dt_tm:",format(ld_request->person[1].pregnancy_list[1].onset_dt_tm,
       "YYYYMMDD;;d")))
   ENDIF
   DECLARE ceidx = i4 WITH protect, noconstant(0)
   SELECT
    IF (honor_org_security_flag=1)INTO "nl:"
     res =
     IF (ce.result_units_cd > 0.0) concat(trim(ce.result_val)," ",uar_get_code_display(ce
        .result_units_cd))
     ELSEIF (cd.event_id > 0.0) format(cd.result_dt_tm,"@SHORTDATETIME")
     ELSE ce.result_val
     ENDIF
     , rgroup =
     IF (cv.concept_cki="CERNER!F585EADF-7F01-46CD-8D43-1C7B01C17592") build(cv.concept_cki,cl
       .label_name)
     ELSE build(ce.event_cd,cl.label_name)
     ENDIF
     FROM clinical_event ce,
      code_value cv,
      ce_dynamic_label cl,
      ce_date_result cd,
      encounter e
     PLAN (ce
      WHERE (ce.person_id=request->person[1].person_id)
       AND (ce.encntr_id=request->visit[1].encntr_id)
       AND ce.result_status_cd IN (auth, altered, modified)
       AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
       AND cnvtint(format(ce.event_end_dt_tm,"YYYYMMDD;;D")) >= cnvtint(format(ld_request->person[1].
        pregnancy_list[1].onset_dt_tm,"YYYYMMDD;;D"))
       AND expand(ceidx,1,size(ce->rec,5),ce.event_cd,ce->rec[ceidx].event_cd))
      JOIN (cv
      WHERE cv.code_value=ce.event_cd
       AND cv.active_ind=1)
      JOIN (cl
      WHERE (cl.ce_dynamic_label_id= Outerjoin(ce.ce_dynamic_label_id))
       AND (cl.valid_until_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
      JOIN (cd
      WHERE (cd.event_id= Outerjoin(ce.event_id))
       AND (cd.valid_until_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
      JOIN (e
      WHERE e.encntr_id=ce.encntr_id
       AND expand(os_idx,1,size(preg_sec_orgs->qual,5),e.organization_id,preg_sec_orgs->qual[os_idx].
       org_id))
     ORDER BY rgroup, ce.event_end_dt_tm DESC
    ELSE INTO "nl:"
     res =
     IF (ce.result_units_cd > 0.0) concat(trim(ce.result_val)," ",uar_get_code_display(ce
        .result_units_cd))
     ELSEIF (cd.event_id > 0.0) format(cd.result_dt_tm,"@SHORTDATETIME")
     ELSE ce.result_val
     ENDIF
     , rgroup =
     IF (cv.concept_cki="CERNER!F585EADF-7F01-46CD-8D43-1C7B01C17592") build(cv.concept_cki,cl
       .label_name)
     ELSE build(ce.event_cd,cl.label_name)
     ENDIF
     FROM clinical_event ce,
      code_value cv,
      ce_dynamic_label cl,
      ce_date_result cd
     PLAN (ce
      WHERE (ce.person_id=request->person[1].person_id)
       AND (ce.encntr_id=request->visit[1].encntr_id)
       AND ce.result_status_cd IN (auth, altered, modified)
       AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
       AND cnvtint(format(ce.event_end_dt_tm,"YYYYMMDD;;D")) >= cnvtint(format(ld_request->person[1].
        pregnancy_list[1].onset_dt_tm,"YYYYMMDD;;D"))
       AND expand(ceidx,1,size(ce->rec,5),ce.event_cd,ce->rec[ceidx].event_cd))
      JOIN (cv
      WHERE cv.code_value=ce.event_cd
       AND cv.active_ind=1)
      JOIN (cl
      WHERE (cl.ce_dynamic_label_id= Outerjoin(ce.ce_dynamic_label_id))
       AND (cl.valid_until_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
      JOIN (cd
      WHERE (cd.event_id= Outerjoin(ce.event_id))
       AND (cd.valid_until_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
     ORDER BY rgroup, ce.event_end_dt_tm DESC
    ENDIF
    HEAD REPORT
     res_cnt = 0
    HEAD rgroup
     res_cnt += 1, stat = alterlist(allresult->rec,res_cnt), allresult->rec[res_cnt].label_name = cl
     .label_name,
     allresult->rec[res_cnt].concept_cki = cv.concept_cki, allresult->rec[res_cnt].cki = cv.cki,
     allresult->rec[res_cnt].display = cv.display,
     allresult->rec[res_cnt].f_event_cd = cv.code_value
     IF (ce.event_cd != mf_anesthesiaob_cd)
      IF (ce.result_status_cd=modified)
       allresult->rec[res_cnt].result_val = concat(trim(res),trim(modifiedcaption))
      ELSE
       IF (cv.concept_cki != "CERNER!F585EADF-7F01-46CD-8D43-1C7B01C17592")
        allresult->rec[res_cnt].result_val = trim(res)
       ENDIF
      ENDIF
     ENDIF
     IF (cv.concept_cki="CERNER!ASYr9AEYvUr1YoRACqIGfQ")
      bereave_event_id = ce.event_id
     ENDIF
     IF (ce.result_units_cd=dhrs)
      allresult->rec[res_cnt].units_flag = 1
     ELSEIF (ce.result_units_cd=dmin)
      allresult->rec[res_cnt].units_flag = 2
     ENDIF
    DETAIL
     IF (ce.event_cd=mf_anesthesiaob_cd)
      IF (size(trim(allresult->rec[res_cnt].result_val,3)) > 0)
       IF (ce.result_status_cd=modified)
        allresult->rec[res_cnt].result_val = concat(allresult->rec[res_cnt].result_val,", ",trim(res),
         "  ",trim(format(ce.performed_dt_tm,"MM/DD/YY HH:mm:ss;;q"),3),
         trim(modifiedcaption))
       ELSE
        allresult->rec[res_cnt].result_val = concat(allresult->rec[res_cnt].result_val,", ",trim(res),
         "  ",trim(format(ce.performed_dt_tm,"MM/DD/YY HH:mm:ss;;q"),3))
       ENDIF
      ELSE
       IF (ce.result_status_cd=modified)
        allresult->rec[res_cnt].result_val = concat(trim(res),"  ",trim(format(ce.performed_dt_tm,
           "MM/DD/YY HH:mm:ss;;q"),3),trim(modifiedcaption))
       ELSE
        allresult->rec[res_cnt].result_val = concat(trim(res),"  ",trim(format(ce.performed_dt_tm,
           "MM/DD/YY HH:mm:ss;;q"),3))
       ENDIF
      ENDIF
     ENDIF
     piecestr = "", nondupstr = "", numidx = 1
     IF (cv.concept_cki="CERNER!F585EADF-7F01-46CD-8D43-1C7B01C17592")
      IF ((allresult->rec[res_cnt].result_val=""))
       IF (ce.result_status_cd=modified)
        allresult->rec[res_cnt].result_val = concat(trim(res),trim(modifiedcaption))
       ELSE
        allresult->rec[res_cnt].result_val = trim(res)
       ENDIF
      ELSE
       IF (findstring(trim(res),allresult->rec[res_cnt].result_val,1,0) <= 0)
        IF (ce.result_status_cd=modified)
         allresult->rec[res_cnt].result_val = build2(allresult->rec[res_cnt].result_val,"; ",concat(
           trim(res),trim(modifiedcaption)))
        ELSE
         allresult->rec[res_cnt].result_val = build2(allresult->rec[res_cnt].result_val,"; ",trim(res
           ))
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     IF (((cv.concept_cki="CERNER!F4497987-EBEA-452A-8E7A-E9A11D9B0C63") OR (((cv.concept_cki=
     "CERNER!4D713327-956D-46E5-893B-8DAFA44336FE") OR (cv.concept_cki=
     "CERNER!6B69F0FC-5514-40A1-BBE4-EF20AAF35BE0")) )) )
      WHILE (piecestr != notfnd)
        piecestr = piece(res,",",numidx,notfnd)
        IF (findstring(trim(piecestr,7),allresult->rec[res_cnt].result_val,1,0)=0
         AND piecestr != notfnd)
         IF (nondupstr="")
          nondupstr = trim(piecestr,7)
         ELSE
          nondupstr = build2(nondupstr,", ",trim(piecestr,7))
         ENDIF
        ENDIF
        numidx += 1
      ENDWHILE
      IF (nondupstr != "")
       IF ((allresult->rec[res_cnt].result_val=""))
        IF (ce.result_status_cd=modified)
         allresult->rec[res_cnt].result_val = concat(trim(nondupstr),trim(modifiedcaption))
        ELSE
         allresult->rec[res_cnt].result_val = trim(nondupstr)
        ENDIF
       ELSE
        IF (ce.result_status_cd=modified)
         allresult->rec[res_cnt].result_val = build2(allresult->rec[res_cnt].result_val,", ",concat(
           trim(nondupstr),trim(modifiedcaption)))
        ELSE
         allresult->rec[res_cnt].result_val = build2(allresult->rec[res_cnt].result_val,", ",trim(
           nondupstr))
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0)=1)
    CALL echorecord(allresult)
   ENDIF
 END ;Subroutine
 SUBROUTINE loadsectionnames(null)
   SELECT INTO "nl:"
    ln = allresult->rec[d1.seq].label_name
    FROM (dummyt d1  WITH seq = size(allresult->rec,5))
    PLAN (d1
     WHERE size(trim(allresult->rec[d1.seq].label_name)) > 0)
    ORDER BY ln
    HEAD REPORT
     l_cnt = 0, rtf->mother[1].section[1].section_name = "Labor Information", rtf->mother[1].section[
     2].section_name = "Delivery Information"
    HEAD ln
     l_cnt += 1, stat = alterlist(rtf->baby,l_cnt), stat = alterlist(rtf->mother[1].section[1].baby,
      l_cnt),
     rtf->mother[1].section[1].baby[l_cnt].label_name = ln, rtf->baby[l_cnt].label_name = ln, rtf->
     baby[l_cnt].section[1].section_name = "Delivery Information",
     rtf->baby[l_cnt].section[2].section_name = "Care Team", rtf->baby[l_cnt].section[3].section_name
      = "Labor Information", rtf->baby[l_cnt].section[4].section_name = "Neonatal Information",
     rtf->baby[l_cnt].section[5].section_name = "Operative Delivery"
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE loadlabeldisplay(null)
   DECLARE rtfs1 = i4 WITH private, noconstant(0)
   DECLARE rtfs2 = i4 WITH private, noconstant(0)
   DECLARE rtfs3 = i4 WITH private, noconstant(0)
   DECLARE rtfs4 = i4 WITH private, noconstant(0)
   DECLARE rtfs5 = i4 WITH private, noconstant(0)
   DECLARE mom_rtfs1 = i4 WITH private, noconstant(0)
   DECLARE mom_rtfs2 = i4 WITH private, noconstant(0)
   DECLARE mom_baby_rtf1 = i4 WITH private, noconstant(0)
   FOR (lbl = 1 TO size(rtf->baby,5))
     SET rtfs1 = 0
     SET rtfs2 = 0
     SET rtfs3 = 0
     SET rtfs4 = 0
     SET rtfs5 = 0
     SET mom_rtfs1 = 0
     SET mom_rtfs2 = 0
     SET mom_baby_rtf1 = 0
     FOR (cc = 1 TO size(concept_cki->rec,5))
       IF (cc BETWEEN 1 AND 17)
        SET rtfs1 += 1
        SET stat = alterlist(rtf->baby[lbl].section[1].event,rtfs1)
        SET rtf->baby[lbl].section[1].event[rtfs1].event_label = concept_cki->rec[cc].display
        SET rtf->baby[lbl].section[1].event[rtfs1].event_cd = concept_cki->rec[cc].f_code_value
       ELSEIF (cc BETWEEN 18 AND 30)
        SET rtfs2 += 1
        SET stat = alterlist(rtf->baby[lbl].section[2].event,rtfs2)
        SET rtf->baby[lbl].section[2].event[rtfs2].event_label = concept_cki->rec[cc].display
        SET rtf->baby[lbl].section[2].event[rtfs2].event_cd = concept_cki->rec[cc].f_code_value
       ELSEIF (cc BETWEEN 31 AND 35)
        SET rtfs3 += 1
        SET stat = alterlist(rtf->baby[lbl].section[3].event,rtfs3)
        SET rtf->baby[lbl].section[3].event[rtfs3].event_label = concept_cki->rec[cc].display
        SET rtf->baby[lbl].section[3].event[rtfs3].event_cd = concept_cki->rec[cc].f_code_value
       ELSEIF (cc BETWEEN 36 AND 55)
        SET rtfs4 += 1
        SET stat = alterlist(rtf->baby[lbl].section[4].event,rtfs4)
        SET rtf->baby[lbl].section[4].event[rtfs4].event_label = concept_cki->rec[cc].display
        SET rtf->baby[lbl].section[4].event[rtfs4].event_cd = concept_cki->rec[cc].f_code_value
       ELSEIF (cc BETWEEN 56 AND 68)
        SET rtfs5 += 1
        SET stat = alterlist(rtf->baby[lbl].section[5].event,rtfs5)
        SET rtf->baby[lbl].section[5].event[rtfs5].event_label = concept_cki->rec[cc].display
        SET rtf->baby[lbl].section[5].event[rtfs5].event_cd = concept_cki->rec[cc].f_code_value
       ELSEIF (cc BETWEEN 69 AND 70)
        SET mom_rtfs1 += 1
        SET stat = alterlist(rtf->mother[1].section[1].event,mom_rtfs1)
        SET rtf->mother[1].section[1].event[mom_rtfs1].event_label = concept_cki->rec[cc].display
        SET rtf->mother[1].section[1].event[mom_rtfs1].event_cd = concept_cki->rec[cc].f_code_value
       ELSEIF (cc BETWEEN 71 AND 73)
        SET mom_baby_rtf1 += 1
        SET stat = alterlist(rtf->mother[1].section[1].baby[lbl].event,mom_baby_rtf1)
        SET rtf->mother[1].section[1].baby[lbl].event[mom_baby_rtf1].event_label = concept_cki->rec[
        cc].display
        SET rtf->mother[1].section[1].baby[lbl].event[mom_baby_rtf1].event_cd = concept_cki->rec[cc].
        f_code_value
       ELSEIF (cc BETWEEN 74 AND 99)
        SET mom_rtfs2 += 1
        SET stat = alterlist(rtf->mother[1].section[2].event,mom_rtfs2)
        SET rtf->mother[1].section[2].event[mom_rtfs2].event_label = concept_cki->rec[cc].display
        SET rtf->mother[1].section[2].event[mom_rtfs2].event_cd = concept_cki->rec[cc].f_code_value
       ENDIF
     ENDFOR
   ENDFOR
   IF (validate(debug_ind,0)=1)
    CALL echorecord(rtf)
   ENDIF
 END ;Subroutine
 SUBROUTINE (createmessagertf(message=vc) =vc WITH protect)
   DECLARE rtf_message = vc WITH protect, noconstant("")
   SET rtf_message = concat(rhead_colors1,rhead_colors2,rhead_colors3,"\tx1500\tx7300",rtitle,
    colornavy,captions_genview_title,wr,reol,rsecline,
    colorgrey,boldline,wr,reol,reol,
    wr,rpard,rtabstopnd,rtab,message,
    wrs,reol,reol,rsecline,colorgrey,
    boldline,wr,rpard,reol,rpard)
   RETURN(rtf_message)
 END ;Subroutine
#exit_script
 IF (stand_alone_ind=1)
  SET reply->text = concat(reply->text,rtfeof)
 ELSE
  SET reply->text = concat(reply->text)
 ENDIF
 FREE RECORD rtf
 SET script_version = "000"
END GO

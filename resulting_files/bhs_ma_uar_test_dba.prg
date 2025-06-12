CREATE PROGRAM bhs_ma_uar_test:dba
 PROMPT
  "PRINTER " = "MINE"
 DECLARE page_cnt = i4 WITH public, noconstant(0)
 DECLARE last_title = vc WITH public, noconstant(" ")
 DECLARE title_string = vc WITH public, noconstant(" ")
 DECLARE tempstring = vc WITH public, noconstant(" ")
 DECLARE temp = vc WITH public, noconstant(" ")
 DECLARE print_string = vc WITH public, noconstant(" ")
 DECLARE printstring = vc WITH public, noconstant(" ")
 DECLARE newstring = vc WITH public, noconstant(" ")
 DECLARE print_flag = i4 WITH public, noconstant(0)
 DECLARE line1 = vc WITH public, constant(fillstring(95,"_"))
 DECLARE equal_line = c116 WITH public, constant(fillstring(116,"_"))
 DECLARE starline = vc WITH public, constant(fillstring(71,"*"))
 DECLARE filler = vc WITH public, constant(fillstring(100," "))
 DECLARE line2 = vc WITH public, constant(fillstring(100," "))
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE cntd = i4 WITH public, noconstant(0)
 DECLARE i = i4 WITH public, noconstant(0)
 DECLARE lastflag = i4 WITH public, noconstant(0)
 DECLARE tblobout = vc WITH public, noconstant(" ")
 DECLARE rpt_title = c20 WITH public, constant("BUILD/CLINSUM")
 DECLARE user_name = vc WITH public, noconstant(" ")
 DECLARE last_encntr_id = f8 WITH public, noconstant(0.0)
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE compressed_cd = f8
 SET stat = uar_get_meaning_by_codeset(120,"OCFCOMP",1,compressed_cd)
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE o_incomplete_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE o_inprocess_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE o_ordered_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE o_pending_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE o_suspended_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE o_pending_rev_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE o_completed_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE inerror_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE allergy_cancelled_cd = f8 WITH public, constant(uar_get_code_by("MEANING",12025,"CANCELED"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE e_encntr_status_cd = f8 WITH public, constant(uar_get_code_by("MEANING",261,"ACTIVE"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE mrn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"MRN"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE ssn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"SSN"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE account_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"ACCOUNT"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE fin_cd = f8 WITH public, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE admitdoc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ADMITDOC"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE attenddoc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE pcp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",331,"PCP"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE code_status_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"TSL"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE chiefcomplaint_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CHIEFCOMPLAINT"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE order_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE laboratory_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"LABORATORY"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE generallab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"GENERALLAB"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE micro_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"MICRO"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE ocfcomp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE codestatusnsg_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"CODESTATUSNSG"
   ))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE iv_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",18309,"IV"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE intermittent_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",18309,"INTERMITTENT"
   ))
 DECLARE ivsolutions_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",16389,"IVSOLUTIONS"))
 DECLARE laboratory_cattyp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,
   "LABORATORY"))
 DECLARE anatomicpathology_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "ANATOMICPATHOLOGY"))
 DECLARE bloodbank_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"BLOODBANK"))
 DECLARE generallab_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"GENERALLAB"
   ))
 DECLARE micro_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"MICRO"))
 DECLARE radiology_cattyp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"RADIOLOGY"
   ))
 DECLARE radiology_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"RADIOLOGY"))
 DECLARE specialprocedures_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "SPECIALPROCEDURES"))
 DECLARE ultrasound_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ULTRASOUND"
   ))
 DECLARE pharmacy_cattyp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE pharmacy_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY"))
 SET cnt = (cnt+ 1)
 CALL echo(build("pt data ",cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE codestatus_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"CODESTATUS"))
 DECLARE isolation_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ISOLATION"))
 DECLARE authorizedtodiscusspatientshealth_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",
   72,"AUTHORIZEDTODISCUSSPATIENTSHEALTH"))
 DECLARE contactproxyphonenumber_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CONTACTPROXYPHONENUMBER"))
 DECLARE proxy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"PROXY"))
 DECLARE copyplacedonchart_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "COPYPLACEDONCHART"))
 DECLARE advancedirective_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "ADVANCEDIRECTIVE"))
 DECLARE homephonenumber_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "HOMEPHONENUMBER"))
 DECLARE relationshiptopatient_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "RELATIONSHIPTOPATIENT"))
 DECLARE contactperson_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"CONTACTPERSON")
  )
 DECLARE ispatientachronicco2retainer_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "ISPATIENTACHRONICCO2RETAINER"))
 DECLARE languagespoken_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "LANGUAGESPOKEN"))
 DECLARE fallsriskscore_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "FALLSRISKSCORE"))
 SET cnt = (cnt+ 1)
 CALL echo(build("section2",cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE edc_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"EDC"))
 DECLARE gravida_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"GRAVIDA"))
 DECLARE term_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"TERM"))
 DECLARE parity_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"PARITY"))
 DECLARE living_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"LIVING"))
 DECLARE abortion_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"ABORTION"))
 DECLARE gestationalage_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "GESTATIONALAGE"))
 DECLARE deliverydate_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"DELIVERYDATE"))
 DECLARE deliverytype_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"DELIVERYTYPE"))
 DECLARE birthweight_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"BIRTHWEIGHT"))
 DECLARE code_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"CODE"))
 DECLARE deliveredby_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"DELIVEREDBY"))
 DECLARE placeofbirth_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"PLACEOFBIRTH"))
 SET cnt = (cnt+ 1)
 CALL echo(build("section3",cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE thighcircumference_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "THIGHCIRCUMFERENCE"))
 DECLARE calfcircumference_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CALFCIRCUMFERENCE"))
 DECLARE bodymassindex_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"BODYMASSINDEX")
  )
 DECLARE bodysurfacearea_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "BODYSURFACEAREA"))
 DECLARE abdominalgirth_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "ABDOMINALGIRTH"))
 DECLARE headcircumference_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEADCIRCUMFERENCE"))
 DECLARE weight_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT"))
 DECLARE height_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"HEIGHT"))
 SET cnt = (cnt+ 1)
 CALL echo(build("section3.5 ",cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE admittransferdischarge_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "ADMITTRANSFERDISCHARGE"))
 DECLARE communicationorders_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "COMMUNICATIONORDERS"))
 DECLARE callmd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"CALLMD"))
 DECLARE rntorn_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"RNTORN"))
 SET cnt = (cnt+ 1)
 CALL echo(build("section4",cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE nursecommunicationnutrition_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "NURSECOMMUNICATIONNUTRITION"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE cardiacrehabnursecommunication_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CARDIACREHABNURSECOMMUNICATION"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE nursecommunicationrehab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "NURSECOMMUNICATIONREHAB"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE nursecommunicationpulmonaryrehab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",
   72,"NURSECOMMUNICATIONPULMONARYREHAB"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE nursecommunicationsocialservices_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",
   72,"NURSECOMMUNICATIONSOCIALSERVICES"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE agencycontactperson_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "AGENCYCONTACTPERSON"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE servicefrequency_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "SERVICEFREQUENCY"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE equipment_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"EQUIPMENT"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE servicecategories_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "SERVICECATEGORIES"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE portableunitrequired_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "PORTABLEUNITREQUIRED"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE patientgoinghomeonoxygen_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "PATIENTGOINGHOMEONOXYGEN"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE currenthometreatments_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CURRENTHOMETREATMENTS"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE currenthomeservices_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CURRENTHOMESERVICES"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE medicalequipmentcompanies_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "MEDICALEQUIPMENTCOMPANIES"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE jail_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"JAIL"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE fostercare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"FOSTERCARE"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE ambulanceservices_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "AMBULANCESERVICES"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE modeoftransportationarranged_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "MODEOFTRANSPORTATIONARRANGED"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE confirmedtransferstarttimedate_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CONFIRMEDTRANSFERSTARTTIMEDATE"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE pulmonarynurseappointment_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "PULMONARYNURSEAPPOINTMENT"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE earlyinterventionprograms_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "EARLYINTERVENTIONPROGRAMS"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE vnahospicehomecare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "VNAHOSPICEHOMECARE"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE adultdayhealthcare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "ADULTDAYHEALTHCARE"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE resthomescommunityresidencesshelters_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"RESTHOMESCOMMUNITYRESIDENCESSHELTERS"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE nursinghomesskilledrehabfacilities_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"NURSINGHOMESSKILLEDREHABFACILITIES"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE chronichospital_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CHRONICHOSPITAL"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE dischargenursinghomesrehabfacilities_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"DISCHARGENURSINGHOMESREHABFACILITIES"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE dischargeresthomesresidencesshelters_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"DISCHARGERESTHOMESRESIDENCESSHELTERS"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE dischargeadultdayhealthcare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGEADULTDAYHEALTHCARE"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE dischargevnahospicehomecare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGEVNAHOSPICEHOMECARE"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE dischargeearlyinterventionprograms_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"DISCHARGEEARLYINTERVENTIONPROGRAMS"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE dischargemedicalequipmentcompanies_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"DISCHARGEMEDICALEQUIPMENTCOMPANIES"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 SET cnt = (cnt+ 1)
 CALL echo(build("pt care ",cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 SET cnt = (cnt+ 1)
 CALL echo(build("DIETARY ",cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE dietary_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"DIETARY"))
 DECLARE respther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"RESP THER"))
 DECLARE nsgrespiratorytx_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "NSGRESPIRATORYTX"))
 SET cnt = (cnt+ 1)
 CALL echo(build("ASMT ",cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE woundcare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"WOUNDCARE"))
 DECLARE orthopedictreatments_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "ORTHOPEDICTREATMENTS"))
 DECLARE orthosupply_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ORTHOSUPPLY"))
 DECLARE mdtorntxprocedures_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "MDTORNTXPROCEDURES"))
 DECLARE asmttxmonitoring_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "ASMTTXMONITORING"))
 SET cnt = (cnt+ 1)
 CALL echo(build("lINESTUBES ",cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE bloodbankproduct_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "BLOODBANKPRODUCT"))
 DECLARE invasivelinestubesdrains_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "INVASIVELINESTUBESDRAINS"))
 SET cnt = (cnt+ 1)
 CALL echo(build("D1EVENTS ",cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE bloodtransfusionreaction_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "BLOODTRANSFUSIONREACTION"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE anesthesiareaction_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "ANESTHESIAREACTION"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE litersperminute_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "LITERSPERMINUTE"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE oxygensaturation_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "OXYGENSATURATION"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE respiratoryrate_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPIRATORYRATE"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE diastolicbloodpressure_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE systolicbloodpressure_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE pulserate_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATE"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE temperature_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"TEMPERATURE"))
 SET cnt = (cnt+ 1)
 CALL echo(build(cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 SET cnt = (cnt+ 1)
 CALL echo(build("D2EVENTS ",cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE groupbstrep_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"GROUPBSTREP"))
 DECLARE herpes_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"HERPES"))
 DECLARE fetalheartrate_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTRATE"))
 DECLARE fetalweight_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"FETALWEIGHT"))
 DECLARE fundalheight_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"FUNDALHEIGHT"))
 DECLARE fetalpresentation_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALPRESENTATION"))
 DECLARE cervicaldilatation_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CERVICALDILATATION"))
 DECLARE effacement_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"EFFACEMENT"))
 DECLARE fetalstation_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"FETALSTATION"))
 DECLARE fluiddescription_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "FLUIDDESCRIPTION"))
 DECLARE membranes_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"MEMBRANES"))
 DECLARE contractionsbeganon_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CONTRACTIONSBEGANON"))
 DECLARE reasonforadmission_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "REASONFORADMISSION"))
 DECLARE mucouscolor_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"MUCOUSCOLOR"))
 DECLARE tubeposition_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"TUBEPOSITION"))
 DECLARE ettsize_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"ETTSIZE"))
 DECLARE ventilatorsupport_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "VENTILATORSUPPORT"))
 DECLARE resuscitationatbirth_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "RESUSCITATIONATBIRTH"))
 DECLARE chestcircumference_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CHESTCIRCUMFERENCE"))
 DECLARE birthlength_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"BIRTHLENGTH"))
 SET cnt = (cnt+ 1)
 CALL echo(build("D4EVENTS ",cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE birthcomplications_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "BIRTHCOMPLICATIONS"))
 DECLARE riskfactorsinuteroneonate_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "RISKFACTORSINUTERONEONATE"))
 DECLARE riskfactorsinuteromaternal_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "RISKFACTORSINUTEROMATERNAL"))
 DECLARE length_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"LENGTH"))
 DECLARE numberoflumens_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "NUMBEROFLUMENS"))
 DECLARE ivgauge_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"IVGAUGE"))
 DECLARE datedressingchange_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DATEDRESSINGCHANGE"))
 DECLARE dateofinsertion_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DATEOFINSERTION"))
 DECLARE centrallinecathetertype_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CENTRALLINECATHETERTYPE"))
 SET cnt = (cnt+ 1)
 CALL echo(build("heent ",cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE mouthandthroatsymptoms_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "MOUTHANDTHROATSYMPTOMS"))
 DECLARE epistaxisrelatedhistory_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "EPISTAXISRELATEDHISTORY"))
 DECLARE bleedingamount_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "BLEEDINGAMOUNT"))
 DECLARE epistaxislocation_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "EPISTAXISLOCATION"))
 DECLARE nasalsymptoms_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"NASALSYMPTOMS")
  )
 DECLARE noselocation_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"NOSELOCATION"))
 DECLARE earsymptoms_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"EARSYMPTOMS"))
 DECLARE earlocation_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"EARLOCATION"))
 DECLARE eyesymptoms_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"EYESYMPTOMS"))
 DECLARE eyelocation_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"EYELOCATION"))
 DECLARE dentitionageappropriate_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DENTITIONAGEAPPROPRIATE"))
 DECLARE tonguenormalappearance_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "TONGUENORMALAPPEARANCE"))
 DECLARE earsnormalappearance_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "EARSNORMALAPPEARANCE"))
 DECLARE eyesnormalappearance_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "EYESNORMALAPPEARANCE"))
 DECLARE cleftlippalate_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CLEFTLIPPALATE"))
 DECLARE narespatent_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"NARESPATENT"))
 DECLARE eardrainageleft_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "EARDRAINAGELEFT"))
 DECLARE eardrainageright_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "EARDRAINAGERIGHT"))
 DECLARE eyedrainageright_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "EYEDRAINAGERIGHT"))
 DECLARE eyedrainageleft_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "EYEDRAINAGELEFT"))
 DECLARE normocephalic_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"NORMOCEPHALIC")
  )
 DECLARE evidencecongenitalanomalies_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "EVIDENCECONGENITALANOMALIES"))
 DECLARE neckconditionnewborn_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "NECKCONDITIONNEWBORN"))
 DECLARE earconditionnewborn_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "EARCONDITIONNEWBORN"))
 DECLARE mouthconditionnewborn_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "MOUTHCONDITIONNEWBORN"))
 DECLARE nasalcondition_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "NASALCONDITION"))
 DECLARE scleracolor_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"SCLERACOLOR"))
 DECLARE pupileyecolor_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"PUPILEYECOLOR")
  )
 DECLARE eyecondition_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"EYECONDITION"))
 DECLARE eyesdescriptionnewborn_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "EYESDESCRIPTIONNEWBORN"))
 DECLARE facialmovement_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "FACIALMOVEMENT"))
 DECLARE symmetryofface_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYMMETRYOFFACE"))
 DECLARE headdescriptionnewborn_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEADDESCRIPTIONNEWBORN"))
 DECLARE heent_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"HEENT"))
 SET cnt = (cnt+ 1)
 CALL echo(build("d7events",cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 DECLARE gait_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"GAIT"))
 DECLARE extremitymovement_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "EXTREMITYMOVEMENT"))
 DECLARE tremors_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"TREMORS"))
 DECLARE headache_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"HEADACHE"))
 DECLARE preseizureaura_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "PRESEIZUREAURA"))
 DECLARE seizurehistory_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "SEIZUREHISTORY"))
 DECLARE headtraumahistory_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEADTRAUMAHISTORY"))
 DECLARE swallowingdifficulty_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "SWALLOWINGDIFFICULTY"))
 DECLARE sucknormal_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"SUCKNORMAL"))
 DECLARE behaviornewborn_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "BEHAVIORNEWBORN"))
 DECLARE sleepalertstatesnewborn_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "SLEEPALERTSTATESNEWBORN"))
 DECLARE seizureactivity_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "SEIZUREACTIVITY"))
 DECLARE headlag_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"HEADLAG"))
 DECLARE movementnewborn_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "MOVEMENTNEWBORN"))
 DECLARE tonenewborn_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"TONENEWBORN"))
 DECLARE reflexesnewborn_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "REFLEXESNEWBORN"))
 DECLARE mororeflex_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"MOROREFLEX"))
 DECLARE crydescription_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CRYDESCRIPTION"))
 DECLARE posteriorfontaneldescription_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "POSTERIORFONTANELDESCRIPTION"))
 DECLARE anteriorfontaneldescription_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "ANTERIORFONTANELDESCRIPTION"))
 DECLARE fontanels_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"FONTANELS"))
 DECLARE sensoryperception_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "SENSORYPERCEPTION"))
 DECLARE hallucinations_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "HALLUCINATIONS"))
 DECLARE levelofconsciousness_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "LEVELOFCONSCIOUSNESS"))
 DECLARE orientatedtopersonplacetime_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "ORIENTATEDTOPERSONPLACETIME"))
 DECLARE neurologicalsymptoms_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "NEUROLOGICALSYMPTOMS"))
 DECLARE neuronew_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"NEURONEW"))
 SET cnt = (cnt+ 1)
 CALL echo(build("last",cnt," - ","- ",format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d")))
 SELECT INTO  $1
  FROM prsnl p
  WHERE ((p.username=curuser) OR (p.person_id=1))
  ORDER BY p.person_id
  DETAIL
   user_name = substring(1,35,p.name_full_formatted), user_name, row + 1
  WITH nocounter
 ;end select
END GO

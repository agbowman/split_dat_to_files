CREATE PROGRAM bhs_ma_cumulative_orders:dba
 PROMPT
  "Enter output device MINE/printer/file name: " = "MINE",
  "Enter Desired Nursing Unit: " = "ICU"
  WITH outdev, loc
 FREE SET request
 RECORD request(
   1 output_device = vc
   1 script_name = vc
   1 visit_cnt = i4
   1 nur_unit_desc = vc
   1 nur_unit_cd = f8
   1 visit[*]
     2 encntr_id = f8
     2 person_id = f8
 )
 SET vversion = "V10"
 SET cnt = 0
 SET nu = cnvtupper(cnvtalphanum( $LOC))
 SELECT INTO "nl:"
  cv = c.code_value, dk = c.display_key, e.encntr_id
  FROM code_value c,
   encntr_domain ed,
   encounter e
  PLAN (c
   WHERE c.code_set=220
    AND c.cdf_meaning="NURSEUNIT"
    AND c.display_key=nu
    AND c.active_ind=1
    AND c.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00"))
   JOIN (ed
   WHERE ed.loc_nurse_unit_cd=c.code_value
    AND ed.active_ind=1
    AND ed.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00"))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.active_ind=1
    AND e.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00")
    AND e.disch_dt_tm=null)
  ORDER BY e.encntr_id
  HEAD REPORT
   cnt = 0
  HEAD PAGE
   request->output_device = cnvtupper( $OUTDEV), request->script_name = "bhs_ma_clinical_summary",
   request->nur_unit_cd = e.loc_nurse_unit_cd,
   request->nur_unit_desc = uar_get_code_display(e.loc_nurse_unit_cd)
  HEAD e.encntr_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(request->visit,(cnt+ 10))
   ENDIF
   request->visit[cnt].person_id = e.person_id, request->visit[cnt].encntr_id = e.encntr_id
  FOOT REPORT
   IF (cnt > 0)
    stat = alterlist(request->visit,cnt), request->visit_cnt = cnt
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO endprog
 ENDIF
 RECORD dlrec(
   1 encntr_total = i4
   1 seq[*]
     2 encntr_id = f8
     2 person_id = f8
     2 account_nbr = c20
     2 mrn = vc
     2 cmrn = vc
     2 name_full_formatted = vc
     2 nurse_unit = c6
     2 pt_loc = c16
     2 org_name = vc
     2 isolation_disp = vc
     2 code_status = vc
     2 los = i4
     2 reason_for_visit = vc
     2 age = c12
     2 birth_dt_tm = dq8
     2 admit_dt = c20
     2 dschg_dt = dq8
     2 pcpdoc_name = vc
     2 pcpdoc_alias = vc
     2 ic_cnt = i4
     2 zisol_code[*]
       3 order_mnemonic = vc
       3 order_detail_display_line = vc
       3 clinical_display_line = vc
     2 total_al = i4
     2 allergy[*]
       3 source_identifier = vc
       3 source_string = vc
       3 severity = vc
       3 type_source_string = vc
       3 allergy_dt_tm = vc
       3 diag_dt_tm = vc
       3 substance_type_disp = vc
       3 note = vc
       3 nomenclature_id = f8
       3 source_vocabulary_cd = f8
       3 source_vocabulary_disp = c40
       3 source_vocabulary_desc = c60
       3 source_vocabulary_mean = c12
     2 total_diag = i4
     2 diagnosis[*]
       3 source_identifier = vc
       3 source_string = vc
       3 diag_dt_tm = c16
       3 diag_type_desc = vc
       3 note = vc
       3 nomenclature_id = f8
       3 source_vocabulary_cd = f8
       3 source_vocabulary_disp = c40
       3 source_vocabulary_desc = c60
       3 source_vocabulary_mean = c12
     2 section1_total = i4
     2 section1_events[*]
       3 event_cd_disp = vc
       3 event_cd = f8
       3 event_type = vc
       3 event_dt_tm = vc
       3 result = vc
     2 section2_total = i4
     2 section2_events[*]
       3 event_cd_disp = vc
       3 event_cd = f8
       3 event_type = vc
       3 event_dt_tm = vc
       3 result = vc
     2 section3_total = i4
     2 section3_events[*]
       3 event_cd_disp = vc
       3 event_cd = f8
       3 event_type = vc
       3 event_dt_tm = vc
       3 result = vc
     2 orders35_total = i4
     2 orders35[*]
       3 order_mnemonic = vc
       3 order_detail_display_line = vc
       3 clinical_display_line = vc
       3 orig_order_dt_tm = dq8
       3 order_comment_ind = i2
     2 section4_total = i4
     2 section4_events[*]
       3 event_cd_disp = vc
       3 event_cd = f8
       3 event_type = vc
       3 event_dt_tm = vc
       3 result = vc
     2 diet_total = i4
     2 diet[*]
       3 order_mnemonic = vc
       3 order_detail_display_line = vc
       3 clinical_display_line = vc
       3 order_comment_ind = i2
     2 resp_total = i4
     2 resp[*]
       3 order_mnemonic = vc
       3 order_detail_display_line = vc
       3 clinical_display_line = vc
       3 order_comment_ind = i2
     2 asmt_total = i4
     2 asmt[*]
       3 order_mnemonic = vc
       3 order_detail_display_line = vc
       3 clinical_display_line = vc
       3 order_comment_ind = i2
     2 ltd_total = i4
     2 ltd[*]
       3 order_mnemonic = vc
       3 order_detail_display_line = vc
       3 clinical_display_line = vc
       3 order_comment_ind = i2
     2 problem_total = i4
     2 problem[*]
       3 status = vc
       3 beg_effective_dt_tm = vc
       3 text = vc
       3 full_text = vc
     2 number_of_orders = i4
     2 orders[*]
       3 activity_type_disp = vc
       3 catalog_type_sort = i4
       3 catalog_type_disp = vc
       3 order_mnemonic = vc
       3 start_dt_tm = c20
       3 orig_order_dt_tm = c20
       3 order_status_cd = f8
       3 template_order_flag = f8
       3 order_status_disp = c20
       3 order_detail_display_line = vc
       3 clinical_display_line = vc
       3 long_text = vc
       3 frequency_display = vc
       3 order_comment_ind = f8
       3 order_person = vc
       3 order_doctor = vc
       3 misc = vc
       3 order_comment_ind = i2
     2 number_of_labs = i4
     2 labs[*]
       3 event_id = f8
       3 parent_event_id = f8
       3 event_cd_disp = vc
       3 result_val = vc
       3 result_units_disp = c25
       3 normal_low = c25
       3 normal_high = c25
       3 normalcy_disp = c25
       3 reference_range = c30
       3 event_end_dt_tm = dq8
       3 date = c25
       3 order_person = vc
       3 order_doctor = vc
     2 rorders_total = i4
     2 rorders[*]
       3 order_mnemonic = vc
       3 order_detail_display_line = vc
       3 clinical_display_line = vc
       3 order_comment_ind = i2
     2 cporders_total = i4
     2 cporders[*]
       3 order_mnemonic = vc
       3 order_detail_display_line = vc
       3 clinical_display_line = vc
       3 order_comment_ind = i2
     2 number_of_meds = i4
     2 meds[*]
       3 order_id = f8
       3 person_id = f8
       3 comments = vc
       3 mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 activity_type_disp = vc
       3 catalog_type_sort = i4
       3 catalog_type_disp = vc
       3 date = c20
       3 orig_order_dt_tm = c20
       3 order_status_cd = f8
       3 template_order_flag = f8
       3 order_status_disp = c20
       3 order_detail_display_line = vc
       3 display_line = vc
       3 long_text = vc
       3 freq = c30
       3 dose = c30
       3 doseunit = c30
       3 next_dose_dt_tm = c14
       3 order_comment_ind = i2
       3 order_person = vc
       3 order_doctor = vc
       3 need_rx_verify_ind = i2
       3 need_rx_verify_str = vc
       3 mso = i2
       3 ioi = i2
       3 event_id = f8
       3 event_cd_disp = vc
       3 result_val = vc
       3 normal_low = c25
       3 normal_high = c25
       3 normalcy_disp = vc
       3 event_end_dt_tm = dq8
     2 admitdoc_name = vc
     2 admitdoc_alias = vc
     2 attenddoc_name = vc
     2 attenddoc_alias = vc
     2 total_events = i4
     2 events[*]
       3 event_cd_disp = vc
       3 event_cd = f8
       3 event_type = vc
       3 event_dt_tm = vc
       3 result = vc
       3 misc = vc
       3 event_sort_order = f8
       3 dttmsort = i4
     2 d0events_total = i4
     2 d0events[*]
       3 event_cd_disp = vc
       3 parent_event = vc
       3 event_cd = f8
       3 event_id = f8
       3 event_type = vc
       3 event_dt_tm = vc
       3 result = vc
       3 event_seq = f8
       3 header1_txt = vc
       3 header2_txt = vc
 )
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
 DECLARE compressed_cd = f8
 SET stat = uar_get_meaning_by_codeset(120,"OCFCOMP",1,compressed_cd)
 DECLARE o_incomplete_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE o_inprocess_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE o_ordered_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE o_pending_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE o_suspended_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
 DECLARE o_pending_rev_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE o_completed_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE inerror_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE notdone_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"NOTDONE"))
 DECLARE allergy_cancelled_cd = f8 WITH public, constant(uar_get_code_by("MEANING",12025,"CANCELED"))
 DECLARE e_encntr_status_cd = f8 WITH public, constant(uar_get_code_by("MEANING",261,"ACTIVE"))
 DECLARE mrn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE cmrn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE ssn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE account_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"ACCOUNT"))
 DECLARE fin_cd = f8 WITH public, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE admitdoc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ADMITDOC"))
 DECLARE attenddoc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE pcp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE code_status_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"TSL"))
 DECLARE chiefcomplaint_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CHIEFCOMPLAINT"))
 DECLARE order_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE laboratory_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"LABORATORY"))
 DECLARE generallab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"GENERALLAB"))
 DECLARE micro_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"MICRO"))
 DECLARE ocfcomp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE codestatusnsg_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"CODESTATUSNSG"
   ))
 DECLARE iv_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",18309,"IV"))
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
 DECLARE codestatus_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"CODESTATUS"))
 DECLARE isolation_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ISOLATION"))
 DECLARE authorizedtodiscusspatientshealth_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",
   72,"AUTHORIZEDTODISCUSSPATIENTSHEALTH"))
 DECLARE contactproxyphonenumber_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CONTACTPROXYPHONENUMBER"))
 DECLARE proxy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"PROXY"))
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
 DECLARE admittransferdischarge_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "ADMITTRANSFERDISCHARGE"))
 DECLARE communicationorders_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "COMMUNICATIONORDERS"))
 DECLARE callmd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"CALLMD"))
 DECLARE rntorn_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"RNTORN"))
 DECLARE nursecommunicationnutrition_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "NURSECOMMUNICATIONNUTRITION"))
 DECLARE cardiacrehabnursecommunication_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CARDIACREHABNURSECOMMUNICATION"))
 DECLARE nursecommunicationrehab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "NURSECOMMUNICATIONREHAB"))
 DECLARE nursecommunicationpulmonaryrehab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",
   72,"NURSECOMMUNICATIONPULMONARYREHAB"))
 DECLARE nursecommunicationsocialservices_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",
   72,"NURSECOMMUNICATIONSOCIALSERVICES"))
 DECLARE agencycontactperson_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "AGENCYCONTACTPERSON"))
 DECLARE servicefrequency_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "SERVICEFREQUENCY"))
 DECLARE equipment_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"EQUIPMENT"))
 DECLARE servicecategories_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "SERVICECATEGORIES"))
 DECLARE portableunitrequired_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "PORTABLEUNITREQUIRED"))
 DECLARE patientgoinghomeonoxygen_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "PATIENTGOINGHOMEONOXYGEN"))
 DECLARE currenthometreatments_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CURRENTHOMETREATMENTS"))
 DECLARE currenthomeservices_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CURRENTHOMESERVICES"))
 DECLARE medicalequipmentcompanies_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "MEDICALEQUIPMENTCOMPANIES"))
 DECLARE jail_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"JAIL"))
 DECLARE fostercare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"FOSTERCARE"))
 DECLARE ambulanceservices_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "AMBULANCESERVICES"))
 DECLARE modeoftransportationarranged_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "MODEOFTRANSPORTATIONARRANGED"))
 DECLARE confirmedtransferstarttimedate_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CONFIRMEDTRANSFERSTARTTIMEDATE"))
 DECLARE pulmonarynurseappointment_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "PULMONARYNURSEAPPOINTMENT"))
 DECLARE earlyinterventionprograms_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "EARLYINTERVENTIONPROGRAMS"))
 DECLARE vnahospicehomecare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "VNAHOSPICEHOMECARE"))
 DECLARE adultdayhealthcare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "ADULTDAYHEALTHCARE"))
 DECLARE resthomescommunityresidencesshelters_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"RESTHOMESCOMMUNITYRESIDENCESSHELTERS"))
 DECLARE nursinghomesskilledrehabfacilities_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"NURSINGHOMESSKILLEDREHABFACILITIES"))
 DECLARE chronichospital_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CHRONICHOSPITAL"))
 DECLARE dischargenursinghomesrehabfacilities_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"DISCHARGENURSINGHOMESREHABFACILITIES"))
 DECLARE dischargeresthomesresidencesshelters_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"DISCHARGERESTHOMESRESIDENCESSHELTERS"))
 DECLARE dischargeadultdayhealthcare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGEADULTDAYHEALTHCARE"))
 DECLARE dischargevnahospicehomecare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGEVNAHOSPICEHOMECARE"))
 DECLARE dischargeearlyinterventionprograms_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"DISCHARGEEARLYINTERVENTIONPROGRAMS"))
 DECLARE dischargemedicalequipmentcompanies_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"DISCHARGEMEDICALEQUIPMENTCOMPANIES"))
 DECLARE dietary_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"DIETARY"))
 DECLARE respther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"RESP THER"))
 DECLARE nsgrespiratorytx_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "NSGRESPIRATORYTX"))
 DECLARE woundcare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"WOUNDCARE"))
 DECLARE orthopedictreatments_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "ORTHOPEDICTREATMENTS"))
 DECLARE orthosupply_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ORTHOSUPPLY"))
 DECLARE asmttxmonitoring_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "ASMTTXMONITORING"))
 DECLARE intakeandoutput_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "INTAKEANDOUTPUT"))
 DECLARE bloodbankproduct_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "BLOODBANKPRODUCT"))
 DECLARE invasivelinestubesdrains_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "INVASIVELINESTUBESDRAINS"))
 DECLARE snmct_cd = f8 WITH public, constant(uar_get_code_by("MEANING",400,"SNMCT"))
 DECLARE dcpgenericcode_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DCPGENERICCODE"))
 DECLARE anatomicpathology_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "ANATOMICPATHOLOGY"))
 DECLARE bloodbank_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"BLOODBANK"))
 DECLARE bloodbankmlh_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"BLOODBANKMLH"))
 DECLARE cardiactxprocedures_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "CARDIACTXPROCEDURES"))
 DECLARE ecg_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ECG"))
 DECLARE pointofcare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"POINTOFCARE"))
 DECLARE radiology_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"RADIOLOGY"))
 DECLARE physther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"PHYS THER"))
 DECLARE occther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"OCC THER"))
 DECLARE speechther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"SPEECH THER"))
 DECLARE audiology_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"AUDIOLOGY"))
 DECLARE antepartum_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"ANTEPARTUM"))
 DECLARE neurodiag_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"NEURODIAG"))
 DECLARE pulmlab_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"PULM LAB"))
 DECLARE noninvasivecardiologytxprocedures_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",
   106,"NONINVASIVECARDIOLOGYTXPROCEDURES"))
 DECLARE mdtornconsults_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "MDTORNCONSULTS"))
 CALL echo(mdtornconsults_cd)
 DECLARE consults_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"CONSULTS"))
 CALL echo(mdtornconsults_cd)
 DECLARE hyperbaricoxygentx_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "HYPERBARICOXYGENTX"))
 DECLARE mdtorntxprocedures_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "MDTORNTXPROCEDURES"))
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE ((p.username=curuser) OR (p.person_id=1))
  ORDER BY p.person_id
  DETAIL
   user_name = substring(1,35,p.name_full_formatted)
  WITH nocounter
 ;end select
 IF ((request->visit_cnt > 0))
  SELECT INTO "nl:"
   nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd), pt_loc = concat(trim(uar_get_code_display(
      e.loc_room_cd)),"-",trim(uar_get_code_display(e.loc_bed_cd))), isolation_disp =
   uar_get_code_display(e.isolation_cd)
   FROM (dummyt d  WITH seq = value(request->visit_cnt)),
    encounter e,
    encntr_alias ea,
    person p,
    organization org,
    person_alias pa
   PLAN (d)
    JOIN (e
    WHERE (e.encntr_id=request->visit[d.seq].encntr_id)
     AND (e.loc_nurse_unit_cd=request->nur_unit_cd))
    JOIN (p
    WHERE e.person_id=p.person_id
     AND p.active_ind=1)
    JOIN (pa
    WHERE p.person_id=pa.person_id
     AND pa.person_alias_type_cd IN (mrn_cd, cmrn_cd)
     AND pa.active_ind=1)
    JOIN (org
    WHERE e.organization_id=org.organization_id)
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(e.encntr_id)
     AND ea.encntr_alias_type_cd=outerjoin(fin_cd)
     AND ea.active_ind=outerjoin(1)
     AND ea.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
     AND ea.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   ORDER BY pt_loc, e.encntr_id
   HEAD REPORT
    cnt = 0
   HEAD pt_loc
    col + 0
   HEAD e.encntr_id
    stat = alterlist(dlrec->seq,request->visit_cnt), dlrec->seq[d.seq].encntr_id = request->visit[d
    .seq].encntr_id, dlrec->seq[d.seq].admit_dt = substring(1,14,format(e.reg_dt_tm,
      "@SHORTDATETIME;;Q")),
    dlrec->seq[d.seq].reason_for_visit = trim(e.reason_for_visit,3), dlrec->seq[d.seq].
    name_full_formatted = trim(p.name_full_formatted), dlrec->seq[d.seq].birth_dt_tm = p.birth_dt_tm,
    dlrec->seq[d.seq].account_nbr = ea.alias, dlrec->seq[d.seq].person_id = request->visit[d.seq].
    person_id
    IF (pa.person_alias_type_cd=mrn_cd)
     dlrec->seq[d.seq].mrn = pa.alias
    ELSEIF (pa.person_alias_type_cd=cmrn_cd)
     dlrec->seq[d.seq].cmrn = pa.alias
    ENDIF
    dlrec->seq[d.seq].nurse_unit = nurse_unit, dlrec->seq[d.seq].pt_loc = pt_loc, dlrec->seq[d.seq].
    isolation_disp = isolation_disp,
    dlrec->seq[d.seq].org_name = org.org_name
   FOOT  e.encntr_id
    stat = alterlist(dlrec->seq[d.seq].diagnosis,10), dlrec->seq[d.seq].diagnosis[1].diag_type_desc
     = "Reason For Visit", dlrec->seq[d.seq].diagnosis[1].source_string = e.reason_for_visit,
    dlrec->seq[d.seq].diagnosis[1].diag_dt_tm = substring(1,14,format(e.reg_dt_tm,"@SHORTDATETIME;;Q"
      )), dlrec->seq[d.seq].total_diag = 1
   FOOT  pt_loc
    col + 0
   FOOT REPORT
    IF ((request->visit_cnt > 0))
     stat = alterlist(dlrec->seq,request->visit_cnt), dlrec->encntr_total = request->visit_cnt
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   sort_order =
   IF (o.activity_type_cd=codestatus_cd) 1
   ELSE o.activity_type_cd
   ENDIF
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    orders o
   PLAN (dd)
    JOIN (o
    WHERE (o.encntr_id=dlrec->seq[dd.seq].encntr_id)
     AND o.order_status_cd IN (o_ordered_cd, o_completed_cd)
     AND o.template_order_flag IN (0, 1)
     AND o.activity_type_cd IN (codestatus_cd, isolation_cd))
   ORDER BY o.encntr_id, sort_order, cnvtdatetime(o.orig_order_dt_tm),
    o.order_id
   DETAIL
    IF (o.activity_type_cd=isolation_cd)
     dlrec->seq[dd.seq].isolation_disp = build("{b}",o.hna_order_mnemonic,":{endb} ",o
      .clinical_display_line)
    ELSE
     dlrec->seq[dd.seq].code_status = build("{b}",o.hna_order_mnemonic,":{endb} ",o
      .clinical_display_line)
    ENDIF
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   short_source_string = concat(trim(substring(1,40,n.source_string)),trim(substring(1,40,a
      .substance_ftdesc))), substance_type_disp =
   IF (uar_get_code_display(a.substance_type_cd) > " ") uar_get_code_display(a.substance_type_cd)
   ELSE "Other "
   ENDIF
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    allergy a,
    nomenclature n
   PLAN (dd)
    JOIN (a
    WHERE (a.person_id=dlrec->seq[dd.seq].person_id)
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
     AND a.reaction_status_cd != allergy_cancelled_cd)
    JOIN (n
    WHERE n.nomenclature_id=outerjoin(a.substance_nom_id))
   ORDER BY a.person_id, substance_type_disp, short_source_string
   HEAD a.person_id
    al = 0, stat = alterlist(dlrec->seq[dd.seq].allergy,10)
   DETAIL
    al = (al+ 1)
    IF (mod(al,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].allergy,(al+ 10))
    ENDIF
    dlrec->seq[dd.seq].allergy[al].source_string = short_source_string, dlrec->seq[dd.seq].allergy[al
    ].substance_type_disp = substance_type_disp, dlrec->seq[dd.seq].allergy[al].type_source_string =
    concat(build(substance_type_disp,": ")," ",short_source_string),
    dlrec->seq[dd.seq].allergy[al].source_string = short_source_string, dlrec->seq[dd.seq].allergy[al
    ].severity = uar_get_code_display(a.severity_cd), dlrec->seq[dd.seq].allergy[al].
    substance_type_disp = substance_type_disp,
    dlrec->seq[dd.seq].allergy[al].allergy_dt_tm = substring(1,14,format(a.updt_dt_tm,
      "@SHORTDATETIME;;Q"))
   FOOT  a.person_id
    IF (al > 0)
     stat = alterlist(dlrec->seq[dd.seq].allergy,al), dlrec->seq[dd.seq].total_al = al
    ENDIF
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   sort_order =
   IF (c.event_cd=authorizedtodiscusspatientshealth_cd) 10
   ELSEIF (c.event_cd=contactproxyphonenumber_cd) 9
   ELSEIF (c.event_cd=proxy_cd) 8
   ELSEIF (c.event_cd=advancedirective_cd) 7
   ELSEIF (c.event_cd=homephonenumber_cd) 6
   ELSEIF (c.event_cd=relationshiptopatient_cd) 5
   ELSEIF (c.event_cd=contactperson_cd) 4
   ELSEIF (c.event_cd=ispatientachronicco2retainer_cd) 3
   ELSEIF (c.event_cd=languagespoken_cd) 2
   ELSEIF (c.event_cd=fallsriskscore_cd) 1
   ELSE 999
   ENDIF
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    clinical_event c
   PLAN (dd)
    JOIN (c
    WHERE (c.person_id=dlrec->seq[dd.seq].person_id)
     AND c.event_cd IN (authorizedtodiscusspatientshealth_cd, contactproxyphonenumber_cd, proxy_cd,
    homephonenumber_cd, relationshiptopatient_cd,
    contactperson_cd, languagespoken_cd, fallsriskscore_cd)
     AND ((c.encntr_id+ 0)=dlrec->seq[dd.seq].encntr_id)
     AND c.view_level=1
     AND c.publish_flag=1
     AND c.valid_until_dt_tm=cnvtdatetime("31-dec-2100,00:00:00")
     AND  NOT (c.result_status_cd IN (inerror_cd, notdone_cd))
     AND c.event_tag > " ")
   ORDER BY c.encntr_id, sort_order, cnvtdatetime(c.event_end_dt_tm) DESC,
    c.parent_event_id
   HEAD c.encntr_id
    cnt = 0, last_event_cd = 0.0
   DETAIL
    IF (c.event_cd != last_event_cd)
     last_event_cd = c.event_cd, cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(dlrec->seq[dd.seq].section1_events,(cnt+ 9))
     ENDIF
     dlrec->seq[dd.seq].section1_events[cnt].event_type = c.event_tag, dlrec->seq[dd.seq].
     section1_events[cnt].event_cd = c.event_cd, dlrec->seq[dd.seq].section1_events[cnt].
     event_cd_disp = uar_get_code_display(c.event_cd),
     dlrec->seq[dd.seq].section1_events[cnt].event_dt_tm = substring(1,14,format(c.updt_dt_tm,
       "@SHORTDATETIME;;Q")), dlrec->seq[dd.seq].section1_events[cnt].result = build(c.result_val,
      uar_get_code_display(c.result_units_cd))
    ENDIF
   FOOT  c.encntr_id
    IF (cnt > 0)
     stat = alterlist(dlrec->seq[dd.seq].section1_events,cnt), dlrec->seq[dd.seq].section1_total =
     cnt
    ENDIF
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   d.encntr_id, diag_dt_tm = cnvtdatetime(d.diag_dt_tm), d.nomenclature_id,
   d.diagnosis_id
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    diagnosis d,
    nomenclature n
   PLAN (dd)
    JOIN (d
    WHERE (d.encntr_id=dlrec->seq[dd.seq].encntr_id)
     AND d.active_ind=1)
    JOIN (n
    WHERE n.nomenclature_id=outerjoin(d.nomenclature_id))
   ORDER BY d.encntr_id, diag_dt_tm DESC, d.nomenclature_id,
    d.diagnosis_id
   HEAD d.encntr_id
    cnt = 1
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1
     AND cnt != 1)
     stat = alterlist(dlrec->seq[dd.seq].diagnosis,(cnt+ 10))
    ENDIF
    IF (n.nomenclature_id > 0)
     dlrec->seq[dd.seq].diagnosis[cnt].source_string = n.source_string
    ELSE
     dlrec->seq[dd.seq].diagnosis[cnt].source_string = d.diag_ftdesc
    ENDIF
    dlrec->seq[dd.seq].diagnosis[cnt].diag_dt_tm = substring(1,14,format(d.diag_dt_tm,
      "@SHORTDATETIME;;Q")), dlrec->seq[dd.seq].diagnosis[cnt].diag_type_desc = uar_get_code_display(
     d.diag_type_cd)
   FOOT  d.encntr_id
    IF (cnt > 0)
     stat = alterlist(dlrec->seq[dd.seq].diagnosis,cnt), dlrec->seq[dd.seq].total_diag = cnt
    ENDIF
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    clinical_event c
   PLAN (dd)
    JOIN (c
    WHERE (dlrec->seq[dd.seq].person_id=c.person_id)
     AND c.event_cd=chiefcomplaint_cd
     AND (dlrec->seq[dd.seq].encntr_id=(c.encntr_id+ 0))
     AND c.view_level=1
     AND c.publish_flag=1
     AND c.valid_until_dt_tm=cnvtdatetime("31-dec-2100,00:00:00")
     AND  NOT (c.result_status_cd IN (inerror_cd, notdone_cd))
     AND c.event_tag > " ")
   ORDER BY c.encntr_id, cnvtdatetime(c.event_end_dt_tm)
   HEAD c.encntr_id
    col + 0
   DETAIL
    IF ((dlrec->seq[dd.seq].total_diag=0))
     cnt = 1, stat = alterlist(dlrec->seq[dd.seq].diagnosis,cnt), dlrec->seq[dd.seq].diagnosis[cnt].
     source_string = c.result_val,
     dlrec->seq[dd.seq].diagnosis[cnt].diag_dt_tm = substring(1,14,format(c.event_end_dt_tm,
       "@SHORTDATETIME;;Q")), dlrec->seq[dd.seq].diagnosis[cnt].diag_type_desc = uar_get_code_display
     (c.event_cd), dlrec->seq[dd.seq].total_diag = cnt
    ENDIF
   FOOT  c.encntr_id
    col + 0
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   sort_order =
   IF (c.event_cd=edc_cd) 1
   ELSEIF (c.event_cd=gravida_cd) 2
   ELSEIF (c.event_cd=term_cd) 3
   ELSEIF (c.event_cd=parity_cd) 4
   ELSEIF (c.event_cd=living_cd) 5
   ELSEIF (c.event_cd=abortion_cd) 6
   ELSEIF (c.event_cd=gestationalage_cd) 7
   ELSEIF (c.event_cd=deliverydate_cd) 8
   ELSEIF (c.event_cd=deliverytype_cd) 8
   ELSEIF (c.event_cd=birthweight_cd) 8
   ELSEIF (c.event_cd=code_cd) 8
   ELSEIF (c.event_cd=deliveredby_cd) 8
   ELSEIF (c.event_cd=placeofbirth_cd) 13
   ELSE 999
   ENDIF
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    clinical_event c,
    ce_date_result cd
   PLAN (dd)
    JOIN (c
    WHERE (dlrec->seq[dd.seq].person_id=c.person_id)
     AND c.event_cd IN (edc_cd, gravida_cd, term_cd, parity_cd, living_cd,
    abortion_cd, gestationalage_cd, deliverydate_cd, deliverytype_cd, birthweight_cd,
    code_cd, deliveredby_cd, placeofbirth_cd)
     AND (dlrec->seq[dd.seq].encntr_id=(c.encntr_id+ 0))
     AND c.view_level=1
     AND c.publish_flag=1
     AND c.valid_until_dt_tm=cnvtdatetime("31-dec-2100,00:00:00")
     AND  NOT (c.result_status_cd IN (inerror_cd, notdone_cd))
     AND c.event_tag > " ")
    JOIN (cd
    WHERE outerjoin(c.event_id)=cd.event_id
     AND c.valid_until_dt_tm=outerjoin(cnvtdatetime("31-dec-2100,00:00:00")))
   ORDER BY c.encntr_id, sort_order, c.parent_event_id,
    c.event_id
   HEAD c.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].section2_events,10)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].section2_events,(cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].section2_events[cnt].event_type = c.event_tag, dlrec->seq[dd.seq].
    section2_events[cnt].event_cd = c.event_cd, dlrec->seq[dd.seq].section2_events[cnt].event_cd_disp
     = uar_get_code_display(c.event_cd),
    dlrec->seq[dd.seq].section2_events[cnt].event_dt_tm = substring(1,14,format(c.updt_dt_tm,
      "@SHORTDATETIME;;Q")), dlrec->seq[dd.seq].section2_events[cnt].result = build(c.result_val,
     uar_get_code_display(c.result_units_cd)), dlrec->seq[dd.seq].section2_events[cnt].result = c
    .result_val
    IF (c.event_id=cd.event_id)
     CASE (cd.date_type_flag)
      OF 0:
       dlrec->seq[dd.seq].section2_events[cnt].result = format(cd.result_dt_tm,"mm/dd/yy hh:mm;;;d")
      OF 1:
       dlrec->seq[dd.seq].section2_events[cnt].result = format(cd.result_dt_tm,"mm/dd/yy;;;d")
      OF 2:
       dlrec->seq[dd.seq].section2_events[cnt].result = format(cd.result_dt_tm,"hh:mm;;;d")
     ENDCASE
    ENDIF
   FOOT  c.encntr_id
    IF (cnt > 0)
     stat = alterlist(dlrec->seq[dd.seq].section2_events,cnt), dlrec->seq[dd.seq].section2_total =
     cnt
    ENDIF
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   sort_order =
   IF (c.event_cd=height_cd) 1
   ELSEIF (c.event_cd=weight_cd) 2
   ELSEIF (c.event_cd=headcircumference_cd) 3
   ELSEIF (c.event_cd=abdominalgirth_cd) 4
   ELSEIF (c.event_cd=bodysurfacearea_cd) 5
   ELSEIF (c.event_cd=bodymassindex_cd) 6
   ELSEIF (c.event_cd=calfcircumference_cd) 7
   ELSEIF (c.event_cd=thighcircumference_cd) 8
   ELSE 99
   ENDIF
   FROM (dummyt dd  WITH seq = dlrec->seq, request->visit_cnt),
    clinical_event c,
    ce_date_result cdr
   PLAN (dd)
    JOIN (c
    WHERE (dlrec->seq[dd.seq].person_id=c.person_id)
     AND c.event_cd IN (thighcircumference_cd, calfcircumference_cd, bodymassindex_cd,
    bodysurfacearea_cd, abdominalgirth_cd,
    headcircumference_cd, weight_cd, height_cd)
     AND (dlrec->seq[dd.seq].encntr_id=(c.encntr_id+ 0))
     AND c.view_level=1
     AND c.publish_flag=1
     AND c.valid_until_dt_tm=cnvtdatetime("31-dec-2100,00:00:00")
     AND  NOT (c.result_status_cd IN (inerror_cd, notdone_cd))
     AND c.event_tag > " ")
    JOIN (cdr
    WHERE outerjoin(c.event_id)=cdr.event_id
     AND c.valid_until_dt_tm=outerjoin(cnvtdatetime("31-dec-2100,00:00:00")))
   ORDER BY c.encntr_id, sort_order, cnvtdatetime(c.event_end_dt_tm)
   HEAD c.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].section3_events,10)
   HEAD sort_order
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].section3_events,(cnt+ 10))
    ENDIF
   DETAIL
    dlrec->seq[dd.seq].section3_events[cnt].event_type = c.event_tag, dlrec->seq[dd.seq].
    section3_events[cnt].event_cd = c.event_cd, dlrec->seq[dd.seq].section3_events[cnt].event_cd_disp
     = uar_get_code_display(c.event_cd),
    dlrec->seq[dd.seq].section3_events[cnt].event_dt_tm = substring(1,14,format(c.event_end_dt_tm,
      "@SHORTDATETIME;;Q"))
    IF (cdr.event_id > 0.0)
     dlrec->seq[dd.seq].section3_events[cnt].result = substring(1,14,format(cdr.result_dt_tm,
       "@SHORTDATETIME;;Q"))
    ELSE
     dlrec->seq[dd.seq].section3_events[cnt].result = concat(substring(1,14,format(c.event_end_dt_tm,
        "@SHORTDATETIME;;Q"))," ",trim(c.result_val,3)," ",uar_get_code_display(c.result_units_cd))
    ENDIF
   FOOT  sort_order
    col + 0
   FOOT  c.encntr_id
    IF (cnt > 0)
     stat = alterlist(dlrec->seq[dd.seq].section3_events,cnt), dlrec->seq[dd.seq].section3_total =
     cnt
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   sort_order =
   IF (o.activity_type_cd=rntorn_cd) 1
   ELSEIF (o.activity_type_cd=callmd_cd) 2
   ELSEIF (o.activity_type_cd=communicationorders_cd) 3
   ELSEIF (o.activity_type_cd=admittransferdischarge_cd) 4
   ELSE 99
   ENDIF
   FROM (dummyt dd  WITH seq = value(request->visit_cnt)),
    orders o
   PLAN (dd)
    JOIN (o
    WHERE (o.encntr_id=request->visit[dd.seq].encntr_id)
     AND o.order_status_cd IN (o_incomplete_cd, o_inprocess_cd, o_ordered_cd, o_pending_cd,
    o_pending_rev_cd)
     AND o.template_order_flag IN (0, 1)
     AND o.activity_type_cd IN (admittransferdischarge_cd, communicationorders_cd, callmd_cd,
    rntorn_cd))
   ORDER BY o.encntr_id, sort_order, cnvtdatetime(o.orig_order_dt_tm),
    o.order_id
   HEAD o.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].orders35,10)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].orders35,(cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].orders35[cnt].order_mnemonic = o.order_mnemonic, dlrec->seq[dd.seq].orders35[
    cnt].clinical_display_line = o.clinical_display_line, dlrec->seq[dd.seq].orders35[cnt].
    order_comment_ind = o.order_comment_ind
   FOOT  o.encntr_id
    IF (cnt > 0)
     stat = alterlist(dlrec->seq[dd.seq].orders35,cnt), dlrec->seq[dd.seq].orders35_total = cnt
    ENDIF
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   sort_order =
   IF (c.event_cd=nursecommunicationnutrition_cd) 32
   ELSEIF (c.event_cd=cardiacrehabnursecommunication_cd) 31
   ELSEIF (c.event_cd=nursecommunicationrehab_cd) 30
   ELSEIF (c.event_cd=nursecommunicationpulmonaryrehab_cd) 29
   ELSEIF (c.event_cd=nursecommunicationsocialservices_cd) 28
   ELSEIF (c.event_cd=agencycontactperson_cd) 27
   ELSEIF (c.event_cd=servicefrequency_cd) 26
   ELSEIF (c.event_cd=equipment_cd) 25
   ELSEIF (c.event_cd=servicecategories_cd) 24
   ELSEIF (c.event_cd=portableunitrequired_cd) 23
   ELSEIF (c.event_cd=patientgoinghomeonoxygen_cd) 22
   ELSEIF (c.event_cd=currenthometreatments_cd) 21
   ELSEIF (c.event_cd=currenthomeservices_cd) 20
   ELSEIF (c.event_cd=medicalequipmentcompanies_cd) 19
   ELSEIF (c.event_cd=jail_cd) 18
   ELSEIF (c.event_cd=fostercare_cd) 17
   ELSEIF (c.event_cd=ambulanceservices_cd) 16
   ELSEIF (c.event_cd=modeoftransportationarranged_cd) 15
   ELSEIF (c.event_cd=confirmedtransferstarttimedate_cd) 14
   ELSEIF (c.event_cd=pulmonarynurseappointment_cd) 13
   ELSEIF (c.event_cd=earlyinterventionprograms_cd) 12
   ELSEIF (c.event_cd=vnahospicehomecare_cd) 11
   ELSEIF (c.event_cd=adultdayhealthcare_cd) 10
   ELSEIF (c.event_cd=resthomescommunityresidencesshelters_cd) 9
   ELSEIF (c.event_cd=nursinghomesskilledrehabfacilities_cd) 8
   ELSEIF (c.event_cd=chronichospital_cd) 7
   ELSEIF (c.event_cd=dischargemedicalequipmentcompanies_cd) 6
   ELSEIF (c.event_cd=dischargeearlyinterventionprograms_cd) 5
   ELSEIF (c.event_cd=dischargevnahospicehomecare_cd) 4
   ELSEIF (c.event_cd=dischargeadultdayhealthcare_cd) 3
   ELSEIF (c.event_cd=dischargeresthomesresidencesshelters_cd) 2
   ELSEIF (c.event_cd=dischargenursinghomesrehabfacilities_cd) 1
   ELSE 9999
   ENDIF
   FROM (dummyt dd  WITH seq = dlrec->seq, request->visit_cnt),
    clinical_event c,
    ce_date_result cd
   PLAN (dd)
    JOIN (c
    WHERE (dlrec->seq[dd.seq].person_id=c.person_id)
     AND c.event_cd IN (nursecommunicationnutrition_cd, cardiacrehabnursecommunication_cd,
    nursecommunicationrehab_cd, nursecommunicationpulmonaryrehab_cd,
    nursecommunicationsocialservices_cd,
    agencycontactperson_cd, portableunitrequired_cd, patientgoinghomeonoxygen_cd,
    confirmedtransferstarttimedate_cd, pulmonarynurseappointment_cd,
    earlyinterventionprograms_cd, vnahospicehomecare_cd, adultdayhealthcare_cd,
    resthomescommunityresidencesshelters_cd, nursinghomesskilledrehabfacilities_cd,
    chronichospital_cd, dischargenursinghomesrehabfacilities_cd,
    dischargeresthomesresidencesshelters_cd, dischargeadultdayhealthcare_cd,
    dischargevnahospicehomecare_cd,
    dischargeearlyinterventionprograms_cd, dischargemedicalequipmentcompanies_cd)
     AND (dlrec->seq[dd.seq].encntr_id=(c.encntr_id+ 0))
     AND c.view_level=1
     AND c.publish_flag=1
     AND c.valid_until_dt_tm=cnvtdatetime("31-dec-2100,00:00:00")
     AND  NOT (c.result_status_cd IN (inerror_cd, notdone_cd))
     AND c.event_tag > " ")
    JOIN (cd
    WHERE outerjoin(c.event_id)=cd.event_id
     AND c.valid_until_dt_tm=outerjoin(cnvtdatetime("31-dec-2100,00:00:00")))
   ORDER BY c.encntr_id, sort_order, cnvtdatetime(c.event_end_dt_tm),
    c.event_id
   HEAD c.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].section4_events,10)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].section4_events,(cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].section4_events[cnt].event_type = c.event_tag, dlrec->seq[dd.seq].
    section4_events[cnt].event_cd = c.event_cd, dlrec->seq[dd.seq].section4_events[cnt].event_cd_disp
     = uar_get_code_display(c.event_cd),
    dlrec->seq[dd.seq].section4_events[cnt].event_dt_tm = substring(1,14,format(c.event_end_dt_tm,
      "@SHORTDATETIME;;Q")), dlrec->seq[dd.seq].section4_events[cnt].result = c.result_val
    IF (c.event_id=cd.event_id)
     CASE (cd.date_type_flag)
      OF 0:
       dlrec->seq[dd.seq].section4_events[cnt].result = format(cd.result_dt_tm,"mm/dd/yy hh:mm;;;d")
      OF 1:
       dlrec->seq[dd.seq].section4_events[cnt].result = format(cd.result_dt_tm,"mm/dd/yy;;;d")
      OF 2:
       dlrec->seq[dd.seq].section4_events[cnt].result = format(cd.result_dt_tm,"hh:mm;;;d")
     ENDCASE
    ENDIF
   FOOT  c.encntr_id
    IF (cnt > 0)
     stat = alterlist(dlrec->seq[dd.seq].section4_events,cnt), dlrec->seq[dd.seq].section4_total =
     cnt
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt dd  WITH seq = value(request->visit_cnt)),
    orders o
   PLAN (dd)
    JOIN (o
    WHERE (o.encntr_id=request->visit[dd.seq].encntr_id)
     AND o.order_status_cd IN (o_incomplete_cd, o_inprocess_cd, o_ordered_cd, o_pending_cd,
    o_pending_rev_cd)
     AND o.template_order_flag IN (0, 1)
     AND o.catalog_type_cd=dietary_cd)
   ORDER BY o.encntr_id, cnvtdatetime(o.orig_order_dt_tm), o.order_id
   HEAD o.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].diet,10)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].diet,(cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].diet[cnt].order_mnemonic = o.order_mnemonic, dlrec->seq[dd.seq].diet[cnt].
    clinical_display_line = o.clinical_display_line, dlrec->seq[dd.seq].diet[cnt].order_comment_ind
     = o.order_comment_ind
   FOOT  o.encntr_id
    IF (cnt > 0)
     stat = alterlist(dlrec->seq[dd.seq].diet,cnt), dlrec->seq[dd.seq].diet_total = cnt
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt dd  WITH seq = value(request->visit_cnt)),
    orders o
   PLAN (dd)
    JOIN (o
    WHERE (o.encntr_id=request->visit[dd.seq].encntr_id)
     AND o.order_status_cd IN (o_incomplete_cd, o_inprocess_cd, o_ordered_cd, o_pending_cd,
    o_pending_rev_cd)
     AND o.template_order_flag IN (0, 1)
     AND ((o.catalog_type_cd=respther_cd) OR (o.activity_type_cd=nsgrespiratorytx_cd)) )
   ORDER BY o.encntr_id, cnvtdatetime(o.orig_order_dt_tm), o.order_id
   HEAD o.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].resp,10)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].resp,(cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].resp[cnt].order_mnemonic = o.order_mnemonic, dlrec->seq[dd.seq].resp[cnt].
    clinical_display_line = o.clinical_display_line, dlrec->seq[dd.seq].resp[cnt].order_comment_ind
     = o.order_comment_ind
   FOOT  o.encntr_id
    IF (cnt > 0)
     stat = alterlist(dlrec->seq[dd.seq].resp,cnt), dlrec->seq[dd.seq].resp_total = cnt
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   sort_order =
   IF (o.activity_type_cd=asmttxmonitoring_cd) 1
   ELSEIF (o.activity_type_cd=orthosupply_cd) 3
   ELSEIF (o.activity_type_cd=orthopedictreatments_cd) 4
   ELSEIF (o.activity_type_cd=woundcare_cd) 5
   ELSEIF (o.activity_type_cd=intakeandoutput_cd) 6
   ENDIF
   FROM (dummyt dd  WITH seq = value(request->visit_cnt)),
    orders o
   PLAN (dd)
    JOIN (o
    WHERE (o.encntr_id=request->visit[dd.seq].encntr_id)
     AND o.order_status_cd IN (o_incomplete_cd, o_inprocess_cd, o_ordered_cd, o_pending_cd,
    o_pending_rev_cd)
     AND o.template_order_flag IN (0, 1)
     AND o.activity_type_cd IN (woundcare_cd, orthopedictreatments_cd, orthosupply_cd,
    asmttxmonitoring_cd, intakeandoutput_cd))
   ORDER BY o.encntr_id, sort_order, cnvtdatetime(o.orig_order_dt_tm),
    o.order_id
   HEAD o.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].asmt,10)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].asmt,(cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].asmt[cnt].order_mnemonic = o.order_mnemonic, dlrec->seq[dd.seq].asmt[cnt].
    clinical_display_line = o.clinical_display_line, dlrec->seq[dd.seq].asmt[cnt].order_comment_ind
     = o.order_comment_ind
   FOOT  o.encntr_id
    IF (cnt > 0)
     stat = alterlist(dlrec->seq[dd.seq].asmt,cnt), dlrec->seq[dd.seq].asmt_total = cnt
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   sort_order =
   IF (o.activity_type_cd=bloodbankproduct_cd) 1
   ELSEIF (o.activity_type_cd=invasivelinestubesdrains_cd) 2
   ELSE 99
   ENDIF
   FROM (dummyt dd  WITH seq = value(request->visit_cnt)),
    orders o
   PLAN (dd)
    JOIN (o
    WHERE (o.encntr_id=request->visit[dd.seq].encntr_id)
     AND o.order_status_cd IN (o_incomplete_cd, o_inprocess_cd, o_ordered_cd, o_pending_cd,
    o_pending_rev_cd)
     AND o.template_order_flag IN (0, 1)
     AND o.activity_type_cd IN (bloodbankproduct_cd, invasivelinestubesdrains_cd))
   ORDER BY o.encntr_id, sort_order, cnvtdatetime(o.orig_order_dt_tm),
    o.order_id
   HEAD o.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].ltd,10)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].ltd,(cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].ltd[cnt].order_mnemonic = o.order_mnemonic, dlrec->seq[dd.seq].ltd[cnt].
    clinical_display_line = o.clinical_display_line, dlrec->seq[dd.seq].ltd[cnt].order_comment_ind =
    o.order_comment_ind
   FOOT  o.encntr_id
    IF (cnt > 0)
     stat = alterlist(dlrec->seq[dd.seq].ltd,cnt), dlrec->seq[dd.seq].ltd_total = cnt
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl"
   p.problem_id, problem = build(p.problem_ftdesc,n.source_string)
   FROM (dummyt d  WITH seq = value(dlrec->encntr_total)),
    problem p,
    nomenclature n
   PLAN (d)
    JOIN (p
    WHERE (p.person_id=dlrec->seq[d.seq].person_id)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null))
    )
    JOIN (n
    WHERE n.nomenclature_id=outerjoin(p.nomenclature_id)
     AND n.source_vocabulary_cd=snmct_cd)
   ORDER BY p.person_id, cnvtdatetime(p.onset_dt_tm) DESC
   HEAD p.person_id
    cnt = 0, stat = alterlist(dlrec->seq[d.seq].problem,10)
   DETAIL
    IF (((n.source_string > " ") OR (p.problem_ftdesc > " ")) )
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(dlrec->seq[d.seq].problem,(cnt+ 10))
     ENDIF
     IF (p.nomenclature_id > 0)
      dlrec->seq[d.seq].problem[cnt].text = n.source_string
     ELSE
      dlrec->seq[d.seq].problem[cnt].text = p.problem_ftdesc
     ENDIF
     dlrec->seq[d.seq].problem[cnt].status = uar_get_code_display(p.life_cycle_status_cd), dlrec->
     seq[d.seq].problem[cnt].beg_effective_dt_tm = substring(1,14,format(p.beg_effective_dt_tm,
       "@SHORTDATETIME;;Q")), dlrec->seq[d.seq].problem[cnt].full_text = build(dlrec->seq[d.seq].
      problem[cnt].status,": ",dlrec->seq[d.seq].problem[cnt].text)
    ENDIF
   FOOT  p.person_id
    IF (cnt > 0)
     dlrec->seq[d.seq].problem_total = cnt, stat = alterlist(dlrec->seq[d.seq].problem,cnt)
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    orders o,
    order_action oa,
    prsnl p,
    prsnl p2,
    clinical_event c
   PLAN (dd)
    JOIN (o
    WHERE (o.encntr_id=dlrec->seq[dd.seq].encntr_id)
     AND o.catalog_type_cd=laboratory_cd
     AND o.activity_type_cd=generallab_cd
     AND o.template_order_flag IN (0, 1))
    JOIN (oa
    WHERE outerjoin(o.order_id)=oa.order_id
     AND outerjoin(order_cd)=oa.action_type_cd)
    JOIN (p
    WHERE outerjoin(oa.action_personnel_id)=p.person_id)
    JOIN (p2
    WHERE outerjoin(oa.order_provider_id)=p2.person_id)
    JOIN (c
    WHERE c.order_id=o.order_id
     AND c.view_level=1
     AND c.publish_flag=1
     AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND c.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime)
     AND c.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
     AND  NOT (c.result_status_cd IN (inerror_cd, notdone_cd)))
   ORDER BY c.encntr_id, cnvtdatetime(c.event_end_dt_tm), c.parent_event_id
   HEAD REPORT
    cnt = 0
   HEAD c.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].labs,10)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].labs,(cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].labs[cnt].parent_event_id = c.parent_event_id, dlrec->seq[dd.seq].labs[cnt].
    event_cd_disp = uar_get_code_display(c.event_cd), dlrec->seq[dd.seq].labs[cnt].result_val = build
    (c.result_val,uar_get_code_display(c.normalcy_cd)),
    dlrec->seq[dd.seq].labs[cnt].date = format(c.event_end_dt_tm,"mm/dd/yy hh:mm;;d"), dlrec->seq[dd
    .seq].labs[cnt].result_units_disp = uar_get_code_display(c.result_units_cd), dlrec->seq[dd.seq].
    labs[cnt].normalcy_disp = uar_get_code_display(c.normalcy_cd)
    IF (c.normal_low > " "
     AND c.normal_high > " ")
     dlrec->seq[dd.seq].labs[cnt].reference_range = build("(",c.normal_low,"-",c.normal_high,
      uar_get_code_display(c.result_units_cd),
      ")")
    ELSE
     dlrec->seq[dd.seq].labs[cnt].reference_range = "(Nrml rng unspecfd)"
    ENDIF
    dlrec->seq[dd.seq].labs[cnt].order_person = p.name_first, dlrec->seq[dd.seq].labs[cnt].
    order_doctor = p2.name_last
   FOOT  c.encntr_id
    IF (cnt > 0)
     stat = alterlist(dlrec->seq[dd.seq].labs,cnt), dlrec->seq[dd.seq].number_of_labs = cnt
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   sort_order =
   IF (o.activity_type_cd=anatomicpathology_cd) 1
   ELSEIF (o.activity_type_cd=bloodbank_cd) 2
   ELSEIF (o.activity_type_cd=bloodbankmlh_cd) 3
   ELSEIF (o.activity_type_cd=cardiactxprocedures_cd) 4
   ELSEIF (o.activity_type_cd=ecg_cd) 5
   ELSEIF (o.activity_type_cd=generallab_cd) 6
   ELSEIF (o.activity_type_cd=micro_cd) 7
   ELSEIF (o.activity_type_cd=pointofcare_cd) 8
   ELSE 99
   ENDIF
   FROM (dummyt dd  WITH seq = value(request->visit_cnt)),
    orders o
   PLAN (dd)
    JOIN (o
    WHERE (o.encntr_id=request->visit[dd.seq].encntr_id)
     AND o.order_status_cd IN (o_incomplete_cd, o_inprocess_cd, o_ordered_cd, o_pending_cd,
    o_pending_rev_cd)
     AND o.template_order_flag IN (0, 1)
     AND ((o.catalog_type_cd=radiology_cd) OR (o.activity_type_cd IN (anatomicpathology_cd,
    bloodbank_cd, bloodbankmlh_cd, cardiactxprocedures_cd, ecg_cd,
    generallab_cd, micro_cd, pointofcare_cd))) )
   ORDER BY o.encntr_id, sort_order, cnvtdatetime(o.orig_order_dt_tm),
    o.order_id
   HEAD o.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].orders,10)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].rorders,(cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].rorders[cnt].order_mnemonic = o.order_mnemonic, dlrec->seq[dd.seq].rorders[cnt
    ].clinical_display_line = o.clinical_display_line, dlrec->seq[dd.seq].rorders[cnt].
    order_comment_ind = o.order_comment_ind
   FOOT  o.encntr_id
    IF (cnt > 0)
     stat = alterlist(dlrec->seq[dd.seq].rorders,cnt), dlrec->seq[dd.seq].rorders_total = cnt
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   sort_order =
   IF (o.catalog_type_cd=physther_cd) 1
   ELSEIF (o.catalog_type_cd=occther_cd) 2
   ELSEIF (o.catalog_type_cd=speechther_cd) 3
   ELSEIF (o.catalog_type_cd=audiology_cd) 4
   ELSEIF (o.catalog_type_cd=antepartum_cd) 5
   ELSEIF (o.activity_type_cd=consults_cd) 6
   ELSEIF (o.activity_type_cd=mdtornconsults_cd) 7
   ELSEIF (o.catalog_type_cd=neurodiag_cd) 8
   ELSEIF (o.catalog_type_cd=pulmlab_cd) 9
   ELSEIF (o.activity_type_cd=hyperbaricoxygentx_cd) 10
   ELSEIF (o.activity_type_cd=noninvasivecardiologytxprocedures_cd) 11
   ELSEIF (o.activity_type_cd=mdtorntxprocedures_cd) 12
   ELSE 99
   ENDIF
   FROM (dummyt dd  WITH seq = value(request->visit_cnt)),
    orders o
   PLAN (dd)
    JOIN (o
    WHERE (o.encntr_id=request->visit[dd.seq].encntr_id)
     AND o.order_status_cd IN (o_incomplete_cd, o_inprocess_cd, o_ordered_cd, o_pending_cd,
    o_pending_rev_cd)
     AND o.template_order_flag IN (0, 1)
     AND ((o.catalog_type_cd IN (physther_cd, occther_cd, speechther_cd, audiology_cd, antepartum_cd,
    neurodiag_cd, pulmlab_cd)) OR (o.activity_type_cd IN (noninvasivecardiologytxprocedures_cd,
    hyperbaricoxygentx_cd, mdtornconsults_cd, consults_cd, mdtorntxprocedures_cd))) )
   ORDER BY o.encntr_id, sort_order, cnvtdatetime(o.orig_order_dt_tm),
    o.order_id
   HEAD o.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].cporders,10)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].cporders,(cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].cporders[cnt].order_mnemonic = o.order_mnemonic, dlrec->seq[dd.seq].cporders[
    cnt].clinical_display_line = o.clinical_display_line, dlrec->seq[dd.seq].cporders[cnt].
    order_comment_ind = o.order_comment_ind
   FOOT  o.encntr_id
    IF (cnt > 0)
     stat = alterlist(dlrec->seq[dd.seq].cporders,cnt), dlrec->seq[dd.seq].cporders_total = cnt
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   mso =
   IF (((o.med_order_type_cd IN (iv_cd, intermittent_cd)) OR (o.dcp_clin_cat_cd=ivsolutions_cd)) ) 4
   ELSEIF (o.prn_ind=0
    AND o.freq_type_flag != 5) 1
   ELSEIF (o.prn_ind=0
    AND o.freq_type_flag=5) 2
   ELSEIF (o.prn_ind=1) 3
   ENDIF
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    orders o,
    order_action oa,
    prsnl p,
    prsnl p2,
    order_detail od
   PLAN (dd)
    JOIN (o
    WHERE (o.encntr_id=dlrec->seq[dd.seq].encntr_id)
     AND o.catalog_type_cd=pharmacy_cattyp_cd
     AND o.order_status_cd IN (o_incomplete_cd, o_inprocess_cd, o_ordered_cd, o_pending_cd,
    o_pending_rev_cd)
     AND o.template_order_flag IN (0, 1)
     AND  NOT (o.orig_ord_as_flag IN (1, 2)))
    JOIN (oa
    WHERE outerjoin(o.order_id)=oa.order_id
     AND outerjoin(order_cd)=oa.action_type_cd)
    JOIN (p
    WHERE outerjoin(oa.action_personnel_id)=p.person_id)
    JOIN (p2
    WHERE outerjoin(oa.order_provider_id)=p2.person_id)
    JOIN (od
    WHERE od.order_id=o.order_id
     AND od.oe_field_meaning IN ("FREQ", "FREETXTDOSE", "DOSE", "DOSEUNIT", "NEXTDOSEDTTM"))
   ORDER BY o.encntr_id, mso, o.incomplete_order_ind,
    o.hna_order_mnemonic, cnvtdatetime(o.orig_order_dt_tm), od.action_sequence
   HEAD REPORT
    cnt = 0
   HEAD o.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].meds,10)
   HEAD mso
    col + 0
   HEAD o.hna_order_mnemonic
    col + 0
   HEAD o.order_id
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].meds,(cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].meds[cnt].mso = mso, dlrec->seq[dd.seq].meds[cnt].ioi = o.incomplete_order_ind,
    dlrec->seq[dd.seq].meds[cnt].mnemonic = o.hna_order_mnemonic,
    dlrec->seq[dd.seq].meds[cnt].ordered_as_mnemonic = o.ordered_as_mnemonic, dlrec->seq[dd.seq].
    meds[cnt].order_comment_ind = o.order_comment_ind, dlrec->seq[dd.seq].meds[cnt].display_line = o
    .clinical_display_line,
    dlrec->seq[dd.seq].meds[cnt].date = format(o.orig_order_dt_tm,"mm/dd/yy hh:mm;;d"), dlrec->seq[dd
    .seq].meds[cnt].order_status_disp = uar_get_code_display(o.order_status_cd), dlrec->seq[dd.seq].
    meds[cnt].need_rx_verify_ind = o.need_rx_verify_ind
    CASE (o.need_rx_verify_ind)
     OF 0:
      dlrec->seq[dd.seq].meds[cnt].need_rx_verify_str = "(Verified)"
     OF 1:
      dlrec->seq[dd.seq].meds[cnt].need_rx_verify_str = "(Unverified)"
     OF 2:
      dlrec->seq[dd.seq].meds[cnt].need_rx_verify_str = "(Rejected)"
    ENDCASE
   DETAIL
    IF (od.oe_field_meaning="FREQ")
     dlrec->seq[dd.seq].meds[cnt].freq = od.oe_field_display_value
    ELSEIF (od.oe_field_meaning IN ("FREETXTDOSE", "DOSE"))
     dlrec->seq[dd.seq].meds[cnt].dose = od.oe_field_display_value
    ELSEIF (od.oe_field_meaning="DOSEUNIT")
     dlrec->seq[dd.seq].meds[cnt].doseunit = od.oe_field_display_value
    ELSEIF (od.oe_field_meaning="NEXTDOSEDTTM")
     dlrec->seq[dd.seq].meds[cnt].next_dose_dt_tm = od.oe_field_display_value
    ENDIF
    IF (p.name_first > " ")
     dlrec->seq[dd.seq].meds[cnt].order_person = p.name_first
    ENDIF
    IF (p2.name_last > " ")
     dlrec->seq[dd.seq].meds[cnt].order_doctor = p2.name_full_formatted
    ENDIF
   FOOT  o.order_id
    IF ((dlrec->seq[dd.seq].meds[cnt].dose > " ")
     AND (dlrec->seq[dd.seq].meds[cnt].doseunit > " "))
     dlrec->seq[dd.seq].meds[cnt].dose = concat(trim(dlrec->seq[dd.seq].meds[cnt].dose)," ",trim(
       dlrec->seq[dd.seq].meds[cnt].doseunit))
    ENDIF
   FOOT  o.hna_order_mnemonic
    col + 0
   FOOT  mso
    col + 0
   FOOT  o.encntr_id
    IF (cnt > 0)
     dlrec->seq[dd.seq].number_of_meds = cnt, stat = alterlist(dlrec->seq[dd.seq].meds,cnt)
    ENDIF
   FOOT REPORT
    col + 0
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    encntr_prsnl_reltn epr,
    prsnl pl,
    prsnl_alias pla
   PLAN (dd)
    JOIN (epr
    WHERE (epr.encntr_id=dlrec->seq[dd.seq].encntr_id)
     AND epr.active_ind=1
     AND epr.encntr_prsnl_r_cd IN (attenddoc_cd, admitdoc_cd))
    JOIN (pl
    WHERE pl.person_id=outerjoin(epr.prsnl_person_id))
    JOIN (pla
    WHERE pla.person_id=outerjoin(pl.person_id))
   DETAIL
    IF (epr.encntr_prsnl_r_cd=attenddoc_cd)
     dlrec->seq[dd.seq].attenddoc_name = pl.name_full_formatted, dlrec->seq[dd.seq].attenddoc_alias
      = pla.alias
    ELSE
     dlrec->seq[dd.seq].admitdoc_name = pl.name_full_formatted, dlrec->seq[dd.seq].admitdoc_alias =
     pla.alias
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(dlrec->encntr_total)),
    prsnl pl2,
    person_prsnl_reltn ppr,
    prsnl_alias pla
   PLAN (d)
    JOIN (ppr
    WHERE (dlrec->seq[d.seq].person_id=ppr.person_id)
     AND ppr.person_prsnl_r_cd=pcp_cd
     AND ppr.active_ind=1
     AND ppr.beg_effective_dt_tm <= cnvtdatetime((curdate+ 1),curtime3)
     AND ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (pl2
    WHERE ppr.prsnl_person_id=pl2.person_id)
    JOIN (pla
    WHERE pla.person_id=outerjoin(pl2.person_id))
   DETAIL
    dlrec->seq[d.seq].pcpdoc_name = pl2.name_full_formatted, dlrec->seq[d.seq].pcpdoc_alias = pla
    .alias
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   FROM (dummyt dd  WITH seq = value(request->visit_cnt)),
    clinical_event c,
    ce_date_result cd,
    bhs_events be,
    clinical_event c2
   PLAN (dd)
    JOIN (c
    WHERE (dlrec->seq[dd.seq].person_id=c.person_id)
     AND (dlrec->seq[dd.seq].encntr_id=c.encntr_id)
     AND c.publish_flag=1
     AND c.valid_until_dt_tm=cnvtdatetime("31-dec-2100,00:00:00")
     AND  NOT (c.result_status_cd IN (inerror_cd, notdone_cd))
     AND c.event_tag > " "
     AND c.event_cd != dcpgenericcode_cd)
    JOIN (cd
    WHERE outerjoin(c.event_id)=cd.event_id
     AND c.valid_until_dt_tm=outerjoin(cnvtdatetime("31-dec-2100,00:00:00")))
    JOIN (be
    WHERE c.event_cd=be.event_cd)
    JOIN (c2
    WHERE outerjoin(c.parent_event_id)=c2.event_id)
   ORDER BY c.encntr_id, be.event_seq, cnvtdatetime(c.event_end_dt_tm),
    c.event_id
   HEAD c.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].d0events,10)
   HEAD be.event_seq
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].d0events,(cnt+ 10))
    ENDIF
   DETAIL
    dlrec->seq[dd.seq].d0events[cnt].event_type = c.event_tag, dlrec->seq[dd.seq].d0events[cnt].
    event_cd = c.event_cd, dlrec->seq[dd.seq].d0events[cnt].event_id = c.event_id,
    dlrec->seq[dd.seq].d0events[cnt].event_seq = be.event_seq, dlrec->seq[dd.seq].d0events[cnt].
    header1_txt = be.header1_txt, dlrec->seq[dd.seq].d0events[cnt].header2_txt = be.header2_txt
    IF (c2.event_cd=dcpgenericcode_cd)
     dlrec->seq[dd.seq].d0events[cnt].parent_event = ""
    ELSE
     dlrec->seq[dd.seq].d0events[cnt].parent_event = uar_get_code_display(c2.event_cd)
    ENDIF
    dlrec->seq[dd.seq].d0events[cnt].event_cd_disp = uar_get_code_display(c.event_cd), dlrec->seq[dd
    .seq].d0events[cnt].event_dt_tm = substring(1,14,format(c.event_end_dt_tm,"@SHORTDATETIME;;Q")),
    dlrec->seq[dd.seq].d0events[cnt].result = c.result_val
    IF (c.event_id=cd.event_id)
     CASE (cd.date_type_flag)
      OF 0:
       dlrec->seq[dd.seq].d0events[cnt].result = format(cd.result_dt_tm,"mm/dd/yy hh:mm;;;d")
      OF 1:
       dlrec->seq[dd.seq].d0events[cnt].result = format(cd.result_dt_tm,"mm/dd/yy;;;d")
      OF 2:
       dlrec->seq[dd.seq].d0events[cnt].result = format(cd.result_dt_tm,"hh:mm;;;d")
     ENDCASE
    ENDIF
   FOOT  be.event_seq
    col + 0
   FOOT  c.encntr_id
    IF (cnt > 0)
     stat = alterlist(dlrec->seq[dd.seq].d0events,cnt), dlrec->seq[dd.seq].d0events_total = cnt
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO request->output_device
   encntr_id = dlrec->seq[d1.seq].encntr_id
   FROM (dummyt d1  WITH seq = value(dlrec->encntr_total))
   HEAD REPORT
    end_report_flag = 0, "{f/8}{cpi/14}{lpi/8}", row + 1,
    yrow1 = 5, breakflag = 1, xcol1 = 26,
    xcol2 = 38, xcol3 = 86, xcol4 = 158,
    xcol5 = 228, xcol6 = 273, xcol7 = 308,
    xcol8 = 388, xcol9 = 428, xcol10 = 433,
    xcol11 = 467, xcol12 = 540, wrapcol = 122,
    mso[5] = "Unknown             ", mso[4] = "Continuous Infusions", mso[3] = "PRN                 ",
    mso[2] = "Unscheduled         ", mso[1] = "Scheduled           ", lcol1[2] = 0,
    lcol2[2] = 0, lcol3[2] = 0, gap = 85,
    lcol1[1] = xcol1, lcol2[1] = (lcol1[1]+ gap), lcol3[1] = (lcol2[1]+ gap),
    lcol1[2] = (lcol3[1]+ gap), lcol2[2] = (lcol1[2]+ gap), lcol3[2] = (lcol2[2]+ gap),
    printer_disp = request->output_device
    IF (printer_disp="cer_temp:*")
     printer_disp = "Screen"
    ENDIF
    MACRO (title_print)
     CALL print(calcpos(xcol1,yrow1)), "{color/19}", equal_line,
     "{color/0}", row + 1, yrow1 = (yrow1+ 12),
     CALL print(calcpos(xcol1,yrow1)), "{b}", title_string,
     "{endb}", last_title = title_string, rowplusone2
    ENDMACRO
    ,
    MACRO (calcpos_print)
     maxpos = (colpos+ size(trim(tempstring)))
     IF (maxpos > 80)
      row + 1, colpos = 20, col colpos,
      "{color/0}", tempstring
     ELSE
      col colpos, tempstring, "\"
     ENDIF
     colpos = ((colpos+ size(trim(tempstring)))+ 1)
    ENDMACRO
    ,
    MACRO (rowplusone)
     yrow1 = (yrow1+ 10), row + 1
     IF (yrow1 > 600)
      BREAK, yrow1 = 105
     ENDIF
    ENDMACRO
    ,
    MACRO (rowplusone2)
     yrow1 = (yrow1+ 10), row + 1
    ENDMACRO
    ,
    MACRO (line_wrap2)
     limit = 0, maxlen = 80, cr = char(13)
     WHILE (tempstring > " "
      AND limit < 1000)
       ii = 0, limit = (limit+ 1), pos = 0
       WHILE (pos=0)
        ii = (ii+ 1),
        IF (substring((maxlen - ii),1,tempstring) IN (" ", cr))
         pos = (maxlen - ii)
        ELSEIF (ii=maxlen)
         pos = maxlen
        ENDIF
       ENDWHILE
       printstring = substring(1,pos,tempstring),
       CALL print(calcpos(xcolvar,yrow1)), printstring,
       rowplusone, tempstring = substring((pos+ 1),9999,tempstring)
     ENDWHILE
    ENDMACRO
    ,
    MACRO (line_wrap)
     limit = 0, maxlen = wrapcol, cr = char(10)
     WHILE (tempstring > " "
      AND limit < 1000)
       ii = 0, limit = (limit+ 1), pos = 0
       WHILE (pos=0)
        ii = (ii+ 1),
        IF (substring((maxlen - ii),1,tempstring) IN (" ", ",", cr))
         pos = (maxlen - ii)
        ELSEIF (ii=maxlen)
         pos = maxlen
        ENDIF
       ENDWHILE
       printstring = substring(1,pos,tempstring),
       CALL print(calcpos(xcolvar,yrow1)), printstring
       IF (limit=1)
        maxlen = (maxlen - 5)
       ENDIF
       IF (breakflag=1)
        rowplusone
       ELSE
        rowplusone2
       ENDIF
       tempstring = substring((pos+ 1),9999,tempstring)
     ENDWHILE
    ENDMACRO
   HEAD PAGE
    IF (end_report_flag < 2)
     yrow1 = 35, new_encntr_flag = 0,
     CALL print(calcpos(xcol1,yrow1)),
     curdate, " ", curtime,
     CALL print(calcpos(xcol4,yrow1)), "{b}Downtime Clinical Summary {endb}", vversion,
     CALL print(calcpos(xcol10,yrow1)), rpt_title,
     CALL print(calcpos(550,yrow1)),
     "X", rowplusone2,
     CALL print(calcpos(xcol1,yrow1)),
     "{color/12}", equal_line, "{color/0}",
     rowplusone2,
     CALL print(calcpos(xcol1,yrow1)), "{b}",
     dlrec->seq[d1.seq].name_full_formatted, "{endb}",
     CALL print(calcpos(xcol10,yrow1)),
     dlrec->seq[d1.seq].nurse_unit, " ", dlrec->seq[d1.seq].pt_loc,
     rowplusone2,
     CALL print(calcpos(xcol2,yrow1)), "MRN: ",
     dlrec->seq[d1.seq].mrn,
     CALL print(calcpos(xcol4,yrow1)), "DOB: ",
     dlrec->seq[d1.seq].birth_dt_tm"mm/dd/yy;;D",
     CALL print(calcpos(xcol7,yrow1)), "<teaching team>",
     rowplusone2,
     CALL print(calcpos(xcol2,yrow1)), "CMRN: ",
     dlrec->seq[d1.seq].mrn,
     CALL print(calcpos((xcol4 - 5),yrow1)), "Acct #: ",
     dlrec->seq[d1.seq].account_nbr,
     CALL print(calcpos((xcol6 - 3),yrow1)), "Admit: ",
     dlrec->seq[d1.seq].admit_dt, rowplusone2,
     CALL print(calcpos(xcol1,yrow1)),
     "{color/14}", equal_line, "{color/0}",
     rowplusone2
     IF (curpage > 1
      AND last_title > " ")
      lastpage_cnt = (curpage - 1),
      CALL print(calcpos(xcol1,yrow1)), "{color/20}-------- ",
      last_title, "  (Continued from page ", lastpage_cnt"###;l",
      "){color/0}", rowplusone2
     ENDIF
    ENDIF
   DETAIL
    cnt = (cnt+ 1), title_string = "Patient Data", colpos2 = 0,
    title_print, rowplusone
    FOR (a = 1 TO dlrec->seq[d1.seq].total_al)
      CALL print(calcpos(xcol1,yrow1)), "{b}Allergy{endb} ", dlrec->seq[d1.seq].allergy[a].
      type_source_string,
      ", Reaction: --", dlrec->seq[d1.seq].allergy[a].severity, rowplusone
    ENDFOR
    xcolvar = xcol1, tempstring = dlrec->seq[d1.seq].code_status, line_wrap,
    CALL print(calcpos(xcol1,yrow1)), "{b/12}Attending MD: ", dlrec->seq[d1.seq].attenddoc_name,
    rowplusone,
    CALL print(calcpos(xcol1,yrow1)), "{b/4}PCP: ",
    dlrec->seq[d1.seq].pcpdoc_name, rowplusone,
    CALL print(calcpos(xcol1,yrow1)),
    "{b/18}Teaching Coverage: ", rowplusone, xcolvar = xcol1,
    tempstring = dlrec->seq[d1.seq].isolation_disp, line_wrap, xcolvar = xcol3
    IF ((dlrec->seq[d1.seq].problem_total > 0))
     CALL print(calcpos(xcol1,yrow1)), "{b}Problem List:{endb}", last_title = "Problem List"
     FOR (a = 1 TO dlrec->seq[d1.seq].problem_total)
      tempstring = concat(dlrec->seq[d1.seq].problem[a].full_text," "),line_wrap
     ENDFOR
    ENDIF
    xcolvar = xcol1
    FOR (a = 1 TO dlrec->seq[d1.seq].section1_total)
     tempstring = concat("{b}",dlrec->seq[d1.seq].section1_events[a].event_cd_disp,"{endb} ",dlrec->
      seq[d1.seq].section1_events[a].result),line_wrap
    ENDFOR
    xcolvar = (xcol3 - 10)
    IF ((dlrec->seq[d1.seq].total_diag > 0))
     CALL print(calcpos(xcol1,yrow1)), "{b}Diagnosis:{endb}", last_title = "Diagnosis"
     FOR (a = 1 TO dlrec->seq[d1.seq].total_diag)
      tempstring = concat(trim(dlrec->seq[d1.seq].diagnosis[a].source_string,3)," (",trim(dlrec->seq[
        d1.seq].diagnosis[a].diag_type_desc,3),")   "),line_wrap
     ENDFOR
    ENDIF
    xcolvar = xcol1
    FOR (a = 1 TO dlrec->seq[d1.seq].section2_total)
     tempstring = concat("{b}",dlrec->seq[d1.seq].section2_events[a].event_cd_disp,"{endb} ",dlrec->
      seq[d1.seq].section2_events[a].result),line_wrap
    ENDFOR
    title_string = "Nurse Communication:", title_print, rowplusone,
    xcolvar = xcol1
    FOR (a = 1 TO dlrec->seq[d1.seq].section3_total)
     tempstring = concat("{b}",dlrec->seq[d1.seq].section3_events[a].event_cd_disp,"{endb} ",dlrec->
      seq[d1.seq].section3_events[a].result),line_wrap
    ENDFOR
    xcolvar = xcol1
    FOR (a = 1 TO dlrec->seq[d1.seq].orders35_total)
      IF ((dlrec->seq[d1.seq].orders35[a].order_comment_ind=1))
       tempstring = concat("{b}",dlrec->seq[d1.seq].orders35[a].order_mnemonic,"{endb} ",dlrec->seq[
        d1.seq].orders35[a].clinical_display_line,"  --  COMMENT --  "), line_wrap
      ELSE
       tempstring = concat("{b}",dlrec->seq[d1.seq].orders35[a].order_mnemonic,"{endb} ",dlrec->seq[
        d1.seq].orders35[a].clinical_display_line), line_wrap
      ENDIF
    ENDFOR
    title_string = "Discharge Communication:", title_print, rowplusone,
    xcolvar = xcol1
    FOR (a = 1 TO dlrec->seq[d1.seq].section4_total)
     tempstring = concat("{b}",dlrec->seq[d1.seq].section4_events[a].event_cd_disp,"{endb} ",dlrec->
      seq[d1.seq].section4_events[a].result),line_wrap
    ENDFOR
    title_string = "Patient Care Orders:", title_print, rowplusone,
    CALL print(calcpos(xcol3,yrow1)), "{b}{u}  Diet  {endu}{endb}", rowplusone,
    xcolvar = xcol1, last_title = "Patient Care Orders: Diet"
    FOR (a = 1 TO dlrec->seq[d1.seq].diet_total)
      IF ((dlrec->seq[d1.seq].diet[a].order_comment_ind=1))
       tempstring = concat("{b}",dlrec->seq[d1.seq].diet[a].order_mnemonic,"{endb} ",dlrec->seq[d1
        .seq].diet[a].clinical_display_line,"  -- COMMENT --  "), line_wrap
      ELSE
       tempstring = concat("{b}",dlrec->seq[d1.seq].diet[a].order_mnemonic,"{endb} ",dlrec->seq[d1
        .seq].diet[a].clinical_display_line), line_wrap
      ENDIF
    ENDFOR
    CALL print(calcpos(xcol3,yrow1)), "{b}{u}  Respiratory Therapy  {endu}{endb}", last_title =
    "Patient Care Orders: Respiratory Therapy",
    rowplusone, xcolvar = xcol1
    FOR (a = 1 TO dlrec->seq[d1.seq].resp_total)
      IF ((dlrec->seq[d1.seq].resp[a].order_comment_ind=1))
       tempstring = concat("{b}",dlrec->seq.resp[a].order_mnemonic,"{endb} ",dlrec->seq[d1.seq].resp[
        a].clinical_display_line,"  -- COMMENT --  "), line_wrap
      ELSE
       tempstring = concat("{b}",dlrec->seq[d1.seq].resp[a].order_mnemonic,"{endb} ",dlrec->seq[d1
        .seq].resp[a].clinical_display_line), line_wrap
      ENDIF
    ENDFOR
    CALL print(calcpos(xcol3,yrow1)), "{b}{u}  Assess/Monitor/Treatment  {endu}{endb}", last_title =
    "Patient Care Orders: Assess/Monitor/Treatment",
    rowplusone, xcolvar = xcol1
    FOR (a = 1 TO dlrec->seq[d1.seq].asmt_total)
      IF ((dlrec->seq[d1.seq].asmt[a].order_comment_ind=1))
       tempstring = concat("{b}",dlrec->seq[d1.seq].asmt[a].order_mnemonic,"{endb} ",dlrec->seq[d1
        .seq].asmt[a].clinical_display_line,"  --  COMMENT  --  "), line_wrap
      ELSE
       tempstring = concat("{b}",dlrec->seq[d1.seq].asmt[a].order_mnemonic,"{endb} ",dlrec->seq[d1
        .seq].asmt[a].clinical_display_line), line_wrap
      ENDIF
    ENDFOR
    rowplusone,
    CALL print(calcpos(xcol3,yrow1)), "{b}{u}  Meds/Invasive Lines/Tubes/Drains  {endu}{endb}",
    last_title = "Patient Care Orders: Meds/Invasive Lines/Tubes/Drains", rowplusone, xcolvar = xcol1
    FOR (a = 1 TO dlrec->seq[d1.seq].ltd_total)
      IF ((dlrec->seq[d1.seq].ltd[a].order_comment_ind=1))
       tempstring = concat("{b}",dlrec->seq[d1.seq].ltd[a].order_mnemonic,"{endb} ",dlrec->seq[d1.seq
        ].ltd[a].clinical_display_line,"  --  COMMENT  --  "), line_wrap
      ELSE
       tempstring = concat("{b}",dlrec->seq[d1.seq].ltd[a].order_mnemonic,"{endb} ",dlrec->seq[d1.seq
        ].ltd[a].clinical_display_line), line_wrap
      ENDIF
    ENDFOR
    rowplusone, lastflag = 0,
    CALL print(calcpos(xcol3,yrow1)),
    "{b}{u}  Medications  {endu}{endb}", last_title = "Patient Care Orders: Medications", rowplusone,
    lastdatedoc = fillstring(90," ")
    FOR (a = 1 TO dlrec->seq[d1.seq].number_of_meds)
      IF (((yrow1+ 36) > 650))
       yrow1 = 651, rowplusone
      ENDIF
      IF (((a=1) OR (a > 1
       AND (dlrec->seq[d1.seq].meds[a].mso > dlrec->seq[d1.seq].meds[(a - 1)].mso))) )
       CALL print(calcpos((xcol1+ 27),yrow1)), "{b}{color/20}", mso[dlrec->seq[d1.seq].meds[a].mso],
       "{endb}{color/0}", rowplusone
      ENDIF
      IF ((dlrec->seq[d1.seq].meds[a].ioi=1))
       "{color/20}"
      ENDIF
      CALL print(calcpos((xcol1+ 7),yrow1)), "{b}", dlrec->seq[d1.seq].meds[a].ordered_as_mnemonic,
      "{endb} ", "     ", dlrec->seq[d1.seq].meds[a].order_status_disp,
      "{endb}", "   ", dlrec->seq[d1.seq].meds[a].need_rx_verify_str
      IF ((dlrec->seq[d1.seq].meds[a].order_comment_ind=1))
       CALL print("  --  COMMENT  --  ")
      ENDIF
      breakflag = 0, rowplusone2, tempstring = dlrec->seq[d1.seq].meds[a].display_line,
      xcolvar = xcol2, line_wrap, "{color/0}"
      IF ((dlrec->seq[d1.seq].meds[a].mso=1))
       breakflag = 1
      ENDIF
    ENDFOR
    rowplusone, breakflag = 1, rowplusone,
    CALL print(calcpos(xcol3,yrow1)), "{b}{u}  Lab/Rad/EKG  {endu}{endb}", last_title =
    "Patient Care Orders: Lab/Rad/EKG ",
    rowplusone, xcolvar = xcol1
    FOR (a = 1 TO dlrec->seq[d1.seq].rorders_total)
      IF ((dlrec->seq[d1.seq].rorders[a].order_comment_ind=1))
       tempstring = concat("{b}",dlrec->seq[d1.seq].rorders[a].order_mnemonic,"{endb} ",dlrec->seq[d1
        .seq].rorders[a].clinical_display_line,"  --  COMMENT  --  "), line_wrap
      ELSE
       tempstring = concat("{b}",dlrec->seq[d1.seq].rorders[a].order_mnemonic,"{endb} ",dlrec->seq[d1
        .seq].rorders[a].clinical_display_line), line_wrap
      ENDIF
    ENDFOR
    rowplusone,
    CALL print(calcpos(xcol3,yrow1)), "{b}{u}  Consults/Procedures  {endu}{endb}",
    last_title = "Patient Care Orders: Consults/Procedures ", rowplusone, xcolvar = xcol1
    FOR (a = 1 TO dlrec->seq[d1.seq].cporders_total)
      IF ((dlrec->seq[d1.seq].cporders[a].order_comment_ind=1))
       tempstring = concat("{b}",dlrec->seq[d1.seq].cporders[a].order_mnemonic,"{endb} ",dlrec->seq[
        d1.seq].cporders[a].clinical_display_line,"  --  COMMENT  --  "), line_wrap
      ELSE
       tempstring = concat("{b}",dlrec->seq[d1.seq].cporders[a].order_mnemonic,"{endb} ",dlrec->seq[
        d1.seq].cporders[a].clinical_display_line), line_wrap
      ENDIF
    ENDFOR
    rowplusone, last_header1_txt = fillstring(60," "), last_header2_txt = fillstring(60," "),
    last_parent_event = fillstring(60," "), xcolvar = (xcol1+ 10)
    FOR (a = 1 TO dlrec->seq[d1.seq].d0events_total)
      IF ((dlrec->seq[d1.seq].d0events[a].header1_txt != last_header1_txt))
       last_header1_txt = dlrec->seq[d1.seq].d0events[a].header1_txt, title_string = dlrec->seq[d1
       .seq].d0events[a].header1_txt, last_title = title_string,
       title_print, rowplusone
      ENDIF
      IF ((dlrec->seq[d1.seq].d0events[a].header2_txt != last_header2_txt))
       last_header2_txt = dlrec->seq[d1.seq].d0events[a].header2_txt, rowplusone,
       CALL print(calcpos(xcol1,yrow1)),
       "{b}{u} ", last_header2_txt, " {endu}{endb}",
       last_title = concat("Documentation: ",last_header2_txt), rowplusone
      ENDIF
      IF ((dlrec->seq[d1.seq].d0events[a].parent_event > " "))
       IF ((dlrec->seq[d1.seq].d0events[a].parent_event != last_parent_event))
        last_parent_event = dlrec->seq[d1.seq].d0events[a].parent_event
        IF ((dlrec->seq[d1.seq].d0events[a].parent_event != dlrec->seq[d1.seq].d0events[a].
        event_cd_disp))
         IF ( NOT (last_parent_event IN ("IV Observation Row", "Nutrient Need-Catch Up Growth Row")))
          CALL print(calcpos((xcol1+ 10),yrow1)), "{u}", last_parent_event,
          "{endu}", rowplusone
         ENDIF
        ENDIF
       ENDIF
       tempstring = concat("{b}   ",dlrec->seq[d1.seq].d0events[a].event_cd_disp,"{endb} ",dlrec->
        seq[d1.seq].d0events[a].result,"   (",
        dlrec->seq[d1.seq].d0events[a].event_dt_tm,")"), line_wrap
      ELSE
       tempstring = concat("{b}",dlrec->seq[d1.seq].d0events[a].event_cd_disp,"{endb} ",dlrec->seq[d1
        .seq].d0events[a].result,"   (",
        dlrec->seq[d1.seq].d0events[a].event_dt_tm,")"), line_wrap
      ENDIF
    ENDFOR
    lastflag = 1
    IF (end_report_flag=1)
     end_report_flag = 2
    ENDIF
   FOOT  encntr_id
    IF ((cnt=dlrec->encntr_total))
     end_report_flag = 1
    ENDIF
    last_title = " ", yrow1 = 5, new_encntr_flag = 1,
    BREAK
   FOOT PAGE
    IF (end_report_flag < 2)
     IF (new_encntr_flag=0)
      CALL print(calcpos(xcol6,655)), "Continued", row + 1,
      CALL print(calcpos(xcol1,660)), "{color/12}", equal_line,
      "{color/0}", rowplusone2,
      CALL print(calcpos(xcol1,675)),
      dlrec->seq[d1.seq].name_full_formatted,
      CALL print(calcpos(xcol5,675)), "Acct #:",
      dlrec->seq[d1.seq].account_nbr,
      CALL print(calcpos(xcol11,675)), "Pg ",
      curpage"###;l", row + 1
     ENDIF
    ENDIF
   FOOT REPORT
    rowplusone,
    CALL print(calcpos(xcol5,yrow1)), "** End of Clinical Summary **",
    row + 1, yrow1 = 650
    FOR (i = 1 TO 10)
      CALL print(calcpos(xcol1,(yrow1+ i))), "{color/12}", equal_line,
      "{color/0}", row + 1
    ENDFOR
   WITH maxcol = 366, maxrow = 166, dio = postscript
  ;end select
 ELSE
  SELECT INTO request->output_device
   FROM dummyt d1
   DETAIL
    col 1, starline, row + 3,
    col 1, "                                INVALID DATA ENTERED", row + 3,
    col 1, "Printer:  ", request->output_device,
    row + 1, col 1, "encntr_id ",
    request->visit[1].encntr_id, row + 2, col 1,
    starline, row + 1
   WITH nocounter
  ;end select
 ENDIF
#endprog
 FREE RECORD dlrec
 FREE RECORD pt
END GO

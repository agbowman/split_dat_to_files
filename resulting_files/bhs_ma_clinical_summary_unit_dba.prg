CREATE PROGRAM bhs_ma_clinical_summary_unit:dba
 IF (validate(reply->status_data,"ZZZ")="ZZZ")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 RECORD dlrec(
   1 encntr_total = i4
   1 seq[*]
     2 encntr_id = f8
     2 person_id = f8
     2 account_nbr = c20
     2 mrn = vc
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
     2 number_of_rorders = i4
     2 rorders[*]
       3 order_id = f8
       3 person_id = f8
       3 comments = vc
       3 results = vc
       3 procedure = vc
       3 mnemonic = vc
       3 activity_type_disp = vc
       3 catalog_type_sort = i4
       3 catalog_type_disp = vc
       3 order_mnemonic = vc
       3 start_dt_tm = c20
       3 orig_order_dt_tm = c20
       3 performed_dt_tm = c20
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
       3 event_end_dt_tm = c20
       3 event_cd = f8
       3 author = c50
       3 doc_name = c50
       3 num_lines = i4
       3 text[*]
         4 text_line = vc
     2 number_of_meds = i4
     2 meds[*]
       3 order_id = f8
       3 person_id = f8
       3 comments = vc
       3 mnemonic = vc
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
       3 order_comment_ind = f8
       3 order_person = vc
       3 order_doctor = vc
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
     2 total_isol = i4
     2 isolation[*]
       3 isolation_disp = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
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
 DECLARE allergy_cancelled_cd = f8 WITH public, constant(uar_get_code_by("MEANING",12025,"CANCELED"))
 DECLARE e_encntr_status_cd = f8 WITH public, constant(uar_get_code_by("MEANING",261,"ACTIVE"))
 DECLARE mrn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE ssn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE account_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"ACCOUNT"))
 DECLARE fin_cd = f8 WITH public, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE admitdoc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ADMITDOC"))
 DECLARE attenddoc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE isolation_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"ISOLATION"))
 DECLARE code_status_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"TSL"))
 DECLARE order_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE laboratory_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"LABORATORY"))
 DECLARE generallab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"GENERALLAB"))
 DECLARE micro_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"MICRO"))
 DECLARE ocfcomp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE codestatusnsg_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"CODESTATUSNSG"
   ))
 DECLARE airborneprecautionotherthantb_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "AIRBORNEPRECAUTIONOTHERTHANTB"))
 DECLARE airborneprecautionsfortb_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "AIRBORNEPRECAUTIONSFORTB"))
 DECLARE contactprecautions_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "CONTACTPRECAUTIONS"))
 DECLARE dropletprecautions_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "DROPLETPRECAUTIONS"))
 DECLARE neutropenicprecautions_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "NEUTROPENICPRECAUTIONS"))
 DECLARE vremultidrugresistantorganismprecau_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",200,"VREMULTIDRUGRESISTANTORGANISMPRECAU"))
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
 DECLARE ct_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"CT"))
 DECLARE mri_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"MRI"))
 DECLARE mammography_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "MAMMOGRAPHY"))
 DECLARE nuclearmedicine_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "NUCLEARMEDICINE"))
 DECLARE radiology_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"RADIOLOGY"))
 DECLARE specialprocedures_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "SPECIALPROCEDURES"))
 DECLARE ultrasound_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ULTRASOUND"
   ))
 DECLARE pharmacy_cattyp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE pharmacy_actvy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY"))
 DECLARE relationshiptopatient_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "RELATIONSHIPTOPATIENT"))
 DECLARE phonenumber_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"PHONENUMBER"))
 DECLARE authorizedtodiscusspatientshealth_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",
   72,"AUTHORIZEDTODISCUSSPATIENTSHEALTH"))
 DECLARE languagespoken_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "LANGUAGESPOKEN"))
 DECLARE ispatientachronicco2retainer_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "ISPATIENTACHRONICCO2RETAINER"))
 DECLARE height_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"HEIGHT"))
 DECLARE weight_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT"))
 DECLARE abdominalgirth_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "ABDOMINALGIRTH"))
 DECLARE headcircumference_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEADCIRCUMFERENCE"))
 DECLARE bodysurfacearea_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "BODYSURFACEAREA"))
 DECLARE bodymassindex_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"BODYMASSINDEX")
  )
 DECLARE calfcircumference_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CALFCIRCUMFERENCE"))
 DECLARE thighcircumference_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "THIGHCIRCUMFERENCE"))
 DECLARE chronichospital_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CHRONICHOSPITAL"))
 DECLARE nursinghomesskilledrehabfacilities_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"NURSINGHOMESSKILLEDREHABFACILITIES"))
 DECLARE resthomescommunityresidencesshelters_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"RESTHOMESCOMMUNITYRESIDENCESSHELTERS"))
 DECLARE adultdayhealthcare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "ADULTDAYHEALTHCARE"))
 DECLARE currentlyreceivinghomeservices_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CURRENTLYRECEIVINGHOMESERVICES"))
 DECLARE earlyinterventionprograms_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "EARLYINTERVENTIONPROGRAMS"))
 DECLARE fostercare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"FOSTERCARE"))
 DECLARE jail_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"JAIL"))
 DECLARE medicalequipmentcompanies_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "MEDICALEQUIPMENTCOMPANIES"))
 DECLARE currenthomeservices_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CURRENTHOMESERVICES"))
 DECLARE currenthometreatments_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CURRENTHOMETREATMENTS"))
 DECLARE servicecategories_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "SERVICECATEGORIES"))
 DECLARE equipment_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"EQUIPMENT"))
 DECLARE servicefrequency_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "SERVICEFREQUENCY"))
 DECLARE nursecommunicationsocialservices_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",
   72,"NURSECOMMUNICATIONSOCIALSERVICES"))
 DECLARE contactperson_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"CONTACTPERSON")
  )
 DECLARE nursecommunicationpulmonaryrehab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",
   72,"NURSECOMMUNICATIONPULMONARYREHAB"))
 DECLARE nursecommunicationrehab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "NURSECOMMUNICATIONREHAB"))
 DECLARE cardiacrehabnursecommunication_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CARDIACREHABNURSECOMMUNICATION"))
 DECLARE nursecommunicationnutrition_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "NURSECOMMUNICATIONNUTRITION"))
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
    organization o,
    person_alias pa
   PLAN (d)
    JOIN (e
    WHERE (e.encntr_id=request->visit[d.seq].encntr_id))
    JOIN (ea
    WHERE outerjoin(e.encntr_id)=ea.encntr_id
     AND outerjoin(fin_cd)=ea.encntr_alias_type_cd
     AND ea.active_ind=outerjoin(1)
     AND ea.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
     AND ea.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
    JOIN (p
    WHERE e.person_id=p.person_id
     AND p.active_ind=1)
    JOIN (o
    WHERE e.organization_id=o.organization_id)
    JOIN (pa
    WHERE p.person_id=pa.person_id
     AND pa.person_alias_type_cd=mrn_cd
     AND pa.active_ind=1)
   ORDER BY pt_loc, e.encntr_id
   HEAD REPORT
    cnt = 0
   HEAD pt_loc
    col + 0
   HEAD e.encntr_id
    IF (e.encntr_id > 0)
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(dlrec->seq,(cnt+ 10))
     ENDIF
     dlrec->seq[cnt].encntr_id = e.encntr_id, dlrec->seq[cnt].admit_dt = substring(1,14,format(e
       .reg_dt_tm,"@SHORTDATETIME;;Q")), dlrec->seq[cnt].reason_for_visit = trim(e.reason_for_visit,3
      ),
     dlrec->seq[cnt].name_full_formatted = trim(p.name_full_formatted), dlrec->seq[cnt].birth_dt_tm
      = p.birth_dt_tm, dlrec->seq[cnt].account_nbr = ea.alias,
     dlrec->seq[cnt].person_id = p.person_id, dlrec->seq[cnt].mrn = pa.alias, dlrec->seq[cnt].
     nurse_unit = nurse_unit,
     dlrec->seq[cnt].pt_loc = pt_loc, dlrec->seq[cnt].isolation_disp = isolation_disp, dlrec->seq[cnt
     ].org_name = o.org_name
    ENDIF
   FOOT  e.encntr_id
    stat = alterlist(dlrec->seq[d.seq].diagnosis,1), dlrec->seq[d.seq].diagnosis[1].diag_type_desc =
    "Reason For Visit", dlrec->seq[d.seq].diagnosis[1].source_string = e.reason_for_visit,
    dlrec->seq[d.seq].diagnosis[1].diag_dt_tm = substring(1,14,format(e.reg_dt_tm,"@SHORTDATETIME;;Q"
      )), dlrec->seq[d.seq].total_diag = 1
   FOOT  pt_loc
    col + 0
   FOOT REPORT
    stat = alterlist(dlrec->seq,cnt), dlrec->encntr_total = cnt
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    diagnosis d,
    nomenclature n
   PLAN (dd)
    JOIN (d
    WHERE (d.encntr_id=dlrec->seq[dd.seq].encntr_id)
     AND d.active_ind=1)
    JOIN (n
    WHERE n.nomenclature_id=outerjoin(d.nomenclature_id))
   ORDER BY d.encntr_id, cnvtdatetime(d.diag_dt_tm) DESC, d.nomenclature_id
   HEAD d.encntr_id
    cnt = 1, stat = alterlist(dlrec->seq[dd.seq].diagnosis,10)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
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
    stat = alterlist(dlrec->seq[dd.seq].diagnosis,cnt), dlrec->seq[dd.seq].total_diag = cnt
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
    WHERE outerjoin(a.substance_nom_id)=n.nomenclature_id)
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
    stat = alterlist(dlrec->seq[dd.seq].allergy,al), dlrec->seq[dd.seq].total_al = al
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    clinical_event c
   PLAN (dd)
    JOIN (c
    WHERE (dlrec->seq[dd.seq].encntr_id=c.encntr_id)
     AND c.event_cd IN (contactperson_cd, relationshiptopatient_cd, phonenumber_cd,
    authorizedtodiscusspatientshealth_cd, languagespoken_cd)
     AND c.view_level=1
     AND c.publish_flag=1
     AND c.valid_until_dt_tm=cnvtdatetime("31-dec-2100,00:00:00")
     AND c.result_status_cd != inerror_cd
     AND c.event_tag > " ")
   ORDER BY c.encntr_id, c.event_cd, c.event_id
   HEAD c.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].section1_events,10)
   HEAD c.event_id
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].section1_events,(cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].section1_events[cnt].event_type = c.event_tag, dlrec->seq[dd.seq].
    section1_events[cnt].event_cd = c.event_cd, dlrec->seq[dd.seq].section1_events[cnt].event_cd_disp
     = uar_get_code_display(c.event_cd),
    dlrec->seq[dd.seq].section1_events[cnt].event_dt_tm = substring(1,14,format(c.updt_dt_tm,
      "@SHORTDATETIME;;Q")), dlrec->seq[dd.seq].section1_events[cnt].result = build(c.result_val,
     uar_get_code_display(c.result_units_cd))
   FOOT  c.encntr_id
    stat = alterlist(dlrec->seq[dd.seq].section1_events,cnt), dlrec->seq[dd.seq].section1_total = cnt
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
    WHERE n.nomenclature_id=outerjoin(p.nomenclature_id))
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
    dlrec->seq[d.seq].problem_total = cnt, stat = alterlist(dlrec->seq[d.seq].problem,cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   catalog_type_cdf = uar_get_code_meaning(o.catalog_type_cd), catalog_type_disp =
   uar_get_code_display(o.catalog_type_cd), activity_type_disp = uar_get_code_display(o
    .activity_type_cd),
   order_status_disp = uar_get_code_display(o.order_status_cd)
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    orders o,
    order_action oa,
    prsnl p,
    prsnl p2
   PLAN (dd)
    JOIN (o
    WHERE (o.encntr_id=dlrec->seq[dd.seq].encntr_id)
     AND o.order_status_cd IN (o_incomplete_cd, o_inprocess_cd, o_ordered_cd, o_pending_cd,
    o_pending_rev_cd)
     AND o.template_order_flag IN (0, 1)
     AND o.catalog_type_cd != pharmacy_cattyp_cd)
    JOIN (oa
    WHERE outerjoin(o.order_id)=oa.order_id
     AND outerjoin(order_cd)=oa.action_type_cd)
    JOIN (p
    WHERE outerjoin(oa.action_personnel_id)=p.person_id)
    JOIN (p2
    WHERE outerjoin(oa.order_provider_id)=p2.person_id)
   ORDER BY o.encntr_id, catalog_type_disp, activity_type_disp,
    cnvtdatetime(o.orig_order_dt_tm), o.order_id
   HEAD o.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].orders,10)
   HEAD catalog_type_disp
    col + 0
   HEAD activity_type_disp
    col + 0
   DETAIL
    col + 0, cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].orders,(cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].orders[cnt].order_mnemonic = o.order_mnemonic, dlrec->seq[dd.seq].orders[cnt].
    order_person = p.name_full_formatted, dlrec->seq[dd.seq].orders[cnt].order_doctor = p2
    .name_full_formatted,
    dlrec->seq[dd.seq].orders[cnt].order_status_cd = o.order_status_cd, dlrec->seq[dd.seq].orders[cnt
    ].order_status_disp = order_status_disp, dlrec->seq[dd.seq].orders[cnt].clinical_display_line = o
    .clinical_display_line,
    dlrec->seq[dd.seq].orders[cnt].orig_order_dt_tm = format(o.orig_order_dt_tm,"MM/DD/YY HH:MM;;D"),
    dlrec->seq[dd.seq].orders[cnt].misc = build(uar_get_code_display(o.catalog_type_cd),"\",
     uar_get_code_display(o.activity_type_cd))
   FOOT  activity_type_disp
    col + 0
   FOOT  catalog_type_disp
    col + 0
   FOOT  o.encntr_id
    stat = alterlist(dlrec->seq[dd.seq].orders,cnt), dlrec->seq[dd.seq].number_of_orders = cnt
   WITH nocounter, maxcol = 800
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
     AND c.result_status_cd != inerror_cd)
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
    stat = alterlist(dlrec->seq[dd.seq].labs,cnt), dlrec->seq[dd.seq].number_of_labs = cnt
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   blob_contents = substring(1,30000,ce.blob_contents)
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    orders o,
    order_action oa,
    prsnl p,
    prsnl p2,
    clinical_event c,
    ce_blob ce,
    clinical_event c2
   PLAN (dd)
    JOIN (o
    WHERE (o.encntr_id=dlrec->seq[dd.seq].encntr_id)
     AND o.catalog_type_cd=radiology_cattyp_cd
     AND o.activity_type_cd IN (ct_actvy_cd, mri_actvy_cd, mammography_actvy_cd,
    nuclearmedicine_actvy_cd, radiology_actvy_cd,
    specialprocedures_actvy_cd, ultrasound_actvy_cd))
    JOIN (oa
    WHERE outerjoin(o.order_id)=oa.order_id
     AND outerjoin(order_cd)=oa.action_type_cd)
    JOIN (p
    WHERE outerjoin(oa.action_personnel_id)=p.person_id)
    JOIN (p2
    WHERE outerjoin(oa.order_provider_id)=p2.person_id)
    JOIN (c
    WHERE c.person_id=o.person_id
     AND c.encntr_id=o.encntr_id
     AND c.order_id=o.order_id
     AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
    JOIN (c2
    WHERE c2.parent_event_id=c.event_id
     AND c2.performed_dt_tm > cnvtdatetime((curdate - 1),curtime))
    JOIN (ce
    WHERE ce.event_id=outerjoin(c2.event_id)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
   ORDER BY o.encntr_id, o.order_id, ce.event_id
   HEAD o.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].rorders,10), testflag = 0
   HEAD o.order_id
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].rorders,(cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].rorders[cnt].order_mnemonic, dlrec->seq[dd.seq].rorders[cnt].order_id = c
    .order_id
   HEAD ce.event_id
    blob_out = fillstring(30000," "), blob_out2 = blob_out, blob_ret_len = 0
    IF (ce.compression_cd=compressed_cd)
     CALL uar_ocf_uncompress(blob_contents,30000,blob_out,30000,blob_ret_len)
    ELSE
     blob_out = blob_contents
    ENDIF
    CALL uar_rtf2(blob_out,blob_ret_len,blob_out2,30000,blob_ret_len,1), dlrec->seq[dd.seq].rorders[
    cnt].comments = blob_out2
    IF (blob_ret_len > 1000)
     FOR (pp = 1 TO blob_ret_len)
       IF (ichar(substring(pp,1,blob_out2)) != 32)
        IF (ichar(substring((pp - 1),1,blob_out2))=32)
         newstring = concat(newstring," ",substring(pp,1,blob_out2))
        ELSE
         newstring = concat(newstring,substring(pp,1,blob_out2))
        ENDIF
       ENDIF
     ENDFOR
     dlrec->seq[dd.seq].rorders[cnt].comments = newstring
    ENDIF
    dlrec->seq[dd.seq].rorders[cnt].order_mnemonic = o.order_mnemonic, dlrec->seq[dd.seq].rorders[cnt
    ].order_status_cd = o.order_status_cd, dlrec->seq[dd.seq].rorders[cnt].order_status_disp =
    uar_get_code_display(o.order_status_cd),
    dlrec->seq[dd.seq].rorders[cnt].clinical_display_line = o.clinical_display_line, dlrec->seq[dd
    .seq].rorders[cnt].performed_dt_tm = substring(1,14,format(c2.performed_dt_tm,"@SHORTDATETIME;;Q"
      ))
   FOOT  ce.event_id
    col + 0
   FOOT  o.order_id
    col + 0
   FOOT  o.encntr_id
    stat = alterlist(dlrec->seq[dd.seq].rorders,cnt), dlrec->seq[dd.seq].number_of_rorders = cnt
   WITH nocounter
  ;end select
  FOR (x = 1 TO dlrec->encntr_total)
    FOR (y = 1 TO dlrec->seq[x].number_of_rorders)
      SET pt->line_cnt = 0
      SET max_length = 100
      EXECUTE dcp_parse_text value(dlrec->seq[x].rorders[y].comments), value(max_length)
      SET stat = alterlist(dlrec->seq[x].rorders[y].text,pt->line_cnt)
      SET dlrec->seq[x].rorders[y].num_lines = pt->line_cnt
      FOR (w = 1 TO pt->line_cnt)
        SET dlrec->seq[x].rorders[y].text[w].text_line = pt->lns[w].line
      ENDFOR
    ENDFOR
  ENDFOR
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
     AND o.template_order_flag IN (0, 1))
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
    dlrec->seq[dd.seq].meds[cnt].display_line = o.clinical_display_line, dlrec->seq[dd.seq].meds[cnt]
    .date = format(o.orig_order_dt_tm,"mm/dd/yy hh:mm;;d"), dlrec->seq[dd.seq].meds[cnt].
    order_status_disp = uar_get_code_display(o.order_status_cd)
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
    dlrec->seq[dd.seq].number_of_meds = cnt, stat = alterlist(dlrec->seq[dd.seq].meds,cnt)
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
  SELECT DISTINCT INTO "nl:"
   event_sort_order =
   IF (c.event_cd=relationshiptopatient_cd) 1
   ELSEIF (c.event_cd=phonenumber_cd) 2
   ELSEIF (c.event_cd=authorizedtodiscusspatientshealth_cd) 3
   ELSEIF (c.event_cd=languagespoken_cd) 4
   ELSEIF (c.event_cd=ispatientachronicco2retainer_cd) 5
   ELSEIF (c.event_cd=height_cd) 6
   ELSEIF (c.event_cd=weight_cd) 7
   ELSEIF (c.event_cd=abdominalgirth_cd) 8
   ELSEIF (c.event_cd=headcircumference_cd) 9
   ELSEIF (c.event_cd=bodysurfacearea_cd) 10
   ELSEIF (c.event_cd=bodymassindex_cd) 11
   ELSEIF (c.event_cd=calfcircumference_cd) 12
   ELSEIF (c.event_cd=thighcircumference_cd) 13
   ELSEIF (c.event_cd=chronichospital_cd) 14
   ELSEIF (c.event_cd=nursinghomesskilledrehabfacilities_cd) 15
   ELSEIF (c.event_cd=resthomescommunityresidencesshelters_cd) 16
   ELSEIF (c.event_cd=adultdayhealthcare_cd) 17
   ELSEIF (c.event_cd=currentlyreceivinghomeservices_cd) 18
   ELSEIF (c.event_cd=earlyinterventionprograms_cd) 19
   ELSEIF (c.event_cd=fostercare_cd) 20
   ELSEIF (c.event_cd=jail_cd) 21
   ELSEIF (c.event_cd=medicalequipmentcompanies_cd) 22
   ELSEIF (c.event_cd=currenthomeservices_cd) 23
   ELSEIF (c.event_cd=currenthometreatments_cd) 24
   ELSEIF (c.event_cd=servicecategories_cd) 25
   ELSEIF (c.event_cd=equipment_cd) 26
   ELSEIF (c.event_cd=servicefrequency_cd) 27
   ELSEIF (c.event_cd=nursecommunicationsocialservices_cd) 28
   ELSEIF (c.event_cd=contactperson_cd) 29
   ELSEIF (c.event_cd=nursecommunicationpulmonaryrehab_cd) 30
   ELSEIF (c.event_cd=nursecommunicationrehab_cd) 31
   ELSEIF (c.event_cd=cardiacrehabnursecommunication_cd) 32
   ELSEIF (c.event_cd=nursecommunicationnutrition_cd) 33
   ELSE c.event_cd
   ENDIF
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    clinical_event c,
    ce_date_result cd,
    code_value cv
   PLAN (dd)
    JOIN (c
    WHERE (dlrec->seq[dd.seq].encntr_id=c.encntr_id)
     AND c.event_cd > 0
     AND c.view_level=1
     AND c.publish_flag=1
     AND c.valid_until_dt_tm=cnvtdatetime("31-dec-2100,00:00:00")
     AND c.result_status_cd != inerror_cd
     AND c.event_tag > " "
     AND c.catalog_cd=0)
    JOIN (cd
    WHERE outerjoin(c.event_id)=cd.event_id)
    JOIN (cv
    WHERE c.event_cd=cv.code_value)
   ORDER BY c.encntr_id, event_sort_order, cnvtdatetime(c.event_end_dt_tm)
   HEAD c.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].events,10)
   HEAD event_sort_order
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].events,(cnt+ 10))
    ENDIF
   DETAIL
    dlrec->seq[dd.seq].events[cnt].event_type = c.event_tag, dlrec->seq[dd.seq].events[cnt].
    event_sort_order = event_sort_order, dlrec->seq[dd.seq].events[cnt].event_cd = c.event_cd,
    dlrec->seq[dd.seq].events[cnt].event_cd_disp = uar_get_code_display(c.event_cd), dlrec->seq[dd
    .seq].events[cnt].event_dt_tm = format(c.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"), dlrec->seq[dd.seq
    ].events[cnt].dttmsort = cnvtint(format(c.event_end_dt_tm,"YYMMDDHHMM;;;D")),
    dlrec->seq[dd.seq].events[cnt].result = concat(trim(c.result_val)," ",trim(uar_get_code_display(c
       .result_units_cd))), dlrec->seq[dd.seq].events[cnt].misc = build(cnvtint(c.event_cd),"\",cv
     .display_key)
    IF (c.event_id=cd.event_id)
     CASE (cd.date_type_flag)
      OF 0:
       dlrec->seq[dd.seq].events[cnt].result = format(cd.result_dt_tm,"mm/dd/yy hh:mm;;;d")
      OF 1:
       dlrec->seq[dd.seq].events[cnt].result = format(cd.result_dt_tm,"mm/dd/yy;;;d")
      OF 2:
       dlrec->seq[dd.seq].events[cnt].result = format(cd.result_dt_tm,"hh:mm;;;d")
     ENDCASE
    ENDIF
   FOOT  event_sort_order
    col + 0
   FOOT  c.encntr_id
    stat = alterlist(dlrec->seq[dd.seq].events,(cnt+ 1)), dlrec->seq[dd.seq].total_events = cnt
   WITH nocounter
  ;end select
  FOR (ii = 1 TO dlrec->encntr_total)
    SET max = dlrec->seq[ii].total_events
    SET min = 0
    FOR (e = 1 TO max)
      IF (min=0
       AND (dlrec->seq[ii].events[e].event_sort_order > 100))
       SET min = e
      ENDIF
    ENDFOR
    FOR (jj = min TO max)
      SET jm = (max+ 1)
      SET mark = 0
      SET maxdttm = 0
      FOR (j = min TO max)
        IF ((dlrec->seq[ii].events[j].dttmsort >= maxdttm))
         SET mark = j
         SET maxdttm = dlrec->seq[ii].events[j].dttmsort
        ENDIF
      ENDFOR
      IF (mark > 0)
       SET dlrec->seq[ii].events[jm].event_type = dlrec->seq[ii].events[mark].event_type
       SET dlrec->seq[ii].events[jm].event_sort_order = dlrec->seq[ii].events[mark].event_sort_order
       SET dlrec->seq[ii].events[jm].event_cd = dlrec->seq[ii].events[mark].event_cd
       SET dlrec->seq[ii].events[jm].event_cd_disp = dlrec->seq[ii].events[mark].event_cd_disp
       SET dlrec->seq[ii].events[jm].event_dt_tm = dlrec->seq[ii].events[mark].event_dt_tm
       SET dlrec->seq[ii].events[jm].dttmsort = dlrec->seq[ii].events[mark].dttmsort
       SET dlrec->seq[ii].events[jm].result = dlrec->seq[ii].events[mark].result
       SET dlrec->seq[ii].events[jm].misc = dlrec->seq[ii].events[mark].misc
       SET jm = mark
       FOR (j = min TO mark)
         SET dlrec->seq[ii].events[jm].event_type = dlrec->seq[ii].events[(jm - 1)].event_type
         SET dlrec->seq[ii].events[jm].event_sort_order = dlrec->seq[ii].events[(jm - 1)].
         event_sort_order
         SET dlrec->seq[ii].events[jm].event_cd = dlrec->seq[ii].events[(jm - 1)].event_cd
         SET dlrec->seq[ii].events[jm].event_cd_disp = dlrec->seq[ii].events[(jm - 1)].event_cd_disp
         SET dlrec->seq[ii].events[jm].event_dt_tm = dlrec->seq[ii].events[(jm - 1)].event_dt_tm
         SET dlrec->seq[ii].events[jm].dttmsort = dlrec->seq[ii].events[(jm - 1)].dttmsort
         SET dlrec->seq[ii].events[jm].result = dlrec->seq[ii].events[(jm - 1)].result
         SET dlrec->seq[ii].events[jm].misc = dlrec->seq[ii].events[(jm - 1)].misc
         SET jm = (jm - 1)
       ENDFOR
       SET dlrec->seq[ii].events[min].event_type = dlrec->seq[ii].events[(max+ 1)].event_type
       SET dlrec->seq[ii].events[min].event_sort_order = dlrec->seq[ii].events[(max+ 1)].
       event_sort_order
       SET dlrec->seq[ii].events[min].event_cd = dlrec->seq[ii].events[(max+ 1)].event_cd
       SET dlrec->seq[ii].events[min].event_cd_disp = dlrec->seq[ii].events[(max+ 1)].event_cd_disp
       SET dlrec->seq[ii].events[min].event_dt_tm = dlrec->seq[ii].events[(max+ 1)].event_dt_tm
       SET dlrec->seq[ii].events[min].dttmsort = dlrec->seq[ii].events[(max+ 1)].dttmsort
       SET dlrec->seq[ii].events[min].result = dlrec->seq[ii].events[(max+ 1)].result
       SET dlrec->seq[ii].events[min].misc = dlrec->seq[ii].events[(max+ 1)].misc
       SET min = (min+ 1)
      ENDIF
    ENDFOR
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
    orders o,
    order_detail od
   PLAN (dd)
    JOIN (o
    WHERE (o.encntr_id=dlrec->seq[dd.seq].encntr_id)
     AND ((o.catalog_cd+ 0) IN (codestatusnsg_cd, airborneprecautionotherthantb_cd,
    airborneprecautionsfortb_cd, contactprecautions_cd, dropletprecautions_cd,
    neutropenicprecautions_cd, vremultidrugresistantorganismprecau_cd))
     AND o.active_ind=1)
    JOIN (od
    WHERE o.order_id=od.order_id
     AND od.oe_field_meaning IN ("ISOLATIONCODE", "OTHER"))
   ORDER BY o.encntr_id, cnvtdatetime(o.orig_order_dt_tm), o.order_id,
    od.action_sequence
   HEAD o.encntr_id
    cnt = 0, stat = alterlist(dlrec->seq[dd.seq].isolation,10)
   DETAIL
    IF (o.catalog_cd=codestatusnsg_cd)
     dlrec->seq[dd.seq].code_status = od.oe_field_display_value
    ELSE
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(dlrec->seq[dd.seq].isolation,(cnt+ 10))
     ENDIF
     dlrec->seq[dd.seq].isolation[cnt].isolation_disp = build(uar_get_code_description(o.catalog_cd),
      " - ",od.oe_field_display_value)
    ENDIF
   FOOT  o.encntr_id
    stat = alterlist(dlrec->seq[dd.seq].isolation,cnt), dlrec->seq[dd.seq].total_isol = cnt
   WITH nocounter
  ;end select
  SELECT INTO request->output_device
   HEAD REPORT
    "{f/8}{cpi/14}{lpi/8}", row + 1, yrow1 = 5,
    breakflag = 1, xcol1 = 26, xcol2 = 38,
    xcol3 = 86, xcol4 = 158, xcol5 = 228,
    xcol6 = 273, xcol7 = 308, xcol8 = 388,
    xcol9 = 428, xcol10 = 433, xcol11 = 467,
    xcol12 = 540, mso[5] = "Unknown             ", mso[4] = "Continuous Infusions",
    mso[3] = "PRN                 ", mso[2] = "Unscheduled         ", mso[1] = "Scheduled           ",
    lcol1[2] = 0, lcol2[2] = 0, lcol3[2] = 0,
    gap = 85, lcol1[1] = xcol1, lcol2[1] = (lcol1[1]+ gap),
    lcol3[1] = (lcol2[1]+ gap), lcol1[2] = (lcol3[1]+ gap), lcol2[2] = (lcol1[2]+ gap),
    lcol3[2] = (lcol2[2]+ gap), printer_disp = request->output_device
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
     IF (yrow1 > 650)
      BREAK
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
     limit = 0, maxlen = 88, cr = char(10)
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
    yrow1 = 35
    IF ((dlrec->seq[i].encntr_id != last_encntr_id))
     page_cnt = 0, last_encntr_id = dlrec->seq[i].encntr_id
    ENDIF
    page_cnt = (page_cnt+ 1)
    IF (i=0)
     i = 1
    ENDIF
    CALL print(calcpos(xcol1,yrow1)), curdate, " ",
    curtime,
    CALL print(calcpos(xcol5,yrow1)), "{b}Clinical Summary{endb}",
    CALL print(calcpos(xcol10,yrow1)), rpt_title,
    CALL print(calcpos(550,yrow1)),
    "X", rowplusone2,
    CALL print(calcpos(xcol1,yrow1)),
    "{color/12}", equal_line, "{color/0}",
    rowplusone2,
    CALL print(calcpos(xcol1,yrow1)), "{b}",
    dlrec->seq[i].name_full_formatted, "{endb}",
    CALL print(calcpos(xcol10,yrow1)),
    dlrec->seq[i].nurse_unit, " ", dlrec->seq[i].pt_loc,
    rowplusone2,
    CALL print(calcpos(xcol2,yrow1)), "MRN: ",
    dlrec->seq[i].mrn,
    CALL print(calcpos(xcol4,yrow1)), "DOB: ",
    dlrec->seq[i].birth_dt_tm"mm/dd/yy;;D",
    CALL print(calcpos(xcol7,yrow1)), "<teaching team>",
    rowplusone2,
    CALL print(calcpos((xcol2 - 5),yrow1)), "Acct #: ",
    dlrec->seq[i].account_nbr,
    CALL print(calcpos((xcol4 - 3),yrow1)), "Admit: ",
    dlrec->seq[i].admit_dt,
    CALL print(calcpos(xcol7,yrow1)), dlrec->seq[i].attenddoc_name,
    rowplusone2,
    CALL print(calcpos(xcol1,yrow1)), "{color/14}",
    equal_line, "{color/0}", rowplusone2
    IF (page_cnt > 1
     AND last_title > " "
     AND lastflag=0)
     lastpage_cnt = (page_cnt - 1), lastflag = 0,
     CALL print(calcpos(xcol1,yrow1)),
     "{color/20}-------- ", last_title, "  (Continued from page ",
     lastpage_cnt"###;l", "){color/0}", rowplusone2
    ENDIF
    CALL print(calcpos(xcol6,655)), "Continued", row + 1,
    CALL print(calcpos(xcol1,660)), "{color/12}", equal_line,
    "{color/0}", rowplusone2,
    CALL print(calcpos(xcol1,675)),
    dlrec->seq[i].name_full_formatted,
    CALL print(calcpos(xcol5,675)), "Acct #:",
    dlrec->seq[i].account_nbr,
    CALL print(calcpos(xcol11,675)), "Pg ",
    page_cnt"###;l", row + 1
   DETAIL
    FOR (i = 1 TO dlrec->encntr_total)
      IF (i > 1)
       BREAK
      ENDIF
      colpos2 = 0, title_string = "Allergies:",
      CALL print(calcpos(xcol1,yrow1)),
      "{b}", title_string, "{endb}",
      last_title = title_string, rowplusone
      FOR (a = 1 TO dlrec->seq[i].total_al)
        CALL print(calcpos(xcol1,yrow1)), dlrec->seq[i].allergy[a].allergy_dt_tm, "{b} ",
        dlrec->seq[i].allergy[a].type_source_string, ", Reaction: --", dlrec->seq[i].allergy[a].
        severity,
        "{endb}", rowplusone
      ENDFOR
      title_string = "Patient Data:", title_print
      FOR (a = 1 TO dlrec->seq[i].section1_total)
        CALL print(calcpos(xcol1,yrow1)), dlrec->seq[i].section1_events[a].event_dt_tm, " ",
        dlrec->seq[i].section1_events[a].event_cd_disp, " ", dlrec->seq[i].section1_events[a].result,
        rowplusone
      ENDFOR
      title_string = "Problems:", title_print
      FOR (a = 1 TO dlrec->seq[i].problem_total)
        CALL print(calcpos(xcol1,yrow1)), dlrec->seq[i].problem[a].beg_effective_dt_tm, tempstring =
        dlrec->seq[i].problem[a].full_text,
        xcolvar = (xcol3+ 10), line_wrap
      ENDFOR
      title_string = "Diagnosis:", title_print
      FOR (a = 1 TO dlrec->seq[i].total_diag)
        CALL print(calcpos(xcol1,yrow1)), dlrec->seq[i].diagnosis[a].diag_dt_tm, "{b} ",
        dlrec->seq[i].diagnosis[a].diag_type_desc, ":{endb} ", dlrec->seq[i].diagnosis[a].
        source_string,
        rowplusone
      ENDFOR
      lastflag = 0, title_string = "All Orders:", title_print
      FOR (a = 1 TO dlrec->seq[i].number_of_orders)
        IF ((dlrec->seq[i].orders[a].order_mnemonic="Code Status*"))
         CALL print(calcpos(xcol1,yrow1)), dlrec->seq[i].orders[a].orig_order_dt_tm,
         CALL print(calcpos(xcol10,yrow1)),
         dlrec->seq[i].orders[a].misc, tempstring = concat("{b/",build(size(dlrec->seq[i].orders[a].
            order_mnemonic)),"}",dlrec->seq[i].orders[a].order_mnemonic," ",
          dlrec->seq[i].orders[a].clinical_display_line,"   Entered by: ",dlrec->seq[i].orders[a].
          order_person,"   Order Physician: ",dlrec->seq[i].orders[a].order_doctor), xcolvar = (xcol3
         + 10),
         line_wrap
        ENDIF
      ENDFOR
      FOR (a = 1 TO dlrec->seq[i].number_of_orders)
        IF ((dlrec->seq[i].orders[a].order_mnemonic != "Code Status*"))
         CALL print(calcpos(xcol1,yrow1)), dlrec->seq[i].orders[a].orig_order_dt_tm,
         CALL print(calcpos(xcol10,yrow1)),
         dlrec->seq[i].orders[a].misc, tempstring = concat("{b/",build(size(dlrec->seq[i].orders[a].
            order_mnemonic)),"}",dlrec->seq[i].orders[a].order_mnemonic," ",
          dlrec->seq[i].orders[a].clinical_display_line,"   Entered by: ",dlrec->seq[i].orders[a].
          order_person,"   Order Physician: ",dlrec->seq[i].orders[a].order_doctor), xcolvar = (xcol3
         + 10),
         line_wrap
        ENDIF
      ENDFOR
      lastflag = 0, title_string = "Medications:", title_print,
      lastdatedoc = fillstring(90," ")
      FOR (a = 1 TO dlrec->seq[i].number_of_meds)
        IF (((yrow1+ 36) > 650))
         yrow1 = 651, rowplusone
        ENDIF
        IF (((a=1) OR (a > 1
         AND (dlrec->seq[i].meds[a].mso > dlrec->seq[i].meds[(a - 1)].mso))) )
         CALL print(calcpos((xcol1+ 27),yrow1)), "{b}{color/20}", mso[dlrec->seq[i].meds[a].mso],
         "{endb}{color/0}", rowplusone
        ENDIF
        IF ((a=dlrec->seq[i].number_of_meds))
         lastflag = 1
        ENDIF
        IF ((dlrec->seq[i].meds[a].ioi=1))
         "{color/20}"
        ENDIF
        CALL print(calcpos((xcol1+ 7),yrow1)), "{b}", dlrec->seq[i].meds[a].mnemonic,
        "{endb} ", "     ", dlrec->seq[i].meds[a].order_status_disp,
        "{endb}", breakflag = 0, rowplusone2,
        tempstring = dlrec->seq[i].meds[a].display_line, xcolvar = xcol2, line_wrap,
        "{color/0}"
        IF ((dlrec->seq[i].meds[a].mso=1))
         CALL print(calcpos((xcol1+ 24),yrow1)), "{b}Next Dose: {endb}", dlrec->seq[i].meds[a].
         next_dose_dt_tm,
         breakflag = 1, rowplusone
        ENDIF
      ENDFOR
      rowplusone, breakflag = 1, lastflag = 0,
      title_string = "Results:", title_print
      FOR (a = 1 TO dlrec->seq[i].total_events)
        CALL print(calcpos(xcol1,yrow1)), dlrec->seq[i].events[a].event_dt_tm,
        CALL print(calcpos(xcol10,yrow1)),
        dlrec->seq[i].events[a].misc, tempstring = concat(dlrec->seq[i].events[a].event_cd_disp,
         " {b/",build(size(dlrec->seq[i].events[a].result)),"}",dlrec->seq[i].events[a].result),
        xcolvar = (xcol3+ 10),
        line_wrap
      ENDFOR
    ENDFOR
    rowplusone,
    CALL print(calcpos(xcol5,yrow1)), "** End of Clinical Summary **",
    row + 1
   WITH maxcol = 366, maxrow = 166, dio = postscript
  ;end select
  SET reply->status_data.status = "S"
 ELSE
  SELECT INTO request->output_device
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

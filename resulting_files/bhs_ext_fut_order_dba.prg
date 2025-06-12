CREATE PROGRAM bhs_ext_fut_order:dba
 DECLARE mf_cs6004_future_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!11559"))
 DECLARE mf_cs6000_lab_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3081"))
 DECLARE mf_cs57_male_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2773"))
 DECLARE mf_cs57_female_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2774"))
 DECLARE mf_cs212_home_addr_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4018"))
 DECLARE mf_cs43_email_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4102349364")
  )
 DECLARE mf_cs43_home_phone_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4017"))
 DECLARE mf_cs43_prim_home_phone_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!4000022570"))
 DECLARE mf_cs43_cell_phone_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!2510010055"))
 DECLARE mf_cs27_hisp_yes_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!1003004")
  )
 DECLARE mf_cs27_hisp_no_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!1003005"))
 DECLARE mf_cs282_asian1_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!4001382823"))
 DECLARE mf_cs282_asian2_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!4001382834"))
 DECLARE mf_cs282_asian3_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!4001382821"))
 DECLARE mf_cs282_asian4_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!4001382826"))
 DECLARE mf_cs282_asian5_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!4001382816"))
 DECLARE mf_cs282_asian6_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3948"))
 DECLARE mf_cs282_asian7_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!4001382827"))
 DECLARE mf_cs282_other_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",282,"OTHER"))
 DECLARE mf_cs282_black_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3947"))
 DECLARE mf_cs282_white_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3949"))
 DECLARE mf_cs282_pac_isl1_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!4001382860"))
 DECLARE mf_cs282_pac_isl2_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!4001382861"))
 DECLARE mf_cs282_pac_isl3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",282,
   "OTHERPACIFICISLANDER"))
 DECLARE mf_cs282_amer_indian_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",282,
   "AMERICANINDIANALASKANATIVE"))
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs4_cmrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 DECLARE mf_cs320_npi_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2160654021"))
 DECLARE mf_sunquest_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",73,"SUNQUEST"))
 DECLARE mf_icd9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",400,"ICD9CM"))
 DECLARE mf_icd10_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"ICD10-CM"))
 DECLARE mf_cs23056_tel_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3877599"))
 DECLARE mf_cs23056_email_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3877602")
  )
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx3 = i4 WITH protect, noconstant(0)
 DECLARE ml_cat_loc = i4 WITH protect, noconstant(0)
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 ) WITH protect
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_person_id = f8
     2 s_pat_lname = vc
     2 s_pat_fname = vc
     2 s_pat_mname = vc
     2 s_pat_dob = vc
     2 s_pat_gender = vc
     2 s_pat_address = vc
     2 s_pat_city = vc
     2 s_pat_state = vc
     2 s_pat_zip = vc
     2 s_pat_phone = vc
     2 s_pat_email = vc
     2 s_race = vc
     2 s_ethnicity = vc
     2 s_cmrn = vc
     2 s_bill_type = vc
     2 l_ocnt = i4
     2 oqual[*]
       3 f_order_id = f8
       3 f_encntr_id = f8
       3 f_catalog_cd = f8
       3 l_cat_cnt = i4
       3 f_orig_enc = f8
       3 s_orig_fin = vc
       3 s_acct_name = vc
       3 s_acct_nbr = vc
       3 s_phys_fname = vc
       3 s_phys_lname = vc
       3 s_phys_npi = vc
       3 s_order_code = vc
       3 s_order_name = vc
       3 s_diag = vc
       3 s_collection_date_time = vc
       3 s_req_nbr = vc
 ) WITH protect
 FREE RECORD m_ord
 RECORD m_ord(
   1 l_cnt = i4
   1 qual[*]
     2 f_order_id = f8
 )
 SELECT INTO "nl:"
  FROM orders o,
   person p,
   address a,
   phone ph1,
   phone ph2,
   phone ph3,
   phone ph4,
   phone ph5,
   phone ph6,
   code_value_outbound cvo,
   person_alias pa,
   encounter e,
   encntr_alias ea,
   code_value_outbound cvo2
  PLAN (o
   WHERE o.order_status_cd=mf_cs6004_future_cd
    AND o.catalog_type_cd=mf_cs6000_lab_cd
    AND o.active_ind=1
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime("09-MAR-2024 10:15:01") AND cnvtdatetime(
    "10-MAR-2024 09:10:00")
    AND o.template_order_flag != 7)
   JOIN (p
   WHERE p.person_id=o.person_id
    AND p.active_ind=1)
   JOIN (a
   WHERE (a.parent_entity_id= Outerjoin(p.person_id))
    AND (a.address_type_cd= Outerjoin(mf_cs212_home_addr_cd))
    AND (a.parent_entity_name= Outerjoin("PERSON"))
    AND (a.active_ind= Outerjoin(1))
    AND (a.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (ph1
   WHERE (ph1.parent_entity_id= Outerjoin(p.person_id))
    AND (ph1.parent_entity_name= Outerjoin("PERSON"))
    AND (ph1.phone_type_cd= Outerjoin(mf_cs43_email_cd))
    AND (ph1.active_ind= Outerjoin(1))
    AND (ph1.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (ph2
   WHERE (ph2.parent_entity_id= Outerjoin(p.person_id))
    AND (ph2.parent_entity_name= Outerjoin("PERSON"))
    AND (ph2.phone_type_cd= Outerjoin(mf_cs43_home_phone_cd))
    AND (ph2.active_ind= Outerjoin(1))
    AND (ph2.contact_method_cd= Outerjoin(mf_cs23056_tel_cd))
    AND (ph2.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (ph3
   WHERE (ph3.parent_entity_id= Outerjoin(p.person_id))
    AND (ph3.parent_entity_name= Outerjoin("PERSON"))
    AND (ph3.phone_type_cd= Outerjoin(mf_cs43_prim_home_phone_cd))
    AND (ph3.contact_method_cd= Outerjoin(mf_cs23056_tel_cd))
    AND (ph3.active_ind= Outerjoin(1))
    AND (ph3.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (ph4
   WHERE (ph4.parent_entity_id= Outerjoin(p.person_id))
    AND (ph4.parent_entity_name= Outerjoin("PERSON_PATIENT"))
    AND (ph4.phone_type_cd= Outerjoin(mf_cs43_home_phone_cd))
    AND (ph4.active_ind= Outerjoin(1))
    AND (ph4.contact_method_cd= Outerjoin(mf_cs23056_tel_cd))
    AND (ph4.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (ph5
   WHERE (ph5.parent_entity_id= Outerjoin(p.person_id))
    AND (ph5.parent_entity_name= Outerjoin("PERSON_PATIENT"))
    AND (ph5.phone_type_cd= Outerjoin(mf_cs43_home_phone_cd))
    AND (ph5.active_ind= Outerjoin(1))
    AND (ph5.contact_method_cd= Outerjoin(mf_cs23056_email_cd))
    AND (ph5.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (ph6
   WHERE (ph6.parent_entity_id= Outerjoin(p.person_id))
    AND (ph6.parent_entity_name= Outerjoin("PERSON"))
    AND (ph6.phone_type_cd= Outerjoin(mf_cs43_cell_phone_cd))
    AND (ph6.active_ind= Outerjoin(1))
    AND (ph6.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (cvo
   WHERE (cvo.code_value= Outerjoin(o.catalog_cd))
    AND (cvo.contributor_source_cd= Outerjoin(mf_sunquest_cd))
    AND (cvo.code_set= Outerjoin(200)) )
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(o.person_id))
    AND (pa.active_ind= Outerjoin(1))
    AND (pa.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (pa.person_alias_type_cd= Outerjoin(mf_cs4_cmrn_cd)) )
   JOIN (e
   WHERE (e.encntr_id= Outerjoin(o.originating_encntr_id)) )
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_cs319_fin_cd)) )
   JOIN (cvo2
   WHERE (cvo2.code_value= Outerjoin(e.loc_nurse_unit_cd))
    AND (cvo2.contributor_source_cd= Outerjoin(mf_sunquest_cd))
    AND (cvo2.code_set= Outerjoin(220)) )
  ORDER BY o.person_id, o.order_id, a.address_type_seq,
   ph1.phone_type_seq, ph2.phone_type_seq, ph3.phone_type_seq,
   ph4.phone_type_seq, ph5.phone_type_seq, ph6.phone_type_seq,
   pa.beg_effective_dt_tm
  HEAD o.person_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   s_pat_lname = trim(p.name_last,3),
   m_rec->qual[m_rec->l_cnt].s_pat_fname = trim(p.name_first,3), m_rec->qual[m_rec->l_cnt].
   s_pat_mname = trim(p.name_middle,3), m_rec->qual[m_rec->l_cnt].s_pat_dob = trim(format(
     cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"YYYYMMDD;;q"),3)
   IF (p.sex_cd IN (mf_cs57_male_cd, mf_cs57_female_cd))
    m_rec->qual[m_rec->l_cnt].s_pat_gender = substring(1,1,trim(uar_get_code_display(p.sex_cd),3))
   ELSE
    m_rec->qual[m_rec->l_cnt].s_pat_gender = "N"
   ENDIF
   m_rec->qual[m_rec->l_cnt].s_pat_address = trim(a.street_addr,3), m_rec->qual[m_rec->l_cnt].
   s_pat_city = trim(evaluate(a.city_cd,0.0,a.city,uar_get_code_display(a.city_cd)),3), m_rec->qual[
   m_rec->l_cnt].s_pat_state = trim(evaluate(a.state_cd,0.0,a.state,uar_get_code_display(a.state_cd)),
    3),
   m_rec->qual[m_rec->l_cnt].s_pat_zip = trim(a.zipcode_key,3)
   IF (size(trim(ph5.phone_num_key,3)) > 0)
    m_rec->qual[m_rec->l_cnt].s_pat_email = trim(ph5.phone_num,3)
   ELSE
    m_rec->qual[m_rec->l_cnt].s_pat_email = trim(ph1.phone_num,3)
   ENDIF
   IF (size(trim(ph3.phone_num_key,3)) > 0)
    m_rec->qual[m_rec->l_cnt].s_pat_phone = trim(ph3.phone_num_key,3)
   ELSEIF (size(trim(ph4.phone_num_key,3)) > 0)
    m_rec->qual[m_rec->l_cnt].s_pat_phone = trim(ph4.phone_num_key,3)
   ELSEIF (size(trim(ph2.phone_num_key,3)) > 0)
    m_rec->qual[m_rec->l_cnt].s_pat_phone = trim(ph2.phone_num_key,3)
   ELSE
    m_rec->qual[m_rec->l_cnt].s_pat_phone = trim(ph6.phone_num_key,3)
   ENDIF
   m_rec->qual[m_rec->l_cnt].f_person_id = p.person_id, m_rec->qual[m_rec->l_cnt].s_cmrn = trim(pa
    .alias,3)
   IF (p.ethnic_grp_cd=mf_cs27_hisp_yes_cd)
    m_rec->qual[m_rec->l_cnt].s_ethnicity = "H"
   ELSEIF (p.ethnic_grp_cd=mf_cs27_hisp_no_cd)
    m_rec->qual[m_rec->l_cnt].s_ethnicity = "N"
   ELSE
    m_rec->qual[m_rec->l_cnt].s_ethnicity = "U"
   ENDIF
   IF (p.race_cd IN (mf_cs282_asian1_cd, mf_cs282_asian2_cd, mf_cs282_asian3_cd, mf_cs282_asian4_cd,
   mf_cs282_asian5_cd,
   mf_cs282_asian6_cd, mf_cs282_asian7_cd))
    m_rec->qual[m_rec->l_cnt].s_race = "A"
   ELSEIF (p.race_cd IN (mf_cs282_black_cd))
    m_rec->qual[m_rec->l_cnt].s_race = "B"
   ELSEIF (p.race_cd IN (mf_cs282_white_cd))
    m_rec->qual[m_rec->l_cnt].s_race = "C"
   ELSEIF (p.race_cd IN (mf_cs282_amer_indian_cd))
    m_rec->qual[m_rec->l_cnt].s_race = "I"
   ELSEIF (p.race_cd IN (mf_cs282_other_cd))
    m_rec->qual[m_rec->l_cnt].s_race = "O"
   ELSEIF (p.race_cd IN (mf_cs282_pac_isl1_cd, mf_cs282_pac_isl2_cd, mf_cs282_pac_isl3_cd))
    m_rec->qual[m_rec->l_cnt].s_race = "P"
   ELSE
    m_rec->qual[m_rec->l_cnt].s_race = "X"
   ENDIF
   m_rec->qual[m_rec->l_cnt].s_bill_type = "P"
  HEAD o.order_id
   m_rec->qual[m_rec->l_cnt].l_ocnt += 1, stat = alterlist(m_rec->qual[m_rec->l_cnt].oqual,m_rec->
    qual[m_rec->l_cnt].l_ocnt), m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].
   f_order_id = o.order_id,
   m_ord->l_cnt += 1, stat = alterlist(m_ord->qual,m_ord->l_cnt), m_ord->qual[m_ord->l_cnt].
   f_order_id = o.order_id,
   m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].s_collection_date_time = trim(
    format(o.current_start_dt_tm,"YYYYMMDDHHmm;;q"),3), m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[
   m_rec->l_cnt].l_ocnt].s_order_code = trim(cvo.alias,3), m_rec->qual[m_rec->l_cnt].oqual[m_rec->
   qual[m_rec->l_cnt].l_ocnt].s_order_name = trim(o.order_mnemonic,3),
   ml_cat_loc = 0
   FOR (ml_idx1 = 1 TO m_rec->qual[m_rec->l_cnt].l_ocnt)
     IF ((o.catalog_cd=m_rec->qual[m_rec->l_cnt].oqual[ml_idx1].f_catalog_cd))
      ml_cat_loc = ml_idx1
     ENDIF
   ENDFOR
   m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].f_catalog_cd = o.catalog_cd
   IF (ml_cat_loc=0)
    m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].l_cat_cnt = 1
   ELSE
    m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].l_cat_cnt = (m_rec->qual[m_rec
    ->l_cnt].oqual[ml_cat_loc].l_cat_cnt+ 1)
   ENDIF
   IF (e.encntr_id > 0)
    m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].s_orig_fin = trim(ea.alias,3),
    m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].f_encntr_id = o
    .originating_encntr_id, m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].
    s_acct_nbr = trim(cvo2.alias,3),
    m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].s_acct_name = trim(
     uar_get_code_display(e.loc_nurse_unit_cd),3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_action oa,
   prsnl p,
   prsnl_alias pa
  PLAN (o
   WHERE expand(ml_idx1,1,m_ord->l_cnt,o.order_id,m_ord->qual[ml_idx1].f_order_id))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=1)
   JOIN (p
   WHERE p.person_id=oa.order_provider_id)
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(p.person_id))
    AND (pa.active_ind= Outerjoin(1))
    AND (pa.prsnl_alias_type_cd= Outerjoin(mf_cs320_npi_cd)) )
  ORDER BY o.person_id, o.order_id, pa.beg_effective_dt_tm DESC
  HEAD o.person_id
   ml_idx3 = locatevalsort(ml_idx1,1,m_rec->l_cnt,o.person_id,m_rec->qual[ml_idx1].f_person_id),
   ml_idx2 = 0
  HEAD o.order_id
   IF (ml_idx3 > 0)
    ml_idx2 = locateval(ml_idx1,1,m_rec->qual[ml_idx3].l_ocnt,o.order_id,m_rec->qual[ml_idx3].oqual[
     ml_idx1].f_order_id)
    IF (ml_idx2 > 0)
     m_rec->qual[ml_idx3].oqual[ml_idx2].s_phys_fname = trim(p.name_first,3), m_rec->qual[ml_idx3].
     oqual[ml_idx2].s_phys_lname = trim(p.name_last,3), m_rec->qual[ml_idx3].oqual[ml_idx2].
     s_phys_npi = trim(pa.alias,3)
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   nomen_entity_reltn ner,
   nomenclature n
  PLAN (o
   WHERE expand(ml_idx1,1,m_ord->l_cnt,o.order_id,m_ord->qual[ml_idx1].f_order_id))
   JOIN (ner
   WHERE ner.parent_entity_id=o.order_id
    AND ner.parent_entity_name="ORDERS"
    AND ner.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=ner.nomenclature_id
    AND n.source_vocabulary_cd IN (mf_icd9_cd, mf_icd10_cd))
  ORDER BY o.person_id, ner.parent_entity_id, n.source_identifier
  HEAD o.person_id
   ml_idx3 = locatevalsort(ml_idx1,1,m_rec->l_cnt,o.person_id,m_rec->qual[ml_idx1].f_person_id),
   ml_idx2 = 0
  HEAD ner.parent_entity_id
   IF (ml_idx3 > 0)
    ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,ner.parent_entity_id,m_rec->qual[ml_idx3].oqual[
     ml_idx1].f_order_id)
   ENDIF
  HEAD n.source_identifier
   IF (ml_idx2 > 0)
    IF (size(trim(m_rec->qual[ml_idx3].oqual[ml_idx2].s_diag,3))=0)
     m_rec->qual[ml_idx3].oqual[ml_idx2].s_diag = trim(n.source_identifier,3)
    ELSE
     m_rec->qual[ml_idx3].oqual[ml_idx2].s_diag = concat(m_rec->qual[ml_idx3].oqual[ml_idx2].s_diag,
      ";",trim(n.source_identifier,3))
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SET frec->file_name = concat("bhs_lab_fut_order_ext",format(cnvtdatetime(sysdate),"MMDDYYYY;;q"),
  ".txt")
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = build("Patient Last Name|","Patient First Name|","Patient MI|","Patient DOB|",
  "Patient Gender|",
  "Patient Address|","Patient City|","Patient State|","Patient Zip|","Patient Phone|",
  "Patient eMail|","Race|","Ethnicity|","Req Ctrl #|","Patient ID|",
  "Acct Name|","Acct #|","Bill Type|","Physican First Name|","Physician Last Name|",
  "NPI|","Order Code|","Order Name|","CSID|","Insurance Company Name|",
  "Insurance Company Address|","Insurance Company City|","Insurance Company State|",
  "Insurance Company Zip Code|","Group Number of Insured Patient|",
  "Insured's Relationship to Patient|","Policy Number (Insurance Number)|","Guarantor Last Name|",
  "Guarantor First Name|","Diagnosis Code|",
  "Collection Date and Time|","Fasting|","Source|","CC Type|","CC Text|",
  "CC Attention|","Guarantor Address Line 1|","Guarantor Address Line 2|","Guarantor City|",
  "Guarantor State|",
  "Guarantor Zip|","Guarantor Phone #|","Guarantor Relationship to Patient|",
  "Secondary Insurance Company Name|","Secondary Insurance Company Address Line 1|",
  "Secondary Insurance Company Address Line 2|","Secondary Insurance Company City|",
  "Secondary Insurance Company State|","Secondary Insurance Company Zip Code|",
  "Secondary Group Number of Insured Patient|",
  "Secondary Insured's Relationship to Patient|","Secondary Policy Number (Insurance Number)|",
  "Insurance Payer Code|","FIN # Baystate|","Order ID",
  char(13),char(10))
 SET stat = cclio("WRITE",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_ocnt)
     IF ( NOT ((m_rec->qual[ml_idx1].oqual[ml_idx2].s_acct_nbr IN ("BMA PREOP", "TRNSP DNRB",
     "TRNSP PRE", "TRNSP POST", "BAYPLASURG",
     "BMPMLSRG M", "BMPVLYORTF", "ML MULTISP", "MOCK - CICU", "EDN",
     "CHST", "S3", "SW6", "W4", "WIN2"))))
      IF (size(trim(m_rec->qual[ml_idx1].oqual[ml_idx2].s_acct_nbr,3))=0)
       SET m_rec->qual[ml_idx1].oqual[ml_idx2].s_acct_nbr = m_rec->qual[ml_idx1].oqual[ml_idx2].
       s_acct_name
      ENDIF
      IF (trim(m_rec->qual[ml_idx1].oqual[ml_idx2].s_acct_nbr,3)="Heme/Onc Adult")
       SET m_rec->qual[ml_idx1].oqual[ml_idx2].s_acct_nbr = "H/ONC-ADLT"
      ELSEIF (trim(m_rec->qual[ml_idx1].oqual[ml_idx2].s_acct_nbr,3)="Heme/Onc Pedi")
       SET m_rec->qual[ml_idx1].oqual[ml_idx2].s_acct_nbr = "H/ONC-PEDI"
      ENDIF
      IF (size(trim(m_rec->qual[ml_idx1].oqual[ml_idx2].s_orig_fin,3)) > 0)
       SET m_rec->qual[ml_idx1].oqual[ml_idx2].s_req_nbr = concat(m_rec->qual[ml_idx1].oqual[ml_idx2]
        .s_orig_fin,"-",trim(cnvtstring(m_rec->qual[ml_idx1].oqual[ml_idx2].l_cat_cnt,20,0),3))
      ELSEIF ((m_rec->qual[ml_idx1].oqual[ml_idx2].f_encntr_id > 0))
       SET m_rec->qual[ml_idx1].oqual[ml_idx2].s_req_nbr = concat(trim(cnvtstring(m_rec->qual[ml_idx1
          ].oqual[ml_idx2].f_encntr_id,20,0),3),"-",trim(cnvtstring(m_rec->qual[ml_idx1].oqual[
          ml_idx2].l_cat_cnt,20,0),3))
      ELSE
       SET m_rec->qual[ml_idx1].oqual[ml_idx2].s_req_nbr = concat(trim(cnvtstring(m_rec->qual[ml_idx1
          ].oqual[ml_idx2].f_order_id,20,0),3),trim(cnvtstring(m_rec->qual[ml_idx1].f_person_id,20,0),
         3),"-",trim(cnvtstring(m_rec->qual[ml_idx1].oqual[ml_idx2].l_cat_cnt,20,0),3))
      ENDIF
      SET frec->file_buf = build(trim(m_rec->qual[ml_idx1].s_pat_lname,3),"|",trim(m_rec->qual[
        ml_idx1].s_pat_fname,3),"|",trim(m_rec->qual[ml_idx1].s_pat_mname,3),
       "|",trim(m_rec->qual[ml_idx1].s_pat_dob,3),"|",trim(m_rec->qual[ml_idx1].s_pat_gender,3),"|",
       trim(m_rec->qual[ml_idx1].s_pat_address,3),"|",trim(m_rec->qual[ml_idx1].s_pat_city,3),"|",
       trim(m_rec->qual[ml_idx1].s_pat_state,3),
       "|",trim(m_rec->qual[ml_idx1].s_pat_zip,3),"|",trim(m_rec->qual[ml_idx1].s_pat_phone,3),"|",
       trim(m_rec->qual[ml_idx1].s_pat_email,3),"|",trim(m_rec->qual[ml_idx1].s_race,3),"|",trim(
        m_rec->qual[ml_idx1].s_ethnicity,3),
       "|",trim(m_rec->qual[ml_idx1].oqual[ml_idx2].s_req_nbr,3),"|",trim(m_rec->qual[ml_idx1].s_cmrn,
        3),"|",
       trim(m_rec->qual[ml_idx1].oqual[ml_idx2].s_acct_name,3),"|",trim(m_rec->qual[ml_idx1].oqual[
        ml_idx2].s_acct_nbr,3),"|",trim(m_rec->qual[ml_idx1].s_bill_type,3),
       "|",trim(m_rec->qual[ml_idx1].oqual[ml_idx2].s_phys_fname,3),"|",trim(m_rec->qual[ml_idx1].
        oqual[ml_idx2].s_phys_lname,3),"|",
       trim(m_rec->qual[ml_idx1].oqual[ml_idx2].s_phys_npi,3),"|",trim(m_rec->qual[ml_idx1].oqual[
        ml_idx2].s_order_code,3),"|",trim(m_rec->qual[ml_idx1].oqual[ml_idx2].s_order_name,3),
       "|","|","|","|","|",
       "|","|","|","|","|",
       "|","|",trim(m_rec->qual[ml_idx1].oqual[ml_idx2].s_diag,3),"|",trim(m_rec->qual[ml_idx1].
        oqual[ml_idx2].s_collection_date_time,3),
       "|","|","|","|","|",
       "|","|","|","|","|",
       "|","|","|","|","|",
       "|","|","|","|","|",
       "|","|","|","FUT",trim(substring(1,16,trim(m_rec->qual[ml_idx1].oqual[ml_idx2].s_orig_fin,3)),
        3),
       "|",trim(cnvtstring(m_rec->qual[ml_idx1].oqual[ml_idx2].f_order_id,20,0),3))
      SET frec->file_buf = concat(replace(replace(frec->file_buf,char(13)," "),char(10)," "),char(13),
       char(10))
      SET stat = cclio("WRITE",frec)
     ENDIF
   ENDFOR
 ENDFOR
 SET stat = cclio("CLOSE",frec)
#exit_script
END GO

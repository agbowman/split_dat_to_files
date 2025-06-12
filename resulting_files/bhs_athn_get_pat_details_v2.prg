CREATE PROGRAM bhs_athn_get_pat_details_v2
 DECLARE moutputdevice = vc WITH noconstant( $1)
 DECLARE f_pcp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",331,"PCP"))
 DECLARE f_preff_lag_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PREFERREDLANGFORDISCUSSINGHLTHCARE"))
 DECLARE f_chief_comp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"CHIEFCOMPLAINT"
   ))
 DECLARE f_body_wt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"DRYWEIGHT"))
 DECLARE f_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE f_res_status_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED"))
 DECLARE f_addr_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",212,"HOME"))
 DECLARE per_id = f8 WITH protect, constant( $2)
 DECLARE enc_id = f8 WITH protect, constant( $3)
 DECLARE patidx = i4 WITH protect, noconstant(0)
 DECLARE f_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE f_phone_type_h_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE f_phone_type_b_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 DECLARE f_phone_type_m_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"MOBILE"))
 SET where_pat_params = build(" P.PERSON_ID = ",per_id)
 IF (enc_id > 0)
  SET where_enc_params = build(" E.ENCNTR_ID = ",enc_id)
 ELSE
  SET where_enc_params = build(" E.ENCNTR_ID = OUTERJOIN(0)")
 ENDIF
 FREE RECORD patients
 RECORD patients(
   1 person_id = vc
   1 encntr_id = vc
   1 enc_created_dt_tm = vc
   1 fin = vc
   1 enc_status = vc
   1 enc_type = vc
   1 enc_facility = vc
   1 enc_facility_cd = vc
   1 enc_location = vc
   1 enc_location_cd = vc
   1 enc_med_service_disp = vc
   1 pcp = vc
   1 chief_complaint = vc
   1 ethnicity_cd = vc
   1 ethnicity_display = vc
   1 pref_language = vc
   1 body_weight = vc
   1 body_weight_unit = vc
   1 pre_reg_dt_tm = vc
   1 reg_dt_tm = vc
   1 disch_dt_tm = vc
   1 inpat_admit_dt_tm = vc
   1 arrive_dt_tm = vc
   1 est_arrive_dt_tm = vc
   1 name_full_formatted = vc
   1 sex_cd = vc
   1 sex = vc
   1 mrn = vc
   1 encntr_type = vc
   1 dob = vc
   1 age = vc
   1 fname = vc
   1 mname = vc
   1 lname = vc
   1 street_addr1 = vc
   1 street_addr2 = vc
   1 street_addr3 = vc
   1 street_addr4 = vc
   1 zipcode = vc
   1 city = vc
   1 state = vc
   1 country = vc
   1 county = vc
   1 last_visit_dt_tm = vc
   1 admit_phys = vc
   1 refer_phys = vc
   1 pcp_phys = vc
   1 ph_home = vc
   1 ph_work = vc
   1 ph_cell = vc
 )
 SELECT INTO "NL:"
  admit_phys = pm_get_encntr_prsnl("ADMITDOC",e.encntr_id,sysdate), refer_phys = pm_get_encntr_prsnl(
   "REFERDOC",e.encntr_id,sysdate), pcp_phys = pm_get_person_prsnl("PCP",e.person_id,sysdate)
  FROM person p,
   encounter e,
   person_alias pa,
   encntr_alias ea,
   address a,
   phone ph
  PLAN (p
   WHERE parser(where_pat_params))
   JOIN (e
   WHERE (e.person_id= Outerjoin(p.person_id))
    AND parser(where_enc_params))
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(p.person_id))
    AND (pa.active_ind= Outerjoin(1))
    AND (pa.beg_effective_dt_tm< Outerjoin(sysdate))
    AND (pa.end_effective_dt_tm> Outerjoin(sysdate))
    AND (pa.person_alias_type_cd= Outerjoin(f_mrn_cd)) )
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.beg_effective_dt_tm< Outerjoin(sysdate))
    AND (ea.end_effective_dt_tm> Outerjoin(sysdate))
    AND (ea.encntr_alias_type_cd= Outerjoin(f_fin_cd)) )
   JOIN (a
   WHERE (a.parent_entity_id= Outerjoin(p.person_id))
    AND (a.active_ind= Outerjoin(1))
    AND (a.beg_effective_dt_tm< Outerjoin(sysdate))
    AND (a.end_effective_dt_tm> Outerjoin(sysdate))
    AND (a.address_type_cd= Outerjoin(f_addr_type_cd)) )
   JOIN (ph
   WHERE (ph.parent_entity_id= Outerjoin(p.person_id))
    AND (ph.parent_entity_name= Outerjoin("PERSON"))
    AND (ph.phone_num!= Outerjoin(" "))
    AND (ph.phone_num_key!= Outerjoin("0000000000"))
    AND (ph.active_ind= Outerjoin(1)) )
  ORDER BY p.person_id, a.parent_entity_id, a.address_type_seq
  HEAD REPORT
   patidx = 0
  HEAD p.person_id
   patidx += 1, patients->person_id = cnvtstring(p.person_id)
   IF (e.encntr_id > 0)
    patients->encntr_id = cnvtstring(e.encntr_id), patients->enc_facility_cd = cnvtstring(e
     .loc_facility_cd), patients->enc_location_cd = cnvtstring(e.loc_nurse_unit_cd)
   ENDIF
   patients->fin = trim(ea.alias,3), patients->enc_type = trim(uar_get_code_display(e.encntr_type_cd),
    3), patients->enc_status = trim(uar_get_code_display(e.encntr_status_cd),3),
   patients->enc_facility = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(e
           .loc_facility_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3), patients->enc_location = trim(replace(replace(replace(replace(replace(trim(
          uar_get_code_display(e.loc_nurse_unit_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3), patients->pre_reg_dt_tm = format(e.pre_reg_dt_tm,
    "MM/DD/YYYY HH:MM:SS;;D"),
   patients->reg_dt_tm = format(e.reg_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), patients->inpat_admit_dt_tm =
   format(e.inpatient_admit_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), patients->disch_dt_tm = format(e
    .disch_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
   patients->arrive_dt_tm = format(e.arrive_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), patients->
   est_arrive_dt_tm = format(e.est_arrive_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), patients->
   enc_med_service_disp = uar_get_code_display(e.med_service_cd),
   patients->name_full_formatted = trim(p.name_full_formatted,3), patients->sex_cd = cnvtstring(p
    .sex_cd), patients->sex = trim(uar_get_code_display(p.sex_cd),3),
   patients->ethnicity_cd = cnvtstring(p.ethnic_grp_cd), patients->ethnicity_display = trim(
    uar_get_code_display(p.ethnic_grp_cd),3)
   IF (2=textlen(trim(pa.alias,3)))
    patients->mrn = build("00000",trim(pa.alias,3))
   ELSEIF (3=textlen(trim(pa.alias,3)))
    patients->mrn = build("0000",trim(pa.alias,3))
   ELSEIF (4=textlen(trim(pa.alias,3)))
    patients->mrn = build("000",trim(pa.alias,3))
   ELSEIF (5=textlen(trim(pa.alias,3)))
    patients->mrn = build("00",trim(pa.alias,3))
   ELSEIF (6=textlen(trim(pa.alias,3)))
    patients->mrn = build("0",trim(pa.alias,3))
   ELSE
    patients->mrn = trim(pa.alias,3)
   ENDIF
   patients->dob = format(p.birth_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), patients->age = cnvtage(p
    .birth_dt_tm), patients->fname = trim(p.name_first,3),
   patients->mname = trim(p.name_middle,3), patients->lname = trim(p.name_last,3), patients->
   street_addr1 = trim(a.street_addr,3),
   patients->street_addr2 = trim(a.street_addr2,3), patients->street_addr3 = trim(a.street_addr3,3),
   patients->street_addr4 = trim(a.street_addr4,3),
   patients->zipcode = trim(a.zipcode_key,3), patients->city =
   IF (a.city_cd=0) trim(a.city,3)
   ELSE trim(uar_get_code_display(a.city_cd),3)
   ENDIF
   , patients->state =
   IF (a.state_cd=0) trim(a.state,3)
   ELSE trim(uar_get_code_display(a.state_cd),3)
   ENDIF
   ,
   patients->country =
   IF (a.country_cd=0) trim(a.country,3)
   ELSE trim(uar_get_code_display(a.country_cd),3)
   ENDIF
   , patients->county =
   IF (a.county_cd=0) trim(a.county,3)
   ELSE trim(uar_get_code_display(a.county_cd),3)
   ENDIF
   , patients->admit_phys = trim(admit_phys,3),
   patients->refer_phys = trim(refer_phys,3), patients->pcp_phys = trim(pcp_phys,3), patients->
   chief_complaint = trim(replace(replace(replace(replace(replace(trim(e.reason_for_visit,3),"&",
         "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   patients->admit_phys = trim(admit_phys,3)
  HEAD ph.phone_type_cd
   IF (ph.phone_type_cd=f_phone_type_h_cd)
    patients->ph_home = trim(ph.phone_num,3)
   ELSEIF (ph.phone_type_cd=f_phone_type_b_cd)
    patients->ph_work = trim(ph.phone_num,3)
   ELSEIF (ph.phone_type_cd=f_phone_type_m_cd)
    patients->ph_cell = trim(ph.phone_num,3)
   ENDIF
  WITH nocounter, time = 20
 ;end select
 IF (enc_id > 0)
  SELECT INTO "NL:"
   c.result_val
   FROM clinical_event c
   WHERE c.person_id=per_id
    AND c.encntr_id=enc_id
    AND c.event_cd=f_preff_lag_cd
    AND c.result_status_cd=f_res_status_cd
   ORDER BY c.updt_dt_tm DESC, c.event_id DESC
   HEAD c.person_id
    patients->pref_language = trim(c.result_val,3)
   WITH nocounter, time = 10
  ;end select
  SELECT INTO "NL:"
   c.result_val, result = concat(trim(c.result_val,3)," ",trim(uar_get_code_display(c.result_units_cd
      ),3))
   FROM clinical_event c
   WHERE c.person_id=per_id
    AND c.encntr_id=enc_id
    AND c.event_cd=f_body_wt_cd
    AND c.result_status_cd=f_res_status_cd
   ORDER BY c.updt_dt_tm DESC, c.event_id DESC
   HEAD c.person_id
    patients->body_weight = trim(result,3), patients->body_weight_unit = cnvtstring(c.result_units_cd
     )
   WITH nocounter, time = 10
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM encounter enc,
   encntr_alias ea1
  PLAN (enc
   WHERE enc.person_id=per_id
    AND enc.encntr_id != enc_id
    AND enc.disch_dt_tm IS NOT null
    AND enc.reg_dt_tm IS NOT null
    AND enc.encntr_type_cd > 0)
   JOIN (ea1
   WHERE ea1.encntr_id=enc.encntr_id
    AND ea1.encntr_alias_type_cd=f_fin_cd
    AND ea1.end_effective_dt_tm > sysdate
    AND ea1.active_ind=1)
  ORDER BY enc.disch_dt_tm DESC
  HEAD REPORT
   patients->enc_created_dt_tm = trim(format(enc.reg_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),3)
  WITH nocounter, time = 10
 ;end select
 EXECUTE bhs_athn_write_json_output  WITH replace("OUT_REC","PATIENTS"), replace("OUT_REC","PATIENTS"
  )
END GO

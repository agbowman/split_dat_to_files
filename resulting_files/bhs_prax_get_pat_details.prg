CREATE PROGRAM bhs_prax_get_pat_details
 DECLARE f_pcp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",331,"PCP"))
 DECLARE f_preff_lag_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PREFERREDLANGFORDISCUSSINGHLTHCARE"))
 DECLARE f_chief_comp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"CHIEFCOMPLAINT"
   ))
 DECLARE f_body_wt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"DOSINGBODYWEIGHT")
  )
 DECLARE f_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE per_id = f8 WITH protect, constant( $2)
 DECLARE enc_id = f8 WITH protect, constant( $3)
 DECLARE patidx = i4 WITH protect, noconstant(0)
 DECLARE f_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 SET where_pat_params = build(" P.PERSON_ID = ",per_id)
 SET where_enc_params = build(" E.ENCNTR_ID = ",enc_id)
 FREE RECORD patients
 RECORD patients(
   1 person_id = i8
   1 encntr_id = i8
   1 enc_created_dt_tm = vc
   1 fin = vc
   1 enc_status = vc
   1 enc_type = vc
   1 enc_facility = vc
   1 pcp = vc
   1 chief_complaint = vc
   1 pref_language = vc
   1 body_weight = vc
   1 pre_reg_dt_tm = vc
   1 disch_dt_tm = vc
   1 inpat_admit_dt_tm = vc
   1 arrive_dt_tm = vc
   1 est_arrive_dt_tm = vc
   1 name_full_formatted = vc
   1 sex_cd = f8
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
   1 attend_phy = vc
 )
 DECLARE person_id = i4 WITH protect, noconstant(0)
 DECLARE encntr_id = i4 WITH protect, noconstant(0)
 DECLARE enc_created_dt_tm = vc WITH protect, noconstant("")
 DECLARE fin = vc WITH protect, noconstant("")
 DECLARE enc_status = vc WITH protect, noconstant("")
 DECLARE enc_type = vc WITH protect, noconstant("")
 DECLARE enc_facility = vc WITH protect, noconstant("")
 DECLARE pcp = vc WITH protect, noconstant("")
 DECLARE chief_complaint = vc WITH protect, noconstant("")
 DECLARE pref_language = vc WITH protect, noconstant("")
 DECLARE body_weight = vc WITH protect, noconstant("")
 DECLARE pre_reg_dt_tm = vc WITH protect, noconstant("")
 DECLARE disch_dt_tm = vc WITH protect, noconstant("")
 DECLARE inpat_admit_dt_tm = vc WITH protect, noconstant("")
 DECLARE arrive_dt_tm = vc WITH protect, noconstant("")
 DECLARE est_arrive_dt_tm = vc WITH protect, noconstant("")
 DECLARE name_full_formatted = vc WITH protect, noconstant("")
 DECLARE sex_cd = f8 WITH protect, noconstant(0.0)
 DECLARE sex = vc WITH protect, noconstant("")
 DECLARE mrn = vc WITH protect, noconstant("")
 DECLARE fin = vc WITH protect, noconstant("")
 DECLARE dob = vc WITH protect, noconstant("")
 DECLARE age = vc WITH protect, noconstant("")
 DECLARE fname = vc WITH protect, noconstant("")
 DECLARE mname = vc WITH protect, noconstant("")
 DECLARE lname = vc WITH protect, noconstant("")
 DECLARE street_addr1 = vc WITH protect, noconstant("")
 DECLARE street_addr2 = vc WITH protect, noconstant("")
 DECLARE street_addr3 = vc WITH protect, noconstant("")
 DECLARE street_addr4 = vc WITH protect, noconstant("")
 DECLARE zipcode = vc WITH protect, noconstant("")
 DECLARE city = vc WITH protect, noconstant("")
 DECLARE state = vc WITH protect, noconstant("")
 DECLARE country = vc WITH protect, noconstant("")
 DECLARE county = vc WITH protect, noconstant("")
 DECLARE v1 = vc WITH protect, noconstant("")
 DECLARE v2 = vc WITH protect, noconstant("")
 DECLARE v3 = vc WITH protect, noconstant("")
 DECLARE v4 = vc WITH protect, noconstant("")
 DECLARE v5 = vc WITH protect, noconstant("")
 DECLARE v6 = vc WITH protect, noconstant("")
 DECLARE v7 = vc WITH protect, noconstant("")
 DECLARE v8 = vc WITH protect, noconstant("")
 DECLARE v9 = vc WITH protect, noconstant("")
 DECLARE v10 = vc WITH protect, noconstant("")
 DECLARE v11 = vc WITH protect, noconstant("")
 DECLARE v12 = vc WITH protect, noconstant("")
 DECLARE v13 = vc WITH protect, noconstant("")
 DECLARE v14 = vc WITH protect, noconstant("")
 DECLARE v15 = vc WITH protect, noconstant("")
 DECLARE v16 = vc WITH protect, noconstant("")
 DECLARE v17 = vc WITH protect, noconstant("")
 DECLARE v18 = vc WITH protect, noconstant("")
 DECLARE v19 = vc WITH protect, noconstant("")
 DECLARE v20 = vc WITH protect, noconstant("")
 DECLARE v21 = vc WITH protect, noconstant("")
 DECLARE v22 = vc WITH protect, noconstant("")
 DECLARE v23 = vc WITH protect, noconstant("")
 DECLARE v24 = vc WITH protect, noconstant("")
 DECLARE v25 = vc WITH protect, noconstant("")
 DECLARE v26 = vc WITH protect, noconstant("")
 DECLARE v27 = vc WITH protect, noconstant("")
 DECLARE v28 = vc WITH protect, noconstant("")
 DECLARE v29 = vc WITH protect, noconstant("")
 DECLARE v30 = vc WITH protect, noconstant("")
 DECLARE v31 = vc WITH protect, noconstant("")
 DECLARE v32 = vc WITH protect, noconstant("")
 DECLARE v33 = vc WITH protect, noconstant("")
 DECLARE v34 = vc WITH protect, noconstant("")
 DECLARE v35 = vc WITH protect, noconstant("")
 DECLARE v36 = vc WITH protect, noconstant("")
 DECLARE v37 = vc WITH protect, noconstant("")
 DECLARE v38 = vc WITH protect, noconstant("")
 DECLARE v39 = vc WITH protect, noconstant("")
 DECLARE v40 = vc WITH protect, noconstant("")
 DECLARE v41 = vc WITH protect, noconstant("")
 DECLARE v42 = vc WITH protect, noconstant("")
 DECLARE v43 = vc WITH protect, noconstant("")
 SELECT INTO "NL:"
  admit_phys = pm_get_encntr_prsnl("ADMITDOC",e.encntr_id,sysdate), refer_phys = pm_get_encntr_prsnl(
   "REFERDOC",e.encntr_id,sysdate), pcp_phys = pm_get_person_prsnl("PCP",e.person_id,sysdate),
  attend_phy = pm_get_encntr_prsnl("ATTENDDOC",e.encntr_id,sysdate)
  FROM person p,
   encounter e,
   person_alias pa,
   encntr_alias ea,
   address a
  PLAN (p
   WHERE parser(where_pat_params))
   JOIN (e
   WHERE e.person_id=p.person_id
    AND parser(where_enc_params))
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < sysdate
    AND pa.end_effective_dt_tm > sysdate
    AND pa.person_alias_type_cd=f_mrn_cd)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm < sysdate
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=f_fin_cd)
   JOIN (a
   WHERE a.parent_entity_id=outerjoin(p.person_id)
    AND a.active_ind=outerjoin(1)
    AND a.beg_effective_dt_tm < outerjoin(sysdate)
    AND a.end_effective_dt_tm > outerjoin(sysdate)
    AND a.address_type_cd=outerjoin(756))
  ORDER BY p.person_id, a.parent_entity_id, a.address_type_seq
  HEAD REPORT
   patidx = 0
  HEAD p.person_id
   patidx = (patidx+ 1), patients->person_id = cnvtint(p.person_id), patients->encntr_id = cnvtint(e
    .encntr_id),
   patients->enc_created_dt_tm = trim(format(e.reg_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),3), patients->fin
    = trim(ea.alias,3), patients->enc_type = trim(uar_get_code_display(e.encntr_type_class_cd),3),
   patients->enc_status = trim(uar_get_code_display(e.encntr_status_cd),3), patients->enc_facility =
   trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(e.loc_facility_cd),3),"&",
         "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), patients->
   pre_reg_dt_tm = format(e.pre_reg_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
   patients->inpat_admit_dt_tm = format(e.inpatient_admit_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), patients->
   disch_dt_tm = format(e.disch_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), patients->arrive_dt_tm = format(e
    .arrive_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
   patients->est_arrive_dt_tm = format(e.est_arrive_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), patients->
   name_full_formatted = trim(p.name_full_formatted,3), patients->sex_cd = p.sex_cd,
   patients->sex = trim(uar_get_code_display(p.sex_cd),3)
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
   attend_phy = trim(attend_phy,3)
  WITH nocounter, time = 20
 ;end select
 SELECT INTO "NL:"
  c.result_val
  FROM clinical_event c
  WHERE c.person_id=per_id
   AND c.encntr_id=enc_id
   AND c.event_cd=f_preff_lag_cd
   AND c.result_status_cd=25
  ORDER BY c.updt_dt_tm DESC, c.event_id DESC
  HEAD c.person_id
   patients->pref_language = trim(c.result_val,3)
  WITH nocounter, time = 10
 ;end select
 SELECT INTO "NL:"
  c.result_val
  FROM clinical_event c
  WHERE c.person_id=per_id
   AND c.encntr_id=enc_id
   AND c.event_cd=f_body_wt_cd
   AND c.result_status_cd=25
  ORDER BY c.updt_dt_tm DESC, c.event_id DESC
  HEAD c.person_id
   patients->body_weight = trim(c.result_val,3)
  WITH nocounter, time = 10
 ;end select
 SELECT INTO "nl:"
  e.encntr_id, e.inpatient_admit_dt_tm, e.reg_dt_tm
  FROM encounter e
  PLAN (e
   WHERE e.person_id=per_id
    AND e.encntr_id != enc_id)
  ORDER BY e.reg_dt_tm DESC
 ;end select
 SELECT INTO  $1
  FROM dummyt dt
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>"
   IF (patidx > 0)
    person_id = patients->person_id, encntr_id = patients->encntr_id, enc_created_dt_tm = trim(
     patients->enc_created_dt_tm,3),
    fin = patients->fin, enc_status = patients->enc_status, enc_type = patients->enc_type,
    enc_facility = patients->enc_facility, pcp = patients->pcp, chief_complaint = patients->
    chief_complaint,
    pref_language = patients->pref_language, body_weight = patients->body_weight, pre_reg_dt_tm =
    patients->pre_reg_dt_tm,
    disch_dt_tm = patients->disch_dt_tm, inpat_admit_dt_tm = patients->inpat_admit_dt_tm,
    arrive_dt_tm = patients->arrive_dt_tm,
    est_arrive_dt_tm = patients->est_arrive_dt_tm, name_full_formatted = patients->
    name_full_formatted, sex_cd = patients->sex_cd,
    sex = patients->sex, mrn = patients->mrn, dob = patients->dob,
    age = patients->age, fname = patients->fname, mname = patients->mname,
    lname = patients->lname, street_addr1 = patients->street_addr1, street_addr2 = patients->
    street_addr2,
    street_addr3 = patients->street_addr3, street_addr4 = patients->street_addr4, zipcode = patients
    ->zipcode,
    city = patients->city, state = patients->state, country = patients->country,
    county = patients->county
   ELSE
    person_id = 0, encntr_id = 0, enc_created_dt_tm = "",
    fin = "", enc_status = "", enc_type = "",
    enc_facility = "", pcp = "", chief_complaint = "",
    pref_language = "", body_weight = "", pre_reg_dt_tm = "",
    disch_dt_tm = "", inpat_admit_dt_tm = "", arrive_dt_tm = "",
    est_arrive_dt_tm = "", name_full_formatted = "", sex_cd = 0.0,
    sex = "", mrn = "", dob = "",
    age = "", fname = "", mname = "",
    lname = "", street_addr1 = "", street_addr2 = "",
    street_addr3 = "", street_addr4 = "", zipcode = "",
    city = "", state = "", country = "",
    county = ""
   ENDIF
   v1 = build("<PersonId>",person_id,"</PersonId>"), col + 1, v1,
   row + 1, v2 = build("<EncntrId>",encntr_id,"</EncntrId>"), col + 1,
   v2, row + 1, v3 = build("<PrimaryCarePhysician>",trim(replace(replace(replace(replace(replace(
          patients->pcp_phys,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
      0),3),"</PrimaryCarePhysician>"),
   col + 1, v3, row + 1,
   v41 = build("<AdmittingPhysician>",trim(replace(replace(replace(replace(replace(patients->
          admit_phys,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
    "</AdmittingPhysician>"), col + 1, v41,
   row + 1, v42 = build("<ReferringPhysician>",trim(replace(replace(replace(replace(replace(patients
          ->refer_phys,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
    "</ReferringPhysician>"), col + 1,
   v42, row + 1, v43 = build("<AttendingPhysician>",trim(replace(replace(replace(replace(replace(
          patients->attend_phy,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
      "&quot;",0),3),"</AttendingPhysician>"),
   col + 1, v43, row + 1,
   v4 = build("<LastVisitDateTime>",trim(enc_created_dt_tm,3),"</LastVisitDateTime>"), col + 1, v4,
   row + 1, v5 = build("<ChiefComplaint>",trim(chief_complaint,3),"</ChiefComplaint>"), col + 1,
   v5, row + 1, v6 = build("<PreferredLanguage>",trim(pref_language,3),"</PreferredLanguage>"),
   col + 1, v6, row + 1,
   v7 = build("<DosingBodyWeight>",trim(body_weight,3),"</DosingBodyWeight>"), col + 1, v7,
   row + 1, v8 = build("<FIN>",trim(fin,3),"</FIN>"), col + 1,
   v8, row + 1, v9 = build("<EncounterStatus>",trim(patients->enc_status,3),"</EncounterStatus>"),
   col + 1, v9, row + 1,
   v10 = build("<EncounterType>",trim(enc_type,3),"</EncounterType>"), col + 1, v10,
   row + 1, v11 = build("<EncounterLocFacility>",trim(enc_facility,3),"</EncounterLocFacility>"), col
    + 1,
   v11, row + 1, v12 = build("<RegistrationDateTime>",trim(enc_created_dt_tm,3),
    "</RegistrationDateTime>"),
   col + 1, v12, row + 1,
   v13 = build("<PreRegistrationDateTime>",trim(pre_reg_dt_tm,3),"</PreRegistrationDateTime>"), col
    + 1, v13,
   row + 1, v14 = build("<InpatientAdmitDateTime>",trim(inpat_admit_dt_tm,3),
    "</InpatientAdmitDateTime>"), col + 1,
   v14, row + 1, v15 = build("<DischargeDateTime>",trim(disch_dt_tm,3),"</DischargeDateTime>"),
   col + 1, v15, row + 1,
   v16 = build("<ArriveDateTime>",trim(arrive_dt_tm,3),"</ArriveDateTime>"), col + 1, v16,
   row + 1, v17 = build("<EstimatedArriveDateTime>",trim(est_arrive_dt_tm,3),
    "</EstimatedArriveDateTime>"), col + 1,
   v17, row + 1, col + 1,
   "<Patient>", row + 1, v18 = build("<FullName>",trim(name_full_formatted,3),"</FullName>"),
   col + 1, v18, row + 1,
   v19 = build("<SexCd>",cnvtint(sex_cd),"</SexCd>"), col + 1, v19,
   row + 1, v20 = build("<Sex>",trim(sex,3),"</Sex>"), col + 1,
   v20, row + 1, v21 = build("<MRN>",trim(mrn,3),"</MRN>"),
   col + 1, v21, row + 1,
   v22 = build("<DateOfBirth>",trim(dob,3),"</DateOfBirth>"), col + 1, v22,
   row + 1, v23 = build("<Age>",trim(age,3),"</Age>"), col + 1,
   v23, row + 1, v24 = build("<Fname>",trim(fname,3),"</Fname>"),
   col + 1, v24, row + 1,
   v25 = build("<Mname>",trim(mname,3),"</Mname>"), col + 1, v25,
   row + 1, v26 = build("<Lname>",trim(lname,3),"</Lname>"), col + 1,
   v26, row + 1, v27 = build("<StreetAddr1>",trim(street_addr1,3),"</StreetAddr1>"),
   col + 1, v27, row + 1,
   v28 = build("<StreetAddr2>",trim(street_addr2,3),"</StreetAddr2>"), col + 1, v28,
   row + 1, v29 = build("<StreetAddr3>",trim(street_addr3,3),"</StreetAddr3>"), col + 1,
   v29, row + 1, v30 = build("<StreetAddr4>",trim(street_addr4,3),"</StreetAddr4>"),
   col + 1, v30, row + 1,
   v31 = build("<ZipCode>",trim(zipcode,3),"</ZipCode>"), col + 1, v31,
   row + 1, v32 = build("<City>",trim(city,3),"</City>"), col + 1,
   v32, row + 1, v33 = build("<State>",trim(state,3),"</State>"),
   col + 1, v33, row + 1,
   v34 = build("<Country>",trim(country,3),"</Country>"), col + 1, v34,
   row + 1, v35 = build("<County>",trim(county,3),"</County>"), col + 1,
   v35, row + 1, col + 1,
   "</Patient>", row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH maxcol = 1000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 10
 ;end select
END GO

CREATE PROGRAM bhs_athn_allpatient_ls_v2
 DECLARE f_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE f_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE f_pcp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",331,"PCP"))
 DECLARE f_enc_status_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",261,"ACTIVE"))
 DECLARE f_phone_type_h_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE f_phone_type_b_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 DECLARE f_phone_type_m_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"MOBILE"))
 DECLARE default_where_params = vc WITH constant(build("1=1"))
 DECLARE where_search_fname_params = vc WITH noconstant(" ")
 DECLARE where_search_lname_params = vc WITH noconstant(" ")
 DECLARE where_search_mrn_params = vc WITH noconstant(" ")
 DECLARE where_search_fin_params = vc WITH noconstant(" ")
 DECLARE where_birth_dt_params = vc WITH noconstant(" ")
 DECLARE where_sex_cd_params = vc WITH noconstant(" ")
 DECLARE where_enc_disch_dt_params = vc WITH noconstant(" ")
 DECLARE where_loc_fac_cd_params = vc WITH noconstant(" ")
 DECLARE where_loc_nu_cd_params = vc WITH noconstant(" ")
 DECLARE where_active_status_params = vc WITH noconstant(" ")
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE cnt1 = i4 WITH noconstant(0)
 DECLARE cnt2 = i4 WITH noconstant(0)
 FREE RECORD ip_list
 RECORD ip_list(
   1 qual[*]
     2 encntr_id = f8
     2 person_id = f8
 )
 FREE RECORD pat_list
 RECORD pat_list(
   1 qual[*]
     2 person_id = vc
     2 full_name = vc
     2 gender_id = vc
     2 gender = vc
     2 dob = vc
     2 age = vc
     2 language = vc
     2 mrn = vc
     2 marital_status = vc
     2 absolute_dob = vc
     2 last_encntr_dt_tm = vc
     2 primary_care_physician = vc
     2 ph_home = vc
     2 ph_work = vc
     2 ph_cell = vc
     2 encntrs[*]
       3 encntr_id = vc
       3 person_id = vc
       3 bed_id = vc
       3 bed = vc
       3 room = vc
       3 registration_dt_tm = vc
       3 pre_registration_dt_tm = vc
       3 estimate_arrive_dt_tm = vc
       3 admit_dt_tm = vc
       3 discharged_dt_tm = vc
       3 reason_for_visit = vc
       3 med_service = vc
       3 fin = vc
       3 encntr_status = vc
       3 attending_physician = vc
       3 admitting_physician = vc
       3 referring_physician = vc
       3 primary_care_physician = vc
       3 facility_id = vc
       3 facility = vc
       3 encntr_type_id = vc
       3 encntr_type = vc
       3 nurse_unit_id = vc
       3 nurse_unit = vc
       3 patient_type = vc
       3 encntr_type_class_id = vc
       3 encntr_type_class_disp = vc
       3 encntr_type_class_mean = vc
 )
 DECLARE enc_type = vc WITH constant( $2)
 DECLARE cv_nu = f8 WITH constant( $3)
 DECLARE prsnl_id = f8 WITH constant( $4)
 DECLARE fname_input = vc WITH constant(cnvtupper(trim( $5)))
 DECLARE lname_input = vc WITH constant(cnvtupper(trim( $6)))
 DECLARE mrn_input = vc WITH constant(cnvtupper(trim( $7)))
 DECLARE fin_input = vc WITH constant(cnvtupper(trim( $8)))
 DECLARE from_birth_dt = vc WITH constant(trim( $9))
 DECLARE to_birth_dt = vc WITH constant(trim( $10))
 DECLARE f_sex_cd = f8 WITH constant( $11)
 DECLARE discharged_dt = vc WITH constant(trim( $12))
 DECLARE f_loc_fac_cd = f8 WITH constant( $13)
 DECLARE f_nu_cd = f8 WITH constant( $14)
 DECLARE cv_encnt_id = f8 WITH constant( $15)
 DECLARE active_status = vc WITH constant( $16)
 IF (enc_type="IP")
  SET where_enc_type_params = build(
"e.encntr_type_cd in (679668,679662,679658,679656,679659,2495726,309310,679683,679670,679657,679677,309308,309312,679653,67\
9672,679660,679654,679655,679664)\
")
 ELSEIF (enc_type="OP")
  SET where_enc_type_params = build(
"e.encntr_type_cd in (241212455,35303248,241211989,241212224,309309,43976921,35303251,54600279,335953107,679661,54600280,67\
9684,43976920,54600278,180235116,241211989) \
")
 ELSEIF (enc_type="BOTH")
  SET where_enc_type_params = default_where_params
 ELSE
  SET where_enc_type_params = default_where_params
 ENDIF
 IF (fname_input != "")
  SET where_search_fname_params = build(" p.name_first_key LIKE ","'",fname_input,"*'"," ")
 ELSE
  SET where_search_fname_params = default_where_params
 ENDIF
 IF (lname_input != "")
  SET where_search_lname_params = build(" p.name_last_key LIKE ","'",lname_input,"*'"," ")
 ELSE
  SET where_search_lname_params = default_where_params
 ENDIF
 IF (mrn_input != "")
  SET where_search_mrn_params = build(" pa.alias LIKE ","'",mrn_input,"*'"," ")
 ELSE
  SET where_search_mrn_params = default_where_params
 ENDIF
 IF (fin_input != "")
  SET where_search_fin_params = build(" ea.alias LIKE ","'",fin_input,"*'"," ")
 ELSE
  SET where_search_fin_params = default_where_params
 ENDIF
 IF (from_birth_dt != ""
  AND to_birth_dt != "")
  SET where_birth_dt_params = build(" p.birth_dt_tm between cnvtdatetime('",from_birth_dt,
   "') AND cnvtdatetime('",to_birth_dt,"') ")
 ELSE
  SET where_birth_dt_params = default_where_params
 ENDIF
 IF (f_sex_cd != 0)
  SET where_sex_cd_params = build("p.sex_cd = ",f_sex_cd)
 ELSE
  SET where_sex_cd_params = default_where_params
 ENDIF
 IF (discharged_dt != "")
  SET where_enc_disch_dt_params = build(" e.disch_dt_tm >= cnvtdatetime ","('",discharged_dt,"')"," "
   )
 ELSE
  SET where_enc_disch_dt_params = default_where_params
 ENDIF
 IF (f_loc_fac_cd != 0)
  SET where_loc_fac_cd_params = build("e.loc_facility_cd = ",f_loc_fac_cd)
 ELSE
  SET where_loc_fac_cd_params = default_where_params
 ENDIF
 IF (f_nu_cd != 0)
  SET where_loc_nu_cd_params = build("e.loc_nurse_unit_cd = ",f_nu_cd)
 ELSE
  SET where_loc_nu_cd_params = default_where_params
 ENDIF
 IF (active_status != "")
  SET where_active_status_params = build("e.ENCNTR_STATUS_CD IN ",active_status)
 ELSE
  SET where_active_status_params = default_where_params
 ENDIF
 IF (cv_nu != 0
  AND enc_type="IP")
  SELECT INTO "nl:"
   ed.encntr_id
   FROM encntr_domain ed,
    encounter e
   PLAN (ed
    WHERE ed.loc_nurse_unit_cd=cv_nu)
    JOIN (e
    WHERE e.active_ind=1
     AND e.encntr_id=ed.encntr_id
     AND e.disch_dt_tm = null)
   HEAD ed.encntr_id
    cnt = (cnt+ 1), stat = alterlist(ip_list->qual,cnt), ip_list->qual[cnt].encntr_id = ed.encntr_id,
    ip_list->qual[cnt].person_id = ed.person_id
   WITH nocounter, time = 30
  ;end select
 ELSEIF (cv_nu != 0
  AND enc_type="OP")
  SELECT INTO "nl:"
   e.encntr_id
   FROM encounter e
   PLAN (e
    WHERE e.loc_nurse_unit_cd=cv_nu
     AND e.active_ind=1
     AND e.disch_dt_tm = null)
   HEAD e.encntr_id
    cnt = (cnt+ 1), stat = alterlist(ip_list->qual,cnt), ip_list->qual[cnt].encntr_id = e.encntr_id,
    ip_list->qual[cnt].person_id = e.person_id
   WITH nocounter, time = 45
  ;end select
 ELSEIF (cv_encnt_id != 0)
  SELECT INTO "nl:"
   e.encntr_id
   FROM encounter e
   PLAN (e
    WHERE e.encntr_id=cv_encnt_id)
   HEAD e.encntr_id
    cnt = (cnt+ 1), stat = alterlist(ip_list->qual,cnt), ip_list->qual[cnt].encntr_id = e.encntr_id,
    ip_list->qual[cnt].person_id = e.person_id
   WITH nocounter, time = 10
  ;end select
 ENDIF
 IF (((cv_nu != 0) OR (cv_encnt_id != 0)) )
  SELECT INTO "NL:"
   pat_name = trim(replace(replace(replace(replace(replace(trim(p.name_full_formatted,3),"&","&amp;",
         0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), gender = trim(replace(
     replace(replace(replace(replace(trim(uar_get_code_display(p.sex_cd),3),"&","&amp;",0),"<","&lt;",
        0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), marital_status = uar_get_code_display(p
    .marital_type_cd),
   dob = format(p.birth_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), absolutedob = format(p.abs_birth_dt_tm,
    "MM/DD/YYYY HH:MM:SS;;D"), age = cnvtage(p.birth_dt_tm),
   bed = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(e.loc_bed_cd),3),"&",
         "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), room = trim(
    replace(replace(replace(replace(replace(trim(uar_get_code_display(e.loc_room_cd),3),"&","&amp;",0
         ),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), reg_dt = format(e
    .reg_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
   prereg_dt = format(e.pre_reg_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), estarrival_dt = format(e
    .est_arrive_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), admit_dt = format(e.inpatient_admit_dt_tm,
    "MM/DD/YYYY HH:MM:SS;;D"),
   disch_dt = format(e.disch_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), rov = trim(replace(replace(replace(
       replace(replace(trim(e.reason_for_visit,3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3), med_service = trim(replace(replace(replace(replace(replace(trim
         (uar_get_code_display(e.med_service_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3),
   language = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(p.language_cd),3
          ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), p
   .person_id, e.encntr_id,
   mrn = trim(cnvtalias(pa.alias,pa.alias_pool_cd),3), fin = trim(cnvtalias(ea.alias,ea.alias_pool_cd
     ),3), encntr_status = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(e
           .encntr_status_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3),
   attend_phys = trim(replace(replace(replace(replace(replace(trim(pm_get_encntr_prsnl("ATTENDDOC",e
           .encntr_id,sysdate),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3), pcp_phys = trim(replace(replace(replace(replace(replace(trim(pm_get_person_prsnl
          ("PCP",e.person_id,sysdate),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
     '"',"&quot;",0),3), last_enct_dt = format(p.last_encntr_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
   e.loc_facility_cd, facilityname = trim(replace(replace(replace(replace(replace(trim(
          uar_get_code_display(e.loc_facility_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3), nurseunit = trim(replace(replace(replace(replace(replace(trim(
          uar_get_code_display(e.loc_nurse_unit_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3),
   encountertypename = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(e
           .encntr_type_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3), patienttype =
   IF (((e.encntr_type_cd=679668) OR (((e.encntr_type_cd=679662) OR (((e.encntr_type_cd=679658) OR (
   ((e.encntr_type_cd=679656) OR (((e.encntr_type_cd=679659) OR (((e.encntr_type_cd=2495726) OR (((e
   .encntr_type_cd=309310) OR (((e.encntr_type_cd=679683) OR (((e.encntr_type_cd=679670) OR (((e
   .encntr_type_cd=679657) OR (((e.encntr_type_cd=679677) OR (((e.encntr_type_cd=309308) OR (((e
   .encntr_type_cd=309312) OR (((e.encntr_type_cd=679653) OR (((e.encntr_type_cd=679672) OR (((e
   .encntr_type_cd=679660) OR (((e.encntr_type_cd=679654) OR (((e.encntr_type_cd=679655) OR (e
   .encntr_type_cd=679664)) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ) "IP"
   ELSE "OP"
   ENDIF
   , e_encntr_type_class_cd = cnvtstring(e.encntr_type_class_cd),
   e_encntr_type_class_disp = uar_get_code_display(e.encntr_type_class_cd), e_encntr_type_class_mean
    = uar_get_code_meaning(e.encntr_type_class_cd)
   FROM (dummyt d1  WITH seq = value(size(ip_list->qual,5))),
    encounter e,
    person p,
    person_alias pa,
    encntr_alias ea
   PLAN (d1)
    JOIN (e
    WHERE (e.encntr_id=ip_list->qual[d1.seq].encntr_id))
    JOIN (p
    WHERE p.person_id=e.person_id)
    JOIN (pa
    WHERE pa.person_id=p.person_id
     AND pa.person_alias_type_cd=f_mrn_cd
     AND pa.beg_effective_dt_tm < sysdate
     AND pa.end_effective_dt_tm > sysdate
     AND pa.active_ind=1)
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(e.encntr_id)
     AND ea.encntr_alias_type_cd=outerjoin(f_fin_cd)
     AND ea.beg_effective_dt_tm < outerjoin(sysdate)
     AND ea.end_effective_dt_tm > outerjoin(sysdate)
     AND ea.active_ind=outerjoin(1))
   ORDER BY nurseunit, room, bed,
    p.name_last_key, p.name_first_key, e.person_id,
    e.encntr_id
   HEAD e.encntr_id
    cnt1 = (cnt1+ 1), stat = alterlist(pat_list->qual,cnt1), pat_list->qual[cnt1].person_id =
    cnvtstring(p.person_id),
    pat_list->qual[cnt1].full_name = pat_name, pat_list->qual[cnt1].gender_id = cnvtstring(p.sex_cd),
    pat_list->qual[cnt1].gender = gender,
    pat_list->qual[cnt1].dob = dob, pat_list->qual[cnt1].age = age, pat_list->qual[cnt1].language =
    language
    IF (2=textlen(trim(mrn,3)))
     pat_list->qual[cnt1].mrn = build("00000",mrn)
    ELSEIF (3=textlen(trim(mrn,3)))
     pat_list->qual[cnt1].mrn = build("0000",mrn)
    ELSEIF (4=textlen(trim(mrn,3)))
     pat_list->qual[cnt1].mrn = build("000",mrn)
    ELSEIF (5=textlen(trim(mrn,3)))
     pat_list->qual[cnt1].mrn = build("00",mrn)
    ELSEIF (6=textlen(trim(mrn,3)))
     pat_list->qual[cnt1].mrn = build("0",mrn)
    ELSE
     pat_list->qual[cnt1].mrn = mrn
    ENDIF
    pat_list->qual[cnt1].marital_status = marital_status, pat_list->qual[cnt1].absolute_dob =
    absolutedob, pat_list->qual[cnt1].last_encntr_dt_tm = last_enct_dt,
    pat_list->qual[cnt1].primary_care_physician = pcp_phys, stat = alterlist(pat_list->qual[cnt1].
     encntrs,1), pat_list->qual[cnt1].encntrs[cnt2].encntr_id = cnvtstring(e.encntr_id),
    pat_list->qual[cnt1].encntrs[cnt2].person_id = cnvtstring(e.person_id), pat_list->qual[cnt1].
    encntrs[1].bed_id = cnvtstring(e.loc_bed_cd), pat_list->qual[cnt1].encntrs[1].bed = bed,
    pat_list->qual[cnt1].encntrs[1].room = room, pat_list->qual[cnt1].encntrs[1].registration_dt_tm
     = reg_dt, pat_list->qual[cnt1].encntrs[1].pre_registration_dt_tm = prereg_dt,
    pat_list->qual[cnt1].encntrs[1].estimate_arrive_dt_tm = estarrival_dt, pat_list->qual[cnt1].
    encntrs[1].admit_dt_tm = admit_dt, pat_list->qual[cnt1].encntrs[1].discharged_dt_tm = disch_dt,
    pat_list->qual[cnt1].encntrs[1].reason_for_visit = rov, pat_list->qual[cnt1].encntrs[1].
    med_service = med_service, pat_list->qual[cnt1].encntrs[1].fin = fin,
    pat_list->qual[cnt1].encntrs[1].encntr_status = encntr_status, pat_list->qual[cnt1].encntrs[1].
    attending_physician = attend_phys, pat_list->qual[cnt1].encntrs[1].admitting_physician = "",
    pat_list->qual[cnt1].encntrs[1].referring_physician = "", pat_list->qual[cnt1].encntrs[1].
    primary_care_physician = pcp_phys, pat_list->qual[cnt1].encntrs[1].facility_id = cnvtstring(e
     .loc_facility_cd),
    pat_list->qual[cnt1].encntrs[1].facility = facilityname, pat_list->qual[cnt1].encntrs[1].
    encntr_type_id = cnvtstring(e.encntr_type_cd), pat_list->qual[cnt1].encntrs[1].encntr_type =
    encountertypename,
    pat_list->qual[cnt1].encntrs[1].nurse_unit_id = cnvtstring(e.loc_nurse_unit_cd), pat_list->qual[
    cnt1].encntrs[1].nurse_unit = nurseunit, pat_list->qual[cnt1].encntrs[1].patient_type =
    patienttype,
    pat_list->qual[cnt1].encntrs[1].encntr_type_class_id = e_encntr_type_class_cd, pat_list->qual[
    cnt1].encntrs[1].encntr_type_class_disp = e_encntr_type_class_disp, pat_list->qual[cnt1].encntrs[
    1].encntr_type_class_mean = e_encntr_type_class_mean
   WITH time = 60
  ;end select
 ELSEIF (cv_nu=0)
  SELECT INTO "NL:"
   pat_name = trim(replace(replace(replace(replace(replace(trim(p.name_full_formatted,3),"&","&amp;",
         0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), gender = trim(replace(
     replace(replace(replace(replace(trim(uar_get_code_display(p.sex_cd),3),"&","&amp;",0),"<","&lt;",
        0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), marital_status = uar_get_code_display(p
    .marital_type_cd),
   dob = format(p.birth_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), absolutedob = format(p.abs_birth_dt_tm,
    "MM/DD/YYYY HH:MM:SS;;D"), age = cnvtage(p.birth_dt_tm),
   bed = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(e.loc_bed_cd),3),"&",
         "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), room = trim(
    replace(replace(replace(replace(replace(trim(uar_get_code_display(e.loc_room_cd),3),"&","&amp;",0
         ),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), reg_dt = format(e
    .reg_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
   prereg_dt = format(e.pre_reg_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), estarrival_dt = format(e
    .est_arrive_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), admit_dt = format(e.inpatient_admit_dt_tm,
    "MM/DD/YYYY HH:MM:SS;;D"),
   disch_dt = format(e.disch_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), rov = trim(replace(replace(replace(
       replace(replace(trim(e.reason_for_visit,3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3), med_service = trim(replace(replace(replace(replace(replace(trim
         (uar_get_code_display(e.med_service_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3),
   language = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(p.language_cd),3
          ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), p
   .person_id, e.encntr_id,
   mrn = trim(cnvtalias(pa.alias,pa.alias_pool_cd),3), fin = trim(cnvtalias(ea.alias,ea.alias_pool_cd
     ),3), encntr_status = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(e
           .encntr_status_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3),
   attend_phys = trim(replace(replace(replace(replace(replace(trim(pm_get_encntr_prsnl("ATTENDDOC",e
           .encntr_id,sysdate),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3), pcp_phys = trim(replace(replace(replace(replace(replace(trim(pm_get_person_prsnl
          ("PCP",e.person_id,sysdate),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
     '"',"&quot;",0),3), last_enct_dt = format(p.last_encntr_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
   e.loc_facility_cd, facilityname = trim(replace(replace(replace(replace(replace(trim(
          uar_get_code_display(e.loc_facility_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3), nurseunit = trim(replace(replace(replace(replace(replace(trim(
          uar_get_code_display(e.loc_nurse_unit_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3),
   encountertypename = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(e
           .encntr_type_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3), patienttype =
   IF (((e.encntr_type_cd=679668) OR (((e.encntr_type_cd=679662) OR (((e.encntr_type_cd=679658) OR (
   ((e.encntr_type_cd=679656) OR (((e.encntr_type_cd=679659) OR (((e.encntr_type_cd=2495726) OR (((e
   .encntr_type_cd=309310) OR (((e.encntr_type_cd=679683) OR (((e.encntr_type_cd=679670) OR (((e
   .encntr_type_cd=679657) OR (((e.encntr_type_cd=679677) OR (((e.encntr_type_cd=309308) OR (((e
   .encntr_type_cd=309312) OR (((e.encntr_type_cd=679653) OR (((e.encntr_type_cd=679672) OR (((e
   .encntr_type_cd=679660) OR (((e.encntr_type_cd=679654) OR (((e.encntr_type_cd=679655) OR (e
   .encntr_type_cd=679664)) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ) "IP"
   ELSE "OP"
   ENDIF
   , e_encntr_type_class_cd = cnvtstring(e.encntr_type_class_cd),
   e_encntr_type_class_disp = uar_get_code_display(e.encntr_type_class_cd), e_encntr_type_class_mean
    = uar_get_code_meaning(e.encntr_type_class_cd)
   FROM encounter e,
    person p,
    person_alias pa,
    encntr_alias ea,
    phone ph
   PLAN (e
    WHERE e.active_ind=1
     AND e.active_status_cd=188
     AND parser(where_loc_fac_cd_params)
     AND parser(where_loc_nu_cd_params)
     AND parser(where_enc_disch_dt_params)
     AND parser(where_active_status_params))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND parser(where_search_fname_params)
     AND parser(where_search_lname_params)
     AND parser(where_birth_dt_params)
     AND parser(where_sex_cd_params))
    JOIN (pa
    WHERE pa.person_id=p.person_id
     AND pa.person_alias_type_cd=f_mrn_cd
     AND pa.beg_effective_dt_tm < sysdate
     AND pa.end_effective_dt_tm > sysdate
     AND pa.active_ind=1
     AND parser(where_search_mrn_params))
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(e.encntr_id)
     AND ea.encntr_alias_type_cd=outerjoin(f_fin_cd)
     AND ea.beg_effective_dt_tm < outerjoin(sysdate)
     AND ea.end_effective_dt_tm > outerjoin(sysdate)
     AND ea.active_ind=outerjoin(1)
     AND parser(where_search_fin_params))
    JOIN (ph
    WHERE ph.parent_entity_id=outerjoin(e.person_id)
     AND ph.parent_entity_name=outerjoin("PERSON")
     AND ph.phone_num != outerjoin(" ")
     AND ph.phone_num_key != outerjoin("0000000000")
     AND ph.active_ind=outerjoin(1))
   ORDER BY p.name_last_key, p.name_first_key, e.person_id,
    e.encntr_id
   HEAD e.person_id
    cnt1 = (cnt1+ 1), stat = alterlist(pat_list->qual,cnt1), pat_list->qual[cnt1].person_id =
    cnvtstring(e.person_id),
    pat_list->qual[cnt1].full_name = pat_name, pat_list->qual[cnt1].gender_id = cnvtstring(p.sex_cd),
    pat_list->qual[cnt1].gender = gender,
    pat_list->qual[cnt1].dob = dob, pat_list->qual[cnt1].age = age, pat_list->qual[cnt1].language =
    language
    IF (2=textlen(trim(mrn,3)))
     pat_list->qual[cnt1].mrn = build("00000",mrn)
    ELSEIF (3=textlen(trim(mrn,3)))
     pat_list->qual[cnt1].mrn = build("0000",mrn)
    ELSEIF (4=textlen(trim(mrn,3)))
     pat_list->qual[cnt1].mrn = build("000",mrn)
    ELSEIF (5=textlen(trim(mrn,3)))
     pat_list->qual[cnt1].mrn = build("00",mrn)
    ELSEIF (6=textlen(trim(mrn,3)))
     pat_list->qual[cnt1].mrn = build("0",mrn)
    ELSE
     pat_list->qual[cnt1].mrn = mrn
    ENDIF
    pat_list->qual[cnt1].marital_status = marital_status, pat_list->qual[cnt1].absolute_dob =
    absolutedob, pat_list->qual[cnt1].last_encntr_dt_tm = last_enct_dt,
    pat_list->qual[cnt1].primary_care_physician = pcp_phys, ph_home = fillstring(200," "), ph_work =
    fillstring(200," "),
    ph_cell = fillstring(200," ")
   HEAD ph.phone_type_cd
    IF (ph.phone_type_cd=f_phone_type_h_cd)
     pat_list->qual[cnt1].ph_home = trim(ph.phone_num,3)
    ELSEIF (ph.phone_type_cd=f_phone_type_b_cd)
     pat_list->qual[cnt1].ph_work = trim(ph.phone_num,3)
    ELSEIF (ph.phone_type_cd=f_phone_type_m_cd)
     pat_list->qual[cnt1].ph_cell = trim(ph.phone_num,3)
    ENDIF
    cnt2 = 0
   HEAD e.encntr_id
    cnt2 = (cnt2+ 1), stat = alterlist(pat_list->qual[cnt1].encntrs,cnt2), pat_list->qual[cnt1].
    encntrs[cnt2].encntr_id = cnvtstring(e.encntr_id),
    pat_list->qual[cnt1].encntrs[cnt2].person_id = cnvtstring(e.person_id), pat_list->qual[cnt1].
    encntrs[cnt2].bed_id = cnvtstring(e.loc_bed_cd), pat_list->qual[cnt1].encntrs[cnt2].bed = bed,
    pat_list->qual[cnt1].encntrs[cnt2].room = room, pat_list->qual[cnt1].encntrs[cnt2].
    registration_dt_tm = reg_dt, pat_list->qual[cnt1].encntrs[cnt2].pre_registration_dt_tm =
    prereg_dt,
    pat_list->qual[cnt1].encntrs[cnt2].estimate_arrive_dt_tm = estarrival_dt, pat_list->qual[cnt1].
    encntrs[cnt2].admit_dt_tm = admit_dt, pat_list->qual[cnt1].encntrs[cnt2].discharged_dt_tm =
    disch_dt,
    pat_list->qual[cnt1].encntrs[cnt2].reason_for_visit = rov, pat_list->qual[cnt1].encntrs[cnt2].
    med_service = med_service, pat_list->qual[cnt1].encntrs[cnt2].fin = fin,
    pat_list->qual[cnt1].encntrs[cnt2].encntr_status = encntr_status, pat_list->qual[cnt1].encntrs[
    cnt2].attending_physician = attend_phys, pat_list->qual[cnt1].encntrs[cnt2].admitting_physician
     = "",
    pat_list->qual[cnt1].encntrs[cnt2].referring_physician = "", pat_list->qual[cnt1].encntrs[cnt2].
    primary_care_physician = pcp_phys, pat_list->qual[cnt1].encntrs[cnt2].facility_id = cnvtstring(e
     .loc_facility_cd),
    pat_list->qual[cnt1].encntrs[cnt2].facility = facilityname, pat_list->qual[cnt1].encntrs[cnt2].
    encntr_type_id = cnvtstring(e.encntr_type_cd), pat_list->qual[cnt1].encntrs[cnt2].encntr_type =
    encountertypename,
    pat_list->qual[cnt1].encntrs[cnt2].nurse_unit_id = cnvtstring(e.loc_nurse_unit_cd), pat_list->
    qual[cnt1].encntrs[cnt2].nurse_unit = nurseunit, pat_list->qual[cnt1].encntrs[cnt2].patient_type
     = patienttype,
    pat_list->qual[cnt1].encntrs[cnt2].encntr_type_class_id = e_encntr_type_class_cd, pat_list->qual[
    cnt1].encntrs[cnt2].encntr_type_class_disp = e_encntr_type_class_disp, pat_list->qual[cnt1].
    encntrs[cnt2].encntr_type_class_mean = e_encntr_type_class_mean
   WITH nocounter, time = 10
  ;end select
 ENDIF
 CALL echorecord(pat_list)
 CALL echojson(pat_list, $1)
 FREE RECORD pat_list
 FREE RECORD ip_list
END GO

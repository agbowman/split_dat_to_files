CREATE PROGRAM bhs_prax_allpatient_ls
 DECLARE f_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE f_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE f_pcp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",331,"PCP"))
 DECLARE f_enc_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",261,"ACTIVE"))
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
 DECLARE cnt = i4 WITH noconstant(0)
 FREE RECORD ip_list
 RECORD ip_list(
   1 qual[*]
     2 encntr_id = f8
     2 person_id = f8
     2 epr = c3
     2 ppr = c3
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
 IF (enc_type="IP")
  SET where_enc_type_params = build("e.encntr_type_class_cd in ( 391, 392)")
 ELSEIF (enc_type="OP")
  SET where_enc_type_params = build("e.encntr_type_class_cd in (393, 395, 397) ")
 ELSEIF (enc_type="BOTH")
  SET where_enc_type_params = build("e.encntr_type_class_cd in (391, 392, 393, 395, 397, 389)")
 ELSEIF (enc_type="EMER")
  SET where_enc_type_params = build("e.encntr_type_class_cd in (389)")
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
 IF (cv_nu != 0)
  SELECT INTO "nl:"
   ed.encntr_id
   FROM encntr_domain ed,
    encounter e
   PLAN (ed
    WHERE ed.loc_nurse_unit_cd=cv_nu)
    JOIN (e
    WHERE parser(where_enc_type_params)
     AND e.encntr_id=ed.encntr_id
     AND e.disch_dt_tm = null)
   HEAD ed.encntr_id
    cnt = (cnt+ 1), stat = alterlist(ip_list->qual,cnt), ip_list->qual[cnt].encntr_id = ed.encntr_id,
    ip_list->qual[cnt].person_id = ed.person_id, ip_list->qual[cnt].epr = "NO", ip_list->qual[cnt].
    ppr = "NO"
   WITH nocounter, time = 30
  ;end select
 ELSEIF (cv_encnt_id != 0)
  SELECT INTO "nl:"
   e.encntr_id
   FROM encounter e
   PLAN (e
    WHERE e.encntr_id=cv_encnt_id)
   HEAD e.encntr_id
    cnt = (cnt+ 1), stat = alterlist(ip_list->qual,cnt), ip_list->qual[cnt].encntr_id = e.encntr_id,
    ip_list->qual[cnt].person_id = e.person_id, ip_list->qual[cnt].epr = "NO", ip_list->qual[cnt].ppr
     = "NO"
   WITH nocounter, time = 10
  ;end select
 ENDIF
 IF (((cv_nu != 0) OR (cv_encnt_id != 0)) )
  SELECT INTO "nl:"
   r_ep.encntr_id
   FROM (dummyt d1  WITH seq = value(size(ip_list->qual,5))),
    encntr_prsnl_reltn r_ep
   PLAN (d1)
    JOIN (r_ep
    WHERE (r_ep.encntr_id=ip_list->qual[d1.seq].encntr_id)
     AND r_ep.beg_effective_dt_tm < sysdate
     AND r_ep.end_effective_dt_tm > sysdate
     AND r_ep.active_ind=1
     AND r_ep.prsnl_person_id=prsnl_id)
   DETAIL
    ip_list->qual[d1.seq].epr = "YES"
   WITH nocounter, time = 30
  ;end select
  SELECT INTO "nl:"
   r_pp.person_id
   FROM (dummyt d1  WITH seq = value(size(ip_list->qual,5))),
    person_prsnl_reltn r_pp
   PLAN (d1)
    JOIN (r_pp
    WHERE (r_pp.person_id=ip_list->qual[d1.seq].person_id)
     AND r_pp.beg_effective_dt_tm < sysdate
     AND r_pp.end_effective_dt_tm > sysdate
     AND r_pp.active_ind=1
     AND r_pp.prsnl_person_id=prsnl_id)
   DETAIL
    ip_list->qual[d1.seq].ppr = "YES"
   WITH nocounter, time = 30
  ;end select
  SELECT INTO  $1
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
     "&quot;",0),3), admit_phys = trim(replace(replace(replace(replace(replace(trim(
          pm_get_encntr_prsnl("ADMITDOC",e.encntr_id,sysdate),3),"&","&amp;",0),"<","&lt;",0),">",
       "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), refer_phys = trim(replace(replace(replace(
       replace(replace(trim(pm_get_encntr_prsnl("REFERDOC",e.encntr_id,sysdate),3),"&","&amp;",0),"<",
        "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   pcp_phys = trim(replace(replace(replace(replace(replace(trim(pm_get_person_prsnl("PCP",e.person_id,
           sysdate),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   epr = ip_list->qual[d1.seq].epr, ppr = ip_list->qual[d1.seq].ppr,
   last_enct_dt = format(p.last_encntr_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), e.loc_facility_cd,
   facilityname = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(e
           .loc_facility_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3),
   nurseunit = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(e
           .loc_nurse_unit_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3), encountertypename = trim(replace(replace(replace(replace(replace(trim(
          uar_get_code_display(e.encntr_type_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3), patienttype =
   IF (e.encntr_type_class_cd=389) "EMER"
   ELSEIF (((e.encntr_type_class_cd=391) OR (e.encntr_type_class_cd=392)) ) "IP"
   ELSEIF (((e.encntr_type_class_cd=393) OR (((e.encntr_type_class_cd=395) OR (e.encntr_type_class_cd
   =397)) )) ) "OP"
   ELSE "IP"
   ENDIF
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
     AND pa.active_ind=1
     AND parser(where_search_mrn_params))
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd=f_fin_cd
     AND ea.beg_effective_dt_tm < sysdate
     AND ea.end_effective_dt_tm > sysdate
     AND ea.active_ind=1
     AND parser(where_search_fin_params))
   ORDER BY nurseunit, room, bed,
    p.name_last_key, p.name_first_key, e.person_id,
    e.encntr_id
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>"
   HEAD e.encntr_id
    col + 1, "<Patient>", row + 1,
    p_patid = build("<PatientId>",cnvtint(e.person_id),"</PatientId>"), col + 1, p_patid,
    row + 1, pname = build("<FullName>",pat_name,"</FullName>"), col + 1,
    pname, row + 1, pgender = build("<Gender>",gender,"</Gender>"),
    col + 1, pgender, row + 1,
    pdob = build("<DOB>",dob,"</DOB>"), col + 1, pdob,
    row + 1, p_age = build("<Age>",age,"</Age>"), col + 1,
    p_age, row + 1, p_lan = build("<Language>",language,"</Language>"),
    col + 1, p_lan, row + 1
    IF (2=textlen(trim(mrn,3)))
     p_mrn = build("<Mrn>","00000",mrn,"</Mrn>")
    ELSEIF (3=textlen(trim(mrn,3)))
     p_mrn = build("<Mrn>","0000",mrn,"</Mrn>")
    ELSEIF (4=textlen(trim(mrn,3)))
     p_mrn = build("<Mrn>","000",mrn,"</Mrn>")
    ELSEIF (5=textlen(trim(mrn,3)))
     p_mrn = build("<Mrn>","00",mrn,"</Mrn>")
    ELSEIF (6=textlen(trim(mrn,3)))
     p_mrn = build("<Mrn>","0",mrn,"</Mrn>")
    ELSE
     p_mrn = build("<Mrn>",mrn,"</Mrn>")
    ENDIF
    col + 1, p_mrn, row + 1,
    p_marital = build("<MaritalStatus>",marital_status,"</MaritalStatus>"), col + 1, p_marital,
    row + 1, p_absdob = build("<AbsoluteBirthDateTime>",absolutedob,"</AbsoluteBirthDateTime>"), col
     + 1,
    p_absdob, row + 1, p_lstencdt = build("<LastEncounterDateTime>",last_enct_dt,
     "</LastEncounterDateTime>"),
    col + 1, p_lstencdt, row + 1,
    p_pcp = build("<PrimaryCarePhysician>",pcp_phys,"</PrimaryCarePhysician>"), col + 1, p_pcp,
    row + 1, col + 1, "<Encounters>",
    row + 1, col + 1, "<Encounter>",
    row + 1, p_encid = build("<EncounterId>",cnvtint(e.encntr_id),"</EncounterId>"), col + 1,
    p_encid, row + 1, col + 1,
    p_patid, row + 1, p_bed = build("<Bed>",bed,"</Bed>"),
    col + 1, p_bed, row + 1,
    p_bedid = build("<BedId>",cnvtint(e.loc_bed_cd),"</BedId>"), col + 1, p_bedid,
    row + 1, p_room = build("<Room>",room,"</Room>"), col + 1,
    p_room, row + 1, p_reg_dt = build("<RegistrationDateTime>",reg_dt,"</RegistrationDateTime>"),
    col + 1, p_reg_dt, row + 1,
    p_prereg_dt = build("<PreRegistrationDateTime>",prereg_dt,"</PreRegistrationDateTime>"), col + 1,
    p_prereg_dt,
    row + 1, p_estarr_dt = build("<EstimateArriveDateTime>",estarrival_dt,"</EstimateArriveDateTime>"
     ), col + 1,
    p_estarr_dt, row + 1, p_admit_dt = build("<AdmitDateTime>",admit_dt,"</AdmitDateTime>"),
    col + 1, p_admit_dt, row + 1,
    p_disch_dt = build("<DischDateTime>",disch_dt,"</DischDateTime>"), col + 1, p_disch_dt,
    row + 1, p_rov = build("<ReasonForVisit>",rov,"</ReasonForVisit>"), col + 1,
    p_rov, row + 1, p_ms = build("<MedService>",med_service,"</MedService>"),
    col + 1, p_ms, row + 1,
    p_fin = build("<Fin>",fin,"</Fin>"), col + 1, p_fin,
    row + 1, p_es = build("<EncounterStatus>",encntr_status,"</EncounterStatus>"), col + 1,
    p_es, row + 1, p_attend = build("<AttendingPhysician>",attend_phys,"</AttendingPhysician>"),
    col + 1, p_attend, row + 1,
    p_admit = build("<AdmittingPhysician>",admit_phys,"</AdmittingPhysician>"), col + 1, p_admit,
    row + 1, p_refer = build("<ReferringPhysician>",refer_phys,"</ReferringPhysician>"), col + 1,
    p_refer, row + 1, p_pcp = build("<PrimaryCarePhysician>",pcp_phys,"</PrimaryCarePhysician>"),
    col + 1, p_pcp, row + 1,
    p_epr = build("<EncounterLevelRelationship>",trim(epr),"</EncounterLevelRelationship>"), col + 1,
    p_epr,
    row + 1, p_ppr = build("<PersonLevelRelationship>",trim(ppr),"</PersonLevelRelationship>"), col
     + 1,
    p_ppr, row + 1, p_fac = build("<FacilityId>",cnvtint(e.loc_facility_cd),"</FacilityId>"),
    col + 1, p_fac, row + 1,
    p_fac_n = build("<FacilityName>",facilityname,"</FacilityName>"), col + 1, p_fac_n,
    row + 1, p_enctype = build("<EncounterTypeId>",cnvtint(e.encntr_type_cd),"</EncounterTypeId>"),
    col + 1,
    p_enctype, row + 1, p_enctype_n = build("<EncounterTypeString>",encountertypename,
     "</EncounterTypeString>"),
    col + 1, p_enctype_n, row + 1,
    p_nurseunit = build("<NurseUnit>",nurseunit,"</NurseUnit>"), col + 1, p_nurseunit,
    row + 1, p_nurseunitid = build("<NurseUnitId>",cnvtint(e.loc_nurse_unit_cd),"</NurseUnitId>"),
    col + 1,
    p_nurseunitid, row + 1, p_patienttype = build("<PatientType>",patienttype,"</PatientType>"),
    col + 1, p_patienttype, row + 1,
    col + 1, "</Encounter>", row + 1,
    col + 1, "</Encounters>", row + 1,
    col + 1, "</Patient>", row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH nocounter, nullreport, formfeed = none,
    maxcol = 1000, format = variable, maxrow = 0,
    time = 60
  ;end select
 ELSEIF (cv_nu=0)
  SELECT INTO  $1
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
     "&quot;",0),3), admit_phys = trim(replace(replace(replace(replace(replace(trim(
          pm_get_encntr_prsnl("ADMITDOC",e.encntr_id,sysdate),3),"&","&amp;",0),"<","&lt;",0),">",
       "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), refer_phys = trim(replace(replace(replace(
       replace(replace(trim(pm_get_encntr_prsnl("REFERDOC",e.encntr_id,sysdate),3),"&","&amp;",0),"<",
        "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   pcp_phys = trim(replace(replace(replace(replace(replace(trim(pm_get_person_prsnl("PCP",e.person_id,
           sysdate),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   epr =
   IF (r_ep.encntr_id != 0) "YES"
   ELSE "NO"
   ENDIF
   , ppr =
   IF (r_pp.person_id != 0) "YES"
   ELSE "NO"
   ENDIF
   ,
   last_enct_dt = format(p.last_encntr_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), e.loc_facility_cd,
   facilityname = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(e
           .loc_facility_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3),
   nurseunit = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(e
           .loc_nurse_unit_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3), encountertypename = trim(replace(replace(replace(replace(replace(trim(
          uar_get_code_display(e.encntr_type_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3), patienttype =
   IF (e.encntr_type_class_cd=389) "EMER"
   ELSEIF (((e.encntr_type_class_cd=391) OR (e.encntr_type_class_cd=392)) ) "IP"
   ELSEIF (((e.encntr_type_class_cd=393) OR (((e.encntr_type_class_cd=395) OR (e.encntr_type_class_cd
   =397)) )) ) "OP"
   ELSE "IP"
   ENDIF
   ,
   ph_phone_type =
   IF (ph.phone_type_cd=170.00) "H"
   ELSEIF (ph.phone_type_cd=163.00) "B"
   ELSEIF (ph.phone_type_cd=158598878.00) "C"
   ELSE "O"
   ENDIF
   FROM encounter e,
    person p,
    person_alias pa,
    encntr_alias ea,
    encntr_prsnl_reltn r_ep,
    person_prsnl_reltn r_pp,
    phone ph
   PLAN (e
    WHERE e.active_ind=1
     AND e.active_status_cd=188
     AND parser(where_loc_fac_cd_params)
     AND parser(where_loc_nu_cd_params)
     AND parser(where_enc_disch_dt_params))
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
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd=f_fin_cd
     AND ea.beg_effective_dt_tm < sysdate
     AND ea.end_effective_dt_tm > sysdate
     AND ea.active_ind=1
     AND parser(where_search_fin_params))
    JOIN (r_ep
    WHERE r_ep.encntr_id=outerjoin(e.encntr_id)
     AND r_ep.beg_effective_dt_tm < outerjoin(sysdate)
     AND r_ep.end_effective_dt_tm > outerjoin(sysdate)
     AND r_ep.active_ind=outerjoin(1)
     AND r_ep.prsnl_person_id=outerjoin(prsnl_id))
    JOIN (r_pp
    WHERE r_pp.person_id=outerjoin(e.person_id)
     AND r_pp.beg_effective_dt_tm < outerjoin(sysdate)
     AND r_pp.end_effective_dt_tm > outerjoin(sysdate)
     AND r_pp.active_ind=outerjoin(1)
     AND r_pp.prsnl_person_id=outerjoin(prsnl_id))
    JOIN (ph
    WHERE ph.parent_entity_id=outerjoin(e.person_id)
     AND ph.parent_entity_name=outerjoin("PERSON")
     AND ph.phone_num != outerjoin(" ")
     AND ph.phone_num_key != outerjoin("0000000000")
     AND ph.active_ind=outerjoin(1))
   ORDER BY p.name_last_key, p.name_first_key, e.person_id,
    e.encntr_id
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>"
   HEAD e.person_id
    col + 1, "<Patient>", row + 1,
    p_patid = build("<PatientId>",cnvtint(e.person_id),"</PatientId>"), col + 1, p_patid,
    row + 1, pname = build("<FullName>",pat_name,"</FullName>"), col + 1,
    pname, row + 1, pgender = build("<Gender>",gender,"</Gender>"),
    col + 1, pgender, row + 1,
    pdob = build("<DOB>",dob,"</DOB>"), col + 1, pdob,
    row + 1, p_age = build("<Age>",age,"</Age>"), col + 1,
    p_age, row + 1, p_lan = build("<Language>",language,"</Language>"),
    col + 1, p_lan, row + 1
    IF (2=textlen(trim(mrn,3)))
     p_mrn = build("<Mrn>","00000",mrn,"</Mrn>")
    ELSEIF (3=textlen(trim(mrn,3)))
     p_mrn = build("<Mrn>","0000",mrn,"</Mrn>")
    ELSEIF (4=textlen(trim(mrn,3)))
     p_mrn = build("<Mrn>","000",mrn,"</Mrn>")
    ELSEIF (5=textlen(trim(mrn,3)))
     p_mrn = build("<Mrn>","00",mrn,"</Mrn>")
    ELSEIF (6=textlen(trim(mrn,3)))
     p_mrn = build("<Mrn>","0",mrn,"</Mrn>")
    ELSE
     p_mrn = build("<Mrn>",mrn,"</Mrn>")
    ENDIF
    col + 1, p_mrn, row + 1,
    p_marital = build("<MaritalStatus>",marital_status,"</MaritalStatus>"), col + 1, p_marital,
    row + 1, p_absdob = build("<AbsoluteBirthDateTime>",absolutedob,"</AbsoluteBirthDateTime>"), col
     + 1,
    p_absdob, row + 1, p_lstencdt = build("<LastEncounterDateTime>",last_enct_dt,
     "</LastEncounterDateTime>"),
    col + 1, p_lstencdt, row + 1,
    p_pcp = build("<PrimaryCarePhysician>",pcp_phys,"</PrimaryCarePhysician>"), col + 1, p_pcp,
    row + 1, col + 1, "<Encounters>",
    row + 1
   HEAD e.encntr_id
    col + 1, "<Encounter>", row + 1,
    p_encid = build("<EncounterId>",cnvtint(e.encntr_id),"</EncounterId>"), col + 1, p_encid,
    row + 1, col + 1, p_patid,
    row + 1, p_bed = build("<Bed>",bed,"</Bed>"), col + 1,
    p_bed, row + 1, p_bedid = build("<BedId>",cnvtint(e.loc_bed_cd),"</BedId>"),
    col + 1, p_bedid, row + 1,
    p_room = build("<Room>",room,"</Room>"), col + 1, p_room,
    row + 1, p_reg_dt = build("<RegistrationDateTime>",reg_dt,"</RegistrationDateTime>"), col + 1,
    p_reg_dt, row + 1, p_prereg_dt = build("<PreRegistrationDateTime>",prereg_dt,
     "</PreRegistrationDateTime>"),
    col + 1, p_prereg_dt, row + 1,
    p_estarr_dt = build("<EstimateArriveDateTime>",estarrival_dt,"</EstimateArriveDateTime>"), col +
    1, p_estarr_dt,
    row + 1, p_admit_dt = build("<AdmitDateTime>",admit_dt,"</AdmitDateTime>"), col + 1,
    p_admit_dt, row + 1, p_disch_dt = build("<DischDateTime>",disch_dt,"</DischDateTime>"),
    col + 1, p_disch_dt, row + 1,
    p_rov = build("<ReasonForVisit>",rov,"</ReasonForVisit>"), col + 1, p_rov,
    row + 1, p_ms = build("<MedService>",med_service,"</MedService>"), col + 1,
    p_ms, row + 1, p_fin = build("<Fin>",fin,"</Fin>"),
    col + 1, p_fin, row + 1,
    p_es = build("<EncounterStatus>",encntr_status,"</EncounterStatus>"), col + 1, p_es,
    row + 1, p_attend = build("<AttendingPhysician>",attend_phys,"</AttendingPhysician>"), col + 1,
    p_attend, row + 1, p_admit = build("<AdmittingPhysician>",admit_phys,"</AdmittingPhysician>"),
    col + 1, p_admit, row + 1,
    p_refer = build("<ReferringPhysician>",refer_phys,"</ReferringPhysician>"), col + 1, p_refer,
    row + 1, p_pcp = build("<PrimaryCarePhysician>",pcp_phys,"</PrimaryCarePhysician>"), col + 1,
    p_pcp, row + 1, p_epr = build("<EncounterLevelRelationship>",epr,"</EncounterLevelRelationship>"),
    col + 1, p_epr, row + 1,
    p_ppr = build("<PersonLevelRelationship>",ppr,"</PersonLevelRelationship>"), col + 1, p_ppr,
    row + 1, p_fac = build("<FacilityId>",cnvtint(e.loc_facility_cd),"</FacilityId>"), col + 1,
    p_fac, row + 1, p_fac_n = build("<FacilityName>",facilityname,"</FacilityName>"),
    col + 1, p_fac_n, row + 1,
    p_enctype = build("<EncounterTypeId>",cnvtint(e.encntr_type_cd),"</EncounterTypeId>"), col + 1,
    p_enctype,
    row + 1, p_enctype_n = build("<EncounterTypeString>",encountertypename,"</EncounterTypeString>"),
    col + 1,
    p_enctype_n, row + 1, p_nurseunit = build("<NurseUnit>",nurseunit,"</NurseUnit>"),
    col + 1, p_nurseunit, row + 1,
    p_nurseunitid = build("<NurseUnitId>",cnvtint(e.loc_nurse_unit_cd),"</NurseUnitId>"), col + 1,
    p_nurseunitid,
    row + 1, p_patienttype = build("<PatientType>",patienttype,"</PatientType>"), col + 1,
    p_patienttype, row + 1, ph_home = fillstring(200," "),
    ph_work = fillstring(200," "), ph_cell = fillstring(200," ")
   HEAD ph.phone_type_cd
    IF (ph.phone_type_cd=f_phone_type_h_cd)
     ph_home = trim(ph.phone_num,3)
    ELSEIF (ph.phone_type_cd=f_phone_type_b_cd)
     ph_work = trim(ph.phone_num,3)
    ELSEIF (ph.phone_type_cd=f_phone_type_m_cd)
     ph_cell = trim(ph.phone_num,3)
    ENDIF
   FOOT  e.encntr_id
    col + 1, "</Encounter>", row + 1
   FOOT  e.person_id
    col + 1, "</Encounters>", row + 1,
    vh1 = build("<HomePhoneNumber>",ph_home,"</HomePhoneNumber>"), col + 1, vh1,
    row + 1, vw1 = build("<WorkPhoneNumber>",ph_work,"</WorkPhoneNumber>"), col + 1,
    vw1, row + 1, vc1 = build("<CellPhoneNumber>",ph_cell,"</CellPhoneNumber>"),
    col + 1, vc1, row + 1,
    col + 1, "</Patient>", row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH nocounter, nullreport, formfeed = none,
    maxcol = 1000, format = variable, maxrow = 0,
    time = 20
  ;end select
 ENDIF
 FREE RECORD ip_list
END GO

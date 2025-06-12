CREATE PROGRAM al_bhs_rpt_bri_export:dba
 DECLARE mf_beg_dt_tm = f8 WITH protect, constant(cnvtdatetime((curdate - 10),000000))
 DECLARE mf_end_dt_tm = f8 WITH protect, constant(cnvtdatetime((curdate - 3),235959))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_addr_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE mf_addr_bus_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"BUSINESS"))
 DECLARE mf_phone_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE mf_phone_bus_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 DECLARE mf_ssn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_org_employer_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",338,"EMPLOYER"))
 DECLARE mf_def_guar_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",351,"DEFGUAR"))
 DECLARE mf_adtegate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",73,"ADTEGATE"))
 DECLARE mf_subscriber_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",353,"SUBSCRIBER"))
 DECLARE ms_cr_str = vc WITH protect, constant(char(13))
 DECLARE mf_briekg_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BRIEKGTECHONLY"))
 DECLARE mf_briholter_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "BRIHOLTERTECHONLY"))
 DECLARE mf_tcchest1view_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "TCCHEST1VIEW"))
 DECLARE mf_tcchest2view_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "TCCHEST2VIEW"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED"))
 DECLARE mf_exam_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14192,
   "COMPLETED"))
 DECLARE mf_baystateradimaging_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,
   "BAYSTATERADIMAGING"))
 DECLARE ms_filename = vc WITH protect, constant(concat("al_bridemo","_",format(cnvtdatetime((curdate
      - 1),curtime3),"YYMMDD;;d"),".csv"))
 DECLARE mf_bri_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ml_ins_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_info_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ms_line = vc WITH protect, noconstant("")
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 CALL echo(format(mf_beg_dt_tm,";;q"))
 CALL echo(format(mf_end_dt_tm,";;q"))
 FREE RECORD pinfo
 RECORD pinfo(
   1 cnt = i4
   1 qual[*]
     2 f_person_id = f8
     2 s_site_code = vc
     2 s_last_name = vc
     2 s_first_name = vc
     2 s_gender = vc
     2 s_addr1 = vc
     2 s_addr2 = vc
     2 s_city = vc
     2 s_state = vc
     2 s_zip = vc
     2 s_home_phone = vc
     2 s_ssn = vc
     2 s_dob = vc
     2 s_employer = vc
     2 s_accession_nbr = vc
     2 s_cmrn = vc
     2 s_guar_first_name = vc
     2 s_guar_last_name = vc
     2 s_guar_relation = vc
     2 s_guar_addr1 = vc
     2 s_guar_city = vc
     2 s_guar_state = vc
     2 s_guar_zip = vc
     2 s_guar_home_phone = vc
     2 s_guar_emp_name = vc
     2 s_guar_emp_address1 = vc
     2 s_guar_emp_address2 = vc
     2 s_guar_emp_city = vc
     2 s_guar_emp_state = vc
     2 s_guar_emp_zip = vc
     2 s_guar_emp_phone = vc
     2 s_accident_dt = vc
     2 s_accident_loc = vc
     2 s_carrier_code_1 = vc
     2 s_policy_id_1 = vc
     2 s_group_nbr_1 = vc
     2 s_carrier_desc_1 = vc
     2 s_carrier_code_2 = vc
     2 s_policy_id_2 = vc
     2 s_group_nbr_2 = vc
     2 s_carrier_desc_2 = vc
     2 s_carrier_code_3 = vc
     2 s_policy_id_3 = vc
     2 s_group_nbr_3 = vc
     2 s_carrier_desc_3 = vc
     2 s_sub1name = vc
     2 s_sub1relation = vc
     2 s_sub1dob = vc
     2 s_sub1gender = vc
     2 s_sub1addr1 = vc
     2 s_sub1city = vc
     2 s_sub1state = vc
     2 s_sub1zip = vc
     2 s_sub1phone = vc
     2 s_sub2name = vc
     2 s_sub2relation = vc
     2 s_sub2dob = vc
     2 s_sub2gender = vc
     2 s_sub2addr1 = vc
     2 s_sub2addr2 = vc
     2 s_sub2city = vc
     2 s_sub2state = vc
     2 s_sub2zip = vc
     2 s_sub2phone = vc
     2 s_sub3name = vc
     2 s_sub3relation = vc
     2 s_sub3dob = vc
     2 s_sub3gender = vc
     2 s_sub3addr1 = vc
     2 s_sub3addr2 = vc
     2 s_sub3city = vc
     2 s_sub3state = vc
     2 s_sub3zip = vc
     2 s_sub3phone = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.cdf_meaning="FACILITY"
   AND cv.display_key="BRI"
   AND cv.active_ind=1
  DETAIL
   mf_bri_cd = cv.code_value
  WITH nocounter
 ;end select
 CALL echo(mf_bri_cd)
 SELECT INTO "nl:"
  FROM rad_report rr,
   order_radiology orad,
   encounter e,
   encntr_accident ea,
   person p,
   person_alias pa,
   person_alias pa1,
   address a1,
   phone ph1,
   person_org_reltn por,
   organization org,
   encntr_person_reltn epr,
   person p2,
   address a2,
   phone ph2,
   person_org_reltn por2,
   organization org2,
   address a3,
   phone ph3,
   encntr_plan_reltn eplr,
   health_plan hp,
   code_value_alias cva,
   person_plan_reltn ppr,
   encntr_person_reltn epr2,
   person sp,
   address sa,
   phone sph
  PLAN (rr
   WHERE rr.posted_final_dt_tm >= cnvtdatetime(mf_beg_dt_tm)
    AND rr.posted_final_dt_tm <= cnvtdatetime(mf_end_dt_tm))
   JOIN (orad
   WHERE orad.order_id=rr.order_id)
   JOIN (e
   WHERE e.encntr_id=orad.encntr_id
    AND e.loc_facility_cd=mf_bri_cd
    AND  NOT (e.med_service_cd IN (mf_baystateradimaging_cd)))
   JOIN (p
   WHERE p.person_id=orad.person_id)
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.active_ind=outerjoin(1)
    AND ea.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.person_alias_type_cd=outerjoin(mf_ssn_cd)
    AND pa.active_ind=outerjoin(1)
    AND pa.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (pa1
   WHERE pa1.person_id=outerjoin(p.person_id)
    AND pa1.person_alias_type_cd=outerjoin(mf_cmrn_cd)
    AND pa1.active_ind=outerjoin(1)
    AND pa1.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (a1
   WHERE a1.parent_entity_name=outerjoin("PERSON")
    AND a1.parent_entity_id=outerjoin(p.person_id)
    AND a1.active_ind=outerjoin(1)
    AND a1.address_type_cd=outerjoin(mf_addr_home_cd)
    AND a1.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))
    AND a1.address_type_seq=outerjoin(1))
   JOIN (ph1
   WHERE ph1.parent_entity_id=outerjoin(p.person_id)
    AND ph1.parent_entity_name=outerjoin("PERSON")
    AND ph1.active_ind=outerjoin(1)
    AND ph1.phone_type_seq=outerjoin(1)
    AND ph1.phone_type_cd=outerjoin(mf_phone_home_cd)
    AND ph1.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (por
   WHERE por.person_id=outerjoin(p.person_id)
    AND por.active_ind=outerjoin(1)
    AND por.person_org_reltn_cd=outerjoin(mf_org_employer_cd)
    AND por.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (org
   WHERE org.organization_id=outerjoin(por.organization_id))
   JOIN (epr
   WHERE epr.encntr_id=outerjoin(e.encntr_id)
    AND epr.active_ind=outerjoin(1)
    AND epr.person_reltn_type_cd=outerjoin(mf_def_guar_cd)
    AND epr.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (p2
   WHERE p2.person_id=outerjoin(epr.related_person_id))
   JOIN (a2
   WHERE a2.parent_entity_name=outerjoin("PERSON")
    AND a2.parent_entity_id=outerjoin(p2.person_id)
    AND a2.active_ind=outerjoin(1)
    AND a2.address_type_cd=outerjoin(mf_addr_home_cd)
    AND a2.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))
    AND a2.address_type_seq=outerjoin(1))
   JOIN (ph2
   WHERE ph2.parent_entity_id=outerjoin(p2.person_id)
    AND ph2.parent_entity_name=outerjoin("PERSON")
    AND ph2.active_ind=outerjoin(1)
    AND ph2.phone_type_seq=outerjoin(1)
    AND ph2.phone_type_cd=outerjoin(mf_phone_home_cd)
    AND ph2.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (por2
   WHERE por2.person_id=outerjoin(p2.person_id)
    AND por2.active_ind=outerjoin(1)
    AND por2.person_org_reltn_cd=outerjoin(mf_org_employer_cd)
    AND por2.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (org2
   WHERE org2.organization_id=outerjoin(por2.organization_id))
   JOIN (a3
   WHERE a3.parent_entity_name=outerjoin("ORGANIZATION")
    AND a3.parent_entity_id=outerjoin(org2.organization_id)
    AND a3.active_ind=outerjoin(1)
    AND a3.address_type_cd=outerjoin(mf_addr_bus_cd)
    AND a3.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))
    AND a3.address_type_seq=outerjoin(1))
   JOIN (ph3
   WHERE ph3.parent_entity_id=outerjoin(org2.organization_id)
    AND ph3.parent_entity_name=outerjoin("ORGANIZATION")
    AND ph3.active_ind=outerjoin(1)
    AND ph3.phone_type_seq=outerjoin(1)
    AND ph3.phone_type_cd=outerjoin(mf_phone_bus_cd)
    AND ph3.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (eplr
   WHERE eplr.encntr_id=outerjoin(e.encntr_id)
    AND eplr.active_ind=outerjoin(1)
    AND eplr.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (hp
   WHERE hp.health_plan_id=outerjoin(eplr.health_plan_id))
   JOIN (cva
   WHERE cva.code_value=outerjoin(hp.plan_type_cd)
    AND cva.contributor_source_cd=outerjoin(mf_adtegate_cd))
   JOIN (ppr
   WHERE ppr.person_plan_reltn_id=outerjoin(eplr.person_plan_reltn_id)
    AND ppr.person_plan_r_cd=outerjoin(mf_subscriber_cd))
   JOIN (epr2
   WHERE epr2.related_person_id=outerjoin(ppr.subscriber_person_id))
   JOIN (sp
   WHERE sp.person_id=outerjoin(epr2.related_person_id))
   JOIN (sa
   WHERE sa.parent_entity_id=outerjoin(sp.person_id)
    AND sa.parent_entity_name=outerjoin("PERSON")
    AND sa.active_ind=outerjoin(1)
    AND sa.address_type_cd=outerjoin(mf_addr_home_cd)
    AND sa.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))
    AND sa.address_type_seq=outerjoin(1))
   JOIN (sph
   WHERE sph.parent_entity_id=outerjoin(sp.person_id)
    AND sph.parent_entity_name=outerjoin("PERSON")
    AND sph.active_ind=outerjoin(1)
    AND sph.phone_type_seq=outerjoin(1)
    AND sph.phone_type_cd=outerjoin(mf_phone_home_cd)
    AND sph.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
  ORDER BY orad.accession, eplr.priority_seq
  HEAD REPORT
   pinfo->cnt = 0
  HEAD orad.accession
   pinfo->cnt = (pinfo->cnt+ 1), stat = alterlist(pinfo->qual,pinfo->cnt), pinfo->qual[pinfo->cnt].
   f_person_id = p.person_id,
   pinfo->qual[pinfo->cnt].s_last_name = p.name_last_key, pinfo->qual[pinfo->cnt].s_first_name = p
   .name_first_key, pinfo->qual[pinfo->cnt].s_gender = trim(uar_get_code_display(p.sex_cd),3),
   pinfo->qual[pinfo->cnt].s_site_code = trim(uar_get_code_display(e.loc_nurse_unit_cd),3), pinfo->
   qual[pinfo->cnt].s_addr1 = a1.street_addr, pinfo->qual[pinfo->cnt].s_addr2 = a1.street_addr2,
   pinfo->qual[pinfo->cnt].s_city = a1.city, pinfo->qual[pinfo->cnt].s_state = a1.state, pinfo->qual[
   pinfo->cnt].s_zip = a1.zipcode,
   pinfo->qual[pinfo->cnt].s_home_phone = ph1.phone_num_key, pinfo->qual[pinfo->cnt].s_dob = format(p
    .birth_dt_tm,"YYYYMMDD;;q"), pinfo->qual[pinfo->cnt].s_ssn = pa.alias,
   pinfo->qual[pinfo->cnt].s_accession_nbr = orad.accession, pinfo->qual[pinfo->cnt].s_cmrn = pa1
   .alias, pinfo->qual[pinfo->cnt].s_employer = org.org_name,
   pinfo->qual[pinfo->cnt].s_guar_first_name = p2.name_first_key, pinfo->qual[pinfo->cnt].
   s_guar_last_name = p2.name_last_key, pinfo->qual[pinfo->cnt].s_guar_relation =
   uar_get_code_display(epr.person_reltn_cd),
   pinfo->qual[pinfo->cnt].s_guar_addr1 = a2.street_addr, pinfo->qual[pinfo->cnt].s_guar_city = a2
   .city, pinfo->qual[pinfo->cnt].s_guar_state = a2.state,
   pinfo->qual[pinfo->cnt].s_guar_zip = a2.zipcode, pinfo->qual[pinfo->cnt].s_guar_home_phone = ph2
   .phone_num_key, pinfo->qual[pinfo->cnt].s_guar_emp_name = org2.org_name,
   pinfo->qual[pinfo->cnt].s_guar_emp_address1 = a3.street_addr, pinfo->qual[pinfo->cnt].
   s_guar_emp_address2 = a3.street_addr2, pinfo->qual[pinfo->cnt].s_guar_emp_city = a3.city,
   pinfo->qual[pinfo->cnt].s_guar_emp_state = a3.state, pinfo->qual[pinfo->cnt].s_guar_emp_zip = a3
   .zipcode, pinfo->qual[pinfo->cnt].s_guar_emp_phone = ph3.phone_num_key,
   pinfo->qual[pinfo->cnt].s_accident_dt = format(ea.accident_dt_tm,";;q"), pinfo->qual[pinfo->cnt].
   s_accident_loc = trim(ea.accident_loctn,3), ml_ins_cnt = 0
  HEAD eplr.encntr_plan_reltn_id
   ml_ins_cnt = (ml_ins_cnt+ 1)
   IF (ml_ins_cnt=1)
    pinfo->qual[pinfo->cnt].s_carrier_code_1 = trim(cva.alias,3), pinfo->qual[pinfo->cnt].
    s_carrier_desc_1 = hp.plan_name, pinfo->qual[pinfo->cnt].s_policy_id_1 = eplr.member_nbr,
    pinfo->qual[pinfo->cnt].s_group_nbr_1 = eplr.group_nbr, pinfo->qual[pinfo->cnt].s_sub1name = trim
    (sp.name_full_formatted,3), pinfo->qual[pinfo->cnt].s_sub1relation = trim(uar_get_code_display(
      epr2.person_reltn_cd)),
    pinfo->qual[pinfo->cnt].s_sub1dob = format(sp.birth_dt_tm,"YYYYMMDD;;q"), pinfo->qual[pinfo->cnt]
    .s_sub1gender = trim(uar_get_code_display(sp.sex_cd)), pinfo->qual[pinfo->cnt].s_sub1addr1 = sa
    .street_addr,
    pinfo->qual[pinfo->cnt].s_sub1city = sa.city, pinfo->qual[pinfo->cnt].s_sub1state = sa.state,
    pinfo->qual[pinfo->cnt].s_sub1zip = sa.zipcode,
    pinfo->qual[pinfo->cnt].s_sub1phone = sph.phone_num
   ENDIF
   IF (ml_ins_cnt=2)
    pinfo->qual[pinfo->cnt].s_carrier_code_2 = trim(cva.alias,3), pinfo->qual[pinfo->cnt].
    s_carrier_desc_2 = hp.plan_name, pinfo->qual[pinfo->cnt].s_policy_id_2 = eplr.member_nbr,
    pinfo->qual[pinfo->cnt].s_group_nbr_2 = eplr.group_nbr, pinfo->qual[pinfo->cnt].s_sub2name = trim
    (sp.name_full_formatted,3), pinfo->qual[pinfo->cnt].s_sub2relation = trim(uar_get_code_display(
      epr2.person_reltn_cd)),
    pinfo->qual[pinfo->cnt].s_sub2dob = format(sp.birth_dt_tm,"YYYYMMDD;;q"), pinfo->qual[pinfo->cnt]
    .s_sub2gender = trim(uar_get_code_display(sp.sex_cd)), pinfo->qual[pinfo->cnt].s_sub2addr1 = sa
    .street_addr,
    pinfo->qual[pinfo->cnt].s_sub2addr2 = sa.street_addr2, pinfo->qual[pinfo->cnt].s_sub2city = sa
    .city, pinfo->qual[pinfo->cnt].s_sub2state = sa.state,
    pinfo->qual[pinfo->cnt].s_sub2zip = sa.zipcode, pinfo->qual[pinfo->cnt].s_sub2phone = sph
    .phone_num
   ENDIF
   IF (ml_ins_cnt=3)
    pinfo->qual[pinfo->cnt].s_carrier_code_3 = trim(cva.alias,3), pinfo->qual[pinfo->cnt].
    s_carrier_desc_3 = hp.plan_name, pinfo->qual[pinfo->cnt].s_policy_id_3 = eplr.member_nbr,
    pinfo->qual[pinfo->cnt].s_group_nbr_3 = eplr.group_nbr, pinfo->qual[pinfo->cnt].s_sub3name = trim
    (sp.name_full_formatted,3), pinfo->qual[pinfo->cnt].s_sub3relation = trim(uar_get_code_display(
      epr2.person_reltn_cd)),
    pinfo->qual[pinfo->cnt].s_sub3dob = format(sp.birth_dt_tm,"YYYYMMDD;;q"), pinfo->qual[pinfo->cnt]
    .s_sub3gender = trim(uar_get_code_display(sp.sex_cd)), pinfo->qual[pinfo->cnt].s_sub3addr1 = sa
    .street_addr,
    pinfo->qual[pinfo->cnt].s_sub3addr2 = sa.street_addr2, pinfo->qual[pinfo->cnt].s_sub3city = sa
    .city, pinfo->qual[pinfo->cnt].s_sub3state = sa.state,
    pinfo->qual[pinfo->cnt].s_sub3zip = sa.zipcode, pinfo->qual[pinfo->cnt].s_sub3phone = sph
    .phone_num
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders orad,
   encounter e,
   encntr_accident ea,
   person p,
   person_alias pa,
   person_alias pa1,
   address a1,
   phone ph1,
   person_org_reltn por,
   organization org,
   encntr_person_reltn epr,
   person p2,
   address a2,
   phone ph2,
   person_org_reltn por2,
   organization org2,
   address a3,
   phone ph3,
   encntr_plan_reltn eplr,
   health_plan hp,
   code_value_alias cva,
   person_plan_reltn ppr,
   encntr_person_reltn epr2,
   person sp,
   address sa,
   phone sph
  PLAN (orad
   WHERE orad.catalog_cd IN (mf_briekg_cd, mf_briholter_cd)
    AND orad.order_status_cd=mf_completed_cd
    AND orad.status_dt_tm >= cnvtdatetime(mf_beg_dt_tm)
    AND orad.status_dt_tm <= cnvtdatetime(mf_end_dt_tm))
   JOIN (e
   WHERE e.encntr_id=orad.encntr_id
    AND e.loc_facility_cd=mf_bri_cd
    AND  NOT (e.med_service_cd IN (mf_baystateradimaging_cd)))
   JOIN (p
   WHERE p.person_id=orad.person_id)
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.active_ind=outerjoin(1)
    AND ea.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.person_alias_type_cd=outerjoin(mf_ssn_cd)
    AND pa.active_ind=outerjoin(1)
    AND pa.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (pa1
   WHERE pa1.person_id=outerjoin(p.person_id)
    AND pa1.person_alias_type_cd=outerjoin(mf_cmrn_cd)
    AND pa1.active_ind=outerjoin(1)
    AND pa1.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (a1
   WHERE a1.parent_entity_name=outerjoin("PERSON")
    AND a1.parent_entity_id=outerjoin(p.person_id)
    AND a1.active_ind=outerjoin(1)
    AND a1.address_type_cd=outerjoin(mf_addr_home_cd)
    AND a1.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))
    AND a1.address_type_seq=outerjoin(1))
   JOIN (ph1
   WHERE ph1.parent_entity_id=outerjoin(p.person_id)
    AND ph1.parent_entity_name=outerjoin("PERSON")
    AND ph1.active_ind=outerjoin(1)
    AND ph1.phone_type_seq=outerjoin(1)
    AND ph1.phone_type_cd=outerjoin(mf_phone_home_cd)
    AND ph1.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (por
   WHERE por.person_id=outerjoin(p.person_id)
    AND por.active_ind=outerjoin(1)
    AND por.person_org_reltn_cd=outerjoin(mf_org_employer_cd)
    AND por.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (org
   WHERE org.organization_id=outerjoin(por.organization_id))
   JOIN (epr
   WHERE epr.encntr_id=outerjoin(e.encntr_id)
    AND epr.active_ind=outerjoin(1)
    AND epr.person_reltn_type_cd=outerjoin(mf_def_guar_cd)
    AND epr.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (p2
   WHERE p2.person_id=outerjoin(epr.related_person_id))
   JOIN (a2
   WHERE a2.parent_entity_name=outerjoin("PERSON")
    AND a2.parent_entity_id=outerjoin(p2.person_id)
    AND a2.active_ind=outerjoin(1)
    AND a2.address_type_cd=outerjoin(mf_addr_home_cd)
    AND a2.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))
    AND a2.address_type_seq=outerjoin(1))
   JOIN (ph2
   WHERE ph2.parent_entity_id=outerjoin(p2.person_id)
    AND ph2.parent_entity_name=outerjoin("PERSON")
    AND ph2.active_ind=outerjoin(1)
    AND ph2.phone_type_seq=outerjoin(1)
    AND ph2.phone_type_cd=outerjoin(mf_phone_home_cd)
    AND ph2.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (por2
   WHERE por2.person_id=outerjoin(p2.person_id)
    AND por2.active_ind=outerjoin(1)
    AND por2.person_org_reltn_cd=outerjoin(mf_org_employer_cd)
    AND por2.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (org2
   WHERE org2.organization_id=outerjoin(por2.organization_id))
   JOIN (a3
   WHERE a3.parent_entity_name=outerjoin("ORGANIZATION")
    AND a3.parent_entity_id=outerjoin(org2.organization_id)
    AND a3.active_ind=outerjoin(1)
    AND a3.address_type_cd=outerjoin(mf_addr_bus_cd)
    AND a3.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))
    AND a3.address_type_seq=outerjoin(1))
   JOIN (ph3
   WHERE ph3.parent_entity_id=outerjoin(org2.organization_id)
    AND ph3.parent_entity_name=outerjoin("ORGANIZATION")
    AND ph3.active_ind=outerjoin(1)
    AND ph3.phone_type_seq=outerjoin(1)
    AND ph3.phone_type_cd=outerjoin(mf_phone_bus_cd)
    AND ph3.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (eplr
   WHERE eplr.encntr_id=outerjoin(e.encntr_id)
    AND eplr.active_ind=outerjoin(1)
    AND eplr.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (hp
   WHERE hp.health_plan_id=outerjoin(eplr.health_plan_id))
   JOIN (cva
   WHERE cva.code_value=outerjoin(hp.plan_type_cd)
    AND cva.contributor_source_cd=outerjoin(mf_adtegate_cd))
   JOIN (ppr
   WHERE ppr.person_plan_reltn_id=outerjoin(eplr.person_plan_reltn_id)
    AND ppr.person_plan_r_cd=outerjoin(mf_subscriber_cd))
   JOIN (epr2
   WHERE epr2.related_person_id=outerjoin(ppr.subscriber_person_id))
   JOIN (sp
   WHERE sp.person_id=outerjoin(epr2.related_person_id))
   JOIN (sa
   WHERE sa.parent_entity_id=outerjoin(sp.person_id)
    AND sa.parent_entity_name=outerjoin("PERSON")
    AND sa.active_ind=outerjoin(1)
    AND sa.address_type_cd=outerjoin(mf_addr_home_cd)
    AND sa.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))
    AND sa.address_type_seq=outerjoin(1))
   JOIN (sph
   WHERE sph.parent_entity_id=outerjoin(sp.person_id)
    AND sph.parent_entity_name=outerjoin("PERSON")
    AND sph.active_ind=outerjoin(1)
    AND sph.phone_type_seq=outerjoin(1)
    AND sph.phone_type_cd=outerjoin(mf_phone_home_cd)
    AND sph.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
  ORDER BY orad.order_id, eplr.priority_seq
  HEAD REPORT
   pinfo->cnt = pinfo->cnt
  HEAD orad.order_id
   pinfo->cnt = (pinfo->cnt+ 1), stat = alterlist(pinfo->qual,pinfo->cnt), pinfo->qual[pinfo->cnt].
   f_person_id = p.person_id,
   pinfo->qual[pinfo->cnt].s_last_name = p.name_last_key, pinfo->qual[pinfo->cnt].s_first_name = p
   .name_first_key, pinfo->qual[pinfo->cnt].s_gender = trim(uar_get_code_display(p.sex_cd),3),
   pinfo->qual[pinfo->cnt].s_site_code = trim(uar_get_code_display(e.loc_nurse_unit_cd),3), pinfo->
   qual[pinfo->cnt].s_addr1 = a1.street_addr, pinfo->qual[pinfo->cnt].s_addr2 = a1.street_addr2,
   pinfo->qual[pinfo->cnt].s_city = a1.city, pinfo->qual[pinfo->cnt].s_state = a1.state, pinfo->qual[
   pinfo->cnt].s_zip = a1.zipcode,
   pinfo->qual[pinfo->cnt].s_home_phone = ph1.phone_num_key, pinfo->qual[pinfo->cnt].s_dob = format(p
    .birth_dt_tm,"YYYYMMDD;;q"), pinfo->qual[pinfo->cnt].s_ssn = pa.alias,
   pinfo->qual[pinfo->cnt].s_accession_nbr = cnvtstring(orad.order_id,20), pinfo->qual[pinfo->cnt].
   s_cmrn = pa1.alias, pinfo->qual[pinfo->cnt].s_employer = org.org_name,
   pinfo->qual[pinfo->cnt].s_guar_first_name = p2.name_first_key, pinfo->qual[pinfo->cnt].
   s_guar_last_name = p2.name_last_key, pinfo->qual[pinfo->cnt].s_guar_relation =
   uar_get_code_display(epr.person_reltn_cd),
   pinfo->qual[pinfo->cnt].s_guar_addr1 = a2.street_addr, pinfo->qual[pinfo->cnt].s_guar_city = a2
   .city, pinfo->qual[pinfo->cnt].s_guar_state = a2.state,
   pinfo->qual[pinfo->cnt].s_guar_zip = a2.zipcode, pinfo->qual[pinfo->cnt].s_guar_home_phone = ph2
   .phone_num_key, pinfo->qual[pinfo->cnt].s_guar_emp_name = org2.org_name,
   pinfo->qual[pinfo->cnt].s_guar_emp_address1 = a3.street_addr, pinfo->qual[pinfo->cnt].
   s_guar_emp_address2 = a3.street_addr2, pinfo->qual[pinfo->cnt].s_guar_emp_city = a3.city,
   pinfo->qual[pinfo->cnt].s_guar_emp_state = a3.state, pinfo->qual[pinfo->cnt].s_guar_emp_zip = a3
   .zipcode, pinfo->qual[pinfo->cnt].s_guar_emp_phone = ph3.phone_num_key,
   pinfo->qual[pinfo->cnt].s_accident_dt = format(ea.accident_dt_tm,";;q"), pinfo->qual[pinfo->cnt].
   s_accident_loc = trim(ea.accident_loctn,3), ml_ins_cnt = 0
  HEAD eplr.encntr_plan_reltn_id
   ml_ins_cnt = (ml_ins_cnt+ 1)
   IF (ml_ins_cnt=1)
    pinfo->qual[pinfo->cnt].s_carrier_code_1 = trim(cva.alias,3), pinfo->qual[pinfo->cnt].
    s_carrier_desc_1 = hp.plan_name, pinfo->qual[pinfo->cnt].s_policy_id_1 = eplr.member_nbr,
    pinfo->qual[pinfo->cnt].s_group_nbr_1 = eplr.group_nbr, pinfo->qual[pinfo->cnt].s_sub1name = trim
    (sp.name_full_formatted,3), pinfo->qual[pinfo->cnt].s_sub1relation = trim(uar_get_code_display(
      epr2.person_reltn_cd)),
    pinfo->qual[pinfo->cnt].s_sub1dob = format(sp.birth_dt_tm,"YYYYMMDD;;q"), pinfo->qual[pinfo->cnt]
    .s_sub1gender = trim(uar_get_code_display(sp.sex_cd)), pinfo->qual[pinfo->cnt].s_sub1addr1 = sa
    .street_addr,
    pinfo->qual[pinfo->cnt].s_sub1city = sa.city, pinfo->qual[pinfo->cnt].s_sub1state = sa.state,
    pinfo->qual[pinfo->cnt].s_sub1zip = sa.zipcode,
    pinfo->qual[pinfo->cnt].s_sub1phone = sph.phone_num
   ENDIF
   IF (ml_ins_cnt=2)
    pinfo->qual[pinfo->cnt].s_carrier_code_2 = trim(cva.alias,3), pinfo->qual[pinfo->cnt].
    s_carrier_desc_2 = hp.plan_name, pinfo->qual[pinfo->cnt].s_policy_id_2 = eplr.member_nbr,
    pinfo->qual[pinfo->cnt].s_group_nbr_2 = eplr.group_nbr, pinfo->qual[pinfo->cnt].s_sub2name = trim
    (sp.name_full_formatted,3), pinfo->qual[pinfo->cnt].s_sub2relation = trim(uar_get_code_display(
      epr2.person_reltn_cd)),
    pinfo->qual[pinfo->cnt].s_sub2dob = format(sp.birth_dt_tm,"YYYYMMDD;;q"), pinfo->qual[pinfo->cnt]
    .s_sub2gender = trim(uar_get_code_display(sp.sex_cd)), pinfo->qual[pinfo->cnt].s_sub2addr1 = sa
    .street_addr,
    pinfo->qual[pinfo->cnt].s_sub2addr2 = sa.street_addr2, pinfo->qual[pinfo->cnt].s_sub2city = sa
    .city, pinfo->qual[pinfo->cnt].s_sub2state = sa.state,
    pinfo->qual[pinfo->cnt].s_sub2zip = sa.zipcode, pinfo->qual[pinfo->cnt].s_sub2phone = sph
    .phone_num
   ENDIF
   IF (ml_ins_cnt=3)
    pinfo->qual[pinfo->cnt].s_carrier_code_3 = trim(cva.alias,3), pinfo->qual[pinfo->cnt].
    s_carrier_desc_3 = hp.plan_name, pinfo->qual[pinfo->cnt].s_policy_id_3 = eplr.member_nbr,
    pinfo->qual[pinfo->cnt].s_group_nbr_3 = eplr.group_nbr, pinfo->qual[pinfo->cnt].s_sub3name = trim
    (sp.name_full_formatted,3), pinfo->qual[pinfo->cnt].s_sub3relation = trim(uar_get_code_display(
      epr2.person_reltn_cd)),
    pinfo->qual[pinfo->cnt].s_sub3dob = format(sp.birth_dt_tm,"YYYYMMDD;;q"), pinfo->qual[pinfo->cnt]
    .s_sub3gender = trim(uar_get_code_display(sp.sex_cd)), pinfo->qual[pinfo->cnt].s_sub3addr1 = sa
    .street_addr,
    pinfo->qual[pinfo->cnt].s_sub3addr2 = sa.street_addr2, pinfo->qual[pinfo->cnt].s_sub3city = sa
    .city, pinfo->qual[pinfo->cnt].s_sub3state = sa.state,
    pinfo->qual[pinfo->cnt].s_sub3zip = sa.zipcode, pinfo->qual[pinfo->cnt].s_sub3phone = sph
    .phone_num
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_radiology orad,
   encounter e,
   encntr_accident ea,
   person p,
   person_alias pa,
   person_alias pa1,
   address a1,
   phone ph1,
   person_org_reltn por,
   organization org,
   encntr_person_reltn epr,
   person p2,
   address a2,
   phone ph2,
   person_org_reltn por2,
   organization org2,
   address a3,
   phone ph3,
   encntr_plan_reltn eplr,
   health_plan hp,
   code_value_alias cva,
   person_plan_reltn ppr,
   encntr_person_reltn epr2,
   person sp,
   address sa,
   phone sph
  PLAN (orad
   WHERE orad.catalog_cd IN (mf_tcchest1view_cd, mf_tcchest2view_cd)
    AND orad.exam_status_cd=mf_exam_completed_cd
    AND orad.complete_dt_tm >= cnvtdatetime(mf_beg_dt_tm)
    AND orad.complete_dt_tm <= cnvtdatetime(mf_end_dt_tm))
   JOIN (e
   WHERE e.encntr_id=orad.encntr_id
    AND e.loc_facility_cd=mf_bri_cd
    AND  NOT (e.med_service_cd IN (mf_baystateradimaging_cd)))
   JOIN (p
   WHERE p.person_id=orad.person_id)
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.active_ind=outerjoin(1)
    AND ea.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.person_alias_type_cd=outerjoin(mf_ssn_cd)
    AND pa.active_ind=outerjoin(1)
    AND pa.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (pa1
   WHERE pa1.person_id=outerjoin(p.person_id)
    AND pa1.person_alias_type_cd=outerjoin(mf_cmrn_cd)
    AND pa1.active_ind=outerjoin(1)
    AND pa1.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (a1
   WHERE a1.parent_entity_name=outerjoin("PERSON")
    AND a1.parent_entity_id=outerjoin(p.person_id)
    AND a1.active_ind=outerjoin(1)
    AND a1.address_type_cd=outerjoin(mf_addr_home_cd)
    AND a1.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))
    AND a1.address_type_seq=outerjoin(1))
   JOIN (ph1
   WHERE ph1.parent_entity_id=outerjoin(p.person_id)
    AND ph1.parent_entity_name=outerjoin("PERSON")
    AND ph1.active_ind=outerjoin(1)
    AND ph1.phone_type_seq=outerjoin(1)
    AND ph1.phone_type_cd=outerjoin(mf_phone_home_cd)
    AND ph1.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (por
   WHERE por.person_id=outerjoin(p.person_id)
    AND por.active_ind=outerjoin(1)
    AND por.person_org_reltn_cd=outerjoin(mf_org_employer_cd)
    AND por.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (org
   WHERE org.organization_id=outerjoin(por.organization_id))
   JOIN (epr
   WHERE epr.encntr_id=outerjoin(e.encntr_id)
    AND epr.active_ind=outerjoin(1)
    AND epr.person_reltn_type_cd=outerjoin(mf_def_guar_cd)
    AND epr.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (p2
   WHERE p2.person_id=outerjoin(epr.related_person_id))
   JOIN (a2
   WHERE a2.parent_entity_name=outerjoin("PERSON")
    AND a2.parent_entity_id=outerjoin(p2.person_id)
    AND a2.active_ind=outerjoin(1)
    AND a2.address_type_cd=outerjoin(mf_addr_home_cd)
    AND a2.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))
    AND a2.address_type_seq=outerjoin(1))
   JOIN (ph2
   WHERE ph2.parent_entity_id=outerjoin(p2.person_id)
    AND ph2.parent_entity_name=outerjoin("PERSON")
    AND ph2.active_ind=outerjoin(1)
    AND ph2.phone_type_seq=outerjoin(1)
    AND ph2.phone_type_cd=outerjoin(mf_phone_home_cd)
    AND ph2.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (por2
   WHERE por2.person_id=outerjoin(p2.person_id)
    AND por2.active_ind=outerjoin(1)
    AND por2.person_org_reltn_cd=outerjoin(mf_org_employer_cd)
    AND por2.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (org2
   WHERE org2.organization_id=outerjoin(por2.organization_id))
   JOIN (a3
   WHERE a3.parent_entity_name=outerjoin("ORGANIZATION")
    AND a3.parent_entity_id=outerjoin(org2.organization_id)
    AND a3.active_ind=outerjoin(1)
    AND a3.address_type_cd=outerjoin(mf_addr_bus_cd)
    AND a3.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))
    AND a3.address_type_seq=outerjoin(1))
   JOIN (ph3
   WHERE ph3.parent_entity_id=outerjoin(org2.organization_id)
    AND ph3.parent_entity_name=outerjoin("ORGANIZATION")
    AND ph3.active_ind=outerjoin(1)
    AND ph3.phone_type_seq=outerjoin(1)
    AND ph3.phone_type_cd=outerjoin(mf_phone_bus_cd)
    AND ph3.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (eplr
   WHERE eplr.encntr_id=outerjoin(e.encntr_id)
    AND eplr.active_ind=outerjoin(1)
    AND eplr.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (hp
   WHERE hp.health_plan_id=outerjoin(eplr.health_plan_id))
   JOIN (cva
   WHERE cva.code_value=outerjoin(hp.plan_type_cd)
    AND cva.contributor_source_cd=outerjoin(mf_adtegate_cd))
   JOIN (ppr
   WHERE ppr.person_plan_reltn_id=outerjoin(eplr.person_plan_reltn_id)
    AND ppr.person_plan_r_cd=outerjoin(mf_subscriber_cd))
   JOIN (epr2
   WHERE epr2.related_person_id=outerjoin(ppr.subscriber_person_id))
   JOIN (sp
   WHERE sp.person_id=outerjoin(epr2.related_person_id))
   JOIN (sa
   WHERE sa.parent_entity_id=outerjoin(sp.person_id)
    AND sa.parent_entity_name=outerjoin("PERSON")
    AND sa.active_ind=outerjoin(1)
    AND sa.address_type_cd=outerjoin(mf_addr_home_cd)
    AND sa.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))
    AND sa.address_type_seq=outerjoin(1))
   JOIN (sph
   WHERE sph.parent_entity_id=outerjoin(sp.person_id)
    AND sph.parent_entity_name=outerjoin("PERSON")
    AND sph.active_ind=outerjoin(1)
    AND sph.phone_type_seq=outerjoin(1)
    AND sph.phone_type_cd=outerjoin(mf_phone_home_cd)
    AND sph.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
  ORDER BY orad.order_id, eplr.priority_seq
  HEAD REPORT
   pinfo->cnt = pinfo->cnt
  HEAD orad.order_id
   pinfo->cnt = (pinfo->cnt+ 1), stat = alterlist(pinfo->qual,pinfo->cnt), pinfo->qual[pinfo->cnt].
   f_person_id = p.person_id,
   pinfo->qual[pinfo->cnt].s_last_name = p.name_last_key, pinfo->qual[pinfo->cnt].s_first_name = p
   .name_first_key, pinfo->qual[pinfo->cnt].s_gender = trim(uar_get_code_display(p.sex_cd),3),
   pinfo->qual[pinfo->cnt].s_site_code = trim(uar_get_code_display(e.loc_nurse_unit_cd),3), pinfo->
   qual[pinfo->cnt].s_addr1 = a1.street_addr, pinfo->qual[pinfo->cnt].s_addr2 = a1.street_addr2,
   pinfo->qual[pinfo->cnt].s_city = a1.city, pinfo->qual[pinfo->cnt].s_state = a1.state, pinfo->qual[
   pinfo->cnt].s_zip = a1.zipcode,
   pinfo->qual[pinfo->cnt].s_home_phone = ph1.phone_num_key, pinfo->qual[pinfo->cnt].s_dob = format(p
    .birth_dt_tm,"YYYYMMDD;;q"), pinfo->qual[pinfo->cnt].s_ssn = pa.alias,
   pinfo->qual[pinfo->cnt].s_accession_nbr = orad.accession, pinfo->qual[pinfo->cnt].s_cmrn = pa1
   .alias, pinfo->qual[pinfo->cnt].s_employer = org.org_name,
   pinfo->qual[pinfo->cnt].s_guar_first_name = p2.name_first_key, pinfo->qual[pinfo->cnt].
   s_guar_last_name = p2.name_last_key, pinfo->qual[pinfo->cnt].s_guar_relation =
   uar_get_code_display(epr.person_reltn_cd),
   pinfo->qual[pinfo->cnt].s_guar_addr1 = a2.street_addr, pinfo->qual[pinfo->cnt].s_guar_city = a2
   .city, pinfo->qual[pinfo->cnt].s_guar_state = a2.state,
   pinfo->qual[pinfo->cnt].s_guar_zip = a2.zipcode, pinfo->qual[pinfo->cnt].s_guar_home_phone = ph2
   .phone_num_key, pinfo->qual[pinfo->cnt].s_guar_emp_name = org2.org_name,
   pinfo->qual[pinfo->cnt].s_guar_emp_address1 = a3.street_addr, pinfo->qual[pinfo->cnt].
   s_guar_emp_address2 = a3.street_addr2, pinfo->qual[pinfo->cnt].s_guar_emp_city = a3.city,
   pinfo->qual[pinfo->cnt].s_guar_emp_state = a3.state, pinfo->qual[pinfo->cnt].s_guar_emp_zip = a3
   .zipcode, pinfo->qual[pinfo->cnt].s_guar_emp_phone = ph3.phone_num_key,
   pinfo->qual[pinfo->cnt].s_accident_dt = format(ea.accident_dt_tm,";;q"), pinfo->qual[pinfo->cnt].
   s_accident_loc = trim(ea.accident_loctn,3), ml_ins_cnt = 0
  HEAD eplr.encntr_plan_reltn_id
   ml_ins_cnt = (ml_ins_cnt+ 1)
   IF (ml_ins_cnt=1)
    pinfo->qual[pinfo->cnt].s_carrier_code_1 = trim(cva.alias,3), pinfo->qual[pinfo->cnt].
    s_carrier_desc_1 = hp.plan_name, pinfo->qual[pinfo->cnt].s_policy_id_1 = eplr.member_nbr,
    pinfo->qual[pinfo->cnt].s_group_nbr_1 = eplr.group_nbr, pinfo->qual[pinfo->cnt].s_sub1name = trim
    (sp.name_full_formatted,3), pinfo->qual[pinfo->cnt].s_sub1relation = trim(uar_get_code_display(
      epr2.person_reltn_cd)),
    pinfo->qual[pinfo->cnt].s_sub1dob = format(sp.birth_dt_tm,"YYYYMMDD;;q"), pinfo->qual[pinfo->cnt]
    .s_sub1gender = trim(uar_get_code_display(sp.sex_cd)), pinfo->qual[pinfo->cnt].s_sub1addr1 = sa
    .street_addr,
    pinfo->qual[pinfo->cnt].s_sub1city = sa.city, pinfo->qual[pinfo->cnt].s_sub1state = sa.state,
    pinfo->qual[pinfo->cnt].s_sub1zip = sa.zipcode,
    pinfo->qual[pinfo->cnt].s_sub1phone = sph.phone_num
   ENDIF
   IF (ml_ins_cnt=2)
    pinfo->qual[pinfo->cnt].s_carrier_code_2 = trim(cva.alias,3), pinfo->qual[pinfo->cnt].
    s_carrier_desc_2 = hp.plan_name, pinfo->qual[pinfo->cnt].s_policy_id_2 = eplr.member_nbr,
    pinfo->qual[pinfo->cnt].s_group_nbr_2 = eplr.group_nbr, pinfo->qual[pinfo->cnt].s_sub2name = trim
    (sp.name_full_formatted,3), pinfo->qual[pinfo->cnt].s_sub2relation = trim(uar_get_code_display(
      epr2.person_reltn_cd)),
    pinfo->qual[pinfo->cnt].s_sub2dob = format(sp.birth_dt_tm,"YYYYMMDD;;q"), pinfo->qual[pinfo->cnt]
    .s_sub2gender = trim(uar_get_code_display(sp.sex_cd)), pinfo->qual[pinfo->cnt].s_sub2addr1 = sa
    .street_addr,
    pinfo->qual[pinfo->cnt].s_sub2addr2 = sa.street_addr2, pinfo->qual[pinfo->cnt].s_sub2city = sa
    .city, pinfo->qual[pinfo->cnt].s_sub2state = sa.state,
    pinfo->qual[pinfo->cnt].s_sub2zip = sa.zipcode, pinfo->qual[pinfo->cnt].s_sub2phone = sph
    .phone_num
   ENDIF
   IF (ml_ins_cnt=3)
    pinfo->qual[pinfo->cnt].s_carrier_code_3 = trim(cva.alias,3), pinfo->qual[pinfo->cnt].
    s_carrier_desc_3 = hp.plan_name, pinfo->qual[pinfo->cnt].s_policy_id_3 = eplr.member_nbr,
    pinfo->qual[pinfo->cnt].s_group_nbr_3 = eplr.group_nbr, pinfo->qual[pinfo->cnt].s_sub3name = trim
    (sp.name_full_formatted,3), pinfo->qual[pinfo->cnt].s_sub3relation = trim(uar_get_code_display(
      epr2.person_reltn_cd)),
    pinfo->qual[pinfo->cnt].s_sub3dob = format(sp.birth_dt_tm,"YYYYMMDD;;q"), pinfo->qual[pinfo->cnt]
    .s_sub3gender = trim(uar_get_code_display(sp.sex_cd)), pinfo->qual[pinfo->cnt].s_sub3addr1 = sa
    .street_addr,
    pinfo->qual[pinfo->cnt].s_sub3addr2 = sa.street_addr2, pinfo->qual[pinfo->cnt].s_sub3city = sa
    .city, pinfo->qual[pinfo->cnt].s_sub3state = sa.state,
    pinfo->qual[pinfo->cnt].s_sub3zip = sa.zipcode, pinfo->qual[pinfo->cnt].s_sub3phone = sph
    .phone_num
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO value(ms_filename)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   ms_line = concat('"SiteCode",','"LastName",','"FirstName",','"Sex",','"Street",',
    '"PatientAddress2",','"City",','"PatientState",','"Zip",','"Phone",',
    '"SSN",','"DOB",','"Patient Employer",','"CarrierCode",','"PolicyID",',
    '"GroupNo",','"FirstCarrierDesc",','"SecCarrierCode",','"SecPolicyID",','"SecGroupNo",',
    '"SecCarrierDesc",','"ThrdCarrierCode",','"ThrdPolicyID",','"ThrdGroupNo",','"ThrdCarrierDesc",',
    '"PreCertNum",','"PreCertNum2",','"PreCertNum3",','"CompletionDate",','"SignDate",',
    '"AccessionNumber",','"Status",','"Exam",','"AddCharge1",','"AddCharge1Units",',
    '"AddCharge2",','"AddCharge2Units",','"AddCharge3",','"AddCharge3Units",','"AddCharge4",',
    '"AddCharge4Units",','"AddCharge5",','"AddCharge5Units",','"History",','"Radiologist",',
    '"Reason",','"PatientID",','"ReferrerName",','"SiteName",','"NPIN",',
    '"MiscCar1Name",','"Subscriber",','"Subscriber1Relationship",','"SubscriberDOB",',
    '"SubscriberGender",',
    '"SubscriberAddress",','"SubscriberCity",','"SubscriberState",','"SubscriberZip",',
    '"SubscriberPhone",',
    '"MVAClaimNo",','"MVADateOfAccident",','"MVAInsuranceCo",','"MVAInsuranceAddress",',
    '"MVAInsurancePhone",',
    '"MVAAttorney",','"MVAFirmName",','"MVAAttorneyAddress",','"MVAAttorneyPhone",','"SepAttorney",',
    '"SepAttorneyFirmName",','"SepAttorneyAddress",','"SepAttorneyPhone",','"AutoAccidentState",',
    '"WCClaimNumber",',
    '"WCCarrier",','"WCAddress",','"WCPhone",','"InjuryDate",','"GuarantorFirstName",',
    '"GuarantorLastName",','"GuarantorRelationship",','"GuarantorAddress",','"GuarantorCity",',
    '"GuarantorState",',
    '"GuarantorZip",','"GuarantorPhone",','"GuarantorEmployerName",','"GuarantorEmployerAddress1",',
    '"GuarantorEmployerAddress2",',
    '"GuarantorEmployerCity",','"GuarantorEmployerState",','"GuarantorEmployerZip",',
    '"GuarantorEmployerPhone",','"SecondSubscriber",',
    '"Subscriber2Relationship",','"Subscriber2DOB",','"Subscriber2Gender",',
    '"SecondSubscriberAddress",','"SecondSubscriberAddress2",',
    '"SecondSubscriberCity",','"SecondSubscriberState",','"SecondSubscriberZip",',
    '"SecondSubscriberPhone",','"ThrdSubscriber",',
    '"Subscriber3Relationship",','"Subscriber3DOB",','"Subscriber3Gender",',
    '"ThrdSubscriberAddress",','"ThirdSubscriberAddress2",',
    '"ThrdSubscriberCity",','"ThrdSubscriberState",','"ThrdSubscriberZip",','"ThrdSubscriberPhone",',
    '"Report",',
    '"Addendum",','"EmergencyContactName"'),
   CALL print(ms_line), row + 1
   FOR (ml_info_cnt = 1 TO pinfo->cnt)
     ms_line = concat('"',pinfo->qual[ml_info_cnt].s_site_code,'","',pinfo->qual[ml_info_cnt].
      s_last_name,'","',
      pinfo->qual[ml_info_cnt].s_first_name,'","',pinfo->qual[ml_info_cnt].s_gender,'","',pinfo->
      qual[ml_info_cnt].s_addr1,
      '","',pinfo->qual[ml_info_cnt].s_addr2,'","',pinfo->qual[ml_info_cnt].s_city,'","',
      pinfo->qual[ml_info_cnt].s_state,'","',pinfo->qual[ml_info_cnt].s_zip,'","',pinfo->qual[
      ml_info_cnt].s_home_phone,
      '","',pinfo->qual[ml_info_cnt].s_ssn,'","',pinfo->qual[ml_info_cnt].s_dob,'","',
      pinfo->qual[ml_info_cnt].s_employer,'","',pinfo->qual[ml_info_cnt].s_carrier_code_1,'","',pinfo
      ->qual[ml_info_cnt].s_policy_id_1,
      '","',pinfo->qual[ml_info_cnt].s_group_nbr_1,'","',pinfo->qual[ml_info_cnt].s_carrier_desc_1,
      '","',
      pinfo->qual[ml_info_cnt].s_carrier_code_2,'","',pinfo->qual[ml_info_cnt].s_policy_id_2,'","',
      pinfo->qual[ml_info_cnt].s_group_nbr_2,
      '","',pinfo->qual[ml_info_cnt].s_carrier_desc_2,'","',pinfo->qual[ml_info_cnt].s_carrier_code_3,
      '","',
      pinfo->qual[ml_info_cnt].s_policy_id_3,'","',pinfo->qual[ml_info_cnt].s_group_nbr_3,'","',pinfo
      ->qual[ml_info_cnt].s_carrier_desc_3,
      '","','","','","','","','","',
      '","',pinfo->qual[ml_info_cnt].s_accession_nbr,'","','","','","',
      '","','","','","','","','","',
      '","','","','","','","','","',
      '","','","','","',pinfo->qual[ml_info_cnt].s_cmrn,'","',
      '","','","','","','","',pinfo->qual[ml_info_cnt].s_sub1name,
      '","',pinfo->qual[ml_info_cnt].s_sub1relation,'","',pinfo->qual[ml_info_cnt].s_sub1dob,'","',
      pinfo->qual[ml_info_cnt].s_sub1gender,'","',pinfo->qual[ml_info_cnt].s_sub1addr1,'","',pinfo->
      qual[ml_info_cnt].s_sub1city,
      '","',pinfo->qual[ml_info_cnt].s_sub1state,'","',pinfo->qual[ml_info_cnt].s_sub1zip,'","',
      pinfo->qual[ml_info_cnt].s_sub1phone,'","','","','","','","',
      '","','","','","','","','","',
      '","','","','","','","','","',
      pinfo->qual[ml_info_cnt].s_accident_loc,'","','","','","','","',
      '","',pinfo->qual[ml_info_cnt].s_accident_dt,'","',pinfo->qual[ml_info_cnt].s_guar_first_name,
      '","',
      pinfo->qual[ml_info_cnt].s_guar_last_name,'","',pinfo->qual[ml_info_cnt].s_guar_relation,'","',
      pinfo->qual[ml_info_cnt].s_guar_addr1,
      '","',pinfo->qual[ml_info_cnt].s_guar_city,'","',pinfo->qual[ml_info_cnt].s_guar_state,'","',
      pinfo->qual[ml_info_cnt].s_guar_zip,'","',pinfo->qual[ml_info_cnt].s_guar_home_phone,'","',
      pinfo->qual[ml_info_cnt].s_guar_emp_name,
      '","',pinfo->qual[ml_info_cnt].s_guar_emp_address1,'","',pinfo->qual[ml_info_cnt].
      s_guar_emp_address2,'","',
      pinfo->qual[ml_info_cnt].s_guar_emp_city,'","',pinfo->qual[ml_info_cnt].s_guar_emp_state,'","',
      pinfo->qual[ml_info_cnt].s_guar_emp_zip,
      '","',pinfo->qual[ml_info_cnt].s_guar_emp_phone,'","',pinfo->qual[ml_info_cnt].s_sub2name,'","',
      pinfo->qual[ml_info_cnt].s_sub2relation,'","',pinfo->qual[ml_info_cnt].s_sub2dob,'","',pinfo->
      qual[ml_info_cnt].s_sub2gender,
      '","',pinfo->qual[ml_info_cnt].s_sub2addr1,'","',pinfo->qual[ml_info_cnt].s_sub2addr2,'","',
      pinfo->qual[ml_info_cnt].s_sub2city,'","',pinfo->qual[ml_info_cnt].s_sub2state,'","',pinfo->
      qual[ml_info_cnt].s_sub2zip,
      '","',pinfo->qual[ml_info_cnt].s_sub2phone,'","',pinfo->qual[ml_info_cnt].s_sub3name,'","',
      pinfo->qual[ml_info_cnt].s_sub3relation,'","',pinfo->qual[ml_info_cnt].s_sub3dob,'","',pinfo->
      qual[ml_info_cnt].s_sub3gender,
      '","',pinfo->qual[ml_info_cnt].s_sub3addr1,'","',pinfo->qual[ml_info_cnt].s_sub3addr2,'","',
      pinfo->qual[ml_info_cnt].s_sub3city,'","',pinfo->qual[ml_info_cnt].s_sub3state,'","',pinfo->
      qual[ml_info_cnt].s_sub3zip,
      '","',pinfo->qual[ml_info_cnt].s_sub3phone,'","','","','","',
      '"'),
     CALL print(ms_line), row + 1
   ENDFOR
  WITH nocounter, maxcol = 3000, format,
   noheading, maxrow = 1
 ;end select
 SET ms_dclcom = concat("$cust_script/bhs_ftp_file.ksh ",ms_filename,
  " 172.17.10.5 'bhs\cisftp' C!sftp01 '",'"',"ciscore/bri_extract",
  '"',"'")
 CALL echo(ms_dclcom)
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
#exit_program
END GO

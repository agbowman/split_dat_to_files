CREATE PROGRAM dcp_get_genview_ins3_test:dba
 SET rhead =
 "{\rtf1\ansi\deff0{\fonttbl{\f0\fswissArial;}}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134"
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = " \plain \f0 \fs18 \cb2 "
 SET wb = " \plain \f0 \fs18 \b \cb2 "
 SET wu = " \plain \f0 \fs18 \ul \cb2 "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET rtfeof = "}"
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET finnbr_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 SET ssn_alias_cd = uar_get_code_by("MEANING",4,"SSN")
 SET primcaredoc_cd = uar_get_code_by("MEANING",333,"PCP")
 SET familydoc_cd = uar_get_code_by("MEANING",331,"FAMILYDOC")
 SET attenddoc_cd = uar_get_code_by("MEANING",333,"ATTENDDOC")
 SET admitdoc_cd = uar_get_code_by("MEANING",333,"ADMITDOC")
 SET referdoc_cd = uar_get_code_by("MEANING",333,"REFERDOC")
 SET home_phone_cd = uar_get_code_by("MEANING",43,"HOME")
 SET alt_phone_cd = uar_get_code_by("MEANING",43,"ALTERNATE")
 SET bus_phone_cd = uar_get_code_by("MEANING",43,"BUSINESS")
 SET bill_phone_cd = uar_get_code_by("MEANING",43,"BILLING")
 SET home_address_cd = uar_get_code_by("MEANING",212,"HOME")
 SET bus_address_cd = uar_get_code_by("MEANING",212,"BUSINESS")
 SET bill_address_cd = uar_get_code_by("MEANING",212,"BILLING")
 SET org_insur_cd = uar_get_code_by("MEANING",338,"INSURANCE CO")
 SET org_empl_cd = uar_get_code_by("MEANING",338,"EMPLOYER")
 SET insured_cd = uar_get_code_by("MEANING",351,"INSURED")
 SET emc_cd = uar_get_code_by("MEANING",351,"EMC")
 SET family_cd = uar_get_code_by("MEANING",351,"FAMILY")
 SET def_guar_cd = uar_get_code_by("MEANING",351,"DEFGUAR")
 SET insured_cd = uar_get_code_by("MEANING",351,"INSURED")
 SET nok_cd = uar_get_code_by("MEANING",351,"NOK")
 SET pcg_cd = uar_get_code_by("MEANING",351,"PCG")
 SET mrn_cd = uar_get_code_by("MEANING",319,"MRN")
 SET cmrn_cd = uar_get_code_by("MEANING",4,"CMRN")
 DECLARE mobile_phone_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"CELL"))
 DECLARE advance_dir_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ADVANCEDIRECTIVE"))
 DECLARE adv_dir_ind = i2
 SET adv_type = uar_get_code_by("DISPLAYKEY",72,"ADVANCEDIRECTIVETYPE")
 SET adv_proxy = uar_get_code_by("DISPLAYKEY",72,"PROXY")
 SET adv_phone = uar_get_code_by("DISPLAYKEY",72,"CONTACTPROXYPHONENUMBER")
 SET adv_date = uar_get_code_by("DISPLAYKEY",72,"ADVANCEDIRECTIVEDATE")
 SET x = 1
 SET lidx = 0
 SET tmp_display1 = fillstring(30," ")
 SET temp_disp1 = fillstring(200," ")
 SET temp_disp2 = fillstring(200," ")
 SET temp_disp5 = fillstring(200," ")
 SET temp_disp6 = fillstring(200," ")
 SET temp_disp7 = fillstring(200," ")
 SET temp_disp8 = fillstring(200," ")
 SET temp_disp9 = fillstring(200," ")
 SET temp_disp10 = fillstring(200," ")
 RECORD drec(
   1 line_cnt = i4
   1 dislay_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 FREE RECORD pers
 RECORD pers(
   1 arrive_dt_tm = dq8
   1 disch_dt_tm = dq8
   1 birth_dt_cd = i2
   1 birth_dt_tm = dq8
   1 name_full_formatted = c30
   1 marital_type_cd = vc
   1 mrn = vc
   1 fin_nbr = vc
   1 loc_facility = vc
   1 cmrn = vc
   1 encntr = f8
   1 person_id = f8
   1 person_type_cd = vc
   1 sex_cd = vc
   1 patient_type_cd = vc
   1 ssn = vc
   1 home_st_addr = vc
   1 home_st_addr2 = vc
   1 home_city = vc
   1 home_state = vc
   1 home_zip = vc
   1 home_csz = vc
   1 home_state_disp = vc
   1 home_phone = vc
   1 bus_phone = vc
   1 mobile_phone = vc
   1 referdoc = vc
   1 attenddoc = vc
   1 admitdoc = vc
   1 familydoc = vc
   1 primcaredoc = vc
   1 reason4visit = vc
   1 language = vc
   1 empl_id = f8
   1 empl_name = vc
   1 empl_occup = vc
   1 empl_sts = vc
   1 empl_st_addr = vc
   1 empl_st_addr2 = vc
   1 empl_csz = vc
   1 empl_phone = vc
   1 guar_name = vc
   1 guar_reltn = vc
   1 guar_addr = vc
   1 guar_addr2 = vc
   1 guar_csz = vc
   1 guar_home_ph = vc
   1 guar_wk_ph = vc
   1 guar_wk_ext = vc
   1 guar_mobile_ph = vc
   1 emc_name = vc
   1 emc_addr = vc
   1 emc_csz = vc
   1 emc_home_ph = vc
   1 emc_wk_ph = vc
   1 emc_wk_ext = vc
   1 emc_mobile_ph = vc
   1 pcg_name = vc
   1 pcg_addr = vc
   1 pcg_csz = vc
   1 pcg_home_ph = vc
   1 pcg_wk_ph = vc
   1 pcg_wk_ext = vc
   1 pcg_mobile_ph = vc
   1 adv_type = vc
   1 adv_proxy = vc
   1 adv_phone = vc
   1 adv_date = vc
   1 nok[2]
     2 nok_name = vc
     2 nok_reltn = vc
     2 nok_home_ph = vc
     2 nok_wk_ph = vc
     2 nok_wk_ext = vc
     2 nok_mobile_ph = vc
     2 nok_addr = vc
     2 nok_addr2 = vc
     2 nok_csz = vc
   1 acc_dt = dq8
   1 acc_cd = vc
   1 acc_loc = vc
   1 ins[5]
     2 ins_name = vc
     2 hp_name = vc
     2 mbr_nbr = vc
     2 grp_nbr = vc
     2 plan_type = vc
     2 hp_addr = vc
     2 hp_addr2 = vc
     2 hp_csz = vc
     2 hp_ph = vc
     2 sub_name = vc
     2 sub_person_id = f8
     2 sub_dob = dq8
     2 sub_ssn = vc
     2 sub_sex = vc
     2 sub_empl_id = f8
     2 sub_empl_name = vc
     2 sub_empl_st_addr = vc
     2 sub_empl_st_addr2 = vc
     2 sub_empl_csz = vc
     2 sub_empl_occup = vc
     2 sub_empl_sts = vc
 )
 FREE RECORD dispa
 RECORD dispa(
   1 spaces1 = vc
   1 display1 = vc
   1 spaces2 = vc
   1 display2 = vc
 )
 FREE RECORD drec
 RECORD drec(
   1 line_cnt = i4
   1 dislay_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 DECLARE diagtype = f8
 SET stat = uar_get_meaning_by_codeset(17,"ADMIT",1,diagtype)
 SET loc_display = fillstring(60,"")
 SET est_arrival = fillstring(30,"")
 SELECT INTO "NL:"
  e.encntr_id, e.reason_for_visit, e.arrive_dt_tm,
  e.disch_dt_tm, lang = uar_get_code_display(p.language_cd), patient_type_cd = uar_get_code_display(e
   .encntr_type_cd),
  p.birth_dt_tm, sex_cd = uar_get_code_display(p.sex_cd), p.name_full_formatted,
  marital_type_cd = uar_get_code_display(p.marital_type_cd), diagft = d.diag_ftdesc, diagcode =
  concat(trim(n.source_identifier)," ",n.source_string),
  pa.alias, loc = build(uar_get_code_display(e.loc_nurse_unit_cd),"/",uar_get_code_display(e
    .loc_room_cd),"-",uar_get_code_display(e.loc_bed_cd)), fac = uar_get_code_description(e
   .loc_facility_cd)
  FROM encounter e,
   person p,
   person_alias pa,
   diagnosis d,
   nomenclature n
  PLAN (e
   WHERE (e.encntr_id= $1))
   JOIN (p
   WHERE e.person_id=p.person_id)
   JOIN (pa
   WHERE p.person_id=pa.person_id
    AND pa.person_alias_type_cd=cmrn_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d
   WHERE d.encntr_id=outerjoin(e.encntr_id)
    AND outerjoin(diagtype)=d.diag_type_cd
    AND outerjoin(cnvtdatetime(curdate,curtime3)) >= d.beg_effective_dt_tm
    AND outerjoin(cnvtdatetime(curdate,curtime3)) <= d.end_effective_dt_tm)
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(d.nomenclature_id)
    AND outerjoin(cnvtdatetime(curdate,curtime3)) >= n.beg_effective_dt_tm
    AND outerjoin(cnvtdatetime(curdate,curtime3)) <= n.end_effective_dt_tm)
  DETAIL
   loc_display = loc, est_arrival = format(e.est_arrive_dt_tm,"mm/dd/yyyy hh:mm;;q"), pers->
   patient_type_cd = patient_type_cd,
   pers->arrive_dt_tm = e.arrive_dt_tm, pers->disch_dt_tm = e.disch_dt_tm, pers->birth_dt_cd = p
   .birth_dt_cd,
   pers->birth_dt_tm = p.birth_dt_tm, pers->name_full_formatted = substring(1,30,p
    .name_full_formatted), pers->marital_type_cd = marital_type_cd,
   pers->person_id = p.person_id, pers->sex_cd = sex_cd, pers->cmrn = substring(1,10,cnvtalias(pa
     .alias,pa.alias_pool_cd)),
   pers->encntr =  $1, pers->loc_facility = fac
   IF (p.language_cd=0.0)
    pers->language = "unknown"
   ELSE
    pers->language = lang
   ENDIF
   IF (textlen(trim(diagcode)) > 0)
    pers->reason4visit = substring(1,80,diagcode)
   ELSEIF (textlen(trim(diagft)) > 0)
    pers->reason4visit = substring(1,80,diagft)
   ELSE
    pers->reason4visit = substring(1,80,e.reason_for_visit)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM person_alias a
  WHERE (a.person_id=pers->person_id)
   AND a.person_alias_type_cd=ssn_alias_cd
   AND a.active_ind=1
  DETAIL
   pers->ssn = cnvtalias(a.alias,a.alias_pool_cd)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM encntr_alias a
  WHERE (a.encntr_id= $1)
   AND a.encntr_alias_type_cd IN (finnbr_cd, mrn_cd)
   AND a.active_ind=1
  DETAIL
   IF (a.encntr_alias_type_cd=finnbr_cd)
    pers->fin_nbr = format(a.alias,"##########;p0")
   ELSEIF (a.encntr_alias_type_cd=mrn_cd)
    pers->mrn = format(a.alias,"#######;P0")
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  state_cd = uar_get_code_display(a.state_cd)
  FROM address a
  WHERE (a.parent_entity_id=pers->person_id)
   AND a.parent_entity_name="PERSON"
   AND a.address_type_cd=home_address_cd
   AND a.active_ind=1
  DETAIL
   pers->home_st_addr = a.street_addr, pers->home_st_addr2 = a.street_addr2, pers->home_city = a.city,
   pers->home_state = a.state, pers->home_zip = a.zipcode, pers->home_state_disp = state_cd
   IF (a.state_cd > 0)
    pers->home_csz = concat(trim(a.city),", ",trim(state_cd)," ",trim(a.zipcode))
   ELSE
    pers->home_csz = concat(trim(a.city),", ",trim(a.state)," ",trim(a.zipcode))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  phone = p.phone_num
  FROM phone p
  WHERE (p.parent_entity_id=pers->person_id)
   AND p.parent_entity_name="PERSON"
   AND p.phone_type_cd IN (home_phone_cd, bus_phone_cd, mobile_phone_cd)
   AND p.active_ind=1
  DETAIL
   IF (p.phone_type_cd=home_phone_cd)
    pers->home_phone = phone
   ELSEIF (p.phone_type_cd=bus_phone_cd)
    pers->bus_phone = phone
   ELSEIF (p.phone_type_cd=mobile_phone_cd)
    pers->mobile_phone = phone
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  o.org_name, po.empl_occupation_text, po.empl_title,
  po.empl_retire_dt_tm, empl_status_disp = uar_get_code_display(po.empl_status_cd), state_cd =
  uar_get_code_display(a.state_cd)
  FROM person_org_reltn po,
   organization o,
   phone p,
   address a
  PLAN (po
   WHERE (pers->person_id=po.person_id)
    AND po.person_org_reltn_cd=org_empl_cd
    AND po.end_effective_dt_tm=cnvtdatetime(cnvtdate(12312100),0)
    AND po.active_ind=1)
   JOIN (o
   WHERE po.organization_id=o.organization_id)
   JOIN (a
   WHERE a.parent_entity_id=outerjoin(o.organization_id)
    AND a.parent_entity_name=outerjoin("ORGANIZATION")
    AND a.active_ind=outerjoin(1))
   JOIN (p
   WHERE p.parent_entity_id=outerjoin(o.organization_id)
    AND p.parent_entity_name=outerjoin("ORGANIZATION")
    AND p.phone_type_cd=outerjoin(bus_phone_cd)
    AND p.active_ind=outerjoin(1))
  ORDER BY po.person_id, po.updt_dt_tm DESC
  HEAD po.person_id
   pers->empl_id = o.organization_id, pers->empl_name = o.org_name, pers->empl_occup = po
   .empl_occupation_text,
   pers->empl_sts = empl_status_disp, pers->empl_st_addr = a.street_addr, pers->empl_st_addr2 = a
   .street_addr2
   IF (a.state_cd > 0)
    pers->empl_csz = concat(trim(a.city),", ",trim(state_cd)," ",trim(a.zipcode))
   ELSE
    pers->empl_csz = concat(trim(a.city),", ",trim(a.state)," ",trim(a.zipcode))
   ENDIF
   IF (cnvtalphanum(p.phone_num) != p.phone_num)
    pers->empl_phone = cnvtalphanum(p.phone_num)
   ELSE
    pers->empl_phone = p.phone_num
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  state_cd = uar_get_code_display(a.state_cd), p.name_full_formatted, person_reltn_type_cd =
  uar_get_code_display(e.person_reltn_type_cd),
  person_reltn_cd = uar_get_code_display(e.person_reltn_cd)
  FROM encntr_person_reltn e,
   (dummyt d  WITH seq = value(1)),
   person p,
   address a,
   phone ph
  PLAN (d
   WHERE ( $1 > 0))
   JOIN (e
   WHERE (e.encntr_id= $1)
    AND e.active_ind >= 1
    AND e.person_reltn_type_cd IN (nok_cd, def_guar_cd, pcg_cd, emc_cd)
    AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=outerjoin(e.related_person_id))
   JOIN (a
   WHERE a.parent_entity_id=outerjoin(p.person_id)
    AND a.parent_entity_name=outerjoin("PERSON")
    AND a.address_type_cd=outerjoin(home_address_cd)
    AND a.active_ind=outerjoin(1))
   JOIN (ph
   WHERE ph.parent_entity_id=outerjoin(p.person_id)
    AND ph.parent_entity_name=outerjoin("PERSON")
    AND ph.active_ind=outerjoin(1))
  ORDER BY e.related_person_id
  HEAD REPORT
   cnt = 1, phone = fillstring(20," "), ext = fillstring(8," ")
  HEAD e.related_person_id
   IF (e.person_reltn_type_cd=nok_cd)
    pers->nok[cnt].nok_name = p.name_full_formatted, pers->nok[cnt].nok_reltn = person_reltn_cd, pers
    ->nok[cnt].nok_addr = a.street_addr,
    pers->nok[cnt].nok_addr2 = a.street_addr2
    IF (a.state_cd > 0)
     pers->nok[cnt].nok_csz = concat(trim(a.city),", ",trim(state_cd)," ",trim(a.zipcode))
    ELSE
     pers->nok[cnt].nok_csz = concat(trim(a.city),", ",trim(a.state)," ",trim(a.zipcode))
    ENDIF
   ENDIF
   IF (e.person_reltn_type_cd=def_guar_cd)
    pers->guar_name = p.name_full_formatted, pers->guar_reltn = person_reltn_cd, pers->guar_addr = a
    .street_addr,
    pers->guar_addr2 = a.street_addr2
    IF (a.state_cd > 0)
     pers->guar_csz = concat(trim(a.city),", ",trim(state_cd)," ",trim(a.zipcode))
    ELSE
     pers->guar_csz = concat(trim(a.city),", ",trim(a.state)," ",trim(a.zipcode))
    ENDIF
   ENDIF
   IF (e.person_reltn_type_cd=emc_cd)
    pers->emc_name = p.name_full_formatted, pers->emc_addr = concat(a.street_addr,char(32),a
     .street_addr2)
    IF (a.state_cd > 0)
     pers->emc_csz = concat(trim(a.city),", ",trim(state_cd)," ",trim(a.zipcode))
    ELSE
     pers->emc_csz = concat(trim(a.city),", ",trim(a.state)," ",trim(a.zipcode))
    ENDIF
   ENDIF
   IF (e.person_reltn_type_cd=pcg_cd)
    pers->pcg_name = p.name_full_formatted, pers->pcg_addr = concat(a.street_addr,char(32),a
     .street_addr2)
    IF (a.state_cd > 0)
     pers->pcg_csz = concat(trim(a.city),", ",trim(state_cd)," ",trim(a.zipcode))
    ELSE
     pers->pcg_csz = concat(trim(a.city),", ",trim(a.state)," ",trim(a.zipcode))
    ENDIF
   ENDIF
  DETAIL
   phone = ph.phone_num, ext = substring(1,8,ph.extension)
   IF (e.person_reltn_type_cd=nok_cd)
    IF (ph.phone_type_cd=home_phone_cd)
     pers->nok[cnt].nok_home_ph = phone
    ELSEIF (ph.phone_type_cd=bus_phone_cd)
     pers->nok[cnt].nok_wk_ph = phone, pers->nok[cnt].nok_wk_ext = ext
    ELSEIF (ph.phone_type_cd=mobile_phone_cd)
     pers->nok[cnt].nok_mobile_ph = phone
    ENDIF
   ENDIF
   IF (e.person_reltn_type_cd=def_guar_cd)
    IF (ph.phone_type_cd=home_phone_cd)
     pers->guar_home_ph = phone
    ELSEIF (ph.phone_type_cd=bus_phone_cd)
     pers->guar_wk_ph = phone, pers->guar_wk_ext = ext
    ELSEIF (ph.phone_type_cd=mobile_phone_cd)
     pers->guar_mobile_ph = phone
    ENDIF
   ENDIF
   IF (e.person_reltn_type_cd=emc_cd)
    IF (ph.phone_type_cd=home_phone_cd)
     pers->emc_home_ph = phone
    ELSEIF (ph.phone_type_cd=bus_phone_cd)
     pers->emc_wk_ph = phone, pers->emc_wk_ext = ext
    ELSEIF (ph.phone_type_cd=mobile_phone_cd)
     pers->emc_mobile_ph = phone
    ENDIF
   ENDIF
   IF (e.person_reltn_type_cd=pcg_cd)
    IF (ph.phone_type_cd=home_phone_cd)
     pers->pcg_home_ph = phone
    ELSEIF (ph.phone_type_cd=bus_phone_cd)
     pers->pcg_wk_ph = phone, pers->pcg_wk_ext = ext
    ELSEIF (ph.phone_type_cd=mobile_phone_cd)
     pers->pcg_mobile_ph = phone
    ENDIF
   ENDIF
  FOOT  e.related_person_id
   IF (e.person_reltn_type_cd=nok_cd)
    cnt = (cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  ea.accident_dt_tm, accident_disp = uar_get_code_display(ea.accident_cd), ea.accident_loctn
  FROM encntr_accident ea
  WHERE (ea.encntr_id= $1)
   AND ea.active_ind=1
  DETAIL
   pers->acc_dt = ea.accident_dt_tm, pers->acc_cd = accident_disp, pers->acc_loc = ea.accident_loctn
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  e.encntr_id, e.encntr_plan_reltn_id, e.end_effective_dt_tm,
  e.member_nbr, e.group_nbr, e.person_id,
  e.organization_id, e.active_ind, h.beg_effective_dt_tm,
  h.end_effective_dt_tm, h.plan_name, plan_type_disp = uar_get_code_display(h.plan_type_cd),
  org.org_name, a.street_addr, a.street_addr2,
  a.state, a.city, a.zipcode,
  p.phone_num, code1 = decode(a.seq,1,p.seq,2,3), pe.name_full_formatted,
  pe.birth_dt_tm, sex_cd = uar_get_code_display(pe.sex_cd), pa.alias,
  pa.alias_pool_cd, code1 = decode(a.seq,1,p.seq,2,3), state_cd = uar_get_code_display(a.state_cd)
  FROM encntr_plan_reltn e,
   person pe,
   person_alias pa,
   health_plan h,
   organization org,
   address a,
   phone p
  PLAN (e
   WHERE (e.encntr_id= $1)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pe
   WHERE pe.person_id=e.person_id)
   JOIN (pa
   WHERE pa.person_id=outerjoin(e.person_id)
    AND pa.person_alias_type_cd=outerjoin(ssn_alias_cd)
    AND pa.active_ind=outerjoin(1))
   JOIN (h
   WHERE h.health_plan_id=e.health_plan_id
    AND h.active_ind=1)
   JOIN (org
   WHERE org.organization_id=outerjoin(e.organization_id))
   JOIN (a
   WHERE a.parent_entity_id=outerjoin(e.organization_id)
    AND a.active_ind=outerjoin(1)
    AND a.address_type_cd=outerjoin(bus_address_cd)
    AND a.parent_entity_name=outerjoin("ORGANIZATION"))
   JOIN (p
   WHERE p.parent_entity_id=outerjoin(org.organization_id)
    AND p.active_ind=outerjoin(1)
    AND p.phone_type_cd=outerjoin(bus_phone_cd)
    AND p.parent_entity_name=outerjoin("ORGANIZATION"))
  ORDER BY e.encntr_plan_reltn_id
  HEAD REPORT
   cnt = 1, phone = fillstring(20," ")
  DETAIL
   IF (cnvtalphanum(p.phone_num) != p.phone_num)
    phone = cnvtalphanum(p.phone_num)
   ELSE
    phone = p.phone_num
   ENDIF
   pers->ins[cnt].ins_name = org.org_name, pers->ins[cnt].hp_name = h.plan_name, pers->ins[cnt].
   mbr_nbr = e.member_nbr,
   pers->ins[cnt].grp_nbr = e.group_nbr, pers->ins[cnt].plan_type = plan_type_disp, pers->ins[cnt].
   hp_addr = a.street_addr,
   pers->ins[cnt].hp_addr2 = a.street_addr2
   IF (a.state_cd > 0)
    pers->ins[cnt].hp_csz = concat(trim(a.city),", ",trim(state_cd)," ",trim(a.zipcode))
   ELSE
    pers->ins[cnt].hp_csz = concat(trim(a.city),", ",trim(a.state)," ",trim(a.zipcode))
   ENDIF
   pers->ins[cnt].hp_ph = phone, pers->ins[cnt].sub_name = pe.name_full_formatted, pers->ins[cnt].
   sub_person_id = pe.person_id,
   pers->ins[cnt].sub_dob = pe.birth_dt_tm, pers->ins[cnt].sub_ssn = cnvtalias(pa.alias,pa
    .alias_pool_cd), pers->ins[cnt].sub_sex = sex_cd,
   cnt = (cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  p.prsnl_person_id, p2.name_full_formatted, p.ft_prsnl_name
  FROM encntr_prsnl_reltn p,
   prsnl p2
  PLAN (p
   WHERE (p.encntr_id= $1)
    AND p.encntr_prsnl_r_cd IN (familydoc_cd, primcaredoc_cd, referdoc_cd, attenddoc_cd, admitdoc_cd)
   )
   JOIN (p2
   WHERE p2.person_id=outerjoin(p.prsnl_person_id))
  ORDER BY p.encntr_prsnl_r_cd, p.beg_effective_dt_tm DESC
  HEAD p.encntr_prsnl_r_cd
   IF (p.encntr_prsnl_r_cd=familydoc_cd)
    IF (p.prsnl_person_id > 0)
     pers->familydoc = p2.name_full_formatted
    ELSE
     pers->familydoc = p.ft_prsnl_name
    ENDIF
   ELSEIF (p.encntr_prsnl_r_cd=primcaredoc_cd)
    IF (p.prsnl_person_id > 0)
     pers->primcaredoc = build(p2.name_full_formatted)
    ELSE
     pers->primcaredoc = build(p.ft_prsnl_name)
    ENDIF
   ELSEIF (p.encntr_prsnl_r_cd=referdoc_cd)
    pers->referdoc = p2.name_full_formatted
   ELSEIF (p.encntr_prsnl_r_cd=attenddoc_cd)
    IF (p.prsnl_person_id > 0)
     pers->attenddoc = p2.name_full_formatted
    ELSE
     pers->attenddoc = p.ft_prsnl_name
    ENDIF
   ELSEIF (p.encntr_prsnl_r_cd=admitdoc_cd)
    pers->admitdoc = p2.name_full_formatted
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  o.org_name, po.empl_occupation_text, po.empl_title,
  po.empl_retire_dt_tm, empl_status_disp = uar_get_code_display(po.empl_status_cd), state_cd =
  uar_get_code_display(a.state_cd)
  FROM person_org_reltn po,
   organization o,
   dummyt d,
   address a
  PLAN (d
   WHERE (pers->ins[d.seq].ins_name > "  "))
   JOIN (po
   WHERE (pers->ins[d.seq].sub_person_id=po.person_id)
    AND po.person_org_reltn_cd=org_empl_cd
    AND po.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND po.active_ind=1)
   JOIN (o
   WHERE po.organization_id=o.organization_id)
   JOIN (a
   WHERE a.parent_entity_id=outerjoin(o.organization_id)
    AND a.parent_entity_name=outerjoin("ORGANIZATION")
    AND a.active_ind=outerjoin(1))
  ORDER BY po.person_id, po.updt_dt_tm
  HEAD po.person_id
   pers->ins[d.seq].sub_empl_id = o.organization_id, pers->ins[d.seq].sub_empl_name = o.org_name,
   pers->ins[d.seq].sub_empl_occup = po.empl_occupation_text,
   pers->ins[d.seq].sub_empl_sts = empl_status_disp, pers->ins[d.seq].sub_empl_st_addr = a
   .street_addr, pers->ins[d.seq].sub_empl_st_addr2 = a.street_addr2
   IF (a.state_cd > 0)
    pers->ins[d.seq].sub_empl_csz = concat(trim(a.city),", ",trim(state_cd)," ",trim(a.zipcode))
   ELSE
    pers->ins[d.seq].sub_empl_csz = concat(trim(a.city),", ",trim(a.state)," ",trim(a.zipcode))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  result = substring(1,30,ce.result_val)
  FROM clinical_event ce
  WHERE (ce.person_id=pers->person_id)
   AND (ce.encntr_id=pers->encntr)
   AND ce.event_cd IN (advance_dir_cd, adv_type, adv_proxy, adv_phone, adv_date)
  ORDER BY ce.event_cd, ce.updt_dt_tm DESC, ce.event_end_dt_tm DESC
  HEAD REPORT
   adv_month = "  ", adv_day = "  ", adv_year = "    "
  HEAD ce.event_cd
   IF (ce.event_cd=advance_dir_cd)
    IF (ce.result_val="N*")
     adv_dir_ind = 0
    ELSEIF (ce.result_val="Y*")
     adv_dir_ind = 1
    ENDIF
   ENDIF
   CASE (ce.event_cd)
    OF adv_type:
     pers->adv_type = result
    OF adv_proxy:
     pers->adv_proxy = result
    OF adv_phone:
     pers->adv_phone = result
    OF adv_date:
     adv_year = substring(3,4,result),adv_month = substring(7,2,result),adv_day = substring(9,2,
      result),
     pers->adv_date = concat(trim(adv_month),"/",trim(adv_day),"/",trim(adv_year))
   ENDCASE
  DETAIL
   x = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.user
  FROM dummyt d
  HEAD REPORT
   y = 0, cnt = 0, disp20 = fillstring(20," "),
   line60 = fillstring(138,"-"), sp60 = fillstring(60," "), sp5 = fillstring(5," "),
   lidx = 1, vv = 1, ins_idx = 1,
   nok_idx = 1, enbr_disp = fillstring(20," "), phone_disp = fillstring(20," "),
   phone_disp2 = fillstring(20," "), phone_disp3 = fillstring(20," "), phone_disp4 = fillstring(20,
    " "),
   phone_disp5 = fillstring(20," "), phone_disp6 = fillstring(20," "), phone_disp7 = fillstring(20,
    " "),
   dispab = fillstring(57," "), len = 0, dispcd = fillstring(80," ")
  DETAIL
   g_length = 62, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    rhead,rtab,rtab,rtab,rh2bu,
    "PATIENT INSURANCE & DEMOGRAPHICS",reol,wr),
   lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
   drec->line_qual[lidx].disp_line = concat(rhead,rtab,rtab,rtab,rh2b,
    pers->loc_facility,reol,wr), lidx = (lidx+ 1), row + 1,
   stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp60,reol), lidx
    = (lidx+ 1),
   row + 1, stat = alterlist(drec->line_qual,lidx), enbr_disp = cnvtstring(pers->encntr),
   name_disp = concat(trim(pers->name_full_formatted)), drec->line_qual[lidx].disp_line = concat(sp5,
    "Name: ",name_disp,rtab,"MRN#: ",
    pers->mrn,rtab,"ACCT#: ",pers->fin_nbr,rtab,
    " LOC:",loc_display,reol), lidx = (lidx+ 1),
   row + 1, stat = alterlist(drec->line_qual,lidx), tmp_display1 = concat(format(pers->birth_dt_tm,
     "MM/DD/YYYY;;D")," [",cnvtage(pers->birth_dt_tm),"]")
   IF (textlen(pers->patient_type_cd) > 8)
    drec->line_qual[lidx].disp_line = concat(sp5,"Patient Type: ",pers->patient_type_cd,rtab,rtab,
     rtab,"DOB: ",tmp_display1,reol)
   ELSE
    drec->line_qual[lidx].disp_line = concat(sp5,"Patient Type: ",pers->patient_type_cd,rtab,rtab,
     rtab,rtab,"DOB: ",tmp_display1,reol)
   ENDIF
   lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx)
   IF (textlen(pers->language) > 5)
    drec->line_qual[lidx].disp_line = concat(sp5,"Language Spoken: ",pers->language,rtab,"Sex: ",
     pers->sex_cd,rtab,rtab,"Mar Stat: ",pers->marital_type_cd,
     reol)
   ELSE
    drec->line_qual[lidx].disp_line = concat(sp5,"Language Spoken: ",pers->language,rtab,rtab,
     "Sex: ",pers->sex_cd,rtab,rtab,"Mar Stat: ",
     pers->marital_type_cd,reol)
   ENDIF
   IF ((pers->primcaredoc > ""))
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = concat(sp5,"PCP: ",pers->primcaredoc,reol)
   ENDIF
   lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
   lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
   drec->line_qual[lidx].disp_line = concat(sp5,line60,reol), lidx = (lidx+ 1), row + 1,
   stat = alterlist(drec->line_qual,lidx), tmp_display7 = fillstring(30," "), tmp_display8 =
   fillstring(30," "),
   tmp_display7 = trim(format(pers->arrive_dt_tm,"mm/dd/yyyy hh:mm;;q")), tmp_display8 = format(pers
    ->disch_dt_tm,"mm/dd/yyyy hh:mm;;q")
   IF (tmp_display7 > "")
    drec->line_qual[lidx].disp_line = concat(sp5,"Admit Date: ",tmp_display7,rtab,rtab,
     "Discharge Date: ",tmp_display8,reol)
   ELSE
    drec->line_qual[lidx].disp_line = concat(sp5,"Est Arrive Date: ",est_arrival,rtab,rtab,
     "Discharge Date: ",tmp_display8,reol)
   ENDIF
   lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx)
   IF ((pers->patient_type_cd IN ("In-patient", "Preadmission")))
    drec->line_qual[lidx].disp_line = concat(sp5,"Adm. Diag: ",pers->reason4visit,reol)
   ELSE
    drec->line_qual[lidx].disp_line = concat(sp5,"Reason for visit: ",pers->reason4visit,reol)
   ENDIF
   lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
   tmp_display1 = fillstring(30," "), tmp_display1 = format(pers->acc_dt,"MM/DD/YYYY;;q"), drec->
   line_qual[lidx].disp_line = concat(sp5,"Accident Date: ",tmp_display1,rtab,rtab,
    "Accident Location: ",pers->acc_loc,reol),
   lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
   drec->line_qual[lidx].disp_line = concat(sp5,"Accident Code: ",pers->acc_cd,reol), lidx = (lidx+ 1
   ), row + 1,
   stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,reol), lidx
    = (lidx+ 1),
   row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,
    "Admitting Physician: ",rtab,pers->admitdoc,reol),
   lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
   drec->line_qual[lidx].disp_line = concat(sp5,"Attending Physician: ",rtab,pers->attenddoc,reol),
   lidx = (lidx+ 1), row + 1,
   stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,
    "Referring Physician: ",rtab,pers->referdoc,reol), lidx = (lidx+ 1),
   row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,
    line60,reol),
   lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx)
   IF (adv_dir_ind=1
    AND (pers->adv_type > " "))
    drec->line_qual[lidx].disp_line = concat(sp5,"Advance Directive: ",rtab,pers->adv_type,reol),
    lidx = (lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,"Proxy: ",
     rtab,rtab,pers->adv_proxy,
     reol), lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,
     "Proxy Phone: ",rtab,pers->adv_phone,reol),
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    tmp_display9 = concat(trim(pers->adv_date)), drec->line_qual[lidx].disp_line = concat(sp5,
     "Date Filed: ",rtab,rtab,tmp_display9,
     reol), lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,
     line60,reol),
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx)
   ENDIF
   IF (adv_dir_ind=0)
    drec->line_qual[lidx].disp_line = concat(sp5,"Advance Directive: No",reol), lidx = (lidx+ 1), row
     + 1,
    stat = alterlist(drec->line_qual,lidx)
   ENDIF
   drec->line_qual[lidx].disp_line = concat(sp5,"Patient Address:",rtab,pers->home_st_addr," ",
    pers->home_st_addr2,reol), lidx = (lidx+ 1), row + 1,
   stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,rtab,rtab,
    pers->home_csz,reol), lidx = (lidx+ 1),
   row + 1, stat = alterlist(drec->line_qual,lidx)
   IF ((pers->bus_phone > " "))
    phone_disp = pers->home_phone, phone_disp2 = pers->bus_phone, drec->line_qual[lidx].disp_line =
    concat(sp5,rtab,rtab,"Home Phone: ",phone_disp,
     rtab,"Bus: ",phone_disp2,reol),
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx)
   ELSE
    phone_disp = pers->home_phone, drec->line_qual[lidx].disp_line = concat(sp5,rtab,rtab,
     "Home Phone: ",phone_disp,
     reol), lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx)
   ENDIF
   IF ((pers->mobile_phone > " "))
    phone_disp = trim(pers->mobile_phone), drec->line_qual[lidx].disp_line = concat(sp5,rtab,rtab,
     "Mobile Phone: ",phone_disp,
     reol), lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx)
   ENDIF
   CALL echo(build("pers->MOBILE_PHONE:",pers->mobile_phone)),
   CALL echo(build("PHONE_DISP:",phone_disp)),
   CALL echo(build("drec:",drec->line_qual[(lidx - 1)].disp_line)),
   drec->line_qual[lidx].disp_line = concat(sp5,reol), lidx = (lidx+ 1), row + 1,
   stat = alterlist(drec->line_qual,lidx)
   IF ((pers->emc_name > " "))
    drec->line_qual[lidx].disp_line = concat(sp5,"Emergency Contact: ",rtab,pers->emc_name,reol),
    lidx = (lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,rtab,rtab,
     pers->emc_addr,reol), lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,
     rtab,rtab,pers->emc_csz,reol),
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx)
    IF ((pers->emc_wk_ph > " "))
     phone_disp6 = pers->emc_home_ph, phone_disp7 = pers->emc_wk_ph, drec->line_qual[lidx].disp_line
      = concat(sp5,rtab,rtab,"Home Phone: ",phone_disp6,
      rtab,"Bus: ",phone_disp7,reol),
     lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx)
    ELSE
     phone_disp6 = pers->emc_home_ph, drec->line_qual[lidx].disp_line = concat(sp5,rtab,rtab,
      "Home Phone: ",phone_disp7,
      reol), lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx)
    ENDIF
    IF ((pers->emc_mobile_ph > " "))
     phone_disp6 = pers->emc_mobile_ph, drec->line_qual[lidx].disp_line = concat(sp5,rtab,rtab,
      "Mobile Phone: ",phone_disp6,
      reol), lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx)
    ENDIF
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = concat(sp5,reol), lidx = (lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx)
   ENDIF
   IF ((pers->pcg_name > " "))
    drec->line_qual[lidx].disp_line = concat(sp5,"Primary Caregiver: ",rtab,pers->pcg_name,reol),
    lidx = (lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,rtab,rtab,
     pers->pcg_addr,reol), lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,
     rtab,rtab,pers->pcg_csz,reol),
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx)
    IF ((pers->pcg_wk_ph > " "))
     phone_disp6 = pers->pcg_home_ph, phone_disp7 = pers->pcg_wk_ph, drec->line_qual[lidx].disp_line
      = concat(sp5,rtab,rtab,"Home Phone: ",phone_disp6,
      rtab,"Bus: ",phone_disp7,reol),
     lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx)
    ELSE
     phone_disp6 = pers->pcg_home_ph, drec->line_qual[lidx].disp_line = concat(sp5,rtab,rtab,
      "Home Phone: ",phone_disp7,
      reol), lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx)
    ENDIF
    IF ((pers->pcg_mobile_ph > " "))
     phone_disp6 = pers->pcg_mobile_ph, drec->line_qual[lidx].disp_line = concat(sp5,rtab,rtab,
      "Mobile Phone: ",phone_disp6,
      reol), lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx)
    ENDIF
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx)
   ENDIF
   IF ((pers->guar_name > " "))
    drec->line_qual[lidx].disp_line = concat(sp5,"Guarantor:  ",rtab,pers->guar_name,reol), lidx = (
    lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,rtab,rtab,
     pers->guar_addr," ",
     pers->guar_addr2,reol), lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), tmp_display1 = format(pers->acc_dt,
     "MM/DD/YYYY;;D"),
    drec->line_qual[lidx].disp_line = concat(sp5,rtab,rtab,pers->guar_csz,reol), lidx = (lidx+ 1),
    row + 1,
    stat = alterlist(drec->line_qual,lidx)
    IF ((pers->guar_wk_ph > " "))
     phone_disp5 = pers->guar_home_ph, phone_disp6 = pers->guar_wk_ph, drec->line_qual[lidx].
     disp_line = concat(sp5,rtab,rtab,"Home Phone: ",phone_disp5,
      rtab,"Bus: ",phone_disp6,reol),
     lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx)
    ELSE
     phone_disp5 = pers->guar_home_ph, drec->line_qual[lidx].disp_line = concat(sp5,rtab,rtab,
      "Home Phone: ",phone_disp5,
      reol), lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx)
    ENDIF
    IF ((pers->guar_mobile_ph > " "))
     phone_disp5 = pers->guar_mobile_ph, drec->line_qual[lidx].disp_line = concat(sp5,rtab,rtab,
      "Mobile Phone: ",phone_disp5,
      reol), lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx)
    ENDIF
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx)
   ENDIF
   FOR (nok_idx = 1 TO 2)
     IF ((pers->nok[nok_idx].nok_name > " "))
      drec->line_qual[lidx].disp_line = concat(sp5,reol), lidx = (lidx+ 1), row + 1,
      stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,"NOK:",
       rtab,rtab,pers->nok[nok_idx].nok_name,
       "  ",pers->nok[nok_idx].nok_reltn,reol), lidx = (lidx+ 1),
      row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,
       rtab,rtab,pers->nok[nok_idx].nok_addr," ",
       pers->nok[nok_idx].nok_addr2,reol),
      lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
      drec->line_qual[lidx].disp_line = concat(sp5,rtab,rtab,pers->nok[nok_idx].nok_csz,reol), lidx
       = (lidx+ 1), row + 1,
      stat = alterlist(drec->line_qual,lidx)
      IF ((pers->nok[nok_idx].nok_wk_ph > " "))
       phone_disp3 = pers->nok[nok_idx].nok_home_ph, phone_disp4 = pers->nok[nok_idx].nok_wk_ph, drec
       ->line_qual[lidx].disp_line = concat(sp5,rtab,rtab,"Home Phone: ",phone_disp3,
        rtab,"Bus: ",phone_disp4,reol),
       lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx)
      ELSE
       phone_disp3 = pers->nok[nok_idx].nok_home_ph, drec->line_qual[lidx].disp_line = concat(sp5,
        rtab,rtab,"Home Phone: ",phone_disp3,
        reol), lidx = (lidx+ 1),
       row + 1, stat = alterlist(drec->line_qual,lidx)
      ENDIF
      IF ((pers->nok[nok_idx].nok_mobile_ph > " "))
       phone_disp3 = pers->nok[nok_idx].nok_mobile_ph, drec->line_qual[lidx].disp_line = concat(sp5,
        rtab,rtab,"Mobile Phone: ",phone_disp3,
        reol), lidx = (lidx+ 1),
       row + 1, stat = alterlist(drec->line_qual,lidx)
      ENDIF
      lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx)
     ENDIF
   ENDFOR
   lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
   drec->line_qual[lidx].disp_line = concat(sp5,line60,reol), lidx = (lidx+ 1), row + 1,
   stat = alterlist(drec->line_qual,lidx), temp_disp_emp = fillstring(30," "), temp_disp_emp = concat
   (substring(1,30,pers->empl_name)),
   drec->line_qual[lidx].disp_line = concat(sp5,"Employer: ",rtab,temp_disp_emp,rtab,
    "Occupation: ",rtab,pers->empl_occup,reol), lidx = (lidx+ 1), row + 1,
   stat = alterlist(drec->line_qual,lidx)
   IF ((pers->empl_name > " "))
    drec->line_qual[lidx].disp_line = concat(sp5,rtab,pers->empl_st_addr,rtab,pers->empl_st_addr2,
     reol), lidx = (lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,rtab,pers->
     empl_csz,reol), lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp60,
     reol)
   ENDIF
   lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx)
   FOR (ins_idx = 1 TO 5)
     IF ((pers->ins[ins_idx].ins_name > "  "))
      drec->line_qual[lidx].disp_line = concat(sp5,line60,reol), lidx = (lidx+ 1), row + 1,
      stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,
       "Insurance: ",rtab,pers->ins[ins_idx].ins_name,"  /  ",
       pers->ins[ins_idx].hp_name,"  /   ",pers->ins[ins_idx].plan_type,reol), lidx = (lidx+ 1),
      row + 1, stat = alterlist(drec->line_qual,lidx)
      IF ((pers->ins[ins_idx].hp_addr > " "))
       drec->line_qual[lidx].disp_line = concat(sp5,rtab,pers->ins[ins_idx].hp_addr," ",pers->ins[
        ins_idx].hp_addr2,
        reol), lidx = (lidx+ 1), row + 1,
       stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,rtab,pers
        ->ins[ins_idx].hp_csz,reol), lidx = (lidx+ 1),
       row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,
        rtab,cnvtphone(pers->ins[ins_idx].hp_ph,874),rtab,rtab,
        rtab,reol),
       lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
       drec->line_qual[lidx].disp_line = concat(sp60,reol), lidx = (lidx+ 1), row + 1,
       stat = alterlist(drec->line_qual,lidx)
      ENDIF
      tmp_subscriber_disp = fillstring(30," "), tmp_subscriber_disp = concat(trim(pers->ins[ins_idx].
        sub_name)), tmp_contract_disp = fillstring(30," "),
      tmp_contract_disp = concat(trim(pers->ins[ins_idx].mbr_nbr)), tmp_group_disp = fillstring(30,
       " "), tmp_group_disp = concat(trim(pers->ins[ins_idx].grp_nbr)),
      tmp_occupation_disp = fillstring(30," "), tmp_occupation_disp = concat(trim(pers->ins[ins_idx].
        sub_empl_occup)), tmp_ssn_disp = fillstring(30," "),
      tmp_ssn_disp = concat(trim(pers->ins[ins_idx].sub_ssn)), tmp_dob_disp = fillstring(30," "),
      tmp_dob_disp = format(pers->ins[ins_idx].sub_dob,"MM/DD/YYYY;;D"),
      drec->line_qual[lidx].disp_line = concat(sp5,"Contract#: ",rtab,rtab,tmp_contract_disp,
       rtab,rtab,"Group: ",tmp_group_disp,reol), lidx = (lidx+ 1), row + 1,
      stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,
       "Subscriber: ",rtab,tmp_subscriber_disp,rtab,
       rtab,"Sub SSN: ",tmp_ssn_disp,reol), lidx = (lidx+ 1),
      row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,
       "Sub DOB: ",rtab,rtab,tmp_dob_disp,
       rtab,rtab,"Sub Sex: ",pers->ins[ins_idx].sub_sex,reol),
      lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
      emp_disp = concat(trim(pers->ins[ins_idx].sub_empl_name)), drec->line_qual[lidx].disp_line =
      concat(sp5,"Sub Employer: ",rtab,emp_disp,reol), lidx = (lidx+ 1),
      row + 1, stat = alterlist(drec->line_qual,lidx)
      IF (emp_disp > " ")
       drec->line_qual[lidx].disp_line = concat(sp5,rtab,rtab,pers->ins[ins_idx].sub_empl_st_addr," ",
        pers->ins[ins_idx].sub_empl_st_addr2,reol), lidx = (lidx+ 1), row + 1,
       stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(sp5,rtab,rtab,
        pers->ins[ins_idx].sub_empl_csz,reol), lidx = (lidx+ 1),
       row + 1, stat = alterlist(drec->line_qual,lidx), enbr_disp = cnvtstring(pers->ins[ins_idx].
        sub_person_id)
      ENDIF
      drec->line_qual[lidx].disp_line = concat(sp5,"Sub Occupation:",rtab,tmp_occupation_disp,"/",
       pers->ins[ins_idx].sub_empl_sts,reol), lidx = (lidx+ 1), row + 1,
      stat = alterlist(drec->line_qual,lidx)
     ENDIF
   ENDFOR
  FOOT REPORT
   lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
   drec->line_qual[lidx].disp_line = concat(sp5,reol), lidx = (lidx+ 1), row + 1,
   stat = alterlist(drec->line_qual,lidx)
  WITH nocounter, maxcol = 500, maxrow = 800
 ;end select
#end_prog
 FREE RECORD pers
END GO

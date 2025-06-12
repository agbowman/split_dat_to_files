CREATE PROGRAM bhs_ma_genview_case_mgmt:dba
 DECLARE ssn_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4,"SSN")), protect
 DECLARE mrn_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"MRN")), protect
 DECLARE emc_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",351,"EMERGENCYCONTACT")), protect
 DECLARE nok_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",351,"NEXTOFKIN")), protect
 DECLARE insured_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",351,"INSURED")), protect
 DECLARE employer_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",338,"EMPLOYER")), protect
 DECLARE insurance_co_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",338,"INSURANCECOMPANY")),
 protect
 DECLARE fin_nbr_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE home_ph_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",43,"HOME")), protect
 DECLARE business_ph_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",43,"BUSINESS")), protect
 DECLARE cell_ph_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",43,"CELL")), protect
 DECLARE home_ad_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",212,"HOME")), protect
 DECLARE bus_ad_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",212,"BUSINESS")), protect
 DECLARE diagtype = f8
 SET stat = uar_get_meaning_by_codeset(17,"ADMIT",1,diagtype)
 SET rhead = "{\rtf1\ansi\ansicpg1252\deff0\deflang2057{\fonttbl{\f0\fswiss\fcharset0 Arial;}}"
 SET rh2r = "\PLAIN \F0 \FS18 \CB2 \PARD\SL0 "
 SET rh2b = "\PLAIN \F0 \FS18 \B \CB2 \PARD\SL0 "
 SET rh2bu = "\PLAIN \F0 \FS18 \B \UL \CB2 \PARD\SL0 "
 SET rh2u = "\PLAIN \F0 \FS18 \UL \CB2 \PARD\SL0 "
 SET rh2i = "\PLAIN \F0 \FS18 \I \CB2 \PARD\SL0 "
 SET reol = "\PAR "
 SET rtab = "\TAB "
 SET wr = " \PLAIN \F0 \FS18 \CB2 "
 SET wb = " \PLAIN \F0 \FS18 \B \CB2 "
 SET wu = " \PLAIN \F0 \FS18 \UL \CB2 "
 SET wbu = " \PLAIN \F0 \FS18 \B \UL \CB2 "
 SET wi = " \PLAIN \F0 \FS18 \I \CB2 "
 SET wbi = " \PLAIN \F0 \FS18 \B \I \CB2 "
 SET wbiu = " \PLAIN \F0 \FS18 \B \I \UL \CB2 "
 SET rtfeof = "}}"
 SET x = 1
 SET lidx = 0
 IF ( NOT (validate(caseinfo,0)))
  RECORD caseinfo(
    1 patient_name = vc
    1 birth_dt_cd = i2
    1 birth_dt_tm = dq8
    1 sex_cd = vc
    1 marital_type_cd = vc
    1 arrive_dt_tm = dq8
    1 reason4visit = vc
    1 ssn = vc
    1 person_id = f8
    1 visit_cnt = i4
    1 encntr = f8
    1 home_st_addr = vc
    1 home_st_addr2 = vc
    1 home_city = vc
    1 home_state = vc
    1 home_zip = vc
    1 home_csz = vc
    1 home_state_disp = vc
    1 home_phone = vc
    1 bus_phone = vc
    1 cell_phone = vc
    1 language = vc
    1 emc_name = vc
    1 emc_addr = vc
    1 emc_csz = vc
    1 emc_home_ph = vc
    1 emc_wk_ph = vc
    1 emc_wk_ext = vc
    1 emc_cell_ph = vc
    1 emc_reltn = vc
    1 nok[2]
      2 nok_name = vc
      2 nok_reltn = vc
      2 nok_addr = vc
      2 nok_addr2 = vc
      2 nok_csz = vc
      2 nok_home_ph = vc
      2 nok_wk_ph = vc
      2 nok_wk_ext = vc
      2 nok_cell_ph = vc
    1 ins[2]
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
  )
  SET caseinfo->visit_cnt = 1
 ENDIF
 RECORD dlrec(
   1 line_cnt = i4
   1 line_qual[*]
     2 disp_line = vc
 )
 IF (validate(reply->text,"A")="A"
  AND validate(reply->text,"Z")="Z")
  RECORD reply(
    1 text = vc
  )
 ENDIF
 IF (validate(request->visit[x].encntr_id,0.00) <= 0.00)
  RECORD request(
    1 visit[x]
      2 encntr_id = f8
  )
  SET request->visit[x].encntr_id = 31573351
 ENDIF
 EXECUTE cclseclogin
 SELECT INTO "NL:"
  e.person_id, e.encntr_id, e.arrive_dt_tm,
  p.sex_cd, e.reason_for_visit, p.name_full_formatted,
  p.birth_dt_tm, p.marital_type_cd, p.language_cd,
  lang = uar_get_code_display(p.language_cd)
  FROM encounter e,
   person p
  PLAN (e
   WHERE (e.encntr_id=request->visit[x].encntr_id))
   JOIN (p
   WHERE e.person_id=p.person_id)
  DETAIL
   caseinfo->patient_name = p.name_full_formatted, caseinfo->person_id = e.person_id, caseinfo->
   arrive_dt_tm = e.arrive_dt_tm,
   caseinfo->birth_dt_tm = cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1), caseinfo->
   marital_type_cd = uar_get_code_display(p.marital_type_cd), caseinfo->sex_cd = uar_get_code_display
   (p.sex_cd),
   caseinfo->reason4visit = substring(1,80,e.reason_for_visit), caseinfo->encntr = request->visit[x].
   encntr_id
   IF (p.language_cd=0)
    caseinfo->language = "UNKNOWN"
   ELSE
    caseinfo->language = lang
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  a.street_addr, a.street_addr2, a.city,
  a.state, a.zipcode, state_var = uar_get_code_display(a.state_cd)
  FROM address a
  WHERE (a.parent_entity_id=caseinfo->person_id)
   AND a.parent_entity_name="PERSON"
   AND a.address_type_cd=home_ad_var
   AND a.active_ind=1
  DETAIL
   caseinfo->home_st_addr = a.street_addr, caseinfo->home_st_addr2 = a.street_addr2, caseinfo->
   home_city = a.city,
   caseinfo->home_state = a.state, caseinfo->home_zip = a.zipcode, caseinfo->home_state_disp =
   state_var
   IF (a.state_cd > 0)
    caseinfo->home_csz = concat(trim(a.city),", ",trim(state_var)," ",trim(a.zipcode))
   ELSE
    caseinfo->home_csz = concat(trim(a.city),", ",trim(a.state)," ",trim(a.zipcode))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  phone_var = p.phone_num
  FROM phone p
  WHERE (p.parent_entity_id=caseinfo->person_id)
   AND p.parent_entity_name="PERSON"
   AND p.phone_type_cd IN (home_ph_var, business_ph_var, cell_ph_var)
   AND p.active_ind=1
  DETAIL
   IF (p.phone_type_cd=home_ph_var)
    caseinfo->home_phone = phone_var
   ELSEIF (p.phone_type_cd=business_ph_var)
    caseinfo->bus_phone = phone_var
   ELSEIF (p.phone_type_cd=cell_ph_var)
    caseinfo->cell_phone = phone_var
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM person_alias pa
  WHERE (pa.person_id=caseinfo->person_id)
   AND pa.person_alias_type_cd=ssn_var
   AND pa.active_ind=1
  DETAIL
   caseinfo->ssn = cnvtalias(pa.alias,pa.alias_pool_cd)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  state_var = uar_get_code_display(a.state_cd), p.name_full_formatted, person_reltn_type_var =
  uar_get_code_display(e.person_reltn_type_cd),
  person_reltn_var = uar_get_code_display(e.person_reltn_cd), a.street_addr, a.street_addr2,
  a.city, a.state, a.zipcode
  FROM encntr_person_reltn e,
   (dummyt d  WITH seq = value(1)),
   person p,
   address a,
   phone ph
  PLAN (d
   WHERE (request->visit[x].encntr_id > 0))
   JOIN (e
   WHERE (e.encntr_id=request->visit[x].encntr_id)
    AND e.active_ind >= 1
    AND e.person_reltn_type_cd IN (nok_var, emc_var)
    AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND e.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (p
   WHERE (p.person_id= Outerjoin(e.related_person_id)) )
   JOIN (a
   WHERE (a.parent_entity_id= Outerjoin(p.person_id))
    AND (a.parent_entity_name= Outerjoin("PERSON"))
    AND (a.address_type_cd= Outerjoin(home_ad_var))
    AND (a.active_ind= Outerjoin(1)) )
   JOIN (ph
   WHERE (ph.parent_entity_id= Outerjoin(p.person_id))
    AND (ph.parent_entity_name= Outerjoin("PERSON"))
    AND (ph.active_ind= Outerjoin(1)) )
  ORDER BY e.related_person_id
  HEAD REPORT
   cnt = 0, phone_var = fillstring(20," "), ext_var = fillstring(8," ")
  HEAD e.related_person_id
   IF (e.person_reltn_type_cd=nok_var
    AND cnt <= 2)
    cnt += 1, caseinfo->nok[cnt].nok_name = p.name_full_formatted, caseinfo->nok[cnt].nok_reltn =
    person_reltn_var,
    caseinfo->nok[cnt].nok_addr = a.street_addr, caseinfo->nok[cnt].nok_addr2 = a.street_addr2
    IF (a.state_cd > 0)
     caseinfo->nok[cnt].nok_csz = concat(trim(a.city),", ",trim(state_var)," ",trim(a.zipcode))
    ELSE
     caseinfo->nok[cnt].nok_csz = concat(trim(a.city),", ",trim(a.state)," ",trim(a.zipcode))
    ENDIF
   ENDIF
   IF (e.person_reltn_type_cd=emc_var)
    caseinfo->emc_name = p.name_full_formatted, caseinfo->emc_reltn = person_reltn_var, caseinfo->
    emc_addr = concat(a.street_addr,char(32),a.street_addr2)
    IF (a.state_cd > 0)
     caseinfo->emc_csz = concat(trim(a.city),", ",trim(state_var)," ",trim(a.zipcode))
    ELSE
     caseinfo->emc_csz = concat(trim(a.city),", ",trim(a.state)," ",trim(a.zipcode))
    ENDIF
   ENDIF
  DETAIL
   phone_var = fillstring(20," "), ext_var = fillstring(8," "), phone_var = ph.phone_num,
   ext_var = substring(1,8,ph.extension)
   IF (e.person_reltn_type_cd=nok_var
    AND cnt <= 2)
    IF (ph.phone_type_cd=home_ph_var
     AND trim(caseinfo->nok[cnt].nok_home_ph) <= " ")
     caseinfo->nok[cnt].nok_home_ph = phone_var
    ELSEIF (ph.phone_type_cd=business_ph_var
     AND trim(caseinfo->nok[cnt].nok_wk_ph) <= " ")
     caseinfo->nok[cnt].nok_wk_ph = phone_var, caseinfo->nok[cnt].nok_wk_ext = ext_var
    ELSEIF (ph.phone_type_cd=cell_ph_var
     AND trim(caseinfo->nok[cnt].nok_cell_ph) <= " ")
     caseinfo->nok[cnt].nok_cell_ph = phone_var
    ENDIF
   ENDIF
   IF (e.person_reltn_type_cd=emc_var)
    IF (ph.phone_type_cd=home_ph_var
     AND trim(caseinfo->emc_home_ph) <= " ")
     caseinfo->emc_home_ph = phone_var
    ELSEIF (ph.phone_type_cd=business_ph_var
     AND trim(caseinfo->emc_wk_ph) <= " ")
     caseinfo->emc_wk_ph = phone_var, caseinfo->emc_wk_ext = ext_var
    ELSEIF (ph.phone_type_cd=cell_ph_var
     AND trim(caseinfo->emc_cell_ph) <= " ")
     caseinfo->emc_cell_ph = phone_var
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  e.encntr_id, e.encntr_plan_reltn_id, e.end_effective_dt_tm,
  e.member_nbr, e.group_nbr, e.person_id,
  e.organization_id, e.active_ind, h.beg_effective_dt_tm,
  h.end_effective_dt_tm, h.plan_name, plan_type_disp_var = uar_get_code_display(h.plan_type_cd),
  org.org_name, a.street_addr, a.street_addr2,
  a.state, a.city, a.zipcode,
  p.phone_num, pe.name_full_formatted, pe.birth_dt_tm,
  sex_var = uar_get_code_display(pe.sex_cd), pa.alias, pa.alias_pool_cd,
  state_var = uar_get_code_display(a.state_cd)
  FROM encntr_plan_reltn e,
   person pe,
   person_alias pa,
   health_plan h,
   organization org,
   address a,
   phone p
  PLAN (e
   WHERE (e.encntr_id=request->visit[x].encntr_id)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pe
   WHERE pe.person_id=e.person_id)
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(e.person_id))
    AND (pa.person_alias_type_cd= Outerjoin(ssn_var))
    AND (pa.active_ind= Outerjoin(1)) )
   JOIN (h
   WHERE h.health_plan_id=e.health_plan_id
    AND h.active_ind=1)
   JOIN (org
   WHERE (org.organization_id= Outerjoin(e.organization_id)) )
   JOIN (a
   WHERE (a.parent_entity_id= Outerjoin(e.organization_id))
    AND (a.active_ind= Outerjoin(1))
    AND (a.address_type_cd= Outerjoin(bus_ad_var))
    AND (a.parent_entity_name= Outerjoin("ORGANIZATION")) )
   JOIN (p
   WHERE (p.parent_entity_id= Outerjoin(org.organization_id))
    AND (p.active_ind= Outerjoin(1))
    AND (p.phone_type_cd= Outerjoin(business_ph_var))
    AND (p.parent_entity_name= Outerjoin("ORGANIZATION")) )
  ORDER BY e.encntr_plan_reltn_id
  HEAD REPORT
   cnt = 1, phone_var = fillstring(20," ")
  DETAIL
   IF (cnt <= 3)
    phone_var = p.phone_num, caseinfo->ins[cnt].ins_name = org.org_name, caseinfo->ins[cnt].hp_name
     = h.plan_name,
    caseinfo->ins[cnt].mbr_nbr = e.member_nbr, caseinfo->ins[cnt].grp_nbr = e.group_nbr, caseinfo->
    ins[cnt].plan_type = plan_type_disp_var,
    caseinfo->ins[cnt].hp_addr = a.street_addr, caseinfo->ins[cnt].hp_addr2 = a.street_addr2
    IF (a.state_cd > 0)
     caseinfo->ins[cnt].hp_csz = concat(trim(a.city),", ",trim(state_var)," ",trim(a.zipcode))
    ELSE
     caseinfo->ins[cnt].hp_csz = concat(trim(a.city),", ",trim(a.state)," ",trim(a.zipcode))
    ENDIF
    caseinfo->ins[cnt].hp_ph = phone_var, caseinfo->ins[cnt].sub_name = pe.name_full_formatted,
    caseinfo->ins[cnt].sub_person_id = pe.person_id,
    caseinfo->ins[cnt].sub_dob = cnvtdatetimeutc(datetimezone(pe.birth_dt_tm,pe.birth_tz),1),
    caseinfo->ins[cnt].sub_ssn = cnvtalias(pa.alias,pa.alias_pool_cd)
   ENDIF
   cnt += 1
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM dummyt d
  HEAD REPORT
   print_flag = 0, y = 0, cnt = 0,
   disp20 = fillstring(20," "), line60 = fillstring(180,"-"), sp60 = fillstring(60," "),
   sp5 = fillstring(5," "), lidx = 1, ins_idx = 1,
   nok_idx = 1, phone_disp = fillstring(20," "), phone_disp1 = fillstring(20," "),
   phone_disp2 = fillstring(20," "), phone_disp3 = fillstring(20," "), phone_disp4 = fillstring(20,
    " "),
   phone_disp5 = fillstring(20," "), len = 0
  DETAIL
   stat = alterlist(dlrec->line_qual,lidx), dlrec->line_qual[lidx].disp_line = concat(rhead,rtab,rtab,
    rtab,rh2bu,
    "PATIENT CASE MANAGEMENT INFORMATION",wr," (-- ",rh2i,"Unofficial Copy",
    wr," --)",reol), lidx += 1,
   row + 1, stat = alterlist(dlrec->line_qual,lidx), dlrec->line_qual[lidx].disp_line = concat(sp60,
    reol),
   lidx += 1, row + 1, stat = alterlist(dlrec->line_qual,lidx),
   dlrec->line_qual[lidx].disp_line = concat(sp5,wb,"PATIENT NAME: ",wr,caseinfo->patient_name,
    reol), lidx += 1, row + 1,
   stat = alterlist(dlrec->line_qual,lidx), dob_display = concat(format(caseinfo->birth_dt_tm,
     "MM/DD/YYYY;;D"),"  [ ",cnvtage(caseinfo->birth_dt_tm),"]"), dlrec->line_qual[lidx].disp_line =
   concat(sp5,wb,"DOB: ",wr,dob_display,
    rtab,wb,"Sex: ",wr,caseinfo->sex_cd,
    rtab,wb,"Marital Status: ",wr,caseinfo->marital_type_cd,
    rtab,rtab,wb,"Language Spoken: ",wr,
    caseinfo->language,reol),
   lidx += 1, row + 1, stat = alterlist(dlrec->line_qual,lidx),
   tmp_display2 = fillstring(30," "), tmp_display2 = trim(format(caseinfo->arrive_dt_tm,
     "MM/DD/YYYY HH:MM;;Q"))
   IF (tmp_display2 > "")
    dlrec->line_qual[lidx].disp_line = concat(sp5,wb,"ADMIT DATE: ",wr,tmp_display2,
     rtab,wb,"REASON FOR VISIT: ",wr,caseinfo->reason4visit,
     reol)
   ELSE
    dlrec->line_qual[lidx].disp_line = concat(sp5,wb,"REASON FOR VISIT: ",wr,caseinfo->reason4visit,
     reol)
   ENDIF
   lidx += 1, row + 1, stat = alterlist(dlrec->line_qual,lidx),
   dlrec->line_qual[lidx].disp_line = concat(sp5,wb,"PATIENT ADDRESS: ",wr,rtab,
    caseinfo->home_st_addr," ",caseinfo->home_st_addr2,",  ",caseinfo->home_csz,
    reol), lidx += 1, row + 1,
   stat = alterlist(dlrec->line_qual,lidx), dlrec->line_qual[lidx].disp_line = concat(sp5,wb,
    "Home Phone: ",wr)
   IF (trim(caseinfo->home_phone,4) > " ")
    dlrec->line_qual[lidx].disp_line = concat(dlrec->line_qual[lidx].disp_line,caseinfo->home_phone)
   ENDIF
   dlrec->line_qual[lidx].disp_line = concat(dlrec->line_qual[lidx].disp_line,rtab,wb,"Work Phone: ",
    wr)
   IF (trim(caseinfo->bus_phone,4) > " ")
    dlrec->line_qual[lidx].disp_line = concat(dlrec->line_qual[lidx].disp_line,caseinfo->bus_phone)
   ENDIF
   dlrec->line_qual[lidx].disp_line = concat(dlrec->line_qual[lidx].disp_line,rtab,wb,"Cell Phone: ",
    wr)
   IF (trim(caseinfo->cell_phone,4) > " ")
    dlrec->line_qual[lidx].disp_line = concat(dlrec->line_qual[lidx].disp_line,caseinfo->cell_phone)
   ENDIF
   dlrec->line_qual[lidx].disp_line = concat(dlrec->line_qual[lidx].disp_line,reol), lidx += 1, row
    + 1,
   stat = alterlist(dlrec->line_qual,lidx), dlrec->line_qual[lidx].disp_line = concat(sp60,reol),
   lidx += 1,
   stat = alterlist(dlrec->line_qual,lidx), dlrec->line_qual[lidx].disp_line = concat(sp5,line60,wr,
    reol)
   IF ((caseinfo->emc_name > " "))
    lidx += 1, row + 1, stat = alterlist(dlrec->line_qual,lidx),
    dlrec->line_qual[lidx].disp_line = concat(sp5,wb,"PRIMARY CONTACT:       ",wr,caseinfo->emc_name,
     rtab,wb,"Relation to Pt: ",wr,caseinfo->emc_reltn,
     reol), lidx += 1, row + 1,
    stat = alterlist(dlrec->line_qual,lidx), dlrec->line_qual[lidx].disp_line = concat(sp5,rtab,rtab,
     caseinfo->emc_addr,",  ",
     caseinfo->emc_csz,reol), lidx += 1,
    row + 1, stat = alterlist(dlrec->line_qual,lidx), dlrec->line_qual[lidx].disp_line = concat(sp5,
     rtab,rtab,wb,"Home Phone: ",
     wr)
    IF (trim(caseinfo->emc_home_ph,4) > " ")
     dlrec->line_qual[lidx].disp_line = concat(dlrec->line_qual[lidx].disp_line,caseinfo->emc_home_ph
      )
    ENDIF
    dlrec->line_qual[lidx].disp_line = concat(dlrec->line_qual[lidx].disp_line,rtab,wb,"Work Phone: ",
     wr)
    IF (trim(caseinfo->emc_wk_ph,4) > " ")
     dlrec->line_qual[lidx].disp_line = concat(dlrec->line_qual[lidx].disp_line,caseinfo->emc_wk_ph)
    ENDIF
    dlrec->line_qual[lidx].disp_line = concat(dlrec->line_qual[lidx].disp_line,rtab,wb,"Cell Phone: ",
     wr)
    IF (trim(caseinfo->emc_cell_ph,4) > " ")
     dlrec->line_qual[lidx].disp_line = concat(dlrec->line_qual[lidx].disp_line,caseinfo->emc_cell_ph
      )
    ENDIF
    dlrec->line_qual[lidx].disp_line = concat(dlrec->line_qual[lidx].disp_line,reol)
   ENDIF
   lidx += 1, row + 1, stat = alterlist(dlrec->line_qual,lidx),
   dlrec->line_qual[lidx].disp_line = concat(sp60,reol), lidx += 1, row + 1,
   stat = alterlist(dlrec->line_qual,lidx), dlrec->line_qual[lidx].disp_line = concat(sp5,line60,wr,
    reol)
   FOR (nok_idx = 1 TO 2)
     IF ((caseinfo->nok[nok_idx].nok_name > " "))
      lidx += 1, row + 1, stat = alterlist(dlrec->line_qual,lidx),
      dlrec->line_qual[lidx].disp_line = concat(sp5,wb,"SECONDARY CONTACT: ",wr,caseinfo->nok[nok_idx
       ].nok_name,
       rtab,wb,"Relation to Pt: ",wr,caseinfo->nok[nok_idx].nok_reltn,
       reol), lidx += 1, row + 1,
      stat = alterlist(dlrec->line_qual,lidx), dlrec->line_qual[lidx].disp_line = concat(sp5,rtab,
       rtab,caseinfo->nok[nok_idx].nok_addr," ",
       caseinfo->nok[nok_idx].nok_addr2,",  ",caseinfo->nok[nok_idx].nok_csz,reol), lidx += 1,
      row + 1, stat = alterlist(dlrec->line_qual,lidx), dlrec->line_qual[lidx].disp_line = concat(sp5,
       rtab,rtab,wb,"Home Phone: ",
       wr)
      IF (trim(caseinfo->nok[nok_idx].nok_home_ph,4) > " ")
       dlrec->line_qual[lidx].disp_line = concat(dlrec->line_qual[lidx].disp_line,caseinfo->nok[
        nok_idx].nok_home_ph)
      ENDIF
      dlrec->line_qual[lidx].disp_line = concat(dlrec->line_qual[lidx].disp_line,rtab,wb,
       "Work Phone: ",wr)
      IF (trim(caseinfo->nok[nok_idx].nok_wk_ph,4) > " ")
       dlrec->line_qual[lidx].disp_line = concat(dlrec->line_qual[lidx].disp_line,caseinfo->nok[
        nok_idx].nok_wk_ph)
      ENDIF
      dlrec->line_qual[lidx].disp_line = concat(dlrec->line_qual[lidx].disp_line,rtab,wb,
       "Cell Phone: ",wr)
      IF (trim(caseinfo->nok[nok_idx].nok_cell_ph,4) > " ")
       dlrec->line_qual[lidx].disp_line = concat(dlrec->line_qual[lidx].disp_line,caseinfo->nok[
        nok_idx].nok_cell_ph)
      ENDIF
      dlrec->line_qual[lidx].disp_line = concat(dlrec->line_qual[lidx].disp_line,reol), lidx += 1,
      row + 1,
      stat = alterlist(dlrec->line_qual,lidx), dlrec->line_qual[lidx].disp_line = concat(sp60,reol)
     ENDIF
   ENDFOR
   lidx += 1, row + 1, stat = alterlist(dlrec->line_qual,lidx),
   dlrec->line_qual[lidx].disp_line = concat(sp5,line60,wr,reol)
   FOR (ins_idx = 1 TO 2)
     IF ((caseinfo->ins[ins_idx].ins_name > " "))
      lidx += 1, row + 1, stat = alterlist(dlrec->line_qual,lidx),
      dlrec->line_qual[lidx].disp_line = concat(sp5,wb,"INSURANCE: ",wr,caseinfo->ins[ins_idx].
       ins_name,
       "  /  ",caseinfo->ins[ins_idx].hp_name,"  /  ",caseinfo->ins[ins_idx].plan_type,reol), lidx
       += 1, row + 1,
      stat = alterlist(dlrec->line_qual,lidx)
      IF ((caseinfo->ins[ins_idx].hp_addr > " "))
       dlrec->line_qual[lidx].disp_line = concat(rtab,sp5,caseinfo->ins[ins_idx].hp_addr," ",caseinfo
        ->ins[ins_idx].hp_addr2,
        ", ",caseinfo->ins[ins_idx].hp_csz,rtab,wb,"Phone: ",
        wr,caseinfo->ins[ins_idx].hp_ph,reol)
      ELSEIF ((caseinfo->ins[ins_idx].hp_ph > " "))
       dlrec->line_qual[lidx].disp_line = concat(rtab,rtab,rtab,rtab,wb,
        "Phone: ",wr,caseinfo->ins[ins_idx].hp_ph,reol)
      ENDIF
      tmp_subscriber_disp = fillstring(30," "), tmp_subscriber_disp = concat(trim(caseinfo->ins[
        ins_idx].sub_name)), tmp_contract_disp = fillstring(30," "),
      tmp_contract_disp = concat(trim(caseinfo->ins[ins_idx].mbr_nbr)), tmp_group_disp = fillstring(
       30," "), tmp_group_disp = concat(trim(caseinfo->ins[ins_idx].grp_nbr)),
      tmp_ssn_disp = fillstring(30," "), tmp_ssn_disp = concat(trim(caseinfo->ins[ins_idx].sub_ssn)),
      tmp_dob_disp = fillstring(30," "),
      tmp_dob_disp = format(caseinfo->ins[ins_idx].sub_dob,"MM/DD/YYYY;;D"), lidx += 1, row + 1,
      stat = alterlist(dlrec->line_qual,lidx), dlrec->line_qual[lidx].disp_line = concat(sp5,wb,
       "SUBSCRIBER: ",wr,tmp_subscriber_disp,
       rtab,wb,"SUB DOB: ",wr,tmp_dob_disp,
       reol), lidx += 1,
      row + 1, stat = alterlist(dlrec->line_qual,lidx), dlrec->line_qual[lidx].disp_line = concat(sp5,
       wb,"CONTRACT#: ",wr,tmp_contract_disp,
       rtab,wb,"GROUP: ",wr,tmp_group_disp,
       reol)
     ENDIF
     lidx += 1, row + 1, stat = alterlist(dlrec->line_qual,lidx),
     dlrec->line_qual[lidx].disp_line = concat(sp60,reol), lidx += 1, row + 1,
     stat = alterlist(dlrec->line_qual,lidx), dlrec->line_qual[lidx].disp_line = concat(sp5,line60,wr,
      reol)
   ENDFOR
   FOR (y = 1 TO lidx)
     reply->text = concat(reply->text,dlrec->line_qual[y].disp_line)
   ENDFOR
  WITH nocounter
 ;end select
 SET reply->text = concat(reply->text,rtfeof)
 FREE RECORD caseinfo
 FREE RECORD dlrec
END GO

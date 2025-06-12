CREATE PROGRAM cls_valenccnv:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Choose how many encounters to bypass (1 - 1000000)" = ""
  WITH outdev, everyxrecs
 DECLARE corp_cd = f8
 SET corp_cd = 0.0
 SET corp_cd = uar_get_code_by("DISPLAY",263,"BHS CMRN")
 DECLARE bmcmrn_cd = f8
 SET bmcmrn_cd = 0.0
 SET bmcmrn_cd = uar_get_code_by("DISPLAYKEY",263,"BMCMRN")
 DECLARE fmcmrn_cd = f8
 SET fmcmrn_cd = 0.0
 SET fmcmrn_cd = uar_get_code_by("DISPLAYKEY",263,"FMCMRN")
 DECLARE mlhmrn_cd = f8
 SET mlhmrn_cd = 0.0
 SET mlhmrn_cd = uar_get_code_by("DISPLAYKEY",263,"MLHMRN")
 DECLARE ssn_cd = f8
 SET ssn_cd = 0.0
 SET ssn_cd = uar_get_code_by("DISPLAYKEY",263,"SSN")
 DECLARE fin_cd = f8
 SET fin_cd = 0.0
 SET fin_cd = uar_get_code_by("DISPLAYKEY",319,"FINNBR")
 DECLARE att_cd = f8
 SET att_cd = 0.0
 SET att_cd = uar_get_code_by("DISPLAYKEY",333,"ATTENDINGPHYSICIAN")
 DECLARE counter1 = f8
 SET counter1 = cnvtreal( $2)
 DECLARE loop1 = f8
 SELECT INTO value( $OUTDEV)
  admit_source = substring(1,30,uar_get_code_display(e.admit_src_cd)), admit_type = substring(1,20,
   uar_get_code_display(e.admit_type_cd)), disch_disposition = substring(1,35,uar_get_code_display(e
    .disch_disposition_cd)),
  patient_class = substring(1,10,uar_get_code_display(e.encntr_class_cd)), cis_encounter_id = e
  .encntr_id, visit_type = substring(1,20,uar_get_code_display(e.encntr_type_cd)),
  fin_class = substring(1,30,uar_get_code_display(e.financial_class_cd)), med_service = substring(1,
   30,uar_get_code_display(e.med_service_cd)), chief_complaint = substring(1,50,e.reason_for_visit),
  e.organization_id, admit_date = format(e.reg_dt_tm,"mm/dd/yyyy;;d"), disch_date = format(e
   .disch_dt_tm,"mm/dd/yyyy;;d"),
  birth_date = format(p.birth_dt_tm,"mm/dd/yyyy;;d"), race = substring(1,20,uar_get_code_display(p
    .race_cd)), language = substring(1,20,uar_get_code_display(p.language_cd)),
  marital_status = substring(1,15,uar_get_code_display(p.marital_type_cd)), name = substring(1,30,p
   .name_full_formatted), cis_person_id = p.person_id,
  religion = substring(1,25,uar_get_code_display(p.religion_cd)), sex = substring(1,10,
   uar_get_code_display(p.sex_cd)), vet_military_stat = substring(1,20,uar_get_code_display(p
    .vet_military_status_cd)),
  pt_addr1 = substring(1,30,a.street_addr), pt_addr2 = substring(1,30,a.street_addr2), pt_city =
  substring(1,20,a.city),
  pt_state = substring(1,2,a.state), pt_zip = substring(1,10,a.zipcode), cmrn = substring(1,10,pa1
   .alias),
  bmc_mrn = substring(1,10,pa2.alias), fmc_mrn = substring(1,10,pa3.alias), mlh_mrn = substring(1,10,
   pa4.alias),
  ssn = substring(1,12,pa5.alias), acctnum = substring(1,15,ea.alias), attdocname = substring(1,30,p1
   .name_full_formatted)
  FROM encounter e,
   encntr_alias ea,
   person p,
   address a,
   dummyt d1,
   person_alias pa1,
   dummyt d2,
   person_alias pa2,
   dummyt d3,
   person_alias pa3,
   dummyt d4,
   person_alias pa4,
   dummyt d5,
   person_alias pa5,
   encntr_prsnl_reltn epr,
   prsnl p1
  PLAN (e
   WHERE e.encntr_id > 0
    AND e.active_ind=1)
   JOIN (ea
   WHERE e.encntr_id=ea.encntr_id
    AND ea.encntr_alias_type_cd=fin_cd)
   JOIN (p
   WHERE e.person_id=p.person_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (a
   WHERE p.person_id=a.parent_entity_id
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d1)
   JOIN (pa1
   WHERE e.person_id=pa1.person_id
    AND pa1.alias_pool_cd=corp_cd
    AND pa1.active_ind=1
    AND pa1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d2)
   JOIN (pa2
   WHERE e.person_id=pa2.person_id
    AND pa2.alias_pool_cd=bmcmrn_cd
    AND pa2.active_ind=1
    AND pa2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d3)
   JOIN (pa3
   WHERE e.person_id=pa3.person_id
    AND pa3.alias_pool_cd=fmcmrn_cd
    AND pa3.active_ind=1
    AND pa3.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa3.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d4)
   JOIN (pa4
   WHERE e.person_id=pa4.person_id
    AND pa4.alias_pool_cd=mlhmrn_cd
    AND pa4.active_ind=1
    AND pa4.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa4.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d5)
   JOIN (pa5
   WHERE e.person_id=pa5.person_id
    AND pa5.alias_pool_cd=ssn_cd
    AND pa5.active_ind=1
    AND pa5.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa5.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=att_cd
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (p1
   WHERE p1.person_id=epr.prsnl_person_id
    AND p1.active_ind=1
    AND p1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY e.person_id
  HEAD REPORT
   IF (counter1=0)
    counter1 = 1
   ENDIF
   loop1 = 0.0
  DETAIL
   loop1 = (loop1+ 1)
   IF (loop1=counter1)
    col 001, admit_source, col 032,
    admit_type, col 053, disch_disposition,
    col 089, patient_class, col 105,
    cis_encounter_id, col 120, visit_type,
    col 141, fin_class, col 172,
    med_service, col 203, chief_complaint,
    col 255, e.organization_id, col 270,
    admit_date, col 288, disch_date,
    col 306, birth_date, col 317,
    race, col 338, language,
    col 359, marital_status, col 375,
    name, col 406, cis_person_id,
    col 421, religion, col 447,
    sex, col 458, vet_military_stat,
    col 479, pt_addr1, col 510,
    pt_addr2, col 541, pt_city,
    col 562, pt_state, col 571,
    pt_zip, col 582, cmrn,
    col 593, bmc_mrn, col 605,
    fmc_mrn, col 615, mlh_mrn,
    col 626, ssn, col 639,
    acctnum, col 655, attdocname,
    row + 1, loop1 = 0.0
   ENDIF
  WITH outerjoin = d1, dontcare = pa2, outerjoin = d2,
   dontcare = pa3, outerjoin = d3, dontcare = pa4,
   outerjoin = d4, dontcare = pa5, outerjoin = d5,
   maxcol = 700
 ;end select
END GO

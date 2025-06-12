CREATE PROGRAM al_test_read:dba
 FREE RECORD bohd_person
 RECORD bohd_person(
   1 l_cnt = i4
   1 qual[*]
     2 f_pid = f8
 ) WITH protect
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_sortby = i4 WITH noconstant(0)
 DECLARE ms_separator_cd = c1 WITH protect, constant("|")
 DECLARE ml_pers_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_pers_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_for_cnt = i4 WITH protect, noconstant(0)
 DECLARE gs_need_header = vc WITH public, noconstant("Y")
 DECLARE gs_output_file = vc WITH public, noconstant("")
 DECLARE ms_displayline = vc WITH protect, noconstant("")
 DECLARE mf_icd9_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"ICD9"))
 DECLARE mf_snmct_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"SNMCT"))
 DECLARE mf_imo_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",400,"IMO"))
 DECLARE mf_icd10_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"ICD10-CM"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_docnpi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",320,
   "NATIONALPROVIDERIDENTIFIER"))
 DECLARE mf_att_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,"ATTENDINGPHYSICIAN")
  )
 DECLARE mf_ranking_primary_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",12034,
   "PRIMARY"))
 DECLARE mf_ranking_secondary_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",12034,
   "SECONDARY"))
 DECLARE mf_ranking_tertiary_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",12034,
   "TERTIARY"))
 DECLARE mf_adtegate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",89,"ADTEGATE"))
 IF ( NOT (validate(requestin)))
  FREE RECORD requestin
  RECORD requestin(
    1 l_lcnt = i4
    1 list_0[*]
      2 mrn = vc
      2 svc_facility_id = vc
      2 svc_dt = vc
      2 encounter_id = vc
      2 hne_member_id = vc
      2 invoice_nbr = vc
  ) WITH protect
 ENDIF
 FREE RECORD pat
 RECORD pat(
   1 l_cnt = i4
   1 qual[*]
     2 f_pid = f8
     2 f_eid = f8
     2 s_invoice_number = vc
     2 s_medical_record_number = vc
     2 s_cmrn = vc
     2 s_encounter_number = vc
     2 s_hne_memberid = vc
     2 s_hne_claim_number = vc
     2 s_pfirst_name = vc
     2 s_plast_name = vc
     2 s_hicn = vc
     2 s_mass_health_id = vc
     2 s_gender = vc
     2 s_date_of_birth = vc
     2 s_provider_id = vc
     2 s_service_provider_name = vc
     2 s_npi = vc
     2 s_service_from_date = vc
     2 s_service_thru_date = vc
     2 s_transdate = vc
     2 s_record_type = vc
     2 l_diag_cnt = i4
     2 d_current_updt_dt_tm = dq8
     2 icd9[50]
       3 s_icd9_cd = vc
 ) WITH protect
 CALL echorecord(requestin)
 SELECT INTO "nl:"
  FROM encntr_alias ea,
   encounter e,
   person p,
   person_alias pa
  PLAN (ea
   WHERE expand(ml_num,1,size(requestin->list_0,5),ea.alias,trim(cnvtstring(cnvtreal(requestin->
       list_0[ml_num].encounter_id),20),3))
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND ea.encntr_alias_type_cd=mf_fin_cd)
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id
    AND e.active_ind=1)
   JOIN (p
   WHERE e.person_id=p.person_id
    AND p.active_ind=1)
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(p.person_id))
    AND (pa.active_ind= Outerjoin(1))
    AND (pa.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate)))
    AND (pa.person_alias_type_cd= Outerjoin(mf_cmrn_cd)) )
  HEAD REPORT
   ml_pos = 0, ml_idx = 0
   IF (gs_need_header="Y")
    pat->l_cnt += 1, stat = alterlist(pat->qual,pat->l_cnt), pat->qual[pat->l_cnt].s_invoice_number
     = "INVOICENBR",
    pat->qual[pat->l_cnt].s_medical_record_number = "MEDICALRECORDNBR", pat->qual[pat->l_cnt].s_cmrn
     = "MEDICALRECORDNBR", pat->qual[pat->l_cnt].s_encounter_number = "ENCOUNTERNBR",
    pat->qual[pat->l_cnt].s_hne_memberid = "MEMBERID", pat->qual[pat->l_cnt].s_hne_claim_number =
    "CLAIMNO", pat->qual[pat->l_cnt].s_pfirst_name = "MEMBERFN",
    pat->qual[pat->l_cnt].s_plast_name = "MEMBERLN", pat->qual[pat->l_cnt].s_hicn = "HICN", pat->
    qual[pat->l_cnt].s_mass_health_id = "MASS_HEALTH_ID",
    pat->qual[pat->l_cnt].s_gender = "SEX", pat->qual[pat->l_cnt].s_date_of_birth = "DOB", pat->qual[
    pat->l_cnt].s_provider_id = "PROVIDERID",
    pat->qual[pat->l_cnt].s_service_provider_name = "PROVIDERNAME", pat->qual[pat->l_cnt].s_npi =
    "NPI", pat->qual[pat->l_cnt].s_service_from_date = "FROMDATE",
    pat->qual[pat->l_cnt].s_service_thru_date = "THRUDATE"
    FOR (ml_for_cnt = 1 TO 50)
      pat->qual[pat->l_cnt].icd9[ml_for_cnt].s_icd9_cd = concat("DIAG",trim(cnvtstring(ml_for_cnt),3)
       )
    ENDFOR
    pat->qual[pat->l_cnt].s_transdate = "TRANSDATE", pat->qual[pat->l_cnt].s_record_type =
    "RECORD_TYPE", pat->qual[pat->l_cnt].l_diag_cnt = 1,
    gs_need_header = "N"
   ENDIF
  DETAIL
   ml_idx = 0, ml_pos = locateval(ml_idx,1,size(requestin->list_0,5),ea.alias,trim(cnvtstring(
      cnvtreal(requestin->list_0[ml_idx].encounter_id),20),3)), pat->l_cnt += 1,
   stat = alterlist(pat->qual,pat->l_cnt), pat->qual[pat->l_cnt].f_eid = e.encntr_id, pat->qual[pat->
   l_cnt].f_pid = e.person_id,
   pat->qual[pat->l_cnt].s_invoice_number = trim(requestin->list_0[ml_pos].invoice_nbr,3), pat->qual[
   pat->l_cnt].s_medical_record_number = trim(requestin->list_0[ml_pos].mrn,3), pat->qual[pat->l_cnt]
   .s_cmrn = format(cnvtreal(pa.alias),"#######;P0"),
   pat->qual[pat->l_cnt].s_encounter_number = trim(requestin->list_0[ml_pos].encounter_id,3), pat->
   qual[pat->l_cnt].s_hne_memberid = trim(requestin->list_0[ml_pos].hne_member_id,3), pat->qual[pat->
   l_cnt].s_pfirst_name = trim(p.name_first,3),
   pat->qual[pat->l_cnt].s_plast_name = trim(p.name_last,3), pat->qual[pat->l_cnt].s_gender = trim(
    uar_get_code_display(p.sex_cd),3), pat->qual[pat->l_cnt].s_date_of_birth = trim(format(p
     .birth_dt_tm,"YYYYMMDD"),3)
   IF (size(trim(format(e.reg_dt_tm,"YYYYMMDD"),3),1)=0)
    pat->qual[pat->l_cnt].s_service_from_date = trim(format(e.disch_dt_tm,"YYYYMMDD"),3)
   ELSE
    pat->qual[pat->l_cnt].s_service_from_date = trim(format(e.reg_dt_tm,"YYYYMMDD"),3)
   ENDIF
   IF (size(trim(format(e.disch_dt_tm,"YYYYMMDD"),3),1)=0)
    pat->qual[pat->l_cnt].s_service_thru_date = trim(format(e.reg_dt_tm,"YYYYMMDD"),3)
   ELSE
    pat->qual[pat->l_cnt].s_service_thru_date = trim(format(e.disch_dt_tm,"YYYYMMDD"),3)
   ENDIF
   pat->qual[pat->l_cnt].s_record_type = "EMRDIAG", pat->qual[pat->l_cnt].s_transdate = trim(format(e
     .updt_dt_tm,"YYYYMMDDHHMMSS;;d"),3), pat->qual[pat->l_cnt].s_provider_id = "10488"
  WITH nocounter, expand = 1
 ;end select
 CALL echorecord(pat)
 IF (size(pat->qual,5)=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   person p,
   prsnl_alias pa
  PLAN (epr
   WHERE expand(ml_num,1,size(pat->qual,5),epr.encntr_id,pat->qual[ml_num].f_eid)
    AND epr.encntr_prsnl_r_cd=mf_att_cd
    AND epr.prsnl_person_id != 0
    AND epr.encntr_id != 0)
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id
    AND p.name_last_key != "NOTONSTAFF")
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.prsnl_alias_type_cd=mf_docnpi_cd)
  ORDER BY epr.encntr_id, epr.beg_effective_dt_tm DESC
  HEAD epr.encntr_id
   ml_pos = 0, ml_idx = 0, ml_pos = locateval(ml_idx,1,size(pat->qual,5),epr.encntr_id,pat->qual[
    ml_idx].f_eid)
   IF (ml_pos > 0)
    pat->qual[ml_pos].s_service_provider_name = trim(p.name_full_formatted,3), pat->qual[ml_pos].
    s_npi = trim(pa.alias,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT DISTINCT INTO "nl:"
  d.encntr_id, ml_sortby =
  IF (d.ranking_cd=mf_ranking_primary_cd) 1
  ELSEIF (d.ranking_cd=mf_ranking_secondary_cd) 2
  ELSEIF (d.ranking_cd=mf_ranking_tertiary_cd) 3
  ELSE d.diag_dt_tm
  ENDIF
  , d.nomenclature_id
  FROM diagnosis d,
   nomenclature n
  PLAN (d
   WHERE expand(ml_num,1,size(pat->qual,5),d.encntr_id,pat->qual[ml_num].f_eid)
    AND d.active_ind=1
    AND d.contributor_system_cd != mf_adtegate_cd)
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id
    AND n.source_vocabulary_cd IN (mf_icd9_cd, mf_icd10_cd))
  ORDER BY d.encntr_id, ml_sortby, d.nomenclature_id
  HEAD REPORT
   ml_pos = 0, ml_idx = 0
  HEAD d.encntr_id
   ml_pos = locateval(ml_idx,1,size(pat->qual,5),d.encntr_id,pat->qual[ml_idx].f_eid), pat->qual[
   ml_pos].l_diag_cnt = 0
  DETAIL
   pat->qual[ml_pos].l_diag_cnt += 1
   IF ((pat->qual[pat->l_cnt].l_diag_cnt <= 50))
    pat->qual[ml_pos].icd9[pat->qual[ml_pos].l_diag_cnt].s_icd9_cd = trim(n.source_identifier,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl"
  FROM problem p,
   nomenclature n,
   cmt_cross_map ccm
  PLAN (p
   WHERE expand(ml_num,1,size(pat->qual,5),p.person_id,pat->qual[ml_num].f_pid)
    AND p.active_ind=1
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id
    AND n.source_vocabulary_cd IN (mf_icd9_cd, mf_snmct_cd))
   JOIN (ccm
   WHERE (ccm.concept_cki= Outerjoin(n.concept_cki))
    AND (ccm.source_vocabulary_cd= Outerjoin(mf_icd10_cd))
    AND (ccm.active_ind= Outerjoin(1))
    AND (ccm.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY p.person_id, p.updt_dt_tm DESC
  HEAD REPORT
   ml_pos = 0, ml_idx = 0
  HEAD p.person_id
   ml_pers_loc = 0
   IF ((bohd_person->l_cnt > 0))
    ml_pers_loc = locateval(ml_pers_idx,1,bohd_person->l_cnt,p.person_id,bohd_person->qual[
     ml_pers_idx].f_pid)
    IF (ml_pers_loc=0)
     bohd_person->l_cnt += 1, stat = alterlist(bohd_person->qual,bohd_person->l_cnt), bohd_person->
     qual[bohd_person->l_cnt].f_pid = p.person_id
    ENDIF
   ELSE
    bohd_person->l_cnt += 1, stat = alterlist(bohd_person->qual,bohd_person->l_cnt), bohd_person->
    qual[bohd_person->l_cnt].f_pid = p.person_id
   ENDIF
   IF (ml_pers_loc=0)
    ml_pos = locateval(ml_idx,1,size(pat->qual,5),p.person_id,pat->qual[ml_idx].f_pid), pat->l_cnt
     += 1, stat = alterlist(pat->qual,pat->l_cnt),
    pat->qual[pat->l_cnt].f_pid = p.person_id, pat->qual[pat->l_cnt].s_cmrn = pat->qual[ml_pos].
    s_cmrn, pat->qual[pat->l_cnt].s_hne_memberid = pat->qual[ml_pos].s_hne_memberid,
    pat->qual[pat->l_cnt].s_pfirst_name = pat->qual[ml_pos].s_pfirst_name, pat->qual[pat->l_cnt].
    s_plast_name = pat->qual[ml_pos].s_plast_name, pat->qual[pat->l_cnt].s_gender = pat->qual[ml_pos]
    .s_gender,
    pat->qual[pat->l_cnt].s_date_of_birth = pat->qual[ml_pos].s_date_of_birth, pat->qual[pat->l_cnt].
    s_service_from_date = trim(format(p.beg_effective_dt_tm,"YYYYMMDD"),3), pat->qual[pat->l_cnt].
    s_service_thru_date = trim(format(p.end_effective_dt_tm,"YYYYMMDD"),3),
    pat->qual[pat->l_cnt].s_record_type = "EMRSNOMED", pat->qual[pat->l_cnt].d_current_updt_dt_tm = p
    .updt_dt_tm, pat->qual[pat->l_cnt].s_transdate = trim(format(p.updt_dt_tm,"YYYYMMDDHHMMSS;;d"),3),
    pat->qual[pat->l_cnt].s_provider_id = "10488", pat->qual[pat->l_cnt].l_diag_cnt = 0
   ENDIF
  DETAIL
   IF (ml_pers_loc=0)
    pat->qual[pat->l_cnt].l_diag_cnt += 1
    IF ((pat->qual[pat->l_cnt].l_diag_cnt <= 50))
     IF (n.source_vocabulary_cd=mf_icd9_cd)
      pat->qual[pat->l_cnt].icd9[pat->qual[pat->l_cnt].l_diag_cnt].s_icd9_cd = trim(n
       .source_identifier,3)
     ELSE
      pat->qual[pat->l_cnt].icd9[pat->qual[pat->l_cnt].l_diag_cnt].s_icd9_cd = trim(ccm
       .source_identifier,3)
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 CALL echorecord(pat)
END GO

CREATE PROGRAM bhs_ops_hne_diag_data:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Discharge Date Start:" = "CURDATE",
  "Discharge Date End:" = "CURDATE"
  WITH outdev, s_start_dt, s_stop_dt
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs4_cmrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 DECLARE mf_cs333_attenddoc_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4024"))
 DECLARE mf_cs320_npi_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2160654021"))
 DECLARE mf_cs12034_primary_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3474"))
 DECLARE mf_cs12034_secondary_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3475"
   ))
 DECLARE mf_cs12034_tertiary_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!3756565"))
 DECLARE mf_cs89_adtegate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",89,"ADTEGATE"))
 DECLARE mf_cs400_icd10_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4101498946"
   ))
 DECLARE mf_cs400_snmct_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3240237"))
 DECLARE mf_cs400_icd9_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2953"))
 IF (cnvtupper(trim( $2,3))="CURDATE*")
  SET mf_start_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
        5,trim( $2,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTWEEK")
  SET mf_start_dt = datetimeadd(cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W",
      "B","B"),"DD-MMM-YYYY HH:MM:SS;;d")),1)
 ELSEIF (cnvtupper(trim( $2,3))="LASTMONTH")
  SET mf_start_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"01-MMM-YYYY 00:00:00;;d"))
 ELSE
  SET mf_start_dt = cnvtdatetime(concat(trim( $2,3)," 00:00:00"))
 ENDIF
 IF (cnvtupper(trim( $3,3))="CURDATE*")
  SET mf_stop_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,5,
        trim( $3,3)))),"DD-MMM-YYYY;;d")," 23:59:59"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTWEEK")
  SET mf_stop_dt = datetimeadd(cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","E",
      "E"),"DD-MMM-YYYY HH:MM:SS;;d")),1)
 ELSEIF (cnvtupper(trim( $3,3))="LASTMONTH")
  SET mf_stop_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"DD-MMM-YYYY 23:59:59;;d"))
 ELSE
  SET mf_stop_dt = cnvtdatetime(concat(trim( $3,3)," 23:59:59"))
 ENDIF
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 ) WITH protect
 FREE RECORD m_hp
 RECORD m_hp(
   1 l_cnt = i4
   1 qual[*]
     2 f_hp_id = f8
     2 s_hp_name = vc
     2 s_carrier = vc
 ) WITH protect
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 f_hp = f8
     2 s_member_nbr = vc
     2 s_fin = vc
     2 s_cmrn = vc
     2 s_attending = vc
     2 s_npi = vc
     2 s_fname = vc
     2 s_lname = vc
     2 s_gender = vc
     2 s_dob = vc
     2 s_service_dt_from = vc
     2 s_service_dt_to = vc
     2 s_updt_dt = vc
     2 s_prob_code = vc
     2 l_dcnt = i4
     2 dqual[50]
       3 s_icd_code = vc
 ) WITH protect
 FREE RECORD m_prob
 RECORD m_prob(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 f_hp = f8
     2 s_member_nbr = vc
     2 s_fin = vc
     2 s_cmrn = vc
     2 s_attending = vc
     2 s_npi = vc
     2 s_fname = vc
     2 s_lname = vc
     2 s_gender = vc
     2 s_dob = vc
     2 s_service_dt_from = vc
     2 s_service_dt_to = vc
     2 s_updt_dt = vc
     2 s_prob_code = vc
     2 l_dcnt = i4
     2 dqual[50]
       3 s_icd_code = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM organization o,
   org_plan_reltn opr,
   health_plan hp
  PLAN (o
   WHERE o.org_name_key IN ("HNEBHSHMO", "HNEBHSPPO", "HNESELECTHMO", "HNESELECTPPO", "HNEIDENTICAL",
   "HNEHMOBAYCAREHP", "HNESRSOFPROVPPO", "HNESRSOFPROVEPO", "HNESELECTHMO", "HNEBHSHMO",
   "HNESELECTPPO", "HNEIDENTICAL", "ONEMONARCHPLACE", "HEALTHNEWENGLANDIDENTICAL",
   "HEALTHNEWENGLANDIDENT",
   "HEALTHNEWENGLAND", "HNEBHSPPO", "HEALTHNEWENGLAND", "HNEHMOBAYCAREHP", "HNEFFNONBHPHMOP",
   "HNEMEDICAREADVANTA", "HNEBEHEALTHYMCAID", "L99", "HNESUPPLEMENTAL", "BWHHNECOMMONWEALTHCARE",
   "HEALTHNEWENGLAND", "HNEMCRADVANTAGEREPLC", "HEALTHNEWENGLAND", "HNEBEHEALTHY",
   "HNECOMMONWEALTHCARE",
   "HNEFFNONBHPHMO", "HNEBHSHMO", "HNEBHSPPO", "HNEHMOBAYCAREHP", "HNESRSOFPROVEPO",
   "HNESELECTHMO", "HNESRSOFPROVPPO", "HEALTHNEWENGLAND", "MASSBEHAVORIALHEALTHPARTNERS",
   "HNEMEDICARE2NDRY",
   "MBHPHNEACO", "HNECONNECTORCARE", "HNEMEDICAREADVPPO")
    AND o.active_ind=1)
   JOIN (opr
   WHERE opr.organization_id=o.organization_id
    AND opr.active_ind=1
    AND opr.org_plan_reltn_cd=1200.00)
   JOIN (hp
   WHERE hp.health_plan_id=opr.health_plan_id
    AND hp.plan_name_key="*HNE*")
  ORDER BY hp.health_plan_id
  HEAD hp.health_plan_id
   m_hp->l_cnt += 1, stat = alterlist(m_hp->qual,m_hp->l_cnt), m_hp->qual[m_hp->l_cnt].f_hp_id = hp
   .health_plan_id,
   m_hp->qual[m_hp->l_cnt].s_hp_name = trim(hp.plan_name,3), m_hp->qual[m_hp->l_cnt].s_carrier = trim
   (o.org_name)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   encntr_plan_reltn epr,
   encntr_alias ea,
   person_alias pa
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND expand(ml_idx1,1,m_hp->l_cnt,epr.health_plan_id,m_hp->qual[ml_idx1].f_hp_id))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(e.person_id))
    AND (pa.active_ind= Outerjoin(1))
    AND (pa.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (pa.person_alias_type_cd= Outerjoin(mf_cs4_cmrn_cd)) )
  ORDER BY e.encntr_id, epr.priority_seq, ea.beg_effective_dt_tm DESC,
   pa.beg_effective_dt_tm
  HEAD e.encntr_id
   IF (((size(trim(epr.subs_member_nbr,3)) != 0) OR (size(trim(epr.member_nbr,3)) != 0)) )
    m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
    f_encntr_id = e.encntr_id,
    m_rec->qual[m_rec->l_cnt].f_person_id = e.person_id, m_rec->qual[m_rec->l_cnt].f_hp = epr
    .health_plan_id
    IF (size(trim(epr.member_nbr,3)) != 0)
     m_rec->qual[m_rec->l_cnt].s_member_nbr = trim(epr.member_nbr,3)
    ELSE
     m_rec->qual[m_rec->l_cnt].s_member_nbr = trim(epr.subs_member_nbr,3)
    ENDIF
    m_rec->qual[m_rec->l_cnt].s_fin = trim(ea.alias,3), m_rec->qual[m_rec->l_cnt].s_cmrn = format(
     cnvtreal(pa.alias),"#######;P0"), m_rec->qual[m_rec->l_cnt].s_gender = trim(uar_get_code_display
     (p.sex_cd),3),
    m_rec->qual[m_rec->l_cnt].s_fname = trim(p.name_first,3), m_rec->qual[m_rec->l_cnt].s_lname =
    trim(p.name_last,3), m_rec->qual[m_rec->l_cnt].s_dob = trim(format(p.birth_dt_tm,"YYYYMMDD;;q"),3
     ),
    m_rec->qual[m_rec->l_cnt].s_service_dt_from = trim(format(e.reg_dt_tm,"YYYYMMDD;;q"),3), m_rec->
    qual[m_rec->l_cnt].s_service_dt_to = trim(format(e.disch_dt_tm,"YYYYMMDD;;q"),3), m_rec->qual[
    m_rec->l_cnt].s_updt_dt = trim(format(e.updt_dt_tm,"YYYYMMDDHHMMSS;;d"),3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   prsnl p,
   prsnl_alias pa
  PLAN (epr
   WHERE expand(ml_idx1,1,m_rec->l_cnt,epr.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
    AND epr.encntr_prsnl_r_cd=mf_cs333_attenddoc_cd
    AND epr.active_ind=1
    AND epr.prsnl_person_id != 0)
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id
    AND p.name_last_key != "NOTONSTAFF")
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.prsnl_alias_type_cd=mf_cs320_npi_cd)
  ORDER BY epr.encntr_id, epr.beg_effective_dt_tm DESC
  HEAD epr.encntr_id
   ml_idx2 = locatevalsort(ml_idx1,1,m_rec->l_cnt,epr.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_attending = trim(p.name_full_formatted,3), m_rec->qual[ml_idx2].s_npi =
    trim(pa.alias,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT DISTINCT INTO "nl:"
  d.encntr_id, ml_sortby =
  IF (d.ranking_cd=mf_cs12034_primary_cd) 1
  ELSEIF (d.ranking_cd=mf_cs12034_secondary_cd) 2
  ELSEIF (d.ranking_cd=mf_cs12034_tertiary_cd) 3
  ELSE d.diag_dt_tm
  ENDIF
  , d.nomenclature_id
  FROM diagnosis d,
   nomenclature n
  PLAN (d
   WHERE expand(ml_idx1,1,m_rec->l_cnt,d.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
    AND d.active_ind=1
    AND d.contributor_system_cd != mf_cs89_adtegate_cd)
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id
    AND n.source_vocabulary_cd=mf_cs400_icd10_cd)
  ORDER BY d.encntr_id, ml_sortby, d.nomenclature_id
  HEAD d.encntr_id
   ml_idx2 = locatevalsort(ml_idx1,1,m_rec->l_cnt,d.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
  DETAIL
   IF (ml_idx2 > 0)
    IF ((m_rec->qual[ml_idx2].l_dcnt < 50))
     m_rec->qual[ml_idx2].l_dcnt += 1, m_rec->qual[ml_idx2].dqual[m_rec->qual[ml_idx2].l_dcnt].
     s_icd_code = trim(n.source_identifier,3)
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl"
  FROM problem p,
   nomenclature n,
   cmt_cross_map ccm
  PLAN (p
   WHERE expand(ml_idx1,1,m_rec->l_cnt,p.person_id,m_rec->qual[ml_idx1].f_person_id)
    AND p.active_ind=1
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id
    AND n.source_vocabulary_cd IN (mf_cs400_icd9_cd, mf_cs400_snmct_cd))
   JOIN (ccm
   WHERE (ccm.concept_cki= Outerjoin(n.concept_cki))
    AND (ccm.source_vocabulary_cd= Outerjoin(mf_cs400_icd10_cd))
    AND (ccm.active_ind= Outerjoin(1))
    AND (ccm.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY p.person_id, p.updt_dt_tm DESC
  HEAD p.person_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,p.person_id,m_rec->qual[ml_idx1].f_person_id)
   IF (ml_idx2 > 0)
    m_prob->l_cnt += 1, stat = alterlist(m_prob->qual,m_prob->l_cnt), m_prob->qual[m_prob->l_cnt].
    f_person_id = p.person_id,
    m_prob->qual[m_prob->l_cnt].s_cmrn = m_rec->qual[ml_idx2].s_cmrn, m_prob->qual[m_prob->l_cnt].
    s_member_nbr = m_rec->qual[ml_idx2].s_member_nbr, m_prob->qual[m_prob->l_cnt].s_fname = m_rec->
    qual[ml_idx2].s_fname,
    m_prob->qual[m_prob->l_cnt].s_lname = m_rec->qual[ml_idx2].s_lname, m_prob->qual[m_prob->l_cnt].
    s_dob = m_rec->qual[ml_idx2].s_dob, m_prob->qual[m_prob->l_cnt].s_gender = m_rec->qual[ml_idx2].
    s_gender,
    m_prob->qual[m_prob->l_cnt].s_service_dt_from = trim(format(p.beg_effective_dt_tm,"YYYYMMDD"),3),
    m_prob->qual[m_prob->l_cnt].s_service_dt_to = trim(format(p.end_effective_dt_tm,"YYYYMMDD"),3),
    m_prob->qual[m_prob->l_cnt].s_updt_dt = trim(format(p.updt_dt_tm,"YYYYMMDDHHMMSS;;d"),3)
   ENDIF
  DETAIL
   IF (ml_idx2 > 0)
    IF ((m_prob->qual[m_prob->l_cnt].l_dcnt < 50))
     m_prob->qual[m_prob->l_cnt].l_dcnt += 1
     IF (n.source_vocabulary_cd=mf_cs400_icd9_cd)
      m_prob->qual[m_prob->l_cnt].dqual[m_prob->qual[m_prob->l_cnt].l_dcnt].s_icd_code = trim(n
       .source_identifier,3)
     ELSE
      m_prob->qual[m_prob->l_cnt].dqual[m_prob->qual[m_prob->l_cnt].l_dcnt].s_icd_code = trim(ccm
       .source_identifier,3)
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SET frec->file_name = concat("bhs_hne_diag_",format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;d"),
  ".txt")
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = concat("INVOICENBR|","MEDICALRECORDNBR|","ENCOUNTERNBR|","MEMBERID|","CLAIMNO|",
  "MEMBERFN|","MEMBERLN|","HICN|","MASS_HEALTH_ID|","SEX|",
  "DOB|","PROVIDERID|","PROVIDERNAME|","NPI|","FROMDATE|",
  "THRUDATE|","DIAG1|","DIAG2|","DIAG3|","DIAG4|",
  "DIAG5|","DIAG6|","DIAG7|","DIAG8|","DIAG9|",
  "DIAG10|","DIAG11|","DIAG12|","DIAG13|","DIAG14|",
  "DIAG15|","DIAG16|","DIAG17|","DIAG18|","DIAG19|",
  "DIAG20|","DIAG21|","DIAG22|","DIAG23|","DIAG24|",
  "DIAG25|","DIAG26|","DIAG27|","DIAG28|","DIAG29|",
  "DIAG30|","DIAG31|","DIAG32|","DIAG33|","DIAG34|",
  "DIAG35|","DIAG36|","DIAG37|","DIAG38|","DIAG39|",
  "DIAG40|","DIAG41|","DIAG42|","DIAG43|","DIAG44|",
  "DIAG45|","DIAG46|","DIAG47|","DIAG48|","DIAG49|",
  "DIAG50|","TRANSDATE|","RECORD_TYPE",char(13),char(10))
 SET stat = cclio("WRITE",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   IF ((m_rec->qual[ml_idx1].l_dcnt > 0))
    SET frec->file_buf = concat(trim(m_rec->qual[ml_idx1].s_fin,3),"|",trim(m_rec->qual[ml_idx1].
      s_cmrn,3),"|",trim(m_rec->qual[ml_idx1].s_fin,3),
     "|",trim(m_rec->qual[ml_idx1].s_member_nbr,3),"|","|",trim(m_rec->qual[ml_idx1].s_fname,3),
     "|",trim(m_rec->qual[ml_idx1].s_lname,3),"|","|","|",
     trim(m_rec->qual[ml_idx1].s_gender,3),"|",trim(m_rec->qual[ml_idx1].s_dob,3),"|","10488",
     "|",trim(m_rec->qual[ml_idx1].s_attending,3),"|",trim(m_rec->qual[ml_idx1].s_npi,3),"|",
     trim(m_rec->qual[ml_idx1].s_service_dt_from,3),"|",trim(m_rec->qual[ml_idx1].s_service_dt_to,3),
     "|",trim(m_rec->qual[ml_idx1].dqual[1].s_icd_code,3),
     "|",trim(m_rec->qual[ml_idx1].dqual[2].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[3].
      s_icd_code,3),"|",
     trim(m_rec->qual[ml_idx1].dqual[4].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[5].
      s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[6].s_icd_code,3),
     "|",trim(m_rec->qual[ml_idx1].dqual[7].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[8].
      s_icd_code,3),"|",
     trim(m_rec->qual[ml_idx1].dqual[9].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[10].
      s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[11].s_icd_code,3),
     "|",trim(m_rec->qual[ml_idx1].dqual[12].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[13].
      s_icd_code,3),"|",
     trim(m_rec->qual[ml_idx1].dqual[14].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[15].
      s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[16].s_icd_code,3),
     "|",trim(m_rec->qual[ml_idx1].dqual[17].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[18].
      s_icd_code,3),"|",
     trim(m_rec->qual[ml_idx1].dqual[19].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[20].
      s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[21].s_icd_code,3),
     "|",trim(m_rec->qual[ml_idx1].dqual[22].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[23].
      s_icd_code,3),"|",
     trim(m_rec->qual[ml_idx1].dqual[24].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[25].
      s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[26].s_icd_code,3),
     "|",trim(m_rec->qual[ml_idx1].dqual[27].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[28].
      s_icd_code,3),"|",
     trim(m_rec->qual[ml_idx1].dqual[29].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[30].
      s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[31].s_icd_code,3),
     "|",trim(m_rec->qual[ml_idx1].dqual[32].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[33].
      s_icd_code,3),"|",
     trim(m_rec->qual[ml_idx1].dqual[34].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[35].
      s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[36].s_icd_code,3),
     "|",trim(m_rec->qual[ml_idx1].dqual[37].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[38].
      s_icd_code,3),"|",
     trim(m_rec->qual[ml_idx1].dqual[39].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[40].
      s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[41].s_icd_code,3),
     "|",trim(m_rec->qual[ml_idx1].dqual[42].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[43].
      s_icd_code,3),"|",
     trim(m_rec->qual[ml_idx1].dqual[44].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[45].
      s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[46].s_icd_code,3),
     "|",trim(m_rec->qual[ml_idx1].dqual[47].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[48].
      s_icd_code,3),"|",
     trim(m_rec->qual[ml_idx1].dqual[49].s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].dqual[50].
      s_icd_code,3),"|",trim(m_rec->qual[ml_idx1].s_updt_dt,3),
     "|","EMRDIAG",char(13),char(10))
    SET stat = cclio("WRITE",frec)
   ENDIF
 ENDFOR
 FOR (ml_idx1 = 1 TO m_prob->l_cnt)
   IF ((m_prob->qual[ml_idx1].l_dcnt > 0))
    SET frec->file_buf = concat(trim(m_prob->qual[ml_idx1].s_fin,3),"|",trim(m_prob->qual[ml_idx1].
      s_cmrn,3),"|",trim(m_prob->qual[ml_idx1].s_fin,3),
     "|",trim(m_prob->qual[ml_idx1].s_member_nbr,3),"|","|",trim(m_prob->qual[ml_idx1].s_fname,3),
     "|",trim(m_prob->qual[ml_idx1].s_lname,3),"|","|","|",
     trim(m_prob->qual[ml_idx1].s_gender,3),"|",trim(m_prob->qual[ml_idx1].s_dob,3),"|","10488",
     "|",trim(m_prob->qual[ml_idx1].s_attending,3),"|",trim(m_prob->qual[ml_idx1].s_npi,3),"|",
     trim(m_prob->qual[ml_idx1].s_service_dt_from,3),"|",trim(m_prob->qual[ml_idx1].s_service_dt_to,3
      ),"|",trim(m_prob->qual[ml_idx1].dqual[1].s_icd_code,3),
     "|",trim(m_prob->qual[ml_idx1].dqual[2].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[3].
      s_icd_code,3),"|",
     trim(m_prob->qual[ml_idx1].dqual[4].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[5].
      s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[6].s_icd_code,3),
     "|",trim(m_prob->qual[ml_idx1].dqual[7].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[8].
      s_icd_code,3),"|",
     trim(m_prob->qual[ml_idx1].dqual[9].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[10].
      s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[11].s_icd_code,3),
     "|",trim(m_prob->qual[ml_idx1].dqual[12].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[13].
      s_icd_code,3),"|",
     trim(m_prob->qual[ml_idx1].dqual[14].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[15].
      s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[16].s_icd_code,3),
     "|",trim(m_prob->qual[ml_idx1].dqual[17].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[18].
      s_icd_code,3),"|",
     trim(m_prob->qual[ml_idx1].dqual[19].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[20].
      s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[21].s_icd_code,3),
     "|",trim(m_prob->qual[ml_idx1].dqual[22].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[23].
      s_icd_code,3),"|",
     trim(m_prob->qual[ml_idx1].dqual[24].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[25].
      s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[26].s_icd_code,3),
     "|",trim(m_prob->qual[ml_idx1].dqual[27].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[28].
      s_icd_code,3),"|",
     trim(m_prob->qual[ml_idx1].dqual[29].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[30].
      s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[31].s_icd_code,3),
     "|",trim(m_prob->qual[ml_idx1].dqual[32].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[33].
      s_icd_code,3),"|",
     trim(m_prob->qual[ml_idx1].dqual[34].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[35].
      s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[36].s_icd_code,3),
     "|",trim(m_prob->qual[ml_idx1].dqual[37].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[38].
      s_icd_code,3),"|",
     trim(m_prob->qual[ml_idx1].dqual[39].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[40].
      s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[41].s_icd_code,3),
     "|",trim(m_prob->qual[ml_idx1].dqual[42].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[43].
      s_icd_code,3),"|",
     trim(m_prob->qual[ml_idx1].dqual[44].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[45].
      s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[46].s_icd_code,3),
     "|",trim(m_prob->qual[ml_idx1].dqual[47].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[48].
      s_icd_code,3),"|",
     trim(m_prob->qual[ml_idx1].dqual[49].s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].dqual[50].
      s_icd_code,3),"|",trim(m_prob->qual[ml_idx1].s_updt_dt,3),
     "|","EMRSNOMED",char(13),char(10))
    SET stat = cclio("WRITE",frec)
   ENDIF
 ENDFOR
 SET stat = cclio("CLOSE",frec)
#exit_script
END GO

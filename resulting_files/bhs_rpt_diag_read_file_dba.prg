CREATE PROGRAM bhs_rpt_diag_read_file:dba
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 FREE RECORD m_diag
 RECORD m_diag(
   1 l_cnt = i4
   1 qual[*]
     2 s_dx = vc
     2 f_nomen_id = f8
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 ) WITH protect
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_fin = vc
     2 s_cmrn = vc
     2 s_pat_name = vc
     2 s_diag = vc
     2 s_diag_type = vc
     2 s_enc_type = vc
     2 s_reg_dt = vc
     2 s_disch_dt = vc
     2 s_hp = vc
 ) WITH protect
 IF (findfile("diag_test.dat",4) != 1)
  SET reply->text = "File al_enc_temp not found. This file is needed for the script to function."
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 "ccluserdir:diag_test.dat"
 SELECT INTO "nl:"
  FROM rtl2t r
  DETAIL
   m_diag->l_cnt += 1, stat = alterlist(m_diag->qual,m_diag->l_cnt), m_diag->qual[m_diag->l_cnt].s_dx
    = trim(r.line,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM nomenclature n
  PLAN (n
   WHERE expand(ml_idx1,1,m_diag->l_cnt,n.source_identifier,m_diag->qual[ml_idx1].s_dx)
    AND n.active_ind=1
    AND n.source_vocabulary_cd=444514158.00)
  ORDER BY n.source_identifier
  HEAD n.source_identifier
   ml_idx2 = locateval(ml_idx1,1,m_diag->l_cnt,n.source_identifier,m_diag->qual[ml_idx1].s_dx)
   IF (ml_idx2 > 0)
    m_diag->qual[ml_idx2].f_nomen_id = n.nomenclature_id
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   diagnosis d,
   encntr_alias ea,
   nomenclature n,
   encntr_plan_reltn epr,
   health_plan hp,
   person_alias pa
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime("01-JAN-2024 00:00:00") AND cnvtdatetime(
    "31-DEC-2024 23:59:59")
    AND e.active_ind=1
    AND e.encntr_type_cd IN (309310.00, 679658.00)
    AND  NOT (e.person_id IN (
   (SELECT
    e2.person_id
    FROM encounter e2
    WHERE e2.disch_dt_tm BETWEEN cnvtdatetime("01-JAN-2023 00:00:00") AND cnvtdatetime(
     "31-DEC-2023 23:59:59")
     AND e2.med_service_cd=1689816.00))))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1
    AND p.deceased_dt_tm = null)
   JOIN (d
   WHERE d.encntr_id=e.encntr_id
    AND d.active_ind=1
    AND expand(ml_idx1,1,m_diag->l_cnt,d.nomenclature_id,m_diag->qual[ml_idx1].f_nomen_id))
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea.encntr_alias_type_cd=1077)
   JOIN (epr
   WHERE (epr.encntr_id= Outerjoin(e.encntr_id))
    AND (epr.active_ind= Outerjoin(1))
    AND (epr.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (hp
   WHERE (hp.health_plan_id= Outerjoin(epr.health_plan_id)) )
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND pa.person_alias_type_cd=2)
  ORDER BY e.person_id, e.encntr_id, epr.priority_seq
  HEAD e.person_id
   null
  HEAD e.encntr_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_person_id = e.person_id,
   m_rec->qual[m_rec->l_cnt].f_encntr_id = e.encntr_id, m_rec->qual[m_rec->l_cnt].s_pat_name = trim(p
    .name_full_formatted,3), m_rec->qual[m_rec->l_cnt].s_fin = trim(ea.alias,3),
   m_rec->qual[m_rec->l_cnt].s_cmrn = trim(pa.alias,3), m_rec->qual[m_rec->l_cnt].s_diag = trim(n
    .source_identifier,3), m_rec->qual[m_rec->l_cnt].s_diag_type = trim(uar_get_code_display(d
     .diag_type_cd),3),
   m_rec->qual[m_rec->l_cnt].s_enc_type = trim(uar_get_code_display(e.encntr_type_cd),3), m_rec->
   qual[m_rec->l_cnt].s_reg_dt = trim(format(e.reg_dt_tm,"MM/DD/YYYY;;q"),3), m_rec->qual[m_rec->
   l_cnt].s_disch_dt = trim(format(e.disch_dt_tm,"MM/DD/YYYY;;q"),3),
   m_rec->qual[m_rec->l_cnt].s_hp = trim(hp.plan_name,3)
  WITH nocounter, expand = 1
 ;end select
 SET frec->file_name = "bhs_rpt_diag_read_file.csv"
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = build('"',"FIN",'","',"CMRN",'","',
  "Patient",'","',"Encounter Type",'","',"Diagnosis",
  '","',"Diagnosis Type",'","',"Reg DT",'","',
  "Disch DT",'","',"Health Plan",'"',char(13),
  char(10))
 SET stat = cclio("WRITE",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   IF (size(trim(m_rec->qual[ml_idx1].s_diag,3)) > 0)
    SET frec->file_buf = build('"',trim(m_rec->qual[ml_idx1].s_fin,3),'","',trim(m_rec->qual[ml_idx1]
      .s_cmrn,3),'","',
     trim(m_rec->qual[ml_idx1].s_pat_name,3),'","',trim(m_rec->qual[ml_idx1].s_enc_type,3),'","',trim
     (m_rec->qual[ml_idx1].s_diag,3),
     '","',trim(m_rec->qual[ml_idx1].s_diag_type,3),'","',trim(m_rec->qual[ml_idx1].s_reg_dt,3),'","',
     trim(m_rec->qual[ml_idx1].s_disch_dt,3),'","',trim(m_rec->qual[ml_idx1].s_hp,3),'"',char(13),
     char(10))
    SET stat = cclio("WRITE",frec)
   ENDIF
 ENDFOR
 SET stat = cclio("CLOSE",frec)
#exit_script
END GO

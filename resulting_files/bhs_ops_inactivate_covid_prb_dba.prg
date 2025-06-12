CREATE PROGRAM bhs_ops_inactivate_covid_prb:dba
 DECLARE mf_cs400_snomed_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3240237"))
 DECLARE mf_cs12030_active_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3465"))
 DECLARE mf_cs71_inpatient_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3958"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_person_id = f8
     2 f_problem_id = f8
     2 l_skip_ind = i4
 ) WITH protect
 SELECT INTO "nl:"
  FROM problem p,
   nomenclature n
  PLAN (p
   WHERE p.beg_effective_dt_tm < cnvtdatetime((curdate - 21),0)
    AND p.life_cycle_status_cd=mf_cs12030_active_cd
    AND p.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id
    AND n.source_identifier IN ("2791866015", "3323230018", "3902358015")
    AND n.source_vocabulary_cd=mf_cs400_snomed_cd)
  ORDER BY p.person_id
  HEAD p.person_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_person_id = p.person_id,
   m_rec->qual[m_rec->l_cnt].f_problem_id = p.problem_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE expand(ml_idx1,1,m_rec->l_cnt,e.person_id,m_rec->qual[ml_idx1].f_person_id)
    AND e.active_ind=1
    AND e.reg_dt_tm IS NOT null
    AND e.disch_dt_tm = null
    AND e.encntr_type_cd=mf_cs71_inpatient_cd)
  ORDER BY e.person_id
  HEAD e.person_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,e.person_id,m_rec->qual[ml_idx1].f_person_id)
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].l_skip_ind = 1
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF ((m_rec->l_cnt > 0))
  FOR (ml_idx1 = 1 TO m_rec->l_cnt)
    IF ((m_rec->qual[ml_idx1].l_skip_ind=0))
     EXECUTE bhs_rule_fire "P", m_rec->qual[ml_idx1].f_person_id, "EKS_INACTIVATE_COVID"
    ENDIF
  ENDFOR
 ENDIF
END GO

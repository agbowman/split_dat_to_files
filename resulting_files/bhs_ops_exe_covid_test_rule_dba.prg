CREATE PROGRAM bhs_ops_exe_covid_test_rule:dba
 FREE RECORD m_rec
 RECORD m_rec(
   1 fac[*]
     2 cd = f8
     2 disp = vc
   1 nu[*]
     2 cd = f8
     2 disp = vc
   1 pat[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_fin = vc
     2 s_pat_name = vc
 ) WITH protect
 DECLARE mf_cs71_obs = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17613"))
 DECLARE mf_cs71_inpt = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3958"))
 DECLARE mf_cs71_iphospice = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"IPHOSPICE"))
 DECLARE mf_cs6004_ordered = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3102"))
 DECLARE ml_exp1 = i4 WITH protect, noconstant(0)
 DECLARE ml_exp2 = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND cv.cdf_meaning="FACILITY"
   AND cv.display_key IN ("BMC")
  HEAD REPORT
   pl_cnt = 0
  HEAD cv.code_value
   pl_cnt += 1,
   CALL alterlist(m_rec->fac,pl_cnt), m_rec->fac[pl_cnt].cd = cv.code_value,
   m_rec->fac[pl_cnt].disp = trim(cv.display,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND cv.cdf_meaning="NURSEUNIT"
   AND cv.display_key IN ("S3ONC1")
  HEAD REPORT
   pl_cnt = 0
  HEAD cv.code_value
   pl_cnt += 1,
   CALL alterlist(m_rec->nu,pl_cnt), m_rec->nu[pl_cnt].cd = cv.code_value,
   m_rec->nu[pl_cnt].disp = trim(cv.display,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encounter e,
   encntr_alias ea,
   person p
  PLAN (ed
   WHERE ed.active_ind=1
    AND expand(ml_exp1,1,size(m_rec->fac,5),ed.loc_facility_cd,m_rec->fac[ml_exp1].cd)
    AND expand(ml_exp2,1,size(m_rec->nu,5),ed.loc_nurse_unit_cd,m_rec->nu[ml_exp2].cd))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_cd IN (mf_cs71_obs, mf_cs71_inpt, mf_cs71_iphospice)
    AND e.active_ind=1
    AND e.disch_dt_tm=null)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=1077)
   JOIN (p
   WHERE p.person_id=e.person_id)
  HEAD REPORT
   pl_cnt = 0
  HEAD e.encntr_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->pat,5))
    CALL alterlist(m_rec->pat,(pl_cnt+ 100))
   ENDIF
   m_rec->pat[pl_cnt].f_person_id = e.person_id, m_rec->pat[pl_cnt].f_encntr_id = e.encntr_id, m_rec
   ->pat[pl_cnt].s_fin = trim(ea.alias,3),
   m_rec->pat[pl_cnt].s_pat_name = trim(p.name_full_formatted,3)
  FOOT REPORT
   CALL alterlist(m_rec->pat,pl_cnt),
   CALL echo(build2("pl_cnt : ",pl_cnt))
  WITH nocounter
 ;end select
 FOR (ml_loop = 1 TO size(m_rec->pat,5))
  EXECUTE bhs_rule_fire "E", m_rec->pat[ml_loop].f_encntr_id, "BHS_ASY_ORD_COVID_TEST2"
  CALL echo(concat(m_rec->pat[ml_loop].s_fin," ",m_rec->pat[ml_loop].s_pat_name))
 ENDFOR
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO

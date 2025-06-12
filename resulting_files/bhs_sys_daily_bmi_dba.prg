CREATE PROGRAM bhs_sys_daily_bmi:dba
 FREE RECORD m_info
 RECORD m_info(
   1 new[*]
     2 f_person_id = f8
     2 s_person_name = vc
     2 f_phys_id = f8
     2 n_exists_ind = i2
   1 updt[*]
     2 f_person_id = f8
     2 f_pcp_id = f8
     2 n_updt_ind = i2
 ) WITH protect
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 ) WITH protect
 DECLARE mf_pcp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",331,"PCP"))
 DECLARE mf_bmi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"BODYMASSINDEX"))
 DECLARE mf_95_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",30443,"95"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"ACTIVE"))
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE md_action_dt_tm = dq8 WITH protect, noconstant(0)
 DECLARE md_beg_dt_tm = dq8 WITH protect, noconstant(0)
 DECLARE md_end_dt_tm = dq8 WITH protect, noconstant(0)
 DECLARE md_2_yrs_dt_tm = dq8 WITH protect, noconstant(0)
 DECLARE md_21_yrs_dt_tm = dq8 WITH protect, noconstant(0)
 IF (validate(request->batch_selection))
  SET md_action_dt_tm = datetimeadd(cnvtdatetime(request->ops_date),- (1))
  IF (md_action_dt_tm <= 0)
   SET d_action_dt_tm = datetimeadd(cnvtdatetime(curdate,curtime3),- (1))
  ENDIF
  SET md_beg_dt_tm = datetimefind(md_action_dt_tm,"D","B","B")
  SET md_end_dt_tm = datetimefind(md_action_dt_tm,"D","E","E")
 ELSE
  SET md_beg_dt_tm = cnvtdatetime("01-NOV-2008 00:00:00")
  SET md_end_dt_tm = cnvtdatetime("04-NOV-2009 23:59:59")
 ENDIF
 CALL echo(concat("md_beg_dt_tm: ",format(md_beg_dt_tm,"mm-dd-yy;;d")))
 CALL echo(concat("md_end_dt_tm: ",format(md_end_dt_tm,"mm-dd-yy;;d")))
 SET md_2_yrs_dt_tm = datetimeadd(sysdate,- ((2 * 365)))
 CALL echo(concat("2 yrs ago: ",format(md_2_yrs_dt_tm,"mm-dd-yyyy hh:mm:ss;;d")))
 SET md_21_yrs_dt_tm = datetimeadd(cnvtdatetime(curdate,curtime3),- ((21 * 365)))
 CALL echo(concat("21yrs ago: ",format(md_21_yrs_dt_tm,"mm-dd-yyyy hh:mm:ss;;d")))
 SELECT INTO "nl:"
  FROM bhs_problem_registry b,
   person_prsnl_reltn ppr
  PLAN (b
   WHERE b.problem="OBESITY")
   JOIN (ppr
   WHERE ppr.person_id=b.person_id
    AND ppr.person_prsnl_r_cd=mf_pcp_cd
    AND ppr.active_ind=1
    AND ppr.end_effective_dt_tm > sysdate
    AND ppr.prsnl_person_id != b.pcp_id)
  HEAD REPORT
   pn_cnt = 0
  DETAIL
   pn_cnt = (pn_cnt+ 1)
   IF (pn_cnt > size(m_info->updt,5))
    stat = alterlist(m_info->updt,(pn_cnt+ 10))
   ENDIF
   m_info->updt[pn_cnt].f_person_id = b.person_id, m_info->updt[pn_cnt].f_pcp_id = ppr
   .prsnl_person_id, m_info->updt[pn_cnt].n_updt_ind = 1
  FOOT REPORT
   stat = alterlist(m_info->updt,pn_cnt)
  WITH nocounter
 ;end select
 IF (size(m_info->updt,5) > 0)
  UPDATE  FROM bhs_problem_registry b,
    (dummyt d  WITH seq = value(size(m_info->updt,5)))
   SET b.pcp_id = m_info->updt[d.seq].f_pcp_id
   PLAN (d)
    JOIN (b
    WHERE (b.person_id=m_info->updt[d.seq].f_person_id)
     AND b.problem="CHF"
     AND b.active_ind=1)
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 CALL echo("find problems")
 SELECT INTO "nl:"
  FROM bhs_nomen_list n,
   problem pr,
   person p
  PLAN (n
   WHERE n.nomen_list_key="REGISTRY-BMI")
   JOIN (pr
   WHERE pr.nomenclature_id=n.nomenclature_id
    AND pr.active_ind=1
    AND pr.life_cycle_status_cd=mf_active_cd
    AND pr.updt_dt_tm BETWEEN cnvtdatetime(md_beg_dt_tm) AND cnvtdatetime(md_end_dt_tm))
   JOIN (p
   WHERE p.person_id=pr.person_id
    AND p.birth_dt_tm BETWEEN cnvtdatetime(md_21_yrs_dt_tm) AND cnvtdatetime(md_2_yrs_dt_tm))
  ORDER BY pr.person_id
  HEAD REPORT
   pn_cnt = 0
  HEAD pr.person_id
   pn_cnt = (pn_cnt+ 1)
   IF (pn_cnt > size(m_info->new,5))
    stat = alterlist(m_info->new,(pn_cnt+ 10))
   ENDIF
   m_info->new[pn_cnt].f_person_id = pr.person_id, m_info->new[pn_cnt].s_person_name = trim(p
    .name_full_formatted)
  FOOT REPORT
   stat = alterlist(m_info->new,pn_cnt)
  WITH nocounter
 ;end select
 CALL echo("find diagnoses")
 SELECT INTO "nl:"
  FROM bhs_nomen_list n,
   diagnosis d,
   person p
  PLAN (n
   WHERE n.nomen_list_key="REGISTRY-BMI")
   JOIN (d
   WHERE d.nomenclature_id=n.nomenclature_id
    AND d.active_ind=1
    AND d.updt_dt_tm BETWEEN cnvtdatetime(md_beg_dt_tm) AND cnvtdatetime(md_end_dt_tm))
   JOIN (p
   WHERE p.person_id=d.person_id
    AND p.birth_dt_tm BETWEEN cnvtdatetime(md_21_yrs_dt_tm) AND cnvtdatetime(md_2_yrs_dt_tm))
  ORDER BY d.person_id
  HEAD REPORT
   pn_cnt = size(m_info->new,5), ml_idx = 0
  HEAD d.person_id
   IF (pn_cnt > 0)
    ml_idx = locateval(ml_num,1,pn_cnt,d.person_id,m_info->new[ml_num].f_person_id)
   ENDIF
   IF (((pn_cnt=0) OR (ml_idx=0)) )
    pn_cnt = (pn_cnt+ 1)
    IF (pn_cnt > size(m_info->new,5))
     stat = alterlist(m_info->new,(pn_cnt+ 10))
    ENDIF
    m_info->new[pn_cnt].f_person_id = d.person_id, m_info->new[pn_cnt].s_person_name = trim(p
     .name_full_formatted)
   ENDIF
  FOOT REPORT
   stat = alterlist(m_info->new,pn_cnt)
  WITH nocounter
 ;end select
 CALL echo("look for bmi > 95%")
 SELECT INTO "nl:"
  FROM hm_expect_sat hes,
   hm_expect_mod hem,
   person p
  PLAN (hes
   WHERE hes.expect_sat_name="BMI Percentile"
    AND hes.active_ind=1)
   JOIN (hem
   WHERE hem.expect_sat_id=hes.expect_sat_id
    AND hem.active_ind=1
    AND hem.updt_dt_tm BETWEEN cnvtdatetime(md_beg_dt_tm) AND cnvtdatetime(md_end_dt_tm)
    AND hem.modifier_reason_cd=mf_95_cd)
   JOIN (p
   WHERE p.person_id=hem.person_id
    AND p.birth_dt_tm BETWEEN cnvtdatetime(md_21_yrs_dt_tm) AND cnvtdatetime(md_2_yrs_dt_tm))
  HEAD REPORT
   pn_cnt = size(m_info->new,5)
  DETAIL
   IF (pn_cnt > 0)
    ml_idx = locateval(ml_num,1,pn_cnt,p.person_id,m_info->new[ml_num].f_person_id)
   ENDIF
   IF (((pn_cnt=0) OR (ml_idx=0)) )
    pn_cnt = (pn_cnt+ 1)
    IF (pn_cnt > size(m_info->new,5))
     stat = alterlist(m_info->new,(pn_cnt+ 10))
    ENDIF
    m_info->new[pn_cnt].f_person_id = p.person_id, m_info->new[pn_cnt].s_person_name = trim(p
     .name_full_formatted)
   ENDIF
  FOOT REPORT
   stat = alterlist(m_info->new,pn_cnt)
  WITH nocounter
 ;end select
 CALL echo("look for bmi > 30")
 SELECT INTO "nl:"
  pl_bmi = cnvtreal(ce.result_val)
  FROM clinical_event ce,
   person p
  PLAN (ce
   WHERE ce.event_cd=mf_bmi_cd
    AND ce.updt_dt_tm BETWEEN cnvtdatetime(md_beg_dt_tm) AND cnvtdatetime(md_end_dt_tm)
    AND ce.valid_from_dt_tm BETWEEN cnvtdatetime(md_beg_dt_tm) AND cnvtdatetime(md_end_dt_tm)
    AND ce.valid_until_dt_tm >= sysdate)
   JOIN (p
   WHERE p.person_id=ce.person_id
    AND p.birth_dt_tm BETWEEN cnvtdatetime(md_21_yrs_dt_tm) AND cnvtdatetime(md_2_yrs_dt_tm))
  ORDER BY ce.person_id, ce.clinsig_updt_dt_tm DESC
  HEAD REPORT
   pn_cnt = size(m_info->new,5)
  HEAD p.person_id
   IF (pl_bmi > 30)
    IF (pn_cnt > 0)
     ml_idx = locateval(ml_num,1,pn_cnt,p.person_id,m_info->new[ml_num].f_person_id)
    ENDIF
    IF (((pn_cnt=0) OR (ml_idx=0)) )
     pn_cnt = (pn_cnt+ 1)
     IF (pn_cnt > size(m_info->new,5))
      stat = alterlist(m_info->new,(pn_cnt+ 10))
     ENDIF
     m_info->new[pn_cnt].f_person_id = p.person_id, m_info->new[pn_cnt].s_person_name = trim(p
      .name_full_formatted)
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(m_info->new,pn_cnt)
  WITH nocounter
 ;end select
 IF (size(m_info->new,5)=0)
  CALL echo("no records found")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_info->new,5))),
   person_prsnl_reltn ppr,
   prsnl p
  PLAN (d)
   JOIN (ppr
   WHERE (ppr.person_id=m_info->new[d.seq].f_person_id)
    AND ppr.person_prsnl_r_cd=mf_pcp_cd
    AND ppr.active_ind=1
    AND ppr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id
    AND p.name_last_key != "NOTONSTAFF")
  ORDER BY ppr.person_id
  HEAD ppr.person_id
   m_info->new[d.seq].f_phys_id = ppr.prsnl_person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_info->new,5))),
   bhs_problem_registry b
  PLAN (d)
   JOIN (b
   WHERE (b.person_id=m_info->new[d.seq].f_person_id)
    AND b.problem="OBESITY")
  DETAIL
   m_info->new[d.seq].n_exists_ind = 1
  WITH nocounter
 ;end select
 CALL echo("insert")
 INSERT  FROM (dummyt d  WITH seq = value(size(m_info->new,5))),
   bhs_problem_registry b
  SET b.active_ind = 1, b.pcp_id = m_info->new[d.seq].f_phys_id, b.person_id = m_info->new[d.seq].
   f_person_id,
   b.practice_id = 0.00, b.problem = "OBESITY"
  PLAN (d
   WHERE (m_info->new[d.seq].n_exists_ind=0))
   JOIN (b)
  WITH nocounter
 ;end insert
 COMMIT
#exit_script
 FREE RECORD m_info
END GO

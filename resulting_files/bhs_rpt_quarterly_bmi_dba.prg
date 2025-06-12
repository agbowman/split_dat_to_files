CREATE PROGRAM bhs_rpt_quarterly_bmi:dba
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD m_info
 RECORD m_info(
   1 prac[*]
     2 f_practice_id = f8
     2 s_practice_name = vc
     2 s_email = vc
     2 pat[*]
       3 f_person_id = f8
       3 f_pcp_id = f8
       3 s_patient_name = vc
       3 s_patient_age = vc
       3 s_mrn = vc
       3 s_street1 = vc
       3 s_street2 = vc
       3 s_street3 = vc
       3 s_street4 = vc
       3 s_city = vc
       3 s_state = vc
       3 s_zip = vc
       3 s_problems = vc
       3 s_diagnoses = vc
       3 s_latest_bmi = vc
       3 s_latest_bmi_per = vc
       3 s_glucose = vc
       3 s_cholesterol = vc
       3 s_trigylcerides = vc
       3 s_hdl = vc
       3 s_ldl = vc
       3 s_ast = vc
       3 s_alt = vc
       3 s_bun = vc
       3 s_creatinine = vc
       3 s_tsh = vc
       3 s_hgba1c = vc
 ) WITH protect
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE mf_bmi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"BODYMASSINDEX"))
 DECLARE mf_general_lab_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"GLB"))
 DECLARE mf_laboratory_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"GENERAL LAB"))
 DECLARE mf_bun_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BUN"))
 DECLARE mf_hg_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HEMOGLOBINA1CMONITORING"))
 DECLARE mf_tsh_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"TSH"))
 DECLARE mf_creatinine_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CREATININE"))
 DECLARE mf_alt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ALT"))
 DECLARE mf_ast_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"AST"))
 DECLARE mf_glucose_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"GLUCOSELEVEL"))
 DECLARE mf_lipid_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"LIPIDPANEL"))
 DECLARE mf_cholesterol_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"CHOLESTEROL")
  )
 DECLARE mf_triglycerides_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TRIGLYCERIDES"))
 DECLARE mf_hdl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"HDLCHOLESTEROL"))
 DECLARE mf_ldl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"LDLCHOLESTEROL"))
 DECLARE ms_file_name = vc WITH protect, constant("obesity_quarterly_reg.xls")
 DECLARE mn_month = i2 WITH protect, noconstant(0)
 DECLARE ms_tmp_str = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_dclcom_str = vc WITH protect, noconstant(" ")
 DECLARE ml_dclcom_len = i4 WITH protect, noconstant(0.0)
 DECLARE mn_dclcom_stat = i2 WITH protect, noconstant(0)
 DECLARE mn_loop_cnt = i4 WITH protect, noconstant(0)
 IF (validate(request->batch_selection))
  SET mn_month = month(cnvtdatetime(request->ops_date))
  IF (cnvtdatetime(request->ops_date) <= 0)
   SET mn_month = month(cnvtdatetime(sysdate))
  ENDIF
  IF ( NOT (mn_month IN (1, 4, 7, 10)))
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  b1.location_id, b2.person_id
  FROM bhs_practice_location b1,
   bhs_physician_location b2,
   bhs_problem_registry b3
  PLAN (b1
   WHERE b1.email != null)
   JOIN (b2
   WHERE b2.location_id=b1.location_id)
   JOIN (b3
   WHERE b3.pcp_id=b2.person_id
    AND b3.active_ind=1
    AND b3.problem="OBESITY")
  HEAD REPORT
   pn_head_cnt = 0, pn_det_cnt = 0
  HEAD b1.location_id
   pn_head_cnt += 1
   IF (pn_head_cnt > size(m_info->prac,5))
    stat = alterlist(m_info->prac,(pn_head_cnt+ 10))
   ENDIF
   m_info->prac[pn_head_cnt].f_practice_id = b1.location_id, m_info->prac[pn_head_cnt].
   s_practice_name = trim(b1.location_description), m_info->prac[pn_head_cnt].s_email = trim(b1.email
    ),
   pn_det_cnt = 0
  DETAIL
   pn_det_cnt += 1
   IF (pn_det_cnt > size(m_info->prac[pn_head_cnt].pat,5))
    stat = alterlist(m_info->prac[pn_head_cnt].pat,(pn_det_cnt+ 10))
   ENDIF
   m_info->prac[pn_head_cnt].pat[pn_det_cnt].f_person_id = b3.person_id, m_info->prac[pn_head_cnt].
   pat[pn_det_cnt].f_pcp_id = b3.pcp_id
  FOOT  b1.location_id
   stat = alterlist(m_info->prac[pn_head_cnt].pat,pn_det_cnt)
  FOOT REPORT
   stat = alterlist(m_info->prac,pn_head_cnt)
  WITH nocounter
 ;end select
 IF (size(m_info->prac,5)=0)
  CALL echo("no records found")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(m_info->prac,5))),
   dummyt d2,
   person p,
   person_alias pa,
   address a,
   bhs_problem_registry b
  PLAN (d1
   WHERE maxrec(d2,size(m_info->prac[d1.seq].pat,5)))
   JOIN (d2)
   JOIN (p
   WHERE (p.person_id=m_info->prac[d1.seq].pat[d2.seq].f_person_id)
    AND p.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mf_mrn_cd
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (a
   WHERE (a.parent_entity_id= Outerjoin(p.person_id))
    AND (a.parent_entity_name= Outerjoin("PERSON")) )
   JOIN (b
   WHERE b.person_id=p.person_id
    AND b.problem="OBESITY")
  ORDER BY p.person_id, pa.active_status_dt_tm DESC
  HEAD p.person_id
   pn_done_ind = 0, m_info->prac[d1.seq].pat[d2.seq].s_patient_name = trim(p.name_full_formatted),
   m_info->prac[d1.seq].pat[d2.seq].s_patient_age = trim(substring(1,3,cnvtage(cnvtdatetimeutc(
       datetimezone(p.birth_dt_tm,p.birth_tz),1))),3),
   m_info->prac[d1.seq].pat[d2.seq].s_city = trim(a.city), m_info->prac[d1.seq].pat[d2.seq].s_state
    = trim(a.state), m_info->prac[d1.seq].pat[d2.seq].s_street1 = trim(a.street_addr),
   m_info->prac[d1.seq].pat[d2.seq].s_street2 = trim(a.street_addr2), m_info->prac[d1.seq].pat[d2.seq
   ].s_street3 = trim(a.street_addr3), m_info->prac[d1.seq].pat[d2.seq].s_street4 = trim(a
    .street_addr4),
   m_info->prac[d1.seq].pat[d2.seq].s_zip = format(trim(a.zipcode),"#####;p0")
  HEAD pa.active_status_dt_tm
   IF (pn_done_ind=0)
    IF (pa.alias != "RAD*")
     m_info->prac[d1.seq].pat[d2.seq].s_mrn = trim(pa.alias), pn_done_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("look for bmi > 30")
 SELECT INTO "nl:"
  pl_bmi = cnvtreal(ce.result_val)
  FROM (dummyt d1  WITH seq = value(size(m_info->prac,5))),
   dummyt d2,
   clinical_event ce
  PLAN (d1
   WHERE maxrec(d2,size(m_info->prac[d1.seq].pat,5)))
   JOIN (d2)
   JOIN (ce
   WHERE (ce.person_id=m_info->prac[d1.seq].pat[d2.seq].f_person_id)
    AND ce.event_cd=mf_bmi_cd)
  ORDER BY ce.person_id, ce.valid_from_dt_tm DESC
  HEAD REPORT
   pn_cnt = 0
  DETAIL
   pn_cnt += 1
   IF (pn_cnt=1)
    m_info->prac[d1.seq].pat[d2.seq].s_latest_bmi = trim(ce.result_val)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("get percentiles")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(m_info->prac,5))),
   dummyt d2,
   hm_expect_sat hes,
   hm_expect_mod hem
  PLAN (d1
   WHERE maxrec(d2,size(m_info->prac[d1.seq].pat,5)))
   JOIN (d2)
   JOIN (hem
   WHERE (hem.person_id=m_info->prac[d1.seq].pat[d2.seq].f_person_id)
    AND hem.active_ind=1)
   JOIN (hes
   WHERE hes.expect_sat_name="BMI Percentile"
    AND hes.expect_sat_id=hem.expect_sat_id
    AND hes.active_ind=1)
  ORDER BY hem.person_id, hem.modifier_dt_tm DESC
  HEAD REPORT
   pn_cnt = 0
  DETAIL
   pn_cnt += 1
   IF (pn_cnt=1)
    m_info->prac[d1.seq].pat[d1.seq].s_latest_bmi_per = trim(uar_get_code_display(hem
      .modifier_reason_cd))
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("get problems")
 SELECT INTO "nl:"
  pf_person_id = m_info->prac[d1.seq].pat[d2.seq].f_person_id
  FROM (dummyt d1  WITH seq = value(size(m_info->prac,5))),
   dummyt d2,
   bhs_nomen_list l,
   nomenclature n,
   problem p
  PLAN (d1
   WHERE maxrec(d2,size(m_info->prac[d1.seq].pat,5)))
   JOIN (d2)
   JOIN (p
   WHERE (p.person_id=m_info->prac[d1.seq].pat[d2.seq].f_person_id)
    AND p.active_ind=1)
   JOIN (l
   WHERE l.nomenclature_id=p.nomenclature_id
    AND l.nomen_list_key="REGISTRY-BMI")
   JOIN (n
   WHERE n.nomenclature_id=l.nomenclature_id
    AND n.active_ind=1)
  ORDER BY p.person_id
  HEAD pf_person_id
   ms_tmp_str = "", pn_cnt = 0
  DETAIL
   IF (pn_cnt=0)
    ms_tmp_str = trim(n.source_string), pn_cnt = 1
   ELSE
    ms_tmp_str = concat(trim(ms_tmp_str),"; ",trim(n.source_string))
   ENDIF
  FOOT  pf_person_id
   m_info->prac[d1.seq].pat[d2.seq].s_problems = ms_tmp_str
  WITH nocounter
 ;end select
 CALL echo("get diagnoses")
 SELECT INTO "nl:"
  pf_person_id = m_info->prac[d1.seq].pat[d2.seq].f_person_id
  FROM (dummyt d1  WITH seq = value(size(m_info->prac,5))),
   dummyt d2,
   bhs_nomen_list l,
   nomenclature n,
   diagnosis p
  PLAN (d1
   WHERE maxrec(d2,size(m_info->prac[d1.seq].pat,5)))
   JOIN (d2)
   JOIN (p
   WHERE (p.person_id=m_info->prac[d1.seq].pat[d2.seq].f_person_id)
    AND p.active_ind=1)
   JOIN (l
   WHERE l.nomenclature_id=p.nomenclature_id
    AND l.nomen_list_key="REGISTRY-BMI")
   JOIN (n
   WHERE n.nomenclature_id=l.nomenclature_id
    AND n.active_ind=1)
  ORDER BY p.person_id
  HEAD pf_person_id
   ms_tmp_str = "", pn_cnt = 0
  DETAIL
   IF (pn_cnt=0)
    ms_tmp_str = trim(n.source_string), pn_cnt = 1
   ELSE
    ms_tmp_str = concat(trim(ms_tmp_str),"; ",trim(n.source_string))
   ENDIF
  FOOT  pf_person_id
   m_info->prac[d1.seq].pat[d2.seq].s_diagnoses = ms_tmp_str
  WITH nocounter
 ;end select
 CALL echo("get resus/labs/vents")
 SELECT INTO "nl:"
  o.active_status_dt_tm, ps_unit = trim(uar_get_code_display(ce.result_units_cd))
  FROM (dummyt d1  WITH seq = value(size(m_info->prac,5))),
   dummyt d2,
   clinical_event ce,
   orders o
  PLAN (d1
   WHERE maxrec(d2,size(m_info->prac[d1.seq].pat,5)))
   JOIN (d2)
   JOIN (o
   WHERE (o.person_id=m_info->prac[d1.seq].pat[d2.seq].f_person_id)
    AND o.activity_type_cd IN (mf_general_lab_cd)
    AND o.catalog_type_cd IN (mf_laboratory_cd)
    AND o.catalog_cd IN (mf_bun_cd, mf_hg_cd, mf_tsh_cd, mf_creatinine_cd, mf_alt_cd,
   mf_ast_cd, mf_glucose_cd, mf_lipid_cd))
   JOIN (ce
   WHERE ce.order_id=o.order_id
    AND ce.view_level=1)
  ORDER BY o.active_status_dt_tm
  DETAIL
   ms_tmp_str = trim(ce.result_val)
   CASE (o.catalog_cd)
    OF mf_bun_cd:
     m_info->prac[d1.seq].pat[d2.seq].s_bun = ms_tmp_str
    OF mf_hg_cd:
     m_info->prac[d1.seq].pat[d2.seq].s_hgba1c = ms_tmp_str
    OF mf_tsh_cd:
     m_info->prac[d1.seq].pat[d2.seq].s_tsh = ms_tmp_str
    OF mf_creatinine_cd:
     m_info->prac[d1.seq].pat[d2.seq].s_creatinine = ms_tmp_str
    OF mf_alt_cd:
     m_info->prac[d1.seq].pat[d2.seq].s_alt = ms_tmp_str
    OF mf_ast_cd:
     m_info->prac[d1.seq].pat[d2.seq].s_ast = ms_tmp_str
    OF mf_glucose_cd:
     m_info->prac[d1.seq].pat[d2.seq].s_glucose = ms_tmp_str
    OF mf_lipid_cd:
     IF (ce.event_cd=mf_cholesterol_cd)
      m_info->prac[d1.seq].pat[d2.seq].s_cholesterol = ms_tmp_str
     ELSEIF (ce.event_cd=mf_triglycerides_cd)
      m_info->prac[d1.seq].pat[d2.seq].s_trigylcerides = ms_tmp_str
     ELSEIF (ce.event_cd=mf_hdl_cd)
      m_info->prac[d1.seq].pat[d2.seq].s_hdl = ms_tmp_str
     ELSEIF (ce.event_cd=mf_ldl_cd)
      m_info->prac[d1.seq].pat[d2.seq].s_ldl = ms_tmp_str
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 FOR (mn_loop_cnt = 1 TO size(m_info->prac,5))
  SELECT INTO value(ms_file_name)
   pn_name = m_info->prac[mn_loop_cnt].pat[d.seq].s_patient_name
   FROM (dummyt d  WITH seq = value(size(m_info->prac[mn_loop_cnt].pat,5)))
   PLAN (d)
   ORDER BY pn_name
   HEAD REPORT
    ms_tmp_str = "Obesity Registry Report for ", m_info->prac[mn_loop_cnt].s_practice_name, col 0,
    ms_tmp_str, row + 1, ms_tmp_str = concat("Patient Name",char(9),"Age",char(9),"MRN",
     char(9),"Street Address",char(9),"City",char(9),
     "State",char(9),"Zip Code",char(9),"Latest BMI Result",
     char(9),"Latest BMI Percentile",char(9),"Glucose",char(9),
     "Cholesterol",char(9),"Triglycerides",char(9),"HDL",
     char(9),"LDL",char(9),"AST",char(9),
     "ALT",char(9),"BUN",char(9),"Creatinine",
     char(9),"TSH",char(9),"HgbA1C"),
    col 0, ms_tmp_str,
    CALL echo(ms_tmp_str),
    row + 1
   DETAIL
    ms_tmp_str = concat(m_info->prac[mn_loop_cnt].pat[d.seq].s_patient_name,char(9),m_info->prac[
     mn_loop_cnt].pat[d.seq].s_patient_age,char(9),m_info->prac[mn_loop_cnt].pat[d.seq].s_mrn,
     char(9),trim(concat(m_info->prac[mn_loop_cnt].pat[d.seq].s_street1," ",m_info->prac[mn_loop_cnt]
       .pat[d.seq].s_street2," ",m_info->prac[mn_loop_cnt].pat[d.seq].s_street3,
       " ",m_info->prac[mn_loop_cnt].pat[d.seq].s_street4)),char(9),m_info->prac[mn_loop_cnt].pat[d
     .seq].s_city,char(9),
     m_info->prac[mn_loop_cnt].pat[d.seq].s_state,char(9),m_info->prac[mn_loop_cnt].pat[d.seq].s_zip,
     char(9),m_info->prac[mn_loop_cnt].pat[d.seq].s_latest_bmi,
     char(9),m_info->prac[mn_loop_cnt].pat[d.seq].s_latest_bmi_per,char(9),m_info->prac[mn_loop_cnt].
     pat[d.seq].s_glucose,char(9),
     m_info->prac[mn_loop_cnt].pat[d.seq].s_cholesterol,char(9),m_info->prac[mn_loop_cnt].pat[d.seq].
     s_trigylcerides,char(9),m_info->prac[mn_loop_cnt].pat[d.seq].s_hdl,
     char(9),m_info->prac[mn_loop_cnt].pat[d.seq].s_ldl,char(9),m_info->prac[mn_loop_cnt].pat[d.seq].
     s_ast,char(9),
     m_info->prac[mn_loop_cnt].pat[d.seq].s_alt,char(9),m_info->prac[mn_loop_cnt].pat[d.seq].s_bun,
     char(9),m_info->prac[mn_loop_cnt].pat[d.seq].s_creatinine,
     char(9),m_info->prac[mn_loop_cnt].pat[d.seq].s_tsh,char(9),m_info->prac[mn_loop_cnt].pat[d.seq].
     s_hgba1c), col 0, ms_tmp_str,
    CALL echo(ms_tmp_str), row + 1
   WITH nocounter, maxcol = 1000, formfeed = none
  ;end select
  IF (findfile(ms_file_name)=1)
   SET ms_tmp_str = build2("QUARTERLY OBESITY REGISTRY FOR ",m_info->prac[mn_loop_cnt].
    s_practice_name)
   CALL emailfile("obesity_quarterly_reg.xls","obesity_quarterly_reg.xls",trim(m_info->prac[
     mn_loop_cnt].s_email),ms_tmp_str,1)
   SET ms_tmp_str = concat("The report was emailed to ",trim(m_info->prac[mn_loop_cnt].s_email))
  ENDIF
 ENDFOR
 SET reply->status_data[1].status = "S"
#exit_script
 FREE RECORD m_info
END GO

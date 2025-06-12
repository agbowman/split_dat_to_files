CREATE PROGRAM bhs_rpt_bmi_prompts:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Choose the type of report" = 0,
  "Enter the practice's password" = "",
  "Choose the physician" = 0,
  "Choose a practice" = 0,
  "Enter email address(es) separated by a space" = ""
  WITH outdev, n_type, s_pass,
  f_pcp_id, f_practice_id, s_email
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD m_info
 RECORD m_info(
   1 pat[*]
     2 f_person_id = f8
     2 s_patient_name = vc
     2 s_patient_age = vc
     2 f_phys_id = f8
     2 s_mrn = vc
     2 s_street1 = vc
     2 s_street2 = vc
     2 s_street3 = vc
     2 s_street4 = vc
     2 s_city = vc
     2 s_state = vc
     2 s_zip = vc
     2 s_problems = vc
     2 s_diagnoses = vc
     2 s_latest_bmi = vc
     2 s_latest_bmi_dt_tm = vc
     2 s_previous_bmi = vc
     2 s_latest_bmi_per = vc
     2 s_latest_bmi_per_dt_tm = vc
     2 s_previous_bmi_per = vc
     2 s_glucose = vc
     2 s_cholesterol = vc
     2 s_trigylcerides = vc
     2 s_hdl = vc
     2 s_ldl = vc
     2 s_ast = vc
     2 s_alt = vc
     2 s_bun = vc
     2 s_creatinine = vc
     2 s_tsh = vc
     2 s_hgba1c = vc
 ) WITH protect
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
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
 DECLARE mf_bmi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"BODYMASSINDEX"))
 DECLARE mf_95_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",30443,"95"))
 DECLARE ms_file_name = vc WITH protect, constant("obesity_reg.xls")
 DECLARE ms_pcp_id = vc WITH protect, noconstant(" ")
 DECLARE ms_parse_str = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp_str = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_requester_name = vc WITH protect, noconstant(" ")
 IF (( $N_TYPE=0))
  SELECT INTO  $OUTDEV
   FROM dummyt d
   PLAN (d)
   DETAIL
    col 0, "You did not select a report type. Choose a report type."
   WITH nocounter
  ;end select
  GO TO exit_script
 ELSEIF (( $N_TYPE=1))
  IF (( $F_PCP_ID=0))
   SELECT INTO  $OUTDEV
    FROM dummyt d
    PLAN (d)
    DETAIL
     col 0, "You did not select a physician. Choose a physician."
    WITH nocounter
   ;end select
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE (p.person_id= $F_PCP_ID)
     AND p.active_ind=1)
   DETAIL
    ms_requester_name = trim(p.name_full_formatted)
   WITH nocounter
  ;end select
  SET ms_pcp_id = trim(cnvtstring( $F_PCP_ID))
 ELSEIF (( $N_TYPE=2))
  IF (( $F_PRACTICE_ID=0))
   SELECT INTO  $OUTDEV
    FROM dummyt d
    PLAN (d)
    DETAIL
     col 0, "You did not select a practice. Choose a practice."
    WITH nocounter
   ;end select
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM bhs_practice_location b1,
    bhs_physician_location b2
   PLAN (b1
    WHERE (b1.location_id= $F_PRACTICE_ID))
    JOIN (b2
    WHERE b2.location_id=b1.location_id)
   ORDER BY b2.person_id
   HEAD REPORT
    ms_requester_name = b1.location_description, pn_first_ind = 0
   HEAD b2.person_id
    IF (pn_first_ind=0)
     ms_pcp_id = concat(trim(cnvtstring(b2.person_id))), pn_first_ind = 1
    ELSE
     ms_pcp_id = concat(ms_pcp_id,", ",trim(cnvtstring(b2.person_id)))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (findstring("@", $S_EMAIL)=0)
  CALL echo("here6")
  SELECT INTO  $OUTDEV
   FROM dummyt d
   PLAN (d)
   DETAIL
    col 0, "Enter a valid email address."
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 SET ms_parse_str = concat("b.pcp_id in (",ms_pcp_id,")")
 CALL echo("get patients")
 SELECT INTO "nl:"
  FROM bhs_problem_registry b
  PLAN (b
   WHERE parser(ms_parse_str)
    AND b.active_ind=1
    AND b.problem="OBESITY")
  HEAD REPORT
   pn_cnt = 0
  DETAIL
   pn_cnt += 1
   IF (pn_cnt > size(m_info->pat,5))
    stat = alterlist(m_info->pat,(pn_cnt+ 10))
   ENDIF
   m_info->pat[pn_cnt].f_person_id = b.person_id, m_info->pat[pn_cnt].f_phys_id = b.pcp_id
  FOOT REPORT
   stat = alterlist(m_info->pat,pn_cnt)
  WITH nocounter
 ;end select
 IF (size(m_info->pat,5)=0)
  CALL echo("no patients found")
  GO TO exit_script
 ENDIF
 CALL echo("get patient demographics")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_info->pat,5))),
   person p,
   person_alias pa,
   address a,
   bhs_problem_registry b
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=m_info->pat[d.seq].f_person_id)
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
   pn_done_ind = 0, m_info->pat[d.seq].s_patient_name = trim(p.name_full_formatted), m_info->pat[d
   .seq].s_patient_age = trim(cnvtstring((datetimediff(sysdate,cnvtdatetimeutc(datetimezone(p
        .birth_dt_tm,p.birth_tz),1),1)/ 365))),
   m_info->pat[d.seq].s_city = trim(a.city), m_info->pat[d.seq].s_state = trim(a.state), m_info->pat[
   d.seq].s_street1 = trim(a.street_addr),
   m_info->pat[d.seq].s_street2 = trim(a.street_addr2), m_info->pat[d.seq].s_street3 = trim(a
    .street_addr3), m_info->pat[d.seq].s_street4 = trim(a.street_addr4),
   m_info->pat[d.seq].s_zip = format(trim(a.zipcode),"#####;p0")
  HEAD pa.active_status_dt_tm
   IF (pn_done_ind=0)
    IF (pa.alias != "RAD*")
     m_info->pat[d.seq].s_mrn = trim(pa.alias), pn_done_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("look for bmi > 30")
 SELECT INTO "nl:"
  pl_bmi = cnvtreal(ce.result_val)
  FROM (dummyt d  WITH seq = value(size(m_info->pat,5))),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.person_id=m_info->pat[d.seq].f_person_id)
    AND ce.event_cd=mf_bmi_cd)
  ORDER BY ce.person_id, ce.valid_from_dt_tm DESC
  HEAD ce.person_id
   pn_cnt = 0
  DETAIL
   pn_cnt += 1
   IF (pn_cnt=1)
    m_info->pat[d.seq].s_latest_bmi = trim(ce.result_val), m_info->pat[d.seq].s_latest_bmi_dt_tm =
    trim(format(ce.valid_from_dt_tm,"mm-dd-yyyy hh:mm;;d"))
   ELSEIF (pn_cnt=2)
    m_info->pat[d.seq].s_previous_bmi = trim(ce.result_val)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("get percentile values")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_info->pat,5))),
   hm_expect_sat hes,
   hm_expect_mod hem
  PLAN (d)
   JOIN (hem
   WHERE (hem.person_id=m_info->pat[d.seq].f_person_id)
    AND hem.active_ind=1)
   JOIN (hes
   WHERE hes.expect_sat_name="BMI Percentile"
    AND hes.expect_sat_id=hem.expect_sat_id
    AND hes.active_ind=1)
  ORDER BY hem.person_id, hem.modifier_dt_tm DESC
  HEAD hem.person_id
   pn_cnt = 0
  DETAIL
   pn_cnt += 1
   IF (pn_cnt=1)
    m_info->pat[d.seq].s_latest_bmi_per = trim(uar_get_code_display(hem.modifier_reason_cd)), m_info
    ->pat[d.seq].s_latest_bmi_per_dt_tm = trim(format(hem.modifier_dt_tm,"mm-dd-yyyy hh:mm;;d"))
   ELSEIF (pn_cnt=2)
    m_info->pat[d.seq].s_previous_bmi_per = uar_get_code_display(hem.modifier_reason_cd)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("get problems")
 SELECT INTO "nl:"
  pf_person_id = m_info->pat[d.seq].f_person_id
  FROM (dummyt d  WITH seq = value(size(m_info->pat,5))),
   bhs_nomen_list l,
   nomenclature n,
   problem p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=m_info->pat[d.seq].f_person_id)
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
   m_info->pat[d.seq].s_problems = ms_tmp_str
  WITH nocounter
 ;end select
 CALL echo("get diagnoses")
 SELECT INTO "nl:"
  pf_person_id = m_info->pat[d.seq].f_person_id
  FROM (dummyt d  WITH seq = value(size(m_info->pat,5))),
   bhs_nomen_list l,
   nomenclature n,
   diagnosis p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=m_info->pat[d.seq].f_person_id)
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
   m_info->pat[d.seq].s_diagnoses = ms_tmp_str
  WITH nocounter
 ;end select
 CALL echo("get resus/labs/vents")
 SELECT INTO "nl:"
  o.active_status_dt_tm, ps_unit = trim(uar_get_code_display(ce.result_units_cd))
  FROM (dummyt d  WITH seq = value(size(m_info->pat,5))),
   clinical_event ce,
   orders o
  PLAN (d)
   JOIN (o
   WHERE (o.person_id=m_info->pat[d.seq].f_person_id)
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
     m_info->pat[d.seq].s_bun = ms_tmp_str
    OF mf_hg_cd:
     m_info->pat[d.seq].s_hgba1c = ms_tmp_str
    OF mf_tsh_cd:
     m_info->pat[d.seq].s_tsh = ms_tmp_str
    OF mf_creatinine_cd:
     m_info->pat[d.seq].s_creatinine = ms_tmp_str
    OF mf_alt_cd:
     m_info->pat[d.seq].s_alt = ms_tmp_str
    OF mf_ast_cd:
     m_info->pat[d.seq].s_ast = ms_tmp_str
    OF mf_glucose_cd:
     m_info->pat[d.seq].s_glucose = ms_tmp_str
    OF mf_lipid_cd:
     IF (ce.event_cd=mf_cholesterol_cd)
      m_info->pat[d.seq].s_cholesterol = ms_tmp_str
     ELSEIF (ce.event_cd=mf_triglycerides_cd)
      m_info->pat[d.seq].s_trigylcerides = ms_tmp_str
     ELSEIF (ce.event_cd=mf_hdl_cd)
      m_info->pat[d.seq].s_hdl = ms_tmp_str
     ELSEIF (ce.event_cd=mf_ldl_cd)
      m_info->pat[d.seq].s_ldl = ms_tmp_str
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO value(ms_file_name)
  pn_name = m_info->pat[d.seq].s_patient_name
  FROM (dummyt d  WITH seq = value(size(m_info->pat,5)))
  ORDER BY pn_name
  HEAD REPORT
   ms_tmp_str = "Obesity Registry Report for ", ms_requester_name, col 0,
   ms_tmp_str, row + 1, ms_tmp_str = concat("Patient Name",char(9),"Age",char(9),"MRN",
    char(9),"Street Address",char(9),"City",char(9),
    "State",char(9),"Zip Code",char(9),"Problems",
    char(9),"Diagnoses",char(9),"Latest BMI Result",char(9),
    "Latest BMI Percentile",char(9),"Glucose",char(9),"Cholesterol",
    char(9),"Triglycerides",char(9),"HDL",char(9),
    "LDL",char(9),"AST",char(9),"ALT",
    char(9),"BUN",char(9),"Creatinine",char(9),
    "TSH",char(9),"HgbA1C"),
   col 0, ms_tmp_str,
   CALL echo(ms_tmp_str),
   row + 1
  DETAIL
   ms_tmp_str = concat(m_info->pat[d.seq].s_patient_name,char(9),m_info->pat[d.seq].s_patient_age,
    char(9),m_info->pat[d.seq].s_mrn,
    char(9),trim(concat(m_info->pat[d.seq].s_street1," ",m_info->pat[d.seq].s_street2," ",m_info->
      pat[d.seq].s_street3,
      " ",m_info->pat[d.seq].s_street4)),char(9),m_info->pat[d.seq].s_city,char(9),
    m_info->pat[d.seq].s_state,char(9),m_info->pat[d.seq].s_zip,char(9),m_info->pat[d.seq].s_problems,
    char(9),m_info->pat[d.seq].s_diagnoses,char(9),m_info->pat[d.seq].s_latest_bmi,char(9),
    m_info->pat[d.seq].s_latest_bmi_per,char(9),m_info->pat[d.seq].s_glucose,char(9),m_info->pat[d
    .seq].s_cholesterol,
    char(9),m_info->pat[d.seq].s_trigylcerides,char(9),m_info->pat[d.seq].s_hdl,char(9),
    m_info->pat[d.seq].s_ldl,char(9),m_info->pat[d.seq].s_ast,char(9),m_info->pat[d.seq].s_alt,
    char(9),m_info->pat[d.seq].s_bun,char(9),m_info->pat[d.seq].s_creatinine,char(9),
    m_info->pat[d.seq].s_tsh,char(9),m_info->pat[d.seq].s_hgba1c), col 0, ms_tmp_str,
   row + 1
  WITH nocounter, maxcol = 1000, formfeed = none
 ;end select
 IF (findfile(ms_file_name)=1)
  CALL emailfile("obesity_reg.xls","obesity_reg.xls",trim( $S_EMAIL),"OBESITY REGISTRY",1)
  SET ms_tmp_str = concat("The report was emailed to ",trim( $S_EMAIL))
  SELECT INTO  $OUTDEV
   DETAIL
    col 0, ms_tmp_str
   WITH nocounter, maxcol = 500
  ;end select
 ENDIF
#exit_script
 FREE RECORD m_info
END GO

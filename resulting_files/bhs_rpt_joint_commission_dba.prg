CREATE PROGRAM bhs_rpt_joint_commission:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Location" = 0,
  "Chart Age is >= 30 days:" = 30,
  "BAYSTATE RESIDENT DEFICIENCY REPORT" = 0,
  "Profile Status" = 0,
  "Send Email" = 0,
  "Enter Emails" = "Joseph.Fenton2@baystatehealth.org"
  WITH outdev, f_organization, l_chart_age,
  m_bmcrdr, f_status, f_send_email,
  s_emails
 FREE RECORD defic
 RECORD defic(
   1 ml_cnt = i4
   1 charts[*]
     2 s_chart_age = i4
     2 s_discharge_date = vc
     2 s_fin = vc
     2 s_mrn = vc
     2 s_phys_name = vc
     2 s_phys_status = vc
     2 s_phys_dept = vc
     2 s_allocation_dt = vc
     2 s_date_defic = vc
     2 s_doc_type = vc
     2 f_phys_id = f8
     2 s_stat_requested = vc
     2 s_org = vc
     2 s_pat_name = vc
     2 s_pat_type = vc
     2 s_phys_role = vc
 )
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
 )
 FREE RECORD m_lname_to_exclude_rec
 RECORD m_lname_to_exclude_rec(
   1 n_cnt = i4
   1 person[*]
     2 f_prsnl_id = f8
 )
 FREE RECORD m_position_cd_rec
 RECORD m_position_cd_rec(
   1 n_pos_cd_cnt = i4
   1 position[*]
     2 s_display = vc
     2 f_code_value = f8
 )
 DECLARE mf_cs14030_pendingtranscription = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14030,
   "PENDINGTRANSCRIPTION")), protect
 DECLARE mf_cs14030_pendingsignature = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14030,
   "PENDINGSIGNATURE")), protect
 DECLARE mf_cs14030_dictatepowernote = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14030,
   "DICTATEPOWERNOTE")), protect
 DECLARE mf_progress_note_hsptl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PROGRESSNOTEHOSPITAL"))
 DECLARE mf_bhs_rad_resident_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSRADRESIDENT"))
 DECLARE mf_bhs_resident_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,"BHSRESIDENT"
   ))
 DECLARE mf_bhs_bh_resident_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSBHRESIDENT"))
 DECLARE mf_bhs_ob_resident_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSOBRESIDENT"))
 DECLARE mf_auth_verified_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,
   "AUTHVERIFIED"))
 DECLARE mf_org_bfmc = f8 WITH protect, constant(589745.00)
 DECLARE mf_org_bfmc_inpt_psych = f8 WITH protect, constant(589764.00)
 DECLARE mf_org_bmc = f8 WITH protect, constant(589744.00)
 DECLARE mf_org_bmc_inptpsych = f8 WITH protect, constant(589763.00)
 DECLARE mf_org_bnh = f8 WITH protect, constant(47599182.00)
 DECLARE mf_org_bnh_inpt_psych = f8 WITH protect, constant(47646451.00)
 DECLARE mf_org_bnh_rehab = f8 WITH protect, constant(47646455.00)
 DECLARE mf_org_bwh = f8 WITH protect, constant(42410879.00)
 DECLARE mf_org_bwh_inpt_psych = f8 WITH protect, constant(42427170.00)
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mn_cnt = i2 WITH protect, noconstant(0)
 DECLARE mn_cnt2 = i2 WITH protect, noconstant(0)
 DECLARE mn_cnt3 = i2 WITH protect, noconstant(0)
 DECLARE mn_sort = i2 WITH protect, noconstant(0)
 DECLARE ms_filename = vc WITH noconstant("bhs_joint_comm_"), protect
 IF (( $M_BMCRDR=1))
  SET ms_filename = "bhs_resident_defic_"
 ENDIF
 DECLARE ms_report_type = vc WITH noconstant("Joint Commission"), protect
 IF (( $M_BMCRDR=1))
  SET ms_report_type = "Resident Deficiency"
 ENDIF
 DECLARE ms_output_file = vc WITH noconstant(build(trim(ms_filename,3),format(sysdate,"YYYYMMDD;;q"),
   ".csv")), protect
 DECLARE ms_subject = vc WITH noconstant(""), protect
 DECLARE ms_opr_var = vc WITH protect
 DECLARE ms_lcheck = vc WITH protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 DECLARE ml_cnt = i4 WITH noconstant(0), protect
 DECLARE ml_sort = i4 WITH noconstant(0), protect
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE p.name_last_key IN ("NOTONSTAFF", "EXTRA", "REFUSED")
   AND p.active_ind=1
  HEAD REPORT
   m_lname_to_exclude_rec->n_cnt = 0
  DETAIL
   m_lname_to_exclude_rec->n_cnt += 1, stat = alterlist(m_lname_to_exclude_rec->person,
    m_lname_to_exclude_rec->n_cnt), m_lname_to_exclude_rec->person[m_lname_to_exclude_rec->n_cnt].
   f_prsnl_id = p.person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=88
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate)
  HEAD REPORT
   m_position_cd_rec->n_pos_cd_cnt = 0
  DETAIL
   m_position_cd_rec->n_pos_cd_cnt += 1, stat = alterlist(m_position_cd_rec->position,
    m_position_cd_rec->n_pos_cd_cnt), m_position_cd_rec->position[m_position_cd_rec->n_pos_cd_cnt].
   s_display = trim(cv.display,3),
   m_position_cd_rec->position[m_position_cd_rec->n_pos_cd_cnt].f_code_value = cv.code_value
  WITH nocounter
 ;end select
 FREE RECORD grec1
 RECORD grec1(
   1 list[*]
     2 mf_cv = f8
     2 ms_disp = c15
 )
 IF (ms_lcheck="L")
  SET ms_opr_var = "IN"
  WHILE (ms_lcheck > " ")
    SET ml_gcnt += 1
    SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_ORGANIZATION),ml_gcnt)))
    CALL echo(ms_lcheck)
    IF (ms_lcheck > " ")
     IF (mod(ml_gcnt,5)=1)
      SET stat = alterlist(grec1->list,(ml_gcnt+ 4))
     ENDIF
     SET grec1->list[ml_gcnt].mf_cv = cnvtint(parameter(parameter2( $F_ORGANIZATION),ml_gcnt))
     SET grec1->list[ml_gcnt].disp = uar_get_code_display(parameter(parameter2( $F_ORGANIZATION),
       ml_gcnt))
    ENDIF
  ENDWHILE
  SET ml_gcnt -= 1
  SET stat = alterlist(grec1->list,ml_gcnt)
 ELSE
  SET stat = alterlist(grec1->list,1)
  SET ml_gcnt = 1
  SET grec1->list[1].mf_cv =  $F_ORGANIZATION
  IF ((grec1->list[1].mf_cv=0.0))
   SET ms_opr_var = "!="
  ELSE
   SET ms_opr_var = "="
  ENDIF
 ENDIF
 IF (( $M_BMCRDR=0))
  SELECT INTO "nl:"
   org.org_name_key, ml_sort =
   IF (d.profile_status_cd=mf_cs14030_dictatepowernote) 1
   ELSEIF (d.profile_status_cd=mf_cs14030_pendingtranscription) 2
   ELSEIF (d.profile_status_cd=mf_cs14030_pendingsignature) 3
   ENDIF
   , d.chart_age,
   d.event_end_dt_tm, d.event_cd, d.action_prsnl_id,
   d.profile_status, c.reg_dt_tm, c.allocation_dt_tm,
   c.disch_dt_tm, c.encntr_id, c.encntr_id,
   c.organization_id, c.person_id, c.encntr_type_cd,
   d.position_cd
   FROM him_pv_chart c,
    him_pv_document d,
    bhs_provider_dept b,
    person p,
    prsnl pr,
    encntr_alias mrn,
    encntr_alias fin,
    organization org
   PLAN (c
    WHERE operator(c.organization_id,ms_opr_var, $F_ORGANIZATION)
     AND c.organization_id IN (mf_org_bfmc, mf_org_bfmc_inpt_psych, mf_org_bmc, mf_org_bmc_inptpsych,
    mf_org_bnh,
    mf_org_bnh_inpt_psych, mf_org_bnh_rehab, mf_org_bwh, mf_org_bwh_inpt_psych))
    JOIN (d
    WHERE (d.encntr_id= Outerjoin(c.encntr_id))
     AND (d.profile_status_cd= $F_STATUS)
     AND (d.chart_age >=  $L_CHART_AGE)
     AND  NOT (expand(mn_cnt2,1,size(m_lname_to_exclude_rec->person,5),d.action_prsnl_id,
     m_lname_to_exclude_rec->person[mn_cnt2].f_prsnl_id))
     AND  NOT (d.event_cd IN (mf_progress_note_hsptl_cd))
     AND expand(mn_cnt3,1,size(m_position_cd_rec->position,5),d.position_cd,m_position_cd_rec->
     position[mn_cnt3].f_code_value))
    JOIN (b
    WHERE (b.person_id= Outerjoin(d.action_prsnl_id)) )
    JOIN (p
    WHERE p.person_id=c.person_id
     AND p.person_id > 0)
    JOIN (pr
    WHERE pr.person_id=d.action_prsnl_id)
    JOIN (mrn
    WHERE mrn.encntr_id=c.encntr_id
     AND mrn.active_status_cd=mf_cs48_active
     AND mrn.encntr_alias_type_cd=mf_cs319_mrn_cd
     AND mrn.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND mrn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND mrn.active_ind=1)
    JOIN (fin
    WHERE fin.encntr_id=c.encntr_id
     AND fin.active_status_cd=mf_cs48_active
     AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
     AND fin.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND fin.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND fin.active_ind=1)
    JOIN (org
    WHERE (org.organization_id= Outerjoin(c.organization_id)) )
   ORDER BY org.org_name, ml_sort, d.event_cd,
    d.action_prsnl_id, c.reg_dt_tm, d.chart_age,
    c.disch_dt_tm, c.allocation_dt_tm, d.event_end_dt_tm,
    c.encntr_id
   HEAD REPORT
    stat = alterlist(defic->charts,10)
   HEAD org.org_name
    null
   HEAD ml_sort
    null
   HEAD d.event_cd
    null
   HEAD d.action_prsnl_id
    null
   HEAD c.reg_dt_tm
    null
   HEAD c.disch_dt_tm
    null
   HEAD d.chart_age
    null
   HEAD d.event_end_dt_tm
    null
   HEAD c.allocation_dt_tm
    null
   HEAD c.encntr_id
    defic->ml_cnt += 1
    IF (mod(defic->ml_cnt,10)=1
     AND (defic->ml_cnt > 1))
     stat = alterlist(defic->charts,(defic->ml_cnt+ 9))
    ENDIF
    defic->charts[defic->ml_cnt].s_chart_age = d.chart_age, defic->charts[defic->ml_cnt].
    s_discharge_date = format(c.disch_dt_tm,";;d"), defic->charts[defic->ml_cnt].s_fin = trim(fin
     .alias,3),
    defic->charts[defic->ml_cnt].s_mrn = trim(mrn.alias,3), defic->charts[defic->ml_cnt].s_phys_name
     = trim(pr.name_full_formatted,3), defic->charts[defic->ml_cnt].s_phys_status = b.status,
    defic->charts[defic->ml_cnt].s_phys_dept = b.dept, defic->charts[defic->ml_cnt].s_allocation_dt
     = format(c.allocation_dt_tm,";;d"), defic->charts[defic->ml_cnt].s_date_defic = format(d
     .event_end_dt_tm,";;d"),
    defic->charts[defic->ml_cnt].s_doc_type = uar_get_code_display(d.event_cd), defic->charts[defic->
    ml_cnt].f_phys_id = d.action_prsnl_id, defic->charts[defic->ml_cnt].s_stat_requested = d
    .profile_status,
    defic->charts[defic->ml_cnt].s_org = trim(org.org_name,3), defic->charts[defic->ml_cnt].
    s_pat_name = trim(p.name_full_formatted,3), defic->charts[defic->ml_cnt].s_pat_type = trim(
     uar_get_code_display(c.encntr_type_cd),3),
    defic->charts[defic->ml_cnt].s_phys_role = trim(uar_get_code_display(d.position_cd),3)
   FOOT REPORT
    stat = alterlist(defic->charts,defic->ml_cnt)
   WITH nocounter, expand = 1
  ;end select
  IF (curqual=0)
   SELECT INTO value( $OUTDEV)
    FROM dummyt d
    HEAD REPORT
     text = build2("No rows qualified"), col 1, row 0,
     text
    WITH nocounter, maxcol = 32000
   ;end select
   GO TO exit_script
  ELSEIF (( $F_SEND_EMAIL=0))
   SELECT INTO  $OUTDEV
    org.org_name_key, ml_sort =
    IF (d.profile_status_cd=mf_cs14030_dictatepowernote) 1
    ELSEIF (d.profile_status_cd=mf_cs14030_pendingtranscription) 2
    ELSEIF (d.profile_status_cd=mf_cs14030_pendingsignature) 3
    ENDIF
    , chart_age = defic->charts[d1.seq].s_chart_age,
    discharge_date = substring(1,30,defic->charts[d1.seq].s_discharge_date), fin_number = substring(1,
     30,defic->charts[d1.seq].s_fin), medical_record_number = substring(1,30,defic->charts[d1.seq].
     s_mrn),
    physician_name = substring(1,100,defic->charts[d1.seq].s_phys_name), physician_status = substring
    (1,30,defic->charts[d1.seq].s_phys_status), physician_dept = substring(1,30,defic->charts[d1.seq]
     .s_phys_dept),
    allocation_date = substring(1,30,defic->charts[d1.seq].s_allocation_dt), date_of_deficiency =
    substring(1,30,defic->charts[d1.seq].s_date_defic), document_type = substring(1,100,defic->
     charts[d1.seq].s_doc_type),
    physician_id = defic->charts[d1.seq].f_phys_id, state_requested = substring(1,30,defic->charts[d1
     .seq].s_stat_requested), organization = substring(1,100,defic->charts[d1.seq].s_org),
    patient_name = substring(1,100,defic->charts[d1.seq].s_pat_name), patient_type = substring(1,100,
     defic->charts[d1.seq].s_pat_type), physician_role = substring(1,100,defic->charts[d1.seq].
     s_phys_role)
    FROM (dummyt d1  WITH seq = size(defic->charts,5))
    PLAN (d1)
    WITH nocounter, separator = " ", format,
     maxcol = 500
   ;end select
  ELSEIF (( $F_SEND_EMAIL=1))
   SET ml_cnt = 0
   SET frec->file_name = ms_output_file
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = build('"Chart Age",','"Discharge Date",','"FIN Number",',
    '"Medical Record Number",','"Physician Name",',
    '"Physician Status",','"Physician Dept",','"Allocation Date",','"Date of Deficiency",',
    '"Document Type",',
    '"Physician ID",','"State Requested",','"Organization",','"Patient Name",','"Patient Type ",',
    '"Physician Role",','"',char(13))
   SET stat = cclio("WRITE",frec)
   FOR (ml_cnt = 1 TO size(defic->charts,5))
    SET frec->file_buf = build('"',defic->charts[ml_cnt].s_chart_age,'","',trim(defic->charts[ml_cnt]
      .s_discharge_date,3),'","',
     trim(defic->charts[ml_cnt].s_fin,3),'","',trim(defic->charts[ml_cnt].s_mrn,3),'","',trim(defic->
      charts[ml_cnt].s_phys_name,3),
     '","',trim(defic->charts[ml_cnt].s_phys_status,3),'","',trim(defic->charts[ml_cnt].s_phys_dept,3
      ),'","',
     trim(defic->charts[ml_cnt].s_allocation_dt,3),'","',trim(defic->charts[ml_cnt].s_date_defic,3),
     '","',trim(defic->charts[ml_cnt].s_doc_type,3),
     '","',defic->charts[ml_cnt].f_phys_id,'","',trim(defic->charts[ml_cnt].s_stat_requested,3),'","',
     trim(defic->charts[ml_cnt].s_org,3),'","',trim(defic->charts[ml_cnt].s_pat_name,3),'","',trim(
      defic->charts[ml_cnt].s_pat_type,3),
     '","',trim(defic->charts[ml_cnt].s_phys_role,3),'"',char(13))
    SET stat = cclio("WRITE",frec)
   ENDFOR
   SET stat = cclio("CLOSE",frec)
   IF (textlen(trim( $S_EMAILS,3)) > 4
    AND findstring("@", $S_EMAILS,1,0) >= 1)
    EXECUTE bhs_ma_email_file
    SET ms_subject = build2(ms_report_type," ","Date :",trim(format(cnvtdatetime(sysdate),
       "mmm-dd-yyyy hh:mm ;;d"),3))
    CALL emailfile(frec->file_name,frec->file_name, $S_EMAILS,ms_subject,1)
    SELECT INTO value( $OUTDEV)
     FROM dummyt d
     HEAD REPORT
      msg1 = "The report has been sent to:", msg2 = build2("     ", $S_EMAILS),
      CALL print(calcpos(36,18)),
      msg1, row + 2, msg2
     WITH dio = 08
    ;end select
   ELSE
    SELECT INTO value( $OUTDEV)
     FROM dummyt d
     HEAD REPORT
      row + 1, "{F/1}{CPI/7}",
      CALL print(calcpos(26,18)),
      "Recipient email is invalid."
     WITH dio = 08
    ;end select
   ENDIF
  ENDIF
 ELSEIF (( $M_BMCRDR=1))
  SELECT INTO "nl:"
   org.org_name_key, ml_sort =
   IF (d.profile_status_cd=mf_cs14030_dictatepowernote) 1
   ELSEIF (d.profile_status_cd=mf_cs14030_pendingtranscription) 2
   ELSEIF (d.profile_status_cd=mf_cs14030_pendingsignature) 3
   ENDIF
   , d.chart_age,
   d.event_end_dt_tm, d.event_cd, d.action_prsnl_id,
   b.dept, b.status, d.profile_status,
   c.reg_dt_tm, c.allocation_dt_tm, c.disch_dt_tm,
   c.encntr_id, c.organization_id, c.person_id,
   c.encntr_type_cd, d.position_cd
   FROM him_pv_chart c,
    him_pv_document d,
    bhs_provider_dept b,
    person p,
    prsnl pr,
    encntr_alias mrn,
    encntr_alias fin,
    organization org
   PLAN (c
    WHERE operator(c.organization_id,ms_opr_var, $F_ORGANIZATION)
     AND c.organization_id IN (mf_org_bfmc, mf_org_bfmc_inpt_psych, mf_org_bmc, mf_org_bmc_inptpsych,
    mf_org_bnh,
    mf_org_bnh_inpt_psych, mf_org_bnh_rehab, mf_org_bwh, mf_org_bwh_inpt_psych))
    JOIN (d
    WHERE (d.encntr_id= Outerjoin(c.encntr_id))
     AND (d.profile_status_cd= $F_STATUS)
     AND (d.chart_age >=  $L_CHART_AGE)
     AND  NOT (expand(mn_cnt,1,size(m_lname_to_exclude_rec->person,5),d.action_prsnl_id,
     m_lname_to_exclude_rec->person[mn_cnt].f_prsnl_id))
     AND  NOT (d.event_cd IN (mf_progress_note_hsptl_cd))
     AND d.position_cd IN (mf_bhs_rad_resident_cd, mf_bhs_resident_cd, mf_bhs_bh_resident_cd,
    mf_bhs_ob_resident_cd))
    JOIN (b
    WHERE (b.person_id= Outerjoin(d.action_prsnl_id)) )
    JOIN (p
    WHERE p.person_id=c.person_id
     AND p.person_id > 0)
    JOIN (pr
    WHERE pr.person_id=d.action_prsnl_id)
    JOIN (mrn
    WHERE mrn.encntr_id=c.encntr_id
     AND mrn.active_status_cd=mf_cs48_active
     AND mrn.encntr_alias_type_cd=mf_cs319_mrn_cd
     AND mrn.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND mrn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND mrn.active_ind=1)
    JOIN (fin
    WHERE fin.encntr_id=c.encntr_id
     AND fin.active_status_cd=mf_cs48_active
     AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
     AND fin.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND fin.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND fin.active_ind=1)
    JOIN (org
    WHERE (org.organization_id= Outerjoin(c.organization_id)) )
   ORDER BY org.org_name, ml_sort, d.event_cd,
    d.action_prsnl_id, c.reg_dt_tm, d.chart_age,
    c.disch_dt_tm, c.allocation_dt_tm, d.event_end_dt_tm,
    c.encntr_id
   HEAD REPORT
    stat = alterlist(defic->charts,10)
   HEAD org.org_name
    null
   HEAD ml_sort
    null
   HEAD d.event_cd
    null
   HEAD d.action_prsnl_id
    null
   HEAD c.reg_dt_tm
    null
   HEAD c.disch_dt_tm
    null
   HEAD d.chart_age
    null
   HEAD d.event_end_dt_tm
    null
   HEAD c.allocation_dt_tm
    null
   HEAD c.encntr_id
    defic->ml_cnt += 1
    IF (mod(defic->ml_cnt,10)=1
     AND (defic->ml_cnt > 1))
     stat = alterlist(defic->charts,(defic->ml_cnt+ 9))
    ENDIF
    defic->charts[defic->ml_cnt].s_chart_age = d.chart_age, defic->charts[defic->ml_cnt].
    s_discharge_date = format(c.disch_dt_tm,";;d"), defic->charts[defic->ml_cnt].s_fin = trim(fin
     .alias,3),
    defic->charts[defic->ml_cnt].s_mrn = trim(mrn.alias,3), defic->charts[defic->ml_cnt].s_phys_name
     = trim(pr.name_full_formatted,3), defic->charts[defic->ml_cnt].s_phys_status = b.status,
    defic->charts[defic->ml_cnt].s_phys_dept = b.dept, defic->charts[defic->ml_cnt].s_allocation_dt
     = format(c.allocation_dt_tm,";;d"), defic->charts[defic->ml_cnt].s_date_defic = format(d
     .event_end_dt_tm,";;d"),
    defic->charts[defic->ml_cnt].s_doc_type = uar_get_code_display(d.event_cd), defic->charts[defic->
    ml_cnt].f_phys_id = d.action_prsnl_id, defic->charts[defic->ml_cnt].s_stat_requested = d
    .profile_status,
    defic->charts[defic->ml_cnt].s_org = trim(org.org_name,3), defic->charts[defic->ml_cnt].
    s_pat_name = trim(p.name_full_formatted,3), defic->charts[defic->ml_cnt].s_pat_type = trim(
     uar_get_code_display(c.encntr_type_cd),3),
    defic->charts[defic->ml_cnt].s_phys_role = trim(uar_get_code_display(d.position_cd),3)
   FOOT REPORT
    stat = alterlist(defic->charts,defic->ml_cnt)
   WITH nocounter, expand = 1
  ;end select
  IF (curqual=0)
   SELECT INTO value( $OUTDEV)
    FROM dummyt d
    HEAD REPORT
     text = build2("No rows qualified"), col 1, row 0,
     text
    WITH nocounter, maxcol = 32000
   ;end select
   GO TO exit_script
  ELSEIF (( $F_SEND_EMAIL=0))
   SELECT INTO  $OUTDEV
    chart_age = defic->charts[d1.seq].s_chart_age, discharge_date = substring(1,30,defic->charts[d1
     .seq].s_discharge_date), fin_number = substring(1,30,defic->charts[d1.seq].s_fin),
    medical_record_number = substring(1,30,defic->charts[d1.seq].s_mrn), physician_name = substring(1,
     100,defic->charts[d1.seq].s_phys_name), physician_status = substring(1,30,defic->charts[d1.seq].
     s_phys_status),
    physician_dept = substring(1,30,defic->charts[d1.seq].s_phys_dept), allocation_date = substring(1,
     30,defic->charts[d1.seq].s_allocation_dt), date_of_deficiency = substring(1,30,defic->charts[d1
     .seq].s_date_defic),
    document_type = substring(1,100,defic->charts[d1.seq].s_doc_type), physician_id = defic->charts[
    d1.seq].f_phys_id, state_requested = substring(1,30,defic->charts[d1.seq].s_stat_requested),
    organization = substring(1,100,defic->charts[d1.seq].s_org), patient_name = substring(1,100,defic
     ->charts[d1.seq].s_pat_name), patient_type = substring(1,100,defic->charts[d1.seq].s_pat_type),
    physician_role = substring(1,100,defic->charts[d1.seq].s_phys_role)
    FROM (dummyt d1  WITH seq = size(defic->charts,5))
    PLAN (d1)
    WITH nocounter, separator = " ", format,
     maxcol = 500
   ;end select
  ELSEIF (( $F_SEND_EMAIL=1))
   SET frec->file_name = ms_output_file
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = build('"Chart Age",','"Discharge Date",','"FIN Number",',
    '"Medical Record Number",','"Physician Name",',
    '"Physician Status",','"Physician Dept",','"Allocation Date",','"Date of Deficiency",',
    '"Document Type",',
    '"Physician ID",','"State Requested",','"Organization",','"Patient Name",','"Patient Type ",',
    '"Physician Role",','"',char(13))
   SET stat = cclio("WRITE",frec)
   FOR (ml_cnt = 1 TO size(defic->charts,5))
    SET frec->file_buf = build('"',defic->charts[ml_cnt].s_chart_age,'","',trim(defic->charts[ml_cnt]
      .s_discharge_date,3),'","',
     trim(defic->charts[ml_cnt].s_fin,3),'","',trim(defic->charts[ml_cnt].s_mrn,3),'","',trim(defic->
      charts[ml_cnt].s_phys_name,3),
     '","',trim(defic->charts[ml_cnt].s_phys_status,3),'","',trim(defic->charts[ml_cnt].s_phys_dept,3
      ),'","',
     trim(defic->charts[ml_cnt].s_allocation_dt,3),'","',trim(defic->charts[ml_cnt].s_date_defic,3),
     '","',trim(defic->charts[ml_cnt].s_doc_type,3),
     '","',defic->charts[ml_cnt].f_phys_id,'","',trim(defic->charts[ml_cnt].s_stat_requested,3),'","',
     trim(defic->charts[ml_cnt].s_org,3),'","',trim(defic->charts[ml_cnt].s_pat_name,3),'","',trim(
      defic->charts[ml_cnt].s_pat_type,3),
     '","',trim(defic->charts[ml_cnt].s_phys_role,3),'"',char(13))
    SET stat = cclio("WRITE",frec)
   ENDFOR
   SET stat = cclio("CLOSE",frec)
   IF (textlen(trim( $S_EMAILS,3)) > 4
    AND findstring("@", $S_EMAILS,1,0) >= 1)
    EXECUTE bhs_ma_email_file
    SET ms_subject = build2(ms_report_type," ","Date :",trim(format(cnvtdatetime(sysdate),
       "mmm-dd-yyyy hh:mm ;;d"),3))
    CALL emailfile(frec->file_name,frec->file_name, $S_EMAILS,ms_subject,1)
    SELECT INTO value( $OUTDEV)
     FROM dummyt d
     HEAD REPORT
      msg1 = "The report has been sent to:", msg2 = build2("     ", $S_EMAILS),
      CALL print(calcpos(36,18)),
      msg1, row + 2, msg2
     WITH dio = 08
    ;end select
   ELSE
    SELECT INTO value( $OUTDEV)
     FROM dummyt d
     HEAD REPORT
      row + 1, "{F/1}{CPI/7}",
      CALL print(calcpos(26,18)),
      "Recipient email is invalid."
     WITH dio = 08
    ;end select
   ENDIF
  ENDIF
 ENDIF
 FREE RECORD grec1
 FREE RECORD defic
 FREE RECORD frec
 FREE RECORD m_lname_to_exclude_rec
 FREE RECORD m_position_cd_rec
#exit_script
END GO

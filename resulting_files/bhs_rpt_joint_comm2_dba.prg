CREATE PROGRAM bhs_rpt_joint_comm2:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Choose report to run:" = "BMC",
  "Chart Age is >= 30 days:" = 30
  WITH outdev, s_report_name, l_chart_age
 FREE RECORD m_organization_rec
 RECORD m_organization_rec(
   1 organization[*]
     2 f_organization_id = f8
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
 DECLARE ms_report_name = vc WITH protect, noconstant(" ")
 DECLARE mn_org_cnt = i2 WITH protect, noconstant(0)
 DECLARE mn_cnt = i2 WITH protect, noconstant(0)
 DECLARE mn_cnt2 = i2 WITH protect, noconstant(0)
 DECLARE mn_cnt3 = i2 WITH protect, noconstant(0)
 SET ms_report_name = trim( $S_REPORT_NAME,3)
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
 IF (ms_report_name="FMC")
  SET stat = alterlist(m_organization_rec->organization,2)
  SET m_organization_rec->organization[1].f_organization_id = 589764.00
  SET m_organization_rec->organization[2].f_organization_id = 589745.00
 ELSEIF (ms_report_name="MLH")
  SET stat = alterlist(m_organization_rec->organization,1)
  SET m_organization_rec->organization[1].f_organization_id = 589746.00
 ELSEIF (((ms_report_name="BMC") OR (ms_report_name="BMCRDR")) )
  SET stat = alterlist(m_organization_rec->organization,2)
  SET m_organization_rec->organization[1].f_organization_id = 589763.00
  SET m_organization_rec->organization[2].f_organization_id = 589744.00
 ELSEIF (ms_report_name="BNH")
  SELECT INTO "nl:"
   FROM organization o
   WHERE o.org_name_key IN ("BAYSTATENOBLEHOSPITAL", "BAYSTATENOBLEREHABILITATION",
   "BAYSTATENOBLEHOSPITALINPATIENTPSYCHIATRY")
    AND o.data_status_cd=mf_auth_verified_cd
   HEAD REPORT
    mn_org_cnt = 0
   DETAIL
    mn_org_cnt += 1, stat = alterlist(m_organization_rec->organization,mn_org_cnt),
    m_organization_rec->organization[mn_org_cnt].f_organization_id = o.organization_id
   WITH nocounter
  ;end select
 ELSEIF (ms_report_name="BWH")
  SELECT INTO "nl:"
   FROM organization o
   WHERE o.org_name_key IN ("BAYSTATEWINGHOSPITALINPATIENTPSYCHIATRY", "BAYSTATEWINGHOSPITAL")
    AND o.data_status_cd=mf_auth_verified_cd
   HEAD REPORT
    mn_org_cnt = 0
   DETAIL
    mn_org_cnt += 1, stat = alterlist(m_organization_rec->organization,mn_org_cnt),
    m_organization_rec->organization[mn_org_cnt].f_organization_id = o.organization_id
   WITH nocounter
  ;end select
 ENDIF
 IF (ms_report_name != "BMCRDR")
  SELECT INTO value( $OUTDEV)
   chart_age = d.chart_age, discharge_date = format(c.disch_dt_tm,";;d"), fin_number =
   omf_get_fin_nbr(c.encntr_id),
   medical_record_number = cnvtalias(omf_get_alias("mrn",c.encntr_id),omf_get_alias_pool_cd("mrn",319,
     c.encntr_id)), physician_name = omf_get_prsnl_full(d.action_prsnl_id), physician_status = b
   .status,
   physician_dept = b.dept, allocation_date = format(c.allocation_dt_tm,";;d"), date_of_deficiency =
   format(d.event_end_dt_tm,";;d"),
   document_type = omf_get_cv_display(d.event_cd), physician_id = d.action_prsnl_id, status_requested
    = d.profile_status,
   organization = omf_get_org_name(c.organization_id), patient_name = omf_get_pers_full(c.person_id),
   patient_type = omf_get_cv_display(c.encntr_type_cd),
   physician_role = omf_get_cv_display(d.position_cd)
   FROM him_pv_chart c,
    him_pv_document d,
    bhs_provider_dept b
   PLAN (c
    WHERE expand(mn_cnt,1,size(m_organization_rec->organization,5),c.organization_id,
     m_organization_rec->organization[mn_cnt].f_organization_id))
    JOIN (d
    WHERE (c.encntr_id= Outerjoin(d.encntr_id))
     AND  NOT (expand(mn_cnt2,1,size(m_lname_to_exclude_rec->person,5),d.action_prsnl_id,
     m_lname_to_exclude_rec->person[mn_cnt2].f_prsnl_id))
     AND  NOT (d.event_cd IN (mf_progress_note_hsptl_cd))
     AND expand(mn_cnt3,1,size(m_position_cd_rec->position,5),d.position_cd,m_position_cd_rec->
     position[mn_cnt3].f_code_value))
    JOIN (b
    WHERE (b.person_id= Outerjoin(d.action_prsnl_id)) )
   GROUP BY d.chart_age, d.event_end_dt_tm, d.event_cd,
    d.action_prsnl_id, b.dept, b.status,
    d.profile_status, c.reg_dt_tm, c.allocation_dt_tm,
    c.disch_dt_tm, c.encntr_id, c.encntr_id,
    c.organization_id, c.person_id, c.encntr_type_cd,
    d.position_cd
   HAVING (d.chart_age >=  $L_CHART_AGE)
   ORDER BY d.event_cd
   WITH nocounter, maxcol = 32000, separator = " ",
    format
  ;end select
 ELSE
  SELECT INTO value( $OUTDEV)
   chart_age = d.chart_age, fin_number = omf_get_fin_nbr(c.encntr_id), patient_name =
   omf_get_pers_full(c.person_id),
   physician_status = b.status, physician_dept = b.dept, physician_name = omf_get_prsnl_full(d
    .action_prsnl_id),
   document_type = omf_get_cv_display(d.event_cd), physician_id = d.action_prsnl_id, status_requested
    = d.profile_status,
   allocation_dt_tm = format(c.allocation_dt_tm,";;d"), discharge_dt_tm = format(c.disch_dt_tm,";;d"),
   medical_record_number = cnvtalias(omf_get_alias("mrn",c.encntr_id),omf_get_alias_pool_cd("mrn",319,
     c.encntr_id)),
   physician_role = omf_get_cv_display(d.position_cd), document_status = omf_get_cv_display(d
    .result_status_cd)
   FROM him_pv_chart c,
    him_pv_document d,
    bhs_provider_dept b
   PLAN (c
    WHERE expand(mn_cnt,1,size(m_organization_rec->organization,5),c.organization_id,
     m_organization_rec->organization[mn_cnt].f_organization_id))
    JOIN (d
    WHERE (c.encntr_id= Outerjoin(d.encntr_id))
     AND  NOT (expand(mn_cnt,1,size(m_lname_to_exclude_rec->person,5),d.action_prsnl_id,
     m_lname_to_exclude_rec->person[mn_cnt].f_prsnl_id))
     AND  NOT (d.event_cd IN (mf_progress_note_hsptl_cd))
     AND d.position_cd IN (mf_bhs_rad_resident_cd, mf_bhs_resident_cd, mf_bhs_bh_resident_cd,
    mf_bhs_ob_resident_cd))
    JOIN (b
    WHERE (b.person_id= Outerjoin(d.action_prsnl_id)) )
   GROUP BY d.chart_age, d.event_cd, d.action_prsnl_id,
    d.action_prsnl_id, b.dept, b.status,
    d.profile_status, c.allocation_dt_tm, c.disch_dt_tm,
    c.encntr_id, c.encntr_id, c.person_id,
    d.position_cd, d.result_status_cd
   HAVING (d.chart_age >=  $L_CHART_AGE)
   ORDER BY d.event_cd
   WITH nocounter, maxcol = 32000, separator = " ",
    format
  ;end select
 ENDIF
 IF (curqual < 1)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    text = build2("No rows qualified. ", $S_REPORT_NAME), col 1, row 0,
    text
   WITH nocounter, maxcol = 32000
  ;end select
 ENDIF
#exit_script
 FREE RECORD m_organization_rec
 FREE RECORD m_lname_to_exclude_rec
 FREE RECORD m_position_cd_rec
END GO

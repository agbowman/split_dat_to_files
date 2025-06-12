CREATE PROGRAM bhs_rpt_plan_attributes:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD m_pws
 RECORD m_pws(
   1 l_cnt = i4
   1 qual[*]
     2 f_pathway_catalog_id = f8
     2 c_display_description = c100
     2 c_description = c100
     2 c_description_key = c100
     2 c_plan_type = c40
     2 c_type_mean = c12
     2 c_display_method = c40
     2 c_status = c50
     2 c_version = c1
     2 c_beg_effective_dt_tm = c25
     2 c_end_effective_dt_tm = c25
     2 c_reference_text = c255
     2 c_evidence_link = c255
     2 c_duration = c5
     2 c_duration_unit = c40
     2 c_facility_flexing = c1000
     2 c_sub_phase = c1
     2 c_allow_diagnosis_propagation = c1
     2 c_hide_flexed_components = c1
     2 c_cycle_ind = c1
     2 c_default_view = c12
     2 c_prompt_for_ordering_physician = c1
     2 c_copy_forward = c1
     2 c_check_alerts_on_plan = c1
     2 c_check_alerts_on_plan_updts = c1
     2 c_classification = c100
     2 c_plan_ordering_defaults = c100
     2 c_this_visit_outpt = c40
     2 c_this_visit_inpt = c40
     2 c_future_visit_outpt = c40
     2 c_future_visit_inpt = c40
     2 c_phase_start = c10
     2 c_document_reschedule_reason = c100
     2 c_build_link_components_group = c500
     2 c_do_not_allow_proposal = c1
     2 c_do_not_allow_as_plan_favorite = c1
     2 c_clinical_diagnosis_problem = c500
     2 c_update_user = c100
 )
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = h
   1 file_offset = h
   1 file_dir = h
 )
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ndx = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp_str = vc WITH protect, noconstant(" ")
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_date_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_outstring = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_in = vc WITH protect, noconstant(" ")
 DECLARE md_filename_out = vc WITH protect, noconstant(" ")
 IF (findstring("@", $OUTDEV) > 0)
  SET mn_email_ind = 1
  SET ms_output_dest = trim(concat("powerplan_attribute_audit_",format(cnvtdatetime(sysdate),
     "MMDDYYYYHHMMSS;;D")))
 ELSE
  SET mn_email_ind = 0
  SET ms_output_dest =  $OUTDEV
 ENDIF
 SELECT INTO "nl:"
  FROM pathway_catalog pc,
   prsnl pr
  PLAN (pc
   WHERE pc.active_ind=1
    AND pc.type_mean != "PHASE"
    AND pc.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pr
   WHERE pr.person_id=pc.updt_id)
  ORDER BY pc.description_key, pc.pathway_catalog_id
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   ml_cnt += 1, m_pws->l_cnt = ml_cnt, stat = alterlist(m_pws->qual,ml_cnt),
   m_pws->qual[ml_cnt].f_pathway_catalog_id = pc.pathway_catalog_id, m_pws->qual[ml_cnt].
   c_display_description = trim(pc.display_description,3), m_pws->qual[ml_cnt].c_description = trim(
    pc.description,3),
   m_pws->qual[ml_cnt].c_description_key = trim(pc.description_key,3), m_pws->qual[ml_cnt].
   c_plan_type = uar_get_code_display(pc.pathway_type_cd), m_pws->qual[ml_cnt].c_type_mean = pc
   .type_mean,
   m_pws->qual[ml_cnt].c_display_method = uar_get_code_display(pc.display_method_cd), m_pws->qual[
   ml_cnt].c_this_visit_outpt = uar_get_code_display(pc.default_action_outpt_now_cd), m_pws->qual[
   ml_cnt].c_this_visit_inpt = uar_get_code_display(pc.default_action_inpt_now_cd),
   m_pws->qual[ml_cnt].c_future_visit_outpt = uar_get_code_display(pc.default_action_outpt_future_cd),
   m_pws->qual[ml_cnt].c_future_visit_inpt = uar_get_code_display(pc.default_action_inpt_future_cd),
   m_pws->qual[ml_cnt].c_update_user = trim(pr.name_full_formatted)
   IF (pc.beg_effective_dt_tm > cnvtdatetime(sysdate))
    m_pws->qual[ml_cnt].c_status = "Testing"
   ELSE
    m_pws->qual[ml_cnt].c_status = "Production"
   ENDIF
   IF (pc.version > 0)
    m_pws->qual[ml_cnt].c_version = build(pc.version)
   ENDIF
   m_pws->qual[ml_cnt].c_beg_effective_dt_tm = format(pc.beg_effective_dt_tm,"mm/dd/yyyy HH:mm;;D")
   IF (pc.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    m_pws->qual[ml_cnt].c_end_effective_dt_tm = "Current"
   ELSE
    m_pws->qual[ml_cnt].c_end_effective_dt_tm = format(pc.end_effective_dt_tm,"mm/dd/yyyy HH:mm;;D")
   ENDIF
   m_pws->qual[ml_cnt].c_reference_text = " ", m_pws->qual[ml_cnt].c_evidence_link = " "
   IF (pc.duration_qty > 0)
    m_pws->qual[ml_cnt].c_duration = build(pc.duration_qty)
   ENDIF
   m_pws->qual[ml_cnt].c_duration_unit = trim(uar_get_code_display(pc.duration_unit_cd),3)
   IF (pc.sub_phase_ind > 0)
    m_pws->qual[ml_cnt].c_sub_phase = build(pc.sub_phase_ind)
   ENDIF
   IF (pc.diagnosis_capture_ind > 0)
    m_pws->qual[ml_cnt].c_allow_diagnosis_propagation = build(pc.diagnosis_capture_ind)
   ENDIF
   IF (pc.hide_flexed_comp_ind > 0)
    m_pws->qual[ml_cnt].c_hide_flexed_components = build(pc.hide_flexed_comp_ind)
   ENDIF
   IF (pc.cycle_ind=1)
    m_pws->qual[ml_cnt].c_cycle_ind = build(pc.cycle_ind)
   ENDIF
   m_pws->qual[ml_cnt].c_default_view = trim(pc.default_view_mean,3)
   IF (pc.provider_prompt_ind > 0)
    prompt_for_ordering_physician = build(pc.provider_prompt_ind)
   ENDIF
   IF (pc.allow_copy_forward_ind > 0)
    m_pws->qual[ml_cnt].c_copy_forward = build(pc.allow_copy_forward_ind)
   ENDIF
   IF (pc.alerts_on_plan_ind > 0)
    m_pws->qual[ml_cnt].c_check_alerts_on_plan = build(pc.alerts_on_plan_ind)
   ENDIF
   IF (pc.alerts_on_plan_upd_ind > 0)
    m_pws->qual[ml_cnt].c_check_alerts_on_plan_updts = build(pc.alerts_on_plan_upd_ind)
   ENDIF
   IF (pc.sub_phase_ind > 0)
    m_pws->qual[ml_cnt].c_sub_phase = build(pc.sub_phase_ind)
   ENDIF
   IF (pc.provider_prompt_ind > 0)
    m_pws->qual[ml_cnt].c_prompt_for_ordering_physician = build(pc.provider_prompt_ind)
   ENDIF
   CASE (pc.reschedule_reason_accept_flag)
    OF 0.00:
     m_pws->qual[ml_cnt].c_document_reschedule_reason = "Off"
    OF 1.00:
     m_pws->qual[ml_cnt].c_document_reschedule_reason = "Optional"
    OF 2.00:
     m_pws->qual[ml_cnt].c_document_reschedule_reason = "Required"
   ENDCASE
  WITH nocounter
 ;end select
 IF (ml_cnt < 1)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  facility = trim(uar_get_code_display(pcf.parent_entity_id),3)
  FROM pw_cat_flex pcf
  PLAN (pcf
   WHERE expand(ml_ndx,1,ml_cnt,pcf.pathway_catalog_id,m_pws->qual[ml_ndx].f_pathway_catalog_id))
  ORDER BY pcf.pathway_catalog_id, facility
  HEAD REPORT
   ml_pos = 0
  HEAD pcf.pathway_catalog_id
   ml_pos = locateval(ml_num,1,ml_cnt,pcf.pathway_catalog_id,m_pws->qual[ml_num].f_pathway_catalog_id
    ), m_pws->qual[ml_pos].c_facility_flexing = " "
  HEAD facility
   IF (pcf.parent_entity_id=0.00)
    m_pws->qual[ml_pos].c_facility_flexing = "All Facilities"
   ELSE
    IF ((m_pws->qual[ml_pos].c_facility_flexing=" "))
     m_pws->qual[ml_pos].c_facility_flexing = trim(uar_get_code_display(pcf.parent_entity_id),3)
    ELSE
     m_pws->qual[ml_pos].c_facility_flexing = concat(trim(m_pws->qual[ml_pos].c_facility_flexing,3),
      ", ",trim(uar_get_code_display(pcf.parent_entity_id),3))
    ENDIF
   ENDIF
  WITH expand = 1, nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pw_cat_reltn pcr,
   pathway_catalog pc
  PLAN (pcr
   WHERE expand(ml_ndx,1,ml_cnt,pcr.pw_cat_s_id,m_pws->qual[ml_ndx].f_pathway_catalog_id)
    AND pcr.type_mean="GROUP")
   JOIN (pc
   WHERE pc.pathway_catalog_id=pcr.pw_cat_t_id)
  ORDER BY pc.pathway_catalog_id
  HEAD REPORT
   ml_cnt = m_pws->l_cnt, ml_pos = 0
  DETAIL
   ml_pos = locateval(ml_num,1,ml_cnt,pcr.pw_cat_s_id,m_pws->qual[ml_num].f_pathway_catalog_id),
   ml_cnt += 1, m_pws->l_cnt = ml_cnt,
   stat = alterlist(m_pws->qual,ml_cnt), m_pws->qual[ml_cnt].f_pathway_catalog_id = pc
   .pathway_catalog_id, m_pws->qual[ml_cnt].c_display_description = m_pws->qual[ml_pos].
   c_display_description,
   m_pws->qual[ml_cnt].c_description = concat(trim(m_pws->qual[ml_pos].c_description,3)," (",trim(pc
     .description,3),")"), m_pws->qual[ml_cnt].c_description_key = trim(m_pws->qual[ml_pos].
    c_description_key,3), m_pws->qual[ml_cnt].c_plan_type = uar_get_code_display(pc.pathway_type_cd),
   m_pws->qual[ml_cnt].c_type_mean = trim(pc.type_mean,3), m_pws->qual[ml_cnt].c_display_method =
   uar_get_code_display(pc.display_method_cd), m_pws->qual[ml_cnt].c_this_visit_outpt =
   uar_get_code_display(pc.default_action_outpt_now_cd),
   m_pws->qual[ml_cnt].c_this_visit_inpt = uar_get_code_display(pc.default_action_inpt_now_cd), m_pws
   ->qual[ml_cnt].c_future_visit_outpt = uar_get_code_display(pc.default_action_outpt_future_cd),
   m_pws->qual[ml_cnt].c_future_visit_inpt = uar_get_code_display(pc.default_action_inpt_future_cd),
   m_pws->qual[ml_cnt].c_update_user = trim(m_pws->qual[ml_pos].c_update_user,3)
   IF (pc.beg_effective_dt_tm > cnvtdatetime(sysdate))
    m_pws->qual[ml_cnt].c_status = "Testing"
   ELSE
    m_pws->qual[ml_cnt].c_status = "Production"
   ENDIF
   IF (pc.version > 0)
    m_pws->qual[ml_cnt].c_version = build(pc.version)
   ENDIF
   m_pws->qual[ml_cnt].c_beg_effective_dt_tm = format(pc.beg_effective_dt_tm,"mm/dd/yyyy HH:mm;;D")
   IF (pc.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    m_pws->qual[ml_cnt].c_end_effective_dt_tm = "Current"
   ELSE
    m_pws->qual[ml_cnt].c_end_effective_dt_tm = format(pc.end_effective_dt_tm,"mm/dd/yyyy HH:mm;;D")
   ENDIF
   m_pws->qual[ml_cnt].c_reference_text = " ", m_pws->qual[ml_cnt].c_evidence_link = " "
   IF (pc.duration_qty > 0)
    m_pws->qual[ml_cnt].c_duration = build(pc.duration_qty)
   ENDIF
   m_pws->qual[ml_cnt].c_duration_unit = trim(uar_get_code_display(pc.duration_unit_cd),3)
   IF (pc.sub_phase_ind > 0)
    m_pws->qual[ml_cnt].c_sub_phase = build(pc.sub_phase_ind)
   ENDIF
   IF (pc.diagnosis_capture_ind > 0)
    m_pws->qual[ml_cnt].c_allow_diagnosis_propagation = build(pc.diagnosis_capture_ind)
   ENDIF
   IF (pc.hide_flexed_comp_ind > 0)
    m_pws->qual[ml_cnt].c_hide_flexed_components = build(pc.hide_flexed_comp_ind)
   ENDIF
   IF (pc.cycle_ind=1)
    m_pws->qual[ml_cnt].c_cycle_ind = build(pc.cycle_ind)
   ENDIF
   m_pws->qual[ml_cnt].c_default_view = trim(pc.default_view_mean,3)
   IF (pc.provider_prompt_ind > 0)
    prompt_for_ordering_physician = build(pc.provider_prompt_ind)
   ENDIF
   IF (pc.allow_copy_forward_ind > 0)
    m_pws->qual[ml_cnt].c_copy_forward = build(pc.allow_copy_forward_ind)
   ENDIF
   IF (pc.alerts_on_plan_ind > 0)
    m_pws->qual[ml_cnt].c_check_alerts_on_plan = build(pc.alerts_on_plan_ind)
   ENDIF
   IF (pc.alerts_on_plan_upd_ind > 0)
    m_pws->qual[ml_cnt].c_check_alerts_on_plan_updts = build(pc.alerts_on_plan_upd_ind)
   ENDIF
   IF (pc.sub_phase_ind > 0)
    m_pws->qual[ml_cnt].c_sub_phase = build(pc.sub_phase_ind)
   ENDIF
   IF (pc.provider_prompt_ind > 0)
    m_pws->qual[ml_cnt].c_prompt_for_ordering_physician = build(pc.provider_prompt_ind)
   ENDIF
   CASE (pc.reschedule_reason_accept_flag)
    OF 0.00:
     m_pws->qual[ml_cnt].c_document_reschedule_reason = "Off"
    OF 1.00:
     m_pws->qual[ml_cnt].c_document_reschedule_reason = "Optional"
    OF 2.00:
     m_pws->qual[ml_cnt].c_document_reschedule_reason = "Required"
   ENDCASE
  WITH expand = 1, nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pw_evidence_reltn per
  PLAN (per
   WHERE expand(ml_ndx,1,ml_cnt,per.pathway_catalog_id,m_pws->qual[ml_ndx].f_pathway_catalog_id)
    AND per.type_mean="URL")
  ORDER BY per.pathway_catalog_id
  HEAD REPORT
   ml_pos = 0
  HEAD per.pathway_catalog_id
   ml_pos = locateval(ml_num,1,ml_cnt,per.pathway_catalog_id,m_pws->qual[ml_num].f_pathway_catalog_id
    ), m_pws->qual[ml_pos].c_evidence_link = trim(replace(per.evidence_locator,"URL:"," "),3)
  WITH expand = 1, nocounter
 ;end select
 SELECT INTO "nl:"
  FROM ref_text_reltn rtr
  PLAN (rtr
   WHERE expand(ml_ndx,1,ml_cnt,rtr.parent_entity_id,m_pws->qual[ml_ndx].f_pathway_catalog_id)
    AND rtr.active_ind=1
    AND rtr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00"))
  ORDER BY rtr.parent_entity_id
  HEAD REPORT
   ml_pos = 0
  HEAD rtr.parent_entity_id
   ml_pos = locateval(ml_num,1,ml_cnt,rtr.parent_entity_id,m_pws->qual[ml_num].f_pathway_catalog_id),
   m_pws->qual[ml_pos].c_reference_text = "Reference Text Attached"
  WITH expand = 1, nocounter
 ;end select
 IF (mn_email_ind=1)
  SET ms_filename_in = trim(concat(ms_output_dest,".dat"))
  SET frec->file_name = ms_filename_in
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = concat('"Display Description",','"Description",','"Plan Type",','"Type Mean",',
   '"Display Method",',
   '"Status",','"Version",','"Beg Effective Dt Tm",','"Reference Text",','"Evidence Link",',
   '"Duration",','"Duration Unit",','"Facility Flexing",','"Sub Phase",',
   '"Allow Diagnosis Propagation",',
   '"Hide Flexed Components",','"Default View",','"Prompt For Ordering Physician",','"Copy Forward",',
   '"Ceck Alerts On Plan",',
   '"Check Alerts On Plan Updts",','"Classification",','"This Visit Outpt",','"This Visit Inpt",',
   '"Futher Visit Outpt",',
   '"Futher Visit Inpt",','"Phase Start Time",','"Plan Ordering Defaults",',
   '"Document Reschedule Reason",','"Build Link Components Group",',
   '"Do Not Allow Proposal",','"Do Not Allow As Plan Favorite",','"Clinical Diagnosis Problem",',
   '"Update User"',char(13),
   char(10))
  SET stat = cclio("PUTS",frec)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = m_pws->l_cnt)
   PLAN (d)
   ORDER BY m_pws->qual[d.seq].c_description_key
   HEAD REPORT
    ml_loop = 0
   DETAIL
    ml_loop += 1, frec->file_buf = concat('"',trim(m_pws->qual[d.seq].c_display_description,3),'",',
     '"',trim(m_pws->qual[d.seq].c_description,3),
     '",','"',trim(m_pws->qual[d.seq].c_plan_type,3),'",','"',
     trim(m_pws->qual[d.seq].c_type_mean,3),'",','"',trim(m_pws->qual[d.seq].c_display_method,3),'",',
     '"',trim(m_pws->qual[d.seq].c_status,3),'",','"',trim(m_pws->qual[d.seq].c_version,3),
     '",','"',trim(m_pws->qual[d.seq].c_beg_effective_dt_tm,3),'",','"',
     trim(m_pws->qual[d.seq].c_reference_text,3),'",','"',trim(m_pws->qual[d.seq].c_evidence_link,3),
     '",',
     '"',trim(m_pws->qual[d.seq].c_duration,3),'",','"',trim(m_pws->qual[d.seq].c_duration_unit,3),
     '",','"',trim(m_pws->qual[d.seq].c_facility_flexing,3),'",','"',
     trim(m_pws->qual[d.seq].c_sub_phase,3),'",','"',trim(m_pws->qual[d.seq].
      c_allow_diagnosis_propagation,3),'",',
     '"',trim(m_pws->qual[d.seq].c_hide_flexed_components,3),'",','"',trim(m_pws->qual[d.seq].
      c_default_view,3),
     '",','"',trim(m_pws->qual[d.seq].c_prompt_for_ordering_physician,3),'",','"',
     trim(m_pws->qual[d.seq].c_copy_forward,3),'",','"',trim(m_pws->qual[d.seq].
      c_check_alerts_on_plan,3),'",',
     '"',trim(m_pws->qual[d.seq].c_check_alerts_on_plan_updts,3),'",','"',trim(m_pws->qual[d.seq].
      c_classification,3),
     '",','"',trim(m_pws->qual[d.seq].c_this_visit_outpt,3),'",','"',
     trim(m_pws->qual[d.seq].c_this_visit_inpt,3),'",','"',trim(m_pws->qual[d.seq].
      c_future_visit_outpt,3),'",',
     '"',trim(m_pws->qual[d.seq].c_future_visit_inpt,3),'",','"',trim(m_pws->qual[d.seq].
      c_phase_start,3),
     '",','"',trim(m_pws->qual[d.seq].c_plan_ordering_defaults,3),'",','"',
     trim(m_pws->qual[d.seq].c_document_reschedule_reason,3),'",','"',trim(m_pws->qual[d.seq].
      c_build_link_components_group,3),'",',
     '"',trim(m_pws->qual[d.seq].c_do_not_allow_proposal,3),'",','"',trim(m_pws->qual[d.seq].
      c_do_not_allow_as_plan_favorite,3),
     '",','"',trim(m_pws->qual[d.seq].c_clinical_diagnosis_problem,3),'",','"',
     trim(m_pws->qual[d.seq].c_update_user,3),'"',char(13),char(10))
    IF ((ml_loop < m_pws->l_cnt))
     stat = cclio("PUTS",frec)
    ENDIF
   WITH nocounter
  ;end select
  SET stat = cclio("WRITE",frec)
  SET stat = cclio("CLOSE",frec)
  SET ms_filename_out = concat("PowerPlanAttributeAudit_",format(curdate,"MMDDYYYY;;D"),".csv")
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_filename_in,ms_filename_out, $OUTDEV,concat(cnvtlower(curprog),
    " - Baystate Medical Center Powerplan Attributes Audit"),1)
 ELSE
  SELECT INTO  $OUTDEV
   display_description = trim(m_pws->qual[d.seq].c_display_description,3), description = trim(m_pws->
    qual[d.seq].c_description,3), plan_type = trim(m_pws->qual[d.seq].c_plan_type,3),
   type_mean = trim(m_pws->qual[d.seq].c_type_mean,3), display_method = trim(m_pws->qual[d.seq].
    c_display_method,3), status = trim(m_pws->qual[d.seq].c_status,3),
   version = trim(m_pws->qual[d.seq].c_version,3), beg_effective_dt_tm = trim(m_pws->qual[d.seq].
    c_beg_effective_dt_tm,3), reference_text = trim(m_pws->qual[d.seq].c_reference_text,3),
   evidence_link = trim(m_pws->qual[d.seq].c_evidence_link,3), duration = trim(m_pws->qual[d.seq].
    c_duration,3), duration_unit = trim(m_pws->qual[d.seq].c_duration_unit,3),
   facility_flexing = trim(m_pws->qual[d.seq].c_facility_flexing,3), sub_phase = trim(m_pws->qual[d
    .seq].c_sub_phase,3), allow_diagnosis_propagation = trim(m_pws->qual[d.seq].
    c_allow_diagnosis_propagation,3),
   hide_flexed_components = trim(m_pws->qual[d.seq].c_hide_flexed_components,3), default_view = trim(
    m_pws->qual[d.seq].c_default_view,3), prompt_for_ordering_physician = trim(m_pws->qual[d.seq].
    c_prompt_for_ordering_physician,3),
   copy_forward = trim(m_pws->qual[d.seq].c_copy_forward,3), check_alerts_on_plan = trim(m_pws->qual[
    d.seq].c_check_alerts_on_plan,3), check_alerts_on_plan_updts = trim(m_pws->qual[d.seq].
    c_check_alerts_on_plan_updts,3),
   classification = trim(m_pws->qual[d.seq].c_classification,3), this_visit_outpt = trim(m_pws->qual[
    d.seq].c_this_visit_outpt,3), this_visit_inpt = trim(m_pws->qual[d.seq].c_this_visit_inpt,3),
   future_visit_outpt = trim(m_pws->qual[d.seq].c_future_visit_outpt,3), future_visit_inpt = trim(
    m_pws->qual[d.seq].c_future_visit_inpt,3), phase_start_time = trim(m_pws->qual[d.seq].
    c_phase_start,3),
   plan_ordering_defaults = trim(m_pws->qual[d.seq].c_plan_ordering_defaults,3),
   document_reschedule_reason = trim(m_pws->qual[d.seq].c_document_reschedule_reason,3),
   build_link_components_group = trim(m_pws->qual[d.seq].c_build_link_components_group,3),
   do_not_allow_proposal = trim(m_pws->qual[d.seq].c_do_not_allow_proposal,3),
   do_not_allow_as_plan_favorite = trim(m_pws->qual[d.seq].c_do_not_allow_as_plan_favorite,3),
   clinical_diagnosis_problem = trim(m_pws->qual[d.seq].c_clinical_diagnosis_problem,3),
   update_user = trim(m_pws->qual[d.seq].c_update_user,3)
   FROM (dummyt d  WITH seq = m_pws->l_cnt)
   PLAN (d)
   ORDER BY m_pws->qual[d.seq].c_description_key
   WITH format, separator = " ", nocounter
  ;end select
 ENDIF
#exit_script
END GO

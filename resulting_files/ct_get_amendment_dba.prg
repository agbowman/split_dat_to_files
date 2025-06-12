CREATE PROGRAM ct_get_amendment:dba
 RECORD reply(
   1 enroll_stratification_type_cd = f8
   1 enroll_stratification_type_disp = vc
   1 enroll_stratification_type_desc = vc
   1 enroll_stratification_type_mean = c12
   1 initiating_service_cd = f8
   1 initiating_service_disp = c50
   1 initiating_service_desc = c50
   1 initiating_service_mean = c12
   1 initiating_service_other_desc = vc
   1 sub_initiating_service_cd = f8
   1 sub_initiating_service_disp = c50
   1 sub_initiating_service_desc = c50
   1 sub_initiating_service_mean = c12
   1 sub_initiating_service_other_desc = vc
   1 prot_phase_cd = f8
   1 prot_phase_disp = c50
   1 prot_phase_desc = c50
   1 prot_phase_mean = c12
   1 prot_type_cd = f8
   1 prot_type_disp = c50
   1 prot_type_desc = c50
   1 prot_type_mean = c12
   1 primary_mnemonic = c50
   1 prot_master_id = f8
   1 prot_purpose_cd = f8
   1 prot_purpose_disp = c50
   1 prot_purpose_desc = c50
   1 prot_purpose_mean = c12
   1 program_cd = f8
   1 program_disp = c50
   1 program_desc = c50
   1 program_mean = c12
   1 prot_status_cd = f8
   1 prot_status_disp = c50
   1 prot_status_desc = c50
   1 prot_status_mean = c12
   1 accession_nbr_last = i4
   1 accession_nbr_prefix = vc
   1 accession_nbr_sig_dig = i4
   1 participation_type_cd = f8
   1 participation_type_disp = c50
   1 participation_type_desc = c50
   1 participation_type_mean = c12
   1 prot_master_updt_cnt = i4
   1 revision_nbr_highest = i4
   1 collab_site_org_id = f8
   1 collab_site_org_name = vc
   1 parent_prot_master_id = f8
   1 contributing_depts[*]
     2 dept_id = f8
     2 dept_cd = f8
     2 dept_disp = c50
     2 dept_desc = c50
     2 dept_mean = c12
     2 dept_other_desc = vc
     2 dept_updt_cnt = i4
   1 regulatory[*]
     2 regulatory_id = f8
     2 reporting_type_cd = f8
     2 reporting_type_disp = c50
     2 reporting_type_desc = c50
     2 reporting_type_mean = c12
     2 updt_cnt = i4
   1 reviewers[*]
     2 reviewer_id = f8
     2 organization_id = f8
     2 org_name = vc
     2 reviewer_status_cd = f8
     2 reviewer_status_disp = c50
     2 reviewer_status_desc = c50
     2 reviewer_status_mean = c12
     2 reviewer_updt_cnt = i4
   1 prot_aliases[*]
     2 alias_id = f8
     2 alias = vc
     2 alias_type_cd = f8
     2 alias_type_disp = c50
     2 alias_type_desc = c50
     2 alias_type_mean = c12
     2 alias_pool_cd = f8
     2 alias_pool_disp = c50
     2 alias_pool_desc = c50
     2 alias_pool_mean = c12
     2 alias_format = c100
     2 alias_updt_cnt = i4
   1 amd_aliases[*]
     2 alias_id = f8
     2 alias = vc
     2 alias_type_cd = f8
     2 alias_type_disp = c50
     2 alias_type_desc = c50
     2 alias_type_mean = c12
     2 alias_pool_cd = f8
     2 alias_pool_disp = c50
     2 alias_pool_desc = c50
     2 alias_pool_mean = c12
     2 alias_format = c100
     2 alias_updt_cnt = i4
   1 eligible_alias_pools[*]
     2 alias_pool_cd = f8
     2 alias_pool_disp = c50
     2 alias_pool_desc = c50
     2 alias_pool_mean = c12
     2 alias_entity_type_cd = f8
     2 alias_entity_type_disp = c50
     2 alias_entity_type_desc = c50
     2 alias_entity_type_mean = c12
     2 format_mask = c100
     2 unique_ind = i2
   1 accrual_required_indc_cd = f8
   1 accrual_required_indc_disp = c50
   1 accrual_required_indc_desc = c50
   1 accrual_required_indc_mean = c12
   1 amendment_description = vc
   1 amendment_dt_tm = dq8
   1 amendment_nbr = i4
   1 anticipated_prot_duration = f8
   1 anticipated_prot_dur_uom_cd = f8
   1 anticipated_prot_dur_uom_disp = c50
   1 anticipated_prot_dur_uom_desc = c50
   1 anticipated_prot_dur_uom_mean = c12
   1 groupwide_targeted_accrual = i4
   1 prot_title = vc
   1 targeted_accrual = i4
   1 prot_status_ind = i2
   1 amendment_status_cd = f8
   1 amendment_status_disp = c50
   1 amendment_status_desc = c50
   1 amendment_status_mean = c12
   1 diseases[*]
     2 disease_id = f8
     2 disease_type_cd = f8
     2 disease_type_disp = c50
     2 disease_type_desc = c50
     2 disease_type_mean = c12
     2 disease_sub_type_cd = f8
     2 disease_sub_type_disp = c50
     2 disease_sub_type_desc = c50
     2 disease_sub_type_mean = c12
     2 disease_updt_cnt = i4
   1 modalities[*]
     2 modality_id = f8
     2 modality_cd = f8
     2 modality_disp = c50
     2 modality_desc = c50
     2 modality_mean = c12
     2 modality_updt_cnt = i4
   1 sponsors[*]
     2 prot_grant_sponsor_id = f8
     2 organization_id = f8
     2 org_name = vc
     2 funded_ind = i2
     2 grant_project_title = vc
     2 grant_num = vc
     2 support_type[*]
       3 support_type_id = f8
       3 support_type_cd = f8
       3 support_type_disp = c50
       3 support_type_desc = c50
       3 support_type_mean = c12
       3 support_updt_cnt = i4
     2 primary_secondary_cd = f8
     2 primary_secondary_disp = c50
     2 primary_secondary_desc = c50
     2 primary_secondary_mean = c12
     2 sponsor_updt_cnt = i4
   1 data_submission[*]
     2 submitted_to_cd = f8
     2 submitted_to_disp = c50
     2 submitted_to_desc = c50
     2 submitted_to_mean = c12
     2 submitted_to_description = vc
     2 submitted_updt_cnt = i4
   1 other_applicable_prot_ind = i2
   1 safety_monitor_committee_ind = i2
   1 safety_committee[*]
     2 person_id = f8
     2 person_full_name = vc
     2 safety_updt_cnt = i4
   1 compensation_description = vc
   1 reasons[*]
     2 reason_id = f8
     2 reason_cd = f8
     2 reason_disp = c50
     2 reason_desc = c50
     2 reason_mean = c12
     2 reason_updt_cnt = i4
   1 objectives[*]
     2 objective_id = f8
     2 objective = vc
     2 objective_type_cd = f8
     2 objective_type_disp = c50
     2 objective_type_desc = c50
     2 objective_type_mean = c12
     2 objective_nbr = vc
     2 sequence_nbr = i4
     2 parent_prot_objective_id = f8
     2 objective_updt_cnt = i4
   1 stypeaccrual = f8
   1 stypebalance = f8
   1 stypenostrat = f8
   1 scohorttypedefault = f8
   1 scohorttypemulti = f8
   1 scohorttypetypical = f8
   1 scohortstatusclosed = f8
   1 scohortstatusopen = f8
   1 scohortstatussuspended = f8
   1 sstatusopen = f8
   1 sstatusclosed = f8
   1 sstatussuspended = f8
   1 schgreasonautosusp_cd = f8
   1 schgreasonautosusp_disp = vc
   1 cohort_id = f8
   1 assignstatus = c1
   1 ss[*]
     2 status_chg_reason_cd = f8
     2 prot_stratum_id = f8
     2 stratum_id = f8
     2 parent_stratum_id = f8
     2 stratum_ctms_extn_txt = vc
     2 organization_id = f8
     2 prot_amendment_id = f8
     2 stratum_label = c100
     2 stratum_cd = f8
     2 stratum_disp = vc
     2 stratum_desc = vc
     2 stratum_mean = c12
     2 stratum_description = vc
     2 stratum_status_cd = f8
     2 stratum_status_disp = vc
     2 stratum_status_desc = vc
     2 stratum_status_mean = c12
     2 stratum_cohort_type_cd = f8
     2 stratum_cohort_type_disp = vc
     2 stratum_cohort_type_desc = vc
     2 stratum_cohort_type_mean = c12
     2 length_evaluation = i4
     2 length_evaluation_uom_cd = f8
     2 length_evaluation_uom_disp = vc
     2 length_evaluation_uom_desc = vc
     2 length_evaluation_uom_mean = c12
     2 updt_cnt = i4
     2 cs[*]
       3 status_chg_reason_cd = f8
       3 prot_cohort_id = f8
       3 cohort_id = f8
       3 parent_cohort_id = f8
       3 stratum_id = f8
       3 pt_accrual = i4
       3 cohort_status_cd = f8
       3 cohort_status_disp = vc
       3 cohort_status_desc = vc
       3 cohort_status_mean = c12
       3 prot_cohort_description = vc
       3 cohort_label = c30
       3 valid_from_dt_tm = dq8
       3 valid_to_dt_tm = dq8
       3 updt_cnt = i4
     2 susps[*]
       3 prot_stratum_susp_id = f8
       3 susp_id = f8
       3 reason_cd = f8
       3 reason_disp = vc
       3 reason_desc = vc
       3 reason_mean = c12
       3 comment_txt = vc
       3 susp_effective_dt_tm = dq8
       3 susp_end_dt_tm = dq8
       3 updt_cnt = i4
   1 invest_agent[*]
     2 agent_id = f8
     2 agent_dev_id = f8
     2 agent_dev_cd = f8
     2 agent_dev_disp = c50
     2 agent_dev_desc = c50
     2 agent_dev_mean = c12
     2 agent_updt_cnt = i4
     2 drug_dev_id = f8
     2 drug_catalog_cd = f8
     2 drug_catalog_disp = c50
     2 drug_catalog_desc = c50
     2 drug_catalog_mean = c12
     2 drug_name = vc
     2 drug_nbr = vc
     2 drug_updt_cnt = i4
     2 dev_id = f8
     2 dev_nbr = vc
     2 dev_type_cd = f8
     2 dev_type_disp = c50
     2 dev_type_desc = c50
     2 dev_type_mean = c12
     2 dev_name = vc
     2 dev_updt_cnt = i4
     2 owners[*]
       3 owner_id = f8
       3 owner_roletype_cd = f8
       3 owner_roletype_disp = c50
       3 owner_roletype_desc = c50
       3 owner_roletype_mean = c12
       3 org_id = f8
       3 org_name = vc
       3 person_id = f8
       3 person_name = vc
       3 nbr = c6
       3 valid_from_dt_tm = dq8
       3 valid_to_dt_tm = dq8
       3 owner_updt_cnt = i4
   1 updt_cnt = i4
   1 display_ind = i2
   1 committees[*]
     2 prot_amd_committee_id = f8
     2 committee_id = f8
     2 committee_name = vc
     2 committee_type_cd = f8
     2 committee_type_disp = c50
     2 committee_type_desc = c50
     2 committee_type_mean = c12
     2 validate_ind = i2
     2 edit_ind = i2
     2 updt_cnt = i2
   1 compensation_ind = i2
   1 revision_ind = i2
   1 parent_amendment_id = f8
   1 revision_nbr_txt = c30
   1 revision_seq = i4
   1 revision_id = f8
   1 revision_description = vc
   1 revision_dt_tm = dq8
   1 data_capture_str = vc
   1 data_capture_ind = i2
   1 ct_domain_id = f8
   1 data_script_cd = f8
   1 data_script_disp = c50
   1 data_script_desc = c50
   1 data_script_mean = c12
   1 auto_enroll_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 debug[*]
     2 str = vc
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE open_cd = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET cnt = 0
 SET new = 0
 SET cval = 0.0
 SET cmean = fillstring(12," ")
 CALL echo("before select- amend")
 SELECT INTO "NL:"
  pa.*
  FROM prot_amendment pa
  WHERE (pa.prot_amendment_id=request->prot_amendment_id)
  DETAIL
   reply->accrual_required_indc_cd = pa.accrual_required_indc_cd, reply->amendment_description = pa
   .amendment_description, reply->amendment_dt_tm = pa.amendment_dt_tm,
   reply->amendment_nbr = pa.amendment_nbr, reply->anticipated_prot_duration = pa
   .anticipated_prot_dur_value, reply->anticipated_prot_dur_uom_cd = pa.anticipated_prot_dur_uom_cd,
   reply->groupwide_targeted_accrual = pa.groupwide_targeted_accrual, reply->prot_master_id = pa
   .prot_master_id, reply->prot_title = pa.prot_title,
   reply->targeted_accrual = pa.targeted_accrual, reply->amendment_status_cd = pa.amendment_status_cd,
   reply->other_applicable_prot_ind = pa.other_applicable_prot_ind,
   reply->safety_monitor_committee_ind = pa.safety_monitor_committee_ind, reply->
   compensation_description = pa.compensation_description, reply->enroll_stratification_type_cd = pa
   .enroll_stratification_type_cd,
   reply->participation_type_cd = pa.participation_type_cd, reply->updt_cnt = pa.updt_cnt, reply->
   compensation_ind = pa.compensation_ind,
   reply->revision_ind = pa.revision_ind, reply->parent_amendment_id = pa.parent_amendment_id, reply
   ->revision_nbr_txt = pa.revision_nbr_txt,
   reply->revision_seq = pa.revision_seq, reply->data_capture_ind = pa.data_capture_ind, reply->
   ct_domain_id = pa.ct_domain_info_id,
   reply->data_script_cd = pa.data_script_cd, reply->auto_enroll_ind = pa.dcv_auto_enroll_ind
  WITH nocounter
 ;end select
 CALL echo(reply->prot_master_id)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = 1
  GO TO endgo
 ENDIF
 IF ((request->copy_for_collab_site=1))
  SELECT INTO "NL:"
   pm.*
   FROM prot_master pm,
    organization o
   PLAN (pm
    WHERE (pm.prot_master_id=request->prot_master_id))
    JOIN (o
    WHERE (pm.collab_site_org_id= Outerjoin(o.organization_id)) )
   DETAIL
    reply->primary_mnemonic = pm.primary_mnemonic, reply->collab_site_org_id = pm.collab_site_org_id,
    reply->collab_site_org_name = o.org_name
   WITH nocounter
  ;end select
 ELSE
  IF ((request->parent_last_high_amd_id > 0))
   SELECT INTO "NL:"
    pa.*
    FROM prot_amendment pa
    WHERE (pa.prot_amendment_id=request->parent_last_high_amd_id)
    DETAIL
     reply->groupwide_targeted_accrual = pa.groupwide_targeted_accrual
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 CALL echo("before select- master")
 SELECT INTO "NL:"
  a.*
  FROM prot_master a,
   organization o
  PLAN (a
   WHERE (a.prot_master_id=reply->prot_master_id))
   JOIN (o
   WHERE (a.collab_site_org_id= Outerjoin(o.organization_id)) )
  DETAIL
   reply->prot_purpose_cd = a.prot_purpose_cd, reply->program_cd = a.program_cd, reply->prot_type_cd
    = a.prot_type_cd,
   reply->prot_phase_cd = a.prot_phase_cd, reply->prot_status_cd = a.prot_status_cd, reply->
   sub_initiating_service_cd = a.sub_initiating_service_cd,
   reply->initiating_service_cd = a.initiating_service_cd, reply->initiating_service_other_desc = a
   .initiating_service_desc
   IF ((reply->primary_mnemonic=""))
    reply->primary_mnemonic = a.primary_mnemonic
   ENDIF
   reply->accession_nbr_last = a.accession_nbr_last, reply->accession_nbr_prefix = a
   .accession_nbr_prefix, reply->accession_nbr_sig_dig = a.accession_nbr_sig_dig,
   reply->prot_master_updt_cnt = a.updt_cnt, reply->display_ind = a.display_ind
   IF ((reply->collab_site_org_id=0))
    reply->collab_site_org_id = a.collab_site_org_id, reply->collab_site_org_name = o.org_name
   ENDIF
   reply->parent_prot_master_id = a.parent_prot_master_id
  WITH nocounter
 ;end select
 CALL echo("after select - master")
 CALL echo(reply->prot_master_id)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = 1
  GO TO endgo
 ENDIF
 SET nbr = 0
 SELECT INTO "nl:"
  r.*
  FROM revision r
  WHERE (r.prot_amendment_id=request->prot_amendment_id)
  DETAIL
   IF ((reply->revision_ind=1))
    reply->revision_id = r.revision_id, reply->revision_description = r.revision_description, reply->
    revision_dt_tm = r.revision_dt_tm
   ELSE
    IF (nbr < r.revision_nbr)
     nbr = r.revision_nbr
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET reply->revision_nbr_highest = nbr
 SELECT INTO "nl:"
  d.*
  FROM contributing_dept d
  WHERE (d.prot_master_id=reply->prot_master_id)
   AND d.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->contributing_depts,(cnt+ 9))
   ENDIF
   reply->contributing_depts[cnt].dept_cd = d.dept_cd, reply->contributing_depts[cnt].dept_other_desc
    = d.dept_desc, reply->contributing_depts[cnt].dept_id = d.contributing_dept_id,
   reply->contributing_depts[cnt].dept_updt_cnt = d.updt_cnt,
   CALL echo(d.dept_desc)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->contributing_depts,cnt)
 CALL echo("before select- regulatory")
 SET cnt = 0
 SELECT INTO "nl:"
  p_r.*
  FROM prot_regulatory_req p_r
  WHERE (p_r.prot_master_id=reply->prot_master_id)
   AND p_r.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->regulatory,(cnt+ 9))
   ENDIF
   reply->regulatory[cnt].reporting_type_cd = p_r.reg_reporting_type_cd, reply->regulatory[cnt].
   regulatory_id = p_r.prot_regulatory_req_id, reply->regulatory[cnt].updt_cnt = p_r.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->regulatory,cnt)
 CALL echo("before select- diseases")
 SET cnt = 0
 SELECT INTO "NL:"
  d.*
  FROM appl_disease d
  WHERE (d.prot_amendment_id=request->prot_amendment_id)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    new = (cnt+ 10), stat = alterlist(reply->diseases,new)
   ENDIF
   reply->diseases[cnt].disease_id = d.appl_disease_id, reply->diseases[cnt].disease_type_cd = d
   .disease_type_cd, reply->diseases[cnt].disease_sub_type_cd = d.disease_sub_type_cd,
   reply->diseases[cnt].disease_updt_cnt = d.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->diseases,cnt)
 CALL echo("before select- modalities")
 SET cnt = 0
 SELECT INTO "NL:"
  p_m.*
  FROM prot_modality p_m
  WHERE (p_m.prot_amendment_id=request->prot_amendment_id)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    new = (cnt+ 10), stat = alterlist(reply->modalities,new)
   ENDIF
   reply->modalities[cnt].modality_id = p_m.prot_modality_id, reply->modalities[cnt].modality_cd =
   p_m.modality_cd, reply->modalities[cnt].modality_updt_cnt = p_m.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->modalities,cnt)
 CALL echo("before select- sponsors")
 SET cnt = 0
 SELECT INTO "NL:"
  p_s.grant_nbr, p_s.organization_id, o.org_name,
  p_s.funded_ind, p_s.grant_project_title, p_s.primary_secondary_cd,
  p_s.updt_cnt, s_t.support_type_cd, s_t.updt_cnt
  FROM prot_grant_sponsor p_s,
   organization o,
   support_type s_t
  PLAN (p_s
   WHERE (p_s.prot_amendment_id=request->prot_amendment_id))
   JOIN (o
   WHERE o.organization_id=p_s.organization_id)
   JOIN (s_t
   WHERE (s_t.prot_grant_sponsor_id= Outerjoin(p_s.prot_grant_sponsor_id)) )
  ORDER BY p_s.prot_grant_sponsor_id
  HEAD p_s.prot_grant_sponsor_id
   cnt += 1
   IF (mod(cnt,10)=1)
    new = (cnt+ 10), stat = alterlist(reply->sponsors,new)
   ENDIF
   reply->sponsors[cnt].prot_grant_sponsor_id = p_s.prot_grant_sponsor_id, reply->sponsors[cnt].
   grant_num = p_s.grant_nbr, reply->sponsors[cnt].organization_id = p_s.organization_id,
   reply->sponsors[cnt].org_name = o.org_name, reply->sponsors[cnt].funded_ind = p_s.funded_ind,
   reply->sponsors[cnt].grant_project_title = p_s.grant_project_title,
   reply->sponsors[cnt].primary_secondary_cd = p_s.primary_secondary_cd, reply->sponsors[cnt].
   sponsor_updt_cnt = p_s.updt_cnt,
   CALL echo(build("org:",o.org_name)),
   cnt1 = 0
  DETAIL
   cnt1 += 1
   IF (mod(cnt1,10)=1)
    new = (cnt1+ 10), stat = alterlist(reply->sponsors[cnt].support_type,new)
   ENDIF
   reply->sponsors[cnt].support_type[cnt1].support_type_id = s_t.support_type_id, reply->sponsors[cnt
   ].support_type[cnt1].support_type_cd = s_t.support_type_cd, reply->sponsors[cnt].support_type[cnt1
   ].support_updt_cnt = s_t.updt_cnt
  FOOT  p_s.prot_grant_sponsor_id
   stat = alterlist(reply->sponsors[cnt].support_type,cnt1)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->sponsors,cnt)
 CALL echo("before select- reviewer")
 SET cnt = 0
 SELECT INTO "NL:"
  p_r.*
  FROM peer_reviewer p_r,
   organization o
  PLAN (p_r
   WHERE (p_r.prot_master_id=reply->prot_master_id))
   JOIN (o
   WHERE p_r.organization_id=o.organization_id)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    new = (cnt+ 10), stat = alterlist(reply->reviewers,new)
   ENDIF
   reply->reviewers[cnt].reviewer_id = p_r.peer_reviewer_id, reply->reviewers[cnt].reviewer_status_cd
    = p_r.peer_reviewer_status_cd, reply->reviewers[cnt].organization_id = p_r.organization_id,
   reply->reviewers[cnt].org_name = o.org_name, reply->reviewers[cnt].reviewer_updt_cnt = p_r
   .updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->reviewers,cnt)
 SET pmid = reply->prot_master_id
 SET highestamdnbr = 0
 SET highestamdid = 0
 EXECUTE ct_get_highest_a_nbr
 CALL echo(build("amd no-",highestamdid))
 CALL echo("before select- aliases")
 SET cnt = 0
 SELECT INTO "nl:"
  d.*
  FROM prot_alias p,
   alias_pool a
  PLAN (p
   WHERE (p.prot_master_id=reply->prot_master_id)
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (a
   WHERE p.alias_pool_cd=a.alias_pool_cd)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->prot_aliases,(cnt+ 9))
   ENDIF
   reply->prot_aliases[cnt].alias_id = p.prot_alias_id, reply->prot_aliases[cnt].alias = p.prot_alias,
   reply->prot_aliases[cnt].alias_pool_cd = a.alias_pool_cd,
   reply->prot_aliases[cnt].alias_format = a.format_mask, reply->prot_aliases[cnt].alias_type_cd = p
   .prot_alias_type_cd, reply->prot_aliases[cnt].alias_updt_cnt = p.updt_cnt,
   CALL echo(build("description:",p.prot_alias)),
   CALL echo(build("description:",a.description))
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->prot_aliases,cnt)
 CALL echo(build("cnt of aliases:",cnt))
 SET cnt = 0
 SELECT INTO "NL:"
  FROM amendment_alias aa,
   alias_pool a
  PLAN (aa
   WHERE (aa.prot_amendment_id=request->prot_amendment_id)
    AND aa.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (a
   WHERE aa.alias_pool_cd=a.alias_pool_cd)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->amd_aliases,(cnt+ 9))
   ENDIF
   reply->amd_aliases[cnt].alias_id = aa.amendment_alias_id, reply->amd_aliases[cnt].alias = aa
   .amendment_alias, reply->amd_aliases[cnt].alias_pool_cd = a.alias_pool_cd,
   reply->amd_aliases[cnt].alias_format = a.format_mask, reply->amd_aliases[cnt].alias_type_cd = aa
   .amendment_alias_type_cd, reply->amd_aliases[cnt].alias_updt_cnt = aa.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->amd_aliases,cnt)
 CALL echo("before select- eligible alias pools")
 SET cnt = 0
 SET institution = 0.0
 SET stat = uar_get_meaning_by_codeset(17296,"INSTITUTION",1,institution)
 SELECT INTO "nl:"
  p.*
  FROM alias_pool p,
   prot_role r,
   org_alias_pool_reltn oar,
   code_value v
  PLAN (r
   WHERE r.prot_amendment_id=highestamdid
    AND r.prot_role_type_cd=institution
    AND r.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (oar
   WHERE oar.organization_id=r.organization_id
    AND oar.active_ind=1
    AND oar.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (v
   WHERE oar.alias_entity_alias_type_cd=v.code_value
    AND v.code_set=12801)
   JOIN (p
   WHERE oar.alias_pool_cd=p.alias_pool_cd
    AND p.active_ind=1
    AND p.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   CALL echo(concat("role is:  ",build(r.prot_role_id))), cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->eligible_alias_pools,(cnt+ 9))
   ENDIF
   reply->eligible_alias_pools[cnt].alias_pool_cd = p.alias_pool_cd, reply->eligible_alias_pools[cnt]
   .format_mask = p.format_mask, reply->eligible_alias_pools[cnt].unique_ind = p.unique_ind,
   reply->eligible_alias_pools[cnt].alias_entity_type_cd = oar.alias_entity_alias_type_cd,
   CALL echo(build("description:",p.description)),
   CALL echo(build("unique_ind:",reply->eligible_alias_pools[cnt].unique_ind))
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->eligible_alias_pools,cnt)
 CALL echo(build("cnt of elig pools:",cnt))
 CALL echo("before select- data submission ")
 SET cnt = 0
 SELECT INTO "NL:"
  d_s.*
  FROM data_submission d_s
  WHERE (d_s.prot_amendment_id=request->prot_amendment_id)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    new = (cnt+ 10), stat = alterlist(reply->data_submission,new)
   ENDIF
   reply->data_submission[cnt].submitted_to_cd = d_s.submitted_to_cd, reply->data_submission[cnt].
   submitted_to_description = d_s.submitted_to_desc, reply->data_submission[cnt].submitted_updt_cnt
    = d_s.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->data_submission,cnt)
 CALL echo("before select- safety_committee ")
 SET cnt = 0
 SELECT INTO "NL:"
  s_c.*
  FROM safety_committee s_c,
   person p
  PLAN (s_c
   WHERE (s_c.prot_amendment_id=request->prot_amendment_id)
    AND s_c.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (p
   WHERE s_c.person_id=p.person_id)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    new = (cnt+ 10), stat = alterlist(reply->safety_committee,new)
   ENDIF
   reply->safety_committee[cnt].person_id = s_c.person_id, reply->safety_committee[cnt].
   safety_updt_cnt = s_c.updt_cnt, reply->safety_committee[cnt].person_full_name = p
   .name_full_formatted
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->safety_committee,cnt)
 CALL echo("before select- reasons")
 SET cnt = 0
 SELECT INTO "NL:"
  a_r.*
  FROM amendment_reason a_r
  WHERE (a_r.prot_amendment_id=request->prot_amendment_id)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    new = (cnt+ 10), stat = alterlist(reply->reasons,new)
   ENDIF
   reply->reasons[cnt].reason_id = a_r.amendment_reason_cd, reply->reasons[cnt].reason_cd = a_r
   .amendment_reason_cd, reply->reasons[cnt].reason_updt_cnt = a_r.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->reasons,cnt)
 CALL echo("before select- objectives")
 SET cnt = 0
 SELECT INTO "NL:"
  p_o.*
  FROM prot_objective p_o,
   long_text_reference ltr
  PLAN (p_o
   WHERE (p_o.prot_amendment_id=request->prot_amendment_id)
    AND p_o.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (ltr
   WHERE ltr.long_text_id=p_o.long_text_id)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    new = (cnt+ 10), stat = alterlist(reply->objectives,new)
   ENDIF
   reply->objectives[cnt].objective_id = p_o.prot_objective_id, reply->objectives[cnt].objective =
   ltr.long_text, reply->objectives[cnt].objective_type_cd = p_o.objective_type_cd,
   reply->objectives[cnt].objective_nbr = p_o.objective_nbr, reply->objectives[cnt].sequence_nbr =
   p_o.sequence_nbr, reply->objectives[cnt].parent_prot_objective_id = p_o.parent_prot_objective_id,
   reply->objectives[cnt].objective_updt_cnt = p_o.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->objectives,cnt)
 CALL echo("before select- strata")
 SET func_doecho = 1
 SET stratum_g_func_status = "F"
 EXECUTE ct_stratum_g_func
 IF (stratum_g_func_status="F")
  GO TO endgo
 ENDIF
 SET stat = uar_get_meaning_by_codeset(18790,"ACCRUAL",1,reply->stypeaccrual)
 SET stat = uar_get_meaning_by_codeset(18790,"BALANCE",1,reply->stypebalance)
 SET stat = uar_get_meaning_by_codeset(18790,"NOSTRAT",1,reply->stypenostrat)
 SET stat = uar_get_meaning_by_codeset(18776,"DEFAULT",1,reply->scohorttypedefault)
 SET stat = uar_get_meaning_by_codeset(18776,"MULTI",1,reply->scohorttypemulti)
 SET stat = uar_get_meaning_by_codeset(18776,"TYPICAL",1,reply->scohorttypetypical)
 SET stat = uar_get_meaning_by_codeset(18778,"CLOSED",1,reply->scohortstatusclosed)
 SET stat = uar_get_meaning_by_codeset(18778,"OPEN",1,reply->scohortstatusopen)
 SET stat = uar_get_meaning_by_codeset(18778,"SUSPENDED",1,reply->scohortstatussuspended)
 SET stat = uar_get_meaning_by_codeset(18775,"OPEN",1,reply->sstatusopen)
 SET stat = uar_get_meaning_by_codeset(18775,"CLOSED",1,reply->sstatusclosed)
 SET stat = uar_get_meaning_by_codeset(18775,"SUSPENDED",1,reply->sstatussuspended)
 SET stat = uar_get_meaning_by_codeset(18785,"AUTOSUSP",1,reply->schgreasonautosusp_cd)
 CALL echo("before select- AGENTDEVS")
 SET cnt = 0
 SET cntown = 0
 SELECT INTO "NL:"
  agent.*
  FROM invest_agent_dev agent,
   invest_new_drug drug,
   invest_dev dev,
   ind_ide_ownership owner,
   person p,
   organization o,
   dummyt d1,
   dummyt d2,
   dummyt d3,
   dummyt d4,
   dummyt d5
  PLAN (agent
   WHERE (agent.prot_amendment_id=request->prot_amendment_id)
    AND agent.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (d1)
   JOIN (drug
   WHERE drug.agent_dev_id=agent.agent_dev_id
    AND drug.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (d2)
   JOIN (dev
   WHERE dev.agent_dev_id=agent.agent_dev_id
    AND dev.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (d3)
   JOIN (owner
   WHERE owner.agent_dev_id=agent.agent_dev_id
    AND owner.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (d4)
   JOIN (p
   WHERE p.person_id=owner.person_id)
   JOIN (d5)
   JOIN (o
   WHERE o.organization_id=owner.organization_id)
  ORDER BY agent.invest_agent_dev_id
  HEAD agent.invest_agent_dev_id
   CALL echo(build("agent.invest_agent_dev_id = ",agent.invest_agent_dev_id))
   IF (((dev.invest_dev_id > 0) OR (drug.invest_new_drug_dev_id > 0)) )
    cnt += 1
    IF (mod(cnt,10)=1)
     new = (cnt+ 9), stat = alterlist(reply->invest_agent,new)
    ENDIF
    reply->invest_agent[cnt].agent_id = agent.invest_agent_dev_id, reply->invest_agent[cnt].
    agent_dev_id = agent.agent_dev_id, reply->invest_agent[cnt].agent_dev_cd = agent
    .invest_agent_dev_cd,
    reply->invest_agent[cnt].agent_updt_cnt = agent.updt_cnt, reply->invest_agent[cnt].drug_dev_id =
    drug.invest_new_drug_dev_id, reply->invest_agent[cnt].drug_catalog_cd = drug.catalog_cd,
    reply->invest_agent[cnt].drug_name = drug.invest_drug_name, reply->invest_agent[cnt].drug_nbr =
    drug.invest_drug_nbr_txt, reply->invest_agent[cnt].drug_updt_cnt = drug.updt_cnt,
    reply->invest_agent[cnt].dev_id = dev.invest_dev_id, reply->invest_agent[cnt].dev_nbr = dev
    .invest_device_nbr_txt, reply->invest_agent[cnt].dev_type_cd = dev.device_type_cd,
    reply->invest_agent[cnt].dev_name = dev.device_name, reply->invest_agent[cnt].dev_updt_cnt = dev
    .updt_cnt,
    CALL echo(concat("Adding agent[",trim(cnvtstring(cnt)),"]",cnvtstring(agent.invest_agent_dev_id),
     " OR ",
     cnvtstring(drug.invest_new_drug_dev_id)))
   ENDIF
   cntown = 0
  DETAIL
   IF (owner.ind_ide_ownership_id > 0
    AND ((dev.invest_dev_id > 0) OR (drug.invest_new_drug_dev_id > 0)) )
    cntown += 1
    IF (mod(cntown,10)=1)
     new = (cntown+ 9), stat = alterlist(reply->invest_agent[cnt].owners,new)
    ENDIF
    reply->invest_agent[cnt].owners[cntown].owner_id = owner.ind_ide_ownership_id, reply->
    invest_agent[cnt].owners[cntown].owner_roletype_cd = owner.role_type_cd, reply->invest_agent[cnt]
    .owners[cntown].org_id = owner.organization_id,
    reply->invest_agent[cnt].owners[cntown].org_name = o.org_name, reply->invest_agent[cnt].owners[
    cntown].person_id = owner.person_id, reply->invest_agent[cnt].owners[cntown].person_name = p
    .name_full_formatted,
    reply->invest_agent[cnt].owners[cntown].nbr = owner.ind_ide_nbr, reply->invest_agent[cnt].owners[
    cntown].valid_from_dt_tm = owner.valid_from_dt_tm, reply->invest_agent[cnt].owners[cntown].
    valid_to_dt_tm = owner.valid_to_dt_tm,
    reply->invest_agent[cnt].owners[cntown].owner_updt_cnt = owner.updt_cnt,
    CALL echo(concat("Adding agent[",trim(cnvtstring(cnt)),"]- Owner[",trim(cnvtstring(cntown)),"]: ",
     trim(p.name_full_formatted),trim(o.org_name)))
   ENDIF
  FOOT  agent.invest_agent_dev_id
   IF (((dev.invest_dev_id > 0) OR (drug.invest_new_drug_dev_id > 0)) )
    stat = alterlist(reply->invest_agent[cnt].owners,cntown),
    CALL echo(concat("alterlist agent[",trim(cnvtstring(cnt)),"]- Owner to: ",trim(cnvtstring(cntown)
      )))
   ENDIF
  WITH dontcare = drug, dontcare = dev, dontcare = owner,
   outerjoin = d4, outerjoin = d5, nocounter
 ;end select
 SET stat = alterlist(reply->invest_agent,cnt)
 IF ((request->copy_for_collab_site=0))
  SET cnt = 0
  SELECT INTO "NL:"
   FROM prot_amd_committee_reltn pacr,
    committee com
   PLAN (pacr
    WHERE (pacr.prot_amendment_id=request->prot_amendment_id)
     AND pacr.active_ind=1)
    JOIN (com
    WHERE com.committee_id=pacr.committee_id)
   ORDER BY com.committee_name
   DETAIL
    cnt += 1
    IF (mod(cnt,10)=1)
     new = (cnt+ 10), stat = alterlist(reply->committees,new)
    ENDIF
    reply->committees[cnt].prot_amd_committee_id = pacr.prot_amd_committee_id, reply->committees[cnt]
    .committee_id = pacr.committee_id, reply->committees[cnt].committee_name = com.committee_name,
    reply->committees[cnt].committee_type_cd = com.committee_type_cd, reply->committees[cnt].
    validate_ind = pacr.validate_ind, reply->committees[cnt].edit_ind = pacr.edit_ind,
    reply->committees[cnt].updt_cnt = pacr.updt_cnt
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->committees,cnt)
 ENDIF
 IF ((reply->data_capture_ind > 0))
  RECORD datacapturerequest(
    1 prot_amendment_id = f8
    1 get_amd_orgs_ind = i2
  )
  RECORD datacapturereply(
    1 long_text = vc
    1 long_text_id = f8
    1 orgs[*]
      2 org_id = f8
      2 org_name = c100
    1 ct_domain_id = f8
    1 url_one_text = c255
    1 url_two_text = c255
    1 data_script_cd = f8
    1 data_script_disp = c40
    1 data_script_desc = c60
    1 data_script_mean = c12
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET datacapturerequest->prot_amendment_id = request->prot_amendment_id
  EXECUTE ct_get_prot_data_capture  WITH replace("REQUEST","DATACAPTUREREQUEST"), replace("REPLY",
   "DATACAPTUREREPLY")
  IF ((datacapturereply->status_data.status="S")
   AND (datacapturereply->long_text_id > 0))
   SET reply->data_capture_str = datacapturereply->long_text
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#endgo
 CALL echo(build("reply status:",reply->status_data.status))
 SET last_mod = "023"
 SET mod_date = "Nov 13, 2019"
 SET debug_code_stemp = fillstring(999," ")
 SET debug_code_ecode = 1
 SET debug_code_cntd = size(reply->debug,5)
 WHILE (debug_code_ecode != 0)
  SET debug_code_ecode = error(debug_code_stemp,0)
  IF (debug_code_ecode != 0)
   SET debug_code_cntd += 1
   SET stat = alterlist(reply->debug,debug_code_cntd)
   SET reply->debug[debug_code_cntd].str = debug_code_stemp
  ENDIF
 ENDWHILE
END GO

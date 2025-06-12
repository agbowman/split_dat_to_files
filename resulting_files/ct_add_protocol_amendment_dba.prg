CREATE PROGRAM ct_add_protocol_amendment:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET prot_master_id = 0.0
 SET failed = "F"
 SET program_cd = 0
 SET prot_purpose_cd = 0
 SET prot_status_cd = 0
 SET peer_review_indicator_cd = 0
 SET amendment_num = 1
 SET amendment_status_cd = 0
 SELECT INTO "NL:"
  a.*
  FROM prot_master a
  WHERE (a.primary_mnemonic=request->primary_mnemonic)
 ;end select
 IF (curqual != 0)
  GO TO endgo
 ENDIF
 SELECT INTO "NL:"
  code_value.code_value
  FROM code_value cv
  WHERE cv.code_set=17276
   AND cv.cdf_meaning="UDEFINED"
  DETAIL
   prot_purpose_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  num = seq(protocol_def_seq,nextval)"########################;rpO"
  FROM dual
  DETAIL
   prot_master_id = cnvtreal(num)
  WITH format, counter
 ;end select
 CALL echo("before select")
 INSERT  FROM prot_master pa
  SET pa.prot_master_id = prot_master_id, pa.initiating_service_cd = request->initiating_service_cd,
   pa.initiating_service_desc = request->initiating_service_desc,
   pa.peer_review_indicator_cd = peer_review_indicator_cd, pa.program_cd = program_cd, pa
   .prot_master_id = prot_master_id,
   pa.prot_phase_cd = request->prot_phase_cd, pa.prot_purpose_cd = prot_purpose_cd, pa.prot_status_cd
    = prot_status_cd,
   pa.prot_type_cd = request->prot_type_cd, pa.primary_mnemonic = request->primary_mnemonic, pa
   .prescreen_type_flag = 1,
   pa.updt_dt_tm = cnvtdatetime(sysdate), pa.updt_id = reqinfo->updt_id, pa.updt_applctx = reqinfo->
   updt_applctx,
   pa.updt_task = reqinfo->updt_task, pa.updt_cnt = 0
  WITH nocounter
 ;end insert
 CALL echo("after insert")
 IF (curqual=0)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  GO TO endgo
 ENDIF
 SELECT INTO "nl:"
  num = seq(protocol_def_seq,nextval)"########################;rpO"
  FROM dual
  DETAIL
   primary_id = cnvtreal(num)
  WITH format, counter
 ;end select
 CALL echo("before select")
 SET num_to_add = size(request->contributing_depts,5)
 FOR (i = 1 TO num_to_add)
  SELECT INTO "nl:"
   num = seq(protocol_def_seq,nextval)"########################;rpO"
   FROM dual
   DETAIL
    primary_id = cnvtreal(num)
   WITH format, counter
  ;end select
  INSERT  FROM contributing_dept d
   SET d.contributing_dept_id = primary_id, d.prot_master_id = prot_master_id, d.dept_cd = request->
    contributing_depts[i].dept_cd,
    d.dept_desc = request->contributing_depts[i].dept_desc, d.beg_effective_dt_tm = cnvtdatetime(
     sysdate), d.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
    d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_id, d.updt_applctx = reqinfo->
    updt_applctx,
    d.updt_task = reqinfo->updt_task, d.updt_cnt = 0
  ;end insert
 ENDFOR
 SET amendment_id = 0.0
 SET failed = "F"
 SET accrual_required_indc_cd = 0
 SET anticipated_prot_dur_uom_cd = 0
 SET amendment_status_cd = 0
 CALL echo("before role type")
 SELECT INTO "NL:"
  code_value.code_value
  FROM code_value cv
  WHERE cv.code_set=17274
   AND (cv.cdf_meaning=request->amendment_status_cdf)
  DETAIL
   amendment_status_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  code_value.code_value
  FROM code_value cv
  WHERE cv.code_set=17438
   AND (cv.cdf_meaning=request->accrual_required_indc_cdf)
  DETAIL
   accrual_required_indc_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  code_value.code_value
  FROM code_value cv
  WHERE cv.code_set=17278
   AND (cv.cdf_meaning=request->anticipated_prot_dur_uom_cdf)
  DETAIL
   anticipated_prot_dur_uom_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  num = seq(protocol_def_seq,nextval)"########################;rpO"
  FROM dual
  DETAIL
   amendment_id = cnvtreal(num)
  WITH format, counter
 ;end select
 CALL echo("before select")
 INSERT  FROM prot_amendment pa
  SET pa.prot_amendment_id = amendment_id, pa.accrual_required_indc_cd = accrual_required_indc_cd, pa
   .amendment_description = request->amendment_description,
   pa.amendment_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), pa.amendment_nbr = amendment_num, pa
   .anticipated_prot_dur_value = request->anticipated_prot_duration,
   pa.anticipated_prot_dur_uom_cd = anticipated_prot_dur_uom_cd, pa.groupwide_targeted_accrual =
   request->groupwide_targeted_accrual, pa.prot_master_id = prot_master_id,
   pa.prot_title = request->prot_title, pa.targeted_accrual = request->targeted_accrual, pa
   .amendment_status_cd = amendment_status_cd,
   pa.participation_type_cd = request->participation_type_cd, pa.other_applicable_prot_ind = request
   ->other_applicable_prot_ind, pa.safety_monitor_committee_ind = request->
   safety_monitor_committee_ind,
   pa.compensation_description = request->compensation_description, pa.updt_dt_tm = cnvtdatetime(
    sysdate), pa.updt_id = reqinfo->updt_id,
   pa.updt_applctx = reqinfo->updt_applctx, pa.updt_task = reqinfo->updt_task, pa.updt_cnt = 0
  WITH nocounter
 ;end insert
 SET num_to_add = size(request->diseases,5)
 FOR (i = 1 TO num_to_add)
  SELECT INTO "nl:"
   num = seq(protocol_def_seq,nextval)"########################;rpO"
   FROM dual
   DETAIL
    primary_id = cnvtreal(num)
   WITH format, counter
  ;end select
  INSERT  FROM appl_disease d
   SET d.appl_disease_id = primary_id, d.prot_amendment_id = amendment_id, d.disease_type_cd =
    request->disease[i].disease_type_cd,
    d.disease_sub_type_cd = request->disease[i].disease_sub_type_cd, d.updt_dt_tm = cnvtdatetime(
     sysdate), d.updt_id = reqinfo->updt_id,
    d.updt_applctx = reqinfo->updt_applctx, d.updt_task = reqinfo->updt_task, d.updt_cnt = 0
   WITH nocounter
  ;end insert
 ENDFOR
 SET num_to_add = size(request->modalities,5)
 FOR (i = 1 TO num_to_add)
  SELECT INTO "nl:"
   num = seq(protocol_def_seq,nextval)"########################;rpO"
   FROM dual
   DETAIL
    primary_id = cnvtreal(num)
   WITH format, counter
  ;end select
  INSERT  FROM prot_modality p_m
   SET p_m.prot_modality_id = primary_id, p_m.prot_amendment_id = amendment_id, p_m.modality_cd =
    request->modalities[i].modality_cd,
    p_m.updt_dt_tm = cnvtdatetime(sysdate), p_m.updt_id = reqinfo->updt_id, p_m.updt_applctx =
    reqinfo->updt_applctx,
    p_m.updt_task = reqinfo->updt_task, p_m.updt_cnt = 0
   WITH nocounter
  ;end insert
 ENDFOR
 SET num_to_add = size(request->sponsors,5)
 FOR (i = 1 TO num_to_add)
  SELECT INTO "nl:"
   num = seq(protocol_def_seq,nextval)"########################;rpO"
   FROM dual
   DETAIL
    primary_id = cnvtreal(num)
   WITH format, counter
  ;end select
  INSERT  FROM prot_grant_sponsor p_s
   SET p_s.prot_grant_sponsor_id = primary_id, p_s.prot_amendment_id = amendment_id, p_s.grant_num =
    request->sponsors[i].grant_num,
    p_s.organization_id = request->sponsors[i].organization_id, p_s.grant_project_title = request->
    sponsors[i].grant_project_title, p_s.primary_secondary_cd = request->sponsors[i].
    primary_secondary_cd,
    p_s.updt_dt_tm = cnvtdatetime(sysdate), p_s.updt_id = reqinfo->updt_id, p_s.updt_applctx =
    reqinfo->updt_applctx,
    p_s.updt_task = reqinfo->updt_task, p_s.updt_cnt = 0
   WITH nocounter
  ;end insert
 ENDFOR
 SET num_to_add = size(request->data_submission,5)
 FOR (i = 1 TO num_to_add)
  SELECT INTO "nl:"
   num = seq(protocol_def_seq,nextval)"########################;rpO"
   FROM dual
   DETAIL
    primary_id = cnvtreal(num)
   WITH format, counter
  ;end select
  INSERT  FROM data_submission d_s
   SET d_s.data_submission_id = primary_id, d_s.prot_amendment_id = amendment_id, d_s.submitted_to_cd
     = request->sponsors[i].submitted_to_cd,
    d_s.submitted_to_desc = request->sponsors[i].submitted_to_desc, d_s.updt_dt_tm = cnvtdatetime(
     sysdate), d_s.updt_id = reqinfo->updt_id,
    d_s.updt_applctx = reqinfo->updt_applctx, d_s.updt_task = reqinfo->updt_task, d_s.updt_cnt = 0
   WITH nocounter
  ;end insert
 ENDFOR
 SET num_to_add = size(request->safety_committee,5)
 FOR (i = 1 TO num_to_add)
  SELECT INTO "nl:"
   num = seq(protocol_def_seq,nextval)"########################;rpO"
   FROM dual
   DETAIL
    primary_id = cnvtreal(num)
   WITH format, counter
  ;end select
  INSERT  FROM safety_committee s_c
   SET s_c.safety_committee_id = primary_id, s_c.prot_amendment_id = amendment_id, s_c.person_id =
    request->safety_committee[i].person_id,
    s_c.beg_effective_dt_tm = cnvtdatetime(sysdate), s_c.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100 00:00:00.00"), s_c.updt_dt_tm = cnvtdatetime(sysdate),
    s_c.updt_id = reqinfo->updt_id, s_c.updt_applctx = reqinfo->updt_applctx, s_c.updt_task = reqinfo
    ->updt_task,
    s_c.updt_cnt = 0
   WITH nocounter
  ;end insert
 ENDFOR
 CALL echo("after insert")
 EXECUTE ct_add_peer_reviewer
 IF (curqual != 0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
#endgo
END GO

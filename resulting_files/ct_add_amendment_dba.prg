CREATE PROGRAM ct_add_amendment:dba
 RECORD reply(
   1 prot_amendment_id = f8
   1 revision_id = f8
   1 statusfunc = c1
   1 a_c_results[*]
     2 a_key = vc
     2 stratumstatus = c1
     2 prot_stratum_id = f8
     2 stratum_id = f8
     2 suspsummary = c1
     2 cohortsummary = c1
     2 susps[*]
       3 a_key = vc
       3 suspstatus = c1
       3 prot_stratum_susp_id = f8
       3 susp_id = f8
     2 cohorts[*]
       3 a_key = vc
       3 cohortstatus = c1
       3 prot_cohort_id = f8
       3 cohort_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 debug[*]
     2 str = vc
   1 probdesc[*]
     2 str = vc
 )
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 SET reply->status_data.status = "F"
 DECLARE cur_updt_cnt = i2 WITH protect, noconstant(0)
 DECLARE accrual_required_indc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE anticipated_prot_dur_uom_cd = f8 WITH protect, noconstant(0.0)
 DECLARE amendment_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE role_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pr_role_type = f8 WITH protect, noconstant(0.0)
 DECLARE primary_secondary_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cdf_meaning = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE sponsor_id = f8 WITH protect, noconstant(0.0)
 DECLARE parent_amendment_id = f8 WITH protect, noconstant(0.0)
 DECLARE stat = i2 WITH private, noconstant(0)
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE prev_amendment_id = f8 WITH protect, noconstant(0.0)
 SET currentdate = cnvtdatetime(sysdate)
 DECLARE generate_id = i2 WITH private, constant(1)
 DECLARE insert_error = i2 WITH private, constant(2)
 DECLARE update_error = i2 WITH private, constant(3)
 DECLARE updt_cnt_no_match = i2 WITH private, constant(4)
 DECLARE amd_number_exists = i2 WITH private, constant(5)
 SET stat = uar_get_meaning_by_codeset(17274,"INDVLPMENT",1,amendment_status_cd)
 IF ((request->revision_ind=0))
  SELECT INTO "nl:"
   pa.*
   FROM prot_amendment pa
   WHERE (pa.prot_master_id=request->prot_master_id)
    AND (pa.amendment_nbr=request->amendment_num)
   WITH nocounter
  ;end select
  IF (curqual != 0)
   SET fail_flag = amd_number_exists
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Searching for duplicate amd amendment number in prot_amendment."
   GO TO check_error
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  num = seq(protocol_def_seq,nextval)
  FROM dual
  DETAIL
   reply->prot_amendment_id = num
  WITH format, counter
 ;end select
 IF ((request->revision_ind=1)
  AND (request->collab_site_amd_ind=0))
  SET parent_amendment_id = request->parent_amendment_id
 ELSE
  SET parent_amendment_id = reply->prot_amendment_id
 ENDIF
 CALL echo("before SELECT")
 INSERT  FROM prot_amendment pa
  SET pa.prot_amendment_id = reply->prot_amendment_id, pa.enroll_stratification_type_cd = request->
   enroll_stratification_type_cd, pa.accrual_required_indc_cd = request->accrual_required_indc_cd,
   pa.amendment_description = request->amendment_description, pa.amendment_dt_tm = cnvtdatetime(
    "31-dec-2100 00:00:00"), pa.amendment_nbr = request->amendment_num,
   pa.anticipated_prot_dur_value = request->anticipated_prot_duration, pa.anticipated_prot_dur_uom_cd
    = request->anticipated_prot_dur_uom_cd, pa.groupwide_targeted_accrual =
   IF ((request->collab_site_amd_ind=0)) request->groupwide_targeted_accrual
   ELSE 0
   ENDIF
   ,
   pa.prot_master_id = request->prot_master_id, pa.prot_title = request->prot_title, pa
   .targeted_accrual = request->targeted_accrual,
   pa.amendment_status_cd = amendment_status_cd, pa.other_applicable_prot_ind = request->
   other_applicable_prot_ind, pa.safety_monitor_committee_ind = request->safety_monitor_committee_ind,
   pa.compensation_description = request->compensation_description, pa.participation_type_cd =
   request->participation_type_cd, pa.updt_dt_tm = cnvtdatetime(currentdate),
   pa.updt_id = reqinfo->updt_id, pa.updt_applctx = reqinfo->updt_applctx, pa.updt_task = reqinfo->
   updt_task,
   pa.updt_cnt = 0, pa.compensation_ind = request->compensation_ind, pa.revision_ind = request->
   revision_ind,
   pa.parent_amendment_id = parent_amendment_id, pa.revision_seq = request->revision_seq, pa
   .revision_nbr_txt = request->revision_nbr_txt,
   pa.data_capture_ind = request->data_capture_ind, pa.ct_domain_info_id = request->ct_domain_id, pa
   .data_script_cd = request->data_script_cd,
   pa.dcv_auto_enroll_ind = request->auto_enroll_ind
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET fail_flag = insert_error
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Inserting into prot_amendment table."
  GO TO check_error
 ENDIF
 SELECT INTO "nl:"
  num = seq(protocol_def_seq,nextval)
  FROM dual
  DETAIL
   reply->revision_id = num
  WITH format, counter
 ;end select
 INSERT  FROM revision r
  SET r.revision_id = reply->revision_id, r.prot_amendment_id = reply->prot_amendment_id, r
   .revision_nbr = request->revision_nbr,
   r.revision_description = request->revision_description, r.revision_dt_tm = cnvtdatetime(
    currentdate), r.updt_dt_tm = cnvtdatetime(sysdate),
   r.updt_id = reqinfo->updt_id, r.updt_applctx = reqinfo->updt_applctx, r.updt_task = reqinfo->
   updt_task,
   r.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET fail_flag = insert_error
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Inserting into revision table."
  GO TO check_error
 ENDIF
 SET stat = uar_get_meaning_by_codeset(17441,"CREATOR",1,role_cd)
 SET stat = uar_get_meaning_by_codeset(17296,"PERSONAL",1,pr_role_type)
 CALL echo("before role")
 INSERT  FROM prot_role ro
  SET ro.prot_role_id = seq(protocol_def_seq,nextval), ro.prot_amendment_id = reply->
   prot_amendment_id, ro.prot_role_type_cd = pr_role_type,
   ro.person_id = reqinfo->updt_id, ro.prot_role_cd = role_cd, ro.beg_effective_dt_tm = cnvtdatetime(
    sysdate),
   ro.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), ro.updt_dt_tm = cnvtdatetime(
    sysdate), ro.updt_id = reqinfo->updt_id,
   ro.updt_applctx = reqinfo->updt_applctx, ro.updt_task = reqinfo->updt_task, ro.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET fail_flag = insert_error
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Inserting creator into prot_role table."
  GO TO check_error
 ENDIF
 IF ((request->insert_def_roles_ind=1))
  RECORD defaultroles(
    1 defrolelist[*]
      2 prot_role_cd = f8
      2 prot_role_type_cd = f8
      2 person_id = f8
      2 organization_id = f8
      2 position_cd = f8
  )
  DECLARE rolecnt = i2 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM prot_default_roles pdr
   WHERE (pdr.logical_domain_id=domain_reply->logical_domain_id)
   DETAIL
    rolecnt += 1
    IF (mod(rolecnt,10)=1)
     stat = alterlist(defaultroles->defrolelist,(rolecnt+ 9))
    ENDIF
    defaultroles->defrolelist[rolecnt].prot_role_cd = pdr.prot_role_cd, defaultroles->defrolelist[
    rolecnt].prot_role_type_cd = pdr.role_type_cd, defaultroles->defrolelist[rolecnt].person_id = pdr
    .person_id,
    defaultroles->defrolelist[rolecnt].organization_id = pdr.organization_id, defaultroles->
    defrolelist[rolecnt].position_cd = pdr.position_cd
   WITH nocounter
  ;end select
  SET stat = alterlist(defaultroles->defrolelist,rolecnt)
  IF (rolecnt > 0)
   INSERT  FROM prot_role pr,
     (dummyt d  WITH seq = value(rolecnt))
    SET pr.prot_role_id = seq(protocol_def_seq,nextval), pr.prot_amendment_id = reply->
     prot_amendment_id, pr.prot_role_cd = defaultroles->defrolelist[d.seq].prot_role_cd,
     pr.prot_role_type_cd = defaultroles->defrolelist[d.seq].prot_role_type_cd, pr.person_id =
     defaultroles->defrolelist[d.seq].person_id, pr.organization_id = defaultroles->defrolelist[d.seq
     ].organization_id,
     pr.position_cd = defaultroles->defrolelist[d.seq].position_cd, pr.beg_effective_dt_tm =
     cnvtdatetime(sysdate), pr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
     pr.updt_dt_tm = cnvtdatetime(sysdate), pr.updt_id = reqinfo->updt_id, pr.updt_applctx = reqinfo
     ->updt_applctx,
     pr.updt_task = reqinfo->updt_task, pr.updt_cnt = 0
    PLAN (d)
     JOIN (pr)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET fail_flag = insert_error
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Inserting default roles into prot_role table."
    GO TO check_error
   ENDIF
  ENDIF
 ENDIF
 CALL echo("after INSERT- role")
 IF ((request->prot_status_ind=1))
  SELECT INTO "nl:"
   pr.*
   FROM prot_master pr
   WHERE (pr.prot_master_id=request->prot_master_id)
   DETAIL
    cur_updt_cnt = pr.updt_cnt
   WITH nocounter, forupdate(pr)
  ;end select
  IF (curqual=0)
   SET fail_flag = find_cur_updt_cnt
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Searching for current update count in prot_master table."
   GO TO check_error
  ENDIF
  IF ((cur_updt_cnt != request->prot_updt_cnt))
   SET fail_flag = updt_cnt_no_match
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Update counts for prot_master and request don't match."
   GO TO check_error
  ENDIF
  INSERT  FROM prot_master pm
   (pm.prot_master_id, pm.accession_nbr_last, pm.accession_nbr_prefix,
   pm.accession_nbr_sig_dig, pm.prescreen_type_flag, pm.beg_effective_dt_tm,
   pm.collab_site_org_id, pm.display_ind, pm.end_effective_dt_tm,
   pm.initiating_service_cd, pm.initiating_service_desc, pm.parent_prot_master_id,
   pm.participation_type_cd, pm.peer_review_indicator_cd, pm.prev_prot_master_id,
   pm.primary_mnemonic, pm.primary_mnemonic_key, pm.program_cd,
   pm.prot_phase_cd, pm.prot_purpose_cd, pm.prot_status_cd,
   pm.prot_type_cd, pm.research_sponsor_org_id, pm.updt_dt_tm,
   pm.updt_id, pm.updt_task, pm.updt_applctx,
   pm.updt_cnt, pm.logical_domain_id)(SELECT
    seq(protocol_def_seq,nextval), pm1.accession_nbr_last, pm1.accession_nbr_prefix,
    pm1.accession_nbr_sig_dig, pm1.prescreen_type_flag, pm1.beg_effective_dt_tm,
    pm1.collab_site_org_id, pm1.display_ind, cnvtdatetime(script_date),
    pm1.initiating_service_cd, pm1.initiating_service_desc, pm1.parent_prot_master_id,
    pm1.participation_type_cd, pm1.peer_review_indicator_cd, pm1.prev_prot_master_id,
    pm1.primary_mnemonic, pm1.primary_mnemonic_key, pm1.program_cd,
    pm1.prot_phase_cd, pm1.prot_purpose_cd, pm1.prot_status_cd,
    pm1.prot_type_cd, pm1.research_sponsor_org_id, pm1.updt_dt_tm,
    pm1.updt_id, pm1.updt_task, pm1.updt_applctx,
    pm1.updt_cnt, pm1.logical_domain_id
    FROM prot_master pm1
    WHERE (pm1.prot_master_id=request->prot_master_id))
  ;end insert
  IF (curqual=0)
   SET fail_flag = insert_error
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Inserting previous record into the prot_master table."
   GO TO check_error
  ENDIF
  CALL echo("before update")
  UPDATE  FROM prot_master pr
   SET pr.prot_status_cd = amendment_status_cd, pr.updt_dt_tm = cnvtdatetime(sysdate), pr.updt_id =
    reqinfo->updt_id,
    pr.updt_applctx = reqinfo->updt_applctx, pr.updt_task = reqinfo->updt_task, pr.updt_cnt = (pr
    .updt_cnt+ 1),
    pr.beg_effective_dt_tm = cnvtdatetime(script_date)
   WHERE (pr.prot_master_id=request->prot_master_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET fail_flag = update_error
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Updating status in prot_master table."
   GO TO check_error
  ENDIF
 ENDIF
 SET num_to_add = size(request->diseases,5)
 FOR (i = 1 TO num_to_add)
  INSERT  FROM appl_disease d
   SET d.appl_disease_id = seq(protocol_def_seq,nextval), d.prot_amendment_id = reply->
    prot_amendment_id, d.disease_type_cd = request->diseases[i].disease_type_cd,
    d.appl_disease_desc_otr = request->diseases[i].disease_desc_other, d.updt_dt_tm = cnvtdatetime(
     sysdate), d.updt_id = reqinfo->updt_id,
    d.updt_applctx = reqinfo->updt_applctx, d.updt_task = reqinfo->updt_task, d.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET fail_flag = insert_error
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Inserting appl_diseases table."
   GO TO check_error
  ENDIF
 ENDFOR
 SET num_to_add = size(request->modalities,5)
 FOR (i = 1 TO num_to_add)
  INSERT  FROM prot_modality p_m
   SET p_m.prot_modality_id = seq(protocol_def_seq,nextval), p_m.prot_amendment_id = reply->
    prot_amendment_id, p_m.modality_cd = request->modalities[i].modality_cd,
    p_m.modality_desc_otr = request->modalities[i].modality_desc_other, p_m.updt_dt_tm = cnvtdatetime
    (sysdate), p_m.updt_id = reqinfo->updt_id,
    p_m.updt_applctx = reqinfo->updt_applctx, p_m.updt_task = reqinfo->updt_task, p_m.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET fail_flag = insert_error
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Inserting into prot_modality table."
   GO TO check_error
  ENDIF
 ENDFOR
 SET num_to_add = size(request->sponsors,5)
 SET sponsor_id = 0.0
 FOR (i = 1 TO num_to_add)
   SET primary_secondary_cd = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = request->sponsors[i].primary_secondary_cdf
   SET stat = uar_get_meaning_by_codeset(17271,cdf_meaning,1,primary_secondary_cd)
   SELECT INTO "nl:"
    num = seq(protocol_def_seq,nextval)
    FROM dual
    DETAIL
     sponsor_id = num
    WITH format, counter
   ;end select
   IF (curqual=0)
    SET fail_flag = generate_id
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Generating sponsor id"
    GO TO check_error
   ENDIF
   INSERT  FROM prot_grant_sponsor p_s
    SET p_s.prot_grant_sponsor_id = sponsor_id, p_s.prot_amendment_id = reply->prot_amendment_id, p_s
     .grant_nbr = request->sponsors[i].grant_num,
     p_s.organization_id = request->sponsors[i].organization_id, p_s.funded_ind = request->sponsors[i
     ].funded_ind, p_s.primary_secondary_cd = primary_secondary_cd,
     p_s.updt_dt_tm = cnvtdatetime(sysdate), p_s.updt_id = reqinfo->updt_id, p_s.updt_applctx =
     reqinfo->updt_applctx,
     p_s.updt_task = reqinfo->updt_task, p_s.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET fail_flag = insert_error
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Inserting into prot_grant_sponsor table."
    GO TO check_error
   ENDIF
   SET num_of_support = size(request->sponsors[i].support_type,5)
   FOR (j = 1 TO num_of_support)
    INSERT  FROM support_type p_s
     SET p_s.support_type_id = seq(protocol_def_seq,nextval), p_s.prot_grant_sponsor_id = sponsor_id,
      p_s.support_type_cd = request->sponsors[i].support_type[j].support_type_cd,
      p_s.updt_dt_tm = cnvtdatetime(sysdate), p_s.updt_id = reqinfo->updt_id, p_s.updt_applctx =
      reqinfo->updt_applctx,
      p_s.updt_task = reqinfo->updt_task, p_s.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET fail_flag = insert_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Inserting into support_type table."
     GO TO check_error
    ENDIF
   ENDFOR
 ENDFOR
 SET num_to_add = size(request->data_submission,5)
 FOR (i = 1 TO num_to_add)
  INSERT  FROM data_submission d_s
   SET d_s.data_submission_id = seq(protocol_def_seq,nextval), d_s.prot_amendment_id = reply->
    prot_amendment_id, d_s.submitted_to_cd = request->data_submission[i].submitted_to_cd,
    d_s.submitted_to_desc = request->data_submission[i].submitted_to_desc, d_s.updt_dt_tm =
    cnvtdatetime(sysdate), d_s.updt_id = reqinfo->updt_id,
    d_s.updt_applctx = reqinfo->updt_applctx, d_s.updt_task = reqinfo->updt_task, d_s.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET fail_flag = insert_error
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Inserting into data_submission table."
   GO TO check_error
  ENDIF
 ENDFOR
 SET num_to_add = size(request->safety_committee,5)
 FOR (i = 1 TO num_to_add)
  INSERT  FROM safety_committee s_c
   SET s_c.safety_committee_id = seq(protocol_def_seq,nextval), s_c.prot_amendment_id = reply->
    prot_amendment_id, s_c.person_id = request->safety_committee[i].person_id,
    s_c.beg_effective_dt_tm = cnvtdatetime(sysdate), s_c.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100 00:00:00.00"), s_c.updt_dt_tm = cnvtdatetime(sysdate),
    s_c.updt_id = reqinfo->updt_id, s_c.updt_applctx = reqinfo->updt_applctx, s_c.updt_task = reqinfo
    ->updt_task,
    s_c.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET fail_flag = insert_error
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Inserting into safety_committee table."
   GO TO check_error
  ENDIF
 ENDFOR
 SET num_to_add = size(request->reasons,5)
 FOR (i = 1 TO num_to_add)
  INSERT  FROM amendment_reason a_r
   SET a_r.amendment_reason_id = seq(protocol_def_seq,nextval), a_r.prot_amendment_id = reply->
    prot_amendment_id, a_r.amendment_reason_cd = request->reasons[i].reason_cd,
    a_r.updt_dt_tm = cnvtdatetime(sysdate), a_r.updt_id = reqinfo->updt_id, a_r.updt_applctx =
    reqinfo->updt_applctx,
    a_r.updt_task = reqinfo->updt_task, a_r.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET fail_flag = insert_error
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Inserting into amendment_reason table."
   GO TO check_error
  ENDIF
 ENDFOR
 SET num_to_add = size(request->objectives,5)
 FOR (i = 1 TO num_to_add)
   INSERT  FROM long_text_reference ltr
    SET ltr.long_text_id = seq(long_data_seq,nextval), ltr.long_text = request->objectives[i].
     objective, ltr.parent_entity_name = "PROT_OBJECTIVE",
     ltr.parent_entity_id = reply->prot_amendment_id, ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr
     .updt_id = reqinfo->updt_id,
     ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_task = reqinfo->updt_task, ltr.updt_cnt = 0,
     ltr.active_ind = 1, ltr.active_status_cd = reqdata->active_status_cd, ltr.active_status_dt_tm =
     cnvtdatetime(sysdate),
     ltr.active_status_prsnl_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET fail_flag = insert_error
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Inserting into long_text_reference for objective."
    GO TO check_error
   ENDIF
   CALL echo("before insert - objectives")
   INSERT  FROM prot_objective p_o
    SET p_o.prot_objective_id = seq(protocol_def_seq,nextval), p_o.prot_amendment_id = reply->
     prot_amendment_id, p_o.objective_type_cd = request->objectives[i].objective_type_cd,
     p_o.objective_nbr = request->objectives[i].objective_nbr, p_o.sequence_nbr = request->
     objectives[i].sequence_nbr, p_o.long_text_id = seq(long_data_seq,currval),
     p_o.beg_effective_dt_tm = cnvtdatetime(sysdate), p_o.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100 00:00:00.00"), p_o.updt_dt_tm = cnvtdatetime(sysdate),
     p_o.updt_id = reqinfo->updt_id, p_o.updt_applctx = reqinfo->updt_applctx, p_o.updt_task =
     reqinfo->updt_task,
     p_o.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET fail_flag = insert_error
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Inserting objective into prot_objective table."
    GO TO check_error
   ENDIF
 ENDFOR
 SET num_to_add = size(request->ss,5)
 CALL echo(num_to_add)
 IF (num_to_add > 0)
  CALL echo("pre call to ct_stratum_a_c_func")
  SET func_doecho = 0
  SET request->prot_amendment_id = reply->prot_amendment_id
  EXECUTE ct_stratum_a_c_func
  IF ((reply->statusfunc="F"))
   SET fail_flag = insert_error
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Addding stratum and cohort"
   GO TO check_error
  ENDIF
  CALL echo("Post call to ct_stratum_a_c_func")
 ENDIF
 SET num_to_add = size(request->invest_agent,5)
 DECLARE agent_dev_cd = f8 WITH protect, noconstant(0.0)
 DECLARE role_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE agent_id = f8 WITH protect, noconstant(0.0)
 DECLARE in_role_type = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(17296,"INSTITUTION",1,in_role_type)
 FOR (i = 1 TO num_to_add)
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = request->invest_agent[i].agent_dev_mean
   SET stat = uar_get_meaning_by_codeset(17444,cdf_meaning,1,agent_dev_cd)
   SELECT INTO "nl:"
    num = seq(protocol_def_seq,nextval)
    FROM dual
    DETAIL
     agent_id = num
    WITH format, counter
   ;end select
   IF (curqual=0)
    SET fail_flag = generate_id
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Generating agent id"
    GO TO check_error
   ENDIF
   INSERT  FROM invest_agent_dev agent
    SET agent.invest_agent_dev_id = agent_id, agent.agent_dev_id = agent_id, agent.prot_amendment_id
      = reply->prot_amendment_id,
     agent.invest_agent_dev_cd = agent_dev_cd, agent.beg_effective_dt_tm = cnvtdatetime(sysdate),
     agent.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
     agent.updt_dt_tm = cnvtdatetime(sysdate), agent.updt_id = reqinfo->updt_id, agent.updt_applctx
      = reqinfo->updt_applctx,
     agent.updt_task = reqinfo->updt_task, agent.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET fail_flag = insert_error
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Inserting into invest_agent_dev table."
    GO TO check_error
   ENDIF
   CALL echo("before owners")
   SET num_of_owners = size(request->invest_agent[i].owners,5)
   FOR (j = 1 TO num_of_owners)
     IF ((request->invest_agent[i].owners[j].owner_roletype_mean="PERSONAL"))
      SET role_type_cd = pr_role_type
     ELSE
      SET role_type_cd = in_role_type
     ENDIF
     INSERT  FROM ind_ide_ownership owner
      SET owner.ind_ide_ownership_id = seq(protocol_def_seq,nextval), owner.ownership_id = seq(
        protocol_def_seq,currval), owner.agent_dev_id = agent_id,
       owner.role_type_cd = role_type_cd, owner.organization_id = request->invest_agent[i].owners[j].
       org_id, owner.person_id = request->invest_agent[i].owners[j].person_id,
       owner.ind_ide_nbr = request->invest_agent[i].owners[j].nbr, owner.valid_from_dt_tm =
       cnvtdatetime(request->invest_agent[i].owners[j].valid_from_dt_tm), owner.valid_to_dt_tm =
       cnvtdatetime(request->invest_agent[i].owners[j].valid_to_dt_tm),
       owner.beg_effective_dt_tm = cnvtdatetime(sysdate), owner.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100 00:00:00.00"), owner.updt_dt_tm = cnvtdatetime(sysdate),
       owner.updt_id = reqinfo->updt_id, owner.updt_applctx = reqinfo->updt_applctx, owner.updt_task
        = reqinfo->updt_task,
       owner.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET fail_flag = insert_error
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Inserting Ind_Ide_ownership table."
      GO TO check_error
     ENDIF
   ENDFOR
   IF ((request->invest_agent[i].agent_dev_mean="IND"))
    INSERT  FROM invest_new_drug drug
     SET drug.invest_new_drug_dev_id = seq(protocol_def_seq,nextval), drug.new_drug_id = seq(
       protocol_def_seq,currval), drug.agent_dev_id = agent_id,
      drug.catalog_cd = request->invest_agent[i].drug_catalog_cd, drug.invest_drug_name = request->
      invest_agent[i].drug_name, drug.invest_drug_nbr_txt = request->invest_agent[i].drug_nbr,
      drug.beg_effective_dt_tm = cnvtdatetime(sysdate), drug.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"), drug.updt_dt_tm = cnvtdatetime(sysdate),
      drug.updt_id = reqinfo->updt_id, drug.updt_applctx = reqinfo->updt_applctx, drug.updt_task =
      reqinfo->updt_task,
      drug.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET fail_flag = insert_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Inserting into invest_new_drug table."
     GO TO check_error
    ENDIF
   ELSE
    INSERT  FROM invest_dev dev
     SET dev.invest_dev_id = seq(protocol_def_seq,nextval), dev.device_id = seq(protocol_def_seq,
       currval), dev.agent_dev_id = agent_id,
      dev.device_type_cd = request->invest_agent[i].dev_type_cd, dev.device_name = request->
      invest_agent[i].dev_name, dev.invest_device_nbr_txt = request->invest_agent[i].dev_nbr,
      dev.beg_effective_dt_tm = cnvtdatetime(sysdate), dev.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"), dev.updt_dt_tm = cnvtdatetime(sysdate),
      dev.updt_id = reqinfo->updt_id, dev.updt_applctx = reqinfo->updt_applctx, dev.updt_task =
      reqinfo->updt_task,
      dev.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET fail_flag = insert_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Inserting new device into invest_dev table."
     GO TO check_error
    ENDIF
   ENDIF
 ENDFOR
 SET pamendmentid = 0
 SET pamendmentid = reply->prot_amendment_id
 EXECUTE ct_add_amd_alias
 SET num_to_add = size(request->committees,5)
 IF (num_to_add > 0)
  INSERT  FROM prot_amd_committee_reltn pacr,
    (dummyt d  WITH seq = value(num_to_add))
   SET pacr.prot_amd_committee_id = seq(protocol_def_seq,nextval), pacr.prot_amendment_id = reply->
    prot_amendment_id, pacr.committee_id = request->committees[d.seq].committee_id,
    pacr.validate_ind = request->committees[d.seq].validate_ind, pacr.edit_ind = request->committees[
    d.seq].edit_ind, pacr.active_ind = 1,
    pacr.updt_dt_tm = cnvtdatetime(sysdate), pacr.updt_id = reqinfo->updt_id, pacr.updt_applctx =
    reqinfo->updt_applctx,
    pacr.updt_task = reqinfo->updt_task, pacr.updt_cnt = 0
   PLAN (d)
    JOIN (pacr)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET fail_flag = insert_error
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Inserting into prot_amd_committee_reltn table."
   GO TO check_error
  ENDIF
 ENDIF
 IF (size(trim(request->data_capture_str),1) > 0)
  INSERT  FROM long_text_reference ltr
   SET ltr.long_text_id = seq(long_data_seq,nextval), ltr.long_text = request->data_capture_str, ltr
    .parent_entity_name = "PROT_AMENDMENT",
    ltr.parent_entity_id = reply->prot_amendment_id, ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr
    .updt_id = reqinfo->updt_id,
    ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_task = reqinfo->updt_task, ltr.updt_cnt = 0,
    ltr.active_ind = 1, ltr.active_status_cd = reqdata->active_status_cd, ltr.active_status_dt_tm =
    cnvtdatetime(sysdate),
    ltr.active_status_prsnl_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET fail_flag = insert_error
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Inserting data capture information into long_reference table."
   GO TO check_error
  ENDIF
 ENDIF
 IF ((request->prev_amendment_id > 0.0))
  RECORD cfv_request(
    1 values[*]
      2 ct_prot_amd_custom_fld_id = f8
      2 ct_custom_field_id = f8
      2 prot_amendment_id = f8
      2 field_position = i2
      2 value_text = c255
      2 value_dt_tm = dq8
      2 value_cd = f8
      2 delete_ind = i2
  )
  RECORD cfv_reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  DECLARE cnt = i2 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM ct_prot_amd_custom_fld_val val
   WHERE (val.prot_amendment_id=request->prev_amendment_id)
    AND val.end_effective_dt_tm > cnvtdatetime(sysdate)
   ORDER BY val.field_position
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt += 1
    IF (mod(cnt,10)=1)
     stat = alterlist(cfv_request->values,(cnt+ 9))
    ENDIF
    cfv_request->values[cnt].ct_prot_amd_custom_fld_id = 0.0, cfv_request->values[cnt].
    ct_custom_field_id = val.ct_custom_field_id, cfv_request->values[cnt].prot_amendment_id = reply->
    prot_amendment_id,
    cfv_request->values[cnt].field_position = val.field_position, cfv_request->values[cnt].value_cd
     = val.value_cd, cfv_request->values[cnt].value_text = val.value_text,
    cfv_request->values[cnt].value_dt_tm = val.value_dt_tm
   FOOT REPORT
    stat = alterlist(cfv_request->values,cnt)
   WITH nocounter
  ;end select
  IF (cnt > 0)
   EXECUTE ct_chg_amd_custom_values  WITH replace("REQUEST","CFV_REQUEST"), replace("REPLY",
    "CFV_REPLY")
   IF ((cfv_reply->status_data.status != "S"))
    SET fail_flag = insert_error
    SET reply->status_data.subeventstatus[1].targetobjectvalue = cfv_reply->status_data.
    subeventstatus[1].targetobjectvalue
    GO TO check_error
   ENDIF
  ENDIF
 ENDIF
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  CASE (fail_flag)
   OF generate_id:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   OF updt_cnt_no_match:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   OF amd_number_exists:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectname = ""
    SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  ENDCASE
  IF (fail_flag=amd_number_exists)
   SET reply->status_data.status = "D"
   SET reply->status_data.subeventstatus[1].operationstatus = "D"
  ELSE
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
  ENDIF
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "024"
 SET mod_date = "July 30, 2019"
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

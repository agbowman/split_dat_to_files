CREATE PROGRAM ct_chg_protocol:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD req_access_list(
   1 person_list[*]
     2 person_id = f8
     2 prot_amendment_id = f8
     2 action_ind = i2
 )
 RECORD reply_access(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD ct_add_prot_role_request(
   1 qual[*]
     2 prot_role_id = f8
     2 amendment_id = f8
     2 organization_id = f8
     2 person_id = f8
     2 prot_role_cd = f8
     2 prot_role_type = c100
     2 updt_cnt = i4
     2 primary_ind = i2
     2 position_cd = f8
 )
 RECORD ct_add_prot_role_reply(
   1 qual[*]
     2 id = f8
     2 debug = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD ct_del_prot_role_request(
   1 qual[*]
     2 prot_role_id = f8
     2 updt_cnt = i4
 )
 RECORD ct_del_prot_role_reply(
   1 qual[*]
     2 id = f8
     2 debug = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD ct_upt_master_amendment_status_request(
   1 prot_amendment_id = f8
   1 new_status_cd = f8
   1 mode = i2
   1 prot_suspension_id = f8
   1 reason_cd = f8
   1 comment_txt = vc
   1 revision_ind = i2
   1 closeonly_ind = i2
 )
 RECORD ct_upt_master_amendment_status_reply(
   1 prot_suspension_id = f8
   1 reason_for_failure = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 DECLARE pmid = f8 WITH public, noconstant(0.0)
 DECLARE highestamdnbr = i2 WITH public, noconstant(0)
 DECLARE highestamdid = f8 WITH public, noconstant(0.0)
 DECLARE prot_amendment_id = f8 WITH public, noconstant(0.0)
 DECLARE cur_updt_cnt = i2 WITH public, noconstant(0)
 DECLARE primary_id = f8 WITH public, noconstant(0.0)
 DECLARE parent_chg = i2 WITH protect, noconstant(0)
 DECLARE prot_master_id = f8 WITH public, noconstant(0.0)
 DECLARE parent_prot_master_id = f8 WITH protect, noconstant(0.0)
 DECLARE bfounddup = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE mnemonic_changed_ind = i2 WITH protect, noconstant(0)
 DECLARE dup_mnemonic_ind = i2 WITH protect, noconstant(0)
 DECLARE primary_mnemonic = c255 WITH protect, noconstant(fillstring(255," "))
 DECLARE primary_mnemonic_key = c255 WITH protect, noconstant(fillstring(255," "))
 DECLARE pr_role_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE amendment_id = f8 WITH protect, noconstant(0.0)
 DECLARE role_cnt = i4 WITH protect, noconstant(0)
 DECLARE add_role_cnt = i4 WITH protect, noconstant(0)
 DECLARE del_role_cnt = i4 WITH protect, noconstant(0)
 SET pmid = request->prot_master_id
 SET highestamdnbr = 0
 SET highestamdid = 0
 EXECUTE ct_get_highest_a_nbr
 SET prot_amendment_id = highestamdid
 CALL echo(request->no_prot_chg_ind)
 IF ((request->no_prot_chg_ind=0))
  CALL echo("before select - master")
  SELECT INTO "nl:"
   pr.*
   FROM prot_master pr
   WHERE (pr.prot_master_id=request->prot_master_id)
   DETAIL
    cur_updt_cnt = pr.updt_cnt
    IF ((request->collab_site_org_id=0))
     IF ((((request->initiating_service_cd != pr.initiating_service_cd)) OR ((((request->program_cd
      != pr.program_cd)) OR ((request->sub_initiating_service_cd != pr.sub_initiating_service_cd)))
     )) )
      parent_chg = 1
     ENDIF
    ELSE
     parent_prot_master_id = pr.parent_prot_master_id
    ENDIF
    IF ((request->primary_mnemonic != pr.primary_mnemonic))
     primary_mnemonic = request->primary_mnemonic, primary_mnemonic_key = request->
     primary_mnemonic_key, mnemonic_changed_ind = 1
    ELSE
     primary_mnemonic = request->primary_mnemonic, primary_mnemonic_key = request->
     primary_mnemonic_key
    ENDIF
   WITH nocounter, forupdate(pr)
  ;end select
  CALL echo("checking curqual - master")
  IF (curqual=0)
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
  CALL echo(build("checking updtcnt- master",cur_updt_cnt))
  IF ((cur_updt_cnt != request->prot_master_updt_cnt))
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error with updt_cnt on prot_master table."
   GO TO exit_script
  ENDIF
  IF (mnemonic_changed_ind=1)
   SELECT INTO "nl:"
    FROM prot_master pm
    WHERE pm.prot_master_id > 0.0
     AND (pm.prot_master_id != request->prot_master_id)
     AND (pm.primary_mnemonic=request->primary_mnemonic)
     AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND (pm.logical_domain_id=domain_reply->logical_domain_id)
    DETAIL
     dup_mnemonic_ind = 1
    WITH nocounter
   ;end select
   IF (dup_mnemonic_ind=1)
    SET reqinfo->commit_ind = 0
    SET reply->status_data.status = "M"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Mnemonic is not unique"
    GO TO exit_script
   ENDIF
  ENDIF
  IF (parent_prot_master_id > 0)
   SELECT INTO "nl:"
    FROM prot_master pm
    WHERE pm.parent_prot_master_id=parent_prot_master_id
     AND (pm.collab_site_org_id=request->collab_site_org_id)
     AND (pm.prot_master_id != request->prot_master_id)
     AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
    DETAIL
     bfounddup = 1
    WITH nocounter
   ;end select
   IF (bfounddup=1)
    SET reqinfo->commit_ind = 0
    SET reply->status_data.status = "C"
    GO TO exit_script
   ENDIF
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
   pm.updt_cnt, pm.sub_initiating_service_cd, pm.sub_initiating_service_desc,
   pm.logical_domain_id)(SELECT
    seq(protocol_def_seq,nextval), pm1.accession_nbr_last, pm1.accession_nbr_prefix,
    pm1.accession_nbr_sig_dig, pm1.prescreen_type_flag, pm1.beg_effective_dt_tm,
    pm1.collab_site_org_id, pm1.display_ind, cnvtdatetime(script_date),
    pm1.initiating_service_cd, pm1.initiating_service_desc, pm1.parent_prot_master_id,
    pm1.participation_type_cd, pm1.peer_review_indicator_cd, pm1.prev_prot_master_id,
    pm1.primary_mnemonic, pm1.primary_mnemonic_key, pm1.program_cd,
    pm1.prot_phase_cd, pm1.prot_purpose_cd, pm1.prot_status_cd,
    pm1.prot_type_cd, pm1.research_sponsor_org_id, pm1.updt_dt_tm,
    pm1.updt_id, pm1.updt_task, pm1.updt_applctx,
    pm1.updt_cnt, pm1.sub_initiating_service_cd, pm1.sub_initiating_service_desc,
    pm1.logical_domain_id
    FROM prot_master pm1
    WHERE (pm1.prot_master_id=request->prot_master_id))
  ;end insert
  IF (curqual=0)
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error inserting previous record into the prot_master table."
   GO TO exit_script
  ENDIF
  UPDATE  FROM prot_master pm
   SET pm.initiating_service_cd = request->initiating_service_cd, pm.initiating_service_desc =
    request->initiating_service_desc, pm.sub_initiating_service_cd = request->
    sub_initiating_service_cd,
    pm.sub_initiating_service_desc = request->sub_initiating_service_desc, pm.prot_phase_cd = request
    ->prot_phase_cd, pm.program_cd = request->program_cd,
    pm.prot_type_cd = request->prot_type_cd, pm.accession_nbr_last = request->accession_nbr_last, pm
    .accession_nbr_prefix = request->accession_nbr_prefix,
    pm.accession_nbr_sig_dig = request->accession_nbr_sig_dig, pm.updt_dt_tm = cnvtdatetime(
     script_date), pm.updt_id = reqinfo->updt_id,
    pm.updt_cnt = (cur_updt_cnt+ 1), pm.display_ind = request->display_ind, pm.collab_site_org_id =
    request->collab_site_org_id,
    pm.beg_effective_dt_tm = cnvtdatetime(script_date), pm.primary_mnemonic = primary_mnemonic, pm
    .primary_mnemonic_key = primary_mnemonic_key
   WHERE (pm.prot_master_id=request->prot_master_id)
   WITH nocounter
  ;end update
  CALL echo(build("after update where:",request->prot_master_id))
  IF (curqual=0)
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error updating the original prot_master record."
   GO TO exit_script
  ENDIF
  IF (parent_chg=1)
   SELECT INTO "nl:"
    pm.*
    FROM prot_master pm
    WHERE (pm.parent_prot_master_id=request->prot_master_id)
     AND (pm.prot_master_id != request->prot_master_id)
     AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
    WITH nocounter, forupdate(pm)
   ;end select
   IF (curqual > 0)
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
     pm.updt_cnt, pm.sub_initiating_service_cd, pm.sub_initiating_service_desc,
     pm.logical_domain_id)(SELECT
      seq(protocol_def_seq,nextval), pm1.accession_nbr_last, pm1.accession_nbr_prefix,
      pm1.accession_nbr_sig_dig, pm1.prescreen_type_flag, pm1.beg_effective_dt_tm,
      pm1.collab_site_org_id, pm1.display_ind, cnvtdatetime(script_date),
      pm1.initiating_service_cd, pm1.initiating_service_desc, pm1.parent_prot_master_id,
      pm1.participation_type_cd, pm1.peer_review_indicator_cd, pm1.prev_prot_master_id,
      pm1.primary_mnemonic, pm1.primary_mnemonic_key, pm1.program_cd,
      pm1.prot_phase_cd, pm1.prot_purpose_cd, pm1.prot_status_cd,
      pm1.prot_type_cd, pm1.research_sponsor_org_id, pm1.updt_dt_tm,
      pm1.updt_id, pm1.updt_task, pm1.updt_applctx,
      pm1.updt_cnt, pm1.sub_initiating_service_cd, pm1.sub_initiating_service_desc,
      pm1.logical_domain_id
      FROM prot_master pm1
      WHERE (pm1.parent_prot_master_id=request->prot_master_id)
       AND (pm1.prot_master_id != request->prot_master_id)
       AND pm1.end_effective_dt_tm > cnvtdatetime(sysdate))
    ;end insert
    IF (curqual=0)
     SET reqinfo->commit_ind = 0
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error inserting previous record into the prot_master table for parent_chg."
     GO TO exit_script
    ENDIF
    UPDATE  FROM prot_master pm
     SET pm.initiating_service_cd = request->initiating_service_cd, pm.initiating_service_desc =
      request->initiating_service_desc, pm.sub_initiating_service_cd = request->
      sub_initiating_service_cd,
      pm.sub_initiating_service_desc = request->sub_initiating_service_desc, pm.program_cd = request
      ->program_cd, pm.updt_dt_tm = cnvtdatetime(sysdate),
      pm.updt_id = reqinfo->updt_id, pm.updt_cnt = (pm.updt_cnt+ 1), pm.beg_effective_dt_tm =
      cnvtdatetime(script_date)
     WHERE (pm.parent_prot_master_id=request->prot_master_id)
      AND (pm.prot_master_id != request->prot_master_id)
      AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET reqinfo->commit_ind = 0
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error updating record into the prot_master table for parent_chg."
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
  IF ((request->prot_chg_ind=0))
   CALL echo("before select - amend")
   SELECT INTO "nl:"
    pa.*
    FROM prot_amendment pa
    WHERE pa.prot_amendment_id=prot_amendment_id
    DETAIL
     cur_updt_cnt = pa.updt_cnt
    WITH nocounter, forupdate(pa)
   ;end select
   IF (curqual=0)
    SET reqinfo->commit_ind = 0
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error locking the prot_amendment table for update."
    GO TO exit_script
   ENDIF
   CALL echo("before update - amend")
   UPDATE  FROM prot_amendment pa
    SET pa.enroll_stratification_type_cd = request->enroll_stratification_type_cd, pa
     .participation_type_cd = request->participation_type_cd, pa.updt_dt_tm = cnvtdatetime(sysdate),
     pa.updt_id = reqinfo->updt_id, pa.updt_cnt = (cur_updt_cnt+ 1)
    WHERE pa.prot_amendment_id=prot_amendment_id
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET reqinfo->commit_ind = 0
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error updating into the prot_amendment table."
    GO TO exit_script
   ENDIF
   IF ((request->concept_amd_id > 0))
    SELECT INTO "nl:"
     pa.*
     FROM prot_amendment pa
     WHERE (pa.prot_amendment_id=request->concept_amd_id)
     DETAIL
      cur_updt_cnt = pa.updt_cnt
     WITH nocounter, forupdate(pa)
    ;end select
    IF (curqual=0)
     SET reqinfo->commit_ind = 0
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error locking the prot_amendment table for concept update."
     GO TO exit_script
    ENDIF
    CALL echo("before update - amend")
    UPDATE  FROM prot_amendment pa
     SET pa.prot_title = request->prot_title, pa.updt_dt_tm = cnvtdatetime(sysdate), pa.updt_id =
      reqinfo->updt_id,
      pa.updt_cnt = (cur_updt_cnt+ 1)
     WHERE (pa.prot_amendment_id=request->concept_amd_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET reqinfo->commit_ind = 0
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error updating into the concept title in the prot_amendment table."
     GO TO exit_script
    ENDIF
   ENDIF
  ELSE
   SET prot_master_id = request->prot_master_id
   EXECUTE ct_add_peer_reviewer
   EXECUTE ct_add_prot_alias
  ENDIF
  CALL echo("before depts")
  SET num_to_add = size(request->contributing_depts,5)
  FOR (i = 1 TO num_to_add)
   CALL echo(build("depts to add:",num_to_add))
   IF ((request->contributing_depts[i].dept_updt_cnt=- (9)))
    CALL echo("before insert - depts")
    INSERT  FROM contributing_dept d
     SET d.contributing_dept_id = seq(protocol_def_seq,nextval), d.prot_master_id = request->
      prot_master_id, d.dept_cd = request->contributing_depts[i].dept_cd,
      d.dept_desc = request->contributing_depts[i].dept_desc, d.beg_effective_dt_tm = cnvtdatetime(
       sysdate), d.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
      d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_id, d.updt_applctx = reqinfo->
      updt_applctx,
      d.updt_task = reqinfo->updt_task, d.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET reqinfo->commit_ind = 0
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error inserting into contributing_dept table."
     GO TO exit_script
    ENDIF
   ELSE
    CALL echo("before select - depts")
    SELECT INTO "nl:"
     d.*
     FROM contributing_dept d
     WHERE (d.prot_master_id=request->prot_master_id)
      AND (d.dept_cd=request->contributing_depts[i].dept_cd)
     DETAIL
      cur_updt_cnt = d.updt_cnt
     WITH nocounter, forupdate(d)
    ;end select
    IF (curqual=0)
     SET reqinfo->commit_ind = 0
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error locking contributing_dept table."
     GO TO exit_script
    ENDIF
    IF ((cur_updt_cnt != request->contributing_depts[i].dept_updt_cnt))
     SET reqinfo->commit_ind = 0
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error updating contributing_dept table - updt_cnt does not match."
     GO TO exit_script
    ENDIF
    CALL echo("before update - depts")
    UPDATE  FROM contributing_dept d
     SET d.end_effective_dt_tm = cnvtdatetime(sysdate), d.updt_dt_tm = cnvtdatetime(sysdate), d
      .updt_id = reqinfo->updt_id,
      d.updt_cnt = (cur_updt_cnt+ 1)
     WHERE (d.prot_master_id=request->prot_master_id)
      AND (d.dept_cd=request->contributing_depts[i].dept_cd)
      AND d.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET reqinfo->commit_ind = 0
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error updating contributing_dept table"
     GO TO exit_script
    ENDIF
   ENDIF
  ENDFOR
  CALL echo("before regulatory")
  SET num_to_add = size(request->regulatory,5)
  FOR (i = 1 TO num_to_add)
   CALL echo(build("regulatory to add:",num_to_add))
   IF ((request->regulatory[i].reg_updt_cnt=- (9)))
    CALL echo("before insert - regulatory")
    INSERT  FROM prot_regulatory_req p_r
     SET p_r.prot_regulatory_req_id = seq(protocol_def_seq,nextval), p_r.regulatory_req_id =
      primary_id, p_r.prot_master_id = request->prot_master_id,
      p_r.reg_reporting_type_cd = request->regulatory[i].reg_reporting_cd, p_r.beg_effective_dt_tm =
      cnvtdatetime(sysdate), p_r.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
      p_r.updt_dt_tm = cnvtdatetime(sysdate), p_r.updt_id = reqinfo->updt_id, p_r.updt_applctx =
      reqinfo->updt_applctx,
      p_r.updt_task = reqinfo->updt_task, p_r.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET reqinfo->commit_ind = 0
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error inserting into the prot_regulatory_req table"
     GO TO exit_script
    ENDIF
   ELSE
    CALL echo("before select - regulatory")
    SELECT INTO "nl:"
     p_r.*
     FROM prot_regulatory_req p_r
     WHERE (p_r.prot_master_id=request->prot_master_id)
      AND (p_r.reg_reporting_type_cd=request->regulatory[i].reg_reporting_cd)
     DETAIL
      cur_updt_cnt = p_r.updt_cnt
     WITH nocounter, forupdate(p_r)
    ;end select
    IF (curqual=0)
     SET reqinfo->commit_ind = 0
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error locking the prot_regulatory_req table for update"
     GO TO exit_script
    ENDIF
    IF ((cur_updt_cnt != request->regulatory[i].reg_updt_cnt))
     SET reqinfo->commit_ind = 0
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error updating the prot_regulatory_req table - updt_cnt does not match."
     GO TO exit_script
    ENDIF
    CALL echo("before update - regulatory")
    UPDATE  FROM prot_regulatory_req p_r
     SET p_r.end_effective_dt_tm = cnvtdatetime(sysdate), p_r.updt_dt_tm = cnvtdatetime(sysdate), p_r
      .updt_id = reqinfo->updt_id,
      p_r.updt_cnt = (cur_updt_cnt+ 1)
     WHERE (p_r.prot_master_id=request->prot_master_id)
      AND (p_r.reg_reporting_type_cd=request->regulatory[i].reg_reporting_cd)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET reqinfo->commit_ind = 0
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error updating the prot_regulatory_req table."
     GO TO exit_script
    ENDIF
   ENDIF
  ENDFOR
 ENDIF
 SET role_cnt = size(request->roles,5)
 IF (role_cnt > 0)
  SET stat = alterlist(req_access_list->person_list,role_cnt)
  SET add_role_cnt = 0
  SET del_role_cnt = 0
  SET i = 0
  FOR (i = 1 TO role_cnt)
    IF ((request->roles[i].role_cd > - (1)))
     SET add_role_cnt += 1
     SET stat = alterlist(ct_add_prot_role_request->qual,add_role_cnt)
     SET ct_add_prot_role_request->qual[add_role_cnt].prot_role_id = request->roles[i].
     prev_prot_role_id
     SET ct_add_prot_role_request->qual[add_role_cnt].prot_role_cd = request->roles[i].role_cd
     SET ct_add_prot_role_request->qual[add_role_cnt].person_id = request->roles[i].prsnl_id
     SET ct_add_prot_role_request->qual[add_role_cnt].prot_role_type = "PERSONAL"
     SET ct_add_prot_role_request->qual[add_role_cnt].amendment_id = prot_amendment_id
     SET req_access_list->person_list[i].action_ind = 1
    ELSE
     IF ((request->roles[i].role_cd=- (1))
      AND (request->roles[i].prev_prot_role_id > 0.00))
      SET del_role_cnt += 1
      SET stat = alterlist(ct_del_prot_role_request->qual,del_role_cnt)
      SET ct_del_prot_role_request->qual[i].prot_role_id = request->roles[i].prev_prot_role_id
      SET ct_del_prot_role_request->qual[i].updt_cnt = request->roles[i].updt_cnt
      SET req_access_list->person_list[i].action_ind = 2
     ENDIF
    ENDIF
    SET req_access_list->person_list[i].person_id = request->roles[i].prsnl_id
    SET req_access_list->person_list[i].prot_amendment_id = prot_amendment_id
  ENDFOR
  IF (add_role_cnt > 0)
   EXECUTE ct_add_prot_role  WITH replace("REQUEST","CT_ADD_PROT_ROLE_REQUEST"), replace("REPLY",
    "CT_ADD_PROT_ROLE_REPLY")
   IF ((ct_add_prot_role_reply->status_data.status != "S"))
    SET reqinfo->commit_ind = 0
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error adding or updating roles."
    GO TO exit_script
   ENDIF
  ENDIF
  IF (del_role_cnt > 0)
   EXECUTE ct_del_prot_role  WITH replace("REQUEST","CT_DEL_PROT_ROLE_REQUEST"), replace("REPLY",
    "CT_DEL_PROT_ROLE_REPLY")
   IF ((ct_del_prot_role_reply->status_data.status != "S"))
    SET reqinfo->commit_ind = 0
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error deleting roles."
    GO TO exit_script
   ENDIF
  ENDIF
  IF (((add_role_cnt+ del_role_cnt) > 0))
   EXECUTE ct_chg_screener_access  WITH replace("REQUEST","REQ_ACCESS_LIST"), replace("REPLY",
    "REPLY_ACCESS")
   IF ((reply_access->status_data.status != "S"))
    SET reqinfo->commit_ind = 0
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error setting entity access."
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF ((request->new_status_cd > 0.0))
  SET ct_upt_master_amendment_status_request->new_status_cd = request->new_status_cd
  SET ct_upt_master_amendment_status_request->prot_amendment_id = prot_amendment_id
  EXECUTE ct_upt_master_amendment_status  WITH replace("REQUEST",
   "CT_UPT_MASTER_AMENDMENT_STATUS_REQUEST"), replace("REPLY","CT_UPT_MASTER_AMENDMENT_STATUS_REPLY")
  IF ((ct_upt_master_amendment_status_reply->status_data.status != "S"))
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = ct_upt_master_amendment_status_reply
   ->reason_for_failure
   GO TO exit_script
  ENDIF
 ENDIF
 SET reqinfo->commit_ind = 1
 SET reply->status_data.status = "S"
 SET last_mod = "010"
 SET mod_date = "July 30, 2019"
#exit_script
 CALL echo(build("status:",reply->status_data.status))
END GO

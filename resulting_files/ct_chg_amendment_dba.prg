CREATE PROGRAM ct_chg_amendment:dba
 RECORD amendment(
   1 qual[*]
     2 prot_amendment_id = f8
     2 prot_amendment_nbr = i4
     2 revision_nbr = i4
     2 delete_ind = i2
     2 stratum_ind = i2
 )
 RECORD reply(
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
   1 probdesc[*]
     2 str = vc
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
 SET reply->status_data.status = "F"
 DECLARE sponsor_id = f8 WITH protect, noconstant(0.0)
 DECLARE amendment_nbr = i2 WITH protect, noconstant(0)
 DECLARE prot_master_id = f8 WITH protect, noconstant(0.0)
 DECLARE cur_updt_cnt = i2 WITH protect, noconstant(0)
 DECLARE currentdate = dq8 WITH protect
 DECLARE long_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH private, noconstant(0)
 DECLARE role_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE in_role_type = f8 WITH protect, noconstant(0.0)
 DECLARE pr_role_type = f8 WITH protect, noconstant(0.0)
 DECLARE primary_secondary_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cdf_meaning = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE agent_dev_cd = f8 WITH protect, noconstant(0.0)
 DECLARE agent_id = f8 WITH protect, noconstant(0.0)
 DECLARE invest_id = f8 WITH protect, noconstant(0.0)
 DECLARE parent_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_committee_ind = i2 WITH protect, noconstant(0)
 DECLARE updt_committee_ind = i2 WITH protect, noconstant(0)
 DECLARE updt_cnt_problem = i2 WITH protect, noconstant(0)
 DECLARE com_count = i2 WITH protect, noconstant(0)
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE index = i2 WITH protect, noconstant(0)
 DECLARE cur_cmt_cnt = i2 WITH noconstant(0)
 DECLARE nstart = i2 WITH protect, noconstant(1)
 DECLARE batch_size = i2 WITH protect, noconstant(20)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE new_cmt_cnt = i2 WITH protect, noconstant(0)
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE ret_val = i2 WITH protect, noconstant(0)
 DECLARE amd_list_size = i2 WITH public, noconstant(0)
 DECLARE not_stratified_cd = f8 WITH public, noconstant(0.0)
 SET currentdate = cnvtdatetime(sysdate)
 DECLARE lock_table = i2 WITH private, constant(1)
 DECLARE generate_id = i2 WITH private, constant(2)
 DECLARE insert_into_table = i2 WITH protect, constant(3)
 DECLARE update_into_table = i2 WITH private, constant(4)
 DECLARE updt_cnt_no_match = i2 WITH private, constant(5)
 DECLARE delete_from_table = i2 WITH protect, constant(6)
 SUBROUTINE (nextsequence(x=i2) =f8)
   DECLARE nsequence = f8 WITH protect
   SELECT INTO "nl:"
    nextseqnum = seq(protocol_def_seq,nextval)
    FROM dual
    DETAIL
     nsequence = nextseqnum
    WITH nocounter
   ;end select
   RETURN(nsequence)
 END ;Subroutine
 SET stat = uar_get_meaning_by_codeset(18790,"NOSTRAT",1,not_stratified_cd)
 CALL echo("before select - amend")
 SELECT INTO "nl:"
  pa.*
  FROM prot_amendment pa
  WHERE (pa.prot_amendment_id=request->prot_amendment_id)
  DETAIL
   cur_updt_cnt = pa.updt_cnt, amendment_nbr = pa.amendment_nbr, revision_nbr = pa.revision_seq,
   prot_master_id = pa.prot_master_id
  WITH nocounter, forupdate(pa)
 ;end select
 IF (curqual=0)
  SET fail_flag = lock_table
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Locking prot_amendment table."
  GO TO check_error
 ENDIF
 IF ((cur_updt_cnt != request->amendment_updt_cnt))
  SET fail_flag = updt_cnt_no_match
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Update counts do not match in the prot_amendment table."
  GO TO check_error
 ENDIF
 CALL echo("before update - amend")
 UPDATE  FROM prot_amendment pa
  SET pa.prot_title = request->prot_title, pa.accrual_required_indc_cd = request->
   accrual_required_indc_cd, pa.amendment_description = request->amendment_description,
   pa.anticipated_prot_dur_value = request->anticipated_prot_duration, pa.anticipated_prot_dur_uom_cd
    = request->anticipated_prot_dur_uom_cd, pa.groupwide_targeted_accrual = request->
   groupwide_targeted_accrual,
   pa.prot_title = request->prot_title, pa.targeted_accrual = request->targeted_accrual, pa
   .other_applicable_prot_ind = request->other_applicable_prot_ind,
   pa.safety_monitor_committee_ind = request->safety_monitor_committee_ind, pa
   .compensation_description = request->compensation_description, pa.participation_type_cd = request
   ->participation_type_cd,
   pa.updt_dt_tm = cnvtdatetime(currentdate), pa.updt_id = reqinfo->updt_id, pa.updt_cnt = (
   cur_updt_cnt+ 1),
   pa.compensation_ind = request->compensation_ind, pa.revision_ind = request->revision_ind, pa
   .parent_amendment_id = request->parent_amendment_id,
   pa.revision_seq = request->revision_seq, pa.revision_nbr_txt = request->revision_nbr_txt, pa
   .data_capture_ind = request->data_capture_ind,
   pa.ct_domain_info_id = request->ct_domain_id, pa.data_script_cd = request->data_script_cd, pa
   .dcv_auto_enroll_ind = request->auto_enroll_ind
  WHERE (pa.prot_amendment_id=request->prot_amendment_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET fail_flag = update_into_table
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Updating into prot_amendment table."
  GO TO check_error
 ENDIF
 CALL echo("before diseases")
 SET num_to_add = size(request->diseases,5)
 FOR (i = 1 TO num_to_add)
  CALL echo(build("diseases to add:",num_to_add))
  IF ((request->diseases[i].disease_updt_cnt=- (9)))
   CALL echo("before insert - diseases")
   INSERT  FROM appl_disease d
    SET d.appl_disease_id = seq(protocol_def_seq,nextval), d.prot_amendment_id = request->
     prot_amendment_id, d.disease_type_cd = request->diseases[i].disease_type_cd,
     d.appl_disease_desc_otr = request->diseases[i].disease_desc_other, d.updt_dt_tm = cnvtdatetime(
      sysdate), d.updt_id = reqinfo->updt_id,
     d.updt_applctx = reqinfo->updt_applctx, d.updt_task = reqinfo->updt_task, d.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET fail_flag = insert_into_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Inserting into disease table."
    GO TO check_error
   ENDIF
  ELSE
   CALL echo("before select - diseases")
   SELECT INTO "nl:"
    d.*
    FROM appl_disease d
    WHERE (d.prot_amendment_id=request->prot_amendment_id)
     AND (d.disease_type_cd=request->diseases[i].disease_type_cd)
    DETAIL
     cur_updt_cnt = d.updt_cnt
    WITH nocounter, forupdate(d)
   ;end select
   IF (curqual=0)
    SET fail_flag = lock_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Locking disease table."
    GO TO check_error
   ENDIF
   IF ((cur_updt_cnt != request->diseases[i].disease_updt_cnt))
    SET fail_flag = updt_cnt_no_match
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Update counts do not match for disease table ."
    GO TO check_error
   ENDIF
   CALL echo("before update - diseases")
   DELETE  FROM appl_disease d
    WHERE (d.prot_amendment_id=request->prot_amendment_id)
     AND (d.disease_type_cd=request->diseases[i].disease_type_cd)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET fail_flag = delete_from_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Deleting from disease table ."
    GO TO check_error
   ENDIF
  ENDIF
 ENDFOR
 CALL echo("before modalities")
 SET num_to_add = size(request->modalities,5)
 FOR (i = 1 TO num_to_add)
  CALL echo(build("modalities to add:",num_to_add))
  IF ((request->modalities[i].modality_updt_cnt=- (9)))
   CALL echo("before insert - modalities")
   INSERT  FROM prot_modality p_m
    SET p_m.prot_modality_id = seq(protocol_def_seq,nextval), p_m.prot_amendment_id = request->
     prot_amendment_id, p_m.modality_cd = request->modalities[i].modality_cd,
     p_m.modality_desc_otr = request->modalities[i].modality_desc_other, p_m.updt_dt_tm =
     cnvtdatetime(sysdate), p_m.updt_id = reqinfo->updt_id,
     p_m.updt_applctx = reqinfo->updt_applctx, p_m.updt_task = reqinfo->updt_task, p_m.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET fail_flag = insert_into_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Inserting into modality table."
    GO TO check_error
   ENDIF
  ELSE
   CALL echo("before select - modalities")
   SELECT INTO "nl:"
    p_m.*
    FROM prot_modality p_m
    WHERE (p_m.prot_amendment_id=request->prot_amendment_id)
     AND (p_m.modality_cd=request->modalities[i].modality_cd)
    DETAIL
     cur_updt_cnt = p_m.updt_cnt
    WITH nocounter, forupdate(p_m)
   ;end select
   IF (curqual=0)
    SET fail_flag = lock_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Locking modality table."
    GO TO check_error
   ENDIF
   IF ((cur_updt_cnt != request->modalities[i].modality_updt_cnt))
    SET fail_flag = updt_cnt_no_match
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Update counts do not match for modality table."
    GO TO check_error
   ENDIF
   CALL echo("before update - modalities")
   DELETE  FROM prot_modality p_m
    WHERE (p_m.prot_amendment_id=request->prot_amendment_id)
     AND (p_m.modality_cd=request->modalities[i].modality_cd)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET fail_flag = delete_from_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Deleting from modality table ."
    GO TO check_error
   ENDIF
  ENDIF
 ENDFOR
 CALL echo("before sponsors")
 SET num_to_add = size(request->sponsors,5)
 CALL echo(build("sponsors to process:",num_to_add))
 FOR (i = 1 TO num_to_add)
   SET primary_secondary_cd = 0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = request->sponsors[i].primary_secondary_cdf
   SET stat = uar_get_meaning_by_codeset(17271,cdf_meaning,1,primary_secondary_cd)
   CALL echo(build("request->sponsors[i]->delete_ind",request->sponsors[i].delete_ind))
   IF ((request->sponsors[i].delete_ind=1))
    CALL echo("before delete - support type")
    DELETE  FROM support_type st
     WHERE (st.prot_grant_sponsor_id=request->sponsors[i].prot_grant_sponsor_id)
     WITH nocounter
    ;end delete
    IF (curqual=0)
     SET fail_flag = delete_from_table
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Deleting from support_type table ."
     GO TO check_error
    ENDIF
    CALL echo("before delete - sponsors")
    DELETE  FROM prot_grant_sponsor pgs
     WHERE (pgs.prot_grant_sponsor_id=request->sponsors[i].prot_grant_sponsor_id)
      AND (pgs.organization_id=request->sponsors[i].organization_id)
      AND (pgs.prot_amendment_id=request->prot_amendment_id)
     WITH nocounter
    ;end delete
    IF (curqual=0)
     SET fail_flag = delete_from_table
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "Deleting from sponsor table ."
     GO TO check_error
    ENDIF
   ELSEIF ((request->sponsors[i].prot_grant_sponsor_id > 0))
    CALL echo(build("primary_secondary_cd :",primary_secondary_cd))
    CALL echo(build("request->sponsors[i]->prot_grant_sponsor_id :",request->sponsors[i].
      prot_grant_sponsor_id))
    SELECT INTO "nl:"
     pgs.*
     FROM prot_grant_sponsor pgs
     WHERE (pgs.prot_grant_sponsor_id=request->sponsors[i].prot_grant_sponsor_id)
      AND pgs.primary_secondary_cd=primary_secondary_cd
     DETAIL
      cur_updt_cnt = pgs.updt_cnt, sponsor_id = pgs.prot_grant_sponsor_id
     WITH nocounter, forupdate(pgs)
    ;end select
    IF (curqual=0)
     SET fail_flag = lock_table
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "Locking sponsor table."
     GO TO check_error
    ENDIF
    CALL echo(build("cur_updt_cnt :",cur_updt_cnt))
    CALL echo(build("request->sponsors[i]->sponsor_updt_cnt :",request->sponsors[i].sponsor_updt_cnt)
     )
    IF ((cur_updt_cnt != request->sponsors[i].sponsor_updt_cnt))
     SET fail_flag = updt_cnt_no_match
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Update counts do not match for sponsor table."
     GO TO check_error
    ENDIF
    CALL echo(build("sponsor_id :",sponsor_id))
    CALL echo("before update - sponsor")
    UPDATE  FROM prot_grant_sponsor pgs
     SET pgs.grant_nbr = request->sponsors[i].grant_num, pgs.organization_id = request->sponsors[i].
      organization_id, pgs.funded_ind = request->sponsors[i].funded_ind,
      pgs.updt_dt_tm = cnvtdatetime(sysdate), pgs.updt_id = reqinfo->updt_id, pgs.updt_applctx =
      reqinfo->updt_applctx,
      pgs.updt_task = reqinfo->updt_task, pgs.updt_cnt = (pgs.updt_cnt+ 1)
     WHERE pgs.prot_grant_sponsor_id=sponsor_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET fail_flag = update_into_table
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "Updating into sponsor table."
     GO TO check_error
    ENDIF
    SET ret_val = processsupporttypes(i,sponsor_id)
    IF (curqual=0)
     GO TO check_error
    ENDIF
   ELSE
    SET sponsor_id = nextsequence(0)
    INSERT  FROM prot_grant_sponsor pgs
     SET pgs.prot_grant_sponsor_id = sponsor_id, pgs.prot_amendment_id = request->prot_amendment_id,
      pgs.grant_nbr = request->sponsors[i].grant_num,
      pgs.organization_id = request->sponsors[i].organization_id, pgs.primary_secondary_cd =
      primary_secondary_cd, pgs.funded_ind = request->sponsors[i].funded_ind,
      pgs.updt_dt_tm = cnvtdatetime(sysdate), pgs.updt_id = reqinfo->updt_id, pgs.updt_applctx =
      reqinfo->updt_applctx,
      pgs.updt_task = reqinfo->updt_task, pgs.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET fail_flag = insert_into_table
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "Inserting into sponsor table."
     GO TO check_error
    ENDIF
    SET ret_val = processsupporttypes(i,sponsor_id)
    IF (curqual=0)
     GO TO check_error
    ENDIF
   ENDIF
 ENDFOR
 CALL echo("before data_submission")
 SET num_to_add = size(request->data_submission,5)
 FOR (i = 1 TO num_to_add)
  CALL echo(build("data_submission to add:",num_to_add))
  IF ((request->data_submission[i].submitted_updt_cnt=- (9)))
   CALL echo("before insert - data_submission")
   INSERT  FROM data_submission d_s
    SET d_s.data_submission_id = seq(protocol_def_seq,nextval), d_s.prot_amendment_id = request->
     prot_amendment_id, d_s.submitted_to_cd = request->data_submission[i].submitted_to_cd,
     d_s.submitted_to_desc = request->data_submission[i].submitted_to_desc, d_s.updt_dt_tm =
     cnvtdatetime(sysdate), d_s.updt_id = reqinfo->updt_id,
     d_s.updt_applctx = reqinfo->updt_applctx, d_s.updt_task = reqinfo->updt_task, d_s.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET fail_flag = insert_into_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Inserting into data_submission table."
    GO TO check_error
   ENDIF
  ELSE
   CALL echo("before select - data_submission")
   SELECT INTO "nl:"
    d_s.*
    FROM data_submission d_s
    WHERE (d_s.prot_amendment_id=request->prot_amendment_id)
     AND (d_s.submitted_to_cd=request->data_submission[i].submitted_to_cd)
    DETAIL
     cur_updt_cnt = d_s.updt_cnt
    WITH nocounter, forupdate(d_s)
   ;end select
   IF (curqual=0)
    SET fail_flag = lock_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Locking data_submission table."
    GO TO check_error
   ENDIF
   IF ((cur_updt_cnt != request->data_submission[i].submitted_updt_cnt))
    SET fail_flag = updt_cnt_no_match
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Update counts do not match for data_submission table."
    GO TO check_error
   ENDIF
   CALL echo("before update - data_submission")
   DELETE  FROM data_submission d_s
    WHERE (d_s.prot_amendment_id=request->prot_amendment_id)
     AND (d_s.submitted_to_cd=request->data_submission[i].submitted_to_cd)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET fail_flag = delete_from_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Deleting from data_submission table ."
    GO TO check_error
   ENDIF
  ENDIF
 ENDFOR
 CALL echo("before safety_committee")
 SET num_to_add = size(request->safety_committee,5)
 FOR (i = 1 TO num_to_add)
  CALL echo(build("safety_committee to add:",num_to_add))
  IF ((request->safety_committee[i].safety_updt_cnt=- (9)))
   CALL echo("before insert - safety_committee")
   INSERT  FROM safety_committee s_c
    SET s_c.safety_committee_id = seq(protocol_def_seq,nextval), s_c.prot_amendment_id = request->
     prot_amendment_id, s_c.person_id = request->safety_committee[i].person_id,
     s_c.beg_effective_dt_tm = cnvtdatetime(sysdate), s_c.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100 00:00:00.00"), s_c.updt_dt_tm = cnvtdatetime(sysdate),
     s_c.updt_id = reqinfo->updt_id, s_c.updt_applctx = reqinfo->updt_applctx, s_c.updt_task =
     reqinfo->updt_task,
     s_c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET fail_flag = insert_into_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Inserting into safety_committee table."
    GO TO check_error
   ENDIF
  ELSE
   CALL echo("before select - safety_committee")
   SELECT INTO "nl:"
   ;end select
   SELECT INTO "nl:"
    s_c.*
    FROM safety_committee s_c
    WHERE (s_c.prot_amendment_id=request->prot_amendment_id)
     AND (s_c.person_id=request->safety_committee[i].person_id)
    DETAIL
     cur_updt_cnt = s_c.updt_cnt
    WITH nocounter, forupdate(s_c)
   ;end select
   IF (curqual=0)
    SET fail_flag = lock_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Locking safety_committee table."
    GO TO check_error
   ENDIF
   IF ((cur_updt_cnt != request->safety_committee[i].safety_updt_cnt))
    SET fail_flag = udpt_cnt_safety_comm
    GO TO check_error
   ENDIF
   CALL echo("before update - safety_committee")
   UPDATE  FROM safety_committee s_c
    SET s_c.end_effective_dt_tm = cnvtdatetime(sysdate), s_c.updt_dt_tm = cnvtdatetime(sysdate), s_c
     .updt_id = reqinfo->updt_id,
     s_c.updt_cnt = (cur_updt_cnt+ 1)
    WHERE (s_c.prot_amendment_id=request->prot_amendment_id)
     AND (s_c.person_id=request->safety_committee[i].person_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET fail_flag = update_into_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Updating into safety_committee table."
    GO TO check_error
   ENDIF
  ENDIF
 ENDFOR
 CALL echo("before reasons")
 SET num_to_add = size(request->reasons,5)
 FOR (i = 1 TO num_to_add)
  CALL echo(build("reasons to add:",num_to_add))
  IF ((request->reasons[i].reason_updt_cnt=- (9)))
   CALL echo("before insert - reasons")
   INSERT  FROM amendment_reason a_r
    SET a_r.amendment_reason_id = seq(protocol_def_seq,nextval), a_r.prot_amendment_id = request->
     prot_amendment_id, a_r.amendment_reason_cd = request->reasons[i].reason_cd,
     a_r.updt_dt_tm = cnvtdatetime(sysdate), a_r.updt_id = reqinfo->updt_id, a_r.updt_applctx =
     reqinfo->updt_applctx,
     a_r.updt_task = reqinfo->updt_task, a_r.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET fail_flag = insert_into_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Inserting into amendment_reason table."
    GO TO check_error
   ENDIF
  ELSE
   CALL echo("before select - reasons")
   SELECT INTO "nl:"
    a_r.*
    FROM amendment_reason a_r
    WHERE (a_r.prot_amendment_id=request->prot_amendment_id)
     AND (a_r.amendment_reason_cd=request->reasons[i].reason_cd)
    DETAIL
     cur_updt_cnt = a_r.updt_cnt
    WITH nocounter, forupdate(a_r)
   ;end select
   IF (curqual=0)
    SET fail_flag = lock_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Locking amendment_reason table."
    GO TO check_error
   ENDIF
   IF ((cur_updt_cnt != request->reasons[i].reason_updt_cnt))
    SET fail_flag = updt_cnt_no_match
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Update counts do not match for amendment_reason table."
    GO TO check_error
   ENDIF
   DELETE  FROM amendment_reason a_r
    WHERE (a_r.prot_amendment_id=request->prot_amendment_id)
     AND (a_r.amendment_reason_cd=request->reasons[i].reason_cd)
   ;end delete
   IF (curqual=0)
    SET fail_flag = delete_from_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Deleting from amendment_reason table ."
    GO TO check_error
   ENDIF
  ENDIF
 ENDFOR
 CALL echo("before objectives")
 SET num_to_add = size(request->objectives,5)
 FOR (i = 1 TO num_to_add)
  CALL echo(build("objectives to add:",num_to_add))
  IF ((request->objectives[i].objective_id=- (9)))
   INSERT  FROM long_text_reference ltr
    SET ltr.long_text_id = seq(long_data_seq,nextval), ltr.long_text = request->objectives[i].
     objective, ltr.parent_entity_name = "PROT_OBJECTIVE",
     ltr.parent_entity_id = request->prot_amendment_id, ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr
     .updt_id = reqinfo->updt_id,
     ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_task = reqinfo->updt_task, ltr.updt_cnt = 0,
     ltr.active_ind = 1, ltr.active_status_cd = reqdata->active_status_cd, ltr.active_status_dt_tm =
     cnvtdatetime(sysdate),
     ltr.active_status_prsnl_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET fail_flag = insert_into_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Inserting into long_text_reference table."
    GO TO check_error
   ENDIF
   CALL echo("before insert - objectives")
   INSERT  FROM prot_objective p_o
    SET p_o.prot_objective_id = seq(protocol_def_seq,nextval), p_o.prot_amendment_id = request->
     prot_amendment_id, p_o.objective_type_cd = request->objectives[i].objective_type_cd,
     p_o.objective_nbr = request->objectives[i].objective_nbr, p_o.sequence_nbr = request->
     objectives[i].sequence_nbr, p_o.beg_effective_dt_tm = cnvtdatetime(sysdate),
     p_o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), p_o.updt_dt_tm = cnvtdatetime
     (sysdate), p_o.updt_id = reqinfo->updt_id,
     p_o.updt_applctx = reqinfo->updt_applctx, p_o.updt_task = reqinfo->updt_task, p_o.updt_cnt = 0,
     p_o.long_text_id = seq(long_data_seq,currval)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET fail_flag = insert_into_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Inserting into prot_objective table."
    GO TO check_error
   ENDIF
  ELSE
   CALL echo("before select - objectives")
   SELECT INTO "nl:"
    p_o.*
    FROM prot_objective p_o
    WHERE (p_o.prot_objective_id=request->objectives[i].objective_id)
    DETAIL
     cur_updt_cnt = p_o.updt_cnt, long_text_id = p_o.long_text_id
    WITH nocounter, forupdate(p_o)
   ;end select
   IF (curqual=0)
    SET fail_flag = lock_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Locking prot_objective table."
    GO TO check_error
   ELSEIF ((cur_updt_cnt != request->objectives[i].objective_updt_cnt))
    SET fail_flag = updt_cnt_no_match
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Update counts do not match for prot_objective table."
    GO TO check_error
   ELSE
    IF ((request->objectives[i].delete_ind=1))
     UPDATE  FROM prot_objective p_o
      SET p_o.end_effective_dt_tm = cnvtdatetime(sysdate), p_o.updt_dt_tm = cnvtdatetime(sysdate),
       p_o.updt_id = reqinfo->updt_id,
       p_o.updt_cnt = (cur_updt_cnt+ 1)
      WHERE (p_o.prot_objective_id=request->objectives[i].objective_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET fail_flag = update_into_table
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Updating into prot_objective table."
      GO TO check_error
     ENDIF
     UPDATE  FROM long_text_reference ltr
      SET ltr.long_text = request->objectives[i].objective, ltr.updt_dt_tm = cnvtdatetime(sysdate),
       ltr.updt_id = reqinfo->updt_id,
       ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_task = reqinfo->updt_task, ltr.updt_cnt = (
       ltr.updt_cnt+ 1),
       ltr.active_ind = 0, ltr.active_status_cd = reqdata->inactive_status_cd, ltr
       .active_status_dt_tm = cnvtdatetime(sysdate),
       ltr.active_status_prsnl_id = reqinfo->updt_id
      WHERE ltr.long_text_id=long_text_id
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET fail_flag = update_into_table
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Updating into long_text_reference table."
      GO TO check_error
     ENDIF
    ELSE
     UPDATE  FROM prot_objective p_o
      SET p_o.objective_type_cd = request->objectives[i].objective_type_cd, p_o.objective_nbr =
       request->objectives[i].objective_nbr, p_o.sequence_nbr = request->objectives[i].sequence_nbr,
       p_o.updt_dt_tm = cnvtdatetime(sysdate), p_o.updt_id = reqinfo->updt_id, p_o.updt_cnt = (
       cur_updt_cnt+ 1)
      WHERE (p_o.prot_objective_id=request->objectives[i].objective_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET fail_flag = update_into_table
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Updating into prot_objective table."
      GO TO check_error
     ENDIF
     UPDATE  FROM long_text_reference ltr
      SET ltr.long_text = request->objectives[i].objective, ltr.updt_dt_tm = cnvtdatetime(sysdate),
       ltr.updt_id = reqinfo->updt_id,
       ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_task = reqinfo->updt_task, ltr.updt_cnt = (
       ltr.updt_cnt+ 1)
      WHERE ltr.long_text_id=long_text_id
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET fail_flag = update_into_table
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Updating into long_text_reference table."
      GO TO check_error
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 CALL echo("pre call to ct_stratum_a_c_func")
 SET func_doecho = 0
 EXECUTE ct_stratum_a_c_func
 IF (amd_list_size > 0)
  IF ((request->enroll_stratification_type_cd=not_stratified_cd))
   SELECT
    FROM prot_stratum pr_str,
     (dummyt d  WITH seq = value(amd_list_size))
    PLAN (d)
     JOIN (pr_str
     WHERE (pr_str.prot_amendment_id=amendment->qual[d.seq].prot_amendment_id)
      AND pr_str.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     amendment->qual[d.seq].stratum_ind = 1
    WITH nocounter
   ;end select
  ENDIF
  UPDATE  FROM prot_amendment pa,
    (dummyt d  WITH seq = value(amd_list_size))
   SET pa.enroll_stratification_type_cd = request->enroll_stratification_type_cd, pa.updt_cnt = (pa
    .updt_cnt+ 1), pa.updt_applctx = reqinfo->updt_applctx,
    pa.updt_task = reqinfo->updt_task, pa.updt_id = reqinfo->updt_id, pa.updt_dt_tm = cnvtdatetime(
     sysdate)
   PLAN (d)
    JOIN (pa
    WHERE (pa.prot_amendment_id=amendment->qual[d.seq].prot_amendment_id)
     AND (pa.enroll_stratification_type_cd != request->enroll_stratification_type_cd)
     AND (amendment->qual[d.seq].stratum_ind=0))
   WITH nocounter
  ;end update
 ENDIF
 IF ((reply->statusfunc="F"))
  SET fail_flag = strata_failed
  GO TO check_error
 ENDIF
 CALL echo("Post call to ct_stratum_a_c_func")
 SET role_type_cd = 0.0
 SET in_role_type = 0.0
 SET stat = uar_get_meaning_by_codeset(17296,"INSTITUTION",1,in_role_type)
 SET pr_role_type = 0.0
 SET stat = uar_get_meaning_by_codeset(17296,"PERSONAL",1,pr_role_type)
 CALL echo("before agents ")
 SET agent_id = 0.0
 SET num_to_add = size(request->invest_agent,5)
 FOR (i = 1 TO num_to_add)
   SET agent_dev_cd = 0
   IF ((request->invest_agent[i].agent_dev_id=- (9)))
    SET cdf_meaning = fillstring(12," ")
    SET cdf_meaning = request->invest_agent[i].agent_dev_mean
    SET stat = uar_get_meaning_by_codeset(17444,cdf_meaning,1,agent_dev_cd)
    SELECT INTO "nl:"
     num = seq(protocol_def_seq,nextval)"########################;rpO"
     FROM dual
     DETAIL
      agent_id = cnvtreal(num)
     WITH format, counter
    ;end select
    IF (curqual=0)
     SET fail_flag = generate_id
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "Generating new id for agent."
     GO TO check_error
    ENDIF
    INSERT  FROM invest_agent_dev agent
     SET agent.invest_agent_dev_id = agent_id, agent.agent_dev_id = agent_id, agent.prot_amendment_id
       = request->prot_amendment_id,
      agent.invest_agent_dev_cd = agent_dev_cd, agent.beg_effective_dt_tm = cnvtdatetime(sysdate),
      agent.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
      agent.updt_dt_tm = cnvtdatetime(sysdate), agent.updt_id = reqinfo->updt_id, agent.updt_applctx
       = reqinfo->updt_applctx,
      agent.updt_task = reqinfo->updt_task, agent.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET fail_flag = insert_into_table
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Inserting into invest_agent_dev table."
     GO TO check_error
    ENDIF
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
      SET fail_flag = insert_into_table
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Inserting into invest_new_drug table."
      GO TO check_error
     ENDIF
    ELSE
     CALL echo("before ide")
     INSERT  FROM invest_dev dev
      SET dev.invest_dev_id = seq(protocol_def_seq,nextval), dev.device_id = seq(protocol_def_seq,
        currval), dev.agent_dev_id = agent_id,
       dev.invest_device_nbr_txt = request->invest_agent[i].dev_nbr, dev.device_type_cd = request->
       invest_agent[i].dev_type_cd, dev.device_name = request->invest_agent[i].dev_name,
       dev.beg_effective_dt_tm = cnvtdatetime(sysdate), dev.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100 00:00:00.00"), dev.updt_dt_tm = cnvtdatetime(sysdate),
       dev.updt_id = reqinfo->updt_id, dev.updt_applctx = reqinfo->updt_applctx, dev.updt_task =
       reqinfo->updt_task,
       dev.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET fail_flag = insert_into_table
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "Inserting into invest_dev table."
      GO TO check_error
     ENDIF
    ENDIF
   ELSE
    SET agent_id = request->invest_agent[i].agent_dev_id
    IF ((request->invest_agent[i].agent_dev_mean="IND"))
     SELECT INTO "nl:"
      drug.*
      FROM invest_new_drug drug
      WHERE drug.agent_dev_id=agent_id
       AND drug.end_effective_dt_tm > cnvtdatetime(sysdate)
      DETAIL
       cur_updt_cnt = drug.updt_cnt, parent_id = drug.new_drug_id
      WITH nocounter, forupdate(drug)
     ;end select
     IF (curqual=0)
      SET fail_flag = lock_table
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Locking invest_new_drug table for logical delete."
      GO TO check_error
     ENDIF
     IF ((cur_updt_cnt != request->invest_agent[i].drug_updt_cnt))
      SET fail_flag = updt_cnt_no_match
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Update counts do not match for invest_new_drug logical delete."
      GO TO check_error
     ENDIF
     UPDATE  FROM invest_new_drug drug
      SET drug.end_effective_dt_tm = cnvtdatetime(sysdate), drug.updt_dt_tm = cnvtdatetime(sysdate),
       drug.updt_id = reqinfo->updt_id,
       drug.updt_applctx = reqinfo->updt_applctx, drug.updt_task = reqinfo->updt_task, drug.updt_cnt
        = (drug.updt_cnt+ 1)
      WHERE drug.agent_dev_id=agent_id
       AND drug.end_effective_dt_tm > cnvtdatetime(sysdate)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET fail_flag = update_into_table
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Updating into invest_new_drug table for logical delete."
      GO TO check_error
     ENDIF
     IF ((request->invest_agent[i].agent_delete_ind=0))
      INSERT  FROM invest_new_drug drug
       SET drug.invest_new_drug_dev_id = seq(protocol_def_seq,nextval), drug.new_drug_id = parent_id,
        drug.agent_dev_id = agent_id,
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
       SET fail_flag = insert_into_table
       SET reply->status_data.subeventstatus[1].targetobjectvalue =
       "Inserting into invest_new_drug table."
       GO TO check_error
      ENDIF
     ENDIF
    ELSE
     SELECT INTO "nl:"
      dev.*
      FROM invest_dev dev
      WHERE dev.agent_dev_id=agent_id
       AND dev.end_effective_dt_tm > cnvtdatetime(sysdate)
      DETAIL
       cur_updt_cnt = dev.updt_cnt, parent_id = dev.device_id
      WITH nocounter, forupdate(dev)
     ;end select
     IF (curqual=0)
      SET fail_flag = lock_table
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Locking invest_dev table for logical update."
      GO TO check_error
     ENDIF
     IF ((cur_updt_cnt != request->invest_agent[i].dev_updt_cnt))
      SET fail_flag = updt_cnt_no_match
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Update counts do not match for invest_dev logical delete."
      GO TO check_error
     ENDIF
     UPDATE  FROM invest_dev dev
      SET dev.end_effective_dt_tm = cnvtdatetime(sysdate), dev.updt_dt_tm = cnvtdatetime(sysdate),
       dev.updt_id = reqinfo->updt_id,
       dev.updt_applctx = reqinfo->updt_applctx, dev.updt_task = reqinfo->updt_task, dev.updt_cnt = (
       dev.updt_cnt+ 1)
      WHERE dev.agent_dev_id=agent_id
       AND dev.end_effective_dt_tm > cnvtdatetime(sysdate)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET fail_flag = update_into_table
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Updating into invest_dev table for logical delete."
      GO TO check_error
     ENDIF
     IF ((request->invest_agent[i].agent_delete_ind=0))
      INSERT  FROM invest_dev dev
       SET dev.invest_dev_id = seq(protocol_def_seq,nextval), dev.device_id = parent_id, dev
        .agent_dev_id = agent_id,
        dev.invest_device_nbr_txt = request->invest_agent[i].dev_nbr, dev.device_type_cd = request->
        invest_agent[i].dev_type_cd, dev.device_name = request->invest_agent[i].dev_name,
        dev.beg_effective_dt_tm = cnvtdatetime(sysdate), dev.end_effective_dt_tm = cnvtdatetime(
         "31-DEC-2100 00:00:00.00"), dev.updt_dt_tm = cnvtdatetime(sysdate),
        dev.updt_id = reqinfo->updt_id, dev.updt_applctx = reqinfo->updt_applctx, dev.updt_task =
        reqinfo->updt_task,
        dev.updt_cnt = 0
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET fail_flag = insert_into_table
       SET reply->status_data.subeventstatus[1].targetobjectvalue =
       "Inserting into invest_dev table for update."
       GO TO check_error
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo("before owners")
   SET num_of_owners = size(request->invest_agent[i].owners,5)
   FOR (j = 1 TO num_of_owners)
    IF ((request->invest_agent[i].owners[j].owner_roletype_mean="PERSONAL"))
     SET role_type_cd = pr_role_type
    ELSE
     SET role_type_cd = in_role_type
    ENDIF
    IF ((request->invest_agent[i].owners[j].owner_id=- (9)))
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
      SET fail_flag = insert_into_table
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Inserting into ind_ide_ownership table."
      GO TO check_error
     ENDIF
    ELSEIF ((request->invest_agent[i].owners[j].owner_delete_ind=1))
     SELECT INTO "nl:"
      owner.*
      FROM ind_ide_ownership owner
      WHERE (owner.ind_ide_ownership_id=request->invest_agent[i].owners[j].owner_id)
       AND owner.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
      DETAIL
       cur_updt_cnt = owner.updt_cnt
      WITH nocounter, forupdate(owner)
     ;end select
     IF (curqual=0)
      SET fail_flag = lock_table
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "Locking ind_ide_ownership table."
      GO TO check_error
     ENDIF
     IF ((cur_updt_cnt != request->invest_agent[i].owners[j].owner_updt_cnt))
      SET fail_flag = updt_cnt_no_match
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Update counts do not match for ind_ide_ownership table."
      GO TO check_error
     ENDIF
     UPDATE  FROM ind_ide_ownership owner
      SET owner.end_effective_dt_tm = cnvtdatetime(sysdate), owner.updt_dt_tm = cnvtdatetime(sysdate),
       owner.updt_id = reqinfo->updt_id,
       owner.updt_applctx = reqinfo->updt_applctx, owner.updt_task = reqinfo->updt_task, owner
       .updt_cnt = (cur_updt_cnt+ 1)
      WHERE (owner.ind_ide_ownership_id=request->invest_agent[i].owners[j].owner_id)
       AND owner.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET fail_flag = update_into_table
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Updating into ind_ide_ownership table."
      GO TO check_error
     ENDIF
    ELSE
     SELECT INTO "nl:"
      owner.*
      FROM ind_ide_ownership owner
      WHERE (owner.ind_ide_ownership_id=request->invest_agent[i].owners[j].owner_id)
       AND owner.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
      DETAIL
       cur_updt_cnt = owner.updt_cnt, parent_id = owner.ownership_id
      WITH nocounter, forupdate(owner)
     ;end select
     IF (curqual=0)
      SET fail_flag = lock_table
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Locking ind_ide_ownership table for update."
      GO TO check_error
     ENDIF
     IF ((cur_updt_cnt != request->invest_agent[i].owners[j].owner_updt_cnt))
      SET fail_flag = updt_cnt_no_match
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Update counts do not match for ind_ide_ownership table for update."
      GO TO check_error
     ENDIF
     UPDATE  FROM ind_ide_ownership owner
      SET owner.end_effective_dt_tm = cnvtdatetime(sysdate), owner.updt_dt_tm = cnvtdatetime(sysdate),
       owner.updt_id = reqinfo->updt_id,
       owner.updt_applctx = reqinfo->updt_applctx, owner.updt_task = reqinfo->updt_task, owner
       .updt_cnt = (cur_updt_cnt+ 1)
      WHERE (owner.ind_ide_ownership_id=request->invest_agent[i].owners[j].owner_id)
       AND owner.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET fail_flag = update_into_table
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Updating into ind_ide_ownership table."
      GO TO check_error
     ENDIF
     INSERT  FROM ind_ide_ownership owner
      SET owner.ind_ide_ownership_id = seq(protocol_def_seq,nextval), owner.ownership_id = parent_id,
       owner.agent_dev_id = agent_id,
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
      SET fail_flag = insert_into_table
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Inserting updated owner into ind_ide_ownership table."
      GO TO check_error
     ENDIF
    ENDIF
   ENDFOR
 ENDFOR
 IF ((request->revision_ind=1))
  SELECT INTO "nl:"
   r.*
   FROM revision r
   WHERE (r.revision_id=request->revision_id)
   DETAIL
    cur_updt_cnt = r.updt_cnt
   WITH nocounter, forupdate(r)
  ;end select
  IF (curqual=0)
   SET fail_flag = lock_table
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Locking revision table."
   GO TO check_error
  ENDIF
  UPDATE  FROM revision r
   SET r.prot_amendment_id = request->prot_amendment_id, r.revision_nbr = request->revision_nbr, r
    .revision_description = request->revision_description,
    r.revision_dt_tm = cnvtdatetime(request->revision_dt_tm), r.updt_dt_tm = cnvtdatetime(sysdate), r
    .updt_id = reqinfo->updt_id,
    r.updt_applctx = reqinfo->updt_applctx, r.updt_task = reqinfo->updt_task, r.updt_cnt = (
    cur_updt_cnt+ 1)
   WHERE (r.revision_id=request->revision_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET fail_flag = insert_into_table
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Inserting into revision table."
   GO TO check_error
  ENDIF
  SET reply->revision_id = request->revision_id
 ENDIF
 SET pamendmentid = request->prot_amendment_id
 EXECUTE ct_add_amd_alias
 SET cur_cmt_cnt = size(request->committees,5)
 IF (cur_cmt_cnt > 0)
  SET new_committee_ind = 0
  SET updt_committee_ind = 0
  FOR (j = 1 TO cur_cmt_cnt)
    IF ((request->committees[j].prot_amd_committee_id=0))
     SET new_committee_ind = 1
    ELSE
     SET updt_committee_ind = 1
    ENDIF
  ENDFOR
  IF (new_committee_ind=1)
   INSERT  FROM prot_amd_committee_reltn pacr,
     (dummyt d  WITH seq = value(cur_cmt_cnt))
    SET pacr.prot_amd_committee_id = seq(protocol_def_seq,nextval), pacr.prot_amendment_id = request
     ->prot_amendment_id, pacr.committee_id = request->committees[d.seq].committee_id,
     pacr.validate_ind = request->committees[d.seq].validate_ind, pacr.edit_ind = request->
     committees[d.seq].edit_ind, pacr.active_ind = 1,
     pacr.updt_dt_tm = cnvtdatetime(sysdate), pacr.updt_id = reqinfo->updt_id, pacr.updt_applctx =
     reqinfo->updt_applctx,
     pacr.updt_task = reqinfo->updt_task, pacr.updt_cnt = 0
    PLAN (d
     WHERE (request->committees[d.seq].prot_amd_committee_id=0))
     JOIN (pacr)
    WITH counter
   ;end insert
   IF (curqual=0)
    SET fail_flag = insert_into_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Inserting into prot_amd_committee_reltn table."
    GO TO check_error
   ENDIF
  ENDIF
  IF (updt_committee_ind=1)
   SET updt_cnt_prob = 0
   SET com_count = 0
   SET cur_cmt_cnt = size(request->committees,5)
   SET loop_cnt = ceil((cnvtreal(cur_cmt_cnt)/ batch_size))
   SET new_cmt_cnt = (batch_size * loop_cnt)
   SET stat = alterlist(request->committees,new_cmt_cnt)
   FOR (i = (cur_cmt_cnt+ 1) TO new_cmt_cnt)
     SET request->committees[i].prot_amd_committee_id = request->committees[cur_cmt_cnt].
     prot_amd_committee_id
   ENDFOR
   SET index = 0
   SELECT INTO "nl:"
    FROM prot_amd_committee_reltn pacr,
     (dummyt d  WITH seq = value(loop_cnt))
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (pacr
     WHERE expand(idx,nstart,((nstart+ batch_size) - 1),pacr.prot_amd_committee_id,request->
      committees[idx].prot_amd_committee_id)
      AND pacr.prot_amd_committee_id != 0)
    DETAIL
     index = locateval(idx,1,cur_cmt_cnt,pacr.prot_amd_committee_id,request->committees[idx].
      prot_amd_committee_id)
     IF ((request->committees[index].updt_cnt != pacr.updt_cnt))
      updt_cnt_prob = 1
     ENDIF
     com_count += 1
    WITH nocounter, forupdate(pacr)
   ;end select
   SET stat = alterlist(request->committees,cur_cmt_cnt)
   IF (com_count=0)
    SET fail_flag = lock_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Locking prot_amd_committee_reltn table."
    GO TO check_error
   ELSEIF (updt_cnt_prob=1)
    SET fail_flag = updt_cnt_no_match
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Update counts do not match for prot_amd_committee_reltn table."
    GO TO check_error
   ELSE
    UPDATE  FROM prot_amd_committee_reltn pacr,
      (dummyt d  WITH seq = value(cur_cmt_cnt))
     SET pacr.validate_ind = request->committees[d.seq].validate_ind, pacr.edit_ind = request->
      committees[d.seq].edit_ind, pacr.updt_dt_tm = cnvtdatetime(sysdate),
      pacr.updt_id = reqinfo->updt_id, pacr.updt_applctx = reqinfo->updt_applctx, pacr.updt_task =
      reqinfo->updt_task,
      pacr.updt_cnt = (pacr.updt_cnt+ 1)
     PLAN (d)
      JOIN (pacr
      WHERE (pacr.prot_amd_committee_id=request->committees[d.seq].prot_amd_committee_id)
       AND pacr.prot_amd_committee_id != 0)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET fail_flag = update_into_table
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Updating into prot_amd_committee_reltn table."
     GO TO check_error
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF ((request->data_capture_ind > 0))
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
   UPDATE  FROM long_text_reference ltr
    SET ltr.long_text = request->data_capture_str, ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr
     .updt_id = reqinfo->updt_id,
     ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_task = reqinfo->updt_task, ltr.updt_cnt = (
     cur_updt_cnt+ 1),
     ltr.active_ind = 1
    WHERE (ltr.long_text_id=datacapturereply->long_text_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET fail_flag = update_into_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Updating into long_text_reference table."
    GO TO check_error
   ENDIF
  ELSEIF (size(trim(request->data_capture_str),1) > 0)
   INSERT  FROM long_text_reference ltr
    SET ltr.long_text_id = seq(long_data_seq,nextval), ltr.long_text = request->data_capture_str, ltr
     .parent_entity_name = "PROT_AMENDMENT",
     ltr.parent_entity_id = request->prot_amendment_id, ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr
     .updt_id = reqinfo->updt_id,
     ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_task = reqinfo->updt_task, ltr.updt_cnt = 0,
     ltr.active_ind = 1, ltr.active_status_cd = reqdata->active_status_cd, ltr.active_status_dt_tm =
     cnvtdatetime(sysdate),
     ltr.active_status_prsnl_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET fail_flag = insert_into_table
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Inserting data capture information into long_reference table."
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
   OF lock_table:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   OF generate_id:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   OF insert_into_table:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_into_table:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF updt_cnt_no_match:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   OF delete_from_table:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectname = ""
    SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  ENDCASE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 SUBROUTINE (processsupporttypes(index=i4,sponsor_id=f8) =i2)
   DECLARE st_cnt = i4 WITH protect, noconstant(0)
   SET st_cnt = size(request->sponsors[index].support_type,5)
   CALL echo(build("SupportType records to process :",st_cnt))
   FOR (x = 1 TO st_cnt)
    CALL echo(build("request->sponsors[index]->prot_grant_sponsor_id :",request->sponsors[index].
      prot_grant_sponsor_id))
    IF ((request->sponsors[index].support_type[x].delete_ind=1))
     CALL echo(build("Deleting support type :",request->sponsors[index].support_type[x].
       support_type_id))
     DELETE  FROM support_type st
      WHERE (st.prot_grant_sponsor_id=request->sponsors[index].prot_grant_sponsor_id)
       AND (st.support_type_id=request->sponsors[index].support_type[x].support_type_id)
      WITH nocounter
     ;end delete
     CALL echo(build("curqual :",curqual))
     IF (curqual=0)
      SET fail_flag = delete_from_table
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Deleting from support_type table from subroutine."
      RETURN(false)
     ENDIF
    ELSEIF ((request->sponsors[index].support_type[x].support_type_id < 0))
     CALL echo(build("Inserting support type :",request->sponsors[index].support_type[x].
       support_type_id))
     INSERT  FROM support_type st
      SET st.support_type_id = seq(protocol_def_seq,nextval), st.prot_grant_sponsor_id = sponsor_id,
       st.support_type_cd = request->sponsors[index].support_type[x].support_type_cd,
       st.updt_dt_tm = cnvtdatetime(sysdate), st.updt_id = reqinfo->updt_id, st.updt_applctx =
       reqinfo->updt_applctx,
       st.updt_task = reqinfo->updt_task, st.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET fail_flag = insert_into_table
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Inserting into support_type table from subroutine."
      RETURN(false)
     ENDIF
    ENDIF
   ENDFOR
   RETURN(true)
 END ;Subroutine
 SET last_mod = "020"
 SET mod_date = "SEP 07, 2016"
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

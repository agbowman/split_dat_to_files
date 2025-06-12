CREATE PROGRAM ct_del_log_pt_enroll:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE consent_count = i2 WITH protect, noconstant(0)
 DECLARE not_enrolled_cd = f8 WITH protect, noconstant(0.0)
 DECLARE enroll_del_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pt_prot_reg_id = f8 WITH protect, noconstant(0.0)
 DECLARE pt_prot_prescreen_id = f8 WITH protect, noconstant(0.0)
 DECLARE person_id = f8 WITH protect, noconstant(0.0)
 DECLARE prot_master_id = f8 WITH protect, noconstant(0.0)
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE enrolled_cd = f8 WITH public, constant(uar_get_code_by("MEANING",17901,"ENROLLED"))
 DECLARE consented_cd = f8 WITH public, constant(uar_get_code_by("MEANING",17901,"CONSENTED"))
 DECLARE audit_mode = i2 WITH protect, constant(0)
 DECLARE lst_updt_dt_tm_str = vc WITH public, noconstant("")
 DECLARE pt_reg_id = f8 WITH protect, noconstant(0.0)
 DECLARE participant_name = vc WITH public, noconstant("")
 DECLARE reg_id_str = vc WITH public, noconstant("")
 DECLARE person_id_audit = f8 WITH protect, noconstant(0.0)
 SET fail_flag = 0
 SET reply->status_data.status = "F"
 SET consent_count = 0
 SET not_enrolled_cd = 0.0
 SET enroll_del_cd = 0.0
 SET pt_prot_reg_id = 0.0
 SET pt_prot_prescreen_id = 0.0
 SET person_id = 0.0
 SET prot_master_id = 0.0
 RECORD consent_list(
   1 consents[*]
     2 id = f8
 )
 DECLARE lock_error = i2 WITH private, constant(1)
 DECLARE update_error = i2 WITH private, constant(2)
 DECLARE delete_error = i2 WITH private, constant(7)
 DECLARE insert_error = i2 WITH private, constant(20)
 IF ((request->partial_del_ind=0))
  SELECT INTO "nl:"
   p_pr_r.pt_prot_reg_id
   FROM pt_prot_reg p_pr_r
   WHERE (p_pr_r.reg_id=request->regid)
    AND p_pr_r.end_effective_dt_tm > cnvtdatetime(sysdate)
   DETAIL
    pt_prot_reg_id = p_pr_r.pt_prot_reg_id, pt_reg_id = p_pr_r.reg_id, person_id_audit = p_pr_r
    .person_id,
    lst_updt_dt_tm_str = build("LST_UPDT_DT_TM: ",datetimezoneformat(p_pr_r.updt_dt_tm,0,
      "MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef))
   WITH nocounter, forupdate(p_pr_r)
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error locking pt_prot_reg table."
   SET fail_flag = lock_error
   GO TO check_error
  ENDIF
  UPDATE  FROM pt_prot_reg p_pr_r
   SET p_pr_r.end_effective_dt_tm = cnvtdatetime(sysdate), p_pr_r.updt_cnt = (p_pr_r.updt_cnt+ 1),
    p_pr_r.updt_applctx = reqinfo->updt_applctx,
    p_pr_r.updt_task = reqinfo->updt_task, p_pr_r.updt_id = reqinfo->updt_id, p_pr_r.updt_dt_tm =
    cnvtdatetime(sysdate)
   WHERE p_pr_r.pt_prot_reg_id=pt_prot_reg_id
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error updating pt_prot_reg table."
   SET fail_flag = update_error
   GO TO check_error
  ENDIF
  SELECT INTO "nl:"
   p_p_p.pt_prot_prescreen_id, p_p_r.person_id, p_p_r.prot_master_id
   FROM pt_prot_prescreen p_p_p,
    pt_prot_reg p_p_r
   WHERE (p_p_r.reg_id=request->regid)
    AND p_p_p.person_id=p_p_r.person_id
    AND p_p_p.prot_master_id=p_p_r.prot_master_id
    AND ((p_p_p.screening_status_cd=enrolled_cd) OR (p_p_p.screening_status_cd=consented_cd))
   DETAIL
    pt_prot_prescreen_id = p_p_p.pt_prot_prescreen_id, person_id = p_p_r.person_id, prot_master_id =
    p_p_r.prot_master_id
   WITH nocounter, forupdate(p_p_p)
  ;end select
  IF (curqual > 0)
   DELETE  FROM pt_prot_prescreen p_p_p
    WHERE p_p_p.person_id=person_id
     AND p_p_p.prot_master_id=prot_master_id
     AND ((p_p_p.screening_status_cd=enrolled_cd) OR (p_p_p.screening_status_cd=consented_cd))
   ;end delete
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error updating pt_prot_prescreen table."
    SET fail_flag = delete_error
    GO TO check_error
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   a_r.reg_id
   FROM assign_reg_reltn a_r
   WHERE (a_r.reg_id=request->regid)
    AND a_r.end_effective_dt_tm > cnvtdatetime(sysdate)
   WITH nocounter, forupdate(a_r)
  ;end select
  IF (curqual > 0)
   UPDATE  FROM assign_reg_reltn a_r
    SET a_r.end_effective_dt_tm = cnvtdatetime(sysdate), a_r.updt_cnt = (a_r.updt_cnt+ 1), a_r
     .updt_applctx = reqinfo->updt_applctx,
     a_r.updt_task = reqinfo->updt_task, a_r.updt_id = reqinfo->updt_id, a_r.updt_dt_tm =
     cnvtdatetime(sysdate)
    WHERE (a_r.reg_id=request->regid)
     AND a_r.end_effective_dt_tm > cnvtdatetime(sysdate)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error updating assign_reg_reltn table."
    SET fail_flag = update_error
    GO TO check_error
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   rcrltn.consent_id
   FROM pt_reg_consent_reltn rcrltn
   WHERE (rcrltn.reg_id=request->regid)
   DETAIL
    consent_count += 1
    IF (mod(consent_count,10)=1)
     stat = alterlist(consent_list->consents,(consent_count+ 9))
    ENDIF
    consent_list->consents[consent_count].id = rcrltn.consent_id
   WITH nocounter, forupdate(rcrltn)
  ;end select
  SET stat = alterlist(consent_list->consents,consent_count)
  IF (consent_count > 0)
   UPDATE  FROM pt_reg_consent_reltn rcrltn
    SET rcrltn.active_ind = 0, rcrltn.active_status_cd = reqdata->inactive_status_cd, rcrltn
     .active_status_dt_tm = cnvtdatetime(sysdate),
     rcrltn.active_status_prsnl_id = reqinfo->updt_id, rcrltn.updt_cnt = (rcrltn.updt_cnt+ 1), rcrltn
     .updt_applctx = reqinfo->updt_applctx,
     rcrltn.updt_task = reqinfo->updt_task, rcrltn.updt_id = reqinfo->updt_id, rcrltn.updt_dt_tm =
     cnvtdatetime(sysdate)
    PLAN (rcrltn
     WHERE (rcrltn.reg_id=request->regid))
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error updating pt_reg_consent_reltn table."
    SET fail_flag = update_error
    GO TO check_error
   ENDIF
   SELECT INTO "nl:"
    p_cn.consent_id
    FROM pt_consent p_cn,
     (dummyt d  WITH seq = value(consent_count))
    PLAN (d)
     JOIN (p_cn
     WHERE (p_cn.consent_id=consent_list->consents[d.seq].id)
      AND p_cn.end_effective_dt_tm > cnvtdatetime(sysdate))
    WITH nocounter, forupdate(p_cn)
   ;end select
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error locking pt_consent table for reg_id."
    SET fail_flag = lock_error
    GO TO check_error
   ENDIF
   UPDATE  FROM pt_consent p_cn,
     (dummyt d  WITH seq = value(consent_count))
    SET p_cn.end_effective_dt_tm = cnvtdatetime(sysdate), p_cn.updt_cnt = (p_cn.updt_cnt+ 1), p_cn
     .updt_applctx = reqinfo->updt_applctx,
     p_cn.updt_task = reqinfo->updt_task, p_cn.updt_id = reqinfo->updt_id, p_cn.updt_dt_tm =
     cnvtdatetime(sysdate)
    PLAN (d)
     JOIN (p_cn
     WHERE (p_cn.consent_id=consent_list->consents[d.seq].id))
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error updating pt_consent table for reg_id."
    SET fail_flag = update_error
    GO TO check_error
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   rertln.pt_elig_tracking_id
   FROM pt_reg_elig_reltn rerltn
   WHERE (rerltn.reg_id=request->regid)
   DETAIL
    request->pt_elig_tracking_id = rerltn.pt_elig_tracking_id
   WITH nocounter, forupdate(rerltn)
  ;end select
  IF ((request->pt_elig_tracking_id > 0))
   UPDATE  FROM pt_reg_elig_reltn rerltn
    SET rerltn.active_ind = 0, rerltn.active_status_cd = reqdata->inactive_status_cd, rerltn
     .active_status_dt_tm = cnvtdatetime(sysdate),
     rerltn.active_status_prsnl_id = reqinfo->updt_id, rerltn.updt_cnt = (rerltn.updt_cnt+ 1), rerltn
     .updt_applctx = reqinfo->updt_applctx,
     rerltn.updt_task = reqinfo->updt_task, rerltn.updt_id = reqinfo->updt_id, rerltn.updt_dt_tm =
     cnvtdatetime(sysdate)
    PLAN (rerltn
     WHERE (rerltn.pt_elig_tracking_id=request->pt_elig_tracking_id))
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error updating pt_reg_elig_reltn table."
    SET fail_flag = update_error
    GO TO check_error
   ENDIF
  ENDIF
  SET cdaa_ct_pt_amd_assignment_id = 0.0
  SET cdaa_reg_id = request->regid
  SET cdaa_status = "F"
  EXECUTE ct_del_amd_assignment
  IF (cdaa_status="F")
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error updating ct_pt_amd_assignment table."
   SET fail_flag = update_error
   GO TO check_error
  ENDIF
 ENDIF
 IF ((request->pt_elig_tracking_id > 0.0))
  SET stat = uar_get_meaning_by_codeset(17285,"NOTENROLLED",1,not_enrolled_cd)
  SET stat = uar_get_meaning_by_codeset(17284,"ENROLLDEL",1,enroll_del_cd)
  SELECT INTO "nl:"
   pet.pt_elig_tracking_id
   FROM pt_elig_tracking pet
   WHERE (pet.pt_elig_tracking_id=request->pt_elig_tracking_id)
   WITH nocounter, forupdate(pet)
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error locking pt_elig_tracking table."
   SET fail_flag = lock_error
   GO TO check_error
  ENDIF
  UPDATE  FROM pt_elig_tracking pet
   SET pet.elig_status_cd = not_enrolled_cd, pet.reason_ineligible_cd = enroll_del_cd, pet.updt_cnt
     = (pet.updt_cnt+ 1),
    pet.updt_applctx = reqinfo->updt_applctx, pet.updt_task = reqinfo->updt_task, pet.updt_id =
    reqinfo->updt_id,
    pet.updt_dt_tm = cnvtdatetime(sysdate)
   WHERE (pet.pt_elig_tracking_id=request->pt_elig_tracking_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error updating pt_elig_tracking table."
   SET fail_flag = update_error
   GO TO check_error
  ENDIF
  SELECT INTO "nl:"
   per.pt_elig_tracking_id
   FROM pt_elig_result per
   WHERE (per.pt_elig_tracking_id=request->pt_elig_tracking_id)
   WITH nocounter, forupdate(per)
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error locking pt_elig_result table."
   SET fail_flag = lock_error
   GO TO check_error
  ENDIF
  UPDATE  FROM pt_elig_result per
   SET per.active_ind = 0, per.active_status_cd = reqdata->inactive_status_cd, per
    .active_status_dt_tm = cnvtdatetime(sysdate),
    per.active_status_prsnl_id = reqinfo->updt_id, per.updt_cnt = (per.updt_cnt+ 1), per.updt_applctx
     = reqinfo->updt_applctx,
    per.updt_task = reqinfo->updt_task, per.updt_id = reqinfo->updt_id, per.updt_dt_tm = cnvtdatetime
    (sysdate)
   WHERE (per.pt_elig_tracking_id=request->pt_elig_tracking_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error updating pt_elig_result table."
   SET fail_flag = update_error
   GO TO check_error
  ENDIF
  SELECT INTO "nl:"
   a_e.pt_elig_tracking_id
   FROM assign_elig_reltn a_e
   WHERE (a_e.pt_elig_tracking_id=request->pt_elig_tracking_id)
    AND a_e.end_effective_dt_tm > cnvtdatetime(sysdate)
   WITH nocounter, forupdate(a_e)
  ;end select
  IF (curqual > 0)
   UPDATE  FROM assign_elig_reltn a_e
    SET a_e.end_effective_dt_tm = cnvtdatetime(sysdate), a_e.updt_cnt = (a_e.updt_cnt+ 1), a_e
     .updt_applctx = reqinfo->updt_applctx,
     a_e.updt_task = reqinfo->updt_task, a_e.updt_id = reqinfo->updt_id, a_e.updt_dt_tm =
     cnvtdatetime(sysdate)
    WHERE (a_e.pt_elig_tracking_id=request->pt_elig_tracking_id)
     AND a_e.end_effective_dt_tm > cnvtdatetime(sysdate)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error updating assign_elig_reltn table."
    SET fail_flag = update_error
    GO TO check_error
   ENDIF
  ENDIF
  SET consent_count = 0
  SET stat = alterlist(consent_list->consents,consent_count)
  SELECT INTO "nl:"
   ecrltn.consent_id
   FROM pt_elig_consent_reltn ecrltn
   WHERE (ecrltn.pt_elig_tracking_id=request->pt_elig_tracking_id)
   DETAIL
    consent_count += 1
    IF (mod(consent_count,10)=1)
     stat = alterlist(consent_list->consents,(consent_count+ 9))
    ENDIF
    consent_list->consents[consent_count].id = ecrltn.consent_id
   WITH nocounter, forupdate(ecrltn)
  ;end select
  SET stat = alterlist(consent_list->consents,consent_count)
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error locking pt_elig_consent_reltn table."
   SET fail_flag = lock_error
   GO TO check_error
  ENDIF
  UPDATE  FROM pt_elig_consent_reltn ecrltn
   SET ecrltn.active_ind = 0, ecrltn.active_status_cd = reqdata->inactive_status_cd, ecrltn
    .active_status_dt_tm = cnvtdatetime(sysdate),
    ecrltn.active_status_prsnl_id = reqinfo->updt_id, ecrltn.updt_cnt = (ecrltn.updt_cnt+ 1), ecrltn
    .updt_applctx = reqinfo->updt_applctx,
    ecrltn.updt_task = reqinfo->updt_task, ecrltn.updt_id = reqinfo->updt_id, ecrltn.updt_dt_tm =
    cnvtdatetime(sysdate)
   PLAN (ecrltn
    WHERE (ecrltn.pt_elig_tracking_id=request->pt_elig_tracking_id))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error updating pt_elig_consent_reltn table."
   SET fail_flag = update_error
   GO TO check_error
  ENDIF
  SELECT INTO "nl:"
   p_cn.consent_id
   FROM pt_consent p_cn,
    (dummyt d  WITH seq = value(consent_count))
   PLAN (d)
    JOIN (p_cn
    WHERE (p_cn.consent_id=consent_list->consents[d.seq].id)
     AND p_cn.end_effective_dt_tm > cnvtdatetime(sysdate))
   WITH nocounter, forupdate(p_cn)
  ;end select
  IF (consent_count > 0
   AND curqual > 0)
   UPDATE  FROM pt_consent p_cn,
     (dummyt d  WITH seq = value(consent_count))
    SET p_cn.end_effective_dt_tm = cnvtdatetime(sysdate), p_cn.updt_cnt = (p_cn.updt_cnt+ 1), p_cn
     .updt_applctx = reqinfo->updt_applctx,
     p_cn.updt_task = reqinfo->updt_task, p_cn.updt_id = reqinfo->updt_id, p_cn.updt_dt_tm =
     cnvtdatetime(sysdate)
    PLAN (d)
     JOIN (p_cn
     WHERE (p_cn.consent_id=consent_list->consents[d.seq].id))
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error updating pt_consent table for pt_elig_tracking_id."
    SET fail_flag = update_error
    GO TO check_error
   ENDIF
  ENDIF
 ENDIF
 INSERT  FROM ct_reason_deleted del
  SET del.reg_id = pt_prot_reg_id, del.ct_reason_del_id = seq(protocol_def_seq,nextval), del
   .deletion_dt_tm = cnvtdatetime(sysdate),
   del.deletion_prsnl_id = reqinfo->updt_id, del.deletion_reason = request->reason, del
   .pt_elig_tracking_id = request->pt_elig_tracking_id,
   del.updt_cnt = 0, del.updt_applctx = reqinfo->updt_applctx, del.updt_task = reqinfo->updt_task,
   del.updt_id = reqinfo->updt_id, del.updt_dt_tm = cnvtdatetime(sysdate), del.active_ind = 1,
   del.active_status_cd = reqdata->active_status_cd, del.active_status_dt_tm = cnvtdatetime(sysdate),
   del.active_status_prsnl_id = reqinfo->updt_id
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error inserting into ct_reason_deleted table."
  SET fail_flag = insert_error
  GO TO check_error
 ENDIF
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  SET reg_id_str = build3(3,"REG_ID: ",pt_reg_id)
  SET participant_name = concat(reg_id_str," ",lst_updt_dt_tm_str," (UPDT_DT_TM)")
  EXECUTE cclaudit audit_mode, "Enrollment_Delete", "Delete",
  "Person", "Patient", "Patient",
  "Destruction", person_id_audit, participant_name
 ELSE
  CASE (fail_flag)
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
    SET reply->status_data.subeventstatus[1].operationstatus = "L"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unknown error."
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 FREE RECORD consent_list
 SET last_mod = "006"
 SET mod_date = "Feb 15, 2024"
END GO

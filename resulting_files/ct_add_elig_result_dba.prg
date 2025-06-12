CREATE PROGRAM ct_add_elig_result:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 pt_elig_tracking_id = f8
    1 prescreen_chg_ind = i2
    1 notes[*]
      2 pt_elig_tracking_note_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD status_request(
   1 pt_prot_prescreen_id = f8
   1 status_cd = f8
   1 status_comment_text = vc
 )
 RECORD status_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD pref_reply(
   1 pref_value = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD ct_chg_checklist_notes_request(
   1 pt_elig_tracking_id = f8
   1 pt_elig_tracking_note_id = f8
   1 note_text = vc
   1 note_type_cd = f8
   1 delete_ind = i2
 )
 RECORD ct_chg_checklist_notes_reply(
   1 pt_elig_tracking_note_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE maxseq = f8 WITH protect, noconstant(0.0)
 DECLARE enrollment_nbr = i2 WITH protect, noconstant(0)
 DECLARE last_record_id = f8 WITH protect, noconstant(0.0)
 DECLARE failed = i2 WITH protect, noconstant(- (1))
 DECLARE last_attempt_yes_cd = f8 WITH protect, noconstant(0.0)
 DECLARE last_attempt_no_cd = f8 WITH protect, noconstant(0.0)
 DECLARE elig_tracking_id = f8 WITH protect, noconstant(0.0)
 DECLARE prot_master_id = f8 WITH protect, noconstant(0.0)
 DECLARE followup_cd = f8 WITH protect, noconstant(0.0)
 DECLARE syscancel_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pending_cd = f8 WITH protect, noconstant(0.0)
 DECLARE not_qual_cd = f8 WITH protect, noconstant(0.0)
 DECLARE referred_cd = f8 WITH protect, noconstant(0.0)
 DECLARE notelistsize = i2 WITH protect, noconstant(0)
 DECLARE noteidx = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET failed = - (1)
 SET stat = uar_get_meaning_by_codeset(17283,"YES",1,last_attempt_yes_cd)
 SET stat = uar_get_meaning_by_codeset(17283,"NO",1,last_attempt_no_cd)
 SELECT INTO "nl:"
  FROM pt_elig_tracking pet
  WHERE (pet.prot_questionnaire_id=request->prot_questionnaire_id)
   AND (pet.person_id=request->person_id)
   AND pet.last_attempt_indicator_cd=last_attempt_yes_cd
  DETAIL
   maxseq = pet.sequence_nbr, enrollment_nbr = pet.enrollment_nbr, last_record_id = pet
   .pt_elig_tracking_id
  WITH nocounter
 ;end select
 SET maxseq = (maxseq+ 1)
 IF (last_record_id=0.0)
  SELECT INTO "nl:"
   FROM prot_amendment pa
   WHERE (pa.prot_amendment_id=request->prot_amend_id)
   DETAIL
    IF (enrollment_nbr < pa.amendment_nbr)
     enrollment_nbr = pa.amendment_nbr
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET failed = 1
   GO TO check_error
  ENDIF
 ELSE
  UPDATE  FROM pt_elig_tracking pet
   SET pet.last_attempt_indicator_cd = last_attempt_no_cd
   WHERE pet.pt_elig_tracking_id=last_record_id
  ;end update
  IF (curqual=0)
   SET failed = 2
   GO TO check_error
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  num = seq(protocol_def_seq,nextval)"########################;rpO"
  FROM dual
  DETAIL
   elig_tracking_id = cnvtreal(num)
  WITH format, counter
 ;end select
 IF (curqual=0)
  SET failed = 3
  GO TO check_error
 ENDIF
 CALL echo("After getting the next Tracking Id")
 INSERT  FROM pt_elig_tracking pet
  SET pet.person_id = request->person_id, pet.pt_elig_tracking_id = elig_tracking_id, pet
   .prot_questionnaire_id = request->prot_questionnaire_id,
   pet.sequence_nbr = maxseq, pet.beg_effective_dt_tm = cnvtdatetime(request->result_dt_tm), pet
   .elig_status_cd = request->elig_status_cd,
   pet.reason_ineligible_cd = request->reason_ineligible_cd, pet.last_attempt_indicator_cd =
   last_attempt_yes_cd, pet.enrollment_nbr = enrollment_nbr,
   pet.elig_request_person_id = request->elig_request_person_id, pet.elig_request_org_id = request->
   elig_request_org_id, pet.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   pet.updt_id = reqinfo->updt_id, pet.updt_task = reqinfo->updt_task, pet.updt_applctx = reqinfo->
   updt_applctx,
   pet.updt_cnt = 0, pet.override_reason_cd = request->override_reason_cd, pet.override_dt_tm =
   cnvtdatetime(request->override_dt_tm)
  WITH nocounter
 ;end insert
 CALL echo("After inserting into the tracking table")
 IF (curqual=0)
  SET failed = 4
  GO TO check_error
 ENDIF
 SET notelistsize = size(request->notes,5)
 IF (notelistsize > 0)
  SET stat = alterlist(reply->notes,notelistsize)
  FOR (noteidx = 1 TO notelistsize)
    SET ct_chg_checklist_notes_request->pt_elig_tracking_id = elig_tracking_id
    SET ct_chg_checklist_notes_request->note_text = request->notes[noteidx].note_text
    SET ct_chg_checklist_notes_request->note_type_cd = request->notes[noteidx].note_type_cd
    EXECUTE ct_chg_checklist_notes  WITH replace("REQUEST","CT_CHG_CHECKLIST_NOTES_REQUEST"), replace
    ("REPLY","CT_CHG_CHECKLIST_NOTES_REPLY")
    IF ((ct_chg_checklist_notes_reply->status_data.status="S"))
     SET reply->notes[noteidx].pt_elig_tracking_note_id = ct_chg_checklist_notes_reply->
     pt_elig_tracking_note_id
    ELSE
     SET failed = 7
     GO TO check_error
    ENDIF
  ENDFOR
 ENDIF
 SET qual_size = size(request->qual,5)
 CALL echo("Before inserting into pt_elig_Result table")
 IF (qual_size > 0)
  INSERT  FROM pt_elig_result per,
    (dummyt d  WITH seq = value(qual_size))
   SET per.pt_elig_result_id = seq(protocol_def_seq,nextval), per.pt_elig_tracking_id =
    elig_tracking_id, per.prot_amendment_id = request->prot_amend_id,
    per.prot_elig_quest_id = request->qual[d.seq].question_id, per.elig_value_provider_person_id =
    request->qual[d.seq].elig_provider_person_id, per.elig_value_provider_org_id = request->qual[d
    .seq].elig_provider_org_id,
    per.elig_indicator_cd = request->qual[d.seq].elig_indicator_cd, per.value = request->qual[d.seq].
    value, per.value_cd = request->qual[d.seq].value_cd,
    per.specimen_test_dt_tm = cnvtdatetime(request->qual[d.seq].specimen_dt_tm), per.updt_dt_tm =
    cnvtdatetime(curdate,curtime3), per.updt_id = reqinfo->updt_id,
    per.updt_task = reqinfo->updt_task, per.updt_applctx = reqinfo->updt_applctx, per.updt_cnt = 0,
    per.active_ind = 1, per.active_status_cd = reqdata->active_status_cd, per.active_status_dt_tm =
    cnvtdatetime(curdate,curtime3),
    per.active_status_prsnl_id = reqinfo->updt_id
   PLAN (d)
    JOIN (per)
   WITH nocounter
  ;end insert
  CALL echo("After inserting into pt_elig_Result table")
  IF (curqual=0)
   SET failed = 5
   GO TO check_error
  ELSE
   SET failed = 0
  ENDIF
 ENDIF
 EXECUTE ct_get_prescreen_pref  WITH replace("REPLY","PREF_REPLY")
 IF ((pref_reply->pref_value=1))
  SET stat = uar_get_meaning_by_codeset(17901,"INFOLLOWUP",1,followup_cd)
  SET stat = uar_get_meaning_by_codeset(17901,"PENDING",1,pending_cd)
  SET stat = uar_get_meaning_by_codeset(17901,"NOTQUAL",1,not_qual_cd)
  SET stat = uar_get_meaning_by_codeset(17901,"REFERRED",1,referred_cd)
  SET stat = uar_get_meaning_by_codeset(17901,"SYSCANCEL",1,syscancel_cd)
  IF (followup_cd > 0)
   SELECT INTO "NL:"
    FROM prot_amendment pa
    WHERE (pa.prot_amendment_id=request->prot_amend_id)
    DETAIL
     prot_master_id = pa.prot_master_id
    WITH nocounter
   ;end select
   IF (prot_master_id > 0)
    SELECT INTO "NL:"
     FROM pt_prot_prescreen pps
     WHERE (pps.person_id=request->person_id)
      AND pps.prot_master_id=prot_master_id
      AND pps.screening_status_cd != syscancel_cd
     DETAIL
      IF (pps.screening_status_cd IN (pending_cd, not_qual_cd, referred_cd))
       status_request->pt_prot_prescreen_id = pps.pt_prot_prescreen_id, status_request->status_cd =
       followup_cd, status_request->status_comment_text = ""
      ENDIF
     WITH nocounter
    ;end select
    IF ((status_request->pt_prot_prescreen_id > 0))
     EXECUTE ct_chg_prescreen_status  WITH replace("REQUEST","STATUS_REQUEST"), replace("REPLY",
      "STATUS_REPLY")
     IF ((status_reply->status_data.status != "S"))
      SET failed = 6
      GO TO check_error
     ELSE
      SET reply->prescreen_chg_ind = 1
      SET failed = 0
     ENDIF
    ELSE
     SET failed = 0
    ENDIF
   ENDIF
  ENDIF
 ENDIF
#check_error
 IF (failed=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->pt_elig_tracking_id = elig_tracking_id
  CALL echo("SUCCESS")
 ELSE
  CALL echo(failed)
  CALL echo("FAILED")
  SET reply->status_data.status = "F"
  CASE (failed)
   OF 1:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   OF 2:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF 3:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF 4:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF 5:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT2"
   OF 6:
    SET reply->status_data.subeventstatus[1].operationname = "PRESCREEN"
   OF 7:
    SET reply->status_data.subeventstatus[1].operationname = "NOTES"
   OF - (1):
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  SET reqinfo->commit_ind = 0
  SET reply->pt_elig_tracking_id = 0.0
 ENDIF
 FREE RECORD status_request
 FREE RECORD status_reply
 FREE RECORD pref_reply
 SET last_mod = "007"
 SET mod_date = "Feb 27, 2009"
END GO

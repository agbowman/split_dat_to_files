CREATE PROGRAM ct_upt_elig_result:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 pt_elig_tracking_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
    1 notes[*]
      2 pt_elig_tracking_note_id = f8
  )
 ENDIF
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
 DECLARE notelistsize = i2 WITH protect, noconstant(0)
 DECLARE noteidx = i2 WITH protect, noconstant(0)
 SET reply->pt_elig_tracking_id = request->pt_elig_tracking_id
 SET reply->status_data.status = "F"
 SET failed = - (1)
 CALL echorecord(request)
 IF ((request->upt_mode=1))
  UPDATE  FROM pt_elig_tracking pet
   SET pet.elig_status_cd = request->elig_status_cd, pet.reason_ineligible_cd = request->
    reason_ineligible_cd, pet.elig_request_person_id = request->elig_request_person_id,
    pet.elig_request_org_id = request->elig_request_org_id, pet.beg_effective_dt_tm = cnvtdatetime(
     request->result_dt_tm), pet.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    pet.updt_id = reqinfo->updt_id, pet.updt_task = reqinfo->updt_task, pet.updt_applctx = reqinfo->
    updt_applctx,
    pet.updt_cnt = (pet.updt_cnt+ 1), pet.override_reason_cd = request->override_reason_cd, pet
    .override_dt_tm = cnvtdatetime(request->override_dt_tm)
   WHERE (pet.pt_elig_tracking_id=request->pt_elig_tracking_id)
  ;end update
  IF (curqual=0)
   SET failed = 1
   GO TO check_error
  ENDIF
 ELSE
  UPDATE  FROM pt_elig_tracking pet
   SET pet.elig_status_cd =
    IF ((request->elig_status_cd != 0)) request->elig_status_cd
    ENDIF
    , pet.reason_ineligible_cd = request->reason_ineligible_cd, pet.elig_request_person_id = request
    ->elig_request_person_id,
    pet.elig_request_org_id = request->elig_request_org_id, pet.beg_effective_dt_tm = cnvtdatetime(
     request->result_dt_tm), pet.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    pet.updt_id = reqinfo->updt_id, pet.updt_task = reqinfo->updt_task, pet.updt_applctx = reqinfo->
    updt_applctx,
    pet.updt_cnt = (pet.updt_cnt+ 1), pet.override_reason_cd = request->override_reason_cd, pet
    .override_dt_tm = cnvtdatetime(request->override_dt_tm)
   WHERE (pet.pt_elig_tracking_id=request->pt_elig_tracking_id)
  ;end update
  IF (curqual=0)
   SET failed = 1
   GO TO check_error
  ENDIF
 ENDIF
 SET update_cnt = size(request->qual,5)
 IF (update_cnt > 0)
  UPDATE  FROM pt_elig_result per,
    (dummyt d  WITH seq = value(update_cnt))
   SET per.elig_indicator_cd = request->qual[d.seq].elig_indicator_cd, per.value = request->qual[d
    .seq].value, per.value_cd = request->qual[d.seq].value_cd,
    per.specimen_test_dt_tm = cnvtdatetime(request->qual[d.seq].specimen_dt_tm), per
    .elig_value_provider_person_id = request->qual[d.seq].elig_provider_person_id, per
    .elig_value_provider_org_id = request->qual[d.seq].elig_provider_org_id,
    per.updt_dt_tm = cnvtdatetime(curdate,curtime3), per.updt_id = reqinfo->updt_id, per.updt_task =
    reqinfo->updt_task,
    per.updt_applctx = reqinfo->updt_applctx, per.updt_cnt = (per.updt_cnt+ 1)
   PLAN (d)
    JOIN (per
    WHERE (per.pt_elig_tracking_id=request->pt_elig_tracking_id)
     AND (per.prot_elig_quest_id=request->qual[d.seq].question_id))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = 2
   GO TO check_error
  ENDIF
 ENDIF
 SET notelistsize = size(request->notes,5)
 IF (notelistsize > 0)
  SET stat = alterlist(reply->notes,notelistsize)
  FOR (noteidx = 1 TO notelistsize)
    SET ct_chg_checklist_notes_request->pt_elig_tracking_id = request->pt_elig_tracking_id
    SET ct_chg_checklist_notes_request->pt_elig_tracking_note_id = request->notes[noteidx].
    pt_elig_tracking_note_id
    SET ct_chg_checklist_notes_request->note_text = request->notes[noteidx].note_text
    SET ct_chg_checklist_notes_request->note_type_cd = request->notes[noteidx].note_type_cd
    SET ct_chg_checklist_notes_request->delete_ind = request->notes[noteidx].delete_ind
    EXECUTE ct_chg_checklist_notes  WITH replace("REQUEST","CT_CHG_CHECKLIST_NOTES_REQUEST"), replace
    ("REPLY","CT_CHG_CHECKLIST_NOTES_REPLY")
    IF ((ct_chg_checklist_notes_reply->status_data.status="S"))
     SET reply->notes[noteidx].pt_elig_tracking_note_id = ct_chg_checklist_notes_reply->
     pt_elig_tracking_note_id
    ELSE
     SET failed = 3
     GO TO check_error
    ENDIF
  ENDFOR
 ENDIF
 SET failed = 0
#check_error
 IF (failed=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CASE (failed)
   OF 1:
    SET reply->status_data.subeventstatus[1].operationname = "UPT_TRACK"
   OF 2:
    SET reply->status_data.subeventstatus[1].operationname = "UPT_RESULT"
   OF 3:
    SET reply->status_data.subeventstatus[1].operationname = "NOTES"
   OF - (1):
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "003"
 SET mod_date = "October 22, 2008"
END GO

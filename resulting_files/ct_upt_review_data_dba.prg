CREATE PROGRAM ct_upt_review_data:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 reason_for_failure = vc
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
 SET reply->status_data.status = "F"
 SET failed = - (1)
 SET qual_size = size(request->qual,5)
 UPDATE  FROM pt_elig_tracking pet
  SET pet.elig_review_person_id = request->elig_review_person_id, pet.elig_review_org_id = request->
   elig_review_org_id, pet.elig_status_cd = request->elig_status_cd
  WHERE (pet.pt_elig_tracking_id=request->pt_elig_tracking_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = 1
  GO TO check_error
 ENDIF
 IF (qual_size > 0)
  UPDATE  FROM pt_elig_result per,
    (dummyt d  WITH seq = value(qual_size))
   SET per.elig_review_dt_tm = cnvtdatetime(curdate,curtime3), per.verified_elig_status_cd = request
    ->qual[d.seq].verified_elig_status_cd, per.audited_value = request->qual[d.seq].audited_value,
    per.audited_value_cd = request->qual[d.seq].audited_value_cd, per.verified_specimen_test_dt_tm =
    cnvtdatetime(request->qual[d.seq].verified_specimen_dt_tm), per.updt_applctx = reqinfo->
    updt_applctx,
    per.updt_dt_tm = cnvtdatetime(curdate,curtime3), per.updt_id = reqinfo->updt_id, per.updt_task =
    reqinfo->updt_task,
    per.updt_cnt = (per.updt_cnt+ 1)
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
 ELSEIF (failed=1)
  SET reply->reason_for_failure = "Failure to update Pt_Elig_Tracking"
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSEIF (failed=2)
  SET reply->reason_for_failure = "Failure to update Pt_Elig_Result table"
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSEIF (failed=3)
  SET reply->reason_for_failure = "Failure to update checklist notes."
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
 SET last_mod = "001"
 SET mod_date = "October 23, 2008"
END GO

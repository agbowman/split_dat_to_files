CREATE PROGRAM ct_get_checklist_notes
 RECORD reply(
   1 notes[*]
     2 pt_elig_tracking_note_id = f8
     2 note_text = vc
     2 note_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE cnt = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 IF ((request->note_type_cd=0.0))
  SELECT INTO "NL:"
   FROM pt_elig_tracking_notes petn,
    long_text lt
   PLAN (petn
    WHERE (petn.pt_elig_tracking_id=request->pt_elig_tracking_id)
     AND petn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (lt
    WHERE petn.note_long_text_id=lt.long_text_id)
   ORDER BY uar_get_code_display(petn.note_type_cd)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->notes,(cnt+ 9))
    ENDIF
    reply->notes[cnt].pt_elig_tracking_note_id = petn.pt_elig_tracking_notes_id, reply->notes[cnt].
    note_text = lt.long_text, reply->notes[cnt].note_type_cd = petn.note_type_cd
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "NL:"
   FROM pt_elig_tracking_notes petn,
    long_text lt
   PLAN (petn
    WHERE (petn.pt_elig_tracking_id=request->pt_elig_tracking_id)
     AND petn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND (petn.note_type_cd=request->note_type_cd))
    JOIN (lt
    WHERE petn.note_long_text_id=lt.long_text_id)
   ORDER BY uar_get_code_display(petn.note_type_cd)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->notes,(cnt+ 9))
    ENDIF
    reply->notes[cnt].pt_elig_tracking_note_id = petn.pt_elig_tracking_notes_id, reply->notes[cnt].
    note_text = lt.long_text, reply->notes[cnt].note_type_cd = petn.note_type_cd
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->notes,cnt)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "000"
 SET mod_date = "October 16, 2008"
END GO

CREATE PROGRAM ct_chg_checklist_notes
 RECORD reply(
   1 pt_elig_tracking_note_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 SUBROUTINE (nextlongtextsequence(x=i2) =f8)
   DECLARE nsequence = f8 WITH protect
   SELECT INTO "nl:"
    nextseqnum = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     nsequence = nextseqnum
    WITH nocounter
   ;end select
   RETURN(nsequence)
 END ;Subroutine
 SUBROUTINE (insert_long_text(long_text_id=f8,text=vc,parent_name=vc,parent_id=f8) =i2)
  INSERT  FROM long_text lt
   SET lt.long_text_id =
    IF (long_text_id > 0) long_text_id
    ELSE seq(long_data_seq,nextval)
    ENDIF
    , lt.long_text = text, lt.parent_entity_name = parent_name,
    lt.parent_entity_id = parent_id, lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_id = reqinfo->
    updt_id,
    lt.updt_applctx = reqinfo->updt_applctx, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
    lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
    cnvtdatetime(sysdate),
    lt.active_status_prsnl_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   RETURN(false)
  ELSE
   RETURN(true)
  ENDIF
 END ;Subroutine
 DECLARE insert_error = i2 WITH private, constant(1)
 DECLARE update_error = i2 WITH private, constant(2)
 DECLARE lock_error = i2 WITH private, constant(3)
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE new_notes_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_long_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE prev_long_text_id = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET new_notes_id = nextsequence(0)
 SET new_long_text_id = nextlongtextsequence(0)
 IF ((request->pt_elig_tracking_note_id=0.0))
  IF (insert_long_text(new_long_text_id,request->note_text,"pt_elig_tracking_notes",new_notes_id) !=
  true)
   SET fail_flag = insert_error
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "There was an error adding the note to the long_text table."
   GO TO check_error
  ELSE
   INSERT  FROM pt_elig_tracking_notes petn
    SET petn.beg_effective_dt_tm = cnvtdatetime(sysdate), petn.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100 00:00:00.00"), petn.note_long_text_id = new_long_text_id,
     petn.note_type_cd = request->note_type_cd, petn.prev_pt_elig_tracking_notes_id = new_notes_id,
     petn.pt_elig_tracking_id = request->pt_elig_tracking_id,
     petn.pt_elig_tracking_notes_id = new_notes_id, petn.updt_applctx = reqinfo->updt_applctx, petn
     .updt_cnt = 0,
     petn.updt_dt_tm = cnvtdatetime(sysdate), petn.updt_id = reqinfo->updt_id, petn.updt_task =
     reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET fail_flag = insert_error
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "There was an error adding the note to the pt_elig_tracking_notes table."
    GO TO check_error
   ELSE
    SET reply->pt_elig_tracking_note_id = new_notes_id
   ENDIF
  ENDIF
 ELSE
  SELECT INTO "nl:"
   petn.note_long_text_id
   FROM pt_elig_tracking_notes petn
   WHERE (petn.pt_elig_tracking_notes_id=request->pt_elig_tracking_note_id)
   DETAIL
    prev_long_text_id = petn.note_long_text_id
   WITH nocounter, forupdate(petn)
  ;end select
  IF (curqual != 1)
   SET fail_flag = lock_error
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "The pt_elig_tracking_notes table could not be locked."
   GO TO check_error
  ELSE
   SELECT INTO "nl:"
    lt.long_text_id
    FROM long_text lt
    WHERE lt.long_text_id=prev_long_text_id
    WITH nocounter, forupdate(lt)
   ;end select
   IF (curqual != 1)
    SET fail_flag = lock_error
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "The long_text table could not be locked."
   ELSE
    UPDATE  FROM long_text lt
     SET lt.active_ind = 0
     WHERE lt.long_text_id=prev_long_text_id
     WITH nocounter
    ;end update
    IF (curqual != 1)
     SET fail_flag = insert_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "There was an error updating the note in the long_text table for versioning."
     GO TO check_error
    ELSE
     INSERT  FROM pt_elig_tracking_notes petn
      (petn.beg_effective_dt_tm, petn.end_effective_dt_tm, petn.note_long_text_id,
      petn.note_type_cd, petn.prev_pt_elig_tracking_notes_id, petn.pt_elig_tracking_id,
      petn.pt_elig_tracking_notes_id, petn.updt_applctx, petn.updt_cnt,
      petn.updt_dt_tm, petn.updt_id, petn.updt_task)(SELECT
       petn1.beg_effective_dt_tm, cnvtdatetime(sysdate), petn1.note_long_text_id,
       petn1.note_type_cd, petn1.prev_pt_elig_tracking_notes_id, petn1.pt_elig_tracking_id,
       new_notes_id, petn1.updt_applctx, petn1.updt_cnt,
       petn1.updt_dt_tm, petn1.updt_id, petn1.updt_task
       FROM pt_elig_tracking_notes petn1
       WHERE (petn1.pt_elig_tracking_notes_id=request->pt_elig_tracking_note_id))
      WITH nocounter
     ;end insert
     IF (curqual != 1)
      SET fail_flag = insert_error
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "There was an error inserting the note in the pt_elig_tracking_notes table for versioning."
      GO TO check_error
     ELSE
      IF ((request->delete_ind=0))
       IF (insert_long_text(new_long_text_id,request->note_text,"pt_elig_tracking_notes",new_notes_id
        ) != true)
        SET fail_flag = insert_error
        SET reply->status_data.subeventstatus[1].targetobjectvalue =
        "There was an error inserting into the long_text table."
        GO TO check_error
       ENDIF
      ENDIF
      UPDATE  FROM pt_elig_tracking_notes petn
       SET petn.beg_effective_dt_tm = cnvtdatetime(sysdate), petn.end_effective_dt_tm =
        IF ((request->delete_ind=1)) cnvtdatetime(sysdate)
        ELSE petn.end_effective_dt_tm
        ENDIF
        , petn.note_long_text_id =
        IF ((request->delete_ind=1)) petn.note_long_text_id
        ELSE new_long_text_id
        ENDIF
        ,
        petn.note_type_cd = petn.note_type_cd, petn.prev_pt_elig_tracking_notes_id = petn
        .prev_pt_elig_tracking_notes_id, petn.pt_elig_tracking_id = petn.pt_elig_tracking_id,
        petn.pt_elig_tracking_notes_id = petn.pt_elig_tracking_notes_id, petn.updt_applctx = reqinfo
        ->updt_applctx, petn.updt_cnt = (petn.updt_cnt+ 1),
        petn.updt_dt_tm = cnvtdatetime(sysdate), petn.updt_id = reqinfo->updt_id, petn.updt_task =
        reqinfo->updt_task
       WHERE (petn.pt_elig_tracking_notes_id=request->pt_elig_tracking_note_id)
       WITH nocounter
      ;end update
      CALL echo("EXITING UPDATE")
      IF (curqual != 1)
       SET fail_flag = update_error
       SET reply->status_data.subeventstatus[1].targetobjectvalue =
       "The pt_elig_tracking_notes table could not be updated."
      ELSE
       SET reply->pt_elig_tracking_note_id = request->pt_elig_tracking_note_id
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CASE (fail_flag)
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "000"
 SET mod_date = "October 22, 2008"
END GO

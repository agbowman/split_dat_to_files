CREATE PROGRAM bbd_chg_contact_note:dba
 RECORD reply(
   1 contact_note_id = f8
   1 contact_updt_cnt = i4
   1 long_text = vc
   1 long_text_id = f8
   1 long_text_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c40
       3 targetobjectvalue = c150
       3 sub_event_dt_tm = di8
 )
 RECORD hold_text(
   1 text = vc
 )
 RECORD new_text(
   1 text = vc
 )
 SET modify = predeclare
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 DECLARE text_id = f8 WITH protect, noconstant(0.0)
 DECLARE count1 = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE new_contact_note_id = f8 WITH protect, noconstant(0.0)
 DECLARE cv_cnt = i4 WITH protect, noconstant(1)
 DECLARE contact_type_code = f8 WITH protect, noconstant(0.0)
 DECLARE dt_tm_text = vc WITH protect, noconstant(concat(trim(format(curdate,"mm/dd/yyyy;;d"))," ",
   trim(format(curtime,"hh:mm;;m"))))
 DECLARE stat = i4 WITH protect, noconstant(0)
 IF ((request->contact_type_mean="DONATE"))
  SET stat = uar_get_meaning_by_codeset(14220,"DONATE",cv_cnt,contact_type_code)
 ELSEIF ((request->contact_type_mean="RECRUIT"))
  SET stat = uar_get_meaning_by_codeset(14220,"RECRUIT",cv_cnt,contact_type_code)
 ELSEIF ((request->contact_type_mean="COUNSEL"))
  SET stat = uar_get_meaning_by_codeset(14220,"COUNSEL",cv_cnt,contact_type_code)
 ELSEIF ((request->contact_type_mean="OTHER"))
  SET stat = uar_get_meaning_by_codeset(14220,"OTHER",cv_cnt,contact_type_code)
 ENDIF
 IF (contact_type_code=0.0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_contact_note"
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Code value"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "could not retrieve contact type code for update"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 IF ((request->new_indicator=1))
  SET hold_text->text = concat(">> ",trim(dt_tm_text),"  ",trim(request->user_name),"   ",
   trim(request->long_text))
  SET new_pathnet_seq = 0.0
  SELECT INTO "nl:"
   seqn = seq(pathnet_seq,nextval)
   FROM dual
   DETAIL
    new_pathnet_seq = seqn
   WITH format, nocounter
  ;end select
  SET new_contact_note_id = new_pathnet_seq
  SELECT INTO "nl:"
   seqn = seq(long_data_seq,nextval)
   FROM dual
   DETAIL
    text_id = seqn
   WITH format, nocounter
  ;end select
  INSERT  FROM long_text lt
   SET lt.long_text_id = text_id, lt.parent_entity_name = "BBD_CONTACT_NOTE", lt.parent_entity_id =
    new_contact_note_id,
    lt.long_text = hold_text->text, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx,
    lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
    cnvtdatetime(curdate,curtime3),
    lt.active_status_prsnl_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_contact_note"
   SET reply->status_data.subeventstatus[1].operationname = "Insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Long Text"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "long text table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  INSERT  FROM bbd_contact_note b
   SET b.contact_note_id = new_contact_note_id, b.contact_id = request->contact_id, b.encntr_id =
    request->encntr_id,
    b.person_id = request->person_id, b.contact_type_cd = contact_type_code, b.long_text_id = text_id,
    b.create_dt_tm = cnvtdatetime(curdate,curtime3), b.active_ind = 1, b.active_status_cd = reqdata->
    active_status_cd,
    b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
    updt_id, b.updt_cnt = 0,
    b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
    reqinfo->updt_task,
    b.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_contact_note"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_contact_note"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "contact note"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ELSE
   SET reply->contact_note_id = new_contact_note_id
   SET reply->contact_updt_cnt = 0
   SET reply->long_text = hold_text->text
   SET reply->long_text_id = text_id
   SET reply->long_text_updt_cnt = 0
  ENDIF
 ELSE
  SELECT INTO "nl:"
   lt.*
   FROM long_text lt
   WHERE (lt.long_text_id=request->long_text_id)
    AND (lt.updt_cnt=request->long_text_updt_cnt)
   DETAIL
    hold_text->text = lt.long_text
   WITH counter, forupdate(lt)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_contact_note"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "long text lock"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM long_text lt
   SET lt.active_ind = 0, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx
   WHERE (lt.long_text_id=request->long_text_id)
    AND (lt.updt_cnt=request->long_text_updt_cnt)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_contact_note"
   SET reply->status_data.subeventstatus[1].operationname = "inactivate"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "long text lock"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   b.*
   FROM bbd_contact_note b
   WHERE (b.contact_note_id=request->contact_note_id)
    AND (b.updt_cnt=request->contact_note_updt_cnt)
   WITH counter, forupdate(b)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_contact_note"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_contact_note"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "contact note lock"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM bbd_contact_note b
   SET b.active_ind = 0, b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
    updt_applctx
   WHERE (b.contact_note_id=request->contact_note_id)
    AND (b.updt_cnt=request->contact_note_updt_cnt)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_contact_note"
   SET reply->status_data.subeventstatus[1].operationname = "inactivate"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "contact note"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "contact note inactivate"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  IF ((request->add_indicator=1))
   SET new_text->text = concat(">> ",trim(dt_tm_text),"  ",trim(request->user_name),"   ",
    trim(request->long_text),char(13),char(10),char(13),char(10),
    trim(hold_text->text))
  ELSE
   SET new_text->text = trim(request->long_text)
  ENDIF
  SET new_pathnet_seq = 0.0
  SELECT INTO "nl:"
   seqn = seq(pathnet_seq,nextval)
   FROM dual
   DETAIL
    new_pathnet_seq = seqn
   WITH format, nocounter
  ;end select
  SET new_contact_note_id = new_pathnet_seq
  SELECT INTO "nl:"
   seqn = seq(long_data_seq,nextval)
   FROM dual
   DETAIL
    text_id = seqn
   WITH format, nocounter
  ;end select
  INSERT  FROM long_text lt
   SET lt.long_text_id = text_id, lt.parent_entity_name = "BBD_CONTACT_NOTE", lt.parent_entity_id =
    new_contact_note_id,
    lt.long_text = new_text->text, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx,
    lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
    cnvtdatetime(curdate,curtime3),
    lt.active_status_prsnl_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_contact_note"
   SET reply->status_data.subeventstatus[1].operationname = "Insert2"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Long Text"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "long text table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  INSERT  FROM bbd_contact_note b
   SET b.contact_note_id = new_contact_note_id, b.contact_id = request->contact_id, b.encntr_id =
    request->encntr_id,
    b.person_id = request->person_id, b.contact_type_cd = contact_type_code, b.long_text_id = text_id,
    b.create_dt_tm = cnvtdatetime(curdate,curtime3), b.active_ind = 1, b.active_status_cd = reqdata->
    active_status_cd,
    b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
    updt_id, b.updt_cnt = 0,
    b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
    reqinfo->updt_task,
    b.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_contact_note"
   SET reply->status_data.subeventstatus[1].operationname = "insert2"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_contact_note"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "contact note"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ELSE
   SET reply->contact_note_id = new_contact_note_id
   SET reply->contact_updt_cnt = 0
   SET reply->long_text = new_text->text
   SET reply->long_text_id = text_id
   SET reply->long_text_updt_cnt = 0
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO

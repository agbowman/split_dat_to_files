CREATE PROGRAM dcp_add_sticky_note:dba
 RECORD reply(
   1 sticky_note_id = f8
   1 updt_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE sticky_note_id = f8 WITH protect, noconstant(0)
 DECLARE msg_text_id = f8 WITH protect, noconstant(0)
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET sticky_note_id = 0
 IF ((request->beg_effective_dt_tm <= 0))
  SET request->beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
 ENDIF
 IF ((request->end_effective_dt_tm <= 0))
  SET request->end_effective_dt_tm = cnvtdatetime("31-Dec-2100")
 ENDIF
 SELECT INTO "nl:"
  j = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   sticky_note_id = j
  WITH format, nocounter
 ;end select
 IF (textlen(request->sticky_note_text) > 255)
  SELECT INTO "nl:"
   nextseqnum = seq(long_data_seq,nextval)"#################;rp0"
   FROM dual
   DETAIL
    msg_text_id = nextseqnum
   WITH format
  ;end select
  IF (msg_text_id=0.0)
   SET reply->error_number = 1
   SET reply->error_string = "LONG_DATA_SEQ"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_DATA_SEQ"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_add_sticky_note"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 INSERT  FROM sticky_note sn
  SET sn.sticky_note_id = sticky_note_id, sn.sticky_note_type_cd = request->sticky_note_type_cd, sn
   .parent_entity_name = request->parent_entity_name,
   sn.parent_entity_id = request->parent_entity_id, sn.sticky_note_text = substring(1,255,request->
    sticky_note_text), sn.sticky_note_status_cd = request->sticky_note_status_cd,
   sn.public_ind = request->public_ind, sn.beg_effective_dt_tm = cnvtdatetime(request->
    beg_effective_dt_tm), sn.end_effective_dt_tm = cnvtdatetime(request->end_effective_dt_tm),
   sn.updt_dt_tm = cnvtdatetime(curdate,curtime3), sn.updt_id = reqinfo->updt_id, sn.updt_task =
   reqinfo->updt_task,
   sn.updt_applctx = reqinfo->updt_applctx, sn.updt_cnt = 0, sn.long_text_id = msg_text_id
  WITH counter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "sticky_note table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into table"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (textlen(request->sticky_note_text) > 255)
  INSERT  FROM long_text lt
   SET lt.long_text_id = msg_text_id, lt.parent_entity_name = "STICKY_NOTE", lt.parent_entity_id =
    sticky_note_id,
    lt.long_text = request->sticky_note_text, lt.active_ind = 1, lt.active_status_cd = reqdata->
    active_status_cd,
    lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
    updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
    lt.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->error_number = 1
   SET reply->error_string = "LONG_TEXT"
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_add_sticky_note"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->sticky_note_id = sticky_note_id
  SET reply->updt_dt_tm = cnvtdatetime(curdate,curtime)
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
 EXECUTE cclaudit 0, "Maintain Person", "Add Sticky Note",
 "Person", "Patient", "Patient",
 "Addition", request->parent_entity_id, " "
END GO

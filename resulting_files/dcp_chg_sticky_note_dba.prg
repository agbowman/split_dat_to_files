CREATE PROGRAM dcp_chg_sticky_note:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "S"
 SET modify = predeclare
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE long_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE sticky_note_id = f8 WITH protect, noconstant(0.0)
 IF (textlen(request->sticky_note_text) > 255)
  SELECT INTO "NL:"
   sn.long_text_id
   FROM sticky_note sn
   WHERE (sn.sticky_note_id=request->sticky_note_id)
   DETAIL
    long_text_id = sn.long_text_id, sticky_note_id = sn.sticky_note_id
   WITH nocounter
  ;end select
  IF (long_text_id=0)
   DECLARE msg_text_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    nextseqnum = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     msg_text_id = nextseqnum
    WITH format
   ;end select
   SET long_text_id = msg_text_id
   IF (msg_text_id=0.0)
    SET reply->error_number = 1
    SET reply->error_string = "LONG_DATA_SEQ"
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_DATA_SEQ"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_chg_aticky_note"
    SET failed = "T"
    GO TO exit_script
   ENDIF
   INSERT  FROM long_text lt
    SET lt.long_text_id = long_text_id, lt.parent_entity_name = "STICKY_NOTE", lt.parent_entity_id =
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
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_chg_sticky_note"
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ELSE
   UPDATE  FROM long_text lt
    SET lt.long_text = request->sticky_note_text, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt
     .updt_id = reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = (lt
     .updt_cnt+ 1)
    WHERE lt.long_text_id=long_text_id
    WITH nocounter
   ;end update
  ENDIF
  IF (curqual=0)
   SET failed = "T"
  ENDIF
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "long_text table"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "update/insert"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to update/insert into table"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE text_exists = i2 WITH public, noconstant(0)
 IF (textlen(trim(request->sticky_note_text,3)) > 0)
  SET text_exists = 1
 ENDIF
 UPDATE  FROM sticky_note sn
  SET sn.sticky_note_text = evaluate(text_exists,0,sn.sticky_note_text,substring(1,255,request->
     sticky_note_text)), sn.sticky_note_status_cd = evaluate(request->sticky_note_status_cd,- (1.0),
    sn.sticky_note_status_cd,request->sticky_note_status_cd), sn.public_ind = evaluate(request->
    public_ind,- (1),sn.public_ind,request->public_ind),
   sn.updt_dt_tm = cnvtdatetime(curdate,curtime3), sn.updt_id = reqinfo->updt_id, sn.updt_task =
   reqinfo->updt_task,
   sn.updt_applctx = reqinfo->updt_applctx, sn.updt_cnt = (sn.updt_cnt+ 1), sn.long_text_id =
   long_text_id
  WHERE (sn.sticky_note_id=request->sticky_note_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
 ENDIF
#check_error
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "sticky_note table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to update into table"
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
 SET modify = nopredeclare
END GO

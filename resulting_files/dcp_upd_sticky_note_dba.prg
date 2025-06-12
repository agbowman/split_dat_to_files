CREATE PROGRAM dcp_upd_sticky_note:dba
 RECORD temp(
   1 sticky_note_type_cd = f8
   1 parent_entity_name = c40
   1 parent_entity_id = f8
   1 sticky_note_text = vc
   1 sticky_note_status_cd = f8
   1 public_ind = i2
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 msg_text_id = f8
   1 updt_cnt = i4
 )
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
 SET failed = "F"
 SET reply->status_data.status = "F"
 DECLARE msg_text_id = f8 WITH protect, noconstant(0)
 SET del_msg_id = 0
 SET sticky_note_id = request->sticky_note_id
 SET text_max = 255
 IF ((request->sticky_note_id=0))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM sticky_note sn
  WHERE (sn.sticky_note_id=request->sticky_note_id)
  DETAIL
   temp->sticky_note_type_cd = sn.sticky_note_type_cd, temp->parent_entity_name = sn
   .parent_entity_name, temp->parent_entity_id = sn.parent_entity_id,
   temp->sticky_note_text = sn.sticky_note_text, temp->sticky_note_status_cd = sn
   .sticky_note_status_cd, temp->public_ind = sn.public_ind,
   temp->beg_effective_dt_tm = cnvtdatetime(sn.beg_effective_dt_tm), temp->end_effective_dt_tm =
   cnvtdatetime(sn.end_effective_dt_tm), temp->msg_text_id = sn.long_text_id,
   temp->updt_cnt = sn.updt_cnt
  WITH nocounter
 ;end select
 IF ((request->sn_type_cd_present_ind=1))
  SET temp->sticky_note_type_cd = request->sticky_note_type_cd
 ENDIF
 IF ((request->pe_name_present_ind=1))
  SET temp->parent_entity_name = request->parent_entity_name
 ENDIF
 IF ((request->pe_id_present_ind=1))
  SET temp->parent_entity_id = request->parent_entity_id
 ENDIF
 IF ((request->sn_text_present_ind=1))
  SET temp->sticky_note_text = request->sticky_note_text
 ENDIF
 IF ((request->sn_status_cd_present_ind=1))
  SET temp->sticky_note_status_cd = request->sticky_note_status_cd
 ENDIF
 IF ((request->public_ind_present_ind=1))
  SET temp->public_ind = request->public_ind
 ENDIF
 IF (request->be_dt_tm_present_ind)
  SET temp->beg_effective_dt_tm = request->beg_effective_dt_tm
 ENDIF
 IF (request->ee_dt_tm_present_ind)
  SET temp->end_effective_dt_tm = request->end_effective_dt_tm
 ENDIF
 IF ((request->sn_text_present_ind=1))
  IF ((temp->msg_text_id=0))
   IF (textlen(temp->sticky_note_text) > text_max)
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)"#################;rp0"
     FROM dual
     DETAIL
      msg_text_id = nextseqnum
     WITH format
    ;end select
    IF (msg_text_id=0.0)
     SET reply->status_data.subeventstatus[1].operationname = "SELECT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_DATA_SEQ"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_sticky_note"
     SET failed = "T"
     GO TO exit_script
    ENDIF
   ELSE
    SET msg_text_id = 0
   ENDIF
  ELSE
   IF (textlen(temp->sticky_note_text) <= text_max)
    SET del_msg_id = 1
    SET msg_text_id = 0
   ELSE
    SET msg_text_id = temp->msg_text_id
   ENDIF
  ENDIF
 ENDIF
 UPDATE  FROM sticky_note sn
  SET sn.sticky_note_text = substring(1,text_max,temp->sticky_note_text), sn.updt_dt_tm =
   cnvtdatetime(curdate,curtime3), sn.updt_id = reqinfo->updt_id,
   sn.updt_task = reqinfo->updt_task, sn.updt_applctx = reqinfo->updt_applctx, sn.updt_cnt = (temp->
   updt_cnt+ 1),
   sn.sticky_note_type_cd = temp->sticky_note_type_cd, sn.parent_entity_name = temp->
   parent_entity_name, sn.parent_entity_id = temp->parent_entity_id,
   sn.sticky_note_text = temp->sticky_note_text, sn.sticky_note_status_cd = temp->
   sticky_note_status_cd, sn.public_ind = temp->public_ind,
   sn.beg_effective_dt_tm = cnvtdatetime(temp->beg_effective_dt_tm), sn.end_effective_dt_tm =
   cnvtdatetime(temp->end_effective_dt_tm), sn.long_text_id = msg_text_id
  WHERE (sn.sticky_note_id=request->sticky_note_id)
  WITH counter
 ;end update
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "sticky_note table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to update into table"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF ((request->sn_text_present_ind=1))
  IF (textlen(temp->sticky_note_text) > text_max)
   IF ((temp->msg_text_id=0))
    INSERT  FROM long_text lt
     SET lt.long_text_id = msg_text_id, lt.parent_entity_name = "STICKY_NOTE", lt.parent_entity_id =
      sticky_note_id,
      lt.long_text = temp->sticky_note_text, lt.active_ind = 1, lt.active_status_cd = reqdata->
      active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
      updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
      lt.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_sticky_note"
     SET failed = "T"
     GO TO exit_script
    ENDIF
   ELSE
    UPDATE  FROM long_text lt
     SET lt.parent_entity_name = "STICKY_NOTE", lt.parent_entity_id = sticky_note_id, lt.long_text =
      temp->sticky_note_text,
      lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      lt.active_status_prsnl_id = reqinfo->updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      lt.updt_id = reqinfo->updt_id,
      lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0, lt.updt_applctx = reqinfo->updt_applctx
     WHERE lt.long_text_id=msg_text_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_sticky_note"
     SET failed = "T"
     GO TO exit_script
    ENDIF
   ENDIF
  ELSE
   IF (del_msg_id=1)
    DELETE  FROM long_text lt
     WHERE (lt.long_text_id=temp->msg_text_id)
    ;end delete
   ENDIF
  ENDIF
 ENDIF
 COMMIT
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
 "Amendment", temp->parent_entity_id, " "
 SET script_version = "MOD 001 09/21/06 NC014668"
END GO

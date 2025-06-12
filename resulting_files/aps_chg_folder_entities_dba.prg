CREATE PROGRAM aps_chg_folder_entities:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 comment_qual[*]
     2 comment_id = f8
     2 comment = vc
 )
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET updt_cnt_err = 0
 SET entity_cnt = cnvtint(size(request->folder_entity_qual,5))
 SET stat = alterlist(temp->comment_qual,entity_cnt)
 SET x = 0
 SET del_long_text_id = 0.0
 SELECT INTO "nl:"
  afe.entity_id, afe.comment_id, afe.updt_cnt
  FROM ap_folder_entity afe,
   (dummyt d  WITH seq = value(entity_cnt))
  PLAN (d)
   JOIN (afe
   WHERE (afe.entity_id=request->folder_entity_qual[d.seq].entity_id)
    AND afe.entity_id != 0.0)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (afe.comment_id != 0.0)
    temp->comment_qual[d.seq].comment_id = afe.comment_id
   ENDIF
   IF ((afe.updt_cnt != request->folder_entity_qual[d.seq].updt_cnt))
    updt_cnt_err = 1
   ENDIF
  WITH nocounter, forupdate(afe)
 ;end select
 IF (((curqual=0) OR (cnt != entity_cnt)) )
  GO TO afe_sel_failed
 ENDIF
 IF (updt_cnt_err=1)
  GO TO afe_cnt_failed
 ENDIF
 SELECT INTO "nl:"
  lt.long_text_id
  FROM (dummyt d  WITH seq = value(cnt)),
   long_text lt
  PLAN (d)
   JOIN (lt
   WHERE (lt.long_text_id=temp->comment_qual[d.seq].comment_id)
    AND (temp->comment_qual[d.seq].comment_id != 0.0))
  DETAIL
   temp->comment_qual[d.seq].comment = lt.long_text
  WITH nocounter
 ;end select
 FOR (x = 1 TO entity_cnt)
   IF ((request->folder_entity_qual[x].comment="")
    AND (temp->comment_qual[x].comment_id != 0.0))
    SET del_long_text_id = temp->comment_qual[x].comment_id
    SET temp->comment_qual[x].comment_id = 0.0
   ELSEIF ((request->folder_entity_qual[x].comment != "")
    AND (temp->comment_qual[x].comment_id=0.0))
    SELECT INTO "nl:"
     seq_nbr = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      temp->comment_qual[x].comment_id = seq_nbr
     WITH format, counter
    ;end select
    IF (curqual=0)
     GO TO lt_seq_failed
    ENDIF
    INSERT  FROM long_text lt
     SET lt.long_text_id = temp->comment_qual[x].comment_id, lt.long_text = request->
      folder_entity_qual[x].comment, lt.parent_entity_name = "AP_FOLDER_ENTITY",
      lt.parent_entity_id = request->folder_entity_qual[x].entity_id, lt.active_ind = 1, lt
      .active_status_cd = reqdata->active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
      updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
      updt_applctx,
      lt.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual != 1)
     GO TO lt_ins_failed
    ENDIF
   ELSEIF ((request->folder_entity_qual[x].comment != temp->comment_qual[x].comment))
    UPDATE  FROM long_text lt
     SET lt.long_text = request->folder_entity_qual[x].comment, lt.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), lt.updt_id = reqinfo->updt_id,
      lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = (lt
      .updt_cnt+ 1)
     WHERE (lt.long_text_id=temp->comment_qual[x].comment_id)
      AND long_text_id != 0.0
     WITH nocounter
    ;end update
    IF (curqual != 1)
     GO TO lt_upd_failed
    ENDIF
   ENDIF
 ENDFOR
 UPDATE  FROM ap_folder_entity afe,
   (dummyt d  WITH seq = value(entity_cnt))
  SET afe.folder_id = request->folder_entity_qual[d.seq].folder_id, afe.display = request->
   folder_entity_qual[d.seq].display, afe.comment_id = temp->comment_qual[d.seq].comment_id,
   afe.updt_dt_tm = cnvtdatetime(curdate,curtime3), afe.updt_id = reqinfo->updt_id, afe.updt_task =
   reqinfo->updt_task,
   afe.updt_applctx = reqinfo->updt_applctx, afe.updt_cnt = (afe.updt_cnt+ 1)
  PLAN (d)
   JOIN (afe
   WHERE (afe.entity_id=request->folder_entity_qual[d.seq].entity_id)
    AND afe.entity_id != 0.0)
  WITH nocounter
 ;end update
 IF (curqual != entity_cnt)
  GO TO afe_upd_failed
 ENDIF
 IF (del_long_text_id != 0.0)
  DELETE  FROM long_text lt
   WHERE lt.long_text_id=del_long_text_id
   WITH nocounter
  ;end delete
  IF (curqual != 1)
   GO TO lt_del_failed
  ENDIF
 ENDIF
 GO TO exit_script
#lt_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "NEXTVAL"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "SEQ"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_DATA_SEQ"
 SET failed = "T"
 GO TO exit_script
#lt_ins_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#lt_upd_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#lt_del_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#afe_upd_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER_ENTITY"
 SET failed = "T"
 GO TO exit_script
#afe_sel_failed
 SET reply->status_data.subeventstatus[1].operationname = "SELECT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER_ENTITY"
 SET failed = "T"
 GO TO exit_script
#afe_cnt_failed
 SET reply->status_data.subeventstatus[1].operationname = "VERIFYCHG"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER_ENTITY"
 SET failed = "T"
 GO TO exit_script
#exit_script
 SET stat = alterlist(temp->comment_qual,0)
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO

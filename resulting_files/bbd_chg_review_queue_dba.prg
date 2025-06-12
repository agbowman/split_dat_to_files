CREATE PROGRAM bbd_chg_review_queue:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE new_long_text_id = f8 WITH protect, noconstant(0.0)
 SET new_updt_cnt = 0
 SET cur_updt_cnt = 0
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET new_long_text_id = request->review_doc_id
 SELECT INTO "nl:"
  bb.*
  FROM bb_review_queue bb
  WHERE (bb.bb_review_queue_id=request->bb_review_queue_id)
   AND (bb.updt_cnt=request->updt_cnt)
  WITH nocounter, forupdate(bb)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "Lock"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bb_review_queue"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "bb_review_queue table"
  GO TO exit_script
 ENDIF
 IF ((request->change_text=1))
  IF ((request->review_doc_id != 0))
   SELECT INTO "nl:"
    lg.*
    FROM long_text lg
    WHERE (lg.long_text_id=request->review_doc_id)
    WITH nocounter, forupdate(lg)
   ;end select
  ENDIF
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].operationname = "Lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "long_text table"
   GO TO exit_script
  ENDIF
  IF ((request->review_doc_id != 0))
   UPDATE  FROM long_text lg
    SET lg.updt_cnt = (lg.updt_cnt+ 1), lg.updt_dt_tm = cnvtdatetime(curdate,curtime3), lg.updt_id =
     reqinfo->updt_id,
     lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx, lg.long_text =
     request->long_text
    WHERE (lg.long_text_id=request->review_doc_id)
    WITH nocounter
   ;end update
  ELSE
   SELECT INTO "nl:"
    seqn = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     new_long_text_id = seqn
    WITH format, nocounter
   ;end select
   INSERT  FROM long_text lg
    SET lg.long_text = request->long_text, lg.long_text_id = new_long_text_id, lg.updt_cnt = 0,
     lg.updt_dt_tm = cnvtdatetime(curdate,curtime3), lg.updt_id = reqinfo->updt_id, lg.updt_task =
     reqinfo->updt_task,
     lg.updt_applctx = reqinfo->updt_applctx, lg.active_ind = 1, lg.active_status_cd = reqdata->
     active_status_cd,
     lg.active_status_prsnl_id = reqinfo->updt_id, lg.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), lg.parent_entity_name = "BB_REVIEW_QUEUE",
     lg.parent_entity_id = request->bb_review_queue_id
    WITH nocounter
   ;end insert
  ENDIF
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].operationname = "Add"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "long_text table"
   GO TO exit_script
  ENDIF
 ENDIF
 UPDATE  FROM bb_review_queue bb
  SET bb.updt_dt_tm = cnvtdatetime(curdate,curtime3), bb.updt_id = reqinfo->updt_id, bb.updt_task =
   reqinfo->updt_task,
   bb.updt_applctx = reqinfo->updt_applctx, bb.updt_cnt = (bb.updt_cnt+ 1), bb.review_dt_tm =
   cnvtdatetime(request->review_dt_tm),
   bb.review_outcome_cd = request->review_outcome_cd, bb.review_prsnl_id = request->review_prsnl_id,
   bb.review_doc_id = new_long_text_id
  WHERE (bb.bb_review_queue_id=request->bb_review_queue_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "Update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bb_review_queue"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "bb_review_queue table"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO

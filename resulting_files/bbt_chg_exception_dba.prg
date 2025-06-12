CREATE PROGRAM bbt_chg_exception:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE new_long_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_updt_cnt = i4 WITH protect, noconstant(0)
 DECLARE cur_updt_cnt = i4 WITH protect, noconstant(0)
 DECLARE failed = c1 WITH protect, noconstant("F")
 SET new_long_text_id = request->review_doc_id
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  bb.*
  FROM bb_exception bb
  WHERE (bb.exception_id=request->exception_id)
   AND (bb.updt_cnt=request->updt_cnt)
  WITH nocounter, forupdate(bb)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "Lock"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bb_exception"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "bb_exception table"
  GO TO exit_script
 ENDIF
 IF ((request->change_long_text=1))
  IF ((request->review_doc_id != 0))
   SELECT INTO "nl:"
    lg.*
    FROM long_text lg
    WHERE (lg.long_text_id=request->review_doc_id)
    WITH nocounter, forupdate(lg)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].operationname = "Lock"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "long_text table"
    GO TO exit_script
   ENDIF
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
      curtime3), lg.parent_entity_name = "BB_EXCEPTION",
     lg.parent_entity_id = request->exception_id
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
 UPDATE  FROM bb_exception bb
  SET bb.updt_dt_tm = cnvtdatetime(curdate,curtime3), bb.updt_id = reqinfo->updt_id, bb.updt_task =
   reqinfo->updt_task,
   bb.updt_applctx = reqinfo->updt_applctx, bb.updt_cnt = (bb.updt_cnt+ 1), bb.review_dt_tm =
   cnvtdatetime(request->review_dt_tm),
   bb.review_status_cd = request->review_status_cd, bb.review_by_prsnl_id = request->
   review_by_prsnl_id, bb.review_doc_id = new_long_text_id
  WHERE (bb.exception_id=request->exception_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "Update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bb_exception"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "bb_exception table"
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

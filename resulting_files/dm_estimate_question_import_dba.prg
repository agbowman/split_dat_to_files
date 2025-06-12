CREATE PROGRAM dm_estimate_question_import:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->status_data.status = "f"
 SET question_number = cnvtint(requestin->list_0[1].question_number)
 SET description = requestin->list_0[1].description
 SET question_type = cnvtint(requestin->list_0[1].question_type)
 UPDATE  FROM dm_question dq
  SET dq.description = description, dq.question_type = question_type, dq.updt_applctx = reqinfo->
   updt_applctx,
   dq.updt_dt_tm = cnvtdatetime(curdate,curtime3), dq.updt_cnt = (dq.updt_cnt+ 1), dq.updt_id =
   reqinfo->updt_id,
   dq.updt_task = reqinfo->updt_task
  WHERE dq.question_number=question_number
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM dm_question dq
   SET dq.description = description, dq.question_type = question_type, dq.question_number =
    question_number,
    dq.updt_applctx = reqinfo->updt_applctx, dq.updt_dt_tm = cnvtdatetime(curdate,curtime3), dq
    .updt_cnt = 0,
    dq.updt_id = reqinfo->updt_id, dq.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
 ENDIF
 IF (curqual=1)
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
END GO

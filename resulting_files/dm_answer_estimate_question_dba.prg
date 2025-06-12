CREATE PROGRAM dm_answer_estimate_question:dba
 UPDATE  FROM dm_env_question dq
  SET dq.environment_id = request->environment_id, dq.question_answer = request->question_answer, dq
   .updt_applctx = 0,
   dq.updt_dt_tm = cnvtdatetime(curdate,curtime3), dq.updt_cnt = (dq.updt_cnt+ 1), dq.updt_id = 0,
   dq.updt_task = 0
  WHERE (dq.question_number=request->question_number)
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM dm_env_question dq
   SET dq.question_number = request->question_number, dq.environment_id = request->environment_id, dq
    .question_answer = request->question_answer,
    dq.updt_applctx = 0, dq.updt_dt_tm = cnvtdatetime(curdate,curtime3), dq.updt_cnt = 0,
    dq.updt_id = 0, dq.updt_task = 0
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
END GO

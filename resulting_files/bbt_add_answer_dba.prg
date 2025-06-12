CREATE PROGRAM bbt_add_answer:dba
 RECORD reply(
   1 qual[1]
     2 process_cd = f8
     2 answer_qual[1]
       3 question_cd = f8
       3 answer_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE new_answer_id = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET status_count = 0
 SET cur_updt_cnt = 0
 SET number_of_process = cnvtint(size(request->qual,5))
 SET number_of_answers = cnvtint(size(request->qual.answer_qual,5))
 SET sequence_cntr = 0
 SET failed = "F"
 SET partial_update = "F"
 SET count1 = 0
 SET count2 = 0
 FOR (x = 1 TO number_of_process)
   SET count2 = 0
   SET count1 = (count1+ 1)
   FOR (y = 1 TO number_of_answers)
     IF ((request->qual[x].answer_qual[y].answer_id > 0))
      SELECT INTO "nl:"
       a.*
       FROM answer a
       WHERE (a.module_cd=request->module_cd)
        AND (a.process_cd=request->qual[x].process_cd)
        AND (a.question_cd=request->qual[x].answer_qual[y].question_cd)
        AND (a.answer_id=request->qual[x].answer_qual[y].answer_id)
        AND a.active_ind=1
       DETAIL
        cur_updt_cnt = a.updt_cnt, sequence_cntr = a.sequence
       WITH nocounter, forupdate(a)
      ;end select
      IF (curqual > 0)
       IF ((request->qual[x].answer_qual[y].updt_cnt != cur_updt_cnt))
        SET failed = "T"
        SET reply->status_data.status = "C"
        SET status_count = (status_count+ 1)
        IF (status_count > 1)
         SET stat = alter(reply->status_data.subeventstatus,(status_count+ 1))
        ENDIF
        SET reply->status_data.subeventstatus[status_count].operationname = "ADD"
        SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
        SET reply->status_data.subeventstatus[status_count].targetobjectname = "Answer"
        SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
        "Unable to update to answer table due to updt_cnt"
       ELSE
        UPDATE  FROM answer a
         SET a.active_ind = 0, a.inactive_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_dt_tm =
          cnvtdatetime(curdate,curtime3),
          a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
          updt_applctx,
          a.updt_cnt = (a.updt_cnt+ 1)
         WHERE (a.module_cd=request->module_cd)
          AND (a.process_cd=request->qual[x].process_cd)
          AND (a.question_cd=request->qual[x].answer_qual[y].question_cd)
          AND (a.answer_id=request->qual[x].answer_qual[y].answer_id)
          AND a.active_ind=1
         WITH nocounter
        ;end update
        IF (curqual=0)
         SET failed = "T"
         SET status_count = (status_count+ 1)
         IF (status_count > 1)
          SET stat = alter(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "ADD"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "Answer"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
         "Unable to update previous answer"
        ELSE
         SET partial_update = "T"
         INSERT  FROM answer a
          SET a.module_cd = request->module_cd, a.process_cd = request->qual[x].process_cd, a
           .question_cd = request->qual[x].answer_qual[y].question_cd,
           a.answer_id = request->qual[x].answer_qual[y].answer_id, a.sequence = (sequence_cntr+ 1),
           a.answer = request->qual[x].answer_qual[y].answer,
           a.active_ind = request->qual[x].answer_qual[y].active_ind, a.active_dt_tm = cnvtdatetime(
            curdate,curtime3), a.inactive_dt_tm = null,
           a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id, a.updt_task
            = reqinfo->updt_task,
           a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = 0
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alter(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "ADD"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Answer"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to add changed answer to answer table"
         ELSE
          IF (count1 > 1)
           SET stat = alter(reply->qual,(count1+ 1))
          ENDIF
          SET count2 = (count2+ 1)
          IF (count2 > 1)
           SET stat = alter(reply->qual.answer_qual,(count2+ 1))
          ENDIF
          SET reply->qual[count1].process_cd = request->qual[x].process_cd
          SET reply->qual[count1].answer_qual[count2].question_cd = request->qual[x].answer_qual[y].
          question_cd
          SET reply->qual[count1].answer_qual[count2].answer_id = request->qual[x].answer_qual[y].
          answer_id
         ENDIF
        ENDIF
       ENDIF
      ELSE
       SET failed = "T"
       SET status_count = (status_count+ 1)
       IF (status_count > 1)
        SET stat = alter(reply->status_data.subeventstatus,(status_count+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[status_count].operationname = "ADD"
       SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
       SET reply->status_data.subeventstatus[status_count].targetobjectname = "Answer"
       SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
       "Previous answer does not exist"
      ENDIF
     ELSE
      IF ((request->qual[x].answer_qual[y].question_cd > 0))
       SELECT INTO "nl:"
        nextseqnum = seq(pathnet_seq,nextval)
        FROM dual
        DETAIL
         new_answer_id = nextseqnum
        WITH format, nocounter
       ;end select
       IF (curqual=0)
        SET failed = "T"
        SET status_count = (status_count+ 1)
        IF (status_count > 1)
         SET stat = alter(reply->status_data.subeventstatus,(status_count+ 1))
        ENDIF
        SET reply->status_data.subeventstatus[status_count].operationname = "ADD"
        SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
        SET reply->status_data.subeventstatus[status_count].targetobjectname = "Answer"
        SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
        "Unable to get seq number"
       ELSE
        INSERT  FROM answer a
         SET a.module_cd = request->module_cd, a.process_cd = request->qual[x].process_cd, a
          .question_cd = request->qual[x].answer_qual[y].question_cd,
          a.answer_id = new_answer_id, a.sequence = 1, a.answer = request->qual[x].answer_qual[y].
          answer,
          a.active_ind = request->qual[x].answer_qual[y].active_ind, a.active_dt_tm = cnvtdatetime(
           curdate,curtime3), a.inactive_dt_tm = null,
          a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id, a.updt_task =
          reqinfo->updt_task,
          a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = 0
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET failed = "T"
         SET status_count = (status_count+ 1)
         IF (status_count > 1)
          SET stat = alter(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "ADD"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "Answer"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
         "Unable to add new record to answer table"
        ELSE
         SET partial_update = "T"
         IF (count1 > 1)
          SET stat = alter(reply->qual,(count1+ 1))
         ENDIF
         SET count2 = (count2+ 1)
         IF (count2 > 1)
          SET stat = alter(reply->qual.answer_qual,(count2+ 1))
         ENDIF
         SET reply->qual[count1].process_cd = request->qual[x].process_cd
         SET reply->qual[count1].answer_qual[count2].question_cd = request->qual[x].answer_qual[y].
         question_cd
         SET reply->qual[count1].answer_qual[count2].answer_id = new_answer_id
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
#exit_script
 IF (failed="T"
  AND partial_update="F")
  SET reqinfo->commit_ind = 0
 ELSEIF (failed="T"
  AND partial_update="T")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "P"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO

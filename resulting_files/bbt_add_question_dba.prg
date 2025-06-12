CREATE PROGRAM bbt_add_question:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET module_cd = 0.0
 SET process_cd = 0.0
 SET question_cd = 0.0
 SET response_cd = 0.0
 SET failed = "F"
 SET partial_update = "F"
 SET count1 = 0
 SET number_of_process = cnvtint(size(request->process_qual,5))
 SET number_of_question = 0
 SET number_of_response = 0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=1660
   AND (c.cdf_meaning=request->module_meaning)
  DETAIL
   module_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curqual > 0)
  FOR (x = 1 TO number_of_process)
   SELECT INTO "nl:"
    c.code_value
    FROM code_value c
    WHERE c.code_set=1662
     AND (c.cdf_meaning=request->process_qual[x].process_meaning)
    DETAIL
     process_cd = c.code_value
    WITH nocounter
   ;end select
   IF (curqual > 0
    AND process_cd > 0)
    SET number_of_question = request->process_qual[x].nbr_of_question
    FOR (y = 1 TO number_of_question)
     SELECT INTO "nl:"
      q.code_value
      FROM code_value q
      WHERE q.code_set=1661
       AND (q.cdf_meaning=request->process_qual[x].question_qual[y].question_meaning)
      DETAIL
       question_cd = cnvtint(q.code_value)
      WITH nocounter
     ;end select
     IF (curqual > 0)
      INSERT  FROM question q
       SET q.module_cd = module_cd, q.process_cd = process_cd, q.question_cd = question_cd,
        q.question = request->process_qual[x].question_qual[y].question, q.sequence = request->
        process_qual[x].question_qual[y].sequence, q.response_flag = request->process_qual[x].
        question_qual[y].response_flg,
        q.response_length = request->process_qual[x].question_qual[y].response_length, q.code_set =
        request->process_qual[x].question_qual[y].code_set, q.active_ind = request->process_qual[x].
        question_qual[y].active_ind,
        q.def_answer = request->process_qual[x].question_qual[y].def_answer, q.dwb_ind = request->
        process_qual[x].question_qual[y].dwb_ind, q.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        q.updt_id = reqinfo->updt_id, q.updt_task = reqinfo->updt_task, q.updt_applctx = reqinfo->
        updt_applctx,
        q.updt_cnt = 0
       WITH nocounter
      ;end insert
      IF (curqual > 0)
       SET partial_update = "T"
       SET number_of_response = request->process_qual[x].question_qual[y].nbr_of_response
       IF (number_of_response > 0)
        FOR (z = 1 TO number_of_response)
         SELECT INTO "nl:"
          r.code_value
          FROM code_value r
          WHERE r.code_set=1659
           AND (r.cdf_meaning=request->process_qual[x].question_qual[y].valid_response_qual[z].
          response_meaning)
          DETAIL
           response_cd = cnvtint(r.code_value)
          WITH nocounter
         ;end select
         IF (curqual > 0)
          INSERT  FROM valid_response r
           SET r.module_cd = module_cd, r.process_cd = process_cd, r.question_cd = question_cd,
            r.response_cd = response_cd, r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_id =
            reqinfo->updt_id,
            r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = 0
           WITH nocounter
          ;end insert
          IF (curqual=0)
           SET failed = "T"
           SET count1 = (count1+ 1)
           IF (count1 > 1)
            SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[count1].operationname = "ADD"
           SET reply->status_data.subeventstatus[count1].operationstatus = "F"
           SET reply->status_data.subeventstatus[count1].targetobjectname = "Response"
           SET reply->status_data.subeventstatus[count1].targetobjectvalue =
           "Valid response not added"
          ENDIF
         ELSE
          SET failed = "T"
          SET count1 = (count1+ 1)
          IF (count1 > 1)
           SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[count1].operationname = "ADD"
          SET reply->status_data.subeventstatus[count1].operationstatus = "F"
          SET reply->status_data.subeventstatus[count1].targetobjectname = "Response"
          SET reply->status_data.subeventstatus[count1].targetobjectvalue =
          "Response code not retrieved"
         ENDIF
        ENDFOR
       ENDIF
      ELSE
       SET failed = "T"
       SET count1 = (count1+ 1)
       IF (count1 > 1)
        SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[count1].operationname = "ADD"
       SET reply->status_data.subeventstatus[count1].operationstatus = "F"
       SET reply->status_data.subeventstatus[count1].targetobjectname = "Question"
       SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Question not added"
      ENDIF
     ELSE
      SET failed = "T"
      SET count1 = (count1+ 1)
      IF (count1 > 1)
       SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[count1].operationname = "ADD"
      SET reply->status_data.subeventstatus[count1].operationstatus = "F"
      SET reply->status_data.subeventstatus[count1].targetobjectname = "Question"
      SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Question code not retrieved"
     ENDIF
    ENDFOR
   ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (failed="T"
  AND partial_update="F")
  SET reqinfo->commit_ind = 0
  ROLLBACK
 ELSEIF (failed="T"
  AND partial_update="T")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "P"
  COMMIT
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO

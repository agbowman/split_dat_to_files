CREATE PROGRAM bbt_add_dependency:dba
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
 SET count1 = 0
 SET failed = "F"
 SET partial_update = "F"
 SET number_of_process = cnvtint(size(input->process_qual,5))
 SET module_cd = 0.0
 SELECT INTO "nl:"
  m.code_value
  FROM code_value m
  WHERE m.code_set=1660
   AND (m.cdf_meaning=input->module_meaning)
  DETAIL
   module_cd = cnvtreal(m.code_value)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "ADD"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "Module"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "Unable to retrieve module to add to question table"
  GO TO exit_script
 ELSE
  FOR (x = 1 TO number_of_process)
    SET process_cd = 0.0
    SELECT INTO "nl:"
     p.code_value
     FROM code_value p
     WHERE p.code_set=1662
      AND (p.cdf_meaning=input->process_qual[x].process_meaning)
     DETAIL
      process_cd = cnvtreal(p.code_value)
     WITH nocounter
    ;end select
    IF (curqual=0
     AND (input->process_qual[x].process_meaning > " "))
     SET failed = "T"
     SET count1 = (count1+ 1)
     IF (count1 > 1)
      SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[count1].operationname = "ADD"
     SET reply->status_data.subeventstatus[count1].operationstatus = "F"
     SET reply->status_data.subeventstatus[count1].targetobjectname = "Process"
     SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Process code not retrieved"
    ENDIF
    SET number_of_question = input->process_qual[x].nbr_of_question
    FOR (y = 1 TO number_of_question)
      SET question_cd = 0.0
      SELECT INTO "nl:"
       p.code_value
       FROM code_value p
       WHERE p.code_set=1661
        AND (p.cdf_meaning=input->process_qual[x].question_qual[y].question_meaning)
       DETAIL
        question_cd = cnvtreal(p.code_value)
       WITH nocounter
      ;end select
      IF (curqual=0
       AND (input->process_qual[x].question_qual[y].question_meaning > " "))
       SET failed = "T"
       SET count1 = (count1+ 1)
       IF (count1 > 1)
        SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[count1].operationname = "ADD"
       SET reply->status_data.subeventstatus[count1].operationstatus = "F"
       SET reply->status_data.subeventstatus[count1].targetobjectname = "Process"
       SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Process code not retrieved"
      ENDIF
      INSERT  FROM question_dependency q
       SET q.question_cd = question_cd, q.updt_dt_tm = cnvtdatetime(curdate,curtime3), q.updt_id =
        reqinfo->updt_id,
        q.updt_task = reqinfo->updt_task, q.updt_applctx = reqinfo->updt_applctx, q.updt_cnt = 0
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
       SET reply->status_data.subeventstatus[count1].targetobjectname = "Module"
       SET reply->status_data.subeventstatus[count1].targetobjectvalue =
       "Unable to add to question dependency table"
      ENDIF
      SET number_of_dependents = input->process_qual[x].question_qual[y].nbr_of_dependency
      FOR (z = 1 TO number_of_dependents)
        SET depend_question_cd = 0.0
        SELECT INTO "nl:"
         p.code_value
         FROM code_value p
         WHERE p.code_set=1661
          AND (p.cdf_meaning=input->process_qual[x].question_qual[y].dependency_qual[z].
         dependent_question_mean)
         DETAIL
          depend_question_cd = cnvtreal(p.code_value)
         WITH nocounter
        ;end select
        IF (curqual=0
         AND depend_question_cd > 0)
         SET failed = "T"
         SET count1 = (count1+ 1)
         IF (count1 > 1)
          SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[count1].operationname = "ADD"
         SET reply->status_data.subeventstatus[count1].operationstatus = "F"
         SET reply->status_data.subeventstatus[count1].targetobjectname = "Process"
         SET reply->status_data.subeventstatus[count1].targetobjectvalue =
         "Process code not retrieved"
        ENDIF
        SET response_cd = 0.0
        SELECT INTO "nl:"
         p.code_value
         FROM code_value p
         WHERE p.code_set=1659
          AND (p.cdf_meaning=input->process_qual[x].question_qual[y].dependency_qual[z].
         response_meaning)
         DETAIL
          response_cd = cnvtreal(p.code_value)
         WITH nocounter
        ;end select
        IF (curqual=0
         AND response_cd > 0)
         SET failed = "T"
         SET count1 = (count1+ 1)
         IF (count1 > 1)
          SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[count1].operationname = "ADD"
         SET reply->status_data.subeventstatus[count1].operationstatus = "F"
         SET reply->status_data.subeventstatus[count1].targetobjectname = "Valid Response"
         SET reply->status_data.subeventstatus[count1].targetobjectvalue =
         "Response code not retrieved"
        ENDIF
        IF (curqual > 0
         AND depend_question_cd > 0)
         SET partial_update = "T"
         INSERT  FROM dependency d
          SET d.module_cd = module_cd, d.process_cd = process_cd, d.question_cd = question_cd,
           d.response_cd = response_cd, d.depend_quest_cd = depend_question_cd, d.updt_dt_tm =
           cnvtdatetime(curdate,curtime3),
           d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
           updt_applctx,
           d.updt_cnt = 0
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
          SET reply->status_data.subeventstatus[count1].targetobjectname = "Dependency"
          SET reply->status_data.subeventstatus[count1].targetobjectvalue =
          "Unable to add to dependency table"
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
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

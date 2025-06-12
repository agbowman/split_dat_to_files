CREATE PROGRAM bbd_imp_question:dba
 RECORD status_data(
   1 active_ind = i2
   1 active_dt_tm = dq8
   1 inactive_dt_tm = dq8
 )
 DECLARE max_list = i4 WITH protect, noconstant(size(requestin->list_0,5))
 DECLARE x = i4 WITH protect, noconstant(1)
 DECLARE cdf_meaning = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE code_set = i4 WITH protect, noconstant(0)
 DECLARE code_value = f8 WITH protect, noconstant(0.0)
 DECLARE sub_answer_id = f8 WITH protect, noconstant(0.0)
 DECLARE sub_answer = vc WITH protect, noconstant(fillstring(22," "))
#start_loop
 IF (x > max_list)
  GO TO exit_script
 ENDIF
 FOR (x = x TO size(requestin->list_0,5))
   SET cdf_meaning = fillstring(12," ")
   SET code_set = 0
   SET code_value = 0.0
   SET sub_answer_id = 0.0
   SET code_set = 1660
   SET cdf_meaning = substring(1,12,requestin->list_0[x].module_mean)
   EXECUTE cpm_get_cd_for_cdf
   IF (code_value > 0)
    SET requestin->list_0[x].module_cd = cnvtstring(code_value)
   ELSE
    GO TO next_item
   ENDIF
   SET code_set = 1662
   SET cdf_meaning = requestin->list_0[x].process_mean
   EXECUTE cpm_get_cd_for_cdf
   IF (code_value > 0)
    SET requestin->list_0[x].process_cd = cnvtstring(code_value)
   ELSE
    GO TO next_item
   ENDIF
   SET code_set = 1661
   SET cdf_meaning = requestin->list_0[x].ques_mean
   EXECUTE cpm_get_cd_for_cdf
   IF (code_value > 0)
    SET requestin->list_0[x].question_cd = cnvtstring(code_value)
   ELSE
    GO TO next_item
   ENDIF
   FOR (b = 1 TO cnvtint(requestin->list_0[x].nbr_of_resp))
     SET code_set = 1659
     SET cdf_meaning = requestin->list_0[x].list_1[b].resp
     EXECUTE cpm_get_cd_for_cdf
     IF (code_value > 0)
      SET requestin->list_0[x].list_1[b].resp_cd = cnvtstring(code_value)
     ELSE
      GO TO next_item
     ENDIF
   ENDFOR
   SET code_set = 1659
   SET code_value = 0.0
   SET cdf_meaning = requestin->list_0[x].def_answer
   EXECUTE cpm_get_cd_for_cdf
   SET sub_answer = cnvtstring(code_value)
   SELECT INTO "NL:"
    q.question_cd
    FROM question q
    WHERE q.question_cd=cnvtreal(requestin->list_0[x].question_cd)
     AND q.process_cd=cnvtreal(requestin->list_0[x].process_cd)
     AND q.module_cd=cnvtreal(requestin->list_0[x].module_cd)
     AND q.active_ind=1
    DETAIL
     status_data->active_ind = q.active_ind
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM question q
     SET q.module_cd = cnvtreal(requestin->list_0[x].module_cd), q.process_cd = cnvtreal(requestin->
       list_0[x].process_cd), q.question_cd = cnvtreal(requestin->list_0[x].question_cd),
      q.question = requestin->list_0[x].ques_text, q.sequence = cnvtint(requestin->list_0[x].resp_seq
       ), q.response_flag = cnvtint(requestin->list_0[x].resp_flag),
      q.response_length = cnvtint(requestin->list_0[x].resp_length), q.code_set = cnvtint(requestin->
       list_0[x].resp_codeset), q.cdf_meaning = requestin->list_0[x].resp_meaning,
      q.def_answer = requestin->list_0[x].def_answer, q.active_ind = cnvtint(requestin->list_0[x].
       active_ind), q.dwb_ind = cnvtint(requestin->list_0[x].dwb_ind),
      q.updt_id = 1, q.updt_task = 1, q.updt_applctx = 1,
      q.updt_cnt = 0, q.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO next_item
    ENDIF
    INSERT  FROM valid_response r,
      (dummyt d2  WITH seq = value(cnvtint(requestin->list_0[x].nbr_of_resp)))
     SET r.module_cd = cnvtreal(requestin->list_0[x].module_cd), r.question_cd = cnvtreal(requestin->
       list_0[x].question_cd), r.process_cd = cnvtreal(requestin->list_0[x].process_cd),
      r.response_cd = cnvtreal(requestin->list_0[x].list_1[d2.seq].resp_cd), r.updt_id = 1, r
      .updt_task = 1,
      r.updt_applctx = 1, r.updt_cnt = 0, r.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (d2)
      JOIN (r
      WHERE cnvtint(requestin->list_0[x].list_1[d2.seq].resp_cd) > 0.00)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO next_item
    ENDIF
   ELSE
    UPDATE  FROM question q
     SET q.module_cd = cnvtreal(requestin->list_0[x].module_cd), q.process_cd = cnvtreal(requestin->
       list_0[x].process_cd), q.question_cd = cnvtreal(requestin->list_0[x].question_cd),
      q.question = requestin->list_0[x].ques_text, q.sequence = cnvtint(requestin->list_0[x].resp_seq
       ), q.response_flag = cnvtint(requestin->list_0[x].resp_flag),
      q.response_length = cnvtint(requestin->list_0[x].resp_length), q.code_set = cnvtint(requestin->
       list_0[x].resp_codeset), q.cdf_meaning = requestin->list_0[x].resp_meaning,
      q.active_ind = cnvtint(requestin->list_0[x].active_ind), q.def_answer = requestin->list_0[x].
      def_answer, q.dwb_ind = cnvtint(requestin->list_0[x].dwb_ind),
      q.updt_id = 1, q.updt_task = 1, q.updt_applctx = 1,
      q.updt_cnt = (q.updt_cnt+ 1), q.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE cnvtreal(requestin->list_0[x].question_cd)=q.question_cd
      AND cnvtreal(requestin->list_0[x].process_cd)=q.process_cd
      AND cnvtreal(requestin->list_0[x].module_cd)=q.module_cd
     WITH nocounter
    ;end update
    IF (curqual=0)
     GO TO next_item
    ENDIF
    FOR (a = 1 TO size(requestin->list_0[x].list_1,5))
     SELECT INTO "NL:"
      r.response_cd
      FROM valid_response r
      WHERE cnvtreal(requestin->list_0[x].module_cd)=r.module_cd
       AND cnvtreal(requestin->list_0[x].process_cd)=r.process_cd
       AND cnvtreal(requestin->list_0[x].question_cd)=r.question_cd
       AND cnvtreal(requestin->list_0[x].list_1[a].resp_cd)=r.response_cd
       AND cnvtreal(requestin->list_0[x].list_1[a].resp_cd) > 0.00
      WITH nocounter
     ;end select
     IF (curqual=0)
      IF (cnvtreal(requestin->list_0[x].list_1[a].resp_cd) > 0)
       INSERT  FROM valid_response r
        SET r.module_cd = cnvtreal(requestin->list_0[x].module_cd), r.question_cd = cnvtreal(
          requestin->list_0[x].question_cd), r.process_cd = cnvtreal(requestin->list_0[x].process_cd),
         r.response_cd = cnvtreal(requestin->list_0[x].list_1[a].resp_cd), r.updt_id = 1, r.updt_task
          = 1,
         r.updt_applctx = 1, r.updt_cnt = 0, r.updt_dt_tm = cnvtdatetime(curdate,curtime3)
        WITH nocounter
       ;end insert
       IF (curqual=0)
        GO TO next_item
       ENDIF
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   SELECT INTO "NL:"
    ans.question_cd, ans.*
    FROM answer ans
    WHERE cnvtreal(requestin->list_0[x].question_cd)=ans.question_cd
     AND cnvtreal(requestin->list_0[x].process_cd)=ans.process_cd
     AND cnvtreal(requestin->list_0[x].module_cd)=ans.module_cd
     AND ans.active_ind=1
    ORDER BY ans.answer_id
    DETAIL
     status_data->active_ind = ans.active_ind, status_data->inactive_dt_tm = ans.inactive_dt_tm,
     status_data->active_dt_tm = ans.active_dt_tm
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sub_answer = fillstring(50," ")
    SET sub_answer_id = 0.0
    SET code_set = 1659
    SET code_value = 0.0
    SET cdf_meaning = requestin->list_0[x].def_answer
    EXECUTE cpm_get_cd_for_cdf
    IF (code_value > 0.00)
     SET sub_answer = cnvtstring(code_value)
     SELECT INTO "NL:"
      nextseqnum = seq(pathnet_seq,nextval)
      FROM dual
      DETAIL
       sub_answer_id = nextseqnum
      WITH format
     ;end select
     IF (sub_answer_id=0)
      GO TO next_item
     ENDIF
     INSERT  FROM answer a
      SET a.module_cd = cnvtreal(requestin->list_0[x].module_cd), a.process_cd = cnvtreal(requestin->
        list_0[x].process_cd), a.question_cd = cnvtreal(requestin->list_0[x].question_cd),
       a.answer_id = sub_answer_id, a.sequence = 1, a.answer = sub_answer,
       a.active_ind = cnvtint(requestin->list_0[x].active_ind), a.active_dt_tm =
       IF ((requestin->list_0[x].active_ind="1")) cnvtdatetime(curdate,curtime3)
       ELSE null
       ENDIF
       , a.inactive_dt_tm =
       IF ((requestin->list_0[x].active_ind="0")) cnvtdatetime(curdate,curtime3)
       ELSE null
       ENDIF
       ,
       a.updt_id = 1, a.updt_task = 1, a.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       a.updt_applctx = 1, a.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      GO TO next_item
     ENDIF
    ENDIF
   ENDIF
   COMMIT
 ENDFOR
 GO TO exit_script
#next_item
 ROLLBACK
 SET x = (x+ 1)
 GO TO start_loop
#exit_script
END GO

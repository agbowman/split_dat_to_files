CREATE PROGRAM dm_cb_questions_load:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Starting Readme..."
 DECLARE ques_check_cnt = i4
 DECLARE first_ind = i2
 DECLARE errmsg = c132
 DECLARE dim_cnt = i4
 DECLARE after_cnt = i4
 DECLARE dcd_cnt = i4
 DECLARE dm_hist_insert(type_in,value_in_old,value_in_new,column_in,ques_num_in,
  reason_in,ques_his_tab) = null WITH public
 DECLARE ques_ndx = i4
 DECLARE ques_cnt = i4
 DECLARE found_ques = i2
 DECLARE ques_reason = c132
 DECLARE upd_diff = i2
 DECLARE exe_ind = i2
 DECLARE answer_nbr_hold = i2
 DECLARE ans_cnt = i4
 DECLARE dgts_perform_check = i2
 SET dgts_perform_check = 0
 SET dgts_perform_check = checkdic("DM_CB_OBJECTS","T",0)
 IF (dgts_perform_check=0)
  SET readme_data->status = "S"
  SET readme_data->message = "DM_CB_OBJECTS definition does not exist."
  GO TO exit_script
 ELSEIF (dgts_perform_check=2)
  SELECT INTO "nl:"
   FROM user_tab_columns u
   WHERE u.table_name="DM_CB_OBJECTS"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET readme_data->status = "S"
   SET readme_data->message = "DM_CB_OBJECTS table does not exist."
   GO TO exit_script
  ENDIF
 ENDIF
 SET ans_cnt = 0
 SET answer_nbr_hold = 0
 SET exe_ind = 0
 SET ques_cnt = 0
 SET first_ind = 1
 FREE RECORD rs_questions
 RECORD rs_questions(
   1 list_old[*]
     2 ques_num[1]
       3 question_nbr = i4
     2 ques[1]
       3 question = vc
     2 ask[1]
       3 ask_flag = i4
       3 skipped = i2
     2 upd_appl[1]
       3 updt_applctx = i4
     2 ques_ord[1]
       3 question_order_seq = i4
     2 active[1]
       3 answer_upd = i2
       3 active_ind = i2
   1 list_new[*]
     2 question_nbr = i4
     2 question = vc
     2 ask_flag = i4
     2 question_order_seq = i4
     2 active_ind = i2
 )
 FREE RECORD ans_stat
 RECORD ans_stat(
   1 ans[*]
     2 status = vc
     2 ans_num = i4
 )
 SUBROUTINE dm_hist_insert(type_in,value_in_old,value_in_new,column_in,ques_num_in,reason_in,
  ques_his_tab)
   CASE (type_in)
    OF "CHAR":
     INSERT  FROM dm_cb_history
      SET history_id = seq(dm_clinical_seq,nextval), table_name = ques_his_tab, column_name =
       column_in,
       change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_txt = trim(value_in_old),
       new_value_txt = trim(value_in_new),
       change_reason = reason_in, change_process = "QUESTION LOAD", question_nbr = ques_num_in
      WITH nocounter
     ;end insert
    OF "NUMBER":
     INSERT  FROM dm_cb_history
      SET history_id = seq(dm_clinical_seq,nextval), table_name = ques_his_tab, column_name =
       column_in,
       change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_num = cnvtint(trim(value_in_old)),
       new_value_num = cnvtint(trim(value_in_new)),
       change_reason = reason_in, change_process = "QUESTION LOAD", question_nbr = ques_num_in
      WITH nocounter
     ;end insert
    OF "DATE":
     INSERT  FROM dm_cb_history
      SET history_id = seq(dm_clinical_seq,nextval), table_name = ques_his_tab, column_name =
       column_in,
       change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_dt_tm = cnvtdatetime(value_in_old),
       new_value_dt_tm = cnvtdatetime(value_in_new),
       change_reason = reason_in, change_process = "QUESTION LOAD", question_nbr = ques_num_in
      WITH nocounter
     ;end insert
   ENDCASE
 END ;Subroutine
 SET ques_check_cnt = value(size(requestin->list_0,5))
 IF (ques_check_cnt > 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Updating dm_cb_questions.."
  SELECT INTO "nl:"
   FROM dm_cb_questions q
   ORDER BY q.question_nbr
   HEAD REPORT
    dcd_cnt = 0
   DETAIL
    dcd_cnt = (dcd_cnt+ 1)
    IF (mod(dcd_cnt,10)=1)
     stat = alterlist(rs_questions->list_old,(dcd_cnt+ 9))
    ENDIF
    rs_questions->list_old[dcd_cnt].ques_num[1].question_nbr = q.question_nbr, rs_questions->
    list_old[dcd_cnt].ques[1].question = q.question, rs_questions->list_old[dcd_cnt].ask[1].ask_flag
     = q.ask_flag,
    rs_questions->list_old[dcd_cnt].upd_appl[1].updt_applctx = q.updt_applctx, rs_questions->
    list_old[dcd_cnt].ques_ord[1].question_order_seq = q.question_order_seq, rs_questions->list_old[
    dcd_cnt].active[1].active_ind = q.active_ind
   FOOT REPORT
    stat = alterlist(rs_questions->list_old,dcd_cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(requestin->list_0,5)))
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    dcd_cnt = 0
   DETAIL
    dcd_cnt = (dcd_cnt+ 1)
    IF (mod(dcd_cnt,10)=1)
     stat = alterlist(rs_questions->list_new,(dcd_cnt+ 9))
    ENDIF
    rs_questions->list_new[dcd_cnt].question_nbr = cnvtint(requestin->list_0[d.seq].question_nbr),
    rs_questions->list_new[dcd_cnt].question = requestin->list_0[d.seq].question, rs_questions->
    list_new[dcd_cnt].ask_flag = cnvtint(requestin->list_0[d.seq].ask_flag),
    rs_questions->list_new[dcd_cnt].question_order_seq = cnvtint(requestin->list_0[d.seq].
     question_order_seq), rs_questions->list_new[dcd_cnt].active_ind = cnvtint(requestin->list_0[d
     .seq].active_ind)
   FOOT REPORT
    stat = alterlist(rs_questions->list_new,dcd_cnt)
   WITH nocounter
  ;end select
  FOR (dcd_cnt = 1 TO ques_check_cnt)
    SET ques_ndx = 0
    SET found_ques = 0
    FOR (ques_ndx = 1 TO size(rs_questions->list_old,5))
      IF ((rs_questions->list_old[ques_ndx].ques_num[1].question_nbr=rs_questions->list_new[dcd_cnt].
      question_nbr))
       SET ques_cnt = ques_ndx
       SET ques_ndx = size(rs_questions->list_old,5)
       SET found_ques = 1
      ENDIF
    ENDFOR
    SET ques_reason = "CSV UPDATE"
    IF (found_ques=1)
     SET upd_diff = 0
     IF (cnvtupper(rs_questions->list_old[ques_cnt].ques[1].question) != cnvtupper(rs_questions->
      list_new[dcd_cnt].question))
      CALL dm_hist_insert("CHAR",rs_questions->list_old[ques_cnt].ques[1].question,rs_questions->
       list_new[dcd_cnt].question,"QUESTION",rs_questions->list_new[dcd_cnt].question_nbr,
       ques_reason,"DM_CB_QUESTIONS")
      SET upd_diff = 1
      IF ((rs_questions->list_old[ques_cnt].ask[1].ask_flag=0))
       CALL dm_hist_insert("NUMBER",cnvtstring(rs_questions->list_old[ques_cnt].ask[1].ask_flag),
        cnvtstring(1),"ASK_FLAG",rs_questions->list_new[dcd_cnt].question_nbr,
        ques_reason,"DM_CB_QUESTIONS")
      ENDIF
     ELSE
      SET rs_questions->list_old[ques_cnt].ask[1].skipped = 1
     ENDIF
     IF ((rs_questions->list_old[ques_cnt].active_ind != rs_questions->list_new[dcd_cnt].active_ind))
      IF ((rs_questions->list_old[ques_cnt].active_ind=0)
       AND (rs_questions->list_new[dcd_cnt].active_ind=1))
       SET rs_questions->list_old[ques_cnt].active[1].answer_upd = 1
      ENDIF
      CALL dm_hist_insert("NUMBER",cnvtstring(rs_questions->list_old[ques_cnt].active[1].active_ind),
       cnvtstring(rs_questions->list_new[dcd_cnt].active_ind),"ACTIVE_IND",rs_questions->list_new[
       dcd_cnt].question_nbr,
       ques_reason,"DM_CB_QUESTIONS")
      SET upd_diff = 1
     ENDIF
     IF ((rs_questions->list_old[ques_cnt].question_order_seq != rs_questions->list_new[dcd_cnt].
     question_order_seq))
      CALL dm_hist_insert("NUMBER",cnvtstring(rs_questions->list_old[ques_cnt].ques_ord[1].
        question_order_seq),cnvtstring(rs_questions->list_new[dcd_cnt].question_order_seq),
       "QUESTION_ORDER_SEQ",rs_questions->list_new[dcd_cnt].question_nbr,
       ques_reason,"DM_CB_QUESTIONS")
      SET upd_diff = 1
      SET rs_questions->list_old[ques_cnt].ask[1].skipped = 1
     ENDIF
     IF (upd_diff=1)
      IF ((rs_questions->list_old[ques_cnt].ask[1].skipped=0))
       UPDATE  FROM dm_cb_questions dcd
        SET dcd.question = trim(rs_questions->list_new[dcd_cnt].question), dcd.active_ind =
         rs_questions->list_new[dcd_cnt].active_ind, dcd.question_order_seq = rs_questions->list_new[
         dcd_cnt].question_order_seq,
         dcd.ask_flag = 1, dcd.updt_applctx = 100, dcd.updt_cnt = (dcd.updt_cnt+ 1)
        WHERE (dcd.question_nbr=rs_questions->list_new[dcd_cnt].question_nbr)
        WITH nocounter
       ;end update
      ELSE
       UPDATE  FROM dm_cb_questions dcd
        SET dcd.question = trim(rs_questions->list_new[dcd_cnt].question), dcd.active_ind =
         rs_questions->list_new[dcd_cnt].active_ind, dcd.question_order_seq = rs_questions->list_new[
         dcd_cnt].question_order_seq,
         dcd.updt_cnt = (dcd.updt_cnt+ 1), dcd.updt_applctx = 100
        WHERE (dcd.question_nbr=rs_questions->list_new[dcd_cnt].question_nbr)
        WITH nocounter
       ;end update
      ENDIF
     ENDIF
     IF ((rs_questions->list_old[ques_cnt].active[1].answer_upd=1))
      UPDATE  FROM dm_cb_questions q
       SET q.ask_flag = 1
       WHERE (q.question_nbr=rs_questions->list_new[dcd_cnt].question_nbr)
        AND q.ask_flag=0
       WITH nocounter
      ;end update
      IF (curqual > 0)
       CALL dm_hist_insert("NUMBER",cnvtstring(rs_questions->list_old[ques_cnt].ask[1].ask_flag),
        cnvtstring(1),"ASK_FLAG",rs_questions->list_new[dcd_cnt].question_nbr,
        ques_reason,"DM_CB_QUESTIONS")
      ENDIF
      SELECT INTO "nl:"
       FROM dm_cb_answers a
       WHERE (a.question_nbr=rs_questions->list_new[dcd_cnt].question_nbr)
       HEAD REPORT
        ans_cnt = 0
       DETAIL
        ans_cnt = (ans_cnt+ 1)
        IF (mod(ans_cnt,10)=1)
         stat = alterlist(ans_stat->ans,(ans_cnt+ 9))
        ENDIF
        ans_stat->ans[ans_cnt].status = a.answer_status, ans_stat->ans[ans_cnt].ans_num = a
        .answer_nbr
       FOOT REPORT
        stat = alterlist(ans_stat->ans,ans_cnt), ans_cnt = 0
       WITH nocounter
      ;end select
      FOR (ans_cnt = 1 TO size(ans_stat->ans,5))
        IF ((ans_stat->ans[ans_cnt].status != ""))
         UPDATE  FROM dm_cb_answers a
          SET a.answer_status = null
          WHERE (a.question_nbr=rs_questions->list_new[dcd_cnt].question_nbr)
           AND (a.answer_nbr=ans_stat->ans[ans_cnt].ans_num)
          WITH nocounter
         ;end update
         INSERT  FROM dm_cb_history
          SET history_id = seq(dm_clinical_seq,nextval), table_name = "DM_CB_ANSWERS", column_name =
           "ANSWER_STATUS",
           change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_txt = ans_stat->ans[ans_cnt].
           status, new_value_txt = null,
           change_reason = "QUESTION ACTIVATED", change_process = "QUESTION CHANGED", question_nbr =
           rs_questions->list_new[dcd_cnt].question_nbr,
           answer_nbr = ans_stat->ans[ans_cnt].ans_num
          WITH nocounter
         ;end insert
        ENDIF
      ENDFOR
     ENDIF
    ELSE
     INSERT  FROM dm_cb_questions dcd
      SET dcd.question = trim(rs_questions->list_new[dcd_cnt].question), dcd.active_ind =
       rs_questions->list_new[dcd_cnt].active_ind, dcd.question_order_seq = rs_questions->list_new[
       dcd_cnt].question_order_seq,
       dcd.ask_flag = rs_questions->list_new[dcd_cnt].ask_flag, dcd.updt_applctx = 100, dcd
       .question_nbr = rs_questions->list_new[dcd_cnt].question_nbr
      WHERE (dcd.question_nbr=rs_questions->list_new[dcd_cnt].question_nbr)
      WITH nocounter
     ;end insert
    ENDIF
  ENDFOR
  FOR (dcd_cnt = 1 TO size(rs_questions->list_old,5))
    SET ques_ndx = 0
    SET found_ques = 0
    FOR (ques_ndx = 1 TO size(rs_questions->list_new,5))
      IF ((rs_questions->list_new[ques_ndx].question_nbr=rs_questions->list_old[dcd_cnt].ques_num[1].
      question_nbr))
       SET ques_cnt = ques_ndx
       SET ques_ndx = size(rs_questions->list_new,5)
       SET found_ques = 1
      ENDIF
    ENDFOR
    SET ques_reason = "IN TABLE, NOT CSV"
    IF (found_ques=0)
     UPDATE  FROM dm_cb_questions q
      SET q.active_ind = 0, q.updt_applctx = 100, q.updt_cnt = (q.updt_cnt+ 1),
       q.updt_dt_tm = sysdate
      WHERE (rs_questions->list_old[dcd_cnt].question_nbr=q.question_nbr)
       AND q.active_ind=1
      WITH nocounter
     ;end update
     IF (curqual > 0)
      CALL dm_hist_insert("NUMBER",cnvtstring(rs_questions->list_old[dcd_cnt].active[1].active_ind),
       cnvtstring(0),"ACTIVE_IND",rs_questions->list_old[dcd_cnt].question_nbr,
       ques_reason,"DM_CB_QUESTIONS")
     ENDIF
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM dm_cb_questions di,
    (dummyt d  WITH seq = value(size(requestin->list_0,5)))
   PLAN (d)
    JOIN (di
    WHERE di.question_nbr=cnvtint(requestin->list_0[d.seq].question_nbr)
     AND (di.question=requestin->list_0[d.seq].question)
     AND di.active_ind=cnvtint(requestin->list_0[d.seq].active_ind)
     AND di.question_order_seq=cnvtint(requestin->list_0[d.seq].question_order_seq))
   DETAIL
    IF (first_ind=1)
     readme_data->message = concat("Missing question(s): ",trim(requestin->list_0[d.seq].question_nbr
       ))
    ELSE
     readme_data->message = concat(readme_data->message,", ",trim(requestin->list_0[d.seq].
       question_nbr))
    ENDIF
    first_ind = 0
   WITH outerjoin = d, dontexist
  ;end select
  CALL echo(readme_data->message)
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed.  The request structure has not been ",
   "populated with dm_cb_questions.csv information.")
  GO TO exit_script
 ENDIF
 IF (first_ind=1)
  IF (error(errmsg,0) != 0)
   SET readme_data->message = errmsg
   GO TO exit_script
  ENDIF
  SET readme_data->status = "S"
  SET readme_data->message = "All dm_cb_question rows inserted successfully."
 ENDIF
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSEIF ((readme_data->status="S"))
  COMMIT
 ENDIF
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echo("##################################################")
  CALL echo(readme_data->message)
  CALL echo("##################################################")
 ENDIF
END GO

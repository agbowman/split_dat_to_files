CREATE PROGRAM dm_cb_answers_load:dba
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
 DECLARE dim_filename = c35
 DECLARE ans_stat_check_cnt = i4
 DECLARE first_ind = i2
 DECLARE errmsg = c132
 DECLARE dim_cnt = i4
 DECLARE after_cnt = i4
 DECLARE dcd_cnt = i4
 DECLARE dm_hist_insert(type_in,value_in_old,value_in_new,column_in,ans_in,
  ques_in,his_table_in) = null WITH public
 DECLARE ans_stat_ndx = i4
 DECLARE found_ans = i2
 DECLARE ans_cnt = i4
 DECLARE upd_diff = i2
 DECLARE exe_ind = i2
 DECLARE action_chg_ind = i2
 DECLARE execute_successful = i2
 DECLARE error_logfile = c132
 DECLARE dgts_perform_check = i2
 SET dgts_perform_check = 0
 DECLARE inhouse_ind = i2
 DECLARE dca_ebook_ind = i2
 DECLARE dca_rhio_ind = i2
 SET dca_ebook_ind = 0
 SET inhouse_ind = 0
 SET dca_rhio_ind = 0
 SELECT INTO "nl:"
  FROM dm_info
  WHERE info_domain="DATA MANAGEMENT"
   AND info_name="INHOUSE DOMAIN"
  DETAIL
   inhouse_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_info
  WHERE info_domain="DATA MANAGEMENT"
   AND info_name="EBOOKINGS DOMAIN"
  DETAIL
   dca_ebook_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_info
  WHERE info_domain="DATA MANAGEMENT"
   AND info_name="RHIO DOMAIN"
  DETAIL
   dca_rhio_ind = 1
  WITH nocounter
 ;end select
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
 UPDATE  FROM dm_cb_answers a
  SET a.answer_nbr = 26
  WHERE a.answer_nbr=20
   AND a.question_nbr=9
  WITH nocounter
 ;end update
 UPDATE  FROM dm_cb_answers a
  SET a.answer_nbr = 20
  WHERE a.answer_nbr=1000
   AND a.question_nbr=99
  WITH nocounter
 ;end update
 SET action_chg_ind = 0
 SET exe_ind = 0
 SET first_ind = 1
 FREE RECORD rs_answers
 RECORD rs_answers(
   1 list_old[*]
     2 ques_num[1]
       3 question_nbr = i4
     2 ans_num[1]
       3 answer_nbr = i4
     2 ans[1]
       3 answer = vc
     2 ans_stat[1]
       3 answer_status = vc
     2 act_stat[1]
       3 action_status = vc
     2 act[1]
       3 action = vc
     2 upd_appl[1]
       3 updt_applctx = i4
     2 active[1]
       3 answer_upd = i2
       3 active_ind = i2
     2 ignore_first[1]
       3 ignore_first_ind = i2
   1 list_new[*]
     2 question_nbr = i4
     2 answer_nbr = i4
     2 answer = vc
     2 action_status = vc
     2 answer_status = vc
     2 action = vc
     2 active_ind = i2
     2 ignore_first_ind = i2
 )
 SUBROUTINE dm_hist_insert(type_in,value_in_old,value_in_new,column_in,ans_in,ques_in,his_table_in)
   CASE (type_in)
    OF "CHAR":
     INSERT  FROM dm_cb_history
      SET history_id = seq(dm_clinical_seq,nextval), table_name = his_table_in, column_name =
       column_in,
       change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_txt = trim(value_in_old),
       new_value_txt = trim(value_in_new),
       change_reason = "CSV LOAD", change_process = "DM_CB_ANSWERS_LOAD", answer_nbr = ans_in,
       question_nbr = ques_in
      WITH nocounter
     ;end insert
    OF "NUMBER":
     INSERT  FROM dm_cb_history
      SET history_id = seq(dm_clinical_seq,nextval), table_name = his_table_in, column_name =
       column_in,
       change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_num = cnvtint(trim(value_in_old)),
       new_value_num = cnvtint(trim(value_in_new)),
       change_reason = "CSV LOAD", change_process = "DM_CB_ANSWERS_LOAD", answer_nbr = ans_in,
       question_nbr = ques_in
      WITH nocounter
     ;end insert
    OF "DATE":
     INSERT  FROM dm_cb_history
      SET history_id = seq(dm_clinical_seq,nextval), table_name = his_table_in, column_name =
       column_in,
       change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_dt_tm = cnvtdatetime(value_in_old),
       new_value_dt_tm = cnvtdatetime(value_in_new),
       change_reason = "CSV LOAD", change_process = "DM_CB_ANSWERS_LOAD", answer_nbr = ans_in,
       question_nbr = ques_in
      WITH nocounter
     ;end insert
   ENDCASE
 END ;Subroutine
 SET ans_stat_check_cnt = value(size(requestin->list_0,5))
 IF (ans_stat_check_cnt > 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Updating dm_cb_answers.."
  SELECT INTO "nl:"
   FROM dm_cb_answers q
   ORDER BY q.question_nbr, q.answer_nbr
   HEAD REPORT
    dcd_cnt = 0
   DETAIL
    dcd_cnt = (dcd_cnt+ 1)
    IF (mod(dcd_cnt,10)=1)
     stat = alterlist(rs_answers->list_old,(dcd_cnt+ 9))
    ENDIF
    rs_answers->list_old[dcd_cnt].ans_num[1].answer_nbr = q.answer_nbr, rs_answers->list_old[dcd_cnt]
    .ques_num[1].question_nbr = q.question_nbr, rs_answers->list_old[dcd_cnt].ignore_first[1].
    ignore_first_ind = q.ignore_first_ind,
    rs_answers->list_old[dcd_cnt].ans[1].answer = q.answer, rs_answers->list_old[dcd_cnt].ans_stat[1]
    .answer_status = q.answer_status, rs_answers->list_old[dcd_cnt].act[1].action = q.action,
    rs_answers->list_old[dcd_cnt].upd_appl[1].updt_applctx = q.updt_applctx, rs_answers->list_old[
    dcd_cnt].active[1].active_ind = q.active_ind, rs_answers->list_old[dcd_cnt].act_stat[1].
    action_status = q.action_status
   FOOT REPORT
    stat = alterlist(rs_answers->list_old,dcd_cnt)
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
     stat = alterlist(rs_answers->list_new,(dcd_cnt+ 9))
    ENDIF
    rs_answers->list_new[dcd_cnt].answer_nbr = cnvtint(requestin->list_0[d.seq].answer_nbr),
    rs_answers->list_new[dcd_cnt].question_nbr = cnvtint(requestin->list_0[d.seq].question_nbr),
    rs_answers->list_new[dcd_cnt].ignore_first_ind = cnvtint(requestin->list_0[d.seq].
     ignore_first_ind),
    rs_answers->list_new[dcd_cnt].answer = requestin->list_0[d.seq].answer, rs_answers->list_new[
    dcd_cnt].answer_status = requestin->list_0[d.seq].answer_status, rs_answers->list_new[dcd_cnt].
    action = requestin->list_0[d.seq].action,
    rs_answers->list_new[dcd_cnt].active_ind = cnvtint(requestin->list_0[d.seq].active_ind),
    rs_answers->list_new[dcd_cnt].action_status = requestin->list_0[d.seq].action_status
    IF ((rs_answers->list_new[dcd_cnt].question_nbr=100))
     IF ((rs_answers->list_new[dcd_cnt].answer_nbr=18))
      IF (dca_ebook_ind=0)
       rs_answers->list_new[dcd_cnt].answer_status = "SELECTED"
      ELSE
       rs_answers->list_new[dcd_cnt].answer_status = ""
      ENDIF
     ENDIF
    ENDIF
    IF ((rs_answers->list_new[dcd_cnt].question_nbr=101))
     IF ((rs_answers->list_new[dcd_cnt].answer_nbr=22))
      IF (dca_rhio_ind=0)
       rs_answers->list_new[dcd_cnt].answer_status = "SELECTED"
      ELSE
       rs_answers->list_new[dcd_cnt].answer_status = ""
      ENDIF
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist(rs_answers->list_new,dcd_cnt)
   WITH nocounter
  ;end select
  FOR (dcd_cnt = 1 TO size(rs_answers->list_new,5))
    SET upd_diff = 0
    SET action_chg_ind = 0
    SET ans_stat_ndx = 0
    SET found_ans = 0
    SET ans_cnt = 0
    FOR (ans_cnt = 1 TO size(rs_answers->list_old,5))
      IF ((rs_answers->list_old[ans_cnt].ans_num[1].answer_nbr=rs_answers->list_new[dcd_cnt].
      answer_nbr))
       SET ans_stat_ndx = ans_cnt
       SET ans_cnt = size(rs_answers->list_old,5)
       SET found_ans = 1
      ENDIF
    ENDFOR
    IF (found_ans=1)
     IF ((rs_answers->list_old[ans_stat_ndx].answer != rs_answers->list_new[dcd_cnt].answer))
      CALL dm_hist_insert("CHAR",rs_answers->list_old[ans_stat_ndx].ans[1].answer,rs_answers->
       list_new[dcd_cnt].answer,"ANSWER",rs_answers->list_new[dcd_cnt].answer_nbr,
       rs_answers->list_new[dcd_cnt].question_nbr,"DM_CB_ANSWERS")
      SET upd_diff = 1
     ENDIF
     IF ((rs_answers->list_old[ans_stat_ndx].action != rs_answers->list_new[dcd_cnt].action))
      SET action_chg_ind = 0
      IF ((rs_answers->list_old[ans_stat_ndx].answer_status="SELECTED"))
       SELECT INTO "nl:"
        FROM dm_cb_questions q
        WHERE (q.question_nbr=rs_answers->list_new[dcd_cnt].question_nbr)
         AND q.active_ind=1
        WITH nocounter
       ;end select
       IF (curqual > 0)
        SET action_chg_ind = 1
        UPDATE  FROM dm_cb_answers dcd
         SET dcd.action_status = "EXECUTE", dcd.updt_applctx = 101, dcd.updt_cnt = (dcd.updt_cnt+ 1)
         WHERE (dcd.answer_nbr=rs_answers->list_new[dcd_cnt].answer_nbr)
          AND dcd.active_ind=1
         WITH nocounter
        ;end update
        IF (curqual > 0)
         CALL dm_hist_insert("CHAR",rs_answers->list_old[ans_stat_ndx].act_stat[1].action_status,
          "EXECUTE","ACTION_STATUS",rs_answers->list_new[dcd_cnt].answer_nbr,
          rs_answers->list_new[dcd_cnt].question_nbr,"DM_CB_ANSWERS")
        ENDIF
       ENDIF
      ENDIF
      CALL dm_hist_insert("CHAR",rs_answers->list_old[ans_stat_ndx].act[1].action,rs_answers->
       list_new[dcd_cnt].action,"ACTION",rs_answers->list_new[dcd_cnt].answer_nbr,
       rs_answers->list_new[dcd_cnt].question_nbr,"DM_CB_ANSWERS")
      SET upd_diff = 1
     ENDIF
     IF ((rs_answers->list_old[ans_stat_ndx].active[1].active_ind != rs_answers->list_new[dcd_cnt].
     active_ind))
      CALL dm_hist_insert("NUMBER",cnvtstring(rs_answers->list_old[ans_stat_ndx].active[1].active_ind
        ),cnvtstring(rs_answers->list_new[dcd_cnt].active_ind),"ACTIVE_IND",rs_answers->list_new[
       dcd_cnt].answer_nbr,
       rs_answers->list_new[dcd_cnt].question_nbr,"DM_CB_ANSWERS")
      IF ((rs_answers->list_old[ans_stat_ndx].active[1].active_ind=0)
       AND (rs_answers->list_new[dcd_cnt].active_ind=1))
       UPDATE  FROM dm_cb_questions q
        SET q.ask_flag = 1
        WHERE (q.question_nbr=rs_answers->list_new[dcd_cnt].question_nbr)
         AND q.ask_flag=0
         AND q.active_ind=1
        WITH nocounter
       ;end update
       IF (curqual > 0)
        CALL dm_hist_insert("NUMBER",cnvtstring(0),cnvtstring(1),"ASK_FLAG",rs_answers->list_new[
         dcd_cnt].answer_nbr,
         rs_answers->list_new[dcd_cnt].question_nbr,"DM_CB_QUESTIONS")
       ENDIF
      ENDIF
      SET upd_diff = 1
     ENDIF
     IF (upd_diff=1
      AND action_chg_ind=1
      AND inhouse_ind != 1)
      UPDATE  FROM dm_cb_answers dcd
       SET dcd.active_ind = rs_answers->list_new[dcd_cnt].active_ind, dcd.action = rs_answers->
        list_new[dcd_cnt].action, dcd.answer = trim(rs_answers->list_new[dcd_cnt].answer),
        dcd.updt_applctx = 101, dcd.updt_cnt = (dcd.updt_cnt+ 1)
       WHERE (dcd.answer_nbr=rs_answers->list_new[dcd_cnt].answer_nbr)
       WITH nocounter
      ;end update
      SELECT INTO "nl:"
       FROM dm_cb_answers a
       WHERE (a.answer_nbr=rs_answers->list_new[dcd_cnt].answer_nbr)
        AND a.answer_status="SELECTED"
        AND a.action_status="EXECUTE"
        AND a.active_ind=1
       HEAD REPORT
        exe_ind = 0
       DETAIL
        exe_ind = 1
       WITH nocounter
      ;end select
      IF (exe_ind=1)
       CALL echo(concat("Performing action for Question Number: ",trim(cnvtstring(rs_answers->
           list_new[dcd_cnt].question_nbr)),"."))
       EXECUTE dm_cb_scan_for_execute rs_answers->list_new[dcd_cnt].question_nbr,
       "DM_CB_ANSWERS_LOAD"
       IF (execute_successful=0)
        SET readme_data->message = concat("Error performing action for Question Number: ",trim(
          cnvtstring(rs_answers->list_new[dcd_cnt].question_nbr)),", Answer Number: ",trim(cnvtstring
          (rs_answers->list_new[dcd_cnt].answer_nbr)),". Log File: ",
         error_logfile,".")
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF (upd_diff=1)
      UPDATE  FROM dm_cb_answers dcd
       SET dcd.active_ind = rs_answers->list_new[dcd_cnt].active_ind, dcd.action = rs_answers->
        list_new[dcd_cnt].action, dcd.answer = trim(rs_answers->list_new[dcd_cnt].answer),
        dcd.updt_applctx = 101, dcd.updt_cnt = (dcd.updt_cnt+ 1)
       WHERE (dcd.answer_nbr=rs_answers->list_new[dcd_cnt].answer_nbr)
       WITH nocounter
      ;end update
     ENDIF
    ELSE
     INSERT  FROM dm_cb_answers dcd
      SET dcd.active_ind = rs_answers->list_new[dcd_cnt].active_ind, dcd.action = rs_answers->
       list_new[dcd_cnt].action, dcd.updt_applctx = 101,
       dcd.ignore_first_ind = rs_answers->list_new[dcd_cnt].ignore_first_ind, dcd.answer = rs_answers
       ->list_new[dcd_cnt].answer, dcd.question_nbr = rs_answers->list_new[dcd_cnt].question_nbr,
       dcd.updt_dt_tm = cnvtdatetime(curdate,curtime3), dcd.answer_nbr = rs_answers->list_new[dcd_cnt
       ].answer_nbr, dcd.action_status = rs_answers->list_new[dcd_cnt].action_status,
       dcd.answer_status = rs_answers->list_new[dcd_cnt].answer_status
      WHERE (dcd.answer_nbr=rs_answers->list_new[dcd_cnt].answer_nbr)
      WITH nocounter
     ;end insert
    ENDIF
  ENDFOR
  FOR (dcd_cnt = 1 TO size(rs_answers->list_old,5))
    SET ans_stat_ndx = 0
    SET found_ans = 0
    SET ans_cnt = 0
    FOR (ans_cnt = 1 TO size(rs_answers->list_new,5))
      IF ((rs_answers->list_new[ans_cnt].answer_nbr=rs_answers->list_old[dcd_cnt].ans_num[1].
      answer_nbr))
       SET ans_stat_ndx = ans_cnt
       SET ans_cnt = size(rs_answers->list_new,5)
       SET found_ans = 1
      ENDIF
    ENDFOR
    IF (found_ans=0)
     UPDATE  FROM dm_cb_answers q
      SET q.active_ind = 0, q.updt_applctx = 101, q.updt_cnt = (q.updt_cnt+ 1),
       q.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (rs_answers->list_old[dcd_cnt].ans_num[1].answer_nbr=q.answer_nbr)
       AND q.active_ind=1
      WITH nocounter
     ;end update
     CALL dm_hist_insert("NUMBER",cnvtstring(rs_answers->list_old[dcd_cnt].active[1].active_ind),"0",
      "ACTIVE_IND",rs_answers->list_old[dcd_cnt].ans_num[1].answer_nbr,
      rs_answers->list_old[dcd_cnt].ques_num[1].question_nbr,"DM_CB_ANSWERS")
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM dm_cb_answers di,
    (dummyt d  WITH seq = value(size(requestin->list_0,5)))
   PLAN (d)
    JOIN (di
    WHERE di.answer_nbr=cnvtint(requestin->list_0[d.seq].answer_nbr)
     AND (di.answer=requestin->list_0[d.seq].answer)
     AND di.active_ind=cnvtint(requestin->list_0[d.seq].active_ind))
   DETAIL
    IF (first_ind=1)
     readme_data->message = concat("Missing answer_nbr(s): ",trim(requestin->list_0[d.seq].answer_nbr
       ))
    ELSE
     readme_data->message = concat(readme_data->message,", ",trim(requestin->list_0[d.seq].answer_nbr
       ))
    ENDIF
    first_ind = 0
   WITH outerjoin = d, dontexist
  ;end select
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed.  The requestin structure has not been ",
   "populated with dm_cb_answers.csv information.")
  GO TO exit_script
 ENDIF
 IF (first_ind=1)
  IF (error(errmsg,0) != 0)
   SET readme_data->message = errmsg
   GO TO exit_script
  ENDIF
  SET readme_data->status = "S"
  SET readme_data->message = "All dm_cb_answers rows inserted successfully."
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

CREATE PROGRAM dm_cb_customize_env:dba
 DECLARE dcm_get_answers(get_ans_ques) = null WITH public
 DECLARE dcm_get_objects(get_obj_ques) = null WITH public
 DECLARE dcm_get_questions(dcm_select_ques) = null WITH public
 DECLARE dcm_get_requests(get_req_ques) = null WITH public
 DECLARE ms_table_missing(ms_table) = i2 WITH public
 DECLARE ms_index_missing(ms_index) = i2 WITH public
 DECLARE execute_actions(codb_action_in) = null WITH public
 DECLARE mt_trigger_missing(mt_trigger,mt_table) = i2 WITH public
 DECLARE rp_request_missing(rp_request,rp_script,rp_active) = i2 WITH public
 DECLARE dcm_process_operations(dpo_ques_in,dpo_op_mode) = i2 WITH public
 DECLARE dcm_postop_updates(op_ques_in,op_mode) = null WITH public
 DECLARE dcm_check_op_success(dos_interactive,dos_ques_in) = null WITH public
 DECLARE dcm_create_error_log(dcm_program_name,log_ques_in) = null WITH public
 DECLARE dcm_log_hist(dcm_type,dcm_value_old,dcm_value_new,dcm_column_in,dcm_ques_in,
  dcm_table_name_in,dcm_request_num_in) = null WITH public
 DECLARE dcm_error(null) = null WITH public
 IF (validate(dcm_error_operation,- (1)) < 0)
  DECLARE dcm_error_operation = i2
  DECLARE dcm_error_occurred = i2
  DECLARE dcm_op_err_cnt = i4
  DECLARE dpo_ans_cnt = i4
  DECLARE dpo_obj_cnt = i4
  DECLARE dpo_op_cnt = i4
  DECLARE dpo_answer = c132
  DECLARE dcm_proc_desc = c30
 ENDIF
 SET dcm_proc_desc = ""
 SET dcm_error_operation = 0
 SET dcm_error_occurred = 0
 SET dcm_op_err_cnt = 0
 IF (validate(dccs_master->question[1].question_nbr,- (1)) < 0)
  FREE RECORD dccs_master
  RECORD dccs_master(
    1 dccs_logfile = vc
    1 question[*]
      2 question_nbr = i4
      2 question_order_seq = i4
      2 question_full = vc
      2 question_full_unedit = vc
      2 question_break[*]
        3 question_segment = vc
        3 question_break_seq = i4
      2 question_answer = vc
      2 question_answer_db = vc
      2 question_answer_num_db = i4
      2 question_options = vc
      2 ask_flag = i4
      2 action_status = vc
      2 question_object_cnt = i4
      2 obj_act_performed = vc
      2 answer[*]
        3 answer_orig = vc
        3 question_nbr = i4
        3 answer_nbr = i4
        3 answer = vc
        3 answer_status_old = vc
        3 answer_status_new = vc
        3 answer_status_db = vc
        3 action = vc
        3 action_status = vc
        3 ignore_first_ind = i2
        3 ignore_first_ind_db = i2
      2 object[*]
        3 object_active = i2
        3 object_type = vc
        3 object_name = vc
        3 object_status = vc
        3 object_status_orig = vc
        3 table_name = vc
        3 object_tablespace = vc
        3 op[*]
          4 operations = vc
          4 op_status = vc
          4 op_success_ind = i2
      2 request_op_cnt = i4
      2 request[*]
        3 request_number = i4
        3 active_ind = i2
        3 request_status = vc
        3 request_status_orig = vc
        3 format_script = vc
        3 op[*]
          4 operations = vc
          4 op_status = vc
          4 op_success_ind = i2
  )
 ENDIF
 IF (validate(dcm_info->err_msg,"N")="N")
  RECORD dcm_info(
    1 err_msg = vc
    1 fail_flag = i2
  )
 ENDIF
 IF (validate(scan_call_prog,"X")="X")
  SET dcm_proc_desc = "DM_CB_CUSTOMIZE_ENV"
 ELSE
  SET dcm_proc_desc = scan_call_prog
 ENDIF
 SUBROUTINE dcm_log_hist(dcm_type,dcm_value_old,dcm_value_new,dcm_column_in,dcm_ques_in,
  dcm_table_name_in,dcm_request_num_in,dcm_answer_in)
   CASE (dcm_type)
    OF "CHAR":
     INSERT  FROM dm_cb_history
      SET history_id = seq(dm_clinical_seq,nextval), table_name = dcm_table_name_in, column_name =
       dcm_column_in,
       request_number = dcm_request_num_in, change_dt_tm = cnvtdatetime(curdate,curtime3),
       old_value_txt = trim(dcm_value_old),
       new_value_txt = trim(dcm_value_new), change_reason = "POST-OP UPDATES", change_process =
       dcm_proc_desc,
       question_nbr = dcm_ques_in, answer_nbr = dcm_answer_in
      WITH nocounter
     ;end insert
    OF "NUMBER":
     INSERT  FROM dm_cb_history
      SET history_id = seq(dm_clinical_seq,nextval), table_name = dcm_table_name_in, column_name =
       dcm_column_in,
       request_number = dcm_request_num_in, change_dt_tm = cnvtdatetime(curdate,curtime3),
       old_value_num = cnvtint(trim(dcm_value_old)),
       new_value_num = cnvtint(trim(dcm_value_new)), change_reason = "POST-OP UPDATES",
       change_process = dcm_proc_desc,
       question_nbr = dcm_ques_in, answer_nbr = dcm_answer_in
      WITH nocounter
     ;end insert
    OF "DATE":
     INSERT  FROM dm_cb_history
      SET history_id = seq(dm_clinical_seq,nextval), table_name = dcm_table_name_in, column_name =
       dcm_column_in,
       request_number = dcm_request_num_in, change_dt_tm = cnvtdatetime(curdate,curtime3),
       old_value_dt_tm = cnvtdatetime(value_in_old),
       new_value_dt_tm = cnvtdatetime(value_in_new), change_reason = "POST-OP UPDATES",
       change_process = dcm_proc_desc,
       question_nbr = dcm_ques_in, answer_nbr = dcm_answer_in
      WITH nocounter
     ;end insert
   ENDCASE
 END ;Subroutine
 SUBROUTINE dcm_postop_updates(op_ques_in,op_mode)
   DECLARE do_update_ind = i2
   DECLARE dcm_status_update = c20
   DECLARE dcm_ask_flag = i4
   IF (op_mode="Y")
    IF (size(dccs_master->question[op_ques_in].object,5) > 0)
     FOR (op_obj_cnt = 1 TO size(dccs_master->question[op_ques_in].object,5))
      SET do_update_ind = 1
      IF (do_update_ind=1)
       IF ((dccs_master->question[op_ques_in].object[op_obj_cnt].object_status != dccs_master->
       question[op_ques_in].object[op_obj_cnt].object_status_orig))
        UPDATE  FROM dm_cb_objects o
         SET o.object_status = dccs_master->question[op_ques_in].object[op_obj_cnt].object_status, o
          .updt_applctx = 111, o.updt_cnt = (o.updt_cnt+ 1),
          o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_task = 444
         WHERE (o.object_name=dccs_master->question[op_ques_in].object[op_obj_cnt].object_name)
          AND (o.object_type=dccs_master->question[op_ques_in].object[op_obj_cnt].object_type)
         WITH nocounter
        ;end update
        CALL dcm_log_hist("CHAR",dccs_master->question[op_ques_in].object[op_obj_cnt].
         object_status_orig,dccs_master->question[op_ques_in].object[op_obj_cnt].object_status,
         "OBJECT_STATUS",dccs_master->question[op_ques_in].question_nbr,
         "DM_CB_OBJECTS",null,dccs_master->question[op_ques_in].question_answer_num_db)
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
    IF (size(dccs_master->question[op_ques_in].request,5) > 0)
     FOR (op_req_cnt = 1 TO size(dccs_master->question[op_ques_in].request,5))
       SET do_update_ind = 0
       SET do_update_ind = 1
       IF (do_update_ind=1)
        IF ((dccs_master->question[op_ques_in].request[op_req_cnt].request_status != dccs_master->
        question[op_ques_in].request[op_req_cnt].request_status_orig))
         UPDATE  FROM dm_cb_request_processing r
          SET r.request_status = dccs_master->question[op_ques_in].request[op_req_cnt].request_status,
           r.updt_applctx = 111, r.updt_cnt = (r.updt_cnt+ 1),
           r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_task = 555
          WHERE (r.request_number=dccs_master->question[op_ques_in].request[op_req_cnt].
          request_number)
           AND (r.format_script=dccs_master->question[op_ques_in].request[op_req_cnt].format_script)
          WITH nocounter
         ;end update
         CALL dcm_log_hist("CHAR",dccs_master->question[op_ques_in].request[op_req_cnt].
          request_status_orig,dccs_master->question[op_ques_in].request[op_req_cnt].request_status,
          "REQUEST_STATUS",dccs_master->question[op_ques_in].question_nbr,
          "DM_CB_REQUEST_PROCESSING",dccs_master->question[op_ques_in].request[op_req_cnt].
          request_number,dccs_master->question[op_ques_in].question_answer_num_db)
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ELSE
    IF ((dccs_master->question[op_ques_in].action_status="EXECUTE"))
     FOR (op_ans_cnt = 1 TO size(dccs_master->question[op_ques_in].answer,5))
      IF ((((dccs_master->question[op_ques_in].answer[op_ans_cnt].answer_status_db != dccs_master->
      question[op_ques_in].answer[op_ans_cnt].answer_status_new)) OR ((dccs_master->question[
      op_ques_in].answer[op_ans_cnt].ignore_first_ind != dccs_master->question[op_ques_in].answer[
      op_ans_cnt].ignore_first_ind_db))) )
       SET dcm_status_update = ""
       IF (dcm_error_operation=1
        AND (dccs_master->question[op_ques_in].answer[op_ans_cnt].answer_status_new != "DESELECTED"))
        SET dcm_status_update = "ERROR"
       ELSEIF (dcm_error_operation=0
        AND (dccs_master->question[op_ques_in].answer[op_ans_cnt].answer_status_new != "DESELECTED"))
        SET dcm_status_update = "COMPLETE"
       ELSEIF ((dccs_master->question[op_ques_in].answer[op_ans_cnt].answer_status_new="DESELECTED"))
        SET dcm_status_update = ""
       ENDIF
       UPDATE  FROM dm_cb_answers a
        SET a.answer_status = dccs_master->question[op_ques_in].answer[op_ans_cnt].answer_status_new,
         a.action_status = dcm_status_update, a.ignore_first_ind = dccs_master->question[op_ques_in].
         answer[op_ans_cnt].ignore_first_ind,
         a.updt_applctx = 111, a.updt_cnt = (a.updt_cnt+ 1), a.updt_dt_tm = cnvtdatetime(curdate,
          curtime3),
         a.updt_task = 222
        WHERE (a.question_nbr=dccs_master->question[op_ques_in].question_nbr)
         AND (a.answer_nbr=dccs_master->question[op_ques_in].answer[op_ans_cnt].answer_nbr)
        WITH nocounter
       ;end update
       IF ((dccs_master->question[op_ques_in].answer[op_ans_cnt].answer_status_db != dccs_master->
       question[op_ques_in].answer[op_ans_cnt].answer_status_new))
        CALL dcm_log_hist("CHAR",dccs_master->question[op_ques_in].answer[op_ans_cnt].
         answer_status_db,dccs_master->question[op_ques_in].answer[op_ans_cnt].answer_status_new,
         "ANSWER_STATUS",dccs_master->question[op_ques_in].question_nbr,
         "DM_CB_ANSWERS",null,dccs_master->question[op_ques_in].answer[op_ans_cnt].answer_nbr)
       ENDIF
       IF ((dccs_master->question[op_ques_in].answer[op_ans_cnt].ignore_first_ind != dccs_master->
       question[op_ques_in].answer[op_ans_cnt].ignore_first_ind_db))
        CALL dcm_log_hist("NUMBER",trim(cnvtstring(dccs_master->question[op_ques_in].answer[
           op_ans_cnt].ignore_first_ind_db)),trim(cnvtstring(dccs_master->question[op_ques_in].
           answer[op_ans_cnt].ignore_first_ind)),"IGNORE_FIRST_IND",dccs_master->question[op_ques_in]
         .question_nbr,
         "DM_CB_ANSWERS",null,dccs_master->question[op_ques_in].answer[op_ans_cnt].answer_nbr)
       ENDIF
      ENDIF
      IF ((((dccs_master->question[op_ques_in].answer[op_ans_cnt].answer_status_new="SELECTED")) OR (
      (dccs_master->question[op_ques_in].answer[op_ans_cnt].answer_status_new="")
       AND (dccs_master->question[op_ques_in].answer[op_ans_cnt].answer_status_db="SELECTED"))) )
       IF (dcm_error_operation=1)
        SET dcm_ask_flag = 1
       ELSE
        SET dcm_ask_flag = 0
       ENDIF
       IF ((dcm_ask_flag != dccs_master->question[op_ques_in].ask_flag))
        UPDATE  FROM dm_cb_questions q
         SET q.ask_flag = dcm_ask_flag, q.updt_applctx = 111, q.updt_cnt = (q.updt_cnt+ 1),
          q.updt_dt_tm = cnvtdatetime(curdate,curtime3), q.updt_task = 333
         WHERE (q.question_nbr=dccs_master->question[op_ques_in].question_nbr)
         WITH nocounter
        ;end update
        CALL dcm_log_hist("NUMBER",cnvtstring(dccs_master->question[op_ques_in].ask_flag),cnvtstring(
          dcm_ask_flag),"ASK_FLAG",dccs_master->question[op_ques_in].question_nbr,
         "DM_CB_QUESTIONS",null,null)
       ENDIF
       IF (size(dccs_master->question[op_ques_in].object,5) > 0)
        FOR (op_obj_cnt = 1 TO size(dccs_master->question[op_ques_in].object,5))
          IF ((dccs_master->question[op_ques_in].object[op_obj_cnt].object_status != dccs_master->
          question[op_ques_in].object[op_obj_cnt].object_status_orig))
           UPDATE  FROM dm_cb_objects o
            SET o.object_status = dccs_master->question[op_ques_in].object[op_obj_cnt].object_status,
             o.updt_applctx = 111, o.updt_cnt = (o.updt_cnt+ 1),
             o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_task = 444
            WHERE (o.object_name=dccs_master->question[op_ques_in].object[op_obj_cnt].object_name)
             AND (o.object_type=dccs_master->question[op_ques_in].object[op_obj_cnt].object_type)
            WITH nocounter
           ;end update
           CALL dcm_log_hist("CHAR",dccs_master->question[op_ques_in].object[op_obj_cnt].
            object_status_orig,dccs_master->question[op_ques_in].object[op_obj_cnt].object_status,
            "OBJECT_STATUS",dccs_master->question[op_ques_in].question_nbr,
            "DM_CB_OBJECTS",null,dccs_master->question[op_ques_in].question_answer_num_db)
          ENDIF
        ENDFOR
       ENDIF
       IF (size(dccs_master->question[op_ques_in].request,5) > 0)
        FOR (op_req_cnt = 1 TO size(dccs_master->question[op_ques_in].request,5))
          IF ((dccs_master->question[op_ques_in].request[op_req_cnt].request_status != dccs_master->
          question[op_ques_in].request[op_req_cnt].request_status_orig))
           UPDATE  FROM dm_cb_request_processing r
            SET r.request_status = dccs_master->question[op_ques_in].request[op_req_cnt].
             request_status, r.updt_applctx = 111, r.updt_cnt = (r.updt_cnt+ 1),
             r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_task = 555
            WHERE (r.request_number=dccs_master->question[op_ques_in].request[op_req_cnt].
            request_number)
             AND (r.format_script=dccs_master->question[op_ques_in].request[op_req_cnt].format_script
            )
            WITH nocounter
           ;end update
           CALL dcm_log_hist("CHAR",dccs_master->question[op_ques_in].request[op_req_cnt].
            request_status_orig,dccs_master->question[op_ques_in].request[op_req_cnt].request_status,
            "REQUEST_STATUS",dccs_master->question[op_ques_in].question_nbr,
            "DM_CB_REQUEST_PROCESSING",dccs_master->question[op_ques_in].request[op_req_cnt].
            request_number,dccs_master->question[op_ques_in].question_answer_num_db)
          ENDIF
        ENDFOR
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dcm_process_operations(dpo_ques_in,dpo_op_mode)
   FOR (dpo_ans_cnt = 1 TO size(dccs_master->question[dpo_ques_in].answer,5))
    IF (dpo_op_mode="Y")
     SET dpo_answer = dccs_master->question[dpo_ques_in].answer[dpo_ans_cnt].answer_status_db
    ELSE
     SET dpo_answer = dccs_master->question[dpo_ques_in].answer[dpo_ans_cnt].answer_status_new
    ENDIF
    IF (dpo_answer="SELECTED"
     AND findstring("BUILD",dccs_master->question[dpo_ques_in].answer[dpo_ans_cnt].action)=0)
     IF (size(dccs_master->question[dpo_ques_in].object,5) > 0)
      FOR (dpo_obj_cnt = 1 TO size(dccs_master->question[dpo_ques_in].object,5))
        FOR (dpo_op_cnt = 1 TO size(dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].op,5))
          IF (findstring("BUILD",cnvtupper(dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].
            object_status))=0)
           CALL echo(dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].op[dpo_op_cnt].operations
            )
           CALL parser(dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].op[dpo_op_cnt].
            operations,1)
           CALL dcm_error(null)
           IF ((dcm_info->fail_flag=1))
            SET dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].op[dpo_op_cnt].op_status =
            concat(dcm_info->err_msg," ",dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].op[
             dpo_op_cnt].op_status)
           ENDIF
           INSERT  FROM dm_cb_history
            SET history_id = seq(dm_clinical_seq,nextval), table_name = "OP Logging", column_name =
             "OP Logging",
             request_number = 0, change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_txt =
             dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].object_status,
             new_value_txt = dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].op[dpo_op_cnt].
             operations, change_reason = "Performing operations.", change_process = evaluate(
              dpo_answer,"Y","DM_CB_SCAN_FOR_EXECUTE","DM_CB_CUSTOMIZE_ENV"),
             question_nbr = dccs_master->question[dpo_ques_in].question_nbr, answer_nbr = dccs_master
             ->question[dpo_ques_in].answer[dpo_ans_cnt].answer_nbr
            WITH nocounter
           ;end insert
           IF ( NOT (findstring("coalesce",dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].op[
            dpo_op_cnt].operations)))
            IF ((dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].object_type="INDEX"))
             IF (ms_index_missing(dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].object_name)
             =0)
              SET dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].op[dpo_op_cnt].op_status =
              concat(dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].op[dpo_op_cnt].op_status,
               " ","NOT SUCCESSFUL, INDEX STILL EXISTS IN DM2_USER_INDEXES")
              SET dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].op[dpo_op_cnt].
              op_success_ind = 1
             ENDIF
            ELSEIF ((dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].object_type="TABLE"))
             IF (ms_table_missing(dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].object_name)
             =0)
              SET dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].op[dpo_op_cnt].op_status =
              concat(dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].op[dpo_op_cnt].op_status,
               " ","NOT SUCCESSFUL, TABLE STILL EXISTS IN DM2_USER_TABLES")
              SET dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].op[dpo_op_cnt].
              op_success_ind = 1
             ENDIF
            ELSEIF ((dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].object_type="TRIGGER"))
             IF (mt_trigger_missing(dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].
              object_name,dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].table_name)=0)
              SET dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].op[dpo_op_cnt].op_status =
              concat(dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].op[dpo_op_cnt].op_status,
               " ","NOT SUCCESSFUL, TRIGGER STILL EXISTS IN DM2_USER_TRIGGERS")
              SET dccs_master->question[dpo_ques_in].object[dpo_obj_cnt].op[dpo_op_cnt].
              op_success_ind = 1
             ENDIF
            ENDIF
           ENDIF
          ENDIF
        ENDFOR
      ENDFOR
     ENDIF
     IF (size(dccs_master->question[dpo_ques_in].request,5) > 0)
      FOR (dpo_obj_cnt = 1 TO size(dccs_master->question[dpo_ques_in].request,5))
        FOR (dpo_op_cnt = 1 TO size(dccs_master->question[dpo_ques_in].request[dpo_obj_cnt].op,5))
          CALL echo(dccs_master->question[dpo_ques_in].request[dpo_obj_cnt].op[dpo_op_cnt].operations
           )
          CALL parser(dccs_master->question[dpo_ques_in].request[dpo_obj_cnt].op[dpo_op_cnt].
           operations)
          INSERT  FROM dm_cb_history
           SET history_id = seq(dm_clinical_seq,nextval), table_name = "OP Logging", column_name =
            "OP Logging",
            request_number = dccs_master->question[dpo_ques_in].request[dpo_obj_cnt].request_number,
            change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_txt = dccs_master->question[
            dpo_ques_in].request[dpo_obj_cnt].request_status,
            new_value_txt = dccs_master->question[dpo_ques_in].request[dpo_obj_cnt].op[dpo_op_cnt].
            operations, change_reason = "Performing operations.", change_process = evaluate(
             dpo_answer,"Y","DM_CB_SCAN_FOR_EXECUTE","DM_CB_CUSTOMIZE_ENV"),
            question_nbr = dccs_master->question[dpo_ques_in].question_nbr, answer_nbr = dccs_master
            ->question[dpo_ques_in].answer[dpo_ans_cnt].answer_nbr
           WITH nocounter
          ;end insert
          IF ((dccs_master->question[dpo_ques_in].request[dpo_obj_cnt].request_status="ACTIVE"))
           IF (rp_request_missing(dccs_master->question[dpo_ques_in].request[dpo_obj_cnt].
            request_number,dccs_master->question[dpo_ques_in].request[dpo_obj_cnt].format_script,1)=1
           )
            SET dccs_master->question[dpo_ques_in].request[dpo_obj_cnt].op[dpo_op_cnt].op_status =
            concat(dccs_master->question[dpo_ques_in].request[dpo_obj_cnt].op[dpo_op_cnt].op_status,
             " ","REQUEST ACTIVATION OPERATION NOT SUCCESSFUL")
            SET dccs_master->question[dpo_ques_in].request[dpo_obj_cnt].op[dpo_op_cnt].op_success_ind
             = 1
           ENDIF
          ELSE
           IF (rp_request_missing(dccs_master->question[dpo_ques_in].request[dpo_obj_cnt].
            request_number,dccs_master->question[dpo_ques_in].request[dpo_obj_cnt].format_script,0)=1
           )
            SET dccs_master->question[dpo_ques_in].request[dpo_obj_cnt].op[dpo_op_cnt].op_status =
            concat(dccs_master->question[dpo_ques_in].request[dpo_obj_cnt].op[dpo_op_cnt].op_status,
             " ","REQUEST INACTIVATION OPERATION NOT SUCCESSFUL")
            SET dccs_master->question[dpo_ques_in].request[dpo_obj_cnt].op[dpo_op_cnt].op_success_ind
             = 1
           ENDIF
          ENDIF
        ENDFOR
      ENDFOR
     ENDIF
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE dcm_check_op_success(dos_interactive,dos_ques_in)
   SET dcm_error_operation = 0
   IF (size(dccs_master->question[dos_ques_in].object,5) > 0)
    FOR (dpo_obj_cnt = 1 TO size(dccs_master->question[dos_ques_in].object,5))
      FOR (dpo_op_cnt = 1 TO size(dccs_master->question[dos_ques_in].object[dpo_obj_cnt].op,5))
        IF ((dccs_master->question[dos_ques_in].object[dpo_obj_cnt].op[dpo_op_cnt].op_success_ind=1))
         SET dcm_error_operation = 1
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF (size(dccs_master->question[dos_ques_in].request,5) > 0)
    FOR (dpo_obj_cnt = 1 TO size(dccs_master->question[dos_ques_in].request,5))
      FOR (dpo_op_cnt = 1 TO size(dccs_master->question[dos_ques_in].request[dpo_obj_cnt].op,5))
        IF ((dccs_master->question[dos_ques_in].request[dpo_obj_cnt].op[dpo_op_cnt].op_success_ind=1)
        )
         SET dcm_error_operation = 1
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE dcm_create_error_log(dcm_program_name,log_ques_in)
   DECLARE dcm_logfile_name = c132
   DECLARE log_obj_cnt = i4
   DECLARE log_ques_cnt = i4
   DECLARE log_op_cnt = i4
   DECLARE log_text = c255
   SET log_obj_cnt = 0
   SET log_ques_cnt = 0
   SET log_op_cnt = 0
   IF ((dccs_master->dccs_logfile=""))
    SET dcm_logfile_name = concat("CCLUSERDIR:",dcm_program_name,trim(cnvtstring(cnvtdatetime(curdate,
        curtime3))),".log")
    SET dccs_master->dccs_logfile = dcm_logfile_name
    SET logical logfile_hold dcm_logfile_name
   ENDIF
   SELECT INTO logfile_hold
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     FOR (log_ques_cnt = log_ques_in TO log_ques_in)
       col 1, "Question_nbr corresponds to the question_nbr in DM_CB_QUESTIONS.", row + 1,
       dcm_text = concat("Question_nbr: ",cnvtstring(dccs_master->question[log_ques_cnt].question_nbr
         )), col 1, dcm_text,
       row + 1, col 1, "================================",
       row + 1
       IF (size(dccs_master->question[log_ques_cnt].object,5) > 0)
        FOR (log_obj_cnt = 1 TO size(dccs_master->question[log_ques_cnt].object,5))
          FOR (log_op_cnt = 1 TO size(dccs_master->question[log_ques_cnt].object[log_obj_cnt].op,5))
            IF ( NOT (findstring("coalesce",dccs_master->question[log_ques_cnt].object[log_obj_cnt].
             op[log_op_cnt].operations)))
             IF ((dccs_master->question[log_ques_cnt].object[log_obj_cnt].op[log_op_cnt].
             op_success_ind=1))
              log_text = concat(dccs_master->question[log_ques_cnt].object[log_obj_cnt].object_type,
               ":",dccs_master->question[log_ques_cnt].object[log_obj_cnt].object_name), row + 1, col
               1,
              log_text, row + 1, log_text = concat("ERROR MESSAGE:",dccs_master->question[
               log_ques_cnt].object[log_obj_cnt].op[log_op_cnt].op_status),
              col 4, log_text, row + 1,
              col 4, "OPERATION BEING PERFORMED: ", row + 1,
              col 6, dccs_master->question[log_ques_cnt].object[log_obj_cnt].op[log_op_cnt].
              operations, row + 2
             ENDIF
            ENDIF
          ENDFOR
        ENDFOR
       ENDIF
       IF (size(dccs_master->question[log_ques_cnt].request,5) > 0)
        FOR (log_obj_cnt = 1 TO size(dccs_master->question[log_ques_cnt].request,5))
          FOR (log_op_cnt = 1 TO size(dccs_master->question[log_ques_cnt].request[log_obj_cnt].op,5))
            IF ((dccs_master->question[log_ques_cnt].request[log_obj_cnt].op[log_op_cnt].
            op_success_ind=1))
             log_text = concat(cnvtstring(dccs_master->question[log_ques_cnt].request[log_obj_cnt].
               request_number),":",dccs_master->question[log_ques_cnt].request[log_obj_cnt].
              format_script), row + 1, col 1,
             log_text, row + 1, log_text = concat("ERROR MESSAGE:",dccs_master->question[log_ques_cnt
              ].request[log_obj_cnt].op[log_op_cnt].op_status),
             col 4, log_text, row + 1,
             col 4, "OPERATION BEING PERFORMED: ", row + 1,
             col 6, dccs_master->question[log_ques_cnt].request[log_obj_cnt].op[log_op_cnt].
             operations, row + 2
            ENDIF
          ENDFOR
        ENDFOR
       ENDIF
     ENDFOR
    WITH nocounter, formfeed = none, maxcol = 525,
     format = stream, noheading, append
   ;end select
 END ;Subroutine
 SUBROUTINE dcm_get_answers(get_ans_ques)
   DECLARE dcm_ans_ndx_cnt = i4
   DECLARE ans_select_mode = i2
   SET ans_select_mode = 0
   IF (get_ans_ques="ALL")
    SET ans_select_mode = 0
   ELSE
    SET ans_select_mode = 1
   ENDIF
   SELECT
    IF (ans_select_mode=0)INTO "nl:"
     FROM dm_cb_questions q,
      dm_cb_answers a
     PLAN (a
      WHERE a.active_ind=1)
      JOIN (q
      WHERE q.active_ind=1
       AND q.question_nbr=a.question_nbr)
     ORDER BY q.question_nbr
    ELSE INTO "nl:"
     FROM dm_cb_questions q,
      dm_cb_answers a
     PLAN (a
      WHERE a.active_ind=1)
      JOIN (q
      WHERE q.active_ind=1
       AND q.question_nbr=a.question_nbr
       AND q.question_nbr=cnvtint(get_ans_ques))
     ORDER BY q.question_nbr
    ENDIF
    HEAD REPORT
     dccs_ans_cnt = 0, dccs_ndx = 0
    HEAD q.question_nbr
     dccs_ans_cnt = 0, dcm_ans_ndx_cnt = 0, dccs_ndx = 0
     FOR (dcm_ans_ndx_cnt = 1 TO size(dccs_master->question,5))
       IF ((q.question_nbr=dccs_master->question[dcm_ans_ndx_cnt].question_nbr))
        dccs_ndx = dcm_ans_ndx_cnt, dcm_ans_ndx_cnt = size(dccs_master->question,5)
       ENDIF
     ENDFOR
     IF (dccs_ndx > 0)
      dccs_master->question[dccs_ndx].question_options = ""
     ENDIF
    DETAIL
     IF (dccs_ndx > 0)
      dccs_ans_cnt = (dccs_ans_cnt+ 1)
      IF (mod(dccs_ans_cnt,10)=1)
       stat = alterlist(dccs_master->question[dccs_ndx].answer,(dccs_ans_cnt+ 9))
      ENDIF
      dccs_master->question[dccs_ndx].answer[dccs_ans_cnt].question_nbr = a.question_nbr, dccs_master
      ->question[dccs_ndx].answer[dccs_ans_cnt].answer_nbr = a.answer_nbr, dccs_master->question[
      dccs_ndx].answer[dccs_ans_cnt].answer = a.answer,
      dccs_master->question[dccs_ndx].question_answer = ""
      IF (a.answer_status="SELECTED")
       dccs_master->question[dccs_ndx].answer[dccs_ans_cnt].answer_orig = a.answer, dccs_master->
       question[dccs_ndx].question_answer_db = a.answer, dccs_master->question[dccs_ndx].
       question_answer_num_db = a.answer_nbr
      ENDIF
      IF ((dccs_master->question[dccs_ndx].question_options=""))
       dccs_master->question[dccs_ndx].question_options = a.answer
      ELSE
       dccs_master->question[dccs_ndx].question_options = concat(dccs_master->question[dccs_ndx].
        question_options,",",a.answer)
      ENDIF
      dccs_master->question[dccs_ndx].answer[dccs_ans_cnt].answer_status_db = a.answer_status,
      dccs_master->question[dccs_ndx].answer[dccs_ans_cnt].action = a.action, dccs_master->question[
      dccs_ndx].answer[dccs_ans_cnt].action_status = a.action_status,
      dccs_master->question[dccs_ndx].answer[dccs_ans_cnt].answer_status_old = a.answer_status,
      dccs_master->question[dccs_ndx].answer[dccs_ans_cnt].answer_status_new = "", dccs_master->
      question[dccs_ndx].answer[dccs_ans_cnt].ignore_first_ind = a.ignore_first_ind,
      dccs_master->question[dccs_ndx].answer[dccs_ans_cnt].ignore_first_ind_db = a.ignore_first_ind
     ENDIF
    FOOT  q.question_nbr
     stat = alterlist(dccs_master->question[dccs_ndx].answer,dccs_ans_cnt)
    FOOT REPORT
     dccs_ans_cnt = 0
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE dcm_get_objects(get_obj_ques)
   DECLARE dcm_obj_ndx_cnt = i4
   DECLARE get_select_mode = i2
   SET dccs_ndx = 0
   SET dccs_obj_cnt = 0
   SET get_select_mode = 0
   IF (get_obj_ques="ALL")
    SET get_select_mode = 0
   ELSE
    SET get_select_mode = 1
   ENDIF
   SELECT
    IF (get_select_mode=0)INTO "nl:"
     FROM dm_cb_questions q,
      dm_cb_objects a
     PLAN (a
      WHERE a.active_ind=1)
      JOIN (q
      WHERE q.active_ind=1
       AND q.question_nbr=a.question_nbr)
     ORDER BY q.question_nbr
    ELSE INTO "nl:"
     FROM dm_cb_questions q,
      dm_cb_objects a
     PLAN (a
      WHERE a.active_ind=1)
      JOIN (q
      WHERE q.active_ind=1
       AND q.question_nbr=cnvtint(get_obj_ques)
       AND q.question_nbr=a.question_nbr)
     ORDER BY q.question_nbr
    ENDIF
    HEAD REPORT
     dccs_obj_cnt = 0
    HEAD q.question_nbr
     dcm_obj_ndx_cnt = 0, dccs_obj_cnt = 0
    DETAIL
     dccs_ndx = 0
     FOR (dcm_obj_ndx_cnt = 1 TO size(dccs_master->question,5))
       IF ((q.question_nbr=dccs_master->question[dcm_obj_ndx_cnt].question_nbr))
        dccs_ndx = dcm_obj_ndx_cnt, dcm_obj_ndx_cnt = size(dccs_master->question,5)
       ENDIF
     ENDFOR
     IF (dccs_ndx > 0)
      dccs_obj_cnt = (dccs_obj_cnt+ 1)
      IF (mod(dccs_obj_cnt,10)=1)
       stat = alterlist(dccs_master->question[dccs_ndx].object,(dccs_obj_cnt+ 9))
      ENDIF
      dccs_master->question[dccs_ndx].object[dccs_obj_cnt].object_name = a.object_name, dccs_master->
      question[dccs_ndx].object[dccs_obj_cnt].object_active = a.active_ind, dccs_master->question[
      dccs_ndx].object[dccs_obj_cnt].object_type = a.object_type,
      dccs_master->question[dccs_ndx].object[dccs_obj_cnt].object_status_orig = a.object_status,
      dccs_master->question[dccs_ndx].object[dccs_obj_cnt].object_status = a.object_status,
      dccs_master->question[dccs_ndx].object[dccs_obj_cnt].table_name = a.table_name,
      stat = alterlist(dccs_master->question[dccs_ndx].object[dccs_obj_cnt].op,0)
     ENDIF
    FOOT  q.question_nbr
     stat = alterlist(dccs_master->question[dccs_ndx].object,dccs_obj_cnt)
    FOOT REPORT
     dccs_obj_cnt = 0
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE dcm_get_requests(get_req_ques)
   DECLARE req_select_mode = i2
   SET req_select_mode = 0
   SET dccs_ndx = 0
   SET dccs_req_cnt = 0
   IF (get_req_ques="ALL")
    SET req_select_mode = 0
   ELSE
    SET req_select_mode = 1
   ENDIF
   SELECT
    IF (req_select_mode=0)INTO "nl:"
     FROM dm_cb_questions q,
      dm_cb_request_processing r
     PLAN (r
      WHERE r.active_ind=1)
      JOIN (q
      WHERE q.active_ind=1
       AND q.question_nbr=r.question_nbr)
     ORDER BY q.question_nbr
    ELSE INTO "nl:"
     FROM dm_cb_questions q,
      dm_cb_request_processing r
     PLAN (r
      WHERE r.active_ind=1)
      JOIN (q
      WHERE q.active_ind=1
       AND q.question_nbr=cnvtint(get_req_ques)
       AND q.question_nbr=r.question_nbr)
     ORDER BY q.question_nbr
    ENDIF
    HEAD REPORT
     dccs_req_cnt = 0
    HEAD q.question_nbr
     dccs_req_cnt = 0
    DETAIL
     rp_found = 1, dccs_ndx = 0, dccs_request_ndx = 0
     FOR (dccs_ndx = 1 TO size(dccs_master->question,5))
       IF ((q.question_nbr=dccs_master->question[dccs_ndx].question_nbr))
        rp_found = 0, dccs_request_ndx = dccs_ndx
       ENDIF
     ENDFOR
     IF (rp_found=0)
      dccs_req_cnt = (dccs_req_cnt+ 1)
      IF (mod(dccs_req_cnt,10)=1)
       stat = alterlist(dccs_master->question[dccs_request_ndx].request,(dccs_req_cnt+ 9))
      ENDIF
      dccs_master->question[dccs_request_ndx].request[dccs_req_cnt].request_number = r.request_number,
      dccs_master->question[dccs_request_ndx].request[dccs_req_cnt].active_ind = r.active_ind,
      dccs_master->question[dccs_request_ndx].request[dccs_req_cnt].format_script = r.format_script,
      dccs_master->question[dccs_request_ndx].request[dccs_req_cnt].request_status = r.request_status,
      dccs_master->question[dccs_request_ndx].request[dccs_req_cnt].request_status_orig = r
      .request_status, dccs_master->question[dccs_request_ndx].request_op_cnt = 0
     ENDIF
    FOOT  q.question_nbr
     stat = alterlist(dccs_master->question[dccs_request_ndx].request,dccs_req_cnt)
    FOOT REPORT
     dccs_req_cnt = 0
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE dcm_get_questions(dcm_select_ques)
   DECLARE dcm_all_ques = i2
   SET dccs_ques_cnt = 0
   IF (dcm_select_ques="ALL")
    SET dcm_all_ques = 0
   ELSE
    SET dcm_all_ques = 1
   ENDIF
   SELECT
    IF (dcm_all_ques=0)INTO "nl:"
     FROM dm_cb_questions q
     WHERE q.active_ind=1
     ORDER BY q.question_order_seq
    ELSE INTO "nl:"
     FROM dm_cb_questions q
     WHERE q.active_ind=1
      AND q.question_nbr=cnvtint(dcm_select_ques)
     ORDER BY q.question_order_seq
    ENDIF
    HEAD REPORT
     dccs_ques_cnt = 0, stat = alterlist(dccs_master->question,100)
    DETAIL
     dccs_ques_cnt = (dccs_ques_cnt+ 1)
     IF (mod(dccs_ques_cnt,10)=1)
      stat = alterlist(dccs_master->question,(dccs_ques_cnt+ 9))
     ENDIF
     dccs_master->question[dccs_ques_cnt].question_full = "", dccs_master->question[dccs_ques_cnt].
     question_full = trim(q.question)
     IF (findstring(" ",dccs_master->question[dccs_ques_cnt].question_full))
      dccs_master->question[dccs_ques_cnt].question_full = concat(trim(replace(trim(dccs_master->
          question[dccs_ques_cnt].question_full)," ","$",0)),"*")
     ELSE
      dccs_master->question[dccs_ques_cnt].question_full = concat(trim(dccs_master->question[
        dccs_ques_cnt].question_full),"*")
     ENDIF
     dccs_master->question[dccs_ques_cnt].question_nbr = q.question_nbr, dccs_master->question[
     dccs_ques_cnt].question_full_unedit = trim(q.question), dccs_master->question[dccs_ques_cnt].
     ask_flag = q.ask_flag,
     dccs_master->question[dccs_ques_cnt].question_order_seq = q.question_order_seq, dccs_master->
     question[dccs_ques_cnt].question_object_cnt = 0, dccs_master->question[dccs_ques_cnt].
     question_answer = "",
     dccs_master->question[dccs_ques_cnt].question_answer_db = ""
    FOOT REPORT
     stat = alterlist(dccs_master->question,dccs_ques_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE execute_actions(codb_action_in)
   CALL parser(codb_action_in,1)
 END ;Subroutine
 SUBROUTINE mt_trigger_missing(mt_trigger,mt_table)
   DECLARE t_flag = i2
   SET t_flag = 1
   SELECT INTO "nl:"
    FROM user_triggers t
    WHERE t.trigger_name=patstring(cnvtupper(trim(mt_trigger,3)))
     AND t.table_name=mt_table
    DETAIL
     t_flag = 0
    WITH nocounter
   ;end select
   RETURN(t_flag)
 END ;Subroutine
 SUBROUTINE ms_table_missing(ms_table)
   DECLARE t_flag = i2
   SET t_flag = 1
   SELECT INTO "nl:"
    t.table_name
    FROM user_tables t
    WHERE t.table_name=cnvtupper(trim(ms_table,3))
    DETAIL
     t_flag = 0
    WITH nocounter
   ;end select
   RETURN(t_flag)
 END ;Subroutine
 SUBROUTINE ms_index_missing(ms_index)
   DECLARE i_flag = i2
   SET i_flag = 1
   SELECT INTO "nl:"
    FROM user_indexes t
    WHERE t.index_name=cnvtupper(trim(ms_index,3))
    DETAIL
     i_flag = 0
    WITH nocounter
   ;end select
   RETURN(i_flag)
 END ;Subroutine
 SUBROUTINE rp_request_missing(rp_request,rp_script,rp_active)
   DECLARE r_flag = i2
   SET r_flag = 1
   SELECT
    IF (rp_script="X")
     FROM request_processing r
     WHERE r.format_script=" "
      AND r.request_number=rp_request
      AND r.active_ind=rp_active
    ELSEIF (rp_script="NULLIFY")
     FROM request_processing r
     WHERE r.format_script = null
      AND r.request_number=rp_request
      AND r.active_ind=rp_active
    ELSE
     FROM request_processing r
     WHERE r.format_script=cnvtupper(trim(rp_script,3))
      AND r.request_number=rp_request
      AND r.active_ind=rp_active
    ENDIF
    INTO "nl:"
    DETAIL
     r_flag = 0
    WITH nocounter
   ;end select
   RETURN(r_flag)
 END ;Subroutine
 SUBROUTINE dcm_error(null)
   DECLARE dcm_err_msg = c132
   SET dcm_info->fail_flag = 0
   IF (error(dcm_err_msg,0) > 0)
    SET dcm_info->err_msg = dcm_err_msg
    SET dcm_info->fail_flag = 1
   ENDIF
 END ;Subroutine
 SET message = window
 DECLARE dcm_cont = i2
 DECLARE dcm_line_cnt = i4
 DECLARE dcm_togo = i4
 DECLARE dcm_txt = c132
 DECLARE dcm_place_hold = i4
 DECLARE dcm_cur_rows = i4
 DECLARE dcm_up_start = i4
 DECLARE dcm_reached_end = i2
 DECLARE dcm_down_start = i4
 DECLARE ques_seq_hold = c132
 DECLARE start_place = i4
 DECLARE dccs_cnt = i4
 DECLARE found_spacer = i4
 DECLARE end_not_reached = i2
 DECLARE find_place_hold = i4
 DECLARE dcm_disp_mode = c1
 DECLARE dcm_first = i2
 DECLARE user_select = i2
 DECLARE reset_return = i2
 DECLARE dccs_ndx = i4
 DECLARE dccs_obj_cnt = i4
 DECLARE dccs_ans_cnt = i4
 DECLARE dccs_ques_cnt = i4
 DECLARE answer_size = i4
 DECLARE answer_cnt = i4
 DECLARE ques_cnt = i4
 DECLARE ques_size = i4
 DECLARE dcm_con_approve_ind = i2
 DECLARE dcm_ignore = i2
 DECLARE user_canceled_ind = i2
 DECLARE run_mode = i2
 DECLARE allow_view = i2
 DECLARE report_perform = i2
 DECLARE dcm_ask_cnt = i4
 DECLARE dcm_ask_found = i2
 DECLARE dcm_scroll_unanswered = i2
 DECLARE inhouse_ind = i2
 DECLARE last_message = c80
 DECLARE dcce_ebookings_ind = i2
 DECLARE dcce_rhio_ind = i2
 SET inhouse_ind = 0
 SELECT INTO "nl:"
  FROM dm_info
  WHERE info_domain="DATA MANAGEMENT"
   AND info_name="INHOUSE DOMAIN"
  DETAIL
   inhouse_ind = 1
  WITH nocounter
 ;end select
 SET dcm_scroll_unanswered = 1
 SET run_mode = 1
 DECLARE dm_cb_menu(null) = null WITH pubic
 DECLARE dcm_header(null) = null WITH public
 DECLARE dcm_footer(dcm_disp_dir) = null WITH public
 DECLARE dcm_disp_ques(dcm_start_row,goto_mode) = null WITH public
 DECLARE dcm_allow_ans(dcm_line_in) = null WITH public
 DECLARE dcm_clear_ques(null) = null WITH public
 DECLARE dcm_modify(null) = null WITH public
 DECLARE dcm_goto_ques(null) = null
 DECLARE dcm_reset(null) = null WITH public
 DECLARE dcm_inform_user(inform_type,iu_message) = i2 WITH public
 DECLARE dcm_confirm(confirm_ques_in) = null WITH public
 DECLARE display_confirmation_report(con_ques_ndx,con_local_nbr) = null WITH public
 DECLARE dcm_confirm_approval(null) = i2 WITH public
 DECLARE dcm_reset_ops(dcm_reset_ques_in,dcm_type_in) = null WITH public
 DECLARE dcm_allques_screen(das_mode) = null WITH public
 DECLARE dcm_reprocess(rp_ques_in) = null WITH public
 DECLARE dcm_check_exe(rp_ques_in,rp_ans_in) = i2 WITH public
 SET start_place = 0
 SET end_place = 0
 SET seg_cnt = 0
 SET dccs_cnt = 0
 SET found_spacer = 0
 SET end_place = 70
 SET seg_cnt = 0
 SET end_not_reached = 0
 SET find_place_hold = 0
 SET dcm_scroll_first = 0
 SET dcce_ebookings_ind = 0
 SET dcce_rhio_ind = 0
 SELECT INTO "nl:"
  FROM dm_info
  WHERE info_domain="DATA MANAGEMENT"
   AND info_name="RHIO DOMAIN"
  DETAIL
   dcce_rhio_ind = 1
  WITH nocounter
 ;end select
 IF (dcce_rhio_ind=0)
  UPDATE  FROM dm_cb_questions q
   SET q.active_ind = 0
   WHERE q.question_nbr=9
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info
  WHERE info_domain="DATA MANAGEMENT"
   AND info_name="EBOOKINGS DOMAIN"
  DETAIL
   dcce_ebookings_ind = 1
  WITH nocounter
 ;end select
 IF (dcce_ebookings_ind=0)
  UPDATE  FROM dm_cb_questions q
   SET q.active_ind = 0
   WHERE q.question_nbr=8
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 CALL dcm_get_questions("ALL")
 CALL dcm_get_answers("ALL")
 CALL dcm_get_objects("ALL")
 CALL dcm_get_requests("ALL")
 FOR (dccs_cnt = 1 TO size(dccs_master->question,5))
   SET seg_cnt = 0
   SET end_not_reached = 0
   SET start_place = 0
   IF (size(dccs_master->question[dccs_cnt].question_full) > 90)
    WHILE (end_not_reached=0)
      SET seg_cnt = (seg_cnt+ 1)
      IF (mod(seg_cnt,10)=1)
       SET stat = alterlist(dccs_master->question[dccs_cnt].question_break,(seg_cnt+ 9))
      ENDIF
      SET ques_seg_hold = substring((start_place+ 1),end_place,dccs_master->question[dccs_cnt].
       question_full)
      SET find_place_hold = findstring("*",ques_seg_hold)
      IF (find_place_hold > 0)
       SET dccs_master->question[dccs_cnt].question_break[seg_cnt].question_segment = trim(
        ques_seg_hold)
       SET dccs_master->question[dccs_cnt].question_break[seg_cnt].question_segment = replace(
        ques_seg_hold,"*"," ",0)
       SET dccs_master->question[dccs_cnt].question_break[seg_cnt].question_segment = replace(
        dccs_master->question[dccs_cnt].question_break[seg_cnt].question_segment,"$"," ",0)
       SET dccs_master->question[dccs_cnt].question_break[seg_cnt].question_break_seq = seg_cnt
       SET end_not_reached = 1
       SET start_place = 1
      ELSE
       SET found_spacer = findstring("$",ques_seg_hold,1,1)
       SET dccs_master->question[dccs_cnt].question_break[seg_cnt].question_segment = substring(1,
        found_spacer,ques_seg_hold)
       SET dccs_master->question[dccs_cnt].question_break[seg_cnt].question_segment = replace(
        dccs_master->question[dccs_cnt].question_break[seg_cnt].question_segment,"$"," ",0)
       SET dccs_master->question[dccs_cnt].question_break[seg_cnt].question_break_seq = seg_cnt
      ENDIF
      SET start_place = (start_place+ found_spacer)
    ENDWHILE
    SET stat = alterlist(dccs_master->question[dccs_cnt].question_break,seg_cnt)
   ELSE
    SET seg_cnt = (seg_cnt+ 1)
    SET stat = alterlist(dccs_master->question[dccs_cnt].question_break,1)
    SET dccs_master->question[dccs_cnt].question_break[seg_cnt].question_segment = replace(
     dccs_master->question[dccs_cnt].question_full,"$"," ",0)
    SET dccs_master->question[dccs_cnt].question_break[seg_cnt].question_segment = replace(
     dccs_master->question[dccs_cnt].question_break[seg_cnt].question_segment,"*"," ",0)
    SET stat = alterlist(dccs_master->question[dccs_cnt].question_break,seg_cnt)
    SET dccs_master->question[dccs_cnt].question_break[seg_cnt].question_break_seq = seg_cnt
   ENDIF
 ENDFOR
 CALL dcm_allques_screen(1)
 CALL dm_cb_menu(null)
 SUBROUTINE dm_cb_menu(null)
   DECLARE dcm_starting_point = i4
   DECLARE dcm_start_cnt = i4
   DECLARE dcm_found_start = i2
   SET dcm_found_start = 0
   SET dcm_starting_point = 0
   SET dcm_start_cnt = 0
   CALL clear(1,1)
   SET width = 132
   SET dcm_first = 0
   WHILE (dcm_cont=0)
     CALL dcm_header(null)
     IF (dcm_place_hold=0)
      FOR (dcm_start_cnt = 1 TO size(dccs_master->question,5))
        IF ((dccs_master->question[dcm_start_cnt].ask_flag=1))
         SET dcm_starting_point = dcm_start_cnt
         SET dcm_found_start = 1
         SET dcm_start_cnt = size(dccs_master->question,5)
        ENDIF
      ENDFOR
     ELSE
      CALL dcm_disp_ques(dcm_place_hold,0)
     ENDIF
     IF (dcm_first=0)
      IF (dcm_reached_end=0)
       CALL dcm_footer("N")
       IF (dcm_found_start=1)
        IF (dcm_place_hold != 0)
         CALL dcm_disp_ques(dcm_place_hold,0)
         CALL dcm_message(last_message)
        ELSE
         CALL dcm_disp_ques(dcm_starting_point,0)
         CALL dcm_message("More questions remain. Press 'D' to Scroll Down.")
        ENDIF
       ELSE
        CALL dcm_message(
         "There are no unanswered questions. Run menu in Answered Questions ('A') mode.")
       ENDIF
      ELSE
       CALL dcm_footer("N")
      ENDIF
     ENDIF
     SET dcm_first = 1
     CALL accept(22,9,"C;CU","Q"
      WHERE cnvtupper(curaccept) IN ("M", "Q", "R", "D", "U",
      "C", "V", "G", "P", "L",
      "A", "N"))
     CASE (curaccept)
      OF "M":
       CALL dcm_message("User selected to modify answer.")
       IF (((dcm_disp_mode IN ("D", "U", "N", " ", "M",
       "")
        AND inhouse_ind != 1
        AND (dccs_master->question[dcm_togo].ask_flag=1)
        AND dcm_scroll_unanswered IN (1, 0)) OR (dcm_disp_mode IN ("D", "U", "N", " ", "M",
       "")
        AND inhouse_ind != 1
        AND (dccs_master->question[dcm_togo].ask_flag=0)
        AND dcm_scroll_unanswered IN (0))) )
        SET dcm_disp_mode = "M"
        CALL dcm_footer(dcm_disp_mode)
        CALL dcm_modify(null)
        CALL dcm_allow_ans(11)
        IF (dcm_check_exe(dccs_master->question[dcm_togo].question_nbr,dccs_master->question[dcm_togo
         ].question_answer)=1
         AND user_canceled_ind != 1)
         CALL dcm_message("Answer has been executed before.")
         SET dcm_disp_mode = "N"
         CALL dcm_footer(dcm_disp_mode)
        ELSE
         CALL dcm_message("Modifying answer....")
         SET report_perform = 0
         IF (user_canceled_ind != 1)
          IF (size(dccs_master->question[dcm_togo].object,5) > 0)
           IF ((dccs_master->question[dcm_togo].question_object_cnt > 0))
            SET report_perform = 1
           ENDIF
          ENDIF
          IF (size(dccs_master->question[dcm_togo].request,5) > 0)
           IF ((dccs_master->question[dcm_togo].request_op_cnt > 0))
            SET report_perform = 1
           ENDIF
          ENDIF
          IF (dcm_ignore=1
           AND report_perform=0)
           SET report_perform = 1
          ENDIF
          IF (report_perform=1)
           CALL display_confirmation_report(dcm_togo,trim(cnvtstring(dccs_master->question[dcm_togo].
              question_order_seq)))
           IF (dcm_con_approve_ind=1)
            IF (dcm_confirm_approval(null)=1)
             CALL dcm_message("Performing operations....")
             CALL dcm_process_operations(dcm_togo,"N")
             CALL dcm_check_op_success(run_mode,dcm_togo)
             CALL dcm_footer(dcm_disp_mode)
             IF (dcm_error_operation=1)
              CALL dcm_postop_updates(dcm_togo,"Y")
              CALL dcm_create_error_log("DM_CB_CUSTOMIZE_ENV",dcm_togo)
              SET dcm_txt = concat("An error occurred. Logfile is ",dccs_master->dccs_logfile,
               ". Press 'L' to view log.")
              SET allow_view = 1
              CALL dcm_message(dcm_txt)
              SET dcm_disp_mode = "N"
              CALL dcm_footer(dcm_disp_mode)
              COMMIT
             ELSE
              SET allow_view = 0
              CALL dcm_message("Operations have been performed. Recording Actions....")
              CALL dcm_postop_updates(dcm_togo,"N")
              COMMIT
             ENDIF
             IF ((dccs_master->question[dcm_togo].question_object_cnt > 0))
              CALL dcm_reset_ops(dcm_togo,"OBJECT")
             ELSEIF ((dccs_master->question[dcm_togo].request_op_cnt > 0))
              CALL dcm_reset_ops(dcm_togo,"REQUEST")
             ENDIF
             CALL dcm_reset(null)
             IF (dcm_error_operation=0)
              CALL dcm_message("Actions have been recorded.")
             ENDIF
             SET dcm_disp_mode = "N"
             CALL dcm_footer(dcm_disp_mode)
            ELSE
             CALL dcm_message("User canceled operations.  Resetting Answers.......")
             IF ((dccs_master->question[dcm_togo].question_object_cnt > 0))
              CALL dcm_reset_ops(dcm_togo,"OBJECT")
             ELSEIF ((dccs_master->question[dcm_togo].request_op_cnt > 0))
              CALL dcm_reset_ops(dcm_togo,"REQUEST")
             ENDIF
             CALL dcm_reset(null)
             CALL dcm_message("User canceled operations.  Answers reset.")
             SET dcm_disp_mode = "N"
             CALL dcm_footer(dcm_disp_mode)
            ENDIF
           ELSE
            IF (dcm_ignore=0)
             IF (dcm_confirm_approval(null)=1)
              CALL dcm_postop_updates(dcm_togo,"N")
              CALL dcm_message("Question answered.")
             ELSE
              CALL dcm_message("User canceled operations.  Answers reset.")
             ENDIF
            ELSE
             CALL dcm_message("Default for Environment. Answer Reset")
            ENDIF
            IF ((dccs_master->question[dcm_togo].question_object_cnt > 0))
             CALL dcm_reset_ops(dcm_togo,"OBJECT")
             SET dccs_master->question[dcm_togo].question_object_cnt = 0
            ELSEIF ((dccs_master->question[dcm_togo].request_op_cnt > 0))
             CALL dcm_reset_ops(dcm_togo,"REQUEST")
             SET dccs_master->question[dcm_togo].request_op_cnt = 0
            ENDIF
            CALL dcm_reset(null)
            SET dcm_disp_mode = "N"
            CALL dcm_footer(dcm_disp_mode)
           ENDIF
          ELSE
           CALL dcm_postop_updates(dcm_togo,"N")
           CALL dcm_message("No operations are available.")
           CALL dcm_reset(null)
           SET dcm_disp_mode = "N"
           CALL dcm_footer(dcm_disp_mode)
          ENDIF
         ELSE
          CALL clear(1,1)
          CALL dcm_footer(dcm_disp_mode)
          CALL dcm_message("User chose not to modify.")
          SET dcm_disp_mode = "N"
          CALL dcm_footer(dcm_disp_mode)
         ENDIF
        ENDIF
       ELSE
        CALL dcm_message("Option not available at this time.")
        IF (inhouse_ind=1)
         CALL dcm_message("Not executed since we are in inhouse domain.")
        ENDIF
        SET dcm_disp_mode = "N"
        CALL dcm_footer(dcm_disp_mode)
       ENDIF
      OF "Q":
       SET dcm_cont = 1
      OF "A":
       SET dcm_scroll_unanswered = 0
       CALL dcm_header(null)
       CALL dcm_footer(dcm_disp_mode)
      OF "N":
       SELECT INTO "nl:"
        FROM dm_cb_questions q
        WHERE q.ask_flag=1
         AND q.active_ind=1
        WITH nocounter
       ;end select
       IF (curqual > 0)
        SET dcm_scroll_unanswered = 1
        CALL dcm_header(null)
        CALL dcm_footer(dcm_disp_mode)
       ELSE
        CALL dcm_header(null)
        CALL dcm_footer(dcm_disp_mode)
        CALL dcm_message("There are no unanswered questions.")
       ENDIF
      OF "R":
       SET reset_return = dcm_inform_user("INFO","Refresh Answers?  (YES,NO)")
       IF (reset_return=1)
        CALL dcm_reset(null)
       ELSE
        CALL dcm_message("User chose not to reset.")
       ENDIF
      OF "P":
       IF (inhouse_ind=1)
        CALL dcm_message("Not executed since we are in inhouse domain.")
       ELSE
        SET reset_return = 0
        SET reset_return = dcm_inform_user("VERIFY","Reprocess Operations?")
        IF (reset_return=1)
         CALL dcm_message("Reprocessing operations...")
         CALL dcm_reprocess(dcm_togo)
        ENDIF
       ENDIF
      OF "D":
       CALL dcm_scroll_down(null)
       CALL dcm_footer(dcm_disp_mode)
      OF "U":
       CALL dcm_scroll_up(null)
       CALL dcm_footer(dcm_disp_mode)
      OF "V":
       CALL dcm_allques_screen(0)
       SET dcm_first = 0
      OF "G":
       CALL dcm_goto_ques(null)
       IF (dcm_place_hold=size(dccs_master->question,5))
        CALL dcm_footer(dcm_disp_mode)
        CALL dcm_message("You have reached the last question. Press 'U' to Scroll Up.")
       ELSEIF (dcm_place_hold=1)
        CALL dcm_footer(dcm_disp_mode)
        CALL dcm_message("You have reached the first question.. Press 'D' to Scroll Down.")
       ENDIF
      OF "L":
       IF (allow_view=1)
        FREE DEFINE rtl
        DEFINE rtl "logfile_hold"
        SELECT INTO mine
         r.line
         FROM rtlt r
         DETAIL
          col 1, r.line, row + 1
         WITH maxcol = 1000
        ;end select
       ELSE
        CALL dcm_message("Option not available at this time.")
       ENDIF
       SET dcm_disp_mode = "N"
       CALL dcm_footer(dcm_disp_mode)
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dcm_confirm(confirm_ques_in)
   DECLARE sel_check_cnt = i4
   DECLARE sel_found = i2
   SET sel_found = 0
   SET sel_check_cnt = 0
   SET answer_cnt = 0
   SET ques_cnt = 0
   FOR (ques_cnt = confirm_ques_in TO confirm_ques_in)
     SET answer_size = 0
     SET answer_size = size(dccs_master->question[ques_cnt].answer,5)
     IF ((dccs_master->question[ques_cnt].question_answer_db != dccs_master->question[ques_cnt].
     question_answer)
      AND (dccs_master->question[ques_cnt].question_answer > ""))
      FOR (answer_cnt = 1 TO answer_size)
        IF ((dccs_master->question[ques_cnt].question_answer=dccs_master->question[ques_cnt].answer[
        answer_cnt].answer))
         SET dccs_master->question[ques_cnt].action_status = "EXECUTE"
         SET dccs_master->question[ques_cnt].answer[answer_cnt].action_status = "EXECUTE"
         SET dccs_master->question[ques_cnt].answer[answer_cnt].answer_status_new = "SELECTED"
         SET dccs_master->question[ques_cnt].answer[answer_cnt].answer_status_old = "DESELECTED"
        ELSE
         SET dccs_master->question[ques_cnt].answer[answer_cnt].answer_status_new = "DESELECTED"
        ENDIF
      ENDFOR
     ELSE
      FOR (answer_cnt = 1 TO answer_size)
        IF ((dccs_master->question[ques_cnt].question_answer=dccs_master->question[ques_cnt].answer[
        answer_cnt].answer))
         IF ((dccs_master->question[ques_cnt].answer[answer_cnt].answer_status_old="SELECTED")
          AND (dccs_master->question[ques_cnt].answer[answer_cnt].action_status="EXECUTE"))
          SET dccs_master->question[ques_cnt].action_status = "EXECUTE"
          SET dccs_master->question[ques_cnt].answer[answer_cnt].answer_status_new = "SELECTED"
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
     SET dcm_ignore = 0
     FOR (answer_cnt = 1 TO answer_size)
       IF ((dccs_master->question[ques_cnt].action_status="EXECUTE"))
        IF ((dccs_master->question[ques_cnt].answer[answer_cnt].answer_status_new="SELECTED")
         AND (dccs_master->question[ques_cnt].answer[answer_cnt].action_status="EXECUTE")
         AND (dccs_master->question[ques_cnt].answer[answer_cnt].ignore_first_ind=1))
         SET sel_found = 0
         SET dcm_ignore = 1
         FOR (sel_check_cnt = 1 TO answer_size)
          IF ((dccs_master->question[ques_cnt].answer[sel_check_cnt].answer_status_db="SELECTED")
           AND (dccs_master->question[ques_cnt].answer[sel_check_cnt].answer != dccs_master->
          question[ques_cnt].answer[answer_cnt].answer))
           SET sel_found = 1
          ENDIF
          IF (sel_found=1)
           SET dccs_master->question[ques_cnt].answer[answer_cnt].ignore_first_ind = 0
           SET dcm_ignore = 0
          ENDIF
         ENDFOR
        ENDIF
        IF ((dccs_master->question[ques_cnt].answer[answer_cnt].answer_status_new="SELECTED")
         AND (dccs_master->question[ques_cnt].answer[answer_cnt].action_status="EXECUTE"))
         CALL execute_actions(dccs_master->question[ques_cnt].answer[answer_cnt].action)
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE dcm_allques_screen(das_mode)
   DECLARE das_line = c132
   DECLARE das_answer = c132
   DECLARE das_num = c132
   DECLARE das_ans_cnt = i4
   DECLARE found_ans_ind = i2
   SET das_ans_cnt = 0
   SET found_ans_ind = 0
   SET das_line = fillstring(132,"=")
   SELECT
    IF (das_mode=1)INTO mine
     FROM (dummyt d  WITH seq = value(size(dccs_master->question,5)))
     PLAN (d
      WHERE (dccs_master->question[d.seq].ask_flag=1))
    ELSE INTO mine
     FROM (dummyt d  WITH seq = value(size(dccs_master->question,5)))
    ENDIF
    HEAD REPORT
     col 0, das_line, row + 1,
     col 0, "=",
     CALL center("*********** DM - Customize Environment (Schema and Script Usage)  ***********",0,
     132),
     col 132, "=", row + 1,
     col 0, das_line, row + 1,
     col 0,
     "The following questions will be used to customize the database schema and script execution to ",
     row + 1,
     col 0,
     " reduce processing overhead across the Cerner Millennium Solutions you have implemented.", row
      + 1,
     das_line = fillstring(132,"-"), col 0, das_line,
     row + 3, col 0, "All Unanswered Questions for Customize Schema are displayed below."
    HEAD PAGE
     row + 2, col 1, "Question Number",
     col 17, "Answer", col 32,
     "Question", row + 1, col 1,
     "---------------", col 17, "------",
     col 32, "--------", row + 1
    DETAIL
     found_ans_ind = 0, das_ans_cnt = 0, das_num = trim(cnvtstring(dccs_master->question[d.seq].
       question_order_seq)),
     col 1, das_num
     FOR (das_ans_cnt = 1 TO size(dccs_master->question[d.seq].answer,5))
       IF ((dccs_master->question[d.seq].answer[das_ans_cnt].answer_status_db="SELECTED"))
        das_answer = trim(dccs_master->question[d.seq].answer[das_ans_cnt].answer), found_ans_ind = 1
       ENDIF
     ENDFOR
     IF (found_ans_ind=0)
      col 17, "NOT ANSWERED"
     ELSE
      col 17, das_answer
     ENDIF
     col 32, dccs_master->question[d.seq].question_full_unedit, row + 1
    FOOT REPORT
     IF (das_ans_cnt=0)
      row + 2, col 1, "There are no Unanswered questions available.",
      row + 1
     ENDIF
    WITH nocounter, maxcol = 1000, nullreport
   ;end select
 END ;Subroutine
 SUBROUTINE dcm_header(null)
   CALL box(1,1,3,132)
   CALL text(2,22,"*********** DM - Customize Environment (Schema and Script Usage)  ***********")
   CALL text(4,3,
    "The following questions will be used to customize the database schema and script execution to")
   CALL text(5,3,
    "reduce processing overhead across the Cerner Millennium Solutions you have implemented.")
   CALL text(6,3,
    "Based on your answers, a confirmation report will be provided to describe which database")
   CALL text(7,3,"objects or scripts will be affected before making changes to your environment.")
   CALL text(10,3,"Question")
   CALL clear(9,15,40)
   IF (dcm_scroll_unanswered=1)
    CALL text(9,15,"Scroll Mode: U'n'answered Questions.")
   ELSE
    CALL text(9,15," Scroll Mode:  'A'll Questions")
   ENDIF
   CALL text(9,100,"Answer")
   CALL text(10,100,"Options")
   CALL text(9,110,"Your")
   CALL text(10,110,"Answer")
 END ;Subroutine
 SUBROUTINE dcm_clear_ques(null)
   CALL clear(11,1,132)
   CALL clear(12,1,132)
   CALL clear(13,1,132)
   CALL clear(14,1,132)
   CALL clear(15,1,132)
   CALL clear(16,1,132)
 END ;Subroutine
 SUBROUTINE dcm_goto_ques(null)
   DECLARE ques_valid = i2
   DECLARE warning_displayed = i2
   DECLARE help_pressed = i2
   SET help_pressed = 0
   SET warning_displayed = 0
   SET ques_valid = 0
   WHILE (ques_valid=0)
     CALL text(10,117,"GoTo")
     CALL box(11,117,13,130)
     CALL text(11,118,"Ques #:")
     CALL dcm_message("HELP: Press <SHIFT><F5> to select question to go to.")
     SET help = pos(11,3,10,115)
     IF (dcm_scroll_unanswered=0)
      SET help =
      SELECT INTO "nl:"
       question = trim(cnvtstring(q.question_order_seq)), q.question
       FROM dm_cb_questions q
       WHERE q.active_ind=1
       ORDER BY q.question_order_seq
      ;end select
     ELSE
      SET help =
      SELECT INTO "nl:"
       question = trim(cnvtstring(q.question_order_seq)), q.question
       FROM dm_cb_questions q
       WHERE q.active_ind=1
        AND q.ask_flag=1
       ORDER BY q.question_order_seq
      ;end select
     ENDIF
     CALL accept(12,119,"9(3);CU","0")
     SELECT
      IF (dcm_scroll_unanswered=0)INTO "nl:"
       FROM dm_cb_questions q
       WHERE q.question_order_seq=cnvtint(trim(curaccept))
        AND q.active_ind=1
       ORDER BY q.question_order_seq
      ELSE INTO "nl:"
       FROM dm_cb_questions q
       WHERE q.question_order_seq=cnvtint(trim(curaccept))
        AND q.active_ind=1
        AND q.ask_flag=1
       ORDER BY q.question_order_seq
      ENDIF
      WITH nocounter
     ;end select
     IF (curqual > 0)
      SET ques_valid = 1
     ENDIF
     IF (ques_valid=1)
      CALL dcm_disp_ques(cnvtint(trim(curaccept)),1)
     ELSE
      SET warning_displayed = 1
      CALL dcm_message("Question not in list.  <SHIFT><F5> for HELP")
     ENDIF
     CALL clear(9,40,40)
     CALL clear(10,40,40)
     CALL clear(10,117,10)
     CALL clear(11,117,10)
     CALL clear(12,117,10)
     SET help = off
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dcm_footer(dcm_disp_dir)
   CALL text(22,0,"Option:")
   CALL clear(22,20,112)
   CASE (dcm_disp_dir)
    OF "N":
     IF (dcm_scroll_unanswered=1)
      IF ((dccs_master->dccs_logfile != ""))
       CALL text(22,12,"(M=Modify Answer,R=Refresh,Q=Quit,G=GoTo,")
       CALL text(22,53,"V=View All Questions,D=Down,U=Up,P=Reprocess,A=Include Answered, L=Logfile)")
       SET dcm_disp_mode = "N"
      ELSE
       CALL text(22,12,
        "(M=Modify Answer,R=Refresh,Q=Quit,G=GoTo,V=View All Questions,D=Down,U=Up,P=Reprocess,A=Include Answered)"
        )
       SET dcm_disp_mode = "N"
      ENDIF
     ELSE
      IF ((dccs_master->dccs_logfile != ""))
       CALL text(22,12,"(M=Modify Answer,R=Refresh,Q=Quit,G=GoTo,")
       SET dcm_disp_mode = "N"
       CALL text(22,53,"V=View All Questions,D=Down,U=Up,P=Reprocess, N= Unanswered Only, L=Logfile)"
        )
      ELSE
       CALL text(22,12,"(M=Modify Answer,R=Refresh,Q=Quit,G=GoTo,")
       CALL text(22,53,"V=View All Questions,D=Down,U=Up,P=Reprocess, N= Unanswered Only)")
       SET dcm_disp_mode = "N"
      ENDIF
     ENDIF
    OF "M":
     CALL text(22,12,"(X= Cancel Answer)")
    ELSE
     CALL text(22,53,
      "(M=Modify Answer,R=Refresh,Q=Quit,G=GoTo,V=View All Questions,D=Down,U=Up,P=Reprocess)")
   ENDCASE
   CALL text(24,0,"Message Area:")
 END ;Subroutine
 SUBROUTINE dcm_message(dcm_mess_in)
   CALL clear(24,15,115)
   CALL text(24,15,dcm_mess_in)
   SET last_message = dcm_mess_in
 END ;Subroutine
 SUBROUTINE dcm_disp_ques(dcm_start_row,goto_mode)
   DECLARE disp_ans_cnt = i4
   DECLARE disp_ans_found = i2
   SET disp_ans_found = 0
   SET disp_ans_cnt = 0
   SET dcm_cur_rows = 0
   SET dcm_line_cnt = 0
   SET ans_size = 0
   SET dcm_cur_rows = 0
   SET dcm_line_cnt = 10
   CALL dcm_clear_ques(null)
   IF (goto_mode=1)
    FOR (seg_togo = 1 TO size(dccs_master->question,5))
      IF ((dccs_master->question[seg_togo].question_order_seq=dcm_start_row))
       SET dcm_togo = seg_togo
       SET seg_togo = size(dccs_master->question,5)
      ENDIF
    ENDFOR
   ELSE
    SET dcm_togo = dcm_start_row
   ENDIF
   SET seg_togo = 0
   FOR (seg_togo = 1 TO size(dccs_master->question[dcm_togo].question_break,5))
     SET dcm_cur_rows = (dcm_cur_rows+ 1)
     SET dcm_line_cnt = (dcm_line_cnt+ 1)
     IF ((dccs_master->question[dcm_togo].question_break[seg_togo].question_break_seq=1))
      SET ans_size = size(dccs_master->question[dcm_togo].answer,5)
      SET dcm_txt = trim(dccs_master->question[dcm_togo].question_options)
      CALL text(value(dcm_line_cnt),100,trim(dcm_txt))
      SET dcm_txt = ""
      IF ((dccs_master->question[dcm_togo].question_answer_db=""))
       IF (size(dccs_master->question[dcm_togo].answer,5) > 0)
        FOR (disp_ans_cnt = 1 TO ans_size)
          IF ((dccs_master->question[dcm_togo].answer[disp_ans_cnt].answer_status_db="SELECTED"))
           IF (dcm_disp_mode="R")
            SET dcm_txt = dccs_master->question[dcm_togo].answer[disp_ans_cnt].answer_orig
           ELSE
            SET dcm_txt = dccs_master->question[dcm_togo].answer[disp_ans_cnt].answer
           ENDIF
          ENDIF
          SET disp_ans_cnt = ans_size
          SET disp_ans_found = 1
        ENDFOR
        IF (disp_ans_found=0)
         IF ((dccs_master->question[dcm_togo].question_answer != ""))
          SET dcm_txt = dccs_master->question[dcm_togo].question_answer
         ENDIF
        ENDIF
       ENDIF
      ELSE
       SET dcm_txt = dccs_master->question[dcm_togo].question_answer_db
      ENDIF
      CALL text(value(dcm_line_cnt),110,trim(dcm_txt))
      SET dcm_txt = concat(trim(cnvtstring(dccs_master->question[dcm_togo].question_order_seq)),". ",
       dccs_master->question[dcm_togo].question_break[seg_togo].question_segment)
     ELSE
      SET dcm_txt = dccs_master->question[dcm_togo].question_break[seg_togo].question_segment
     ENDIF
     CALL text(value(dcm_line_cnt),3,trim(dcm_txt))
     SET dcm_place_hold = dcm_togo
   ENDFOR
 END ;Subroutine
 SUBROUTINE dcm_allow_ans(dcm_line_in)
   DECLARE default_ans = c1
   DECLARE allow_ans_cnt = i4
   DECLARE found_ans_ind = i4
   SET allow_ans_cnt = 0
   SET found_ans_ind = 0
   SET user_canceled_ind = 0
   IF ((dccs_master->question[dcm_togo].question_answer=""))
    FOR (allow_ans_cnt = 1 TO size(dccs_master->question[dcm_togo].answer,5))
      IF ((dccs_master->question[dcm_togo].answer[allow_ans_cnt].answer_status_db="SELECTED"))
       IF ( NOT ((dccs_master->question[dcm_togo].answer[allow_ans_cnt].answer IN ("Y", "N"))))
        SET default_ans = ""
       ELSE
        SET default_ans = dccs_master->question[dcm_togo].answer[allow_ans_cnt].answer
       ENDIF
       SET found_ans_ind = 1
       SET allow_ans_cnt = size(dccs_master->question[dcm_togo].answer,5)
      ENDIF
    ENDFOR
   ELSE
    SET default_ans = dccs_master->question[dcm_togo].question_answer
   ENDIF
   CALL dcm_message("***Press 'X' to cancel modify.***")
   CALL accept(dcm_line_in,110,"P;CU",default_ans
    WHERE cnvtupper(curaccept) IN ("Y", "N", "X"))
   IF (curaccept != "X")
    IF (curaccept != default_ans)
     SET dccs_master->question[dcm_togo].question_answer = curaccept
     CALL dcm_confirm(dcm_togo)
    ELSE
     SET dccs_master->question[dcm_togo].question_answer = default_ans
     CALL dcm_confirm(dcm_togo)
    ENDIF
   ELSE
    SET user_canceled_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE display_confirmation_report(con_ques_ndx,con_local_nbr)
   DECLARE con_cnt = i4
   DECLARE con_obj_cnt = i4
   DECLARE con_oper_cnt = i4
   DECLARE con_name_hold = c132
   DECLARE con_tot_obj = c132
   DECLARE con_sequence_cnt = i4
   DECLARE found_script = i2
   DECLARE con_temp_str = c132
   SET con_obj_cnt = 0
   SET con_tot_obj = ""
   SET con_temp_str = ""
   SET dcm_con_approve_ind = 0
   SELECT INTO mine
    FROM (dummyt d  WITH seq = 1)
    HEAD REPORT
     line_d = fillstring(90,"="), con_cnt = 0,
     CALL center("***CUSTOMIZE SCHEMA***",0,90),
     row + 1,
     CALL center("***CONFIRMATION REPORT***",0,90), row + 2,
     col 0, line_d, row + 1,
     col 1, "Question: ", col 10,
     con_local_nbr, con_obj_cnt = 0, con_oper_cnt = 0
     WHILE (con_cnt < size(dccs_master->question[con_ques_ndx].question_break,5))
       con_cnt = (con_cnt+ 1), col 14, dccs_master->question[con_ques_ndx].question_break[con_cnt].
       question_segment,
       row + 1
     ENDWHILE
     col 1, "You answered: "
     IF ((dccs_master->question[con_ques_ndx].question_answer=""))
      col 14, dccs_master->question[con_ques_ndx].question_answer_db
     ELSE
      col 14, dccs_master->question[con_ques_ndx].question_answer
     ENDIF
     row + 1, line_d, row + 2,
     col 0, "** Please review the following information CAREFULLY to make sure all ", row + 1,
     col 0, "**database operations are appropriate for your environment. ", row + 2,
     col 0, "** Database Operations are tied to the question you have answered.", row + 2
    DETAIL
     IF (dcm_ignore=0)
      IF (size(dccs_master->question[con_ques_ndx].object,5) > 0)
       con_tot_obj = trim(cnvtstring(dccs_master->question[con_ques_ndx].question_object_cnt))
       CASE (dccs_master->question[con_ques_ndx].obj_act_performed)
        OF "BUILD":
         col 1,"Number of objects that need to be built:",col 43,
         con_tot_obj,dcm_con_approve_ind = 0
        OF "":
         col 1,"No objects need to be built:"
        OF "DROP":
         col 1,"Number of objects that will be dropped:",col 40,
         con_tot_obj
       ENDCASE
       row + 1
       IF (cnvtint(con_tot_obj) > 0)
        CASE (dccs_master->question[con_ques_ndx].obj_act_performed)
         OF "DROP":
          col 1,"Objects that will be dropped...."
         ELSE
          col 1,"Objects that need to be built ...."
        ENDCASE
       ELSE
        col 1, "All objects exist in current environment"
       ENDIF
       row + 1, line_d, row + 1,
       con_sequence_cnt = 0, found_script = 0
       WHILE (con_obj_cnt < size(dccs_master->question[con_ques_ndx].object,5))
         con_obj_cnt = (con_obj_cnt+ 1), con_oper_cnt = 0
         IF ((dccs_master->question[con_ques_ndx].object[con_obj_cnt].table_name="WILDCARD"))
          CASE (dccs_master->question[con_ques_ndx].obj_act_performed)
           OF "":
            col 1,"No objects need to be built:"
           OF "DROP":
            IF (size(dccs_master->question[con_ques_ndx].object[con_obj_cnt].op,5) > 0)
             con_name_hold = concat("The following objects will be dropped based on the pattern:",
              dccs_master->question[con_ques_ndx].object[con_obj_cnt].object_name), col 1,
             con_name_hold,
             row + 1
            ENDIF
          ENDCASE
          WHILE (con_oper_cnt < size(dccs_master->question[con_ques_ndx].object[con_obj_cnt].op,5))
            con_oper_cnt = (con_oper_cnt+ 1), con_sequence_cnt = (con_sequence_cnt+ 1), con_name_hold
             = concat(trim(cnvtstring(con_sequence_cnt))," of ",con_tot_obj),
            col 1, con_name_hold, con_name_hold = "",
            con_temp_str = "", con_temp_str = dccs_master->question[con_ques_ndx].object[con_obj_cnt]
            .op[con_oper_cnt].operations
            IF ((dccs_master->question[con_ques_ndx].object[con_obj_cnt].object_status="BUILD"))
             con_name_hold = dccs_master->question[con_ques_ndx].object[con_obj_cnt].op[con_oper_cnt]
             .operations
            ELSE
             con_name_hold = concat(dccs_master->question[con_ques_ndx].object[con_obj_cnt].
              object_type,":",substring((findstring("trigger",con_temp_str,1,1)+ 8),(textlen(
                con_temp_str) - findstring("trigger",con_temp_str,1,1)),con_temp_str)), con_name_hold
              = substring(1,findstring(" go",con_name_hold,1,1),con_name_hold)
            ENDIF
            col 14, con_name_hold, row + 1
            IF ( NOT ((dccs_master->question[con_ques_ndx].obj_act_performed IN ("BUILD"))))
             dcm_con_approve_ind = 1
            ENDIF
          ENDWHILE
          IF ((dccs_master->question[con_ques_ndx].obj_act_performed="DROP"))
           IF (size(dccs_master->question[con_ques_ndx].object[con_obj_cnt].op,5) > 0)
            con_name_hold = concat("End of pattern match for:",dccs_master->question[con_ques_ndx].
             object[con_obj_cnt].object_name), col 1, con_name_hold,
            row + 1
           ENDIF
          ENDIF
         ELSE
          WHILE (con_oper_cnt < size(dccs_master->question[con_ques_ndx].object[con_obj_cnt].op,5))
           con_oper_cnt = (con_oper_cnt+ 1),
           IF ((dccs_master->question[con_ques_ndx].object[con_obj_cnt].op[con_oper_cnt].operations
            > ""))
            IF ( NOT (findstring("coalesce",dccs_master->question[con_ques_ndx].object[con_obj_cnt].
             op[con_oper_cnt].operations)))
             con_sequence_cnt = (con_sequence_cnt+ 1), con_name_hold = concat(trim(cnvtstring(
                con_sequence_cnt))," of ",con_tot_obj), col 1,
             con_name_hold, con_name_hold = ""
             IF ((dccs_master->question[con_ques_ndx].object[con_obj_cnt].object_status="BUILD"))
              con_name_hold = dccs_master->question[con_ques_ndx].object[con_obj_cnt].op[con_oper_cnt
              ].operations
             ELSE
              con_name_hold = concat(dccs_master->question[con_ques_ndx].object[con_obj_cnt].
               object_type,":",dccs_master->question[con_ques_ndx].object[con_obj_cnt].object_name)
             ENDIF
             col 14, con_name_hold, row + 1
             IF ( NOT ((dccs_master->question[con_ques_ndx].obj_act_performed IN ("BUILD"))))
              dcm_con_approve_ind = 1
             ENDIF
            ENDIF
           ENDIF
          ENDWHILE
         ENDIF
       ENDWHILE
      ENDIF
      con_obj_cnt = 0, con_tot_obj = ""
      IF (size(dccs_master->question[con_ques_ndx].request,5) > 0)
       row + 2
       IF ((dccs_master->question[con_ques_ndx].request_op_cnt > 0))
        IF ((dccs_master->question[con_ques_ndx].obj_act_performed="BUILD"))
         col 1, "Number of scripts that will be activated:"
        ELSE
         col 1, "Number of scripts that will be inactivated:"
        ENDIF
        con_tot_obj = trim(cnvtstring(dccs_master->question[con_ques_ndx].request_op_cnt)), col 47,
        con_tot_obj,
        row + 1
       ELSE
        IF ((dccs_master->question[con_ques_ndx].obj_act_performed="BUILD"))
         col 1, "No scripts will be activated."
        ELSE
         col 1, "No scripts will be inactivated."
        ENDIF
        row + 1
       ENDIF
       IF ((dccs_master->question[con_ques_ndx].request_op_cnt > 0))
        IF ((dccs_master->question[con_ques_ndx].obj_act_performed="BUILD"))
         col 1, "Scripts that will be activated...."
        ELSE
         col 1, "Scripts that will be inactivated...."
        ENDIF
        row + 1, line_d, row + 1,
        con_sequence_cnt = 0
        WHILE (con_obj_cnt < size(dccs_master->question[con_ques_ndx].request,5))
          con_obj_cnt = (con_obj_cnt+ 1), con_oper_cnt = 0
          WHILE (con_oper_cnt < size(dccs_master->question[con_ques_ndx].request[con_obj_cnt].op,5))
            IF ((dccs_master->question[con_ques_ndx].request[con_obj_cnt].op[con_oper_cnt].operations
             > ""))
             con_oper_cnt = (con_oper_cnt+ 1), con_sequence_cnt = (con_sequence_cnt+ 1),
             con_name_hold = concat(trim(cnvtstring(con_sequence_cnt))," of ",con_tot_obj),
             col 1, con_name_hold, con_name_hold = ""
             CASE (dccs_master->question[con_ques_ndx].request[con_obj_cnt].format_script)
              OF "NULLIFY":
               con_name_hold = concat("Request Number... ",trim(cnvtstring(dccs_master->question[
                  con_ques_ndx].request[con_obj_cnt].request_number))," with Format Script: null")
              OF "X":
               con_name_hold = concat("Request Number... ",trim(cnvtstring(dccs_master->question[
                  con_ques_ndx].request[con_obj_cnt].request_number))," with Format Script: ' ' ")
              ELSE
               con_name_hold = concat("Request Number... ",trim(cnvtstring(dccs_master->question[
                  con_ques_ndx].request[con_obj_cnt].request_number))," with Format Script: ",
                dccs_master->question[con_ques_ndx].request[con_obj_cnt].format_script)
             ENDCASE
             col 14, con_name_hold, row + 1,
             dcm_con_approve_ind = 1
            ENDIF
          ENDWHILE
        ENDWHILE
       ELSE
        col 1,
        "This answer has already been EXECUTED in this environment or no actions need to be taken.",
        row + 1
       ENDIF
      ENDIF
     ELSE
      col 1, "This is the default for the environment, no operations will be executed."
     ENDIF
    WITH nocounter, formfeed = none, maxcol = 525,
     format = stream, noheading
   ;end select
 END ;Subroutine
 SUBROUTINE dcm_scroll_down(null)
   SET dcm_ask_cnt = 0
   SET dcm_ask_found = 0
   IF (dcm_place_hold=size(dccs_master->question,5))
    CALL dcm_footer(dcm_disp_mode)
    CALL dcm_message("You have reached the last question. Press 'U' to Scroll Up.")
   ELSE
    CALL dcm_footer(dcm_disp_mode)
    CALL dcm_message("More questions remain. Press 'D' to Scroll Down.")
    SET dcm_down_start = (dcm_place_hold+ 1)
    IF (dcm_scroll_unanswered=1)
     IF ((dccs_master->question[dcm_down_start].ask_flag=1))
      CALL dcm_disp_ques(dcm_down_start,0)
     ELSE
      FOR (dcm_ask_cnt = dcm_down_start TO size(dccs_master->question,5))
        IF ((dccs_master->question[dcm_ask_cnt].ask_flag=1))
         SET dcm_down_start = dcm_ask_cnt
         SET dcm_ask_found = 1
         SET dcm_ask_cnt = size(dccs_master->question,5)
        ENDIF
      ENDFOR
      IF (dcm_ask_found=1)
       CALL dcm_disp_ques(dcm_down_start,0)
      ELSE
       CALL dcm_footer(dcm_disp_mode)
       CALL dcm_message("You have reached the last question. Press 'U' to Scroll Up.")
      ENDIF
     ENDIF
    ELSE
     SET dcm_down_start = (dcm_place_hold+ 1)
     CALL dcm_footer(dcm_disp_mode)
     CALL dcm_disp_ques(dcm_down_start,0)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dcm_reset_ops(dcm_reset_ques_in,dcm_type_in)
  DECLARE reset_req_cnt = i4
  IF (dcm_type_in="REQUEST")
   FOR (reset_req_cnt = 1 TO size(dccs_master->question[dcm_reset_ques_in].request,5))
     SET stat = alterlist(dccs_master->question[dcm_reset_ques_in].request[reset_req_cnt].op,0)
   ENDFOR
  ELSE
   FOR (reset_req_cnt = 1 TO size(dccs_master->question[dcm_reset_ques_in].object,5))
     SET stat = alterlist(dccs_master->question[dcm_reset_ques_in].object[reset_req_cnt].op,0)
   ENDFOR
  ENDIF
 END ;Subroutine
 SUBROUTINE dcm_scroll_up(null)
   SET dcm_ask_cnt = 0
   SET dcm_ask_found = 0
   SET dcm_up_start = 0
   IF (dcm_place_hold=1)
    CALL dcm_footer(dcm_disp_mode)
    CALL dcm_message("You have reached the first question. Press 'D' to Scroll Down.")
   ELSE
    IF (dcm_scroll_unanswered=1)
     CALL dcm_footer(dcm_disp_mode)
     CALL dcm_message("More questions remain. Press 'U' to Scroll Up.")
     SET dcm_up_start = (dcm_place_hold - 1)
     IF ((dccs_master->question[dcm_up_start].ask_flag=1))
      CALL dcm_disp_ques(dcm_up_start,0)
     ELSE
      SET dcm_ask_cnt = dcm_up_start
      WHILE (dcm_ask_cnt >= 1)
       SET dcm_ask_cnt = (dcm_ask_cnt - 1)
       IF ((dccs_master->question[dcm_ask_cnt].ask_flag=1))
        SET dcm_up_start = dcm_ask_cnt
        SET dcm_ask_found = 1
        SET dcm_ask_cnt = 0
       ENDIF
      ENDWHILE
      IF (dcm_ask_found=1)
       CALL dcm_disp_ques(dcm_up_start,0)
      ELSE
       CALL dcm_footer(dcm_disp_mode)
       CALL dcm_message("You have reached the first question. Press 'D' to Scroll Down.")
      ENDIF
     ENDIF
    ELSE
     SET dcm_up_start = (dcm_place_hold - 1)
     CALL dcm_footer(dcm_disp_mode)
     CALL dcm_message("More questions remain. Press 'U' to Scroll Up.")
     CALL dcm_disp_ques(dcm_up_start,0)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dcm_modify(null)
  CALL dcm_message("Modifying Answers....")
  IF (dcm_place_hold=0)
   CALL dcm_disp_ques(1,0)
  ELSE
   CALL dcm_disp_ques(dcm_place_hold,0)
  ENDIF
 END ;Subroutine
 SUBROUTINE dcm_reset(null)
   CALL dcm_get_questions("ALL")
   CALL dcm_get_answers("ALL")
   CALL dcm_get_objects("ALL")
   CALL dcm_get_requests("ALL")
   CALL dcm_disp_ques(dcm_togo,0)
 END ;Subroutine
 SUBROUTINE dcm_confirm_approval(null)
   CALL dcm_header(null)
   CALL dcm_footer(dcm_disp_mode)
   CALL video(r)
   CALL text(10,40,"APPROVAL OF OPERATIONS")
   CALL box(11,40,18,102)
   CALL video(n)
   CALL text(14,41,"Execute all operations on confirmation report?      (YES,NO)")
   CALL accept(14,88,"C(3);CU","NO"
    WHERE curaccept IN ("NO", "YES"))
   IF (curaccept="YES")
    SET user_select = 1
   ELSE
    SET user_select = 0
   ENDIF
   SET help = off
   CALL clear(1,1)
   CALL dcm_footer(dcm_disp_mode)
   RETURN(user_select)
 END ;Subroutine
 SUBROUTINE dcm_inform_user(inform_type,iu_message)
   CALL clear(9,40,42)
   CALL clear(10,40,42)
   CALL clear(11,40,42)
   CALL clear(12,40,42)
   CALL clear(13,40,42)
   CALL clear(14,40,42)
   CALL clear(15,40,42)
   CALL clear(16,40,42)
   CALL clear(17,40,42)
   CALL clear(18,40,42)
   CASE (inform_type)
    OF "INFO":
     CALL video(r)
     CALL text(10,40,"INFORMATION")
     CALL box(11,40,18,80)
     CALL video(n)
     CALL text(14,41,iu_message)
    OF "VERIFY":
     CALL video(r)
     CALL text(10,40,"VERIFICATION")
     CALL box(11,40,18,80)
     CALL video(n)
     CALL text(14,41,iu_message)
   ENDCASE
   CALL accept(14,70,"C(3);CU","NO"
    WHERE curaccept IN ("NO", "YES"))
   IF (curaccept="YES")
    SET user_select = 1
   ELSE
    SET user_select = 0
   ENDIF
   CALL clear(9,40,42)
   CALL clear(10,40,42)
   CALL clear(11,40,42)
   CALL clear(12,40,42)
   CALL clear(13,40,42)
   CALL clear(14,40,42)
   CALL clear(15,40,42)
   CALL clear(16,40,42)
   CALL clear(17,40,42)
   CALL clear(18,40,42)
   SET help = off
   RETURN(user_select)
 END ;Subroutine
 SUBROUTINE dcm_reprocess(rp_ques_in)
   DECLARE rep_ans_found = i2
   DECLARE rep_perform = i4
   SET rep_ans_found = 0
   SET answer_cnt = 0
   CALL dcm_reset(null)
   FOR (answer_cnt = 1 TO size(dccs_master->question[rp_ques_in].answer,5))
     IF ((dccs_master->question[rp_ques_in].answer[answer_cnt].answer_status_db="SELECTED"))
      SET rep_ans_found = 1
      CALL execute_actions(dccs_master->question[rp_ques_in].answer[answer_cnt].action)
      SET rep_perform = 0
      IF (size(dccs_master->question[rp_ques_in].object,5) > 0)
       IF ((dccs_master->question[rp_ques_in].question_object_cnt > 0))
        SET rep_perform = 1
       ENDIF
      ENDIF
      IF (size(dccs_master->question[rp_ques_in].request,5) > 0)
       IF ((dccs_master->question[rp_ques_in].request_op_cnt > 0))
        SET rep_perform = 1
       ENDIF
      ENDIF
      IF (rep_perform=1)
       CALL display_confirmation_report(rp_ques_in,trim(cnvtstring(dccs_master->question[rp_ques_in].
          question_order_seq)))
       IF (dcm_confirm_approval(null)=1)
        CALL dcm_message("Performing actions....")
        CALL dcm_process_operations(rp_ques_in,"Y")
        CALL dcm_check_op_success(run_mode,dcm_togo)
        CALL dcm_footer(dcm_disp_mode)
        IF (dcm_error_operation=1)
         CALL dcm_postop_updates(dcm_togo,"Y")
         CALL dcm_create_error_log("DM_CB_CUSTOMIZE_ENV",dcm_togo)
         SET dcm_txt = concat("An error occurred. Logfile is ",dccs_master->dccs_logfile,
          ". Press 'L' to view log.")
         SET allow_view = 1
         CALL dcm_message(trim(dcm_txt))
         SET dcm_disp_mode = "N"
         CALL dcm_footer(dcm_disp_mode)
         COMMIT
        ELSE
         SET allow_view = 0
         CALL dcm_message("Operations have been performed. Recording Actions....")
         CALL dcm_postop_updates(dcm_togo,"Y")
         CALL dcm_message("Actions have been recorded.")
         CALL dcm_footer("N")
         CALL dcm_reset(null)
         COMMIT
        ENDIF
       ELSE
        CALL dcm_reset(null)
        SET dcm_disp_mode = "N"
        CALL dcm_footer(dcm_disp_mode)
        CALL dcm_message("Actions not Reprocessed.")
       ENDIF
      ELSE
       SET dcm_disp_mode = "N"
       CALL dcm_footer(dcm_disp_mode)
       CALL dcm_message("No operations need to be executed.")
       CALL dcm_reset(null)
      ENDIF
     ENDIF
   ENDFOR
   IF (rep_ans_found=0)
    CALL dcm_message("Cannot Reprocess. Question has never been answered.")
   ENDIF
   CALL dcm_footer(dcm_disp_mode)
 END ;Subroutine
 SUBROUTINE dcm_check_exe(rp_ques_in,rp_ans_in)
   DECLARE execute_status = i2
   SET execute_status = 0
   SELECT INTO "nl:"
    FROM dm_cb_answers a
    WHERE a.action_status="COMPLETE"
     AND a.answer_status="SELECTED"
     AND a.answer=rp_ans_in
     AND a.question_nbr=rp_ques_in
   ;end select
   IF (curqual > 0)
    SET execute_status = 1
   ENDIF
   RETURN(execute_status)
 END ;Subroutine
#exit_program
 SET message = nowindow
 COMMIT
 IF ((dccs_master->dccs_logfile != ""))
  CALL echo("*")
  CALL echo("*")
  CALL echo("*")
  CALL echo("**********************************************************")
  CALL echo(concat("Open log file to view errors:  ",dccs_master->dccs_logfile))
  CALL echo("**********************************************************")
  CALL echo("*")
  CALL echo("*")
  CALL echo("*")
 ENDIF
END GO

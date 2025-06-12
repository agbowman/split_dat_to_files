CREATE PROGRAM dm2_cb_manage_schema:dba
 DECLARE ques_in = i4
 DECLARE action_in = c132
 DECLARE obj_size = i4
 DECLARE sch_obj_cnt = i4
 DECLARE op_cnt = i4
 DECLARE find_ques_in = i4
 DECLARE dcms_ora_version = i4
 DECLARE ms_add_tbl_space(t_space_in,add_op_ind) = null WITH public
 DECLARE dcm_get_tablespace(tbs_obj_type,tbs_obj_name) = null WITH public
 DECLARE dcm_check_cb_objects(dcco_type_in,dcco_name_in) = i2 WITH public
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
 FREE RECORD ms_tablespace
 RECORD ms_tablespace(
   1 qual[*]
     2 tbl_space = vc
 )
 SUBROUTINE ms_gather_trig_names(mgtn_name_in,mgtn_ndx_in)
   DECLARE mgtn_cnt = i4
   SET mgtn_cnt = 0
   SELECT INTO "nl:"
    FROM user_triggers u
    WHERE u.trigger_name=patstring(mgtn_name_in)
    DETAIL
     mgtn_cnt = (mgtn_cnt+ 1), stat = alterlist(dccs_master->question[ques_in].object[mgtn_ndx_in].op,
      mgtn_cnt), dccs_master->question[ques_in].object[mgtn_ndx_in].op[mgtn_cnt].operations = concat(
      "rdb drop trigger ",trim(u.trigger_name)," go"),
     dccs_master->question[ques_in].question_object_cnt = (dccs_master->question[ques_in].
     question_object_cnt+ 1)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE ms_add_tbl_space(t_space_in,add_op_ind)
   DECLARE t_space_cnt = i4
   DECLARE t_space_found = i2
   DECLARE t_rec_cnt = i4
   SET t_space_cnt = 0
   SET t_space_found = 0
   SET t_rec_cnt = 0
   FOR (t_space_cnt = 1 TO size(ms_tablespace->qual,5))
     IF ((ms_tablespace->qual[t_space_cnt].tbl_space=t_space_in))
      SET t_space_found = 1
     ENDIF
   ENDFOR
   IF (t_space_found=0
    AND t_space_in != "DUMMY")
    SET t_rec_cnt = (size(ms_tablespace->qual,5)+ 1)
    SET stat = alterlist(ms_tablespace->qual,t_rec_cnt)
    SET ms_tablespace->qual[t_rec_cnt].tbl_space = t_space_in
   ENDIF
   SET t_space_cnt = 0
   IF (add_op_ind=1)
    FOR (t_space_cnt = 1 TO size(ms_tablespace->qual,5))
     SET stat = alterlist(dccs_master->question[ques_in].object[sch_obj_cnt].op,(op_cnt+ t_space_cnt)
      )
     SET dccs_master->question[ques_in].object[sch_obj_cnt].op[(op_cnt+ t_space_cnt)].operations =
     concat("rdb alter tablespace ",trim(ms_tablespace->qual[t_space_cnt].tbl_space)," coalesce go")
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE dcm_get_tablespace(tbs_obj_type,tbs_obj_name)
   DECLARE obj_tspace_out = c132
   SET obj_tspace_out = ""
   SELECT
    IF (tbs_obj_type="INDEX")INTO "nl:"
     FROM user_indexes u
     WHERE u.index_name=tbs_obj_name
    ELSEIF (tbs_obj_type="TABLE")INTO "nl:"
     FROM user_tables u
     WHERE u.table_name=tbs_obj_name
    ELSE
    ENDIF
    DETAIL
     obj_tspace_out = u.tablespace_name
    WITH nocounter
   ;end select
   RETURN(trim(obj_tspace_out))
 END ;Subroutine
 SUBROUTINE dcm_check_cb_objects(dcco_type_in,dcco_name_in)
   DECLARE dcco_flag = i2
   SET dcco_flag = 1
   SELECT INTO "nl:"
    FROM dm_cb_objects t
    WHERE t.object_type=dcco_type_in
     AND t.object_name=dcco_name_in
     AND t.active_ind=1
    DETAIL
     dcco_flag = 0
    WITH nocounter
   ;end select
   RETURN(dcco_flag)
 END ;Subroutine
 SET dcms_ora_version = 0
 SELECT INTO "nl:"
  FROM product_component_version p
  WHERE cnvtupper(p.product)="ORACLE*"
  DETAIL
   dcms_ora_version = cnvtint(substring(1,findstring(".",p.version,1,0),p.version))
  WITH nocounter
 ;end select
 SET find_ques_in =  $1
 SET action_in =  $2
 FOR (sch_obj_cnt = 1 TO size(dccs_master->question,5))
   IF ((dccs_master->question[sch_obj_cnt].question_nbr=find_ques_in))
    SET ques_in = sch_obj_cnt
    SET sch_obj_cnt = size(dccs_master->question,5)
   ENDIF
 ENDFOR
 SET sch_obj_cnt = 0
 SET obj_size = size(dccs_master->question[ques_in].object,5)
 SET op_cnt = 0
 SET dccs_master->question[ques_in].question_object_cnt = 0
 IF (action_in="DROP")
  SET dccs_master->question[ques_in].obj_act_performed = "DROP"
  FOR (sch_obj_cnt = 1 TO obj_size)
    SET op_cnt = 0
    SET ms_table = dccs_master->question[ques_in].object[sch_obj_cnt].table_name
    CASE (dccs_master->question[ques_in].object[sch_obj_cnt].object_type)
     OF "INDEX":
      IF (ms_index_missing(dccs_master->question[ques_in].object[sch_obj_cnt].object_name)=1)
       SET dccs_master->question[ques_in].object[sch_obj_cnt].object_status = "DROP"
       IF (sch_obj_cnt=obj_size)
        CALL ms_add_tbl_space("DUMMY",1)
       ENDIF
      ELSE
       SET op_cnt = (op_cnt+ 1)
       SET stat = alterlist(dccs_master->question[ques_in].object[sch_obj_cnt].op,op_cnt)
       SET dccs_master->question[ques_in].object[sch_obj_cnt].op[op_cnt].operations = concat(
        "rdb drop index ",dccs_master->question[ques_in].object[sch_obj_cnt].object_name," go")
       SET dccs_master->question[ques_in].object[sch_obj_cnt].object_tablespace = dcm_get_tablespace(
        "INDEX",dccs_master->question[ques_in].object[sch_obj_cnt].object_name)
       SET dccs_master->question[ques_in].object[sch_obj_cnt].object_status = "DROP"
       SET dccs_master->question[ques_in].question_object_cnt = (dccs_master->question[ques_in].
       question_object_cnt+ 1)
       IF (sch_obj_cnt=obj_size)
        CALL ms_add_tbl_space(dccs_master->question[ques_in].object[sch_obj_cnt].object_tablespace,1)
       ELSE
        CALL ms_add_tbl_space(dccs_master->question[ques_in].object[sch_obj_cnt].object_tablespace,0)
       ENDIF
      ENDIF
     OF "TABLE":
      IF (ms_table_missing(dccs_master->question[ques_in].object[sch_obj_cnt].object_name)=1)
       SET dccs_master->question[ques_in].object[sch_obj_cnt].object_status = "DROP"
       IF (sch_obj_cnt=obj_size)
        CALL ms_add_tbl_space("DUMMY",1)
       ENDIF
      ELSE
       SET op_cnt = (op_cnt+ 1)
       SET stat = alterlist(dccs_master->question[ques_in].object[sch_obj_cnt].op,op_cnt)
       IF (dcms_ora_version < 10)
        SET dccs_master->question[ques_in].object[sch_obj_cnt].op[op_cnt].operations = concat(
         "rdb drop table ",dccs_master->question[ques_in].object[sch_obj_cnt].object_name,
         " cascade constraints go")
       ELSE
        SET dccs_master->question[ques_in].object[sch_obj_cnt].op[op_cnt].operations = concat(
         "rdb drop table ",dccs_master->question[ques_in].object[sch_obj_cnt].object_name,
         " cascade constraints purge go")
       ENDIF
       SET dccs_master->question[ques_in].object[sch_obj_cnt].object_tablespace = dcm_get_tablespace(
        "TABLE",dccs_master->question[ques_in].object[sch_obj_cnt].object_name)
       SET dccs_master->question[ques_in].object[sch_obj_cnt].object_status = "DROP"
       SET dccs_master->question[ques_in].question_object_cnt = (dccs_master->question[ques_in].
       question_object_cnt+ 1)
       IF (sch_obj_cnt=obj_size)
        CALL ms_add_tbl_space(dccs_master->question[ques_in].object[sch_obj_cnt].object_tablespace,1)
       ELSE
        CALL ms_add_tbl_space(dccs_master->question[ques_in].object[sch_obj_cnt].object_tablespace,0)
       ENDIF
      ENDIF
     OF "TRIGGER":
      SET op_cnt = 0
      IF ((dccs_master->question[ques_in].object[sch_obj_cnt].table_name="WILDCARD"))
       CALL ms_gather_trig_names(dccs_master->question[ques_in].object[sch_obj_cnt].object_name,
        sch_obj_cnt)
       SET dccs_master->question[ques_in].object[sch_obj_cnt].object_status = "DROP"
      ELSE
       IF (mt_trigger_missing(dccs_master->question[ques_in].object[sch_obj_cnt].object_name,
        dccs_master->question[ques_in].object[sch_obj_cnt].table_name)=1)
        SET dccs_master->question[ques_in].object[sch_obj_cnt].object_status = "DROP"
       ELSE
        SET op_cnt = (op_cnt+ 1)
        SET stat = alterlist(dccs_master->question[ques_in].object[sch_obj_cnt].op,op_cnt)
        SET dccs_master->question[ques_in].object[sch_obj_cnt].op[op_cnt].operations = concat(
         "rdb drop trigger ",dccs_master->question[ques_in].object[sch_obj_cnt].object_name,"  go")
        SET dccs_master->question[ques_in].object[sch_obj_cnt].object_status = "DROP"
        SET dccs_master->question[ques_in].question_object_cnt = (dccs_master->question[ques_in].
        question_object_cnt+ 1)
       ENDIF
      ENDIF
    ENDCASE
  ENDFOR
 ELSEIF (action_in="BUILD")
  SET dccs_master->question[ques_in].obj_act_performed = "BUILD"
  SET op_cnt = 0
  FOR (sch_obj_cnt = 1 TO obj_size)
    CASE (dccs_master->question[ques_in].object[sch_obj_cnt].object_type)
     OF "INDEX":
      IF (ms_index_missing(dccs_master->question[ques_in].object[sch_obj_cnt].object_name)=1)
       SET dccs_master->question[ques_in].object[sch_obj_cnt].object_status = "BUILD"
       IF (findstring("$C",dccs_master->question[ques_in].object[sch_obj_cnt].object_name)=0)
        SET op_cnt = (op_cnt+ 1)
        SET stat = alterlist(dccs_master->question[ques_in].object[sch_obj_cnt].op,op_cnt)
        SET dccs_master->question[ques_in].object[sch_obj_cnt].op[op_cnt].operations = concat(
         "Please run DM2_CAPTURE_DESIRED_SCHEMA to regenerate ",dccs_master->question[ques_in].
         object[sch_obj_cnt].object_type,": ",dccs_master->question[ques_in].object[sch_obj_cnt].
         object_name)
        SET op_cnt = 0
        SET dccs_master->question[ques_in].question_object_cnt = (dccs_master->question[ques_in].
        question_object_cnt+ 1)
       ENDIF
      ELSE
       SET dccs_master->question[ques_in].object[sch_obj_cnt].object_status = "BUILD"
      ENDIF
     OF "TABLE":
      IF (ms_table_missing(dccs_master->question[ques_in].object[sch_obj_cnt].object_name)=1)
       SET dccs_master->question[ques_in].object[sch_obj_cnt].object_status = "BUILD"
       SET op_cnt = (op_cnt+ 1)
       SET stat = alterlist(dccs_master->question[ques_in].object[sch_obj_cnt].op,op_cnt)
       SET dccs_master->question[ques_in].object[sch_obj_cnt].op[op_cnt].operations = concat(
        "Please run DM2_CAPTURE_DESIRED_SCHEMA to regenerate ",dccs_master->question[ques_in].object[
        sch_obj_cnt].object_type,": ",dccs_master->question[ques_in].object[sch_obj_cnt].object_name)
       SET op_cnt = 0
       SET dccs_master->question[ques_in].question_object_cnt = (dccs_master->question[ques_in].
       question_object_cnt+ 1)
      ELSE
       SET dccs_master->question[ques_in].object[sch_obj_cnt].object_status = "BUILD"
      ENDIF
     OF "TRIGGER":
      IF (mt_trigger_missing(dccs_master->question[ques_in].object[sch_obj_cnt].object_name,
       dccs_master->question[ques_in].object[sch_obj_cnt].table_name)=1)
       SET dccs_master->question[ques_in].object[sch_obj_cnt].object_status = "BUILD"
       IF (findstring("$C",dccs_master->question[ques_in].object[sch_obj_cnt].object_name)=0)
        SET op_cnt = (op_cnt+ 1)
        SET stat = alterlist(dccs_master->question[ques_in].object[sch_obj_cnt].op,op_cnt)
        IF ((dccs_master->question[ques_in].object[sch_obj_cnt].table_name="WILDCARD"))
         SET dccs_master->question[ques_in].object[sch_obj_cnt].op[op_cnt].operations = concat(
          "Please run DM2_COMBINE_TRIGGERS to regenerate triggers matching pattern:",dccs_master->
          question[ques_in].object[sch_obj_cnt].object_name)
        ELSE
         SET dccs_master->question[ques_in].object[sch_obj_cnt].op[op_cnt].operations = concat(
          "Please run DM_BUILD_EA_TRIGGERS to regenerate ",dccs_master->question[ques_in].object[
          sch_obj_cnt].object_type,": ",dccs_master->question[ques_in].object[sch_obj_cnt].
          object_name)
        ENDIF
        SET op_cnt = 0
        SET dccs_master->question[ques_in].question_object_cnt = (dccs_master->question[ques_in].
        question_object_cnt+ 1)
       ENDIF
      ELSE
       SET dccs_master->question[ques_in].object[sch_obj_cnt].object_status = "BUILD"
      ENDIF
    ENDCASE
  ENDFOR
 ENDIF
END GO

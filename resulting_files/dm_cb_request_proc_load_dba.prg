CREATE PROGRAM dm_cb_request_proc_load:dba
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
 DECLARE req_stat_check_cnt = i4
 DECLARE diff_ind = i2
 DECLARE first_ind = i2
 DECLARE errmsg = c132
 DECLARE dim_cnt = i4
 DECLARE after_cnt = i4
 DECLARE dcd_cnt = i4
 DECLARE dm_hist_insert(type_in,value_in_old,value_in_new,column_in,ques_in,
  table_name_in,request_num_in) = null WITH public
 DECLARE req_stat_ndx = i4
 DECLARE found_obj = i2
 DECLARE obj_cnt = i4
 DECLARE execute_actions_ind = i2
 DECLARE search_cnt = i4
 DECLARE found_ques = i2
 DECLARE exe_ind = i2
 DECLARE execute_successful = i4
 DECLARE error_logfile = c132
 DECLARE req_answer_nbr = i4
 DECLARE req_ans_hold = i4
 DECLARE req_ans_status_hold = c20
 DECLARE inhouse_ind = i2
 SET inhouse_ind = 0
 SELECT INTO "nl:"
  FROM dm_info
  WHERE info_domain="DATA MANAGEMENT"
   AND info_name="INHOUSE DOMAIN"
  DETAIL
   inhouse_ind = 1
  WITH nocounter
 ;end select
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
 SET req_answer_nbr = 0
 SET found_ques = 0
 SET execute_actions_ind = 0
 SET act_cnt = 0
 SET search_cnt = 0
 SET execute_successful = 0
 SET diff_ind = 0
 SET exe_ind = 0
 SET first_ind = 1
 FREE RECORD rs_rec_proc
 RECORD rs_rec_proc(
   1 list_old[*]
     2 ques_num[1]
       3 question_nbr = i4
     2 req_num[1]
       3 request_number = i4
     2 req_stat[1]
       3 skipped = i2
     2 format_scr[1]
       3 format_script = vc
     2 active[1]
       3 answer_upd = i2
       3 active_ind = i2
   1 list_new[*]
     2 question_nbr = i4
     2 request_number = i4
     2 format_script = vc
     2 active_ind = i2
 )
 FREE RECORD rs_ques
 RECORD rs_ques(
   1 qual[*]
     2 ques = i4
 )
 SUBROUTINE dm_hist_insert(type_in,value_in_old,value_in_new,column_in,ques_in,table_name_in,
  request_num_in)
   CASE (type_in)
    OF "CHAR":
     INSERT  FROM dm_cb_history
      SET history_id = seq(dm_clinical_seq,nextval), table_name = table_name_in, column_name =
       column_in,
       request_number = request_num_in, change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_txt
        = trim(value_in_old),
       new_value_txt = trim(value_in_new), change_reason = "CSV LOAD", change_process =
       "DM_CB_REQUEST_PROC_LOAD",
       question_nbr = ques_in
      WITH nocounter
     ;end insert
    OF "NUMBER":
     INSERT  FROM dm_cb_history
      SET history_id = seq(dm_clinical_seq,nextval), table_name = table_name_in, column_name =
       column_in,
       request_number = request_num_in, change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_num
        = cnvtint(trim(value_in_old)),
       new_value_num = cnvtint(trim(value_in_new)), change_reason = "CSV LOAD", change_process =
       "DM_CB_REQUEST_PROC_LOAD",
       question_nbr = ques_in
      WITH nocounter
     ;end insert
    OF "DATE":
     INSERT  FROM dm_cb_history
      SET history_id = seq(dm_clinical_seq,nextval), table_name = table_name_in, column_name =
       column_in,
       request_number = request_num_in, change_dt_tm = cnvtdatetime(curdate,curtime3),
       old_value_dt_tm = cnvtdatetime(value_in_old),
       new_value_dt_tm = cnvtdatetime(value_in_new), change_reason = "CSV LOAD", change_process =
       "DM_CB_REQUEST_PROC_LOAD",
       question_nbr = ques_in
      WITH nocounter
     ;end insert
   ENDCASE
 END ;Subroutine
 SET req_stat_check_cnt = value(size(requestin->list_0,5))
 IF (req_stat_check_cnt > 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Updating dm_cb_request_processing.."
  SELECT INTO "nl:"
   FROM dm_cb_request_processing r
   ORDER BY r.question_nbr, r.request_number
   HEAD REPORT
    dcd_cnt = 0
   DETAIL
    dcd_cnt = (dcd_cnt+ 1)
    IF (mod(dcd_cnt,10)=1)
     stat = alterlist(rs_rec_proc->list_old,(dcd_cnt+ 9))
    ENDIF
    rs_rec_proc->list_old[dcd_cnt].req_num[1].request_number = r.request_number, rs_rec_proc->
    list_old[dcd_cnt].ques_num[1].question_nbr = r.question_nbr, rs_rec_proc->list_old[dcd_cnt].
    format_scr[1].format_script = r.format_script,
    rs_rec_proc->list_old[dcd_cnt].active[1].active_ind = r.active_ind
   FOOT REPORT
    stat = alterlist(rs_rec_proc->list_old,dcd_cnt)
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
     stat = alterlist(rs_rec_proc->list_new,(dcd_cnt+ 9))
    ENDIF
    rs_rec_proc->list_new[dcd_cnt].request_number = cnvtint(requestin->list_0[d.seq].request_number),
    rs_rec_proc->list_new[dcd_cnt].format_script = requestin->list_0[d.seq].format_script,
    rs_rec_proc->list_new[dcd_cnt].question_nbr = cnvtint(requestin->list_0[d.seq].question_nbr),
    rs_rec_proc->list_new[dcd_cnt].active_ind = cnvtint(requestin->list_0[d.seq].active_ind)
   FOOT REPORT
    stat = alterlist(rs_rec_proc->list_new,dcd_cnt)
   WITH nocounter
  ;end select
  FOR (dcd_cnt = 1 TO size(rs_rec_proc->list_new,5))
    SET req_stat_ndx = 0
    SET found_obj = 0
    SET obj_cnt = 0
    FOR (obj_cnt = 1 TO size(rs_rec_proc->list_old,5))
      IF ((rs_rec_proc->list_old[obj_cnt].format_scr[1].format_script=rs_rec_proc->list_new[dcd_cnt].
      format_script)
       AND (rs_rec_proc->list_old[obj_cnt].req_num[1].request_number=rs_rec_proc->list_new[dcd_cnt].
      request_number))
       SET req_stat_ndx = obj_cnt
       SET obj_cnt = size(rs_rec_proc->list_old,5)
       SET found_obj = 1
      ENDIF
    ENDFOR
    IF (found_obj=1)
     IF ((rs_rec_proc->list_old[req_stat_ndx].active_ind != rs_rec_proc->list_new[dcd_cnt].active_ind
     ))
      IF ((rs_rec_proc->list_old[req_stat_ndx].active_ind=0)
       AND (rs_rec_proc->list_new[dcd_cnt].active_ind=1))
       SET found_ques = 0
       SET execute_actions_ind = 1
       FOR (search_cnt = 1 TO size(rs_ques->qual,5))
         IF ((rs_rec_proc->list_new[dcd_cnt].question_nbr=rs_ques->qual[search_cnt].ques))
          SET found_ques = 1
          SET search_cnt = size(rs_ques->qual,5)
         ENDIF
       ENDFOR
       IF (found_ques=0)
        SET act_cnt = (act_cnt+ 1)
        SET stat = alterlist(rs_ques->qual,act_cnt)
        SET rs_ques->qual[act_cnt].ques = rs_rec_proc->list_new[dcd_cnt].question_nbr
       ENDIF
      ENDIF
      CALL dm_hist_insert("NUMBER",cnvtstring(rs_rec_proc->list_old[req_stat_ndx].active[1].
        active_ind),cnvtstring(rs_rec_proc->list_new[dcd_cnt].active_ind),"ACTIVE_IND",rs_rec_proc->
       list_new[dcd_cnt].question_nbr,
       "DM_CB_REQUEST_PROCESSING",rs_rec_proc->list_new[dcd_cnt].request_number)
      SET diff_ind = 1
      IF (diff_ind=1)
       UPDATE  FROM dm_cb_request_processing dcd
        SET dcd.active_ind = rs_rec_proc->list_new[dcd_cnt].active_ind, dcd.updt_cnt = (dcd.updt_cnt
         + 1), dcd.updt_applctx = 103,
         dcd.updt_dt_tm = cnvtdatetime(curdate,curtime3)
        WHERE (dcd.request_number=rs_rec_proc->list_new[dcd_cnt].request_number)
         AND (dcd.format_script=rs_rec_proc->list_new[dcd_cnt].format_script)
        WITH nocounter
       ;end update
       SET diff_ind = 0
      ENDIF
     ENDIF
    ELSE
     INSERT  FROM dm_cb_request_processing dcd
      SET dcd.active_ind = rs_rec_proc->list_new[dcd_cnt].active_ind, dcd.format_script = trim(
        rs_rec_proc->list_new[dcd_cnt].format_script), dcd.updt_applctx = 103,
       dcd.question_nbr = rs_rec_proc->list_new[dcd_cnt].question_nbr, dcd.updt_dt_tm = cnvtdatetime(
        curdate,curtime3), dcd.request_number = rs_rec_proc->list_new[dcd_cnt].request_number
      WITH nocounter
     ;end insert
     SET found_ques = 0
     SET execute_actions_ind = 1
     FOR (search_cnt = 1 TO size(rs_ques->qual,5))
       IF ((rs_rec_proc->list_new[dcd_cnt].question_nbr=rs_ques->qual[search_cnt].ques))
        SET found_ques = 1
        SET search_cnt = size(rs_ques->qual,5)
       ENDIF
     ENDFOR
     IF (found_ques=0)
      SET act_cnt = (act_cnt+ 1)
      SET stat = alterlist(rs_ques->qual,act_cnt)
      SET rs_ques->qual[act_cnt].ques = rs_rec_proc->list_new[dcd_cnt].question_nbr
     ENDIF
    ENDIF
  ENDFOR
  FOR (dcd_cnt = 1 TO size(rs_rec_proc->list_old,5))
    SET req_stat_ndx = 0
    SET found_obj = 0
    SET obj_cnt = 0
    FOR (obj_cnt = 1 TO size(rs_rec_proc->list_new,5))
      IF ((rs_rec_proc->list_new[obj_cnt].format_script=rs_rec_proc->list_old[dcd_cnt].format_scr[1].
      format_script)
       AND (rs_rec_proc->list_new[obj_cnt].request_number=rs_rec_proc->list_old[dcd_cnt].req_num[1].
      request_number))
       SET req_stat_ndx = obj_cnt
       SET obj_cnt = size(rs_rec_proc->list_new,5)
       SET found_obj = 1
      ENDIF
    ENDFOR
    IF (found_obj=0)
     UPDATE  FROM dm_cb_request_processing r
      SET r.active_ind = 0, r.updt_applctx = 103, r.updt_cnt = (r.updt_cnt+ 1),
       r.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (rs_rec_proc->list_old[dcd_cnt].request_number=r.request_number)
       AND (rs_rec_proc->list_old[dcd_cnt].format_script=r.format_script)
       AND r.active_ind=1
      WITH nocounter
     ;end update
     IF (curqual > 0)
      CALL dm_hist_insert("NUMBER",cnvtstring(rs_rec_proc->list_old[dcd_cnt].active[1].active_ind),
       "0","ACTIVE_IND",rs_rec_proc->list_old[dcd_cnt].ques_num[1].question_nbr,
       "DM_CB_REQUEST_PROCESSING",rs_rec_proc->list_old[dcd_cnt].request_number)
     ENDIF
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM dm_cb_request_processing di,
    (dummyt d  WITH seq = value(size(requestin->list_0,5)))
   PLAN (d)
    JOIN (di
    WHERE di.request_number=cnvtint(requestin->list_0[d.seq].request_number)
     AND (di.format_script=requestin->list_0[d.seq].format_script))
   DETAIL
    IF (first_ind=1)
     readme_data->message = concat("Missing format_script(s): ",trim(requestin->list_0[d.seq].
       format_script))
    ELSE
     readme_data->message = concat(readme_data->message,", ",trim(requestin->list_0[d.seq].
       format_script))
    ENDIF
    first_ind = 0
   WITH outerjoin = d, dontexist
  ;end select
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed.  The requestin structure has not been ",
   "populated with dm_cb_request_processing.csv information.")
  GO TO exit_script
 ENDIF
 IF (first_ind=1)
  IF (error(errmsg,0) != 0)
   SET readme_data->message = errmsg
   GO TO exit_script
  ENDIF
  IF (execute_actions_ind=1
   AND inhouse_ind != 1)
   SET act_cnt = 0
   FOR (act_cnt = 1 TO size(rs_ques->qual,5))
     SET req_ans_hold = 0
     SET req_ans_status_hold = ""
     SELECT INTO "nl:"
      FROM dm_cb_answers a
      WHERE (a.question_nbr=rs_ques->qual[act_cnt].ques)
       AND a.answer_status="SELECTED"
       AND a.active_ind=1
      DETAIL
       req_ans_status_hold = a.action_status, req_ans_hold = a.answer_nbr
      WITH nocounter
     ;end select
     IF (curqual > 0
      AND req_ans_status_hold != "EXECUTE")
      UPDATE  FROM dm_cb_answers a
       SET a.action_status = "EXECUTE", a.updt_applctx = 103, a.updt_cnt = (a.updt_cnt+ 1),
        a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       WHERE (a.question_nbr=rs_ques->qual[act_cnt].ques)
        AND a.answer_status="SELECTED"
        AND a.active_ind=1
       WITH nocounter
      ;end update
      IF (curqual > 0)
       INSERT  FROM dm_cb_history
        SET history_id = seq(dm_clinical_seq,nextval), table_name = "DM_CB_ANSWERS", column_name =
         "ACTION_STATUS",
         change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_txt = trim(req_ans_status_hold),
         new_value_txt = "EXECUTE",
         change_reason = "CSV LOAD", change_process = "DM_DBIMPORT", question_nbr = rs_ques->qual[
         act_cnt].ques,
         answer_nbr = req_ans_hold
        WITH nocounter
       ;end insert
      ENDIF
     ENDIF
     SELECT INTO "nl:"
      FROM dm_cb_answers a
      WHERE (a.question_nbr=rs_ques->qual[act_cnt].ques)
       AND a.answer_status="SELECTED"
       AND a.action_status="EXECUTE"
       AND a.active_ind=1
      HEAD REPORT
       exe_ind = 0
      DETAIL
       exe_ind = 1, req_answer_nbr = a.answer_nbr
      WITH nocounter
     ;end select
     IF (exe_ind=1)
      EXECUTE dm_cb_scan_for_execute rs_ques->qual[act_cnt].ques, "REQ_PROC_LOAD"
      IF (execute_successful=0)
       SET readme_data->message = concat("Error performing action for Question Number: ",trim(
         cnvtstring(rs_ques->qual[act_cnt].ques)),", Answer Number: ",trim(cnvtstring(req_answer_nbr)
         ),". Request actions failed. Log File: ",
        error_logfile,".")
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
  SET readme_data->status = "S"
  SET readme_data->message = "All dm_cb_request_processing rows inserted successfully."
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

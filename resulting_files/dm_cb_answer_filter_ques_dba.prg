CREATE PROGRAM dm_cb_answer_filter_ques:dba
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
 DECLARE dcafq_err_cd = i2
 DECLARE dcafq_err_msg = c100
 DECLARE execute_successful = i2
 DECLARE dcafq_fnd_ind = i2
 SET dcafq_err_cd = 0
 SET dcafq_err_msg = fillstring(100,"")
 SET execute_successful = 0
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting dm_cb_answer_filter_ques script"
 SET dcafq_err_cd = error(dcafq_err_msg,1)
 SET dcafq_err_cd = 0
 SELECT INTO "nl:"
  FROM dm_info
  WHERE info_domain="DATA MANAGEMENT"
   AND info_name="INHOUSE DOMAIN"
  WITH nocounter
 ;end select
 SET dcafq_err_cd = error(dcafq_err_msg,1)
 IF (dcafq_err_cd > 0)
  GO TO exit_program
 ENDIF
 IF (curqual > 0)
  SET execute_successful = 1
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-Success for Inhouse."
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM user_tables dutc
  WHERE dutc.table_name IN ("DM_CB_ANSWERS", "PM_PREF", "PM_PREF_SETUP")
  DETAIL
   IF (checkdic(dutc.table_name,"T",0)=2)
    dcafq_fnd_ind = (dcafq_fnd_ind+ 1)
   ENDIF
  WITH nocounter
 ;end select
 SET dcafq_err_cd = error(dcafq_err_msg,1)
 IF (dcafq_err_cd > 0)
  GO TO exit_program
 ENDIF
 IF (dcafq_fnd_ind < 3)
  SET execute_successful = 1
  SET readme_data->status = "S"
  SET readme_data->message =
  "One or more target tables do not exist. Auto-Success due to schema not being present."
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_cb_answers a
  WHERE a.question_nbr=10
   AND a.answer_status > " "
  WITH nocounter
 ;end select
 SET dcafq_err_cd = error(dcafq_err_msg,1)
 IF (dcafq_err_cd > 0)
  GO TO exit_program
 ENDIF
 IF (curqual > 0)
  SET execute_successful = 1
  SET readme_data->status = "S"
  SET readme_data->message = "Question 10 has valued answer. No actions required."
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM pm_pref pp,
   pm_pref_setup pps
  PLAN (pp
   WHERE pp.pref_type_flag=9)
   JOIN (pps
   WHERE pps.pm_pref_setup_id=pp.pm_pref_setup_id
    AND pps.application_number=100100)
  WITH maxqual(pp,1)
 ;end select
 SET dcafq_err_cd = error(dcafq_err_msg,1)
 IF (dcafq_err_cd > 0)
  GO TO exit_program
 ENDIF
 IF (curqual > 0)
  UPDATE  FROM dm_cb_answers a
   SET a.answer_status = "SELECTED", a.action_status = "EXECUTE", a.updt_applctx = 109,
    a.updt_task = reqinfo->updt_task
   WHERE a.answer_nbr=25
    AND a.active_ind=1
   WITH nocounter
  ;end update
  SET dcafq_err_cd = error(dcafq_err_msg,1)
  IF (dcafq_err_cd > 0)
   GO TO exit_program
  ENDIF
  UPDATE  FROM dm_cb_answers a
   SET a.answer_status = "DESELECTED", a.action_status = null, a.updt_applctx = 109,
    a.updt_task = reqinfo->updt_task
   WHERE a.answer_nbr=24
    AND a.active_ind=1
   WITH nocounter
  ;end update
  SET dcafq_err_cd = error(dcafq_err_msg,1)
  IF (dcafq_err_cd > 0)
   GO TO exit_program
  ENDIF
 ELSE
  UPDATE  FROM dm_cb_answers a
   SET a.answer_status = "SELECTED", a.action_status = "EXECUTE", a.updt_applctx = 109,
    a.updt_task = reqinfo->updt_task
   WHERE a.answer_nbr=24
    AND a.active_ind=1
   WITH nocounter
  ;end update
  SET dcafq_err_cd = error(dcafq_err_msg,1)
  IF (dcafq_err_cd > 0)
   GO TO exit_program
  ENDIF
  UPDATE  FROM dm_cb_answers a
   SET a.answer_status = "DESELECTED", a.action_status = null, a.updt_applctx = 109,
    a.updt_task = reqinfo->updt_task
   WHERE a.answer_nbr=25
    AND a.active_ind=1
   WITH nocounter
  ;end update
  SET dcafq_err_cd = error(dcafq_err_msg,1)
  IF (dcafq_err_cd > 0)
   GO TO exit_program
  ENDIF
 ENDIF
 COMMIT
 EXECUTE dm_cb_scan_for_execute 10, "DM_CB_ANSWER_FILTER_QUES"
 IF (execute_successful=0)
  SET readme_data->message = "Error performing action for Question Number:10. Index still exists."
  GO TO exit_program
 ENDIF
 UPDATE  FROM dm_cb_questions q
  SET q.ask_flag = 0, q.updt_applctx = 109, q.updt_task = reqinfo->updt_task
  WHERE q.question_nbr=10
  WITH nocounter
 ;end update
 SET dcafq_err_cd = error(dcafq_err_msg,1)
 IF (dcafq_err_cd > 0)
  GO TO exit_program
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "DM_CB_ANSWERS question 10 has been updated and answered."
#exit_program
 IF (((dcafq_err_cd > 0) OR (execute_successful=0)) )
  SET readme_data->status = "F"
  SET readme_data->message = concat(trim(dcafq_err_msg),":",readme_data->message)
 ENDIF
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO

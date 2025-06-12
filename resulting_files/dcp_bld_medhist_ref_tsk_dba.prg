CREATE PROGRAM dcp_bld_medhist_ref_tsk:dba
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
 SET readme_data->message = "Readme Failed: Starting script dcp_bld_medhist_ref_tsk.prg..."
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE num_records = i4 WITH protect, noconstant(size(requestin->list_0,5))
 DECLARE record_cnt = i4 WITH protect, noconstant(0)
 DECLARE taskact_cd = f8 WITH noconstant(0.0)
 DECLARE tasktype_cd = f8 WITH noconstant(0.0)
 DECLARE row_exists_ind = i2 WITH noconstant(0)
 DECLARE task_description = vc WITH protect, noconstant("")
 DECLARE task_description_key = vc WITH protect, noconstant("")
 DECLARE task_act_cdf_meaning = vc WITH protect, constant("MED HISTORY")
 DECLARE task_type_cdf_meaning = vc WITH protect, constant("MEDRECON")
 DECLARE temp_task_description = vc WITH protect
 DECLARE temp_event_cd = f8 WITH protect
 FOR (record_cnt = 1 TO num_records)
   IF (trim(requestin->list_0[record_cnt].task_activity_cdf)=task_act_cdf_meaning
    AND trim(requestin->list_0[record_cnt].task_type_cdf)=task_type_cdf_meaning)
    SET task_description = trim(requestin->list_0[record_cnt].task_desc)
    SET task_description_key = cnvtupper(task_description)
   ENDIF
 ENDFOR
 IF (task_description="")
  SET readme_data->message = "Undefined name for medication reconciliation reference task."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6027
   AND cv.cdf_meaning=task_act_cdf_meaning
   AND cv.active_ind=1
  DETAIL
   taskact_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual > 1)
  SET readme_data->message = concat("Multiple task activity code values of cdf meaning ",
   task_act_cdf_meaning,".")
  GO TO exit_script
 ELSEIF (taskact_cd <= 0.0)
  SET readme_data->message = concat("No task activity code values of cdf meaning ",
   task_act_cdf_meaning,".")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6026
   AND cv.cdf_meaning=task_type_cdf_meaning
   AND cv.active_ind=1
  DETAIL
   tasktype_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual > 1)
  SET readme_data->message = concat("Multiple task type code values of cdf meaning ",
   task_type_cdf_meaning,".")
  GO TO exit_script
 ELSEIF (tasktype_cd <= 0.0)
  SET readme_data->message = concat("No task type code values of cdf meaning ",task_type_cdf_meaning,
   ".")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM order_task ot
  WHERE ot.task_activity_cd=taskact_cd
   AND ot.task_type_cd=tasktype_cd
   AND ot.active_ind=1
  DETAIL
   row_exists_ind = 1
  WITH nocounter
 ;end select
 CALL echo(build("*** row_exists_ind = ",row_exists_ind,"*** taskact_cd =",taskact_cd,
   "*** tasktype_cd =",
   tasktype_cd))
 CALL echo(build("*** task_description = ",task_description,"*** task_description_key =",
   task_description_key))
 IF (row_exists_ind=0)
  SET temp_task_description = task_description
  EXECUTE tsk_post_event_code
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Fail to create an event code for task ",task_description,". ",
    errmsg,".")
   GO TO exit_script
  ENDIF
  INSERT  FROM order_task ot
   SET ot.reference_task_id = seq(reference_seq,nextval), ot.task_activity_cd = taskact_cd, ot
    .task_type_cd = tasktype_cd,
    ot.task_description = task_description, ot.task_description_key = task_description_key, ot
    .event_cd = temp_event_cd,
    ot.cernertask_flag = 0, ot.active_ind = 1, ot.reschedule_time = 999,
    ot.allpositionchart_ind = 1, ot.quick_chart_done_ind = 1, ot.updt_id = reqinfo->updt_id,
    ot.updt_dt_tm = cnvtdatetime(curdate,curtime3), ot.updt_applctx = reqinfo->updt_applctx, ot
    .updt_cnt = 0,
    ot.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->message = concat("Insert failed to create the reference task ",task_description,
    ". ",errmsg,".",
    readme_data->message)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
END GO

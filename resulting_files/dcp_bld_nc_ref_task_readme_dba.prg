CREATE PROGRAM dcp_bld_nc_ref_task_readme:dba
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
 SET readme_data->message = "Readme Failed: Starting script dcp_bld_nc_ref_task_readme.prg..."
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE taskact_cd = f8 WITH noconstant(0.0)
 DECLARE tasktype_cd = f8 WITH noconstant(0.0)
 DECLARE row_exists_ind = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6027
   AND cv.cdf_meaning="CERSPECCLLCT"
  DETAIL
   taskact_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6026
   AND cv.cdf_meaning="NURSECOL"
  DETAIL
   tasktype_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_task ot
  WHERE ot.task_activity_cd=taskact_cd
   AND ot.active_ind=1
  DETAIL
   row_exists_ind = 1
  WITH nocounter
 ;end select
 IF (row_exists_ind=0
  AND taskact_cd > 0.0)
  INSERT  FROM order_task ot
   SET ot.reference_task_id = seq(reference_seq,nextval), ot.task_activity_cd = taskact_cd, ot
    .task_type_cd = tasktype_cd,
    ot.task_description = "Cerner Specimen Collect", ot.task_description_key =
    "CERNER SPECIMEN COLLECT", ot.cernertask_flag = 0,
    ot.active_ind = 1, ot.overdue_min = 4, ot.overdue_units = 2,
    ot.retain_time = 5, ot.retain_units = 3, ot.reschedule_time = 72,
    ot.allpositionchart_ind = 1, ot.quick_chart_done_ind = 1, ot.updt_id = reqinfo->updt_id,
    ot.updt_dt_tm = cnvtdatetime(curdate,curtime3), ot.updt_applctx = reqinfo->updt_applctx, ot
    .updt_cnt = 0,
    ot.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Insert failed to create the reference task",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
#exit_script
END GO

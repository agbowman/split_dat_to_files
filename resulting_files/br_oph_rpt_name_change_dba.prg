CREATE PROGRAM br_oph_rpt_name_change:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_oph_rpt_name_change.prg> script"
 DECLARE errmsg = vc WITH protect, noconstant("")
 UPDATE  FROM br_datamart_report bd
  SET bd.report_name = "Ophthalmology Measurements - obsoleted bedrock content", bd.updt_cnt = (bd
   .updt_cnt+ 1), bd.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   bd.updt_id = reqinfo->updt_id, bd.updt_task = reqinfo->updt_task, bd.updt_applctx = reqinfo->
   updt_applctx
  WHERE bd.report_mean="MP_OPH_MEASURE"
   AND bd.report_name="Ophthalmology Measurements"
   AND bd.br_datamart_category_id IN (
  (SELECT
   b.br_datamart_category_id
   FROM br_datamart_category b
   WHERE b.category_type_flag=6
    AND b.category_mean="MP_OPH_SUMMARY"))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failure while updating report name of ophthalmology components >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_datamart_report bd
  SET bd.report_name = "Ophthalmology Prescriptions - obsoleted bedrock content", bd.updt_cnt = (bd
   .updt_cnt+ 1), bd.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   bd.updt_id = reqinfo->updt_id, bd.updt_task = reqinfo->updt_task, bd.updt_applctx = reqinfo->
   updt_applctx
  WHERE bd.report_mean="MP_OPH_SCRIPTS"
   AND bd.report_name="Ophthalmology Prescriptions"
   AND bd.br_datamart_category_id IN (
  (SELECT
   b.br_datamart_category_id
   FROM br_datamart_category b
   WHERE b.category_type_flag=6
    AND b.category_mean="MP_OPH_SUMMARY"))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failure while updating report name of ophthalmology components >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_datamart_report bd
  SET bd.report_name = "Ophthalmology Measurements - obsoleted bedrock content", bd.updt_cnt = (bd
   .updt_cnt+ 1), bd.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   bd.updt_id = reqinfo->updt_id, bd.updt_task = reqinfo->updt_task, bd.updt_applctx = reqinfo->
   updt_applctx
  WHERE bd.report_mean="MP_OPH_MEASURE"
   AND bd.report_name="Ophthalmology Measurements"
   AND bd.br_datamart_category_id IN (
  (SELECT
   b.br_datamart_category_id
   FROM br_datamart_category b
   WHERE b.category_mean="VB_*"))
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failure while updating report name of ophthalmology components >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_datamart_report bd
  SET bd.report_name = "Ophthalmology Prescriptions - obsoleted bedrock content", bd.updt_cnt = (bd
   .updt_cnt+ 1), bd.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   bd.updt_id = reqinfo->updt_id, bd.updt_task = reqinfo->updt_task, bd.updt_applctx = reqinfo->
   updt_applctx
  WHERE bd.report_mean="MP_OPH_SCRIPTS"
   AND bd.report_name="Ophthalmology Prescriptions"
   AND bd.br_datamart_category_id IN (
  (SELECT
   b.br_datamart_category_id
   FROM br_datamart_category b
   WHERE b.category_mean="VB_*"))
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update report name of ophthalmology components  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_oph_rpt_name_change.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

CREATE PROGRAM cv_rdm_add_ecg_chart_request:dba
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
 SET readme_data->message = "Readme Failed: Starting cv_rdm_add_ecg_chart_request script"
 DECLARE cdr_id = f8 WITH protect, noconstant(0.0)
 DECLARE serrmsg = vc WITH protect
 DECLARE sb_map = i4 WITH protect, constant(19)
 DECLARE request_num = i4 WITH protect, constant(1349803)
 DECLARE disp_text = vc WITH protect, constant("ECG Interpretations")
 SELECT INTO "nl:"
  FROM chart_discern_request cdr
  WHERE cdr.request_number=request_num
   AND cdr.chart_discern_request_id != 0.0
  DETAIL
   cdr_id = cdr.chart_discern_request_id
  WITH nocounter
 ;end select
 IF (error(serrmsg,0) > 0)
  SET readme_data->message = concat("Readme Failed: ",serrmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  CALL echo("Row does not exist, insert new row")
  INSERT  FROM chart_discern_request cdr
   SET cdr.chart_discern_request_id = seq(reference_seq,nextval), cdr.request_number = request_num,
    cdr.process_flag = 0,
    cdr.display_text = disp_text, cdr.scope_bit_map = sb_map, cdr.active_ind = 1,
    cdr.updt_id = reqinfo->updt_id, cdr.updt_dt_tm = cnvtdatetime(curdate,curtime3), cdr.updt_task =
    reqinfo->updt_task,
    cdr.updt_applctx = reqinfo->updt_applctx, cdr.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (error(serrmsg,0) > 0)
   SET readme_data->message = concat("Readme Failed: ",serrmsg)
   GO TO exit_script
  ENDIF
 ELSEIF (curqual=1)
  CALL echo("Row exists, update existing row")
  UPDATE  FROM chart_discern_request cdr
   SET cdr.request_number = request_num, cdr.process_flag = 0, cdr.display_text = disp_text,
    cdr.scope_bit_map = sb_map, cdr.active_ind = 1, cdr.updt_id = reqinfo->updt_id,
    cdr.updt_dt_tm = cnvtdatetime(curdate,curtime3), cdr.updt_task = reqinfo->updt_task, cdr
    .updt_applctx = reqinfo->updt_applctx,
    cdr.updt_cnt = (cdr.updt_cnt+ 1)
   WHERE cdr.chart_discern_request_id=cdr_id
   WITH nocounter
  ;end update
  IF (error(serrmsg,0) > 0)
   SET readme_data->message = concat("Readme Failed: ",serrmsg)
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("Multiple rows exist, unexpected condition. Exiting in error ...")
  SET readme_data->message = "Readme Failed: Unexpected condition, multiple qualifying rows exist."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM chart_discern_request cdr
  WHERE cdr.request_number=request_num
   AND cdr.process_flag=0
   AND cdr.display_text=disp_text
   AND cdr.scope_bit_map=sb_map
   AND cdr.active_ind=1
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Correct row not found. Exit script with error.")
  SET readme_data->message = "Readme Failed: Cannot verify that row was inserted correctly."
  GO TO exit_script
 ELSEIF (curqual > 1)
  CALL echo("Too many qualifying rows found. Exit script with error.")
  SET readme_data->message = "Readme Failed: More than one row qualified."
  GO TO exit_script
 ELSE
  CALL echo("Row inserted/updated successfully. Commit results.")
 ENDIF
 SET readme_data->status = "S"
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
  SET readme_data->message = "SUCCESS : Adding ECG Interpretation info to CHART_DISCERN_REQUEST."
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 DECLARE cv_rdm_add_chart_request_vrsn = vc WITH protect, constant("MOD 001 BM9013 03/24/08")
END GO

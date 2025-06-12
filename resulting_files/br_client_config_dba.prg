CREATE PROGRAM br_client_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_client_config.prg> script"
 SET cli_id = 1
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET active_ind = - (1)
 SELECT INTO "nl:"
  FROM br_client bc
  PLAN (bc
   WHERE bc.br_client_id=cli_id)
  DETAIL
   active_ind = bc.active_ind
  WITH nocounter
 ;end select
 IF ((active_ind=- (1)))
  INSERT  FROM br_client bc
   SET bc.br_client_id = cli_id, bc.br_client_name = "Client1", bc.active_ind = 1,
    bc.updt_dt_tm = cnvtdatetime(curdate,curtime3), bc.updt_cnt = 0, bc.updt_id = reqinfo->updt_id,
    bc.updt_task = reqinfo->updt_task, bc.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
 ELSEIF (active_ind=0)
  UPDATE  FROM br_client bc
   SET bc.active_ind = 1, bc.updt_dt_tm = cnvtdatetime(curdate,curtime3), bc.updt_cnt = (bc.updt_cnt
    + 1),
    bc.updt_id = reqinfo->updt_id, bc.updt_task = reqinfo->updt_task, bc.updt_applctx = reqinfo->
    updt_applctx
   WHERE bc.br_client_id=cli_id
   WITH nocounter
  ;end update
 ENDIF
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = concat("Unable to insert client ",cli_id," into br_client table.")
 ENDIF
 GO TO exit_script
#exit_script
 IF (error_flag="Y")
  CALL echo(error_msg)
 ENDIF
 IF (error_flag="N")
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: Ending <br_client_config.prg> script"
  COMMIT
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed: <br_client_config.prg> script"
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

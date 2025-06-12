CREATE PROGRAM br_reseq_mpage_wizards:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_reseq_mpage_wizards.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 UPDATE  FROM br_client_sol_step bcss
  SET bcss.sequence = 110, bcss.updt_cnt = (bcss.updt_cnt+ 1), bcss.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   bcss.updt_task = reqinfo->updt_task, bcss.updt_id = reqinfo->updt_id, bcss.updt_applctx = reqinfo
   ->updt_applctx
  WHERE bcss.solution_mean="COREM"
   AND bcss.step_mean="MPAGES"
   AND bcss.sequence != 110
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure updating MPAGES >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_client_sol_step bcss
  SET bcss.sequence = 120, bcss.updt_cnt = (bcss.updt_cnt+ 1), bcss.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   bcss.updt_task = reqinfo->updt_task, bcss.updt_id = reqinfo->updt_id, bcss.updt_applctx = reqinfo
   ->updt_applctx
  WHERE bcss.solution_mean="COREM"
   AND bcss.step_mean="MPAGEVIEWPOINTS"
   AND bcss.sequence != 120
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure updating VIEWPOINTS >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_client_sol_step bcss
  SET bcss.sequence = 130, bcss.updt_cnt = (bcss.updt_cnt+ 1), bcss.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   bcss.updt_task = reqinfo->updt_task, bcss.updt_id = reqinfo->updt_id, bcss.updt_applctx = reqinfo
   ->updt_applctx
  WHERE bcss.solution_mean="COREM"
   AND bcss.step_mean="QUALMEAS"
   AND bcss.sequence != 130
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure updating QUALMEAS >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_reseq_mpage_wizards.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

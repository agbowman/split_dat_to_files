CREATE PROGRAM br_upd_sol_display:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_upd_sol_display.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 UPDATE  FROM br_client_item_reltn bcir
  SET bcir.item_mean = "PATACCT", bcir.item_display = "Patient Accounting", bcir.updt_dt_tm =
   cnvtdatetime(curdate,curtime),
   bcir.updt_id = reqinfo->updt_id, bcir.updt_task = reqinfo->updt_task, bcir.updt_applctx = reqinfo
   ->updt_applctx,
   bcir.updt_cnt = (bcir.updt_cnt+ 1)
  WHERE bcir.item_mean="PROFIT"
   AND bcir.item_type="SOLUTION"
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Updating br_client_item _reltn row: ",errmsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM br_name_value bnv
  SET bnv.br_value = "Patient Accounting", bnv.br_name = "PATACCT", bnv.updt_dt_tm = cnvtdatetime(
    curdate,curtime),
   bnv.updt_cnt = (bnv.updt_cnt+ 1), bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->
   updt_task,
   bnv.updt_applctx = reqinfo->updt_applctx
  WHERE bnv.br_nv_key1="STEP_CAT_MEAN"
   AND bnv.br_name="PROFIT"
   AND bnv.br_value="ProFit"
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Updating br_name_value row: ",errmsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM br_name_value bnv
  SET bnv.br_value = "Patient Accounting", bnv.updt_dt_tm = cnvtdatetime(curdate,curtime), bnv
   .updt_cnt = (bnv.updt_cnt+ 1),
   bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo->
   updt_applctx
  WHERE bnv.br_nv_key1="SOLUTION_STATUS"
   AND bnv.br_name="LIVE_IN_PROD"
   AND bnv.br_value="PROFIT"
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Updating br_name_value row: ",errmsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM br_report b
  SET b.step_cat_mean = "PATACCT", b.solution_mean = "PATACCT", b.solution_disp =
   "Patient Accounting",
   b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo
   ->updt_task,
   b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->updt_applctx
  WHERE b.step_cat_mean="PROFIT"
   AND b.solution_disp="ProFit"
   AND b.solution_mean="PROFIT"
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Updating br_report row: ",errmsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM br_wizard_hist bwh
  SET bwh.solution_mean = "PATACCT", bwh.prsnl_id = reqinfo->updt_id, bwh.log_dt_tm = cnvtdatetime(
    curdate,curtime3),
   bwh.updt_dt_tm = cnvtdatetime(curdate,curtime3), bwh.updt_id = reqinfo->updt_id, bwh.updt_task =
   reqinfo->updt_task,
   bwh.updt_cnt = (bwh.updt_cnt+ 1), bwh.updt_applctx = reqinfo->updt_applctx
  WHERE bwh.solution_mean="PROFIT"
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Updating br_wizard_hist row: ",errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_upd_sol_display.prg> script"
 IF (errcode=0)
  COMMIT
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

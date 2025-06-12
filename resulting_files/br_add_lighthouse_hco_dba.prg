CREATE PROGRAM br_add_lighthouse_hco:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_add_lighthouse_hco.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE last_step_seq = i4 WITH protect, noconstant(0)
 DECLARE last_seq = i4 WITH protect, noconstant(0)
 UPDATE  FROM br_client_item_reltn bcir
  SET bcir.item_display = "Quality Reporting and Promoting Interoperability Setup"
  WHERE bcir.br_client_id=1
   AND bcir.item_type="STEP"
   AND bcir.item_mean="LIGHTREPORTS"
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting into br_client_item_reltn >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_step bs
  SET bs.step_disp = "Quality Reporting and Promoting Interoperability Setup"
  WHERE bs.step_mean="LIGHTREPORTS"
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure updating into br_step >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET upd_name = 0
 SELECT INTO "nl:"
  FROM br_step bs
  PLAN (bs
   WHERE bs.step_mean="HCOIDSETUP")
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed checking existence of HCOIDSETUP row: ",errmsg)
  GO TO exit_script
 ELSEIF (curqual=0)
  INSERT  FROM br_step bs
   SET bs.step_mean = "HCOIDSETUP", bs.step_disp = "Healthcare Organization ID Setup", bs.step_type
     = "IMPMAINT",
    bs.step_cat_mean = "CORE", bs.step_cat_disp = "Core", bs.default_seq = 5000
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure inserting into br_step >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 UPDATE  FROM br_client_item_reltn bcir
  SET bcir.solution_seq = 240, bcir.item_display = "Quality Reporting and Promoting Interoperability",
   bcir.updt_id = reqinfo->updt_id,
   bcir.updt_dt_tm = cnvtdatetime(curdate,curtime), bcir.updt_task = reqinfo->updt_task, bcir
   .updt_applctx = reqinfo->updt_applctx,
   bcir.updt_cnt = (bcir.updt_cnt+ 1)
  PLAN (bcir
   WHERE bcir.br_client_id=1
    AND bcir.item_type="SOLUTION"
    AND bcir.item_mean="COREL")
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to find/update SOLUTION/COREL row: ",errmsg)
  GO TO exit_script
 ELSEIF (curqual=0)
  INSERT  FROM br_client_item_reltn bcir
   SET bcir.br_client_item_reltn_id = seq(bedrock_seq,nextval), bcir.br_client_id = 1, bcir.item_type
     = "SOLUTION",
    bcir.item_mean = "COREL", bcir.item_display = "Quality Reporting and Promoting Interoperability",
    bcir.solution_seq = 240,
    bcir.solution_type_flag = 1
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure inserting into br_client_item_reltn >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ELSE
  COMMIT
 ENDIF
 SET upd_name = 0
 SELECT INTO "nl:"
  FROM br_client_item_reltn bcir
  WHERE bcir.br_client_id=1
   AND bcir.item_type="STEP"
   AND bcir.item_mean="HCOIDSETUP"
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to verify existence of STEP/HCOIDSETUP row: ",errmsg)
  GO TO exit_script
 ELSEIF (curqual=0)
  INSERT  FROM br_client_item_reltn bcir
   SET bcir.br_client_item_reltn_id = seq(bedrock_seq,nextval), bcir.br_client_id = 1, bcir.item_type
     = "STEP",
    bcir.item_mean = "HCOIDSETUP", bcir.item_display = "Healthcare Organization ID Setup", bcir
    .step_cat_mean = "CORE",
    bcir.step_cat_disp = "Core", bcir.solution_type_flag = 1
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure inserting into br_client_item_reltn >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM br_client_sol_step bcss
  WHERE bcss.br_client_id=1
   AND bcss.solution_mean="COREL"
   AND bcss.step_mean="HCOIDSETUP"
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to check for existence of COREL/HCOIDSETUP row: ",errmsg)
  GO TO exit_script
 ELSEIF (curqual=0)
  SELECT INTO "nl:"
   themax = max(bcss.sequence)
   FROM br_client_sol_step bcss
   PLAN (bcss
    WHERE bcss.solution_mean="COREL")
   DETAIL
    last_step_seq = themax
   WITH nocounter
  ;end select
  INSERT  FROM br_client_sol_step bcss
   SET bcss.br_client_id = 1, bcss.solution_mean = "COREL", bcss.step_mean = "HCOIDSETUP",
    bcss.sequence = (last_step_seq+ 10), bcss.updt_cnt = 0, bcss.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    bcss.updt_task = reqinfo->updt_task, bcss.updt_id = reqinfo->updt_id, bcss.updt_applctx = reqinfo
    ->updt_applctx
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure inserting into br_client_sol_step >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_add_lighthouse_hco.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

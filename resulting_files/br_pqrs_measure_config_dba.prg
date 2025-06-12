CREATE PROGRAM br_pqrs_measure_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_pqrs_measure_config.prg> script"
 FREE SET temp_prg
 RECORD temp_prg(
   1 programs[*]
     2 id = f8
     2 measure_number = vc
     2 measure_display = vc
     2 pilot_eligible_ind = i2
     2 pilot_core_ind = i2
     2 active_ind = i2
 )
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE req_cnt = i4
 SET req_cnt = size(requestin->list_0,5)
 IF (req_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt))
   PLAN (d)
   HEAD REPORT
    stat = alterlist(temp_prg->programs,req_cnt)
   DETAIL
    IF ((requestin->list_0[d.seq].measure_number > " "))
     temp_prg->programs[d.seq].measure_number = requestin->list_0[d.seq].measure_number, temp_prg->
     programs[d.seq].measure_display = requestin->list_0[d.seq].measure_display, temp_prg->programs[d
     .seq].pilot_eligible_ind = cnvtint(trim(requestin->list_0[d.seq].pilot_eligible_ind)),
     temp_prg->programs[d.seq].pilot_core_ind = cnvtint(trim(requestin->list_0[d.seq].pilot_core_ind)
      ), temp_prg->programs[d.seq].active_ind = cnvtint(trim(requestin->list_0[d.seq].active_ind))
    ENDIF
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure selecting PQRS measures from requestin list >> ",errmsg
    )
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt)),
    br_pqrs_meas b
   PLAN (d)
    JOIN (b
    WHERE b.meas_number_ident=cnvtupper(temp_prg->programs[d.seq].measure_number))
   DETAIL
    temp_prg->programs[d.seq].id = b.br_pqrs_meas_id
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure selecting the PQRS measures >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  UPDATE  FROM br_pqrs_meas b,
    (dummyt d  WITH seq = value(req_cnt))
   SET b.meas_number_ident = trim(substring(1,50,temp_prg->programs[d.seq].measure_number)), b
    .meas_display = trim(substring(1,500,temp_prg->programs[d.seq].measure_display)), b
    .pilot_eligible_ind = temp_prg->programs[d.seq].pilot_eligible_ind,
    b.pilot_core_ind = temp_prg->programs[d.seq].pilot_core_ind, b.active_ind = temp_prg->programs[d
    .seq].active_ind, b.updt_cnt = (b.updt_cnt+ 1),
    b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_applctx =
    reqinfo->updt_applctx,
    b.updt_task = reqinfo->updt_task
   PLAN (d
    WHERE (temp_prg->programs[d.seq].id > 0.0))
    JOIN (b
    WHERE (b.br_pqrs_meas_id=temp_prg->programs[d.seq].id))
   WITH nocounter
  ;end update
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure updating PQRS measures >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  INSERT  FROM br_pqrs_meas b,
    (dummyt d  WITH seq = value(req_cnt))
   SET b.br_pqrs_meas_id = seq(bedrock_seq,nextval), b.meas_number_ident = trim(substring(1,50,
      temp_prg->programs[d.seq].measure_number)), b.meas_display = trim(substring(1,500,temp_prg->
      programs[d.seq].measure_display)),
    b.pilot_eligible_ind = temp_prg->programs[d.seq].pilot_eligible_ind, b.pilot_core_ind = temp_prg
    ->programs[d.seq].pilot_core_ind, b.active_ind = temp_prg->programs[d.seq].active_ind,
    b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
    b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->updt_task
   PLAN (d
    WHERE (temp_prg->programs[d.seq].measure_number > " ")
     AND (temp_prg->programs[d.seq].id=0))
    JOIN (b)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure inserting PQRS measures >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: <br_pqrs_measure_config.prg> script"
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Failed to find any rows in the br_pqrs_measures.csv file"
 ENDIF
#exit_script
 FREE SET temp_prg
END GO

CREATE PROGRAM br_wizard_parameters_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_wizard_parameters_config.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE step_mean_cnt = i4 WITH protect, noconstant(0)
 DECLARE param_cnt = i4 WITH protect, noconstant(0)
 DECLARE existsflag = i2 WITH protect, noconstant(0)
 DECLARE seq_change_flag = i2 WITH protect, noconstant(0)
 DECLARE temp_step_param_id = f8 WITH protect, noconstant(0.0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE temp_pos = i4 WITH protect, noconstant(0)
 DECLARE del_param_cnt = i4 WITH protect, noconstant(0)
 IF ( NOT (validate(param_ids,0)))
  RECORD param_ids(
    1 params[*]
      2 param_id = f8
  ) WITH protect
 ENDIF
 IF ( NOT (validate(delete_param_ids,0)))
  RECORD delete_param_ids(
    1 params[*]
      2 param_id = f8
  ) WITH protect
 ENDIF
 CALL echorecord(request)
 SET step_mean_cnt = size(request->step_means,5)
 FOR (n = 1 TO step_mean_cnt)
   SET param_cnt = size(request->step_means[n].param_list,5)
   SET stat = alterlist(param_ids->params,param_cnt)
   FOR (p = 1 TO param_cnt)
     SET existsflag = 0
     SET seq_change_flag = 0
     SELECT INTO "nl:"
      FROM br_step_parameter bsp
      PLAN (bsp
       WHERE cnvtupper(bsp.step_mean)=cnvtupper(request->step_means[n].step_mean)
        AND cnvtupper(bsp.parameter_name)=cnvtupper(request->step_means[n].param_list[p].
        parameter_name)
        AND cnvtupper(bsp.parameter_value)=cnvtupper(request->step_means[n].param_list[p].
        parameter_value))
      DETAIL
       param_ids->params[p].param_id = bsp.br_step_parameter_id, existsflag = 1
       IF ((bsp.parameter_seq != request->step_means[n].param_list[p].parameter_seq))
        seq_change_flag = 1
       ENDIF
      WITH nocounter
     ;end select
     SET errcode = error(errmsg,0)
     IF (errcode > 0)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = concat("br_step_param select failure",errmsg)
      GO TO exit_script
     ENDIF
     IF (seq_change_flag=1)
      UPDATE  FROM br_step_parameter bsp
       SET bsp.parameter_seq = request->step_means[n].param_list[p].parameter_seq, bsp.updt_cnt = (
        bsp.updt_cnt+ 1), bsp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        bsp.updt_id = reqinfo->updt_id, bsp.updt_task = reqinfo->updt_task, bsp.updt_applctx =
        reqinfo->updt_applctx
       WHERE (bsp.br_step_parameter_id=param_ids->params[p].param_id)
       WITH nocounter
      ;end update
      SET errcode = error(errmsg,0)
      IF (errcode > 0)
       ROLLBACK
       SET readme_data->status = "F"
       SET readme_data->message = concat("update seq failure",errmsg)
       GO TO exit_script
      ENDIF
     ENDIF
     IF (existsflag=0)
      SELECT INTO "nl:"
       z = seq(bedrock_seq,nextval)
       FROM dual d
       DETAIL
        temp_step_param_id = z
       WITH nocounter
      ;end select
      SET errcode = error(errmsg,0)
      IF (errcode > 0)
       ROLLBACK
       SET readme_data->status = "F"
       SET readme_data->message = concat("insert seq failure",errmsg)
       GO TO exit_script
      ENDIF
      INSERT  FROM br_step_parameter bsp
       SET bsp.br_step_parameter_id = temp_step_param_id, bsp.step_mean = request->step_means[n].
        step_mean, bsp.parameter_name = request->step_means[n].param_list[p].parameter_name,
        bsp.parameter_value = request->step_means[n].param_list[p].parameter_value, bsp.parameter_seq
         = request->step_means[n].param_list[p].parameter_seq, bsp.updt_cnt = 0,
        bsp.updt_dt_tm = cnvtdatetime(curdate,curtime3), bsp.updt_id = reqinfo->updt_id, bsp
        .updt_task = reqinfo->updt_task,
        bsp.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      SET errcode = error(errmsg,0)
      IF (errcode > 0)
       ROLLBACK
       SET readme_data->status = "F"
       SET readme_data->message = concat("br_step_param insert failure",errmsg)
       GO TO exit_script
      ENDIF
      SET param_ids->params[p].param_id = temp_step_param_id
     ENDIF
   ENDFOR
   SET temp_pos = 0
   SET del_param_cnt = 0
   SELECT INTO "nl:"
    FROM br_step_parameter bsp
    PLAN (bsp
     WHERE cnvtupper(bsp.step_mean)=cnvtupper(request->step_means[n].step_mean))
    DETAIL
     temp_pos = locateval(num,1,size(param_ids->params,5),bsp.br_step_parameter_id,param_ids->params[
      num].param_id)
     IF (temp_pos=0)
      del_param_cnt = (del_param_cnt+ 1), stat = alterlist(delete_param_ids->params,del_param_cnt),
      delete_param_ids->params[del_param_cnt].param_id = bsp.br_step_parameter_id
     ENDIF
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("locate unused params error",errmsg)
    GO TO exit_script
   ENDIF
   IF (del_param_cnt > 0)
    DELETE  FROM br_step_parameter bsp,
      (dummyt d  WITH seq = value(del_param_cnt))
     SET bsp.seq = 1
     PLAN (d)
      JOIN (bsp
      WHERE (bsp.br_step_parameter_id=delete_param_ids->params[d.seq].param_id))
     WITH nocounter
    ;end delete
    SET errcode = error(errmsg,0)
    IF (errcode > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("locate unused params error",errmsg)
     GO TO exit_script
    ENDIF
   ENDIF
   SET stat = alterlist(delete_param_ids->params,0)
 ENDFOR
 IF (validate(test_parameters_config,0)=1)
  CALL echo("testing mode. No commit")
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_wizard_parameters_config.prg> script"
#exit_script
 CALL echorecord(readme_data)
END GO

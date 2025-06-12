CREATE PROGRAM cr_set_advanced_logging:dba
 PROMPT
  "Advanced checkpoint logging (1 for true; 0 for false):" = "0"
  WITH cr_server_value_txt_var
 DECLARE flag_type_var = i2
 SET flag_type_var = 23
 SET flag = "0"
 IF (( $CR_SERVER_VALUE_TXT_VAR="1"))
  SET flag = "1"
 ENDIF
 SELECT INTO "NL:"
  sc.type_flag
  FROM cr_server_configuration sc
  WHERE sc.type_flag=flag_type_var
  WITH nocounter
 ;end select
 IF (curqual=0)
  INSERT  FROM cr_server_configuration sc
   SET sc.cr_server_configuration_id = seq(reference_seq,nextval), sc.cr_server_value_txt = flag, sc
    .type_flag = flag_type_var,
    sc.updt_applctx = reqinfo->updt_applctx, sc.updt_cnt = 0, sc.updt_dt_tm = cnvtdatetime(sysdate),
    sc.updt_id = reqinfo->updt_id, sc.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
 ELSE
  UPDATE  FROM cr_server_configuration sc
   SET sc.cr_server_value_txt = flag, sc.updt_cnt = (updt_cnt+ 1), sc.updt_dt_tm = cnvtdatetime(
     sysdate),
    sc.updt_id = reqinfo->updt_id, sc.updt_applctx = reqinfo->updt_applctx, sc.updt_task = reqinfo->
    updt_task
   WHERE sc.type_flag=flag_type_var
   WITH nocounter
  ;end update
 ENDIF
 COMMIT
END GO

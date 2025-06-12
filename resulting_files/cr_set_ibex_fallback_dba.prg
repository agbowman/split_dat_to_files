CREATE PROGRAM cr_set_ibex_fallback:dba
 PROMPT
  "Percent of requests that will be processed with Ibex. Can be integer in range of [0, 100]: " =
  "100"
  WITH cr_server_value_txt_var
 DECLARE flag_type_var = i2 WITH constant(18)
 DECLARE flag = vc WITH noconstant("100")
 DECLARE intvalue = i2
 DECLARE isnumber = i2
 SET intvalue = cnvtint( $CR_SERVER_VALUE_TXT_VAR)
 SET isnumber = isnumeric( $CR_SERVER_VALUE_TXT_VAR,"",3)
 IF (( $CR_SERVER_VALUE_TXT_VAR="0"))
  SET flag = "0"
 ELSEIF (isnumber=1
  AND intvalue > 0
  AND intvalue <= 100)
  SET flag = cnvtstring(intvalue)
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

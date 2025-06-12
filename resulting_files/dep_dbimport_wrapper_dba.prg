CREATE PROGRAM dep_dbimport_wrapper:dba
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
 SET readme_data->message = "Starting dep_dbimport_wrapper, status initialized to FAILURE"
 SET readme_data->status = "F"
 DECLARE env_id = f8
 DECLARE dep_env_id = f8
 FREE SET string_struct_c
 RECORD string_struct_c(
   1 ms_err_msg = vc
 )
 SELECT INTO "nl:"
  FROM dm_info
  WHERE info_domain="DATA MANAGEMENT"
   AND info_name="INHOUSE DOMAIN"
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure on inhouse check:",string_struct_c->ms_err_msg)
  CALL echo(concat("Failure on inhouse check:",string_struct_c->ms_err_msg))
  GO TO enditnow
 ENDIF
 IF (curqual != 0)
  SET readme_data->status = "S"
  SET readme_data->message = "In house domain - autosuccess"
  GO TO enditnow
 ENDIF
 SET env_id = 0.0
 SELECT INTO "nl:"
  r.info_number
  FROM dm_info r
  WHERE info_domain="DATA MANAGEMENT"
   AND info_name="DM_ENV_ID"
  DETAIL
   env_id = r.info_number
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during SELECT from DM_INFO:",string_struct_c->ms_err_msg
   )
  CALL echo(concat("Failure during SELECT from DM_INFO:",string_struct_c->ms_err_msg))
  GO TO enditnow
 ENDIF
 IF (curqual=0)
  SET readme_data->message = "Unable to get environment ID from DM_INFO"
  CALL echo("Unable to get environment ID from DM_INFO")
  GO TO enditnow
 ENDIF
 SET dep_env_id = 0.0
 SELECT INTO "nl:"
  FROM dep_env_id_reltn eir
  WHERE eir.environment_id=env_id
  DETAIL
   dep_env_id = eir.dep_env_id
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during SELECT from dep_env_id_reltn:",string_struct_c->
   ms_err_msg)
  CALL echo(concat("Failure during SELECT from dep_env_id_reltn:",string_struct_c->ms_err_msg))
  GO TO enditnow
 ENDIF
 IF (dep_env_id=0)
  SELECT INTO "nl:"
   y = seq(dm_seq,nextval)
   FROM dual
   DETAIL
    dep_env_id = y
   WITH nocounter
  ;end select
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure getting next sequence from DM_SEQ:",string_struct_c->
    ms_err_msg)
   CALL echo(concat("Failure getting next sequence from DM_SEQ:",string_struct_c->ms_err_msg))
   GO TO enditnow
  ENDIF
  INSERT  FROM dep_env_id_reltn eir
   SET eir.dep_env_id = dep_env_id, eir.environment_id = env_id
   WITH nocounter
  ;end insert
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   CALL echo(concat("Failure during INSERT into dep_env_id_reltn:",string_struct_c->ms_err_msg))
   GO TO enditnow
  ENDIF
  COMMIT
 ENDIF
 EXECUTE dm_dbimport "cer_install:dep_category.csv", "dep_category", 1000
 IF ((readme_data->status != "F"))
  EXECUTE dep_profile_dev_reltn
 ENDIF
 IF ((readme_data->status != "F"))
  EXECUTE dm_dbimport "cer_install:dep_phase.csv", "dep_phase", 1000
 ENDIF
 IF ((readme_data->status != "F"))
  EXECUTE dm_dbimport "cer_install:dep_role.csv", "dep_role", 1000
 ENDIF
 IF ((readme_data->status != "F"))
  EXECUTE dm_dbimport "cer_install:dep_role_param.csv", "dep_role_param", 1000
 ENDIF
 IF ((readme_data->status != "F"))
  EXECUTE dm_dbimport "cer_install:dep_role_param_reltn.csv", "dep_role_param_reltn", 1000
 ENDIF
 IF ((readme_data->status != "F"))
  EXECUTE dm_dbimport "cer_install:dep_role_is_reltn.csv", "dep_role_is_reltn", 1000
 ENDIF
 IF ((readme_data->status != "F"))
  EXECUTE dm_dbimport "cer_install:dep_solution.csv", "dep_solution", 1000
 ENDIF
 IF ((readme_data->status != "F"))
  EXECUTE dm_dbimport "cer_install:dep_end_state.csv", "dep_end_state", 1000
 ENDIF
 IF ((readme_data->status != "F"))
  EXECUTE dm_dbimport "cer_install:dep_obsoletion_is_id_reltn.csv", "dep_obsoletion_is_id_reltn",
  1000
 ENDIF
 IF ((readme_data->status != "F"))
  EXECUTE dm_dbimport "cer_install:dep_platform.csv", "dep_platform", 1000
 ENDIF
 IF ((readme_data->status != "F"))
  EXECUTE dm_dbimport "cer_install:dep_role_platform_reltn.csv", "dep_role_platform_reltn", 1000
 ENDIF
 IF ((readme_data->status != "F"))
  EXECUTE dm_dbimport "cer_install:dep_role_cat_restriction_reltn.csv",
  "dep_role_cat_restriction_reltn", 1000
 ENDIF
 IF ((readme_data->status != "F"))
  EXECUTE dep_virt_end_state_reltn
 ENDIF
 IF ((readme_data->status != "F"))
  EXECUTE dm_dbimport "cer_install:dep_role_group_reltn.csv", "dep_role_group_reltn", 1000
 ENDIF
#enditnow
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  SET readme_data->message = "Completed dep_dbimport_wrapper, all readme completed successfully."
 ENDIF
 CALL echorecord(readme_data)
 FREE SET string_struct_c
 EXECUTE dm_readme_status
END GO

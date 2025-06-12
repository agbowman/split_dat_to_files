CREATE PROGRAM dep_dbmaintenance_wrapper:dba
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
 SET readme_data->message = "Starting dep_dbmaintenance_wrapper, status initialized to FAILURE"
 SET readme_data->status = "F"
 FREE SET string_struct_c
 RECORD string_struct_c(
   1 ms_err_msg = vc
 )
 DECLARE participate_in_no_downtime_id = f8 WITH public, constant(40.0)
 DECLARE chart_local_chart_dir = f8 WITH public, constant(30.0)
 DECLARE chart_mydoc_dir = f8 WITH public, constant(31.0)
 DECLARE system_id = f8 WITH public, constant(9.0)
 DECLARE windows_id = f8 WITH public, constant(38.0)
 DECLARE websphere_cluster = f8 WITH public, constant(106.0)
 DECLARE maindir = f8 WITH public, constant(1.0)
 DECLARE enterprise_appliance_role_id = f8 WITH public, constant(20.0)
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
 IF (curqual=0)
  SET readme_data->message = "Unable to get environment ID from DM_INFO"
  CALL echo("Unable to get environment ID from DM_INFO")
  GO TO exit_program
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
  GO TO exit_program
 ENDIF
 EXECUTE dep_plan_maint
 IF ((readme_data->status != "F"))
  EXECUTE dep_profile_param_reltn_maint
 ENDIF
 IF ((readme_data->status != "F"))
  EXECUTE dep_role_param_reltn_maint
 ENDIF
 IF ((readme_data->status != "F"))
  EXECUTE dep_role_param_maint
 ENDIF
 IF ((readme_data->status != "F"))
  EXECUTE dep_virt_target_maint
 ENDIF
 IF ((readme_data->status != "F"))
  SET readme_data->status = "S"
 ENDIF
#exit_program
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
  SET readme_data->message =
  "Completed dep_dbmaintenance_wrapper, all readme completed successfully."
 ENDIF
 FREE SET string_struct_c
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

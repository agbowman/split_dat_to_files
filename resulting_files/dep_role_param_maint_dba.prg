CREATE PROGRAM dep_role_param_maint:dba
 SET readme_data->status = "F"
 SET readme_data->message = "Beginning readme to update dep_role_param_maint"
 DELETE  FROM dep_role_param drp
  WHERE drp.parameter_id IN (participate_in_no_downtime_id, chart_local_chart_dir, chart_mydoc_dir,
  system_id, windows_id)
   AND drp.dep_env_id=dep_env_id
  WITH nocounter
 ;end delete
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during DELETE from dep_role_param:",string_struct_c->
   ms_err_msg)
  CALL echo(concat("Failure during DELETE from dep_role_param:",string_struct_c->ms_err_msg))
  GO TO exit_program
 ENDIF
 SET readme_data->status = "S"
#exit_program
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
  SET readme_data->message = "Completed dep_role_param_maint successfully."
 ENDIF
END GO

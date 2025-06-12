CREATE PROGRAM dep_plan_maint:dba
 SET readme_data->status = "F"
 SET readme_data->message = "Beginning readme to update dep_plan"
 UPDATE  FROM dep_plan dp
  SET dp.last_commit_dt_tm = sysdate
  WHERE dp.type_cd=4
   AND dp.last_commit_dt_tm=null
   AND dp.dep_env_id=dep_env_id
  WITH nocounter
 ;end update
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_plan UPDATE:",string_struct_c->ms_err_msg)
  CALL echo(concat("Failure during dep_plan UPDATE:",string_struct_c->ms_err_msg))
  GO TO exit_program
 ENDIF
 SET readme_data->status = "S"
#exit_program
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
  SET readme_data->message = "Completed dep_plan_maint sucessfully"
 ENDIF
END GO

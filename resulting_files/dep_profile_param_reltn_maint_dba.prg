CREATE PROGRAM dep_profile_param_reltn_maint:dba
 SET readme_data->status = "F"
 SET readme_data->message = "Beginning readme to update dep_profile_param_reltn"
 FREE RECORD ea_profile_ids
 RECORD ea_profile_ids(
   1 ea_profile[*]
     2 profile_id = f8
     2 delete_ind = i4
 )
 DELETE  FROM dep_profile_param_reltn dppr
  WHERE dppr.profile_id IN (
  (SELECT
   emc.profile_id
   FROM dep_profile emc
   WHERE emc.dep_env_id=dep_env_id))
   AND dppr.parameter_id IN (participate_in_no_downtime_id, chart_local_chart_dir, chart_mydoc_dir,
  system_id, windows_id)
 ;end delete
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure finding profiles for environment SELECT:",
   string_struct_c->ms_err_msg)
  CALL echo(concat("Failure during SELECT from dep_profile_param_reltn:",string_struct_c->ms_err_msg)
   )
  GO TO exit_program
 ENDIF
 SET count1 = 0
 SELECT DISTINCT INTO "NL:"
  dppr.profile_id
  FROM dep_profile_param_reltn dppr,
   dep_role_profile_reltn drpr,
   dep_profile dp
  WHERE dppr.profile_id=drpr.profile_id
   AND dppr.profile_id=dp.profile_id
   AND drpr.role_id=enterprise_appliance_role_id
   AND dppr.parameter_id=maindir
   AND dp.dep_env_id=dep_env_id
  HEAD REPORT
   stat = alterlist(ea_profile_ids->ea_profile,10), count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 > 10)
    stat = alterlist(ea_profile_ids->ea_profile,(count1+ 9))
   ENDIF
   ea_profile_ids->ea_profile[count1].profile_id = dppr.profile_id, ea_profile_ids->ea_profile[count1
   ].delete_ind = 1
  FOOT REPORT
   stat = alterlist(ea_profile_ids->ea_profile,count1)
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure selecting EA profile_ids from dep_profile_param_reltn:",
   string_struct_c->ms_err_msg)
  CALL echo(concat("Failure selecting EA profile_ids from dep_profile_param_reltn:",string_struct_c->
    ms_err_msg))
  GO TO exit_program
 ENDIF
 IF (size(ea_profile_ids->ea_profile,5) > 0)
  SELECT DISTINCT INTO "NL:"
   FROM dep_role_profile_reltn drpr,
    dep_role_param_reltn rpr,
    (dummyt d1  WITH seq = value(size(ea_profile_ids->ea_profile,5)))
   PLAN (d1)
    JOIN (drpr
    WHERE (drpr.profile_id=ea_profile_ids->ea_profile[d1.seq].profile_id)
     AND drpr.role_id != enterprise_appliance_role_id)
    JOIN (rpr
    WHERE drpr.role_id=rpr.role_id
     AND rpr.dep_env_id=dep_env_id
     AND rpr.parameter_id=maindir)
   DETAIL
    ea_profile_ids->ea_profile[d1.seq].delete_ind = 0
   WITH nocounter
  ;end select
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat(
    "Failure selecting non-EA profile_ids from dep_role_profile_reltn:",string_struct_c->ms_err_msg)
   CALL echo(concat("Failure selecting non-EA profile_ids from dep_role_profile_reltn:",
     string_struct_c->ms_err_msg))
   GO TO exit_program
  ENDIF
  DELETE  FROM dep_profile_param_reltn dppr,
    (dummyt d1  WITH seq = value(size(ea_profile_ids->ea_profile,5)))
   SET dppr.seq = 1
   PLAN (d1
    WHERE (ea_profile_ids->ea_profile[d1.seq].delete_ind=1))
    JOIN (dppr
    WHERE (dppr.profile_id=ea_profile_ids->ea_profile[d1.seq].profile_id)
     AND dppr.parameter_id=maindir)
   WITH nocounter
  ;end delete
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure during DELETE from dep_profile_param_reltn:",
    string_struct_c->ms_err_msg)
   CALL echo(concat("Failure during DELETE from dep_profile_param_reltn:",string_struct_c->ms_err_msg
     ))
   GO TO exit_program
  ENDIF
 ENDIF
 SET readme_data->status = "S"
#exit_program
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
  SET readme_data->message = "Completed dep_profile_param_maintenance successfully."
 ENDIF
END GO

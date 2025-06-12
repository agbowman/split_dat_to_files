CREATE PROGRAM dep_role:dba
 SET readme_data->status = "F"
 SET readme_data->message = "Beginning readme to update dep_role"
 SELECT INTO "nl:"
  FROM dep_role emc,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d1)
   JOIN (emc
   WHERE emc.role_id=cnvtreal(requestin->list_0[d1.seq].role_id)
    AND emc.dep_env_id=dep_env_id)
  DETAIL
   requestin->list_0[d1.seq].exists_ind = "1"
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_role SELECT:",string_struct_c->ms_err_msg)
  GO TO enditnow
 ENDIF
 INSERT  FROM dep_role emc,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  SET emc.role_id = cnvtreal(requestin->list_0[d1.seq].role_id), emc.role_name = requestin->list_0[d1
   .seq].role_name, emc.description = requestin->list_0[d1.seq].description,
   emc.dep_env_id = dep_env_id, emc.active_ind = cnvtreal(requestin->list_0[d1.seq].active_ind)
  PLAN (d1
   WHERE (requestin->list_0[d1.seq].exists_ind != "1"))
   JOIN (emc)
  WITH nocounter
 ;end insert
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_role INSERT:",string_struct_c->ms_err_msg)
  GO TO enditnow
 ENDIF
 UPDATE  FROM dep_role emc,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  SET emc.role_id = cnvtreal(requestin->list_0[d1.seq].role_id), emc.role_name = requestin->list_0[d1
   .seq].role_name, emc.description = requestin->list_0[d1.seq].description,
   emc.dep_env_id = dep_env_id, emc.active_ind = cnvtreal(requestin->list_0[d1.seq].active_ind)
  PLAN (d1
   WHERE (requestin->list_0[d1.seq].exists_ind="1"))
   JOIN (emc
   WHERE emc.role_id=cnvtreal(requestin->list_0[d1.seq].role_id)
    AND emc.dep_env_id=dep_env_id)
  WITH nocounter
 ;end update
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_role UPDATE:",string_struct_c->ms_err_msg)
  GO TO enditnow
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "EUC role list inserted successfully"
#enditnow
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO

CREATE PROGRAM dep_solution:dba
 SET readme_data->status = "F"
 SET readme_data->message = "Beginning readme to update dep_solution"
 SELECT INTO "nl:"
  FROM dep_solution emc,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d1)
   JOIN (emc
   WHERE emc.solution_id=cnvtreal(requestin->list_0[d1.seq].solution_id)
    AND emc.dep_env_id=dep_env_id)
  DETAIL
   requestin->list_0[d1.seq].exists_ind = "1"
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_solution SELECT:",string_struct_c->ms_err_msg
   )
  GO TO enditnow
 ENDIF
 INSERT  FROM dep_solution emc,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  SET emc.solution_id = cnvtreal(requestin->list_0[d1.seq].solution_id), emc.solution_number =
   cnvtreal(requestin->list_0[d1.seq].solution_number), emc.description = requestin->list_0[d1.seq].
   description,
   emc.dep_env_id = dep_env_id
  PLAN (d1
   WHERE (requestin->list_0[d1.seq].exists_ind != "1"))
   JOIN (emc)
  WITH nocounter
 ;end insert
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_solution INSERT:",string_struct_c->ms_err_msg
   )
  GO TO enditnow
 ENDIF
 UPDATE  FROM dep_solution emc,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  SET emc.solution_id = cnvtreal(requestin->list_0[d1.seq].solution_id), emc.solution_number =
   cnvtreal(requestin->list_0[d1.seq].solution_number), emc.description = requestin->list_0[d1.seq].
   description,
   emc.dep_env_id = dep_env_id
  PLAN (d1
   WHERE (requestin->list_0[d1.seq].exists_ind="1"))
   JOIN (emc
   WHERE emc.solution_id=cnvtreal(requestin->list_0[d1.seq].solution_id)
    AND emc.dep_env_id=dep_env_id)
  WITH nocounter
 ;end update
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_solution UPDATE:",string_struct_c->ms_err_msg
   )
  GO TO enditnow
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "EUC solution list inserted successfully"
#enditnow
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO

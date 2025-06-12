CREATE PROGRAM dep_phase:dba
 SET readme_data->status = "F"
 SET readme_data->message = "Beginning readme to update dep_phase"
 SELECT INTO "nl:"
  FROM dep_phase emc,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d1)
   JOIN (emc
   WHERE emc.phase_id=cnvtreal(requestin->list_0[d1.seq].phase_id)
    AND emc.dep_env_id=dep_env_id)
  DETAIL
   requestin->list_0[d1.seq].exists_ind = "1"
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_phase SELECT:",string_struct_c->ms_err_msg)
  GO TO enditnow
 ENDIF
 INSERT  FROM dep_phase emc,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  SET emc.phase_id = cnvtreal(requestin->list_0[d1.seq].phase_id), emc.seq_number = cnvtreal(
    requestin->list_0[d1.seq].seq_number), emc.parent_phase_id = cnvtreal(requestin->list_0[d1.seq].
    parent_phase_id),
   emc.phase_name = requestin->list_0[d1.seq].phase_name, emc.description = requestin->list_0[d1.seq]
   .description, emc.dep_env_id = dep_env_id
  PLAN (d1
   WHERE (requestin->list_0[d1.seq].exists_ind != "1"))
   JOIN (emc)
  WITH nocounter
 ;end insert
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_phase INSERT:",string_struct_c->ms_err_msg)
  GO TO enditnow
 ENDIF
 UPDATE  FROM dep_phase emc,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  SET emc.phase_id = cnvtreal(requestin->list_0[d1.seq].phase_id), emc.seq_number = cnvtreal(
    requestin->list_0[d1.seq].seq_number), emc.parent_phase_id = cnvtreal(requestin->list_0[d1.seq].
    parent_phase_id),
   emc.phase_name = requestin->list_0[d1.seq].phase_name, emc.description = requestin->list_0[d1.seq]
   .description, emc.dep_env_id = dep_env_id
  PLAN (d1
   WHERE (requestin->list_0[d1.seq].exists_ind="1"))
   JOIN (emc
   WHERE emc.phase_id=cnvtreal(requestin->list_0[d1.seq].phase_id)
    AND emc.dep_env_id=dep_env_id)
  WITH nocounter
 ;end update
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_phase UPDATE:",string_struct_c->ms_err_msg)
  GO TO enditnow
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "EUC phase list inserted successfully"
#enditnow
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO

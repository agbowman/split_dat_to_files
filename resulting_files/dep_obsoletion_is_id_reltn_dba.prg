CREATE PROGRAM dep_obsoletion_is_id_reltn:dba
 SET readme_data->status = "F"
 SET readme_data->message = "Beginning readme to update dep_obsoletion_is_id_reltn"
 DECLARE ind_target = i2 WITH constant(0)
 DECLARE loop = i4 WITH public, noconstant(1)
 FREE RECORD doisr_parallel
 RECORD doisr_parallel(
   1 list_0[*]
     2 is_id = f8
     2 obsoletion_is_id = f8
 )
 SET stat = alterlist(doisr_parallel->list_0,size(requestin->list_0,5))
 FOR (loop = 1 TO size(requestin->list_0,5))
  SET doisr_parallel->list_0[loop].is_id = cnvtreal(requestin->list_0[loop].is_id)
  SET doisr_parallel->list_0[loop].obsoletion_is_id = cnvtreal(requestin->list_0[loop].
   obsoletion_is_id)
 ENDFOR
 SELECT INTO "nl:"
  FROM dep_obsoletion_is_id_reltn emc,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d1)
   JOIN (emc
   WHERE (emc.is_id=doisr_parallel->list_0[d1.seq].is_id)
    AND emc.dep_env_id=dep_env_id
    AND emc.current_ind=ind_target)
  DETAIL
   requestin->list_0[d1.seq].exists_ind = "1"
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_role_is_reltn SELECT:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 INSERT  FROM dep_obsoletion_is_id_reltn emc,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  SET emc.is_id = doisr_parallel->list_0[d1.seq].is_id, emc.obsoletion_is_id = doisr_parallel->
   list_0[d1.seq].obsoletion_is_id, emc.current_ind = ind_target,
   emc.dep_env_id = dep_env_id
  PLAN (d1
   WHERE (requestin->list_0[d1.seq].exists_ind != "1"))
   JOIN (emc)
  WITH nocounter
 ;end insert
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_role_is_reltn INSERT:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 UPDATE  FROM dep_obsoletion_is_id_reltn emc,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  SET emc.obsoletion_is_id = doisr_parallel->list_0[d1.seq].obsoletion_is_id
  PLAN (d1
   WHERE (requestin->list_0[d1.seq].exists_ind="1"))
   JOIN (emc
   WHERE (emc.is_id=doisr_parallel->list_0[d1.seq].is_id)
    AND emc.current_ind=ind_target
    AND emc.dep_env_id=dep_env_id)
  WITH nocounter
 ;end update
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_obsoletion_is_id_reltn UPDATE:",
   string_struct_c->ms_err_msg)
  GO TO enditnow
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "EUC obsoletion IS relationship list inserted successfully"
#enditnow
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO

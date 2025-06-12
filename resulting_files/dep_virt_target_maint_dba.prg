CREATE PROGRAM dep_virt_target_maint:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Beginning readme to update dep_virt_target"
 FREE RECORD virt_target_ids
 RECORD virt_target_ids(
   1 virt_target[*]
     2 virt_target_id = f8
 )
 FREE RECORD virt_end_states
 RECORD virt_end_states(
   1 virt_end_state[*]
     2 end_state_name = vc
     2 platform_cd = i4
     2 valid_end_state_id = f8
     2 exists_ind = i4
 )
 SET count1 = 0
 SELECT INTO "NL:"
  FROM dep_virt_target dvt,
   dep_virt_target_reltn dvtr
  WHERE dvt.virtual_target_id=dvtr.virtual_target_id
   AND dvt.dep_env_id=dep_env_id
   AND  NOT (dvtr.profile_id IN (
  (SELECT
   profile_id
   FROM dep_profile dp
   WHERE dp.dep_env_id=dep_env_id)))
  HEAD REPORT
   stat = alterlist(virt_target_ids->virt_target,10), count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 > 10)
    stat = alterlist(virt_target_ids->virt_target,(count1+ 9))
   ENDIF
   virt_target_ids->virt_target[count1].virt_target_id = dvt.virtual_target_id
  FOOT REPORT
   stat = alterlist(virt_target_ids->virt_target,count1)
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_virt_target* SELECT:",string_struct_c->
   ms_err_msg)
  CALL echo(concat("Failure during SELECT from dep_virt_target*:",string_struct_c->ms_err_msg))
  GO TO exit_program
 ENDIF
 IF (size(virt_target_ids->virt_target,5) > 0)
  DELETE  FROM dep_virt_target dvt,
    (dummyt d1  WITH seq = value(size(virt_target_ids->virt_target,5)))
   SET dvt.seq = 1
   PLAN (d1)
    JOIN (dvt
    WHERE dvt.virtual_target_id=cnvtreal(virt_target_ids->virt_target[d1.seq].virt_target_id))
   WITH nocounter
  ;end delete
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure during DELETE from dep_virt_target:",string_struct_c->
    ms_err_msg)
   CALL echo(concat("Failure during DELETE from dep_virt_target:",string_struct_c->ms_err_msg))
   GO TO exit_program
  ENDIF
  DELETE  FROM dep_virt_target_reltn dvtr,
    (dummyt d1  WITH seq = value(size(virt_target_ids->virt_target,5)))
   SET dvtr.seq = 1
   PLAN (d1)
    JOIN (dvtr
    WHERE dvtr.virtual_target_id=cnvtreal(virt_target_ids->virt_target[d1.seq].virt_target_id))
   WITH nocounter
  ;end delete
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure during DELETE from dep_virt_target_reltn:",
    string_struct_c->ms_err_msg)
   CALL echo(concat("Failure during DELETE from dep_virt_target_reltn:",string_struct_c->ms_err_msg))
   GO TO exit_program
  ENDIF
  DELETE  FROM dep_virt_end_state_reltn dvesr,
    (dummyt d1  WITH seq = value(size(virt_target_ids->virt_target,5)))
   SET dvesr.seq = 1
   PLAN (d1)
    JOIN (dvesr
    WHERE dvesr.virtual_target_id=cnvtreal(virt_target_ids->virt_target[d1.seq].virt_target_id))
   WITH nocounter
  ;end delete
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure during DELETE from dep_virt_end_state_reltn:",
    string_struct_c->ms_err_msg)
   CALL echo(concat("Failure during DELETE from dep_virt_end_state_reltn:",string_struct_c->
     ms_err_msg))
   GO TO exit_program
  ENDIF
 ENDIF
 DELETE  FROM dep_virt_end_state_reltn dvesr
  WHERE  NOT (dvesr.virtual_target_id IN (
  (SELECT
   dvt.virtual_target_id
   FROM dep_virt_target dvt)))
  WITH nocounter
 ;end delete
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat(
   "Failure deleting orphaned virtual_target_ids from dep_virt_end_state_reltn:",string_struct_c->
   ms_err_msg)
  CALL echo(concat("Failure deleting orphaned virtual_target_ids from dep_virt_end_state_reltn:",
    string_struct_c->ms_err_msg))
  GO TO exit_program
 ENDIF
 SET count2 = 0
 SELECT DISTINCT INTO "NL:"
  dves.end_state_name, dves.platform_cd
  FROM dep_virt_end_state dves
  WHERE dves.dep_env_id=dep_env_id
   AND dves.current_ind=1
  HEAD REPORT
   stat = alterlist(virt_end_states->virt_end_state,10), count2 = 0
  DETAIL
   count2 = (count2+ 1)
   IF (mod(count2,10)=1
    AND count2 > 10)
    stat = alterlist(virt_end_states->virt_end_state,(count2+ 9))
   ENDIF
   virt_end_states->virt_end_state[count2].end_state_name = dves.end_state_name, virt_end_states->
   virt_end_state[count2].platform_cd = dves.platform_cd, virt_end_states->virt_end_state[count2].
   valid_end_state_id = 0,
   virt_end_states->virt_end_state[count2].exists_ind = 0
  FOOT REPORT
   stat = alterlist(virt_end_states->virt_end_state,count2)
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure selecting current endstates from dep_virt_end_state:",
   string_struct_c->ms_err_msg)
  CALL echo(concat("Failure selecting current endstates from dep_virt_end_state:",string_struct_c->
    ms_err_msg))
  GO TO exit_program
 ENDIF
 IF (size(virt_end_states->virt_end_state,5) > 0)
  SELECT INTO "NL:"
   FROM dep_end_state des,
    (dummyt d1  WITH seq = value(size(virt_end_states->virt_end_state,5)))
   PLAN (d1)
    JOIN (des
    WHERE des.dep_env_id=dep_env_id
     AND des.current_ind=1
     AND (des.platform_cd=virt_end_states->virt_end_state[d1.seq].platform_cd)
     AND (des.end_state_name=virt_end_states->virt_end_state[d1.seq].end_state_name))
   DETAIL
    virt_end_states->virt_end_state[d1.seq].valid_end_state_id = des.end_state_id
   WITH nocounter
  ;end select
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure selecting current end_state_id from dep_end_state:",
    string_struct_c->ms_err_msg)
   CALL echo(concat("Failure selecting current end_state_id from dep_end_state:",string_struct_c->
     ms_err_msg))
   GO TO exit_program
  ENDIF
  SELECT INTO "NL:"
   FROM dep_virt_end_state dves,
    (dummyt d1  WITH seq = value(size(virt_end_states->virt_end_state,5)))
   PLAN (d1)
    JOIN (dves
    WHERE dves.dep_env_id=dep_env_id
     AND (dves.end_state_id=virt_end_states->virt_end_state[d1.seq].valid_end_state_id))
   DETAIL
    virt_end_states->virt_end_state[d1.seq].exists_ind = 1
   WITH nocounter
  ;end select
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat(
    "Failure determining if the end_state_id exists in dep_virt_end_state:",string_struct_c->
    ms_err_msg)
   CALL echo(concat("Failure determining if the end_state_id exists in dep_virt_end_state:",
     string_struct_c->ms_err_msg))
   GO TO exit_program
  ENDIF
  INSERT  FROM dep_virt_end_state dves,
    (dummyt d1  WITH seq = value(size(virt_end_states->virt_end_state,5)))
   SET dves.end_state_id = virt_end_states->virt_end_state[d1.seq].valid_end_state_id, dves
    .end_state_name = virt_end_states->virt_end_state[d1.seq].end_state_name, dves.new_ind = 0,
    dves.platform_cd = virt_end_states->virt_end_state[d1.seq].platform_cd, dves.current_ind = 1,
    dves.dep_env_id = dep_env_id
   PLAN (d1
    WHERE (virt_end_states->virt_end_state[d1.seq].exists_ind != 1)
     AND (virt_end_states->virt_end_state[d1.seq].valid_end_state_id != 0))
    JOIN (dves)
   WITH nocounter
  ;end insert
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure inserting current endstates into dep_virt_end_state:",
    string_struct_c->ms_err_msg)
   CALL echo(concat("Failure inserting current endstates into dep_virt_end_state:",string_struct_c->
     ms_err_msg))
   GO TO exit_program
  ENDIF
  UPDATE  FROM dep_virt_end_state_reltn dvesr,
    (dummyt d1  WITH seq = value(size(virt_end_states->virt_end_state,5)))
   SET dvesr.end_state_id = virt_end_states->virt_end_state[d1.seq].valid_end_state_id
   PLAN (d1
    WHERE (virt_end_states->virt_end_state[d1.seq].valid_end_state_id != 0))
    JOIN (dvesr
    WHERE dvesr.end_state_id IN (
    (SELECT
     dves.end_state_id
     FROM dep_virt_end_state dves
     WHERE (dves.end_state_name=virt_end_states->virt_end_state[d1.seq].end_state_name)
      AND dves.current_ind=1
      AND dves.dep_env_id=dep_env_id
      AND (dves.platform_cd=virt_end_states->virt_end_state[d1.seq].platform_cd)
      AND (dves.end_state_id != virt_end_states->virt_end_state[d1.seq].valid_end_state_id))))
   WITH nocounter
  ;end update
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure updating end_state_id in dep_virt_end_state_reltn:",
    string_struct_c->ms_err_msg)
   CALL echo(concat("Failure updating end_state_id in dep_virt_end_state_reltn:",string_struct_c->
     ms_err_msg))
   GO TO exit_program
  ENDIF
  DELETE  FROM dep_virt_end_state dves,
    (dummyt d1  WITH seq = value(size(virt_end_states->virt_end_state,5)))
   SET dves.seq = 1
   PLAN (d1
    WHERE (virt_end_states->virt_end_state[d1.seq].valid_end_state_id != 0))
    JOIN (dves
    WHERE (dves.end_state_name=virt_end_states->virt_end_state[d1.seq].end_state_name)
     AND dves.current_ind=1
     AND dves.dep_env_id=dep_env_id
     AND (dves.platform_cd=virt_end_states->virt_end_state[d1.seq].platform_cd)
     AND (dves.end_state_id != virt_end_states->virt_end_state[d1.seq].valid_end_state_id))
   WITH nocounter
  ;end delete
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure deleting orphaned endstates from dep_virt_end_state:",
    string_struct_c->ms_err_msg)
   CALL echo(concat("Failure deleting orphaned endstates from dep_virt_end_state:",string_struct_c->
     ms_err_msg))
   GO TO exit_program
  ENDIF
 ENDIF
 DELETE  FROM dep_virt_end_state_reltn
  WHERE end_state_id IN (
  (SELECT
   dvesr.end_state_id
   FROM dep_virt_end_state_reltn dvesr,
    dep_virt_end_state dves,
    dep_virt_target dvt,
    dep_virt_target_reltn dvtr,
    dep_profile dp
   WHERE dves.end_state_id=dvesr.end_state_id
    AND dvesr.virtual_target_id=dvt.virtual_target_id
    AND dves.dep_env_id=dvt.dep_env_id
    AND dvtr.virtual_target_id=dvt.virtual_target_id
    AND dp.profile_id=dvtr.profile_id
    AND dp.dep_env_id=dves.dep_env_id
    AND dves.platform_cd != dp.platform_type_cd
    AND dves.dep_env_id=dep_env_id))
  WITH nocounter
 ;end delete
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure deleting endstates from dep_virt_end_state_reltn:",
   string_struct_c->ms_err_msg)
  CALL echo(concat("Failure deleting endstates from dep_virt_end_state_reltn:",string_struct_c->
    ms_err_msg))
  GO TO exit_program
 ENDIF
 SET readme_data->status = "S"
#exit_program
 FREE RECORD virt_target_ids
 FREE RECORD virt_end_states
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
  SET readme_data->message = "Completed dep_virt_target_maint successfully."
 ENDIF
END GO

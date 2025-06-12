CREATE PROGRAM dep_virt_end_state_reltn:dba
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
 SET readme_data->message = "Beginning readme to update dep_virt_end_state_reltn"
 DECLARE device_status_abandoned_cd = i4
 DECLARE count1 = i4
 DECLARE count2 = i4
 DECLARE target_length = i4
 SET device_status_abandoned_cd = 7
 FREE RECORD target_vt_es_reltns
 RECORD target_vt_es_reltns(
   1 target_vt_es_reltn[*]
     2 virtual_target_id = f8
     2 end_state_id = f8
     2 associated_dt_tm = dq8
 )
 SELECT DISTINCT INTO "nl:"
  dvesr.end_state_id, dvesr.virtual_target_id
  FROM dep_virt_end_state_reltn dvesr,
   dep_virt_target_reltn dvtr,
   dep_profile_dev_reltn dpdr,
   dep_profile dp
  WHERE dvesr.associated_dt_tm=null
   AND dvesr.virtual_target_id=dvtr.virtual_target_id
   AND dpdr.profile_id=dvtr.profile_id
   AND dpdr.profile_id=dp.profile_id
   AND dp.dep_env_id=dep_env_id
   AND dpdr.device_status_cd=device_status_abandoned_cd
  HEAD REPORT
   stat = alterlist(target_vt_es_reltns->target_vt_es_reltn,100), count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,100)=1
    AND count1 > 100)
    stat = alterlist(target_vt_es_reltns->target_vt_es_reltn,(count1+ 99))
   ENDIF
   target_vt_es_reltns->target_vt_es_reltn[count1].end_state_id = dvesr.end_state_id,
   target_vt_es_reltns->target_vt_es_reltn[count1].virtual_target_id = dvesr.virtual_target_id
  FOOT REPORT
   stat = alterlist(target_vt_es_reltns->target_vt_es_reltn,count1)
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat(
   "Failure selecting abandoned virt. target/endstates/prof. status information:",string_struct_c->
   ms_err_msg)
  CALL echo(concat("Failure selecting abandoned virt. target/endstates/prof. status information:",
    string_struct_c->ms_err_msg))
  GO TO exit_program
 ENDIF
 SET target_length = size(target_vt_es_reltns->target_vt_es_reltn,5)
 FOR (target_index = 1 TO target_length)
  UPDATE  FROM dep_virt_end_state_reltn dvesr
   SET dvesr.associated_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE dvesr.associated_dt_tm=null
    AND (dvesr.end_state_id=target_vt_es_reltns->target_vt_es_reltn[target_index].end_state_id)
    AND (dvesr.virtual_target_id=target_vt_es_reltns->target_vt_es_reltn[target_index].
   virtual_target_id)
   WITH nocounter
  ;end update
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure updating abandoned profile associated_dt_tm:",
    string_struct_c->ms_err_msg)
   CALL echo(concat("Failure updating abandoned profile associated_dt_tm:",string_struct_c->
     ms_err_msg))
   GO TO exit_program
  ENDIF
 ENDFOR
 SET stat = alterlist(target_vt_es_reltns->target_vt_es_reltn,0)
 SELECT DISTINCT INTO "nl:"
  dvesr.end_state_id, dvesr.virtual_target_id, dpdr.last_commit_dt_tm
  FROM dep_virt_end_state_reltn dvesr,
   dep_virt_target_reltn dvtr,
   dep_profile_dev_reltn dpdr,
   dep_profile dp
  WHERE dvesr.associated_dt_tm=null
   AND dvesr.virtual_target_id=dvtr.virtual_target_id
   AND dpdr.profile_id=dvtr.profile_id
   AND dpdr.profile_id=dp.profile_id
   AND dp.dep_env_id=dep_env_id
  HEAD REPORT
   stat = alterlist(target_vt_es_reltns->target_vt_es_reltn,100), count2 = 0
  DETAIL
   count2 = (count2+ 1)
   IF (mod(count2,100)=1
    AND count2 > 100)
    stat = alterlist(target_vt_es_reltns->target_vt_es_reltn,(count2+ 99))
   ENDIF
   target_vt_es_reltns->target_vt_es_reltn[count2].end_state_id = dvesr.end_state_id,
   target_vt_es_reltns->target_vt_es_reltn[count2].virtual_target_id = dvesr.virtual_target_id
   IF (dpdr.last_commit_dt_tm=null)
    target_vt_es_reltns->target_vt_es_reltn[count2].associated_dt_tm = cnvtdatetime(curdate,curtime3)
   ELSE
    target_vt_es_reltns->target_vt_es_reltn[count2].associated_dt_tm = dpdr.last_commit_dt_tm
   ENDIF
  FOOT REPORT
   stat = alterlist(target_vt_es_reltns->target_vt_es_reltn,count2)
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat(
   "Failure selecting synch./assigned virt. target/endstates/profile status info:",string_struct_c->
   ms_err_msg)
  CALL echo(concat("Failure selecting synch./assigned virt. target/endstates/profile status info:",
    string_struct_c->ms_err_msg))
  GO TO exit_program
 ENDIF
 SET target_length = size(target_vt_es_reltns->target_vt_es_reltn,5)
 FOR (target_index = 1 TO target_length)
  UPDATE  FROM dep_virt_end_state_reltn dvesr
   SET dvesr.associated_dt_tm = cnvtdatetime(target_vt_es_reltns->target_vt_es_reltn[target_index].
     associated_dt_tm)
   WHERE dvesr.associated_dt_tm=null
    AND (dvesr.end_state_id=target_vt_es_reltns->target_vt_es_reltn[target_index].end_state_id)
    AND (dvesr.virtual_target_id=target_vt_es_reltns->target_vt_es_reltn[target_index].
   virtual_target_id)
   WITH nocounter
  ;end update
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure updating synch./assigned profile associated_dt_tm:",
    string_struct_c->ms_err_msg)
   CALL echo(concat("Failure updating synch./assigned profile associated_dt_tm:",string_struct_c->
     ms_err_msg))
   GO TO exit_program
  ENDIF
 ENDFOR
 SET readme_data->status = "S"
#exit_program
 FREE RECORD target_vt_es_reltns
 IF ((readme_data->status="S"))
  COMMIT
  SET readme_data->message = "Completed dep_virt_end_state_reltn successfully."
 ELSE
  ROLLBACK
 ENDIF
END GO

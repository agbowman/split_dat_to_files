CREATE PROGRAM dm_rdm_nvp_dp_updt:dba
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
 SET readme_data->message = "Readme Failed: Starting dm_rdm_nvp_dp_updt script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DELETE  FROM name_value_prefs nvp
  WHERE nvp.pvc_name IN ("C_POS_CHAR_IND", "R_POS_CHAR_IND")
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed:Deleting from name_value_prefs:",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM name_value_prefs nvp
  (nvp.name_value_prefs_id, nvp.parent_entity_name, nvp.parent_entity_id,
  nvp.pvc_name, nvp.pvc_value, nvp.active_ind,
  nvp.updt_cnt, nvp.updt_id, nvp.updt_dt_tm,
  nvp.updt_task, nvp.updt_applctx, nvp.merge_name,
  nvp.merge_id, nvp.sequence)(SELECT
   carenet_seq.nextval, nvp2.parent_entity_name, nvp2.parent_entity_id,
   "C_POS_CHAR_IND", nvp2.pvc_value, nvp2.active_ind,
   0, reqinfo->updt_id, sysdate,
   reqinfo->updt_task, reqinfo->updt_applctx, nvp2.merge_name,
   nvp2.merge_id, nvp2.sequence
   FROM name_value_prefs nvp2
   WHERE nvp2.pvc_name="C_CRIT_CHAR_IND")
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed:Inserting C_POS_CHAR_IND rows into NAME_VALUE_PREFS:",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM name_value_prefs nvp
  (nvp.name_value_prefs_id, nvp.parent_entity_name, nvp.parent_entity_id,
  nvp.pvc_name, nvp.pvc_value, nvp.active_ind,
  nvp.updt_cnt, nvp.updt_id, nvp.updt_dt_tm,
  nvp.updt_task, nvp.updt_applctx, nvp.merge_name,
  nvp.merge_id, nvp.sequence)(SELECT
   carenet_seq.nextval, nvp2.parent_entity_name, nvp2.parent_entity_id,
   "R_POS_CHAR_IND", nvp2.pvc_value, nvp2.active_ind,
   0, reqinfo->updt_id, sysdate,
   reqinfo->updt_task, reqinfo->updt_applctx, nvp2.merge_name,
   nvp2.merge_id, nvp2.sequence
   FROM name_value_prefs nvp2
   WHERE nvp2.pvc_name="R_CRIT_CHAR_IND")
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed:Inserting R_POS_CHAR_IND rows into NAME_VALUE_PREFS:",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: dm_rdm_nvp_dp_updt script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

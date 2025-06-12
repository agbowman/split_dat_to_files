CREATE PROGRAM dcp_rdm_update_marsum_fwd_pref:dba
 FREE RECORD temp_prefs
 RECORD temp_prefs(
   1 prefs[*]
     2 name_value_prefs_id = f8
     2 pvc_value = vc
     2 merge_name = vc
     2 merge_id = f8
     2 sequence = i2
     2 parent_entity_id = f8
 )
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
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c13 WITH protect, noconstant("")
 DECLARE pref_cnt = i4 WITH protect, noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE pref_idx = i4 WITH protect, noconstant(0)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failure. dcp_rdm_update_marsum_fwd_pref.prg script"
 CALL echo("Select all active MAR_SUMMARY_DEFAULT_HRS_FORWARD preferences saved in the database")
 SELECT INTO "nl:"
  FROM name_value_prefs n
  WHERE n.pvc_name="MAR_SUMMARY_DEFAULT_HRS_FORWARD"
   AND n.active_ind=1
  ORDER BY n.updt_dt_tm DESC
  HEAD n.parent_entity_id
   pref_cnt = (pref_cnt+ 1), stat = alterlist(temp_prefs->prefs,pref_cnt), temp_prefs->prefs[pref_cnt
   ].name_value_prefs_id = 0,
   temp_prefs->prefs[pref_cnt].pvc_value = n.pvc_value, temp_prefs->prefs[pref_cnt].merge_name = n
   .merge_name, temp_prefs->prefs[pref_cnt].merge_id = n.merge_id,
   temp_prefs->prefs[pref_cnt].sequence = n.sequence, temp_prefs->prefs[pref_cnt].parent_entity_id =
   n.parent_entity_id
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Select all active MAR_SUMMARY_DEFAULT_HRS_FORWARD failed:",
   errmsg)
  GO TO exit_script
 ENDIF
 CALL echorecord(temp_prefs)
 CALL echo("Determine if there is a matching MAR_SUMMARY_DEFAULT_HRS_FWD row already")
 SELECT INTO "nl:"
  FROM name_value_prefs n
  WHERE n.pvc_name="MAR_SUMMARY_DEFAULT_HRS_FWD"
   AND expand(lidx,1,pref_cnt,n.parent_entity_id,temp_prefs->prefs[lidx].parent_entity_id)
  DETAIL
   pref_idx = locateval(lidx,1,pref_cnt,n.parent_entity_id,temp_prefs->prefs[lidx].parent_entity_id)
   IF (pref_idx > 0)
    temp_prefs->prefs[pref_idx].name_value_prefs_id = n.name_value_prefs_id
   ENDIF
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Select all matching MAR_SUMMARY_DEFAULT_HRS_FWD failed:",errmsg)
  GO TO exit_script
 ENDIF
 CALL echorecord(temp_prefs)
 CALL echo("Update/Insert MAR_SUMMARY_DEFAULT_HRS_FWD rows from MAR_SUMMARY_DEFAULT_HRS_FORWARD rows"
  )
 FOR (pref_idx = 1 TO pref_cnt)
   IF ((temp_prefs->prefs[pref_idx].name_value_prefs_id > 0))
    UPDATE  FROM name_value_prefs nvp
     SET nvp.pvc_value = temp_prefs->prefs[pref_idx].pvc_value, nvp.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), nvp.updt_id = reqinfo->updt_id,
      nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = (
      nvp.updt_cnt+ 1)
     WHERE (nvp.name_value_prefs_id=temp_prefs->prefs[pref_idx].name_value_prefs_id)
     WITH nocounter
    ;end update
    SET errcode = error(errmsg,0)
    IF (errcode > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Update MAR_SUMMARY_DEFAULT_HRS_FWD row failed:",errmsg)
     GO TO exit_script
    ENDIF
   ELSE
    SELECT INTO "nl:"
     j = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      temp_prefs->prefs[pref_idx].name_value_prefs_id = cnvtreal(j)
     WITH format, nocounter
    ;end select
    INSERT  FROM name_value_prefs nvp
     SET nvp.name_value_prefs_id = temp_prefs->prefs[pref_idx].name_value_prefs_id, nvp
      .parent_entity_name = "DETAIL_PREFS", nvp.parent_entity_id = temp_prefs->prefs[pref_idx].
      parent_entity_id,
      nvp.pvc_name = "MAR_SUMMARY_DEFAULT_HRS_FWD", nvp.pvc_value = temp_prefs->prefs[pref_idx].
      pvc_value, nvp.active_ind = 1,
      nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
       = reqinfo->updt_task,
      nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0, nvp.merge_id = temp_prefs->prefs[
      pref_idx].merge_id,
      nvp.merge_name = temp_prefs->prefs[pref_idx].merge_name, nvp.sequence = temp_prefs->prefs[
      pref_idx].sequence
     WITH nocounter
    ;end insert
    SET errcode = error(errmsg,0)
    IF (errcode > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Insert MAR_SUMMARY_DEFAULT_HRS_FWD row failed:",errmsg)
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 CALL echo("Delete all MAR_SUMMARY_DEFAULT_HRS_FORWARD preferences")
 DELETE  FROM name_value_prefs n
  WHERE n.pvc_name="MAR_SUMMARY_DEFAULT_HRS_FORWARD"
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Delete all MAR_SUMMARY_DEFAULT_HRS_FORWARD rows failed:",errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success - All required rows were updated successfully."
 COMMIT
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 SET last_mod = "8/02/06 000"
END GO

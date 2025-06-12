CREATE PROGRAM cmn_rdm_updt_myexp_prsnl_prefs:dba
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
 DECLARE old_report_name = vc WITH protect, constant("mp_driver_my_exp")
 DECLARE new_report_name = vc WITH protect, constant("mp_driver_my_exp_2")
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE PUBLIC::main(null) = null WITH private
 DECLARE PUBLIC::delete_invalid_prsnl_prefs(null) = null WITH protect
 DECLARE PUBLIC::delete_prsnl_preferences(null) = null WITH protect
 DECLARE PUBLIC::update_valid_prsnl_prefs(null) = null WITH protect
 DECLARE PUBLIC::format_report_param(report_param=vc) = vc WITH protect
 DECLARE PUBLIC::update_report_names(null) = null WITH protect
 DECLARE PUBLIC::update_report_params(null) = null WITH protect
 DECLARE PUBLIC::insert_child_name_value_prefs(null) = null WITH protect
 CALL main(null)
 SUBROUTINE PUBLIC::main(null)
   SET readme_data->status = "F"
   SET readme_data->message = "Readme failure: Starting Script cmn_rdm_updt_myexp_prsnl_prefs."
   CALL echo("Starting cmn_rdm_updt_myexp_prsnl_prefs")
   CALL delete_invalid_prsnl_prefs(null)
   CALL update_valid_prsnl_prefs(null)
   SET readme_data->status = "S"
   SET readme_data->message = "Success: Readme performed all required tasks"
   COMMIT
 END ;Subroutine
 SUBROUTINE PUBLIC::delete_invalid_prsnl_prefs(null)
   DECLARE prefs_cnt = i4 WITH protect, noconstant(0)
   FREE RECORD prsnl_prefs_list
   RECORD prsnl_prefs_list(
     1 qual[*]
       2 detail_prefs_id = f8
   ) WITH protect
   SELECT INTO "nl:"
    FROM name_value_prefs nvp,
     detail_prefs dp,
     prsnl pr
    PLAN (nvp
     WHERE nvp.pvc_name="REPORT_NAME"
      AND nvp.pvc_value=old_report_name
      AND nvp.parent_entity_name="DETAIL_PREFS")
     JOIN (dp
     WHERE dp.detail_prefs_id=nvp.parent_entity_id
      AND dp.view_name="DISCERNRPT"
      AND dp.prsnl_id > 0.0
      AND dp.position_cd=0.0)
     JOIN (pr
     WHERE pr.person_id=dp.prsnl_id
      AND  NOT ( EXISTS (
     (SELECT
      vp.view_prefs_id
      FROM view_prefs vp
      WHERE vp.application_number=dp.application_number
       AND vp.frame_type="CHART"
       AND vp.view_name="DISCERNRPT"
       AND vp.view_seq=dp.view_seq
       AND vp.prsnl_id=0.0
       AND vp.position_cd=pr.position_cd))))
    DETAIL
     prefs_cnt = (prefs_cnt+ 1), stat = alterlist(prsnl_prefs_list->qual,prefs_cnt), prsnl_prefs_list
     ->qual[prefs_cnt].detail_prefs_id = dp.detail_prefs_id
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error retrieving invalid PRSNL preferences: ",errmsg)
    CALL echo("Failed to retrieve invalid PRSNL preferences")
    GO TO exit_script
   ENDIF
   IF (size(prsnl_prefs_list->qual,5) > 0)
    CALL delete_prsnl_preferences(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::delete_prsnl_preferences(null)
   DECLARE nvp_idx = i4 WITH protect, noconstant(0)
   DECLARE dp_idx = i4 WITH protect, noconstant(0)
   IF (size(prsnl_prefs_list->qual,5) > 0)
    DELETE  FROM name_value_prefs nvp
     WHERE expand(nvp_idx,1,size(prsnl_prefs_list->qual,5),nvp.parent_entity_id,prsnl_prefs_list->
      qual[nvp_idx].detail_prefs_id)
      AND nvp.parent_entity_name="DETAIL_PREFS"
     WITH nocounter
    ;end delete
    IF (error(errmsg,0) > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Error deleting name value prefs for PRSNL: ",errmsg)
     CALL echo("Error deleting name value prefs for PRSNL")
     GO TO exit_script
    ENDIF
    DELETE  FROM detail_prefs dp
     WHERE expand(dp_idx,1,size(prsnl_prefs_list->qual,5),dp.detail_prefs_id,prsnl_prefs_list->qual[
      dp_idx].detail_prefs_id)
      AND  NOT ( EXISTS (
     (SELECT
      nvp.name_value_prefs_id
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=dp.detail_prefs_id)))
     WITH nocounter
    ;end delete
    IF (error(errmsg,0) > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Error deleting detail prefs for PRSNL: ",errmsg)
     CALL echo("Error deleting detail prefs for PRSNL")
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::update_valid_prsnl_prefs(null)
   DECLARE report_names_cnt = i4 WITH protect, noconstant(0)
   DECLARE report_params_cnt = i4 WITH protect, noconstant(0)
   DECLARE updt_prefs = i2 WITH protect, noconstant(false)
   RECORD report_names(
     1 qual[*]
       2 name_value_prefs_id = f8
   ) WITH protect
   RECORD report_params(
     1 qual[*]
       2 name_value_prefs_id = f8
       2 view_prefs_id = f8
       2 report_param = vc
   ) WITH protect
   SELECT INTO "nl:"
    FROM view_prefs vp,
     detail_prefs dp,
     name_value_prefs nvp
    PLAN (vp
     WHERE vp.frame_type="CHART"
      AND vp.view_name="DISCERNRPT"
      AND vp.position_cd > 0.0
      AND vp.prsnl_id=0.0)
     JOIN (dp
     WHERE dp.view_seq=vp.view_seq
      AND dp.application_number=vp.application_number
      AND dp.view_name="DISCERNRPT"
      AND dp.position_cd=0.0
      AND dp.prsnl_id > 0.0)
     JOIN (nvp
     WHERE nvp.parent_entity_id=dp.detail_prefs_id
      AND nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.pvc_name IN ("REPORT_PARAM", "REPORT_NAME"))
    ORDER BY dp.detail_prefs_id, nvp.pvc_name, nvp.name_value_prefs_id
    HEAD dp.detail_prefs_id
     IF (nvp.pvc_name="REPORT_NAME"
      AND nvp.pvc_value=old_report_name)
      report_names_cnt = (report_names_cnt+ 1), stat = alterlist(report_names->qual,report_names_cnt),
      report_names->qual[report_names_cnt].name_value_prefs_id = nvp.name_value_prefs_id,
      updt_prefs = true
     ENDIF
    HEAD nvp.name_value_prefs_id
     IF (updt_prefs)
      IF (nvp.pvc_name="REPORT_PARAM"
       AND findstring("DISCERNRPT",nvp.pvc_value,1,0) > 0)
       report_params_cnt = (report_params_cnt+ 1), stat = alterlist(report_params->qual,
        report_params_cnt), report_params->qual[report_params_cnt].name_value_prefs_id = nvp
       .name_value_prefs_id,
       report_params->qual[report_params_cnt].view_prefs_id = vp.view_prefs_id, report_params->qual[
       report_params_cnt].report_param = format_report_param(nvp.pvc_value)
      ENDIF
     ENDIF
    FOOT  dp.detail_prefs_id
     updt_prefs = false
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error retrieving PRSNL preferences: ",errmsg)
    CALL echo("Failed to retrieve PRSNL preferences")
    GO TO exit_script
   ENDIF
   CALL update_report_names(null)
   CALL update_report_params(null)
   CALL insert_child_name_value_prefs(null)
 END ;Subroutine
 SUBROUTINE PUBLIC::format_report_param(old_report_param)
   DECLARE updated_report_param = vc WITH protect, noconstant("")
   DECLARE mpmpagemeaning = vc WITH protect, noconstant(trim(replace(piece(old_report_param,",",3,""),
      '"',"",0),3))
   SET updated_report_param = build2('"',"MINE",'"',",",'"',
    mpmpagemeaning,'"',",",
    "$PAT_PERSONID$, $PAT_PPRCODE$, $VIS_ENCNTRID$, $USR_PERSONID$, $USR_POSITIONCD$",",",
    '"',"$DEV_LOCATION$",'"',",",'"',
    "$DEF_LOCATION$",'"',",",'"',"$APP_APPNAME$",
    '"')
   RETURN(updated_report_param)
 END ;Subroutine
 SUBROUTINE PUBLIC::update_report_names(null)
  UPDATE  FROM name_value_prefs nvp,
    (dummyt d  WITH seq = value(size(report_names->qual,5)))
   SET nvp.pvc_value = new_report_name, nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = (nvp
    .updt_cnt+ 1),
    nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
    reqinfo->updt_task
   PLAN (d)
    JOIN (nvp
    WHERE (nvp.name_value_prefs_id=report_names->qual[d.seq].name_value_prefs_id)
     AND nvp.pvc_name="REPORT_NAME")
   WITH nocounter
  ;end update
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Error updating entries for report names in NAME_VALUE_PREFS: ",
    errmsg)
   CALL echo("Failed to update existing NAME_VALUE_PREFS rows for report names.")
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::update_report_params(null)
  UPDATE  FROM name_value_prefs nvp,
    (dummyt d  WITH seq = value(size(report_params->qual,5)))
   SET nvp.pvc_value = report_params->qual[d.seq].report_param, nvp.updt_applctx = reqinfo->
    updt_applctx, nvp.updt_cnt = (nvp.updt_cnt+ 1),
    nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
    reqinfo->updt_task
   PLAN (d)
    JOIN (nvp
    WHERE (nvp.name_value_prefs_id=report_params->qual[d.seq].name_value_prefs_id)
     AND nvp.pvc_name="REPORT_PARAM")
   WITH nocounter
  ;end update
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Error updating entries for report params in NAME_VALUE_PREFS: ",
    errmsg)
   CALL echo("Failed to update existing NAME_VALUE_PREFS rows for report params.")
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::insert_child_name_value_prefs(null)
  INSERT  FROM name_value_prefs nvp,
    (dummyt d  WITH seq = value(size(report_params->qual,5)))
   SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_id = report_params->
    qual[d.seq].name_value_prefs_id, nvp.parent_entity_name = "NAME_VALUE_PREFS",
    nvp.merge_id = report_params->qual[d.seq].view_prefs_id, nvp.merge_name = "VIEW_PREFS", nvp
    .active_ind = true
   PLAN (d)
    JOIN (nvp)
   WITH nocounter
  ;end insert
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat(
    "Error inserting child name value pref entries for report params: ",errmsg)
   CALL echo("Failed to insert child name value pref entries for report params.")
   GO TO exit_script
  ENDIF
 END ;Subroutine
#exit_script
 FREE RECORD prsnl_prefs_list
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

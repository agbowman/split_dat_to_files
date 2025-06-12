CREATE PROGRAM bed_get_ens_tasks_note:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status_list[*]
       3 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD vprequest(
   1 vplist[*]
     2 action_flag = c1
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 frame_type = c12
     2 view_name = c12
     2 view_seq = i4
 )
 FREE SET vpreply
 RECORD vpreply(
   1 vplist[*]
     2 view_prefs_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD vcprequest(
   1 vcplist[*]
     2 action_flag = c1
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 view_name = c12
     2 view_seq = i4
     2 comp_name = c12
     2 comp_seq = i4
 )
 FREE SET vcpreply
 RECORD vcpreply(
   1 vcplist[*]
     2 view_comp_prefs_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD dprequest(
   1 dplist[*]
     2 action_flag = c1
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 person_id = f8
     2 view_name = c12
     2 view_seq = i4
     2 comp_name = c12
     2 comp_seq = i4
 )
 FREE SET dpreply
 RECORD dpreply(
   1 dplist[*]
     2 detail_prefs_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD aprequest(
   1 aplist[*]
     2 action_flag = c1
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
 )
 FREE SET apreply
 RECORD apreply(
   1 aplist[*]
     2 app_prefs_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD nvprequest(
   1 nvplist[*]
     2 action_flag = c1
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 pvc_name = c32
     2 pvc_value = c256
 )
 FREE SET nvpreply
 RECORD nvpreply(
   1 nvplist[*]
     2 name_value_prefs_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD pvrequest(
   1 pvlist[*]
     2 action_flag = c1
     2 person_id = f8
     2 position_cd = f8
     2 ppr_cd = f8
     2 location_cd = f8
     2 priv_cdf_meaning = c12
     2 priv_value = c7
 )
 FREE SET pvreply
 RECORD pvreply(
   1 pvlist[*]
     2 privilege_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(reply->status_data.status_list,3)
 SET stat = alterlist(vprequest->vplist,1)
 SET stat = alterlist(vpreply->vplist,1)
 SET vprequest->vplist[1].application_number = request->application_number
 SET vprequest->vplist[1].position_cd = request->position_cd
 SET vprequest->vplist[1].prsnl_id = request->prsnl_id
 SET vprequest->vplist[1].frame_type = "CHART"
 SET vprequest->vplist[1].view_name = "CLINNOTES"
 SET vprequest->vplist[1].view_seq = 0
 SET stat = alterlist(vcprequest->vcplist,1)
 SET stat = alterlist(vcpreply->vcplist,1)
 SET vcprequest->vcplist[1].application_number = request->application_number
 SET vcprequest->vcplist[1].position_cd = request->position_cd
 SET vcprequest->vcplist[1].prsnl_id = request->prsnl_id
 SET vcprequest->vcplist[1].view_name = "CLINNOTES"
 SET vcprequest->vcplist[1].view_seq = 0
 SET vcprequest->vcplist[1].comp_name = "CLINNOTES"
 SET vcprequest->vcplist[1].comp_seq = 0
 SET stat = alterlist(dprequest->dplist,1)
 SET stat = alterlist(dpreply->dplist,1)
 SET dprequest->dplist[1].application_number = request->application_number
 SET dprequest->dplist[1].prsnl_id = request->prsnl_id
 SET dprequest->dplist[1].person_id = 0.0
 SET dprequest->dplist[1].view_seq = 0
 SET dprequest->dplist[1].comp_seq = 0
 SET stat = alterlist(aprequest->aplist,1)
 SET stat = alterlist(apreply->aplist,1)
 SET aprequest->aplist[1].application_number = request->application_number
 SET aprequest->aplist[1].position_cd = request->position_cd
 SET aprequest->aplist[1].prsnl_id = request->prsnl_id
 SET stat = alterlist(pvrequest->pvlist,1)
 SET stat = alterlist(pvreply->pvlist,1)
 SET pvrequest->pvlist[1].person_id = 0
 SET pvrequest->pvlist[1].position_cd = request->position_cd
 SET pvrequest->pvlist[1].ppr_cd = 0
 SET pvrequest->pvlist[1].location_cd = 0
 SET pvrequest->pvlist[1].priv_cdf_meaning = "SIGNDOC"
 SET dummy_parm1 = 0
 SET dummy_parm2 = 0
 IF ((request->action="0"))
  SET comp_auth_exists = 0
  SET vprequest->vplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
  IF ((vpreply->vplist[1].view_prefs_id > 0))
   CALL complete_vp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[1].action_flag = "0"
   SET nvprequest->nvplist[2].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
   IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
    AND (nvpreply->nvplist[2].name_value_prefs_id > 0))
    SET vcprequest->vcplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
     CALL complete_vcp_nvp(dummy_parm1)
     SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[4].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[5].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[1].action_flag = "0"
     SET nvprequest->nvplist[2].action_flag = "0"
     SET nvprequest->nvplist[3].action_flag = "0"
     SET nvprequest->nvplist[4].action_flag = "0"
     SET nvprequest->nvplist[5].action_flag = "0"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
     IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
      AND (nvpreply->nvplist[2].name_value_prefs_id > 0)
      AND (nvpreply->nvplist[3].name_value_prefs_id > 0)
      AND (nvpreply->nvplist[4].name_value_prefs_id > 0)
      AND (nvpreply->nvplist[5].name_value_prefs_id > 0))
      SET comp_auth_exists = 1
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  SET menu_auth_value = "  "
  SET nvp_exists = 0
  SET dprequest->dplist[1].position_cd = request->position_cd
  SET dprequest->dplist[1].view_name = "AUTHORIZE"
  SET dprequest->dplist[1].comp_name = "AUTHORIZE"
  SET dprequest->dplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
  IF ((dpreply->dplist[1].detail_prefs_id > 0))
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
     AND nvp.pvc_name="COMMAND_33466"
     AND nvp.active_ind=1
    DETAIL
     nvp_exists = 1, menu_auth_value = nvp.pvc_value
    WITH nocounter
   ;end select
  ENDIF
  IF ((((dpreply->dplist[1].detail_prefs_id=0)) OR (nvp_exists=0)) )
   SET dprequest->dplist[1].position_cd = 0.0
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
   IF ((dpreply->dplist[1].detail_prefs_id > 0))
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
      AND nvp.pvc_name="COMMAND_33466"
      AND nvp.active_ind=1
     DETAIL
      menu_auth_value = nvp.pvc_value
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  SET readonly_pref_value = " "
  SET nvp_exists = 0
  SET dprequest->dplist[1].position_cd = request->position_cd
  SET dprequest->dplist[1].view_name = "CLINNOTES"
  SET dprequest->dplist[1].comp_name = "CLINNOTES"
  SET dprequest->dplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
  IF ((dpreply->dplist[1].detail_prefs_id > 0))
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
     AND nvp.pvc_name="pvNotes.ReadOnly"
     AND nvp.active_ind=1
    DETAIL
     nvp_exists = 1, readonly_pref_value = nvp.pvc_value
    WITH nocounter
   ;end select
  ENDIF
  IF ((((dpreply->dplist[1].detail_prefs_id=0)) OR (nvp_exists=0)) )
   SET dprequest->dplist[1].position_cd = 0.0
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
   IF ((dpreply->dplist[1].detail_prefs_id > 0))
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
      AND nvp.pvc_name="pvNotes.ReadOnly"
      AND nvp.active_ind=1
     DETAIL
      nvp_exists = 1, readonly_pref_value = nvp.pvc_value
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  SET imaging_pref_value = " "
  SET nvp_exists = 0
  SET aprequest->aplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_app_prefs  WITH replace("REQUEST",aprequest), replace("REPLY",apreply)
  IF ((apreply->aplist[1].app_prefs_id > 0))
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="APP_PREFS"
     AND (nvp.parent_entity_id=apreply->aplist[1].app_prefs_id)
     AND nvp.pvc_name="USE_OTG_IMAGING"
     AND nvp.active_ind=1
    DETAIL
     nvp_exists = 1, imaging_pref_value = nvp.pvc_value
    WITH nocounter
   ;end select
  ENDIF
  IF ((((apreply->aplist[1].app_prefs_id=0)) OR (nvp_exists=0)) )
   SET aprequest->aplist[1].position_cd = 0.0
   SET trace = recpersist
   EXECUTE bed_get_ens_app_prefs  WITH replace("REQUEST",aprequest), replace("REPLY",apreply)
   IF ((apreply->aplist[1].app_prefs_id > 0))
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="APP_PREFS"
      AND (nvp.parent_entity_id=apreply->aplist[1].app_prefs_id)
      AND nvp.pvc_name="USE_OTG_IMAGING"
      AND nvp.active_ind=1
     DETAIL
      nvp_exists = 1, imaging_pref_value = nvp.pvc_value
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  SET revdoc_pref_value = "0"
  SET clinnotes_detail_prefs_id = 0.0
  SELECT INTO "NL:"
   FROM detail_prefs dp
   WHERE (dp.application_number=request->application_number)
    AND (dp.position_cd=request->position_cd)
    AND (dp.prsnl_id=request->prsnl_id)
    AND dp.person_id=0.0
    AND dp.view_name="CLINNOTES"
    AND dp.view_seq=0
    AND dp.comp_name="CLINNOTES"
    AND dp.comp_seq=0
    AND dp.active_ind=1
   DETAIL
    clinnotes_detail_prefs_id = dp.detail_prefs_id
   WITH nocounter
  ;end select
  IF (clinnotes_detail_prefs_id=0)
   SELECT INTO "NL:"
    FROM detail_prefs dp
    WHERE (dp.application_number=request->application_number)
     AND dp.position_cd=0.0
     AND (dp.prsnl_id=request->prsnl_id)
     AND dp.person_id=0.0
     AND dp.view_name="CLINNOTES"
     AND dp.view_seq=0
     AND dp.comp_name="CLINNOTES"
     AND dp.comp_seq=0
     AND dp.active_ind=1
    DETAIL
     clinnotes_detail_prefs_id = dp.detail_prefs_id
    WITH nocounter
   ;end select
  ENDIF
  IF (clinnotes_detail_prefs_id > 0)
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=clinnotes_detail_prefs_id
     AND nvp.pvc_name="pvNotes.ReviewDocument"
     AND nvp.active_ind=1
    DETAIL
     revdoc_pref_value = nvp.pvc_value
    WITH nocounter
   ;end select
  ENDIF
  SET signdoc_priv_allowed = 0
  SET pvrequest->pvlist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
  IF ((pvreply->pvlist[1].privilege_id=0))
   SET signdoc_priv_allowed = 1
  ENDIF
  SET reply->status_data.status_list[1].status = "0"
  SET reply->status_data.status_list[2].status = "0"
  SET reply->status_data.status_list[3].status = "0"
  IF (comp_auth_exists=1
   AND menu_auth_value="1"
   AND signdoc_priv_allowed=1
   AND revdoc_pref_value IN ("1", "2", "3"))
   SET reply->status_data.status_list[2].status = revdoc_pref_value
   IF (imaging_pref_value="2")
    SET reply->status_data.status_list[3].status = "1"
   ENDIF
  ELSE
   IF (comp_auth_exists=1
    AND readonly_pref_value="1")
    SET reply->status_data.status_list[1].status = "1"
   ENDIF
  ENDIF
 ELSEIF ((request->action="2"))
  SET view_off_on_ind = request->task_list[1].on_off_ind
  SET updt_off_on_ind = request->task_list[2].on_off_ind
  SET scan_off_on_ind = request->task_list[3].on_off_ind
  IF (((view_off_on_ind=1) OR (updt_off_on_ind > 0)) )
   SET vprequest->vplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   IF ((vpreply->vplist[1].view_prefs_id=0))
    SET vprequest->vplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   ENDIF
   IF ((vpreply->vplist[1].view_prefs_id > 0))
    CALL complete_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[1].action_flag = "0"
    SET nvprequest->nvplist[2].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    IF ((nvpreply->nvplist[1].name_value_prefs_id=0)
     AND (nvpreply->nvplist[2].name_value_prefs_id=0))
     SET nvprequest->nvplist[1].action_flag = "1"
     SET nvprequest->nvplist[2].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ELSEIF ((nvpreply->nvplist[1].name_value_prefs_id=0))
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ELSEIF ((nvpreply->nvplist[2].name_value_prefs_id=0))
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     SET nvprequest->nvplist[1].pvc_name = "DISPLAY_SEQ"
     SET nvprequest->nvplist[1].pvc_value = "5"
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ENDIF
   SET vcprequest->vcplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply)
   IF ((vcpreply->vcplist[1].view_comp_prefs_id=0))
    SET vcprequest->vcplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
   ENDIF
   IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
    CALL complete_vcp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[4].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[5].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[1].action_flag = "0"
    SET nvprequest->nvplist[2].action_flag = "0"
    SET nvprequest->nvplist[3].action_flag = "0"
    SET nvprequest->nvplist[4].action_flag = "0"
    SET nvprequest->nvplist[5].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    IF ((nvpreply->nvplist[1].name_value_prefs_id=0)
     AND (nvpreply->nvplist[2].name_value_prefs_id=0)
     AND (nvpreply->nvplist[3].name_value_prefs_id=0)
     AND (nvpreply->nvplist[4].name_value_prefs_id=0)
     AND (nvpreply->nvplist[5].name_value_prefs_id=0))
     SET nvprequest->nvplist[1].action_flag = "1"
     SET nvprequest->nvplist[2].action_flag = "1"
     SET nvprequest->nvplist[3].action_flag = "1"
     SET nvprequest->nvplist[4].action_flag = "1"
     SET nvprequest->nvplist[5].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ELSE
     SET hold_nvp1 = nvpreply->nvplist[1].name_value_prefs_id
     SET hold_nvp2 = nvpreply->nvplist[2].name_value_prefs_id
     SET hold_nvp3 = nvpreply->nvplist[3].name_value_prefs_id
     SET hold_nvp4 = nvpreply->nvplist[4].name_value_prefs_id
     SET hold_nvp5 = nvpreply->nvplist[5].name_value_prefs_id
     SET nvprequest->nvplist[1].action_flag = "1"
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     IF (hold_nvp1=0)
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp2=0)
      SET nvprequest->nvplist[1].pvc_name = "COMP_TYPE"
      SET nvprequest->nvplist[1].pvc_value = "0"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp3=0)
      SET nvprequest->nvplist[1].pvc_name = "LIST_VIEW"
      SET nvprequest->nvplist[1].pvc_value = "0"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp4=0)
      SET nvprequest->nvplist[1].pvc_name = "PREFMGR_ENABLED"
      SET nvprequest->nvplist[1].pvc_value = "0"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp5=0)
      SET nvprequest->nvplist[1].pvc_name = "COMMAND_ID"
      SET nvprequest->nvplist[1].pvc_value = "33244"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
    ENDIF
   ENDIF
  ELSE
   SET vprequest->vplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   IF ((vpreply->vplist[1].view_prefs_id > 0))
    CALL complete_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET vprequest->vplist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
    SET nvprequest->nvplist[1].action_flag = "3"
    SET nvprequest->nvplist[2].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
   SET vcprequest->vcplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply)
   IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
    CALL complete_vcp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[4].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[5].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET vcprequest->vcplist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    SET nvprequest->nvplist[1].action_flag = "3"
    SET nvprequest->nvplist[2].action_flag = "3"
    SET nvprequest->nvplist[3].action_flag = "3"
    SET nvprequest->nvplist[4].action_flag = "3"
    SET nvprequest->nvplist[5].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ENDIF
  SET nvp_exists = 0
  SET menu_auth_value = " "
  SET dpreply->dplist[1].detail_prefs_id = 0.0
  SET dprequest->dplist[1].position_cd = request->position_cd
  SET dprequest->dplist[1].view_name = "AUTHORIZE"
  SET dprequest->dplist[1].comp_name = "AUTHORIZE"
  SET dprequest->dplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
  IF ((dpreply->dplist[1].detail_prefs_id > 0))
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
     AND nvp.pvc_name="COMMAND_33466"
     AND nvp.active_ind=1
    DETAIL
     nvp_exists = 1, menu_auth_value = nvp.pvc_value
    WITH nocounter
   ;end select
  ELSE
   SET dprequest->dplist[1].action_flag = "1"
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
  ENDIF
  SET stat = alterlist(nvprequest->nvplist,1)
  SET stat = alterlist(nvpreply->nvplist,1)
  SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
  SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
  SET nvprequest->nvplist[1].pvc_name = "COMMAND_33466"
  IF (updt_off_on_ind > 0)
   IF (nvp_exists > 0)
    IF (menu_auth_value != "1")
     SET nvprequest->nvplist[1].pvc_value = "1"
     SET nvprequest->nvplist[1].action_flag = "2"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ELSE
    SET nvprequest->nvplist[1].pvc_value = "1"
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ELSE
   IF (nvp_exists > 0)
    IF (menu_auth_value != "-2")
     SET nvprequest->nvplist[1].pvc_value = "-2"
     SET nvprequest->nvplist[1].action_flag = "2"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ELSE
    SET nvprequest->nvplist[1].pvc_value = "-2"
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ENDIF
  SET vnot_row_cnt = 0
  SET rept_row_cnt = 0
  SET vnot_encsumm_value = " "
  SET rept_encsumm_value = " "
  SET dprequest->dplist[1].position_cd = request->position_cd
  SET dprequest->dplist[1].view_name = "ENCSUMMARY"
  SET dprequest->dplist[1].comp_name = "ENCSUMMARY"
  SET dprequest->dplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
  IF ((dpreply->dplist[1].detail_prefs_id > 0))
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
     AND nvp.pvc_name="SHOW_VISITNOTES"
     AND nvp.active_ind=1
    DETAIL
     vnot_row_cnt = (vnot_row_cnt+ 1), vnot_encsumm_value = nvp.pvc_value
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
     AND nvp.pvc_name="SHOW_REPORTS"
     AND nvp.active_ind=1
    DETAIL
     rept_row_cnt = (rept_row_cnt+ 1), rept_encsumm_value = nvp.pvc_value
    WITH nocounter
   ;end select
  ELSE
   SET dprequest->dplist[1].action_flag = "1"
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
  ENDIF
  IF (((view_off_on_ind=1) OR (updt_off_on_ind > 0)) )
   CALL complete_vnot_encsumm_dp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
   IF (vnot_row_cnt > 0)
    IF (vnot_encsumm_value != "1")
     SET nvprequest->nvplist[1].action_flag = "2"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ELSE
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
   CALL complete_rept_encsumm_dp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
   IF (rept_row_cnt > 0)
    IF (rept_encsumm_value != "1")
     SET nvprequest->nvplist[1].action_flag = "2"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ELSE
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ELSE
   CALL complete_vnot_encsumm_dp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
   IF (vnot_row_cnt > 0)
    IF (vnot_encsumm_value != "0")
     SET nvprequest->nvplist[1].pvc_value = "0"
     SET nvprequest->nvplist[1].action_flag = "2"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ELSE
    SET nvprequest->nvplist[1].pvc_value = "0"
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
   CALL complete_rept_encsumm_dp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
   IF (rept_row_cnt > 0)
    IF (rept_encsumm_value != "0")
     SET nvprequest->nvplist[1].pvc_value = "0"
     SET nvprequest->nvplist[1].action_flag = "2"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ELSE
    SET nvprequest->nvplist[1].pvc_value = "0"
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ENDIF
  SET nvp_exists = 0
  SET readonly_value = " "
  SET dpreply->dplist[1].detail_prefs_id = 0.0
  SET dprequest->dplist[1].position_cd = request->position_cd
  SET dprequest->dplist[1].view_name = "CLINNOTES"
  SET dprequest->dplist[1].comp_name = "CLINNOTES"
  SET dprequest->dplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
  IF ((dpreply->dplist[1].detail_prefs_id > 0))
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
     AND nvp.pvc_name="pvNotes.ReadOnly"
     AND nvp.active_ind=1
    DETAIL
     nvp_exists = 1, readonly_value = nvp.pvc_value
    WITH nocounter
   ;end select
  ELSE
   SET dprequest->dplist[1].action_flag = "1"
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
  ENDIF
  SET stat = alterlist(nvprequest->nvplist,1)
  SET stat = alterlist(nvpreply->nvplist,1)
  SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
  SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
  SET nvprequest->nvplist[1].pvc_name = "pvNotes.ReadOnly"
  IF (view_off_on_ind=1)
   IF (nvp_exists > 0)
    IF (readonly_value != "1")
     SET nvprequest->nvplist[1].pvc_value = "1"
     SET nvprequest->nvplist[1].action_flag = "2"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ELSE
    SET nvprequest->nvplist[1].pvc_value = "1"
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ELSE
   IF (nvp_exists > 0)
    IF (readonly_value != "0")
     SET nvprequest->nvplist[1].pvc_value = "0"
     SET nvprequest->nvplist[1].action_flag = "2"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ELSE
    SET nvprequest->nvplist[1].pvc_value = "0"
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ENDIF
  SET nvp_exists = 0
  SET imaging_value = " "
  SET aprequest->aplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_app_prefs  WITH replace("REQUEST",aprequest), replace("REPLY",apreply)
  IF ((apreply->aplist[1].app_prefs_id > 0))
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="APP_PREFS"
     AND (nvp.parent_entity_id=apreply->aplist[1].app_prefs_id)
     AND nvp.pvc_name="USE_OTG_IMAGING"
     AND nvp.active_ind=1
    DETAIL
     nvp_exists = 1, imaging_value = nvp.pvc_value
    WITH nocounter
   ;end select
  ELSE
   SET aprequest->aplist[1].action_flag = "1"
   SET trace = recpersist
   EXECUTE bed_get_ens_app_prefs  WITH replace("REQUEST",aprequest), replace("REPLY",apreply)
  ENDIF
  SET stat = alterlist(nvprequest->nvplist,1)
  SET stat = alterlist(nvpreply->nvplist,1)
  SET nvprequest->nvplist[1].parent_entity_name = "APP_PREFS"
  SET nvprequest->nvplist[1].parent_entity_id = apreply->aplist[1].app_prefs_id
  SET nvprequest->nvplist[1].pvc_name = "USE_OTG_IMAGING"
  IF (scan_off_on_ind=1)
   IF (nvp_exists > 0)
    IF (imaging_value != "2")
     SET nvprequest->nvplist[1].pvc_value = "2"
     SET nvprequest->nvplist[1].action_flag = "2"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ELSE
    SET nvprequest->nvplist[1].pvc_value = "2"
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ELSE
   IF (nvp_exists > 0)
    IF (imaging_value != "0")
     SET nvprequest->nvplist[1].pvc_value = "0"
     SET nvprequest->nvplist[1].action_flag = "2"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ELSE
    SET nvprequest->nvplist[1].pvc_value = "0"
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ENDIF
  SET revdoc_pref_value = "0"
  SET pref_cnt = 0
  SET clinnotes_detail_prefs_id = 0.0
  SELECT INTO "NL:"
   FROM detail_prefs dp
   WHERE (dp.application_number=request->application_number)
    AND (dp.position_cd=request->position_cd)
    AND (dp.prsnl_id=request->prsnl_id)
    AND dp.person_id=0.0
    AND dp.view_name="CLINNOTES"
    AND dp.view_seq=0
    AND dp.comp_name="CLINNOTES"
    AND dp.comp_seq=0
    AND dp.active_ind=1
   DETAIL
    clinnotes_detail_prefs_id = dp.detail_prefs_id
   WITH nocounter
  ;end select
  IF (clinnotes_detail_prefs_id > 0)
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=clinnotes_detail_prefs_id
     AND nvp.pvc_name="pvNotes.ReviewDocument"
     AND nvp.active_ind=1
    DETAIL
     pref_cnt = (pref_cnt+ 1), revdoc_pref_value = nvp.pvc_value
    WITH nocounter
   ;end select
  ENDIF
  IF (updt_off_on_ind > 0)
   IF (pref_cnt > 0)
    IF (cnvtint(revdoc_pref_value) != updt_off_on_ind)
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_value = cnvtstring(updt_off_on_ind), nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id
        = reqinfo->updt_id,
       nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
       .updt_applctx = reqinfo->updt_applctx
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=clinnotes_detail_prefs_id
       AND nvp.pvc_name="pvNotes.ReviewDocument"
       AND nvp.active_ind=1
      WITH nocounter
     ;end update
    ENDIF
   ELSE
    IF (clinnotes_detail_prefs_id=0)
     SET dprequest->dplist[1].view_name = "CLINNOTES"
     SET dprequest->dplist[1].comp_name = "CLINNOTES"
     SET dprequest->dplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
     SET clinnotes_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
    ENDIF
    SET stat = alterlist(nvprequest->nvplist,1)
    SET stat = alterlist(nvpreply->nvplist,1)
    SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
    SET nvprequest->nvplist[1].parent_entity_id = clinnotes_detail_prefs_id
    SET nvprequest->nvplist[1].pvc_name = "pvNotes.ReviewDocument"
    SET nvprequest->nvplist[1].pvc_value = cnvtstring(updt_off_on_ind)
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ELSE
   IF (pref_cnt > 0)
    IF (cnvtint(revdoc_pref_value) != 0)
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_value = "0", nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->updt_id,
       nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
       .updt_applctx = reqinfo->updt_applctx
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=clinnotes_detail_prefs_id
       AND nvp.pvc_name="pvNotes.ReviewDocument"
       AND nvp.active_ind=1
      WITH nocounter
     ;end update
    ENDIF
   ELSE
    IF (clinnotes_detail_prefs_id=0)
     SET dprequest->dplist[1].view_name = "CLINNOTES"
     SET dprequest->dplist[1].comp_name = "CLINNOTES"
     SET dprequest->dplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
     SET clinnotes_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
    ENDIF
    SET stat = alterlist(nvprequest->nvplist,1)
    SET stat = alterlist(nvpreply->nvplist,1)
    SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
    SET nvprequest->nvplist[1].parent_entity_id = clinnotes_detail_prefs_id
    SET nvprequest->nvplist[1].pvc_name = "pvNotes.ReviewDocument"
    SET nvprequest->nvplist[1].pvc_value = "0"
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ENDIF
  SET signdoc_priv_allowed = 0
  SET pvrequest->pvlist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
  IF ((pvreply->pvlist[1].privilege_id=0))
   SET signdoc_priv_allowed = 1
  ENDIF
  IF (updt_off_on_ind > 0)
   IF (signdoc_priv_allowed=0)
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET signdoc_priv_allowed = 1
   ENDIF
  ELSE
   IF (signdoc_priv_allowed=1)
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET pvrequest->pvlist[1].priv_value = "NO"
    SET pvrequest->pvlist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET signdoc_priv_allowed = 0
   ENDIF
  ENDIF
 ENDIF
 GO TO exitscript
 SUBROUTINE complete_vp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,2)
   SET stat = alterlist(nvpreply->nvplist,2)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "VIEW_CAPTION"
   SET nvprequest->nvplist[1].pvc_value = "Clinical Notes"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "DISPLAY_SEQ"
   SET nvprequest->nvplist[2].pvc_value = "5"
 END ;Subroutine
 SUBROUTINE complete_vcp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,5)
   SET stat = alterlist(nvpreply->nvplist,5)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "COMP_DLLNAME"
   SET nvprequest->nvplist[1].pvc_value = "PVNotes.dll"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "COMP_TYPE"
   SET nvprequest->nvplist[2].pvc_value = "0"
   SET nvprequest->nvplist[3].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[3].pvc_name = "LIST_VIEW"
   SET nvprequest->nvplist[3].pvc_value = "0"
   SET nvprequest->nvplist[4].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[4].pvc_name = "PREFMGR_ENABLED"
   SET nvprequest->nvplist[4].pvc_value = "0"
   SET nvprequest->nvplist[5].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[5].pvc_name = "COMMAND_ID"
   SET nvprequest->nvplist[5].pvc_value = "33244"
 END ;Subroutine
 SUBROUTINE complete_vnot_encsumm_dp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,1)
   SET stat = alterlist(nvpreply->nvplist,1)
   SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "SHOW_VISITNOTES"
   SET nvprequest->nvplist[1].pvc_value = "1"
 END ;Subroutine
 SUBROUTINE complete_rept_encsumm_dp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,1)
   SET stat = alterlist(nvpreply->nvplist,1)
   SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "SHOW_REPORTS"
   SET nvprequest->nvplist[1].pvc_value = "1"
 END ;Subroutine
#exitscript
END GO

CREATE PROGRAM bed_get_ens_tasks_allergy:dba
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
 SET stat = alterlist(reply->status_data.status_list,2)
 SET stat = alterlist(vprequest->vplist,1)
 SET stat = alterlist(vpreply->vplist,1)
 SET vprequest->vplist[1].application_number = request->application_number
 SET vprequest->vplist[1].position_cd = request->position_cd
 SET vprequest->vplist[1].prsnl_id = request->prsnl_id
 SET vprequest->vplist[1].frame_type = "CHART"
 SET vprequest->vplist[1].view_name = "ALLERGY"
 SET vprequest->vplist[1].view_seq = 0
 SET stat = alterlist(vcprequest->vcplist,1)
 SET stat = alterlist(vcpreply->vcplist,1)
 SET vcprequest->vcplist[1].application_number = request->application_number
 SET vcprequest->vcplist[1].position_cd = request->position_cd
 SET vcprequest->vcplist[1].prsnl_id = request->prsnl_id
 SET vcprequest->vcplist[1].view_name = "ALLERGY"
 SET vcprequest->vcplist[1].view_seq = 0
 SET vcprequest->vcplist[1].comp_name = "ALLERGY"
 SET vcprequest->vcplist[1].comp_seq = 0
 SET stat = alterlist(pvrequest->pvlist,2)
 SET stat = alterlist(pvreply->pvlist,2)
 SET pvrequest->pvlist[1].person_id = 0
 SET pvrequest->pvlist[1].position_cd = request->position_cd
 SET pvrequest->pvlist[1].ppr_cd = 0
 SET pvrequest->pvlist[1].location_cd = 0
 SET pvrequest->pvlist[2].person_id = 0
 SET pvrequest->pvlist[2].position_cd = request->position_cd
 SET pvrequest->pvlist[2].ppr_cd = 0
 SET pvrequest->pvlist[2].location_cd = 0
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
  CALL complete_dp(dummy_parm1)
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
     AND nvp.pvc_name="COMMAND_33464"
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
      AND nvp.pvc_name="COMMAND_33464"
      AND nvp.active_ind=1
     DETAIL
      menu_auth_value = nvp.pvc_value
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  SET view_priv_allowed = 0
  SET updt_priv_allowed = 0
  SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWALLERGY"
  SET pvrequest->pvlist[2].priv_cdf_meaning = "UPDTALLERGY"
  SET pvrequest->pvlist[1].action_flag = "0"
  SET pvrequest->pvlist[2].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
  IF ((pvreply->pvlist[1].privilege_id=0))
   SET view_priv_allowed = 1
  ENDIF
  IF ((pvreply->pvlist[2].privilege_id=0))
   SET updt_priv_allowed = 1
  ENDIF
  SET task_cnt = size(request->task_list,5)
  IF (task_cnt=2)
   SET reply->status_data.status_list[1].status = "0"
   SET reply->status_data.status_list[2].status = "0"
   IF (comp_auth_exists=1
    AND menu_auth_value="1"
    AND view_priv_allowed=1
    AND updt_priv_allowed=1)
    SET reply->status_data.status_list[2].status = "1"
   ELSE
    IF (comp_auth_exists=1
     AND view_priv_allowed=1)
     SET reply->status_data.status_list[1].status = "1"
    ENDIF
   ENDIF
  ELSEIF ((request->task_list[1].task="VIEWALLERGY"))
   SET reply->status_data.status_list[1].status = "0"
   IF (comp_auth_exists=1
    AND view_priv_allowed=1)
    SET reply->status_data.status_list[1].status = "1"
   ENDIF
  ELSEIF ((request->task_list[1].task="UPDALLERGY"))
   SET reply->status_data.status_list[1].status = "0"
   IF (comp_auth_exists=1
    AND menu_auth_value="1"
    AND view_priv_allowed=1
    AND updt_priv_allowed=1)
    SET reply->status_data.status_list[1].status = "1"
   ENDIF
  ENDIF
 ELSEIF ((request->action="2"))
  SET view_off_on_ind = request->task_list[1].on_off_ind
  SET upd_off_on_ind = request->task_list[2].on_off_ind
  IF (((view_off_on_ind=1) OR (upd_off_on_ind=1)) )
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
     SET nvprequest->nvplist[1].pvc_value = "3"
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
      SET nvprequest->nvplist[1].pvc_value = "1"
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
      SET nvprequest->nvplist[1].pvc_value = "0"
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
  CALL complete_dp(dummy_parm1)
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
     AND nvp.pvc_name="COMMAND_33464"
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
  SET nvprequest->nvplist[1].pvc_name = "COMMAND_33464"
  IF (upd_off_on_ind=1)
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
  SET row_cnt = 0
  SET encsummary_value = " "
  CALL complete_dp(dummy_parm1)
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
     AND nvp.pvc_name="SHOW_ALLERGIES"
     AND nvp.active_ind=1
    DETAIL
     row_cnt = (row_cnt+ 1), encsummary_value = nvp.pvc_value
    WITH nocounter
   ;end select
  ELSE
   SET dprequest->dplist[1].action_flag = "1"
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
  ENDIF
  CALL complete_encsumm_dp_nvp(dummy_parm1)
  SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
  IF (((view_off_on_ind=1) OR (upd_off_on_ind=1)) )
   IF (row_cnt > 0)
    IF (encsummary_value != "1")
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
   IF (row_cnt > 0)
    IF (encsummary_value != "0")
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
  SET view_priv_allowed = 0
  SET updt_priv_allowed = 0
  SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWALLERGY"
  SET pvrequest->pvlist[2].priv_cdf_meaning = "UPDTALLERGY"
  SET pvrequest->pvlist[1].action_flag = "0"
  SET pvrequest->pvlist[2].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
  IF ((pvreply->pvlist[1].privilege_id=0))
   SET view_priv_allowed = 1
  ENDIF
  IF ((pvreply->pvlist[2].privilege_id=0))
   SET updt_priv_allowed = 1
  ENDIF
  IF (upd_off_on_ind=1)
   IF (view_priv_allowed=0)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWALLERGY"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET view_priv_allowed = 1
   ENDIF
   IF (updt_priv_allowed=0)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDTALLERGY"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET updt_priv_allowed = 1
   ENDIF
  ELSEIF (view_off_on_ind=1)
   IF (view_priv_allowed=0)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWALLERGY"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET view_priv_allowed = 1
   ENDIF
   IF (updt_priv_allowed=1)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDTALLERGY"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDTALLERGY"
    SET pvrequest->pvlist[1].priv_value = "NO"
    SET pvrequest->pvlist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET updt_priv_allowed = 0
   ENDIF
  ELSE
   IF (view_priv_allowed=1)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWALLERGY"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWALLERGY"
    SET pvrequest->pvlist[1].priv_value = "NO"
    SET pvrequest->pvlist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET view_priv_allowed = 0
   ENDIF
   IF (updt_priv_allowed=1)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDTALLERGY"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDTALLERGY"
    SET pvrequest->pvlist[1].priv_value = "NO"
    SET pvrequest->pvlist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET updt_priv_allowed = 0
   ENDIF
  ENDIF
 ENDIF
 GO TO exitscript
 SUBROUTINE complete_vp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,2)
   SET stat = alterlist(nvpreply->nvplist,2)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "VIEW_CAPTION"
   SET nvprequest->nvplist[1].pvc_value = "Allergies"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "DISPLAY_SEQ"
   SET nvprequest->nvplist[2].pvc_value = "3"
 END ;Subroutine
 SUBROUTINE complete_vcp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,5)
   SET stat = alterlist(nvpreply->nvplist,5)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "COMP_DLLNAME"
   SET nvprequest->nvplist[1].pvc_value = "CPSUIAllergy.dll"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "COMP_TYPE"
   SET nvprequest->nvplist[2].pvc_value = "0"
   SET nvprequest->nvplist[3].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[3].pvc_name = "LIST_VIEW"
   SET nvprequest->nvplist[3].pvc_value = "1"
   SET nvprequest->nvplist[4].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[4].pvc_name = "PREFMGR_ENABLED"
   SET nvprequest->nvplist[4].pvc_value = "0"
   SET nvprequest->nvplist[5].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[5].pvc_name = "COMMAND_ID"
   SET nvprequest->nvplist[5].pvc_value = "0"
 END ;Subroutine
 SUBROUTINE complete_dp(dummy_parm2)
   SET stat = alterlist(dprequest->dplist,1)
   SET stat = alterlist(dpreply->dplist,1)
   SET dprequest->dplist[1].application_number = request->application_number
   SET dprequest->dplist[1].position_cd = request->position_cd
   SET dprequest->dplist[1].prsnl_id = request->prsnl_id
   SET dprequest->dplist[1].person_id = 0.0
   SET dprequest->dplist[1].view_seq = 0
   SET dprequest->dplist[1].comp_seq = 0
 END ;Subroutine
 SUBROUTINE complete_encsumm_dp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,1)
   SET stat = alterlist(nvpreply->nvplist,1)
   SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "SHOW_ALLERGIES"
   SET nvprequest->nvplist[1].pvc_value = "1"
 END ;Subroutine
#exitscript
END GO

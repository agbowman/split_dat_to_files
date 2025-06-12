CREATE PROGRAM bed_get_ens_tasks_immun:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
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
 SET stat = alterlist(vprequest->vplist,1)
 SET vprequest->vplist[1].application_number = request->application_number
 SET vprequest->vplist[1].position_cd = request->position_cd
 SET vprequest->vplist[1].prsnl_id = request->prsnl_id
 SET vprequest->vplist[1].frame_type = "CHART"
 SET vprequest->vplist[1].view_name = "IMMUNSCHED"
 SET vprequest->vplist[1].view_seq = 0
 SET stat = alterlist(vcprequest->vcplist,1)
 SET vcprequest->vcplist[1].application_number = request->application_number
 SET vcprequest->vcplist[1].position_cd = request->position_cd
 SET vcprequest->vcplist[1].prsnl_id = request->prsnl_id
 SET vcprequest->vcplist[1].view_name = "IMMUNSCHED"
 SET vcprequest->vcplist[1].view_seq = 0
 SET vcprequest->vcplist[1].comp_name = "IMMUNSCHED"
 SET vcprequest->vcplist[1].comp_seq = 0
 SET stat = alterlist(dprequest->dplist,1)
 SET stat = alterlist(dpreply->dplist,1)
 SET dprequest->dplist[1].application_number = request->application_number
 SET dprequest->dplist[1].position_cd = request->position_cd
 SET dprequest->dplist[1].prsnl_id = request->prsnl_id
 SET dprequest->dplist[1].person_id = 0.0
 SET dprequest->dplist[1].view_seq = 0
 SET dprequest->dplist[1].comp_seq = 0
 SET dprequest->dplist[1].view_name = "AUTHORIZE"
 SET dprequest->dplist[1].comp_name = "AUTHORIZE"
 SET dprequest->dplist[1].action_flag = "0"
 SET trace = recpersist
 EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
 SET authorize_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
 SET menu_auth_value = "  "
 SET menu_nvp_exists = 0
 IF (authorize_detail_prefs_id > 0)
  SELECT INTO "NL:"
   FROM name_value_prefs nvp
   WHERE nvp.parent_entity_name="DETAIL_PREFS"
    AND nvp.parent_entity_id=authorize_detail_prefs_id
    AND nvp.pvc_name="COMMAND_33465"
    AND nvp.active_ind=1
   DETAIL
    menu_nvp_exists = 1, menu_auth_value = nvp.pvc_value
   WITH nocounter
  ;end select
 ENDIF
 SET dummy_parm1 = 0
 SET dummy_parm2 = 0
 IF ((request->action="0"))
  SET comp_auth_exists = 0
  SET vprequest->vplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
  IF ((vpreply->vplist[1].view_prefs_id > 0))
   CALL complete_immunsched_vp_nvp(dummy_parm1)
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
     CALL complete_immunsched_vcp_nvp(dummy_parm1)
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
  IF (comp_auth_exists=0)
   SET vprequest->vplist[1].view_name = "IMMUNIZATION"
   SET vcprequest->vcplist[1].view_name = "IMMUNIZATION"
   SET vcprequest->vcplist[1].comp_name = "IMMUNIZATION"
   SET vprequest->vplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   IF ((vpreply->vplist[1].view_prefs_id > 0))
    CALL complete_immuns_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[1].action_flag = "0"
    SET nvprequest->nvplist[2].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
     AND (nvpreply->nvplist[2].name_value_prefs_id > 0))
     SET vcprequest->vcplist[1].action_flag = "0"
     SET trace = recpersist
     EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",
      vcpreply)
     IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
      CALL complete_immuns_vcp_nvp(dummy_parm1)
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
  ENDIF
  IF (((authorize_detail_prefs_id=0) OR (menu_nvp_exists=0)) )
   SET dprequest->dplist[1].position_cd = 0.0
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
   IF ((dpreply->dplist[1].detail_prefs_id > 0))
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
      AND nvp.pvc_name="COMMAND_33465"
      AND nvp.active_ind=1
     DETAIL
      menu_auth_value = nvp.pvc_value
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  SET reply->status_data.status = "F"
  IF (comp_auth_exists=1
   AND menu_auth_value="1")
   SET reply->status_data.status = "S"
  ENDIF
 ELSEIF ((request->action="2"))
  SET vprequest->vplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
  IF ((vpreply->vplist[1].view_prefs_id=0))
   SET vprequest->vplist[1].action_flag = "1"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
  ENDIF
  IF ((vpreply->vplist[1].view_prefs_id > 0))
   CALL complete_immunsched_vp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[1].action_flag = "0"
   SET nvprequest->nvplist[2].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
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
    SET nvprequest->nvplist[1].pvc_value = "15"
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
   EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply)
  ENDIF
  IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
   CALL complete_immunsched_vcp_nvp(dummy_parm1)
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
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
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
     SET nvprequest->nvplist[1].pvc_value = "0"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ENDIF
  ENDIF
  IF (authorize_detail_prefs_id=0)
   SET dprequest->dplist[1].action_flag = "1"
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
   SET authorize_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
  ENDIF
  SET stat = alterlist(nvprequest->nvplist,1)
  SET stat = alterlist(nvpreply->nvplist,1)
  SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
  SET nvprequest->nvplist[1].parent_entity_id = authorize_detail_prefs_id
  SET nvprequest->nvplist[1].pvc_name = "COMMAND_33465"
  IF (menu_nvp_exists > 0)
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
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
  ENDIF
  SET row_cnt = 0
  SET encsummary_value = " "
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
     AND nvp.pvc_name="SHOW_IMMUNIZATIONS"
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
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
  ENDIF
 ELSEIF ((request->action="3"))
  SET vprequest->vplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
  IF ((vpreply->vplist[1].view_prefs_id > 0))
   CALL complete_immunsched_vp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET vprequest->vplist[1].action_flag = "3"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   SET nvprequest->nvplist[1].action_flag = "3"
   SET nvprequest->nvplist[2].action_flag = "3"
   SET trace = recpersist
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
  ENDIF
  SET vcprequest->vcplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply)
  IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
   CALL complete_immunsched_vcp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
   SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
   SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
   SET nvprequest->nvplist[4].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
   SET nvprequest->nvplist[5].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
   SET vcprequest->vcplist[1].action_flag = "3"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply)
   SET nvprequest->nvplist[1].action_flag = "3"
   SET nvprequest->nvplist[2].action_flag = "3"
   SET nvprequest->nvplist[3].action_flag = "3"
   SET nvprequest->nvplist[4].action_flag = "3"
   SET nvprequest->nvplist[5].action_flag = "3"
   SET trace = recpersist
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
  ENDIF
  SET vprequest->vplist[1].view_name = "IMMUNIZATION"
  SET vcprequest->vcplist[1].view_name = "IMMUNIZATION"
  SET vcprequest->vcplist[1].comp_name = "IMMUNIZATION"
  SET vprequest->vplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
  IF ((vpreply->vplist[1].view_prefs_id > 0))
   CALL complete_immuns_vp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET vprequest->vplist[1].action_flag = "3"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   SET nvprequest->nvplist[1].action_flag = "3"
   SET nvprequest->nvplist[2].action_flag = "3"
   SET trace = recpersist
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
  ENDIF
  SET vcprequest->vcplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply)
  IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
   CALL complete_immuns_vcp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
   SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
   SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
   SET nvprequest->nvplist[4].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
   SET nvprequest->nvplist[5].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
   SET vcprequest->vcplist[1].action_flag = "3"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply)
   SET nvprequest->nvplist[1].action_flag = "3"
   SET nvprequest->nvplist[2].action_flag = "3"
   SET nvprequest->nvplist[3].action_flag = "3"
   SET nvprequest->nvplist[4].action_flag = "3"
   SET nvprequest->nvplist[5].action_flag = "3"
   SET trace = recpersist
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
  ENDIF
  IF (authorize_detail_prefs_id=0)
   SET dprequest->dplist[1].action_flag = "1"
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
   SET authorize_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
  ENDIF
  SET stat = alterlist(nvprequest->nvplist,1)
  SET stat = alterlist(nvpreply->nvplist,1)
  SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
  SET nvprequest->nvplist[1].parent_entity_id = authorize_detail_prefs_id
  SET nvprequest->nvplist[1].pvc_name = "COMMAND_33465"
  IF (menu_nvp_exists > 0)
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
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
  ENDIF
  SET row_cnt = 0
  SET encsummary_value = " "
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
     AND nvp.pvc_name="SHOW_IMMUNIZATIONS"
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
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
  ENDIF
 ENDIF
 GO TO exitscript
 SUBROUTINE complete_immunsched_vp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,2)
   SET stat = alterlist(nvpreply->nvplist,2)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "VIEW_CAPTION"
   SET nvprequest->nvplist[1].pvc_value = "Immunization Schedule"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "DISPLAY_SEQ"
   SET nvprequest->nvplist[2].pvc_value = "15"
 END ;Subroutine
 SUBROUTINE complete_immunsched_vcp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,5)
   SET stat = alterlist(nvpreply->nvplist,5)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "COMP_DLLNAME"
   SET nvprequest->nvplist[1].pvc_value = "CPSUIImmunization.dll"
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
   SET nvprequest->nvplist[5].pvc_value = "0"
 END ;Subroutine
 SUBROUTINE complete_immuns_vp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,2)
   SET stat = alterlist(nvpreply->nvplist,2)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "VIEW_CAPTION"
   SET nvprequest->nvplist[1].pvc_value = "Immunizations"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "DISPLAY_SEQ"
   SET nvprequest->nvplist[2].pvc_value = "15"
 END ;Subroutine
 SUBROUTINE complete_immuns_vcp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,5)
   SET stat = alterlist(nvpreply->nvplist,5)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "COMP_DLLNAME"
   SET nvprequest->nvplist[1].pvc_value = "CPSSection.dll"
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
 SUBROUTINE complete_encsumm_dp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,1)
   SET stat = alterlist(nvpreply->nvplist,1)
   SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
   SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
   SET nvprequest->nvplist[1].pvc_name = "SHOW_IMMUNIZATIONS"
   SET nvprequest->nvplist[1].pvc_value = "1"
 END ;Subroutine
#exitscript
END GO

CREATE PROGRAM bed_get_ens_tasks_problem:dba
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
 RECORD temprec(
   1 tlist[*]
     2 temp_tab_name = c256
     2 temp_tab_type = c256
 )
 RECORD temprec2(
   1 tlist2[*]
     2 temp_pvc_name = c32
     2 temp_pvc_value = c256
 )
 SET stat = alterlist(reply->status_data.status_list,2)
 SET stat = alterlist(vprequest->vplist,1)
 SET vprequest->vplist[1].application_number = request->application_number
 SET vprequest->vplist[1].position_cd = request->position_cd
 SET vprequest->vplist[1].prsnl_id = request->prsnl_id
 SET vprequest->vplist[1].frame_type = "CHART"
 SET vprequest->vplist[1].view_name = "PROBLEM_DX"
 SET vprequest->vplist[1].view_seq = 0
 SET stat = alterlist(vcprequest->vcplist,1)
 SET vcprequest->vcplist[1].application_number = request->application_number
 SET vcprequest->vcplist[1].position_cd = request->position_cd
 SET vcprequest->vcplist[1].prsnl_id = request->prsnl_id
 SET vcprequest->vcplist[1].view_name = "PROBLEM_DX"
 SET vcprequest->vcplist[1].view_seq = 0
 SET vcprequest->vcplist[1].comp_name = "PROBLEM_DX"
 SET vcprequest->vcplist[1].comp_seq = 0
 SET stat = alterlist(pvrequest->pvlist,6)
 SET pvrequest->pvlist[1].person_id = 0
 SET pvrequest->pvlist[1].position_cd = request->position_cd
 SET pvrequest->pvlist[1].ppr_cd = 0
 SET pvrequest->pvlist[1].location_cd = 0
 SET pvrequest->pvlist[2].person_id = 0
 SET pvrequest->pvlist[2].position_cd = request->position_cd
 SET pvrequest->pvlist[2].ppr_cd = 0
 SET pvrequest->pvlist[2].location_cd = 0
 SET pvrequest->pvlist[3].person_id = 0
 SET pvrequest->pvlist[3].position_cd = request->position_cd
 SET pvrequest->pvlist[3].ppr_cd = 0
 SET pvrequest->pvlist[3].location_cd = 0
 SET pvrequest->pvlist[4].person_id = 0
 SET pvrequest->pvlist[4].position_cd = request->position_cd
 SET pvrequest->pvlist[4].ppr_cd = 0
 SET pvrequest->pvlist[4].location_cd = 0
 SET pvrequest->pvlist[5].person_id = 0
 SET pvrequest->pvlist[5].position_cd = request->position_cd
 SET pvrequest->pvlist[5].ppr_cd = 0
 SET pvrequest->pvlist[5].location_cd = 0
 SET pvrequest->pvlist[6].person_id = 0
 SET pvrequest->pvlist[6].position_cd = request->position_cd
 SET pvrequest->pvlist[6].ppr_cd = 0
 SET pvrequest->pvlist[6].location_cd = 0
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
  SET prob_menu_auth_value = "  "
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
     AND nvp.pvc_name="COMMAND_33463"
     AND nvp.active_ind=1
    DETAIL
     nvp_exists = 1, prob_menu_auth_value = nvp.pvc_value
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
      AND nvp.pvc_name="COMMAND_33463"
      AND nvp.active_ind=1
     DETAIL
      prob_menu_auth_value = nvp.pvc_value
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  SET diag_menu_auth_value = "  "
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
     AND nvp.pvc_name="COMMAND_32904"
     AND nvp.active_ind=1
    DETAIL
     nvp_exists = 1, diag_menu_auth_value = nvp.pvc_value
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
      AND nvp.pvc_name="COMMAND_32904"
      AND nvp.active_ind=1
     DETAIL
      diag_menu_auth_value = nvp.pvc_value
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  SET superbill_exists = 0
  CALL complete_dp(dummy_parm1)
  SET dprequest->dplist[1].view_name = "SUPERBILL"
  SET dprequest->dplist[1].comp_name = "SUPERBILL"
  SET dprequest->dplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
  IF ((dpreply->dplist[1].detail_prefs_id > 0))
   SET prob_cnt = 0
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
     AND nvp.pvc_name="DIAGNOSIS_TAB_NAME_*"
     AND nvp.pvc_value="Problems"
     AND nvp.active_ind=1
    DETAIL
     prob_cnt = (prob_cnt+ 1)
    WITH nocounter
   ;end select
   IF (prob_cnt > 0)
    SET superbill_exists = 1
   ENDIF
  ENDIF
  IF (superbill_exists=0)
   SET dprequest->dplist[1].position_cd = 0.0
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
   IF ((dpreply->dplist[1].detail_prefs_id > 0))
    SET prob_cnt = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
      AND nvp.pvc_name="DIAGNOSIS_TAB_NAME_*"
      AND nvp.pvc_value="Problems"
      AND nvp.active_ind=1
     DETAIL
      prob_cnt = (prob_cnt+ 1)
     WITH nocounter
    ;end select
    IF (prob_cnt > 0)
     SET superbill_exists = 1
    ENDIF
   ENDIF
  ENDIF
  SET viewprob_priv_allowed = 0
  SET viewprobnom_priv_allowed = 0
  SET viewdiagsel_priv_allowed = 0
  SET updprob_priv_allowed = 0
  SET updprobnom_priv_allowed = 0
  SET upddiagsel_priv_allowed = 0
  SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWPROB"
  SET pvrequest->pvlist[2].priv_cdf_meaning = "VIEWPROBNOM"
  SET pvrequest->pvlist[3].priv_cdf_meaning = "VIEWDIAGSEL"
  SET pvrequest->pvlist[4].priv_cdf_meaning = "UPDATEPROB"
  SET pvrequest->pvlist[5].priv_cdf_meaning = "UPDTPROBNOM"
  SET pvrequest->pvlist[6].priv_cdf_meaning = "UPDTDIAGSEL"
  SET pvrequest->pvlist[1].action_flag = "0"
  SET pvrequest->pvlist[2].action_flag = "0"
  SET pvrequest->pvlist[3].action_flag = "0"
  SET pvrequest->pvlist[4].action_flag = "0"
  SET pvrequest->pvlist[5].action_flag = "0"
  SET pvrequest->pvlist[6].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
  IF ((pvreply->pvlist[1].privilege_id=0))
   SET viewprob_priv_allowed = 1
  ENDIF
  IF ((pvreply->pvlist[2].privilege_id=0))
   SET viewprobnom_priv_allowed = 1
  ENDIF
  IF ((pvreply->pvlist[3].privilege_id=0))
   SET viewdiagsel_priv_allowed = 1
  ENDIF
  IF ((pvreply->pvlist[4].privilege_id=0))
   SET updprob_priv_allowed = 1
  ENDIF
  IF ((pvreply->pvlist[5].privilege_id=0))
   SET updprobnom_priv_allowed = 1
  ENDIF
  IF ((pvreply->pvlist[6].privilege_id=0))
   SET upddiagsel_priv_allowed = 1
  ENDIF
  SET task_cnt = size(request->task_list,5)
  IF (task_cnt=2)
   SET reply->status_data.status_list[1].status = "0"
   SET reply->status_data.status_list[2].status = "0"
   IF (comp_auth_exists=1
    AND prob_menu_auth_value="1"
    AND diag_menu_auth_value="1"
    AND superbill_exists=1
    AND viewprob_priv_allowed=1
    AND viewprobnom_priv_allowed=1
    AND viewdiagsel_priv_allowed=1
    AND updprob_priv_allowed=1
    AND updprobnom_priv_allowed=1
    AND upddiagsel_priv_allowed=1)
    SET reply->status_data.status_list[2].status = "1"
   ELSE
    IF (comp_auth_exists=1
     AND superbill_exists=1
     AND viewprob_priv_allowed=1
     AND viewprobnom_priv_allowed=1
     AND viewdiagsel_priv_allowed=1)
     SET reply->status_data.status_list[1].status = "1"
    ENDIF
   ENDIF
  ELSEIF ((request->task_list[1].task="VIEWPROBLEM"))
   SET reply->status_data.status_list[1].status = "0"
   IF (comp_auth_exists=1
    AND superbill_exists=1
    AND viewprob_priv_allowed=1
    AND viewprobnom_priv_allowed=1
    AND viewdiagsel_priv_allowed=1)
    SET reply->status_data.status_list[1].status = "1"
   ENDIF
  ELSEIF ((request->task_list[1].task="UPDPROBLEM"))
   SET reply->status_data.status_list[1].status = "0"
   IF (comp_auth_exists=1
    AND prob_menu_auth_value="1"
    AND diag_menu_auth_value="1"
    AND superbill_exists=1
    AND viewprob_priv_allowed=1
    AND viewprobnom_priv_allowed=1
    AND viewdiagsel_priv_allowed=1
    AND updprob_priv_allowed=1
    AND updprobnom_priv_allowed=1
    AND upddiagsel_priv_allowed=1)
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
     SET nvprequest->nvplist[1].pvc_value = "30"
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
  SET prob_nvp_exists = 0
  SET prob_menu_auth_value = " "
  SET diag_nvp_exists = 0
  SET diag_menu_auth_value = " "
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
     AND nvp.pvc_name IN ("COMMAND_33463", "COMMAND_32904")
     AND nvp.active_ind=1
    DETAIL
     IF (nvp.pvc_name="COMMAND_33463")
      prob_nvp_exists = 1, prob_menu_auth_value = nvp.pvc_value
     ELSEIF (nvp.pvc_name="COMMAND_32904")
      diag_nvp_exists = 1, diag_menu_auth_value = nvp.pvc_value
     ENDIF
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
  IF (upd_off_on_ind=1)
   IF (prob_nvp_exists > 0)
    IF (prob_menu_auth_value != "1")
     SET nvprequest->nvplist[1].pvc_name = "COMMAND_33463"
     SET nvprequest->nvplist[1].pvc_value = "1"
     SET nvprequest->nvplist[1].action_flag = "2"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ELSE
    SET nvprequest->nvplist[1].pvc_name = "COMMAND_33463"
    SET nvprequest->nvplist[1].pvc_value = "1"
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
   IF (diag_nvp_exists > 0)
    IF (diag_menu_auth_value != "1")
     SET nvprequest->nvplist[1].pvc_name = "COMMAND_32904"
     SET nvprequest->nvplist[1].pvc_value = "1"
     SET nvprequest->nvplist[1].action_flag = "2"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ELSE
    SET nvprequest->nvplist[1].pvc_name = "COMMAND_32904"
    SET nvprequest->nvplist[1].pvc_value = "1"
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ELSE
   IF (prob_nvp_exists > 0)
    IF (prob_menu_auth_value != "-2")
     SET nvprequest->nvplist[1].pvc_name = "COMMAND_33463"
     SET nvprequest->nvplist[1].pvc_value = "-2"
     SET nvprequest->nvplist[1].action_flag = "2"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ELSE
    SET nvprequest->nvplist[1].pvc_name = "COMMAND_33463"
    SET nvprequest->nvplist[1].pvc_value = "-2"
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
   IF (diag_nvp_exists > 0)
    IF (diag_menu_auth_value != "-2")
     SET nvprequest->nvplist[1].pvc_name = "COMMAND_32904"
     SET nvprequest->nvplist[1].pvc_value = "-2"
     SET nvprequest->nvplist[1].action_flag = "2"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ELSE
    SET nvprequest->nvplist[1].pvc_name = "COMMAND_32904"
    SET nvprequest->nvplist[1].pvc_value = "-2"
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ENDIF
  SET prob_row_cnt = 0
  SET diag_row_cnt = 0
  SET prob_encsumm_value = " "
  SET diag_encsumm_value = " "
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
     AND nvp.pvc_name="SHOW_PROBLEMS"
     AND nvp.active_ind=1
    DETAIL
     prob_row_cnt = (prob_row_cnt+ 1), prob_encsumm_value = nvp.pvc_value
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
     AND nvp.pvc_name="SHOW_DIAGNOSIS"
     AND nvp.active_ind=1
    DETAIL
     diag_row_cnt = (diag_row_cnt+ 1), diag_encsumm_value = nvp.pvc_value
    WITH nocounter
   ;end select
  ELSE
   SET dprequest->dplist[1].action_flag = "1"
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
  ENDIF
  IF (((view_off_on_ind=1) OR (upd_off_on_ind=1)) )
   CALL complete_prob_encsumm_dp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
   IF (prob_row_cnt > 0)
    IF (prob_encsumm_value != "1")
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
   CALL complete_diag_encsumm_dp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
   IF (diag_row_cnt > 0)
    IF (diag_encsumm_value != "1")
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
   CALL complete_prob_encsumm_dp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
   IF (prob_row_cnt > 0)
    IF (prob_encsumm_value != "0")
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
   CALL complete_diag_encsumm_dp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
   IF (diag_row_cnt > 0)
    IF (diag_encsumm_value != "0")
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
  SET tab_cnt = 0
  SET prob_tab_found = 0
  CALL complete_dp(dummy_parm1)
  SET dprequest->dplist[1].view_name = "SUPERBILL"
  SET dprequest->dplist[1].comp_name = "SUPERBILL"
  SET dprequest->dplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
  SET pos_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
  IF (pos_detail_prefs_id > 0)
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=pos_detail_prefs_id
     AND nvp.pvc_name="DIAGNOSIS_TAB_COUNT"
     AND nvp.active_ind=1
    DETAIL
     tab_cnt = cnvtint(nvp.pvc_value)
    WITH nocounter
   ;end select
   IF (tab_cnt > 0)
    FOR (t = 1 TO tab_cnt)
      SET tab_name = concat("DIAGNOSIS_TAB_NAME_",cnvtstring(t))
      SELECT INTO "NL:"
       FROM name_value_prefs nvp
       WHERE nvp.parent_entity_name="DETAIL_PREFS"
        AND nvp.parent_entity_id=pos_detail_prefs_id
        AND nvp.pvc_name=tab_name
        AND nvp.pvc_value="Problems"
        AND nvp.active_ind=1
       DETAIL
        prob_tab_found = 1
       WITH nocounter
      ;end select
      IF (prob_tab_found=1)
       SET prob_tab_nbr = t
       SET t = (tab_cnt+ 1)
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
  IF (((view_off_on_ind=1) OR (upd_off_on_ind=1)) )
   IF (prob_tab_found=0)
    IF (((pos_detail_prefs_id=0) OR (tab_cnt=0)) )
     IF (pos_detail_prefs_id=0)
      SET dprequest->dplist[1].action_flag = "1"
      SET trace = recpersist
      EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
      SET pos_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
     ENDIF
     CALL complete_dp(dummy_parm1)
     SET dprequest->dplist[1].position_cd = 0.0
     SET dprequest->dplist[1].view_name = "SUPERBILL"
     SET dprequest->dplist[1].comp_name = "SUPERBILL"
     SET dprequest->dplist[1].action_flag = "0"
     SET trace = recpersist
     EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
     SET app_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
     IF (app_detail_prefs_id=0)
      CALL complete_all_super_dp_nvp(dummy_parm1)
      SET nvprequest->nvplist[1].parent_entity_id = pos_detail_prefs_id
      SET nvprequest->nvplist[2].parent_entity_id = pos_detail_prefs_id
      SET nvprequest->nvplist[3].parent_entity_id = pos_detail_prefs_id
      SET nvprequest->nvplist[1].action_flag = "1"
      SET nvprequest->nvplist[2].action_flag = "1"
      SET nvprequest->nvplist[3].action_flag = "1"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ELSE
      SET app_tab_cnt = 0
      SELECT INTO "NL:"
       FROM name_value_prefs nvp
       WHERE nvp.parent_entity_name="DETAIL_PREFS"
        AND nvp.parent_entity_id=app_detail_prefs_id
        AND nvp.pvc_name="DIAGNOSIS_TAB_COUNT"
        AND nvp.active_ind=1
       DETAIL
        app_tab_cnt = cnvtint(nvp.pvc_value)
       WITH nocounter
      ;end select
      IF (app_tab_cnt=0)
       CALL complete_all_super_dp_nvp(dummy_parm1)
       SET nvprequest->nvplist[1].parent_entity_id = pos_detail_prefs_id
       SET nvprequest->nvplist[2].parent_entity_id = pos_detail_prefs_id
       SET nvprequest->nvplist[3].parent_entity_id = pos_detail_prefs_id
       SET nvprequest->nvplist[1].action_flag = "1"
       SET nvprequest->nvplist[2].action_flag = "1"
       SET nvprequest->nvplist[3].action_flag = "1"
       SET trace = recpersist
       EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
        nvpreply)
      ELSE
       SET pos_tab_cnt = 0
       FOR (t = 1 TO app_tab_cnt)
         SET tab_name = concat("DIAGNOSIS_TAB_NAME_",cnvtstring(t))
         SET tab_type = concat("DIAGNOSIS_TAB_TYPE_",cnvtstring(t))
         SELECT INTO "NL:"
          FROM name_value_prefs nvp1,
           name_value_prefs nvp2
          PLAN (nvp1
           WHERE nvp1.parent_entity_name="DETAIL_PREFS"
            AND nvp1.parent_entity_id=app_detail_prefs_id
            AND nvp1.pvc_name=tab_name
            AND nvp1.active_ind=1)
           JOIN (nvp2
           WHERE nvp2.parent_entity_name="DETAIL_PREFS"
            AND nvp2.parent_entity_id=nvp1.parent_entity_id
            AND nvp2.pvc_name=tab_type
            AND nvp2.active_ind=1)
          DETAIL
           pos_tab_cnt = (pos_tab_cnt+ 1), stat = alterlist(temprec->tlist,pos_tab_cnt), temprec->
           tlist[pos_tab_cnt].temp_tab_name = nvp1.pvc_value,
           temprec->tlist[pos_tab_cnt].temp_tab_type = nvp2.pvc_value
          WITH nocounter
         ;end select
       ENDFOR
       SET stat = alterlist(nvprequest->nvplist,2)
       SET stat = alterlist(nvpreply->nvplist,2)
       SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
       SET nvprequest->nvplist[1].parent_entity_id = pos_detail_prefs_id
       SET nvprequest->nvplist[1].action_flag = "1"
       SET nvprequest->nvplist[2].parent_entity_name = "DETAIL_PREFS"
       SET nvprequest->nvplist[2].parent_entity_id = pos_detail_prefs_id
       SET nvprequest->nvplist[2].action_flag = "1"
       SET prob_row_created = 0
       FOR (t = 1 TO pos_tab_cnt)
         IF ((temprec->tlist[t].temp_tab_name="Problems"))
          SET prob_row_created = 1
         ENDIF
         SET tab_name = concat("DIAGNOSIS_TAB_NAME_",cnvtstring(t))
         SET nvprequest->nvplist[1].pvc_name = tab_name
         SET nvprequest->nvplist[1].pvc_value = temprec->tlist[t].temp_tab_name
         SET tab_type = concat("DIAGNOSIS_TAB_TYPE_",cnvtstring(t))
         SET nvprequest->nvplist[2].pvc_name = tab_type
         SET nvprequest->nvplist[2].pvc_value = temprec->tlist[t].temp_tab_type
         SET trace = recpersist
         EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
          nvpreply)
         IF ((temprec->tlist[t].temp_tab_type="1"))
          CALL copy_type_5_rows(t)
         ENDIF
       ENDFOR
       IF (prob_row_created=0)
        SET pos_tab_cnt = (pos_tab_cnt+ 1)
        SET tab_name = concat("DIAGNOSIS_TAB_NAME_",cnvtstring(pos_tab_cnt))
        SET nvprequest->nvplist[1].pvc_name = tab_name
        SET nvprequest->nvplist[1].pvc_value = "Problems"
        SET tab_type = concat("DIAGNOSIS_TAB_TYPE_",cnvtstring(pos_tab_cnt))
        SET nvprequest->nvplist[2].pvc_name = tab_type
        SET nvprequest->nvplist[2].pvc_value = "9"
        SET trace = recpersist
        EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
         nvpreply)
       ENDIF
       SET stat = alterlist(nvprequest->nvplist,1)
       SET stat = alterlist(nvpreply->nvplist,1)
       SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
       SET nvprequest->nvplist[1].parent_entity_id = pos_detail_prefs_id
       SET nvprequest->nvplist[1].pvc_name = "DIAGNOSIS_TAB_COUNT"
       SET nvprequest->nvplist[1].pvc_value = cnvtstring(pos_tab_cnt)
       SET nvprequest->nvplist[1].action_flag = "1"
       SET trace = recpersist
       EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
        nvpreply)
      ENDIF
     ENDIF
    ELSE
     SET tab_name = concat("DIAGNOSIS_TAB_NAME_",cnvtstring((tab_cnt+ 1)))
     SET row_exists = 0
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=pos_detail_prefs_id
       AND nvp.pvc_name=tab_name
       AND nvp.active_ind=1
      DETAIL
       row_exists = 1
      WITH nocounter
     ;end select
     IF (row_exists=1)
      UPDATE  FROM name_value_prefs nvp
       SET nvp.pvc_value = "Problems", nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->
        updt_id,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
        .updt_applctx = reqinfo->updt_applctx
       WHERE nvp.parent_entity_name="DETAIL_PREFS"
        AND nvp.parent_entity_id=pos_detail_prefs_id
        AND nvp.pvc_name=tab_name
       WITH nocounter
      ;end update
     ELSE
      SET stat = alterlist(nvprequest->nvplist,1)
      SET stat = alterlist(nvpreply->nvplist,1)
      SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
      SET nvprequest->nvplist[1].parent_entity_id = pos_detail_prefs_id
      SET nvprequest->nvplist[1].pvc_name = tab_name
      SET nvprequest->nvplist[1].pvc_value = "Problems"
      SET nvprequest->nvplist[1].action_flag = "1"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     SET tab_name = concat("DIAGNOSIS_TAB_TYPE_",cnvtstring((tab_cnt+ 1)))
     SET row_exists = 0
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=pos_detail_prefs_id
       AND nvp.pvc_name=tab_name
       AND nvp.active_ind=1
      DETAIL
       row_exists = 1
      WITH nocounter
     ;end select
     IF (row_exists=1)
      UPDATE  FROM name_value_prefs nvp
       SET nvp.pvc_value = "9", nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->updt_id,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
        .updt_applctx = reqinfo->updt_applctx
       WHERE nvp.parent_entity_name="DETAIL_PREFS"
        AND nvp.parent_entity_id=pos_detail_prefs_id
        AND nvp.pvc_name=tab_name
       WITH nocounter
      ;end update
     ELSE
      SET stat = alterlist(nvprequest->nvplist,1)
      SET stat = alterlist(nvpreply->nvplist,1)
      SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
      SET nvprequest->nvplist[1].parent_entity_id = pos_detail_prefs_id
      SET nvprequest->nvplist[1].pvc_name = tab_name
      SET nvprequest->nvplist[1].pvc_value = "9"
      SET nvprequest->nvplist[1].action_flag = "1"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     SET row_exists = 0
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=pos_detail_prefs_id
       AND nvp.pvc_name="DIAGNOSIS_TAB_COUNT"
       AND nvp.active_ind=1
      DETAIL
       row_exists = 1
      WITH nocounter
     ;end select
     IF (row_exists=1)
      UPDATE  FROM name_value_prefs nvp
       SET nvp.pvc_value = cnvtstring((tab_cnt+ 1)), nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id =
        reqinfo->updt_id,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
        .updt_applctx = reqinfo->updt_applctx
       WHERE nvp.parent_entity_name="DETAIL_PREFS"
        AND nvp.parent_entity_id=pos_detail_prefs_id
        AND nvp.pvc_name="DIAGNOSIS_TAB_COUNT"
       WITH nocounter
      ;end update
     ELSE
      SET stat = alterlist(nvprequest->nvplist,1)
      SET stat = alterlist(nvpreply->nvplist,1)
      SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
      SET nvprequest->nvplist[1].parent_entity_id = pos_detail_prefs_id
      SET nvprequest->nvplist[1].pvc_name = "DIAGNOSIS_TAB_COUNT"
      SET nvprequest->nvplist[1].pvc_value = "1"
      SET nvprequest->nvplist[1].action_flag = "1"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
    ENDIF
   ENDIF
  ELSE
   IF (prob_tab_found=1)
    IF (tab_cnt != prob_tab_nbr)
     SET tab_name = concat("DIAGNOSIS_TAB_NAME_",cnvtstring(prob_tab_nbr))
     DELETE  FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=pos_detail_prefs_id
       AND nvp.pvc_name=tab_name
       AND nvp.pvc_value="Problems"
      WITH nocounter
     ;end delete
     SET tab_name = concat("DIAGNOSIS_TAB_TYPE_",cnvtstring(prob_tab_nbr))
     DELETE  FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=pos_detail_prefs_id
       AND nvp.pvc_name=tab_name
       AND nvp.pvc_value="9"
      WITH nocounter
     ;end delete
     SET old_tab_nbr = (prob_tab_nbr+ 1)
     FOR (old_tab_nbr = old_tab_nbr TO tab_cnt)
       SET nvp_id = 0.0
       SET tab_name = concat("DIAGNOSIS_TAB_NAME_",cnvtstring(old_tab_nbr))
       SELECT INTO "NL:"
        FROM name_value_prefs nvp
        WHERE nvp.parent_entity_name="DETAIL_PREFS"
         AND nvp.parent_entity_id=pos_detail_prefs_id
         AND nvp.pvc_name=tab_name
         AND nvp.active_ind=1
        DETAIL
         nvp_id = nvp.name_value_prefs_id
        WITH nocounter
       ;end select
       SET tab_name = concat("DIAGNOSIS_TAB_NAME_",cnvtstring((old_tab_nbr - 1)))
       UPDATE  FROM name_value_prefs nvp
        SET nvp.pvc_name = tab_name, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->updt_id,
         nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
         .updt_applctx = reqinfo->updt_applctx
        WHERE nvp.name_value_prefs_id=nvp_id
        WITH nocounter
       ;end update
       SET nvp_id = 0.0
       SET tab_name = concat("DIAGNOSIS_TAB_TYPE_",cnvtstring(old_tab_nbr))
       SELECT INTO "NL:"
        FROM name_value_prefs nvp
        WHERE nvp.parent_entity_name="DETAIL_PREFS"
         AND nvp.parent_entity_id=pos_detail_prefs_id
         AND nvp.pvc_name=tab_name
         AND nvp.active_ind=1
        DETAIL
         nvp_id = nvp.name_value_prefs_id
        WITH nocounter
       ;end select
       SET tab_name = concat("DIAGNOSIS_TAB_TYPE_",cnvtstring((old_tab_nbr - 1)))
       UPDATE  FROM name_value_prefs nvp
        SET nvp.pvc_name = tab_name, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->updt_id,
         nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
         .updt_applctx = reqinfo->updt_applctx
        WHERE nvp.name_value_prefs_id=nvp_id
        WITH nocounter
       ;end update
     ENDFOR
    ENDIF
    UPDATE  FROM name_value_prefs nvp
     SET nvp.pvc_value = cnvtstring((tab_cnt - 1)), nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id =
      reqinfo->updt_id,
      nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
      .updt_applctx = reqinfo->updt_applctx
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=pos_detail_prefs_id
      AND nvp.pvc_name="DIAGNOSIS_TAB_COUNT"
     WITH nocounter
    ;end update
   ELSE
    IF (((pos_detail_prefs_id=0) OR (tab_cnt=0)) )
     CALL complete_dp(dummy_parm1)
     SET dprequest->dplist[1].position_cd = 0.0
     SET dprequest->dplist[1].view_name = "SUPERBILL"
     SET dprequest->dplist[1].comp_name = "SUPERBILL"
     SET dprequest->dplist[1].action_flag = "0"
     SET trace = recpersist
     EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
     SET app_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
     IF (app_detail_prefs_id > 0)
      IF (pos_detail_prefs_id=0)
       CALL complete_dp(dummy_parm1)
       SET dprequest->dplist[1].view_name = "SUPERBILL"
       SET dprequest->dplist[1].comp_name = "SUPERBILL"
       SET dprequest->dplist[1].action_flag = "1"
       SET trace = recpersist
       EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
       SET pos_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
      ENDIF
      SET app_tab_cnt = 0
      SELECT INTO "NL:"
       FROM name_value_prefs nvp
       WHERE nvp.parent_entity_name="DETAIL_PREFS"
        AND nvp.parent_entity_id=app_detail_prefs_id
        AND nvp.pvc_name="DIAGNOSIS_TAB_COUNT"
        AND nvp.active_ind=1
       DETAIL
        app_tab_cnt = cnvtint(nvp.pvc_value)
       WITH nocounter
      ;end select
      IF (app_tab_cnt > 0)
       SET pos_tab_cnt = 0
       FOR (t = 1 TO app_tab_cnt)
         SET tab_name = concat("DIAGNOSIS_TAB_NAME_",cnvtstring(t))
         SET tab_type = concat("DIAGNOSIS_TAB_TYPE_",cnvtstring(t))
         SELECT INTO "NL:"
          FROM name_value_prefs nvp1,
           name_value_prefs nvp2
          PLAN (nvp1
           WHERE nvp1.parent_entity_name="DETAIL_PREFS"
            AND nvp1.parent_entity_id=app_detail_prefs_id
            AND nvp1.pvc_name=tab_name
            AND nvp1.pvc_value != "Problems"
            AND nvp1.active_ind=1)
           JOIN (nvp2
           WHERE nvp2.parent_entity_name="DETAIL_PREFS"
            AND nvp2.parent_entity_id=nvp1.parent_entity_id
            AND nvp2.pvc_name=tab_type
            AND nvp2.active_ind=1)
          DETAIL
           pos_tab_cnt = (pos_tab_cnt+ 1), stat = alterlist(temprec->tlist,pos_tab_cnt), temprec->
           tlist[pos_tab_cnt].temp_tab_name = nvp1.pvc_value,
           temprec->tlist[pos_tab_cnt].temp_tab_type = nvp2.pvc_value
          WITH nocounter
         ;end select
       ENDFOR
       SET stat = alterlist(nvprequest->nvplist,2)
       SET stat = alterlist(nvpreply->nvplist,2)
       SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
       SET nvprequest->nvplist[1].parent_entity_id = pos_detail_prefs_id
       SET nvprequest->nvplist[1].action_flag = "1"
       SET nvprequest->nvplist[2].parent_entity_name = "DETAIL_PREFS"
       SET nvprequest->nvplist[2].parent_entity_id = pos_detail_prefs_id
       SET nvprequest->nvplist[2].action_flag = "1"
       FOR (t = 1 TO pos_tab_cnt)
         SET tab_name = concat("DIAGNOSIS_TAB_NAME_",cnvtstring(t))
         SET nvprequest->nvplist[1].pvc_name = tab_name
         SET nvprequest->nvplist[1].pvc_value = temprec->tlist[t].temp_tab_name
         SET tab_type = concat("DIAGNOSIS_TAB_TYPE_",cnvtstring(t))
         SET nvprequest->nvplist[2].pvc_name = tab_type
         SET nvprequest->nvplist[2].pvc_value = temprec->tlist[t].temp_tab_type
         SET trace = recpersist
         EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
          nvpreply)
         IF ((temprec->tlist[t].temp_tab_type="1"))
          CALL copy_type_5_rows(t)
         ENDIF
       ENDFOR
       SET stat = alterlist(nvprequest->nvplist,1)
       SET stat = alterlist(nvpreply->nvplist,1)
       SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
       SET nvprequest->nvplist[1].parent_entity_id = pos_detail_prefs_id
       SET nvprequest->nvplist[1].pvc_name = "DIAGNOSIS_TAB_COUNT"
       SET nvprequest->nvplist[1].pvc_value = cnvtstring(pos_tab_cnt)
       SET nvprequest->nvplist[1].action_flag = "1"
       SET trace = recpersist
       EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
        nvpreply)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  SET viewprob_priv_allowed = 0
  SET viewprobnom_priv_allowed = 0
  SET viewdiagsel_priv_allowed = 0
  SET updprob_priv_allowed = 0
  SET updprobnom_priv_allowed = 0
  SET upddiagsel_priv_allowed = 0
  SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWPROB"
  SET pvrequest->pvlist[2].priv_cdf_meaning = "VIEWPROBNOM"
  SET pvrequest->pvlist[3].priv_cdf_meaning = "VIEWDIAGSEL"
  SET pvrequest->pvlist[4].priv_cdf_meaning = "UPDATEPROB"
  SET pvrequest->pvlist[5].priv_cdf_meaning = "UPDTPROBNOM"
  SET pvrequest->pvlist[6].priv_cdf_meaning = "UPDTDIAGSEL"
  SET pvrequest->pvlist[1].action_flag = "0"
  SET pvrequest->pvlist[2].action_flag = "0"
  SET pvrequest->pvlist[3].action_flag = "0"
  SET pvrequest->pvlist[4].action_flag = "0"
  SET pvrequest->pvlist[5].action_flag = "0"
  SET pvrequest->pvlist[6].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
  IF ((pvreply->pvlist[1].privilege_id=0))
   SET viewprob_priv_allowed = 1
  ENDIF
  IF ((pvreply->pvlist[2].privilege_id=0))
   SET viewprobnom_priv_allowed = 1
  ENDIF
  IF ((pvreply->pvlist[3].privilege_id=0))
   SET viewdiagsel_priv_allowed = 1
  ENDIF
  IF ((pvreply->pvlist[4].privilege_id=0))
   SET updprob_priv_allowed = 1
  ENDIF
  IF ((pvreply->pvlist[5].privilege_id=0))
   SET updprobnom_priv_allowed = 1
  ENDIF
  IF ((pvreply->pvlist[6].privilege_id=0))
   SET upddiagsel_priv_allowed = 1
  ENDIF
  SET stat = alterlist(pvrequest->pvlist,1)
  SET stat = alterlist(pvreply->pvlist,1)
  IF (upd_off_on_ind=1)
   IF (viewprob_priv_allowed=0)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWPROB"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET viewprob_priv_allowed = 1
   ENDIF
   IF (viewprobnom_priv_allowed=0)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWPROBNOM"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET viewprobnom_priv_allowed = 1
   ENDIF
   IF (viewdiagsel_priv_allowed=0)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWDIAGSEL"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET viewdiagsel_priv_allowed = 1
   ENDIF
   IF (updprob_priv_allowed=0)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDATEPROB"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET updprob_priv_allowed = 1
   ENDIF
   IF (updprobnom_priv_allowed=0)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDTPROBNOM"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET updprobnom_priv_allowed = 1
   ENDIF
   IF (upddiagsel_priv_allowed=0)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDTDIAGSEL"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET upddiagsel_priv_allowed = 1
   ENDIF
  ELSEIF (view_off_on_ind=1)
   IF (viewprob_priv_allowed=0)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWPROB"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET viewprob_priv_allowed = 1
   ENDIF
   IF (viewprobnom_priv_allowed=0)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWPROBNOM"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET viewprobnom_priv_allowed = 1
   ENDIF
   IF (viewdiagsel_priv_allowed=0)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWDIAGSEL"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET viewdiagsel_priv_allowed = 1
   ENDIF
   IF (updprob_priv_allowed=1)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDATEPROB"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDATEPROB"
    SET pvrequest->pvlist[1].priv_value = "NO"
    SET pvrequest->pvlist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET updprob_priv_allowed = 0
   ENDIF
   IF (updprobnom_priv_allowed=1)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDTPROBNOM"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDTPROBNOM"
    SET pvrequest->pvlist[1].priv_value = "NO"
    SET pvrequest->pvlist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET updprobnom_priv_allowed = 0
   ENDIF
   IF (upddiagsel_priv_allowed=1)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDTDIAGSEL"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDTDIAGSEL"
    SET pvrequest->pvlist[1].priv_value = "NO"
    SET pvrequest->pvlist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET upddiagsel_priv_allowed = 0
   ENDIF
  ELSE
   IF (viewprob_priv_allowed=1)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWPROB"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWPROB"
    SET pvrequest->pvlist[1].priv_value = "NO"
    SET pvrequest->pvlist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET viewprob_priv_allowed = 0
   ENDIF
   IF (viewprobnom_priv_allowed=1)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWPROBNOM"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWPROBNOM"
    SET pvrequest->pvlist[1].priv_value = "NO"
    SET pvrequest->pvlist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET viewprobnom_priv_allowed = 0
   ENDIF
   IF (viewdiagsel_priv_allowed=1)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWDIAGSEL"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWDIAGSEL"
    SET pvrequest->pvlist[1].priv_value = "NO"
    SET pvrequest->pvlist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET viewdiagsel_priv_allowed = 0
   ENDIF
   IF (updprob_priv_allowed=1)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDATEPROB"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDATEPROB"
    SET pvrequest->pvlist[1].priv_value = "NO"
    SET pvrequest->pvlist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET updprob_priv_allowed = 0
   ENDIF
   IF (updprobnom_priv_allowed=1)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDTPROBNOM"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDTPROBNOM"
    SET pvrequest->pvlist[1].priv_value = "NO"
    SET pvrequest->pvlist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET updprobnom_priv_allowed = 0
   ENDIF
   IF (upddiagsel_priv_allowed=1)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDTDIAGSEL"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "UPDTDIAGSEL"
    SET pvrequest->pvlist[1].priv_value = "NO"
    SET pvrequest->pvlist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET upddiagsel_priv_allowed = 0
   ENDIF
  ENDIF
 ENDIF
 GO TO exitscript
 SUBROUTINE complete_vp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,2)
   SET stat = alterlist(nvpreply->nvplist,2)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "VIEW_CAPTION"
   SET nvprequest->nvplist[1].pvc_value = "Problems and Diagnoses"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "DISPLAY_SEQ"
   SET nvprequest->nvplist[2].pvc_value = "30"
 END ;Subroutine
 SUBROUTINE complete_vcp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,5)
   SET stat = alterlist(nvpreply->nvplist,5)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "COMP_DLLNAME"
   SET nvprequest->nvplist[1].pvc_value = "KiaProbDx.dll"
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
 SUBROUTINE complete_prob_encsumm_dp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,1)
   SET stat = alterlist(nvpreply->nvplist,1)
   SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "SHOW_PROBLEMS"
   SET nvprequest->nvplist[1].pvc_value = "1"
 END ;Subroutine
 SUBROUTINE complete_diag_encsumm_dp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,1)
   SET stat = alterlist(nvpreply->nvplist,1)
   SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "SHOW_DIAGNOSIS"
   SET nvprequest->nvplist[1].pvc_value = "1"
 END ;Subroutine
 SUBROUTINE complete_all_super_dp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,3)
   SET stat = alterlist(nvpreply->nvplist,3)
   SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "DIAGNOSIS_TAB_COUNT"
   SET nvprequest->nvplist[1].pvc_value = "1"
   SET nvprequest->nvplist[2].parent_entity_name = "DETAIL_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "DIAGNOSIS_TAB_NAME_1"
   SET nvprequest->nvplist[2].pvc_value = "Problems"
   SET nvprequest->nvplist[3].parent_entity_name = "DETAIL_PREFS"
   SET nvprequest->nvplist[3].pvc_name = "DIAGNOSIS_TAB_TYPE_1"
   SET nvprequest->nvplist[3].pvc_value = "9"
 END ;Subroutine
 SUBROUTINE copy_type_5_rows(y)
   SET def_id_exists = 0
   SET def_par_id_exists = 0
   SET count_exists = 0
   SET def_id_val = fillstring(256," ")
   SET def_par_id_val = fillstring(256," ")
   SET count_val = fillstring(256," ")
   SET def_id_name = concat("DIAGNOSIS_TAB_DEF_ID_",cnvtstring(y))
   SET def_par_id_name = concat("DIAGNOSIS_TAB_DEF_PAR_ID_",cnvtstring(y))
   SET count_name = concat("DIAGNOSIS_TAB_COUNT_",cnvtstring(y))
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=app_detail_prefs_id
     AND nvp.pvc_name IN (def_id_name, def_par_id_name, count_name)
     AND nvp.active_ind=1
    DETAIL
     IF (nvp.pvc_name=def_id_name)
      def_id_exists = 1, def_id_val = nvp.pvc_value
     ELSEIF (nvp.pvc_name=def_par_id_name)
      def_par_id_exists = 1, def_par_id_val = nvp.pvc_value
     ELSEIF (nvp.pvc_name=count_name)
      count_exists = 1, count_val = nvp.pvc_value
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(nvprequest->nvplist,1)
   SET stat = alterlist(nvpreply->nvplist,1)
   SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
   SET nvprequest->nvplist[1].parent_entity_id = pos_detail_prefs_id
   SET nvprequest->nvplist[1].action_flag = "1"
   IF (def_id_exists=1)
    SET nvprequest->nvplist[1].pvc_name = def_id_name
    SET nvprequest->nvplist[1].pvc_value = def_id_val
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
   IF (def_par_id_exists=1)
    SET nvprequest->nvplist[1].pvc_name = def_par_id_name
    SET nvprequest->nvplist[1].pvc_value = def_par_id_val
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
   IF (count_exists=1)
    SET nvprequest->nvplist[1].pvc_name = count_name
    SET nvprequest->nvplist[1].pvc_value = count_val
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
   IF (count_exists=1
    AND cnvtint(count_val) > 0)
    SET sub_cnt = 0
    FOR (x = 1 TO cnvtint(count_val))
     SET tab_name = concat("DIAGNOSIS_TAB_ID_",trim(cnvtstring(y)),"_",trim(cnvtstring(x)))
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=app_detail_prefs_id
       AND nvp.pvc_name=tab_name
       AND nvp.active_ind=1
      DETAIL
       sub_cnt = (sub_cnt+ 1), stat = alterlist(temprec2->tlist2,sub_cnt), temprec2->tlist2[sub_cnt].
       temp_pvc_name = nvp.pvc_name,
       temprec2->tlist2[sub_cnt].temp_pvc_value = nvp.pvc_value
      WITH nocounter
     ;end select
    ENDFOR
    FOR (xx = 1 TO sub_cnt)
      SET nvprequest->nvplist[1].pvc_name = temprec2->tlist2[xx].temp_pvc_name
      SET nvprequest->nvplist[1].pvc_value = temprec2->tlist2[xx].temp_pvc_value
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
    ENDFOR
   ENDIF
   SET stat = alterlist(nvprequest->nvplist,2)
   SET stat = alterlist(nvpreply->nvplist,2)
   SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
   SET nvprequest->nvplist[1].parent_entity_id = pos_detail_prefs_id
   SET nvprequest->nvplist[1].action_flag = "1"
   SET nvprequest->nvplist[2].parent_entity_name = "DETAIL_PREFS"
   SET nvprequest->nvplist[2].parent_entity_id = pos_detail_prefs_id
   SET nvprequest->nvplist[2].action_flag = "1"
 END ;Subroutine
#exitscript
END GO

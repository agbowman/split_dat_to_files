CREATE PROGRAM bed_get_ens_tasks_inbox:dba
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
 RECORD pnrequest(
   1 poslist[1]
     2 position_cd = f8
     2 plist[*]
       3 person_id = f8
       3 action_flag = i2
     2 update_prsnl_flag = i2
 )
 FREE SET pnreply
 RECORD pnreply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(reply->status_data.status_list,15)
 SET stat = alterlist(vprequest->vplist,1)
 SET stat = alterlist(vpreply->vplist,1)
 SET vprequest->vplist[1].application_number = request->application_number
 SET vprequest->vplist[1].position_cd = request->position_cd
 SET vprequest->vplist[1].prsnl_id = request->prsnl_id
 SET vprequest->vplist[1].frame_type = "ORG"
 SET vprequest->vplist[1].view_name = "INBOX"
 SET vprequest->vplist[1].view_seq = 0
 SET stat = alterlist(vcprequest->vcplist,1)
 SET stat = alterlist(vcpreply->vcplist,1)
 SET vcprequest->vcplist[1].application_number = request->application_number
 SET vcprequest->vcplist[1].position_cd = request->position_cd
 SET vcprequest->vcplist[1].prsnl_id = request->prsnl_id
 SET vcprequest->vcplist[1].view_name = "INBOX"
 SET vcprequest->vcplist[1].view_seq = 0
 SET vcprequest->vcplist[1].comp_name = "INBOX"
 SET vcprequest->vcplist[1].comp_seq = 0
 SET stat = alterlist(dprequest->dplist,1)
 SET stat = alterlist(dpreply->dplist,1)
 SET dprequest->dplist[1].application_number = request->application_number
 SET dprequest->dplist[1].position_cd = request->position_cd
 SET dprequest->dplist[1].prsnl_id = request->prsnl_id
 SET dprequest->dplist[1].person_id = 0.0
 SET dprequest->dplist[1].view_seq = 0
 SET dprequest->dplist[1].comp_seq = 0
 SET stat = alterlist(aprequest->aplist,1)
 SET stat = alterlist(apreply->aplist,1)
 SET aprequest->aplist[1].application_number = request->application_number
 SET aprequest->aplist[1].position_cd = request->position_cd
 SET aprequest->aplist[1].prsnl_id = request->prsnl_id
 SET dummy_parm1 = 0
 SET dummy_parm2 = 0
 SET psn_detail_prefs_id = 0.0
 SET row_cnt = 0
 SET row_nbr = 0
 SET row_found = 0
 IF ((request->action="0"))
  SET dprequest->dplist[1].view_name = "INBOX"
  SET dprequest->dplist[1].comp_name = "INBOX"
  SET dprequest->dplist[1].action_flag = "0"
  SET psn_detail_prefs_id = 0.0
  SET trace = recpersist
  EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
  SET psn_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
  SET app_detail_prefs_id = 0.0
  SET dprequest->dplist[1].position_cd = 0.0
  SET trace = recpersist
  EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
  SET app_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
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
  SET lbfolder_cnt = 0
  IF (psn_detail_prefs_id > 0)
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_LBFOLDER_CNT"
     AND nvp.active_ind=1
    DETAIL
     lbfolder_cnt = cnvtint(nvp.pvc_value)
    WITH nocounter
   ;end select
  ENDIF
  SET lbfolder_cnt = (lbfolder_cnt - 1)
  SET sritem_cnt = 0
  IF (psn_detail_prefs_id > 0)
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_SRITEM_CNT"
     AND nvp.active_ind=1
    DETAIL
     sritem_cnt = cnvtint(nvp.pvc_value)
    WITH nocounter
   ;end select
  ENDIF
  SET sritem_cnt = (sritem_cnt - 1)
  SET coitem_cnt = 0
  IF (psn_detail_prefs_id > 0)
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_COITEM_CNT"
     AND nvp.active_ind=1
    DETAIL
     coitem_cnt = cnvtint(nvp.pvc_value)
    WITH nocounter
   ;end select
  ENDIF
  SET coitem_cnt = (coitem_cnt - 1)
  SET rsltend_lb_exists = 0
  IF (psn_detail_prefs_id > 0)
   SET pref_cnt = 0
   SET item_nbr = "  "
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_LBFOLDER*"
     AND nvp.pvc_name != "INBOX_LBFOLDER_CNT"
     AND nvp.pvc_value="4"
     AND nvp.active_ind=1
    DETAIL
     pref_cnt = (pref_cnt+ 1), item_nbr = substring(15,2,nvp.pvc_name)
    WITH nocounter
   ;end select
   IF (pref_cnt > 0
    AND ((cnvtint(item_nbr)=lbfolder_cnt) OR (cnvtint(item_nbr) < lbfolder_cnt)) )
    SET rsltend_lb_exists = 1
   ENDIF
  ENDIF
  SET signrev_lb_exists = 0
  IF (psn_detail_prefs_id > 0)
   SET pref_cnt = 0
   SET item_nbr = "  "
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_LBFOLDER*"
     AND nvp.pvc_name != "INBOX_LBFOLDER_CNT"
     AND nvp.pvc_value="3"
     AND nvp.active_ind=1
    DETAIL
     pref_cnt = (pref_cnt+ 1), item_nbr = substring(15,2,nvp.pvc_name)
    WITH nocounter
   ;end select
   IF (pref_cnt > 0
    AND ((cnvtint(item_nbr)=lbfolder_cnt) OR (cnvtint(item_nbr) < lbfolder_cnt)) )
    SET signrev_lb_exists = 1
   ENDIF
  ENDIF
  SET doctosign_sr_exists = 0
  IF (psn_detail_prefs_id > 0)
   SET pref_cnt = 0
   SET item_nbr = "  "
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_SRITEM*"
     AND nvp.pvc_name != "INBOX_SRITEM_CNT"
     AND nvp.pvc_value="2"
     AND nvp.active_ind=1
    DETAIL
     pref_cnt = (pref_cnt+ 1), item_nbr = substring(13,2,nvp.pvc_name)
    WITH nocounter
   ;end select
   IF (pref_cnt > 0
    AND ((cnvtint(item_nbr)=sritem_cnt) OR (cnvtint(item_nbr) < sritem_cnt)) )
    SET row_name = concat("INBOX_SRFOLDER",item_nbr)
    SET pref_cnt = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name=row_name
      AND nvp.pvc_value="1"
      AND nvp.active_ind=1
     DETAIL
      pref_cnt = (pref_cnt+ 1)
     WITH nocounter
    ;end select
    IF (pref_cnt > 0)
     SET doctosign_sr_exists = 1
    ENDIF
   ENDIF
  ENDIF
  SET fwddoctosign_sr_exists = 0
  IF (psn_detail_prefs_id > 0)
   SET pref_cnt = 0
   SET item_nbr = "  "
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_SRITEM*"
     AND nvp.pvc_name != "INBOX_SRITEM_CNT"
     AND nvp.pvc_value="3"
     AND nvp.active_ind=1
    DETAIL
     pref_cnt = (pref_cnt+ 1), item_nbr = substring(13,2,nvp.pvc_name)
    WITH nocounter
   ;end select
   IF (pref_cnt > 0
    AND ((cnvtint(item_nbr)=sritem_cnt) OR (cnvtint(item_nbr) < sritem_cnt)) )
    SET row_name = concat("INBOX_SRFOLDER",item_nbr)
    SET pref_cnt = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name=row_name
      AND nvp.pvc_value="1"
      AND nvp.active_ind=1
     DETAIL
      pref_cnt = (pref_cnt+ 1)
     WITH nocounter
    ;end select
    IF (pref_cnt > 0)
     SET fwddoctosign_sr_exists = 1
    ENDIF
   ENDIF
  ENDIF
  SET fwdrsltosign_sr_exists = 0
  IF (psn_detail_prefs_id > 0)
   SET pref_cnt = 0
   SET item_nbr = "  "
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_SRITEM*"
     AND nvp.pvc_name != "INBOX_SRITEM_CNT"
     AND nvp.pvc_value="7"
     AND nvp.active_ind=1
    DETAIL
     pref_cnt = (pref_cnt+ 1), item_nbr = substring(13,2,nvp.pvc_name)
    WITH nocounter
   ;end select
   IF (pref_cnt > 0
    AND ((cnvtint(item_nbr)=sritem_cnt) OR (cnvtint(item_nbr) < sritem_cnt)) )
    SET row_name = concat("INBOX_SRFOLDER",item_nbr)
    SET pref_cnt = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name=row_name
      AND nvp.pvc_value="13"
      AND nvp.active_ind=1
     DETAIL
      pref_cnt = (pref_cnt+ 1)
     WITH nocounter
    ;end select
    IF (pref_cnt > 0)
     SET fwdrsltosign_sr_exists = 1
    ENDIF
   ENDIF
  ENDIF
  SET fwdrsltorev_sr_exists = 0
  IF (psn_detail_prefs_id > 0)
   SET pref_cnt = 0
   SET item_nbr = "  "
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_SRITEM*"
     AND nvp.pvc_name != "INBOX_SRITEM_CNT"
     AND nvp.pvc_value="8"
     AND nvp.active_ind=1
    DETAIL
     pref_cnt = (pref_cnt+ 1), item_nbr = substring(13,2,nvp.pvc_name)
    WITH nocounter
   ;end select
   IF (pref_cnt > 0
    AND ((cnvtint(item_nbr)=sritem_cnt) OR (cnvtint(item_nbr) < sritem_cnt)) )
    SET row_name = concat("INBOX_SRFOLDER",item_nbr)
    SET pref_cnt = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name=row_name
      AND nvp.pvc_value="13"
      AND nvp.active_ind=1
     DETAIL
      pref_cnt = (pref_cnt+ 1)
     WITH nocounter
    ;end select
    IF (pref_cnt > 0)
     SET fwdrsltorev_sr_exists = 1
    ENDIF
   ENDIF
  ENDIF
  SET fwdind_pref_exists = 0
  SET fwdtopt_pref_exists = 0
  SET fwdind_row_exists = 0
  SELECT INTO "NL"
   FROM app_prefs ap,
    name_value_prefs nvp
   PLAN (ap
    WHERE ap.application_number=961000
     AND (ap.position_cd=request->position_cd)
     AND ap.prsnl_id=0
     AND ap.active_ind=1)
    JOIN (nvp
    WHERE nvp.parent_entity_name="APP_PREFS"
     AND nvp.parent_entity_id=ap.app_prefs_id
     AND nvp.pvc_name="FORWARD_IND"
     AND nvp.active_ind=1)
   DETAIL
    fwdind_row_exists = 1
    IF (nvp.pvc_value="1")
     fwdind_pref_exists = 1
    ENDIF
   WITH nocounter
  ;end select
  SET fwdtopt_row_exists = 0
  SELECT INTO "NL"
   FROM app_prefs ap,
    name_value_prefs nvp
   PLAN (ap
    WHERE ap.application_number=961000
     AND (ap.position_cd=request->position_cd)
     AND ap.prsnl_id=0
     AND ap.active_ind=1)
    JOIN (nvp
    WHERE nvp.parent_entity_name="APP_PREFS"
     AND nvp.parent_entity_id=ap.app_prefs_id
     AND nvp.pvc_name="INBOX_PANE_SEND_TO_PATIENT"
     AND nvp.active_ind=1)
   DETAIL
    fwdtopt_row_exists = 1
    IF (nvp.pvc_value="1")
     fwdtopt_pref_exists = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (fwdind_row_exists=0)
   SELECT INTO "NL"
    FROM app_prefs ap,
     name_value_prefs nvp
    PLAN (ap
     WHERE ap.application_number=961000
      AND ap.position_cd=0
      AND ap.prsnl_id=0
      AND ap.active_ind=1)
     JOIN (nvp
     WHERE nvp.parent_entity_name="APP_PREFS"
      AND nvp.parent_entity_id=ap.app_prefs_id
      AND nvp.pvc_name="FORWARD_IND"
      AND nvp.active_ind=1)
    DETAIL
     IF (nvp.pvc_value="1")
      fwdind_pref_exists = 1
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  IF (fwdtopt_row_exists=0)
   SELECT INTO "NL"
    FROM app_prefs ap,
     name_value_prefs nvp
    PLAN (ap
     WHERE ap.application_number=961000
      AND ap.position_cd=0
      AND ap.prsnl_id=0
      AND ap.active_ind=1)
     JOIN (nvp
     WHERE nvp.parent_entity_name="APP_PREFS"
      AND nvp.parent_entity_id=ap.app_prefs_id
      AND nvp.pvc_name="INBOX_PANE_SEND_TO_PATIENT"
      AND nvp.active_ind=1)
    DETAIL
     IF (nvp.pvc_value="1")
      fwdtopt_pref_exists = 1
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  SET doctorev_sr_exists = 0
  IF (psn_detail_prefs_id > 0)
   SET pref_cnt = 0
   SET item_nbr = "  "
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_SRITEM*"
     AND nvp.pvc_name != "INBOX_SRITEM_CNT"
     AND nvp.pvc_value="4"
     AND nvp.active_ind=1
    DETAIL
     pref_cnt = (pref_cnt+ 1), item_nbr = substring(13,2,nvp.pvc_name)
    WITH nocounter
   ;end select
   IF (pref_cnt > 0
    AND ((cnvtint(item_nbr)=sritem_cnt) OR (cnvtint(item_nbr) < sritem_cnt)) )
    SET row_name = concat("INBOX_SRFOLDER",item_nbr)
    SET pref_cnt = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name=row_name
      AND nvp.pvc_value="3"
      AND nvp.active_ind=1
     DETAIL
      pref_cnt = (pref_cnt+ 1)
     WITH nocounter
    ;end select
    IF (pref_cnt > 0)
     SET doctorev_sr_exists = 1
    ENDIF
   ENDIF
  ENDIF
  SET fwddoctorev_sr_exists = 0
  IF (psn_detail_prefs_id > 0)
   SET pref_cnt = 0
   SET item_nbr = "  "
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_SRITEM*"
     AND nvp.pvc_name != "INBOX_SRITEM_CNT"
     AND nvp.pvc_value="5"
     AND nvp.active_ind=1
    DETAIL
     pref_cnt = (pref_cnt+ 1), item_nbr = substring(13,2,nvp.pvc_name)
    WITH nocounter
   ;end select
   IF (pref_cnt > 0
    AND ((cnvtint(item_nbr)=sritem_cnt) OR (cnvtint(item_nbr) < sritem_cnt)) )
    SET row_name = concat("INBOX_SRFOLDER",item_nbr)
    SET pref_cnt = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name=row_name
      AND nvp.pvc_value="3"
      AND nvp.active_ind=1
     DETAIL
      pref_cnt = (pref_cnt+ 1)
     WITH nocounter
    ;end select
    IF (pref_cnt > 0)
     SET fwddoctorev_sr_exists = 1
    ENDIF
   ENDIF
  ENDIF
  SET doctodict_sr_exists = 0
  IF (psn_detail_prefs_id > 0)
   SET pref_cnt = 0
   SET item_nbr = "  "
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_SRITEM*"
     AND nvp.pvc_name != "INBOX_SRITEM_CNT"
     AND nvp.pvc_value="1"
     AND nvp.active_ind=1
    DETAIL
     pref_cnt = (pref_cnt+ 1), item_nbr = substring(13,2,nvp.pvc_name)
    WITH nocounter
   ;end select
   IF (pref_cnt > 0
    AND ((cnvtint(item_nbr)=sritem_cnt) OR (cnvtint(item_nbr) < sritem_cnt)) )
    SET row_name = concat("INBOX_SRFOLDER",item_nbr)
    SET pref_cnt = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name=row_name
      AND nvp.pvc_value="0"
      AND nvp.active_ind=1
     DETAIL
      pref_cnt = (pref_cnt+ 1)
     WITH nocounter
    ;end select
    IF (pref_cnt > 0)
     SET doctodict_sr_exists = 1
    ENDIF
   ENDIF
  ENDIF
  SET msgs_lb_exists = 0
  IF (psn_detail_prefs_id > 0)
   SET pref_cnt = 0
   SET item_nbr = "  "
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_LBFOLDER*"
     AND nvp.pvc_name != "INBOX_LBFOLDER_CNT"
     AND nvp.pvc_value="1"
     AND nvp.active_ind=1
    DETAIL
     pref_cnt = (pref_cnt+ 1), item_nbr = substring(15,2,nvp.pvc_name)
    WITH nocounter
   ;end select
   IF (pref_cnt > 0
    AND ((cnvtint(item_nbr)=lbfolder_cnt) OR (cnvtint(item_nbr) < lbfolder_cnt)) )
    SET msgs_lb_exists = 1
   ENDIF
  ENDIF
  SET trash_lb_exists = 0
  IF (psn_detail_prefs_id > 0)
   SET pref_cnt = 0
   SET item_nbr = "  "
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_LBFOLDER*"
     AND nvp.pvc_name != "INBOX_LBFOLDER_CNT"
     AND nvp.pvc_value="9"
     AND nvp.active_ind=1
    DETAIL
     pref_cnt = (pref_cnt+ 1), item_nbr = substring(15,2,nvp.pvc_name)
    WITH nocounter
   ;end select
   IF (pref_cnt > 0
    AND ((cnvtint(item_nbr)=lbfolder_cnt) OR (cnvtint(item_nbr) < lbfolder_cnt)) )
    SET trash_lb_exists = 1
   ENDIF
  ENDIF
  SET disablesavechart_pref_value = "0"
  SET hideaddenc_pref_value = "0"
  IF (app_detail_prefs_id > 0)
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=app_detail_prefs_id
     AND nvp.active_ind=1
     AND nvp.pvc_name IN ("INBOX_MSGPH_DISABLESAVECHART", "INBOX_HIDE_ADDENCNTRBTN")
    DETAIL
     IF (nvp.pvc_name="INBOX_MSGPH_DISABLESAVECHART")
      disablesavechart_pref_value = nvp.pvc_value
     ELSEIF (nvp.pvc_name="INBOX_HIDE_ADDENCNTRBTN")
      hideaddenc_pref_value = nvp.pvc_value
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  IF (psn_detail_prefs_id > 0)
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.active_ind=1
     AND nvp.pvc_name IN ("INBOX_MSGPH_DISABLESAVECHART", "INBOX_HIDE_ADDENCNTRBTN")
    DETAIL
     IF (nvp.pvc_name="INBOX_MSGPH_DISABLESAVECHART")
      disablesavechart_pref_value = nvp.pvc_value
     ELSEIF (nvp.pvc_name="INBOX_HIDE_ADDENCNTRBTN")
      hideaddenc_pref_value = nvp.pvc_value
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  SET ordappr_lb_exists = 0
  IF (psn_detail_prefs_id > 0)
   SET pref_cnt = 0
   SET item_nbr = "  "
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_LBFOLDER*"
     AND nvp.pvc_name != "INBOX_LBFOLDER_CNT"
     AND nvp.pvc_value="8"
     AND nvp.active_ind=1
    DETAIL
     pref_cnt = (pref_cnt+ 1), item_nbr = substring(15,2,nvp.pvc_name)
    WITH nocounter
   ;end select
   IF (pref_cnt > 0
    AND ((cnvtint(item_nbr)=lbfolder_cnt) OR (cnvtint(item_nbr) < lbfolder_cnt)) )
    SET ordappr_lb_exists = 1
   ENDIF
  ENDIF
  SET cosignord_co_exists = 0
  IF (psn_detail_prefs_id > 0)
   SET pref_cnt = 0
   SET item_nbr = "  "
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_COITEM*"
     AND nvp.pvc_name != "INBOX_COITEM_CNT"
     AND nvp.pvc_value="14"
     AND nvp.active_ind=1
    DETAIL
     pref_cnt = (pref_cnt+ 1), item_nbr = substring(13,2,nvp.pvc_name)
    WITH nocounter
   ;end select
   IF (pref_cnt > 0
    AND ((cnvtint(item_nbr)=coitem_cnt) OR (cnvtint(item_nbr) < coitem_cnt)) )
    SET row_name = concat("INBOX_COFOLDER",item_nbr)
    SET pref_cnt = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name=row_name
      AND nvp.pvc_value="0"
      AND nvp.active_ind=1
     DETAIL
      pref_cnt = (pref_cnt+ 1)
     WITH nocounter
    ;end select
    IF (pref_cnt > 0)
     SET cosignord_co_exists = 1
    ENDIF
   ENDIF
  ENDIF
  SET medstuord_co_exists = 0
  IF (psn_detail_prefs_id > 0)
   SET pref_cnt = 0
   SET item_nbr = "  "
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_COITEM*"
     AND nvp.pvc_name != "INBOX_COITEM_CNT"
     AND nvp.pvc_value="15"
     AND nvp.active_ind=1
    DETAIL
     pref_cnt = (pref_cnt+ 1), item_nbr = substring(13,2,nvp.pvc_name)
    WITH nocounter
   ;end select
   IF (pref_cnt > 0
    AND ((cnvtint(item_nbr)=coitem_cnt) OR (cnvtint(item_nbr) < coitem_cnt)) )
    SET row_name = concat("INBOX_COFOLDER",item_nbr)
    SET pref_cnt = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name=row_name
      AND nvp.pvc_value="0"
      AND nvp.active_ind=1
     DETAIL
      pref_cnt = (pref_cnt+ 1)
     WITH nocounter
    ;end select
    IF (pref_cnt > 0)
     SET medstuord_co_exists = 1
    ENDIF
   ENDIF
  ENDIF
  SET saveddoc_sr_exists = 0
  IF (psn_detail_prefs_id > 0)
   SET pref_cnt = 0
   SET item_nbr = "  "
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_SRITEM*"
     AND nvp.pvc_name != "INBOX_SRITEM_CNT"
     AND nvp.pvc_value="12"
     AND nvp.active_ind=1
    DETAIL
     pref_cnt = (pref_cnt+ 1), item_nbr = substring(13,2,nvp.pvc_name)
    WITH nocounter
   ;end select
   IF (pref_cnt > 0
    AND ((cnvtint(item_nbr)=sritem_cnt) OR (cnvtint(item_nbr) < sritem_cnt)) )
    SET row_name = concat("INBOX_SRFOLDER",item_nbr)
    SET pref_cnt = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name=row_name
      AND nvp.pvc_value="8"
      AND nvp.active_ind=1
     DETAIL
      pref_cnt = (pref_cnt+ 1)
     WITH nocounter
    ;end select
    IF (pref_cnt > 0)
     SET saveddoc_sr_exists = 1
    ENDIF
   ENDIF
  ENDIF
  SET sentitems_lb_exists = 0
  IF (psn_detail_prefs_id > 0)
   SET pref_cnt = 0
   SET item_nbr = "  "
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_LBFOLDER*"
     AND nvp.pvc_name != "INBOX_LBFOLDER_CNT"
     AND nvp.pvc_value="10"
     AND nvp.active_ind=1
    DETAIL
     pref_cnt = (pref_cnt+ 1), item_nbr = substring(15,2,nvp.pvc_name)
    WITH nocounter
   ;end select
   IF (pref_cnt > 0
    AND ((cnvtint(item_nbr)=lbfolder_cnt) OR (cnvtint(item_nbr) < lbfolder_cnt)) )
    SET sentitems_lb_exists = 1
   ENDIF
  ENDIF
  SET reply->status_data.status_list[1].status = "0"
  SET reply->status_data.status_list[2].status = "0"
  SET reply->status_data.status_list[3].status = "0"
  SET reply->status_data.status_list[4].status = "0"
  SET reply->status_data.status_list[5].status = "0"
  SET reply->status_data.status_list[6].status = "0"
  SET reply->status_data.status_list[7].status = "0"
  SET reply->status_data.status_list[8].status = "0"
  SET reply->status_data.status_list[9].status = "0"
  SET reply->status_data.status_list[10].status = "0"
  SET reply->status_data.status_list[11].status = "0"
  SET reply->status_data.status_list[12].status = "0"
  SET reply->status_data.status_list[13].status = "0"
  SET reply->status_data.status_list[14].status = "0"
  SET reply->status_data.status_list[15].status = "0"
  IF (comp_auth_exists=1)
   IF (rsltend_lb_exists=1)
    SET reply->status_data.status_list[1].status = "1"
   ENDIF
   IF (signrev_lb_exists=1
    AND doctosign_sr_exists=1
    AND fwddoctosign_sr_exists=1)
    SET reply->status_data.status_list[2].status = "1"
   ENDIF
   IF (signrev_lb_exists=1
    AND fwdrsltorev_sr_exists=1)
    SET reply->status_data.status_list[3].status = "1"
   ENDIF
   IF (signrev_lb_exists=1
    AND fwdrsltosign_sr_exists=1)
    SET reply->status_data.status_list[4].status = "1"
   ENDIF
   IF (fwdind_pref_exists=1)
    SET reply->status_data.status_list[6].status = "1"
   ENDIF
   IF (fwdtopt_pref_exists=1)
    SET reply->status_data.status_list[7].status = "1"
   ENDIF
   IF (signrev_lb_exists=1
    AND doctorev_sr_exists=1
    AND fwddoctorev_sr_exists=1)
    SET reply->status_data.status_list[8].status = "1"
   ENDIF
   IF (signrev_lb_exists=1
    AND doctodict_sr_exists=1)
    SET reply->status_data.status_list[9].status = "1"
   ENDIF
   IF (msgs_lb_exists=1
    AND trash_lb_exists=1)
    SET reply->status_data.status_list[12].status = "1"
    IF (disablesavechart_pref_value="0")
     SET reply->status_data.status_list[10].status = "1"
    ENDIF
    IF (hideaddenc_pref_value="0")
     SET reply->status_data.status_list[11].status = "1"
    ENDIF
   ENDIF
   IF (ordappr_lb_exists=1
    AND cosignord_co_exists=1
    AND medstuord_co_exists=1)
    SET reply->status_data.status_list[13].status = "1"
   ENDIF
   IF (signrev_lb_exists=1
    AND saveddoc_sr_exists=1)
    SET reply->status_data.status_list[14].status = "1"
   ENDIF
  ENDIF
 ELSEIF ((request->action="2"))
  SET rsltend_off_on_ind = request->task_list[1].on_off_ind
  SET signpatdoc_off_on_ind = request->task_list[2].on_off_ind
  SET revpatrslt_off_on_ind = request->task_list[3].on_off_ind
  SET signpatrslt_off_on_ind = request->task_list[4].on_off_ind
  SET correspond_off_on_ind = request->task_list[5].on_off_ind
  SET fwdinbox_off_on_ind = request->task_list[6].on_off_ind
  SET fwdemail_off_on_ind = request->task_list[7].on_off_ind
  SET revpatdoc_off_on_ind = request->task_list[8].on_off_ind
  SET recdictdoc_off_on_ind = request->task_list[9].on_off_ind
  SET savephone_off_on_ind = request->task_list[10].on_off_ind
  SET addphone_off_on_ind = request->task_list[11].on_off_ind
  SET recphone_off_on_ind = request->task_list[12].on_off_ind
  SET ordtoapp_off_on_ind = request->task_list[13].on_off_ind
  SET saveddoc_off_on_ind = request->task_list[14].on_off_ind
  SET sentitems_off_on_ind = request->task_list[15].on_off_ind
  IF (((rsltend_off_on_ind=1) OR (((signpatdoc_off_on_ind=1) OR (((revpatrslt_off_on_ind=1) OR (((
  signpatrslt_off_on_ind=1) OR (((correspond_off_on_ind=1) OR (((fwdinbox_off_on_ind=1) OR (((
  fwdemail_off_on_ind=1) OR (((revpatdoc_off_on_ind=1) OR (((recdictdoc_off_on_ind=1) OR (((
  savephone_off_on_ind=1) OR (((addphone_off_on_ind=1) OR (((recphone_off_on_ind=1) OR (((
  ordtoapp_off_on_ind=1) OR (((saveddoc_off_on_ind=1) OR (sentitems_off_on_ind=1)) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )
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
     SET nvprequest->nvplist[1].pvc_value = "16"
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
  SET psn_detail_prefs_id = 0.0
  SET row_cnt = 0
  SET row_nbr = 0
  SET row_found = 0
  CALL find_list_bar_row("4")
  IF (rsltend_off_on_ind=1)
   IF (row_found=0)
    CALL add_list_bar_row("4")
   ENDIF
  ELSE
   IF (row_found=1)
    CALL remove_list_bar_row("4")
   ENDIF
  ENDIF
  SET row_cnt = 0
  SET row_nbr = 0
  SET row_found = 0
  CALL find_list_bar_row("3")
  IF (((signpatdoc_off_on_ind=1) OR (((revpatrslt_off_on_ind=1) OR (((signpatrslt_off_on_ind=1) OR (
  ((revpatdoc_off_on_ind=1) OR (((recdictdoc_off_on_ind=1) OR (saveddoc_off_on_ind=1)) )) )) )) )) )
   IF (row_found=0)
    CALL add_list_bar_row("3")
   ENDIF
  ELSE
   IF (row_found=1)
    CALL remove_list_bar_row("3")
   ENDIF
  ENDIF
  SET row_cnt = 0
  SET row_nbr = 0
  SET item_found = 0
  SET folder_found = 0
  CALL find_sign_and_review_rows("2","1")
  IF (signpatdoc_off_on_ind=1)
   IF (item_found=0)
    CALL add_sign_and_review_item("2")
    CALL add_sign_and_review_folder(row_nbr,"1")
   ELSE
    IF (folder_found=0)
     CALL add_sign_and_review_folder(row_nbr,"1")
    ENDIF
   ENDIF
  ELSE
   IF (item_found=1)
    CALL remove_sign_and_review_rows("2")
   ENDIF
  ENDIF
  SET row_cnt = 0
  SET row_nbr = 0
  SET item_found = 0
  SET folder_found = 0
  CALL find_sign_and_review_rows("3","1")
  IF (signpatdoc_off_on_ind=1)
   IF (item_found=0)
    CALL add_sign_and_review_item("3")
    CALL add_sign_and_review_folder(row_nbr,"1")
   ELSE
    IF (folder_found=0)
     CALL add_sign_and_review_folder(row_nbr,"1")
    ENDIF
   ENDIF
  ELSE
   IF (item_found=1)
    CALL remove_sign_and_review_rows("3")
   ENDIF
  ENDIF
  SET row_cnt = 0
  SET row_nbr = 0
  SET item_found = 0
  SET folder_found = 0
  CALL find_sign_and_review_rows("7","13")
  IF (signpatrslt_off_on_ind=1)
   IF (item_found=0)
    CALL add_sign_and_review_item("7")
    CALL add_sign_and_review_folder(row_nbr,"13")
   ELSE
    IF (folder_found=0)
     CALL add_sign_and_review_folder(row_nbr,"13")
    ENDIF
   ENDIF
  ELSE
   IF (item_found=1)
    CALL remove_sign_and_review_rows("7")
   ENDIF
  ENDIF
  SET row_cnt = 0
  SET row_nbr = 0
  SET item_found = 0
  SET folder_found = 0
  CALL find_sign_and_review_rows("8","13")
  IF (revpatrslt_off_on_ind=1)
   IF (item_found=0)
    CALL add_sign_and_review_item("8")
    CALL add_sign_and_review_folder(row_nbr,"13")
   ELSE
    IF (folder_found=0)
     CALL add_sign_and_review_folder(row_nbr,"13")
    ENDIF
   ENDIF
  ELSE
   IF (item_found=1)
    CALL remove_sign_and_review_rows("8")
   ENDIF
  ENDIF
  SET aprequest->aplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_app_prefs  WITH replace("REQUEST",aprequest), replace("REPLY",apreply)
  IF ((apreply->aplist[1].app_prefs_id > 0))
   SET fwd_pref_value = "0"
   SET pref_cnt = 0
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="APP_PREFS"
     AND (nvp.parent_entity_id=apreply->aplist[1].app_prefs_id)
     AND nvp.pvc_name="FORWARD_IND"
     AND nvp.active_ind=1
    DETAIL
     pref_cnt = (pref_cnt+ 1), fwd_pref_value = nvp.pvc_value
    WITH nocounter
   ;end select
  ENDIF
  CALL complete_fwdind_ap_nvp(dummy_parm1)
  IF (fwdinbox_off_on_ind=1)
   IF ((apreply->aplist[1].app_prefs_id > 0))
    SET nvprequest->nvplist[1].parent_entity_id = apreply->aplist[1].app_prefs_id
    IF (pref_cnt > 0)
     IF (cnvtint(fwd_pref_value) != 1)
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
    SET aprequest->aplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_app_prefs  WITH replace("REQUEST",aprequest), replace("REPLY",apreply)
    SET nvprequest->nvplist[1].parent_entity_id = apreply->aplist[1].app_prefs_id
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ELSE
   IF ((apreply->aplist[1].app_prefs_id > 0))
    SET nvprequest->nvplist[1].parent_entity_id = apreply->aplist[1].app_prefs_id
    IF (pref_cnt > 0)
     IF (cnvtint(fwd_pref_value) != 0)
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
   ELSE
    SET aprequest->aplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_app_prefs  WITH replace("REQUEST",aprequest), replace("REPLY",apreply)
    SET nvprequest->nvplist[1].pvc_value = "0"
    SET nvprequest->nvplist[1].parent_entity_id = apreply->aplist[1].app_prefs_id
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ENDIF
  SET aprequest->aplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_app_prefs  WITH replace("REQUEST",aprequest), replace("REPLY",apreply)
  IF ((apreply->aplist[1].app_prefs_id > 0))
   SET fwd_pref_value = "0"
   SET pref_cnt = 0
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="APP_PREFS"
     AND (nvp.parent_entity_id=apreply->aplist[1].app_prefs_id)
     AND nvp.pvc_name="INBOX_PANE_SEND_TO_PATIENT"
     AND nvp.active_ind=1
    DETAIL
     pref_cnt = (pref_cnt+ 1), fwd_pref_value = nvp.pvc_value
    WITH nocounter
   ;end select
  ENDIF
  CALL complete_fwdtopt_ap_nvp(dummy_parm1)
  IF (fwdemail_off_on_ind=1)
   IF ((apreply->aplist[1].app_prefs_id > 0))
    SET nvprequest->nvplist[1].parent_entity_id = apreply->aplist[1].app_prefs_id
    IF (pref_cnt > 0)
     IF (cnvtint(fwd_pref_value) != 1)
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
    SET aprequest->aplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_app_prefs  WITH replace("REQUEST",aprequest), replace("REPLY",apreply)
    SET nvprequest->nvplist[1].parent_entity_id = apreply->aplist[1].app_prefs_id
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ELSE
   IF ((apreply->aplist[1].app_prefs_id > 0))
    SET nvprequest->nvplist[1].parent_entity_id = apreply->aplist[1].app_prefs_id
    IF (pref_cnt > 0)
     IF (cnvtint(fwd_pref_value) != 0)
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
   ELSE
    SET aprequest->aplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_app_prefs  WITH replace("REQUEST",aprequest), replace("REPLY",apreply)
    SET nvprequest->nvplist[1].pvc_value = "0"
    SET nvprequest->nvplist[1].parent_entity_id = apreply->aplist[1].app_prefs_id
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ENDIF
  SET row_cnt = 0
  SET row_nbr = 0
  SET item_found = 0
  SET folder_found = 0
  CALL find_sign_and_review_rows("4","3")
  IF (revpatdoc_off_on_ind=1)
   IF (item_found=0)
    CALL add_sign_and_review_item("4")
    CALL add_sign_and_review_folder(row_nbr,"3")
   ELSE
    IF (folder_found=0)
     CALL add_sign_and_review_folder(row_nbr,"3")
    ENDIF
   ENDIF
  ELSE
   IF (item_found=1)
    CALL remove_sign_and_review_rows("4")
   ENDIF
  ENDIF
  SET row_cnt = 0
  SET row_nbr = 0
  SET item_found = 0
  SET folder_found = 0
  CALL find_sign_and_review_rows("5","3")
  IF (revpatdoc_off_on_ind=1)
   IF (item_found=0)
    CALL add_sign_and_review_item("5")
    CALL add_sign_and_review_folder(row_nbr,"3")
   ELSE
    IF (folder_found=0)
     CALL add_sign_and_review_folder(row_nbr,"3")
    ENDIF
   ENDIF
  ELSE
   IF (item_found=1)
    CALL remove_sign_and_review_rows("5")
   ENDIF
  ENDIF
  SET row_cnt = 0
  SET row_nbr = 0
  SET item_found = 0
  SET folder_found = 0
  CALL find_sign_and_review_rows("1","0")
  IF (recdictdoc_off_on_ind=1)
   IF (item_found=0)
    CALL add_sign_and_review_item("1")
    CALL add_sign_and_review_folder(row_nbr,"0")
   ELSE
    IF (folder_found=0)
     CALL add_sign_and_review_folder(row_nbr,"0")
    ENDIF
   ENDIF
  ELSE
   IF (item_found=1)
    CALL remove_sign_and_review_rows("1")
   ENDIF
  ENDIF
  SET row_cnt = 0
  SET row_nbr = 0
  SET row_found = 0
  CALL find_list_bar_row("1")
  IF (recphone_off_on_ind=1)
   IF (row_found=0)
    CALL add_list_bar_row("1")
   ENDIF
  ELSE
   IF (row_found=1)
    CALL remove_list_bar_row("1")
   ENDIF
  ENDIF
  SET row_cnt = 0
  SET row_nbr = 0
  SET row_found = 0
  CALL find_list_bar_row("9")
  IF (recphone_off_on_ind=1)
   IF (row_found=0)
    CALL add_list_bar_row("9")
   ENDIF
  ELSE
   IF (row_found=1)
    CALL remove_list_bar_row("9")
   ENDIF
  ENDIF
  SET disablesavechart_exists = 0
  SET disablesavechart_value = " "
  SET hideaddenc_exists = 0
  SET hideaddenc_value = " "
  SET dprequest->dplist[1].view_name = "INBOX"
  SET dprequest->dplist[1].comp_name = "INBOX"
  SET dprequest->dplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
  SET psn_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
  IF (psn_detail_prefs_id > 0)
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.active_ind=1
     AND nvp.pvc_name IN ("INBOX_MSGPH_DISABLESAVECHART", "INBOX_HIDE_ADDENCNTRBTN")
    DETAIL
     IF (nvp.pvc_name="INBOX_MSGPH_DISABLESAVECHART")
      disablesavechart_exists = 1, disablesavechart_value = nvp.pvc_value
     ELSEIF (nvp.pvc_name="INBOX_HIDE_ADDENCNTRBTN")
      hideaddenc_exists = 1, hideaddenc_value = nvp.pvc_value
     ENDIF
    WITH nocounter
   ;end select
  ELSE
   SET dprequest->dplist[1].action_flag = "1"
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
   SET psn_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
  ENDIF
  SET stat = alterlist(nvprequest->nvplist,1)
  SET stat = alterlist(nvpreply->nvplist,1)
  SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
  SET nvprequest->nvplist[1].parent_entity_id = psn_detail_prefs_id
  SET nvprequest->nvplist[1].pvc_name = "INBOX_MSGPH_DISABLESAVECHART"
  IF (savephone_off_on_ind=1)
   IF (disablesavechart_exists > 0)
    IF (disablesavechart_value != "0")
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
  ELSE
   IF (disablesavechart_exists > 0)
    IF (disablesavechart_value != "1")
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
  ENDIF
  SET nvprequest->nvplist[1].pvc_name = "INBOX_HIDE_ADDENCNTRBTN"
  IF (addphone_off_on_ind=1)
   IF (hideaddenc_exists > 0)
    IF (hideaddenc_value != "0")
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
  ELSE
   IF (hideaddenc_exists > 0)
    IF (hideaddenc_value != "1")
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
  ENDIF
  SET row_cnt = 0
  SET row_nbr = 0
  SET row_found = 0
  CALL find_list_bar_row("8")
  IF (ordtoapp_off_on_ind=1)
   IF (row_found=0)
    CALL add_list_bar_row("8")
   ENDIF
  ELSE
   IF (row_found=1)
    CALL remove_list_bar_row("8")
   ENDIF
  ENDIF
  SET row_cnt = 0
  SET row_nbr = 0
  SET item_found = 0
  SET folder_found = 0
  CALL find_cosign_rows("14","0")
  IF (ordtoapp_off_on_ind=1)
   IF (item_found=0)
    CALL add_cosign_item("14")
    CALL add_cosign_folder(row_nbr,"0")
   ELSE
    IF (folder_found=0)
     CALL add_cosign_folder(row_nbr,"0")
    ENDIF
   ENDIF
  ELSE
   IF (item_found=1)
    CALL remove_cosign_rows("14")
   ENDIF
  ENDIF
  SET row_cnt = 0
  SET row_nbr = 0
  SET item_found = 0
  SET folder_found = 0
  CALL find_cosign_rows("15","0")
  IF (ordtoapp_off_on_ind=1)
   IF (item_found=0)
    CALL add_cosign_item("15")
    CALL add_cosign_folder(row_nbr,"0")
   ELSE
    IF (folder_found=0)
     CALL add_cosign_folder(row_nbr,"0")
    ENDIF
   ENDIF
  ELSE
   IF (item_found=1)
    CALL remove_cosign_rows("15")
   ENDIF
  ENDIF
  SET row_cnt = 0
  SET row_nbr = 0
  SET item_found = 0
  SET folder_found = 0
  CALL find_sign_and_review_rows("12","8")
  IF (saveddoc_off_on_ind=1)
   IF (item_found=0)
    CALL add_sign_and_review_item("12")
    CALL add_sign_and_review_folder(row_nbr,"8")
   ELSE
    IF (folder_found=0)
     CALL add_sign_and_review_folder(row_nbr,"8")
    ENDIF
   ENDIF
  ELSE
   IF (item_found=1)
    CALL remove_sign_and_review_rows("12")
   ENDIF
  ENDIF
  SET row_cnt = 0
  SET row_nbr = 0
  SET row_found = 0
  CALL find_list_bar_row("10")
  IF (recphone_off_on_ind=1)
   IF (row_found=0)
    CALL add_list_bar_row("10")
   ENDIF
  ELSE
   IF (row_found=1)
    CALL remove_list_bar_row("10")
   ENDIF
  ENDIF
  SET data_partition_ind = 0
  SET field_found = 0
  RANGE OF c IS code_value_set
  SET field_found = validate(c.br_client_id)
  FREE RANGE c
  IF (field_found=0)
   SET prg_exists_ind = 0
   SET prg_exists_ind = checkprg("ACM_GET_ACC_LOGICAL_DOMAINS")
   IF (prg_exists_ind > 0)
    SET field_found = 0
    RANGE OF p IS prsnl
    SET field_found = validate(p.logical_domain_id)
    FREE RANGE p
    IF (field_found=1)
     SET data_partition_ind = 1
     FREE SET acm_get_acc_logical_domains_req
     RECORD acm_get_acc_logical_domains_req(
       1 write_mode_ind = i2
       1 concept = i4
     )
     FREE SET acm_get_acc_logical_domains_rep
     RECORD acm_get_acc_logical_domains_rep(
       1 logical_domain_grp_id = f8
       1 logical_domains_cnt = i4
       1 logical_domains[*]
         2 logical_domain_id = f8
       1 status_block
         2 status_ind = i2
         2 error_code = i4
     )
     SET acm_get_acc_logical_domains_req->write_mode_ind = 0
     SET acm_get_acc_logical_domains_req->concept = 2
     EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
     replace("REPLY",acm_get_acc_logical_domains_rep)
    ENDIF
   ENDIF
  ENDIF
  DECLARE prsnl_parse = vc
  SET prsnl_parse = "p.position_cd = request->position_cd and p.active_ind = 1"
  IF (data_partition_ind=1)
   IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
    SET prsnl_parse = concat(prsnl_parse," and p.logical_domain_id in (")
    FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
      IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
       SET prsnl_parse = build(prsnl_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
        logical_domain_id,")")
      ELSE
       SET prsnl_parse = build(prsnl_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
        logical_domain_id,",")
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
  SET prsnl_cnt = 0
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE parser(prsnl_parse)
   DETAIL
    prsnl_cnt = (prsnl_cnt+ 1), stat = alterlist(pnrequest->poslist[1].plist,prsnl_cnt), pnrequest->
    poslist[1].plist[prsnl_cnt].person_id = p.person_id,
    pnrequest->poslist[1].plist[prsnl_cnt].action_flag = 1
   WITH nocounter
  ;end select
  SET pnrequest->poslist[1].position_cd = request->position_cd
  SET pnrequest->poslist[1].update_prsnl_flag = 0
  SET trace = recpersist
  EXECUTE bed_ens_prsnl_notify  WITH replace("REQUEST",pnrequest), replace("REPLY",pnreply)
 ENDIF
 GO TO exitscript
 SUBROUTINE complete_vp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,2)
   SET stat = alterlist(nvpreply->nvplist,2)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "VIEW_CAPTION"
   SET nvprequest->nvplist[1].pvc_value = "Inbox"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "DISPLAY_SEQ"
   SET nvprequest->nvplist[2].pvc_value = "16"
 END ;Subroutine
 SUBROUTINE complete_vcp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,5)
   SET stat = alterlist(nvpreply->nvplist,5)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "COMP_DLLNAME"
   SET nvprequest->nvplist[1].pvc_value = "CPSUIINBOX.dll"
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
 SUBROUTINE complete_fwdind_ap_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,1)
   SET stat = alterlist(nvpreply->nvplist,1)
   SET nvprequest->nvplist[1].parent_entity_name = "APP_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "FORWARD_IND"
   SET nvprequest->nvplist[1].pvc_value = "1"
 END ;Subroutine
 SUBROUTINE complete_fwdtopt_ap_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,1)
   SET stat = alterlist(nvpreply->nvplist,1)
   SET nvprequest->nvplist[1].parent_entity_name = "APP_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "INBOX_PANE_SEND_TO_PATIENT"
   SET nvprequest->nvplist[1].pvc_value = "1"
 END ;Subroutine
 SUBROUTINE find_list_bar_row(row_pvc_value)
  IF (psn_detail_prefs_id=0.0)
   SET dprequest->dplist[1].view_name = "INBOX"
   SET dprequest->dplist[1].comp_name = "INBOX"
   SET dprequest->dplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
   SET psn_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
  ENDIF
  IF (psn_detail_prefs_id > 0)
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_LBFOLDER_CNT"
     AND nvp.active_ind=1
    DETAIL
     row_cnt = cnvtint(nvp.pvc_value)
    WITH nocounter
   ;end select
   IF (row_cnt > 0)
    SET row_idx = (row_cnt - 1)
    FOR (t = 0 TO row_idx)
      SET row_name = concat("INBOX_LBFOLDER",cnvtstring(t))
      SELECT INTO "NL:"
       FROM name_value_prefs nvp
       WHERE nvp.parent_entity_name="DETAIL_PREFS"
        AND nvp.parent_entity_id=psn_detail_prefs_id
        AND nvp.pvc_name=row_name
        AND nvp.pvc_value=row_pvc_value
        AND nvp.active_ind=1
       DETAIL
        row_found = 1
       WITH nocounter
      ;end select
      IF (row_found=1)
       SET row_nbr = t
       SET t = (row_idx+ 1)
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE add_list_bar_row(row_pvc_value)
   IF (psn_detail_prefs_id=0.0)
    SET dprequest->dplist[1].view_name = "INBOX"
    SET dprequest->dplist[1].comp_name = "INBOX"
    SET dprequest->dplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
    SET psn_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
    SET stat = alterlist(nvprequest->nvplist,2)
    SET stat = alterlist(nvpreply->nvplist,2)
    SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
    SET nvprequest->nvplist[1].parent_entity_id = psn_detail_prefs_id
    SET nvprequest->nvplist[1].pvc_name = "INBOX_LBFOLDER_CNT"
    SET nvprequest->nvplist[1].pvc_value = "1"
    SET nvprequest->nvplist[2].parent_entity_name = "DETAIL_PREFS"
    SET nvprequest->nvplist[2].parent_entity_id = psn_detail_prefs_id
    SET nvprequest->nvplist[2].pvc_name = "INBOX_LBFOLDER0"
    SET nvprequest->nvplist[2].pvc_value = row_pvc_value
    SET nvprequest->nvplist[1].action_flag = "1"
    SET nvprequest->nvplist[2].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ELSE
    SET row_name = concat("INBOX_LBFOLDER",cnvtstring(row_cnt))
    SET row_exists = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name=row_name
      AND nvp.active_ind=1
     DETAIL
      row_exists = 1
     WITH nocounter
    ;end select
    IF (row_exists=1)
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_value = row_pvc_value, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->
       updt_id,
       nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
       .updt_applctx = reqinfo->updt_applctx
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=psn_detail_prefs_id
       AND nvp.pvc_name=row_name
      WITH nocounter
     ;end update
    ELSE
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
     SET nvprequest->nvplist[1].parent_entity_id = psn_detail_prefs_id
     SET nvprequest->nvplist[1].pvc_name = row_name
     SET nvprequest->nvplist[1].pvc_value = row_pvc_value
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
    SET row_exists = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name="INBOX_LBFOLDER_CNT"
      AND nvp.active_ind=1
     DETAIL
      row_exists = 1
     WITH nocounter
    ;end select
    IF (row_exists=1)
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_value = cnvtstring((row_cnt+ 1)), nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id =
       reqinfo->updt_id,
       nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
       .updt_applctx = reqinfo->updt_applctx
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=psn_detail_prefs_id
       AND nvp.pvc_name="INBOX_LBFOLDER_CNT"
      WITH nocounter
     ;end update
    ELSE
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
     SET nvprequest->nvplist[1].parent_entity_id = psn_detail_prefs_id
     SET nvprequest->nvplist[1].pvc_name = "INBOX_LBFOLDER_CNT"
     SET nvprequest->nvplist[1].pvc_value = "1"
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE remove_list_bar_row(row_pvc_value)
   SET row_name = concat("INBOX_LBFOLDER",cnvtstring(row_nbr))
   DELETE  FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name=row_name
     AND nvp.pvc_value=row_pvc_value
    WITH nocounter
   ;end delete
   SET old_row_number = (row_nbr+ 1)
   SET row_idx = (row_cnt - 1)
   FOR (old_row_number = old_row_number TO row_idx)
     SET nvp_id = 0.0
     SET row_name = concat("INBOX_LBFOLDER",cnvtstring(old_row_number))
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=psn_detail_prefs_id
       AND nvp.pvc_name=row_name
       AND nvp.active_ind=1
      DETAIL
       nvp_id = nvp.name_value_prefs_id
      WITH nocounter
     ;end select
     SET row_name = concat("INBOX_LBFOLDER",cnvtstring((old_row_number - 1)))
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_name = row_name, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->updt_id,
       nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
       .updt_applctx = reqinfo->updt_applctx
      WHERE nvp.name_value_prefs_id=nvp_id
      WITH nocounter
     ;end update
   ENDFOR
   UPDATE  FROM name_value_prefs nvp
    SET nvp.pvc_value = cnvtstring((row_cnt - 1)), nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id =
     reqinfo->updt_id,
     nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
     .updt_applctx = reqinfo->updt_applctx
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_LBFOLDER_CNT"
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE find_sign_and_review_rows(row_pvc_value,folder_pvc_value)
  IF (psn_detail_prefs_id=0.0)
   SET dprequest->dplist[1].view_name = "INBOX"
   SET dprequest->dplist[1].comp_name = "INBOX"
   SET dprequest->dplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
   SET psn_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
  ENDIF
  IF (psn_detail_prefs_id > 0)
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_SRITEM_CNT"
     AND nvp.active_ind=1
    DETAIL
     row_cnt = cnvtint(nvp.pvc_value)
    WITH nocounter
   ;end select
   IF (row_cnt > 0)
    SET row_idx = (row_cnt - 1)
    FOR (t = 0 TO row_idx)
      SET row_name = concat("INBOX_SRITEM",cnvtstring(t))
      SELECT INTO "NL:"
       FROM name_value_prefs nvp
       WHERE nvp.parent_entity_name="DETAIL_PREFS"
        AND nvp.parent_entity_id=psn_detail_prefs_id
        AND nvp.pvc_name=row_name
        AND nvp.pvc_value=row_pvc_value
        AND nvp.active_ind=1
       DETAIL
        item_found = 1
       WITH nocounter
      ;end select
      IF (item_found=1)
       SET row_nbr = t
       SET t = (row_idx+ 1)
      ENDIF
    ENDFOR
    IF (item_found=1)
     SET row_name = concat("INBOX_SRFOLDER",cnvtstring(row_nbr))
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=psn_detail_prefs_id
       AND nvp.pvc_name=row_name
       AND nvp.pvc_value=folder_pvc_value
       AND nvp.active_ind=1
      DETAIL
       folder_found = 1
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE add_sign_and_review_item(row_pvc_value)
   IF (psn_detail_prefs_id=0.0)
    SET dprequest->dplist[1].view_name = "INBOX"
    SET dprequest->dplist[1].comp_name = "INBOX"
    SET dprequest->dplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
    SET psn_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
    SET stat = alterlist(nvprequest->nvplist,2)
    SET stat = alterlist(nvpreply->nvplist,2)
    SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
    SET nvprequest->nvplist[1].parent_entity_id = psn_detail_prefs_id
    SET nvprequest->nvplist[1].pvc_name = "INBOX_SRITEM_CNT"
    SET nvprequest->nvplist[1].pvc_value = "1"
    SET nvprequest->nvplist[2].parent_entity_name = "DETAIL_PREFS"
    SET nvprequest->nvplist[2].parent_entity_id = psn_detail_prefs_id
    SET nvprequest->nvplist[2].pvc_name = "INBOX_SRITEM0"
    SET nvprequest->nvplist[2].pvc_value = row_pvc_value
    SET nvprequest->nvplist[1].action_flag = "1"
    SET nvprequest->nvplist[2].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    SET row_nbr = 0
   ELSE
    SET row_name = concat("INBOX_SRITEM",cnvtstring(row_cnt))
    SET row_exists = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name=row_name
      AND nvp.active_ind=1
     DETAIL
      row_exists = 1
     WITH nocounter
    ;end select
    IF (row_exists=1)
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_value = row_pvc_value, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->
       updt_id,
       nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
       .updt_applctx = reqinfo->updt_applctx
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=psn_detail_prefs_id
       AND nvp.pvc_name=row_name
      WITH nocounter
     ;end update
    ELSE
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
     SET nvprequest->nvplist[1].parent_entity_id = psn_detail_prefs_id
     SET nvprequest->nvplist[1].pvc_name = row_name
     SET nvprequest->nvplist[1].pvc_value = row_pvc_value
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
    SET row_nbr = row_cnt
    SET row_exists = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name="INBOX_SRITEM_CNT"
      AND nvp.active_ind=1
     DETAIL
      row_exists = 1
     WITH nocounter
    ;end select
    IF (row_exists=1)
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_value = cnvtstring((row_cnt+ 1)), nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id =
       reqinfo->updt_id,
       nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
       .updt_applctx = reqinfo->updt_applctx
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=psn_detail_prefs_id
       AND nvp.pvc_name="INBOX_SRITEM_CNT"
      WITH nocounter
     ;end update
    ELSE
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
     SET nvprequest->nvplist[1].parent_entity_id = psn_detail_prefs_id
     SET nvprequest->nvplist[1].pvc_name = "INBOX_SRITEM_CNT"
     SET nvprequest->nvplist[1].pvc_value = "1"
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_sign_and_review_folder(item_row_nbr,folder_pvc_value)
   SET row_name = concat("INBOX_SRFOLDER",cnvtstring(item_row_nbr))
   SET row_exists = 0
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name=row_name
     AND nvp.active_ind=1
    DETAIL
     row_exists = 1
    WITH nocounter
   ;end select
   IF (row_exists=1)
    UPDATE  FROM name_value_prefs nvp
     SET nvp.pvc_value = folder_pvc_value, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->
      updt_id,
      nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
      .updt_applctx = reqinfo->updt_applctx
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name=row_name
     WITH nocounter
    ;end update
   ELSE
    SET stat = alterlist(nvprequest->nvplist,1)
    SET stat = alterlist(nvpreply->nvplist,1)
    SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
    SET nvprequest->nvplist[1].parent_entity_id = psn_detail_prefs_id
    SET nvprequest->nvplist[1].pvc_name = row_name
    SET nvprequest->nvplist[1].pvc_value = folder_pvc_value
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
 END ;Subroutine
 SUBROUTINE remove_sign_and_review_rows(row_pvc_value)
   SET row_name = concat("INBOX_SRITEM",cnvtstring(row_nbr))
   DELETE  FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name=row_name
     AND nvp.pvc_value=row_pvc_value
    WITH nocounter
   ;end delete
   SET row_name = concat("INBOX_SRFOLDER",cnvtstring(row_nbr))
   DELETE  FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name=row_name
    WITH nocounter
   ;end delete
   SET old_row_number = (row_nbr+ 1)
   SET row_idx = (row_cnt - 1)
   FOR (old_row_number = old_row_number TO row_idx)
     SET nvp_id = 0.0
     SET row_name = concat("INBOX_SRITEM",cnvtstring(old_row_number))
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=psn_detail_prefs_id
       AND nvp.pvc_name=row_name
       AND nvp.active_ind=1
      DETAIL
       nvp_id = nvp.name_value_prefs_id
      WITH nocounter
     ;end select
     SET row_name = concat("INBOX_SRITEM",cnvtstring((old_row_number - 1)))
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_name = row_name, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->updt_id,
       nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
       .updt_applctx = reqinfo->updt_applctx
      WHERE nvp.name_value_prefs_id=nvp_id
      WITH nocounter
     ;end update
     SET nvp_id = 0.0
     SET row_name = concat("INBOX_SRFOLDER",cnvtstring(old_row_number))
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=psn_detail_prefs_id
       AND nvp.pvc_name=row_name
       AND nvp.active_ind=1
      DETAIL
       nvp_id = nvp.name_value_prefs_id
      WITH nocounter
     ;end select
     SET row_name = concat("INBOX_SRFOLDER",cnvtstring((old_row_number - 1)))
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_name = row_name, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->updt_id,
       nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
       .updt_applctx = reqinfo->updt_applctx
      WHERE nvp.name_value_prefs_id=nvp_id
      WITH nocounter
     ;end update
   ENDFOR
   UPDATE  FROM name_value_prefs nvp
    SET nvp.pvc_value = cnvtstring((row_cnt - 1)), nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id =
     reqinfo->updt_id,
     nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
     .updt_applctx = reqinfo->updt_applctx
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_SRITEM_CNT"
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE find_cosign_rows(row_pvc_value,folder_pvc_value)
  IF (psn_detail_prefs_id=0.0)
   SET dprequest->dplist[1].view_name = "INBOX"
   SET dprequest->dplist[1].comp_name = "INBOX"
   SET dprequest->dplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
   SET psn_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
  ENDIF
  IF (psn_detail_prefs_id > 0)
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_COITEM_CNT"
     AND nvp.active_ind=1
    DETAIL
     row_cnt = cnvtint(nvp.pvc_value)
    WITH nocounter
   ;end select
   IF (row_cnt > 0)
    SET row_idx = (row_cnt - 1)
    FOR (t = 0 TO row_idx)
      SET row_name = concat("INBOX_COITEM",cnvtstring(t))
      SELECT INTO "NL:"
       FROM name_value_prefs nvp
       WHERE nvp.parent_entity_name="DETAIL_PREFS"
        AND nvp.parent_entity_id=psn_detail_prefs_id
        AND nvp.pvc_name=row_name
        AND nvp.pvc_value=row_pvc_value
        AND nvp.active_ind=1
       DETAIL
        item_found = 1
       WITH nocounter
      ;end select
      IF (item_found=1)
       SET row_nbr = t
       SET t = (row_idx+ 1)
      ENDIF
    ENDFOR
    IF (item_found=1)
     SET row_name = concat("INBOX_COFOLDER",cnvtstring(row_nbr))
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=psn_detail_prefs_id
       AND nvp.pvc_name=row_name
       AND nvp.pvc_value=folder_pvc_value
       AND nvp.active_ind=1
      DETAIL
       folder_found = 1
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE add_cosign_item(row_pvc_value)
   IF (psn_detail_prefs_id=0.0)
    SET dprequest->dplist[1].view_name = "INBOX"
    SET dprequest->dplist[1].comp_name = "INBOX"
    SET dprequest->dplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
    SET psn_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
    SET stat = alterlist(nvprequest->nvplist,2)
    SET stat = alterlist(nvpreply->nvplist,2)
    SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
    SET nvprequest->nvplist[1].parent_entity_id = psn_detail_prefs_id
    SET nvprequest->nvplist[1].pvc_name = "INBOX_COITEM_CNT"
    SET nvprequest->nvplist[1].pvc_value = "1"
    SET nvprequest->nvplist[2].parent_entity_name = "DETAIL_PREFS"
    SET nvprequest->nvplist[2].parent_entity_id = psn_detail_prefs_id
    SET nvprequest->nvplist[2].pvc_name = "INBOX_COITEM0"
    SET nvprequest->nvplist[2].pvc_value = row_pvc_value
    SET nvprequest->nvplist[1].action_flag = "1"
    SET nvprequest->nvplist[2].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    SET row_nbr = 0
   ELSE
    SET row_name = concat("INBOX_COITEM",cnvtstring(row_cnt))
    SET row_exists = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name=row_name
      AND nvp.active_ind=1
     DETAIL
      row_exists = 1
     WITH nocounter
    ;end select
    IF (row_exists=1)
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_value = row_pvc_value, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->
       updt_id,
       nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
       .updt_applctx = reqinfo->updt_applctx
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=psn_detail_prefs_id
       AND nvp.pvc_name=row_name
      WITH nocounter
     ;end update
    ELSE
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
     SET nvprequest->nvplist[1].parent_entity_id = psn_detail_prefs_id
     SET nvprequest->nvplist[1].pvc_name = row_name
     SET nvprequest->nvplist[1].pvc_value = row_pvc_value
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
    SET row_nbr = row_cnt
    SET row_exists = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name="INBOX_COITEM_CNT"
      AND nvp.active_ind=1
     DETAIL
      row_exists = 1
     WITH nocounter
    ;end select
    IF (row_exists=1)
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_value = cnvtstring((row_cnt+ 1)), nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id =
       reqinfo->updt_id,
       nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
       .updt_applctx = reqinfo->updt_applctx
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=psn_detail_prefs_id
       AND nvp.pvc_name="INBOX_COITEM_CNT"
      WITH nocounter
     ;end update
    ELSE
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
     SET nvprequest->nvplist[1].parent_entity_id = psn_detail_prefs_id
     SET nvprequest->nvplist[1].pvc_name = "INBOX_COITEM_CNT"
     SET nvprequest->nvplist[1].pvc_value = "1"
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_cosign_folder(item_row_nbr,folder_pvc_value)
   SET row_name = concat("INBOX_COFOLDER",cnvtstring(item_row_nbr))
   SET row_exists = 0
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name=row_name
     AND nvp.active_ind=1
    DETAIL
     row_exists = 1
    WITH nocounter
   ;end select
   IF (row_exists=1)
    UPDATE  FROM name_value_prefs nvp
     SET nvp.pvc_value = folder_pvc_value, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->
      updt_id,
      nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
      .updt_applctx = reqinfo->updt_applctx
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name=row_name
     WITH nocounter
    ;end update
   ELSE
    SET stat = alterlist(nvprequest->nvplist,1)
    SET stat = alterlist(nvpreply->nvplist,1)
    SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
    SET nvprequest->nvplist[1].parent_entity_id = psn_detail_prefs_id
    SET nvprequest->nvplist[1].pvc_name = row_name
    SET nvprequest->nvplist[1].pvc_value = folder_pvc_value
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
 END ;Subroutine
 SUBROUTINE remove_cosign_rows(row_pvc_value)
   SET row_name = concat("INBOX_COITEM",cnvtstring(row_nbr))
   DELETE  FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name=row_name
     AND nvp.pvc_value=row_pvc_value
    WITH nocounter
   ;end delete
   SET row_name = concat("INBOX_COFOLDER",cnvtstring(row_nbr))
   DELETE  FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name=row_name
    WITH nocounter
   ;end delete
   SET old_row_number = (row_nbr+ 1)
   SET row_idx = (row_cnt - 1)
   FOR (old_row_number = old_row_number TO row_idx)
     SET nvp_id = 0.0
     SET row_name = concat("INBOX_COITEM",cnvtstring(old_row_number))
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=psn_detail_prefs_id
       AND nvp.pvc_name=row_name
       AND nvp.active_ind=1
      DETAIL
       nvp_id = nvp.name_value_prefs_id
      WITH nocounter
     ;end select
     SET row_name = concat("INBOX_COITEM",cnvtstring((old_row_number - 1)))
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_name = row_name, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->updt_id,
       nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
       .updt_applctx = reqinfo->updt_applctx
      WHERE nvp.name_value_prefs_id=nvp_id
      WITH nocounter
     ;end update
     SET nvp_id = 0.0
     SET row_name = concat("INBOX_COFOLDER",cnvtstring(old_row_number))
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=psn_detail_prefs_id
       AND nvp.pvc_name=row_name
       AND nvp.active_ind=1
      DETAIL
       nvp_id = nvp.name_value_prefs_id
      WITH nocounter
     ;end select
     SET row_name = concat("INBOX_COFOLDER",cnvtstring((old_row_number - 1)))
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_name = row_name, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->updt_id,
       nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
       .updt_applctx = reqinfo->updt_applctx
      WHERE nvp.name_value_prefs_id=nvp_id
      WITH nocounter
     ;end update
   ENDFOR
   UPDATE  FROM name_value_prefs nvp
    SET nvp.pvc_value = cnvtstring((row_cnt - 1)), nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id =
     reqinfo->updt_id,
     nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
     .updt_applctx = reqinfo->updt_applctx
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name="INBOX_COITEM_CNT"
    WITH nocounter
   ;end update
 END ;Subroutine
#exitscript
END GO

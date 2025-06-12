CREATE PROGRAM bed_get_ens_tasks_misc:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status_list[*]
       3 status = c1
     2 website_url = vc
     2 website_display = vc
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
 SET task_cnt = size(request->task_list,5)
 IF (task_cnt > 0)
  SET stat = alterlist(reply->status_data.status_list,task_cnt)
 ELSE
  GO TO exitscript
 ENDIF
 SET dummy_parm1 = 0
 SET dummy_parm2 = 0
 SET stat = alterlist(vprequest->vplist,1)
 SET stat = alterlist(vpreply->vplist,1)
 SET vprequest->vplist[1].application_number = request->application_number
 SET vprequest->vplist[1].position_cd = request->position_cd
 SET vprequest->vplist[1].prsnl_id = request->prsnl_id
 SET stat = alterlist(vcprequest->vcplist,1)
 SET stat = alterlist(vcpreply->vcplist,1)
 SET vcprequest->vcplist[1].application_number = request->application_number
 SET vcprequest->vcplist[1].position_cd = request->position_cd
 SET vcprequest->vcplist[1].prsnl_id = request->prsnl_id
 SET stat = alterlist(dprequest->dplist,1)
 SET dprequest->dplist[1].application_number = request->application_number
 SET dprequest->dplist[1].position_cd = request->position_cd
 SET dprequest->dplist[1].prsnl_id = request->prsnl_id
 SET dprequest->dplist[1].person_id = 0.0
 SET dprequest->dplist[1].view_name = "AUTHORIZE"
 SET dprequest->dplist[1].view_seq = 0
 SET dprequest->dplist[1].comp_name = "AUTHORIZE"
 SET dprequest->dplist[1].comp_seq = 0
 SET dprequest->dplist[1].action_flag = "0"
 SET trace = recpersist
 EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
 SET psn_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
 SET dprequest->dplist[1].position_cd = 0
 SET dprequest->dplist[1].action_flag = "0"
 SET trace = recpersist
 EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
 SET app_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
 SET dprequest->dplist[1].position_cd = request->position_cd
 IF ((request->action="0"))
  FOR (t = 1 TO task_cnt)
   SET reply->status_data.status_list[t].status = "0"
   IF ((request->task_list[t].task > " "))
    IF ((request->task_list[t].task IN ("VIEWSTICKYNOTES", "ADDSTICKYNOTES")))
     CALL get_stickynotes(dummy_parm1)
    ELSEIF ((request->task_list[t].task="REPORTS"))
     CALL get_reports(dummy_parm1)
    ELSE
     IF ((request->task_list[t].task="WEBSITE"))
      SET vprequest->vplist[1].view_seq = 1
      SET vcprequest->vcplist[1].view_seq = 1
      SET vcprequest->vcplist[1].comp_seq = 1
     ELSE
      SET vprequest->vplist[1].view_seq = 0
      SET vcprequest->vcplist[1].view_seq = 0
      SET vcprequest->vcplist[1].comp_seq = 0
     ENDIF
     CALL complete_vp_and_vcp(dummy_parm1)
     SET vprequest->vplist[1].action_flag = "0"
     SET trace = recpersist
     EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
     IF ((vpreply->vplist[1].view_prefs_id > 0))
      SET continue_check = 0
      IF ((((request->task_list[t].task="WEBSITE")) OR ((request->task_list[t].task="IANDO"))) )
       SET view_caption_row_exists = 0
       SET display_seq_row_exists = 0
       SELECT INTO "NL:"
        FROM name_value_prefs nvp
        WHERE nvp.parent_entity_name="VIEW_PREFS"
         AND (nvp.parent_entity_id=vpreply->vplist[1].view_prefs_id)
         AND ((nvp.pvc_name="VIEW_CAPTION") OR (nvp.pvc_name="DISPLAY_SEQ"))
         AND nvp.active_ind=1
        DETAIL
         IF (nvp.pvc_name="VIEW_CAPTION")
          view_caption_row_exists = 1
          IF ((request->task_list[t].task="WEBSITE"))
           reply->status_data.website_display = nvp.pvc_value
          ENDIF
         ELSEIF (nvp.pvc_name="DISPLAY_SEQ")
          display_seq_row_exists = 1
         ENDIF
        WITH nocounter
       ;end select
       IF (view_caption_row_exists=1
        AND display_seq_row_exists=1)
        SET continue_check = 1
       ENDIF
      ELSE
       CALL complete_vp_nvp(dummy_parm1)
       SET nvprequest->nvplist[1].action_flag = "0"
       SET nvprequest->nvplist[2].action_flag = "0"
       SET trace = recpersist
       EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
        nvpreply)
       IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
        AND (nvpreply->nvplist[2].name_value_prefs_id > 0))
        SET continue_check = 1
       ENDIF
      ENDIF
      IF (continue_check=1)
       SET vcprequest->vcplist[1].action_flag = "0"
       SET trace = recpersist
       EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",
        vcpreply)
       IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
        CALL complete_vcp_nvp(dummy_parm1)
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
         IF ((request->task_list[t].task="WEBSITE"))
          SET dprequest->dplist[1].view_name = "WEBSITE"
          SET dprequest->dplist[1].view_seq = 1
          SET dprequest->dplist[1].comp_name = "WEBSITE"
          SET dprequest->dplist[1].comp_seq = 1
          SET dprequest->dplist[1].action_flag = "0"
          SET trace = recpersist
          EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",
           dpreply)
          IF ((dpreply->dplist[1].detail_prefs_id > 0))
           SELECT INTO "NL:"
            FROM name_value_prefs nvp
            WHERE nvp.parent_entity_name="DETAIL_PREFS"
             AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
             AND nvp.pvc_name="DEFAULT_URL"
             AND nvp.active_ind=1
            DETAIL
             reply->status_data.status_list[t].status = "1", reply->status_data.website_url = nvp
             .pvc_value
            WITH nocounter
           ;end select
          ENDIF
         ELSE
          SET reply->status_data.status_list[t].status = "1"
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDFOR
 ELSEIF ((request->action="2"))
  FOR (t = 1 TO task_cnt)
    IF ((request->task_list[t].task > " "))
     IF ((request->task_list[t].task IN ("VIEWSTICKYNOTES", "ADDSTICKYNOTES")))
      CALL ens_stickynotes(dummy_parm1)
     ELSEIF ((request->task_list[t].task="REPORTS"))
      CALL ens_reports(dummy_parm1)
     ELSE
      IF ((request->task_list[t].on_off_ind=1))
       IF ((request->task_list[t].task="WEBSITE"))
        SET vprequest->vplist[1].view_seq = 1
        SET vcprequest->vcplist[1].view_seq = 1
        SET vcprequest->vcplist[1].comp_seq = 1
       ELSE
        SET vprequest->vplist[1].view_seq = 0
        SET vcprequest->vcplist[1].view_seq = 0
        SET vcprequest->vcplist[1].comp_seq = 0
       ENDIF
       CALL complete_vp_and_vcp(dummy_parm1)
       SET vprequest->vplist[1].action_flag = "0"
       SET trace = recpersist
       EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
       IF ((vpreply->vplist[1].view_prefs_id=0))
        SET vprequest->vplist[1].action_flag = "1"
        SET trace = recpersist
        EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
       ENDIF
       IF ((vpreply->vplist[1].view_prefs_id > 0))
        IF ((((request->task_list[t].task="WEBSITE")) OR ((request->task_list[t].task="IANDO"))) )
         SET stat = alterlist(nvprequest->nvplist,1)
         SET stat = alterlist(nvpreply->nvplist,1)
         SET nvprequest->nvplist[1].parent_entity_name = "VIEW_PREFS"
         SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
         SET view_caption_row_exists = 0
         SET view_caption_value = fillstring(256," ")
         SELECT INTO "NL:"
          FROM name_value_prefs nvp
          WHERE nvp.parent_entity_name="VIEW_PREFS"
           AND (nvp.parent_entity_id=vpreply->vplist[1].view_prefs_id)
           AND nvp.pvc_name="VIEW_CAPTION"
           AND nvp.active_ind=1
          DETAIL
           view_caption_row_exists = 1, view_caption_value = nvp.pvc_value
          WITH nocounter
         ;end select
         IF (view_caption_row_exists=0)
          SET nvprequest->nvplist[1].pvc_name = "VIEW_CAPTION"
          IF ((request->task_list[t].task="WEBSITE"))
           SET nvprequest->nvplist[1].pvc_value = request->website_display
          ELSE
           SET nvprequest->nvplist[1].pvc_value = "Intake and Output"
          ENDIF
          SET nvprequest->nvplist[1].action_flag = "1"
          SET trace = recpersist
          EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
           nvpreply)
         ELSE
          IF ((request->task_list[t].task="WEBSITE")
           AND (view_caption_value != request->website_display))
           SET nvprequest->nvplist[1].pvc_name = "VIEW_CAPTION"
           SET nvprequest->nvplist[1].pvc_value = request->website_display
           SET nvprequest->nvplist[1].action_flag = "2"
           SET trace = recpersist
           EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
            nvpreply)
          ENDIF
         ENDIF
         SET display_seq_row_exists = 0
         SELECT INTO "NL:"
          FROM name_value_prefs nvp
          WHERE nvp.parent_entity_name="VIEW_PREFS"
           AND (nvp.parent_entity_id=vpreply->vplist[1].view_prefs_id)
           AND nvp.pvc_name="DISPLAY_SEQ"
           AND nvp.active_ind=1
          DETAIL
           display_seq_row_exists = 1
          WITH nocounter
         ;end select
         IF (display_seq_row_exists=0)
          CALL complete_display_seq(dummy_parm1)
          SET nvprequest->nvplist[1].pvc_name = "DISPLAY_SEQ"
          SET nvprequest->nvplist[1].action_flag = "1"
          SET trace = recpersist
          EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
           nvpreply)
         ENDIF
        ELSE
         CALL complete_vp_nvp(dummy_parm1)
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
          CALL complete_display_seq(dummy_parm1)
          SET nvprequest->nvplist[1].pvc_name = "DISPLAY_SEQ"
          SET nvprequest->nvplist[1].action_flag = "1"
          SET trace = recpersist
          EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
           nvpreply)
         ENDIF
        ENDIF
       ENDIF
       SET vcprequest->vcplist[1].action_flag = "0"
       SET trace = recpersist
       EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",
        vcpreply)
       IF ((vcpreply->vcplist[1].view_comp_prefs_id=0))
        SET vcprequest->vcplist[1].action_flag = "1"
        SET trace = recpersist
        EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",
         vcpreply)
       ENDIF
       IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
        CALL complete_vcp_nvp(dummy_parm1)
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
         CALL create_individual_nvp(dummy_parm1)
        ENDIF
       ENDIF
       IF ((request->task_list[t].task="WEBSITE"))
        SET dprequest->dplist[1].view_name = "WEBSITE"
        SET dprequest->dplist[1].view_seq = 1
        SET dprequest->dplist[1].comp_name = "WEBSITE"
        SET dprequest->dplist[1].comp_seq = 1
        SET dprequest->dplist[1].action_flag = "0"
        SET trace = recpersist
        EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
        IF ((dpreply->dplist[1].detail_prefs_id=0))
         SET dprequest->dplist[1].action_flag = "1"
         SET trace = recpersist
         EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply
          )
        ENDIF
        IF ((dpreply->dplist[1].detail_prefs_id > 0))
         SET stat = alterlist(nvprequest->nvplist,1)
         SET stat = alterlist(nvpreply->nvplist,1)
         SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
         SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
         SET default_url_row_exists = 0
         SET default_url_value = fillstring(256," ")
         SELECT INTO "NL:"
          FROM name_value_prefs nvp
          WHERE nvp.parent_entity_name="DETAIL_PREFS"
           AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
           AND nvp.pvc_name="DEFAULT_URL"
           AND nvp.active_ind=1
          DETAIL
           default_url_row_exists = 1, default_url_value = nvp.pvc_value
          WITH nocounter
         ;end select
         IF (default_url_row_exists=0)
          SET nvprequest->nvplist[1].pvc_name = "DEFAULT_URL"
          SET nvprequest->nvplist[1].pvc_value = request->website_url
          SET nvprequest->nvplist[1].action_flag = "1"
          SET trace = recpersist
          EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
           nvpreply)
         ELSE
          IF ((default_url_value != request->website_url))
           SET nvprequest->nvplist[1].pvc_name = "DEFAULT_URL"
           SET nvprequest->nvplist[1].pvc_value = request->website_url
           SET nvprequest->nvplist[1].action_flag = "2"
           SET trace = recpersist
           EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
            nvpreply)
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ELSE
       IF ((request->task_list[t].task="WEBSITE"))
        SET vprequest->vplist[1].view_seq = 1
        SET vcprequest->vcplist[1].view_seq = 1
        SET vcprequest->vcplist[1].comp_seq = 1
       ELSE
        SET vprequest->vplist[1].view_seq = 0
        SET vcprequest->vcplist[1].view_seq = 0
        SET vcprequest->vcplist[1].comp_seq = 0
       ENDIF
       CALL complete_vp_and_vcp(dummy_parm1)
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
        IF ((((request->task_list[t].task="WEBSITE")) OR ((request->task_list[t].task="IANDO"))) )
         DELETE  FROM name_value_prefs nvp
          WHERE nvp.parent_entity_name="VIEW_PREFS"
           AND (nvp.parent_entity_id=nvprequest->nvplist[1].parent_entity_id)
           AND nvp.pvc_name="DISPLAY_SEQ"
          WITH nocounter
         ;end delete
         DELETE  FROM name_value_prefs nvp
          WHERE nvp.parent_entity_name="VIEW_PREFS"
           AND (nvp.parent_entity_id=nvprequest->nvplist[1].parent_entity_id)
           AND nvp.pvc_name="VIEW_CAPTION"
          WITH nocounter
         ;end delete
        ELSE
         SET nvprequest->nvplist[1].action_flag = "3"
         SET nvprequest->nvplist[2].action_flag = "3"
         SET trace = recpersist
         EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
          nvpreply)
        ENDIF
       ENDIF
       SET vcprequest->vcplist[1].action_flag = "0"
       SET trace = recpersist
       EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",
        vcpreply)
       IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
        CALL complete_vcp_nvp(dummy_parm1)
        SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
        SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
        SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
        SET nvprequest->nvplist[4].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
        SET nvprequest->nvplist[5].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
        SET vcprequest->vcplist[1].action_flag = "3"
        SET trace = recpersist
        EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",
         vcpreply)
        SET nvprequest->nvplist[1].action_flag = "3"
        SET nvprequest->nvplist[2].action_flag = "3"
        SET nvprequest->nvplist[3].action_flag = "3"
        SET nvprequest->nvplist[4].action_flag = "3"
        SET nvprequest->nvplist[5].action_flag = "3"
        SET trace = recpersist
        EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
         nvpreply)
       ENDIF
       IF ((request->task_list[t].task="WEBSITE"))
        SET dprequest->dplist[1].view_name = "WEBSITE"
        SET dprequest->dplist[1].view_seq = 1
        SET dprequest->dplist[1].comp_name = "WEBSITE"
        SET dprequest->dplist[1].comp_seq = 1
        SET dprequest->dplist[1].action_flag = "0"
        SET trace = recpersist
        EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
        IF ((dpreply->dplist[1].detail_prefs_id > 0))
         SET dprequest->dplist[1].action_flag = "3"
         SET trace = recpersist
         EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply
          )
         DELETE  FROM name_value_prefs nvp
          WHERE nvp.parent_entity_name="DETAIL_PREFS"
           AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
           AND nvp.pvc_name="DEFAULT_URL"
          WITH nocounter
         ;end delete
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 GO TO exitscript
 SUBROUTINE complete_vp_and_vcp(dummy_parm2)
   IF ((request->task_list[t].task="PATIENTLIST"))
    SET vprequest->vplist[1].frame_type = "ORG"
    SET vprequest->vplist[1].view_name = "PTLIST"
    SET vcprequest->vcplist[1].view_name = "PTLIST"
    SET vcprequest->vcplist[1].comp_name = "PTLIST"
   ELSEIF ((request->task_list[t].task="INTELLISTRIP"))
    SET vprequest->vplist[1].frame_type = "CHART"
    SET vprequest->vplist[1].view_name = "INTELLISTRIP"
    SET vcprequest->vcplist[1].view_name = "INTELLISTRIP"
    SET vcprequest->vcplist[1].comp_name = "INTELLISTRIP"
   ELSEIF ((request->task_list[t].task="PROVRELTN"))
    SET vprequest->vplist[1].frame_type = "CHART"
    SET vprequest->vplist[1].view_name = "PPRSUMMARY"
    SET vcprequest->vcplist[1].view_name = "PPRSUMMARY"
    SET vcprequest->vcplist[1].comp_name = "PPRSUMMARY"
   ELSEIF ((request->task_list[t].task="ENCOUNTERS"))
    SET vprequest->vplist[1].frame_type = "CHART"
    SET vprequest->vplist[1].view_name = "ENCOUNTER"
    SET vcprequest->vcplist[1].view_name = "ENCOUNTER"
    SET vcprequest->vcplist[1].comp_name = "ENCOUNTER"
   ELSEIF ((request->task_list[t].task="HEALTHPLANS"))
    SET vprequest->vplist[1].frame_type = "CHART"
    SET vprequest->vplist[1].view_name = "HEALTHPLAN"
    SET vcprequest->vcplist[1].view_name = "HEALTHPLAN"
    SET vcprequest->vcplist[1].comp_name = "HEALTHPLAN"
   ELSEIF ((request->task_list[t].task="POWERORDERS"))
    SET vprequest->vplist[1].frame_type = "CHART"
    SET vprequest->vplist[1].view_name = "ORDERPOE"
    SET vcprequest->vcplist[1].view_name = "ORDERPOE"
    SET vcprequest->vcplist[1].comp_name = "ORDERPOE"
   ELSEIF ((request->task_list[t].task="MAR"))
    SET vprequest->vplist[1].frame_type = "CHART"
    SET vprequest->vplist[1].view_name = "MAR"
    SET vcprequest->vcplist[1].view_name = "MAR"
    SET vcprequest->vcplist[1].comp_name = "MAR"
   ELSEIF ((request->task_list[t].task="WEBSITE"))
    SET vprequest->vplist[1].frame_type = "ORG"
    SET vprequest->vplist[1].view_name = "WEBSITE"
    SET vcprequest->vcplist[1].view_name = "WEBSITE"
    SET vcprequest->vcplist[1].comp_name = "WEBSITE"
   ELSEIF ((request->task_list[t].task="SHIFTASSIGN"))
    SET vprequest->vplist[1].frame_type = "ORG"
    SET vprequest->vplist[1].view_name = "SHIFTASSIGNM"
    SET vcprequest->vcplist[1].view_name = "SHIFTASSIGNM"
    SET vcprequest->vcplist[1].comp_name = "SHIFTASSIGNM"
   ELSEIF ((request->task_list[t].task="COSIGNORDER"))
    SET vprequest->vplist[1].frame_type = "CHART"
    SET vprequest->vplist[1].view_name = "ORDERSIG"
    SET vcprequest->vcplist[1].view_name = "ORDERSIG"
    SET vcprequest->vcplist[1].comp_name = "ORDERSIG"
   ELSEIF ((request->task_list[t].task="ADVGRAPH"))
    SET vprequest->vplist[1].frame_type = "CHART"
    SET vprequest->vplist[1].view_name = "PREDGRAPH"
    SET vcprequest->vcplist[1].view_name = "PREDGRAPH"
    SET vcprequest->vcplist[1].comp_name = "PREDGRAPH"
   ELSEIF ((request->task_list[t].task="IANDO"))
    SET vprequest->vplist[1].frame_type = "CHART"
    SET vprequest->vplist[1].view_name = "I&O"
    SET vcprequest->vcplist[1].view_name = "I&O"
    SET vcprequest->vcplist[1].comp_name = "I&O"
   ELSEIF ((request->task_list[t].task="CHARTSUMMARY"))
    SET vprequest->vplist[1].frame_type = "CHART"
    SET vprequest->vplist[1].view_name = "CHARTSUMMARY"
    SET vcprequest->vcplist[1].view_name = "CHARTSUMMARY"
    SET vcprequest->vcplist[1].comp_name = "CHARTSUMMARY"
   ELSEIF ((request->task_list[t].task="PATIENTACCESS"))
    SET vprequest->vplist[1].frame_type = "ORG"
    SET vprequest->vplist[1].view_name = "Patient Info"
    SET vcprequest->vcplist[1].view_name = "Patient Info"
    SET vcprequest->vcplist[1].comp_name = "Patient Info"
   ENDIF
 END ;Subroutine
 SUBROUTINE complete_vp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,2)
   SET stat = alterlist(nvpreply->nvplist,2)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[1].pvc_name = "VIEW_CAPTION"
   SET nvprequest->nvplist[2].pvc_name = "DISPLAY_SEQ"
   IF ((request->task_list[t].task="PATIENTLIST"))
    SET nvprequest->nvplist[1].pvc_value = "Patient List"
    SET nvprequest->nvplist[2].pvc_value = "26"
   ELSEIF ((request->task_list[t].task="INTELLISTRIP"))
    SET nvprequest->nvplist[1].pvc_value = "Intellistrip"
    SET nvprequest->nvplist[2].pvc_value = "18"
   ELSEIF ((request->task_list[t].task="PROVRELTN"))
    SET nvprequest->nvplist[1].pvc_value = "Provider Relationships"
    SET nvprequest->nvplist[2].pvc_value = "32"
   ELSEIF ((request->task_list[t].task="ENCOUNTERS"))
    SET nvprequest->nvplist[1].pvc_value = "Encounters"
    SET nvprequest->nvplist[2].pvc_value = "9"
   ELSEIF ((request->task_list[t].task="HEALTHPLANS"))
    SET nvprequest->nvplist[1].pvc_value = "Health Plans"
    SET nvprequest->nvplist[2].pvc_value = "14"
   ELSEIF ((request->task_list[t].task="POWERORDERS"))
    SET nvprequest->nvplist[1].pvc_value = "PowerOrders"
    SET nvprequest->nvplist[2].pvc_value = "29"
   ELSEIF ((request->task_list[t].task="MAR"))
    SET nvprequest->nvplist[1].pvc_value = "MAR"
    SET nvprequest->nvplist[2].pvc_value = "20"
   ELSEIF ((request->task_list[t].task="WEBSITE"))
    SET nvprequest->nvplist[1].pvc_value = "Website"
    SET nvprequest->nvplist[2].pvc_value = "39"
   ELSEIF ((request->task_list[t].task="SHIFTASSIGN"))
    SET nvprequest->nvplist[1].pvc_value = "Shift Assignment"
    SET nvprequest->nvplist[2].pvc_value = "35"
   ELSEIF ((request->task_list[t].task="COSIGNORDER"))
    SET nvprequest->nvplist[1].pvc_value = "Cosign Order"
    SET nvprequest->nvplist[2].pvc_value = "6"
   ELSEIF ((request->task_list[t].task="ADVGRAPH"))
    SET nvprequest->nvplist[1].pvc_value = "Advanced Graphing"
    SET nvprequest->nvplist[2].pvc_value = "2"
   ELSEIF ((request->task_list[t].task="IANDO"))
    SET nvprequest->nvplist[1].pvc_value = "Intake and Output"
    SET nvprequest->nvplist[2].pvc_value = "17"
   ELSEIF ((request->task_list[t].task="CHARTSUMMARY"))
    SET nvprequest->nvplist[1].pvc_value = "Chart Summary"
    SET nvprequest->nvplist[2].pvc_value = "4"
   ELSEIF ((request->task_list[t].task="PATIENTACCESS"))
    SET nvprequest->nvplist[1].pvc_value = "Patient Access List"
    SET nvprequest->nvplist[2].pvc_value = "24"
   ENDIF
 END ;Subroutine
 SUBROUTINE complete_vcp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,5)
   SET stat = alterlist(nvpreply->nvplist,5)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[3].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[4].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[5].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
   SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
   SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
   SET nvprequest->nvplist[4].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
   SET nvprequest->nvplist[5].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
   SET nvprequest->nvplist[1].pvc_name = "COMP_DLLNAME"
   SET nvprequest->nvplist[2].pvc_name = "COMP_TYPE"
   SET nvprequest->nvplist[3].pvc_name = "LIST_VIEW"
   SET nvprequest->nvplist[4].pvc_name = "PREFMGR_ENABLED"
   SET nvprequest->nvplist[5].pvc_name = "COMMAND_ID"
   IF ((request->task_list[t].task="PATIENTLIST"))
    SET nvprequest->nvplist[1].pvc_value = "PVPatientList.dll"
    SET nvprequest->nvplist[2].pvc_value = "0"
    SET nvprequest->nvplist[3].pvc_value = "0"
    SET nvprequest->nvplist[4].pvc_value = "0"
    SET nvprequest->nvplist[5].pvc_value = "0"
   ELSEIF ((request->task_list[t].task="INTELLISTRIP"))
    SET nvprequest->nvplist[1].pvc_value = "isdll.dll"
    SET nvprequest->nvplist[2].pvc_value = "0"
    SET nvprequest->nvplist[3].pvc_value = "0"
    SET nvprequest->nvplist[4].pvc_value = "0"
    SET nvprequest->nvplist[5].pvc_value = "33240"
   ELSEIF ((request->task_list[t].task="PROVRELTN"))
    SET nvprequest->nvplist[1].pvc_value = "PVDemogPPR.dll"
    SET nvprequest->nvplist[2].pvc_value = "0"
    SET nvprequest->nvplist[3].pvc_value = "1"
    SET nvprequest->nvplist[4].pvc_value = "0"
    SET nvprequest->nvplist[5].pvc_value = "0"
   ELSEIF ((request->task_list[t].task="ENCOUNTERS"))
    SET nvprequest->nvplist[1].pvc_value = "CPSSection.dll"
    SET nvprequest->nvplist[2].pvc_value = "0"
    SET nvprequest->nvplist[3].pvc_value = "1"
    SET nvprequest->nvplist[4].pvc_value = "0"
    SET nvprequest->nvplist[5].pvc_value = "0"
   ELSEIF ((request->task_list[t].task="HEALTHPLANS"))
    SET nvprequest->nvplist[1].pvc_value = "CPSUIHealthPlan.dll"
    SET nvprequest->nvplist[2].pvc_value = "0"
    SET nvprequest->nvplist[3].pvc_value = "1"
    SET nvprequest->nvplist[4].pvc_value = "0"
    SET nvprequest->nvplist[5].pvc_value = "0"
   ELSEIF ((request->task_list[t].task="POWERORDERS"))
    SET nvprequest->nvplist[1].pvc_value = "PVOrderpoe.dll"
    SET nvprequest->nvplist[2].pvc_value = "0"
    SET nvprequest->nvplist[3].pvc_value = "0"
    SET nvprequest->nvplist[4].pvc_value = "0"
    SET nvprequest->nvplist[5].pvc_value = "33249"
   ELSEIF ((request->task_list[t].task="MAR"))
    SET nvprequest->nvplist[1].pvc_value = "PVMAR.dll"
    SET nvprequest->nvplist[2].pvc_value = "0"
    SET nvprequest->nvplist[3].pvc_value = "0"
    SET nvprequest->nvplist[4].pvc_value = "0"
    SET nvprequest->nvplist[5].pvc_value = "0"
   ELSEIF ((request->task_list[t].task="WEBSITE"))
    SET nvprequest->nvplist[1].pvc_value = "CPSSection.dll"
    SET nvprequest->nvplist[2].pvc_value = "0"
    SET nvprequest->nvplist[3].pvc_value = "0"
    SET nvprequest->nvplist[4].pvc_value = "0"
    SET nvprequest->nvplist[5].pvc_value = "0"
   ELSEIF ((request->task_list[t].task="SHIFTASSIGN"))
    SET nvprequest->nvplist[1].pvc_value = "pvshiftassignment.dll"
    SET nvprequest->nvplist[2].pvc_value = "0"
    SET nvprequest->nvplist[3].pvc_value = "0"
    SET nvprequest->nvplist[4].pvc_value = "0"
    SET nvprequest->nvplist[5].pvc_value = "0"
   ELSEIF ((request->task_list[t].task="COSIGNORDER"))
    SET nvprequest->nvplist[1].pvc_value = "pvordersig.dll"
    SET nvprequest->nvplist[2].pvc_value = "0"
    SET nvprequest->nvplist[3].pvc_value = "0"
    SET nvprequest->nvplist[4].pvc_value = "0"
    SET nvprequest->nvplist[5].pvc_value = "0"
   ELSEIF ((request->task_list[t].task="ADVGRAPH"))
    SET nvprequest->nvplist[1].pvc_value = "PVPredGraph.dll"
    SET nvprequest->nvplist[2].pvc_value = "0"
    SET nvprequest->nvplist[3].pvc_value = "0"
    SET nvprequest->nvplist[4].pvc_value = "0"
    SET nvprequest->nvplist[5].pvc_value = "0"
   ELSEIF ((request->task_list[t].task="IANDO"))
    SET nvprequest->nvplist[1].pvc_value = "PVINO.dll"
    SET nvprequest->nvplist[2].pvc_value = "0"
    SET nvprequest->nvplist[3].pvc_value = "0"
    SET nvprequest->nvplist[4].pvc_value = "0"
    SET nvprequest->nvplist[5].pvc_value = "0"
   ELSEIF ((request->task_list[t].task="CHARTSUMMARY"))
    SET nvprequest->nvplist[1].pvc_value = "CPSChartSummary.dll"
    SET nvprequest->nvplist[2].pvc_value = "0"
    SET nvprequest->nvplist[3].pvc_value = "0"
    SET nvprequest->nvplist[4].pvc_value = "0"
    SET nvprequest->nvplist[5].pvc_value = "0"
   ELSEIF ((request->task_list[t].task="PATIENTACCESS"))
    SET nvprequest->nvplist[1].pvc_value = "PVPIP.dll"
    SET nvprequest->nvplist[2].pvc_value = "0"
    SET nvprequest->nvplist[3].pvc_value = "0"
    SET nvprequest->nvplist[4].pvc_value = "0"
    SET nvprequest->nvplist[5].pvc_value = "0"
   ENDIF
 END ;Subroutine
 SUBROUTINE complete_display_seq(dummy_parm2)
   IF ((request->task_list[t].task="PATIENTLIST"))
    SET nvprequest->nvplist[1].pvc_value = "26"
   ELSEIF ((request->task_list[t].task="INTELLISTRIP"))
    SET nvprequest->nvplist[1].pvc_value = "18"
   ELSEIF ((request->task_list[t].task="PROVRELTN"))
    SET nvprequest->nvplist[1].pvc_value = "32"
   ELSEIF ((request->task_list[t].task="ENCOUNTERS"))
    SET nvprequest->nvplist[1].pvc_value = "9"
   ELSEIF ((request->task_list[t].task="HEALTHPLANS"))
    SET nvprequest->nvplist[1].pvc_value = "14"
   ELSEIF ((request->task_list[t].task="POWERORDERS"))
    SET nvprequest->nvplist[1].pvc_value = "29"
   ELSEIF ((request->task_list[t].task="MAR"))
    SET nvprequest->nvplist[1].pvc_value = "20"
   ELSEIF ((request->task_list[t].task="WEBSITE"))
    SET nvprequest->nvplist[1].pvc_value = "39"
   ELSEIF ((request->task_list[t].task="SHIFTASSIGN"))
    SET nvprequest->nvplist[1].pvc_value = "35"
   ELSEIF ((request->task_list[t].task="COSIGNORDER"))
    SET nvprequest->nvplist[1].pvc_value = "6"
   ELSEIF ((request->task_list[t].task="ADVGRAPH"))
    SET nvprequest->nvplist[1].pvc_value = "2"
   ELSEIF ((request->task_list[t].task="IANDO"))
    SET nvprequest->nvplist[1].pvc_value = "17"
   ELSEIF ((request->task_list[t].task="CHARTSUMMARY"))
    SET nvprequest->nvplist[1].pvc_value = "4"
   ELSEIF ((request->task_list[t].task="PATIENTACCESS"))
    SET nvprequest->nvplist[1].pvc_value = "24"
   ENDIF
 END ;Subroutine
 SUBROUTINE create_individual_nvp(dummy_parm2)
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
    IF ((request->task_list[t].task IN ("PROVRELTN", "ENCOUNTERS", "HEALTHPLANS")))
     SET nvprequest->nvplist[1].pvc_value = "1"
    ELSE
     SET nvprequest->nvplist[1].pvc_value = "0"
    ENDIF
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
    IF ((request->task_list[t].task="INTELLISTRIP"))
     SET nvprequest->nvplist[1].pvc_value = "33240"
    ELSEIF ((request->task_list[t].task="POWERORDERS"))
     SET nvprequest->nvplist[1].pvc_value = "33249"
    ELSE
     SET nvprequest->nvplist[1].pvc_value = "0"
    ENDIF
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_stickynotes(dummy_parm2)
   IF ((request->task_list[t].task="VIEWSTICKYNOTES"))
    SET pvc_name = "COMMAND_33423"
   ELSEIF ((request->task_list[t].task="ADDSTICKYNOTES"))
    SET pvc_name = "COMMAND_32893"
   ENDIF
   SET nvp_value = "  "
   SET nvp_exists = 0
   IF (psn_detail_prefs_id > 0)
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name=pvc_name
      AND nvp.active_ind=1
     DETAIL
      nvp_exists = 1, nvp_value = nvp.pvc_value
     WITH nocounter
    ;end select
   ENDIF
   IF (((psn_detail_prefs_id=0) OR (nvp_exists=0)) )
    IF (app_detail_prefs_id > 0)
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=app_detail_prefs_id
       AND nvp.pvc_name=pvc_name
       AND nvp.active_ind=1
      DETAIL
       nvp_value = nvp.pvc_value
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (nvp_value="1")
    SET reply->status_data.status_list[t].status = "1"
   ENDIF
 END ;Subroutine
 SUBROUTINE get_reports(dummy_parm2)
   SET nvp_value1 = "  "
   SET nvp_exists1 = 0
   SET nvp_value2 = "  "
   SET nvp_exists2 = 0
   SET nvp_value3 = "  "
   SET nvp_exists3 = 0
   SET pvc_name = "COMMAND_32938"
   IF (psn_detail_prefs_id > 0)
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name=pvc_name
      AND nvp.active_ind=1
     DETAIL
      nvp_exists1 = 1, nvp_value1 = nvp.pvc_value
     WITH nocounter
    ;end select
   ENDIF
   IF (((psn_detail_prefs_id=0) OR (nvp_exists1=0)) )
    IF (app_detail_prefs_id > 0)
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=app_detail_prefs_id
       AND nvp.pvc_name=pvc_name
       AND nvp.active_ind=1
      DETAIL
       nvp_value1 = nvp.pvc_value
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (nvp_value1 != "1")
    SET pvc_name = "COMMAND_33428"
    IF (psn_detail_prefs_id > 0)
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=psn_detail_prefs_id
       AND nvp.pvc_name=pvc_name
       AND nvp.active_ind=1
      DETAIL
       nvp_exists2 = 1, nvp_value2 = nvp.pvc_value
      WITH nocounter
     ;end select
    ENDIF
    IF (((psn_detail_prefs_id=0) OR (nvp_exists2=0)) )
     IF (app_detail_prefs_id > 0)
      SELECT INTO "NL:"
       FROM name_value_prefs nvp
       WHERE nvp.parent_entity_name="DETAIL_PREFS"
        AND nvp.parent_entity_id=app_detail_prefs_id
        AND nvp.pvc_name=pvc_name
        AND nvp.active_ind=1
       DETAIL
        nvp_value2 = nvp.pvc_value
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
    IF (nvp_value2 != "1")
     SET pvc_name = "COMMAND_33336"
     IF (psn_detail_prefs_id > 0)
      SELECT INTO "NL:"
       FROM name_value_prefs nvp
       WHERE nvp.parent_entity_name="DETAIL_PREFS"
        AND nvp.parent_entity_id=psn_detail_prefs_id
        AND nvp.pvc_name=pvc_name
        AND nvp.active_ind=1
       DETAIL
        nvp_exists3 = 1, nvp_value3 = nvp.pvc_value
       WITH nocounter
      ;end select
     ENDIF
     IF (((psn_detail_prefs_id=0) OR (nvp_exists3=0)) )
      IF (app_detail_prefs_id > 0)
       SELECT INTO "NL:"
        FROM name_value_prefs nvp
        WHERE nvp.parent_entity_name="DETAIL_PREFS"
         AND nvp.parent_entity_id=app_detail_prefs_id
         AND nvp.pvc_name=pvc_name
         AND nvp.active_ind=1
        DETAIL
         nvp_value3 = nvp.pvc_value
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (((nvp_value1="1") OR (((nvp_value2="1") OR (nvp_value3="1")) )) )
    SET reply->status_data.status_list[t].status = "1"
   ENDIF
 END ;Subroutine
 SUBROUTINE ens_stickynotes(dummy_parm2)
   IF ((request->task_list[t].task="VIEWSTICKYNOTES"))
    SET pvc_name = "COMMAND_33423"
   ELSEIF ((request->task_list[t].task="ADDSTICKYNOTES"))
    SET pvc_name = "COMMAND_32893"
   ENDIF
   SET nvp_value = "  "
   SET nvp_exists = 0
   IF (psn_detail_prefs_id > 0)
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name=pvc_name
      AND nvp.active_ind=1
     DETAIL
      nvp_exists = 1, nvp_value = nvp.pvc_value
     WITH nocounter
    ;end select
   ELSE
    SET dprequest->dplist[1].view_name = "AUTHORIZE"
    SET dprequest->dplist[1].view_seq = 0
    SET dprequest->dplist[1].comp_name = "AUTHORIZE"
    SET dprequest->dplist[1].comp_seq = 0
    SET dprequest->dplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
    SET psn_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
   ENDIF
   SET stat = alterlist(nvprequest->nvplist,1)
   SET stat = alterlist(nvpreply->nvplist,1)
   SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
   SET nvprequest->nvplist[1].parent_entity_id = psn_detail_prefs_id
   SET nvprequest->nvplist[1].pvc_name = pvc_name
   IF ((request->task_list[t].on_off_ind=1))
    IF (nvp_exists > 0)
     IF (nvp_value != "1")
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
     IF (nvp_value != "-2")
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
 END ;Subroutine
 SUBROUTINE ens_reports(dummy_parm2)
   SET pvc_name = "COMMAND_32938"
   SET nvp_value = "  "
   SET nvp_exists = 0
   IF (psn_detail_prefs_id > 0)
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=psn_detail_prefs_id
      AND nvp.pvc_name=pvc_name
      AND nvp.active_ind=1
     DETAIL
      nvp_exists = 1, nvp_value = nvp.pvc_value
     WITH nocounter
    ;end select
   ELSE
    SET dprequest->dplist[1].view_name = "AUTHORIZE"
    SET dprequest->dplist[1].view_seq = 0
    SET dprequest->dplist[1].comp_name = "AUTHORIZE"
    SET dprequest->dplist[1].comp_seq = 0
    SET dprequest->dplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
    SET psn_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
   ENDIF
   SET stat = alterlist(nvprequest->nvplist,1)
   SET stat = alterlist(nvpreply->nvplist,1)
   SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
   SET nvprequest->nvplist[1].parent_entity_id = psn_detail_prefs_id
   SET nvprequest->nvplist[1].pvc_name = pvc_name
   IF ((request->task_list[t].on_off_ind=1))
    IF (nvp_exists > 0)
     IF (nvp_value != "1")
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
     IF (nvp_value != "-2")
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
   SET pvc_name = "COMMAND_33428"
   SET nvp_value = "  "
   SET nvp_exists = 0
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name=pvc_name
     AND nvp.active_ind=1
    DETAIL
     nvp_exists = 1, nvp_value = nvp.pvc_value
    WITH nocounter
   ;end select
   SET stat = alterlist(nvprequest->nvplist,1)
   SET stat = alterlist(nvpreply->nvplist,1)
   SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
   SET nvprequest->nvplist[1].parent_entity_id = psn_detail_prefs_id
   SET nvprequest->nvplist[1].pvc_name = pvc_name
   IF ((request->task_list[t].on_off_ind=1))
    IF (nvp_exists > 0)
     IF (nvp_value != "1")
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
     IF (nvp_value != "-2")
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
   SET pvc_name = "COMMAND_33336"
   SET nvp_value = "  "
   SET nvp_exists = 0
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=psn_detail_prefs_id
     AND nvp.pvc_name=pvc_name
     AND nvp.active_ind=1
    DETAIL
     nvp_exists = 1, nvp_value = nvp.pvc_value
    WITH nocounter
   ;end select
   SET stat = alterlist(nvprequest->nvplist,1)
   SET stat = alterlist(nvpreply->nvplist,1)
   SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
   SET nvprequest->nvplist[1].parent_entity_id = psn_detail_prefs_id
   SET nvprequest->nvplist[1].pvc_name = pvc_name
   IF (nvp_exists > 0)
    IF (nvp_value != "-2")
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
 END ;Subroutine
#exitscript
END GO

CREATE PROGRAM bed_get_ens_tasks_pthistrslt:dba
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
 RECORD ordtaskrequest(
   1 action_flag = c1
   1 position_cd = f8
   1 olist[*]
     2 order_task_id = f8
 )
 FREE SET ordtaskreply
 RECORD ordtaskreply(
   1 olist[*]
     2 task_exists = i2
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
 RECORD multitaskrequest(
   1 action = c1
   1 task_list[*]
     2 task = c50
     2 on_off_ind = i2
   1 application_number = i4
   1 position_cd = f8
   1 prsnl_id = f8
 )
 FREE SET multitaskreply
 RECORD multitaskreply(
   1 status_data
     2 status_list[*]
       3 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD flowsheets(
   1 flist[*]
     2 pvc_value = c256
     2 view_seq = i4
     2 vp_id = f8
 )
 RECORD posordinfo(
   1 plist[*]
     2 view_prefs_id = f8
     2 view_name = c12
     2 view_seq = i4
 )
 RECORD appordinfo(
   1 alist[*]
     2 view_prefs_id = f8
     2 view_name = c12
     2 view_seq = i4
 )
 SET phys_ind = 0
 SELECT INTO "nl:"
  FROM br_position_cat_comp bpcc,
   br_position_category bpc
  PLAN (bpcc
   WHERE (bpcc.position_cd=request->position_cd))
   JOIN (bpc
   WHERE bpc.category_id=bpcc.category_id)
  ORDER BY bpcc.category_id, bpcc.position_cd
  HEAD bpcc.position_cd
   IF (bpc.step_cat_mean="ACUTE")
    phys_ind = bpcc.physician_ind
   ENDIF
  WITH nocounter
 ;end select
 SET adm_hist_adult_id = 0.0
 SET adm_hist_ped_id = 0.0
 SET adm_hist_newb_id = 0.0
 SET adult_amb_pat_hist_id = 0.0
 SET ped_amb_pat_hist_id = 0.0
 SELECT INTO "NL:"
  FROM order_task ot
  WHERE ot.active_ind=1
   AND ot.task_description IN ("Admission History Adult", "Admission History Pediatric",
  "Admission History Newborn", "Adult Ambulatory Patient History",
  "Pediatric Ambulatory Patient History")
  DETAIL
   IF (ot.task_description="Admission History Adult")
    adm_hist_adult_id = ot.reference_task_id
   ELSEIF (ot.task_description="Admission History Pediatric")
    adm_hist_ped_id = ot.reference_task_id
   ELSEIF (ot.task_description="Admission History Newborn")
    adm_hist_newb_id = ot.reference_task_id
   ELSEIF (ot.task_description="Adult Ambulatory Patient History")
    adult_amb_pat_hist_id = ot.reference_task_id
   ELSEIF (ot.task_description="Pediatric Ambulatory Patient History")
    ped_amb_pat_hist_id = ot.reference_task_id
   ENDIF
  WITH nocounter
 ;end select
 SET adm_hist_adult_exists = 0.0
 SET adm_hist_ped_exists = 0.0
 SET adm_hist_newb_exists = 0.0
 SET adult_amb_pat_hist_exists = 0.0
 SET ped_amb_pat_hist_exists = 0.0
 SELECT INTO "NL:"
  FROM order_task_position_xref otpx
  WHERE (otpx.position_cd=request->position_cd)
   AND otpx.reference_task_id > 0
   AND otpx.reference_task_id IN (adm_hist_adult_id, adm_hist_ped_id, adm_hist_newb_id,
  adult_amb_pat_hist_id, ped_amb_pat_hist_id)
  DETAIL
   IF (otpx.reference_task_id=adm_hist_adult_id)
    adm_hist_adult_exists = 1
   ELSEIF (otpx.reference_task_id=adm_hist_ped_id)
    adm_hist_ped_exists = 1
   ELSEIF (otpx.reference_task_id=adm_hist_newb_id)
    adm_hist_newb_exists = 1
   ELSEIF (otpx.reference_task_id=adult_amb_pat_hist_id)
    adult_amb_pat_hist_exists = 1
   ELSEIF (otpx.reference_task_id=ped_amb_pat_hist_id)
    ped_amb_pat_hist_exists = 1
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->status_data.status_list,4)
 SET dummy_parm1 = 0
 SET dummy_parm2 = 0
 IF ((request->action="0"))
  SET comp_auth_exists = 0
  CALL complete_comp_auth_vp(dummy_parm1)
  SET vprequest->vplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
  IF ((vpreply->vplist[1].view_prefs_id > 0))
   CALL complete_comp_auth_vp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[1].action_flag = "0"
   SET nvprequest->nvplist[2].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
   IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
    AND (nvpreply->nvplist[2].name_value_prefs_id > 0))
    CALL complete_comp_auth_vcp(dummy_parm1)
    SET vcprequest->vcplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
     CALL complete_comp_auth_vcp_nvp(dummy_parm1)
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
  SET viewresults_priv_allowed = 0
  CALL complete_pv(dummy_parm1)
  SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWRSLTS"
  SET pvrequest->pvlist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
  IF ((pvreply->pvlist[1].privilege_id=0))
   SET viewresults_priv_allowed = 1
  ENDIF
  SET flow_lab_ind = 0
  SET flow_rad_ind = 0
  SET flow_clinasses_ind = 0
  SET flow_physoff_ind = 0
  SET flow_lab_view_seq = 0
  SET flow_rad_view_seq = 0
  SET flow_clinasses_view_seq = 0
  SET flow_physoff_view_seq = 0
  SELECT INTO "NL:"
   FROM view_prefs vp,
    name_value_prefs nvp
   PLAN (vp
    WHERE (vp.application_number=request->application_number)
     AND (vp.position_cd=request->position_cd)
     AND vp.prsnl_id=0.0
     AND vp.frame_type="CHART"
     AND vp.view_name="FLOWSHEET"
     AND vp.active_ind=1)
    JOIN (nvp
    WHERE nvp.parent_entity_name="VIEW_PREFS"
     AND nvp.parent_entity_id=vp.view_prefs_id
     AND nvp.pvc_name="VIEW_CAPTION"
     AND nvp.pvc_value IN ("Flowsheet - Lab", "Flowsheet - Radiology",
    "Flowsheet - Clinical Assessments", "Flowsheet - Clinical Assessment",
    "Flowsheet - Physician Office/Clinic")
     AND nvp.active_ind=1)
   DETAIL
    IF (nvp.pvc_value="Flowsheet - Lab")
     flow_lab_ind = 1, flow_lab_view_seq = vp.view_seq
    ELSEIF (nvp.pvc_value="Flowsheet - Radiology")
     flow_rad_ind = 1, flow_rad_view_seq = vp.view_seq
    ELSEIF (nvp.pvc_value="Flowsheet - Clinical Assessment*")
     flow_clinasses_ind = 1, flow_clinasses_view_seq = vp.view_seq
    ELSEIF (nvp.pvc_value="Flowsheet - Physician Office/Clinic")
     flow_physoff_ind = 1, flow_physoff_view_seq = vp.view_seq
    ENDIF
   WITH nocounter
  ;end select
  SET all_flows_exist = 0
  IF (flow_lab_ind=1
   AND flow_rad_ind=1
   AND flow_clinasses_ind=1
   AND flow_physoff_ind=1)
   SET all_flows_exist = 1
  ENDIF
  IF (all_flows_exist=1)
   SET add_comm_row_exists = 0
   SET add_comm_pvc_value = 0
   SELECT INTO "NL:"
    FROM detail_prefs dp,
     name_value_prefs nvp
    PLAN (dp
     WHERE (dp.application_number=request->application_number)
      AND (dp.position_cd=request->position_cd)
      AND dp.prsnl_id=0.0
      AND dp.person_id=0.0
      AND dp.view_name="INBOXFS"
      AND dp.view_seq=1
      AND dp.comp_name="FLOWSHEET"
      AND dp.comp_seq=1
      AND dp.active_ind=1)
     JOIN (nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=dp.detail_prefs_id
      AND nvp.pvc_name="ADD_COMMENTS"
      AND nvp.active_ind=1)
    DETAIL
     add_comm_row_exists = 1
     IF (nvp.pvc_value="1")
      add_comm_pvc_value = 1
     ELSEIF (nvp.pvc_value="2")
      add_comm_pvc_value = 2
     ELSEIF (nvp.pvc_value="3")
      add_comm_pvc_value = 3
     ENDIF
    WITH nocounter
   ;end select
   IF (add_comm_row_exists=0)
    SET add_comm_pvc_value = 0
    SELECT INTO "NL:"
     FROM detail_prefs dp,
      name_value_prefs nvp
     PLAN (dp
      WHERE (dp.application_number=request->application_number)
       AND dp.position_cd=0.0
       AND dp.prsnl_id=0.0
       AND dp.person_id=0.0
       AND dp.view_name="INBOXFS"
       AND dp.view_seq=1
       AND dp.comp_name="FLOWSHEET"
       AND dp.comp_seq=1
       AND dp.active_ind=1)
      JOIN (nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=dp.detail_prefs_id
       AND nvp.pvc_name="ADD_COMMENTS"
       AND nvp.active_ind=1)
     DETAIL
      IF (nvp.pvc_value="1")
       add_comm_pvc_value = 1
      ELSEIF (nvp.pvc_value="2")
       add_comm_pvc_value = 2
      ELSEIF (nvp.pvc_value="3")
       add_comm_pvc_value = 3
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (add_comm_pvc_value > 0)
    SET add_comments_1_row_cnt = 0
    SET add_comments_2_row_cnt = 0
    SET add_comments_3_row_cnt = 0
    SELECT INTO "NL:"
     FROM detail_prefs dp,
      name_value_prefs nvp
     PLAN (dp
      WHERE (dp.application_number=request->application_number)
       AND (dp.position_cd=request->position_cd)
       AND dp.prsnl_id=0.0
       AND dp.person_id=0.0
       AND dp.view_name="FLOWSHEET"
       AND dp.comp_name="FLOWSHEET"
       AND dp.view_seq IN (flow_lab_view_seq, flow_rad_view_seq, flow_clinasses_view_seq,
      flow_physoff_view_seq)
       AND dp.active_ind=1)
      JOIN (nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=dp.detail_prefs_id
       AND nvp.pvc_name="ADD_COMMENTS"
       AND nvp.active_ind=1)
     DETAIL
      IF (nvp.pvc_value="1")
       add_comments_1_row_cnt = (add_comments_1_row_cnt+ 1)
      ELSEIF (nvp.pvc_value="2")
       add_comments_2_row_cnt = (add_comments_2_row_cnt+ 1)
      ELSEIF (nvp.pvc_value="3")
       add_comments_3_row_cnt = (add_comments_3_row_cnt+ 1)
      ENDIF
     WITH nocounter
    ;end select
    IF (add_comments_1_row_cnt=0
     AND add_comments_2_row_cnt=0
     AND add_comments_3_row_cnt=0)
     SELECT INTO "NL:"
      FROM detail_prefs dp,
       name_value_prefs nvp
      PLAN (dp
       WHERE (dp.application_number=request->application_number)
        AND dp.position_cd=0.0
        AND dp.prsnl_id=0.0
        AND dp.person_id=0.0
        AND dp.view_name="FLOWSHEET"
        AND dp.comp_name="FLOWSHEET"
        AND dp.view_seq IN (flow_lab_view_seq, flow_rad_view_seq, flow_clinasses_view_seq,
       flow_physoff_view_seq)
        AND dp.active_ind=1)
       JOIN (nvp
       WHERE nvp.parent_entity_name="DETAIL_PREFS"
        AND nvp.parent_entity_id=dp.detail_prefs_id
        AND nvp.pvc_name="ADD_COMMENTS"
        AND nvp.active_ind=1)
      DETAIL
       IF (nvp.pvc_value="1")
        add_comments_1_row_cnt = (add_comments_1_row_cnt+ 1)
       ELSEIF (nvp.pvc_value="2")
        add_comments_2_row_cnt = (add_comments_2_row_cnt+ 1)
       ELSEIF (nvp.pvc_value="3")
        add_comments_3_row_cnt = (add_comments_3_row_cnt+ 1)
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
  ENDIF
  SET newrsltdlg_pref_exists = 0
  CALL complete_newrsltdlg_vp(dummy_parm1)
  CALL complete_newrsltdlg_vcp(dummy_parm1)
  SET vprequest->vplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
  IF ((vpreply->vplist[1].view_prefs_id > 0))
   CALL complete_newrsltdlg_vp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[3].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[4].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[1].action_flag = "0"
   SET nvprequest->nvplist[2].action_flag = "0"
   SET nvprequest->nvplist[3].action_flag = "0"
   SET nvprequest->nvplist[4].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
   IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
    AND (nvpreply->nvplist[2].name_value_prefs_id > 0)
    AND (nvpreply->nvplist[3].name_value_prefs_id > 0)
    AND (nvpreply->nvplist[4].name_value_prefs_id > 0))
    SET vcprequest->vcplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
     CALL complete_newrsltdlg_vcp_nvp(dummy_parm1)
     SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[1].action_flag = "0"
     SET nvprequest->nvplist[2].action_flag = "0"
     SET nvprequest->nvplist[3].action_flag = "0"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
     IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
      AND (nvpreply->nvplist[2].name_value_prefs_id > 0)
      AND (nvpreply->nvplist[3].name_value_prefs_id > 0))
      SET newrsltdlg_pref_exists = 1
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  IF (newrsltdlg_pref_exists=0)
   SET vprequest->vplist[1].position_cd = 0.0
   SET vprequest->vplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   IF ((vpreply->vplist[1].view_prefs_id > 0))
    CALL complete_newrsltdlg_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[3].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[4].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[1].action_flag = "0"
    SET nvprequest->nvplist[2].action_flag = "0"
    SET nvprequest->nvplist[3].action_flag = "0"
    SET nvprequest->nvplist[4].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
     AND (nvpreply->nvplist[2].name_value_prefs_id > 0)
     AND (nvpreply->nvplist[3].name_value_prefs_id > 0)
     AND (nvpreply->nvplist[4].name_value_prefs_id > 0))
     SET vcprequest->vcplist[1].position_cd = 0.0
     SET vcprequest->vcplist[1].action_flag = "0"
     SET trace = recpersist
     EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",
      vcpreply)
     IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
      CALL complete_newrsltdlg_vcp_nvp(dummy_parm1)
      SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
      SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
      SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
      SET nvprequest->nvplist[1].action_flag = "0"
      SET nvprequest->nvplist[2].action_flag = "0"
      SET nvprequest->nvplist[3].action_flag = "0"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
      IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
       AND (nvpreply->nvplist[2].name_value_prefs_id > 0)
       AND (nvpreply->nvplist[3].name_value_prefs_id > 0))
       SET newrsltdlg_pref_exists = 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  SET inboxfsdlg_pref_exists = 0
  CALL complete_inboxfsdlg_vp(dummy_parm1)
  SET vprequest->vplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
  IF ((vpreply->vplist[1].view_prefs_id > 0))
   CALL complete_inboxfsdlg_vp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[1].action_flag = "0"
   SET nvprequest->nvplist[2].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
   IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
    AND (nvpreply->nvplist[2].name_value_prefs_id > 0))
    SET inboxfsdlg_pref_exists = 1
   ENDIF
  ENDIF
  IF (inboxfsdlg_pref_exists=0)
   SET vprequest->vplist[1].position_cd = 0.0
   SET vprequest->vplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   IF ((vpreply->vplist[1].view_prefs_id > 0))
    CALL complete_inboxfsdlg_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[1].action_flag = "0"
    SET nvprequest->nvplist[2].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
     AND (nvpreply->nvplist[2].name_value_prefs_id > 0))
     SET inboxfsdlg_pref_exists = 1
    ENDIF
   ENDIF
  ENDIF
  SET clinnotes_pref_exists = 0
  CALL complete_clinnotes_vp(dummy_parm1)
  CALL complete_clinnotes_vcp(dummy_parm1)
  SET vprequest->vplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
  IF ((vpreply->vplist[1].view_prefs_id > 0))
   CALL complete_clinnotes_vp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[3].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[1].action_flag = "0"
   SET nvprequest->nvplist[2].action_flag = "0"
   SET nvprequest->nvplist[3].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
   IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
    AND (nvpreply->nvplist[2].name_value_prefs_id > 0)
    AND (nvpreply->nvplist[3].name_value_prefs_id > 0))
    SET vcprequest->vcplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
     CALL complete_clinnotes_vcp_nvp(dummy_parm1)
     SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[1].action_flag = "0"
     SET nvprequest->nvplist[2].action_flag = "0"
     SET nvprequest->nvplist[3].action_flag = "0"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
     IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
      AND (nvpreply->nvplist[2].name_value_prefs_id > 0)
      AND (nvpreply->nvplist[3].name_value_prefs_id > 0))
      SET clinnotes_pref_exists = 1
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  IF (clinnotes_pref_exists=0)
   SET vprequest->vplist[1].position_cd = 0.0
   SET vprequest->vplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   IF ((vpreply->vplist[1].view_prefs_id > 0))
    CALL complete_clinnotes_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[3].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[1].action_flag = "0"
    SET nvprequest->nvplist[2].action_flag = "0"
    SET nvprequest->nvplist[3].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
     AND (nvpreply->nvplist[2].name_value_prefs_id > 0)
     AND (nvpreply->nvplist[3].name_value_prefs_id > 0))
     SET vcprequest->vcplist[1].position_cd = 0.0
     SET vcprequest->vcplist[1].action_flag = "0"
     SET trace = recpersist
     EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",
      vcpreply)
     IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
      CALL complete_clinnotes_vcp_nvp(dummy_parm1)
      SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
      SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
      SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
      SET nvprequest->nvplist[1].action_flag = "0"
      SET nvprequest->nvplist[2].action_flag = "0"
      SET nvprequest->nvplist[3].action_flag = "0"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
      IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
       AND (nvpreply->nvplist[2].name_value_prefs_id > 0)
       AND (nvpreply->nvplist[3].name_value_prefs_id > 0))
       SET clinnotes_pref_exists = 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  SET oflowsheet_pref_exists = 0
  SET oflowsheet_id = 0.0
  SET oflowsheet_seq = 0
  SELECT INTO "NL:"
   FROM view_prefs vp
   WHERE (vp.application_number=request->application_number)
    AND (vp.position_cd=request->position_cd)
    AND (vp.prsnl_id=request->prsnl_id)
    AND vp.frame_type="ORDINFO"
    AND vp.view_name="OFLOWSHEET"
    AND vp.active_ind=1
   DETAIL
    oflowsheet_id = vp.view_prefs_id, oflowsheet_seq = vp.view_seq
   WITH nocounter
  ;end select
  IF (oflowsheet_id > 0)
   CALL complete_oflowsheet_vp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = oflowsheet_id
   SET nvprequest->nvplist[2].parent_entity_id = oflowsheet_id
   SET nvprequest->nvplist[3].parent_entity_id = oflowsheet_id
   SET nvprequest->nvplist[4].parent_entity_id = oflowsheet_id
   SET nvprequest->nvplist[1].action_flag = "0"
   SET nvprequest->nvplist[2].action_flag = "0"
   SET nvprequest->nvplist[3].action_flag = "0"
   SET nvprequest->nvplist[4].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
   IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
    AND (nvpreply->nvplist[2].name_value_prefs_id > 0)
    AND (nvpreply->nvplist[3].name_value_prefs_id > 0)
    AND (nvpreply->nvplist[4].name_value_prefs_id > 0))
    CALL complete_oflowsheet_vcp(dummy_parm1)
    SET vcprequest->vcplist[1].view_seq = oflowsheet_seq
    SET vcprequest->vcplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
     CALL complete_oflowsheet_vcp_nvp(dummy_parm1)
     SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[1].action_flag = "0"
     SET nvprequest->nvplist[2].action_flag = "0"
     SET nvprequest->nvplist[3].action_flag = "0"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
     IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
      AND (nvpreply->nvplist[2].name_value_prefs_id > 0)
      AND (nvpreply->nvplist[3].name_value_prefs_id > 0))
      SET oflowsheet_pref_exists = 1
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  IF (oflowsheet_pref_exists=0)
   SET oflowsheet_id = 0.0
   SET oflowsheet_seq = 0
   SELECT INTO "NL:"
    FROM view_prefs vp
    WHERE (vp.application_number=request->application_number)
     AND vp.position_cd=0.0
     AND (vp.prsnl_id=request->prsnl_id)
     AND vp.frame_type="ORDINFO"
     AND vp.view_name="OFLOWSHEET"
     AND vp.active_ind=1
    DETAIL
     oflowsheet_id = vp.view_prefs_id, oflowsheet_seq = vp.view_seq
    WITH nocounter
   ;end select
   IF (oflowsheet_id > 0)
    CALL complete_oflowsheet_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = oflowsheet_id
    SET nvprequest->nvplist[2].parent_entity_id = oflowsheet_id
    SET nvprequest->nvplist[3].parent_entity_id = oflowsheet_id
    SET nvprequest->nvplist[4].parent_entity_id = oflowsheet_id
    SET nvprequest->nvplist[1].action_flag = "0"
    SET nvprequest->nvplist[2].action_flag = "0"
    SET nvprequest->nvplist[3].action_flag = "0"
    SET nvprequest->nvplist[4].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
     AND (nvpreply->nvplist[2].name_value_prefs_id > 0)
     AND (nvpreply->nvplist[3].name_value_prefs_id > 0)
     AND (nvpreply->nvplist[4].name_value_prefs_id > 0))
     CALL complete_oflowsheet_vcp(dummy_parm1)
     SET vcprequest->vcplist[1].position_cd = 0.0
     SET vcprequest->vcplist[1].view_seq = oflowsheet_seq
     SET vcprequest->vcplist[1].action_flag = "0"
     SET trace = recpersist
     EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",
      vcpreply)
     IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
      CALL complete_oflowsheet_vcp_nvp(dummy_parm1)
      SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
      SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
      SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
      SET nvprequest->nvplist[1].action_flag = "0"
      SET nvprequest->nvplist[2].action_flag = "0"
      SET nvprequest->nvplist[3].action_flag = "0"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
      IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
       AND (nvpreply->nvplist[2].name_value_prefs_id > 0)
       AND (nvpreply->nvplist[3].name_value_prefs_id > 0))
       SET oflowsheet_pref_exists = 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  SET reply->status_data.status_list[1].status = "0"
  SET reply->status_data.status_list[2].status = "0"
  SET reply->status_data.status_list[3].status = "0"
  SET reply->status_data.status_list[4].status = "0"
  IF (comp_auth_exists=1
   AND adm_hist_adult_exists=1
   AND adult_amb_pat_hist_exists=1
   AND ped_amb_pat_hist_exists=1
   AND viewresults_priv_allowed=1)
   SET reply->status_data.status_list[2].status = "1"
  ELSE
   IF (comp_auth_exists=1
    AND adm_hist_adult_exists=0
    AND adm_hist_ped_exists=0
    AND adm_hist_newb_exists=0
    AND adult_amb_pat_hist_exists=0
    AND ped_amb_pat_hist_exists=0
    AND viewresults_priv_allowed=1)
    SET reply->status_data.status_list[1].status = "1"
   ENDIF
  ENDIF
  IF (flow_lab_ind=1
   AND flow_rad_ind=1
   AND flow_clinasses_ind=1
   AND flow_physoff_ind=1
   AND newrsltdlg_pref_exists=1
   AND inboxfsdlg_pref_exists=1
   AND clinnotes_pref_exists=1
   AND oflowsheet_pref_exists=1
   AND viewresults_priv_allowed=1)
   SET reply->status_data.status_list[3].status = "1"
   IF (add_comm_pvc_value > 0)
    IF (add_comments_1_row_cnt=4)
     SET reply->status_data.status_list[4].status = "1"
    ELSEIF (add_comments_2_row_cnt=4)
     SET reply->status_data.status_list[4].status = "2"
    ELSEIF (add_comments_3_row_cnt=4)
     SET reply->status_data.status_list[4].status = "3"
    ENDIF
   ENDIF
  ENDIF
 ELSEIF ((request->action="2"))
  SET viewpthist_off_on_ind = request->task_list[1].on_off_ind
  SET updpthist_off_on_ind = request->task_list[2].on_off_ind
  SET viewresult_off_on_ind = request->task_list[3].on_off_ind
  SET commentresult_off_on_ind = request->task_list[4].on_off_ind
  IF (((viewpthist_off_on_ind=1) OR (updpthist_off_on_ind=1)) )
   CALL complete_comp_auth_vp(dummy_parm1)
   SET vprequest->vplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   IF ((vpreply->vplist[1].view_prefs_id=0))
    SET vprequest->vplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   ENDIF
   IF ((vpreply->vplist[1].view_prefs_id > 0))
    CALL complete_comp_auth_vp_nvp(dummy_parm1)
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
     SET nvprequest->nvplist[1].pvc_value = "25"
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ENDIF
   CALL complete_comp_auth_vcp(dummy_parm1)
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
    CALL complete_comp_auth_vcp_nvp(dummy_parm1)
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
   CALL complete_comp_auth_vp(dummy_parm1)
   SET vprequest->vplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   IF ((vpreply->vplist[1].view_prefs_id > 0))
    CALL complete_comp_auth_vp_nvp(dummy_parm1)
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
   CALL complete_comp_auth_vcp(dummy_parm1)
   SET vcprequest->vcplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply)
   IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
    CALL complete_comp_auth_vcp_nvp(dummy_parm1)
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
  IF (updpthist_off_on_ind=1)
   SET nbr_tasks = 0
   IF (adm_hist_adult_exists=0)
    SET nbr_tasks = (nbr_tasks+ 1)
    SET stat = alterlist(ordtaskrequest->olist,nbr_tasks)
    SET ordtaskrequest->olist[nbr_tasks].order_task_id = adm_hist_adult_id
   ENDIF
   IF (adult_amb_pat_hist_exists=0)
    SET nbr_tasks = (nbr_tasks+ 1)
    SET stat = alterlist(ordtaskrequest->olist,nbr_tasks)
    SET ordtaskrequest->olist[nbr_tasks].order_task_id = adult_amb_pat_hist_id
   ENDIF
   IF (ped_amb_pat_hist_exists=0)
    SET nbr_tasks = (nbr_tasks+ 1)
    SET stat = alterlist(ordtaskrequest->olist,nbr_tasks)
    SET ordtaskrequest->olist[nbr_tasks].order_task_id = ped_amb_pat_hist_id
   ENDIF
   IF (nbr_tasks > 0)
    SET ordtaskrequest->position_cd = request->position_cd
    SET ordtaskrequest->action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_ord_task_psn_xref  WITH replace("REQUEST",ordtaskrequest), replace("REPLY",
     ordtaskreply)
   ENDIF
  ELSE
   SET multitaskrequest->action = "0"
   SET multitaskrequest->application_number = 961000
   SET multitaskrequest->position_cd = request->position_cd
   SET multitaskrequest->prsnl_id = 0.0
   SET stat = alterlist(multitaskrequest->task_list,2)
   SET stat = alterlist(multitaskreply->status_data.status_list,2)
   SET multitaskrequest->task_list[1].task = "VIEWTASK"
   SET multitaskrequest->task_list[2].task = "UPDTASK"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_charttask  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
   SET updtask_stat = multitaskreply->status_data.status_list[2].status
   SET nbr_tasks = 0
   IF (adm_hist_adult_exists=1)
    SET nbr_tasks = (nbr_tasks+ 1)
    SET stat = alterlist(ordtaskrequest->olist,nbr_tasks)
    SET ordtaskrequest->olist[nbr_tasks].order_task_id = adm_hist_adult_id
   ENDIF
   IF (adm_hist_ped_exists=1)
    SET nbr_tasks = (nbr_tasks+ 1)
    SET stat = alterlist(ordtaskrequest->olist,nbr_tasks)
    SET ordtaskrequest->olist[nbr_tasks].order_task_id = adm_hist_ped_id
   ENDIF
   IF (adm_hist_newb_exists=1)
    SET nbr_tasks = (nbr_tasks+ 1)
    SET stat = alterlist(ordtaskrequest->olist,nbr_tasks)
    SET ordtaskrequest->olist[nbr_tasks].order_task_id = adm_hist_newb_id
   ENDIF
   IF (adult_amb_pat_hist_exists=1
    AND updtask_stat != "1")
    SET nbr_tasks = (nbr_tasks+ 1)
    SET stat = alterlist(ordtaskrequest->olist,nbr_tasks)
    SET ordtaskrequest->olist[nbr_tasks].order_task_id = adult_amb_pat_hist_id
   ENDIF
   IF (ped_amb_pat_hist_exists=1
    AND updtask_stat != "1")
    SET nbr_tasks = (nbr_tasks+ 1)
    SET stat = alterlist(ordtaskrequest->olist,nbr_tasks)
    SET ordtaskrequest->olist[nbr_tasks].order_task_id = ped_amb_pat_hist_id
   ENDIF
   IF (nbr_tasks > 0)
    SET ordtaskrequest->position_cd = request->position_cd
    SET ordtaskrequest->action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_ord_task_psn_xref  WITH replace("REQUEST",ordtaskrequest), replace("REPLY",
     ordtaskreply)
   ENDIF
  ENDIF
  SET viewresults_cd = 0.0
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.code_set=6016
    AND cv.cdf_meaning="VIEWRSLTS"
    AND cv.active_ind=1
   DETAIL
    viewresults_cd = cv.code_value
   WITH nocounter
  ;end select
  SET priv_loc_reltn_id = 0.0
  SELECT INTO "NL:"
   FROM priv_loc_reltn plr
   WHERE plr.person_id=0.0
    AND (plr.position_cd=request->position_cd)
    AND plr.ppr_cd=0.0
    AND plr.location_cd=0.0
    AND plr.active_ind=1
   DETAIL
    priv_loc_reltn_id = plr.priv_loc_reltn_id
   WITH nocounter
  ;end select
  SET priv_value_cd = 0.0
  SET priv_id = 0.0
  IF (priv_loc_reltn_id > 0
   AND viewresults_cd > 0)
   SELECT INTO "NL:"
    FROM privilege p
    WHERE p.priv_loc_reltn_id=priv_loc_reltn_id
     AND p.privilege_cd=viewresults_cd
     AND p.active_ind=1
    DETAIL
     priv_value_cd = p.priv_value_cd, priv_id = p.privilege_id
    WITH nocounter
   ;end select
  ENDIF
  SET priv_value_cdf_meaning = fillstring(12," ")
  IF (priv_value_cd > 0.0)
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.code_set=6017
     AND cv.code_value=priv_value_cd
     AND cv.active_ind=1
    DETAIL
     priv_value_cdf_meaning = cv.cdf_meaning
    WITH nocounter
   ;end select
  ENDIF
  SET individual_cd = 0.0
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.code_set=6019
    AND cv.cdf_meaning="INDIVIDUAL"
    AND cv.active_ind=1
   DETAIL
    individual_cd = cv.code_value
   WITH nocounter
  ;end select
  SET event_set_cd = 0.0
  SELECT INTO "NL:"
   FROM v500_event_set_code ec
   WHERE ec.event_set_cd_disp="Clinical Demographics"
   DETAIL
    event_set_cd = ec.event_set_cd
   WITH nocounter
  ;end select
  SET priv_exception_id = 0.0
  IF (priv_id > 0.0
   AND individual_cd > 0.0
   AND event_set_cd > 0.0
   AND priv_value_cdf_meaning="INCLUDE")
   SELECT INTO "NL:"
    FROM privilege_exception pe
    WHERE pe.privilege_id=priv_id
     AND pe.exception_type_cd=individual_cd
     AND pe.exception_id=event_set_cd
     AND pe.exception_entity_name="V500_EVENT_SET_CODE"
     AND pe.event_set_name="CLINICAL DEMOGRAPHICS"
     AND pe.active_ind=1
    DETAIL
     priv_exception_id = pe.privilege_exception_id
    WITH nocounter
   ;end select
  ENDIF
  IF (((viewpthist_off_on_ind=1) OR (updpthist_off_on_ind=1))
   AND viewresult_off_on_ind=3)
   IF (priv_value_cdf_meaning != "INCLUDE")
    CALL complete_pv(dummy_parm1)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWRSLTS"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    DELETE  FROM privilege_exception pe
     WHERE pe.privilege_id=priv_id
      AND pe.exception_type_cd=individual_cd
      AND pe.exception_id=event_set_cd
      AND pe.exception_entity_name="V500_EVENT_SET_CODE"
      AND pe.event_set_name="CLINICAL DEMOGRAPHICS"
     WITH nocounter
    ;end delete
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWRSLTS"
    SET pvrequest->pvlist[1].priv_value = "INCLUDE"
    SET pvrequest->pvlist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    SET priv_id = pvreply->pvlist[1].privilege_id
   ENDIF
   IF (priv_exception_id=0.0)
    SET new_priv_exception_id = 0.0
    SELECT INTO "nl:"
     z = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      new_priv_exception_id = cnvtreal(z)
     WITH format, nocounter
    ;end select
    SET active_cd = 0.0
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE cv.code_set=48
      AND cv.cdf_meaning="ACTIVE"
      AND cv.active_ind=1
     DETAIL
      active_cd = cv.code_value
     WITH nocounter
    ;end select
    INSERT  FROM privilege_exception pe
     SET pe.privilege_exception_id = new_priv_exception_id, pe.privilege_id = priv_id, pe
      .exception_type_cd = individual_cd,
      pe.exception_id = event_set_cd, pe.updt_cnt = 0, pe.updt_dt_tm = cnvtdatetime(curdate,curtime),
      pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->
      updt_applctx,
      pe.active_ind = 1, pe.active_status_cd = active_cd, pe.active_status_dt_tm = cnvtdatetime(
       curdate,curtime),
      pe.active_status_prsnl_id = reqinfo->updt_id, pe.exception_entity_name = "V500_EVENT_SET_CODE",
      pe.event_set_name = "CLINICAL DEMOGRAPHICS"
     WITH nocounter
    ;end insert
   ENDIF
  ENDIF
  IF (viewpthist_off_on_ind=3
   AND updpthist_off_on_ind=3
   AND viewresult_off_on_ind=1)
   IF (priv_value_cdf_meaning != "YES")
    CALL complete_pv(dummy_parm1)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWRSLTS"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    DELETE  FROM privilege_exception pe
     WHERE pe.privilege_id=priv_id
      AND pe.exception_type_cd=individual_cd
      AND pe.exception_id=event_set_cd
      AND pe.exception_entity_name="V500_EVENT_SET_CODE"
      AND pe.event_set_name="CLINICAL DEMOGRAPHICS"
     WITH nocounter
    ;end delete
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWRSLTS"
    SET pvrequest->pvlist[1].priv_value = "YES"
    SET pvrequest->pvlist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
   ENDIF
  ENDIF
  IF (((viewpthist_off_on_ind=1) OR (updpthist_off_on_ind=1))
   AND viewresult_off_on_ind=1)
   IF (priv_value_cdf_meaning != "YES")
    CALL complete_pv(dummy_parm1)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWRSLTS"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    DELETE  FROM privilege_exception pe
     WHERE pe.privilege_id=priv_id
      AND pe.exception_type_cd=individual_cd
      AND pe.exception_id=event_set_cd
      AND pe.exception_entity_name="V500_EVENT_SET_CODE"
      AND pe.event_set_name="CLINICAL DEMOGRAPHICS"
     WITH nocounter
    ;end delete
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWRSLTS"
    SET pvrequest->pvlist[1].priv_value = "YES"
    SET pvrequest->pvlist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
   ENDIF
  ENDIF
  IF (viewpthist_off_on_ind=3
   AND updpthist_off_on_ind=3
   AND viewresult_off_on_ind=3)
   IF (priv_value_cdf_meaning != "NO")
    CALL complete_pv(dummy_parm1)
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWRSLTS"
    SET pvrequest->pvlist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
    DELETE  FROM privilege_exception pe
     WHERE pe.privilege_id=priv_id
      AND pe.exception_type_cd=individual_cd
      AND pe.exception_id=event_set_cd
      AND pe.exception_entity_name="V500_EVENT_SET_CODE"
      AND pe.event_set_name="CLINICAL DEMOGRAPHICS"
     WITH nocounter
    ;end delete
    SET pvrequest->pvlist[1].priv_cdf_meaning = "VIEWRSLTS"
    SET pvrequest->pvlist[1].priv_value = "NO"
    SET pvrequest->pvlist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_privilege  WITH replace("REQUEST",pvrequest), replace("REPLY",pvreply)
   ENDIF
  ENDIF
  SET flow_cnt = 0
  SET flow_lab_ind = 0
  SET flow_rad_ind = 0
  SET flow_clinasses_ind = 0
  SET flow_physoff_ind = 0
  SET flow_2day_ind = 0
  SET flow_lab_idx = 0
  SET flow_rad_idx = 0
  SET flow_clinasses_idx = 0
  SET flow_physoff_idx = 0
  SET flow_2day_idx = 0
  SELECT INTO "NL:"
   FROM view_prefs vp,
    name_value_prefs nvp
   PLAN (vp
    WHERE (vp.application_number=request->application_number)
     AND (vp.position_cd=request->position_cd)
     AND vp.prsnl_id=0.0
     AND vp.frame_type="CHART"
     AND vp.view_name="FLOWSHEET"
     AND vp.active_ind=1)
    JOIN (nvp
    WHERE nvp.parent_entity_name="VIEW_PREFS"
     AND nvp.parent_entity_id=vp.view_prefs_id
     AND nvp.pvc_name="VIEW_CAPTION"
     AND nvp.active_ind=1)
   ORDER BY vp.view_seq
   HEAD REPORT
    flow_cnt = 0
   DETAIL
    flow_cnt = (flow_cnt+ 1), stat = alterlist(flowsheets->flist,flow_cnt), flowsheets->flist[
    flow_cnt].pvc_value = nvp.pvc_value,
    flowsheets->flist[flow_cnt].view_seq = vp.view_seq
    IF (nvp.pvc_value="Flowsheet - Lab")
     flow_lab_ind = 1, flow_lab_idx = flow_cnt
    ELSEIF (nvp.pvc_value="Flowsheet - Radiology")
     flow_rad_ind = 1, flow_rad_idx = flow_cnt
    ELSEIF (nvp.pvc_value="Flowsheet - Clinical Assessment*")
     flow_clinasses_ind = 1, flow_clinasses_idx = flow_cnt
    ELSEIF (nvp.pvc_value="Flowsheet - Physician Office/Clinic")
     flow_physoff_ind = 1, flow_physoff_idx = flow_cnt
    ELSEIF (nvp.pvc_value="Flowsheet - 2 day Lab, Rad, Vitals")
     flow_2day_ind = 1, flow_2day_idx = flow_cnt
    ENDIF
   WITH nocounter
  ;end select
  IF (flow_cnt=0)
   SET tot_view_seq = 0
  ELSE
   SET tot_view_seq = flow_cnt
  ENDIF
  IF (viewresult_off_on_ind=1)
   CALL complete_flow_vp_and_vcp(dummy_parm1)
   SET vprequest->vplist[1].action_flag = "1"
   SET vcprequest->vcplist[1].action_flag = "1"
   IF (flow_lab_ind=0)
    SET vprequest->vplist[1].view_seq = tot_view_seq
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
    CALL complete_flow_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].pvc_value = "Flowsheet - Lab"
    SET nvprequest->nvplist[1].action_flag = "1"
    SET nvprequest->nvplist[2].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    SET vcprequest->vcplist[1].view_seq = tot_view_seq
    IF (tot_view_seq=0)
     SET vcprequest->vcplist[1].comp_seq = 0
    ELSE
     SET vcprequest->vcplist[1].comp_seq = 1
    ENDIF
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    CALL complete_flow_vcp_nvp(dummy_parm1)
    IF (tot_view_seq=0)
     SET nvprequest->nvplist[1].pvc_value = "PVFlowsheet.dll"
     SET nvprequest->nvplist[5].pvc_value = "33246"
    ELSE
     SET nvprequest->nvplist[1].pvc_value = "PVFLOWSHEET"
     SET nvprequest->nvplist[5].pvc_value = "0"
    ENDIF
    SET nvprequest->nvplist[1].action_flag = "1"
    SET nvprequest->nvplist[2].action_flag = "1"
    SET nvprequest->nvplist[3].action_flag = "1"
    SET nvprequest->nvplist[4].action_flag = "1"
    SET nvprequest->nvplist[5].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    CALL complete_addcomm_flow_dp_and_nvp(dummy_parm1)
    SET dprequest->dplist[1].view_seq = tot_view_seq
    IF (tot_view_seq=0)
     SET dprequest->dplist[1].comp_seq = 0
    ELSE
     SET dprequest->dplist[1].comp_seq = 1
    ENDIF
    SET dprequest->dplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
    SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    SET tot_view_seq = (tot_view_seq+ 1)
   ELSE
    CALL complete_addcomm_flow_dp_and_nvp(dummy_parm1)
    SET dprequest->dplist[1].view_seq = flowsheets->flist[flow_lab_idx].view_seq
    IF ((dprequest->dplist[1].view_seq=0))
     SET dprequest->dplist[1].comp_seq = 0
    ELSE
     SET dprequest->dplist[1].comp_seq = 1
    ENDIF
    SET dprequest->dplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
    IF ((dpreply->dplist[1].detail_prefs_id > 0))
     SET add_comments_exists = 0
     SET add_comm_pvc_value = 0
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
       AND nvp.pvc_name="ADD_COMMENTS"
       AND nvp.active_ind=1
      DETAIL
       add_comments_exists = 1, add_comm_pvc_value = cnvtint(nvp.pvc_value)
      WITH nocounter
     ;end select
     IF (add_comments_exists=1)
      IF (add_comm_pvc_value != commentresult_off_on_ind)
       SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
       SET nvprequest->nvplist[1].action_flag = "2"
       SET trace = recpersist
       EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
        nvpreply)
      ENDIF
     ELSE
      SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
      SET nvprequest->nvplist[1].action_flag = "1"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
    ELSE
     SET dprequest->dplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
     SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ENDIF
   IF (flow_rad_ind=0)
    SET vprequest->vplist[1].view_seq = tot_view_seq
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
    CALL complete_flow_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].pvc_value = "Flowsheet - Radiology"
    SET nvprequest->nvplist[1].action_flag = "1"
    SET nvprequest->nvplist[2].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    SET vcprequest->vcplist[1].view_seq = tot_view_seq
    IF (tot_view_seq=0)
     SET vcprequest->vcplist[1].comp_seq = 0
    ELSE
     SET vcprequest->vcplist[1].comp_seq = 1
    ENDIF
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    CALL complete_flow_vcp_nvp(dummy_parm1)
    IF (tot_view_seq=0)
     SET nvprequest->nvplist[1].pvc_value = "PVFlowsheet.dll"
     SET nvprequest->nvplist[5].pvc_value = "33246"
    ELSE
     SET nvprequest->nvplist[1].pvc_value = "PVFLOWSHEET"
     SET nvprequest->nvplist[5].pvc_value = "0"
    ENDIF
    SET nvprequest->nvplist[1].action_flag = "1"
    SET nvprequest->nvplist[2].action_flag = "1"
    SET nvprequest->nvplist[3].action_flag = "1"
    SET nvprequest->nvplist[4].action_flag = "1"
    SET nvprequest->nvplist[5].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    CALL complete_addcomm_flow_dp_and_nvp(dummy_parm1)
    SET dprequest->dplist[1].view_seq = tot_view_seq
    IF (tot_view_seq=0)
     SET dprequest->dplist[1].comp_seq = 0
    ELSE
     SET dprequest->dplist[1].comp_seq = 1
    ENDIF
    SET dprequest->dplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
    SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    SET tot_view_seq = (tot_view_seq+ 1)
   ELSE
    CALL complete_addcomm_flow_dp_and_nvp(dummy_parm1)
    SET dprequest->dplist[1].view_seq = flowsheets->flist[flow_rad_idx].view_seq
    IF ((dprequest->dplist[1].view_seq=0))
     SET dprequest->dplist[1].comp_seq = 0
    ELSE
     SET dprequest->dplist[1].comp_seq = 1
    ENDIF
    SET dprequest->dplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
    IF ((dpreply->dplist[1].detail_prefs_id > 0))
     SET add_comments_exists = 0
     SET add_comm_pvc_value = 0
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
       AND nvp.pvc_name="ADD_COMMENTS"
       AND nvp.active_ind=1
      DETAIL
       add_comments_exists = 1, add_comm_pvc_value = cnvtint(nvp.pvc_value)
      WITH nocounter
     ;end select
     IF (add_comments_exists=1)
      IF (add_comm_pvc_value != commentresult_off_on_ind)
       SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
       SET nvprequest->nvplist[1].action_flag = "2"
       SET trace = recpersist
       EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
        nvpreply)
      ENDIF
     ELSE
      SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
      SET nvprequest->nvplist[1].action_flag = "1"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
    ELSE
     SET dprequest->dplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
     SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ENDIF
   IF (flow_clinasses_ind=0)
    SET vprequest->vplist[1].view_seq = tot_view_seq
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
    CALL complete_flow_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].pvc_value = "Flowsheet - Clinical Assessments"
    SET nvprequest->nvplist[1].action_flag = "1"
    SET nvprequest->nvplist[2].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    SET vcprequest->vcplist[1].view_seq = tot_view_seq
    IF (tot_view_seq=0)
     SET vcprequest->vcplist[1].comp_seq = 0
    ELSE
     SET vcprequest->vcplist[1].comp_seq = 1
    ENDIF
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    CALL complete_flow_vcp_nvp(dummy_parm1)
    IF (tot_view_seq=0)
     SET nvprequest->nvplist[1].pvc_value = "PVFlowsheet.dll"
     SET nvprequest->nvplist[5].pvc_value = "33246"
    ELSE
     SET nvprequest->nvplist[1].pvc_value = "PVFLOWSHEET"
     SET nvprequest->nvplist[5].pvc_value = "0"
    ENDIF
    SET nvprequest->nvplist[1].action_flag = "1"
    SET nvprequest->nvplist[2].action_flag = "1"
    SET nvprequest->nvplist[3].action_flag = "1"
    SET nvprequest->nvplist[4].action_flag = "1"
    SET nvprequest->nvplist[5].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    CALL complete_addcomm_flow_dp_and_nvp(dummy_parm1)
    SET dprequest->dplist[1].view_seq = tot_view_seq
    IF (tot_view_seq=0)
     SET dprequest->dplist[1].comp_seq = 0
    ELSE
     SET dprequest->dplist[1].comp_seq = 1
    ENDIF
    SET dprequest->dplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
    SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    SET tot_view_seq = (tot_view_seq+ 1)
   ELSE
    CALL complete_addcomm_flow_dp_and_nvp(dummy_parm1)
    SET dprequest->dplist[1].view_seq = flowsheets->flist[flow_clinasses_idx].view_seq
    IF ((dprequest->dplist[1].view_seq=0))
     SET dprequest->dplist[1].comp_seq = 0
    ELSE
     SET dprequest->dplist[1].comp_seq = 1
    ENDIF
    SET dprequest->dplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
    IF ((dpreply->dplist[1].detail_prefs_id > 0))
     SET add_comments_exists = 0
     SET add_comm_pvc_value = 0
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
       AND nvp.pvc_name="ADD_COMMENTS"
       AND nvp.active_ind=1
      DETAIL
       add_comments_exists = 1, add_comm_pvc_value = cnvtint(nvp.pvc_value)
      WITH nocounter
     ;end select
     IF (add_comments_exists=1)
      IF (add_comm_pvc_value != commentresult_off_on_ind)
       SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
       SET nvprequest->nvplist[1].action_flag = "2"
       SET trace = recpersist
       EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
        nvpreply)
      ENDIF
     ELSE
      SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
      SET nvprequest->nvplist[1].action_flag = "1"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
    ELSE
     SET dprequest->dplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
     SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ENDIF
   IF (flow_physoff_ind=0)
    SET vprequest->vplist[1].view_seq = tot_view_seq
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
    CALL complete_flow_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].pvc_value = "Flowsheet - Physician Office/Clinic"
    SET nvprequest->nvplist[1].action_flag = "1"
    SET nvprequest->nvplist[2].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    SET vcprequest->vcplist[1].view_seq = tot_view_seq
    IF (tot_view_seq=0)
     SET vcprequest->vcplist[1].comp_seq = 0
    ELSE
     SET vcprequest->vcplist[1].comp_seq = 1
    ENDIF
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    CALL complete_flow_vcp_nvp(dummy_parm1)
    IF (tot_view_seq=0)
     SET nvprequest->nvplist[1].pvc_value = "PVFlowsheet.dll"
     SET nvprequest->nvplist[5].pvc_value = "33246"
    ELSE
     SET nvprequest->nvplist[1].pvc_value = "PVFLOWSHEET"
     SET nvprequest->nvplist[5].pvc_value = "0"
    ENDIF
    SET nvprequest->nvplist[1].action_flag = "1"
    SET nvprequest->nvplist[2].action_flag = "1"
    SET nvprequest->nvplist[3].action_flag = "1"
    SET nvprequest->nvplist[4].action_flag = "1"
    SET nvprequest->nvplist[5].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    CALL complete_addcomm_flow_dp_and_nvp(dummy_parm1)
    SET dprequest->dplist[1].view_seq = tot_view_seq
    IF (tot_view_seq=0)
     SET dprequest->dplist[1].comp_seq = 0
    ELSE
     SET dprequest->dplist[1].comp_seq = 1
    ENDIF
    SET dprequest->dplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
    SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    SET tot_view_seq = (tot_view_seq+ 1)
   ELSE
    CALL complete_addcomm_flow_dp_and_nvp(dummy_parm1)
    SET dprequest->dplist[1].view_seq = flowsheets->flist[flow_physoff_idx].view_seq
    IF ((dprequest->dplist[1].view_seq=0))
     SET dprequest->dplist[1].comp_seq = 0
    ELSE
     SET dprequest->dplist[1].comp_seq = 1
    ENDIF
    SET dprequest->dplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
    IF ((dpreply->dplist[1].detail_prefs_id > 0))
     SET add_comments_exists = 0
     SET add_comm_pvc_value = 0
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
       AND nvp.pvc_name="ADD_COMMENTS"
       AND nvp.active_ind=1
      DETAIL
       add_comments_exists = 1, add_comm_pvc_value = cnvtint(nvp.pvc_value)
      WITH nocounter
     ;end select
     IF (add_comments_exists=1)
      IF (add_comm_pvc_value != commentresult_off_on_ind)
       SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
       SET nvprequest->nvplist[1].action_flag = "2"
       SET trace = recpersist
       EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
        nvpreply)
      ENDIF
     ELSE
      SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
      SET nvprequest->nvplist[1].action_flag = "1"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
    ELSE
     SET dprequest->dplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
     SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ENDIF
   IF (phys_ind=1)
    IF (flow_2day_ind=0)
     SET vprequest->vplist[1].view_seq = tot_view_seq
     SET trace = recpersist
     EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
     CALL complete_flow_vp_nvp(dummy_parm1)
     SET nvprequest->nvplist[1].pvc_value = "Flowsheet - 2 day Lab, Rad, Vitals"
     SET nvprequest->nvplist[1].action_flag = "1"
     SET nvprequest->nvplist[2].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
     SET vcprequest->vcplist[1].view_seq = tot_view_seq
     IF (tot_view_seq=0)
      SET vcprequest->vcplist[1].comp_seq = 0
     ELSE
      SET vcprequest->vcplist[1].comp_seq = 1
     ENDIF
     SET trace = recpersist
     EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",
      vcpreply)
     CALL complete_flow_vcp_nvp(dummy_parm1)
     IF (tot_view_seq=0)
      SET nvprequest->nvplist[1].pvc_value = "PVFlowsheet.dll"
      SET nvprequest->nvplist[5].pvc_value = "33246"
     ELSE
      SET nvprequest->nvplist[1].pvc_value = "PVFLOWSHEET"
      SET nvprequest->nvplist[5].pvc_value = "0"
     ENDIF
     SET nvprequest->nvplist[1].action_flag = "1"
     SET nvprequest->nvplist[2].action_flag = "1"
     SET nvprequest->nvplist[3].action_flag = "1"
     SET nvprequest->nvplist[4].action_flag = "1"
     SET nvprequest->nvplist[5].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
     CALL complete_addcomm_flow_dp_and_nvp(dummy_parm1)
     SET dprequest->dplist[1].view_seq = tot_view_seq
     IF (tot_view_seq=0)
      SET dprequest->dplist[1].comp_seq = 0
     ELSE
      SET dprequest->dplist[1].comp_seq = 1
     ENDIF
     SET dprequest->dplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
     SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
     SET tot_view_seq = (tot_view_seq+ 1)
    ELSE
     CALL complete_addcomm_flow_dp_and_nvp(dummy_parm1)
     SET dprequest->dplist[1].view_seq = flowsheets->flist[flow_2day_idx].view_seq
     IF ((dprequest->dplist[1].view_seq=0))
      SET dprequest->dplist[1].comp_seq = 0
     ELSE
      SET dprequest->dplist[1].comp_seq = 1
     ENDIF
     SET dprequest->dplist[1].action_flag = "0"
     SET trace = recpersist
     EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
     IF ((dpreply->dplist[1].detail_prefs_id > 0))
      SET add_comments_exists = 0
      SET add_comm_pvc_value = 0
      SELECT INTO "NL:"
       FROM name_value_prefs nvp
       WHERE nvp.parent_entity_name="DETAIL_PREFS"
        AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
        AND nvp.pvc_name="ADD_COMMENTS"
        AND nvp.active_ind=1
       DETAIL
        add_comments_exists = 1, add_comm_pvc_value = cnvtint(nvp.pvc_value)
       WITH nocounter
      ;end select
      IF (add_comments_exists=1)
       IF (add_comm_pvc_value != commentresult_off_on_ind)
        SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
        SET nvprequest->nvplist[1].action_flag = "2"
        SET trace = recpersist
        EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
         nvpreply)
       ENDIF
      ELSE
       SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
       SET nvprequest->nvplist[1].action_flag = "1"
       SET trace = recpersist
       EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
        nvpreply)
      ENDIF
     ELSE
      SET dprequest->dplist[1].action_flag = "1"
      SET trace = recpersist
      EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
      SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
      SET nvprequest->nvplist[1].action_flag = "1"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
    ENDIF
   ENDIF
   CALL complete_addcomm_pos_dp_and_nvp(dummy_parm1)
   SET dprequest->dplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
   IF ((dpreply->dplist[1].detail_prefs_id > 0))
    SET add_comments_exists = 0
    SET add_comm_pvc_value = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
      AND nvp.pvc_name="ADD_COMMENTS"
      AND nvp.active_ind=1
     DETAIL
      add_comments_exists = 1, add_comm_pvc_value = cnvtint(nvp.pvc_value)
     WITH nocounter
    ;end select
    IF (add_comments_exists=1)
     IF (add_comm_pvc_value != commentresult_off_on_ind)
      SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
      SET nvprequest->nvplist[1].action_flag = "2"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
    ELSE
     SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ELSE
    SET dprequest->dplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
    SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ELSE
   IF (flow_lab_ind=1)
    CALL complete_flow_vp_and_vcp(dummy_parm1)
    SET vprequest->vplist[1].view_seq = flowsheets->flist[flow_lab_idx].view_seq
    SET vprequest->vplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
    IF ((vpreply->vplist[1].view_prefs_id > 0))
     CALL complete_flow_vp_nvp(dummy_parm1)
     SET vprequest->vplist[1].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
     SET nvprequest->nvplist[1].pvc_value = "Flowsheet - Lab"
     SET nvprequest->nvplist[1].action_flag = "3"
     SET nvprequest->nvplist[2].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
    SET vcprequest->vcplist[1].view_seq = flowsheets->flist[flow_lab_idx].view_seq
    IF ((vcprequest->vcplist[1].view_seq=0))
     SET vcprequest->vcplist[1].comp_seq = 0
    ELSE
     SET vcprequest->vcplist[1].comp_seq = 1
    ENDIF
    SET vcprequest->vcplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
     CALL complete_flow_vcp_nvp(dummy_parm1)
     SET vcprequest->vcplist[1].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",
      vcpreply)
     IF ((vcprequest->vcplist[1].view_seq=0))
      SET nvprequest->nvplist[1].pvc_value = "PVFlowsheet.dll"
      SET nvprequest->nvplist[5].pvc_value = "33246"
     ELSE
      SET nvprequest->nvplist[1].pvc_value = "PVFLOWSHEET"
      SET nvprequest->nvplist[5].pvc_value = "0"
     ENDIF
     SET nvprequest->nvplist[1].action_flag = "3"
     SET nvprequest->nvplist[2].action_flag = "3"
     SET nvprequest->nvplist[3].action_flag = "3"
     SET nvprequest->nvplist[4].action_flag = "3"
     SET nvprequest->nvplist[5].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
    CALL complete_addcomm_flow_dp_and_nvp(dummy_parm1)
    SET dprequest->dplist[1].view_seq = flowsheets->flist[flow_lab_idx].view_seq
    IF ((dprequest->dplist[1].view_seq=0))
     SET dprequest->dplist[1].comp_seq = 0
    ELSE
     SET dprequest->dplist[1].comp_seq = 1
    ENDIF
    SET dprequest->dplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
    IF ((dpreply->dplist[1].detail_prefs_id > 0))
     SET dprequest->dplist[1].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
     SET hold_name_value_prefs_id = 0.0
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
       AND nvp.pvc_name="ADD_COMMENTS"
       AND nvp.active_ind=1
      DETAIL
       hold_name_value_prefs_id = nvp.name_value_prefs_id
      WITH nocounter
     ;end select
     IF (hold_name_value_prefs_id > 0)
      DELETE  FROM name_value_prefs nvp
       WHERE nvp.name_value_prefs_id=hold_name_value_prefs_id
       WITH nocounter
      ;end delete
     ENDIF
    ENDIF
   ENDIF
   IF (flow_rad_ind=1)
    CALL complete_flow_vp_and_vcp(dummy_parm1)
    SET vprequest->vplist[1].view_seq = flowsheets->flist[flow_rad_idx].view_seq
    SET vprequest->vplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
    IF ((vpreply->vplist[1].view_prefs_id > 0))
     CALL complete_flow_vp_nvp(dummy_parm1)
     SET vprequest->vplist[1].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
     SET nvprequest->nvplist[1].pvc_value = "Flowsheet - Radiology"
     SET nvprequest->nvplist[1].action_flag = "3"
     SET nvprequest->nvplist[2].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
    SET vcprequest->vcplist[1].view_seq = flowsheets->flist[flow_rad_idx].view_seq
    IF ((vcprequest->vcplist[1].view_seq=0))
     SET vcprequest->vcplist[1].comp_seq = 0
    ELSE
     SET vcprequest->vcplist[1].comp_seq = 1
    ENDIF
    SET vcprequest->vcplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
     CALL complete_flow_vcp_nvp(dummy_parm1)
     SET vcprequest->vcplist[1].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",
      vcpreply)
     IF ((vcprequest->vcplist[1].view_seq=0))
      SET nvprequest->nvplist[1].pvc_value = "PVFlowsheet.dll"
      SET nvprequest->nvplist[5].pvc_value = "33246"
     ELSE
      SET nvprequest->nvplist[1].pvc_value = "PVFLOWSHEET"
      SET nvprequest->nvplist[5].pvc_value = "0"
     ENDIF
     SET nvprequest->nvplist[1].action_flag = "3"
     SET nvprequest->nvplist[2].action_flag = "3"
     SET nvprequest->nvplist[3].action_flag = "3"
     SET nvprequest->nvplist[4].action_flag = "3"
     SET nvprequest->nvplist[5].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
    CALL complete_addcomm_flow_dp_and_nvp(dummy_parm1)
    SET dprequest->dplist[1].view_seq = flowsheets->flist[flow_rad_idx].view_seq
    IF ((dprequest->dplist[1].view_seq=0))
     SET dprequest->dplist[1].comp_seq = 0
    ELSE
     SET dprequest->dplist[1].comp_seq = 1
    ENDIF
    SET dprequest->dplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
    IF ((dpreply->dplist[1].detail_prefs_id > 0))
     SET dprequest->dplist[1].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
     SET hold_name_value_prefs_id = 0.0
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
       AND nvp.pvc_name="ADD_COMMENTS"
       AND nvp.active_ind=1
      DETAIL
       hold_name_value_prefs_id = nvp.name_value_prefs_id
      WITH nocounter
     ;end select
     IF (hold_name_value_prefs_id > 0)
      DELETE  FROM name_value_prefs nvp
       WHERE nvp.name_value_prefs_id=hold_name_value_prefs_id
       WITH nocounter
      ;end delete
     ENDIF
    ENDIF
   ENDIF
   IF (flow_clinasses_ind=1)
    CALL complete_flow_vp_and_vcp(dummy_parm1)
    SET vprequest->vplist[1].view_seq = flowsheets->flist[flow_clinasses_idx].view_seq
    SET vprequest->vplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
    IF ((vpreply->vplist[1].view_prefs_id > 0))
     CALL complete_flow_vp_nvp(dummy_parm1)
     SET vprequest->vplist[1].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
     SET nvprequest->nvplist[1].pvc_value = "Flowsheet - Clinical Assessments"
     SET nvprequest->nvplist[1].action_flag = "3"
     SET nvprequest->nvplist[2].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
    SET vcprequest->vcplist[1].view_seq = flowsheets->flist[flow_clinasses_idx].view_seq
    IF ((vcprequest->vcplist[1].view_seq=0))
     SET vcprequest->vcplist[1].comp_seq = 0
    ELSE
     SET vcprequest->vcplist[1].comp_seq = 1
    ENDIF
    SET vcprequest->vcplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
     CALL complete_flow_vcp_nvp(dummy_parm1)
     SET vcprequest->vcplist[1].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",
      vcpreply)
     IF ((vcprequest->vcplist[1].view_seq=0))
      SET nvprequest->nvplist[1].pvc_value = "PVFlowsheet.dll"
      SET nvprequest->nvplist[5].pvc_value = "33246"
     ELSE
      SET nvprequest->nvplist[1].pvc_value = "PVFLOWSHEET"
      SET nvprequest->nvplist[5].pvc_value = "0"
     ENDIF
     SET nvprequest->nvplist[1].action_flag = "3"
     SET nvprequest->nvplist[2].action_flag = "3"
     SET nvprequest->nvplist[3].action_flag = "3"
     SET nvprequest->nvplist[4].action_flag = "3"
     SET nvprequest->nvplist[5].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
    CALL complete_addcomm_flow_dp_and_nvp(dummy_parm1)
    SET dprequest->dplist[1].view_seq = flowsheets->flist[flow_clinasses_idx].view_seq
    IF ((dprequest->dplist[1].view_seq=0))
     SET dprequest->dplist[1].comp_seq = 0
    ELSE
     SET dprequest->dplist[1].comp_seq = 1
    ENDIF
    SET dprequest->dplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
    IF ((dpreply->dplist[1].detail_prefs_id > 0))
     SET dprequest->dplist[1].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
     SET hold_name_value_prefs_id = 0.0
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
       AND nvp.pvc_name="ADD_COMMENTS"
       AND nvp.active_ind=1
      DETAIL
       hold_name_value_prefs_id = nvp.name_value_prefs_id
      WITH nocounter
     ;end select
     IF (hold_name_value_prefs_id > 0)
      DELETE  FROM name_value_prefs nvp
       WHERE nvp.name_value_prefs_id=hold_name_value_prefs_id
       WITH nocounter
      ;end delete
     ENDIF
    ENDIF
   ENDIF
   IF (flow_physoff_ind=1)
    CALL complete_flow_vp_and_vcp(dummy_parm1)
    SET vprequest->vplist[1].view_seq = flowsheets->flist[flow_physoff_idx].view_seq
    SET vprequest->vplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
    IF ((vpreply->vplist[1].view_prefs_id > 0))
     CALL complete_flow_vp_nvp(dummy_parm1)
     SET vprequest->vplist[1].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
     SET nvprequest->nvplist[1].pvc_value = "Flowsheet - Physician Office/Clinic"
     SET nvprequest->nvplist[1].action_flag = "3"
     SET nvprequest->nvplist[2].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
    SET vcprequest->vcplist[1].view_seq = flowsheets->flist[flow_physoff_idx].view_seq
    IF ((vcprequest->vcplist[1].view_seq=0))
     SET vcprequest->vcplist[1].comp_seq = 0
    ELSE
     SET vcprequest->vcplist[1].comp_seq = 1
    ENDIF
    SET vcprequest->vcplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
     CALL complete_flow_vcp_nvp(dummy_parm1)
     SET vcprequest->vcplist[1].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",
      vcpreply)
     IF ((vcprequest->vcplist[1].view_seq=0))
      SET nvprequest->nvplist[1].pvc_value = "PVFlowsheet.dll"
      SET nvprequest->nvplist[5].pvc_value = "33246"
     ELSE
      SET nvprequest->nvplist[1].pvc_value = "PVFLOWSHEET"
      SET nvprequest->nvplist[5].pvc_value = "0"
     ENDIF
     SET nvprequest->nvplist[1].action_flag = "3"
     SET nvprequest->nvplist[2].action_flag = "3"
     SET nvprequest->nvplist[3].action_flag = "3"
     SET nvprequest->nvplist[4].action_flag = "3"
     SET nvprequest->nvplist[5].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
    CALL complete_addcomm_flow_dp_and_nvp(dummy_parm1)
    SET dprequest->dplist[1].view_seq = flowsheets->flist[flow_physoff_idx].view_seq
    IF ((dprequest->dplist[1].view_seq=0))
     SET dprequest->dplist[1].comp_seq = 0
    ELSE
     SET dprequest->dplist[1].comp_seq = 1
    ENDIF
    SET dprequest->dplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
    IF ((dpreply->dplist[1].detail_prefs_id > 0))
     SET dprequest->dplist[1].action_flag = "3"
     SET trace = recpersist
     EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
     SET hold_name_value_prefs_id = 0.0
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
       AND nvp.pvc_name="ADD_COMMENTS"
       AND nvp.active_ind=1
      DETAIL
       hold_name_value_prefs_id = nvp.name_value_prefs_id
      WITH nocounter
     ;end select
     IF (hold_name_value_prefs_id > 0)
      DELETE  FROM name_value_prefs nvp
       WHERE nvp.name_value_prefs_id=hold_name_value_prefs_id
       WITH nocounter
      ;end delete
     ENDIF
    ENDIF
   ENDIF
   IF (phys_ind=1)
    IF (flow_2day_ind=1)
     CALL complete_flow_vp_and_vcp(dummy_parm1)
     SET vprequest->vplist[1].view_seq = flowsheets->flist[flow_2day_idx].view_seq
     SET vprequest->vplist[1].action_flag = "0"
     SET trace = recpersist
     EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
     IF ((vpreply->vplist[1].view_prefs_id > 0))
      CALL complete_flow_vp_nvp(dummy_parm1)
      SET vprequest->vplist[1].action_flag = "3"
      SET trace = recpersist
      EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
      SET nvprequest->nvplist[1].pvc_value = "Flowsheet - 2 day Lab, Rad, Vitals"
      SET nvprequest->nvplist[1].action_flag = "3"
      SET nvprequest->nvplist[2].action_flag = "3"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     SET vcprequest->vcplist[1].view_seq = flowsheets->flist[flow_2day_idx].view_seq
     IF ((vcprequest->vcplist[1].view_seq=0))
      SET vcprequest->vcplist[1].comp_seq = 0
     ELSE
      SET vcprequest->vcplist[1].comp_seq = 1
     ENDIF
     SET vcprequest->vcplist[1].action_flag = "0"
     SET trace = recpersist
     EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",
      vcpreply)
     IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
      CALL complete_flow_vcp_nvp(dummy_parm1)
      SET vcprequest->vcplist[1].action_flag = "3"
      SET trace = recpersist
      EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",
       vcpreply)
      IF ((vcprequest->vcplist[1].view_seq=0))
       SET nvprequest->nvplist[1].pvc_value = "PVFlowsheet.dll"
       SET nvprequest->nvplist[5].pvc_value = "33246"
      ELSE
       SET nvprequest->nvplist[1].pvc_value = "PVFLOWSHEET"
       SET nvprequest->nvplist[5].pvc_value = "0"
      ENDIF
      SET nvprequest->nvplist[1].action_flag = "3"
      SET nvprequest->nvplist[2].action_flag = "3"
      SET nvprequest->nvplist[3].action_flag = "3"
      SET nvprequest->nvplist[4].action_flag = "3"
      SET nvprequest->nvplist[5].action_flag = "3"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     CALL complete_addcomm_flow_dp_and_nvp(dummy_parm1)
     SET dprequest->dplist[1].view_seq = flowsheets->flist[flow_2day_idx].view_seq
     IF ((dprequest->dplist[1].view_seq=0))
      SET dprequest->dplist[1].comp_seq = 0
     ELSE
      SET dprequest->dplist[1].comp_seq = 1
     ENDIF
     SET dprequest->dplist[1].action_flag = "0"
     SET trace = recpersist
     EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
     IF ((dpreply->dplist[1].detail_prefs_id > 0))
      SET dprequest->dplist[1].action_flag = "3"
      SET trace = recpersist
      EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
      SET hold_name_value_prefs_id = 0.0
      SELECT INTO "NL:"
       FROM name_value_prefs nvp
       WHERE nvp.parent_entity_name="DETAIL_PREFS"
        AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
        AND nvp.pvc_name="ADD_COMMENTS"
        AND nvp.active_ind=1
       DETAIL
        hold_name_value_prefs_id = nvp.name_value_prefs_id
       WITH nocounter
      ;end select
      IF (hold_name_value_prefs_id > 0)
       DELETE  FROM name_value_prefs nvp
        WHERE nvp.name_value_prefs_id=hold_name_value_prefs_id
        WITH nocounter
       ;end delete
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   SELECT INTO "NL:"
    FROM view_prefs vp,
     name_value_prefs nvp
    PLAN (vp
     WHERE vp.view_prefs_id > 0.0
      AND (vp.application_number=request->application_number)
      AND (vp.position_cd=request->position_cd)
      AND vp.prsnl_id=0.0
      AND vp.frame_type="CHART"
      AND vp.view_name="FLOWSHEET"
      AND vp.active_ind=1)
     JOIN (nvp
     WHERE nvp.parent_entity_name="VIEW_PREFS"
      AND nvp.parent_entity_id=vp.view_prefs_id
      AND nvp.pvc_name="VIEW_CAPTION"
      AND nvp.active_ind=1)
    ORDER BY vp.view_seq
    HEAD REPORT
     flow_cnt = 0
    DETAIL
     flow_cnt = (flow_cnt+ 1), stat = alterlist(flowsheets->flist,flow_cnt), flowsheets->flist[
     flow_cnt].pvc_value = nvp.pvc_value,
     flowsheets->flist[flow_cnt].view_seq = vp.view_seq, flowsheets->flist[flow_cnt].vp_id = vp
     .view_prefs_id
    WITH nocounter
   ;end select
   IF (flow_cnt > 0)
    FOR (x = 1 TO flow_cnt)
      SET new_view_seq = (x - 1)
      IF (new_view_seq=0)
       SET new_comp_seq = 0
      ELSE
       SET new_comp_seq = 1
      ENDIF
      UPDATE  FROM view_prefs vp
       SET vp.view_seq = new_view_seq, vp.updt_cnt = (vp.updt_cnt+ 1), vp.updt_id = reqinfo->updt_id,
        vp.updt_dt_tm = cnvtdatetime(curdate,curtime), vp.updt_task = reqinfo->updt_task, vp
        .updt_applctx = reqinfo->updt_applctx
       WHERE (vp.view_prefs_id=flowsheets->flist[x].vp_id)
       WITH nocounter
      ;end update
      CALL complete_flow_vp_and_vcp(dummy_parm1)
      SET vcprequest->vcplist[1].view_seq = flowsheets->flist[x].view_seq
      IF ((vcprequest->vcplist[1].view_seq=0))
       SET vcprequest->vcplist[1].comp_seq = 0
      ELSE
       SET vcprequest->vcplist[1].comp_seq = 1
      ENDIF
      SET vcprequest->vcplist[1].action_flag = "0"
      SET trace = recpersist
      EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",
       vcpreply)
      IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
       UPDATE  FROM view_comp_prefs vcp
        SET vcp.view_seq = new_view_seq, vcp.comp_seq = new_comp_seq, vcp.updt_cnt = (vcp.updt_cnt+ 1
         ),
         vcp.updt_id = reqinfo->updt_id, vcp.updt_dt_tm = cnvtdatetime(curdate,curtime), vcp
         .updt_task = reqinfo->updt_task,
         vcp.updt_applctx = reqinfo->updt_applctx
        WHERE (vcp.view_comp_prefs_id=vcpreply->vcplist[1].view_comp_prefs_id)
        WITH nocounter
       ;end update
       IF (new_view_seq=0)
        SET stat = alterlist(nvprequest->nvplist,2)
        SET stat = alterlist(nvpreply->nvplist,2)
        SET nvprequest->nvplist[1].parent_entity_name = "VIEW_COMP_PREFS"
        SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
        SET nvprequest->nvplist[1].pvc_name = "COMP_DLLNAME"
        SET nvprequest->nvplist[1].pvc_value = "PVFlowsheet.dll"
        SET nvprequest->nvplist[1].action_flag = "2"
        SET nvprequest->nvplist[2].parent_entity_name = "VIEW_COMP_PREFS"
        SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
        SET nvprequest->nvplist[2].pvc_name = "COMMAND_ID"
        SET nvprequest->nvplist[2].pvc_value = "33246"
        SET nvprequest->nvplist[2].action_flag = "2"
        SET trace = recpersist
        EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
         nvpreply)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (flow_cnt > 0)
    FOR (x = 1 TO flow_cnt)
      SET stat = alterlist(dprequest->dplist,1)
      SET stat = alterlist(dpreply->dplist,1)
      SET dprequest->dplist[1].application_number = request->application_number
      SET dprequest->dplist[1].position_cd = request->position_cd
      SET dprequest->dplist[1].prsnl_id = request->prsnl_id
      SET dprequest->dplist[1].person_id = 0.0
      SET dprequest->dplist[1].view_name = "FLOWSHEET"
      SET dprequest->dplist[1].comp_name = "FLOWSHEET"
      SET dprequest->dplist[1].view_seq = flowsheets->flist[x].view_seq
      IF ((dprequest->dplist[1].view_seq=0))
       SET dprequest->dplist[1].comp_seq = 0
      ELSE
       SET dprequest->dplist[1].comp_seq = 1
      ENDIF
      SET dprequest->dplist[1].action_flag = "0"
      SET trace = recpersist
      EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
      IF ((dpreply->dplist[1].detail_prefs_id > 0))
       UPDATE  FROM detail_prefs dp
        SET dp.view_seq = new_view_seq, dp.comp_seq = new_comp_seq, dp.updt_cnt = (dp.updt_cnt+ 1),
         dp.updt_id = reqinfo->updt_id, dp.updt_dt_tm = cnvtdatetime(curdate,curtime), dp.updt_task
          = reqinfo->updt_task,
         dp.updt_applctx = reqinfo->updt_applctx
        WHERE (dp.detail_prefs_id=dpreply->dplist[1].detail_prefs_id)
        WITH nocounter
       ;end update
      ENDIF
    ENDFOR
   ENDIF
   CALL complete_addcomm_pos_dp_and_nvp(dummy_parm1)
   SET dprequest->dplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
   IF ((dpreply->dplist[1].detail_prefs_id > 0))
    SET add_comments_exists = 0
    SET add_comm_pvc_value = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
      AND nvp.pvc_name="ADD_COMMENTS"
      AND nvp.active_ind=1
     DETAIL
      add_comments_exists = 1, add_comm_pvc_value = cnvtint(nvp.pvc_value)
     WITH nocounter
    ;end select
    IF (add_comments_exists=1)
     IF (add_comm_pvc_value > 0)
      SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
      SET nvprequest->nvplist[1].action_flag = "2"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
    ELSE
     SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ELSE
    SET dprequest->dplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
    SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
    SET nvprequest->nvplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ENDIF
  SET row_cnt = 0
  SET encsummary_value = " "
  CALL complete_encsumm_dp(dummy_parm1)
  SET dprequest->dplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
  IF ((dpreply->dplist[1].detail_prefs_id > 0))
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
     AND nvp.pvc_name="SHOW_ORDERTESTS"
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
  SET hold_detail_prefs_id = dpreply->dplist[1].detail_prefs_id
  IF (viewresult_off_on_ind=1)
   CALL complete_encsumm_dp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = hold_detail_prefs_id
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
   SET multitaskrequest->action = "0"
   SET multitaskrequest->application_number = 961000
   SET multitaskrequest->position_cd = request->position_cd
   SET multitaskrequest->prsnl_id = 0.0
   SET stat = alterlist(multitaskrequest->task_list,11)
   SET stat = alterlist(multitaskreply->status_data.status_list,11)
   SET multitaskrequest->task_list[1].task = "ORDER"
   SET multitaskrequest->task_list[2].task = "VIEWORDER"
   SET multitaskrequest->task_list[3].task = "ORDERPROFILE"
   SET multitaskrequest->task_list[4].task = "CANCELORDER"
   SET multitaskrequest->task_list[5].task = "COMPLETEORDER"
   SET multitaskrequest->task_list[6].task = "MODIFYMEDSTUDORDER"
   SET multitaskrequest->task_list[7].task = "MODIFYORDER"
   SET multitaskrequest->task_list[8].task = "REPEATORDER"
   SET multitaskrequest->task_list[9].task = "RESCHEDORDER"
   SET multitaskrequest->task_list[10].task = "SUSPENDORDER"
   SET multitaskrequest->task_list[11].task = "VOIDORDER"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_order  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
   IF ((multitaskreply->status_data.status_list[1].status != "1")
    AND (multitaskreply->status_data.status_list[2].status != "1")
    AND (multitaskreply->status_data.status_list[3].status != "1"))
    CALL complete_encsumm_dp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = hold_detail_prefs_id
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
  ENDIF
  IF (viewresult_off_on_ind=1)
   CALL complete_newrsltdlg_vp(dummy_parm1)
   SET vprequest->vplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   IF ((vpreply->vplist[1].view_prefs_id=0))
    SET vprequest->vplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   ENDIF
   IF ((vpreply->vplist[1].view_prefs_id > 0))
    CALL complete_newrsltdlg_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[3].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[4].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[1].action_flag = "0"
    SET nvprequest->nvplist[2].action_flag = "0"
    SET nvprequest->nvplist[3].action_flag = "0"
    SET nvprequest->nvplist[4].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    IF ((nvpreply->nvplist[1].name_value_prefs_id=0)
     AND (nvpreply->nvplist[2].name_value_prefs_id=0)
     AND (nvpreply->nvplist[3].name_value_prefs_id=0)
     AND (nvpreply->nvplist[4].name_value_prefs_id=0))
     SET nvprequest->nvplist[1].action_flag = "1"
     SET nvprequest->nvplist[2].action_flag = "1"
     SET nvprequest->nvplist[3].action_flag = "1"
     SET nvprequest->nvplist[4].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ELSE
     SET hold_nvp1 = nvpreply->nvplist[1].name_value_prefs_id
     SET hold_nvp2 = nvpreply->nvplist[2].name_value_prefs_id
     SET hold_nvp3 = nvpreply->nvplist[3].name_value_prefs_id
     SET hold_nvp4 = nvpreply->nvplist[4].name_value_prefs_id
     SET nvprequest->nvplist[1].action_flag = "1"
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     IF (hold_nvp1=0)
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp2=0)
      SET nvprequest->nvplist[1].pvc_name = "DLL_NAME"
      SET nvprequest->nvplist[1].pvc_value = " "
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp3=0)
      SET nvprequest->nvplist[1].pvc_name = "VIEW_CAPTION"
      SET nvprequest->nvplist[1].pvc_value = "Flowsheet New Results"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp4=0)
      SET nvprequest->nvplist[1].pvc_name = "VIEW_IND"
      SET nvprequest->nvplist[1].pvc_value = "0"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
    ENDIF
   ENDIF
   CALL complete_newrsltdlg_vcp(dummy_parm1)
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
    CALL complete_newrsltdlg_vcp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[1].action_flag = "0"
    SET nvprequest->nvplist[2].action_flag = "0"
    SET nvprequest->nvplist[3].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    IF ((nvpreply->nvplist[1].name_value_prefs_id=0)
     AND (nvpreply->nvplist[2].name_value_prefs_id=0)
     AND (nvpreply->nvplist[3].name_value_prefs_id=0))
     SET nvprequest->nvplist[1].action_flag = "1"
     SET nvprequest->nvplist[2].action_flag = "1"
     SET nvprequest->nvplist[3].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ELSE
     SET hold_nvp1 = nvpreply->nvplist[1].name_value_prefs_id
     SET hold_nvp2 = nvpreply->nvplist[2].name_value_prefs_id
     SET hold_nvp3 = nvpreply->nvplist[3].name_value_prefs_id
     SET nvprequest->nvplist[1].action_flag = "1"
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     IF (hold_nvp1=0)
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp2=0)
      SET nvprequest->nvplist[1].pvc_name = "COMP_DLLNAME"
      SET nvprequest->nvplist[1].pvc_value = "PVFLOWSHEET"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp3=0)
      SET nvprequest->nvplist[1].pvc_name = "PROG_ID"
      SET nvprequest->nvplist[1].pvc_value = "FLOWSHEET.FLOWSHEET"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
    ENDIF
   ENDIF
  ELSE
   CALL complete_newrsltdlg_vp(dummy_parm1)
   SET vprequest->vplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   IF ((vpreply->vplist[1].view_prefs_id > 0))
    CALL complete_newrsltdlg_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[3].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[4].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET vprequest->vplist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
    SET nvprequest->nvplist[1].action_flag = "3"
    SET nvprequest->nvplist[2].action_flag = "3"
    SET nvprequest->nvplist[3].action_flag = "3"
    SET nvprequest->nvplist[4].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
   CALL complete_newrsltdlg_vcp(dummy_parm1)
   SET vcprequest->vcplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply)
   IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
    CALL complete_newrsltdlg_vcp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET vcprequest->vcplist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    SET nvprequest->nvplist[1].action_flag = "3"
    SET nvprequest->nvplist[2].action_flag = "3"
    SET nvprequest->nvplist[3].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ENDIF
  IF (viewresult_off_on_ind=1)
   CALL complete_inboxfsdlg_vp(dummy_parm1)
   SET vprequest->vplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   IF ((vpreply->vplist[1].view_prefs_id=0))
    SET vprequest->vplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   ENDIF
   IF ((vpreply->vplist[1].view_prefs_id > 0))
    CALL complete_inboxfsdlg_vp_nvp(dummy_parm1)
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
    ELSE
     SET hold_nvp1 = nvpreply->nvplist[1].name_value_prefs_id
     SET hold_nvp2 = nvpreply->nvplist[2].name_value_prefs_id
     SET nvprequest->nvplist[1].action_flag = "1"
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     IF (hold_nvp1=0)
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp2=0)
      SET nvprequest->nvplist[1].pvc_name = "VIEW_IND"
      SET nvprequest->nvplist[1].pvc_value = "0"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
    ENDIF
   ENDIF
  ELSE
   CALL complete_inboxfsdlg_vp(dummy_parm1)
   SET vprequest->vplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   IF ((vpreply->vplist[1].view_prefs_id > 0))
    CALL complete_inboxfsdlg_vp_nvp(dummy_parm1)
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
  ENDIF
  IF (viewresult_off_on_ind=1)
   CALL complete_clinnotes_vp(dummy_parm1)
   SET vprequest->vplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   IF ((vpreply->vplist[1].view_prefs_id=0))
    SET vprequest->vplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   ENDIF
   IF ((vpreply->vplist[1].view_prefs_id > 0))
    CALL complete_clinnotes_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[3].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[1].action_flag = "0"
    SET nvprequest->nvplist[2].action_flag = "0"
    SET nvprequest->nvplist[3].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    IF ((nvpreply->nvplist[1].name_value_prefs_id=0)
     AND (nvpreply->nvplist[2].name_value_prefs_id=0)
     AND (nvpreply->nvplist[3].name_value_prefs_id=0))
     SET nvprequest->nvplist[1].action_flag = "1"
     SET nvprequest->nvplist[2].action_flag = "1"
     SET nvprequest->nvplist[3].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ELSE
     SET hold_nvp1 = nvpreply->nvplist[1].name_value_prefs_id
     SET hold_nvp2 = nvpreply->nvplist[2].name_value_prefs_id
     SET hold_nvp3 = nvpreply->nvplist[3].name_value_prefs_id
     SET nvprequest->nvplist[1].action_flag = "1"
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     IF (hold_nvp1=0)
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp2=0)
      SET nvprequest->nvplist[1].pvc_name = "VIEW_CAPTION"
      SET nvprequest->nvplist[1].pvc_value = "Document Viewer"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp3=0)
      SET nvprequest->nvplist[1].pvc_name = "VIEW_IND"
      SET nvprequest->nvplist[1].pvc_value = "0"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
    ENDIF
   ENDIF
   CALL complete_clinnotes_vcp(dummy_parm1)
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
    CALL complete_clinnotes_vcp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[1].action_flag = "0"
    SET nvprequest->nvplist[2].action_flag = "0"
    SET nvprequest->nvplist[3].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    IF ((nvpreply->nvplist[1].name_value_prefs_id=0)
     AND (nvpreply->nvplist[2].name_value_prefs_id=0)
     AND (nvpreply->nvplist[3].name_value_prefs_id=0))
     SET nvprequest->nvplist[1].action_flag = "1"
     SET nvprequest->nvplist[2].action_flag = "1"
     SET nvprequest->nvplist[3].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ELSE
     SET hold_nvp1 = nvpreply->nvplist[1].name_value_prefs_id
     SET hold_nvp2 = nvpreply->nvplist[2].name_value_prefs_id
     SET hold_nvp3 = nvpreply->nvplist[3].name_value_prefs_id
     SET nvprequest->nvplist[1].action_flag = "1"
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     IF (hold_nvp1=0)
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp2=0)
      SET nvprequest->nvplist[1].pvc_name = "COMP_POSITION"
      SET nvprequest->nvplist[1].pvc_value = "0,0,3,4"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp3=0)
      SET nvprequest->nvplist[1].pvc_name = "PROG_ID"
      SET nvprequest->nvplist[1].pvc_value = "PVNOTES.PVNOTES"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
    ENDIF
   ENDIF
  ELSE
   CALL complete_clinnotes_vp(dummy_parm1)
   SET vprequest->vplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   IF ((vpreply->vplist[1].view_prefs_id > 0))
    CALL complete_clinnotes_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[3].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET vprequest->vplist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
    SET nvprequest->nvplist[1].action_flag = "3"
    SET nvprequest->nvplist[2].action_flag = "3"
    SET nvprequest->nvplist[3].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
   CALL complete_clinnotes_vcp(dummy_parm1)
   SET vcprequest->vcplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply)
   IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
    CALL complete_clinnotes_vcp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET vcprequest->vcplist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    SET nvprequest->nvplist[1].action_flag = "3"
    SET nvprequest->nvplist[2].action_flag = "3"
    SET nvprequest->nvplist[3].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ENDIF
  SET oflowsheet_id = 0.0
  SET oflowsheet_seq = 0
  SELECT INTO "NL:"
   FROM view_prefs vp
   WHERE (vp.application_number=request->application_number)
    AND (vp.position_cd=request->position_cd)
    AND (vp.prsnl_id=request->prsnl_id)
    AND vp.frame_type="ORDINFO"
    AND vp.view_name="OFLOWSHEET"
    AND vp.active_ind=1
   DETAIL
    oflowsheet_id = vp.view_prefs_id, oflowsheet_seq = vp.view_seq
   WITH nocounter
  ;end select
  IF (viewresult_off_on_ind=1)
   IF (oflowsheet_id=0)
    SET ordinfo_row_cnt = 0
    SELECT INTO "NL:"
     FROM view_prefs vp
     WHERE (vp.application_number=request->application_number)
      AND (vp.position_cd=request->position_cd)
      AND (vp.prsnl_id=request->prsnl_id)
      AND vp.frame_type="ORDINFO"
      AND vp.active_ind=1
     DETAIL
      ordinfo_row_cnt = (ordinfo_row_cnt+ 1)
     WITH nocounter
    ;end select
    IF (ordinfo_row_cnt > 0)
     CALL create_all_oflowsheet_rows(dummy_parm1)
    ELSE
     CALL copy_app_level_ordinfo_rows(1)
    ENDIF
   ELSE
    CALL complete_oflowsheet_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = oflowsheet_id
    SET nvprequest->nvplist[2].parent_entity_id = oflowsheet_id
    SET nvprequest->nvplist[3].parent_entity_id = oflowsheet_id
    SET nvprequest->nvplist[4].parent_entity_id = oflowsheet_id
    SET nvprequest->nvplist[1].action_flag = "0"
    SET nvprequest->nvplist[2].action_flag = "0"
    SET nvprequest->nvplist[3].action_flag = "0"
    SET nvprequest->nvplist[4].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    IF ((nvpreply->nvplist[1].name_value_prefs_id=0)
     AND (nvpreply->nvplist[2].name_value_prefs_id=0)
     AND (nvpreply->nvplist[3].name_value_prefs_id=0)
     AND (nvpreply->nvplist[4].name_value_prefs_id=0))
     SET nvprequest->nvplist[1].action_flag = "1"
     SET nvprequest->nvplist[2].action_flag = "1"
     SET nvprequest->nvplist[3].action_flag = "1"
     SET nvprequest->nvplist[4].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ELSE
     SET hold_nvp1 = nvpreply->nvplist[1].name_value_prefs_id
     SET hold_nvp2 = nvpreply->nvplist[2].name_value_prefs_id
     SET hold_nvp3 = nvpreply->nvplist[3].name_value_prefs_id
     SET hold_nvp4 = nvpreply->nvplist[4].name_value_prefs_id
     SET nvprequest->nvplist[1].action_flag = "1"
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     IF (hold_nvp1=0)
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp2=0)
      SET nvprequest->nvplist[1].pvc_name = "DLL_NAME"
      SET nvprequest->nvplist[1].pvc_value = "PVOAFLOWSHEET"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp3=0)
      SET nvprequest->nvplist[1].pvc_name = "VIEW_CAPTION"
      SET nvprequest->nvplist[1].pvc_value = "Results"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp4=0)
      SET nvprequest->nvplist[1].pvc_name = "VIEW_IND"
      SET nvprequest->nvplist[1].pvc_value = "0"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
    ENDIF
    CALL complete_oflowsheet_vcp(dummy_parm1)
    SET vcprequest->vcplist[1].view_seq = oflowsheet_seq
    SET vcprequest->vcplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    IF ((vcpreply->vcplist[1].view_comp_prefs_id=0))
     SET vcprequest->vcplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",
      vcpreply)
    ENDIF
    IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
     CALL complete_oflowsheet_vcp_nvp(dummy_parm1)
     SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[1].action_flag = "0"
     SET nvprequest->nvplist[2].action_flag = "0"
     SET nvprequest->nvplist[3].action_flag = "0"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
     IF ((nvpreply->nvplist[1].name_value_prefs_id=0)
      AND (nvpreply->nvplist[2].name_value_prefs_id=0)
      AND (nvpreply->nvplist[3].name_value_prefs_id=0))
      SET nvprequest->nvplist[1].action_flag = "1"
      SET nvprequest->nvplist[2].action_flag = "1"
      SET nvprequest->nvplist[3].action_flag = "1"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ELSE
      SET hold_nvp1 = nvpreply->nvplist[1].name_value_prefs_id
      SET hold_nvp2 = nvpreply->nvplist[2].name_value_prefs_id
      SET hold_nvp3 = nvpreply->nvplist[3].name_value_prefs_id
      SET nvprequest->nvplist[1].action_flag = "1"
      SET stat = alterlist(nvprequest->nvplist,1)
      SET stat = alterlist(nvpreply->nvplist,1)
      IF (hold_nvp1=0)
       SET trace = recpersist
       EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
        nvpreply)
      ENDIF
      IF (hold_nvp2=0)
       SET nvprequest->nvplist[1].pvc_name = "COMP_POSITION"
       SET nvprequest->nvplist[1].pvc_value = "0,0,3,4"
       SET trace = recpersist
       EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
        nvpreply)
      ENDIF
      IF (hold_nvp3=0)
       SET nvprequest->nvplist[1].pvc_name = "HIDDEN_CAT_TYPE"
       SET nvprequest->nvplist[1].pvc_value = " "
       SET trace = recpersist
       EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
        nvpreply)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ELSE
   IF (oflowsheet_id > 0)
    CALL delete_all_oflowsheet_rows(dummy_parm1)
   ELSE
    SET ordinfo_row_cnt = 0
    SELECT INTO "NL:"
     FROM view_prefs vp
     WHERE (vp.application_number=request->application_number)
      AND (vp.position_cd=request->position_cd)
      AND (vp.prsnl_id=request->prsnl_id)
      AND vp.frame_type="ORDINFO"
      AND vp.active_ind=1
     DETAIL
      ordinfo_row_cnt = (ordinfo_row_cnt+ 1)
     WITH nocounter
    ;end select
    IF (ordinfo_row_cnt=0)
     CALL copy_app_level_ordinfo_rows(0)
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 GO TO exitscript
 SUBROUTINE complete_comp_auth_vp(dummy_parm2)
   SET stat = alterlist(vprequest->vplist,1)
   SET stat = alterlist(vpreply->vplist,1)
   SET vprequest->vplist[1].application_number = request->application_number
   SET vprequest->vplist[1].position_cd = request->position_cd
   SET vprequest->vplist[1].prsnl_id = request->prsnl_id
   SET vprequest->vplist[1].frame_type = "CHART"
   SET vprequest->vplist[1].view_name = "PATHIST"
   SET vprequest->vplist[1].view_seq = 0
 END ;Subroutine
 SUBROUTINE complete_comp_auth_vp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,2)
   SET stat = alterlist(nvpreply->nvplist,2)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "VIEW_CAPTION"
   SET nvprequest->nvplist[1].pvc_value = "Patient History"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "DISPLAY_SEQ"
   SET nvprequest->nvplist[2].pvc_value = "25"
 END ;Subroutine
 SUBROUTINE complete_comp_auth_vcp(dummy_parm2)
   SET stat = alterlist(vcprequest->vcplist,1)
   SET stat = alterlist(vcpreply->vcplist,1)
   SET vcprequest->vcplist[1].application_number = request->application_number
   SET vcprequest->vcplist[1].position_cd = request->position_cd
   SET vcprequest->vcplist[1].prsnl_id = request->prsnl_id
   SET vcprequest->vcplist[1].view_name = "PATHIST"
   SET vcprequest->vcplist[1].view_seq = 0
   SET vcprequest->vcplist[1].comp_name = "PATHIST"
   SET vcprequest->vcplist[1].comp_seq = 0
 END ;Subroutine
 SUBROUTINE complete_comp_auth_vcp_nvp(dummy_parm2)
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
 SUBROUTINE complete_newrsltdlg_vp(dummy_parm2)
   SET stat = alterlist(vprequest->vplist,1)
   SET stat = alterlist(vpreply->vplist,1)
   SET vprequest->vplist[1].application_number = request->application_number
   SET vprequest->vplist[1].position_cd = request->position_cd
   SET vprequest->vplist[1].prsnl_id = request->prsnl_id
   SET vprequest->vplist[1].frame_type = "FSNEWRSLTDLG"
   SET vprequest->vplist[1].view_name = "FSNEWRSLTDLG"
   SET vprequest->vplist[1].view_seq = 1
 END ;Subroutine
 SUBROUTINE complete_newrsltdlg_vp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,4)
   SET stat = alterlist(nvpreply->nvplist,4)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "DISPLAY_SEQ"
   SET nvprequest->nvplist[1].pvc_value = "11"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "DLL_NAME"
   SET nvprequest->nvplist[2].pvc_value = " "
   SET nvprequest->nvplist[3].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[3].pvc_name = "VIEW_CAPTION"
   SET nvprequest->nvplist[3].pvc_value = "Flowsheet New Results"
   SET nvprequest->nvplist[4].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[4].pvc_name = "VIEW_IND"
   SET nvprequest->nvplist[4].pvc_value = "0"
 END ;Subroutine
 SUBROUTINE complete_newrsltdlg_vcp(dummy_parm2)
   SET stat = alterlist(vcprequest->vcplist,1)
   SET stat = alterlist(vcpreply->vcplist,1)
   SET vcprequest->vcplist[1].application_number = request->application_number
   SET vcprequest->vcplist[1].position_cd = request->position_cd
   SET vcprequest->vcplist[1].prsnl_id = request->prsnl_id
   SET vcprequest->vcplist[1].view_name = "FSNEWRSLTDLG"
   SET vcprequest->vcplist[1].view_seq = 1
   SET vcprequest->vcplist[1].comp_name = "FLOWSHEET"
   SET vcprequest->vcplist[1].comp_seq = 1
 END ;Subroutine
 SUBROUTINE complete_newrsltdlg_vcp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,3)
   SET stat = alterlist(nvpreply->nvplist,3)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "COMP_POSITION"
   SET nvprequest->nvplist[1].pvc_value = "0,0,3,4"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "COMP_DLLNAME"
   SET nvprequest->nvplist[2].pvc_value = "PVFLOWSHEET"
   SET nvprequest->nvplist[3].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[3].pvc_name = "PROGID"
   SET nvprequest->nvplist[3].pvc_value = "FLOWSHEET.FLOWSHEET"
 END ;Subroutine
 SUBROUTINE complete_inboxfsdlg_vp(dummy_parm2)
   SET stat = alterlist(vprequest->vplist,1)
   SET stat = alterlist(vpreply->vplist,1)
   SET vprequest->vplist[1].application_number = request->application_number
   SET vprequest->vplist[1].position_cd = request->position_cd
   SET vprequest->vplist[1].prsnl_id = request->prsnl_id
   SET vprequest->vplist[1].frame_type = "INBOXFSDLG"
   SET vprequest->vplist[1].view_name = "INBOXFS"
   SET vprequest->vplist[1].view_seq = 1
 END ;Subroutine
 SUBROUTINE complete_inboxfsdlg_vp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,2)
   SET stat = alterlist(nvpreply->nvplist,2)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "DISPLAY_SEQ"
   SET nvprequest->nvplist[1].pvc_value = "11"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "VIEW_IND"
   SET nvprequest->nvplist[2].pvc_value = "0"
 END ;Subroutine
 SUBROUTINE complete_clinnotes_vp(dummy_parm2)
   SET stat = alterlist(vprequest->vplist,1)
   SET stat = alterlist(vpreply->vplist,1)
   SET vprequest->vplist[1].application_number = request->application_number
   SET vprequest->vplist[1].position_cd = request->position_cd
   SET vprequest->vplist[1].prsnl_id = request->prsnl_id
   SET vprequest->vplist[1].frame_type = "FSCNDLG"
   SET vprequest->vplist[1].view_name = "FSCLINNOTES"
   SET vprequest->vplist[1].view_seq = 1
 END ;Subroutine
 SUBROUTINE complete_clinnotes_vp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,3)
   SET stat = alterlist(nvpreply->nvplist,3)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "DISPLAY_SEQ"
   SET nvprequest->nvplist[1].pvc_value = "11"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "VIEW_CAPTION"
   SET nvprequest->nvplist[2].pvc_value = "Document Viewer"
   SET nvprequest->nvplist[3].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[3].pvc_name = "VIEW_IND"
   SET nvprequest->nvplist[3].pvc_value = "0"
 END ;Subroutine
 SUBROUTINE complete_clinnotes_vcp(dummy_parm2)
   SET stat = alterlist(vcprequest->vcplist,1)
   SET stat = alterlist(vcpreply->vcplist,1)
   SET vcprequest->vcplist[1].application_number = request->application_number
   SET vcprequest->vcplist[1].position_cd = request->position_cd
   SET vcprequest->vcplist[1].prsnl_id = request->prsnl_id
   SET vcprequest->vcplist[1].view_name = "FSCLINNOTES"
   SET vcprequest->vcplist[1].view_seq = 1
   SET vcprequest->vcplist[1].comp_name = "CLINNOTES"
   SET vcprequest->vcplist[1].comp_seq = 1
 END ;Subroutine
 SUBROUTINE complete_clinnotes_vcp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,3)
   SET stat = alterlist(nvpreply->nvplist,3)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "COMP_POSITION"
   SET nvprequest->nvplist[1].pvc_value = "0,0,3,4"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "COMP_DLLNAME"
   SET nvprequest->nvplist[2].pvc_value = "PVNOTES"
   SET nvprequest->nvplist[3].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[3].pvc_name = "PROGID"
   SET nvprequest->nvplist[3].pvc_value = "PVNOTES.PVNOTES"
 END ;Subroutine
 SUBROUTINE complete_oflowsheet_vp(dummy_parm2)
   SET stat = alterlist(vprequest->vplist,1)
   SET stat = alterlist(vpreply->vplist,1)
   SET vprequest->vplist[1].application_number = request->application_number
   SET vprequest->vplist[1].position_cd = request->position_cd
   SET vprequest->vplist[1].prsnl_id = request->prsnl_id
   SET vprequest->vplist[1].frame_type = "ORDINFO"
   SET vprequest->vplist[1].view_name = "OFLOWSHEET"
   SET vprequest->vplist[1].view_seq = 1
 END ;Subroutine
 SUBROUTINE complete_oflowsheet_vp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,4)
   SET stat = alterlist(nvpreply->nvplist,4)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "DISPLAY_SEQ"
   SET nvprequest->nvplist[1].pvc_value = "11"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "DLL_NAME"
   SET nvprequest->nvplist[2].pvc_value = "PVOAFLOWSHEET "
   SET nvprequest->nvplist[3].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[3].pvc_name = "VIEW_CAPTION"
   SET nvprequest->nvplist[3].pvc_value = "Results"
   SET nvprequest->nvplist[4].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[4].pvc_name = "VIEW_IND"
   SET nvprequest->nvplist[4].pvc_value = "0"
 END ;Subroutine
 SUBROUTINE complete_oflowsheet_vcp(dummy_parm2)
   SET stat = alterlist(vcprequest->vcplist,1)
   SET stat = alterlist(vcpreply->vcplist,1)
   SET vcprequest->vcplist[1].application_number = request->application_number
   SET vcprequest->vcplist[1].position_cd = request->position_cd
   SET vcprequest->vcplist[1].prsnl_id = request->prsnl_id
   SET vcprequest->vcplist[1].view_name = "OFLOWSHEET"
   SET vcprequest->vcplist[1].comp_name = "OFLOWSHEET"
   SET vcprequest->vcplist[1].comp_seq = 1
 END ;Subroutine
 SUBROUTINE complete_oflowsheet_vcp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,3)
   SET stat = alterlist(nvpreply->nvplist,3)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "COMP_POSITION"
   SET nvprequest->nvplist[1].pvc_value = "0,0,3,4"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "COMP_DLLNAME"
   SET nvprequest->nvplist[2].pvc_value = "PVOAFLOWSHEET"
   SET nvprequest->nvplist[3].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[3].pvc_name = "HIDDEN_CAT_TYPE"
   SET nvprequest->nvplist[3].pvc_value = " "
 END ;Subroutine
 SUBROUTINE complete_flow_vp_and_vcp(dummy_parm2)
   SET stat = alterlist(vprequest->vplist,1)
   SET stat = alterlist(vpreply->vplist,1)
   SET vprequest->vplist[1].application_number = request->application_number
   SET vprequest->vplist[1].position_cd = request->position_cd
   SET vprequest->vplist[1].prsnl_id = request->prsnl_id
   SET vprequest->vplist[1].frame_type = "CHART"
   SET vprequest->vplist[1].view_name = "FLOWSHEET"
   SET stat = alterlist(vcprequest->vcplist,1)
   SET stat = alterlist(vcpreply->vcplist,1)
   SET vcprequest->vcplist[1].application_number = request->application_number
   SET vcprequest->vcplist[1].position_cd = request->position_cd
   SET vcprequest->vcplist[1].prsnl_id = request->prsnl_id
   SET vcprequest->vcplist[1].view_name = "FLOWSHEET"
   SET vcprequest->vcplist[1].comp_name = "FLOWSHEET"
 END ;Subroutine
 SUBROUTINE complete_flow_vp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,2)
   SET stat = alterlist(nvpreply->nvplist,2)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[1].pvc_name = "VIEW_CAPTION"
   SET nvprequest->nvplist[2].pvc_name = "DISPLAY_SEQ"
   SET nvprequest->nvplist[2].pvc_value = "11"
 END ;Subroutine
 SUBROUTINE complete_flow_vcp_nvp(dummy_parm2)
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
   SET nvprequest->nvplist[2].pvc_value = "0"
   SET nvprequest->nvplist[3].pvc_value = "0"
   SET nvprequest->nvplist[4].pvc_value = "0"
 END ;Subroutine
 SUBROUTINE complete_addcomm_pos_dp_and_nvp(dummy_parm2)
   SET stat = alterlist(dprequest->dplist,1)
   SET stat = alterlist(dpreply->dplist,1)
   SET dprequest->dplist[1].application_number = request->application_number
   SET dprequest->dplist[1].position_cd = request->position_cd
   SET dprequest->dplist[1].prsnl_id = request->prsnl_id
   SET dprequest->dplist[1].person_id = 0.0
   SET dprequest->dplist[1].view_name = "INBOXFS"
   SET dprequest->dplist[1].view_seq = 1
   SET dprequest->dplist[1].comp_name = "FLOWSHEET"
   SET dprequest->dplist[1].comp_seq = 1
   SET stat = alterlist(nvprequest->nvplist,1)
   SET stat = alterlist(nvpreply->nvplist,1)
   SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "ADD_COMMENTS"
   SET nvprequest->nvplist[1].pvc_value = cnvtstring(commentresult_off_on_ind)
 END ;Subroutine
 SUBROUTINE complete_addcomm_flow_dp_and_nvp(dummy_parm2)
   SET stat = alterlist(dprequest->dplist,1)
   SET stat = alterlist(dpreply->dplist,1)
   SET dprequest->dplist[1].application_number = request->application_number
   SET dprequest->dplist[1].position_cd = request->position_cd
   SET dprequest->dplist[1].prsnl_id = request->prsnl_id
   SET dprequest->dplist[1].person_id = 0.0
   SET dprequest->dplist[1].view_name = "FLOWSHEET"
   SET dprequest->dplist[1].comp_name = "FLOWSHEET"
   SET stat = alterlist(nvprequest->nvplist,1)
   SET stat = alterlist(nvpreply->nvplist,1)
   SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "ADD_COMMENTS"
   SET nvprequest->nvplist[1].pvc_value = cnvtstring(commentresult_off_on_ind)
 END ;Subroutine
 SUBROUTINE complete_encsumm_dp(dummy_parm2)
   SET stat = alterlist(dprequest->dplist,1)
   SET stat = alterlist(dpreply->dplist,1)
   SET dprequest->dplist[1].application_number = request->application_number
   SET dprequest->dplist[1].position_cd = request->position_cd
   SET dprequest->dplist[1].prsnl_id = request->prsnl_id
   SET dprequest->dplist[1].person_id = 0.0
   SET dprequest->dplist[1].view_name = "ENCSUMMARY"
   SET dprequest->dplist[1].view_seq = 0
   SET dprequest->dplist[1].comp_name = "ENCSUMMARY"
   SET dprequest->dplist[1].comp_seq = 0
 END ;Subroutine
 SUBROUTINE complete_encsumm_dp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,1)
   SET stat = alterlist(nvpreply->nvplist,1)
   SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "SHOW_ORDERTESTS"
   SET nvprequest->nvplist[1].pvc_value = "1"
 END ;Subroutine
 SUBROUTINE complete_pv(dummy_parm2)
   SET stat = alterlist(pvrequest->pvlist,1)
   SET stat = alterlist(pvreply->pvlist,1)
   SET pvrequest->pvlist[1].person_id = 0
   SET pvrequest->pvlist[1].position_cd = request->position_cd
   SET pvrequest->pvlist[1].ppr_cd = 0
   SET pvrequest->pvlist[1].location_cd = 0
 END ;Subroutine
 SUBROUTINE copy_app_level_ordinfo_rows(mode)
   SET ctr = 0
   SELECT INTO "NL:"
    FROM view_prefs vp
    WHERE (vp.application_number=request->application_number)
     AND vp.position_cd=0.0
     AND (vp.prsnl_id=request->prsnl_id)
     AND vp.frame_type="ORDINFO"
     AND vp.active_ind=1
    DETAIL
     ctr = (ctr+ 1), stat = alterlist(appordinfo->alist,ctr), appordinfo->alist[ctr].view_prefs_id =
     vp.view_prefs_id,
     appordinfo->alist[ctr].view_name = vp.view_name, appordinfo->alist[ctr].view_seq = vp.view_seq
    WITH nocounter
   ;end select
   FOR (t = 1 TO ctr)
     SET stat = alterlist(vprequest->vplist,1)
     SET stat = alterlist(vpreply->vplist,1)
     SET vprequest->vplist[1].application_number = request->application_number
     SET vprequest->vplist[1].position_cd = request->position_cd
     SET vprequest->vplist[1].prsnl_id = request->prsnl_id
     SET vprequest->vplist[1].frame_type = "ORDINFO"
     SET vprequest->vplist[1].view_name = appordinfo->alist[t].view_name
     SET vprequest->vplist[1].view_seq = appordinfo->alist[t].view_seq
     SET vprequest->vplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
     SET pos_level_view_prefs_id = vpreply->vplist[1].view_prefs_id
     SET display_seq = fillstring(256," ")
     SET dll_name = fillstring(256," ")
     SET view_caption = fillstring(256," ")
     SET view_ind = fillstring(256," ")
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="VIEW_PREFS"
       AND (nvp.parent_entity_id=appordinfo->alist[t].view_prefs_id)
      DETAIL
       IF (nvp.pvc_name="DISPLAY_SEQ")
        display_seq = nvp.pvc_value
       ELSEIF (nvp.pvc_name="DLL_NAME")
        dll_name = nvp.pvc_value
       ELSEIF (nvp.pvc_name="VIEW_CAPTION")
        view_caption = nvp.pvc_value
       ELSEIF (nvp.pvc_name="VIEW_IND")
        view_ind = nvp.pvc_value
       ENDIF
      WITH nocounter
     ;end select
     SET stat = alterlist(nvprequest->nvplist,4)
     SET stat = alterlist(nvpreply->nvplist,4)
     SET nvprequest->nvplist[1].parent_entity_name = "VIEW_PREFS"
     SET nvprequest->nvplist[1].parent_entity_id = pos_level_view_prefs_id
     SET nvprequest->nvplist[1].pvc_name = "DISPLAY_SEQ"
     SET nvprequest->nvplist[1].pvc_value = display_seq
     SET nvprequest->nvplist[2].parent_entity_name = "VIEW_PREFS"
     SET nvprequest->nvplist[2].parent_entity_id = pos_level_view_prefs_id
     SET nvprequest->nvplist[2].pvc_name = "DLL_NAME"
     SET nvprequest->nvplist[2].pvc_value = dll_name
     SET nvprequest->nvplist[3].parent_entity_name = "VIEW_PREFS"
     SET nvprequest->nvplist[3].parent_entity_id = pos_level_view_prefs_id
     SET nvprequest->nvplist[3].pvc_name = "VIEW_CAPTION"
     SET nvprequest->nvplist[3].pvc_value = view_caption
     SET nvprequest->nvplist[4].parent_entity_name = "VIEW_PREFS"
     SET nvprequest->nvplist[4].parent_entity_id = pos_level_view_prefs_id
     SET nvprequest->nvplist[4].pvc_name = "VIEW_IND"
     SET nvprequest->nvplist[4].pvc_value = view_ind
     SET nvprequest->nvplist[1].action_flag = "1"
     SET nvprequest->nvplist[2].action_flag = "1"
     SET nvprequest->nvplist[3].action_flag = "1"
     SET nvprequest->nvplist[4].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
     SET app_level_view_comp_prefs_id = 0.0
     SELECT INTO "NL:"
      FROM view_comp_prefs vcp
      WHERE (vcp.application_number=request->application_number)
       AND vcp.position_cd=0.0
       AND (vcp.prsnl_id=request->prsnl_id)
       AND (vcp.view_name=appordinfo->alist[t].view_name)
       AND (vcp.view_seq=appordinfo->alist[t].view_seq)
       AND (vcp.comp_name=appordinfo->alist[t].view_name)
       AND vcp.comp_seq=1
       AND vcp.active_ind=1
      DETAIL
       app_level_view_comp_prefs_id = vcp.view_comp_prefs_id
      WITH nocounter
     ;end select
     SET stat = alterlist(vcprequest->vcplist,1)
     SET stat = alterlist(vcpreply->vcplist,1)
     SET vcprequest->vcplist[1].application_number = request->application_number
     SET vcprequest->vcplist[1].position_cd = request->position_cd
     SET vcprequest->vcplist[1].prsnl_id = request->prsnl_id
     SET vcprequest->vcplist[1].view_name = appordinfo->alist[t].view_name
     SET vcprequest->vcplist[1].view_seq = appordinfo->alist[t].view_seq
     SET vcprequest->vcplist[1].comp_name = appordinfo->alist[t].view_name
     SET vcprequest->vcplist[1].comp_seq = 1
     SET vcprequest->vcplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",
      vcpreply)
     SET pos_level_view_comp_prefs_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET comp_dllname = fillstring(256," ")
     SET comp_position = fillstring(256," ")
     SET hidden_cat_type = fillstring(256," ")
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="VIEW_COMP_PREFS"
       AND nvp.parent_entity_id=app_level_view_comp_prefs_id
      DETAIL
       IF (nvp.pvc_name="COMP_DLLNAME")
        comp_dllname = nvp.pvc_value
       ELSEIF (nvp.pvc_name="COMP_POSITION")
        comp_position = nvp.pvc_value
       ELSEIF (nvp.pvc_name="HIDDEN_CAT_TYPE")
        hidden_cat_type = nvp.pvc_value
       ENDIF
      WITH nocounter
     ;end select
     SET stat = alterlist(nvprequest->nvplist,3)
     SET stat = alterlist(nvpreply->nvplist,3)
     SET nvprequest->nvplist[1].parent_entity_name = "VIEW_COMP_PREFS"
     SET nvprequest->nvplist[1].parent_entity_id = pos_level_view_comp_prefs_id
     SET nvprequest->nvplist[1].pvc_name = "COMP_DLLNAME"
     SET nvprequest->nvplist[1].pvc_value = comp_dllname
     SET nvprequest->nvplist[2].parent_entity_name = "VIEW_COMP_PREFS"
     SET nvprequest->nvplist[2].parent_entity_id = pos_level_view_comp_prefs_id
     SET nvprequest->nvplist[2].pvc_name = "COMP_POSITION"
     SET nvprequest->nvplist[2].pvc_value = comp_position
     SET nvprequest->nvplist[3].parent_entity_name = "VIEW_COMP_PREFS"
     SET nvprequest->nvplist[3].parent_entity_id = pos_level_view_comp_prefs_id
     SET nvprequest->nvplist[3].pvc_name = "HIDDEN_CAT_TYPE"
     SET nvprequest->nvplist[3].pvc_value = hidden_cat_type
     SET nvprequest->nvplist[1].action_flag = "1"
     SET nvprequest->nvplist[2].action_flag = "1"
     SET nvprequest->nvplist[3].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
   ENDFOR
   SET oflowsheet_id = 0.0
   SET oflowsheet_seq = 0
   SELECT INTO "NL:"
    FROM view_prefs vp
    WHERE (vp.application_number=request->application_number)
     AND (vp.position_cd=request->position_cd)
     AND (vp.prsnl_id=request->prsnl_id)
     AND vp.frame_type="ORDINFO"
     AND vp.view_name="OFLOWSHEET"
     AND vp.active_ind=1
    DETAIL
     oflowsheet_id = vp.view_prefs_id, oflowsheet_seq = vp.view_seq
    WITH nocounter
   ;end select
   IF (mode=1
    AND oflowsheet_id=0)
    CALL create_all_oflowsheet_rows(dummy_parm1)
   ELSEIF (mode=0
    AND oflowsheet_id=1)
    CALL delete_all_oflowsheet_rows(dummy_parm1)
   ENDIF
 END ;Subroutine
 SUBROUTINE create_all_oflowsheet_rows(dummy_parm2)
   SET view_cnt = 0
   SELECT INTO "NL:"
    FROM view_prefs vp
    WHERE (vp.application_number=request->application_number)
     AND (vp.position_cd=request->position_cd)
     AND (vp.prsnl_id=request->prsnl_id)
     AND vp.frame_type="ORDINFO"
     AND vp.active_ind=1
    HEAD REPORT
     view_cnt = 0
    DETAIL
     view_cnt = (view_cnt+ 1)
    WITH nocounter
   ;end select
   CALL complete_oflowsheet_vp(dummy_parm1)
   SET vprequest->vplist[1].view_seq = (view_cnt+ 1)
   SET vprequest->vplist[1].action_flag = "1"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   SET oflowsheet_id = vpreply->vplist[1].view_prefs_id
   SET oflowsheet_seq = (view_cnt+ 1)
   IF (oflowsheet_id > 0)
    CALL complete_oflowsheet_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = oflowsheet_id
    SET nvprequest->nvplist[2].parent_entity_id = oflowsheet_id
    SET nvprequest->nvplist[3].parent_entity_id = oflowsheet_id
    SET nvprequest->nvplist[4].parent_entity_id = oflowsheet_id
    SET nvprequest->nvplist[1].action_flag = "1"
    SET nvprequest->nvplist[2].action_flag = "1"
    SET nvprequest->nvplist[3].action_flag = "1"
    SET nvprequest->nvplist[4].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
   CALL complete_oflowsheet_vcp(dummy_parm1)
   SET vcprequest->vcplist[1].view_seq = oflowsheet_seq
   SET vcprequest->vcplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply)
   IF ((vcpreply->vcplist[1].view_comp_prefs_id=0))
    SET vcprequest->vcplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
     CALL complete_oflowsheet_vcp_nvp(dummy_parm1)
     SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[1].action_flag = "1"
     SET nvprequest->nvplist[2].action_flag = "1"
     SET nvprequest->nvplist[3].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE delete_all_oflowsheet_rows(dummy_parm2)
   CALL complete_oflowsheet_vp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = oflowsheet_id
   SET nvprequest->nvplist[2].parent_entity_id = oflowsheet_id
   SET nvprequest->nvplist[3].parent_entity_id = oflowsheet_id
   SET nvprequest->nvplist[4].parent_entity_id = oflowsheet_id
   DELETE  FROM view_prefs vp
    WHERE vp.view_prefs_id=oflowsheet_id
    WITH nocounter
   ;end delete
   SET nvprequest->nvplist[1].action_flag = "3"
   SET nvprequest->nvplist[2].action_flag = "3"
   SET nvprequest->nvplist[3].action_flag = "3"
   SET nvprequest->nvplist[4].action_flag = "3"
   SET trace = recpersist
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
   CALL complete_oflowsheet_vcp(dummy_parm1)
   SET vcprequest->vcplist[1].view_seq = oflowsheet_seq
   SET vcprequest->vcplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply)
   IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
    CALL complete_oflowsheet_vcp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET vcprequest->vcplist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    SET nvprequest->nvplist[1].action_flag = "3"
    SET nvprequest->nvplist[2].action_flag = "3"
    SET nvprequest->nvplist[3].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
   SET ord_cnt = 0
   SELECT INTO "NL:"
    FROM view_prefs vp
    WHERE (vp.application_number=request->application_number)
     AND (vp.position_cd=request->position_cd)
     AND (vp.prsnl_id=request->prsnl_id)
     AND vp.frame_type="ORDINFO"
     AND vp.active_ind=1
    HEAD REPORT
     ord_cnt = 0
    DETAIL
     ord_cnt = (ord_cnt+ 1), stat = alterlist(posordinfo->plist,ord_cnt), posordinfo->plist[ord_cnt].
     view_prefs_id = vp.view_prefs_id,
     posordinfo->plist[ord_cnt].view_name = vp.view_name, posordinfo->plist[ord_cnt].view_seq = vp
     .view_seq
    WITH nocounter
   ;end select
   IF (ord_cnt > 0)
    FOR (x = 1 TO ord_cnt)
      IF ((posordinfo->plist[x].view_seq > oflowsheet_seq))
       UPDATE  FROM view_prefs vp
        SET vp.view_seq = (vp.view_seq - 1), vp.updt_cnt = (vp.updt_cnt+ 1), vp.updt_id = reqinfo->
         updt_id,
         vp.updt_dt_tm = cnvtdatetime(curdate,curtime), vp.updt_task = reqinfo->updt_task, vp
         .updt_applctx = reqinfo->updt_applctx
        WHERE (vp.view_prefs_id=posordinfo->plist[x].view_prefs_id)
        WITH nocounter
       ;end update
       SET vcp_id = 0.0
       SELECT INTO "NL:"
        FROM view_comp_prefs vcp
        WHERE (vcp.application_number=request->application_number)
         AND (vcp.position_cd=request->position_cd)
         AND (vcp.prsnl_id=request->prsnl_id)
         AND (vcp.view_name=posordinfo->plist[x].view_name)
         AND (vcp.view_seq=posordinfo->plist[x].view_seq)
         AND (vcp.comp_name=posordinfo->plist[x].view_name)
         AND vcp.comp_seq=1
         AND vcp.active_ind=1
        DETAIL
         vcp_id = vcp.view_comp_prefs_id
        WITH nocounter
       ;end select
       IF (vcp_id > 0)
        UPDATE  FROM view_comp_prefs vcp
         SET vcp.view_seq = (vcp.view_seq - 1), vcp.updt_cnt = (vcp.updt_cnt+ 1), vcp.updt_id =
          reqinfo->updt_id,
          vcp.updt_dt_tm = cnvtdatetime(curdate,curtime), vcp.updt_task = reqinfo->updt_task, vcp
          .updt_applctx = reqinfo->updt_applctx
         WHERE vcp.view_comp_prefs_id=vcp_id
         WITH nocounter
        ;end update
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
#exitscript
END GO

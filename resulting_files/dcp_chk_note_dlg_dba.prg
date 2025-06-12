CREATE PROGRAM dcp_chk_note_dlg:dba
 SET vpid = 0
 SET vpctr = 0
 SET vcpid = 0
 SET vcpctr = 0
 SELECT INTO "nl:"
  vp.view_prefs_id
  FROM view_prefs vp
  WHERE vp.frame_type="CLINNOTESDLG"
   AND vp.view_name="CLINNOTES"
   AND vp.view_seq=1
   AND vp.active_ind=1
  DETAIL
   vpid = vp.view_prefs_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  vcp.view_comp_prefs_id
  FROM view_comp_prefs vcp
  WHERE vcp.view_name="CLINNOTES"
   AND vcp.view_seq=1
   AND vcp.comp_name="CLINNOTES"
   AND vcp.comp_seq=1
   AND vcp.active_ind=1
  DETAIL
   vcpid = vcp.view_comp_prefs_id
  WITH nocounter
 ;end select
 IF (vpid > 0)
  SELECT INTO "nl:"
   nvp.parent_entity_id
   FROM name_value_prefs nvp
   WHERE nvp.parent_entity_id=vpid
   DETAIL
    vpctr = (vpctr+ 1)
   WITH nocounter
  ;end select
 ENDIF
 IF (vcpid > 0)
  SELECT INTO "nl:"
   nvp.parent_entity_id
   FROM name_value_prefs nvp
   WHERE nvp.parent_entity_id=vcpid
   DETAIL
    vcpctr = (vcpctr+ 1)
   WITH nocounter
  ;end select
 ENDIF
 SET request->setup_proc[1].process_id = 703
 IF (((vpid=0) OR (vpctr != 4)) )
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Failure in adding the view row for CLINNOTESDLG."
 ELSEIF (((vcpid=0) OR (vcpctr != 2)) )
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Failure in adding the component row for CLINNOTESDLG."
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "Success in adding view and component rows for CLINNOTESDLG."
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO

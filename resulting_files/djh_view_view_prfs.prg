CREATE PROGRAM djh_view_view_prfs
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  v.active_ind, v.application_number, v_position_disp = uar_get_code_display(v.position_cd),
  n.pvc_value, v.frame_type, v.view_name,
  n.parent_entity_name, n.pvc_name, v.position_cd,
  v.prsnl_id, v.updt_applctx, v.updt_cnt,
  v.updt_dt_tm, v.updt_id, v.updt_task,
  v.view_prefs_id, v.view_seq, n.active_ind,
  n.merge_id, n.merge_name, n.name_value_prefs_id,
  n.parent_entity_id, n.sequence, n.updt_applctx,
  n.updt_cnt, n.updt_dt_tm, n.updt_id,
  n.updt_task
  FROM view_prefs v,
   name_value_prefs n
  PLAN (v
   WHERE v.active_ind=1
    AND v.position_cd > 0
    AND v.frame_type="CHART"
    AND v.view_name="CHARTSUMM")
   JOIN (n
   WHERE n.active_ind=1
    AND v.view_prefs_id=n.parent_entity_id
    AND n.parent_entity_name="VIEW_PREFS"
    AND n.pvc_name="VIEW_CAPTION"
    AND n.pvc_value="Me*")
  ORDER BY v.application_number, v_position_disp
  WITH maxrec = 100, nocounter, separator = " ",
   format
 ;end select
END GO

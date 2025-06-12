CREATE PROGRAM djh_view_comp_prefs
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  vc.active_ind, v_position_disp = uar_get_code_display(vc.position_cd), vc.position_cd,
  vc.application_number, vc.comp_name, vc.view_seq,
  vc.comp_seq, vc.prsnl_id, vc.updt_applctx,
  vc.updt_cnt, vc.updt_dt_tm, vc.updt_id,
  vc.updt_task, vc.view_comp_prefs_id, vc.view_name
  FROM view_comp_prefs vc
  WHERE vc.active_ind=1
   AND vc.position_cd > 0
   AND vc.position_cd=227498645
   AND vc.view_name="CHARTSUMM"
  ORDER BY v_position_disp, vc.view_seq, vc.comp_seq
  WITH maxrec = 3000, nocounter, separator = " ",
   format
 ;end select
END GO

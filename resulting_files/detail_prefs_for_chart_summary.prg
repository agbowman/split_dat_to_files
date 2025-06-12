CREATE PROGRAM detail_prefs_for_chart_summary
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT DISTINCT INTO  $OUTDEV
  d_position_disp = uar_get_code_display(d.position_cd), d.view_name, d.comp_name,
  d.active_ind, d.application_number, d.comp_seq,
  d.detail_prefs_id, d.person_id, d.position_cd,
  d.prsnl_id, d.updt_applctx, d.updt_cnt,
  d.updt_dt_tm, d.updt_id, d.updt_task,
  d.view_seq
  FROM detail_prefs d
  WHERE d.view_name="CHARTSUMM"
   AND d.position_cd > 0
  ORDER BY d_position_disp, d.view_name, d.comp_name,
   d.view_seq
  WITH maxrec = 1000, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

CREATE PROGRAM djh_prsnl_priv
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
 SELECT INTO  $OUTDEV
  v.active_ind, v.application_number, v.frame_type,
  v_position_disp = uar_get_code_display(v.position_cd), v.prsnl_id, v.updt_applctx,
  v.updt_cnt, v.updt_dt_tm, v.updt_id,
  v.updt_task, v.view_name, v.view_prefs_id,
  v.view_seq
  FROM view_prefs v
  WHERE v.frame_type="IN*"
  WITH maxrec = 1000, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

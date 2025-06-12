CREATE PROGRAM djh_detail_prefs
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
  SET maxsecs = 60
 ENDIF
 SELECT INTO  $OUTDEV
  d.active_ind, d.application_number, d.comp_name,
  d.comp_seq, d.detail_prefs_id, d.position_cd,
  d_position_disp = uar_get_code_display(d.position_cd), d.updt_applctx, d.updt_cnt,
  d.updt_dt_tm, d.updt_id, d.updt_task,
  d.view_name, d.view_seq
  FROM detail_prefs d
  WHERE d.application_number=600005
  WITH maxrec = 10, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

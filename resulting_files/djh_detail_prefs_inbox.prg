CREATE PROGRAM djh_detail_prefs_inbox
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
  p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd), p.username,
  p.name_full_formatted, p.position_cd, p_position_disp = uar_get_code_display(p.position_cd),
  d.active_ind, p.beg_effective_dt_tm, d.application_number,
  d.comp_name, d.view_name, d.position_cd,
  d_position_disp = uar_get_code_display(d.position_cd), d.comp_seq, d.detail_prefs_id,
  d.updt_applctx, d.view_seq, p.physician_ind,
  p.active_ind
  FROM prsnl p,
   detail_prefs d
  PLAN (p
   WHERE p.active_ind=1
    AND p.active_status_cd=188
    AND p.physician_ind=1
    AND p.position_cd > 0
    AND p.position_cd != 441)
   JOIN (d
   WHERE p.position_cd=d.position_cd
    AND d.comp_name="INB*"
    AND d.comp_seq=0
    AND d.application_number=600005)
  WITH maxrec = 10000, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

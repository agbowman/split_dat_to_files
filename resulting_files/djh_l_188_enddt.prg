CREATE PROGRAM djh_l_188_enddt
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 IF (validate(_separator)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  p.active_ind, p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.username, p.name_full_formatted, p.beg_effective_dt_tm,
  p.create_dt_tm, p.end_effective_dt_tm, p.updt_dt_tm,
  p.physician_ind
  FROM prsnl p
  WHERE p.active_status_cd=188
   AND p.end_effective_dt_tm < cnvtdatetime(curdate,235959)
  ORDER BY p.name_full_formatted
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

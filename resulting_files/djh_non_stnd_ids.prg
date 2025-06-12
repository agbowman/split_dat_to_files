CREATE PROGRAM djh_non_stnd_ids
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 IF (validate(_separator)=0)
  IF (validate(_separator)=0)
   SET _separator = " "
  ENDIF
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  p.username, p.name_full_formatted, p.active_ind,
  p_active_status_disp = uar_get_code_display(p.active_status_cd), p.active_status_cd, p
  .physician_ind,
  p.create_dt_tm, p.beg_effective_dt_tm, p.end_effective_dt_tm,
  p.name_last_key, p.name_first_key
  FROM prsnl p
  WHERE p.active_ind=1
   AND p.active_status_cd=188
   AND p.username > " "
   AND p.username != "EN*"
   AND p.username != "PN*"
   AND p.username != "CN*"
   AND p.username != "PN*"
   AND p.username != "SN*"
   AND p.username != "TN*"
   AND p.username != "CR*"
   AND p.username != "SI*"
   AND p.username != "VT*"
   AND p.username != "NC*"
   AND p.username != "DUM*"
   AND p.username != "CERSU*"
   AND p.username != "SPND*"
   AND p.username != "SUS*"
   AND p.username != "CERNSU*"
   AND p.username != "TERM*"
   AND p.username != "TRMM*"
   AND p.username != "ETE*"
   AND p.username != "SYSTEM*"
   AND p.username != "MOBJECTS"
   AND p.username != "BEDROCK"
   AND p.username != "CHARTUSER"
   AND p.username != "HIST"
   AND p.username != "MED2A"
   AND p.username != "PATROL"
   AND p.username != "PHTRIAGE"
   AND p.username != "REFUSORD"
   AND p.username != "RESET"
   AND p.username != "SHIELDS"
   AND p.username != "FNDTLIST"
   AND p.username != "FNENGINE"
   AND p.name_last_key != "INBOX"
   AND p.name_first_key != "INBOX"
   AND p.name_last_key != "*BHS*"
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

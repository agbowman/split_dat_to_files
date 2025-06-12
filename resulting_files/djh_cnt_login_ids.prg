CREATE PROGRAM djh_cnt_login_ids
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
  SET maxsecs = 60
 ENDIF
 SELECT INTO  $OUTDEV
  p.active_ind, p_active_status_disp = uar_get_code_display(p.active_status_cd), p.active_status_cd,
  p.name_full_formatted, p.username
  FROM prsnl p
  WHERE p.active_ind=1
   AND p.active_status_cd=188
   AND p.username > " "
   AND ((p.username="EN*") OR (((p.username="CN*") OR (((p.username="CR*") OR (((p.username="VT*")
   OR (((p.username="TN*") OR (((p.username="SN*") OR (((p.username="SI*") OR (((p.username="PN*")
   OR (p.username="NC*")) )) )) )) )) )) )) ))
   AND p.username != "DUM*"
   AND p.username != "TERM*"
   AND p.username != "SPND*"
   AND p.username != "TRM*"
   AND p.username != "SUS*"
   AND p.username != "STU*"
  ORDER BY p.username
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO

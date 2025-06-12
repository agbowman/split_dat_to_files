CREATE PROGRAM cnt_psrnl_by_position
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
  p.name_full_formatted, p.username, p_position_disp = uar_get_code_display(p.position_cd),
  p.position_cd, p.active_ind
  FROM prsnl p
  WHERE p.active_ind=1
   AND p.position_cd=441
  ORDER BY p.position_cd
  WITH maxrec = 10, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

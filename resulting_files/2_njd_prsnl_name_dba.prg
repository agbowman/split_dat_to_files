CREATE PROGRAM 2_njd_prsnl_name:dba
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
  p.name_last_key, name = concat(trim(p.name_first),"  ",p.name_last), p_position_disp =
  uar_get_code_display(p.position_cd),
  p.beg_effective_dt_tm
  FROM prsnl p
  WHERE p.name_last_key="A*"
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

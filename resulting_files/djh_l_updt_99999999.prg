CREATE PROGRAM djh_l_updt_99999999
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
  p.active_ind, p.username, p.name_full_formatted,
  p.updt_id, p.updt_dt_tm
  FROM prsnl p
  WHERE p.updt_id=99999999
   AND p.updt_dt_tm >= cnvtdatetime(cnvtdate(062906),0)
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO

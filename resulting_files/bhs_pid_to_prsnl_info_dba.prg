CREATE PROGRAM bhs_pid_to_prsnl_info:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Person ID" = ""
  WITH outdev, pid
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
  documented_by = p.name_full_formatted, p.person_id
  FROM prsnl p
  PLAN (p
   WHERE p.person_id IN (21104559, 24030925, 24030819))
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

CREATE PROGRAM djh_l_create_id
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
  p.username, p.name_full_formatted, p.beg_effective_dt_tm,
  p.end_effective_dt_tm, p.create_prsnl_id, p.updt_id,
  pr.person_id, pr.name_full_formatted
  FROM prsnl p,
   prsnl pr
  PLAN (p
   WHERE p.username="*5715*")
   JOIN (pr
   WHERE p.create_prsnl_id=pr.person_id)
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

CREATE PROGRAM 1_njd_address_rpt:dba
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
  p.person_id, o.person_id, o.encntr_id,
  e.encntr_id
  FROM person p,
   orders o,
   encounter e
  PLAN (p)
   JOIN (o
   WHERE o.person_id=p.person_id)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

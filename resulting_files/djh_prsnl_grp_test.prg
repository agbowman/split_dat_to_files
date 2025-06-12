CREATE PROGRAM djh_prsnl_grp_test
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
  p.name_full_formatted, p.person_id, pg.prsnl_group_id,
  pg.prsnl_group_reltn_id, pgr.prsnl_group_id, pgr.prsnl_group_desc,
  pgr.prsnl_group_name
  FROM prsnl p,
   prsnl_group_reltn pg,
   prsnl_group pgr
  PLAN (p
   WHERE p.person_id=10168032)
   JOIN (pg
   WHERE p.person_id=pg.person_id)
   JOIN (pgr
   WHERE pg.prsnl_group_id=pgr.prsnl_group_id)
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

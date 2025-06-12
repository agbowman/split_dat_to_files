CREATE PROGRAM active_users_and_usernames
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  p.active_ind, p.username, p.name_full_formatted
  FROM prsnl p
  PLAN (p
   WHERE p.active_ind=1)
  WITH time = value(maxsecs), format, skipreport = 1
 ;end select
END GO

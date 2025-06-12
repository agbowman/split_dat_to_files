CREATE PROGRAM activeusers
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 60
 ENDIF
 SELECT INTO  $OUTDEV
  pr.active_ind, pr_active_status_disp = uar_get_code_display(pr.active_status_cd), pr
  .name_full_formatted,
  pr.username
  FROM prsnl pr
  PLAN (pr
   WHERE pr.active_ind=1)
  WITH time = value(maxsecs), format, skipreport = 1
 ;end select
END GO

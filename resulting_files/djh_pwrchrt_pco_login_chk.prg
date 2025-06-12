CREATE PROGRAM djh_pwrchrt_pco_login_chk
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
  SET maxsecs = 300
 ENDIF
 SELECT INTO  $OUTDEV
  o.application_number, a.description, o.frequency,
  p.person_id, p.name_full_formatted, o.log_ins,
  o.minutes, o.person_id, o.start_day
  FROM omf_app_ctx_day_st o,
   application a,
   prsnl p
  PLAN (o
   WHERE o.start_day >= cnvtdatetime(cnvtdate(090107),0)
    AND o.start_day <= cnvtdatetime(cnvtdate(090107),235959)
    AND ((o.application_number=961000) OR (o.application_number=600005)) )
   JOIN (a
   WHERE o.application_number=a.application_number)
   JOIN (p
   WHERE o.person_id=p.person_id)
  ORDER BY a.description, o.frequency
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

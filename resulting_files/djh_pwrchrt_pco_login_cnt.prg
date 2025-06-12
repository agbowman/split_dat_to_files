CREATE PROGRAM djh_pwrchrt_pco_login_cnt
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
  o.log_ins, o.minutes, o.person_id,
  o.start_day, sum_freq = sum(o.frequency)
  FROM omf_app_ctx_day_st o,
   application a
  PLAN (o
   WHERE o.start_day >= cnvtdatetime(cnvtdate(090107),0)
    AND o.start_day <= cnvtdatetime(cnvtdate(090107),235959)
    AND ((o.application_number=961000) OR (o.application_number=600005)) )
   JOIN (a
   WHERE o.application_number=a.application_number)
  GROUP BY o.application_number
  ORDER BY o.application_number
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

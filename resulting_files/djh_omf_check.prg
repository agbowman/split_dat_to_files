CREATE PROGRAM djh_omf_check
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
    AND o.application_number != 3071000
    AND o.application_number != 951060
    AND o.application_number != 1310000
    AND o.application_number != 600036
    AND o.application_number != 600022
    AND o.application_number != 120000
    AND o.application_number != 455021
    AND o.application_number != 3070000
    AND o.application_number != 9000
    AND o.application_number != 1000
    AND o.application_number != 32000
    AND o.application_number != 967100
    AND o.application_number != 961000
    AND o.application_number != 600005
    AND o.application_number != 3000
    AND o.application_number != 3200000
    AND o.application_number != 420001
    AND o.application_number != 950001
    AND o.application_number != 1241002
    AND o.application_number != 100000
    AND o.application_number != 100013
    AND o.application_number != 305600
    AND o.application_number != 335000
    AND o.application_number != 380000
    AND o.application_number != 390400
    AND o.application_number != 968600
    AND o.application_number != 560600
    AND o.application_number != 2204
    AND o.application_number != 400027)
   JOIN (a
   WHERE o.application_number=a.application_number)
   JOIN (p
   WHERE o.person_id=p.person_id)
  ORDER BY a.description, o.frequency
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

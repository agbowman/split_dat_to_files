CREATE PROGRAM djh_pwrchrt_pco_login_byuser
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
  o.person_id, o.application_number, a.description,
  o.start_day, sum_freq = sum(o.frequency)"############", sum_logins = sum(o.log_ins)"############",
  sum_min = sum(o.minutes)"############"
  FROM omf_app_ctx_day_st o,
   application a
  PLAN (o
   WHERE o.start_day >= cnvtdatetime(cnvtdate(102907),0)
    AND o.start_day <= cnvtdatetime(cnvtdate(102907),235959)
    AND ((o.application_number=961000) OR (o.application_number=600005)) )
   JOIN (a
   WHERE o.application_number=a.application_number)
  GROUP BY o.application_number, o.start_day, a.description,
   o.person_id
  ORDER BY sum_min DESC, o.person_id, o.application_number,
   o.start_day, a.description
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO

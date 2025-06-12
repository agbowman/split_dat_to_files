CREATE PROGRAM crmapp_report:dba
 SELECT
  stime = format(a.start_dt_tm,"hh:mm:ss;;m"), username = substring(1,20,a.username), name =
  substring(1,20,a.name),
  app.description, a.*
  FROM application_context a,
   application app
  WHERE a.start_dt_tm >= cnvtdatetime(curdate,0)
   AND a.end_dt_tm=null
   AND a.application_number=app.application_number
  ORDER BY a.start_dt_tm DESC, a.username
 ;end select
END GO

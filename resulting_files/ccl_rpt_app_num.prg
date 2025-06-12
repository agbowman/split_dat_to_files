CREATE PROGRAM ccl_rpt_app_num
 PROMPT
  "application description" = "*"
  WITH prompt1
 EXECUTE ccl_prompt_api_dataset "autoset", "dataset"
 DECLARE app_num = i4
 DECLARE app_num_string = vc
 SET app_num_string = trim( $1,3)
 SET stat = setvalidation(1)
 IF (isvalidationquery(0)=1)
  CALL echo("IsValidationQuery = 1")
  IF (textlen(app_num_string)=1
   AND app_num_string="\*")
   CALL echo("Setting Validation to 1")
   SET stat = setvalidation(1)
  ELSE
   SET app_num = cnvtint(trim(app_num_string))
   SET stat = setvalidation(0)
   SELECT DISTINCT
    c.application_nbr, a.description
    FROM ccl_report_audit c,
     application a
    PLAN (c
     WHERE c.application_nbr > 0
      AND c.updt_dt_tm > cnvtdatetime((curdate - 7),0000))
     JOIN (a
     WHERE c.application_nbr=a.application_number
      AND a.application_number=app_num)
    ORDER BY a.description
    DETAIL
     CALL echo("Setting validation to 1 from detail"), stat = setvalidation(1)
    WITH nocounter, separator = " ", format,
     maxqual(c,10000)
   ;end select
  ENDIF
 ELSE
  CALL echo("IsValidationQuery = 0")
  SELECT DISTINCT
   c.application_nbr, a.description
   FROM ccl_report_audit c,
    application a
   PLAN (c
    WHERE c.application_nbr > 0
     AND c.updt_dt_tm > cnvtdatetime((curdate - 7),0000))
    JOIN (a
    WHERE c.application_nbr=a.application_number
     AND a.description=patstring(app_num_string))
   ORDER BY a.description
   HEAD REPORT
    rec = 0, stat = initdataset(50), fmodname = addstringfield("application_nbr","Application Number",
     true,20),
    fversion = addstringfield("description","Description",true,200)
   DETAIL
    rec = getnextrecord(0), stat = setstringfield(rec,fmodname,build(c.application_nbr)), stat =
    setstringfield(rec,fversion,build(a.description))
   FOOT REPORT
    stat = closedataset(rec)
   WITH nocounter, separator = " ", format,
    maxqual(c,10000)
  ;end select
 ENDIF
END GO

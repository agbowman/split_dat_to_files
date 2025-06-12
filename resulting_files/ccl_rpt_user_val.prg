CREATE PROGRAM ccl_rpt_user_val
 PROMPT
  "username" = "*"
  WITH prompt1
 EXECUTE ccl_prompt_api_dataset "autoset", "dataset"
 DECLARE user_name_string = vc
 SET user_name_string = trim(cnvtupper( $1))
 SET stat = setvalidation(1)
 IF (isvalidationquery(0)=1)
  CALL echo("IsValidationQuery = 1")
  IF (textlen(user_name_string)=1
   AND user_name_string="\*")
   SET stat = setvalidation(1)
  ELSE
   SET stat = setvalidation(0)
   SELECT
    IF (user_name_string="\*")
     PLAN (p)
      JOIN (c
      WHERE p.person_id=c.updt_id)
    ELSE
    ENDIF
    DISTINCT
    p.username
    FROM prsnl p,
     ccl_report_audit c
    PLAN (p
     WHERE ((p.username=patstring(cnvtupper(user_name_string))) OR (p.name_last_key=patstring(
      cnvtupper(user_name_string)))) )
     JOIN (c
     WHERE p.person_id=c.updt_id)
    ORDER BY p.name_last_key
    DETAIL
     stat = setvalidation(1)
    WITH nocounter, separator = " ", format,
     maxqual(p,1)
   ;end select
  ENDIF
 ELSE
  CALL echo("IsValidationQuery = 0")
  SELECT
   IF (user_name_string="\*")
    PLAN (p)
     JOIN (c
     WHERE p.person_id=c.updt_id)
   ELSE
   ENDIF
   DISTINCT INTO "NL:"
   FROM prsnl p,
    ccl_report_audit c
   PLAN (p
    WHERE ((p.username=patstring(cnvtupper(user_name_string))) OR (p.name_last_key=patstring(
     cnvtupper(user_name_string)))) )
    JOIN (c
    WHERE p.person_id=c.updt_id)
   ORDER BY p.name_last_key
   HEAD REPORT
    rec = 0, stat = initdataset(50), fmodname = addstringfield("username","Username",true,50),
    fversion = addstringfield("name_full_formatted","Name",true,100)
   DETAIL
    rec = getnextrecord(0), stat = setstringfield(rec,fmodname,build(p.username)), stat =
    setstringfield(rec,fversion,build(p.name_full_formatted))
   FOOT REPORT
    stat = closedataset(rec)
   WITH nocounter, separator = " ", format,
    maxqual(c,10000)
  ;end select
 ENDIF
END GO

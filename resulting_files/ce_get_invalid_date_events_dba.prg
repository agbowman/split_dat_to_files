CREATE PROGRAM ce_get_invalid_date_events:dba
 DECLARE tomorrow_dt_tm = dq8 WITH protect, constant(cnvtdatetime((curdate+ 1),cnvttime2("235959",
    "HHMMSS")))
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(fillstring(132," "))
 SET errcode = error(errmsg,1)
 IF (textlen(trim( $1,3))=0)
  CALL echo("Invalid file name entered to write patient list to.")
  GO TO exit_script
 ENDIF
 SELECT INTO value( $1)
  ce.person_id
  FROM (
   (
   (SELECT INTO "nl:"
    ce1.person_id
    FROM clinical_event ce1
    WHERE ce1.person_id > 0
     AND ((ce1.valid_from_dt_tm > cnvtdatetime(tomorrow_dt_tm)) UNION (
    (SELECT INTO "nl:"
     ce2.person_id
     FROM clinical_event ce2
     WHERE ((ce2.clinsig_updt_dt_tm > cnvtdatetime(tomorrow_dt_tm)) UNION (
     (SELECT INTO "nl:"
      ce3.person_id
      FROM clinical_event ce3
      WHERE ce3.updt_dt_tm > cnvtdatetime(tomorrow_dt_tm)))) )))
    WITH rdbunion, sqltype("F8")))
   ce)
  DETAIL
   row + 1,
   CALL print(build(ce.person_id))
  WITH nocounter, append
 ;end select
 IF (error(errmsg,0))
  CALL echo(build("An error occured while selecting from clinical_event -",errmsg))
 ELSEIF (curqual=0)
  CALL echo("No invalid date events found.")
 ENDIF
#exit_script
END GO

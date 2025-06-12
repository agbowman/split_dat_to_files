CREATE PROGRAM cp_chg_chartrequest_task:dba
 DECLARE status = c1 WITH noconstant("S")
 SELECT INTO "nl:"
  FROM application_task
  WHERE task_number=1330000
  WITH nocounter
 ;end select
 IF (curqual > 0)
  UPDATE  FROM application_task
   SET description = "RUN Chart Request (Request a Chart)"
   WHERE application_number=1330000
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL echo("Failed in changing RUN Chart Request task description!")
   SET status = "F"
  ENDIF
 ENDIF
 IF (status="S")
  CALL echo("Successful!")
  COMMIT
 ELSE
  CALL echo("Failed!")
  ROLLBACK
 ENDIF
END GO

CREATE PROGRAM cp_chg_cfa_app_settings:dba
 DECLARE status = c1 WITH noconstant("S")
 SELECT INTO "nl:"
  FROM application
  WHERE application_number=1336000
  WITH nocounter
 ;end select
 IF (curqual > 0)
  UPDATE  FROM application
   SET application_ini_ind = 1, direct_access_ind = 1
   WHERE application_number=1336000
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL echo("Failed in changing Chart Format Audit application settings!")
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

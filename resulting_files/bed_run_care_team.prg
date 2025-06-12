CREATE PROGRAM bed_run_care_team
 SET filename = "cer_install:careteam.csv"
 SET scriptname = "bed_imp_care_team"
 EXECUTE dm_dbimport filename, scriptname, 5000
END GO

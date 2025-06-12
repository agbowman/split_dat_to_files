CREATE PROGRAM bed_run_schg
 PROMPT
  "Bedrock Scheduling Guidelines Import, Enter Option: A=AUDIT, I=IMPORT, or Q=QUIT (Return=A): " =
  "A"
 SET option = cnvtupper(trim( $1))
 SET audit_mode = 0
 IF (option="Q")
  CALL echo("Process aborted")
  GO TO exit_script
 ELSEIF ( NOT (option IN ("A", "I")))
  CALL echo("Invalid Option selected.  Process aborted.")
  GO TO exit_script
 ELSEIF (option="A")
  SET audit_mode = 1
 ENDIF
 SET filename = "CCLUSERDIR:bed_imp_schg.csv"
 SET scriptname = "bed_imp_schg"
 EXECUTE dm_dbimport filename, scriptname, 15000
#exit_script
END GO

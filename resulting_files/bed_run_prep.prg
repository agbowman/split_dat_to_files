CREATE PROGRAM bed_run_prep
 PROMPT
  "Bedrock Person Preparation or Post Import, Enter Option: A=AUDIT, I=IMPORT, or Q=QUIT (Return=A): "
   = "A"
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
 SET filename = "CCLUSERDIR:bed_imp_prep.csv"
 SET scriptname = "bed_imp_prep"
 EXECUTE dm_dbimport filename, scriptname, 15000
#exit_script
END GO

CREATE PROGRAM cps_import_charts:dba
 PROMPT
  "Enter Dataset file name including path: " = "None",
  "Enter Datastat file name including path: " = "None"
  WITH dataset, datastat
 DECLARE did_dataset = i2 WITH noconstant(1), protect
 DECLARE did_datastat = i2 WITH noconstant(1), protect
 CALL echo("***")
 CALL echo(concat("***   The Dataset file is ", $DATASET))
 CALL echo(concat("***   The Datastat file is ", $DATASTAT))
 CALL echo("***")
 IF (( $DATASET="None"))
  SET did_dataset = 0
  GO TO skip_dataset
 ENDIF
 CALL echo("***")
 CALL echo(concat("***   Importing the ", $DATASET," file"))
 CALL echo("***")
 EXECUTE dm_dbimport value( $DATASET), "cps_imp_chart_dataset", 500
#skip_dataset
 IF (( $DATASTAT="None"))
  SET did_datastat = 0
  GO TO skip_datastat
 ENDIF
 CALL echo("***")
 CALL echo(concat("***   Importing the ", $DATASTAT," file"))
 CALL echo("***")
 EXECUTE dm_dbimport value( $DATASTAT), "cps_imp_chart_datastats", 500
#skip_datastat
 CALL echo("***")
 IF (((did_dataset=1) OR (did_datastat=1)) )
  IF (did_dataset=1)
   CALL echo("***   Examine the cps_imp_chart_dataset.log file located in the ccluserdir directory")
  ENDIF
  IF (did_datastat=1)
   CALL echo("***   Examine the cps_imp_chart_datastats.log file located in the ccluserdir directory"
    )
  ENDIF
 ELSE
  CALL echo("***   No files specified for import.")
 ENDIF
 CALL echo("***")
END GO

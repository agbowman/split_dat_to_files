CREATE PROGRAM dm_atr_fix_features:dba
 CALL echo("***")
 CALL echo("*** Updating feature statuses in Admin...")
 CALL echo("***")
 UPDATE  FROM dm_features
  SET feature_status = "5"
  WHERE feature_status="2d"
  WITH counter
 ;end update
 CALL echo("***")
 IF (curqual > 0)
  COMMIT
  CALL echo("*** Feature statuses successfully updated in Admin!")
 ELSE
  CALL echo("*** ERROR: feature statuses were NOT updated!")
 ENDIF
 CALL echo("***")
END GO

CREATE PROGRAM cp_chg_ref_lab_flag:dba
 SET failed = "S"
 SET precount = 0
 SET postcount = 0
 SELECT INTO "nl:"
  ref_lab_flag
  FROM chart_format
  WHERE ref_lab_flag=null
   AND chart_format_id > 0.0
  WITH nocounter
 ;end select
 SET precount = curqual
 IF (precount > 0)
  UPDATE  FROM chart_format
   SET ref_lab_flag = 1
   WHERE ref_lab_flag=null
    AND chart_format_id > 0.0
  ;end update
  SET postcount = curqual
  IF (postcount < precount)
   CALL echo("Failed in update chart_request!")
   SET failed = "F"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="S")
  CALL echo("Successful!")
  COMMIT
 ELSE
  CALL echo("Failed!")
  ROLLBACK
 ENDIF
END GO

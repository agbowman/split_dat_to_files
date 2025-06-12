CREATE PROGRAM dcp_remove_io2g_data_flag:dba
 SET ms_err_msg = fillstring(132," ")
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="IO2G CONVERSION DATA FLAG"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  DELETE  FROM dm_info di
   WHERE di.info_domain="IO2G CONVERSION DATA FLAG"
    AND di.info_name="IO2G CONVERSION DATA"
   WITH nocounter
  ;end delete
  IF (error(ms_err_msg,0) != 0)
   CALL echo("***************************************************************")
   CALL echo(concat("FAILED TO REMOVE IO2G CONVERSION DATA MODEL:",ms_err_msg))
   CALL echo("***************************************************************")
   GO TO exit_program
  ENDIF
 ELSE
  CALL echo("***************************************************************")
  CALL echo("ALREADY REMOVED IO2G CONVERSION DATA MODEL")
  CALL echo("***************************************************************")
  GO TO exit_program
 ENDIF
 CALL echo("***************************************************************")
 CALL echo("THE I&O2G CONVERSION DATA MODEL WAS SUCCESSFULLY REMOVED")
 CALL echo("***************************************************************")
 COMMIT
#exit_program
END GO

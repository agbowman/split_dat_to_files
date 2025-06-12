CREATE PROGRAM dcp_remove_io_data_flag:dba
 SET ms_err_msg = fillstring(132," ")
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="IO DATA FLAG"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  DELETE  FROM dm_info di
   WHERE di.info_domain="IO DATA FLAG"
    AND di.info_name="ORIGINAL IO DATA"
   WITH nocounter
  ;end delete
  IF (error(ms_err_msg,0) != 0)
   CALL echo("***************************************************************")
   CALL echo(concat("FAILED TO SET TO THE I&O2G DATA MODEL:",ms_err_msg))
   CALL echo("***************************************************************")
   GO TO exit_program
  ENDIF
 ELSE
  CALL echo("***************************************************************")
  CALL echo("ALREADY USING THE I&O2G DATA MODEL")
  CALL echo("***************************************************************")
  GO TO exit_program
 ENDIF
 CALL echo("***************************************************************")
 CALL echo("THE I&O2G DATA MODEL WAS SUCCESSFULLY SET")
 CALL echo("***************************************************************")
 COMMIT
#exit_program
END GO

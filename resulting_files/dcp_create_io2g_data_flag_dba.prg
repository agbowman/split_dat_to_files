CREATE PROGRAM dcp_create_io2g_data_flag:dba
 SET ms_err_msg = fillstring(132," ")
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="IO2G CONVERSION DATA FLAG"
  WITH nocounter
 ;end select
 IF (curqual=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "IO2G CONVERSION DATA FLAG", di.info_name = "IO2G CONVERSION DATA", di
    .info_number = 1,
    di.info_date = cnvtdatetime(curdate,curtime3), di.info_char =
    "READ USING IO DATA MODEL AND WRITE USING I&O2G DATA MODEL", di.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    di.updt_cnt = 1
   WITH nocounter
  ;end insert
  IF (error(ms_err_msg,0) != 0)
   CALL echo("***************************************************************")
   CALL echo(concat("FAILED TO SET TO THE IO2G CONVERSION DATA MODEL:",ms_err_msg))
   CALL echo("***************************************************************")
   GO TO exit_program
  ENDIF
 ELSE
  CALL echo("***************************************************************")
  CALL echo("ALREADY USING THE IO2G CONVERSION DATA MODEL")
  CALL echo("***************************************************************")
  GO TO exit_program
 ENDIF
 CALL echo("***************************************************************")
 CALL echo("THE IO2G CONVERSION DATA MODEL WAS SUCCESSFULLY SET")
 CALL echo("***************************************************************")
 COMMIT
#exit_program
END GO

CREATE PROGRAM dm_master_script_info:dba
 DECLARE dm_err_msg = vc WITH private
 SELECT INTO "nl:"
  FROM user_tables ut
  WHERE ut.table_name=cnvtupper( $1)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  EXECUTE dm_master_script_info_main  $1, "MINE"
  IF (error(dm_err_msg,1) != 0)
   CALL echo(dm_err_msg)
  ENDIF
 ELSE
  CALL echo("*************************************************")
  CALL echo(concat(cnvtupper( $1)," is not a valid table name."))
  CALL echo("*************************************************")
 ENDIF
END GO

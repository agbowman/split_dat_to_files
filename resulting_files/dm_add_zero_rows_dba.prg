CREATE PROGRAM dm_add_zero_rows:dba
 PROMPT
  "Enter OCD number, table_name, or * for all tables in quotes:  " = ""
 IF (build( $1) != char(42))
  IF (build( $1)="")
   CALL echo(concat("Usage:  ",curprog," '<table_name>' GO"))
   GO TO end_of_program
  ENDIF
 ENDIF
 IF (findstring(char(42),build( $1)))
  FREE SET dazr_ignore_admin_ind
 ELSE
  IF (validate(dazr_ignore_admin_ind,9)=9)
   DECLARE dazr_ignore_admin_ind = i2 WITH public, noconstant(1)
  ELSE
   SET dazr_ignore_admin_ind = 1
  ENDIF
 ENDIF
 SET c_mod = "DM_ADD_ZERO_ROWS 002"
 EXECUTE dm2_add_default_rows  $1
 FREE SET dazr_ignore_admin_ind
#end_of_program
END GO

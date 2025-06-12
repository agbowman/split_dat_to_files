CREATE PROGRAM dm_ocd_schema_log:dba
 SET dsl_calling_script = "DM_OCD_SCHEMA_LOG"
 SET dsl_input = cnvtint( $1)
 SET dsl_header = fillstring(80,"*")
 SELECT DISTINCT INTO "nl:"
  d.ocd
  FROM dm_schema_log d
  WHERE d.ocd=dsl_input
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo(dsl_header)
  CALL echo(build("OCD #",dsl_input," does NOT exist in DM_SCHEMA_LOG table."))
  CALL echo(dsl_header)
  GO TO end_program
 ENDIF
 EXECUTE dm_schema_log
#end_program
END GO

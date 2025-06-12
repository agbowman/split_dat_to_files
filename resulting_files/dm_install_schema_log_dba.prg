CREATE PROGRAM dm_install_schema_log:dba
 SET dsl_calling_script = "DM_INSTALL_SCHEMA_LOG"
 SET dsl_input = cnvtupper( $1)
 SET dsl_header = fillstring(80,"*")
 SET disl_utc_ind = 1
 IF ((validate(curutc,- (1))=- (1))
  AND (validate(curutc,- (2))=- (2)))
  SET disl_utc_ind = 0
 ENDIF
 SELECT
  IF (disl_utc_ind)
   WHERE d.schema_date=cnvtdatetimeutc(dsl_input)
  ELSE
   WHERE d.schema_date=cnvtdatetime(dsl_input)
  ENDIF
  DISTINCT INTO "nl:"
  d.schema_date
  FROM dm_schema_log d
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo(dsl_header)
  CALL echo(build("Schema Date :",dsl_input," does NOT exist in DM_SCHEMA_LOG table."))
  CALL echo(dsl_header)
  GO TO end_program
 ENDIF
 EXECUTE dm_schema_log
#end_program
END GO

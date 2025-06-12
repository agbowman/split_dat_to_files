CREATE PROGRAM dm_drop_unused_tables:dba
 SET dm_env_name = cnvtupper( $1)
 SET dm_schema_date = cnvtdatetime("31-DEC-1900")
 SET valid_env_ind = 0
 SET valid_schema_date_ind = 0
 SELECT INTO "nl:"
  t.schema_date
  FROM dm_tables t
  WHERE t.schema_date=cnvtdatetime( $2)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET dm_schema_date = cnvtdatetime( $2)
  SET valid_schema_date_ind = 1
 ELSE
  SET valid_schema_date_ind = 0
 ENDIF
 SELECT INTO "nl:"
  e.environment_name
  FROM dm_environment e
  WHERE e.environment_name=dm_env_name
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET valid_env_ind = 1
 ELSE
  SET valid_env_ind = 0
 ENDIF
 IF (valid_env_ind=1)
  SELECT INTO "nl:"
   f.function_id
   FROM dm_env_functions f,
    dm_environment e
   WHERE e.environment_name=dm_env_name
    AND f.environment_id=e.environment_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   SELECT
    *
    FROM dual
    DETAIL
     col 0, "********************************************", row + 1,
     col 0, "*** NO PRODUCTS SELECTED FOR ENVIRONMENT ***", row + 1,
     col 0, "***        TERMINATING PROGRAM           ***", row + 1,
     col 0, "********************************************", row + 1
    WITH nocounter
   ;end select
   GO TO end_program
  ENDIF
 ENDIF
 IF (valid_env_ind=0
  AND valid_schema_date_ind=0)
  SELECT
   *
   FROM dual
   DETAIL
    col 0, "*******************************************", row + 1,
    col 0, "*** INVALID ENVIRONMENT AND SCHEMA_DATE ***", row + 1,
    col 0, "***        TERMINATING PROGRAM          ***", row + 1,
    col 0, "*******************************************", row + 1
   WITH nocounter
  ;end select
  GO TO end_program
 ENDIF
 IF (valid_env_ind=1)
  IF (valid_schema_date_ind=0)
   SELECT INTO "nl:"
    sv.schema_date
    FROM dm_schema_version sv,
     dm_environment e
    WHERE e.environment_name=dm_env_name
     AND sv.schema_version=e.schema_version
    DETAIL
     dm_schema_date = sv.schema_date
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT
     *
     FROM dual
     DETAIL
      col 0, "*******************************************", row + 1,
      col 0, "***  ENVIRONMENT IS VALID, BUT SCHEMA   ***", row + 1,
      col 0, "***  DATE FOR THE ENVIRONMENT AND THE   ***", row + 1,
      col 0, "***  PASSED IN $2 PARAMETER IS INVALID  ***", row + 1,
      col 0, "***        TERMINATING PROGRAM          ***", row + 1,
      col 0, "*******************************************", row + 1
     WITH nocounter
    ;end select
    GO TO end_program
   ENDIF
  ENDIF
 ENDIF
 RECORD all_table_list(
   1 table_name[*]
     2 tname = c32
   1 table_count = i4
 )
 SET stat = alterlist(all_table_list->table_name,10)
 SET all_table_list->table_count = 0
 SELECT INTO "nl:"
  t.table_name
  FROM dm_tables t,
   dm_tables_doc td,
   dm_function_dm_section_r f,
   dm_env_functions ef,
   dm_environment e
  WHERE e.environment_name=dm_env_name
   AND ef.environment_id=e.environment_id
   AND f.function_id=ef.function_id
   AND td.data_model_section=f.data_model_section
   AND t.table_name=td.table_name
   AND t.schema_date=cnvtdatetime(dm_schema_date)
  DETAIL
   all_table_list->table_count = (all_table_list->table_count+ 1)
   IF (mod(all_table_list->table_count,10)=1
    AND (all_table_list->table_count != 1))
    stat = alterlist(all_table_list->table_name,(all_table_list->table_count+ 9))
   ENDIF
   all_table_list->table_name[all_table_list->table_count].tname = t.table_name
  WITH nocounter
 ;end select
 SET in_list = 0
 SELECT INTO "DROP_UNUSED_TABLES_OUTPUT"
  ut.table_name
  FROM user_tables ut
  DETAIL
   in_list = 0
   FOR (x = 1 TO all_table_list->table_count)
     IF ((all_table_list->table_name[x].tname=ut.table_name))
      in_list = 1
     ENDIF
   ENDFOR
   IF (in_list=0)
    col 0, "RDB DROP TABLE ", ut.table_name,
    " CASCADE CONSTRAINTS GO ", row + 1
   ENDIF
  WITH format = stream, noheading, maxrow = 1,
   formfeed = none
 ;end select
#end_program
END GO

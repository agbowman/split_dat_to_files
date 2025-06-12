CREATE PROGRAM cclsql_test1
 EXECUTE cclsql_declare
 DECLARE sql_get_code_meaning(p1) = c12
 DECLARE sql_get_code_display(p1) = c40
 DECLARE sql_get_code_displaykey(p1) = c40
 DECLARE sql_get_code_description(p1) = c60
 DECLARE sql_get_code_set(p1) = c12
 SELECT
  codeset = sql_get_code_set( $1), meaning = sql_get_code_meaning( $1), display =
  sql_get_code_display( $1),
  displaykey = sql_get_code_displaykey( $1), desc = sql_get_code_description( $1)
  FROM dual
 ;end select
END GO

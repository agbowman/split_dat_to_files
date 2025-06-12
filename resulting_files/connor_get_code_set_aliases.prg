CREATE PROGRAM connor_get_code_set_aliases
 EXECUTE cclseclogin
 SELECT
  cv.description, cva.alias, cv.code_value
  FROM code_value cv,
   code_value_alias cva
  PLAN (cv)
   JOIN (cva
   WHERE cv.code_value=cva.code_value)
  DETAIL
   col 1, cv.description, col 30,
   cva.alias, col 45, cv.code_value
 ;end select
END GO

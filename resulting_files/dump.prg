CREATE PROGRAM dump
 SELECT
  *
  FROM code_value
  WHERE (code_set= $1)
  ORDER BY display_key
 ;end select
END GO

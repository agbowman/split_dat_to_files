CREATE PROGRAM ccl_menu_test_nooutput
 PROMPT
  "Output device: <MINE> " = mine
 SELECT INTO  $1
  o.person_id, c.display, o.*
  FROM orders o,
   code_value c
  PLAN (o
   WHERE o.person_id=25223799.0)
   JOIN (c
   WHERE c.code_set=200
    AND c.code_value=o.catalog_cd)
  WITH format, separator = " "
 ;end select
END GO

CREATE PROGRAM cv:dba
 SELECT INTO mine
  c.*
  FROM code_value c
  WHERE (c.code_value= $1)
  WITH nocounter
 ;end select
END GO

CREATE PROGRAM cvs:dba
 SELECT INTO mine
  c.*
  FROM code_value c
  WHERE (c.code_set= $1)
  WITH nocounter
 ;end select
END GO

CREATE PROGRAM cs:dba
 SELECT INTO mine
  c.*
  FROM code_value_set c
  WHERE (c.code_set= $1)
  WITH nocounter
 ;end select
END GO

CREATE PROGRAM cva:dba
 SELECT INTO mine
  c.*
  FROM code_value_alias c
  WHERE (c.code_value= $1)
  WITH nocounter
 ;end select
END GO

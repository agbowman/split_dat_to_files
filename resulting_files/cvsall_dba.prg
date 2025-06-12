CREATE PROGRAM cvsall:dba
 SELECT INTO mine
  c.*
  FROM code_value_set c
  ORDER BY code_set
  WITH nocounter
 ;end select
END GO

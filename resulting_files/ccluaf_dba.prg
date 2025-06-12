CREATE PROGRAM ccluaf:dba
 PROMPT
  "Enter MINE/CRT/printer/file: " = mine
 SELECT INTO  $1
  d.*
  FROM duaf d
  WITH format, counter, separator = " "
 ;end select
END GO

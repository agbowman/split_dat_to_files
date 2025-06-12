CREATE PROGRAM cclsrsel:dba
 PROMPT
  "Enter MINE/CRT/printer/file: " = mine,
  "Enter SR KEY VALUE: " = "*"
 SELECT
  sr.key1, sr.data
  FROM sr
  WHERE (sr.key1= $1)
 ;end select
END GO

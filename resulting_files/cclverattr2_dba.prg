CREATE PROGRAM cclverattr2:dba
 PROMPT
  "Enter MINE/CRT/printer/file: " = mine,
  "Enter table name:            " = "*",
  "Enter database name:         " = "*"
 SELECT DISTINCT INTO  $1
  a.table_name, attr1 = substring(1,20,l.attr_name)
  FROM dtable t,
   dtableattr a,
   dtableattrl l,
   dtableattr a2,
   dtableattrl l2
  PLAN (t
   WHERE (t.table_name= $2)
    AND (t.file_name= $3)
    AND t.platform="H0000")
   JOIN (a
   WHERE "H0000"=a.platform
    AND t.table_name=a.table_name)
   JOIN (l
   WHERE l.structtype="F")
   JOIN (a2
   WHERE a.table_name=a2.table_name
    AND "T0000"=a2.platform)
   JOIN (l2
   WHERE l.attr_name=l2.attr_name)
  HEAD a.table_name
   a.table_name
  DETAIL
   col 30, attr1, row + 1
  WITH outerjoin = l, dontexist, maxcol = 60,
   maxqual(l2,1)
 ;end select
END GO

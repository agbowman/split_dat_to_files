CREATE PROGRAM cclvertable:dba
 PROMPT
  "Enter MINE/CRT/printer/file: " = mine,
  "Enter table name:            " = "*",
  "Enter database name:         " = "*"
 SELECT DISTINCT INTO  $1
  msg = concat("TABLE ",a.table_name,":",t.access_code," NOT IN NEW DEF OR DIFF RCODE")
  FROM dtable t,
   dtable t2,
   dtableattr a,
   dtableattr a2
  PLAN (t
   WHERE (t.table_name= $2)
    AND (t.file_name= $3)
    AND t.platform="H0000")
   JOIN (t2
   WHERE t.table_name=t2.table_name
    AND t.file_name=t2.file_name
    AND "T0000"=t2.platform
    AND t.access_code=t2.access_code)
   JOIN (a
   WHERE "H0000"=a.platform
    AND t.table_name=a.table_name)
   JOIN (a2
   WHERE "T0000"=a2.platform
    AND a.table_name=a2.table_name)
  ORDER BY a.table_name
  WITH outerjoin = t2, dontexist
 ;end select
END GO

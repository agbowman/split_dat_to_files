CREATE PROGRAM curdom:dba
 SELECT
  node = curnode, domain = name, user = curuser
  FROM v$database
 ;end select
END GO

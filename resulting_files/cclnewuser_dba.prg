CREATE PROGRAM cclnewuser:dba
 SET modify = system
 DEFINE dic  WITH modify
 INSERT  FROM duaf d,
   ep00_1 e
  SET d.user_name = e.user_id2, d.group = 1, d.group_name = "GROUP1",
   d.datestamp = curdate, d.timestamp = curtime, d.stat = 0,
   d.cclcount = 0
  WHERE e.status="A"
   AND e.user_id2=d.user_name
   AND e.user_id2 != ""
  WITH dontexist, outerjoin = e, clear = "",
  counter
 ;end insert
END GO

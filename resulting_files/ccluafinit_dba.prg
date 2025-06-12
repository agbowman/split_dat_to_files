CREATE PROGRAM ccluafinit:dba
 SET modify = system
 DEFINE dic  WITH modify
 UPDATE  FROM duaf d
  SET d.stat = 0, d.cclcount = 0
  WHERE 1=1
  WITH counter
 ;end update
END GO

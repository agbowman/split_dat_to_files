CREATE PROGRAM dm_clear_errors2:dba
 SET msg = fillstring(132," ")
 SET msgnum = error(msg,1)
END GO

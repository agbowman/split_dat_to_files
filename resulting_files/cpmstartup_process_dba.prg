CREATE PROGRAM cpmstartup_process:dba
 SET trace = callecho
 CALL echo("Executing cpmstartup_process")
 EXECUTE cpmstartup
 SET trace progcachesize 200
END GO

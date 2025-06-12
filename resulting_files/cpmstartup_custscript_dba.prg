CREATE PROGRAM cpmstartup_custscript:dba
 SET trace = callecho
 CALL echo("Executing cpmstartup_custscript")
 EXECUTE cpmstartup
 EXECUTE cpmstartup_recache
 SET trace = noskiprecache
 SET trace = nocallecho
END GO

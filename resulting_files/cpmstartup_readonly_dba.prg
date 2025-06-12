CREATE PROGRAM cpmstartup_readonly:dba
 EXECUTE cpmstartup
 SET trace = skippersist
 SET trace = noskiprecache
 SET trace = cost
END GO

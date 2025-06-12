CREATE PROGRAM cpmstartup_discern:dba
 EXECUTE cpmstartup
 SET trace = noskiprecache
 SET trace = callecho
 SET trace = cost
 SET message = information
 SET trace = warning
 SET trace = warning2
 SET trace = error
 SET trace = skippersist
 SET trace = noautolock
END GO

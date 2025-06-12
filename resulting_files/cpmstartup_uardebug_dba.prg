CREATE PROGRAM cpmstartup_uardebug:dba
 SET trace = callecho
 CALL echo("Executing cpmstartup_uardebug")
 EXECUTE cpmstartup
 SET trace = callecho
 SET trace = server
 SET trace flush 30
 SET trace = cost
 SET trace = echoprogall
 SET trace = showuar
 SET trace = showuarpar
 SET trace = showuarpar2
 CALL echo("Overriding logging --- Debug Uar Logging Turned On...")
END GO

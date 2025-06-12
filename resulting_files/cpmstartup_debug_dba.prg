CREATE PROGRAM cpmstartup_debug:dba
 SET trace = callecho
 CALL echo("Executing cpmstartup_debug")
 EXECUTE cpmstartup
 SET trace = callecho
 SET trace = server
 SET trace flush 30
 SET trace = memory
 SET trace = test
 SET trace = echoinput
 SET trace = echoinput2
 SET trace = echoprog
 SET trace = echoprogsub
 SET trace = showuar
 CALL echo("Overriding logging --- Debug Logging Turned On...")
 SET trace = rdbdebug
 SET trace = rdbbind
END GO

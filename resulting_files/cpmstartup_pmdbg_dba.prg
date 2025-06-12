CREATE PROGRAM cpmstartup_pmdbg:dba
 DECLARE cpmstartup_pmdbg = i2 WITH constant(true), persist
 SET trace = callecho
 CALL echo("executing cpmstartup_pmdbg...")
 EXECUTE cpmstartup
 CALL echo("setting cpmstartup_pmdbg trace parameters...")
 SET trace = callecho
 SET trace flush 60
 SET trace = echoinput
 SET trace = echoinput2
 SET trace = echoprog
 SET trace = echoprogsub
 SET trace = echorecord
 SET trace = memory
 SET trace = rdbdebug
 SET trace = rdbbind
 SET trace = showuar
 SET trace = showuarpar
 SET trace = test
 SET trace = timer
 SET message = information
 SET trace = cost
END GO

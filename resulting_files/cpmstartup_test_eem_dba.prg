CREATE PROGRAM cpmstartup_test_eem:dba
 SET trace = callecho
 CALL echo("Executing cpmstartup_test")
 EXECUTE cpmstartup
 SET logical cpm_global_logging "ON"
 SET trace = callecho
 SET trace = server
 SET trace flush 30
 SET trace = notest
 SET trace = noechoinput
 SET trace = noechoinput2
 SET trace = echoprog
 SET trace = echoprogsub
 SET trace = noechorecord
 SET trace = showuar
 CALL echo("Overriding logging --- Full Logging turned on for testing...")
END GO

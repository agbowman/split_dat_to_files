CREATE PROGRAM cpmstartup_afctest:dba
 CALL echo(
  "##############################################################################################")
 CALL echo("Executing cpmstartup_afctest")
 EXECUTE cpmstartup
 SET trace = callecho
 SET trace = server
 SET trace flush 60
 SET trace = notest
 SET trace = noechoinput
 SET trace = noechoinput2
 SET trace = noechoprog
 SET trace = noechoprogsub
 SET trace = nordbdebug
 SET trace = noechorecord
 SET trace = noshowuar
 CALL echo("Overriding logging --- Full Logging turned on for testing...")
 SET from_afctest = 1
 EXECUTE cpmstartup_afc
 SET trace = showenv
 CALL echo(
  "##############################################################################################")
END GO

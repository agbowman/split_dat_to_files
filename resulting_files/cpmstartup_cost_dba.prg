CREATE PROGRAM cpmstartup_cost:dba
 SET trace = callecho
 CALL echo("Executing cpmstartup_cost")
 EXECUTE cpmstartup
 SET trace = server
 SET trace flush 120
 SET trace = cost
 SET trace = error
 SET trace = notest
 SET trace = noechoinput
 SET trace = noechoinput2
 SET trace = noechoprog
 SET trace = noechoprogsub
 SET trace = noechorecord
 SET trace = noshowuar
END GO

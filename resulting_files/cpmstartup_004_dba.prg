CREATE PROGRAM cpmstartup_004:dba
 SET trace = callecho
 CALL echo("Executing cpmstartup_004")
 SET trace = nocallecho
 EXECUTE cpmstartup
 SET trace progcachesize 255
 IF (1=0)
  SET trace = echoprog
  SET trace = echoprogsub
  SET trace = cost
  SET trace = skiprecache
 ENDIF
 CALL echo("Overriding logging --- Full Logging turned on for testing...")
END GO

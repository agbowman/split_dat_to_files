CREATE PROGRAM cpmstartup_esidbg:dba
 SET trace = callecho
 CALL echo("executing cpmstartup_esidbg...")
 EXECUTE cpmstartup
 EXECUTE esi_startup_load_cv
 CALL echo("setting cpmstartup_esidbg trace parameters...")
 SET trace = callecho
 SET trace flush 1
 SET trace = echoinput
 SET trace = echoinput2
 SET trace = echoprog
 SET trace = echoprogsub
 SET trace = rdbdebug
 SET trace = rdbbind
 SET trace = test
 SET trace = notimer
 SET message = information
 CALL echo("setting cpmstartup_esidbg cache parameters...")
 SET trace rangecache 350
 SET trace progcachesize 250
 SET trace progcache 200
END GO

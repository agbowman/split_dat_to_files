CREATE PROGRAM cpmstartup_esi:dba
 SET trace = callecho
 CALL echo("executing cpmstartup_esi...")
 EXECUTE cpmstartup
 EXECUTE esi_startup_load_cv
 CALL echo("setting cpmstartup_esi trace parameters...")
 SET trace = callecho
 SET trace flush 5
 SET trace = noechoinput
 SET trace = noechoinput2
 SET trace = noechoprog
 SET trace = noechoprogsub
 SET trace = noechorecord
 SET trace = nomemory
 SET trace = nordbdebug
 SET trace = nordbbind
 SET trace = notest
 SET trace = notimer
 SET message = noinformation
 CALL echo("setting cpmstartup_esi cache parameters...")
 SET trace = nocallecho
 SET trace rangecache 350
 SET trace progcachesize 250
 SET trace progcache 200
END GO

CREATE PROGRAM cpmstartup_script:dba
 SET trace = callecho
 CALL echo("Executing cpmstartup_script")
 CALL echo("calling cpmstartup")
 EXECUTE cpmstartup
 SET trace rangecache 1000
 SET trace progcache 300
 SET trace progcachesize 50
END GO

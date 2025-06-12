CREATE PROGRAM cpmstartup_esodbg:dba
 SET trace = callecho
 CALL echo("executing cpmstartup_esodbg...")
 EXECUTE cpmstartup
 SET trace = server
 SET trace = callecho
 CALL echo("setting cpmstartup_esodbg cache parameters...")
 SET trace rangecache 350
 SET trace progcachesize 400
 SET trace progcache 250
 CALL echo("ESODBG set -> Rangecache set to 350")
 CALL echo("ESODBG set -> Program cache set to 250")
 CALL echo("ESODBG set -> Progcachsize set to 400")
 CALL echo("setting cpmstartup_esodbg trace parameters...")
 SET trace = callecho
 SET trace = noechoinput
 SET trace = noechoinput2
 SET trace = noechoprog
 SET trace = noechoprogsub
 SET trace = noechorecord
 SET trace = nomemory
 SET trace = nordbdebug
 SET trace = nordbbind
 SET trace = noshowuar
 SET trace = noshowuarpar
 SET trace = notest
 SET trace = notimer
 SET message = noinformation
 SET trace = recpersist
 RECORD oen_log(
   1 hsys = i4
   1 sysstat = i4
   1 logmsg = c80
 )
 SET trace = norecpersist
 SET oen_log->hsys = 0
 SET sysstat = 0
 CALL uar_syscreatehandle(oen_log->hsys,sysstat)
END GO

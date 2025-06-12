CREATE PROGRAM cpmstartup_oen_srvrouter:dba
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
 EXECUTE cpmstartup
 SET trace rangecache 200
 SET trace progcache 200
 SET trace progcachesize 100
 SET trace rdbarrayfetch 25
 SET trace = callecho
 CALL echo("Oen_srvrouter startup script")
 CALL echo("Call echo statements disabled!")
 SET trace = nocallecho
 IF (trim(logical("OENCALLECHO")) != "")
  SET trace = callecho
  CALL echo("Found Callecho Logical: OENCALLECHO")
  CALL echo("Call echo statements enabled!")
 ENDIF
 IF (cnvtupper(curprcname)="SRV*")
  SET server_callecho = concat("SRV",substring(4,4,curprcname),"_CALLECHO")
  IF (trim(logical(server_callecho)) != "")
   SET trace = callecho
   CALL echo(concat("Found Callecho Logical: ",server_callecho))
   CALL echo("Call echo statements enabled!")
  ENDIF
 ENDIF
 SET trace = callecholock
 SET trace = noflush
 SET trace flush 30
 SET trace = nocost
 SET message = noinformation
 SET trace = error
 SET trace = alterlistinit
END GO

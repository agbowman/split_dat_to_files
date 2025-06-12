CREATE PROGRAM cpmstartup_oen_debugger:dba
 CALL echo("OEN Interface Debugger Startup Script")
 SET trace rangecache 200
 SET trace progcache 200
 SET trace progcachesize 100
 SET trace rdbarrayfetch 25
 SET trace = noskiprecache
 SET trace = callecho
 SET trace = noflush
 SET trace flush 30
 SET message = information
 SET trace = error
 SET trace = alterlistinit
 SET trace = recpersist
 RECORD oen_log(
   1 hsys = i4
   1 sysstat = i4
   1 logmsg = c80
 )
 RECORD oen_result(
   1 result = vc
   1 field_num = i4
   1 delimiter = vc
   1 status = i4
   1 source = vc
   1 seg_name = vc
   1 removed_seg = vc
 )
 SET trace = norecpersist
 SET oen_log->hsys = 0
 SET sysstat = 0
 CALL uar_syscreatehandle(oen_log->hsys,sysstat)
END GO

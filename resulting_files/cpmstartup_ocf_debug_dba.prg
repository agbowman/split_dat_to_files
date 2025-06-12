CREATE PROGRAM cpmstartup_ocf_debug:dba
 SET trace = hipaa2
 SET trace = echoinput
 SET trace = echoinput2
 SET trace = cost
 SET trace = memcost
 SET trace = noflush
 SET trace flush 60
 SET trace = memory3
 SET trace = lock
END GO

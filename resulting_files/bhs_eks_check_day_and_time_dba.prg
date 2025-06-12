CREATE PROGRAM bhs_eks_check_day_and_time:dba
 SET eid = trigger_encntrid
 SET retval = 100
 CALL echo(build("eid:",eid))
 IF (curtime BETWEEN 0800 AND 1729)
  SET retval = 0
 ENDIF
 CALL echo(build("curtime",curtime))
 CALL echo(build("curtime retval:",retval))
 IF (weekday(curdate) IN (0, 6))
  SET retval = 100
 ENDIF
 CALL echo(build("curdate",weekday(curdate)))
 CALL echo(build("curdate retval:",retval))
#exit_prog
END GO

CREATE PROGRAM ccloracursor:dba
 SELECT INTO "nl:"
  s.sid, s.audsid, open_cursor = cnvtint(a.value),
  username = substring(1,12,s.username), node = substring(1,12,s.machine)
  FROM v$sesstat a,
   v$statname b,
   v$session s
  WHERE a.statistic#=b.statistic#
   AND s.sid=a.sid
   AND b.name="opened cursors current"
   AND s.machine=curnode
   AND s.username=currdbuser
   AND s.audsid=cnvtreal(currdbhandle)
  DETAIL
   CALL echo(build(">>>RDBCURSOR SID=",cnvtlong(s.sid),"|HAN=",cnvtlong(s.audsid),"|OPEN=",
    open_cursor,"|USER=",username,"|NODE=",node))
  WITH nocounter, maxrow = 1
 ;end select
END GO

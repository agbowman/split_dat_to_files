CREATE PROGRAM ccloracursor2:dba
 PROMPT
  "Enter output name : " = "MINE",
  "Enter mode 1|2| : " = 1
 CASE ( $2)
  OF 1:
   SELECT INTO  $1
    s.sid, s.audsid, open_cursor = a.value,
    username = substring(1,12,s.username), node = substring(1,12,s.machine), s.module
    FROM v$sesstat a,
     v$statname b,
     v$session s
    WHERE a.statistic#=b.statistic#
     AND s.sid=a.sid
     AND b.name="opened cursors current"
     AND s.machine=curnode
     AND s.username=currdbuser
    ORDER BY open_cursor DESC
    WITH nocounter
   ;end select
  OF 2:
   SELECT INTO  $1
    s.sid, s.audsid, open_cursor = a.value,
    username = substring(1,12,s.username), node = substring(1,12,s.machine), s.module
    FROM v$sesstat a,
     v$statname b,
     v$session s
    WHERE a.statistic#=b.statistic#
     AND s.sid=a.sid
     AND b.name="opened cursors current"
     AND s.machine=curnode
     AND s.username=currdbuser
     AND s.audsid=cnvtreal(currdbhandle)
    WITH nocounter
   ;end select
 ENDCASE
END GO

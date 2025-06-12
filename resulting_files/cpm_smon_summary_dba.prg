CREATE PROGRAM cpm_smon_summary:dba
 SET maxcnt = 0.0
 SET totalcnt = 0
 SET sdate = "01/01"
 RECORD sum(
   1 qual[24]
     2 cnt = i4
     2 dvalue = i2
     2 msrv = vc
     2 msrv_cnt = i4
 )
 IF (validate(p_file," ")=" ")
  SET p_file = "unknown"
 ENDIF
 CALL echo("running summary by hour...")
 SELECT
  hour = substring(7,2,r.line)
  FROM rtlt r
  ORDER BY hour
  HEAD REPORT
   col 0, "hour,count", row + 1
  HEAD PAGE
   sdate = substring(1,5,r.line)
  HEAD hour
   cnt = 0
  DETAIL
   pos = (findstring(",",r.line,15)+ 1), scnt = cnvtint(substring(pos,5,r.line))
   IF (scnt > 0)
    cnt = (cnt+ scnt)
   ENDIF
  FOOT  hour
   dline = trim(concat(hour,",",trim(format(cnt,"######")))), col 0, dline,
   row + 1, idx = (cnvtint(hour)+ 1), sum->qual[idx].cnt = cnt
   IF (cnt > maxcnt)
    maxcnt = cnt
   ENDIF
   cnt = 0
  WITH counter
 ;end select
 CALL echo("running summary by unit of measure...")
 SELECT
  hour = substring(7,5,r.line)
  FROM rtlt r
  ORDER BY hour
  HEAD REPORT
   col 0, "hour,count", row + 1
  HEAD PAGE
   sdate = substring(1,5,r.line)
  HEAD hour
   cnt = 0
  DETAIL
   pos = (findstring(",",r.line,15)+ 1), scnt = cnvtint(substring(pos,5,r.line))
   IF (scnt > 0)
    cnt = (cnt+ scnt)
   ENDIF
  FOOT  hour
   dline = trim(concat(hour,",",trim(format(cnt,"######")))), col 0, dline,
   row + 1
  WITH nocounter, maxrow = 1, noformat,
   noformfeed
 ;end select
 CALL echo("running summary by hour by service...")
 SELECT
  hour = substring(7,2,r.line), service = substring(13,(findstring(",",r.line,14) - 13),r.line)
  FROM rtlt r
  ORDER BY hour, service
  HEAD hour
   cnt = 0, mcnt = 0, mservice = fillstring(30," ")
  HEAD service
   cnt = 0
  DETAIL
   pos = (findstring(",",r.line,15)+ 1), scnt = cnvtint(substring(pos,5,r.line)), cnt = (cnt+ scnt)
  FOOT  service
   dline = concat(hour,",",trim(service),",",trim(cnvtstring(cnt))), dline2 = substring(1,50,dline),
   col 0,
   dline2, row + 1
   IF (cnt > mcnt)
    mcnt = cnt, mservice = service
   ENDIF
  FOOT  hour
   idx = (cnvtint(hour)+ 1), sum->qual[idx].msrv = mservice, sum->qual[idx].msrv_cnt = mcnt
  WITH nocounter, maxrow = 1, noformat,
   noformfeed, maxcol = 55
 ;end select
 CALL echo(build("running summary report... for: ",p_file))
 SELECT
  FROM dummyt d
  HEAD PAGE
   col 0, "Source date: ", sdate,
   col 60, "print date: ", curdate"mm/dd/yyyy;;d",
   " ", curtime"hh:mm;;m", row + 1,
   col 0, "Source File: ", p_file,
   row 20, col 0, "hour",
   col 6, "requests", col 15,
   "percent", col 23, "Max Service/Count",
   row 21, col 0, "-------------------------------------------------------------------",
   percent = 0.0, ccol = 10, prow = 5,
   pcnt = 100
   FOR (x = 0 TO 10)
     row prow, col 0, pcnt"###",
     "%", prow = (prow+ 1), pcnt = (pcnt - 10)
   ENDFOR
   FOR (x = 1 TO 24)
     percent = 0.0
     IF ((sum->qual[x].cnt > 0))
      percent = (sum->qual[x].cnt/ maxcnt), sum->qual[x].dvalue = (percent * 10)
     ENDIF
     rval = (15 - cnvtint(sum->qual[x].dvalue))
     FOR (rcnt = rval TO 15)
       row rcnt, col ccol, "*"
     ENDFOR
     totalcnt = (totalcnt+ sum->qual[x].cnt), row 17
     IF (x < 10)
      col ccol, x"#"
     ELSEIF (x < 20)
      col ccol, "1", row 18,
      dx = (x - 10), col ccol, dx"#"
     ELSE
      col ccol, "2", row 18,
      dx = (x - 20), col ccol, dx"#"
     ENDIF
     ccol = (ccol+ 2), call reportmove('ROW',(21+ x),0), dpercent = (sum->qual[x].dvalue * 10),
     davg = ((cnvtreal(sum->qual[x].msrv_cnt)/ cnvtreal(sum->qual[x].cnt)) * 100), hour = (x - 1),
     col 0,
     hour"##", col 5, sum->qual[x].cnt"#######",
     col 15, dpercent"###.##", "%",
     col 23, sum->qual[x].msrv, col 43,
     sum->qual[x].msrv_cnt"######", col 50, davg"###.##",
     "%"
   ENDFOR
   dashes = fillstring(60,"-"), row 3, col 0,
   "Total request per hour", row 4, col 0,
   dashes, row 16, col 0,
   dashes, row 55, col 0,
   "peak requests per hour: ", maxcnt, row 56,
   avg = (totalcnt/ 24), col 0, "total for day: ",
   totalcnt"#########", " average per hour: ", avg"#####"
  DETAIL
   col + 0
  WITH maxcol = 132, nocounter
 ;end select
END GO

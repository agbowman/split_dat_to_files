CREATE PROGRAM crmtimer4
 PAINT
 DEFINE crmtimer "cer_log:crmtimer.mlg"
 DECLARE startkey = i4
 DECLARE lastkey = i4
#start
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,22,80)
 CALL line(3,1,80,xhoraz)
 CALL text(2,3,"Script Server History by Username")
 CALL video(n)
 CALL text(5,5,"Output File/Printer/Mine (MINE)? ")
 CALL text(6,5,"Elapsed Time Value (1.0)?")
 CALL text(7,5,"Print only those > Elapsed Time?")
 CALL text(9,5,"Start Date? ")
 CALL text(10,5,"End Date?")
 CALL text(11,5,"Start Log Number? ")
 CALL accept(5,40,"PPPPPPPPP;CU","MINE")
 SET outfile = curaccept
 CALL accept(6,40,"99.99",1.0)
 SET mintime = curaccept
 CALL accept(7,40,"X;CU","Y")
 SET printall = curaccept
 IF (printall="Y")
  CALL text(8,5,"Executed > x times? ")
  CALL accept(8,40,"99",10)
  SET minexec = curaccept
 ELSE
  SET minexec = 0
 ENDIF
 CALL accept(9,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
 SET startdate = curaccept
 CALL accept(10,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
 SET enddate = curaccept
 DEFINE msgview concat("cer_log:","crmtimer.mlg")
 SELECT INTO "nl:"
  m.lastrec
  FROM msgviewhdr m
  WHERE m.key1=1
  DETAIL
   startkey = m.lastrec
   IF (m.nextrec=m.maxrec)
    lastkey = m.maxrec
   ELSE
    lastkey = m.nextrec
   ENDIF
  WITH nocounter
 ;end select
 CALL accept(11,40,"99999999",(startkey - 200))
 SET startkey = curaccept
 CALL accept(11,55,"99999999",(startkey+ 200))
 SET lastkey = curaccept
 SELECT INTO value(outfile)
  name = substring(1,40,p.name_full_formatted), c.username, c.event,
  c.appctx, c.bio, c.cpu,
  c.dio, c.key1, c.log,
  c.pageflt, c.perfct, c.reqid,
  c.timer1, c.timer2, c.timer3,
  ttimer = (cnvtreal(c.timer2)+ cnvtreal(c.timer3)), request = cnvtint(c.reqid)
  FROM crmtimer c,
   prsnl p
  PLAN (c
   WHERE c.key1 >= startkey
    AND c.key1 <= lastkey
    AND c.event="Script*"
    AND c.updt_dt_tm >= cnvtdatetime(startdate)
    AND c.updt_dt_tm <= cnvtdatetime(concat(enddate,":24:00:00")))
   JOIN (p
   WHERE c.username=p.username)
  ORDER BY c.username, request, ttimer DESC
  HEAD REPORT
   totalrcnt = 0, totalrcntover = 0, rcnt = 0,
   ot = 0, ottime = 0.0, rtime = 0.0,
   maxt = 0.0, mint = 9999.99, cpu = 0.0
  HEAD PAGE
   col 0, "Summary Requests over ", mintime,
   " seconds as of ", curdate, row + 1,
   col 0, "Request", col 12,
   "Tot Req Cnt", col 25, "Over Min",
   col 35, "Avg Time", col 45,
   "Avg Over", col 55, "Min Time",
   col 65, "Max Time", col 75,
   "Avg CPU", row + 1, col 0,
   "______________________________________________________________________________________", row + 1
  HEAD c.username
   cuser = c.username
  HEAD request
   totalrcnt = (totalrcnt+ 1), rcnt = 0, ot = 0,
   ottime = 0.0, rtime = 0.0, xavg = 0.0,
   maxt = 0.0, mint = 9999.99, cpu = 0.0
  DETAIL
   IF (ttimer > maxt)
    maxt = ttimer
   ENDIF
   IF (ttimer < mint)
    mint = ttimer
   ENDIF
   rcnt = (rcnt+ 1), rtime = (rtime+ ttimer)
   IF (ttimer > mintime)
    ot = (ot+ 1), ottime = (ottime+ ttimer)
   ENDIF
   cpu = (cpu+ cnvtreal(c.cpu))
  FOOT  request
   xavg = (rtime/ rcnt)
   IF (((printall="N") OR (printall="Y"
    AND xavg > mintime
    AND rcnt > minexec)) )
    IF (cuser > " ")
     col 0, cuser, " - ",
     name, row + 1, cuser = " "
    ENDIF
    col 0, request, col 15,
    rcnt"########", col 25, ot"########",
    col 35, xavg"#####.##", xavg = (ottime/ ot),
    col 45, xavg"#####.##", col 55,
    mint"####.##", col 65, maxt"#####.##",
    xavg = (cpu/ rcnt), col 75, xavg"####.####",
    row + 1
   ENDIF
   IF (xavg > mintime)
    totalrcntover = (totalrcntover+ 1)
   ENDIF
  FOOT  c.username
   row + 0
  FOOT REPORT
   BREAK, "Unique Requests                  = ", totalrcnt"######",
   row + 1, "Unique Requests Over Minimum     = ", totalrcntover"######",
   row + 2, "Total requests executed          = ", count(c.seq),
   row + 1, "Avg request elapsed time         = ", avg(cnvtreal(ttimer))"######.####",
   row + 1, "Avg request cpu time             = ", avg(cnvtreal(c.cpu))"######.####",
   row + 1, row + 1, "Total requests executed over     = ",
   count(c.seq
   WHERE cnvtreal(ttimer) > mintime), row + 1, "Avg request elapsed time over    = ",
   avg(cnvtreal(ttimer)
   WHERE cnvtreal(ttimer) > mintime)"######.####", row + 1, "Avg request cpu time over        = ",
   avg(cnvtreal(c.cpu)
   WHERE cnvtreal(c.timer1) > mintime)"######.####", row + 1, row + 1,
   "Total requests executed under    = ", count(c.seq
   WHERE cnvtreal(c.timer1) < mintime), row + 1,
   "Avg request elapsed time under   = ", avg(cnvtreal(ttimer)
   WHERE cnvtreal(ttimer) < mintime)"######.####", row + 1,
   "Avg request cpu time under       = ", avg(cnvtreal(c.cpu)
   WHERE cnvtreal(c.timer1) < mintime)"######.####", row + 1,
   row + 1
  WITH noheading, format = variable, check,
   maxcol = 100, maxrow = 60
 ;end select
END GO

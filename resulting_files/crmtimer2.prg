CREATE PROGRAM crmtimer2
 PAINT
 FREE DEFINE crmtimer
 DEFINE crmtimer "cer_log:crmtimer.mlg"
#start
 SET startkey = 0
 SET lastkey = 0
 SET outfile = "MINE"
 SET mintime = 1.0
 SET appctx = 0
 SET request = 0
 SET printall = "N"
 SET printsummary = "N"
 SET printall = "N"
 SET printsummary = "N"
 SET username = fillstring(100," ")
 SET override = 0
 SET startdate = fillstring(11," ")
 SET enddate = fillstring(11," ")
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,22,80)
 CALL line(3,1,80,xhoraz)
 CALL text(2,3,"Script Server Summary")
 CALL video(n)
 FREE DEFINE msgview
 DEFINE msgview concat("cer_log:","crmtimer.mlg")
 SELECT INTO "nl:"
  m.lastrec
  FROM msgviewhdr m
  WHERE m.key1=1
  DETAIL
   startkey = m.lastrec, lastkey = m.lastrec
   IF (startkey > lastkey)
    lastkey = m.maxrec
   ENDIF
  WITH nocounter
 ;end select
 CALL text(5,5,"Output File/Printer/Mine (MINE)? ")
 CALL text(6,5,"Specific Application Context? ")
 CALL text(7,5,"Specific Username?")
 CALL text(8,5,"Specific Request? ")
 CALL text(9,5,"Start Log Number? ")
 CALL accept(5,40,"PPPPPPPPP;CU","MINE")
 SET outfile = curaccept
 CALL accept(6,40,"99999999999",0)
 SET appctx = curaccept
 CALL accept(7,40,"XXXXXXXXXXX;CU","*")
 SET username = curaccept
 CALL accept(8,40,"99999999999",0)
 SET request = curaccept
 CALL accept(9,40,"99999999",(startkey - 500))
 SET startkey = curaccept
 CALL accept(9,55,"99999999",lastkey)
 SET lastkey = curaccept
 IF (((request > 0) OR (((appctx > 0) OR (username > " ")) )) )
  SET override = 1
  GO TO start_query
 ENDIF
 CALL text(10,5,"Elapsed Time Value (1.0)?")
 CALL text(11,5,"Start Date? ")
 CALL text(12,5,"End Date?")
 CALL text(13,5,"Print only those > Elapsed Time?")
 CALL text(14,5,"Print Summary Only ?")
 CALL accept(10,40,"99.99",1.0)
 SET mintime = curaccept
 CALL accept(11,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
 SET startdate = curaccept
 CALL accept(12,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
 SET enddate = curaccept
 CALL accept(13,40,"X;CU","Y")
 SET printall = curaccept
 CALL accept(14,40,"X;CU","N")
 SET printsummary = curaccept
#start_query
 SELECT
  IF (override=1)
   ORDER BY cnvtint(c.appctx), cnvtint(c.perfct)
  ELSE
   ORDER BY ttimer DESC
  ENDIF
  INTO value(outfile)
  c.username, c.event, c.appctx,
  c.bio, c.cpu, c.dio,
  c.key1, c.log, c.pageflt,
  c.perfct, c.reqid, c.timer1,
  c.timer2, c.timer3, source = substring(9,2,c.source),
  ttimer = (cnvtreal(c.timer2)+ cnvtreal(c.timer3)), ctime = concat(format(c.updt_dt_tm,"mm/dd;;d"),
   " ",format(c.updt_dt_tm,"hh:mm:ss;;m"))
  FROM crmtimer c
  WHERE c.key1 >= startkey
   AND c.key1 <= lastkey
   AND ((override=1) OR (c.updt_dt_tm >= cnvtdatetime(startdate)
   AND c.updt_dt_tm <= cnvtdatetime(concat(enddate,":24:00:00"))))
   AND c.event="Script*"
   AND ((username=" ") OR (c.username=cnvtupper(username)))
   AND ((request=0) OR (request=cnvtint(c.reqid)))
   AND ((appctx=0) OR (appctx=cnvtint(c.appctx)))
  HEAD PAGE
   col 0, "CRM Timer Report of scripts with elapsed time > ", mintime,
   " Page# ", curpage"######", " DateTime ",
   CALL print(format(cnvtdatetime(c.updt_dt_tm),";;q")), row + 1, col 0,
   "AppCxt", col 15, "Req Id",
   col 25, "Elapse1", col 35,
   "Elapse2", col 45, "Elapse3",
   col 55, "Cpu", col 65,
   "Bio", col 75, "Dio",
   col 82, "PgFl", col 87,
   "Username Perform Cnt Date/Time MsgNbr Inst", row + 1, xlin = fillstring(130,"-"),
   col 0, xlin, row + 1
  DETAIL
   IF (printsummary="N")
    IF (((printall="N") OR (printall="Y"
     AND cnvtreal(c.timer1) > mintime)) )
     IF (((row+ 10) >= maxrow))
      BREAK
     ENDIF
     IF (ttimer > mintime)
      col 1, "*"
     ENDIF
     col 2, c.appctx, col 15,
     c.reqid, col 25, c.timer1,
     col 35, c.timer2, col 45,
     c.timer3, col 55, c.cpu,
     col 65, c.bio, col 75,
     c.dio, col 82, c.pageflt,
     col 87, c.username
     IF (cnvtint(c.log)=1)
      col 99, "*"
     ENDIF
     col 100, c.perfct, col 106,
     ctime, ckey = cnvtstring((c.key1+ 2),6,0,r), col 121,
     ckey, col 128, source,
     row + 1
    ENDIF
   ENDIF
  FOOT REPORT
   BREAK, "Total requests                   = ", count(c.seq),
   row + 1, "Avg request elapsed time         = ", avg(cnvtreal(ttimer))"######.####",
   row + 1, "Avg request cpu time             = ", avg(cnvtreal(c.cpu))"######.####",
   row + 1, row + 1, "Total requests over              = ",
   count(c.seq
   WHERE cnvtreal(ttimer) > mintime), row + 1, "Avg request elapsed time over    = ",
   avg(cnvtreal(ttimer)
   WHERE cnvtreal(ttimer) > mintime)"######.####", row + 1, "Avg request cpu time over        = ",
   avg(cnvtreal(c.cpu)
   WHERE cnvtreal(c.timer1) > mintime)"######.####", row + 1, row + 1,
   "Total requests under             = ", count(c.seq
   WHERE cnvtreal(c.timer1) < mintime), row + 1,
   "Avg request elapsed time under   = ", avg(cnvtreal(ttimer)
   WHERE cnvtreal(ttimer) < mintime)"######.####", row + 1,
   "Avg request cpu time under       = ", avg(cnvtreal(c.cpu)
   WHERE cnvtreal(c.timer1) < mintime)"######.####", row + 1,
   row + 1
  WITH noheading, format = variable, check,
   maxcol = 250, maxrow = 60
 ;end select
END GO

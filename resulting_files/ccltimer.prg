CREATE PROGRAM ccltimer
 PAINT
 FREE DEFINE crmtimer
 DEFINE crmtimer "cer_log:crmtimer.mlg"
#start
 SET srv = fillstring(10," ")
 SET startkey = 0
 SET sort_type = "T"
 SET lastkey = 0
 SET outfile = "MINE"
 SET mintime = 0.5
 SET appctx = 0
 SET request = 0
 SET printrestrict = "Y"
 SET printsummary = "N"
 SET username = fillstring(100," ")
 SET startdate = fillstring(11," ")
 SET enddate = fillstring(11," ")
 SET scriptname = fillstring(31," ")
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,22,80)
 CALL line(3,1,80,xhoraz)
 CALL text(2,3,"CCL CRMTIMER Summary    Rev 6.00")
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
 CALL text(9,5,"Start Log Number(last-1000)? ")
 CALL text(10,5,"Elapsed Time Value (0.5)?")
 CALL text(11,5,"Start Date? ")
 CALL text(12,5,"End Date?")
 CALL text(13,5,"Server Number?")
 CALL text(14,5,"Script Name?")
 CALL text(15,5,"Sort (T)ime,(C)pu,(N)one?")
 CALL text(16,5,"Print only > Elapsed Time(N/Y/Z)?")
 CALL text(18,5,"(N:show all Y:show all > time Z: show all > time include all in summary)")
 CALL accept(5,40,"PPPPPPPPP;CU","MINE")
 SET outfile = curaccept
 CALL accept(6,40,"99999999999",0)
 SET appctx = curaccept
 CALL accept(7,40,"PPPPPPPPPPPPPPPPPPPPP;CUP","*")
 SET username = concat(curaccept)
 CALL accept(8,40,"99999999999",0)
 SET request = curaccept
 CALL accept(9,40,"99999999",(startkey - 1000)
  WHERE curaccept > 1)
 SET startkey = curaccept
 CALL accept(9,55,"99999999",lastkey
  WHERE curaccept > startkey)
 SET lastkey = curaccept
 CALL accept(10,40,"NNNNN;",0.5)
 SET mintime = curaccept
 CALL accept(11,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
 SET startdate = curaccept
 CALL accept(12,40,"NNDCCCDNNNN;C",format((curdate+ 1),"DD-MMM-YYYY;;D"))
 SET enddate = curaccept
 CALL accept(13,40,"9999",0)
 SET srv = cnvtstring(curaccept,4,0,r)
 CALL accept(14,40,"p(31);cu","*")
 SET scriptname = curaccept
 SET scriptnameval = ichar(substring(1,1,scriptname))
 CALL accept(15,40,"p;cu","T")
 SET sort_type = curaccept
 CALL accept(16,40,"A;CU","Y")
 SET printrestrict = curaccept
#start_query
 SELECT
  IF (scriptnameval > 32
   AND sort_type="T")
   ORDER BY cnvtreal(c.timer1) DESC
   WITH noheading, format = variable, maxcol = 132,
    maxrow = 60
  ELSEIF (scriptnameval > 32
   AND sort_type="C")
   ORDER BY cnvtreal(c.timer2) DESC
   WITH noheading, format = variable, maxcol = 132,
    maxrow = 60
  ELSEIF (scriptnameval < 32
   AND sort_type="T")
   ORDER BY cnvtreal(c.timer1) DESC
   WITH noheading, format = variable, maxcol = 132,
    maxrow = 60, outerjoin = c
  ELSEIF (scriptnameval < 32
   AND sort_type="C")
   ORDER BY cnvtreal(c.timer2) DESC
   WITH noheading, format = variable, maxcol = 132,
    maxrow = 60, outerjoin = c
  ELSEIF (scriptnameval > 32
   AND sort_type="N")
   WITH noheading, format = variable, maxcol = 132,
    maxrow = 60
  ELSEIF (scriptnameval < 32
   AND sort_type="N")
   WITH noheading, format = variable, maxcol = 132,
    maxrow = 60, outerjoin = c
  ELSE
  ENDIF
  INTO value(outfile)
  c.username, c.event, c.appctx,
  c.bio, c.cpu, c.dio,
  c.key1, c.log, c.pageflt,
  c.perfct, c.reqid, c.timer1,
  c.timer2, c.timer3, hsort = concat(substring(4,4,c.source),cnvtstring(cnvtint(c.reqid),8,0,r)),
  source = substring(4,4,c.source), ttimer = cnvtreal(c.timer1), ctime = concat(format(c.updt_dt_tm,
    "mm/dd;;d")," ",format(c.updt_dt_tm,"hh:mm:ss;;m")),
  d.binary_cnt, d.ccl_version, dflag = decode(d.seq,1,0)
  FROM crmtimer c,
   dprotect d
  PLAN (c
   WHERE c.key1 >= startkey
    AND c.key1 <= lastkey
    AND c.updt_dt_tm >= cnvtdatetime(startdate)
    AND c.updt_dt_tm <= cnvtdatetime(concat(enddate,":24:00:00"))
    AND c.event="StepTimer*"
    AND ((srv="0000") OR (srv=substring(4,4,c.source)))
    AND ((username=" ") OR (c.username=username))
    AND ((request=0) OR (request=cnvtint(trim(c.reqid))))
    AND ((appctx=0) OR (cnvtint(trim(c.appctx))=appctx))
    AND ((cnvtreal(c.timer1) >= mintime
    AND printrestrict != "N") OR (printrestrict != "Y")) )
   JOIN (d
   WHERE "P"=d.object
    AND cnvtupper(uar_get_tdbname(cnvtint(c.reqid)))=d.object_name
    AND d.object_name=scriptname)
  HEAD PAGE
   col 00, "Ccl CrmTimer Report of scripts with elapsed time > ", mintime"#####.####;l",
   col 60, "Sort(", sort_type,
   ")", col 70, " DateTime ",
   CALL print(format(cnvtdatetime(c.updt_dt_tm),";;q")), col 110, " Page# ",
   curpage"######;l", row + 1, col 00,
   "Server", col 10, "Req Id",
   col 20, "Elapse", col 30,
   "CPU", col 40, "Username",
   col 50, "PerfCnt", col 60,
   "Date/Time", col 76, "Msg Nbr",
   col 85, "Bin", col 93,
   "TdbName", col 125, "AppCtx",
   row + 1, xlin = fillstring(130,"-"), col 0,
   xlin, row + 1
  DETAIL
   IF (((ttimer > mintime) OR (printrestrict="N")) )
    IF (ttimer > mintime)
     col 1, "*"
    ENDIF
    col 2, source, col 10,
    c.reqid, col 20, c.timer1,
    col 30, c.timer2, col 40,
    c.username, col 50, c.perfct,
    col 60, ctime, ckey = cnvtstring((c.key1+ 2),6,0,r),
    col 76, ckey
    IF (dflag=1)
     col 85, d.binary_cnt"#####"
    ELSE
     col 85, "    ?"
    ENDIF
    col 93,
    CALL print(trim(uar_get_tdbname(cnvtint(c.reqid)))), col 125,
    c.appctx, row + 1
   ENDIF
  FOOT REPORT
   BREAK, "Total requests                   = ", count(c.seq),
   row + 1, "Avg request elapsed time         = ", avg(cnvtreal(ttimer))"######.####",
   row + 1, "Avg request cpu time             = ", avg(cnvtreal(c.timer2))"######.####",
   row + 1, row + 1, "Total requests over              = ",
   count(c.seq
   WHERE cnvtreal(ttimer) > mintime), row + 1, "Avg request elapsed time over    = ",
   avg(cnvtreal(ttimer)
   WHERE cnvtreal(ttimer) > mintime)"######.####", row + 1, "Avg request cpu time over        = ",
   avg(cnvtreal(c.timer2)
   WHERE cnvtreal(c.timer1) > mintime)"######.####", row + 1, row + 1,
   "Total requests under             = ", count(c.seq
   WHERE cnvtreal(c.timer1) < mintime), row + 1,
   "Avg request elapsed time under   = ", avg(cnvtreal(ttimer)
   WHERE cnvtreal(ttimer) < mintime)"######.####", row + 1,
   "Avg request cpu time under       = ", avg(cnvtreal(c.timer2)
   WHERE cnvtreal(c.timer1) < mintime)"######.####", row + 1,
   row + 1
 ;end select
END GO

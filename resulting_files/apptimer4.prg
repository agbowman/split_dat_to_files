CREATE PROGRAM apptimer4
 PAINT
#start
 FREE DEFINE msgview
 DEFINE msgview concat("cer_log:","apptimer.mlg")
 SET startkey = 0
 SET lastkey = 0
 SELECT INTO "nl:"
  m.lastrec
  FROM msgviewhdr m
  WHERE m.key1=1
  DETAIL
   startkey = m.lastrec, lastkey = m.lastrec
  WITH nocounter
 ;end select
 SET mintime = 1.0
 SET appctx = 0
 SET username = fillstring(100," ")
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,22,80)
 CALL line(3,1,80,xhoraz)
 CALL text(2,3,"CPM Application Authorization Server Summary")
 CALL video(n)
 FREE DEFINE crmtimer
 DEFINE crmtimer "cer_log:apptimer.mlg"
 CALL text(5,5,"Output File/Printer/Mine (MINE)? ")
 CALL text(6,5,"Specific Application Number? ")
 CALL text(7,5,"Specific Username?")
 CALL text(8,5,"Start Log Number? ")
 CALL text(9,5,"Start Date? ")
 CALL text(10,5,"End Date?")
 CALL accept(5,40,"PPPPPPPPP;CU","MINE")
 SET outfile = curaccept
 CALL accept(6,40,"99999999999",0)
 SET appctx = curaccept
 CALL accept(7,40,"XXXXXXXXXXX;CU","*")
 SET username = curaccept
 CALL accept(8,40,"99999999",(startkey - 200))
 SET startkey = curaccept
 CALL accept(8,55,"99999999",lastkey)
 SET lastkey = curaccept
 CALL accept(9,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
 SET startdate = curaccept
 CALL accept(10,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
 SET enddate = curaccept
 SELECT
  a.key1, atime = a.updt_dt_tm"hh:mm:ss;;mm", x = substring(1,50,app.description),
  a.*, app.application_number, p.name_full_formatted
  FROM apptimer a,
   application app,
   dummyt d,
   prsnl p
  PLAN (a
   WHERE a.key1 >= startkey
    AND a.key1 >= 1
    AND a.key1 <= lastkey
    AND a.user=username
    AND ((appctx=0) OR (cnvtint(a.appctx)=appctx))
    AND a.updt_dt_tm >= cnvtdatetime(startdate)
    AND a.updt_dt_tm <= cnvtdatetime(concat(enddate,":24:00:00")))
   JOIN (d)
   JOIN (app
   WHERE app.application_number=cnvtint(a.appctx))
   JOIN (p
   WHERE a.user=p.username)
  ORDER BY a.user, app.application_number
  HEAD REPORT
   totalcnt = 0
  HEAD PAGE
   col 0, "Application Number / Application Description", col 75,
   "page: ", curpage, row + 1,
   col 10, "Username /   Full Name", col 75,
   "Access Counts", row + 1, col 0,
   "-------------------------------------------------------------------------------------------------",
   row + 1
  HEAD a.user
   col 0, a.user, p.name_full_formatted,
   row + 1, usercnt = 0
  HEAD app.application_number
   col 10, app.application_number, col 25,
   x, appcnt = 0
  DETAIL
   usercnt = (usercnt+ 1), appcnt = (appcnt+ 1), totalcnt = (totalcnt+ 1),
   col + 0
  FOOT  app.application_number
   col 80, appcnt, row + 1
  FOOT  a.user
   col 75, "----------------", row + 1,
   col 80, usercnt, row + 2
  FOOT REPORT
   row + 3, col 0, "Total Access:",
   totalcnt, row + 2, col 0,
   "* * *   E N D   O F   R E P O R T   * * * "
  WITH check
 ;end select
END GO

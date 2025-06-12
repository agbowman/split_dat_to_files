CREATE PROGRAM contextreports
 PAINT
#start
 DECLARE appno = i4
 DECLARE tempappstring = c10
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,17,70)
 CALL line(3,1,70,xhoraz)
 CALL box(5,4,14,65)
 CALL video(l)
 CALL text(2,3,"Context Report Parameters")
 CALL text(6,5,"Output File/Printer/Mine (MINE)? ")
 CALL text(7,5,"Application Number (ANY)? ")
 CALL text(8,5,"USERNAME (ANY)?")
 CALL text(9,5,"Start Date? ")
 CALL text(10,5,"End Date? ")
 CALL text(11,5,"Unauthorized Only? ")
 CALL text(16,60,"<PF3> Exit")
 CALL accept(6,40,"PPPPPPPPP;CU","MINE")
 SET outfile = curaccept
 CALL accept(7,40,"XXXXXXXXX","ANY")
 SET tempappstring = cnvtstring(curaccept)
 IF (value(tempappstring)="ANY")
  SET appno = 0
 ELSE
  SET appno = cnvtint(tempappstring)
 ENDIF
 CALL accept(8,40,"XXXXXX;CU","ANY")
 SET usern = curaccept
 CALL accept(9,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
 SET startdate = curaccept
 CALL accept(10,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
 SET enddate = curaccept
 CALL accept(11,40,"X;CU","N")
 SET authind = curaccept
 CALL text(13,5,build("Printing Report to :"," ",outfile))
 CALL video(b)
 CALL text(16,6,"Working...")
 SELECT
  IF ( NOT (appno=0)
   AND usern="ANY"
   AND authind="N")
   WHERE a.application_number=cnvtint(appno)
    AND a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
  ELSEIF ( NOT (appno=0)
   AND usern="ANY"
   AND authind="Y")
   WHERE a.application_number=cnvtint(appno)
    AND a.authorization_ind=0
    AND a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
  ELSEIF (appno=0
   AND  NOT (usern="ANY")
   AND authind="N")
   WHERE a.username=usern
    AND a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
  ELSEIF (appno=0
   AND  NOT (usern="ANY")
   AND authind="Y")
   WHERE a.username=usern
    AND a.authorization_ind=0
    AND a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
  ELSEIF ( NOT (appno=0)
   AND  NOT (usern="ANY")
   AND authind="N")
   WHERE a.username=usern
    AND a.application_number=cnvtint(appno)
    AND a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
  ELSEIF ( NOT (appno=0)
   AND  NOT (usern="ANY")
   AND authind="Y")
   WHERE a.username=usern
    AND a.application_number=cnvtint(appno)
    AND a.authorization_ind=0
    AND a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
  ELSEIF (appno=0
   AND usern="ANY"
   AND authind="N")
   WHERE a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
  ELSEIF (appno=0
   AND usern="ANY"
   AND authind="Y")
   WHERE a.authorization_ind=0
    AND a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
  ELSE
   WHERE a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
  ENDIF
  INTO value(outfile)
  a.username, a.application_number, a.applctx,
  a.application_image, a.device_address, a.tcpip_address,
  a.authorization_ind, a.start_dt_tm, a.name,
  a.end_dt_tm
  FROM application_context a
  ORDER BY a.username, a.application_number, a.applctx
  HEAD PAGE
   col 1, "A P P L I C A T I O N  C O N T E X T   R E P O R T", row + 2,
   col 1, "Time:", col 10,
   curtime"hh:mm;;m", row + 1, col 1,
   "Date:", col 10, curdate"mm/dd/yy;;d",
   row + 2, col 1, "Printer:",
   col 15, outfile, row + 2,
   col 1, "Username", col 44,
   "Application", row + 1, col 1,
   "********************************************************", col 50,
   "********************************************************",
   col 100, "*******************************", row + 1
  HEAD a.username
   row + 0
  HEAD a.application_number
   col 1, "________________________________________________________", col 50,
   "________________________________________________________", col 100,
   "_______________________________",
   row + 2, col 3, a.username,
   col 15, a.name, col 40,
   a.application_number, col 65, a.application_image,
   row + 1, col 10, "Context Number",
   col 28, "Start Date", col 41,
   "Start Time", col 53, "End Date",
   col 64, "End Time", col 77,
   "TCPIP Address", col 102, "Authorization Status",
   row + 1, col 10, "--------------",
   col 28, "----------", col 41,
   "----------", col 53, "--------",
   col 64, "--------", col 77,
   "-------------", col 102, "--------------------",
   row + 1
  DETAIL
   stime = format(a.start_dt_tm,"HH:MM:SS;;M"), etime = format(a.end_dt_tm,"HH:MM:SS;;M"), col 10,
   a.applctx, col 28, a.start_dt_tm,
   col 41, stime, col 53,
   a.end_dt_tm, col 64, etime,
   col 77, a.tcpip_address, col 107,
   a.authorization_ind, row + 1
  FOOT PAGE
   col 1, "Report ID: CONTEXT REPORT                                  ", "Page:",
   curpage"###", "                                          ", "Printed on: ",
   curdate"mm/dd/yy;;d"
  WITH nullreport, nocounter, check,
   maxrow = 63
 ;end select
 CALL video(n)
END GO

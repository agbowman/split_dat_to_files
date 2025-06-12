CREATE PROGRAM appusage
 PAINT
#start
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,19,70)
 CALL box(6,3,14,68)
 CALL line(3,1,70,xhoraz)
 CALL video(l)
 CALL text(2,3,"APPLICATION / USER USAGE UTILITY")
 CALL text(4,3,"Select an audit to run.                                 Choice:")
 CALL text(7,6,"1) Application Summary")
 CALL text(8,6,"2) Request Summary")
 CALL text(9,6,"3) User Summary")
 CALL text(10,6,"4) Current Users")
 CALL text(11,6,"5) Unique Login Summary")
 CALL text(18,59,"<PF3> Exit")
 CALL video(n)
 CALL accept(4,68,"9;d",1)
 SET testtype = curaccept
 CASE (testtype)
  OF 1:
   GO TO appsummary
  OF 2:
   GO TO start
  OF 3:
   GO TO usersummary
  OF 4:
   GO TO currentusers
  OF 5:
   GO TO uniquelogins
  ELSE
   GO TO start
 ENDCASE
#appsummary
 CALL clear(1,1)
 CALL box(1,1,19,70)
 CALL line(3,1,70,xhoraz)
 CALL box(6,3,14,68)
 CALL video(n)
 CALL video(l)
 CALL text(2,3,"APPLICATION USAGE SUMMARY")
 CALL text(4,3,"Select an audit to run.                                  Choice:")
 CALL text(7,6,"1) What applications have been accessed?")
 CALL text(8,6,"2) What applications have not been accessed?")
 CALL text(18,59,"<PF3> Exit")
 CALL video(n)
 CALL accept(4,68,"9;d",1)
 CASE (curscroll)
  OF 0:
   SET testtype = curaccept
  OF 2:
   GO TO appsummary
  OF 3:
   GO TO start
  OF 4:
   GO TO start
  ELSE
   SET dummyval = 1
 ENDCASE
 CASE (testtype)
  OF 1:
   GO TO appsyes
  OF 2:
   CALL clear(1,1)
   GO TO appsno
  ELSE
   GO TO start
 ENDCASE
#appsyes
 DECLARE appno = i4
 DECLARE tempappstring = c10
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,19,70)
 CALL line(3,1,70,xhoraz)
 CALL box(6,3,14,68)
 CALL video(l)
 CALL text(2,3,"Applications Accessed")
 CALL text(7,6,"Output CSV/File/Printer (MINE)? ")
 CALL text(8,6,"Application Number (ANY)? ")
 CALL text(9,6,"USERNAME (ANY)?")
 CALL text(10,6,"Start Date? ")
 CALL text(11,6,"End Date? ")
 CALL text(12,6,"Unauthorized Only? ")
 CALL text(18,59,"<PF3> Exit")
 CALL accept(7,40,"PPPPPPPPP;CU","MINE")
 SET appcnt = 0
 SET totcnt = 0
 CASE (curscroll)
  OF 0:
   SET outfile = curaccept
   CALL accept(8,40,"XXXXXXXXX","ANY")
   SET tempappstring = cnvtstring(curaccept)
   IF (value(tempappstring)="ANY")
    SET appno = 0
   ELSE
    SET appno = cnvtint(tempappstring)
   ENDIF
   CALL accept(9,40,"XXXXXXXXXXXX;CU","ANY")
   SET usern = curaccept
   CALL accept(10,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
   SET startdate = curaccept
   CALL accept(11,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
   SET enddate = curaccept
   CALL accept(12,40,"X;CU","N")
   SET authind = curaccept
   CALL text(13,5,build("Printing Report to :"," ",outfile))
   CALL video(b)
   IF (outfile="CSV")
    GO TO appyescsv
   ENDIF
   CALL text(16,6,"Working...")
   SELECT
    IF ( NOT (appno=0)
     AND trim(usern)="ANY"
     AND authind="N")
     WHERE a.application_number=cnvtint(appno)
      AND a.start_dt_tm >= cnvtdatetime(startdate)
      AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
      AND a.application_number=app.application_number
    ELSEIF ( NOT (appno=0)
     AND trim(usern)="ANY"
     AND authind="Y")
     WHERE a.application_number=cnvtint(appno)
      AND a.authorization_ind=0
      AND a.start_dt_tm >= cnvtdatetime(startdate)
      AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
      AND a.application_number=app.application_number
    ELSEIF (appno=0
     AND  NOT (trim(usern)="ANY")
     AND authind="N")
     WHERE a.username=trim(usern)
      AND a.start_dt_tm >= cnvtdatetime(startdate)
      AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
      AND a.application_number=app.application_number
    ELSEIF (appno=0
     AND  NOT (trim(usern)="ANY")
     AND authind="Y")
     WHERE a.username=trim(usern)
      AND a.authorization_ind=0
      AND a.start_dt_tm >= cnvtdatetime(startdate)
      AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
      AND a.application_number=app.application_number
    ELSEIF ( NOT (appno=0)
     AND  NOT (trim(usern)="ANY")
     AND authind="N")
     WHERE a.username=usern
      AND a.application_number=cnvtint(appno)
      AND a.start_dt_tm >= cnvtdatetime(startdate)
      AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
      AND a.application_number=app.application_number
    ELSEIF ( NOT (appno=0)
     AND  NOT (trim(usern)="ANY")
     AND authind="Y")
     WHERE a.username=usern
      AND a.application_number=cnvtint(appno)
      AND a.authorization_ind=0
      AND a.start_dt_tm >= cnvtdatetime(startdate)
      AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
      AND a.application_number=app.application_number
    ELSEIF (appno=0
     AND trim(usern)="ANY"
     AND authind="N")
     WHERE a.start_dt_tm >= cnvtdatetime(startdate)
      AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
      AND a.application_number=app.application_number
    ELSEIF (appno=0
     AND trim(usern)="ANY"
     AND authind="Y")
     WHERE a.authorization_ind=0
      AND a.start_dt_tm >= cnvtdatetime(startdate)
      AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
      AND a.application_number=app.application_number
    ELSE
     WHERE a.start_dt_tm >= cnvtdatetime(startdate)
      AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
      AND a.application_number=app.application_number
    ENDIF
    INTO value(outfile)
    a.application_number, appdesc = substring(1,70,app.description)
    FROM application_context a,
     application app
    ORDER BY a.application_number
    HEAD REPORT
     col 1, "A P P L I C A T I O N   U S A G E   R E P O R T", row + 2,
     col 1, "Time:", col 10,
     curtime"hh:mm;;m", row + 1, col 1,
     "Date:", col 10, curdate"mm/dd/yy;;d",
     row + 2, col 1, "Printer:",
     col 15, outfile, row + 2,
     col 3, "Applications Accessed Between", col 34,
     startdate, col 47, "00:00:00",
     col 57, "and ", col 62,
     enddate, col 75, "23:59:59",
     row + 1, col 3, "Application",
     col 75, "Number of Logins", row + 1,
     col 1, "********************************************************", col 50,
     "********************************************************", col 100,
     "*******************************",
     row + 1
    HEAD a.application_number
     applogincnt = 0, col 3, a.application_number,
     col 18, appdesc
    DETAIL
     applogincnt = (applogincnt+ 1), totcnt = (totcnt+ 1)
    FOOT  a.application_number
     appcnt = (appcnt+ 1), col 75, applogincnt,
     row + 1
    FOOT REPORT
     row + 1, col 1, "********************************************************",
     col 50, "********************************************************", col 100,
     "*******************************", row + 1, col 1,
     "Total count: ", col 14, appcnt,
     col 75, totcnt, row + 1,
     col 1, "Report ID: USAGE REPORT                                    ", "Page:",
     curpage"###", "                                          ", "Printed on: ",
     curdate"mm/dd/yy;;d"
    WITH nullreport, nocounter, noformfeed,
     check, maxrow = 63
   ;end select
   CALL video(n)
   GO TO start
  OF 1:
   GO TO start
  OF 2:
   GO TO appsyes
  OF 3:
   GO TO appsummary
  OF 4:
   GO TO start
  ELSE
   SET dummyval = 1
 ENDCASE
#appsno
 DECLARE appno = i4
 DECLARE tempappstring = c10
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,19,70)
 CALL line(3,1,70,xhoraz)
 CALL box(6,3,14,68)
 CALL video(l)
 CALL text(2,3,"Applications Not Accessed")
 CALL text(7,6,"Output CSV/File/Printer (MINE)? ")
 CALL text(8,6,"Start Date? ")
 CALL text(9,6,"End Date? ")
 CALL text(18,59,"<PF3> Exit")
 SET appcnt = 0
 CASE (curscroll)
  OF 0:
   CALL accept(7,40,"PPPPPPPPP;CU","MINE")
   SET outfile = curaccept
   CALL accept(8,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
   SET startdate = curaccept
   CALL accept(9,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
   SET enddate = curaccept
   CALL text(13,5,build("Printing Report to :"," ",outfile))
   CALL video(b)
   IF (outfile="CSV")
    GO TO appnocsv
   ENDIF
   CALL text(16,6,"Working...")
   SELECT INTO value(outfile)
    app.application_number, appdesc = substring(1,75,app.description)
    FROM application_context a,
     (dummyt d  WITH seq = 1),
     application app
    PLAN (app)
     JOIN (d)
     JOIN (a
     WHERE a.start_dt_tm >= cnvtdatetime(startdate)
      AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
      AND a.application_number=app.application_number)
    ORDER BY app.application_number
    HEAD REPORT
     col 1, "A P P L I C A T I O N   N E G L E C T   R E P O R T", row + 2,
     col 1, "Time:", col 10,
     curtime"hh:mm;;m", row + 1, col 1,
     "Date:", col 10, curdate"mm/dd/yy;;d",
     row + 2, col 1, "Printer:",
     col 15, outfile, row + 2,
     col 3, "Applications Neglected Between", col 34,
     startdate, col 47, "00:00:00",
     col 57, "and ", col 62,
     enddate, col 75, "23:59:59",
     row + 1, col 1, "********************************************************",
     col 50, "********************************************************", col 100,
     "*******************************", row + 1
    DETAIL
     appcnt = (appcnt+ 1), col 3, app.application_number,
     col 18, appdesc, row + 1
    FOOT REPORT
     row + 1, col 1, "********************************************************",
     col 50, "********************************************************", col 100,
     "*******************************", row + 1, col 1,
     "Total count: ", col 14, appcnt,
     row + 1, col 1, "Report ID: APP NEGLECT REPORT                              ",
     "Page:", curpage"###", "                                          ",
     "Printed on: ", curdate"mm/dd/yy;;d"
    WITH outerjoin = d, dontexist, noformfeed,
     nullreport, nocounter, check,
     maxrow = 63, maxcol = 500
   ;end select
   CALL video(n)
   GO TO start
  OF 2:
   GO TO appsno
  OF 3:
   GO TO appsummary
  OF 4:
   GO TO start
  ELSE
   SET dummyval = 1
 ENDCASE
#usersummary
 CALL clear(1,1)
 CALL box(1,1,19,70)
 CALL line(3,1,70,xhoraz)
 CALL box(6,3,14,68)
 CALL video(n)
 CALL video(l)
 CALL text(2,3,"USER USAGE SUMMARY")
 CALL text(4,3,"Select an audit to run.                                  Choice:")
 CALL text(7,6,"1) What users have logged on?")
 CALL text(8,6,"2) What users have logged on?  What Apps?")
 CALL text(9,6,"3) What users have logged on? (DETAIL)")
 CALL text(10,6,"4) What users have not logged on?")
 CALL text(18,59,"<PF3> Exit")
 CALL video(n)
 CALL accept(4,68,"9;d",1)
 CASE (curscroll)
  OF 0:
   SET testtype = curaccept
  OF 2:
   GO TO usersummary
  OF 3:
   GO TO start
  OF 4:
   GO TO start
  ELSE
   SET dummyval = 1
 ENDCASE
 CASE (testtype)
  OF 1:
   GO TO usersyes
  OF 2:
   GO TO usersapps
  OF 3:
   GO TO usersdetail
  OF 4:
   GO TO usersno
  ELSE
   GO TO start
 ENDCASE
#usersyes
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,19,70)
 CALL line(3,1,70,xhoraz)
 CALL box(6,3,14,68)
 CALL video(l)
 CALL text(2,3,"User Access Report")
 CALL text(7,6,"Output CSV/File/Printer (MINE)? ")
 CALL text(8,6,"USERNAME (ANY)?")
 CALL text(9,6,"Start Date? ")
 CALL text(10,6,"End Date? ")
 CALL text(18,59,"<PF3> Exit")
 SET totcnt = 0
 CASE (curscroll)
  OF 0:
   CALL accept(7,40,"PPPPPPPPP;CU","MINE")
   SET outfile = curaccept
   CALL accept(8,40,"XXXXXXXXXXXX;CU","ANY")
   SET usern = curaccept
   CALL accept(9,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
   SET startdate = curaccept
   CALL accept(10,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
   SET enddate = curaccept
   CALL text(13,5,build("Printing Report to :"," ",outfile))
   CALL video(b)
   SET usercnt = 0
   IF (outfile="CSV")
    GO TO useryescsv
   ENDIF
   CALL text(16,6,"Working...")
   SELECT
    IF (trim(usern)="ANY")
     WHERE a.start_dt_tm >= cnvtdatetime(startdate)
      AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
      AND a.username=p.username
    ELSE
     WHERE a.username=trim(usern)
      AND a.start_dt_tm >= cnvtdatetime(startdate)
      AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
      AND a.username=p.username
    ENDIF
    INTO value(outfile)
    a.username, a.application_number, p.name_full_formatted
    FROM application_context a,
     prsnl p
    ORDER BY a.username, a.application_number
    HEAD REPORT
     col 1, "U S E R   A C C E S S   R E P O R T", row + 2,
     col 1, "Time:", col 10,
     curtime"hh:mm;;m", row + 1, col 1,
     "Date:", col 10, curdate"mm/dd/yy;;d",
     row + 2, col 1, "Printer:",
     col 15, outfile, row + 2,
     col 2, "User", col 38,
     "Number of Logins", col 64, "Number of Applications",
     row + 1, col 1, "********************************************************",
     col 50, "********************************************************", col 100,
     "*******************************", row + 1
    HEAD a.username
     usercnt = (usercnt+ 1), applogincnt = 0, appcnt = 0
    HEAD a.application_number
     appcnt = (appcnt+ 1)
    DETAIL
     applogincnt = (applogincnt+ 1)
    FOOT  a.username
     col 3, a.username, col 18,
     p.name_full_formatted, col 44, applogincnt,
     col 64, appcnt, row + 1
    FOOT REPORT
     row + 1, col 1, "********************************************************",
     col 50, "********************************************************", col 100,
     "*******************************", row + 1, col 1,
     "User count: ", col 14, usercnt,
     row + 1, col 1, "Report ID: USER ACCESS REPORT                            ",
     "Page:", curpage"###", "                                          ",
     "Printed on: ", curdate"mm/dd/yy;;d"
    WITH nullreport, nocounter, noformfeed,
     check, maxrow = 63
   ;end select
   CALL video(n)
   GO TO start
  OF 2:
   GO TO usersyes
  OF 3:
   GO TO usersummary
  OF 4:
   GO TO start
  ELSE
   SET dummyval = 1
 ENDCASE
#usersapps
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,19,70)
 CALL line(3,1,70,xhoraz)
 CALL box(6,3,14,68)
 CALL video(l)
 CALL text(2,3,"User Access Report - Applications")
 CALL text(7,6,"Output CSV/File/Printer (MINE)? ")
 CALL text(8,6,"USERNAME (ANY)?")
 CALL text(9,6,"Start Date? ")
 CALL text(10,6,"End Date? ")
 CALL text(18,59,"<PF3> Exit")
 SET usercnt = 0
 CASE (curscroll)
  OF 0:
   CALL accept(7,40,"PPPPPPPPP;CU","MINE")
   SET outfile = curaccept
   CALL accept(8,40,"XXXXXXXXXXXX;CU","ANY")
   SET usern = curaccept
   CALL accept(9,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
   SET startdate = curaccept
   CALL accept(10,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
   SET enddate = curaccept
   CALL text(13,5,build("Printing Report to :"," ",outfile))
   CALL video(b)
   IF (outfile="CSV")
    GO TO userappscsv
   ENDIF
   CALL text(16,6,"Working...")
   SELECT
    IF (trim(usern)="ANY")
     WHERE a.start_dt_tm >= cnvtdatetime(startdate)
      AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
      AND a.application_number=app.application_number
      AND a.username=p.username
    ELSE
     WHERE a.username=trim(usern)
      AND a.start_dt_tm >= cnvtdatetime(startdate)
      AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
      AND a.application_number=app.application_number
      AND a.username=p.username
    ENDIF
    INTO value(outfile)
    a.username, a.application_number, appdesc = substring(1,30,app.description),
    p.name_full_formatted
    FROM application_context a,
     application app,
     prsnl p
    PLAN (a)
     JOIN (p)
    ORDER BY a.username, a.application_number
    HEAD REPORT
     col 1, "U S E R   A C C E S S   R E P O R T  -  A P P L I C A T I O N S", row + 2,
     col 1, "Time:", col 10,
     curtime"hh:mm;;m", row + 1, col 1,
     "Date:", col 10, curdate"mm/dd/yy;;d",
     row + 2, col 1, "Printer:",
     col 15, outfile, row + 2,
     col 2, "User", col 38,
     "Application", col 85, "Number of Logins",
     row + 1, col 1, "********************************************************",
     col 50, "********************************************************", col 100,
     "*******************************", row + 1
    HEAD a.username
     usercnt = (usercnt+ 1), col 3, a.username,
     col 18, p.name_full_formatted
    HEAD a.application_number
     applogincnt = 0, col 38, a.application_number,
     col 53, appdesc
    DETAIL
     applogincnt = (applogincnt+ 1)
    FOOT  a.application_number
     col 90, applogincnt, row + 1
    FOOT REPORT
     row + 1, col 1, "********************************************************",
     col 50, "********************************************************", col 100,
     "*******************************", row + 1, col 1,
     "User count: ", col 14, usercnt,
     row + 1, col 1, "Report ID: USER ACCESS REPORT APPLICATIONS                 ",
     "Page:", curpage"###", "                                          ",
     "Printed on: ", curdate"mm/dd/yy;;d"
    WITH nullreport, nocounter, noformfeed,
     check, maxrow = 63
   ;end select
   CALL video(n)
   GO TO start
  OF 2:
   GO TO usersyes
  OF 3:
   GO TO usersummary
  OF 4:
   GO TO start
  ELSE
   SET dummyval = 1
 ENDCASE
#usersdetail
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,19,70)
 CALL line(3,1,70,xhoraz)
 CALL box(6,3,14,68)
 CALL video(l)
 SET usercnt = 0
 CALL text(2,3,"User Access Report - Detail")
 CALL text(7,6,"Output CSV/File/Printer (MINE)? ")
 CALL text(8,6,"USERNAME (ANY)?")
 CALL text(9,6,"Start Date? ")
 CALL text(10,6,"End Date? ")
 CALL text(18,59,"<PF3> Exit")
 CASE (curscroll)
  OF 0:
   CALL accept(7,40,"PPPPPPPPP;CU","MINE")
   SET outfile = curaccept
   CALL accept(8,40,"XXXXXXXXXXXX;CU","ANY")
   SET usern = curaccept
   CALL accept(9,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
   SET startdate = curaccept
   CALL accept(10,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
   SET enddate = curaccept
   CALL text(13,5,build("Printing Report to :"," ",outfile))
   CALL video(b)
   IF (outfile="CSV")
    GO TO userdetailcsv
   ENDIF
   CALL text(16,6,"Working...")
   SELECT
    IF (trim(usern)="ANY")
     WHERE a.start_dt_tm >= cnvtdatetime(startdate)
      AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
      AND a.application_number=app.application_number
      AND a.username=p.username
    ELSE
     WHERE a.username=trim(usern)
      AND a.start_dt_tm >= cnvtdatetime(startdate)
      AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
      AND a.application_number=app.application_number
      AND a.username=p.username
    ENDIF
    INTO value(outfile)
    a.username, a.application_number, appdesc = substring(1,30,app.description),
    p.name_full_formatted
    FROM application_context a,
     application app,
     prsnl p
    PLAN (a)
     JOIN (p)
    ORDER BY a.username, a.application_number
    HEAD REPORT
     col 1, "U S E R   A C C E S S   R E P O R T  -  D E T A I L E D", row + 2,
     col 1, "Time:", col 10,
     curtime"hh:mm;;m", row + 1, col 1,
     "Date:", col 10, curdate"mm/dd/yy;;d",
     row + 2, col 1, "Printer:",
     col 15, outfile, row + 2,
     col 2, "User", col 38,
     "Application", col 80, "Started",
     col 100, "Ended", row + 1,
     col 1, "********************************************************", col 50,
     "********************************************************", col 100,
     "*******************************",
     row + 1
    DETAIL
     usercnt = (usercnt+ 1), starttime = format(a.start_dt_tm,"HH:MM:SS"), endtime = format(a
      .end_dt_tm,"HH:MM:SS"),
     col 3, a.username, col 18,
     p.name_full_formatted, col 36, a.application_number,
     col 48, appdesc, col 80,
     a.start_dt_tm, col 90, starttime,
     col 100, a.end_dt_tm, col 110,
     endtime, row + 1
    FOOT REPORT
     row + 1, col 1, "********************************************************",
     col 50, "********************************************************", col 100,
     "*******************************", row + 1, col 1,
     "Login count: ", col 14, usercnt,
     row + 1, col 1, "Report ID: USER ACCESS REPORT DETAILED                 ",
     "Page:", curpage"###", "                                          ",
     "Printed on: ", curdate"mm/dd/yy;;d"
    WITH nullreport, noformfeed, nocounter,
     check, maxrow = 63
   ;end select
   CALL video(n)
   GO TO start
  OF 2:
   GO TO usersyes
  OF 3:
   GO TO usersummary
  OF 4:
   GO TO start
  ELSE
   SET dummyval = 1
 ENDCASE
#usersno
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,19,70)
 CALL line(3,1,70,xhoraz)
 CALL box(6,3,14,68)
 CALL video(l)
 SET usercnt = 0
 CALL text(2,3,"User No-Access Report")
 CALL text(7,6,"Output CSV/File/Printer (MINE)? ")
 CALL text(8,6,"Start Date? ")
 CALL text(9,6,"End Date? ")
 CALL text(18,59,"<PF3> Exit")
 CASE (curscroll)
  OF 0:
   CALL accept(7,40,"PPPPPPPPP;CU","MINE")
   SET outfile = curaccept
   CALL accept(8,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
   SET startdate = curaccept
   CALL accept(9,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
   SET enddate = curaccept
   CALL text(13,5,build("Printing Report to :"," ",outfile))
   CALL video(b)
   IF (outfile="CSV")
    GO TO usernocsv
   ENDIF
   CALL text(16,6,"Working...")
   SELECT INTO value(outfile)
    p.username, namefull = substring(1,50,p.name_full_formatted)
    FROM application_context a,
     (dummyt d  WITH seq = 1),
     prsnl p
    PLAN (p)
     JOIN (d)
     JOIN (a
     WHERE a.start_dt_tm >= cnvtdatetime(startdate)
      AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
      AND a.username=p.username
      AND concat(trim(p.username),"0") > "0"
      AND p.active_ind=1)
    ORDER BY p.username
    HEAD REPORT
     col 1, "U S E R   N O-A C C E S S   R E P O R T", row + 2,
     col 1, "Time:", col 10,
     curtime"hh:mm;;m", row + 1, col 1,
     "Date:", col 10, curdate"mm/dd/yy;;d",
     row + 2, col 1, "Printer:",
     col 15, outfile, row + 2,
     col 2, "Users with no-access between ", col 31,
     startdate, col 44, "00:00:00",
     col 54, "and ", col 59,
     enddate, col 72, "23:59:59",
     row + 1, col 3, "Person ID",
     col 20, "UserName", col 40,
     "Name", row + 1, col 1,
     "********************************************************", col 50,
     "********************************************************",
     col 100, "*******************************", row + 1
    DETAIL
     usercnt = (usercnt+ 1), col 3, p.person_id,
     col 20, p.username, col 40,
     namefull, row + 1
    FOOT PAGE
     row + 1, col 1, "********************************************************",
     col 50, "********************************************************", col 100,
     "*******************************", row + 1, col 1,
     "User count: ", col 14, usercnt,
     row + 1, col 1, "Report ID: USER NO-ACCESS REPORT                            ",
     "Page:", curpage"###", "                                          ",
     "Printed on: ", curdate"mm/dd/yy;;d"
    WITH outerjoin = d, dontexist, noformfeed,
     nullreport, nocounter, check,
     maxrow = 63
   ;end select
   CALL video(n)
   GO TO start
  OF 2:
   GO TO usersno
  OF 3:
   GO TO usersummary
  OF 4:
   GO TO start
  ELSE
   SET dummyval = 1
 ENDCASE
#currentusers
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,19,70)
 CALL line(3,1,70,xhoraz)
 CALL box(6,3,14,68)
 CALL video(l)
 CALL text(2,3,"Current User Report")
 CALL text(7,6,"Output File/Printer (MINE)? ")
 CALL text(8,6,"Application (ALL)? ")
 CALL text(18,59,"<PF3> Exit")
 CASE (curscroll)
  OF 0:
   CALL accept(7,40,"PPPPPPPPP;CU","MINE")
   SET outfile = curaccept
   CALL accept(8,40,"XXXXXXXXX","ANY")
   SET tempappstring = cnvtstring(curaccept)
   IF (value(tempappstring)="ANY")
    SET appno = 0
   ELSE
    SET appno = cnvtint(tempappstring)
   ENDIF
   CALL text(13,5,build("Printing Report to :"," ",outfile))
   CALL video(b)
   CALL text(16,6,"Working...")
   SELECT
    IF (appno=0)
     a.username, a.application_number, appdesc = substring(1,30,app.description),
     a.start_dt_tm, p.name_full_formatted
     FROM application_context a,
      application app,
      prsnl p
     WHERE a.end_dt_tm=null
      AND a.application_number=app.application_number
      AND a.username=p.username
      AND a.start_dt_tm >= cnvtdatetime(curdate,0)
    ELSE
     a.username, a.application_number, appdesc = substring(1,30,app.description),
     a.start_dt_tm, p.name_full_formatted
     FROM application_context a,
      application app,
      prsnl p
     WHERE a.end_dt_tm=null
      AND a.application_number=app.application_number
      AND a.username=p.username
      AND a.start_dt_tm >= cnvtdatetime(curdate,0)
      AND a.application_number=appno
    ENDIF
    INTO value(outfile)
    ORDER BY a.username, a.application_number, a.start_dt_tm
    HEAD REPORT
     col 1, "C U R R E N T  U S E R   R E P O R T", row + 2,
     col 1, "Time:", col 10,
     curtime"hh:mm;;m", row + 1, col 1,
     "Date:", col 10, curdate"mm/dd/yy;;d",
     row + 2, col 1, "Printer:",
     col 15, outfile, row + 2,
     col 2, "User", col 38,
     "Application", col 85, "Start Date",
     row + 1, col 1, "********************************************************",
     col 50, "********************************************************", col 100,
     "*******************************", row + 1
    HEAD a.application_number
     dummyval = 1
    FOOT  a.username
     stime = format(a.start_dt_tm,"HH:MM:SS;;M"), col 3, a.username,
     col 18, p.name_full_formatted, col 38,
     a.application_number, col 53, appdesc,
     col 85, a.start_dt_tm, col 94,
     stime, row + 1
    FOOT REPORT
     col 1, "Report ID: CURRENT USER REPORT                            ", "Page:",
     curpage"###", "                                          ", "Printed on: ",
     curdate"mm/dd/yy;;d"
    WITH nullreport, nocounter, check,
     maxrow = 63
   ;end select
   CALL video(n)
   GO TO start
  OF 2:
   GO TO currentusers
  OF 3:
   GO TO start
  OF 4:
   GO TO start
  ELSE
   SET dummyval = 1
 ENDCASE
#uniquelogins
 CALL video(b)
 CALL text(16,6,"Working...")
 SET cnt = 0
 RECORD ctxdates(
   1 qual[*]
     2 start_dt_tm = dq8
 )
 SELECT DISTINCT INTO "nl:"
  justdate = format(a.start_dt_tm,"MM/DD/YYYY")
  FROM application_context a
  ORDER BY justdate, 0
  DETAIL
   CALL echo(build("date:",a.start_dt_tm)),
   CALL echo(build("just:",justdate)), cnt = (cnt+ 1),
   stat = alterlist(ctxdates->qual,(cnt+ 1)), ctxdates->qual[cnt].start_dt_tm = a.start_dt_tm
  WITH nocounter
 ;end select
 SET datecnt = size(ctxdates->qual,5)
 CALL video(n)
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,19,70)
 CALL line(3,1,70,xhoraz)
 CALL box(6,3,14,68)
 CALL video(l)
 CALL text(2,3,"Unique Login Report")
 CALL text(5,3,"There are ")
 CALL text(5,13,concat(trim(cnvtstring((datecnt - 1))),
   " unique days of data in the APPLICATION_CONTEXT table."))
 CALL text(8,6,"Start Date? ")
 CALL text(9,6,"End Date? ")
 CALL text(7,6,"Output CSV/File/Printer (MINE)? ")
 CALL text(18,59,"<PF3> Exit")
 CASE (curscroll)
  OF 0:
   CALL accept(7,40,"PPPPPPPPP;CU","MINE")
   SET outfile = curaccept
   CALL accept(8,40,"NNDCCCDNNNN;C",format(ctxdates->qual[1].start_dt_tm,"DD-MMM-YYYY;;D"))
   SET startdate = curaccept
   CALL accept(9,40,"NNDCCCDNNNN;C",format(ctxdates->qual[(datecnt - 1)].start_dt_tm,"DD-MMM-YYYY;;D"
     ))
   SET enddate = curaccept
   CALL text(13,5,build("Printing Report to :"," ",outfile))
   CALL video(b)
   SET uniquelogincnt = 0
   IF (outfile="CSV")
    GO TO uniquelogincsv
   ENDIF
   CALL text(16,6,"Working...")
   SELECT INTO value(outfile)
    a.app_ctx_id, justdate = format(a.start_dt_tm,"MM/DD/YYYY")
    FROM application_context a
    WHERE a.start_dt_tm >= cnvtdatetime(startdate)
     AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
    ORDER BY justdate, 0
    HEAD PAGE
     col 1, "U N I Q U E  L O G I N  R E P O R T", row + 2,
     col 1, "Time:", col 10,
     curtime"hh:mm;;m", row + 1, col 1,
     "Date:", col 10, curdate"mm/dd/yy;;d",
     row + 2, col 1, "Printer:",
     col 15, outfile, row + 2,
     col 2, "Date", col 35,
     "Number of Logins", row + 1, col 1,
     "********************************************************", col 50,
     "********************************************************",
     col 100, "*******************************", row + 1
    HEAD justdate
     uniquelogincnt = 0, col 3, justdate
    DETAIL
     uniquelogincnt = (uniquelogincnt+ 1)
    FOOT  justdate
     col 35, uniquelogincnt, row + 1
    FOOT PAGE
     col 1, "Report ID: UNIQUE LOGIN REPORT                            ", "Page:",
     curpage"###", "                                          ", "Printed on: ",
     curdate"mm/dd/yy;;d"
    WITH nullreport, nocounter, check,
     maxrow = 63
   ;end select
   CALL video(n)
   GO TO start
  OF 2:
   GO TO uniquelogins
  OF 3:
   GO TO start
  OF 4:
   GO TO start
  ELSE
   SET dummyval = 1
 ENDCASE
#appyescsv
 CALL text(16,6,"Writing AppUsage.CSV")
 SELECT
  IF ( NOT (appno=0)
   AND trim(usern)="ANY"
   AND authind="N")
   WHERE a.application_number=cnvtint(appno)
    AND a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
    AND a.application_number=app.application_number
  ELSEIF ( NOT (appno=0)
   AND trim(usern)="ANY"
   AND authind="Y")
   WHERE a.application_number=cnvtint(appno)
    AND a.authorization_ind=0
    AND a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
    AND a.application_number=app.application_number
  ELSEIF (appno=0
   AND  NOT (trim(usern)="ANY")
   AND authind="N")
   WHERE a.username=usern
    AND a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
    AND a.application_number=app.application_number
  ELSEIF (appno=0
   AND  NOT (trim(usern)="ANY")
   AND authind="Y")
   WHERE a.username=usern
    AND a.authorization_ind=0
    AND a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
    AND a.application_number=app.application_number
  ELSEIF ( NOT (appno=0)
   AND  NOT (trim(usern)="ANY")
   AND authind="N")
   WHERE a.username=usern
    AND a.application_number=cnvtint(appno)
    AND a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
    AND a.application_number=app.application_number
  ELSEIF ( NOT (appno=0)
   AND  NOT (trim(usern)="ANY")
   AND authind="Y")
   WHERE a.username=usern
    AND a.application_number=cnvtint(appno)
    AND a.authorization_ind=0
    AND a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
    AND a.application_number=app.application_number
  ELSEIF (appno=0
   AND trim(usern)="ANY"
   AND authind="N")
   WHERE a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
    AND a.application_number=app.application_number
  ELSEIF (appno=0
   AND trim(usern)="ANY"
   AND authind="Y")
   WHERE a.authorization_ind=0
    AND a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
    AND a.application_number=app.application_number
  ELSE
   WHERE a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
    AND a.application_number=app.application_number
  ENDIF
  INTO value("AppUsage.CSV")
  a.application_number, appdesc = substring(1,70,app.description)
  FROM application_context a,
   application app
  ORDER BY a.application_number
  HEAD REPORT
   x = concat("AppNumber",",","AppDesc",",","Count"), col 0, x,
   row + 1
  HEAD a.application_number
   applogincnt = 0
  DETAIL
   applogincnt = (applogincnt+ 1)
  FOOT  a.application_number
   csvstring = concat(trim(cnvtstring(a.application_number)),",",trim(appdesc),",",trim(cnvtstring(
      applogincnt))), col 0, csvstring,
   row + 1
  WITH nocounter, noformfeed, check,
   format = variable
 ;end select
 CALL video(n)
 GO TO start
#appnocsv
 CALL text(16,6,"Writing AppsNotUsed.csv...")
 SELECT INTO value("AppsNotUsed.csv")
  app.application_number, appdesc = substring(1,75,app.description)
  FROM application_context a,
   (dummyt d  WITH seq = 1),
   application app
  PLAN (app)
   JOIN (d)
   JOIN (a
   WHERE a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
    AND a.application_number=app.application_number)
  ORDER BY app.application_number
  HEAD REPORT
   x = concat("AppNum",",","AppDesc"), col 0, x,
   row + 1
  DETAIL
   y = concat(trim(cnvtstring(app.application_number)),",",trim(appdesc)), col 0, y,
   row + 1
  WITH outerjoin = d, dontexist, nocounter,
   noformfeed, check, format = variable
 ;end select
 CALL video(n)
 GO TO start
#useryescsv
 CALL text(16,6,"Writing UserAccess.CSV...")
 SELECT
  IF (trim(usern)="ANY")
   WHERE a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
    AND a.username=p.username
  ELSE
   WHERE a.username=usern
    AND a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
    AND a.username=p.username
  ENDIF
  INTO value("UserAccess.CSV")
  a.username, a.application_number, p.name_full_formatted
  FROM application_context a,
   prsnl p
  ORDER BY a.username, a.application_number
  HEAD REPORT
   x = concat("Username",",","Name",",","Logins",
    ",","Applications"), col 0, x,
   row + 1
  HEAD a.username
   applogincnt = 0, appcnt = 0
  HEAD a.application_number
   appcnt = (appcnt+ 1)
  DETAIL
   applogincnt = (applogincnt+ 1)
  FOOT  a.username
   y = concat(trim(a.username),",",trim(p.name_full_formatted),",",trim(cnvtstring(applogincnt)),
    ",",trim(cnvtstring(appcnt))), col 0, y,
   row + 1
  WITH nocounter, maxcol = 500, noformfeed,
   check, format = variable
 ;end select
 CALL video(n)
 GO TO start
#userappscsv
 CALL text(16,6,"Writing UserApps.CSV...")
 SELECT
  IF (trim(usern)="ANY")
   WHERE a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
    AND a.application_number=app.application_number
    AND a.username=p.username
  ELSE
   WHERE a.username=usern
    AND a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
    AND a.application_number=app.application_number
    AND a.username=p.username
  ENDIF
  INTO value("UserApps.csv")
  a.username, a.application_number, appdesc = substring(1,30,app.description),
  p.name_full_formatted
  FROM application_context a,
   application app,
   prsnl p
  ORDER BY a.username, a.application_number
  HEAD REPORT
   x = concat("Username",",","Name",",","AppNum",
    ",","AppDesc",",","AppCount"), col 0, x,
   row + 1
  HEAD a.username
   unamedummycnt = 0
  HEAD a.application_number
   applogincnt = 0
  DETAIL
   applogincnt = (applogincnt+ 1)
  FOOT  a.application_number
   y = concat(trim(a.username),",",trim(p.name_full_formatted),",",trim(cnvtstring(a
      .application_number)),
    ",",trim(appdesc),",",trim(cnvtstring(applogincnt))), col 0, y,
   row + 1
  WITH nocounter, maxcol = 500, noformfeed,
   check, format = variable
 ;end select
 CALL video(n)
 GO TO start
#userdetailcsv
 CALL text(16,6,"Writing UserDetail.CSV...")
 SELECT
  IF (trim(usern)="ANY")
   WHERE a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
    AND a.application_number=app.application_number
    AND a.username=p.username
  ELSE
   WHERE a.username=usern
    AND a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
    AND a.application_number=app.application_number
    AND a.username=p.username
  ENDIF
  INTO value("UserDetail.CSV")
  a.username, a.application_number, appdesc = substring(1,30,app.description),
  p.name_full_formatted
  FROM application_context a,
   application app,
   prsnl p
  PLAN (a)
   JOIN (p)
  ORDER BY a.username, a.application_number
  HEAD REPORT
   x = concat("User",",","Name",",","AppNum",
    ",","AppDesc",",","StartDt",",",
    "StartTime",",","EndDate",",","EndTime"), col 0, x,
   row + 1
  DETAIL
   starttime = format(a.start_dt_tm,"HH:MM:SS"), endtime = format(a.end_dt_tm,"HH:MM:SS"), y = concat
   (trim(a.username),",",trim(p.name_full_formatted),",",trim(cnvtstring(a.application_number)),
    ",",trim(appdesc),",",trim(cnvtstring(a.start_dt_tm)),",",
    starttime,",",trim(cnvtstring(a.end_dt_tm)),",",endtime),
   col 0, y, row + 1
  WITH nocounter, maxcol = 500, noformfeed,
   check, format = variable
 ;end select
 CALL video(n)
 GO TO start
#usernocsv
 CALL text(16,6,"Writing UserNeglect.CSV...")
 SELECT INTO value("UserNeglect.CSV")
  p.username, namefull = substring(1,50,p.name_full_formatted)
  FROM application_context a,
   (dummyt d  WITH seq = 1),
   prsnl p
  PLAN (p)
   JOIN (d)
   JOIN (a
   WHERE a.start_dt_tm >= cnvtdatetime(startdate)
    AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
    AND a.username=p.username
    AND concat(trim(p.username),"0") > "0"
    AND p.active_ind=1)
  ORDER BY p.username
  HEAD REPORT
   x = concat("Person_Id",",","Username",",","Name"), col 0, x,
   row + 1
  DETAIL
   y = trim(concat(trim(cnvtstring(p.person_id)),",",trim(p.username),",",trim(namefull))), col 0, y,
   row + 1
  WITH outerjoin = d, dontexist, maxcol = 500,
   nocounter, check, noformfeed
 ;end select
 CALL video(n)
 GO TO start
#uniquelogincsv
 CALL text(16,6,"Writing UniqueLogin.CSV...")
 SELECT INTO value("UniqueLogin.CSV")
  a.app_ctx_id, justdate = format(a.start_dt_tm,"MM/DD/YYYY")
  FROM application_context a
  WHERE a.start_dt_tm >= cnvtdatetime(startdate)
   AND a.start_dt_tm <= datetimeadd(cnvtdatetime(enddate),1)
  ORDER BY justdate, 0
  HEAD REPORT
   x = concat("Date",",","Login_Count"), col 0, x,
   row + 1
  HEAD justdate
   uniquelogincnt = 0
  DETAIL
   uniquelogincnt = (uniquelogincnt+ 1)
  FOOT  justdate
   y = concat(trim(justdate),",",trim(cnvtstring(uniquelogincnt))), col 0, y,
   row + 1
  WITH nocounter, maxcol = 500, noformfeed,
   check, format = variable
 ;end select
 CALL video(n)
 GO TO start
END GO

CREATE PROGRAM cs_stat:dba
 PAINT
 SET width = 132
 SET modify = system
 DECLARE swhereclause = vc
 DECLARE sparseclause = vc
 DECLARE dchartreqid = f8 WITH noconstant(0.0)
 DECLARE ddistid = f8 WITH noconstant(0.0)
 DECLARE bsuccessonly = i2
 DECLARE bsummaryonly = i2
 DECLARE dtotalpages = f8
 DECLARE dadhocpages = f8
 DECLARE dexpeditepages = f8
 DECLARE ddistpages = f8
 DECLARE dmrppages = f8
 DECLARE dtotalproctime = f8
 DECLARE dadhocproctime = f8
 DECLARE dexpediteproctime = f8
 DECLARE ddistproctime = f8
 DECLARE dmrpproctime = f8
 DECLARE dnumcharts = f8
 DECLARE dnumadhoccharts = f8
 DECLARE dnumexpeditecharts = f8
 DECLARE dnumdistcharts = f8
 DECLARE dnummrpcharts = f8
 DECLARE daverage = f8
 DECLARE sbegindate = c11
 DECLARE sbegintime = c5
 DECLARE sbegindatetime = c17 WITH noconstant("01-Jan-1800 00:00")
 DECLARE senddate = c11
 DECLARE sendtime = c5
 DECLARE senddatetime = c17 WITH noconstant("31-Dec-2100 00:00")
 DECLARE sservername = c20
 DECLARE norderseq = i4
 DECLARE dunprocesscd = f8
 DECLARE dinprocesscd = f8
 DECLARE dsuccesscd = f8
 SET dunprocesscd = uar_get_code_by("MEANING",18609,"UNPROCESSED")
 SET dinprocesscd = uar_get_code_by("MEANING",18609,"INPROCESS")
 SET dsuccesscd = uar_get_code_by("MEANING",18609,"SUCCESSFUL")
#start_main
 CALL clear(1,1)
 CALL box(2,1,23,79)
 CALL text(1,25,"Chart Server Statistics Viewer")
 CALL text(3,2,"  Enter Chart Request ID or Enter 0")
 CALL accept(3,48,"P(16);C","0")
 SET dchartreqid = cnvtreal(curaccept)
 IF (dchartreqid=0)
  CALL text(5,2,"  Enter Distribution Id or leave empty")
  CALL text(6,2,"  Shift/F5 to see a list of Distribution Ids")
  SET help =
  SELECT DISTINCT INTO "nl:"
   cd.distribution_id
   FROM chart_distribution cd
   WHERE cd.active_ind=1
   WITH nocounter
  ;end select
  CALL accept(6,48,"P(16);C","0")
  SET ddistid = cnvtreal(curaccept)
  SET help = off
  CALL text(8,2,"  View only Successful chart request? (Y/N)")
  CALL accept(8,48,"P(1);C","Y"
   WHERE curaccept IN ("Y", "y", "N", "n"))
  IF (curaccept IN ("Y", "y"))
   SET bsuccessonly = 1
  ELSE
   SET bsuccessonly = 0
  ENDIF
 ENDIF
 FREE RECORD servers
 RECORD servers(
   1 ncount = i4
   1 qual[*]
     2 sservername = c20
     2 dtotalpages = i4
     2 dtotalproctime = f8
     2 dnumcharts = i4
 )
 CALL text(9,10," Working......")
 SELECT DISTINCT INTO "nl:"
  cr.server_name
  FROM chart_request cr
  HEAD REPORT
   nservercnt = 0
  DETAIL
   IF (trim(cr.server_name) != null)
    nservercnt = (nservercnt+ 1), stat = alterlist(servers->qual,nservercnt), servers->qual[
    nservercnt].sservername = trim(cr.server_name)
   ENDIF
  FOOT REPORT
   servers->ncount = nservercnt
  WITH nocounter
 ;end select
 CALL text(9,10,"              ")
 IF (dchartreqid=0)
  CALL text(10,2,"  Enter Server Name or leave blank")
  CALL text(11,2,"  Shift/f5 to see a list of server names")
  SET help =
  SELECT INTO "nl:"
   substring(1,20,servers->qual[d1.seq].sservername)
   FROM (dummyt d1  WITH seq = value(servers->ncount))
   PLAN (d1)
   WITH nocounter
  ;end select
  CALL accept(11,48,"P(20);C","                   ")
  SET help = off
  SET sservername = cnvtupper(trim(curaccept))
  CALL text(12,20,sservername)
  CALL text(13,4,"Enter a date/time range")
  CALL text(14,4,"Begin Date: ")
  CALL text(15,4,"Begin Time: ")
  CALL accept(14,48,"nndpppdnnnn;cs",format(curdate,"dd-mmm-yyyy;;d"))
  SET sbegindate = curaccept
  CALL accept(15,48,"hh:mm;cs","00:00")
  SET sbegintime = curaccept
  SET sbegindatetime = concat(trim(sbegindate)," ",trim(sbegintime))
  CALL text(17,4,"End Date: ")
  CALL text(18,4,"End Time: ")
  CALL accept(17,48,"nndpppdnnnn;cs",format(curdate,"dd-mmm-yyyy;;d"))
  SET senddate = curaccept
  CALL accept(18,48,"hh:mm;cs",format(cnvtdatetime(curdate,curtime),"hh:mm;;m"))
  SET sendtime = curaccept
  SET senddatetime = concat(trim(senddate)," ",trim(sendtime))
  CALL text(20,2,"  Sort by (1)Request_id, (2)last updt, (3)process time?")
  CALL accept(20,60,"9;",1
   WHERE curaccept IN (1, 2, 3))
  SET norderseq = curaccept
  CALL text(22,2,"  Display summary only? (Y/N)")
  CALL accept(22,48,"P(1);C","Y"
   WHERE curaccept IN ("Y", "y", "N", "n"))
  IF (curaccept IN ("Y", "y"))
   SET bsummaryonly = 1
  ELSE
   SET bsummaryonly = 0
  ENDIF
 ENDIF
 CALL text(22,60," Working......")
 IF (bsuccessonly=0)
  SET swhereclause = "cr.chart_status_cd+0 not in (dUnprocessCd, dInprocessCd)"
 ELSE
  SET swhereclause = "cr.chart_status_cd+0 = dSuccessCd"
 ENDIF
 IF (dchartreqid > 0)
  SET swhereclause = concat(swhereclause," and cr.chart_request_id = dChartReqId")
 ENDIF
 IF (ddistid > 0)
  SET swhereclause = concat(swhereclause," and cr.distribution_id = dDistId")
 ENDIF
 IF (trim(sservername) != null)
  SET swhereclause = concat(swhereclause," and cr.server_name = trim(sServerName,3)")
 ENDIF
 SET swhereclause = concat(swhereclause,
  " and cr.request_dt_tm between cnvtdatetime(sBeginDateTime) and cnvtdatetime(sEndDateTime)")
 SET dtotalpages = 0.0
 SET dadhocpages = 0.0
 SET dexpeditepages = 0.0
 SET ddistpages = 0.0
 SET dmrppages = 0.0
 SET dtotalproctime = 0.0
 SET dadhocproctime = 0.0
 SET dexpediteproctime = 0.0
 SET ddistproctime = 0.0
 SET dmrpproctime = 0.0
 SET dnumcharts = 0.0
 SET dnumadhoccharts = 0.0
 SET dnumexpeditecharts = 0.0
 SET dnumdistcharts = 0.0
 SET dnummrpcharts = 0.0
 IF (bsummaryonly)
  EXECUTE FROM start_create_sum_report TO end_create_sum_report
 ELSE
  EXECUTE FROM start_create_report TO end_create_report
 ENDIF
 IF (trim(sservername) != null)
  SET sparseclause = "servers->qual[d1.seq].sServerName = sServerName"
 ELSE
  SET sparseclause = "1 = 1"
 ENDIF
 SELECT
  servers->qual[d1.seq].sservername
  FROM (dummyt d1  WITH seq = value(servers->ncount))
  PLAN (d1
   WHERE parser(sparseclause))
  ORDER BY d1.seq
  HEAD REPORT
   col 0, " Current Date/Time:", row + 1,
   col 0, curdate, col 9,
   curtime3, row + 1, col 0,
   "-------------------------------------------------------", col 55,
   "-------------------------------------------------------",
   row + 1,
   CALL center("SERVER SUMMARY",1,120), row + 1,
   col 1,
   CALL print("SERVER"), col 25,
   CALL print("TOTAL CHARTS"), col 39,
   CALL print("TOTAL PAGES"),
   col 52,
   CALL print("TOTAL TIME"), col 64,
   CALL print("Avg Pages/Chart"), col 81,
   CALL print("Avg Time/Chart"),
   col 97,
   CALL print("Avg Time/Page"), row + 1
  HEAD d1.seq
   col 2,
   CALL print(servers->qual[d1.seq].sservername), col 31,
   servers->qual[d1.seq].dnumcharts"######", col 44, servers->qual[d1.seq].dtotalpages"######",
   col 53, servers->qual[d1.seq].dtotalproctime"######.##", daverage = (servers->qual[d1.seq].
   dtotalpages/ servers->qual[d1.seq].dnumcharts),
   col 70, daverage"######.##", daverage = (servers->qual[d1.seq].dtotalproctime/ servers->qual[d1
   .seq].dnumcharts),
   col 86, daverage"######.##", daverage = (servers->qual[d1.seq].dtotalproctime/ servers->qual[d1
   .seq].dtotalpages),
   col 101, daverage"######.##", row + 1
  DETAIL
   do_nothing = 0
  FOOT  d1.seq
   do_nothing = 0
  FOOT REPORT
   col 0, "-------------------------------------------------------", col 55,
   "-------------------------------------------------------", row + 1,
   CALL center("REQUEST TYPE SUMMARY",1,120),
   row + 1, col 1,
   CALL print("REQUEST TYPE"),
   col 25,
   CALL print("TOTAL CHARTS"), col 39,
   CALL print("TOTAL PAGES"), col 52,
   CALL print("TOTAL TIME"),
   col 64,
   CALL print("Avg Pages/Chart"), col 81,
   CALL print("Avg Time/Chart"), col 97,
   CALL print("Avg Time/Page"),
   row + 1, col 2,
   CALL print("ADHOC"),
   col 31, dnumadhoccharts"######", col 44,
   dadhocpages"######", col 53, dadhocproctime"######.##",
   daverage = (dadhocpages/ dnumadhoccharts), col 70, daverage"######.##",
   daverage = (dadhocproctime/ dnumadhoccharts), col 86, daverage"######.##",
   daverage = (dadhocproctime/ dadhocpages), col 101, daverage"######.##",
   row + 1, col 2,
   CALL print("EXPEDITE"),
   col 31, dnumexpeditecharts"######", col 44,
   dexpeditepages"######", col 53, dexpediteproctime"######.##",
   daverage = (dexpeditepages/ dnumexpeditecharts), col 70, daverage"######.##",
   daverage = (dexpediteproctime/ dnumexpeditecharts), col 86, daverage"######.##",
   daverage = (dexpediteproctime/ dexpeditepages), col 101, daverage"######.##",
   row + 1, col 2,
   CALL print("DIST"),
   col 31, dnumdistcharts"######", col 44,
   ddistpages"######", col 53, ddistproctime"######.##",
   daverage = (ddistpages/ dnumdistcharts), col 70, daverage"######.##",
   daverage = (ddistproctime/ dnumdistcharts), col 86, daverage"######.##",
   daverage = (ddistproctime/ ddistpages), col 101, daverage"######.##",
   row + 1, col 2,
   CALL print("MRP"),
   col 31, dnummrpcharts"######", col 44,
   dmrppages"######", col 53, dmrpproctime"######.##",
   daverage = (dmrppages/ dnummrpcharts), col 70, daverage"######.##",
   daverage = (dmrpproctime/ dnummrpcharts), col 86, daverage"######.##",
   daverage = (dmrpproctime/ dmrppages), col 101, daverage"######.##",
   row + 1, col 0, "-------------------------------------------------------",
   col 55, "-------------------------------------------------------", row + 1,
   CALL center("TOTAL SUMMARY",1,120), row + 1, col 25,
   CALL print("TOTAL CHARTS"), col 39,
   CALL print("TOTAL PAGES"),
   col 52,
   CALL print("TOTAL TIME"), col 64,
   CALL print("Avg Pages/Chart"), col 81,
   CALL print("Avg Time/Chart"),
   col 97,
   CALL print("Avg Time/Page"), row + 1,
   col 1,
   CALL print("TOTALS"), col 31,
   dnumcharts"######", col 44, dtotalpages"######",
   col 53, dtotalproctime"######.##", daverage = (dtotalpages/ dnumcharts),
   col 70, daverage"######.##", daverage = (dtotalproctime/ dnumcharts),
   col 86, daverage"######.##", daverage = (dtotalproctime/ dtotalpages),
   col 101, daverage"######.##", row + 1
  WITH nocounter, check, maxcol = 120
 ;end select
 CALL text(5,4,"(C)ontinue or (Q)uit?")
 CALL accept(5,36,"P(1);C","Q"
  WHERE curaccept IN ("Q", "q", "C", "c"))
 IF (curaccept IN ("Q", "q"))
  GO TO end_program
 ELSE
  GO TO start_main
 ENDIF
#end_main
#start_create_report
 SELECT
  IF (norderseq=1)
   cr.*
   FROM chart_request cr,
    code_value cv,
    (dummyt d2  WITH seq = value(servers->ncount))
   PLAN (cr
    WHERE parser(swhereclause))
    JOIN (cv
    WHERE cv.code_value=cr.chart_status_cd)
    JOIN (d2
    WHERE (cr.server_name=servers->qual[d2.seq].sservername))
   ORDER BY cr.chart_request_id DESC
  ELSEIF (norderseq=2)
   cr.*, date1 = cnvtdatetime(cr.request_dt_tm)
   FROM chart_request cr,
    code_value cv,
    (dummyt d2  WITH seq = value(servers->ncount))
   PLAN (cr
    WHERE parser(swhereclause))
    JOIN (cv
    WHERE cv.code_value=cr.chart_status_cd)
    JOIN (d2
    WHERE (cr.server_name=servers->qual[d2.seq].sservername))
   ORDER BY date1 DESC
  ELSE
  ENDIF
  cr.*
  FROM chart_request cr,
   code_value cv,
   (dummyt d2  WITH seq = value(servers->ncount))
  PLAN (cr
   WHERE parser(swhereclause))
   JOIN (cv
   WHERE cv.code_value=cr.chart_status_cd)
   JOIN (d2
   WHERE (cr.server_name=servers->qual[d2.seq].sservername))
  ORDER BY cr.process_time DESC
  HEAD REPORT
   dtotalpages = 0.0, dadhocpages = 0.0, dexpeditepages = 0.0,
   ddistpages = 0.0, dmrppages = 0.0, dtotalproctime = 0.0,
   dadhocproctime = 0.0, dexpediteproctime = 0.0, ddistproctime = 0.0,
   dmrpproctime = 0.0, dnumcharts = 0.0, dnumadhoccharts = 0.0,
   dnumexpeditecharts = 0.0, dnumdistcharts = 0.0, dnummrpcharts = 0.0,
   col 0, " Current Date/Time:", row + 1,
   col 0, curdate, col 9,
   curtime3, row + 1, col 106,
   "", row + 1
  HEAD PAGE
   col 1, "Chart Request", col 20,
   "Request Dt/Tm", col 37, "Pages",
   col 46, "Process Time (Sec)", col 67,
   "Status", col 82, "Server Name",
   row + 1, col 0, "--------------------------------------------------------",
   col 56, "--------------------------------------------------------", row + 1
  DETAIL
   col 0, cr.chart_request_id, col 17,
   cr.request_dt_tm"MM/DD/YY HH:MM:SS", col 41, cr.total_pages"###",
   col 44, cr.process_time, col 67,
   CALL print(cv.cdf_meaning), col 82,
   CALL print(cr.server_name),
   row + 1
   IF (((bsuccessonly=0) OR (cr.total_pages > 0)) )
    dtotalproctime = (dtotalproctime+ cr.process_time)
    CASE (cr.request_type)
     OF 1:
      dadhocproctime = (dadhocproctime+ cr.process_time)
     OF 2:
      dexpediteproctime = (dexpediteproctime+ cr.process_time)
     OF 4:
      ddistproctime = (ddistproctime+ cr.process_time)
     OF 8:
      dmrpproctime = (dmrpproctime+ cr.process_time)
    ENDCASE
    servers->qual[d2.seq].dtotalproctime = (servers->qual[d2.seq].dtotalproctime+ cr.process_time)
   ENDIF
   IF (cr.process_time > 0)
    dtotalpages = (dtotalpages+ cr.total_pages)
    CASE (cr.request_type)
     OF 1:
      dadhocpages = (dadhocpages+ cr.total_pages)
     OF 2:
      dexpeditepages = (dexpeditepages+ cr.total_pages)
     OF 4:
      ddistpages = (ddistpages+ cr.total_pages)
     OF 8:
      dmrppages = (dmrppages+ cr.total_pages)
    ENDCASE
    servers->qual[d2.seq].dtotalpages = (servers->qual[d2.seq].dtotalpages+ cr.total_pages)
   ENDIF
   IF (((bsuccessonly=0) OR (cr.total_pages > 0
    AND cr.process_time > 0)) )
    dnumcharts = (dnumcharts+ 1)
    CASE (cr.request_type)
     OF 1:
      dnumadhoccharts = (dnumadhoccharts+ 1)
     OF 2:
      dnumexpeditecharts = (dnumexpeditecharts+ 1)
     OF 4:
      dnumdistcharts = (dnumdistcharts+ 1)
     OF 8:
      dnummrpcharts = (dnummrpcharts+ 1)
    ENDCASE
    servers->qual[d2.seq].dnumcharts = (servers->qual[d2.seq].dnumcharts+ 1)
   ENDIF
  WITH nocounter, check, maxcol = 120
 ;end select
#end_create_report
#start_create_sum_report
 SELECT INTO "nl:"
  FROM chart_request cr,
   (dummyt d2  WITH seq = value(servers->ncount))
  PLAN (cr
   WHERE parser(swhereclause))
   JOIN (d2
   WHERE (cr.server_name=servers->qual[d2.seq].sservername))
  HEAD REPORT
   dtotalpages = 0.0, dadhocpages = 0.0, dexpeditepages = 0.0,
   ddistpages = 0.0, dmrppages = 0.0, dtotalproctime = 0.0,
   dadhocproctime = 0.0, dexpediteproctime = 0.0, ddistproctime = 0.0,
   dmrpproctime = 0.0, dnumcharts = 0.0, dnumadhoccharts = 0.0,
   dnumexpeditecharts = 0.0, dnumdistcharts = 0.0, dnummrpcharts = 0.0
  DETAIL
   IF (((bsuccessonly=0) OR (cr.total_pages > 0)) )
    dtotalproctime = (dtotalproctime+ cr.process_time)
    CASE (cr.request_type)
     OF 1:
      dadhocproctime = (dadhocproctime+ cr.process_time)
     OF 2:
      dexpediteproctime = (dexpediteproctime+ cr.process_time)
     OF 4:
      ddistproctime = (ddistproctime+ cr.process_time)
     OF 8:
      dmrpproctime = (dmrpproctime+ cr.process_time)
    ENDCASE
    servers->qual[d2.seq].dtotalproctime = (servers->qual[d2.seq].dtotalproctime+ cr.process_time)
   ENDIF
   IF (cr.process_time > 0)
    dtotalpages = (dtotalpages+ cr.total_pages)
    CASE (cr.request_type)
     OF 1:
      dadhocpages = (dadhocpages+ cr.total_pages)
     OF 2:
      dexpeditepages = (dexpeditepages+ cr.total_pages)
     OF 4:
      ddistpages = (ddistpages+ cr.total_pages)
     OF 8:
      dmrppages = (dmrppages+ cr.total_pages)
    ENDCASE
    servers->qual[d2.seq].dtotalpages = (servers->qual[d2.seq].dtotalpages+ cr.total_pages)
   ENDIF
   IF (((bsuccessonly=0) OR (cr.total_pages > 0
    AND cr.process_time > 0)) )
    dnumcharts = (dnumcharts+ 1)
    CASE (cr.request_type)
     OF 1:
      dnumadhoccharts = (dnumadhoccharts+ 1)
     OF 2:
      dnumexpeditecharts = (dnumexpeditecharts+ 1)
     OF 4:
      dnumdistcharts = (dnumdistcharts+ 1)
     OF 8:
      dnummrpcharts = (dnummrpcharts+ 1)
    ENDCASE
    servers->qual[d2.seq].dnumcharts = (servers->qual[d2.seq].dnumcharts+ 1)
   ENDIF
  WITH nocounter, check
 ;end select
#end_create_sum_report
#start_clear_screen
 FOR (x = 3 TO 22)
   CALL clear(x,3,75)
 ENDFOR
#end_clear_screen
#end_program
 FOR (x = 1 TO 24)
   CALL clear(x,1,132)
 ENDFOR
END GO

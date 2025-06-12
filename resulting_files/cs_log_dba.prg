CREATE PROGRAM cs_log:dba
 PAINT
 SET width = 132
 SET modify = system
#initialize
 SET c1 = fillstring(100," ")
 SET c2 = fillstring(100," ")
 SET c3 = fillstring(100," ")
 SET where_clause = fillstring(300," ")
 DECLARE chartreqid = f8 WITH noconstant(0.0)
#start_initial_accepts
 CALL clear(1,1)
 CALL box(2,1,23,79)
 CALL text(1,25,"Chart Server Log Viewer")
 CALL text(4,2,"  Enter Chart Request ID or Enter 0")
 CALL accept(4,48,"P(16);C","0")
 SET chartreqid = cnvtreal(curaccept)
 CALL text(6,2,"  Enter Log Level  (1,2,3,4,5)")
 CALL accept(6,48,"9;",1
  WHERE curaccept IN (1, 2, 3, 4, 5))
 SET loglevel = curaccept
 CALL text(8,2,"  Cummulative log levels  (Y / N)")
 CALL accept(8,48,"P(1);C","Y"
  WHERE curaccept IN ("Y", "y", "N", "n"))
 SET loglevelcum = curaccept
 CALL text(10,2,"  Enter Computer Name or leave blank")
 CALL text(11,2,"  Shift/f5 to see a list of computer names")
 SET help =
 SELECT DISTINCT INTO "nl:"
  cl.server_name
  FROM chart_serv_log cl
  WHERE 1=1
  WITH nocounter
 ;end select
 CALL accept(11,48,"P(30);C","                              ")
 SET help = off
 SET servername = fillstring(30," ")
 SET servername = cnvtupper(trim(curaccept))
 CALL text(13,4,"Enter a date/time range")
 CALL text(14,4,"Begin Date: ")
 CALL text(15,4,"Begin Time: ")
 CALL accept(14,48,"nndpppdnnnn;cs",format(curdate,"dd-mmm-yyyy;;d"))
 SET begindate = curaccept
 CALL accept(15,48,"hh:mm;cs","00:00")
 SET begintime = curaccept
 SET begindatetime = concat(trim(begindate)," ",trim(begintime))
 CALL text(17,4,"End Date: ")
 CALL text(18,4,"End Time: ")
 CALL accept(17,48,"nndpppdnnnn;cs",format(curdate,"dd-mmm-yyyy;;d"))
 SET enddate = curaccept
 CALL accept(18,48,"hh:mm;cs",format(cnvtdatetime(curdate,(curtime+ 10)),"hh:mm;;m"))
 SET endtime = curaccept
 SET enddatetime = concat(trim(enddate)," ",trim(endtime))
 IF (chartreqid > 0)
  SET c1 = " cl.chart_request_id = ChartReqId "
 ELSE
  SET c1 = " 1 = 1 "
 ENDIF
 IF (servername > " ")
  SET c2 = " and cl.server_name = ServerName "
 ELSE
  SET c2 = " and 2 = 2 "
 ENDIF
 SET c3 = " and cl.log_dt_tm between cnvtdatetime(BeginDateTime) and cnvtdatetime(EndDateTime)"
 IF (loglevelcum IN ("Y", "y"))
  SET where_clause = concat(trim(c1)," and cl.log_level <= LogLevel ",trim(c2)," ",trim(c3))
 ELSE
  SET where_clause = concat(trim(c1)," and cl.log_level = LogLevel ",trim(c2)," ",trim(c3))
 ENDIF
 EXECUTE FROM start_create_log TO end_create_log
 GO TO start_initial_accepts
#end_initial_accepts
#start_create_log
 SELECT
  cl.*
  FROM chart_serv_log cl,
   (dummyt d1  WITH seq = 1),
   chart_request cr,
   outputctx o
  PLAN (cl
   WHERE parser(where_clause))
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (cr
   WHERE cr.chart_request_id=cl.chart_request_id)
   JOIN (o
   WHERE o.handle_id=cr.handle_id)
  ORDER BY cl.chart_log_num DESC
  HEAD REPORT
   col 0, " Current Date/Time:", row + 1,
   col 0, curdate, col 9,
   curtime3, row + 1, col 106,
   "", row + 1, col 0,
   "Log Date/Time", col 19, "Chart Request",
   col 34, "Level", col 44,
   "Pages", col 51, "Message Text",
   col 209, "Computer Name", col 245,
   "Dist ID", row + 1, col 0,
   "--------------------------------------------------------", col 56,
   "--------------------------------------------------------",
   col 106, "--------------------------------------------------------", col 156,
   "--------------------------------------------------------", col 206,
   "--------------------------------------------------------",
   row + 1
  DETAIL
   col 0, cl.log_dt_tm"MM/DD/YY HH:MM:SS", col 17,
   cl.chart_request_id, col 36, cl.log_level"#",
   col 46, o.number_of_pages"#", col 51,
   CALL print(cl.message_text), col 209,
   CALL print(cl.server_name),
   col 240, cr.distribution_id, row + 1
  WITH nocounter, check, maxcol = 300,
   outerjoin = d1
 ;end select
 CALL text(5,4,"(C)ontinue or (Q)uit?")
 CALL accept(5,36,"P(1);C","Q"
  WHERE curaccept IN ("Q", "q", "C", "c"))
 IF (curaccept IN ("Q", "q"))
  GO TO end_program
 ELSE
  EXECUTE FROM start_initial_accepts TO end_initial_accepts
 ENDIF
#end_create_log
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

CREATE PROGRAM cd_log:dba
 PAINT
 SET width = 132
 SET modify = system
#initialize
 SET c1 = fillstring(100," ")
 SET c2 = fillstring(100," ")
 SET c3 = fillstring(100," ")
 SET where_clause = fillstring(300," ")
 SET dispdistdesc = 0
 SET dispdisttype = 0
#start_initial_accepts
 CALL clear(1,1)
 CALL box(2,1,23,109)
 CALL text(1,25,"Chart Distribution Log Viewer")
 CALL text(4,2,"  Enter Operation Batch Name or leave empty")
 CALL text(5,2,"  Shift/F5 to see a list of Batch Names")
 SET help =
 SELECT DISTINCT INTO "nl:"
  co.batch_name
  FROM charting_operations co
  WHERE co.active_ind=1
  ORDER BY co.batch_name
  WITH nocounter
 ;end select
 CALL accept(6,6,"P(100);C"," ")
 SET help = off
 SET batchname = fillstring(100," ")
 SET batchname = trim(curaccept)
 CALL text(8,4,"Enter a date/time range")
 CALL text(9,4,"Begin Date: ")
 CALL text(10,4,"Begin Time: ")
 CALL accept(9,48,"nndpppdnnnn;cs",format((curdate - 1),"dd-mmm-yyyy;;d"))
 SET begindate = curaccept
 CALL accept(10,48,"hh:mm;cs",format(cnvtdatetime(curdate,curtime),"hh:mm;;m"))
 SET begintime = curaccept
 SET begindatetime = concat(trim(begindate)," ",trim(begintime))
 CALL text(12,4,"End Date: ")
 CALL text(13,4,"End Time: ")
 CALL accept(12,48,"nndpppdnnnn;cs",format(curdate,"dd-mmm-yyyy;;d"))
 SET enddate = curaccept
 CALL accept(13,48,"hh:mm;cs",format(cnvtdatetime(curdate,curtime),"hh:mm;;m"))
 SET endtime = curaccept
 SET enddatetime = concat(trim(enddate)," ",trim(endtime))
 CALL text(17,4,"ORDER: (0 = Ascending, 1 = Descending)")
 CALL accept(17,44,"9;",0
  WHERE curaccept IN (0, 1))
 SET sort_ind = cnvtint(curaccept)
 IF (batchname > " ")
  SET c1 = " substring(1,100,cdl.batch_selection) = BatchName "
 ELSE
  SET c1 = " 1 = 1 "
 ENDIF
 SET c3 = " and cdl.log_dt_tm between cnvtdatetime(BeginDateTime) and cnvtdatetime(EndDateTime)"
 SET where_clause = concat(trim(c1),trim(c2)," ",trim(c3))
 EXECUTE FROM start_create_log TO end_create_log
 GO TO start_initial_accepts
#end_initial_accepts
#start_create_log
 SET order_clause = fillstring(80," ")
 SELECT
  IF (sort_ind=0)
   ORDER BY cdl.log_dt_tm, cdl.chart_log_num
  ELSE
   ORDER BY cdl.log_dt_tm DESC, cdl.chart_log_num DESC
  ENDIF
  cdl.*
  FROM chart_dist_log cdl,
   chart_distribution cd,
   code_value cv
  PLAN (cdl
   WHERE parser(where_clause))
   JOIN (cd
   WHERE cd.distribution_id=cdl.distribution_id)
   JOIN (cv
   WHERE cv.code_value=cdl.dist_run_type_cd
    AND cv.code_set=22550)
  HEAD REPORT
   diff1 = 0.0, diff2 = 0, diff3 = 0,
   row + 1, col 0, "Current Date/Time:",
   col 22, curdate, col 31,
   curtime3, row + 1, col 106,
   "", row + 1, col 0,
   "Log Date/Time", col 19, "Dist Run Date/Time",
   col 38, "Elapsed Time", col 52,
   "Batch Name"
   IF (dispdistdesc
    AND dispdisttype)
    col 94, "Distribution", col 142,
    "Dist Run Type", col 161, "Message Text"
   ELSE
    IF (dispdistdesc)
     col 94, "Distribution", col 142,
     "Message Text"
    ELSE
     IF (dispdisttype)
      col 94, "Dist Run Type", col 125,
      "Message Text"
     ELSE
      col 94, "Message Text"
     ENDIF
    ENDIF
   ENDIF
   row + 1, col 0, "--------------------------------------------------------",
   col 56, "--------------------------------------------------------", col 106,
   "--------------------------------------------------------", col 156,
   "--------------------------------------------------------",
   row + 1
  DETAIL
   col 0, cdl.log_dt_tm"MM/DD/YY HH:MM:SS", col 19,
   cdl.dist_run_dt_tm"MM/DD/YY HH:MM:SS", diff1 = datetimediff(cdl.log_dt_tm,cdl.dist_run_dt_tm),
   diff2 = floor(diff1),
   diff3 = cnvttime(round(((diff1 - diff2) * 1440),2)), col 38, diff3"##:##",
   col 52,
   CALL print(cdl.batch_selection)
   IF (dispdistdesc
    AND dispdisttype)
    col 94,
    CALL print(cd.dist_descr), col 142,
    CALL print(cv.display), col 161,
    CALL print(cdl.message_text)
   ELSE
    IF (dispdistdesc)
     col 94,
     CALL print(cd.dist_descr), col 142,
     CALL print(cdl.message_text)
    ELSE
     IF (dispdisttype)
      col 94,
      CALL print(cv.display), col 125,
      CALL print(cdl.message_text)
     ELSE
      col 94,
      CALL print(cdl.message_text)
     ENDIF
    ENDIF
   ENDIF
   row + 1
  WITH nocounter, check, maxcol = 500
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

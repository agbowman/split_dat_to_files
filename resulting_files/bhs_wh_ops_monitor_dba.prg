CREATE PROGRAM bhs_wh_ops_monitor:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SET file = "bhs_wh_ops_mon.dat"
 SELECT INTO value(file)
  substring(1,50,o.name), start = o.beg_effective_dt_tm"MM/DD/YYYY HH:MM:SS;;D", finish = o
  .end_effective_dt_tm"MM/DD/YYYY HH:MM:SS;;D",
  duration = datetimediff(o.end_effective_dt_tm,o.beg_effective_dt_tm,5)
  FROM ops_schedule_task o
  WHERE o.beg_effective_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND cnvtdatetime((curdate - 1),
   235959)
   AND o.task_type IN (1, 2)
  ORDER BY duration DESC
  HEAD REPORT
   col 5, "START DATE/TIME ", col 30,
   "FINISH DATE/TIME", col 53, "DURATION (SEC)",
   col 70, "NAME", row + 2
  DETAIL
   IF (duration >= 60.00)
    col 5, start, col + 5,
    finish, col + 5, duration"#######;l",
    col + 5, o.name, row + 1
   ENDIF
  WITH nocounter
 ;end select
 EXECUTE bhs_ma_email_file
 CALL emailfile(file,"bhs_wh_ops_mon.txt","cisard@bhs.org","Operations Job Monitor",1)
END GO

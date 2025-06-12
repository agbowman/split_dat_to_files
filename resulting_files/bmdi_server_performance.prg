CREATE PROGRAM bmdi_server_performance
 DECLARE startdate = vc
 DECLARE enddate = vc
 DECLARE rowcount = i2
 DECLARE latency = f8
 DECLARE avgrows = f8
 DECLARE mindiff = f8
 DECLARE avglatency = f8
 SET startdate = ""
 SET enddate = ""
 SET rowcount = 0
 SET latency = 0.0
 SET avgrows = 0.0
 SET mindiff = 0.0
 SET avglatency = 0.0
#main_menu
 CALL cache_monitors(1)
 CALL clear(1,1)
 CALL video(nw)
 CALL box(2,1,19,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"BMDI SERVER PERFORMANCE")
 CALL box(6,9,17,72)
 CALL line(8,9,64,xhor)
 CALL text(7,11," SET SEARCH CRITERIA")
 CALL text(9,11," Enter all dates in the format of DD-MMM-YYYY HH:MM:SS")
 CALL text(10,11," For example: 06-JUL-2005 13:35:00")
 CALL text(12,11," Enter a start date: ")
 CALL accept(12,35,"99-AAA-9999 99:99:99;CU)","")
 SET startdate = curaccept
 CALL text(14,11," Enter a end date: ")
 CALL accept(14,35,"99-AAA-9999 99:99:99;CU","")
 SET enddate = curaccept
 IF (((startdate="") OR (enddate="")) )
  CALL text(22,2," Invalid date entered. Press any key to continue")
  CALL accept(22,51,"P(1)")
  GO TO exit_script
 ENDIF
 CALL video(rbw)
 CALL text(14,2,"Please wait. This may take several minutes...")
 SELECT INTO "nl"
  bar.acquired_dt_tm, bar.updt_dt_tm
  FROM bmdi_acquired_results bar
  WHERE bar.acquired_dt_tm >= cnvtdatetime(startdate)
   AND bar.acquired_dt_tm <= cnvtdatetime(enddate)
  HEAD REPORT
   rowcount = 0, latency = 0
  DETAIL
   rowcount = (rowcount+ 1), latency = (latency+ datetimediff(bar.updt_dt_tm,bar.acquired_dt_tm,5))
  WITH nocounter
 ;end select
 SET mindiff = datetimediff(cnvtdatetime(enddate),cnvtdatetime(startdate),4)
 SET avgparams = (rowcount/ mindiff)
 SET avglatency = (latency/ rowcount)
 CALL clear(1,1)
 CALL video(nw)
 CALL box(2,1,16,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"BMDI SERVER PERFORMANCE")
 CALL box(6,9,14,72)
 CALL line(8,9,64,xhor)
 CALL text(7,11," PERFORMANCE RESULTS")
 CALL text(9,11," Total number of paramters is: ")
 CALL text(9,60,format(rowcount,"########.##"))
 CALL text(11,11," Average number of parameters per minute is: ")
 CALL text(11,60,format(avgparams,"########.##"))
 CALL text(13,11," Average latency is: ")
 CALL text(13,60,format(avglatency,"########.##"))
 CALL text(18,2,"Press 1 to restart or 2 to exit")
 CALL accept(18,35,"9")
 CASE (curaccept)
  OF 1:
   GO TO main_menu
  ELSE
   GO TO exit_script
 ENDCASE
 GO TO main_menu
#exit_script
END GO

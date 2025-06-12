CREATE PROGRAM bmdi_interface_performance
 DECLARE cache_monitors(int=i2) = null
 DECLARE search_struct(mon=vc,structindex=i2(ref)) = null
 RECORD monitorlisting(
   1 qual[*]
     2 monid = vc
     2 count = f8
 )
 DECLARE startdate = vc
 DECLARE enddate = vc
 DECLARE paramcount = f8
 DECLARE rowcount = f8
 DECLARE setx = vc
 DECLARE setb = vc
 DECLARE etbindex = i2
 DECLARE etxindex = i2
 DECLARE avgresults = f8
 DECLARE avgparams = f8
 DECLARE avgrows = f8
 DECLARE mindiff = f8
 DECLARE structcount = i2
 DECLARE startnum = i2
 DECLARE endnum = i2
 DECLARE done = i2
 DECLARE structind = i2
 DECLARE firsttime = i2
 DECLARE previndex = i2
 DECLARE index = i2
 SET startdate = ""
 SET enddate = ""
 SET paramcount = 0.0
 SET rowcount = 0.0
 SET avgresults = 0.0
 SET avgparams = 0.0
 SET avgrows = 0.0
 SET mindiff = 0.0
 SET sructcount = 0.0
 SET startnum = 0
 SET endnum = 0
 SET done = 0
 SET etbindex = 0
 SET etxindex = 0
 SET structind = 0
 SET firsttime = 0
 SET previndex = 0
 SET index = 0
 SET setx = char(03)
 SET setb = char(23)
#main_menu
 CALL cache_monitors(1)
 CALL clear(1,1)
 CALL video(nw)
 CALL box(2,1,19,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"BMDI INTERFACE PERFORMANCE")
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
  cqm.message
  FROM cqm_bmdi_results_que cqm
  WHERE create_dt_tm >= cnvtdatetime(startdate)
   AND create_dt_tm <= cnvtdatetime(enddate)
  DETAIL
   rowcount = (rowcount+ 1), etbindex = 0, etxindex = 0,
   done = 0, etbindex = findstring(setb,cqm.message,etxindex,0)
   IF (etbindex=0)
    done = 1
   ELSE
    monid = substring(2,(etbindex - 2),cqm.message)
    IF (monid != "")
     structind = 0, monid = trim(monid,3),
     CALL search_struct(monid,structind)
    ENDIF
   ENDIF
   done = 0
   WHILE (done=0)
     etxindex = findstring(setx,cqm.message,etxindex,0)
     IF (etxindex=0)
      done = 1
     ELSE
      IF (structind > 0)
       monitorlisting->qual[structind].count = (monitorlisting->qual[structind].count+ 1)
      ENDIF
      paramcount = (paramcount+ 1)
     ENDIF
     etxindex = (etxindex+ 1)
   ENDWHILE
  WITH nocounter
 ;end select
 SET avgresults = (paramcount/ rowcount)
 SET mindiff = datetimediff(cnvtdatetime(enddate),cnvtdatetime(startdate),4)
 SET avgrows = (rowcount/ mindiff)
 SET avgparams = (paramcount/ mindiff)
 CALL clear(1,1)
 CALL video(nw)
 CALL box(2,1,21,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"BMDI INTERFACE PERFORMANCE")
 CALL box(6,9,19,72)
 CALL line(8,9,64,xhor)
 CALL text(7,11," PERFORMANCE RESULTS")
 CALL text(9,11," Total number of rows is: ")
 CALL text(9,60,format(rowcount,"########.##"))
 CALL text(11,11," Total number of paramters is: ")
 CALL text(11,60,format(paramcount,"########.##"))
 CALL text(13,11," Average number of results per row is: ")
 CALL text(13,60,format(avgresults,"########.##"))
 CALL text(15,11," Average number of rows per minute is: ")
 CALL text(15,60,format(avgrows,"########.##"))
 CALL text(17,11," Average number of parameters per minute is: ")
 CALL text(17,60,format(avgparams,"########.##"))
 CALL text(23,2,"Press 1 to restart, 2 to view details or 3 to exit")
 CALL accept(23,55,"9")
 CASE (curaccept)
  OF 1:
   GO TO main_menu
  OF 2:
   GO TO view_details
  ELSE
   GO TO exit_script
 ENDCASE
 GO TO main_menu
 SUBROUTINE cache_monitors(int)
   CALL video(rbw)
   CALL text(14,2,"Caching in monitors. Please wait...")
   SELECT INTO "nl"
    FROM bmdi_monitored_device bmd
    WHERE bmd.location_cd > 0
    ORDER BY bmd.device_alias
    HEAD REPORT
     structcount = 0
    DETAIL
     structcount = (structcount+ 1)
     IF (mod(structcount,10)=1)
      stat = alterlist(monitorlisting->qual,(structcount+ 9))
     ENDIF
     monitorlisting->qual[structcount].monid = bmd.device_alias, monitorlisting->qual[structcount].
     count = 0
    FOOT REPORT
     stat = alterlist(monitorlisting->qual,structcount)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE search_struct(mon,structindex)
   SET startnum = 1
   SET endnum = (structcount+ 1)
   SET firsttime = 1
   WHILE (done=0)
    SET previndex = round(((startnum+ endnum)/ 2),0)
    IF ((monitorlisting->qual[previndex].monid=mon))
     SET structindex = previndex
     SET done = 1
    ELSE
     IF ((mon > monitorlisting->qual[previndex].monid))
      SET startnum = previndex
     ELSEIF ((mon < monitorlisting->qual[previndex].monid))
      SET endnum = previndex
     ENDIF
     IF (previndex=round(((startnum+ endnum)/ 2),0))
      SET done = 1
     ENDIF
    ENDIF
   ENDWHILE
 END ;Subroutine
#view_details
 SET structind = 1
 SET index = 0
 SELECT
  FROM (dummyt d1  WITH seq = value(index))
  HEAD REPORT
   lined = fillstring(120,"="), col 0, "Monitor ID",
   col 21, "Number of Parameters", row + 1,
   lined, row + 1
  DETAIL
   WHILE (structind <= structcount)
     col 0, monitorlisting->qual[structind].monid, col 21,
     monitorlisting->qual[structind].count, structind = (structind+ 1), row + 1
   ENDWHILE
  WITH nocounter
 ;end select
#exit_script
END GO

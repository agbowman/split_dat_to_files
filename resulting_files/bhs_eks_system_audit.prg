CREATE PROGRAM bhs_eks_system_audit
 PROMPT
  "Output to File/Printer/MINE " = mine,
  "Enter begin date (CURDATE-1): " = (curdate - 1),
  "Enter end date (CURDATE): " = curdate,
  "Enter module name (*): " = "*",
  "Show Details (N) ? " = "N",
  "Enter server class (*): " = "*"
 DECLARE lastfireddatetime = c20
 DECLARE startdate = c8
 DECLARE enddate = c8
 DECLARE datelen = i4
 DECLARE textdate = vc
 SET startdate = eks_monitor_check_date_sub( $2)
 SET enddate = eks_monitor_check_date_sub( $3)
 SET maxsecs = 0
 IF (validate(isodbc,0))
  SET maxsecs = 30
 ENDIF
 RECORD eks_audit(
   1 qual[*]
     2 module_name = c30
       3 evoke[*]
         4 logic[*]
           5 logic_return = c3
 )
 SELECT INTO  $1
  e.module_name, e.begin_dt_tm"DD-MMM-YYYY  HH:MM:SS;;D", e.end_dt_tm"DD-MMM-YYYY  HH:MM:SS;;D",
  e.logic_return
  FROM eks_module_audit e
  WHERE e.module_name=cnvtupper( $4)
   AND e.updt_dt_tm BETWEEN cnvtdatetime(cnvtdate2(startdate,"YYYYMMDD"),000001) AND cnvtdatetime(
   cnvtdate2(enddate,"YYYYMMDD"),235959)
   AND (e.server_class= $6)
  WITH maxcol = 500, time = value(maxsecs), nullreport,
   noheading, format = variable
 ;end select
 SUBROUTINE eks_monitor_check_date_sub(param_date_val)
   SET tempdate = param_date_val
   SET textdate = cnvtstring(tempdate)
   SET datelen = size(textdate)
   DECLARE return_val = c8
   IF (((datelen=6) OR (datelen=5)) )
    SET prevyeardate = cnvtdatetime((curdate - 365),0)
    SET tomorrowdate = cnvtdatetime((curdate+ 1),0)
    IF (cnvtdatetime(tempdate,0) > prevyeardate
     AND cnvtdatetime(tempdate,0) < tomorrowdate)
     SET return_val = format(cnvtdatetime(tempdate,0),"yyyymmdd;;d")
    ELSE
     SET return_val = format(cnvtdate(tempdate),"yyyymmdd;;d")
    ENDIF
   ELSEIF (datelen=8)
    SET return_val = format(tempdate,"########;p0")
   ENDIF
   RETURN(return_val)
 END ;Subroutine
END GO

CREATE PROGRAM cpmprocess_audit:dba
 PAINT
#start
 SET startdate = fillstring(11," ")
 SET enddate = fillstring(20," ")
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,22,80)
 CALL line(3,1,80,xhoraz)
 CALL text(2,3,"Process Server Error Audit")
 CALL video(n)
 CALL text(5,5,"Output File/Printer/Mine (MINE)? ")
 CALL text(6,5,"Request Number? ")
 CALL text(7,5,"Destination Step? ")
 CALL text(8,5,"Date Range? ")
 CALL accept(5,40,"PPPPPPPPP;CU","MINE")
 SET outfile = curaccept
 CALL accept(6,40,"99999999999",0)
 SET reqnbr = curaccept
 CALL accept(7,40,"99999999999",0)
 SET destid = curaccept
 CALL accept(8,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
 SET startdate = curaccept
 CALL accept(9,40,"NNDCCCDNNNN;C",format(curdate,"DD-MMM-YYYY;;D"))
 SET enddate = curaccept
 SET enddate = concat(trim(enddate),":23:59")
 SELECT INTO value(outfile)
  error =
  IF (c.error_code > 0) "Yes"
  ELSE "Recovered"
  ENDIF
  , c.updt_dt_tm, time = format(c.updt_dt_tm,"hh:mm:ss;;m"),
  c.request_number, fail_reason =
  IF (c.error_code=0) "Recovered successfully"
  ELSEIF (c.error_code=1) "No routing defined for request"
  ELSEIF (c.error_code=2) "Prolog Script Failed to execute, check request table"
  ELSEIF (((c.error_code=3) OR (c.error_code=9)) ) "Format Script Failed to execute "
  ELSEIF (c.error_code=4) "Destination Step Id not defined in TDB"
  ELSEIF (c.error_code >= 5
   AND c.error_code < 9) "Failed to send to Destination Server"
  ELSEIF (c.error_code=10) "Epilog Script Failed to execute"
  ENDIF
  , c.error_id,
  c.*
  FROM cpmprocess_error c
  WHERE ((c.request_number=reqnbr) OR (reqnbr=0))
   AND ((c.destination_step_id=destid) OR (destid=0))
   AND c.updt_dt_tm >= cnvtdatetime(startdate)
   AND c.updt_dt_tm <= cnvtdatetime(enddate)
 ;end select
END GO

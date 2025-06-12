CREATE PROGRAM cclocdselectrpt:dba
 SELECT INTO value( $1)
  dp.object, dp.object_name, dp.app_major_version,
  dp.app_minor_version, dc.object, dc.object_name,
  dc.qual, dp.datestamp, dp.timestamp
  FROM dcompileocd dc,
   dprotectocd dp
  PLAN (dp)
   JOIN (dc
   WHERE dp.platform=dc.platform
    AND dp.object=dc.object
    AND dp.object_name=dc.object_name
    AND dp.group=dc.group)
  ORDER BY dp.object, dp.object_name, dc.qual
  HEAD REPORT
   rline = fillstring(120,"="), row 1,
   CALL center("Objects Currently in the Mini Dictionary",0,79),
   row + 1,
   CALL center(trim(minidic),0,79), row + 1,
   rdate = format(curdate,"mmm-dd-yyyy;;d"), rtime = format(curtime,"hh:mm;;m"),
   CALL center(concat(rdate,"  ",rtime),0,79),
   row + 2, col 0, "Type",
   col 10, "Object Name", col 45,
   "Date", col 56, "Time",
   col 65, "       Rev", col 80,
   "       OCD", col 95, "Begin Qual",
   col 110, "  End Qual", row + 1,
   col 0, rline, row + 2
  HEAD dp.object_name
   object_name = fillstring(32," "), object_name = concat( $2,dp.object_name), col 0,
   dp.object, col 10, object_name,
   col 44,  $3, col 45,
   dp.datestamp"mm/dd/yyyy;;d", col 56, dp.timestamp"hh:mm:ss;2;m",
   col 64,  $2, col 65,
   dp.app_major_version, col 80, dp.app_minor_version,
   col 95, dc.qual
  DETAIL
   row + 0
  FOOT  dp.object_name
   col 110, dc.qual, row + 1
  FOOT REPORT
   row + 1,
   CALL center("******** End Report ********",0,79)
  WITH outerjoin = dp, noheading, noformfeed,
   nullreport, format = stream
 ;end select
END GO

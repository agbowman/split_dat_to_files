CREATE PROGRAM ccl_prompt_datetimefind:dba
 PROMPT
  "dt" = sysdate,
  "dtDateMode" = 0,
  "dtrange" = "B",
  "dtTimeMode" = "P"
  WITH dt, dtdatemode, dtrange,
  dttimemode
 SET ccl_prompt_api_disable = 1
 SET ccl_prompt_api_misc = 1
 EXECUTE ccl_prompt_api_dataset "MISC"
 SET stat = setmiscsize(_out_,1)
 SET stat = setmiscrecord(_out_,1,format(datetimefind(cnvtdatetime( $DT), $DTDATEMODE, $DTRANGE,
     $DTTIMEMODE),"yyyymmddhhmmsscc;;q"))
 SET stat = setstatus("S")
END GO

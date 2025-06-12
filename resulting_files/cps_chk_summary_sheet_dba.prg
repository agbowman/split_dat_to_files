CREATE PROGRAM cps_chk_summary_sheet:dba
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET default_display = "Default Template"
 SELECT INTO "nl:"
  s.summary_sheet_id
  FROM summary_sheet s
  WITH nocounter, maxqual(s,1)
 ;end select
 IF (curqual <= 0)
  SET ierrcode = error(serrmsg,1)
  CALL echo(build("Error message: ",ierrcode),1)
  CALL echo(build("Error message: ",serrmsg),1)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = concat("FAILURE Summary Sheet NOT Present "," ",format(
    cnvtdatetime(curdate,curtime3),"mm/dd/yy hh:mm;;q"))
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = concat("Success Summary Sheet Present  "," ",format(
    cnvtdatetime(curdate,curtime3),"mm/dd/yy hh:mm;;q"))
  CALL echo(build("Success message: ",request->setup_proc[1].error_msg),1)
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO

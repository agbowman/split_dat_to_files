CREATE PROGRAM bhs_rpt_surg_dwn_time_ops:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Surgery Downtime" = ""
  WITH outdev, surg_location
 DECLARE s_find_file = vc WITH noconstant(" "), protect
 DECLARE surg_loc_ops = vc WITH noconstant(" "), protect
 DECLARE ops_printer = vc WITH noconstant(" "), protect
 SET surg_loc_ops =  $SURG_LOCATION
 SET ops_printer =  $OUTDEV
 SET s_find_file = concat("bhscust:",trim(surg_loc_ops),"_surgical_sched_data.csv")
 CALL echo("LOADING FILES")
 CALL echo(s_find_file)
 SET csv_stat = findfile(s_find_file)
 IF (csv_stat=0)
  CALL echo(build("Failed to find csv file:",s_find_file))
  GO TO exit_script
 ENDIF
 EXECUTE kia_dm_dbimport value(s_find_file), "bhs_dt_clin_sum2_surg", 100,
 0
 CALL echorecord(requestin)
#exit_script
 FREE DEFINE rtl2
END GO

CREATE PROGRAM bhs_rpt_surg_dwntm_mar_ops:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Surgery Downtime" = ""
  WITH outdev, surg_location
 DECLARE ms_s_find_file = vc WITH noconstant(" "), protect
 DECLARE ms_surg_loc_ops = vc WITH noconstant(" "), protect
 DECLARE ms_ops_printer = vc WITH noconstant(" "), protect
 SET ms_surg_loc_ops =  $SURG_LOCATION
 SET ms_ops_printer =  $OUTDEV
 SET ms_s_find_file = concat("bhscust:",trim(ms_surg_loc_ops),"_surgical_sched_data.csv")
 CALL echo("LOADING FILES")
 CALL echo(ms_s_find_file)
 SET csv_stat = findfile(ms_s_find_file)
 IF (csv_stat=0)
  CALL echo(build("Failed to find csv file:",ms_s_find_file))
  GO TO exit_script
 ENDIF
 EXECUTE kia_dm_dbimport value(ms_s_find_file), "bhs_rpt_surg_downtime_mar", 100,
 0
 CALL echorecord(requestin)
#exit_script
 FREE DEFINE rtl2
END GO

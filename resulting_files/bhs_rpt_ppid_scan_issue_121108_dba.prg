CREATE PROGRAM bhs_rpt_ppid_scan_issue_121108:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "beg_time" = "SYSDATE",
  "end_time" = "SYSDATE"
  WITH outdev, beg_time, end_time
 SELECT INTO  $OUTDEV
  *
  FROM med_admin_event mae,
   med_admin_med_error mam
  PLAN (mae
   WHERE mae.beg_dt_tm BETWEEN cnvtdatetime( $BEG_TIME) AND cnvtdatetime( $END_TIME))
   JOIN (mam
   WHERE mam.event_id=mae.event_id)
  WITH separator = " ", format, time = 300,
   macrec = 100000
 ;end select
END GO

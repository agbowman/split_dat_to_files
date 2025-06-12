CREATE PROGRAM dm_stat_report_pharmacy_vols:dba
 SELECT
  ds.stat_snap_dt_tm, dv.stat_number_val
  FROM dm_stat_snaps ds,
   dm_stat_snaps_values dv
  PLAN (ds
   WHERE ds.snapshot_type="Pharmacy Volumes"
    AND ds.stat_snap_dt_tm BETWEEN cnvtdatetime(dsr_reports->begin_dt_tm) AND cnvtdatetime(
    dsr_reports->end_dt_tm))
   JOIN (dv
   WHERE dv.dm_stat_snap_id=ds.dm_stat_snap_id)
  ORDER BY ds.stat_snap_dt_tm
  HEAD REPORT
   col 0, "Pharmacy Volumes", row + 1,
   col 0, "Begin Date:  ", dsr_reports->begin_dt_tm,
   row + 1, col 0, "End Date:    ",
   dsr_reports->end_dt_tm, row + 2, col 0,
   "Date/Time", col 20, "Count",
   row + 1
  DETAIL
   disp_date = format(ds.stat_snap_dt_tm,"mm/dd/yy hh:mm"), col 0, disp_date,
   col 20, dv.stat_number_val, row + 1
  WITH nocounter, formfeed = none, maxrow = 1
 ;end select
 IF (error(dsr_reports->stat_error_message,1))
  SET dsr_reports->stat_error_flag = 1
 ENDIF
END GO

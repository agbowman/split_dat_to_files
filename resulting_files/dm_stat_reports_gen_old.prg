CREATE PROGRAM dm_stat_reports_gen_old
 RECORD report_data(
   1 header1 = vc
   1 header2 = vc
   1 title = vc
 )
 DECLARE snap_date = vc
 DECLARE order_val = vc
 DECLARE dm_disp = vc
 DECLARE counter = i2
 SET counter = 0
 IF ((dsr_reports->sort_by="stat_snap_dt_tm"))
  SET order_val = build("ds.",dsr_reports->sort_by)
 ELSE
  SET order_val = build("dv.",dsr_reports->sort_by)
 ENDIF
 CASE (dsr_reports->report_type)
  OF "ESM_OSSTAT_DTL":
   SET report_data->title = "Node Utilization Detail"
   SET report_data->header1 = "Metric"
   SET report_data->header2 = "Count"
  OF "ESM_OSSTAT_SMRY":
   SET report_data->title = "Node Utilization Summary"
   SET report_data->header1 = "Metric"
   SET report_data->header2 = "Count"
  OF "ESM_MSGLOG_SMRY":
   SET report_data->title = "Message Log Summary"
   SET report_data->header1 = "Message Type"
   SET report_data->header2 = "Count"
  OF "ESM_MSGLOG_DTL":
   SET report_data->title = "Message Log Detail"
   SET report_data->header1 = "Message Type"
   SET report_data->header2 = "Count"
  OF "Application Volumes":
   SET report_data->title = "Application Volumes"
   SET report_data->header1 = "Application Name"
   SET report_data->header2 = "Count"
  OF "ORDER_VOLUMES":
   SET report_data->title = "Order Volumes"
   SET report_data->header1 = "Order Action"
   SET report_data->header2 = "Count"
  OF "CHART_OPEN_VOLUMES":
   SET report_data->title = "Chart Open Volumes"
   SET report_data->header1 = "Personnel Type"
   SET report_data->header2 = "Chart Opens"
  OF "Personnel Volumes":
   SET report_data->title = "Personnel Volumes"
   SET report_data->header1 = "Personnel Type"
   SET report_data->header2 = "Count"
  OF "Radiology Volumes":
   SET report_data->title = "Radiology Volumes"
   SET report_data->header1 = "Action"
   SET report_data->header2 = "Count"
  OF "SCHEDULING VOLUMES":
   SET report_data->title = "Scheduling Volumes"
   SET report_data->header1 = "Action"
   SET report_data->header2 = "Count"
  OF "ESM_MILLCONFIG":
   SET report_data->title = "Millennium Configuration"
   SET report_data->header1 = "Parameter"
   SET report_data->header2 = "Value"
  OF "ESM_OSCONFIG":
   SET report_data->title = "OS Configuration"
   SET report_data->header1 = "Parameter"
   SET report_data->header2 = "Value"
  OF "ESI Interface Volumes":
   SET report_data->title = "Inbound Interface Volumes"
   SET report_data->header1 = "Source/Transaction"
   SET report_data->header2 = "Count"
  OF "PM VOLUMES":
   SET report_data->title = "PM Volumes"
   SET report_data->header1 = "Transaction"
   SET report_data->header2 = "Count"
  OF "Pathnet Volumes":
   SET report_data->title = "Pathnet Volumes"
   SET report_data->header1 = "Transaction"
   SET report_data->header2 = "Count"
  OF "ESO Outbound Interface Volumes":
   SET report_data->title = "Outbound Volumes"
   SET report_data->header1 = "Transaction"
   SET report_data->header2 = "Count"
  OF "FIRSTNET VOLUMES":
   SET report_data->title = "FirstNet Volumes"
   SET report_data->header1 = "Transaction"
   SET report_data->header2 = "Count"
  OF "ESM_RRD_METRICS_DTL":
   SET report_data->title = "RRD Volumes Detail"
   SET report_data->header1 = "Transaction"
   SET report_data->header2 = "Count"
  OF "ESM_RRD_METRICS_SMRY":
   SET report_data->title = "RRD Volumes Summary"
   SET report_data->header1 = "Transaction"
   SET report_data->header2 = "Count"
  ELSE
   SET dsr_reports->stat_error_flag = 1
   SET dsr_reports->stat_error_message = "Invalid Report Type"
   GO TO exit_program
 ENDCASE
 SELECT
  ds.stat_snap_dt_tm, dv.stat_name, dv.stat_number_val
  FROM dm_stat_snaps ds,
   dm_stat_snaps_values dv,
   dummyt d
  PLAN (d)
   JOIN (ds
   WHERE (ds.snapshot_type=dsr_reports->report_type)
    AND ds.stat_snap_dt_tm BETWEEN cnvtdatetime(dsr_reports->begin_dt_tm) AND cnvtdatetime(
    dsr_reports->end_dt_tm))
   JOIN (dv
   WHERE dv.dm_stat_snap_id=ds.dm_stat_snap_id)
  ORDER BY parser(order_val)
  HEAD REPORT
   col 0, report_data->title, row + 1,
   col 0, "Begin Date: ", dsr_reports->begin_dt_tm,
   row + 1, col 0, "End Date:   ",
   dsr_reports->end_dt_tm, row + 2, col 0,
   "Date/Time", col 22, report_data->header1,
   col 65, report_data->header2, row + 1
  DETAIL
   counter = 1, snap_date = format(ds.stat_snap_dt_tm,"dd-mmm-yyyy hh:mm"), col 0,
   snap_date
   IF ((dsr_reports->report_type="ESM_MSGLOG_SMRY"))
    CASE (dv.stat_name)
     OF "MSG_ERROR_CNT":
      col 20,"Error"
     OF "MSG_WARN_CNT":
      col 20,"Warning"
     OF "MSG_AUDIT_CNT":
      col 20,"Audit"
     OF "MSG_INFO_CNT":
      col 20,"Informational"
     OF "MSG_DEBUG_CNT":
      col 20,"Debug"
     OF "MSG_TOTAL_CNT":
      col 20,"Total"
    ENDCASE
   ELSE
    col 22, dv.stat_name
   ENDIF
   IF ((dsr_reports->report_type="ESM_MILLCONFIG"))
    col 65, dv.stat_str_val
   ELSEIF ((dsr_reports->report_type="ESM_OSCONFIG"))
    IF (dv.stat_type=1)
     dm_disp = cnvtstring(dv.stat_number_val), col 65, dm_disp
    ELSE
     col 65, dv.stat_str_val
    ENDIF
   ELSE
    col 65, dv.stat_number_val
   ENDIF
   row + 1
  FOOT REPORT
   IF (counter=0)
    row + 2, col 22, "****NO RECORDS FOUND****"
   ELSE
    row + 1, col 22, "****END OF REPORT****"
   ENDIF
  WITH nocounter, formfeed = none, nullreport,
   maxcol = 500
 ;end select
 IF (error(dsr_reports->stat_error_message,1))
  SET dsr_reports->stat_error_flag = 1
 ENDIF
#exit_program
 FREE RECORD report_data
END GO

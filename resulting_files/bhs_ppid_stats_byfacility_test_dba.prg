CREATE PROGRAM bhs_ppid_stats_byfacility_test:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Starting date(mm/dd/yyyy):" = curdate,
  "Ending date(mm/dd/yyyy):" = curdate,
  "Facility:" = 0
  WITH out_dev, start_date, end_date,
  facility, nurse_unit
 SET any_status_ind = substring(1,1,reflect(parameter(5,0)))
 SELECT INTO  $1
  unit = uar_get_code_display(mae.nurse_unit_cd), date = mae.beg_dt_tm"mm/dd/yyyy hh:mm", nurse = pr
  .name_full_formatted,
  patient = p.name_full_formatted, med = o.ordered_as_mnemonic, more_info = o.simplified_display_line,
  pos_med_scan = mae.positive_med_ident_ind, event = uar_get_code_display(mae.event_type_cd)
  FROM med_admin_event mae,
   orders o,
   person p,
   prsnl pr
  PLAN (mae
   WHERE mae.beg_dt_tm BETWEEN cnvtdatetime(cnvtdate( $START_DATE),0) AND cnvtdatetime(cnvtdate(
      $END_DATE),235959)
    AND ((mae.nurse_unit_cd+ 0)= $NURSE_UNIT)
    AND mae.event_type_cd > 0)
   JOIN (o
   WHERE o.order_id=mae.order_id)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (pr
   WHERE pr.person_id=mae.prsnl_id)
  ORDER BY o.person_id
  WITH format, separator = " "
 ;end select
END GO

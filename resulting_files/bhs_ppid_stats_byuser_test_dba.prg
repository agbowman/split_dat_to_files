CREATE PROGRAM bhs_ppid_stats_byuser_test:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter UserID:" = 0,
  "Start Date" = curdate,
  "End Date" = curdate
  WITH outdev, prompt1, prompt2,
  prompt3
 SELECT INTO  $1
  o.person_id, mae.order_id, mae.event_id,
  patient = p.name_full_formatted, event = uar_get_code_display(mae.event_type_cd), mae.event_type_cd,
  med = o.ordered_as_mnemonic, date = mae.beg_dt_tm"mm/dd/yyyy hh:mm", pos_med_scan = mae
  .positive_med_ident_ind,
  pos_patient_scan = mae.positive_patient_ident_ind
  FROM med_admin_event mae,
   orders o,
   person p
  PLAN (mae
   WHERE mae.beg_dt_tm BETWEEN cnvtdatetime(cnvtdate( $PROMPT2),0) AND cnvtdatetime(cnvtdate(
      $PROMPT3),235959)
    AND (mae.prsnl_id= $2)
    AND mae.event_type_cd > 0)
   JOIN (o
   WHERE o.order_id=mae.order_id)
   JOIN (p
   WHERE p.person_id=o.person_id)
  ORDER BY o.person_id
  WITH format, separator = " "
 ;end select
END GO

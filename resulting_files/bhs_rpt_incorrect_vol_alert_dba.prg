CREATE PROGRAM bhs_rpt_incorrect_vol_alert:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Select Facility: " = value(673936.00)
  WITH outdev, s_beg_dt, s_end_dt,
  f_facility_cd
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_incorrectvol = f8 WITH constant(uar_get_code_by("MEANING",4000040,"INCORRECTVOL"))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 SET ms_beg_dt_tm = concat( $S_BEG_DT," 00:00:00")
 SET ms_end_dt_tm = concat( $S_END_DT," 00:00:00")
 CALL echo(build2("ms_beg_dt_tm: ",ms_beg_dt_tm))
 CALL echo(build2("ms_end_dt_tm: ",ms_end_dt_tm))
 SELECT INTO  $OUTDEV
  pt_acct# = trim(fin.alias,3), pt_name = trim(p.name_full_formatted,3), pt_unit = trim(
   uar_get_code_display(maa.nurse_unit_cd),3),
  medication = trim(o.order_mnemonic,3), order_sentence = trim(o.order_detail_display_line,3),
  date_time_administered = trim(format(mae.beg_dt_tm,"mm/dd/yy HH:mm;;D"),3),
  administered_user = trim(pr.name_full_formatted,3), volume_entered = concat(build(cnvtstring(cmr
     .infused_volume,11,2))," ",trim(uar_get_code_display(cmr.infused_volume_unit_cd),3))
  FROM med_admin_alert maa,
   med_admin_med_error mame,
   med_admin_event mae,
   orders o,
   encounter e,
   person p,
   encntr_alias fin,
   ce_med_result cmr,
   prsnl pr
  PLAN (maa
   WHERE maa.event_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND maa.event_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND maa.alert_type_cd=mf_incorrectvol)
   JOIN (mame
   WHERE mame.med_admin_alert_id=maa.med_admin_alert_id)
   JOIN (mae
   WHERE mae.order_id=mame.order_id)
   JOIN (o
   WHERE o.order_id=mae.order_id)
   JOIN (e
   WHERE e.encntr_id=mame.encounter_id
    AND (e.loc_facility_cd= $F_FACILITY_CD))
   JOIN (p
   WHERE p.person_id=mame.person_id)
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.encntr_alias_type_cd=1077.00
    AND fin.active_ind=1
    AND fin.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND fin.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (cmr
   WHERE cmr.event_id=mae.event_id)
   JOIN (pr
   WHERE pr.person_id=mae.prsnl_id)
  WITH format, separator = " ", nocounter
 ;end select
#exit_script
END GO

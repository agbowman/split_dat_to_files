CREATE PROGRAM bhs_rpt_pat_transfer:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 qual_cnt = i4
   1 qual[*]
     2 encntr_id = f8
     2 person_id = f8
     2 patient_name = vc
     2 account_number = vc
     2 transfer_dt_tm = vc
     2 transfer_from = vc
     2 transfer_to = vc
 ) WITH protect
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT,3)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT,3)," 23:59:59"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 SELECT INTO value( $OUTDEV)
  patient_name = p.name_full_formatted, account_number = ea.alias, transfer_dt_tm = format(pt
   .activity_dt_tm,"mm/dd/yyyy hh:mm;;d"),
  transfer_from = uar_get_code_display(pt.o_loc_nurse_unit_cd), transfer_to = uar_get_code_display(pt
   .n_loc_nurse_unit_cd)
  FROM pm_transaction pt,
   encounter e,
   person p,
   encntr_alias ea
  PLAN (pt
   WHERE pt.activity_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND pt.n_loc_nurse_unit_cd != pt.o_loc_nurse_unit_cd
    AND pt.n_loc_nurse_unit_cd > 0.00
    AND pt.o_loc_nurse_unit_cd > 0.00)
   JOIN (e
   WHERE e.encntr_id=pt.n_encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.encntr_alias_type_cd=outerjoin(mf_fin_cd)
    AND ea.active_ind=outerjoin(1)
    AND ea.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY pt.transaction_id
  WITH nocounter, format, separator = " "
 ;end select
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO

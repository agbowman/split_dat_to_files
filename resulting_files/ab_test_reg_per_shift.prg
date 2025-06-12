CREATE PROGRAM ab_test_reg_per_shift
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT DISTINCT INTO value( $OUTDEV)
  uar_get_code_display(e.encntr_type_cd), te.complete_id, pt_name = pe.name_full_formatted,
  pt_fin = ea.alias, pt_fin_class = uar_get_code_display(pm.n_fin_class_cd), pt_address = substring(1,
   30,concat(trim(pm.n_per_home_addr_street),", ",pm.n_per_home_ph_number)),
  updt_time = pm.updt_dt_tm"@MEDIUMDATETIME", clerk = pm.current_user, e.reg_prsnl_id,
  p2.name_full_formatted, clerk_cc = e.reason_for_visit, epr.policy_nbr,
  loc_nurse_unit_disp = uar_get_code_display(e.loc_nurse_unit_cd), reg_date = e.reg_dt_tm
  "@MEDIUMDATETIME", reg_task = pm.task_number,
  reg_action = pm.transaction, pm.transaction_id
  FROM encounter e,
   encntr_plan_reltn epr,
   encntr_alias ea,
   prsnl p2,
   person pe,
   pm_transaction pm,
   tracking_item ti,
   tracking_event te,
   track_event t_e
  PLAN (e
   WHERE e.loc_facility_cd=value(uar_get_code_by("DESCRIPTION",220,"BAYSTATE FRANKLIN MEDICAL CENTER"
     ))
    AND e.reg_dt_tm BETWEEN cnvtdatetime((curdate - 4),curtime3) AND cnvtdatetime(sysdate))
   JOIN (ea
   WHERE e.encntr_id=ea.encntr_id
    AND ea.encntr_alias_type_cd=value(uar_get_code_by("MEANING",319,"FIN NBR")))
   JOIN (pe
   WHERE e.person_id=pe.person_id)
   JOIN (epr
   WHERE e.encntr_id=epr.encntr_id
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > sysdate)
   JOIN (pm
   WHERE e.encntr_id=pm.n_encntr_id
    AND pm.task_number != 117029)
   JOIN (ti
   WHERE ti.encntr_id=e.encntr_id)
   JOIN (te
   WHERE te.tracking_id=ti.tracking_id
    AND te.event_status_cd=value(uar_get_code_by("MEANING",16369,"COMPLETE")))
   JOIN (t_e
   WHERE t_e.track_event_id=te.track_event_id
    AND t_e.display="Full Reg"
    AND t_e.active_ind=1)
   JOIN (p2
   WHERE p2.person_id=e.reg_prsnl_id)
  ORDER BY pt_name, pt_fin, updt_time
  WITH time = 20, format, uar_code(m,d)
 ;end select
END GO

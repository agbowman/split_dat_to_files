CREATE PROGRAM bhs_rpt_rxplan_full
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE presc_serv_plan_cv = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",27137,
   "PRESCRIPTIONSERVICEPLAN"))
 SELECT INTO  $OUTDEV
  data_status = uar_get_code_display(data_status_cd), active_date = format(active_status_dt_tm,
   "MM/DD/YYYY HH:MM;;d"), cont_system = uar_get_code_display(contributor_system_cd),
  plan_type = uar_get_code_display(plan_type_cd), service_type = uar_get_code_display(service_type_cd
   ), plan_name,
  plan_desc, group_nbr, group_name,
  policy_nbr
  FROM health_plan
  WHERE service_type_cd=presc_serv_plan_cv
  ORDER BY active_status_dt_tm
  WITH nocounter, format, separator = " "
 ;end select
END GO

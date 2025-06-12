CREATE PROGRAM bhs_rpt_encntr_type_params:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  domain = curdomain, o.organization_id, o.org_name,
  p.encntr_type_cd, encounter_type = uar_get_code_display(p.encntr_type_cd), p.beg_effective_dt_tm,
  p.end_effective_dt_tm, p.param_name, p.value_cd,
  p.value_dt_tm, p.value_ind, p.value_nbr,
  p.value_string
  FROM encntr_type_params p,
   organization o
  PLAN (p
   WHERE p.organization_id > 0)
   JOIN (o
   WHERE o.organization_id=p.organization_id)
  ORDER BY o.org_name, uar_get_code_display(p.encntr_type_cd)
  WITH nocounter, heading, maxrow = 1,
   formfeed = none, format, separator = " "
 ;end select
#exit_script
END GO

CREATE PROGRAM bhs_saved_pf_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = curdate,
  "End Date" = curdate
  WITH outdev, sdate, edate
 SELECT INTO  $1
  personnel_name = p1.name_full_formatted, personnel_position = uar_get_code_display(p2.position_cd),
  patient_name = p.name_full_formatted,
  fin_nbr = e.alias, fa.form_dt_tm";;Q", fa.description,
  form_status = uar_get_code_display(fa.form_status_cd)
  FROM dcp_forms_activity fa,
   encntr_alias e,
   person p,
   person p1,
   prsnl p2,
   dummyt d,
   dummyt d1,
   dummyt d2
  PLAN (fa
   WHERE fa.updt_dt_tm BETWEEN cnvtdatetime(cnvtdate( $2),0) AND cnvtdatetime(cnvtdate( $3),235959)
    AND fa.form_status_cd IN (33, 39))
   JOIN (e
   WHERE fa.encntr_id=e.encntr_id
    AND e.active_ind=1
    AND e.encntr_alias_type_cd=1077)
   JOIN (d)
   JOIN (p
   WHERE p.active_ind=1
    AND p.person_id=fa.person_id)
   JOIN (d1)
   JOIN (p1
   WHERE p1.active_ind=1
    AND p1.person_id=fa.updt_id)
   JOIN (d2)
   JOIN (p2
   WHERE p2.active_ind=1
    AND p2.person_id=p1.person_id)
  ORDER BY p.name_full_formatted, e.alias, fa.form_dt_tm
  WITH format, separator = " "
 ;end select
END GO

CREATE PROGRAM dm_view_retention_criteria:dba
 SET criteria_type = cnvtupper( $1)
 SELECT
  IF (criteria_type="P")
   d.retention_criteria_id, c.cdf_meaning, d.retention_days,
   oname =
   IF (o.organization_id > 0) o.org_name
   ELSE "Default"
   ENDIF
   , v.event_cd_disp, d.beg_effective_dt_tm"MM/DD/YYYY HH:MM",
   d.end_effective_dt_tm"MM/DD/YY HH:MM", d.active_ind, d.apply_ind,
   d.last_apply_dt_tm"MM/DD/YY HH:MM", d.parent_ret_criteria_id
   FROM dm_retention_criteria d,
    code_value c,
    organization o,
    v500_event_code v
   WHERE d.criteria_type_cd=c.code_value
    AND c.cdf_meaning IN ("P*", "CPARENTPURGE")
    AND c.code_set=18249
    AND d.organization_id=o.organization_id
    AND v.event_cd=d.event_cd
   ORDER BY oname, v.event_cd_disp, d.beg_effective_dt_tm
  ELSEIF (criteria_type="A")
   d.retention_criteria_id, c.cdf_meaning, d.retention_days,
   oname =
   IF (o.organization_id > 0) o.org_name
   ELSE "Default"
   ENDIF
   , v.display, d.beg_effective_dt_tm"MM/DD/YYYY HH:MM",
   d.end_effective_dt_tm"MM/DD/YY HH:MM", d.active_ind, d.apply_ind,
   d.last_apply_dt_tm"MM/DD/YY HH:MM", d.parent_ret_criteria_id
   FROM dm_retention_criteria d,
    code_value c,
    organization o,
    code_value v
   WHERE d.criteria_type_cd=c.code_value
    AND c.cdf_meaning IN ("A*", "CPARENTARCH")
    AND c.code_set=18249
    AND d.organization_id=o.organization_id
    AND v.code_value=d.encntr_type_cd
    AND v.code_set=71
   ORDER BY oname, v.display, d.beg_effective_dt_tm
  ELSE
  ENDIF
  WITH nocounter
 ;end select
END GO

CREATE PROGRAM cv_utl_get_cdf_meaning
 PROMPT
  "Enter 0 to check id, 1 to check detail: " = "*"
 IF (( $1="0"))
  SELECT
   c.cdf_meaning, x.task_assay_cd, x.event_cd,
   c.code_value, x.event_type_cd, c.display
   FROM code_value c,
    cv_xref x
   WHERE c.code_value=x.task_assay_cd
    AND c.code_value > 0
    AND x.event_cd > 0
   ORDER BY c.cdf_meaning
   WITH nocounter
  ;end select
 ELSE
  SELECT
   c.cdf_meaning, task_assay_meaing = uar_get_code_display(x.task_assay_cd), x.event_cd,
   c.code_value, c.code_set, event_type_meaning = uar_get_code_display(x.event_type_cd),
   c.display
   FROM code_value c,
    cv_xref x
   WHERE c.code_value=x.task_assay_cd
    AND c.code_value > 0
    AND x.event_cd > 0
   ORDER BY c.cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
END GO

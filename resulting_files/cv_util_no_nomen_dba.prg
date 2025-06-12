CREATE PROGRAM cv_util_no_nomen:dba
 PROMPT
  "Output" = mine
 SELECT INTO  $1
  r.a1, xref_id = r.xref_id, dta = substring(1,30,uar_get_code_display(x.task_assay_cd))
  FROM cv_response r,
   cv_xref x
  PLAN (r
   WHERE r.field_type="A"
    AND r.nomenclature_id=0
    AND r.response_internal_name != "*BLANK*")
   JOIN (x
   WHERE x.xref_id=r.xref_id)
  ORDER BY r.xref_id, r.a1
  HEAD r.xref_id
   "The Xref Id is ::", xref_id, col + 5,
   "DTA::", x.task_assay_cd, dta,
   row + 1
  DETAIL
   col 20, r.a1, row + 1
 ;end select
END GO

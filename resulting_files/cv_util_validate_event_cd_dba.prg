CREATE PROGRAM cv_util_validate_event_cd:dba
 SELECT
  mnemonic = dta.mnemonic, dtaeventcode = uar_get_code_display(dta.event_cd), xrefeventcode =
  uar_get_code_display(ref.event_cd),
  dtaeventcode = dta.event_cd, xrefeventcode = ref.event_cd, taskassaycode = dta.task_assay_cd,
  xreftaskassaycode = ref.task_assay_cd, meaning = cv.cdf_meaning
  FROM discrete_task_assay dta,
   code_value cv,
   cv_xref ref
  PLAN (cv
   WHERE ((cv.cdf_meaning="ACC*") OR (cv.cdf_meaning="STS*"))
    AND cv.code_set=14003)
   JOIN (dta
   WHERE dta.task_assay_cd=cv.code_value)
   JOIN (ref
   WHERE ref.event_cd != dta.event_cd
    AND dta.task_assay_cd=ref.task_assay_cd)
  ORDER BY dtaeventcode
  WITH nocounter
 ;end select
END GO

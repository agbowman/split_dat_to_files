CREATE PROGRAM cv_utl_chk_task_assay_cd:dba
 SELECT DISTINCT
  task_cd_xref = ref.task_assay_cd, task_cd_dta = dta.task_assay_cd, cdf_meaning = cv.cdf_meaning,
  display = cv.display
  FROM code_value cv,
   discrete_task_assay dta,
   cv_xref ref
  WHERE cv.cdf_meaning IN ("ACC*", "AC02*", "STS*")
   AND cv.code_set=14003
   AND cv.code_value=dta.task_assay_cd
   AND dta.event_cd=ref.event_cd
   AND dta.task_assay_cd != ref.task_assay_cd
  WITH nocounter
 ;end select
END GO

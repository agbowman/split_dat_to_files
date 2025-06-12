CREATE PROGRAM cv_util_cmp_disp_cdf_meaning:dba
 PROMPT
  "Output Device " = mine,
  "DataSet Mnemonic " = "acc*"
 SET display = fillstring(250,"")
 SET codeset = 72
 SELECT INTO  $1
  task_assay_cd = dta.task_assay_cd, code_value = cv.code_value, dta_event_cd = dta.event_cd,
  event_cd = cv.code_value, cdf_meaning = cv.cdf_meaning, event_display = cv.display
  FROM discrete_task_assay dta,
   code_value cv,
   code_value cv2
  PLAN (cv
   WHERE cv.code_set=codeset
    AND (((cv.display= $2)) OR (cv.display="STS*")) )
   JOIN (dta
   WHERE cv.code_value=dta.event_cd)
   JOIN (cv2
   WHERE cv2.code_set=codeset
    AND cv2.code_value=dta.task_assay_cd)
  ORDER BY event_display
  WITH nocounter
 ;end select
END GO

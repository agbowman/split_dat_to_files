CREATE PROGRAM bhs_rpt_immuniz_hist_codes:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  vaccine_group = cv.description, collation_seq = cv.collation_seq, parent_code_value = cvg
  .parent_code_value,
  vaccine_name = uar_get_code_display(cvg.child_code_value), vaccine_code_value = cvg
  .child_code_value, cdf_meaning = cv.cdf_meaning
  FROM code_value cv,
   code_value_group cvg
  PLAN (cv
   WHERE cv.code_set=104501
    AND cv.active_ind=1
    AND cv.cdf_meaning="IMMUNEHIST"
    AND cv.active_ind=1)
   JOIN (cvg
   WHERE (cvg.parent_code_value= Outerjoin(cv.code_value))
    AND (cvg.code_set= Outerjoin(72)) )
  ORDER BY cv.collation_seq, vaccine_name
  WITH nocounter, format, separator = " "
 ;end select
END GO

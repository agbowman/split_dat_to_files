CREATE PROGRAM bhs_ma_rpt_smart_temp:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  name = cv.display, level = cv.description, cki = cv.cki,
  prg = cv.definition
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=16529
    AND cv.cdf_meaning="CLINNOTETEMP"
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY cv.display
  WITH nocounter, heading, maxrow = 1,
   formfeed = none, format, separator = " "
 ;end select
#exit_script
END GO

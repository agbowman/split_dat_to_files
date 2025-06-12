CREATE PROGRAM cv_utl_chk_dup_cdf_meaning:dba
 PROMPT
  "enter output device " = mine
 SET code_value = 0
 SET codecount = 0
 SET line_s = 0
 SET display = fillstring(250,"")
 SET icodeset = 14003
 SELECT INTO  $1
  cvnet_codevalue = cv.code_value, meaning = cv.cdf_meaning, display = cv.display
  FROM code_value cv
  WHERE cv.code_set=icodeset
   AND ((cv.cdf_meaning="ACC*") OR (((cv.cdf_meaning="STS*") OR (cv.cdf_meaning="AC02*")) ))
   AND cv.active_ind=1
  ORDER BY meaning
  HEAD REPORT
   codecount = 0
  HEAD PAGE
   col 0,
   "###########Duplicate CDF_MEANING in Code_value tables (Code Set 14003) :######################################### ",
   row + 1,
   col 0, "Code_Value:", col 20,
   "CDF_Meaning:", col 50, "Display:",
   col + 33, "Total Numbers of Duplicate cdf_meaning:", row + 1,
   line_s, row + 1
  HEAD meaning
   codecount = 0
  DETAIL
   codecount = (codecount+ 1)
  FOOT  meaning
   IF (codecount > 1)
    col 0, cv.code_value, col 20,
    cv.cdf_meaning, col 50, display,
    col 120, codecount, row + 1
   ENDIF
  WITH nocounter
 ;end select
END GO

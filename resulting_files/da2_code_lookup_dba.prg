CREATE PROGRAM da2_code_lookup:dba
 PROMPT
  "Code set " = 57
  WITH codeset
 EXECUTE ccl_prompt_api_dataset "autoset"
 DECLARE cdval = i4 WITH noconstant(57)
 SELECT
  display = cv.display, code_value = cv.code_value, cdf_meaning = cv.cdf_meaning,
  code_set = cv.code_set
  FROM code_value cv
  WHERE (cv.code_set= $CODESET)
  HEAD REPORT
   stat = makedataset(10)
  DETAIL
   stat = writerecord(0)
  FOOT REPORT
   stat = closedataset(0)
  WITH nocounter, reporthelp, maxrec = 5000
 ;end select
END GO

CREATE PROGRAM da2_codeset_lookup:dba
 EXECUTE ccl_prompt_api_dataset "autoset"
 SELECT
  usage = cv.display, description = cv.description, code_set = cv.code_set
  FROM code_value_set cv
  ORDER BY cv.code_set
  HEAD REPORT
   stat = makedataset(10)
  DETAIL
   stat = writerecord(0)
  FOOT REPORT
   stat = closedataset(0)
  WITH nocounter, reporthelp, maxrec = 5000
 ;end select
END GO

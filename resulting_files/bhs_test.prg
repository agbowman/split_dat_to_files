CREATE PROGRAM bhs_test
 EXECUTE ccl_prompt_api_dataset "autoset"
 SELECT
  cs.code_value, cs.description
  FROM code_value cs
  PLAN (cs
   WHERE cs.code_set=220
    AND cs.cdf_meaning="FACILITY"
    AND cs.code_value IN (673936, 679549, 673937, 679586, 673938,
   580062482, 580061823)
    AND cs.active_ind=1)
  ORDER BY cs.description
  HEAD REPORT
   stat = makedataset(10)
  DETAIL
   stat = writerecord(0)
  FOOT REPORT
   stat = closedataset(0)
  WITH reporthelp, check
 ;end select
END GO

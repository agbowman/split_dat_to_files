CREATE PROGRAM bbt_chk_duplicates_1636:dba
 SET serrormsg = fillstring(255," ")
 SET nerrorstatus = error(serrormsg,1)
 SELECT INTO "nl:"
  cv.cdf_meaning, count(cv.code_value)
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=1636
    AND cv.active_ind=1)
  GROUP BY cv.cdf_meaning
  HAVING count(cv.code_value) > 1
  WITH nocounter
 ;end select
 SET nerrorstatus = error(serrormsg,0)
 IF (nerrorstatus=0)
  IF (curqual > 0)
   SET request->setup_proc[1].success_ind = 0
  ELSE
   SET request->setup_proc[1].success_ind = 1
  ENDIF
 ELSE
  SET request->setup_proc[1].success_ind = 0
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO

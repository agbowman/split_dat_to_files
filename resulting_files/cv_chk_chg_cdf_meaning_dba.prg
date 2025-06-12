CREATE PROGRAM cv_chk_chg_cdf_meaning:dba
 SET request->setup_proc[1].success_ind = 1
 SET request->setup_proc[1].error_msg = fillstring(200," ")
 SET request->setup_proc[1].error_msg = "CV_CDF Successful.  Count= "
 SET v_count1 = 0
 SET v_expected_count = 195
 SELECT INTO "nl:"
  table_count = count(*)
  FROM code_value
  WHERE cdf_meaning IN ("ST*")
   AND code_set=25351
  DETAIL
   v_count1 = table_count
  WITH nocounter
 ;end select
 IF (v_count1 < v_expected_count)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = concat("CV_STS_CDF: Expected ",trim(cnvtstring(
     v_expected_count),3)," rows but found ",trim(cnvtstring(v_count1),3)," rows")
 ELSE
  SET request->setup_proc[1].error_msg = concat(trim(request->setup_proc[1].error_msg,3),trim(
    cnvtstring(v_count1),3))
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO

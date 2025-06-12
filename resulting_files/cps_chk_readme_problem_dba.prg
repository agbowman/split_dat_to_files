CREATE PROGRAM cps_chk_readme_problem:dba
 SET chk_knt = 0
 SELECT INTO "nl:"
  count(p.problem_instance_id), p.problem_id
  FROM problem p
  PLAN (p
   WHERE p.problem_id > 0
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  GROUP BY p.problem_id
  HAVING count(p.problem_instance_id) > 1
  DETAIL
   chk_knt = (chk_knt+ 1)
  WITH nocounter
 ;end select
 CALL echo("***")
 CALL echo(build("***   chk_knt :",chk_knt))
 CALL echo("***")
 IF (chk_knt > 0)
  CALL echo("***   FAILURE")
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = concat(
   "FAILURE: Not all rows were updated by CPS_POPULATE_ORIG_PRSNL ",format(cnvtdatetime(curdate,
     curtime3),"mm/dd/yy hh:mm;;q"))
 ELSE
  CALL echo("***   SUCCESS")
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = concat(
   "SUCCESS: All rows were updated by CPS_POPULATE_ORIG_PRSNL ",format(cnvtdatetime(curdate,curtime3),
    "mm/dd/yy hh:mm;;q"))
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
#exit_script
END GO

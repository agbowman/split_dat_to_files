CREATE PROGRAM bbt_chk_dependency:dba
 RECORD errors(
   1 err_cnt = i4
   1 err[5]
     2 err_code = i4
     2 err_msg = vc
 )
 SET dep_cnt = 0
 SET cd_cnt = 0
 SELECT INTO "NL:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=1660
   AND c.active_ind=1
  DETAIL
   cd_cnt = (cd_cnt+ 1)
  WITH nocounter
 ;end select
 IF (cd_cnt=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "No rows found for codeset 1660"
  GO TO exit_script
 ENDIF
 SET dep_cnt = 0
 SELECT INTO "NL:"
  *
  FROM dependency d
  WHERE d.depend_quest_cd > 0
  DETAIL
   dep_cnt = (dep_cnt+ 1)
  WITH nocounter
 ;end select
 IF (dep_cnt=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "No rows found on DEPENDENCY table"
  GO TO exit_script
 ENDIF
 SET request->setup_proc[1].success_ind = 1
#exit_script
 EXECUTE dm_add_upt_setup_proc_log
END GO

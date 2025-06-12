CREATE PROGRAM aps_chk_2052_apspec:dba
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=2052
   AND c.display_key="AP SPECIMEN"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "aps_chg_2052_apspec successful"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "aps_chg_2052_apspec failed"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO

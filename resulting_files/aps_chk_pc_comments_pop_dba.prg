CREATE PROGRAM aps_chk_pc_comments_pop:dba
 SET itemcount = 0
 SELECT INTO "nl:"
  FROM pathology_case pc
  WHERE pc.case_id > 0
   AND pc.comments > " "
   AND pc.comments_long_text_id IN (null, 0)
  DETAIL
   itemcount = (itemcount+ 1)
  WITH nocounter
 ;end select
 IF (itemcount > 0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "pathology_case, long_text populate failed"
  CALL echo("******************************************")
  CALL echo("* Failed, curqual = 0, itemcount > 0     *")
  CALL echo("******************************************")
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "pathology_case, long_text populate successful"
  CALL echo("******************************************")
  CALL echo("* Successful, NO CURQUAL, itemcount = 0  *")
  CALL echo("******************************************")
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO

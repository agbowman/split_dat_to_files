CREATE PROGRAM aps_chk_rt_hold_comment_pop:dba
 SET itemcount = 0
 SELECT INTO "nl:"
  FROM report_task rt
  WHERE rt.report_id > 0
   AND rt.hold_comment > " "
   AND rt.hold_comment_long_text_id IN (null, 0)
  DETAIL
   itemcount = (itemcount+ 1)
  WITH nocounter
 ;end select
 IF (itemcount > 0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "report_task, long_text populate failed"
  CALL echo("******************************************")
  CALL echo("* Failed, curqual = 0, itemcount > 0     *")
  CALL echo("******************************************")
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "report_task, long_text populate successful"
  CALL echo("******************************************")
  CALL echo("* Successful, NO CURQUAL, itemcount = 0  *")
  CALL echo("******************************************")
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO

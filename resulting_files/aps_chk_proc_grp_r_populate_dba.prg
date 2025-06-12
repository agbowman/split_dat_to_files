CREATE PROGRAM aps_chk_proc_grp_r_populate:dba
 SET itemcount = 0
 SELECT INTO "nl:"
  itmcntr = count(*)
  FROM ap_processing_grp_r ap
  DETAIL
   itemcount = itmcntr
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ap.parent_entity_name
  FROM ap_processing_grp_r ap
  WHERE ap.parent_entity_name > " "
  WITH nocounter
 ;end select
 IF (itemcount > 0)
  IF (curqual > 0)
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg = "ap_processing_grp_r populate successful"
   CALL echo("******************************************")
   CALL echo("* Successful, curqual > 0, itemcount > 0 *")
   CALL echo("******************************************")
  ELSE
   SET request->setup_proc[1].success_ind = 0
   SET request->setup_proc[1].error_msg = "ap_processing_grp_r populate failed"
   CALL echo("******************************************")
   CALL echo("* Failed, curqual > 0, itemcount > 0     *")
   CALL echo("******************************************")
  ENDIF
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "ap_processing_grp_r populate successful"
  CALL echo("******************************************")
  CALL echo("* Successful, NO CURQUAL, itemcount = 0  *")
  CALL echo("******************************************")
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO

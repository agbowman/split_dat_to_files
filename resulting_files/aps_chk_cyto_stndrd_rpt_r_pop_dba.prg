CREATE PROGRAM aps_chk_cyto_stndrd_rpt_r_pop:dba
 SET itemcount = 0
 SELECT INTO "nl:"
  itmcntr = count(*)
  FROM cyto_standard_rpt_r csrr
  DETAIL
   itemcount = itmcntr
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  csrr.nomenclature_id
  FROM cyto_standard_rpt_r csrr
  WHERE csrr.standard_rpt_id > 0
   AND csrr.result_cd != csrr.nomenclature_id
  WITH nocounter
 ;end select
 IF (itemcount > 0)
  IF (curqual=0)
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg = "cyto_standard_rpt_t populate successful"
   CALL echo("******************************************")
   CALL echo("* Successful, curqual > 0, itemcount > 0 *")
   CALL echo("******************************************")
  ELSE
   SET request->setup_proc[1].success_ind = 0
   SET request->setup_proc[1].error_msg = "cyto_standard_rpt_r populate failed"
   CALL echo("******************************************")
   CALL echo("* Failed, curqual > 0, itemcount > 0     *")
   CALL echo("******************************************")
  ENDIF
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "cyto_standard_rpt_t populate successful"
  CALL echo("******************************************")
  CALL echo("* Successful, NO CURQUAL, itemcount = 0  *")
  CALL echo("******************************************")
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO

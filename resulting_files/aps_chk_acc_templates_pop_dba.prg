CREATE PROGRAM aps_chk_acc_templates_pop:dba
 SET itemcount = 0
 SELECT INTO "nl:"
  FROM ap_accn_template_detail aatd
  WHERE aatd.template_detail_id > 0
   AND aatd.carry_forward_ind=1
   AND aatd.carry_forward_spec_ind=0
  DETAIL
   itemcount = (itemcount+ 1)
  WITH nocounter
 ;end select
 IF (itemcount > 0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "ap_accn_template_detail, populate failed"
  CALL echo("******************************************")
  CALL echo("* Failed, curqual = 0, itemcount > 0     *")
  CALL echo("******************************************")
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "ap_accn_template_detail, nothing to populate"
  CALL echo("******************************************")
  CALL echo("* Successful, NO CURQUAL, itemcount = 0  *")
  CALL echo("******************************************")
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO

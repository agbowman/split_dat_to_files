CREATE PROGRAM bbd_errchk_reports:dba
 SET bb_categ_report_r_cnt = 0
 SELECT INTO "nl:"
  c.categ_report_rel_id
  FROM bb_categ_report_r c
  WHERE c.categ_report_rel_id > 0
  DETAIL
   bb_categ_report_r_cnt = (bb_categ_report_r_cnt+ 1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "No rows found on the BB_CATEG_REOPRT_R table."
  GO TO exit_script
 ENDIF
 SET bb_report_mod_cat_r_cnt = 0
 SELECT INTO "nl:"
  r.module_categ_id
  FROM bb_report_mod_cat_r r
  WHERE r.module_categ_id > 0
  DETAIL
   bb_report_mod_cat_r_cnt = (bb_report_mod_cat_r_cnt+ 1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "No rows found on the BB_REPORT_MOD_CAT_R table."
  GO TO exit_script
 ENDIF
 SET bb_report_management_cnt = 0
 SELECT INTO "nl:"
  bb.report_id
  FROM bb_report_management bb
  WHERE bb.report_id > 0
  DETAIL
   bb_report_management_cnt = (bb_report_management_cnt+ 1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "No rows were found onthe BB_REPORT_MANAGEMENT table."
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "The Blood Bank report tables has been updated correctly."
 ENDIF
#exit_script
 EXECUTE dm_add_upt_setup_proc_log
END GO

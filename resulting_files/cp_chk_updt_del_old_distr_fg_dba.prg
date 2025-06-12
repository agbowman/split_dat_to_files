CREATE PROGRAM cp_chk_updt_del_old_distr_fg:dba
 SET nbr_records = 0
 SELECT INTO "nl:"
  cd.delete_old_distr_flag
  FROM chart_distribution cd
  WHERE cd.delete_old_distr_flag=null
   AND cd.distribution_id != 0
  DETAIL
   nbr_records += 1
  WITH nocounter
 ;end select
 IF (nbr_records=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "delete_old_distr_flag in chart_distribution table was successfully updated"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "delete_old_distr_flag in chart_dist_filter_value table update failed"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
 CALL echo(error_msg)
END GO

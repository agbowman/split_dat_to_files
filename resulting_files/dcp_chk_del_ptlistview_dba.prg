CREATE PROGRAM dcp_chk_del_ptlistview:dba
 SET request->setup_proc[1].process_id = 225
 SET request->setup_proc[1].success_ind = 1
 EXECUTE dm_add_upt_setup_proc_log
END GO

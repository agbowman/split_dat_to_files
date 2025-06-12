CREATE PROGRAM afc_chk_site_prefs:dba
 SET request->setup_proc[1].success_ind = 0
 SET count = 0
 SELECT INTO "nl:"
  di.info_domain
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="MAX QUANTITY"
  DETAIL
   count = (count+ 1)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET request->setup_proc[1].error_msg = "No errors ..."
  SET request->setup_proc[1].success_ind = 1
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO

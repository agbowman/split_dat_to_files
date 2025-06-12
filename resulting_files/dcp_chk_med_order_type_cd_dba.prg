CREATE PROGRAM dcp_chk_med_order_type_cd:dba
 SET iv_failures = 0
 SET med_failures = 0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=18309
   AND ((c.cdf_meaning="IV") OR (c.cdf_meaning="TPN"))
  DETAIL
   IF (c.definition != "IVSOLUTIONS")
    iv_failures = (iv_failures+ 1)
   ENDIF
  WITH check
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=18309
   AND c.definition != "IVSOLUTIONS"
  DETAIL
   IF (c.definition != "MEDICATIONS")
    med_failures = (med_failures+ 1)
   ENDIF
  WITH check
 ;end select
 SET request->setup_proc[1].process_id = 686
 IF (iv_failures=0
  AND med_failures=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "Update of IV's on med_order_type codeset SUCCEEDED, Update of MEDS on med_order_type codeset SUCCEEDED"
 ELSEIF (iv_failures > 0
  AND med_failures=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "Update of IV's on med_order_type codeset FAILED, Update of MEDS on med_order_type codeset SUCCEEDED"
 ELSEIF (iv_failures=0
  AND med_failures > 0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "Update of IV's on med_order_type codeset SUCCEEDED, Update of MEDS on med_order_type codeset FAILED"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "Update of IV's on med_order_type codeset FAILED, Update of MEDS on med_order_type codeset FAILED"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO

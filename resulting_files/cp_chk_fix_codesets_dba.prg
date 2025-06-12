CREATE PROGRAM cp_chk_fix_codesets:dba
 SET successful_ind = 0
 SELECT INTO "nl:"
  c.active_ind
  FROM code_value c
  WHERE c.code_set IN (14929, 14005)
   AND c.cdf_meaning IN ("PRELIM", "880", "1440", "1460", "1480",
  "1610", "1620", "1630", "1640", "1650",
  "1660", "1670", "240", "500", "780",
  "840", "860")
   AND c.active_ind=1
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET successful_ind = 1
 ENDIF
 IF (successful_ind > 0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "update process of active_ind on code_value table from 1 (active) to 0 (inactive) was not successful"
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "active_ind was successfully updated from 1 (active) to 0 (inactive) on code_value table for specified rows"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO

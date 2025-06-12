CREATE PROGRAM bbd_chk_posting_to_antigens:dba
 SET x = 0
 SET y = 0
 SELECT INTO "nl:"
  *
  FROM code_value_extension c
  PLAN (c
   WHERE c.code_set=1612
    AND c.field_name="PostToDonor")
  DETAIL
   x = (x+ 1)
  WITH nocounter, maxqual(c,1)
 ;end select
 IF (x > 0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "Rows exists for post to donor extension"
 ELSE
  SELECT INTO "nl:"
   *
   FROM code_value c
   PLAN (c
    WHERE c.code_set=1612
     AND c.active_ind=1)
   DETAIL
    y = (y+ 1)
   WITH nocounter, maxqual(c,1)
  ;end select
  IF (y=0)
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg = "No rows exist for code values for code set 1612"
  ELSE
   SET request->setup_proc[1].success_ind = 0
   SET request->setup_proc[1].error_msg =
   "Rows exists for code_values for 1612 and not for post to donor extension"
  ENDIF
 ENDIF
#exit_script
 EXECUTE dm_add_upt_setup_proc_log
END GO

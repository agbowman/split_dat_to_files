CREATE PROGRAM cp_ops_chk_pending_flag:dba
 SET nbr_records1 = 0
 SET nbr_records2 = 0
 SET nbr_records3 = 0
 SELECT DISTINCT INTO "nl:"
  c.charting_operations_id
  FROM charting_operations c
  DETAIL
   nbr_records1 += 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.param
  FROM charting_operations c
  WHERE c.param_type_flag=7
   AND c.param IN ("0", "1", "2")
  DETAIL
   nbr_records2 += 1
  WITH nocounter
 ;end select
 IF (nbr_records1=nbr_record2)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "pending_flag rows were successfully added to charting_operations table"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "pending_flag rows not added to all operations (param_type_flag = 7 and param = 6)"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
 SELECT INTO "nl:"
  c.param
  FROM charting_operations c
  WHERE c.param_type_flag=6
   AND c.sequence=7
  DETAIL
   nbr_records3 += 1
  WITH nocounter
 ;end select
 IF (nbr_records3=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "doctor sequences were increased correctly in charting_operations table"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "doctor sequences are not increased correctly (param_type_flag = 6 and sequence = 7)"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO

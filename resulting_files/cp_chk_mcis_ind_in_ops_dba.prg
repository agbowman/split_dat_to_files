CREATE PROGRAM cp_chk_mcis_ind_in_ops:dba
 SET nbr_records1 = 0
 SET nbr_records2 = 0
 SET nbr_records3 = 0
 SELECT DISTINCT INTO "nl:"
  c.charting_operations_id
  FROM charting_operations c
  ORDER BY c.charting_operations_id
  WITH nocounter
 ;end select
 SET nbr_records1 = curqual
 SELECT INTO "nl:"
  c.param
  FROM charting_operations c
  WHERE c.param_type_flag=8
   AND c.param IN ("0", "1")
  HEAD REPORT
   nbr_records2 = 0
  DETAIL
   nbr_records2 += 1
  WITH nocounter
 ;end select
 IF (nbr_records1=nbr_records2)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "mcis_ind rows were successfully added to charting_operations table"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "mcis_ind rows failed to add to all operations (param_type_flag = 8 and sequence=8)"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
 SELECT INTO "nl:"
  c.param
  FROM charting_operations c
  WHERE c.param_type_flag=6
   AND cnvtint(c.sequence) < 9
  WITH nocounter
 ;end select
 SET nbr_records3 = curqual
 IF (nbr_records3=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "doctor sequences were increased correctly in charting_operations table"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "doctor sequences are not increased correctly (param_type_flag = 6 and sequence < 10)"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO

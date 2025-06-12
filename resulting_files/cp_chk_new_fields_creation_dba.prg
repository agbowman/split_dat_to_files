CREATE PROGRAM cp_chk_new_fields_creation:dba
 SET nbr_records1 = 0
 SET nbr_records2 = 0
 SET nbr_records3 = 0
 SET nbr_records4 = 0
 SELECT INTO "nl:"
  cf.unique_ident
  FROM chart_format cf
  WHERE trim(cf.unique_ident)=null
   AND cf.chart_format_id != 0
  DETAIL
   nbr_records1 += 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cs.unique_ident
  FROM chart_section cs
  WHERE trim(cs.unique_ident)=null
   AND cs.chart_section_id != 0
  DETAIL
   nbr_records2 += 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cd.unique_ident
  FROM chart_distribution cd
  WHERE trim(cd.unique_ident)=null
   AND cd.distribution_id != 0
  DETAIL
   nbr_records3 += 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cges.procedure_type_flag
  FROM chart_grp_evnt_set cges
  WHERE cges.procedure_type_flag=null
   AND cges.chart_group_id != 0
  DETAIL
   nbr_records4 += 1
  WITH nocounter
 ;end select
 IF (nbr_records1=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "chart_format table was successfully updated with unique_ident column"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "chart_format table failed successful update with unique_ident column"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
 IF (nbr_records2=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "chart_section table was successfully updated with unique_ident column"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "chart_section table failed successful update with unique_ident column"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
 IF (nbr_records3=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "chart_distribution table was successfully updated with unique_ident column"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "chart_distribution table failed successful update with unique_ident column"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
 IF (nbr_records4=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "chart_grp_evnt_set table was successfully updated with procedure_type_flag column"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "chart_grp_evnt_set table failed successful update with procedure_type_flag column"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO

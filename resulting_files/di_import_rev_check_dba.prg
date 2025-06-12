CREATE PROGRAM di_import_rev_check:dba
 SET success_ind = 0
 SET error_msg = ""
 SET nbr = 0
 SET error_msg = "DI - no templates found"
 SELECT INTO "nl:"
  e.template_name
  FROM eks_template e
  WHERE e.template_name="DI*"
  DETAIL
   nbr = (nbr+ 1)
  WITH check, nocounter
 ;end select
 IF (curqual=0)
  GO TO end_of_check
 ENDIF
 SET error_msg = "DI - no modules found"
 SELECT INTO "nl:"
  e.module_name
  FROM eks_module e
  WHERE e.module_name="DI*"
  DETAIL
   nbr = (nbr+ 1)
  WITH check, nocounter
 ;end select
 IF (curqual=0)
  GO TO end_of_check
 ENDIF
 SET error_msg = "EKS - no eks_event entries"
 SELECT INTO "nl:"
  e.event_number
  FROM eks_event e
  WHERE e.event_number > 0
  WITH check, nocounter
 ;end select
 IF (curqual=0)
  GO TO end_of_check
 ENDIF
 SET error_msg = "EKS - no eks_request entries"
 SELECT INTO "nl:"
  e.request_number
  FROM eks_request e
  WHERE e.request_number > 0
  WITH check, nocounter
 ;end select
 IF (curqual=0)
  GO TO end_of_check
 ENDIF
 SET error_msg = "EKS - no request_processing entries for step 2221"
 SELECT INTO "nl:"
  r.request_number
  FROM request_processing r
  WHERE r.destination_step_id=2221
  WITH check, nocounter
 ;end select
 IF (curqual=0)
  GO TO end_of_check
 ENDIF
#end_of_check
 IF (curqual > 0)
  SET success_ind = 1
  SET error_msg = ""
 ELSE
  SET success_ind = 0
 ENDIF
 SET request->setup_proc[1].success_ind = success_ind
 SET request->setup_proc[1].error_msg = error_msg
 EXECUTE dm_add_upt_setup_proc_log
END GO

CREATE PROGRAM csm_eks_import_rev_check:dba
 SET success_ind = 0
 SET error_msg = ""
 SET nbr = 0
 SET error_msg = "EKS - no templates found"
 SELECT INTO "nl:"
  e.template_name
  FROM eks_template e
  WHERE e.template_name="CSM*"
  DETAIL
   nbr = (nbr+ 1)
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

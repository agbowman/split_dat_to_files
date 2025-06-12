CREATE PROGRAM acm_get_curr_logical_domain:dba
 IF ( NOT (validate(acm_get_curr_logical_domain_rep)))
  RECORD acm_get_curr_logical_domain_rep(
    1 logical_domain_id = f8
    1 status_block
      2 status_ind = i2
      2 error_code = i4
  )
 ENDIF
 DECLARE user_id = f8 WITH protect, noconstant(0.0)
 DECLARE success = i4 WITH protect, constant(true)
 DECLARE failure = i4 WITH protect, constant(false)
 DECLARE no_user = i4 WITH protect, constant(1)
 DECLARE invalid_ld_concept = i4 WITH protect, constant(3)
 IF (validate(reqinfo->updt_id))
  SET user_id = reqinfo->updt_id
 ELSE
  SET acm_get_curr_logical_domain_rep->status_block.status_ind = failure
  SET acm_get_curr_logical_domain_rep->status_block.error_code = no_user
  GO TO exit_script
 ENDIF
 IF ( NOT (validate(acm_get_curr_logical_domain_req->concept)))
  SET acm_get_curr_logical_domain_rep->status_block.status_ind = failure
  SET acm_get_curr_logical_domain_rep->status_block.error_code = invalid_ld_concept
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  p.logical_domain_id
  FROM prsnl p
  WHERE p.person_id=user_id
   AND p.active_ind=1
   AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  DETAIL
   acm_get_curr_logical_domain_rep->logical_domain_id = p.logical_domain_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET acm_get_curr_logical_domain_rep->status_block.status_ind = failure
 ELSE
  SET acm_get_curr_logical_domain_rep->status_block.status_ind = success
 ENDIF
#exit_script
END GO

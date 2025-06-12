CREATE PROGRAM acm_get_acc_logical_domains:dba
 IF ( NOT (validate(acm_get_acc_logical_domains_rep)))
  RECORD acm_get_acc_logical_domains_rep(
    1 logical_domain_grp_id = f8
    1 logical_domains_cnt = i4
    1 logical_domains[*]
      2 logical_domain_id = f8
    1 status_block
      2 status_ind = i2
      2 error_code = i4
  )
 ENDIF
 DECLARE get_current_ind = i4 WITH protect, noconstant(0)
 DECLARE user_id = f8 WITH protect, noconstant(0.0)
 DECLARE logical_domain_count = i4 WITH protect, noconstant(0)
 DECLARE logical_domain_grp_id = f8 WITH protect, noconstant(0.0)
 DECLARE success = i4 WITH protect, constant(true)
 DECLARE failure = i4 WITH protect, constant(false)
 DECLARE no_user = i4 WITH protect, constant(1)
 DECLARE no_logical_domains = i4 WITH protect, constant(2)
 DECLARE invalid_ld_concept = i4 WITH protect, constant(3)
 IF (validate(acm_get_acc_logical_domains_req->write_mode_ind))
  SET get_current_ind = acm_get_acc_logical_domains_req->write_mode_ind
 ENDIF
 IF ( NOT (validate(acm_get_acc_logical_domains_req->concept)))
  SET acm_get_acc_logical_domains_rep->status_block.status_ind = failure
  SET acm_get_acc_logical_domains_rep->status_block.error_code = invalid_ld_concept
  GO TO exit_script
 ENDIF
 IF (validate(reqinfo->updt_id))
  SET user_id = reqinfo->updt_id
 ELSE
  SET acm_get_acc_logical_domains_rep->status_block.status_ind = failure
  SET acm_get_acc_logical_domains_rep->status_block.error_code = no_user
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  p.logical_domain_id, p.logical_domain_grp_id
  FROM prsnl p
  WHERE p.person_id=user_id
   AND p.active_ind=1
   AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  DETAIL
   logical_domain_grp_id = p.logical_domain_grp_id
   IF (((logical_domain_grp_id=0.0) OR (get_current_ind=1)) )
    logical_domain_count = 1, acm_get_acc_logical_domains_rep->logical_domains_cnt =
    logical_domain_count, stat = alterlist(acm_get_acc_logical_domains_rep->logical_domains,
     logical_domain_count),
    acm_get_acc_logical_domains_rep->logical_domains[logical_domain_count].logical_domain_id = p
    .logical_domain_id, acm_get_acc_logical_domains_rep->status_block.status_ind = success
   ENDIF
  WITH nocounter
 ;end select
 IF (logical_domain_grp_id > 0.0
  AND get_current_ind=0)
  SELECT INTO "nl:"
   ld.logical_domain_id
   FROM logical_domain_grp_reltn ld
   WHERE ld.logical_domain_grp_id=logical_domain_grp_id
    AND ld.active_ind=1
    AND ld.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND ld.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
   HEAD ld.logical_domain_grp_id
    acm_get_acc_logical_domains_rep->logical_domain_grp_id = ld.logical_domain_grp_id,
    logical_domain_count = 0
   DETAIL
    logical_domain_count = (logical_domain_count+ 1)
    IF (mod(logical_domain_count,10)=1)
     stat = alterlist(acm_get_acc_logical_domains_rep->logical_domains,(logical_domain_count+ 9))
    ENDIF
    acm_get_acc_logical_domains_rep->logical_domains[logical_domain_count].logical_domain_id = ld
    .logical_domain_id
   FOOT REPORT
    stat = alterlist(acm_get_acc_logical_domains_rep->logical_domains,logical_domain_count),
    acm_get_acc_logical_domains_rep->logical_domains_cnt = logical_domain_count
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET acm_get_acc_logical_domains_rep->status_block.status_ind = failure
  SET acm_get_acc_logical_domains_rep->status_block.error_code = no_logical_domains
 ELSE
  SET acm_get_acc_logical_domains_rep->status_block.status_ind = success
 ENDIF
#exit_script
END GO

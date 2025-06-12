CREATE PROGRAM bed_get_ep_erx:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 providers[*]
      2 eligible_provider_id = f8
      2 name_full_formatted = vc
      2 person_id = f8
      2 username = vc
      2 active_ind = i2
      2 effective_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE ep_prsnl_parse = vc
 SET ep_prsnl_parse = "p.person_id = bep.provider_id"
 SET data_partition_ind = 0
 SET field_found = 0
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
  SET prg_exists_ind = 0
  SET prg_exists_ind = checkprg("ACM_GET_ACC_LOGICAL_DOMAINS")
  IF (prg_exists_ind > 0)
   SET field_found = 0
   RANGE OF p IS prsnl
   SET field_found = validate(p.logical_domain_id)
   FREE RANGE p
   IF (field_found=1)
    SET data_partition_ind = 1
    FREE SET acm_get_acc_logical_domains_req
    RECORD acm_get_acc_logical_domains_req(
      1 write_mode_ind = i2
      1 concept = i4
    )
    FREE SET acm_get_acc_logical_domains_rep
    RECORD acm_get_acc_logical_domains_rep(
      1 logical_domain_grp_id = f8
      1 logical_domains_cnt = i4
      1 logical_domains[*]
        2 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET acm_get_acc_logical_domains_req->write_mode_ind = 0
    SET acm_get_acc_logical_domains_req->concept = 2
    EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
    replace("REPLY",acm_get_acc_logical_domains_rep)
   ENDIF
  ENDIF
 ENDIF
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET ep_prsnl_parse = concat(ep_prsnl_parse," and p.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET ep_prsnl_parse = build(ep_prsnl_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
     ELSE
      SET ep_prsnl_parse = build(ep_prsnl_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 DECLARE count = i4
 DECLARE tempcount = i4
 SELECT INTO "nl:"
  FROM br_eligible_provider bep,
   prsnl p
  PLAN (bep
   WHERE bep.br_eligible_provider_id > 0
    AND bep.erx_submission_ind=1
    AND bep.active_ind=1
    AND bep.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE parser(ep_prsnl_parse))
  HEAD REPORT
   count = 0, tempcount = 0, stat = alterlist(reply->providers,10)
  DETAIL
   count = (count+ 1), tempcount = (tempcount+ 1)
   IF (tempcount > 10)
    tempcount = 0, stat = alterlist(reply->providers,(count+ 10))
   ENDIF
   reply->providers[count].eligible_provider_id = bep.br_eligible_provider_id, reply->providers[count
   ].person_id = p.person_id, reply->providers[count].name_full_formatted = p.name_full_formatted,
   reply->providers[count].username = p.username, reply->providers[count].active_ind = p.active_ind
   IF (p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    reply->providers[count].effective_ind = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->providers,count)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error selecting eligible providers.")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO

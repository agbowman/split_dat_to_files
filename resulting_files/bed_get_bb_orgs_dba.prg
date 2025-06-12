CREATE PROGRAM bed_get_bb_orgs:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 orglist[*]
      2 organization_id = f8
      2 organization_name = vc
      2 typelist[*]
        3 org_type_code_value = f8
        3 org_type_display = vc
        3 org_type_meaning = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 too_many_results_ind = i2
  ) WITH protect
 ENDIF
 DECLARE max_limit = i4 WITH protect, constant(5000)
 SET reply->status_data.status = "F"
 SET ocnt = 0
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 SET max_cnt = max_limit
 DECLARE auth_cd = f8
 DECLARE org_cd = f8
 DECLARE error_flag = i2
 SET error_flag = 0
 SET auth_cd = 0.0
 SET org_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=8
    AND cv.cdf_meaning="AUTH"
    AND cv.active_ind=1)
  DETAIL
   auth_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (((auth_cd=0.0) OR (curqual > 1)) )
  SET error_flag = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=396
    AND cv.cdf_meaning="ORG"
    AND cv.active_ind=1)
  DETAIL
   org_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (((org_cd=0.0) OR (curqual > 1)) )
  SET error_flag = 1
  GO TO exit_script
 ENDIF
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
   RANGE OF o IS organization
   SET field_found = validate(o.logical_domain_id)
   FREE RANGE o
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
    SET acm_get_acc_logical_domains_req->concept = 3
    EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
    replace("REPLY",acm_get_acc_logical_domains_rep)
   ENDIF
  ENDIF
 ENDIF
 DECLARE org_parse = vc
 SET org_parse = "o.active_ind = 1"
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET org_parse = concat(org_parse," and o.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET org_parse = build(org_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
     ELSE
      SET org_parse = build(org_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF ((request->search_txt > " "))
  IF (cnvtupper(request->search_type_flag)="C")
   SET org_parse = build(org_parse," and cnvtupper(o.org_name) = '*",cnvtupper(request->search_txt),
    "*'")
  ELSE
   SET org_parse = build(org_parse," and cnvtupper(o.org_name) = '",cnvtupper(request->search_txt),
    "*'")
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM organization o,
   org_type_reltn otr,
   code_value cv
  PLAN (o
   WHERE o.org_class_cd=org_cd
    AND parser(org_parse)
    AND o.data_status_cd=auth_cd
    AND o.organization_id > 0
    AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND o.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (otr
   WHERE otr.organization_id=o.organization_id
    AND otr.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=otr.org_type_cd)
  ORDER BY o.org_name
  HEAD REPORT
   ocnt = 0, tcnt = 0
  HEAD o.org_name
   tcnt = 0, ocnt = (ocnt+ 1), stat = alterlist(reply->orglist,ocnt),
   reply->orglist[ocnt].organization_id = o.organization_id, reply->orglist[ocnt].organization_name
    = o.org_name
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(reply->orglist[ocnt].typelist,tcnt), reply->orglist[ocnt].
   typelist[tcnt].org_type_code_value = otr.org_type_cd,
   reply->orglist[ocnt].typelist[tcnt].org_type_display = cv.display, reply->orglist[ocnt].typelist[
   tcnt].org_type_meaning = cv.cdf_meaning
  WITH nocounter
 ;end select
 IF (ocnt=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 IF (error_flag=1)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 IF (ocnt > max_cnt)
  SET stat = alterlist(reply->orglist,0)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO

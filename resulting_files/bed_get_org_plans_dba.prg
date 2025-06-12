CREATE PROGRAM bed_get_org_plans:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 org_plans[*]
      2 code_value = f8
      2 display = vc
      2 mean = vc
      2 organizations[*]
        3 id = f8
        3 name = vc
        3 group_number = vc
        3 group_name = vc
        3 org_plan_reltn_id = f8
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
 DECLARE opcnt = i2 WITH protect, noconstant(0)
 DECLARE ocnt = i2 WITH protect, noconstant(0)
 SET wcard = "*"
 SET reply->status_data.status = "F"
 SET data_found = "N"
 SET reply->too_many_results_ind = 0
 SET max_cnt = max_limit
 DECLARE search_string = vc WITH protect
 DECLARE sstring = vc WITH protect
 IF (trim(request->search_txt) > " ")
  SET sstring = trim(cnvtalphanum(request->search_txt))
  IF ((request->search_type_flag="S"))
   SET search_string = concat(cnvtupper(sstring),wcard)
  ELSE
   SET search_string = concat(wcard,cnvtupper(sstring),wcard)
  ENDIF
  SET search_string = replace(search_string," ","")
 ELSE
  SET search_string = wcard
 ENDIF
 CALL echo(build("search_string:",search_string))
 IF (size(request->org_plan_reltns,5) > 0)
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
  DECLARE org_name_parse = vc
  SET org_name_parse = concat("o.org_name_key = '",search_string,"'")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(request->org_plan_reltns,5))),
    org_plan_reltn opr,
    code_value cv,
    organization o
   PLAN (d)
    JOIN (opr
    WHERE (opr.health_plan_id=request->plan_id)
     AND (opr.org_plan_reltn_cd=request->org_plan_reltns[d.seq].code_value)
     AND opr.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=opr.org_plan_reltn_cd)
    JOIN (o
    WHERE o.organization_id=opr.organization_id
     AND parser(org_parse)
     AND parser(org_name_parse))
   HEAD REPORT
    opcnt = 0, ocnt = 0
   HEAD opr.org_plan_reltn_cd
    ocnt = 0, opcnt = (opcnt+ 1), stat = alterlist(reply->org_plans,opcnt),
    reply->org_plans[opcnt].code_value = opr.org_plan_reltn_cd, reply->org_plans[opcnt].display = cv
    .display, reply->org_plans[opcnt].mean = cv.cdf_meaning
   DETAIL
    ocnt = (ocnt+ 1), stat = alterlist(reply->org_plans[opcnt].organizations,ocnt), reply->org_plans[
    opcnt].organizations[ocnt].id = opr.organization_id,
    reply->org_plans[opcnt].organizations[ocnt].name = o.org_name, reply->org_plans[opcnt].
    organizations[ocnt].group_number = opr.group_nbr, reply->org_plans[opcnt].organizations[ocnt].
    group_name = opr.group_name,
    reply->org_plans[opcnt].organizations[ocnt].org_plan_reltn_id = opr.org_plan_reltn_id
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET data_found = "Y"
  ENDIF
  IF (ocnt > max_cnt)
   SET stat = alterlist(reply->org_plans,0)
   SET reply->too_many_results_ind = 1
   SET reply->status_data.status = "S"
   SET data_found = "Y"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
#exit_script
 IF (data_found="Y")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO

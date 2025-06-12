CREATE PROGRAM bed_get_cs_outreach_clients:dba
 FREE SET reply
 RECORD reply(
   1 available_clients[*]
     2 id = f8
     2 name = vc
     2 outreach_ind = i2
   1 selected_clients[*]
     2 id = f8
     2 name = vc
     2 outreach_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 SET tech_cd = 0.0
 SET outreach_cd = 0.0
 SET client_cd = 0.0
 SET wcard = "*"
 SET max_cnt = 0
 IF ((request->max_reply_limit > 0))
  SET max_cnt = request->max_reply_limit
 ELSE
  SET max_cnt = 1000000
 ENDIF
 DECLARE search_string = vc
 DECLARE sstring = vc
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
 DECLARE org_name_parse = vc
 SET org_name_parse = concat("o.org_name_key = '",search_string,"'")
 IF ((request->show_inactive_ind=0))
  SET org_name_parse = concat(org_name_parse," and o.active_ind = 1")
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
   SET org_name_parse = concat(org_name_parse," and o.logical_domain_id in (")
   SET org_parse = concat(org_parse," and o.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET org_name_parse = build(org_name_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
      SET org_parse = build(org_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
     ELSE
      SET org_name_parse = build(org_name_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
      SET org_parse = build(org_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=13031
    AND cv.cdf_meaning IN ("TIERGROUP", "CLTTIERGROUP")
    AND cv.active_ind=1)
  ORDER BY cv.code_value DESC
  DETAIL
   IF (cv.cdf_meaning="TIERGROUP")
    tech_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="CLTTIERGROUP")
    outreach_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=278
    AND cv.cdf_meaning="CLIENT"
    AND cv.active_ind=1)
  DETAIL
   client_cd = cv.code_value
  WITH nocounter
 ;end select
 SET scnt = 0
 SELECT INTO "nl:"
  FROM bill_org_payor b,
   organization o
  PLAN (b
   WHERE b.bill_org_type_cd=outreach_cd
    AND (b.bill_org_type_id=request->outreach_tier_code_value)
    AND b.active_ind=1)
   JOIN (o
   WHERE o.organization_id=b.organization_id
    AND parser(org_parse))
  ORDER BY o.org_name
  HEAD o.org_name
   scnt = (scnt+ 1), stat = alterlist(reply->selected_clients,scnt), reply->selected_clients[scnt].id
    = o.organization_id,
   reply->selected_clients[scnt].name = o.org_name
  WITH nocounter
 ;end select
 IF ((request->only_outreach_ind=1))
  SET acnt = 0
  SELECT INTO "nl:"
   FROM br_organization bo,
    organization o
   PLAN (bo
    WHERE bo.outreach_ind=1
     AND  NOT ( EXISTS (
    (SELECT
     b.organization_id
     FROM bill_org_payor b
     WHERE b.organization_id=bo.organization_id
      AND b.bill_org_type_cd IN (tech_cd, outreach_cd)
      AND b.active_ind=1))))
    JOIN (o
    WHERE o.organization_id=bo.organization_id
     AND parser(org_name_parse))
   ORDER BY o.org_name
   HEAD o.org_name
    acnt = (acnt+ 1), stat = alterlist(reply->available_clients,acnt), reply->available_clients[acnt]
    .id = o.organization_id,
    reply->available_clients[acnt].name = o.org_name
   WITH nocounter, maxqual(o,value((max_cnt+ 2)))
  ;end select
 ELSE
  SET acnt = 0
  SELECT INTO "nl:"
   FROM organization o,
    org_type_reltn otr
   PLAN (o
    WHERE parser(org_name_parse)
     AND  NOT ( EXISTS (
    (SELECT
     b.organization_id
     FROM bill_org_payor b
     WHERE b.organization_id=o.organization_id
      AND b.bill_org_type_cd IN (tech_cd, outreach_cd)
      AND b.active_ind=1))))
    JOIN (otr
    WHERE otr.organization_id=o.organization_id
     AND otr.org_type_cd=client_cd
     AND otr.active_ind=1)
   ORDER BY o.org_name
   HEAD o.org_name
    acnt = (acnt+ 1), stat = alterlist(reply->available_clients,acnt), reply->available_clients[acnt]
    .id = o.organization_id,
    reply->available_clients[acnt].name = o.org_name
   WITH nocounter, maxqual(o,value((max_cnt+ 2)))
  ;end select
 ENDIF
 IF (scnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(scnt)),
    br_organization b
   PLAN (d)
    JOIN (b
    WHERE (b.organization_id=reply->selected_clients[d.seq].id))
   ORDER BY d.seq
   HEAD d.seq
    reply->selected_clients[d.seq].outreach_ind = b.outreach_ind
   WITH nocounter
  ;end select
 ENDIF
 IF (acnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(acnt)),
    br_organization b
   PLAN (d)
    JOIN (b
    WHERE (b.organization_id=reply->available_clients[d.seq].id))
   ORDER BY d.seq
   HEAD d.seq
    reply->available_clients[d.seq].outreach_ind = b.outreach_ind
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (acnt > 0)
  IF (acnt > max_cnt)
   SET reply->too_many_results_ind = 1
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 IF ((reply->too_many_results_ind=1))
  SET stat = alterlist(reply->available_clients,0)
 ENDIF
 CALL echorecord(reply)
END GO

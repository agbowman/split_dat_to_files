CREATE PROGRAM bed_get_cs_outreach_orgs:dba
 FREE SET reply
 RECORD reply(
   1 organizations[*]
     2 id = f8
     2 name = vc
     2 prefix = vc
     2 outreach_tier_code_value = f8
     2 outreach_clients_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tech_cd = 0.0
 SET prof_cd = 0.0
 SET outreach_cd = 0.0
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
 SET ocnt = 0
 SELECT INTO "nl:"
  FROM bill_org_payor b1,
   organization o
  PLAN (b1
   WHERE b1.bill_org_type_cd=tech_cd
    AND b1.active_ind=1)
   JOIN (o
   WHERE o.organization_id=b1.organization_id
    AND parser(org_parse))
  ORDER BY o.org_name
  HEAD o.org_name
   ocnt = (ocnt+ 1), stat = alterlist(reply->organizations,ocnt), reply->organizations[ocnt].id = o
   .organization_id,
   reply->organizations[ocnt].name = o.org_name
  WITH nocounter
 ;end select
 IF (ocnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ocnt)),
    bill_org_payor b
   PLAN (d)
    JOIN (b
    WHERE (b.organization_id=reply->organizations[d.seq].id)
     AND b.bill_org_type_cd=outreach_cd
     AND b.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    reply->organizations[d.seq].outreach_tier_code_value = b.bill_org_type_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ocnt)),
    br_organization b
   PLAN (d)
    JOIN (b
    WHERE (b.organization_id=reply->organizations[d.seq].id))
   ORDER BY d.seq
   HEAD d.seq
    reply->organizations[d.seq].prefix = b.br_prefix
   WITH nocounter
  ;end select
 ENDIF
 FOR (i = 1 TO ocnt)
   SELECT INTO "NL:"
    number = count(*)
    FROM bill_org_payor b
    PLAN (b
     WHERE (b.bill_org_type_id=reply->organizations[i].outreach_tier_code_value)
      AND b.active_ind=1)
    DETAIL
     IF (number > 1)
      reply->organizations[i].outreach_clients_ind = 1
     ELSE
      reply->organizations[i].outreach_clients_ind = 0
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 CALL echorecord(reply)
#exit_script
 IF (ocnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

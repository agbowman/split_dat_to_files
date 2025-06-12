CREATE PROGRAM bed_get_cs_outreach_tiers:dba
 FREE SET reply
 RECORD reply(
   1 tiers[*]
     2 code_value = f8
     2 display = vc
     2 organizations[*]
       3 id = f8
       3 name = vc
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
 SET outreach_cd = 0.0
 RECORD temp(
   1 tier[*]
     2 use_ind = i2
     2 cd = f8
     2 display = vc
     2 org[*]
       3 id = f8
       3 name = vc
 )
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
 SET tcnt = 0
 SET ocnt = 0
 SELECT INTO "nl:"
  FROM bill_org_payor b,
   code_value c,
   organization o
  PLAN (b
   WHERE b.bill_org_type_cd=outreach_cd
    AND b.active_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    b1.organization_id
    FROM bill_org_payor b1
    WHERE b1.organization_id=b.organization_id
     AND b1.bill_org_type_cd=tech_cd
     AND b1.active_ind=1))))
   JOIN (c
   WHERE c.code_value=b.bill_org_type_id)
   JOIN (o
   WHERE o.organization_id=b.organization_id
    AND parser(org_parse))
  ORDER BY c.display, o.org_name
  HEAD c.display
   ocnt = 0, tcnt = (tcnt+ 1), stat = alterlist(temp->tier,tcnt),
   temp->tier[tcnt].cd = c.code_value, temp->tier[tcnt].display = c.display, temp->tier[tcnt].use_ind
    = 1
  DETAIL
   ocnt = (ocnt+ 1), stat = alterlist(temp->tier[tcnt].org,ocnt), temp->tier[tcnt].org[ocnt].id = o
   .organization_id,
   temp->tier[tcnt].org[ocnt].name = o.org_name
  WITH nocounter
 ;end select
 IF (tcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tcnt)),
    bill_org_payor b1,
    bill_org_payor b2
   PLAN (d)
    JOIN (b1
    WHERE (b1.bill_org_type_id=temp->tier[d.seq].cd))
    JOIN (b2
    WHERE b2.organization_id=b1.organization_id
     AND b2.bill_org_type_cd=tech_cd)
   ORDER BY d.seq
   HEAD d.seq
    temp->tier[d.seq].use_ind = 0
   WITH nocounter
  ;end select
 ENDIF
 SET cnt = 0
 SET cnt2 = 0
 FOR (x = 1 TO tcnt)
   IF ((temp->tier[x].use_ind=1))
    SET cnt = (cnt+ 1)
    SET stat = alterlist(reply->tiers,cnt)
    SET reply->tiers[cnt].code_value = temp->tier[x].cd
    SET reply->tiers[cnt].display = temp->tier[x].display
    SET cnt2 = size(temp->tier[x].org,5)
    FOR (y = 1 TO cnt2)
      SET stat = alterlist(reply->tiers[cnt].organizations,cnt2)
      SET reply->tiers[cnt].organizations[cnt2].id = temp->tier[x].org[y].id
      SET reply->tiers[cnt].organizations[cnt2].name = temp->tier[x].org[y].name
    ENDFOR
   ENDIF
 ENDFOR
 CALL echorecord(reply)
#exit_script
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

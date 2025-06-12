CREATE PROGRAM bed_get_org_by_org_group:dba
 FREE SET reply
 RECORD reply(
   01 name = vc
   01 active_ind = i2
   01 description = vc
   01 org[*]
     02 org_set_org_r_id = f8
     02 organization_id = f8
     02 org_name = vc
     02 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD treply(
   01 org[*]
     02 org_set_org_r_id = f8
     02 organization_id = f8
     02 org_name = vc
     02 active_ind = i2
 )
 DECLARE iic = i2
 SET iic = 0
 SET iic = request->include_inactive_child_ind
 SET reply->status_data.status = "F"
 SET ocnt = 0
 CALL echo(build("org_set_id:",request->org_set_id))
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
 SET org_parse = "o.organization_id = osor.organization_id"
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
 SELECT INTO "NL:"
  FROM org_set os
  WHERE (os.org_set_id=request->org_set_id)
  DETAIL
   reply->name = os.name, reply->description = os.description, reply->active_ind = os.active_ind
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM org_set_org_r osor,
   organization o
  PLAN (osor
   WHERE (osor.org_set_id=request->org_set_id)
    AND ((iic=1) OR (osor.active_ind=1)) )
   JOIN (o
   WHERE parser(org_parse)
    AND ((iic=1) OR (o.active_ind=1)) )
  DETAIL
   ocnt = (ocnt+ 1), stat = alterlist(reply->org,ocnt), reply->org[ocnt].org_set_org_r_id = osor
   .org_set_org_r_id,
   reply->org[ocnt].organization_id = o.organization_id, reply->org[ocnt].org_name = o.org_name,
   reply->org[ocnt].active_ind = osor.active_ind
  WITH nocounter
 ;end select
 CALL echo(build("ocnt:",ocnt))
 IF ((reply->name > " "))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO

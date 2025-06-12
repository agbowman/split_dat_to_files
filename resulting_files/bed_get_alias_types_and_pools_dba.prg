CREATE PROGRAM bed_get_alias_types_and_pools:dba
 FREE SET reply
 RECORD reply(
   1 alias_types[*]
     2 code_value = f8
     2 disp = vc
     2 mean = vc
     2 entity_name = vc
     2 alias_pools[*]
       3 code_value = f8
       3 disp = vc
       3 mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
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
   RANGE OF a IS alias_pool
   SET field_found = validate(a.logical_domain_id)
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
    SET acm_get_acc_logical_domains_req->concept = 5
    EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
    replace("REPLY",acm_get_acc_logical_domains_rep)
   ENDIF
  ENDIF
 ENDIF
 DECLARE ap_parse = vc
 SET ap_parse = "a.alias_pool_cd = o.alias_pool_cd"
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET ap_parse = concat(ap_parse," and a.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET ap_parse = build(ap_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
     ELSE
      SET ap_parse = build(ap_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM org_alias_pool_reltn o,
   alias_pool a,
   code_value cv_type,
   code_value cv_pool
  PLAN (o
   WHERE o.alias_entity_name IN ("PERSON_ALIAS", "PRSNL_ALIAS")
    AND o.active_ind=1)
   JOIN (a
   WHERE parser(ap_parse)
    AND a.active_ind=1)
   JOIN (cv_type
   WHERE cv_type.code_value=o.alias_entity_alias_type_cd
    AND cv_type.active_ind=1)
   JOIN (cv_pool
   WHERE cv_pool.code_value=a.alias_pool_cd
    AND cv_pool.active_ind=1)
  ORDER BY o.alias_entity_alias_type_cd, o.alias_pool_cd
  HEAD o.alias_entity_alias_type_cd
   tcnt = (tcnt+ 1), stat = alterlist(reply->alias_types,tcnt), reply->alias_types[tcnt].code_value
    = cv_type.code_value,
   reply->alias_types[tcnt].disp = cv_type.display, reply->alias_types[tcnt].mean = cv_type
   .cdf_meaning, reply->alias_types[tcnt].entity_name = o.alias_entity_name,
   pcnt = 0
  HEAD o.alias_pool_cd
   pcnt = (pcnt+ 1), stat = alterlist(reply->alias_types[tcnt].alias_pools,pcnt), reply->alias_types[
   tcnt].alias_pools[pcnt].code_value = cv_pool.code_value,
   reply->alias_types[tcnt].alias_pools[pcnt].disp = cv_pool.display, reply->alias_types[tcnt].
   alias_pools[pcnt].mean = cv_pool.cdf_meaning
  WITH nocounter
 ;end select
#exit_script
 IF (tcnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO

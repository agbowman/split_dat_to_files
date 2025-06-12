CREATE PROGRAM bed_get_health_plan_alias:dba
 FREE SET reply
 RECORD reply(
   1 alias_types[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
     2 alias_pools[*]
       3 code_value = f8
       3 display = vc
       3 mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET data_partition_ind = 0
 SET logical_domain_id = 0
 SET field_found = 0
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
  SET prg_exists_ind = 0
  SET prg_exists_ind = checkprg("ACM_GET_CURR_LOGICAL_DOMAIN")
  IF (prg_exists_ind > 0)
   SET field_found = 0
   RANGE OF o IS organization
   SET field_found = validate(o.logical_domain_id)
   FREE RANGE o
   IF (field_found=1)
    SET data_partition_ind = 1
    FREE SET acm_get_curr_logical_domain_req
    RECORD acm_get_curr_logical_domain_req(
      1 concept = i4
    )
    FREE SET acm_get_curr_logical_domain_rep
    RECORD acm_get_curr_logical_domain_rep(
      1 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET acm_get_curr_logical_domain_req->concept = 3
    EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
    replace("REPLY",acm_get_curr_logical_domain_rep)
   ENDIF
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM org_alias_pool_reltn o,
   code_value cv1,
   code_value cv2,
   organization org
  PLAN (o
   WHERE o.alias_entity_name=trim(request->alias_entity_name)
    AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND o.active_ind=1)
   JOIN (org
   WHERE org.organization_id=o.organization_id
    AND (org.logical_domain_id=acm_get_curr_logical_domain_rep->logical_domain_id))
   JOIN (cv1
   WHERE cv1.code_value=o.alias_entity_alias_type_cd)
   JOIN (cv2
   WHERE cv2.code_value=o.alias_pool_cd)
  ORDER BY o.alias_entity_alias_type_cd, o.alias_pool_cd
  HEAD REPORT
   tcnt = 0, pcnt = 0
  HEAD o.alias_entity_alias_type_cd
   pcnt = 0, tcnt = (tcnt+ 1), stat = alterlist(reply->alias_types,tcnt),
   reply->alias_types[tcnt].code_value = o.alias_entity_alias_type_cd, reply->alias_types[tcnt].
   display = cv1.display, reply->alias_types[tcnt].mean = cv1.cdf_meaning
  HEAD o.alias_pool_cd
   pcnt = (pcnt+ 1), stat = alterlist(reply->alias_types[tcnt].alias_pools,pcnt), reply->alias_types[
   tcnt].alias_pools[pcnt].code_value = o.alias_pool_cd,
   reply->alias_types[tcnt].alias_pools[pcnt].display = cv2.display, reply->alias_types[tcnt].
   alias_pools[pcnt].mean = cv2.cdf_meaning
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO

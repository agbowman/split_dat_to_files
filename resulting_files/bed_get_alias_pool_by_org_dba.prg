CREATE PROGRAM bed_get_alias_pool_by_org:dba
 FREE SET reply
 RECORD reply(
   1 alias_pools[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
     2 alias_type_code
       3 code_value = f8
       3 display = vc
       3 mean = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
    SET acm_get_acc_logical_domains_req->concept = 5
    EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
    replace("REPLY",acm_get_acc_logical_domains_rep)
   ENDIF
  ENDIF
 ENDIF
 DECLARE ap_parse = vc
 SET ap_parse = "ap.active_ind = 1"
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET ap_parse = concat(ap_parse," and ap.logical_domain_id in (")
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
 DECLARE apcnt = i4
 DECLARE error_msg = vc
 SET error_flag = "F"
 SET apcnt = 0
 IF ((request->related_ind=0))
  SELECT INTO "nl:"
   FROM org_alias_pool_reltn oapr,
    code_value cv,
    alias_pool ap,
    code_value cv1
   PLAN (oapr
    WHERE (oapr.organization_id=request->org_id)
     AND oapr.active_ind=1)
    JOIN (ap
    WHERE parser(ap_parse)
     AND ap.alias_pool_cd=oapr.alias_pool_cd)
    JOIN (cv
    WHERE cv.code_value=oapr.alias_pool_cd)
    JOIN (cv1
    WHERE cv1.code_value=oapr.alias_entity_alias_type_cd)
   DETAIL
    apcnt = (apcnt+ 1), stat = alterlist(reply->alias_pools,apcnt), reply->alias_pools[apcnt].
    code_value = oapr.alias_pool_cd,
    reply->alias_pools[apcnt].display = cv.display, reply->alias_pools[apcnt].mean = cv.cdf_meaning,
    reply->alias_pools[apcnt].alias_type_code.code_value = oapr.alias_entity_alias_type_cd,
    reply->alias_pools[apcnt].alias_type_code.display = cv1.display, reply->alias_pools[apcnt].
    alias_type_code.mean = cv1.cdf_meaning
   WITH nocounter
  ;end select
 ELSEIF ((request->related_ind=1))
  SELECT INTO "nl:"
   FROM alias_pool ap,
    org_alias_pool_reltn oapr,
    code_value cv,
    dummyt d1
   PLAN (ap
    WHERE parser(ap_parse))
    JOIN (cv
    WHERE cv.code_value=ap.alias_pool_cd)
    JOIN (d1)
    JOIN (oapr
    WHERE oapr.alias_pool_cd=ap.alias_pool_cd)
   DETAIL
    apcnt = (apcnt+ 1), stat = alterlist(reply->alias_pools,apcnt), reply->alias_pools[apcnt].
    code_value = ap.alias_pool_cd,
    reply->alias_pools[apcnt].display = cv.display, reply->alias_pools[apcnt].mean = cv.cdf_meaning
   WITH nocounter, outerjoin = d1, dontexist
  ;end select
 ENDIF
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(" >> PROGRAM NAME: BED_GET_ALIAS_POOL_BY_ORG  >> ERROR MESSAGE: ",
   error_msg)
 ELSEIF (apcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO

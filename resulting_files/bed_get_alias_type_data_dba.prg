CREATE PROGRAM bed_get_alias_type_data:dba
 FREE SET reply
 RECORD reply(
   1 alias_type_list[*]
     2 alias_type_code_value = f8
     2 alias_type_disp = vc
     2 alias_type_mean = vc
     2 alias_entity_name = vc
     2 alias_pool_list[*]
       3 alias_pool_code_value = f8
       3 alias_pool_disp = vc
       3 alias_pool_mean = vc
       3 org_id = f8
       3 org_name = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "F"
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET found_alias_types = 0
 SET alcnt = 0
 SET apcnt = 0
 SET orgcnt = 0
 SET listcnt = 0
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
 SET org_parse = "o.organization_id = org.organization_id"
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET org_parse = concat(org_parse," and org.logical_domain_id in (")
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
 SET stat = alterlist(reply->alias_type_list,10)
 SELECT INTO "nl:"
  FROM code_value cv,
   org_alias_pool_reltn oa
  PLAN (cv
   WHERE cv.code_set=320)
   JOIN (oa
   WHERE oa.alias_entity_alias_type_cd=cv.code_value)
  ORDER BY cv.code_value
  HEAD cv.code_value
   alcnt = (alcnt+ 1), listcnt = (listcnt+ 1)
   IF (listcnt=10)
    listcnt = 0, stat = alterlist(reply->alias_type_list,(alcnt+ 10))
   ENDIF
   reply->alias_type_list[alcnt].alias_type_code_value = cv.code_value, reply->alias_type_list[alcnt]
   .alias_type_disp = cv.display, reply->alias_type_list[alcnt].alias_type_mean = cv.cdf_meaning,
   reply->alias_type_list[alcnt].alias_entity_name = "PRSNL_ALIAS"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET found_alias_types = 1
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv,
   org_alias_pool_reltn oa
  PLAN (cv
   WHERE cv.code_set=4)
   JOIN (oa
   WHERE oa.alias_entity_alias_type_cd=cv.code_value)
  ORDER BY cv.code_value
  HEAD cv.code_value
   alcnt = (alcnt+ 1), listcnt = (listcnt+ 1)
   IF (listcnt=10)
    listcnt = 0, stat = alterlist(reply->alias_type_list,(alcnt+ 10))
   ENDIF
   reply->alias_type_list[alcnt].alias_type_code_value = cv.code_value, reply->alias_type_list[alcnt]
   .alias_type_disp = cv.display, reply->alias_type_list[alcnt].alias_type_mean = cv.cdf_meaning,
   reply->alias_type_list[alcnt].alias_entity_name = "PERSON_ALIAS"
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->alias_type_list,alcnt)
 FOR (i = 1 TO alcnt)
  SET apcnt = 0
  SELECT INTO "nl:"
   FROM org_alias_pool_reltn o,
    code_value cv,
    organization org
   PLAN (o
    WHERE (o.alias_entity_alias_type_cd=reply->alias_type_list[i].alias_type_code_value)
     AND (o.alias_entity_name=reply->alias_type_list[i].alias_entity_name))
    JOIN (org
    WHERE parser(org_parse))
    JOIN (cv
    WHERE o.alias_pool_cd=cv.code_value)
   ORDER BY o.alias_pool_cd, o.organization_id, cv.code_value
   HEAD o.alias_pool_cd
    apcnt = (apcnt+ 0)
   HEAD o.organization_id
    apcnt = (apcnt+ 1), stat = alterlist(reply->alias_type_list[i].alias_pool_list,apcnt), reply->
    alias_type_list[i].alias_pool_list[apcnt].alias_pool_code_value = o.alias_pool_cd,
    reply->alias_type_list[i].alias_pool_list[apcnt].org_id = o.organization_id, reply->
    alias_type_list[i].alias_pool_list[apcnt].org_name = org.org_name
   HEAD cv.code_value
    reply->alias_type_list[i].alias_pool_list[apcnt].alias_pool_disp = cv.display, reply->
    alias_type_list[i].alias_pool_list[apcnt].alias_pool_mean = cv.cdf_meaning
   WITH nocounter
  ;end select
 ENDFOR
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(" >> PROGRAM NAME: BED_GET_ALIAS_TYPE_DATA  >> ERROR MESSAGE: ",
   error_msg)
 ELSE
  IF (found_alias_types)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
#endit
 CALL echorecord(reply)
END GO

CREATE PROGRAM bed_get_alias_pool_by_disp:dba
 FREE SET reply
 RECORD reply(
   1 alias_pools[*]
     2 alias_pool_code
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 mnemonic = vc
     2 active_ind = i2
     2 duplicate_flag = i4
     2 format_mask = vc
     2 sys_assign_flag = i4
     2 alias_type_code
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 fsi_id = f8
     2 unsecured_char_count = i4
     2 security_char = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE apcnt = i4
 DECLARE iic = i2
 DECLARE sstring = vc
 DECLARE error_msg = vc
 SET error_flag = "F"
 SET apcnt = 0
 SET iic = request->inc_inactive_ind
 SET sstring = fillstring(60," ")
 IF ((request->display > " "))
  SET sstring = concat(" cnvtupper(ap.description) = '",cnvtupper(trim(request->display)),"*'",
   " and (ap.active_ind = 1 or iic = 1) and ap.alias_pool_cd > 0")
 ELSE
  SET sstring = concat("(ap.active_ind = 1 or iic = 1) and ap.alias_pool_cd > 0")
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
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET sstring = concat(sstring," and ap.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET sstring = build(sstring,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
     ELSE
      SET sstring = build(sstring,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SET sstring = trim(sstring)
 CALL echo(build(sstring))
 SELECT INTO "nl:"
  FROM alias_pool ap,
   code_value cv,
   code_value_extension cve,
   br_alias_pool_info bapi,
   org_alias_pool_reltn oapr,
   code_value cv2,
   code_value cv3
  PLAN (ap
   WHERE parser(sstring))
   JOIN (cv
   WHERE ap.alias_pool_cd=cv.code_value)
   JOIN (cve
   WHERE cve.code_value=outerjoin(cv.code_value)
    AND cve.field_name=outerjoin("MNEMONIC"))
   JOIN (oapr
   WHERE oapr.alias_pool_cd=outerjoin(cv.code_value))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(oapr.alias_entity_alias_type_cd))
   JOIN (bapi
   WHERE bapi.alias_pool_cd=outerjoin(cv.code_value))
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(bapi.alias_pool_type_cd))
  ORDER BY ap.description, ap.alias_pool_cd
  HEAD ap.alias_pool_cd
   apcnt = (apcnt+ 1)
  DETAIL
   stat = alterlist(reply->alias_pools,apcnt), reply->alias_pools[apcnt].alias_pool_code.code_value
    = ap.alias_pool_cd, reply->alias_pools[apcnt].alias_pool_code.display = cv.display,
   reply->alias_pools[apcnt].alias_pool_code.mean = cv.cdf_meaning, reply->alias_pools[apcnt].
   active_ind = ap.active_ind, reply->alias_pools[apcnt].duplicate_flag = ap.dup_allowed_flag,
   reply->alias_pools[apcnt].format_mask = ap.format_mask, reply->alias_pools[apcnt].sys_assign_flag
    = ap.sys_assign_flag, reply->alias_pools[apcnt].active_ind = ap.active_ind,
   reply->alias_pools[apcnt].mnemonic = cve.field_value, reply->alias_pools[apcnt].fsi_id = bapi
   .fsi_id, reply->alias_pools[apcnt].unsecured_char_count = ap.unsecured_char_count,
   reply->alias_pools[apcnt].security_char = ap.security_char
  WITH nocounter
 ;end select
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(" >> PROGRAM NAME: BED_GET_ALIAS_POOL_BY_DISP  >> ERROR MESSAGE: ",
   error_msg)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO

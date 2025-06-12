CREATE PROGRAM bed_get_secure_email_domains:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 domains[*]
      2 org_contributor_sys_reltn_id = f8
      2 domain_addr = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET authorization_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4002607
   AND cv.cdf_meaning="OAUTH"
   AND cv.active_ind=1
  DETAIL
   authorization_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET contributor_sys_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=89
   AND cv.cdf_meaning="CERNERDIRECT"
   AND cv.active_ind=1
  DETAIL
   contributor_sys_cd = cv.code_value
  WITH nocounter
 ;end select
 SET relation_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=311
   AND cv.cdf_meaning="DIRECT"
   AND cv.active_ind=1
  DETAIL
   relation_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET data_partition_ind = 0
 SET field_found = 0
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
  SET prg_exists_ind = 0
  SET prg_exists_ind = checkprg("ACM_GET_CURR_LOGICAL_DOMAIN")
  IF (prg_exists_ind > 0)
   SET field_found = 0
   RANGE OF p IS prsnl
   SET field_found = validate(p.logical_domain_id)
   FREE RANGE p
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
    SET prsnl_logical_domain_id = 0.0
    SET acm_get_curr_logical_domain_req->concept = 2
    EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
    replace("REPLY",acm_get_curr_logical_domain_rep)
    SET prsnl_logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id
   ENDIF
  ENDIF
 ENDIF
 DECLARE oparse = vc
 SET oparse = "o.organization_id > 0 and o.active_ind = 1"
 IF (data_partition_ind=1)
  SET oparse = build(oparse," and o.logical_domain_id = ",prsnl_logical_domain_id)
 ENDIF
 SET dcnt = 0
 SELECT INTO "nl"
  FROM organization o,
   org_contributor_sys_reltn ocs
  PLAN (o
   WHERE parser(oparse))
   JOIN (ocs
   WHERE ocs.authorization_type_cd=authorization_type_cd
    AND ocs.contributor_system_cd=contributor_sys_cd
    AND ocs.reltn_type_cd=relation_type_cd
    AND ocs.organization_id=o.organization_id
    AND ocs.org_contributor_sys_reltn_id > 0
    AND ocs.active_ind=1)
  DETAIL
   dcnt = (dcnt+ 1), stat = alterlist(reply->domains,dcnt), reply->domains[dcnt].
   org_contributor_sys_reltn_id = ocs.org_contributor_sys_reltn_id,
   reply->domains[dcnt].domain_addr = ocs.domain_addr
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

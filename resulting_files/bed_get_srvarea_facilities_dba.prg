CREATE PROGRAM bed_get_srvarea_facilities:dba
 FREE SET reply
 RECORD reply(
   1 facilities[*]
     2 code_value = f8
     2 disp = vc
     2 desc = vc
     2 organization_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE facility = f8 WITH public, noconstant(0.0)
 DECLARE department = f8 WITH public, noconstant(0.0)
 DECLARE radiology = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=222
    AND cv.cdf_meaning="FACILITY")
  DETAIL
   facility = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="DEPARTMENT")
  DETAIL
   department = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="RADIOLOGY")
  DETAIL
   radiology = cv.code_value
  WITH nocounter
 ;end select
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
 SET cnt = 0
 SELECT INTO "nl:"
  FROM location l,
   organization o,
   code_value cv,
   service_resource sr
  PLAN (l
   WHERE l.location_type_cd=facility
    AND l.active_ind=1)
   JOIN (o
   WHERE o.organization_id=l.organization_id
    AND parser(org_parse))
   JOIN (cv
   WHERE cv.code_value=l.location_cd
    AND cv.active_ind=1)
   JOIN (sr
   WHERE sr.organization_id=o.organization_id
    AND sr.service_resource_type_cd=department
    AND sr.discipline_type_cd=radiology
    AND sr.active_ind=1)
  ORDER BY l.location_cd
  HEAD l.location_cd
   cnt = (cnt+ 1), stat = alterlist(reply->facilities,cnt), reply->facilities[cnt].code_value = l
   .location_cd,
   reply->facilities[cnt].disp = cv.display, reply->facilities[cnt].desc = cv.description, reply->
   facilities[cnt].organization_id = o.organization_id
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (size(reply->facilities,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

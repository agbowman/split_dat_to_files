CREATE PROGRAM bed_get_cs_avail_orgs:dba
 FREE SET reply
 RECORD reply(
   1 available_orgs[*]
     2 id = f8
     2 name = vc
     2 prefix = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 SET facility_cd = 0.0
 SET building_cd = 0.0
 SET client_cd = 0.0
 SET wcard = "*"
 SET max_cnt = 0
 IF ((request->max_reply_limit > 0))
  SET max_cnt = request->max_reply_limit
 ELSE
  SET max_cnt = 1000000
 ENDIF
 DECLARE search_string = vc
 DECLARE sstring = vc
 IF (trim(request->search_txt) > " ")
  SET sstring = trim(cnvtalphanum(request->search_txt))
  IF ((request->search_type_flag="S"))
   SET search_string = concat(cnvtupper(sstring),wcard)
  ELSE
   SET search_string = concat(wcard,cnvtupper(sstring),wcard)
  ENDIF
  SET search_string = replace(search_string," ","")
 ELSE
  SET search_string = wcard
 ENDIF
 CALL echo(build("search_string:",search_string))
 DECLARE org_name_parse = vc
 SET org_name_parse = concat("o.org_name_key = '",search_string,"'")
 IF ((request->show_inactive_ind=0))
  SET org_name_parse = concat(org_name_parse," and o.active_ind = 1")
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
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET org_name_parse = concat(org_name_parse," and o.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET org_name_parse = build(org_name_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
     ELSE
      SET org_name_parse = build(org_name_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=278
    AND cv.cdf_meaning="CLIENT"
    AND cv.active_ind=1)
  DETAIL
   client_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=222
    AND cv.cdf_meaning IN ("FACILITY", "BUILDING")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="FACILITY")
    facility_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="BUILDING")
    building_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET ocnt = 0
 IF ((request->show_all_ind=1))
  SELECT INTO "nl:"
   FROM organization o,
    org_type_reltn r,
    location l
   PLAN (o
    WHERE parser(org_name_parse))
    JOIN (r
    WHERE r.organization_id=o.organization_id
     AND r.org_type_cd=client_cd
     AND r.active_ind=1)
    JOIN (l
    WHERE l.organization_id=r.organization_id
     AND l.location_type_cd=facility_cd
     AND l.active_ind=1)
   ORDER BY o.org_name
   HEAD o.org_name
    ocnt = (ocnt+ 1), stat = alterlist(reply->available_orgs,ocnt), reply->available_orgs[ocnt].id =
    o.organization_id,
    reply->available_orgs[ocnt].name = o.org_name
   WITH nocounter, maxqual(o,value((max_cnt+ 2)))
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM organization o,
    org_type_reltn r,
    location l,
    location_group lg1,
    location_group lg2
   PLAN (o
    WHERE parser(org_name_parse))
    JOIN (r
    WHERE r.organization_id=o.organization_id
     AND r.org_type_cd=client_cd
     AND r.active_ind=1)
    JOIN (l
    WHERE l.organization_id=r.organization_id
     AND l.location_type_cd=facility_cd
     AND l.active_ind=1)
    JOIN (lg1
    WHERE lg1.parent_loc_cd=l.location_cd
     AND lg1.location_group_type_cd=facility_cd
     AND lg1.root_loc_cd=0
     AND lg1.active_ind=1)
    JOIN (lg2
    WHERE lg2.parent_loc_cd=lg1.child_loc_cd
     AND lg2.location_group_type_cd=building_cd
     AND lg2.root_loc_cd=0
     AND lg2.active_ind=1)
   ORDER BY o.org_name
   HEAD o.org_name
    ocnt = (ocnt+ 1), stat = alterlist(reply->available_orgs,ocnt), reply->available_orgs[ocnt].id =
    o.organization_id,
    reply->available_orgs[ocnt].name = o.org_name
   WITH nocounter, maxqual(o,value((max_cnt+ 2)))
  ;end select
 ENDIF
 IF (ocnt > max_cnt)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 IF (ocnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ocnt)),
    br_organization b
   PLAN (d)
    JOIN (b
    WHERE (b.organization_id=reply->available_orgs[d.seq].id))
   ORDER BY d.seq
   HEAD d.seq
    reply->available_orgs[d.seq].prefix = b.br_prefix
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (ocnt > 0)
  IF (ocnt > max_cnt)
   SET reply->too_many_results_ind = 1
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 IF ((reply->too_many_results_ind=1))
  SET stat = alterlist(reply->available_orgs,0)
 ENDIF
 CALL echorecord(reply)
END GO

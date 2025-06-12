CREATE PROGRAM bed_get_fac_bldg_hier_list:dba
 FREE SET reply
 RECORD reply(
   1 facility[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 building[*]
       3 code_value = f8
       3 display = vc
       3 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 RECORD treply(
   1 building[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 bldg_cnt = i2
 )
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 SET wcard = "*"
 SET max_cnt = 0
 IF ((request->max_reply_limit > 0))
  SET max_cnt = request->max_reply_limit
 ELSE
  SET max_cnt = 1000000
 ENDIF
 SET bldg_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=222
    AND c.cdf_meaning="BUILDING")
  DETAIL
   bldg_cd = c.code_value
  WITH nocounter
 ;end select
 SET facility_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=222
    AND c.cdf_meaning="FACILITY")
  DETAIL
   facility_cd = c.code_value
  WITH nocounter
 ;end select
 DECLARE bldg_name_parse = vc
 DECLARE loc_parse = vc
 DECLARE search_string = vc
 IF (trim(request->search_txt) > " ")
  IF ((request->search_type_flag="S"))
   SET search_string = concat(trim(cnvtalphanum(cnvtupper(request->search_txt))),wcard)
  ELSE
   SET search_string = concat(wcard,trim(cnvtalphanum(cnvtupper(request->search_txt))),wcard)
  ENDIF
  SET bldg_name_parse = concat("cnvtupper(c.display_key) = '",search_string,"'")
 ELSE
  SET search_string = wcard
  SET bldg_name_parse = concat("cnvtupper(c.display_key) = '",search_string,"'")
 ENDIF
 IF ((request->show_inactive_ind=1))
  SET loc_parse = "l.location_cd = c.code_value and l.location_type_cd = bldg_cd"
 ELSE
  SET loc_parse =
  "l.location_cd = c.code_value and l.location_type_cd = bldg_cd and l.active_ind = 1"
 ENDIF
 SET loc_parse = concat(trim(loc_parse)," and l.organization_id > 0")
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
 SET org_parse = "o.organization_id = l.organization_id"
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
 SET ocnt = 0
 SELECT INTO "nl:"
  bldg_name_key = trim(cnvtalphanum(cnvtupper(c.description)))
  FROM code_value c,
   location l,
   organization o
  PLAN (c
   WHERE parser(bldg_name_parse)
    AND c.code_set=220
    AND c.cdf_meaning="BUILDING"
    AND c.active_ind=1)
   JOIN (l
   WHERE parser(loc_parse))
   JOIN (o
   WHERE parser(org_parse))
  ORDER BY bldg_name_key
  HEAD REPORT
   ocnt = 0
  DETAIL
   ocnt = (ocnt+ 1), stat = alterlist(treply->building,ocnt), treply->building[ocnt].code_value = c
   .code_value,
   treply->building[ocnt].display = c.display, treply->building[ocnt].description = c.description
  WITH nocounter, maxqual(c,value((max_cnt+ 1)))
 ;end select
 CALL echo(build("ocnt",ocnt))
 IF (ocnt=0)
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 SET fcnt = 0
 SET rcnt = 0
 IF (ocnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ocnt)),
    location_group lg1,
    code_value cv1
   PLAN (d)
    JOIN (lg1
    WHERE (lg1.child_loc_cd=treply->building[d.seq].code_value)
     AND lg1.location_group_type_cd=facility_cd
     AND lg1.root_loc_cd=0
     AND lg1.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=lg1.parent_loc_cd
     AND cv1.active_ind=1)
   ORDER BY lg1.parent_loc_cd, lg1.child_loc_cd
   HEAD lg1.parent_loc_cd
    bldcnt = 0, fcnt = (fcnt+ 1), stat = alterlist(reply->facility,fcnt),
    reply->facility[fcnt].code_value = lg1.parent_loc_cd, reply->facility[fcnt].display = cv1.display,
    reply->facility[fcnt].description = cv1.description
   HEAD lg1.child_loc_cd
    bldcnt = (bldcnt+ 1), rcnt = (rcnt+ 1), stat = alterlist(reply->facility[fcnt].building,bldcnt),
    reply->facility[fcnt].building[bldcnt].code_value = lg1.child_loc_cd, reply->facility[fcnt].
    building[bldcnt].display = treply->building[d.seq].display, reply->facility[fcnt].building[bldcnt
    ].description = treply->building[d.seq].description
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build("rcnt",rcnt))
 IF (rcnt > max_cnt)
  SET stat = alterlist(reply->facility,0)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO

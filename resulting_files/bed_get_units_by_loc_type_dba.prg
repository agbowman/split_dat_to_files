CREATE PROGRAM bed_get_units_by_loc_type:dba
 FREE SET reply
 RECORD reply(
   1 units[*]
     2 loc_code_value = f8
     2 loc_display = vc
     2 loc_description = vc
     2 location_type
       3 loc_type_code = f8
       3 loc_type_disp = vc
       3 loc_type_mean = vc
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
 SET wcard = "*"
 SET max_cnt = 0
 IF ((request->max_reply_limit > 0))
  SET max_cnt = request->max_reply_limit
 ELSE
  SET max_cnt = 1000000
 ENDIF
 DECLARE unit_name_parse = vc
 DECLARE loc_parse = vc
 DECLARE search_string = vc
 IF (trim(request->search_txt) > " ")
  IF (cnvtupper(request->search_type_flag)="S")
   SET search_string = concat(trim(cnvtalphanum(cnvtupper(request->search_txt))),wcard)
  ELSEIF (cnvtupper(request->search_type_flag)="C")
   SET search_string = concat(wcard,trim(cnvtalphanum(cnvtupper(request->search_txt))),wcard)
  ENDIF
  SET unit_name_parse = concat("cnvtupper(c.display_key) = '",search_string,"'")
 ELSE
  SET search_string = wcard
  SET unit_name_parse = concat("cnvtupper(c.display_key) = '",search_string,"'")
 ENDIF
 DECLARE loc_type_parse = vc
 SET loc_type_parse =
 "(l1.active_ind+0 = 1 or request->show_inactive_ind = 1) and l1.location_type_cd+0 in ("
 SET lcnt = size(request->location_types,5)
 FOR (l = 1 TO lcnt)
   IF (l=lcnt)
    SET loc_type_parse = build(loc_type_parse,request->location_types[l].code_value,")")
   ELSE
    SET loc_type_parse = build(loc_type_parse,request->location_types[l].code_value,",")
   ENDIF
 ENDFOR
 SET loc_type_parse = concat(trim(loc_type_parse)," and l1.organization_id > 0")
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
 SET org_parse = "o.organization_id = l1.organization_id"
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
 SET rcnt = 0
 SELECT INTO "NL:"
  FROM code_value c,
   location l1,
   organization o,
   code_value cv
  PLAN (c
   WHERE parser(unit_name_parse)
    AND c.code_set=220
    AND ((c.active_ind=1) OR ((request->show_inactive_ind=1))) )
   JOIN (l1
   WHERE l1.location_cd=c.code_value
    AND parser(loc_type_parse))
   JOIN (cv
   WHERE cv.code_value=l1.location_type_cd
    AND cv.active_ind=1)
   JOIN (o
   WHERE o.organization_id=l1.organization_id)
  ORDER BY c.display_key
  HEAD REPORT
   alterlist_rcnt = 0, stat = alterlist(reply->units,100)
  DETAIL
   rcnt = (rcnt+ 1), alterlist_rcnt = (alterlist_rcnt+ 1)
   IF (alterlist_rcnt > 100)
    stat = alterlist(reply->units,(rcnt+ 100)), alterlist_rcnt = 1
   ENDIF
   reply->units[rcnt].loc_code_value = l1.location_cd, reply->units[rcnt].loc_description = c
   .description, reply->units[rcnt].loc_display = c.display,
   reply->units[rcnt].location_type.loc_type_code = l1.location_type_cd, reply->units[rcnt].
   location_type.loc_type_disp = cv.display, reply->units[rcnt].location_type.loc_type_mean = cv
   .cdf_meaning
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->units,rcnt)
 IF (rcnt > max_cnt)
  SET stat = alterlist(reply->units,0)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO

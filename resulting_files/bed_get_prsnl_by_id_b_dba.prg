CREATE PROGRAM bed_get_prsnl_by_id_b:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 person_list[*]
      2 person_id = f8
      2 prsnl_id = f8
      2 name_title = vc
      2 name_first = vc
      2 name_middle = vc
      2 name_last = vc
      2 name_full_formatted = vc
      2 name_suffix = vc
      2 prsnl_name_first = vc
      2 prsnl_name_last = vc
      2 prsnl_name_full_formatted = vc
      2 person_name_id = f8
      2 username = vc
      2 email = vc
      2 birth_dt_tm = dq8
      2 sex_code_value = f8
      2 sex_disp = vc
      2 sex_mean = vc
      2 physician_ind = i2
      2 position_code_value = f8
      2 position_disp = vc
      2 primary_work_loc_code_value = f8
      2 primary_work_loc_disp = vc
      2 primary_work_loc_mean = vc
      2 active_ind = i2
      2 prsnl_alias_list[*]
        3 alias_id = f8
        3 alias_type_code_value = f8
        3 alias_type_disp = vc
        3 alias_type_mean = vc
        3 alias_pool_code_value = f8
        3 alias_pool_disp = vc
        3 alias_pool_mean = vc
        3 alias = vc
        3 active_ind = i2
        3 org_list[*]
          4 organization_id = f8
          4 org_name = vc
      2 person_alias_list[*]
        3 alias_id = f8
        3 alias_type_code_value = f8
        3 alias_type_disp = vc
        3 alias_type_mean = vc
        3 alias_pool_code_value = f8
        3 alias_pool_disp = vc
        3 alias_pool_mean = vc
        3 alias = vc
        3 active_ind = i2
        3 org_list[*]
          4 organization_id = f8
          4 org_name = vc
      2 address_list[*]
        3 address_id = f8
        3 address_type_code_value = f8
        3 address_type_disp = vc
        3 address_type_mean = vc
        3 address_type_seq = i4
        3 street_addr = vc
        3 street_addr2 = vc
        3 street_addr3 = vc
        3 street_addr4 = vc
        3 city = vc
        3 state = vc
        3 state_code_value = f8
        3 state_disp = vc
        3 zipcode = vc
        3 country_code_value = f8
        3 country_disp = vc
        3 county_code_value = f8
        3 county_disp = vc
        3 contact_name = vc
        3 residence_type_code_value = f8
        3 residence_type_disp = vc
        3 residence_type_mean = vc
        3 comment_txt = vc
        3 active_ind = i2
      2 phone_list[*]
        3 phone_id = f8
        3 phone_type_code_value = f8
        3 phone_type_disp = vc
        3 phone_type_mean = vc
        3 phone_format_code_value = f8
        3 phone_format_disp = vc
        3 phone_format_mean = vc
        3 sequence = i4
        3 phone_num = vc
        3 phone_formatted = vc
        3 description = vc
        3 contact = vc
        3 call_instruction = vc
        3 extension = vc
        3 paging_code = vc
        3 operation_hours = vc
        3 active_ind = i2
        3 contact_method_code_value = f8
      2 org_list[*]
        3 prsnl_org_reltn_id = f8
        3 organization_id = f8
        3 organization_name = vc
        3 confid_level_code_value = f8
        3 confid_level_disp = vc
        3 confid_level_mean = vc
        3 active_ind = i2
      2 org_group_list[*]
        3 org_set_prsnl_r_id = f8
        3 org_set_type_code_value = f8
        3 org_set_type_disp = vc
        3 org_set_type_mean = vc
        3 org_set_id = f8
        3 org_set_name = vc
        3 active_ind = i2
      2 location_list[*]
        3 location_code_value = f8
        3 location_disp = vc
        3 location_mean = vc
        3 location_type_code_value = f8
        3 location_type_disp = vc
        3 location_type_mean = vc
      2 credential_list[*]
        3 credential_id = f8
        3 notify_type_code_value = f8
        3 notify_type_disp = vc
        3 notify_type_mean = vc
        3 notify_prsnl_id = f8
        3 notify_prsnl_name_ff = vc
        3 credential_code_value = f8
        3 credential_disp = vc
        3 credential_mean = vc
        3 credential_type_code_value = f8
        3 credential_type_disp = vc
        3 credential_type_mean = vc
        3 state_code_value = f8
        3 state_disp = vc
        3 id_number = vc
        3 renewal_dt_tm = dq8
        3 valid_for_code_value = f8
        3 valid_for_disp = vc
        3 valid_for_mean = vc
        3 notified_dt_tm = dq8
      2 user_group_list[*]
        3 prsnl_group_reltn_id = f8
        3 prsnl_group_id = f8
        3 prsnl_group_name = vc
        3 prsnl_group_r_code_value = f8
        3 prsnl_group_r_disp = vc
        3 prsnl_group_r_mean = vc
        3 primary_ind = i2
        3 active_ind = i2
      2 clin_serv_list[*]
        3 clinical_service_reltn_id = f8
        3 clinical_service_code_value = f8
        3 clinical_service_disp = vc
        3 clinical_service_mean = vc
        3 priority = i4
      2 service_resource_list[*]
        3 service_resource_code_value = f8
        3 service_resource_disp = vc
        3 service_resource_mean = vc
      2 related_prsnl_list[*]
        3 prsnl_prsnl_reltn_id = f8
        3 prsnl_prsnl_reltn_code_value = f8
        3 prsnl_prsnl_reltn_disp = vc
        3 prsnl_prsnl_reltn_mean = vc
        3 related_person_id = f8
        3 related_person_name = vc
        3 active_ind = i2
      2 demog_reltn_list[*]
        3 prsnl_reltn_id = f8
        3 reltn_type_code_value = f8
        3 reltn_type_disp = vc
        3 reltn_type_mean = vc
        3 parent_entity_id = f8
        3 parent_entity_name = vc
        3 demog_reltn_child_list[*]
          4 prsnl_reltn_child_id = f8
          4 parent_entity_id = f8
          4 parent_entity_name = vc
      2 priv_list[*]
        3 prsnl_priv_id = f8
        3 name = vc
        3 use_position_ind = i2
        3 use_org_reltn_ind = i2
        3 super_user_ind = i2
        3 priv_component_list[*]
          4 prsnl_priv_comp_id = f8
          4 priv_type_nbr = f8
          4 component_name = vc
        3 priv_detail_list[*]
          4 prsnl_priv_detail_id = f8
          4 priv_type_id = f8
          4 priv_type_name = vc
      2 notify_list[*]
        3 prsnl_notify_id = f8
        3 task_activity_code_value = f8
        3 task_activity_disp = vc
        3 task_activity_mean = vc
        3 notify_flag = i2
        3 active_ind = i2
      2 position_mean = vc
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
    1 error_msg = vc
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
 DECLARE error_msg = vc
 SET person_cnt = size(request->person_list,5)
 IF (person_cnt=0)
  SET error_flag = "Y"
  SET error_msg = "Empty person_list in request"
  GO TO exit_script
 ENDIF
 RECORD prsnl_logical_domains_rep(
   1 logical_domain_grp_id = f8
   1 logical_domains_cnt = i4
   1 logical_domains[*]
     2 logical_domain_id = f8
   1 status_block
     2 status_ind = i2
     2 error_code = i4
 )
 RECORD org_logical_domains_rep(
   1 logical_domain_grp_id = f8
   1 logical_domains_cnt = i4
   1 logical_domains[*]
     2 logical_domain_id = f8
   1 status_block
     2 status_ind = i2
     2 error_code = i4
 )
 SET prsnl_data_partition_ind = 0
 SET org_data_partition_ind = 0
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
    SET prsnl_data_partition_ind = 1
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
    SET acm_get_acc_logical_domains_req->concept = 2
    EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
    replace("REPLY",acm_get_acc_logical_domains_rep)
    SET stat = moverec(acm_get_acc_logical_domains_rep,prsnl_logical_domains_rep)
   ENDIF
   SET field_found = 0
   RANGE OF o IS organization
   SET field_found = validate(o.logical_domain_id)
   FREE RANGE o
   IF (field_found=1)
    SET org_data_partition_ind = 1
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
    SET stat = moverec(acm_get_acc_logical_domains_rep,org_logical_domains_rep)
   ENDIF
  ENDIF
 ENDIF
 DECLARE prsnl_parse = vc
 SET prsnl_parse = "ppr.person_id = p2.person_id"
 IF (prsnl_data_partition_ind=1)
  IF ((prsnl_logical_domains_rep->logical_domains_cnt > 0))
   SET prsnl_parse = concat(prsnl_parse," and p2.logical_domain_id in (")
   FOR (d = 1 TO prsnl_logical_domains_rep->logical_domains_cnt)
     IF ((d=prsnl_logical_domains_rep->logical_domains_cnt))
      SET prsnl_parse = build(prsnl_parse,prsnl_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
     ELSE
      SET prsnl_parse = build(prsnl_parse,prsnl_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 DECLARE org_parse = vc
 SET org_parse = "org.active_ind = 1"
 IF (org_data_partition_ind=1)
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
 DECLARE prsnl_alias_parse = vc
 SET prsnl_alias_parse = build(
  " ((pra.active_status_cd = active_code and pra.active_ind = 1) or iic = 1)")
 DECLARE person_alias_parse = vc
 SET person_alias_parse = build(
  " ((prsa.active_status_cd = active_code and prsa.active_ind = 1) or iic = 1)")
 IF (validate(request->load.get_effective_alias_only_ind))
  IF (request->load.get_effective_alias_only_ind)
   SET prsnl_alias_parse = build(prsnl_alias_parse,
    " and pra.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
    " and pra.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
   SET person_alias_parse = build(person_alias_parse,
    " and prsa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
    " and prsa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  ENDIF
 ENDIF
 DECLARE get_address_parse = vc
 SET get_address_parse = "(a.active_ind = 1 or iic = 1)"
 IF (validate(request->load.exclude_ineffective_address_ind))
  IF (request->load.exclude_ineffective_address_ind)
   SET get_address_parse = build(get_address_parse,
    " and a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
    " and a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  ENDIF
 ENDIF
 SET exclude_alias_orgs_ind = 0
 IF (validate(request->load.exclude_alias_orgs_ind))
  IF ((request->load.exclude_alias_orgs_ind=1))
   SET exclude_alias_orgs_ind = 1
  ENDIF
 ENDIF
 SET alias_types_cnt = 0
 IF (validate(request->alias_types[1].code_value))
  SET alias_types_cnt = size(request->alias_types,5)
 ENDIF
 SET apool = 0.0
 SET atype = 0.0
 SET org_count = 0
 SET iic = 0
 SET iic = request->include_inactive_child_ind
 SET active_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE")
  DETAIL
   active_code = cv.code_value
  WITH nocounter
 ;end select
 SET fac_org_type_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=278
   AND cv.active_ind=1
   AND cv.cdf_meaning="FACILITY"
  DETAIL
   fac_org_type_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET prsnl_name_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=213
    AND c.cdf_meaning="PRSNL")
  DETAIL
   prsnl_name_type_cd = c.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->person_list,person_cnt)
 IF (request->load.get_person_ind)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = person_cnt),
    person p,
    person_name pn,
    prsnl pr,
    code_value cv,
    code_value cv1,
    code_value cv2
   PLAN (d)
    JOIN (p
    WHERE (p.person_id=request->person_list[d.seq].person_id))
    JOIN (pn
    WHERE pn.person_id=outerjoin(p.person_id)
     AND pn.name_type_cd=outerjoin(prsnl_name_type_cd))
    JOIN (pr
    WHERE pr.person_id=outerjoin(p.person_id))
    JOIN (cv
    WHERE cv.code_value=outerjoin(p.sex_cd))
    JOIN (cv1
    WHERE cv1.code_value=outerjoin(pr.position_cd))
    JOIN (cv2
    WHERE cv2.code_value=outerjoin(pr.prim_assign_loc_cd))
   DETAIL
    reply->person_list[d.seq].person_id = p.person_id, reply->person_list[d.seq].prsnl_id = p
    .person_id, reply->person_list[d.seq].name_first = p.name_first,
    reply->person_list[d.seq].name_middle = p.name_middle, reply->person_list[d.seq].name_last = p
    .name_last, reply->person_list[d.seq].name_full_formatted = p.name_full_formatted,
    reply->person_list[d.seq].birth_dt_tm = p.birth_dt_tm, reply->person_list[d.seq].sex_code_value
     = p.sex_cd, reply->person_list[d.seq].sex_disp = cv.display,
    reply->person_list[d.seq].sex_mean = cv.cdf_meaning
    IF (pn.person_name_id > 0
     AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pn.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     reply->person_list[d.seq].name_title = pn.name_title, reply->person_list[d.seq].name_suffix = pn
     .name_suffix, reply->person_list[d.seq].person_name_id = pn.person_name_id
    ENDIF
    reply->person_list[d.seq].prsnl_name_first = pr.name_first, reply->person_list[d.seq].
    prsnl_name_last = pr.name_last, reply->person_list[d.seq].prsnl_name_full_formatted = pr
    .name_full_formatted,
    reply->person_list[d.seq].email = pr.email, reply->person_list[d.seq].username = pr.username,
    reply->person_list[d.seq].physician_ind = pr.physician_ind,
    reply->person_list[d.seq].active_ind = pr.active_ind, reply->person_list[d.seq].
    beg_effective_dt_tm = pr.beg_effective_dt_tm, reply->person_list[d.seq].end_effective_dt_tm = pr
    .end_effective_dt_tm,
    reply->person_list[d.seq].position_code_value = pr.position_cd, reply->person_list[d.seq].
    position_disp = cv1.display, reply->person_list[d.seq].position_mean = cv1.cdf_meaning,
    reply->person_list[d.seq].primary_work_loc_code_value = pr.prim_assign_loc_cd, reply->
    person_list[d.seq].primary_work_loc_disp = cv2.display, reply->person_list[d.seq].
    primary_work_loc_mean = cv2.cdf_meaning
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET error_flag = "Y"
   SET error_msg = "No person data found"
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = person_cnt),
    prsnl_prsnl_reltn ppr,
    prsnl p2,
    code_value cv
   PLAN (d)
    JOIN (ppr
    WHERE (ppr.related_person_id=request->person_list[d.seq].person_id)
     AND ((ppr.active_ind=1) OR (iic=1)) )
    JOIN (p2
    WHERE parser(prsnl_parse))
    JOIN (cv
    WHERE cv.code_value=ppr.prsnl_prsnl_reltn_cd)
   ORDER BY d.seq
   HEAD d.seq
    pprcnt = 0, listcnt = 0, stat = alterlist(reply->person_list[d.seq].related_prsnl_list,10)
   DETAIL
    pprcnt = (pprcnt+ 1), listcnt = (listcnt+ 1)
    IF (listcnt > 10)
     listcnt = 1, stat = alterlist(reply->person_list[d.seq].related_prsnl_list,(pprcnt+ 10))
    ENDIF
    reply->person_list[d.seq].related_prsnl_list[pprcnt].prsnl_prsnl_reltn_id = ppr
    .prsnl_prsnl_reltn_id, reply->person_list[d.seq].related_prsnl_list[pprcnt].
    prsnl_prsnl_reltn_code_value = ppr.prsnl_prsnl_reltn_cd, reply->person_list[d.seq].
    related_prsnl_list[pprcnt].active_ind = ppr.active_ind,
    reply->person_list[d.seq].related_prsnl_list[pprcnt].prsnl_prsnl_reltn_disp = cv.display, reply->
    person_list[d.seq].related_prsnl_list[pprcnt].prsnl_prsnl_reltn_mean = cv.cdf_meaning, reply->
    person_list[d.seq].related_prsnl_list[pprcnt].related_person_id = ppr.person_id,
    reply->person_list[d.seq].related_prsnl_list[pprcnt].related_person_name = p2.name_full_formatted
   FOOT  d.seq
    stat = alterlist(reply->person_list[d.seq].related_prsnl_list,pprcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (request->load.get_alias_ind)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = person_cnt),
    prsnl_alias pra,
    code_value cv1,
    code_value cv2
   PLAN (d)
    JOIN (pra
    WHERE (pra.person_id=request->person_list[d.seq].person_id)
     AND parser(prsnl_alias_parse))
    JOIN (cv1
    WHERE cv1.code_value=pra.prsnl_alias_type_cd)
    JOIN (cv2
    WHERE cv2.code_value=pra.alias_pool_cd)
   ORDER BY d.seq
   HEAD d.seq
    pracnt = 0, listcnt = 0, stat = alterlist(reply->person_list[d.seq].prsnl_alias_list,10)
   DETAIL
    add_alias_ind = 1
    IF (alias_types_cnt > 0)
     found_ind = 0, start = 1, num = 0,
     found_ind = locateval(num,start,alias_types_cnt,pra.prsnl_alias_type_cd,request->alias_types[num
      ].code_value)
     IF (found_ind=0)
      add_alias_ind = 0
     ENDIF
    ENDIF
    IF (add_alias_ind=1)
     pracnt = (pracnt+ 1), listcnt = (listcnt+ 1)
     IF (listcnt=10)
      stat = alterlist(reply->person_list[d.seq].prsnl_alias_list,(pracnt+ 10))
     ENDIF
     reply->person_list[d.seq].prsnl_alias_list[pracnt].alias_id = pra.prsnl_alias_id, reply->
     person_list[d.seq].prsnl_alias_list[pracnt].alias = pra.alias, reply->person_list[d.seq].
     prsnl_alias_list[pracnt].active_ind = pra.active_ind,
     reply->person_list[d.seq].prsnl_alias_list[pracnt].alias_type_code_value = pra
     .prsnl_alias_type_cd, reply->person_list[d.seq].prsnl_alias_list[pracnt].alias_type_disp = cv1
     .display, reply->person_list[d.seq].prsnl_alias_list[pracnt].alias_type_mean = cv1.cdf_meaning,
     reply->person_list[d.seq].prsnl_alias_list[pracnt].alias_pool_code_value = pra.alias_pool_cd,
     reply->person_list[d.seq].prsnl_alias_list[pracnt].alias_pool_disp = cv2.display, reply->
     person_list[d.seq].prsnl_alias_list[pracnt].alias_pool_mean = cv2.cdf_meaning
    ENDIF
   FOOT  d.seq
    stat = alterlist(reply->person_list[d.seq].prsnl_alias_list,pracnt)
   WITH nocounter
  ;end select
  IF (exclude_alias_orgs_ind=0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(person_cnt)),
     (dummyt d2  WITH seq = 1),
     org_alias_pool_reltn oapr,
     organization org
    PLAN (d
     WHERE maxrec(d2,size(reply->person_list[d.seq].prsnl_alias_list,5)))
     JOIN (d2)
     JOIN (oapr
     WHERE (oapr.alias_pool_cd=reply->person_list[d.seq].prsnl_alias_list[d2.seq].
     alias_pool_code_value)
      AND (oapr.alias_entity_alias_type_cd=reply->person_list[d.seq].prsnl_alias_list[d2.seq].
     alias_type_code_value))
     JOIN (org
     WHERE org.organization_id=oapr.organization_id
      AND parser(org_parse))
    ORDER BY d.seq, d2.seq
    HEAD d.seq
     orgcnt = 0, lstcnt = 0
    HEAD d2.seq
     orgcnt = 0, lstcnt = 0, stat = alterlist(reply->person_list[d.seq].prsnl_alias_list[d2.seq].
      org_list,10)
    DETAIL
     orgcnt = (orgcnt+ 1), lstcnt = (lstcnt+ 1)
     IF (lstcnt > 10)
      lstcnt = 1, stat = alterlist(reply->person_list[d.seq].prsnl_alias_list[d2.seq].org_list,(
       orgcnt+ 10))
     ENDIF
     reply->person_list[d.seq].prsnl_alias_list[d2.seq].org_list[orgcnt].organization_id = oapr
     .organization_id, reply->person_list[d.seq].prsnl_alias_list[d2.seq].org_list[orgcnt].org_name
      = org.org_name
    FOOT  d2.seq
     stat = alterlist(reply->person_list[d.seq].prsnl_alias_list[d2.seq].org_list,orgcnt)
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = person_cnt),
    person_alias prsa,
    code_value cv1,
    code_value cv2
   PLAN (d)
    JOIN (prsa
    WHERE (prsa.person_id=request->person_list[d.seq].person_id)
     AND parser(person_alias_parse))
    JOIN (cv1
    WHERE cv1.code_value=prsa.person_alias_type_cd)
    JOIN (cv2
    WHERE cv2.code_value=prsa.alias_pool_cd)
   ORDER BY d.seq
   HEAD d.seq
    pracnt = 0, listcnt = 0, stat = alterlist(reply->person_list[d.seq].person_alias_list,10)
   DETAIL
    add_alias_ind = 1
    IF (alias_types_cnt > 0)
     found_ind = 0, start = 1, num = 0,
     found_ind = locateval(num,start,alias_types_cnt,prsa.person_alias_type_cd,request->alias_types[
      num].code_value)
     IF (found_ind=0)
      add_alias_ind = 0
     ENDIF
    ENDIF
    IF (add_alias_ind=1)
     pracnt = (pracnt+ 1), listcnt = (listcnt+ 1)
     IF (listcnt=10)
      stat = alterlist(reply->person_list[d.seq].person_alias_list,(pracnt+ 10))
     ENDIF
     reply->person_list[d.seq].person_alias_list[pracnt].alias_id = prsa.person_alias_id, reply->
     person_list[d.seq].person_alias_list[pracnt].alias = prsa.alias, reply->person_list[d.seq].
     person_alias_list[pracnt].active_ind = prsa.active_ind,
     reply->person_list[d.seq].person_alias_list[pracnt].alias_type_code_value = prsa
     .person_alias_type_cd, reply->person_list[d.seq].person_alias_list[pracnt].alias_type_disp = cv1
     .display, reply->person_list[d.seq].person_alias_list[pracnt].alias_type_mean = cv1.cdf_meaning,
     reply->person_list[d.seq].person_alias_list[pracnt].alias_pool_code_value = prsa.alias_pool_cd,
     reply->person_list[d.seq].person_alias_list[pracnt].alias_pool_disp = cv2.display, reply->
     person_list[d.seq].person_alias_list[pracnt].alias_pool_mean = cv2.cdf_meaning
    ENDIF
   FOOT  d.seq
    stat = alterlist(reply->person_list[d.seq].person_alias_list,pracnt)
   WITH nocounter
  ;end select
  IF (exclude_alias_orgs_ind=0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(person_cnt)),
     (dummyt d2  WITH seq = 1),
     org_alias_pool_reltn oapr,
     organization org
    PLAN (d
     WHERE maxrec(d2,size(reply->person_list[d.seq].person_alias_list,5)))
     JOIN (d2)
     JOIN (oapr
     WHERE (oapr.alias_pool_cd=reply->person_list[d.seq].person_alias_list[d2.seq].
     alias_pool_code_value)
      AND (oapr.alias_entity_alias_type_cd=reply->person_list[d.seq].person_alias_list[d2.seq].
     alias_type_code_value))
     JOIN (org
     WHERE org.organization_id=oapr.organization_id
      AND parser(org_parse))
    ORDER BY d.seq, d2.seq
    HEAD d.seq
     orgcnt = 0, lstcnt = 0
    HEAD d2.seq
     orgcnt = 0, lstcnt = 0, stat = alterlist(reply->person_list[d.seq].person_alias_list[d2.seq].
      org_list,10)
    DETAIL
     orgcnt = (orgcnt+ 1), lstcnt = (lstcnt+ 1)
     IF (lstcnt > 10)
      lstcnt = 1, stat = alterlist(reply->person_list[d.seq].person_alias_list[d2.seq].org_list,(
       orgcnt+ 10))
     ENDIF
     reply->person_list[d.seq].person_alias_list[d2.seq].org_list[orgcnt].organization_id = oapr
     .organization_id, reply->person_list[d.seq].person_alias_list[d2.seq].org_list[orgcnt].org_name
      = org.org_name
    FOOT  d2.seq
     stat = alterlist(reply->person_list[d.seq].person_alias_list[d2.seq].org_list,orgcnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (request->load.get_address_ind)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = person_cnt),
    address a,
    code_value cv1,
    code_value cv2,
    code_value cv3,
    code_value cv4,
    code_value cv5
   PLAN (d)
    JOIN (a
    WHERE ((a.parent_entity_name="PRSNL") OR (a.parent_entity_name="PERSON"))
     AND (a.parent_entity_id=request->person_list[d.seq].person_id)
     AND parser(get_address_parse))
    JOIN (cv1
    WHERE cv1.code_value=a.address_type_cd)
    JOIN (cv2
    WHERE cv2.code_value=a.state_cd)
    JOIN (cv3
    WHERE cv3.code_value=a.country_cd)
    JOIN (cv4
    WHERE cv4.code_value=a.county_cd)
    JOIN (cv5
    WHERE cv5.code_value=a.residence_type_cd)
   ORDER BY d.seq
   HEAD d.seq
    acnt = 0, listcnt = 0, stat = alterlist(reply->person_list[d.seq].address_list,10)
   DETAIL
    acnt = (acnt+ 1), listcnt = (listcnt+ 1)
    IF (listcnt > 10)
     listcnt = 1, stat = alterlist(reply->person_list[d.seq].address_list,(acnt+ 10))
    ENDIF
    reply->person_list[d.seq].address_list[acnt].address_id = a.address_id, reply->person_list[d.seq]
    .address_list[acnt].active_ind = a.active_ind, reply->person_list[d.seq].address_list[acnt].
    address_type_code_value = a.address_type_cd,
    reply->person_list[d.seq].address_list[acnt].address_type_disp = cv1.display, reply->person_list[
    d.seq].address_list[acnt].address_type_mean = cv1.cdf_meaning, reply->person_list[d.seq].
    address_list[acnt].street_addr = a.street_addr,
    reply->person_list[d.seq].address_list[acnt].street_addr2 = a.street_addr2, reply->person_list[d
    .seq].address_list[acnt].street_addr3 = a.street_addr3, reply->person_list[d.seq].address_list[
    acnt].street_addr4 = a.street_addr4,
    reply->person_list[d.seq].address_list[acnt].city = a.city, reply->person_list[d.seq].
    address_list[acnt].state = a.state, reply->person_list[d.seq].address_list[acnt].address_type_seq
     = a.address_type_seq,
    reply->person_list[d.seq].address_list[acnt].state_code_value = a.state_cd, reply->person_list[d
    .seq].address_list[acnt].state_disp = cv2.display, reply->person_list[d.seq].address_list[acnt].
    zipcode = a.zipcode,
    reply->person_list[d.seq].address_list[acnt].country_code_value = a.country_cd, reply->
    person_list[d.seq].address_list[acnt].country_disp = cv3.display, reply->person_list[d.seq].
    address_list[acnt].county_code_value = a.county_cd,
    reply->person_list[d.seq].address_list[acnt].county_disp = cv4.display, reply->person_list[d.seq]
    .address_list[acnt].residence_type_code_value = a.residence_type_cd, reply->person_list[d.seq].
    address_list[acnt].residence_type_disp = cv5.display,
    reply->person_list[d.seq].address_list[acnt].residence_type_mean = cv5.cdf_meaning, reply->
    person_list[d.seq].address_list[acnt].contact_name = a.contact_name, reply->person_list[d.seq].
    address_list[acnt].comment_txt = a.comment_txt
   FOOT  d.seq
    stat = alterlist(reply->person_list[d.seq].address_list,acnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (request->load.get_phone_ind)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = person_cnt),
    phone pc,
    code_value cv1,
    code_value cv2
   PLAN (d)
    JOIN (pc
    WHERE ((pc.parent_entity_name="PRSNL") OR (pc.parent_entity_name="PERSON"))
     AND (pc.parent_entity_id=request->person_list[d.seq].person_id)
     AND ((pc.active_ind=1) OR (iic=1)) )
    JOIN (cv1
    WHERE cv1.code_value=pc.phone_type_cd)
    JOIN (cv2
    WHERE cv2.code_value=pc.phone_format_cd)
   ORDER BY d.seq
   HEAD d.seq
    ccnt = 0, listcnt = 0, stat = alterlist(reply->person_list[d.seq].phone_list,10)
   DETAIL
    ccnt = (ccnt+ 1), listcnt = (listcnt+ 1)
    IF (listcnt > 10)
     listcnt = 1, stat = alterlist(reply->person_list[d.seq].phone_list,(ccnt+ 10))
    ENDIF
    reply->person_list[d.seq].phone_list[ccnt].phone_id = pc.phone_id, reply->person_list[d.seq].
    phone_list[ccnt].active_ind = pc.active_ind, reply->person_list[d.seq].phone_list[ccnt].
    phone_type_code_value = pc.phone_type_cd,
    reply->person_list[d.seq].phone_list[ccnt].phone_type_disp = cv1.display, reply->person_list[d
    .seq].phone_list[ccnt].phone_type_mean = cv1.cdf_meaning, reply->person_list[d.seq].phone_list[
    ccnt].sequence = pc.phone_type_seq,
    reply->person_list[d.seq].phone_list[ccnt].phone_num = pc.phone_num, reply->person_list[d.seq].
    phone_list[ccnt].description = pc.description, reply->person_list[d.seq].phone_list[ccnt].contact
     = pc.contact,
    reply->person_list[d.seq].phone_list[ccnt].call_instruction = pc.call_instruction, reply->
    person_list[d.seq].phone_list[ccnt].extension = pc.extension, reply->person_list[d.seq].
    phone_list[ccnt].paging_code = pc.paging_code,
    reply->person_list[d.seq].phone_list[ccnt].phone_formatted = cnvtphone(pc.phone_num,pc
     .phone_format_cd), reply->person_list[d.seq].phone_list[ccnt].operation_hours = pc
    .operation_hours, reply->person_list[d.seq].phone_list[ccnt].contact_method_code_value = pc
    .contact_method_cd,
    reply->person_list[d.seq].phone_list[ccnt].phone_format_code_value = pc.phone_format_cd, reply->
    person_list[d.seq].phone_list[ccnt].phone_format_disp = cv2.display, reply->person_list[d.seq].
    phone_list[ccnt].phone_format_mean = cv2.cdf_meaning
   FOOT  d.seq
    stat = alterlist(reply->person_list[d.seq].phone_list,ccnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (request->load.get_org_ind)
  IF ((request->load.get_fac_ind=1))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = person_cnt),
     prsnl_org_reltn por,
     organization org,
     code_value cv,
     org_type_reltn otr
    PLAN (d)
     JOIN (por
     WHERE (por.person_id=request->person_list[d.seq].person_id)
      AND ((por.active_ind=1
      AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ((por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (por.end_effective_dt_tm=
     null)) ) OR (iic=1)) )
     JOIN (otr
     WHERE otr.org_type_cd=fac_org_type_code_value
      AND otr.organization_id=por.organization_id)
     JOIN (org
     WHERE org.organization_id=otr.organization_id
      AND parser(org_parse))
     JOIN (cv
     WHERE cv.code_value=por.confid_level_cd)
    ORDER BY d.seq
    HEAD d.seq
     orgcnt = 0, listcnt = 0, stat = alterlist(reply->person_list[d.seq].org_list,10)
    DETAIL
     orgcnt = (orgcnt+ 1), listcnt = (listcnt+ 1)
     IF (listcnt > 10)
      listcnt = 1, stat = alterlist(reply->person_list[d.seq].org_list,(orgcnt+ 10))
     ENDIF
     reply->person_list[d.seq].org_list[orgcnt].prsnl_org_reltn_id = por.prsnl_org_reltn_id, reply->
     person_list[d.seq].org_list[orgcnt].organization_id = por.organization_id, reply->person_list[d
     .seq].org_list[orgcnt].organization_name = org.org_name,
     reply->person_list[d.seq].org_list[orgcnt].active_ind = org.active_ind
     IF (por.confid_level_cd > 0)
      reply->person_list[d.seq].org_list[orgcnt].confid_level_code_value = por.confid_level_cd, reply
      ->person_list[d.seq].org_list[orgcnt].confid_level_disp = cv.display, reply->person_list[d.seq]
      .org_list[orgcnt].confid_level_mean = cv.cdf_meaning
     ELSE
      reply->person_list[d.seq].org_list[orgcnt].confid_level_code_value = 0, reply->person_list[d
      .seq].org_list[orgcnt].confid_level_disp = " "
     ENDIF
    FOOT  d.seq
     stat = alterlist(reply->person_list[d.seq].org_list,orgcnt)
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = person_cnt),
     prsnl_org_reltn por,
     organization org,
     code_value cv
    PLAN (d)
     JOIN (por
     WHERE (por.person_id=request->person_list[d.seq].person_id)
      AND ((por.active_ind=1
      AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ((por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (por.end_effective_dt_tm=
     null)) ) OR (iic=1)) )
     JOIN (org
     WHERE org.organization_id=por.organization_id
      AND parser(org_parse))
     JOIN (cv
     WHERE cv.code_value=por.confid_level_cd)
    ORDER BY d.seq
    HEAD d.seq
     orgcnt = 0, listcnt = 0, stat = alterlist(reply->person_list[d.seq].org_list,10)
    DETAIL
     orgcnt = (orgcnt+ 1), listcnt = (listcnt+ 1)
     IF (listcnt > 10)
      listcnt = 1, stat = alterlist(reply->person_list[d.seq].org_list,(orgcnt+ 10))
     ENDIF
     reply->person_list[d.seq].org_list[orgcnt].prsnl_org_reltn_id = por.prsnl_org_reltn_id, reply->
     person_list[d.seq].org_list[orgcnt].organization_id = por.organization_id, reply->person_list[d
     .seq].org_list[orgcnt].organization_name = org.org_name,
     reply->person_list[d.seq].org_list[orgcnt].active_ind = org.active_ind
     IF (por.confid_level_cd > 0)
      reply->person_list[d.seq].org_list[orgcnt].confid_level_code_value = por.confid_level_cd, reply
      ->person_list[d.seq].org_list[orgcnt].confid_level_disp = cv.display, reply->person_list[d.seq]
      .org_list[orgcnt].confid_level_mean = cv.cdf_meaning
     ELSE
      reply->person_list[d.seq].org_list[orgcnt].confid_level_code_value = 0, reply->person_list[d
      .seq].org_list[orgcnt].confid_level_disp = " "
     ENDIF
    FOOT  d.seq
     stat = alterlist(reply->person_list[d.seq].org_list,orgcnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (request->load.get_org_group_ind)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = person_cnt),
    org_set_prsnl_r ospr,
    org_set os,
    code_value cv
   PLAN (d)
    JOIN (ospr
    WHERE (ospr.prsnl_id=request->person_list[d.seq].person_id)
     AND ((ospr.active_ind=1) OR (iic=1)) )
    JOIN (os
    WHERE os.org_set_id=ospr.org_set_id)
    JOIN (cv
    WHERE cv.code_value=ospr.org_set_type_cd)
   ORDER BY d.seq
   HEAD d.seq
    oscnt = 0, listcnt = 0, stat = alterlist(reply->person_list[d.seq].org_group_list,10)
   DETAIL
    oscnt = (oscnt+ 1), listcnt = (listcnt+ 1)
    IF (listcnt > 10)
     listcnt = 1, stat = alterlist(reply->person_list[d.seq].org_group_list,(oscnt+ 10))
    ENDIF
    reply->person_list[d.seq].org_group_list[oscnt].org_set_prsnl_r_id = ospr.org_set_prsnl_r_id,
    reply->person_list[d.seq].org_group_list[oscnt].active_ind = ospr.active_ind, reply->person_list[
    d.seq].org_group_list[oscnt].org_set_type_code_value = ospr.org_set_type_cd,
    reply->person_list[d.seq].org_group_list[oscnt].org_set_type_disp = cv.display, reply->
    person_list[d.seq].org_group_list[oscnt].org_set_type_mean = cv.cdf_meaning, reply->person_list[d
    .seq].org_group_list[oscnt].org_set_id = ospr.org_set_id,
    reply->person_list[d.seq].org_group_list[oscnt].org_set_name = os.name
   FOOT  d.seq
    stat = alterlist(reply->person_list[d.seq].org_group_list,oscnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (request->load.get_loc_ind)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = person_cnt),
    prsnl_location_r plr,
    code_value cv1,
    code_value cv2
   PLAN (d)
    JOIN (plr
    WHERE (plr.person_id=request->person_list[d.seq].person_id))
    JOIN (cv1
    WHERE plr.location_cd=cv1.code_value)
    JOIN (cv2
    WHERE plr.location_type_cd=cv2.code_value)
   ORDER BY d.seq
   HEAD d.seq
    loccnt = 0, listcnt = 0, stat = alterlist(reply->person_list[d.seq].location_list,10)
   DETAIL
    loccnt = (loccnt+ 1), listcnt = (listcnt+ 1)
    IF (listcnt > 10)
     listcnt = 1, stat = alterlist(reply->person_list[d.seq].location_list,(loccnt+ 10))
    ENDIF
    reply->person_list[d.seq].location_list[loccnt].location_code_value = plr.location_cd, reply->
    person_list[d.seq].location_list[loccnt].location_disp = cv1.display, reply->person_list[d.seq].
    location_list[loccnt].location_mean = cv1.cdf_meaning,
    reply->person_list[d.seq].location_list[loccnt].location_type_code_value = plr.location_type_cd,
    reply->person_list[d.seq].location_list[loccnt].location_type_disp = cv2.display, reply->
    person_list[d.seq].location_list[loccnt].location_type_mean = cv2.cdf_meaning
   FOOT  d.seq
    stat = alterlist(reply->person_list[d.seq].location_list,loccnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (request->load.get_user_group_ind)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = person_cnt),
    prsnl_group_reltn pgr,
    prsnl_group pg,
    code_value cv
   PLAN (d)
    JOIN (pgr
    WHERE (pgr.person_id=request->person_list[d.seq].person_id)
     AND ((pgr.active_ind=1) OR (iic=1)) )
    JOIN (pg
    WHERE pgr.prsnl_group_id=pg.prsnl_group_id)
    JOIN (cv
    WHERE pgr.prsnl_group_r_cd=cv.code_value)
   ORDER BY d.seq
   HEAD d.seq
    pgcnt = 0, listcnt = 0, stat = alterlist(reply->person_list[d.seq].user_group_list,10)
   DETAIL
    pgcnt = (pgcnt+ 1), listcnt = (listcnt+ 1)
    IF (listcnt > 10)
     listcnt = 1, stat = alterlist(reply->person_list[d.seq].user_group_list,(pgcnt+ 10))
    ENDIF
    reply->person_list[d.seq].user_group_list[pgcnt].prsnl_group_reltn_id = pgr.prsnl_group_reltn_id,
    reply->person_list[d.seq].user_group_list[pgcnt].prsnl_group_id = pgr.prsnl_group_id, reply->
    person_list[d.seq].user_group_list[pgcnt].prsnl_group_id = pgr.prsnl_group_id,
    reply->person_list[d.seq].user_group_list[pgcnt].active_ind = pgr.active_ind, reply->person_list[
    d.seq].user_group_list[pgcnt].prsnl_group_r_code_value = pgr.prsnl_group_r_cd, reply->
    person_list[d.seq].user_group_list[pgcnt].prsnl_group_r_disp = cv.display,
    reply->person_list[d.seq].user_group_list[pgcnt].prsnl_group_r_mean = cv.cdf_meaning, reply->
    person_list[d.seq].user_group_list[pgcnt].prsnl_group_name = pg.prsnl_group_name, reply->
    person_list[d.seq].user_group_list[pgcnt].primary_ind = pgr.primary_ind
   FOOT  d.seq
    stat = alterlist(reply->person_list[d.seq].user_group_list,pgcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (request->load.get_svcres_ind)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = person_cnt),
    prsnl_service_resource_reltn psr,
    code_value cv
   PLAN (d)
    JOIN (psr
    WHERE (psr.prsnl_id=request->person_list[d.seq].person_id))
    JOIN (cv
    WHERE psr.service_resource_cd=cv.code_value)
   ORDER BY d.seq
   HEAD d.seq
    psrcnt = 0, listcnt = 0, stat = alterlist(reply->person_list[d.seq].service_resource_list,10)
   DETAIL
    psrcnt = (psrcnt+ 1), listcnt = (listcnt+ 1)
    IF (listcnt > 10)
     listcnt = 1, stat = alterlist(reply->person_list[d.seq].service_resource_list,(psrcnt+ 10))
    ENDIF
    reply->person_list[d.seq].service_resource_list[psrcnt].service_resource_code_value = psr
    .service_resource_cd, reply->person_list[d.seq].service_resource_list[psrcnt].
    service_resource_disp = cv.display, reply->person_list[d.seq].service_resource_list[psrcnt].
    service_resource_mean = cv.cdf_meaning
   FOOT  d.seq
    stat = alterlist(reply->person_list[d.seq].service_resource_list,psrcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (request->load.get_prsnl_notify_ind)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = person_cnt),
    prsnl_notify pn,
    code_value cv
   PLAN (d)
    JOIN (pn
    WHERE (pn.person_id=request->person_list[d.seq].person_id)
     AND ((pn.active_ind=1) OR (iic=1)) )
    JOIN (cv
    WHERE pn.task_activity_cd=cv.code_value)
   ORDER BY d.seq
   HEAD d.seq
    pncnt = 0, listcnt = 0, stat = alterlist(reply->person_list[d.seq].notify_list,10)
   DETAIL
    pncnt = (pncnt+ 1), listcnt = (listcnt+ 1)
    IF (listcnt > 10)
     listcnt = 1, stat = alterlist(reply->person_list[d.seq].notify_list,(pncnt+ 10))
    ENDIF
    reply->person_list[d.seq].notify_list[pncnt].prsnl_notify_id = pn.prsnl_notify_id, reply->
    person_list[d.seq].notify_list[pncnt].active_ind = pn.active_ind, reply->person_list[d.seq].
    notify_list[pncnt].task_activity_code_value = pn.task_activity_cd,
    reply->person_list[d.seq].notify_list[pncnt].task_activity_disp = cv.display, reply->person_list[
    d.seq].notify_list[pncnt].task_activity_mean = cv.cdf_meaning, reply->person_list[d.seq].
    notify_list[pncnt].notify_flag = pn.notify_flag,
    reply->person_list[d.seq].notify_list[pncnt].active_ind = pn.active_ind
   FOOT  d.seq
    stat = alterlist(reply->person_list[d.seq].notify_list,pncnt)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(" >> PROGRAM NAME:  BED_GET_PRSNL_BY_ID_B  >> ERROR MESSAGE: ",
   error_msg)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO

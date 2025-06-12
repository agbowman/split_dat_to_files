CREATE PROGRAM bed_get_prsnl_by_id:dba
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
        3 prsnl_alias_sub_type_cd = f8
        3 active_status_cd = f8
        3 beg_effective_dt_tm = dq8
        3 end_effective_dt_tm = dq8
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
        3 person_alias_sub_type_cd = f8
        3 active_status_cd = f8
        3 beg_effective_dt_tm = dq8
        3 end_effective_dt_tm = dq8
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
        3 active_status_cd = f8
        3 beg_effective_dt_tm = dq8
        3 end_effective_dt_tm = dq8
        3 residence_cd = f8
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
        3 parent_entity_id = f8
        3 parent_entity_name = vc
        3 beg_effective_dt_tm = dq8
        3 end_effective_dt_tm = dq8
      2 org_list[*]
        3 prsnl_org_reltn_id = f8
        3 organization_id = f8
        3 organization_name = vc
        3 confid_level_code_value = f8
        3 confid_level_disp = vc
        3 confid_level_mean = vc
        3 active_ind = i2
        3 beg_effective_dt_tm = dq8
        3 end_effective_dt_tm = dq8
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
        3 prsnl_group_type_cd = f8
        3 prsnl_group_class_cd = f8
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
        3 organization_id = f8
        3 beg_effective_dt_tm = dq8
        3 end_effective_dt_tm = dq8
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
      2 external_ind = i2
      2 comment_list[*]
        3 comment = vc
        3 type_code_value = f8
        3 type_disp = vc
        3 type_mean = vc
        3 last_updt_prsnl_id = f8
        3 last_updt_prsnl_name = vc
        3 last_updt_dt_tm = dq8
      2 result_delivery_method_list[*]
        3 type_code_value = f8
        3 type_disp = vc
        3 type_mean = vc
        3 last_updt_prsnl_id = f8
        3 last_updt_prsnl_name = vc
        3 last_updt_dt_tm = dq8
      2 active_status_cd = f8
      2 name_type_cd = f8
      2 name_prefix = vc
      2 birth_tz = i4
      2 birth_prec_flag = i2
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE get_org_name(alias_pool=f8(ref),alias_type=f8(ref),org_count=i2(ref)) = null
 RECORD temp_orgs(
   1 t_org_list[*]
     2 t_organization_id = f8
     2 t_org_name = vc
 )
 SET reply->status_data.status = "F"
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
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE curr_dt_tm = f8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE error_msg = vc
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
 SET exit_qual = 1
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET rpt_person_id = fillstring(20," ")
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
 SET person_cnt = size(request->person_list,5)
 SET stat = alterlist(reply->person_list,person_cnt)
 SET stat = alterlist(reply->status_data.subeventstatus,person_cnt)
 FOR (i = 1 TO person_cnt)
   SET rpt_person_id = build(cnvtint(request->person_list[i].person_id))
   IF (request->load.get_person_ind)
    SELECT INTO "nl:"
     FROM person p,
      code_value cv
     PLAN (p
      WHERE (p.person_id=request->person_list[i].person_id))
      JOIN (cv
      WHERE p.sex_cd=cv.code_value)
     ORDER BY p.person_id, cv.code_value
     HEAD p.person_id
      reply->person_list[i].person_id = p.person_id, reply->person_list[i].prsnl_id = p.person_id,
      reply->person_list[i].name_first = p.name_first,
      reply->person_list[i].name_middle = p.name_middle, reply->person_list[i].name_last = p
      .name_last, reply->person_list[i].name_full_formatted = p.name_full_formatted,
      reply->person_list[i].birth_dt_tm = p.birth_dt_tm, reply->person_list[i].birth_tz = p.birth_tz,
      reply->person_list[i].birth_prec_flag = p.birth_prec_flag
     HEAD cv.code_value
      reply->person_list[i].sex_code_value = p.sex_cd, reply->person_list[i].sex_disp = cv.display,
      reply->person_list[i].sex_mean = cv.cdf_meaning
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET found_person_ind = 0
     SET error_msg = concat("No person data found for person_id: ",rpt_person_id)
     CALL bederror(error_msg)
    ELSE
     SET found_person_ind = 1
    ENDIF
    IF (found_person_ind)
     SELECT INTO "nl:"
      FROM person_name pn
      PLAN (pn
       WHERE (pn.person_id=request->person_list[i].person_id)
        AND pn.name_type_cd=prsnl_name_type_cd
        AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND pn.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
      ORDER BY pn.updt_dt_tm DESC, pn.person_id
      HEAD pn.person_id
       reply->person_list[i].name_title = pn.name_title, reply->person_list[i].name_suffix = pn
       .name_suffix, reply->person_list[i].person_name_id = pn.person_name_id,
       reply->person_list[i].name_type_cd = pn.name_type_cd, reply->person_list[i].name_prefix = pn
       .name_prefix
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET error_msg = concat("No person name data found for person_id: ",rpt_person_id)
     ENDIF
     SELECT INTO "nl:"
      FROM prsnl pr,
       code_value cv1,
       code_value cv2
      PLAN (pr
       WHERE (pr.person_id=request->person_list[i].person_id))
       JOIN (cv1
       WHERE pr.position_cd=cv1.code_value)
       JOIN (cv2
       WHERE pr.prim_assign_loc_cd=cv2.code_value)
      ORDER BY pr.person_id, cv1.code_value, cv2.code_value
      HEAD pr.person_id
       reply->person_list[i].prsnl_name_first = pr.name_first, reply->person_list[i].prsnl_name_last
        = pr.name_last, reply->person_list[i].prsnl_name_full_formatted = pr.name_full_formatted,
       reply->person_list[i].email = pr.email, reply->person_list[i].username = pr.username, reply->
       person_list[i].physician_ind = pr.physician_ind,
       reply->person_list[i].active_ind = pr.active_ind, reply->person_list[i].beg_effective_dt_tm =
       pr.beg_effective_dt_tm, reply->person_list[i].end_effective_dt_tm = pr.end_effective_dt_tm,
       reply->person_list[i].external_ind = pr.external_ind, reply->person_list[i].active_status_cd
        = pr.active_status_cd
      HEAD cv1.code_value
       reply->person_list[i].position_code_value = pr.position_cd, reply->person_list[i].
       position_disp = cv1.display, reply->person_list[i].position_mean = cv1.cdf_meaning
      HEAD cv2.code_value
       reply->person_list[i].primary_work_loc_code_value = pr.prim_assign_loc_cd, reply->person_list[
       i].primary_work_loc_disp = cv2.display, reply->person_list[i].primary_work_loc_mean = cv2
       .cdf_meaning
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET found_prsnl_ind = 0
      SET error_msg = concat("No prsnl data found for person_id: ",rpt_person_id)
      CALL bederror(error_msg)
     ELSE
      SET found_prsnl_ind = 1
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM prsnl_prsnl_reltn ppr,
      prsnl p2,
      code_value cv
     PLAN (ppr
      WHERE (ppr.related_person_id=request->person_list[i].person_id)
       AND ((ppr.active_ind=1) OR (iic=1)) )
      JOIN (p2
      WHERE parser(prsnl_parse))
      JOIN (cv
      WHERE ppr.prsnl_prsnl_reltn_cd=cv.code_value)
     ORDER BY ppr.prsnl_prsnl_reltn_id, p2.person_id, cv.code_value
     HEAD REPORT
      pprcnt = 0, listcnt = 0, stat = alterlist(reply->person_list[i].related_prsnl_list,10)
     HEAD ppr.prsnl_prsnl_reltn_id
      pprcnt = (pprcnt+ 1), listcnt = (listcnt+ 1)
      IF (listcnt > 10)
       listcnt = 1, stat = alterlist(reply->person_list[i].related_prsnl_list,(pprcnt+ 10))
      ENDIF
      reply->person_list[i].related_prsnl_list[pprcnt].prsnl_prsnl_reltn_id = ppr
      .prsnl_prsnl_reltn_id, reply->person_list[i].related_prsnl_list[pprcnt].
      prsnl_prsnl_reltn_code_value = ppr.prsnl_prsnl_reltn_cd, reply->person_list[i].
      related_prsnl_list[pprcnt].active_ind = ppr.active_ind,
      reply->person_list[i].related_prsnl_list[pprcnt].organization_id = ppr.organization_id, reply->
      person_list[i].related_prsnl_list[pprcnt].beg_effective_dt_tm = ppr.beg_effective_dt_tm, reply
      ->person_list[i].related_prsnl_list[pprcnt].end_effective_dt_tm = ppr.end_effective_dt_tm
     HEAD cv.code_value
      reply->person_list[i].related_prsnl_list[pprcnt].prsnl_prsnl_reltn_disp = cv.display, reply->
      person_list[i].related_prsnl_list[pprcnt].prsnl_prsnl_reltn_mean = cv.cdf_meaning, reply->
      person_list[i].related_prsnl_list[pprcnt].related_person_id = ppr.person_id
     HEAD p2.person_id
      reply->person_list[i].related_prsnl_list[pprcnt].related_person_name = p2.name_full_formatted
     FOOT REPORT
      stat = alterlist(reply->person_list[i].related_prsnl_list,pprcnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("Return prsnl error")
   ENDIF
   IF (request->load.get_alias_ind)
    SET pracnt = 0
    SET listcnt = 0
    SET alias_cnt = 0
    SELECT INTO "nl:"
     FROM prsnl_alias pra,
      code_value cv1,
      code_value cv2
     PLAN (pra
      WHERE (pra.person_id=request->person_list[i].person_id)
       AND parser(prsnl_alias_parse))
      JOIN (cv1
      WHERE pra.prsnl_alias_type_cd=cv1.code_value)
      JOIN (cv2
      WHERE pra.alias_pool_cd=cv2.code_value)
     ORDER BY pra.prsnl_alias_id, cv1.code_value, cv2.code_value
     HEAD REPORT
      pracnt = 0, listcnt = 0, stat = alterlist(reply->person_list[i].prsnl_alias_list,10)
     HEAD pra.prsnl_alias_id
      add_alias_ind = 1
      IF (alias_types_cnt > 0)
       found_ind = 0, start = 1, num = 0,
       found_ind = locateval(num,start,alias_types_cnt,pra.prsnl_alias_type_cd,request->alias_types[
        num].code_value)
       IF (found_ind=0)
        add_alias_ind = 0
       ENDIF
      ENDIF
      IF (add_alias_ind=1)
       pracnt = (pracnt+ 1), listcnt = (listcnt+ 1)
       IF (listcnt > 10)
        stat = alterlist(reply->person_list[i].prsnl_alias_list,(pracnt+ 10)), listcnt = 1
       ENDIF
       reply->person_list[i].prsnl_alias_list[pracnt].alias_id = pra.prsnl_alias_id, reply->
       person_list[i].prsnl_alias_list[pracnt].alias = pra.alias, reply->person_list[i].
       prsnl_alias_list[pracnt].active_ind = pra.active_ind,
       reply->person_list[i].prsnl_alias_list[pracnt].alias_type_code_value = pra.prsnl_alias_type_cd,
       reply->person_list[i].prsnl_alias_list[pracnt].prsnl_alias_sub_type_cd = pra
       .prsnl_alias_sub_type_cd, reply->person_list[i].prsnl_alias_list[pracnt].active_status_cd =
       pra.active_status_cd,
       reply->person_list[i].prsnl_alias_list[pracnt].beg_effective_dt_tm = pra.beg_effective_dt_tm,
       reply->person_list[i].prsnl_alias_list[pracnt].end_effective_dt_tm = pra.end_effective_dt_tm,
       reply->person_list[i].prsnl_alias_list[pracnt].alias_type_disp = cv1.display,
       reply->person_list[i].prsnl_alias_list[pracnt].alias_type_mean = cv1.cdf_meaning, reply->
       person_list[i].prsnl_alias_list[pracnt].alias_pool_code_value = pra.alias_pool_cd, reply->
       person_list[i].prsnl_alias_list[pracnt].alias_pool_disp = cv2.display,
       reply->person_list[i].prsnl_alias_list[pracnt].alias_pool_mean = cv2.cdf_meaning
      ENDIF
     FOOT REPORT
      stat = alterlist(reply->person_list[i].prsnl_alias_list,pracnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("Return prsnl alias error")
    FOR (ai = 1 TO pracnt)
      SET apool = reply->person_list[i].prsnl_alias_list[ai].alias_pool_code_value
      SET atype = reply->person_list[i].prsnl_alias_list[ai].alias_type_code_value
      SET org_count = 0
      IF (exclude_alias_orgs_ind=0)
       CALL get_org_name(apool,atype,org_count)
      ENDIF
      IF (org_count > 0)
       SET stat = alterlist(reply->person_list[i].prsnl_alias_list[ai].org_list,org_count)
       FOR (xx = 1 TO org_count)
        SET reply->person_list[i].prsnl_alias_list[ai].org_list[xx].organization_id = temp_orgs->
        t_org_list[xx].t_organization_id
        SET reply->person_list[i].prsnl_alias_list[ai].org_list[xx].org_name = temp_orgs->t_org_list[
        xx].t_org_name
       ENDFOR
      ENDIF
    ENDFOR
    SET pracnt = 0
    SELECT INTO "nl:"
     FROM person_alias prsa,
      code_value cv1,
      code_value cv2
     PLAN (prsa
      WHERE (prsa.person_id=request->person_list[i].person_id)
       AND parser(person_alias_parse))
      JOIN (cv1
      WHERE prsa.person_alias_type_cd=cv1.code_value)
      JOIN (cv2
      WHERE prsa.alias_pool_cd=cv2.code_value)
     ORDER BY prsa.person_alias_id, cv1.code_value, cv2.code_value
     HEAD REPORT
      pracnt = 0, listcnt = 0, stat = alterlist(reply->person_list[i].person_alias_list,10)
     HEAD prsa.person_alias_id
      add_alias_ind = 1
      IF (alias_types_cnt > 0)
       found_ind = 0, start = 1, num = 0,
       found_ind = locateval(num,start,alias_types_cnt,prsa.person_alias_type_cd,request->
        alias_types[num].code_value)
       IF (found_ind=0)
        add_alias_ind = 0
       ENDIF
      ENDIF
      IF (add_alias_ind=1)
       pracnt = (pracnt+ 1), listcnt = (listcnt+ 1)
       IF (listcnt > 10)
        stat = alterlist(reply->person_list[i].person_alias_list,(pracnt+ 10)), listcnt = 1
       ENDIF
       reply->person_list[i].person_alias_list[pracnt].alias_id = prsa.person_alias_id, reply->
       person_list[i].person_alias_list[pracnt].alias = prsa.alias, reply->person_list[i].
       person_alias_list[pracnt].active_ind = prsa.active_ind,
       reply->person_list[i].person_alias_list[pracnt].alias_type_code_value = prsa
       .person_alias_type_cd, reply->person_list[i].person_alias_list[pracnt].alias_type_disp = cv1
       .display, reply->person_list[i].person_alias_list[pracnt].alias_type_mean = cv1.cdf_meaning,
       reply->person_list[i].person_alias_list[pracnt].alias_pool_code_value = prsa.alias_pool_cd,
       reply->person_list[i].person_alias_list[pracnt].alias_pool_disp = cv2.display, reply->
       person_list[i].person_alias_list[pracnt].alias_pool_mean = cv2.cdf_meaning,
       reply->person_list[i].person_alias_list[pracnt].person_alias_sub_type_cd = prsa.alias_pool_cd,
       reply->person_list[i].person_alias_list[pracnt].active_status_cd = prsa.active_status_cd,
       reply->person_list[i].person_alias_list[pracnt].beg_effective_dt_tm = prsa.beg_effective_dt_tm,
       reply->person_list[i].person_alias_list[pracnt].end_effective_dt_tm = prsa.end_effective_dt_tm
      ENDIF
     FOOT REPORT
      stat = alterlist(reply->person_list[i].person_alias_list,pracnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("Return person alias error")
    FOR (ai = 1 TO pracnt)
      SET apool = reply->person_list[i].person_alias_list[ai].alias_pool_code_value
      SET atype = reply->person_list[i].person_alias_list[ai].alias_type_code_value
      SET org_count = 0
      IF (exclude_alias_orgs_ind=0)
       CALL get_org_name(apool,atype,org_count)
      ENDIF
      IF (org_count > 0)
       SET stat = alterlist(reply->person_list[i].person_alias_list[ai].org_list,org_count)
       FOR (xx = 1 TO org_count)
        SET reply->person_list[i].person_alias_list[ai].org_list[xx].organization_id = temp_orgs->
        t_org_list[xx].t_organization_id
        SET reply->person_list[i].person_alias_list[ai].org_list[xx].org_name = temp_orgs->
        t_org_list[xx].t_org_name
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
   IF (request->load.get_address_ind)
    SET acnt = 0
    SELECT INTO "nl:"
     FROM address a,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      code_value cv4
     PLAN (a
      WHERE ((a.parent_entity_name="PRSNL") OR (a.parent_entity_name="PERSON"))
       AND (a.parent_entity_id=request->person_list[i].person_id)
       AND parser(get_address_parse))
      JOIN (cv1
      WHERE a.address_type_cd=cv1.code_value)
      JOIN (cv2
      WHERE a.state_cd=cv2.code_value)
      JOIN (cv3
      WHERE a.country_cd=cv3.code_value)
      JOIN (cv4
      WHERE a.county_cd=cv4.code_value)
     ORDER BY a.address_id, cv1.code_value, cv2.code_value,
      cv3.code_value, cv4.code_value
     HEAD REPORT
      acnt = 0, listcnt = 0, stat = alterlist(reply->person_list[i].address_list,10)
     HEAD a.address_id
      acnt = (acnt+ 1), listcnt = (listcnt+ 1)
      IF (listcnt > 10)
       listcnt = 1, stat = alterlist(reply->person_list[i].address_list,(acnt+ 10))
      ENDIF
      reply->person_list[i].address_list[acnt].address_id = a.address_id, reply->person_list[i].
      address_list[acnt].active_ind = a.active_ind, reply->person_list[i].address_list[acnt].
      active_status_cd = a.active_status_cd,
      reply->person_list[i].address_list[acnt].beg_effective_dt_tm = a.beg_effective_dt_tm, reply->
      person_list[i].address_list[acnt].end_effective_dt_tm = a.end_effective_dt_tm, reply->
      person_list[i].address_list[acnt].residence_cd = a.residence_cd
     HEAD cv1.code_value
      reply->person_list[i].address_list[acnt].address_type_code_value = a.address_type_cd, reply->
      person_list[i].address_list[acnt].address_type_disp = cv1.display, reply->person_list[i].
      address_list[acnt].address_type_mean = cv1.cdf_meaning,
      reply->person_list[i].address_list[acnt].street_addr = a.street_addr, reply->person_list[i].
      address_list[acnt].street_addr2 = a.street_addr2, reply->person_list[i].address_list[acnt].
      street_addr3 = a.street_addr3,
      reply->person_list[i].address_list[acnt].street_addr4 = a.street_addr4, reply->person_list[i].
      address_list[acnt].city = a.city, reply->person_list[i].address_list[acnt].state = a.state,
      reply->person_list[i].address_list[acnt].address_type_seq = a.address_type_seq
     HEAD cv2.code_value
      reply->person_list[i].address_list[acnt].state_code_value = a.state_cd, reply->person_list[i].
      address_list[acnt].state_disp = cv2.display, reply->person_list[i].address_list[acnt].zipcode
       = a.zipcode
     HEAD cv3.code_value
      reply->person_list[i].address_list[acnt].country_code_value = a.country_cd, reply->person_list[
      i].address_list[acnt].country_disp = cv3.display
     HEAD cv4.code_value
      reply->person_list[i].address_list[acnt].county_code_value = a.county_cd, reply->person_list[i]
      .address_list[acnt].county_disp = cv4.display, reply->person_list[i].address_list[acnt].
      residence_type_code_value = a.residence_type_cd,
      reply->person_list[i].address_list[acnt].contact_name = a.contact_name, reply->person_list[i].
      address_list[acnt].comment_txt = a.comment_txt
     FOOT REPORT
      stat = alterlist(reply->person_list[i].address_list,acnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("Return prsnl addresses error")
    IF (acnt > 0)
     FOR (z = 1 TO acnt)
       SELECT INTO "nl:"
        FROM code_value cv5
        PLAN (cv5
         WHERE (cv5.code_value=reply->person_list[i].address_list[z].residence_type_code_value))
        ORDER BY cv5.code_value
        HEAD cv5.code_value
         reply->person_list[i].address_list[z].residence_type_disp = cv5.display, reply->person_list[
         i].address_list[z].residence_type_mean = cv5.cdf_meaning
        WITH nocounter
       ;end select
     ENDFOR
    ENDIF
   ENDIF
   IF (request->load.get_phone_ind)
    SELECT INTO "nl:"
     FROM phone pc,
      code_value cv1,
      code_value cv2
     PLAN (pc
      WHERE ((pc.parent_entity_name="PRSNL") OR (pc.parent_entity_name="PERSON"))
       AND (pc.parent_entity_id=request->person_list[i].person_id)
       AND ((pc.active_ind=1) OR (iic=1)) )
      JOIN (cv1
      WHERE pc.phone_type_cd=cv1.code_value)
      JOIN (cv2
      WHERE pc.phone_format_cd=cv2.code_value)
     ORDER BY pc.phone_id, cv1.code_value, cv2.code_value
     HEAD REPORT
      ccnt = 0, listcnt = 0, stat = alterlist(reply->person_list[i].phone_list,10)
     HEAD pc.phone_id
      ccnt = (ccnt+ 1), listcnt = (listcnt+ 1)
      IF (listcnt > 10)
       listcnt = 1, stat = alterlist(reply->person_list[i].phone_list,(ccnt+ 10))
      ENDIF
      reply->person_list[i].phone_list[ccnt].phone_id = pc.phone_id, reply->person_list[i].
      phone_list[ccnt].active_ind = pc.active_ind, reply->person_list[i].phone_list[ccnt].
      parent_entity_id = pc.parent_entity_id,
      reply->person_list[i].phone_list[ccnt].parent_entity_name = pc.parent_entity_name, reply->
      person_list[i].phone_list[ccnt].beg_effective_dt_tm = pc.beg_effective_dt_tm, reply->
      person_list[i].phone_list[ccnt].end_effective_dt_tm = pc.end_effective_dt_tm
     HEAD cv1.code_value
      reply->person_list[i].phone_list[ccnt].phone_type_code_value = pc.phone_type_cd, reply->
      person_list[i].phone_list[ccnt].phone_type_disp = cv1.display, reply->person_list[i].
      phone_list[ccnt].phone_type_mean = cv1.cdf_meaning,
      reply->person_list[i].phone_list[ccnt].sequence = pc.phone_type_seq, reply->person_list[i].
      phone_list[ccnt].phone_num = pc.phone_num, reply->person_list[i].phone_list[ccnt].description
       = pc.description,
      reply->person_list[i].phone_list[ccnt].contact = pc.contact, reply->person_list[i].phone_list[
      ccnt].call_instruction = pc.call_instruction, reply->person_list[i].phone_list[ccnt].extension
       = pc.extension,
      reply->person_list[i].phone_list[ccnt].paging_code = pc.paging_code, reply->person_list[i].
      phone_list[ccnt].phone_formatted = cnvtphone(pc.phone_num,pc.phone_format_cd), reply->
      person_list[i].phone_list[ccnt].operation_hours = pc.operation_hours,
      reply->person_list[i].phone_list[ccnt].contact_method_code_value = pc.contact_method_cd
     HEAD cv2.code_value
      reply->person_list[i].phone_list[ccnt].phone_format_code_value = pc.phone_format_cd, reply->
      person_list[i].phone_list[ccnt].phone_format_disp = cv2.display, reply->person_list[i].
      phone_list[ccnt].phone_format_mean = cv2.cdf_meaning
     FOOT REPORT
      stat = alterlist(reply->person_list[i].phone_list,ccnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("Return prsnl phones error")
   ENDIF
   IF (request->load.get_org_ind)
    IF ((request->load.get_fac_ind=1))
     SELECT INTO "nl:"
      FROM prsnl_org_reltn por,
       organization org,
       code_value cv,
       org_type_reltn otr
      PLAN (por
       WHERE (por.person_id=request->person_list[i].person_id)
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
      HEAD REPORT
       orgcnt = 0, listcnt = 0, stat = alterlist(reply->person_list[i].org_list,10)
      DETAIL
       orgcnt = (orgcnt+ 1), listcnt = (listcnt+ 1)
       IF (listcnt > 10)
        listcnt = 1, stat = alterlist(reply->person_list[i].org_list,(orgcnt+ 10))
       ENDIF
       reply->person_list[i].org_list[orgcnt].prsnl_org_reltn_id = por.prsnl_org_reltn_id, reply->
       person_list[i].org_list[orgcnt].organization_id = por.organization_id, reply->person_list[i].
       org_list[orgcnt].organization_name = org.org_name,
       reply->person_list[i].org_list[orgcnt].active_ind = por.active_ind, reply->person_list[i].
       org_list[orgcnt].beg_effective_dt_tm = por.beg_effective_dt_tm, reply->person_list[i].
       org_list[orgcnt].end_effective_dt_tm = por.end_effective_dt_tm
       IF (por.confid_level_cd > 0)
        reply->person_list[i].org_list[orgcnt].confid_level_code_value = por.confid_level_cd, reply->
        person_list[i].org_list[orgcnt].confid_level_disp = cv.display, reply->person_list[i].
        org_list[orgcnt].confid_level_mean = cv.cdf_meaning
       ELSE
        reply->person_list[i].org_list[orgcnt].confid_level_code_value = 0, reply->person_list[i].
        org_list[orgcnt].confid_level_disp = " "
       ENDIF
      FOOT REPORT
       stat = alterlist(reply->person_list[i].org_list,orgcnt)
      WITH nocounter
     ;end select
     CALL bederrorcheck("Return prsnl related organizations error")
    ELSE
     SELECT INTO "nl:"
      FROM prsnl_org_reltn por,
       organization org,
       code_value cv
      PLAN (por
       WHERE (por.person_id=request->person_list[i].person_id)
        AND ((por.active_ind=1
        AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND ((por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (por.end_effective_dt_tm=
       null)) ) OR (iic=1)) )
       JOIN (org
       WHERE por.organization_id=org.organization_id
        AND parser(org_parse))
       JOIN (cv
       WHERE por.confid_level_cd=cv.code_value)
      ORDER BY por.prsnl_org_reltn_id, cv.code_value
      HEAD REPORT
       orgcnt = 0, listcnt = 0, stat = alterlist(reply->person_list[i].org_list,10)
      HEAD por.prsnl_org_reltn_id
       orgcnt = (orgcnt+ 1), listcnt = (listcnt+ 1)
       IF (listcnt > 10)
        listcnt = 1, stat = alterlist(reply->person_list[i].org_list,(orgcnt+ 10))
       ENDIF
       reply->person_list[i].org_list[orgcnt].prsnl_org_reltn_id = por.prsnl_org_reltn_id, reply->
       person_list[i].org_list[orgcnt].organization_id = por.organization_id, reply->person_list[i].
       org_list[orgcnt].organization_name = org.org_name,
       reply->person_list[i].org_list[orgcnt].active_ind = por.active_ind, reply->person_list[i].
       org_list[orgcnt].beg_effective_dt_tm = por.beg_effective_dt_tm, reply->person_list[i].
       org_list[orgcnt].end_effective_dt_tm = por.end_effective_dt_tm
      HEAD cv.code_value
       IF (por.confid_level_cd > 0)
        reply->person_list[i].org_list[orgcnt].confid_level_code_value = por.confid_level_cd, reply->
        person_list[i].org_list[orgcnt].confid_level_disp = cv.display, reply->person_list[i].
        org_list[orgcnt].confid_level_mean = cv.cdf_meaning
       ELSE
        reply->person_list[i].org_list[orgcnt].confid_level_code_value = 0, reply->person_list[i].
        org_list[orgcnt].confid_level_disp = " "
       ENDIF
      FOOT REPORT
       stat = alterlist(reply->person_list[i].org_list,orgcnt)
      WITH nocounter
     ;end select
     CALL bederrorcheck("Return prsnl related organizations error")
    ENDIF
   ENDIF
   IF (request->load.get_org_group_ind)
    SELECT INTO "nl:"
     FROM org_set_prsnl_r ospr,
      org_set os,
      code_value cv
     PLAN (ospr
      WHERE (ospr.prsnl_id=request->person_list[i].person_id)
       AND ((ospr.active_ind=1) OR (iic=1)) )
      JOIN (os
      WHERE ospr.org_set_id=os.org_set_id)
      JOIN (cv
      WHERE ospr.org_set_type_cd=cv.code_value)
     ORDER BY ospr.org_set_prsnl_r_id, cv.code_value
     HEAD REPORT
      oscnt = 0, listcnt = 0, stat = alterlist(reply->person_list[i].org_group_list,10)
     HEAD ospr.org_set_prsnl_r_id
      oscnt = (oscnt+ 1), listcnt = (listcnt+ 1)
      IF (listcnt > 10)
       listcnt = 1, stat = alterlist(reply->person_list[i].org_group_list,(oscnt+ 10))
      ENDIF
      reply->person_list[i].org_group_list[oscnt].org_set_prsnl_r_id = ospr.org_set_prsnl_r_id, reply
      ->person_list[i].org_group_list[oscnt].active_ind = ospr.active_ind
     HEAD cv.code_value
      reply->person_list[i].org_group_list[oscnt].org_set_type_code_value = ospr.org_set_type_cd,
      reply->person_list[i].org_group_list[oscnt].org_set_type_disp = cv.display, reply->person_list[
      i].org_group_list[oscnt].org_set_type_mean = cv.cdf_meaning,
      reply->person_list[i].org_group_list[oscnt].org_set_id = ospr.org_set_id, reply->person_list[i]
      .org_group_list[oscnt].org_set_name = os.name
     FOOT REPORT
      stat = alterlist(reply->person_list[i].org_group_list,oscnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("Return prsnl related organization groups error")
   ENDIF
   IF (request->load.get_loc_ind)
    SELECT INTO "nl:"
     FROM prsnl_location_r plr,
      code_value cv1,
      code_value cv2
     PLAN (plr
      WHERE (plr.person_id=request->person_list[i].person_id))
      JOIN (cv1
      WHERE plr.location_cd=cv1.code_value)
      JOIN (cv2
      WHERE plr.location_type_cd=cv2.code_value)
     ORDER BY plr.person_id, plr.location_cd, cv1.code_value,
      cv2.code_value
     HEAD REPORT
      loccnt = 0, listcnt = 0, tempvar = 0,
      stat = alterlist(reply->person_list[i].location_list,10)
     HEAD plr.person_id
      tempvar = (tempvar+ 1)
     HEAD plr.location_cd
      loccnt = (loccnt+ 1), listcnt = (listcnt+ 1)
      IF (listcnt > 10)
       listcnt = 1, stat = alterlist(reply->person_list[i].location_list,(loccnt+ 10))
      ENDIF
     HEAD cv1.code_value
      reply->person_list[i].location_list[loccnt].location_code_value = plr.location_cd, reply->
      person_list[i].location_list[loccnt].location_disp = cv1.display, reply->person_list[i].
      location_list[loccnt].location_mean = cv1.cdf_meaning
     HEAD cv2.code_value
      reply->person_list[i].location_list[loccnt].location_type_code_value = plr.location_type_cd,
      reply->person_list[i].location_list[loccnt].location_type_disp = cv2.display, reply->
      person_list[i].location_list[loccnt].location_type_mean = cv2.cdf_meaning
     FOOT REPORT
      stat = alterlist(reply->person_list[i].location_list,loccnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("Return prsnl related locations error")
   ENDIF
   IF (request->load.get_user_group_ind)
    SELECT INTO "nl:"
     FROM prsnl_group_reltn pgr,
      prsnl_group pg,
      code_value cv
     PLAN (pgr
      WHERE (pgr.person_id=request->person_list[i].person_id)
       AND ((pgr.active_ind=1) OR (iic=1)) )
      JOIN (pg
      WHERE pgr.prsnl_group_id=pg.prsnl_group_id)
      JOIN (cv
      WHERE pgr.prsnl_group_r_cd=cv.code_value)
     ORDER BY pgr.prsnl_group_reltn_id, cv.code_value
     HEAD REPORT
      pgcnt = 0, listcnt = 0, stat = alterlist(reply->person_list[i].user_group_list,10)
     HEAD pgr.prsnl_group_reltn_id
      pgcnt = (pgcnt+ 1), listcnt = (listcnt+ 1)
      IF (listcnt > 10)
       listcnt = 1, stat = alterlist(reply->person_list[i].user_group_list,(pgcnt+ 10))
      ENDIF
      reply->person_list[i].user_group_list[pgcnt].prsnl_group_reltn_id = pgr.prsnl_group_reltn_id,
      reply->person_list[i].user_group_list[pgcnt].prsnl_group_id = pgr.prsnl_group_id, reply->
      person_list[i].user_group_list[pgcnt].prsnl_group_id = pgr.prsnl_group_id,
      reply->person_list[i].user_group_list[pgcnt].active_ind = pgr.active_ind
     HEAD cv.code_value
      reply->person_list[i].user_group_list[pgcnt].prsnl_group_r_code_value = pgr.prsnl_group_r_cd,
      reply->person_list[i].user_group_list[pgcnt].prsnl_group_r_disp = cv.display, reply->
      person_list[i].user_group_list[pgcnt].prsnl_group_r_mean = cv.cdf_meaning,
      reply->person_list[i].user_group_list[pgcnt].prsnl_group_name = pg.prsnl_group_name, reply->
      person_list[i].user_group_list[pgcnt].prsnl_group_type_cd = pg.prsnl_group_type_cd, reply->
      person_list[i].user_group_list[pgcnt].prsnl_group_class_cd = pg.prsnl_group_class_cd,
      reply->person_list[i].user_group_list[pgcnt].primary_ind = pgr.primary_ind
     FOOT REPORT
      stat = alterlist(reply->person_list[i].user_group_list,pgcnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("Return prsnl user groups error")
   ENDIF
   IF (request->load.get_svcres_ind)
    SELECT INTO "nl:"
     FROM prsnl_service_resource_reltn psr,
      code_value cv
     PLAN (psr
      WHERE (psr.prsnl_id=request->person_list[i].person_id))
      JOIN (cv
      WHERE psr.service_resource_cd=cv.code_value)
     ORDER BY psr.prsnl_id, cv.code_value
     HEAD REPORT
      psrcnt = 0, listcnt = 0, tempcnt = 0,
      stat = alterlist(reply->person_list[i].service_resource_list,10)
     HEAD psr.prsnl_id
      tempcnt = (tempcnt+ 1)
     HEAD psr.service_resource_cd
      psrcnt = (psrcnt+ 1), listcnt = (listcnt+ 1)
      IF (listcnt > 10)
       listcnt = 1, stat = alterlist(reply->person_list[i].service_resource_list,(psrcnt+ 10))
      ENDIF
     HEAD cv.code_value
      reply->person_list[i].service_resource_list[psrcnt].service_resource_code_value = psr
      .service_resource_cd, reply->person_list[i].service_resource_list[psrcnt].service_resource_disp
       = cv.display, reply->person_list[i].service_resource_list[psrcnt].service_resource_mean = cv
      .cdf_meaning
     FOOT REPORT
      stat = alterlist(reply->person_list[i].service_resource_list,psrcnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("Return prsnl service resource relations error")
   ENDIF
   IF (request->load.get_prsnl_notify_ind)
    SELECT INTO "nl:"
     FROM prsnl_notify pn,
      code_value cv
     PLAN (pn
      WHERE (pn.person_id=request->person_list[i].person_id)
       AND ((pn.active_ind=1) OR (iic=1)) )
      JOIN (cv
      WHERE pn.task_activity_cd=cv.code_value)
     ORDER BY pn.prsnl_notify_id, cv.code_value
     HEAD REPORT
      pncnt = 0, listcnt = 0, stat = alterlist(reply->person_list[i].notify_list,10)
     HEAD pn.prsnl_notify_id
      pncnt = (pncnt+ 1), listcnt = (listcnt+ 1)
      IF (listcnt > 10)
       listcnt = 1, stat = alterlist(reply->person_list[i].notify_list,(pncnt+ 10))
      ENDIF
      reply->person_list[i].notify_list[pncnt].prsnl_notify_id = pn.prsnl_notify_id, reply->
      person_list[i].notify_list[pncnt].active_ind = pn.active_ind
     HEAD cv.code_value
      reply->person_list[i].notify_list[pncnt].task_activity_code_value = pn.task_activity_cd, reply
      ->person_list[i].notify_list[pncnt].task_activity_disp = cv.display, reply->person_list[i].
      notify_list[pncnt].task_activity_mean = cv.cdf_meaning,
      reply->person_list[i].notify_list[pncnt].notify_flag = pn.notify_flag, reply->person_list[i].
      notify_list[pncnt].active_ind = pn.active_ind
     FOOT REPORT
      stat = alterlist(reply->person_list[i].notify_list,pncnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("Return prsnl notify data error")
   ENDIF
   IF (validate(request->load.get_comment_ind,0))
    DECLARE prsnl_comment_count = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=4300005
       AND cv.active_ind=1
       AND cv.begin_effective_dt_tm <= cnvtdatetime(curr_dt_tm)
       AND cv.end_effective_dt_tm > cnvtdatetime(curr_dt_tm))
     HEAD cv.code_value
      prsnl_comment_count = (prsnl_comment_count+ 1), stat = alterlist(reply->person_list[i].
       comment_list,prsnl_comment_count), reply->person_list[i].comment_list[prsnl_comment_count].
      type_code_value = cv.code_value,
      reply->person_list[i].comment_list[prsnl_comment_count].type_disp = cv.display, reply->
      person_list[i].comment_list[prsnl_comment_count].type_mean = cv.cdf_meaning
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM prsnl_comment pc,
      long_text_reference ltr,
      prsnl p,
      (dummyt d  WITH seq = prsnl_comment_count)
     PLAN (d)
      JOIN (pc
      WHERE (reply->person_list[i].comment_list[d.seq].type_code_value=pc.comment_type_cd)
       AND (pc.prsnl_id=reply->person_list[i].person_id))
      JOIN (ltr
      WHERE ltr.long_text_id=pc.comment_long_text_id)
      JOIN (p
      WHERE p.person_id=pc.updt_id)
     HEAD pc.comment_type_cd
      reply->person_list[i].comment_list[d.seq].comment = ltr.long_text, reply->person_list[i].
      comment_list[d.seq].last_updt_prsnl_id = p.person_id, reply->person_list[i].comment_list[d.seq]
      .last_updt_prsnl_name = p.name_full_formatted,
      reply->person_list[i].comment_list[d.seq].last_updt_dt_tm = pc.updt_dt_tm
     WITH nocounter
    ;end select
    CALL bederrorcheck("Return prsnl comment data error")
   ENDIF
   IF (validate(request->load.get_result_delivery_method_ind,0))
    SELECT INTO "nl:"
     FROM prsnl_code_value_r pcvr,
      code_value cv,
      prsnl p
     PLAN (pcvr
      WHERE (pcvr.prsnl_id=request->person_list[i].person_id)
       AND pcvr.code_set=4348005)
      JOIN (cv
      WHERE cv.code_value=pcvr.code_value
       AND cv.active_ind=1
       AND cv.begin_effective_dt_tm <= cnvtdatetime(curr_dt_tm)
       AND cv.end_effective_dt_tm > cnvtdatetime(curr_dt_tm))
      JOIN (p
      WHERE p.person_id=pcvr.updt_id)
     HEAD REPORT
      result_delivery_method_count = 0
     DETAIL
      result_delivery_method_count = (result_delivery_method_count+ 1), stat = alterlist(reply->
       person_list[i].result_delivery_method_list,result_delivery_method_count), reply->person_list[i
      ].result_delivery_method_list[result_delivery_method_count].type_code_value = cv.code_value,
      reply->person_list[i].result_delivery_method_list[result_delivery_method_count].type_disp = cv
      .display, reply->person_list[i].result_delivery_method_list[result_delivery_method_count].
      type_mean = cv.cdf_meaning, reply->person_list[i].result_delivery_method_list[
      result_delivery_method_count].last_updt_prsnl_id = p.person_id,
      reply->person_list[i].result_delivery_method_list[result_delivery_method_count].
      last_updt_prsnl_name = p.name_full_formatted, reply->person_list[i].
      result_delivery_method_list[result_delivery_method_count].last_updt_dt_tm = pcvr.updt_dt_tm
     WITH nocounter
    ;end select
    CALL bederrorcheck("Return prsnl result delivery methods data error")
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE get_org_name(alias_pool,alias_type,orgcnt)
   SET torgcnt = 0
   SET tlstcnt = 0
   SET stat = alterlist(temp_orgs->t_org_list,10)
   SELECT INTO "nl:"
    FROM org_alias_pool_reltn oapr,
     organization org
    PLAN (oapr
     WHERE oapr.alias_pool_cd=alias_pool
      AND oapr.alias_entity_alias_type_cd=alias_type)
     JOIN (org
     WHERE org.organization_id=oapr.organization_id
      AND parser(org_parse))
    DETAIL
     torgcnt = (torgcnt+ 1), tlstcnt = (tlstcnt+ 1)
     IF (tlstcnt > 10)
      tlstcnt = 1, stat = alterlist(temp_orgs->t_org_list,(torgcnt+ 10))
     ENDIF
     temp_orgs->t_org_list[torgcnt].t_organization_id = oapr.organization_id, temp_orgs->t_org_list[
     torgcnt].t_org_name = org.org_name
    WITH nocounter
   ;end select
   SET orgcnt = torgcnt
 END ;Subroutine
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO

CREATE PROGRAM bed_get_personnel_list:dba
 FREE SET reply
 RECORD reply(
   1 prsnl_list[*]
     2 person_id = f8
     2 org_cnt = i2
     2 org_ind = i2
     2 specialty_cnt = i2
     2 name_full_formatted = vc
     2 username = vc
     2 active_ind = i2
     2 auth_ind = i2
     2 slist[*]
       3 specialty_id = f8
       3 specialty_value = vc
       3 specialty_name = vc
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
     2 position_code_value = f8
     2 position_display = vc
     2 position_mean = vc
     2 organizations[*]
       3 id = f8
       3 name = vc
     2 organization_groups[*]
       3 id = f8
       3 name = vc
   1 error_msg = vc
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
 DECLARE error_msg = vc
 SET error_flag = "F"
 SET wcard = "*"
 SET pcnt = 0
 SET ocnt = 0
 SET listcnt = 0
 SET olist = 0
 SET max_cnt = 0
 SET acnt = 0
 SET ccnt = 0
 IF ((request->max_reply > 0))
  SET max_cnt = request->max_reply
 ELSE
  SET max_cnt = 100000
 ENDIF
 DECLARE plistparse = vc
 DECLARE orderparse = vc
 DECLARE porparse = vc
 SET tempstr = fillstring(1000," ")
 SET cnt = 0
 SET auth_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=8
    AND cv.cdf_meaning="AUTH")
  DETAIL
   auth_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (auth_cd=0)
  SET error_flag = "T"
  SET error_msg = "Unable to read AUTH code, code_set 8"
  GO TO exit_script
 ENDIF
 SET type_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=28881
   AND cv.active_ind=1
   AND cv.cdf_meaning="SECURITY"
  DETAIL
   type_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET positioncnt = size(request->position_list,5)
 IF ((request->username > " "))
  SET orderparse = "p.username"
 ELSE
  SET orderparse = "p.name_full_formatted"
 ENDIF
 SET orgcnt = 0
 SET porparse = "por.person_id = p.person_id"
 SET plistparse = "p.person_id > 0 and p.name_full_formatted > ' '"
 IF ((request->name_last > " "))
  SET plistparse = concat(plistparse," and p.name_last_key = '",nullterm(cnvtalphanum(cnvtupper(trim(
       request->name_last)))),"*'")
 ENDIF
 IF ((request->name_first > " "))
  SET plistparse = concat(plistparse," and p.name_first_key = '",nullterm(cnvtalphanum(cnvtupper(trim
      (request->name_first)))),"*'")
 ENDIF
 IF ((request->username > " "))
  SET plistparse = concat(plistparse," and cnvtupper(p.username) = '",trim(cnvtupper(request->
     username)),"*'")
 ENDIF
 IF ((request->physician_only_ind=1))
  SET plistparse = concat(plistparse," and p.physician_ind = 1")
 ENDIF
 IF ((request->inc_inactive_ind=0))
  SET plistparse = concat(plistparse," and p.active_ind = 1")
 ENDIF
 IF ((request->inc_unauth_ind=0))
  SET plistparse = build(plistparse," and p.data_status_cd  = ",auth_cd)
 ENDIF
 IF ((request->username_only_ind=1))
  SET plistparse = concat(plistparse," and p.username != NULL and p.username > '  *' ")
 ENDIF
 IF (positioncnt > 0)
  FOR (i = 1 TO positioncnt)
    IF (i=1)
     SET plistparse = build(plistparse," and ((p.position_cd = ",request->position_list[i].
      position_cd,")")
    ELSE
     SET plistparse = build(plistparse," or (p.position_cd = ",request->position_list[i].position_cd,
      ")")
    ENDIF
  ENDFOR
  SET plistparse = concat(plistparse,")")
 ENDIF
 SET org_filter_cnt = 0
 SET org_grp_filter_cnt = 0
 IF (validate(request->organizations))
  SET org_filter_cnt = size(request->organizations,5)
  SET org_grp_filter_cnt = size(request->organization_groups,5)
  DECLARE orgparse = vc
  DECLARE orggrpparse = vc
  IF (org_filter_cnt > 0)
   SET orgparse = build(orgparse," por.organization_id in (")
   FOR (o = 1 TO org_filter_cnt)
     IF (o=1)
      SET orgparse = build(orgparse,request->organizations[o].id)
     ELSE
      SET orgparse = build(orgparse,", ",request->organizations[o].id)
     ENDIF
   ENDFOR
   SET orgparse = build(orgparse,")")
  ELSEIF (org_grp_filter_cnt > 0)
   SET orggrpparse = build(orggrpparse," os.org_set_id in (")
   FOR (o = 1 TO org_grp_filter_cnt)
     IF (o=1)
      SET orggrpparse = build(orggrpparse,request->organization_groups[o].id)
     ELSE
      SET orggrpparse = build(orggrpparse,", ",request->organization_groups[o].id)
     ENDIF
   ENDFOR
   SET orggrpparse = build(orggrpparse,")")
  ENDIF
 ENDIF
 SET load_orgs_and_grps_ind = 0
 IF (validate(request->load_orgs_and_groups_ind))
  IF ((request->load_orgs_and_groups_ind=1))
   SET load_orgs_and_grps_ind = 1
  ENDIF
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
    SET acm_get_acc_logical_domains_req->concept = 2
    EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
    replace("REPLY",acm_get_acc_logical_domains_rep)
   ENDIF
  ENDIF
 ENDIF
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET plistparse = concat(plistparse," and p.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET plistparse = build(plistparse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
     ELSE
      SET plistparse = build(plistparse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF ((request->person_id > 0.0))
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE (p.person_id=request->person_id))
   HEAD REPORT
    pcnt = 0
   DETAIL
    pcnt = (pcnt+ 1), stat = alterlist(reply->prsnl_list,pcnt), reply->prsnl_list[pcnt].person_id = p
    .person_id,
    reply->prsnl_list[pcnt].name_full_formatted = p.name_full_formatted, reply->prsnl_list[pcnt].
    username = p.username, reply->prsnl_list[pcnt].position_code_value = p.position_cd,
    reply->prsnl_list[pcnt].active_ind = p.active_ind
    IF ((request->load.get_org_ind=1))
     reply->prsnl_list[pcnt].org_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF ((request->submit_by > " "))
  SELECT INTO "nl:"
   FROM prsnl p,
    br_prsnl_submit b
   PLAN (p
    WHERE parser(plistparse))
    JOIN (b
    WHERE b.submit_by=trim(request->submit_by)
     AND p.person_id=b.prsnl_id)
   ORDER BY parser(orderparse)
   HEAD REPORT
    pcnt = 0, listcnt = 0, stat = alterlist(reply->prsnl_list,10)
   HEAD p.person_id
    pcnt = (pcnt+ 1), listcnt = (listcnt+ 1)
    IF (listcnt > 10)
     listcnt = 1, stat = alterlist(reply->prsnl_list,(pcnt+ 10))
    ENDIF
    ocnt = 0
   DETAIL
    reply->prsnl_list[pcnt].person_id = p.person_id, reply->prsnl_list[pcnt].name_full_formatted = p
    .name_full_formatted, reply->prsnl_list[pcnt].username = p.username,
    reply->prsnl_list[pcnt].position_code_value = p.position_cd, reply->prsnl_list[pcnt].active_ind
     = p.active_ind
    IF ((request->load.get_org_ind=1))
     reply->prsnl_list[pcnt].org_ind = 1
    ENDIF
   WITH maxqual(p,value((max_cnt+ 2))), nocounter
  ;end select
 ELSE
  IF (org_filter_cnt > 0)
   SELECT INTO "nl:"
    FROM prsnl p,
     prsnl_org_reltn por
    PLAN (p
     WHERE parser(plistparse))
     JOIN (por
     WHERE parser(orgparse)
      AND por.person_id=p.person_id
      AND por.active_ind=1
      AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ((por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (por.end_effective_dt_tm=
     null)) )
    ORDER BY parser(orderparse), p.person_id
    HEAD REPORT
     pcnt = 0, listcnt = 0, stat = alterlist(reply->prsnl_list,10)
    HEAD p.person_id
     pcnt = (pcnt+ 1), listcnt = (listcnt+ 1)
     IF (listcnt > 10)
      listcnt = 1, stat = alterlist(reply->prsnl_list,(pcnt+ 10))
     ENDIF
     reply->prsnl_list[pcnt].person_id = p.person_id, reply->prsnl_list[pcnt].name_full_formatted = p
     .name_full_formatted, reply->prsnl_list[pcnt].username = p.username,
     reply->prsnl_list[pcnt].position_code_value = p.position_cd, reply->prsnl_list[pcnt].active_ind
      = p.active_ind
     IF ((request->load.get_org_ind=1))
      reply->prsnl_list[pcnt].org_ind = 1
     ENDIF
    WITH maxqual(p,value((max_cnt+ 2))), nocounter
   ;end select
  ELSEIF (org_grp_filter_cnt > 0)
   SELECT INTO "nl:"
    FROM prsnl p,
     org_set_prsnl_r os
    PLAN (p
     WHERE parser(plistparse))
     JOIN (os
     WHERE parser(orggrpparse)
      AND os.prsnl_id=p.person_id
      AND os.active_ind=1
      AND os.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ((os.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (os.end_effective_dt_tm=null
     )) )
    ORDER BY parser(orderparse), p.person_id
    HEAD REPORT
     pcnt = 0, listcnt = 0, stat = alterlist(reply->prsnl_list,10)
    HEAD p.person_id
     pcnt = (pcnt+ 1), listcnt = (listcnt+ 1)
     IF (listcnt > 10)
      listcnt = 1, stat = alterlist(reply->prsnl_list,(pcnt+ 10))
     ENDIF
     reply->prsnl_list[pcnt].person_id = p.person_id, reply->prsnl_list[pcnt].name_full_formatted = p
     .name_full_formatted, reply->prsnl_list[pcnt].username = p.username,
     reply->prsnl_list[pcnt].position_code_value = p.position_cd, reply->prsnl_list[pcnt].active_ind
      = p.active_ind
     IF ((request->load.get_org_ind=1))
      reply->prsnl_list[pcnt].org_ind = 1
     ENDIF
    WITH maxqual(p,value((max_cnt+ 2))), nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM prsnl p
    PLAN (p
     WHERE parser(plistparse))
    ORDER BY parser(orderparse)
    HEAD REPORT
     pcnt = 0, listcnt = 0, stat = alterlist(reply->prsnl_list,10)
    DETAIL
     pcnt = (pcnt+ 1), listcnt = (listcnt+ 1)
     IF (listcnt > 10)
      listcnt = 1, stat = alterlist(reply->prsnl_list,(pcnt+ 10))
     ENDIF
     reply->prsnl_list[pcnt].person_id = p.person_id, reply->prsnl_list[pcnt].name_full_formatted = p
     .name_full_formatted, reply->prsnl_list[pcnt].username = p.username,
     reply->prsnl_list[pcnt].position_code_value = p.position_cd, reply->prsnl_list[pcnt].active_ind
      = p.active_ind
     IF ((request->load.get_org_ind=1))
      reply->prsnl_list[pcnt].org_ind = 1
     ENDIF
    WITH maxqual(p,value((max_cnt+ 2))), nocounter
   ;end select
  ENDIF
 ENDIF
 SET stat = alterlist(reply->prsnl_list,pcnt)
 IF (pcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = pcnt),
    code_value c
   PLAN (d)
    JOIN (c
    WHERE (c.code_value=reply->prsnl_list[d.seq].position_code_value))
   DETAIL
    IF (c.code_value > 0)
     reply->prsnl_list[d.seq].position_display = c.display, reply->prsnl_list[d.seq].position_mean =
     c.cdf_meaning
    ENDIF
   WITH nocounter
  ;end select
  IF ((request->load.get_org_ind=1))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = pcnt),
     prsnl_org_reltn por
    PLAN (d)
     JOIN (por
     WHERE (por.person_id=reply->prsnl_list[d.seq].person_id)
      AND por.active_ind=1
      AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ((por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (por.end_effective_dt_tm=
     null)) )
    ORDER BY d.seq
    DETAIL
     reply->prsnl_list[d.seq].org_ind = 0
    WITH nocounter, outerjoin = d, dontexist
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = pcnt),
     org_set_prsnl_r os
    PLAN (d
     WHERE (reply->prsnl_list[d.seq].org_ind=0))
     JOIN (os
     WHERE os.active_ind=1
      AND (os.prsnl_id=reply->prsnl_list[d.seq].person_id)
      AND os.org_set_type_cd=type_code_value)
    ORDER BY d.seq
    DETAIL
     reply->prsnl_list[d.seq].org_ind = 1
    WITH nocounter
   ;end select
  ELSEIF ((((request->load.get_org_cnt_ind=1)) OR (load_orgs_and_grps_ind=1)) )
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = pcnt),
     prsnl_org_reltn por,
     organization o
    PLAN (d)
     JOIN (por
     WHERE (por.person_id=reply->prsnl_list[d.seq].person_id)
      AND por.active_ind=1
      AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ((por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (por.end_effective_dt_tm=
     null)) )
     JOIN (o
     WHERE o.organization_id=por.organization_id
      AND o.active_ind=1)
    ORDER BY d.seq
    HEAD d.seq
     ocnt = 0
    DETAIL
     ocnt = (ocnt+ 1)
     IF (load_orgs_and_grps_ind=1)
      stat = alterlist(reply->prsnl_list[d.seq].organizations,ocnt), reply->prsnl_list[d.seq].
      organizations[ocnt].id = por.organization_id, reply->prsnl_list[d.seq].organizations[ocnt].name
       = o.org_name
     ENDIF
    FOOT  d.seq
     reply->prsnl_list[d.seq].org_cnt = ocnt
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = pcnt),
     org_set_prsnl_r os,
     org_set o
    PLAN (d)
     JOIN (os
     WHERE os.active_ind=1
      AND (os.prsnl_id=reply->prsnl_list[d.seq].person_id)
      AND os.org_set_type_cd=type_code_value)
     JOIN (o
     WHERE o.org_set_id=os.org_set_id
      AND o.active_ind=1)
    ORDER BY d.seq
    HEAD d.seq
     ocnt = reply->prsnl_list[d.seq].org_cnt, gcnt = 0
    DETAIL
     ocnt = (ocnt+ 1)
     IF (load_orgs_and_grps_ind=1)
      gcnt = (gcnt+ 1), stat = alterlist(reply->prsnl_list[d.seq].organization_groups,gcnt), reply->
      prsnl_list[d.seq].organization_groups[gcnt].id = os.org_set_id,
      reply->prsnl_list[d.seq].organization_groups[gcnt].name = o.name
     ENDIF
    FOOT  d.seq
     reply->prsnl_list[d.seq].org_cnt = ocnt
    WITH nocounter
   ;end select
  ENDIF
  IF ((((request->load.get_bus_address_ind=1)) OR ((request->load.get_bus_phone_ind=1))) )
   SET acnt = 0
   IF ((request->load.get_bus_address_ind=1))
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = pcnt),
      address a,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      code_value cv4
     PLAN (d1)
      JOIN (a
      WHERE ((a.parent_entity_name="PRSNL") OR (a.parent_entity_name="PERSON"))
       AND (a.parent_entity_id=reply->prsnl_list[d1.seq].person_id)
       AND a.active_ind=1)
      JOIN (cv1
      WHERE a.address_type_cd=cv1.code_value
       AND cv1.cdf_meaning="BUSINESS")
      JOIN (cv2
      WHERE a.state_cd=cv2.code_value)
      JOIN (cv3
      WHERE a.country_cd=cv3.code_value)
      JOIN (cv4
      WHERE a.county_cd=cv4.code_value)
     ORDER BY a.address_id, cv1.code_value, cv2.code_value,
      cv3.code_value, cv4.code_value
     HEAD d1.seq
      acnt = 0, listcnt = 0, stat = alterlist(reply->prsnl_list[d1.seq].address_list,10)
     HEAD a.address_id
      acnt = (acnt+ 1), listcnt = (listcnt+ 1)
      IF (listcnt > 10)
       listcnt = 1, stat = alterlist(reply->prsnl_list[d1.seq].address_list,(acnt+ 10))
      ENDIF
      reply->prsnl_list[d1.seq].address_list[acnt].address_id = a.address_id, reply->prsnl_list[d1
      .seq].address_list[acnt].active_ind = a.active_ind
     HEAD cv1.code_value
      reply->prsnl_list[d1.seq].address_list[acnt].address_type_code_value = a.address_type_cd, reply
      ->prsnl_list[d1.seq].address_list[acnt].address_type_disp = cv1.display, reply->prsnl_list[d1
      .seq].address_list[acnt].address_type_mean = cv1.cdf_meaning,
      reply->prsnl_list[d1.seq].address_list[acnt].street_addr = a.street_addr, reply->prsnl_list[d1
      .seq].address_list[acnt].street_addr2 = a.street_addr2, reply->prsnl_list[d1.seq].address_list[
      acnt].street_addr3 = a.street_addr3,
      reply->prsnl_list[d1.seq].address_list[acnt].street_addr4 = a.street_addr4, reply->prsnl_list[
      d1.seq].address_list[acnt].city = a.city, reply->prsnl_list[d1.seq].address_list[acnt].state =
      a.state,
      reply->prsnl_list[d1.seq].address_list[acnt].address_type_seq = a.address_type_seq
     HEAD cv2.code_value
      reply->prsnl_list[d1.seq].address_list[acnt].state_code_value = a.state_cd, reply->prsnl_list[
      d1.seq].address_list[acnt].state_disp = cv2.display, reply->prsnl_list[d1.seq].address_list[
      acnt].zipcode = a.zipcode
     HEAD cv3.code_value
      reply->prsnl_list[d1.seq].address_list[acnt].country_code_value = a.country_cd, reply->
      prsnl_list[d1.seq].address_list[acnt].country_disp = cv3.display
     HEAD cv4.code_value
      reply->prsnl_list[d1.seq].address_list[acnt].county_code_value = a.county_cd, reply->
      prsnl_list[d1.seq].address_list[acnt].county_disp = cv4.display, reply->prsnl_list[d1.seq].
      address_list[acnt].residence_type_code_value = a.residence_type_cd,
      reply->prsnl_list[d1.seq].address_list[acnt].contact_name = a.contact_name, reply->prsnl_list[
      d1.seq].address_list[acnt].comment_txt = a.comment_txt
     FOOT  d1.seq
      stat = alterlist(reply->prsnl_list[d1.seq].address_list,acnt)
     WITH nocounter
    ;end select
    IF (acnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH value = pcnt),
       (dummyt d2  WITH value = acnt),
       code_value cv5
      PLAN (d1)
       JOIN (d2)
       JOIN (cv5
       WHERE (cv5.code_value=reply->prsnl_list[d1.seq].address_list[d2.seq].residence_type_code_value
       ))
      ORDER BY cv5.code_value
      HEAD cv5.code_value
       reply->prsnl_list[d1.seq].address_list[d2.seq].residence_type_disp = cv5.display, reply->
       prsnl_list[d1.seq].address_list[d2.seq].residence_type_mean = cv5.cdf_meaning
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->load.get_bus_phone_ind=1))
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = pcnt),
      phone pc,
      code_value cv1,
      code_value cv2
     PLAN (d1)
      JOIN (pc
      WHERE ((pc.parent_entity_name="PRSNL") OR (pc.parent_entity_name="PERSON"))
       AND (pc.parent_entity_id=reply->prsnl_list[d1.seq].person_id)
       AND pc.active_ind=1)
      JOIN (cv1
      WHERE pc.phone_type_cd=cv1.code_value
       AND cv1.cdf_meaning="BUSINESS")
      JOIN (cv2
      WHERE pc.phone_format_cd=cv2.code_value)
     ORDER BY pc.phone_id, cv1.code_value, cv2.code_value
     HEAD d1.seq
      ccnt = 0, listcnt = 0, stat = alterlist(reply->prsnl_list[d1.seq].phone_list,10)
     HEAD pc.phone_id
      ccnt = (ccnt+ 1), listcnt = (listcnt+ 1)
      IF (listcnt > 10)
       listcnt = 1, stat = alterlist(reply->prsnl_list[d1.seq].phone_list,(ccnt+ 10))
      ENDIF
      reply->prsnl_list[d1.seq].phone_list[ccnt].phone_id = pc.phone_id, reply->prsnl_list[d1.seq].
      phone_list[ccnt].active_ind = pc.active_ind
     HEAD cv1.code_value
      reply->prsnl_list[d1.seq].phone_list[ccnt].phone_type_code_value = pc.phone_type_cd, reply->
      prsnl_list[d1.seq].phone_list[ccnt].phone_type_disp = cv1.display, reply->prsnl_list[d1.seq].
      phone_list[ccnt].phone_type_mean = cv1.cdf_meaning,
      reply->prsnl_list[d1.seq].phone_list[ccnt].sequence = pc.phone_type_seq, reply->prsnl_list[d1
      .seq].phone_list[ccnt].phone_num = pc.phone_num, reply->prsnl_list[d1.seq].phone_list[ccnt].
      description = pc.description,
      reply->prsnl_list[d1.seq].phone_list[ccnt].contact = pc.contact, reply->prsnl_list[d1.seq].
      phone_list[ccnt].call_instruction = pc.call_instruction, reply->prsnl_list[d1.seq].phone_list[
      ccnt].extension = pc.extension,
      reply->prsnl_list[d1.seq].phone_list[ccnt].paging_code = pc.paging_code, reply->prsnl_list[d1
      .seq].phone_list[ccnt].phone_formatted = cnvtphone(pc.phone_num,pc.phone_format_cd), reply->
      prsnl_list[d1.seq].phone_list[ccnt].operation_hours = pc.operation_hours
     HEAD cv2.code_value
      reply->prsnl_list[d1.seq].phone_list[ccnt].phone_format_code_value = pc.phone_format_cd, reply
      ->prsnl_list[d1.seq].phone_list[ccnt].phone_format_disp = cv2.display, reply->prsnl_list[d1.seq
      ].phone_list[ccnt].phone_format_mean = cv2.cdf_meaning
     FOOT  d1.seq
      stat = alterlist(reply->prsnl_list[d1.seq].phone_list,ccnt)
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  IF ((((request->load.get_specialties_ind=1)) OR ((request->load.get_specialty_cnt_ind=1))) )
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = pcnt),
     br_prsnl_specialty b,
     br_name_value bnv
    PLAN (d)
     JOIN (b
     WHERE (b.prsnl_id=reply->prsnl_list[d.seq].person_id))
     JOIN (bnv
     WHERE bnv.br_name_value_id=b.specialty_id)
    HEAD d.seq
     count = 0, tot_count = 0
     IF ((request->load.get_specialties_ind=1))
      stat = alterlist(reply->prsnl_list[d.seq].slist,10)
     ENDIF
    DETAIL
     tot_count = (tot_count+ 1)
     IF ((request->load.get_specialties_ind=1))
      count = (count+ 1)
      IF (count > 10)
       stat = alterlist(reply->prsnl_list[d.seq].slist,(tot_count+ 10)), count = 1
      ENDIF
     ENDIF
     IF ((request->load.get_specialties_ind=1))
      reply->prsnl_list[d.seq].slist[tot_count].specialty_id = b.specialty_id, reply->prsnl_list[d
      .seq].slist[tot_count].specialty_value = bnv.br_value, reply->prsnl_list[d.seq].slist[tot_count
      ].specialty_name = bnv.br_name
     ENDIF
    FOOT  d.seq
     IF ((request->load.get_specialties_ind=1))
      stat = alterlist(reply->prsnl_list[d.seq].slist,tot_count)
     ENDIF
     IF ((request->load.get_specialty_cnt_ind=1))
      reply->prsnl_list[d.seq].specialty_cnt = tot_count
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (pcnt > max_cnt)
  SET stat = alterlist(reply->prsnl_list,max_cnt)
 ENDIF
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: bed_get_personnel_list   ERROR MESSAGE: ",
   error_msg)
 ELSE
  IF (pcnt > 0)
   IF (pcnt > max_cnt)
    SET stat = alterlist(reply->prsnl_list,0)
    SET reply->too_many_results_ind = 1
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 CALL echorecord(reply)
END GO

CREATE PROGRAM bed_get_organization_list:dba
 FREE SET reply
 RECORD reply(
   01 org[*]
     02 organization_id = f8
     02 org_name = vc
     02 active_ind = i2
     02 person_ind = i2
     02 person_count = i2
     02 person_list[*]
       03 person_id = f8
       03 name_full_formatted = vc
       03 confid_level_code_value = f8
       03 confid_level_disp = vc
       03 confid_level_mean = vc
     02 address_ind = i2
     02 phone_ind = i2
     02 begin_effective_dt_tm = dq8
     02 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
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
 DECLARE iic = i2
 SET iic = request->show_inactive_ind
 SET reply->too_many_results_ind = 0
 SET pcnt = 0
 SET plistcnt = 0
 DECLARE plistparse = vc
 DECLARE oplistparse = vc
 SET reply->status_data.status = "F"
 SET wcard = "*"
 SET max_cnt = 0
 IF ((request->max_reply_limit > 0))
  SET max_cnt = request->max_reply_limit
 ELSE
  SET max_cnt = 1000000
 ENDIF
 SET auth_cd = 0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=8
    AND c.cdf_meaning="AUTH")
  DETAIL
   auth_cd = c.code_value
  WITH nocounter
 ;end select
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
 SET org_class_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=396
    AND c.cdf_meaning="ORG"
    AND c.active_ind=1)
  DETAIL
   org_class_cd = c.code_value
  WITH nocounter
 ;end select
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
 IF (org_class_cd > 0)
  SET org_name_parse = build(org_name_parse," and o.org_class_cd = ",org_class_cd)
 ENDIF
 DECLARE org_type_parse = vc
 SET otcnt = 0
 SET otcnt = size(request->org_type,5)
 IF (otcnt > 0
  AND (request->org_type[1].org_type_code_value > 0))
  SET org_type_parse = "otr.organization_id = o.organization_id and otr.org_type_cd in ("
  FOR (x = 1 TO otcnt)
    IF (x=1)
     SET org_type_parse = build(org_type_parse,request->org_type[x].org_type_code_value)
    ELSE
     SET org_type_parse = build(org_type_parse,",",request->org_type[x].org_type_code_value)
    ENDIF
  ENDFOR
  SET org_type_parse = concat(org_type_parse,")")
  IF ((request->show_inactive_ind=0))
   SET org_type_parse = concat(org_type_parse," and otr.active_ind = 1")
  ENDIF
 ENDIF
 IF (validate(request->show_ineffective_ind))
  IF ((request->show_ineffective_ind=0))
   SET org_name_parse = concat(org_name_parse,
    " and (o.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3) and ",
    "(o.end_effective_dt_tm > cnvtdatetime(curdate, curtime3) or ","o.end_effective_dt_tm = NULL))")
  ENDIF
 ELSE
  SET org_name_parse = concat(org_name_parse,
   " and (o.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3) and ",
   "(o.end_effective_dt_tm > cnvtdatetime(curdate, curtime3) or ","o.end_effective_dt_tm = NULL))")
 ENDIF
 CALL echo(build("org_name_parse:",org_name_parse))
 CALL echo(build("org_type_parse:",org_type_parse))
 CALL echo(build("org type count:",otcnt))
 SET ocnt = 0
 IF ((request->org_id > 0.0))
  SELECT INTO "nl:"
   FROM organization o
   PLAN (o
    WHERE (o.organization_id=request->org_id)
     AND ((o.active_ind=1) OR (iic=1)) )
   HEAD REPORT
    ocnt = 0
   DETAIL
    ocnt = (ocnt+ 1), stat = alterlist(reply->org,ocnt), reply->org[ocnt].organization_id = o
    .organization_id,
    reply->org[ocnt].org_name = o.org_name, reply->org[ocnt].active_ind = o.active_ind, reply->org[
    ocnt].person_count = 0
    IF ((request->load.person_ind=1))
     reply->org[ocnt].person_ind = 1
    ENDIF
    reply->org[ocnt].address_ind = 0, reply->org[ocnt].phone_ind = 0
   WITH nocounter
  ;end select
 ELSE
  IF (org_data_partition_ind=1)
   IF ((org_logical_domains_rep->logical_domains_cnt > 0))
    SET org_name_parse = concat(org_name_parse," and o.logical_domain_id in (")
    FOR (d = 1 TO org_logical_domains_rep->logical_domains_cnt)
      IF ((d=org_logical_domains_rep->logical_domains_cnt))
       SET org_name_parse = build(org_name_parse,org_logical_domains_rep->logical_domains[d].
        logical_domain_id,")")
      ELSE
       SET org_name_parse = build(org_name_parse,org_logical_domains_rep->logical_domains[d].
        logical_domain_id,",")
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
  IF (otcnt > 0
   AND (request->org_type[1].org_type_code_value > 0))
   SELECT DISTINCT INTO "nl:"
    org_name_key = cnvtupper(cnvtalphanum(o.org_name))
    FROM organization o,
     org_type_reltn otr
    PLAN (o
     WHERE parser(org_name_parse)
      AND o.data_status_cd=auth_cd
      AND o.organization_id > 0)
     JOIN (otr
     WHERE parser(org_type_parse))
    ORDER BY org_name_key
    HEAD REPORT
     ocnt = 0
    DETAIL
     ocnt = (ocnt+ 1), stat = alterlist(reply->org,ocnt), reply->org[ocnt].organization_id = o
     .organization_id,
     reply->org[ocnt].org_name = o.org_name, reply->org[ocnt].active_ind = o.active_ind, reply->org[
     ocnt].person_count = 0
     IF ((request->load.person_ind=1))
      reply->org[ocnt].person_ind = 1
     ENDIF
     reply->org[ocnt].address_ind = 0, reply->org[ocnt].phone_ind = 0, reply->org[ocnt].
     begin_effective_dt_tm = o.beg_effective_dt_tm,
     reply->org[ocnt].end_effective_dt_tm = o.end_effective_dt_tm
    WITH nocounter, maxqual(o,value((max_cnt * 2)))
   ;end select
  ELSE
   SELECT INTO "nl:"
    org_name_key = cnvtupper(cnvtalphanum(o.org_name))
    FROM organization o
    PLAN (o
     WHERE parser(org_name_parse)
      AND o.data_status_cd=auth_cd)
    ORDER BY org_name_key
    HEAD REPORT
     ocnt = 0
    DETAIL
     ocnt = (ocnt+ 1), stat = alterlist(reply->org,ocnt), reply->org[ocnt].organization_id = o
     .organization_id,
     reply->org[ocnt].org_name = o.org_name, reply->org[ocnt].active_ind = o.active_ind, reply->org[
     ocnt].person_count = 0
     IF ((request->load.person_ind=1))
      reply->org[ocnt].person_ind = 1
     ENDIF
     reply->org[ocnt].address_ind = 0, reply->org[ocnt].phone_ind = 0, reply->org[ocnt].
     begin_effective_dt_tm = o.beg_effective_dt_tm,
     reply->org[ocnt].end_effective_dt_tm = o.end_effective_dt_tm
    WITH nocounter, maxqual(o,value((max_cnt * 2)))
   ;end select
  ENDIF
 ENDIF
 IF (ocnt > max_cnt)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 IF ((request->load.person_list=1)
  AND ocnt > 0)
  SET positioncnt = size(request->position_list,5)
  SET plistparse = build("p.person_id = por.person_id and p.name_full_formatted > ' '",
   " and p.active_ind = 1 and p.data_status_cd = ",auth_cd)
  SET oplistparse = build("p.person_id = os.prsnl_id and p.name_full_formatted > ' '",
   " and p.active_ind = 1 and p.data_status_cd = ",auth_cd)
  IF (positioncnt > 0)
   FOR (i = 1 TO positioncnt)
     IF (i=1)
      SET plistparse = build(plistparse," and ((p.position_cd = ",request->position_list[i].
       position_cd,")")
      SET oplistparse = build(oplistparse," and ((p.position_cd = ",request->position_list[i].
       position_cd,")")
     ELSE
      SET plistparse = build(plistparse," or (p.position_cd = ",request->position_list[i].position_cd,
       ")")
      SET oplistparse = build(oplistparse," or (p.position_cd = ",request->position_list[i].
       position_cd,")")
     ENDIF
   ENDFOR
   SET plistparse = concat(plistparse,")")
   SET oplistparse = concat(oplistparse,")")
  ENDIF
  IF (prsnl_data_partition_ind=1)
   IF ((prsnl_logical_domains_rep->logical_domains_cnt > 0))
    SET plistparse = concat(plistparse," and p.logical_domain_id in (")
    SET oplistparse = concat(oplistparse," and p.logical_domain_id in (")
    FOR (d = 1 TO prsnl_logical_domains_rep->logical_domains_cnt)
      IF ((d=prsnl_logical_domains_rep->logical_domains_cnt))
       SET plistparse = build(plistparse,prsnl_logical_domains_rep->logical_domains[d].
        logical_domain_id,")")
       SET oplistparse = build(oplistparse,prsnl_logical_domains_rep->logical_domains[d].
        logical_domain_id,")")
      ELSE
       SET plistparse = build(plistparse,prsnl_logical_domains_rep->logical_domains[d].
        logical_domain_id,",")
       SET oplistparse = build(oplistparse,prsnl_logical_domains_rep->logical_domains[d].
        logical_domain_id,",")
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM prsnl_org_reltn por,
    prsnl p,
    (dummyt d  WITH seq = ocnt),
    code_value cv
   PLAN (d)
    JOIN (por
    WHERE (por.organization_id=reply->org[d.seq].organization_id)
     AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (por.end_effective_dt_tm=null
    ))
     AND por.active_ind=1)
    JOIN (p
    WHERE parser(plistparse))
    JOIN (cv
    WHERE cv.code_value=outerjoin(por.confid_level_cd)
     AND cv.active_ind=outerjoin(1))
   ORDER BY d.seq
   HEAD d.seq
    pcnt = 0
   DETAIL
    pcnt = (pcnt+ 1)
    IF ((request->load.person_list=1))
     stat = alterlist(reply->org[d.seq].person_list,pcnt), reply->org[d.seq].person_list[pcnt].
     person_id = por.person_id, reply->org[d.seq].person_list[pcnt].name_full_formatted = p
     .name_full_formatted,
     reply->org[d.seq].person_list[pcnt].confid_level_code_value = cv.code_value, reply->org[d.seq].
     person_list[pcnt].confid_level_disp = cv.display, reply->org[d.seq].person_list[pcnt].
     confid_level_mean = cv.cdf_meaning
    ENDIF
   FOOT  d.seq
    IF ((request->load.person_count=1))
     reply->org[d.seq].person_count = pcnt
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM org_set_prsnl_r os,
    org_set_org_r osr,
    prsnl p,
    (dummyt d  WITH seq = ocnt)
   PLAN (d)
    JOIN (osr
    WHERE osr.active_ind=1
     AND (osr.organization_id=reply->org[d.seq].organization_id))
    JOIN (os
    WHERE os.active_ind=1
     AND os.org_set_id=osr.org_set_id
     AND os.org_set_type_cd=type_code_value)
    JOIN (p
    WHERE parser(oplistparse))
   ORDER BY d.seq, osr.organization_id
   HEAD d.seq
    plistcnt = 0
   DETAIL
    found = 0, pcnt = size(reply->org[d.seq].person_list,5)
    FOR (i = 1 TO pcnt)
      IF ((reply->org[d.seq].person_list[i].person_id=os.prsnl_id))
       found = 1, i = pcnt
      ENDIF
    ENDFOR
    IF (found=0)
     pcnt = (pcnt+ 1), stat = alterlist(reply->org[d.seq].person_list,pcnt)
     IF ((request->load.person_list=1))
      reply->org[d.seq].person_list[pcnt].person_id = os.prsnl_id, reply->org[d.seq].person_list[pcnt
      ].name_full_formatted = p.name_full_formatted
     ENDIF
    ENDIF
   FOOT  d.seq
    IF ((request->load.person_count=1))
     reply->org[d.seq].person_count = pcnt
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF ((request->load.person_ind=1)
  AND ocnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ocnt),
    prsnl_org_reltn por
   PLAN (d)
    JOIN (por
    WHERE (por.organization_id=reply->org[d.seq].organization_id)
     AND por.active_ind=1
     AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (por.end_effective_dt_tm=null
    )) )
   ORDER BY d.seq
   DETAIL
    reply->org[d.seq].person_ind = 0
   WITH nocounter, outerjoin = d, dontexist
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ocnt),
    org_set_prsnl_r os,
    org_set_org_r osr
   PLAN (d
    WHERE (reply->org[d.seq].person_ind=0))
    JOIN (osr
    WHERE osr.active_ind=1
     AND (osr.organization_id=reply->org[d.seq].organization_id))
    JOIN (os
    WHERE os.active_ind=1
     AND os.org_set_id=osr.org_set_id
     AND os.org_set_type_cd=type_code_value)
   ORDER BY d.seq
   DETAIL
    reply->org[d.seq].person_ind = 1
   WITH nocounter
  ;end select
 ELSEIF ((request->load.person_count=1)
  AND ocnt > 0)
  SET positioncnt = size(request->position_list,5)
  SET plistparse = build("p.person_id = por.person_id and p.name_full_formatted > ' '",
   " and p.active_ind = 1 and p.data_status_cd = ",auth_cd)
  IF (positioncnt > 0)
   FOR (i = 1 TO positioncnt)
     IF (i=1)
      SET plistparse = build(plistparse," and ((p.position_cd = ",request->position_list[i].
       position_cd,")")
      SET oplistparse = build(oplistparse," and ((p.position_cd = ",request->position_list[i].
       position_cd,")")
     ELSE
      SET plistparse = build(plistparse," or (p.position_cd = ",request->position_list[i].position_cd,
       ")")
      SET oplistparse = build(oplistparse," or (p.position_cd = ",request->position_list[i].
       position_cd,")")
     ENDIF
   ENDFOR
   SET plistparse = concat(plistparse,")")
  ENDIF
  IF (prsnl_data_partition_ind=1)
   IF ((prsnl_logical_domains_rep->logical_domains_cnt > 0))
    SET plistparse = concat(plistparse," and p.logical_domain_id in (")
    SET oplistparse = concat(oplistparse," and p.logical_domain_id in (")
    FOR (d = 1 TO prsnl_logical_domains_rep->logical_domains_cnt)
      IF ((d=prsnl_logical_domains_rep->logical_domains_cnt))
       SET plistparse = build(plistparse,prsnl_logical_domains_rep->logical_domains[d].
        logical_domain_id,")")
       SET oplistparse = build(oplistparse,prsnl_logical_domains_rep->logical_domains[d].
        logical_domain_id,")")
      ELSE
       SET plistparse = build(plistparse,prsnl_logical_domains_rep->logical_domains[d].
        logical_domain_id,",")
       SET oplistparse = build(oplistparse,prsnl_logical_domains_rep->logical_domains[d].
        logical_domain_id,",")
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM prsnl_org_reltn por,
    prsnl p,
    (dummyt d  WITH seq = ocnt)
   PLAN (d)
    JOIN (por
    WHERE (por.organization_id=reply->org[d.seq].organization_id)
     AND por.active_ind=1
     AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (por.end_effective_dt_tm=null
    )) )
    JOIN (p
    WHERE parser(plistparse))
   ORDER BY d.seq
   HEAD d.seq
    pcnt = 0
   DETAIL
    pcnt = (pcnt+ 1)
   FOOT  d.seq
    reply->org[d.seq].person_count = pcnt
   WITH nocounter
  ;end select
 ENDIF
 IF (ocnt > 0
  AND (request->load.address_ind=1))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ocnt),
    address a
   PLAN (d)
    JOIN (a
    WHERE (a.parent_entity_id=reply->org[d.seq].organization_id)
     AND a.parent_entity_name="ORGANIZATION"
     AND a.active_ind=1)
   DETAIL
    reply->org[d.seq].address_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF (ocnt > 0
  AND (request->load.phone_ind=1))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ocnt),
    phone p
   PLAN (d)
    JOIN (p
    WHERE (p.parent_entity_id=reply->org[d.seq].organization_id)
     AND p.parent_entity_name="ORGANIZATION"
     AND p.active_ind=1)
   DETAIL
    reply->org[d.seq].phone_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build("ocnt:",ocnt))
 CALL echo(build("max_cnt:",max_cnt))
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
#exit_script
 IF ((reply->too_many_results_ind=1))
  SET stat = alterlist(reply->org,0)
 ENDIF
 CALL echorecord(reply)
END GO

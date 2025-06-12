CREATE PROGRAM bed_get_organization_list_b:dba
 IF ( NOT (validate(reply,0)))
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
        03 prsnl_org_reltn_id = f8
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
 ENDIF
 IF ( NOT (validate(temp,0)))
  RECORD temp(
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
        03 prsnl_org_reltn_id = f8
      02 address_ind = i2
      02 phone_ind = i2
      02 begin_effective_dt_tm = dq8
      02 end_effective_dt_tm = dq8
  )
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
 DECLARE idx = i4
 DECLARE prsnl_data_partition_ind = i4
 DECLARE org_data_partition_ind = i4
 DECLARE field_found = i4
 DECLARE pcnt = i4
 DECLARE plistcnt = i4
 DECLARE wcard = vc
 DECLARE max_cnt = i4
 DECLARE prg_exists_ind = i4
 DECLARE ocnt = i4
 DECLARE auth_cd = f8
 DECLARE type_code_value = f8
 DECLARE org_class_cd = f8
 DECLARE otcnt = i4
 DECLARE sizeorg = i4
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
  SET max_cnt = 5000
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
 DECLARE isprsnlsecurityapplied = i4
 SET isprsnlsecurityapplied = getapplyorgsecurityind(0)
 SET ocnt = 0
 IF ((request->org_id > 0.0))
  SELECT INTO "nl:"
   FROM organization o
   PLAN (o
    WHERE (o.organization_id=request->org_id)
     AND ((o.active_ind=1) OR (iic=1)) )
   HEAD REPORT
    ocnt = 0, stat = alterlist(temp->org,50)
   DETAIL
    ocnt = (ocnt+ 1)
    IF (mod(ocnt,10)=1
     AND ocnt > 50)
     stat = alterlist(temp->org,(ocnt+ 10))
    ENDIF
    temp->org[ocnt].organization_id = o.organization_id, temp->org[ocnt].org_name = o.org_name, temp
    ->org[ocnt].active_ind = o.active_ind,
    temp->org[ocnt].person_count = 0
    IF ((request->load.person_ind=1))
     temp->org[ocnt].person_ind = 1
    ENDIF
    temp->org[ocnt].address_ind = 0, temp->org[ocnt].phone_ind = 0
   FOOT REPORT
    stat = alterlist(temp->org,ocnt)
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
     ocnt = 0, stat = alterlist(temp->org,50)
    DETAIL
     ocnt = (ocnt+ 1)
     IF (mod(ocnt,10)=1
      AND ocnt > 50)
      stat = alterlist(temp->org,(ocnt+ 10))
     ENDIF
     temp->org[ocnt].organization_id = o.organization_id, temp->org[ocnt].org_name = o.org_name, temp
     ->org[ocnt].active_ind = o.active_ind,
     temp->org[ocnt].person_count = 0
     IF ((request->load.person_ind=1))
      temp->org[ocnt].person_ind = 1
     ENDIF
     temp->org[ocnt].address_ind = 0, temp->org[ocnt].phone_ind = 0, temp->org[ocnt].
     begin_effective_dt_tm = o.beg_effective_dt_tm,
     temp->org[ocnt].end_effective_dt_tm = o.end_effective_dt_tm
    FOOT REPORT
     stat = alterlist(temp->org,ocnt)
    WITH nocounter
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
     ocnt = 0, stat = alterlist(temp->org,50)
    DETAIL
     ocnt = (ocnt+ 1)
     IF (mod(ocnt,10)=1
      AND ocnt > 50)
      stat = alterlist(temp->org,(ocnt+ 10))
     ENDIF
     temp->org[ocnt].organization_id = o.organization_id, temp->org[ocnt].org_name = o.org_name, temp
     ->org[ocnt].active_ind = o.active_ind,
     temp->org[ocnt].person_count = 0
     IF ((request->load.person_ind=1))
      temp->org[ocnt].person_ind = 1
     ENDIF
     temp->org[ocnt].address_ind = 0, temp->org[ocnt].phone_ind = 0, temp->org[ocnt].
     begin_effective_dt_tm = o.beg_effective_dt_tm,
     temp->org[ocnt].end_effective_dt_tm = o.end_effective_dt_tm
    FOOT REPORT
     stat = alterlist(temp->org,ocnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (isprsnlsecurityapplied=0
  AND ocnt > max_cnt)
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
    WHERE (por.organization_id=temp->org[d.seq].organization_id)
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
    pcnt = (pcnt+ 1), stat = alterlist(temp->org[d.seq].person_list,pcnt)
    IF ((request->load.person_list=1))
     temp->org[d.seq].person_list[pcnt].person_id = por.person_id, temp->org[d.seq].person_list[pcnt]
     .name_full_formatted = p.name_full_formatted, temp->org[d.seq].person_list[pcnt].
     confid_level_code_value = cv.code_value,
     temp->org[d.seq].person_list[pcnt].confid_level_disp = cv.display, temp->org[d.seq].person_list[
     pcnt].confid_level_mean = cv.cdf_meaning, temp->org[d.seq].person_list[pcnt].prsnl_org_reltn_id
      = por.prsnl_org_reltn_id
    ENDIF
   FOOT  d.seq
    stat = alterlist(reply->org[d.seq].person_list,pcnt)
    IF ((request->load.person_count=1))
     temp->org[d.seq].person_count = pcnt
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
     AND (osr.organization_id=temp->org[d.seq].organization_id))
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
    found = 0, pcnt = size(temp->org[d.seq].person_list,5)
    FOR (i = 1 TO pcnt)
      IF ((temp->org[d.seq].person_list[i].person_id=os.prsnl_id))
       found = 1, i = pcnt
      ENDIF
    ENDFOR
    IF (found=0)
     pcnt = (pcnt+ 1), stat = alterlist(temp->org[d.seq].person_list,pcnt)
     IF ((request->load.person_list=1))
      temp->org[d.seq].person_list[pcnt].person_id = os.prsnl_id, temp->org[d.seq].person_list[pcnt].
      name_full_formatted = p.name_full_formatted
     ENDIF
    ENDIF
   FOOT  d.seq
    stat = alterlist(reply->org[d.seq].person_list,pcnt)
    IF ((request->load.person_count=1))
     temp->org[d.seq].person_count = pcnt
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
    WHERE (por.organization_id=temp->org[d.seq].organization_id)
     AND por.active_ind=1
     AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (por.end_effective_dt_tm=null
    )) )
   ORDER BY d.seq
   DETAIL
    temp->org[d.seq].person_ind = 0
   WITH nocounter, outerjoin = d, dontexist
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ocnt),
    org_set_prsnl_r os,
    org_set_org_r osr
   PLAN (d
    WHERE (temp->org[d.seq].person_ind=0))
    JOIN (osr
    WHERE osr.active_ind=1
     AND (osr.organization_id=temp->org[d.seq].organization_id))
    JOIN (os
    WHERE os.active_ind=1
     AND os.org_set_id=osr.org_set_id
     AND os.org_set_type_cd=type_code_value)
   ORDER BY d.seq
   DETAIL
    temp->org[d.seq].person_ind = 1
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
  SET idx = 0
  SELECT INTO "nl:"
   por.organization_id
   FROM prsnl_org_reltn por,
    prsnl p
   PLAN (por
    WHERE expand(idx,1,ocnt,por.organization_id,temp->org[idx].organization_id)
     AND por.active_ind=1
     AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (por.end_effective_dt_tm=null
    )) )
    JOIN (p
    WHERE parser(plistparse))
   ORDER BY por.organization_id
   HEAD por.organization_id
    pos = locateval(idx,1,ocnt,por.organization_id,temp->org[idx].organization_id), pcnt = 0
   DETAIL
    pcnt = (pcnt+ 1)
   FOOT  por.organization_id
    IF (pos > 0)
     temp->org[pos].person_count = pcnt
    ENDIF
    pcnt = 0, pos = 0
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 IF (ocnt > 0
  AND (request->load.address_ind=1))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ocnt),
    address a
   PLAN (d)
    JOIN (a
    WHERE (a.parent_entity_id=temp->org[d.seq].organization_id)
     AND a.parent_entity_name="ORGANIZATION"
     AND a.active_ind=1)
   DETAIL
    temp->org[d.seq].address_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF (ocnt > 0
  AND (request->load.phone_ind=1))
  SET extsecemail_cd = 0.0
  SET intsecemail_cd = 0.0
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.code_set=43
    AND cv.cdf_meaning IN ("EXTSECEMAIL", "INTSECEMAIL")
    AND cv.active_ind=1
   DETAIL
    IF (cv.cdf_meaning="EXTSECEMAIL")
     extsecemail_cd = cv.code_value
    ELSEIF (cv.cdf_meaning="INTSECEMAIL")
     intsecemail_cd = cv.code_value
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ocnt),
    phone p
   PLAN (d)
    JOIN (p
    WHERE (p.parent_entity_id=temp->org[d.seq].organization_id)
     AND p.parent_entity_name="ORGANIZATION"
     AND p.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    found_mail = 0, found_non_mail = 0
   DETAIL
    IF (p.phone_type_cd IN (extsecemail_cd, intsecemail_cd))
     found_mail = 1
    ELSE
     found_non_mail = 1
    ENDIF
    temp->org[d.seq].phone_ind = 1
   FOOT  d.seq
    IF (found_mail=1
     AND found_non_mail=0)
     temp->org[d.seq].phone_ind = 0
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (isprsnlsecurityapplied=0)
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
 ENDIF
 SUBROUTINE isprsnlmatch(organization_id)
   SELECT DISTINCT INTO "nl:"
    FROM prsnl_org_reltn por
    WHERE (por.person_id=reqinfo->updt_id)
     AND por.organization_id=organization_id
     AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (por.end_effective_dt_tm=null
    ))
    WITH nocounter
   ;end select
   CALL echo(curqual)
   RETURN(curqual)
 END ;Subroutine
 DECLARE facility_cd = f8 WITH protect
 SET facility_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=278
    AND c.cdf_meaning="FACILITY"
    AND c.active_ind=1)
  DETAIL
   facility_cd = c.code_value
  WITH nocounter
 ;end select
 SUBROUTINE isfacility(organization_id)
  SELECT INTO "nl:"
   FROM org_type_reltn otr
   WHERE otr.org_type_cd=facility_cd
    AND otr.organization_id=organization_id
   WITH nocounter
  ;end select
  RETURN(curqual)
 END ;Subroutine
 SUBROUTINE getapplyorgsecurityind(dummyvar)
   DECLARE apply_org_security_ind = i2
   SELECT INTO "nl:"
    FROM br_name_value bnv
    PLAN (bnv
     WHERE bnv.br_nv_key1="SYSTEMPARAM"
      AND bnv.br_client_id=1
      AND bnv.br_name="APPLYORGSECURITYIND")
    DETAIL
     apply_org_security_ind = cnvtint(bnv.br_value)
    WITH nocounter
   ;end select
   RETURN(apply_org_security_ind)
 END ;Subroutine
 SUBROUTINE copytemptoreply(tindex,rindex)
   SET rindex = (rindex+ 1)
   SET reply->org[rindex].organization_id = temp->org[tindex].organization_id
   SET reply->org[rindex].org_name = temp->org[tindex].org_name
   SET reply->org[rindex].active_ind = temp->org[tindex].active_ind
   SET reply->org[rindex].person_ind = temp->org[tindex].person_ind
   SET reply->org[rindex].person_count = temp->org[tindex].person_count
   FOR (j = 1 TO size(temp->org[tindex].person_list,5))
     SET stat = alterlist(reply->org[rindex].person_list,size(temp->org[tindex].person_list,5))
     SET reply->org[rindex].person_list[j].person_id = temp->org[tindex].person_list[j].person_id
     SET reply->org[rindex].person_list[j].name_full_formatted = temp->org[tindex].person_list[j].
     name_full_formatted
     SET reply->org[rindex].person_list[j].confid_level_code_value = temp->org[tindex].person_list[j]
     .confid_level_code_value
     SET reply->org[rindex].person_list[j].confid_level_disp = temp->org[tindex].person_list[j].
     confid_level_disp
     SET reply->org[rindex].person_list[j].confid_level_mean = temp->org[tindex].person_list[j].
     confid_level_mean
     SET reply->org[rindex].person_list[j].prsnl_org_reltn_id = temp->org[tindex].person_list[j].
     prsnl_org_reltn_id
   ENDFOR
   SET reply->org[rindex].address_ind = temp->org[tindex].address_ind
   SET reply->org[rindex].phone_ind = temp->org[tindex].phone_ind
   SET reply->org[rindex].begin_effective_dt_tm = temp->org[tindex].begin_effective_dt_tm
   SET reply->org[rindex].end_effective_dt_tm = temp->org[tindex].end_effective_dt_tm
   RETURN(rindex)
 END ;Subroutine
 DECLARE cnt = i4
 DECLARE org_id = f8
 DECLARE securityind = i2
 SET securityind = 0
 IF (validate(request->security_ind))
  SET securityind = request->security_ind
 ENDIF
 SET sizeorg = size(temp->org,5)
 SET stat = alterlist(reply->org,sizeorg)
 IF (isprsnlsecurityapplied=1)
  IF (securityind=1)
   SET cnt = 0
   FOR (i = 1 TO sizeorg)
    SET org_id = temp->org[i].organization_id
    IF (org_id > 0
     AND isfacility(org_id) > 0)
     IF (isprsnlmatch(org_id) > 0)
      SET cnt = copytemptoreply(i,cnt)
     ENDIF
    ELSEIF (org_id > 0)
     SET cnt = copytemptoreply(i,cnt)
    ENDIF
   ENDFOR
  ELSE
   SET cnt = 0
   FOR (i = 1 TO sizeorg)
     SET cnt = copytemptoreply(i,cnt)
   ENDFOR
  ENDIF
 ELSEIF ((reply->too_many_results_ind != 1)
  AND isprsnlsecurityapplied=0)
  SET cnt = 0
  FOR (i = 1 TO sizeorg)
    SET cnt = copytemptoreply(i,cnt)
  ENDFOR
 ENDIF
 SET stat = alterlist(reply->org,cnt)
 IF (cnt > 0)
  IF (((cnt > max_cnt) OR (pcnt > max_cnt)) )
   SET reply->too_many_results_ind = 1
   SET reply->status_data.status = "S"
   GO TO exit_script
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

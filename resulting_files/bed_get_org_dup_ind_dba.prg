CREATE PROGRAM bed_get_org_dup_ind:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    01 org_name[*]
      02 dup_ind = i2
      02 organization_id = f8
      02 org_name = vc
      02 org_prefix = vc
      02 active_ind = i2
      02 org_type[*]
        03 code_value = f8
        03 display = vc
        03 meaning = vc
    01 org_prefix[*]
      02 dup_ind = i2
      02 organization_id = f8
      02 org_name = vc
      02 org_prefix = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET ocnt = size(request->name_list,5)
 SET stat = alterlist(reply->org_name,ocnt)
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
 FOR (i = 1 TO ocnt)
   SET reply->org_name[i].org_name = request->name_list[i].org_name
   SET reply->org_name[i].dup_ind = 0
   SET reply->org_name[i].organization_id = 0
 ENDFOR
 IF (ocnt > 0)
  DECLARE org_parse = vc
  SET org_parse = "o.org_class_cd = org_class_cd"
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
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ocnt),
    organization o,
    br_organization borg
   PLAN (d)
    JOIN (o
    WHERE o.org_name_key=cnvtupper(cnvtalphanum(request->name_list[d.seq].org_name))
     AND o.data_status_cd=auth_cd
     AND parser(org_parse))
    JOIN (borg
    WHERE borg.organization_id=outerjoin(o.organization_id))
   DETAIL
    reply->org_name[d.seq].dup_ind = 1, reply->org_name[d.seq].organization_id = o.organization_id,
    reply->org_name[d.seq].org_prefix = borg.br_prefix,
    reply->org_name[d.seq].active_ind = o.active_ind
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM org_type_reltn otr,
    code_value cv,
    (dummyt d  WITH seq = ocnt)
   PLAN (d
    WHERE (reply->org_name[d.seq].organization_id > 0))
    JOIN (otr
    WHERE (otr.organization_id=reply->org_name[d.seq].organization_id)
     AND otr.active_ind=1)
    JOIN (cv
    WHERE cv.active_ind=1
     AND cv.code_value=otr.org_type_cd)
   HEAD d.seq
    otcnt = 0
   DETAIL
    otcnt = (otcnt+ 1), stat = alterlist(reply->org_name[d.seq].org_type,otcnt), reply->org_name[d
    .seq].org_type[otcnt].code_value = otr.org_type_cd,
    reply->org_name[d.seq].org_type[otcnt].display = cv.display, reply->org_name[d.seq].org_type[
    otcnt].meaning = cv.cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
 SET ocnt = size(request->prefix_list,5)
 SET stat = alterlist(reply->org_prefix,ocnt)
 FOR (i = 1 TO ocnt)
   SET reply->org_prefix[i].org_prefix = request->prefix_list[i].org_prefix
   SET reply->org_prefix[i].dup_ind = 0
   SET reply->org_prefix[i].organization_id = 0
 ENDFOR
 IF (ocnt > 0)
  DECLARE org_parse = vc
  SET org_parse = "o.organization_id = b.organization_id"
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
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ocnt),
    br_organization b,
    organization o
   PLAN (d)
    JOIN (b
    WHERE cnvtupper(b.br_prefix)=cnvtupper(request->prefix_list[d.seq].org_prefix))
    JOIN (o
    WHERE parser(org_parse)
     AND o.data_status_cd=auth_cd)
   DETAIL
    reply->org_prefix[d.seq].org_name = o.org_name, reply->org_prefix[d.seq].dup_ind = 1, reply->
    org_prefix[d.seq].organization_id = o.organization_id
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO

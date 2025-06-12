CREATE PROGRAM bed_get_facility_list:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    01 facility[*]
      02 location_code_value = f8
      02 fac_short_description = vc
      02 fac_full_description = vc
      02 organization_id = f8
      02 bldg_cnt = i2
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
 RECORD treply(
   01 facility[*]
     02 location_code_value = f8
     02 fac_short_description = vc
     02 fac_full_description = vc
     02 organization_id = f8
     02 bldg_cnt = i2
 )
 DECLARE active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE inactive_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"INACTIVE"))
 DECLARE apply_org_security_ind = i2 WITH protect, noconstant(0)
 DECLARE honor_org_security_ind = i2 WITH protect, noconstant(0)
 SET honor_org_security_ind = 0
 IF (validate(request->honor_org_security_ind))
  SET honor_org_security_ind = request->honor_org_security_ind
 ENDIF
 DECLARE getapplyorgsecurityind(dummyvar=i2) = i2
 SET apply_org_security_ind = getapplyorgsecurityind(0)
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 SET wcard = "*"
 SET max_cnt = 0
 IF ((request->max_reply_limit > 0))
  SET max_cnt = request->max_reply_limit
 ELSE
  SET max_cnt = 1000000
 ENDIF
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
 DECLARE fac_name_parse = vc
 DECLARE loc_parse = vc
 DECLARE search_string = vc
 IF (trim(request->search_txt) > " ")
  IF ((request->search_type_flag="S"))
   SET search_string = concat(trim(cnvtupper(request->search_txt)),wcard)
  ELSE
   SET search_string = concat(wcard,trim(cnvtupper(request->search_txt)),wcard)
  ENDIF
  SET fac_name_parse = concat("cnvtupper(c.description) = '",search_string,"'")
 ELSE
  SET search_string = wcard
  SET fac_name_parse = concat("trim(cnvtupper(c.display_key)) = '",search_string,"'")
 ENDIF
 IF ((request->show_inactive_ind=1))
  SET loc_parse =
  "l.location_cd=c.code_value and l.location_type_cd = facility_cd and l.active_status_cd in (active_cd,inactive_cd)"
 ELSE
  SET loc_parse =
  "l.location_cd=c.code_value and l.location_type_cd=facility_cd and l.active_ind=1 and l.active_status_cd=active_cd"
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
 DECLARE alias_parse = vc
 SET alias_parse = "a.alias_pool_cd = oap.alias_pool_cd"
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET org_parse = concat(org_parse," and o.logical_domain_id in (")
   SET alias_parse = concat(alias_parse," and a.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET org_parse = build(org_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
      SET alias_parse = build(alias_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
     ELSE
      SET org_parse = build(org_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
      SET alias_parse = build(alias_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 DECLARE org_id = vc
 SELECT INTO "nl:"
  FROM prsnl_org_reltn por,
   organization o
  PLAN (por
   WHERE (por.person_id=reqinfo->updt_id)
    AND por.active_ind=1
    AND por.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ((por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (por.end_effective_dt_tm=null
   )) )
   JOIN (o
   WHERE o.organization_id=por.organization_id
    AND o.active_ind=1)
  HEAD REPORT
   orgcnt = 0
  DETAIL
   IF (orgcnt > 999)
    org_id = replace(org_id,",","",2), org_id = build(org_id,") or o.organization_id in ("), orgcnt
     = 0
   ENDIF
   org_id = build(org_id,o.organization_id,","), orgcnt = (orgcnt+ 1)
  WITH nocounter
 ;end select
 SET org_id = replace(org_id,",","",2)
 IF (apply_org_security_ind=1
  AND honor_org_security_ind=1)
  SET org_parse = build(org_parse," and o.organization_id in (",org_id,")")
 ENDIF
 IF (validate(request->load_only_effective_facs_ind))
  IF ((request->load_only_effective_facs_ind=1))
   SET org_parse = build(org_parse," and o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) ",
    " and o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3) ")
   SET loc_parse = build(loc_parse," and l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) ",
    " and l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3) ")
  ENDIF
 ENDIF
 SET oap_size = 0
 DECLARE oap_parse = vc
 SET oap_parse = concat("oap.organization_id = o.organization_id ")
 IF (validate(request->org_alias_pool_types[1].code_value))
  SET oap_size = size(request->org_alias_pool_types,5)
  FOR (a = 1 TO oap_size)
    IF (a=1)
     SET oap_parse = build(oap_parse," and oap.alias_entity_alias_type_cd in (",request->
      org_alias_pool_types[a].code_value)
    ELSE
     SET oap_parse = build(oap_parse,",",request->org_alias_pool_types[a].code_value)
    ENDIF
  ENDFOR
  SET oap_parse = build(oap_parse,")")
 ENDIF
 IF (oap_size=0)
  SET ocnt = 0
  SELECT INTO "nl:"
   fac_name_key = trim(cnvtalphanum(cnvtupper(c.description)))
   FROM code_value c,
    location l,
    organization o
   PLAN (c
    WHERE parser(fac_name_parse)
     AND c.code_set=220
     AND c.cdf_meaning="FACILITY"
     AND c.active_ind=1)
    JOIN (l
    WHERE parser(loc_parse))
    JOIN (o
    WHERE parser(org_parse))
   ORDER BY fac_name_key
   HEAD REPORT
    ocnt = 0
   DETAIL
    ocnt = (ocnt+ 1), stat = alterlist(treply->facility,ocnt), treply->facility[ocnt].
    location_code_value = c.code_value,
    treply->facility[ocnt].fac_short_description = c.display, treply->facility[ocnt].
    fac_full_description = c.description, treply->facility[ocnt].organization_id = l.organization_id,
    treply->facility[ocnt].bldg_cnt = 0
   WITH nocounter, maxqual(c,value((max_cnt+ 1)))
  ;end select
 ELSE
  CALL echo(alias_parse)
  SET ocnt = 0
  SELECT INTO "nl:"
   fac_name_key = trim(cnvtalphanum(cnvtupper(c.description)))
   FROM code_value c,
    location l,
    org_alias_pool_reltn oap,
    alias_pool a,
    organization o
   PLAN (c
    WHERE parser(fac_name_parse)
     AND c.code_set=220
     AND c.cdf_meaning="FACILITY"
     AND c.active_ind=1)
    JOIN (l
    WHERE parser(loc_parse))
    JOIN (o
    WHERE parser(org_parse))
    JOIN (oap
    WHERE parser(oap_parse)
     AND oap.alias_entity_name="PRSNL_ALIAS"
     AND oap.active_ind=1
     AND oap.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND oap.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (a
    WHERE parser(alias_parse)
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY fac_name_key, c.code_value
   HEAD REPORT
    ocnt = 0
   HEAD c.code_value
    ocnt = (ocnt+ 1), stat = alterlist(treply->facility,ocnt), treply->facility[ocnt].
    location_code_value = c.code_value,
    treply->facility[ocnt].fac_short_description = c.display, treply->facility[ocnt].
    fac_full_description = c.description, treply->facility[ocnt].organization_id = l.organization_id,
    treply->facility[ocnt].bldg_cnt = 0
   WITH nocounter, maxqual(c,value((max_cnt+ 1)))
  ;end select
 ENDIF
 IF (ocnt=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 IF ((request->load_only_facs_with_units_ind=1))
  SET rcnt = 0
  FOR (o = 1 TO ocnt)
    SET bcnt = 0
    SET ucnt = 0
    SELECT INTO "nl:"
     FROM location_group lg1,
      location_group lg2
     PLAN (lg1
      WHERE (lg1.parent_loc_cd=treply->facility[o].location_code_value)
       AND lg1.location_group_type_cd=facility_cd
       AND lg1.active_ind=1)
      JOIN (lg2
      WHERE lg2.parent_loc_cd=outerjoin(lg1.child_loc_cd)
       AND lg2.active_ind=outerjoin(1))
     ORDER BY lg1.parent_loc_cd, lg1.child_loc_cd, lg2.child_loc_cd
     HEAD lg1.child_loc_cd
      bcnt = (bcnt+ 1)
     DETAIL
      IF (lg2.parent_loc_cd > 0)
       ucnt = (ucnt+ 1)
      ENDIF
     WITH nocounter
    ;end select
    IF (bcnt > 0
     AND ucnt > 0)
     IF ((request->load_bldg_cnt_ind=1))
      SET treply->facility[o].bldg_cnt = bcnt
     ENDIF
     SET rcnt = (rcnt+ 1)
     SET stat = alterlist(reply->facility,rcnt)
     SET reply->facility[rcnt].location_code_value = treply->facility[o].location_code_value
     SET reply->facility[rcnt].fac_short_description = treply->facility[o].fac_short_description
     SET reply->facility[rcnt].fac_full_description = treply->facility[o].fac_full_description
     SET reply->facility[rcnt].organization_id = treply->facility[o].organization_id
     SET reply->facility[rcnt].bldg_cnt = treply->facility[o].bldg_cnt
    ENDIF
  ENDFOR
 ELSE
  IF ((request->load_bldg_cnt_ind=1))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = ocnt),
     location_group lg
    PLAN (d)
     JOIN (lg
     WHERE (lg.parent_loc_cd=treply->facility[d.seq].location_code_value)
      AND lg.location_group_type_cd=facility_cd
      AND lg.active_ind=1)
    ORDER BY d.seq, lg.parent_loc_cd, lg.child_loc_cd
    HEAD lg.parent_loc_cd
     bcnt = 0
    DETAIL
     bcnt = (bcnt+ 1)
    FOOT  lg.parent_loc_cd
     treply->facility[d.seq].bldg_cnt = bcnt
    WITH nocounter
   ;end select
  ENDIF
  SET stat = alterlist(reply->facility,ocnt)
  FOR (o = 1 TO ocnt)
    SET reply->facility[o].location_code_value = treply->facility[o].location_code_value
    SET reply->facility[o].fac_short_description = treply->facility[o].fac_short_description
    SET reply->facility[o].fac_full_description = treply->facility[o].fac_full_description
    SET reply->facility[o].organization_id = treply->facility[o].organization_id
    SET reply->facility[o].bldg_cnt = treply->facility[o].bldg_cnt
  ENDFOR
 ENDIF
 SUBROUTINE getapplyorgsecurityind(dummyvar)
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
 IF (ocnt > max_cnt)
  SET stat = alterlist(reply->facility,0)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO

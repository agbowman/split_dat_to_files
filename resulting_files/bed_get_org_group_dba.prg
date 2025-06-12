CREATE PROGRAM bed_get_org_group:dba
 FREE SET reply
 RECORD reply(
   1 org_group_list[*]
     2 org_set_id = f8
     2 name = vc
     2 description = vc
     2 active_ind = i2
     2 type_list[*]
       3 type_disp = vc
       3 type_mean = vc
       3 type_code_value = f8
     2 nbr_of_orgs = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD ogtypes(
   1 ogtype_list[*]
     2 ogtype_mean = vc
     2 ogtype_disp = vc
     2 ogtype_code_value = f8
 )
 DECLARE ogparse = vc
 DECLARE error_msg = vc
 SET error_flag = "F"
 SET reply->status_data.status = "F"
 SET ogcnt = 0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=28881
    AND c.active_ind=1)
  DETAIL
   ogcnt = (ogcnt+ 1), stat = alterlist(ogtypes->ogtype_list,ogcnt), ogtypes->ogtype_list[ogcnt].
   ogtype_mean = c.cdf_meaning,
   ogtypes->ogtype_list[ogcnt].ogtype_disp = c.display, ogtypes->ogtype_list[ogcnt].ogtype_code_value
    = c.code_value
  WITH nocounter
 ;end select
 SET ogparse = fillstring(100," ")
 SET ogparse = concat(ogparse,"ogt.org_set_id = o.org_set_id and ")
 IF (request->load_by_group_type_ind)
  SET ogsz = size(request->og_type,5)
  FOR (i = 1 TO ogsz)
    IF (i > 1)
     SET ogparse = concat(ogparse," or ")
    ENDIF
    SET ogcode = 0.0
    SELECT INTO "nl:"
     FROM code_value c
     WHERE c.code_set=28881
      AND (c.cdf_meaning=request->og_type[i].org_group_type_mean)
      AND c.active_ind=1
     DETAIL
      ogcode = c.code_value
     WITH nocounter
    ;end select
    IF (ogcode > 0)
     SET ogparse = build(ogparse," ogt.org_set_type_cd = ",ogcode)
    ENDIF
  ENDFOR
 ELSE
  SET ogparse = concat(" ogt.org_set_id = o.org_set_id")
 ENDIF
 CALL echo(build("OGPARSE = ",ogparse))
 SET ocnt = 0
 SET ogtcnt = 0
 IF (request->load_inactive_ind)
  SELECT INTO "nl:"
   FROM org_set o,
    org_set_type_r ogt
   PLAN (o
    WHERE o.name > " ")
    JOIN (ogt
    WHERE parser(ogparse))
   ORDER BY o.org_set_id, ogt.org_set_type_cd
   HEAD o.org_set_id
    ocnt = (ocnt+ 1), ogtcnt = 0, stat = alterlist(reply->org_group_list,ocnt),
    reply->org_group_list[ocnt].org_set_id = o.org_set_id, reply->org_group_list[ocnt].name = o.name,
    reply->org_group_list[ocnt].description = o.description,
    reply->org_group_list[ocnt].active_ind = o.active_ind
   HEAD ogt.org_set_type_cd
    ogtcnt = (ogtcnt+ 1), stat = alterlist(reply->org_group_list[ocnt].type_list,ogtcnt), reply->
    org_group_list[ocnt].type_list[ogtcnt].type_code_value = ogt.org_set_type_cd
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM org_set o,
    org_set_type_r ogt
   PLAN (o
    WHERE o.active_ind=1
     AND o.name > " ")
    JOIN (ogt
    WHERE parser(ogparse))
   ORDER BY o.org_set_id, ogt.org_set_type_cd
   HEAD o.org_set_id
    ocnt = (ocnt+ 1), ogtcnt = 0, stat = alterlist(reply->org_group_list,ocnt),
    reply->org_group_list[ocnt].org_set_id = o.org_set_id, reply->org_group_list[ocnt].name = o.name,
    reply->org_group_list[ocnt].description = o.description,
    reply->org_group_list[ocnt].active_ind = o.active_ind
   HEAD ogt.org_set_type_cd
    ogtcnt = (ogtcnt+ 1), stat = alterlist(reply->org_group_list[ocnt].type_list,ogtcnt), reply->
    org_group_list[ocnt].type_list[ogtcnt].type_code_value = ogt.org_set_type_cd
   WITH nocounter
  ;end select
 ENDIF
 FOR (i = 1 TO ocnt)
  SET zz = size(reply->org_group_list[i].type_list,5)
  FOR (j = 1 TO zz)
    FOR (k = 1 TO ogcnt)
      IF ((reply->org_group_list[i].type_list[j].type_code_value=ogtypes->ogtype_list[k].
      ogtype_code_value))
       SET reply->org_group_list[i].type_list[j].type_disp = ogtypes->ogtype_list[k].ogtype_disp
       SET reply->org_group_list[i].type_list[j].type_mean = ogtypes->ogtype_list[k].ogtype_mean
      ENDIF
    ENDFOR
  ENDFOR
 ENDFOR
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
 SET org_parse = "o.organization_id = osor.organization_id"
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
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = ocnt),
   org_set_org_r osor,
   organization o
  PLAN (d)
   JOIN (osor
   WHERE (osor.org_set_id=reply->org_group_list[d.seq].org_set_id)
    AND osor.active_ind=1)
   JOIN (o
   WHERE parser(org_parse)
    AND o.active_ind=1)
  HEAD d.seq
   org_cnt = 0
  DETAIL
   org_cnt = (org_cnt+ 1)
  FOOT  d.seq
   reply->org_group_list[d.seq].nbr_of_orgs = org_cnt
  WITH nocounter
 ;end select
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(" >> PROGRAM NAME: BED_GET_ORG_GROUP   >>  ERROR MESSAGE: ",error_msg
   )
 ELSE
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 CALL echorecord(reply)
END GO

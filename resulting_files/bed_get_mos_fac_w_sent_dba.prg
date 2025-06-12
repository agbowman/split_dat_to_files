CREATE PROGRAM bed_get_mos_fac_w_sent:dba
 FREE SET reply
 RECORD reply(
   1 facility[*]
     2 location_code_value = f8
     2 fac_short_description = vc
     2 fac_full_description = vc
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD treply(
   01 facility[*]
     02 location_code_value = f8
     02 fac_short_description = vc
     02 fac_full_description = vc
 )
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 SET wcard = "*"
 SET max_cnt = 0
 IF ((request->max_reply_limit > 0))
  SET max_cnt = request->max_reply_limit
 ENDIF
 SET facility_cd = 0.0
 SET facility_cd = uar_get_code_by("MEANING",222,"FACILITY")
 SET pharm_ct = 0.0
 SET pharm_ct = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET pharm_at = 0.0
 SET pharm_at = uar_get_code_by("MEANING",106,"PHARMACY")
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
  SET fac_name_parse = concat("cnvtupper(c.display_key) = '",search_string,"'")
 ENDIF
 SET loc_parse =
 "l.location_cd = c.code_value and l.location_type_cd = facility_cd and l.active_ind = 1 and l.organization_id > 0"
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
 SET cnt = 0
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM filter_entity_reltn f,
   order_sentence os,
   order_catalog_synonym ocs,
   order_catalog oc
  PLAN (f
   WHERE f.parent_entity_name="ORDER_SENTENCE"
    AND f.filter_entity1_name="LOCATION"
    AND f.filter_entity1_id > 0)
   JOIN (os
   WHERE os.order_sentence_id=f.parent_entity_id
    AND os.parent_entity_name="ORDER_CATALOG_SYNONYM")
   JOIN (ocs
   WHERE ocs.synonym_id=os.parent_entity_id
    AND ocs.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND ((oc.catalog_type_cd+ 0)=pharm_ct)
    AND ((oc.activity_type_cd+ 0)=pharm_at)
    AND ((oc.orderable_type_flag+ 0) IN (0, 1))
    AND ((oc.active_ind+ 0)=1))
  ORDER BY f.filter_entity1_id
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(treply->facility,100)
  HEAD f.filter_entity1_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(treply->facility,(tcnt+ 100)), cnt = 1
   ENDIF
   treply->facility[tcnt].location_code_value = f.filter_entity1_id
  FOOT REPORT
   stat = alterlist(treply->facility,tcnt)
  WITH nocounter
 ;end select
 SET totcnt = 0
 IF (tcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tcnt)),
    code_value c,
    location l,
    organization o
   PLAN (d)
    JOIN (c
    WHERE (c.code_value=treply->facility[d.seq].location_code_value)
     AND parser(fac_name_parse)
     AND c.code_set=220
     AND c.cdf_meaning="FACILITY"
     AND c.active_ind=1)
    JOIN (l
    WHERE parser(loc_parse))
    JOIN (o
    WHERE parser(org_parse))
   ORDER BY c.code_value
   HEAD REPORT
    cnt = 0, totcnt = 0, stat = alterlist(reply->facility,100)
   HEAD c.code_value
    cnt = (cnt+ 1), totcnt = (totcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->facility,(totcnt+ 100)), cnt = 1
    ENDIF
    reply->facility[totcnt].location_code_value = c.code_value, reply->facility[totcnt].
    fac_short_description = c.display, reply->facility[totcnt].fac_full_description = c.description
   FOOT REPORT
    stat = alterlist(reply->facility,totcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (totcnt > max_cnt
  AND max_cnt > 0)
  SET stat = alterlist(reply->facility,0)
  SET reply->too_many_results_ind = 1
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

CREATE PROGRAM bed_get_health_plan_list:dba
 IF ( NOT (validate(timelyfilingrequest,0)))
  FREE SET timelyfilingrequest
  RECORD timelyfilingrequest(
    1 timely_filings[*]
      2 health_plan_id = f8
  )
 ENDIF
 IF ( NOT (validate(timelyfilingreply,0)))
  RECORD timelyfilingreply(
    1 timely_filings[*]
      2 health_plan_id = f8
      2 auto_release_days = i4
      2 limit_days = i4
      2 notify_days = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 health_plans[*]
      2 active_ind = i2
      2 plan_id = f8
      2 plan_name = vc
      2 plan_desc = vc
      2 address_ind = i2
      2 phone_ind = i2
      2 financial_class
        3 code_value = f8
        3 display = vc
        3 mean = vc
      2 plan_type
        3 code_value = f8
        3 display = vc
        3 mean = vc
      2 organizations[*]
        3 id = f8
        3 name = vc
        3 org_plan_reltn_id = f8
      2 service_type
        3 code_value = f8
        3 display = vc
        3 mean = vc
      2 plan_category
        3 code_value = f8
        3 display = vc
        3 mean = vc
      2 end_effective_ind = i2
      2 limit_days = i4
      2 auto_release_days = i4
      2 notify_days = i4
      2 consumer_add_covrg_allow_ind = i2
      2 consumer_modify_covrg_deny_ind = i2
      2 priority_ranking_nbr = i4
      2 priority_ranking_nbr_null_ind = i2
      2 classification
        3 code_value = f8
        3 display = vc
        3 mean = vc
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
 DECLARE carrier_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",370,"CARRIER"))
 DECLARE carrier_rx_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",370,"CARRIER_RX"))
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
   ENDIF
  ENDIF
 ENDIF
 SET cnt = 0
 SET tot_cnt = 0
 SET ocnt = 0
 SET tot_ocnt = 0
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 SET max_cnt = 0
 IF ((request->max_reply_limit > 0))
  SET max_cnt = request->max_reply_limit
 ELSE
  SET max_cnt = 1000000
 ENDIF
 SET wcard = "*"
 DECLARE hp_parse = vc
 DECLARE search_string = vc
 IF (trim(request->search_txt) > " ")
  IF ((request->search_type_flag="S"))
   SET search_string = concat(trim(cnvtupper(request->search_txt)),wcard)
  ELSE
   SET search_string = concat(wcard,trim(cnvtupper(request->search_txt)),wcard)
  ENDIF
  SET hp_parse = concat("cnvtupper(h.plan_name) = '",search_string,"'")
 ELSE
  SET search_string = wcard
  SET hp_parse = concat("cnvtupper(h.plan_name) = '",search_string,"'")
 ENDIF
 IF ((request->financial_class_code_value > 0))
  SET hp_parse = concat(hp_parse," and h.financial_class_cd = request->financial_class_code_value")
 ENDIF
 IF ((request->plan_type_code_value > 0))
  SET hp_parse = concat(hp_parse," and h.plan_type_cd = request->plan_type_code_value")
 ENDIF
 IF (validate(request->plan_category_code_value))
  IF ((request->plan_category_code_value > 0))
   SET hp_parse = concat(hp_parse," and h.plan_category_cd = request->plan_category_code_value")
  ENDIF
 ENDIF
 IF (validate(request->service_type_code_value))
  IF ((request->service_type_code_value > 0))
   SET hp_parse = concat(hp_parse," and h.service_type_cd = request->service_type_code_value")
  ENDIF
 ENDIF
 IF ((request->priority_ranking_nbr_flag=1))
  SET hp_parse = concat(hp_parse," and h.priority_ranking_nbr is null")
 ELSEIF ((request->priority_ranking_nbr_flag=2))
  SET hp_parse = concat(hp_parse," and h.priority_ranking_nbr = ",cnvtstring(request->
    priority_ranking_nbr_value))
 ENDIF
 IF (data_partition_ind=1)
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
  SET acm_get_acc_logical_domains_req->concept = 4
  EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
  replace("REPLY",acm_get_acc_logical_domains_rep)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET hp_parse = concat(hp_parse," and h.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET hp_parse = build(hp_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
     ELSE
      SET hp_parse = build(hp_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF ((request->organization_id > 0))
  SET hp_parse = concat(hp_parse," and exists (select o.organization_id from org_plan_reltn o",
   " where o.health_plan_id = h.health_plan_id and o.organization_id = request->organization_id)")
 ENDIF
 DECLARE authenticated = f8 WITH protect
 SET authenticated = uar_get_code_by("MEANING",8,"AUTH")
 SET stat = alterlist(reply->health_plans,100)
 SELECT INTO "NL:"
  FROM health_plan h,
   code_value cv354,
   code_value cv367,
   code_value cv27137,
   code_value cv4002927,
   code_value cv4760207
  PLAN (h
   WHERE h.health_plan_id > 0
    AND h.active_ind=1
    AND h.data_status_cd=authenticated
    AND parser(hp_parse))
   JOIN (cv354
   WHERE cv354.code_value=h.financial_class_cd)
   JOIN (cv367
   WHERE cv367.code_value=h.plan_type_cd)
   JOIN (cv27137
   WHERE cv27137.code_value=outerjoin(h.service_type_cd)
    AND cv27137.active_ind=outerjoin(1))
   JOIN (cv4002927
   WHERE cv4002927.code_value=h.plan_category_cd)
   JOIN (cv4760207
   WHERE cv4760207.code_value=outerjoin(h.classification_cd)
    AND cv4760207.active_ind=outerjoin(1))
  ORDER BY h.health_plan_id
  HEAD h.health_plan_id
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->health_plans,(tot_cnt+ 100)), cnt = 1
   ENDIF
   reply->health_plans[tot_cnt].active_ind = h.active_ind, reply->health_plans[tot_cnt].plan_id = h
   .health_plan_id, reply->health_plans[tot_cnt].plan_name = h.plan_name,
   reply->health_plans[tot_cnt].plan_desc = h.plan_desc, reply->health_plans[tot_cnt].address_ind = 0,
   reply->health_plans[tot_cnt].phone_ind = 0
   IF (h.end_effective_dt_tm < cnvtdatetime(curdate,curtime3))
    reply->health_plans[tot_cnt].end_effective_ind = 1
   ELSE
    reply->health_plans[tot_cnt].end_effective_ind = 0
   ENDIF
   reply->health_plans[tot_cnt].financial_class.code_value = h.financial_class_cd
   IF (h.financial_class_cd > 0)
    reply->health_plans[tot_cnt].financial_class.display = cv354.display, reply->health_plans[tot_cnt
    ].financial_class.mean = cv354.cdf_meaning
   ENDIF
   reply->health_plans[tot_cnt].classification.code_value = h.classification_cd
   IF (h.classification_cd > 0)
    reply->health_plans[tot_cnt].classification.display = cv4760207.display, reply->health_plans[
    tot_cnt].classification.mean = cv4760207.cdf_meaning
   ENDIF
   reply->health_plans[tot_cnt].plan_type.code_value = h.plan_type_cd
   IF (h.plan_type_cd > 0)
    reply->health_plans[tot_cnt].plan_type.display = cv367.display, reply->health_plans[tot_cnt].
    plan_type.mean = cv367.cdf_meaning
   ENDIF
   reply->health_plans[tot_cnt].service_type.code_value = h.service_type_cd
   IF (h.service_type_cd > 0)
    reply->health_plans[tot_cnt].service_type.display = cv27137.display, reply->health_plans[tot_cnt]
    .service_type.mean = cv27137.cdf_meaning
   ENDIF
   reply->health_plans[tot_cnt].plan_category.code_value = h.plan_category_cd
   IF (h.plan_category_cd > 0)
    reply->health_plans[tot_cnt].plan_category.display = cv4002927.display, reply->health_plans[
    tot_cnt].plan_category.mean = cv4002927.cdf_meaning
   ENDIF
   IF (nullind(h.consumer_add_covrg_allow_ind)=1)
    reply->health_plans[tot_cnt].consumer_add_covrg_allow_ind = - (1)
   ELSE
    reply->health_plans[tot_cnt].consumer_add_covrg_allow_ind = h.consumer_add_covrg_allow_ind
   ENDIF
   IF (nullind(h.consumer_modify_covrg_deny_ind)=1)
    reply->health_plans[tot_cnt].consumer_modify_covrg_deny_ind = - (1)
   ELSE
    reply->health_plans[tot_cnt].consumer_modify_covrg_deny_ind = h.consumer_modify_covrg_deny_ind
   ENDIF
   IF (nullind(h.priority_ranking_nbr)=0)
    reply->health_plans[tot_cnt].priority_ranking_nbr = h.priority_ranking_nbr
   ELSE
    reply->health_plans[tot_cnt].priority_ranking_nbr_null_ind = 1
   ENDIF
  WITH nocounter, maxqual(h,value((max_cnt+ 1)))
 ;end select
 SET stat = alterlist(reply->health_plans,tot_cnt)
 IF (tot_cnt=0)
  GO TO exit_script
 ENDIF
 IF ((request->load.address_ind=1))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tot_cnt),
    address a
   PLAN (d)
    JOIN (a
    WHERE (a.parent_entity_id=reply->health_plans[d.seq].plan_id)
     AND a.parent_entity_name="HEALTH_PLAN"
     AND a.active_ind=1)
   DETAIL
    reply->health_plans[d.seq].address_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->load.phone_ind=1))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tot_cnt),
    phone p
   PLAN (d)
    JOIN (p
    WHERE (p.parent_entity_id=reply->health_plans[d.seq].plan_id)
     AND p.parent_entity_name="HEALTH_PLAN"
     AND p.active_ind=1)
   DETAIL
    reply->health_plans[d.seq].phone_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->organization_type_code_value > 0))
  DECLARE org_parse = vc
  SET org_parse = "o.active_ind = 1"
  IF (data_partition_ind=1)
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
   FROM org_plan_reltn opr,
    organization o,
    org_type_reltn otr,
    (dummyt d  WITH seq = tot_cnt)
   PLAN (d)
    JOIN (opr
    WHERE (opr.health_plan_id=reply->health_plans[d.seq].plan_id)
     AND opr.health_plan_id > 0
     AND opr.active_ind=1
     AND opr.org_plan_reltn_cd IN (carrier_cd, carrier_rx_cd))
    JOIN (o
    WHERE o.organization_id=opr.organization_id
     AND parser(org_parse))
    JOIN (otr
    WHERE (otr.org_type_cd=request->organization_type_code_value)
     AND otr.organization_id=o.organization_id
     AND otr.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    tot_ocnt = 0, ocnt = 0, stat = alterlist(reply->health_plans[d.seq].organizations,20)
   DETAIL
    ocnt = (ocnt+ 1), tot_ocnt = (tot_ocnt+ 1)
    IF (ocnt > 20)
     stat = alterlist(reply->health_plans[d.seq].organizations,(tot_ocnt+ 20)), ocnt = 1
    ENDIF
    reply->health_plans[d.seq].organizations[tot_ocnt].id = o.organization_id, reply->health_plans[d
    .seq].organizations[tot_ocnt].name = o.org_name, reply->health_plans[d.seq].organizations[
    tot_ocnt].org_plan_reltn_id = opr.org_plan_reltn_id
   FOOT  d.seq
    stat = alterlist(reply->health_plans[d.seq].organizations,tot_ocnt)
  ;end select
 ENDIF
 SET timely_filing_request_count = size(reply->health_plans,5)
 FOR (x = 1 TO timely_filing_request_count)
  SET stat = alterlist(timelyfilingrequest->timely_filings,timely_filing_request_count)
  SET timelyfilingrequest->timely_filings[x].health_plan_id = reply->health_plans[x].plan_id
 ENDFOR
 EXECUTE bed_get_hp_timely_filing  WITH replace("REQUEST",timelyfilingrequest), replace("REPLY",
  timelyfilingreply)
 DECLARE timely_filing_reply_count = i4 WITH protect
 SET timely_filing_reply_count = size(timelyfilingreply->timely_filings,5)
 IF (timely_filing_reply_count > 0)
  FOR (x = 1 TO timely_filing_reply_count)
    FOR (y = 1 TO size(reply->health_plans,5))
      IF ((timelyfilingreply->timely_filings[x].health_plan_id=reply->health_plans[y].plan_id))
       SET reply->health_plans[y].limit_days = timelyfilingreply->timely_filings[x].limit_days
       SET reply->health_plans[y].auto_release_days = timelyfilingreply->timely_filings[x].
       auto_release_days
       SET reply->health_plans[y].notify_days = timelyfilingreply->timely_filings[x].notify_days
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
#exit_script
 IF (tot_cnt=0)
  SET reply->status_data.status = "Z"
 ELSEIF (tot_cnt > max_cnt)
  SET stat = alterlist(reply->health_plans,0)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO

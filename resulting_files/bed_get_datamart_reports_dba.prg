CREATE PROGRAM bed_get_datamart_reports:dba
 FREE SET reply
 RECORD reply(
   1 category[*]
     2 br_datamart_category_id = f8
     2 category_name = vc
     2 category_mean = vc
     2 text[*]
       3 text_type_mean = vc
       3 text = vc
       3 text_seq = i4
     2 reports[*]
       3 br_datamart_report_id = f8
       3 report_name = vc
       3 report_mean = vc
       3 report_seq = i4
       3 text[*]
         4 text_type_mean = vc
         4 text = vc
         4 text_seq = i4
       3 baseline_value = vc
       3 target_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET lh_base_target_upd = 0
 SELECT INTO "nl:"
  FROM br_name_value b
  WHERE b.br_nv_key1="LH_BASE_TARGET_UPD"
  DETAIL
   lh_base_target_upd = 1
  WITH nocounter
 ;end select
 IF (lh_base_target_upd=1)
  DECLARE v1parse = vc
  DECLARE v2parse = vc
  SET v1parse = "v1.br_datamart_filter_id = outerjoin(0)"
  SET v2parse = "v2.br_datamart_filter_id = outerjoin(0)"
  SET data_partition_ind = 0
  SET br_datamart_value_field_found = 0
  RANGE OF b IS br_datamart_value
  SET br_datamart_value_field_found = validate(b.logical_domain_id)
  FREE RANGE b
  SET prsnl_field_found = 0
  RANGE OF p IS prsnl
  SET prsnl_field_found = validate(p.logical_domain_id)
  FREE RANGE p
  IF (prsnl_field_found=1
   AND br_datamart_value_field_found=1)
   SET data_partition_ind = 1
  ENDIF
  IF (data_partition_ind=1)
   IF (validate(ld_concept_person)=0)
    DECLARE ld_concept_person = i2 WITH public, constant(1)
   ENDIF
   IF (validate(ld_concept_prsnl)=0)
    DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
   ENDIF
   IF (validate(ld_concept_organization)=0)
    DECLARE ld_concept_organization = i2 WITH public, constant(3)
   ENDIF
   IF (validate(ld_concept_healthplan)=0)
    DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
   ENDIF
   IF (validate(ld_concept_alias_pool)=0)
    DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
   ENDIF
   IF (validate(ld_concept_minvalue)=0)
    DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
   ENDIF
   IF (validate(ld_concept_maxvalue)=0)
    DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
   ENDIF
   RECORD acm_get_curr_logical_domain_req(
     1 concept = i4
   )
   RECORD acm_get_curr_logical_domain_rep(
     1 logical_domain_id = f8
     1 status_block
       2 status_ind = i2
       2 error_code = i4
   )
   SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
   EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
   replace("REPLY",acm_get_curr_logical_domain_rep)
   SET v1parse = build2(v1parse," and v1.logical_domain_id = outerjoin(",
    acm_get_curr_logical_domain_rep->logical_domain_id,")")
   SET v2parse = build2(v2parse," and v2.logical_domain_id = outerjoin(",
    acm_get_curr_logical_domain_rep->logical_domain_id,")")
  ENDIF
 ENDIF
 SET ccnt = 0
 SET tcnt = 0
 SET rcnt = 0
 SELECT INTO "nl:"
  FROM br_datamart_category c,
   br_datamart_text t,
   br_long_text l
  PLAN (c
   WHERE c.br_datamart_category_id > 0)
   JOIN (t
   WHERE t.br_datamart_category_id=outerjoin(c.br_datamart_category_id)
    AND t.br_datamart_report_id=outerjoin(0)
    AND t.br_datamart_filter_id=outerjoin(0))
   JOIN (l
   WHERE l.parent_entity_name=outerjoin("BR_DATAMART_TEXT")
    AND l.parent_entity_id=outerjoin(t.br_datamart_text_id))
  ORDER BY c.category_name
  HEAD c.category_name
   tcnt = 0, ccnt = (ccnt+ 1), stat = alterlist(reply->category,ccnt),
   reply->category[ccnt].br_datamart_category_id = c.br_datamart_category_id, reply->category[ccnt].
   category_name = c.category_name, reply->category[ccnt].category_mean = c.category_mean
  DETAIL
   IF (l.long_text > " ")
    tcnt = (tcnt+ 1), stat = alterlist(reply->category[ccnt].text,tcnt), reply->category[ccnt].text[
    tcnt].text_type_mean = t.text_type_mean,
    reply->category[ccnt].text[tcnt].text = l.long_text, reply->category[ccnt].text[tcnt].text_seq =
    t.text_seq
   ENDIF
  WITH nocounter
 ;end select
 IF (ccnt=0)
  GO TO exit_script
 ENDIF
 IF (lh_base_target_upd=1)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ccnt)),
    br_datamart_report r,
    br_datamart_text t,
    br_datamart_value v1,
    br_datamart_value v2,
    br_long_text l
   PLAN (d)
    JOIN (r
    WHERE (r.br_datamart_category_id=reply->category[d.seq].br_datamart_category_id))
    JOIN (t
    WHERE t.br_datamart_report_id=outerjoin(r.br_datamart_report_id))
    JOIN (v1
    WHERE parser(v1parse)
     AND v1.parent_entity_name=outerjoin("BR_DATAMART_REPORT")
     AND v1.parent_entity_id=outerjoin(r.br_datamart_report_id)
     AND v1.mpage_param_mean=outerjoin("baseline"))
    JOIN (v2
    WHERE parser(v2parse)
     AND v2.parent_entity_name=outerjoin("BR_DATAMART_REPORT")
     AND v2.parent_entity_id=outerjoin(r.br_datamart_report_id)
     AND v2.mpage_param_mean=outerjoin("target"))
    JOIN (l
    WHERE l.parent_entity_name=outerjoin("BR_DATAMART_TEXT")
     AND l.parent_entity_id=outerjoin(t.br_datamart_text_id))
   ORDER BY d.seq, r.report_seq
   HEAD d.seq
    rcnt = 0
   HEAD r.report_seq
    tcnt = 0, rcnt = (rcnt+ 1), stat = alterlist(reply->category[d.seq].reports,rcnt),
    reply->category[d.seq].reports[rcnt].br_datamart_report_id = r.br_datamart_report_id, reply->
    category[d.seq].reports[rcnt].report_name = r.report_name, reply->category[d.seq].reports[rcnt].
    report_mean = r.report_mean,
    reply->category[d.seq].reports[rcnt].report_seq = r.report_seq, reply->category[d.seq].reports[
    rcnt].baseline_value = v1.mpage_param_value, reply->category[d.seq].reports[rcnt].target_value =
    v2.mpage_param_value
   DETAIL
    IF (l.long_text > " ")
     tcnt = (tcnt+ 1), stat = alterlist(reply->category[d.seq].reports[rcnt].text,tcnt), reply->
     category[d.seq].reports[rcnt].text[tcnt].text_type_mean = t.text_type_mean,
     reply->category[d.seq].reports[rcnt].text[tcnt].text = l.long_text, reply->category[d.seq].
     reports[rcnt].text[tcnt].text_seq = t.text_seq
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ccnt)),
    br_datamart_report r,
    br_datamart_text t,
    br_long_text l
   PLAN (d)
    JOIN (r
    WHERE (r.br_datamart_category_id=reply->category[d.seq].br_datamart_category_id))
    JOIN (t
    WHERE t.br_datamart_report_id=outerjoin(r.br_datamart_report_id))
    JOIN (l
    WHERE l.parent_entity_name=outerjoin("BR_DATAMART_TEXT")
     AND l.parent_entity_id=outerjoin(t.br_datamart_text_id))
   ORDER BY d.seq, r.report_seq
   HEAD d.seq
    rcnt = 0
   HEAD r.report_seq
    tcnt = 0, rcnt = (rcnt+ 1), stat = alterlist(reply->category[d.seq].reports,rcnt),
    reply->category[d.seq].reports[rcnt].br_datamart_report_id = r.br_datamart_report_id, reply->
    category[d.seq].reports[rcnt].report_name = r.report_name, reply->category[d.seq].reports[rcnt].
    report_mean = r.report_mean,
    reply->category[d.seq].reports[rcnt].report_seq = r.report_seq, reply->category[d.seq].reports[
    rcnt].baseline_value = r.baseline_value, reply->category[d.seq].reports[rcnt].target_value = r
    .target_value
   DETAIL
    IF (l.long_text > " ")
     tcnt = (tcnt+ 1), stat = alterlist(reply->category[d.seq].reports[rcnt].text,tcnt), reply->
     category[d.seq].reports[rcnt].text[tcnt].text_type_mean = t.text_type_mean,
     reply->category[d.seq].reports[rcnt].text[tcnt].text = l.long_text, reply->category[d.seq].
     reports[rcnt].text[tcnt].text_seq = t.text_seq
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

CREATE PROGRAM bed_get_dmart_reports_by_flex:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 reports[*]
      2 br_datamart_report_id = f8
      2 report_name = vc
      2 report_mean = vc
      2 report_seq = i4
      2 text[*]
        3 text_type_mean = vc
        3 text = vc
        3 text_seq = i4
      2 baseline_value = vc
      2 target_value = vc
      2 mpage_pos_flag = i2
      2 mpage_pos_seq = i4
      2 selected_ind = i2
      2 cond_report_mean = vc
      2 mpage_default_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE br_datamart_value_field_found = i2
 DECLARE prsnl_field_found = i2
 DECLARE data_partition_ind = i2
 DECLARE ccnt = i4
 DECLARE tcnt = i4
 DECLARE rcnt = i4
 DECLARE dcnt = i4
 DECLARE micro_ind = i2
 DECLARE lh_base_target_upd = i2
 DECLARE category_type_flag = i4
 SET reply->status_data.status = "F"
 DECLARE bparse = vc
 DECLARE v1parse = vc
 DECLARE v2parse = vc
 SET bparse = "b.end_effective_dt_tm > cnvtdatetime(curdate,curtime)"
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
  SET bparse = build2(bparse," and b.logical_domain_id = ",acm_get_curr_logical_domain_rep->
   logical_domain_id)
  SET v1parse = build2(v1parse," and v1.logical_domain_id = outerjoin(",
   acm_get_curr_logical_domain_rep->logical_domain_id,")")
  SET v2parse = build2(v2parse," and v2.logical_domain_id = outerjoin(",
   acm_get_curr_logical_domain_rep->logical_domain_id,")")
 ENDIF
 SET ccnt = 0
 SET tcnt = 0
 SET rcnt = 0
 SET dcnt = 0
 SET micro_ind = 0
 SELECT INTO "nl:"
  FROM br_name_value b
  PLAN (b
   WHERE b.br_nv_key1="SOLUTION_STATUS"
    AND b.br_name IN ("LIVE_IN_PROD", "GOING_LIVE")
    AND b.br_value="PATHMICRO")
  DETAIL
   micro_ind = 1
  WITH nocounter
 ;end select
 SET lh_base_target_upd = 0
 SELECT INTO "nl:"
  FROM br_name_value b
  WHERE b.br_nv_key1="LH_BASE_TARGET_UPD"
  DETAIL
   lh_base_target_upd = 1
  WITH nocounter
 ;end select
 SET category_type_flag = 0
 SELECT INTO "nl:"
  FROM br_datamart_category bdc
  WHERE (bdc.br_datamart_category_id=request->br_datamart_category_id)
  DETAIL
   category_type_flag = bdc.category_type_flag
  WITH nocounter
 ;end select
 CALL echo("category_type_flag")
 CALL echo(category_type_flag)
 SET rcnt = 0
 IF (((lh_base_target_upd=1) OR (category_type_flag=4)) )
  SELECT INTO "nl:"
   FROM br_datamart_report r,
    br_datamart_text t,
    br_datamart_value v1,
    br_datamart_value v2,
    br_long_text l
   PLAN (r
    WHERE (r.br_datamart_category_id=request->br_datamart_category_id))
    JOIN (t
    WHERE t.br_datamart_report_id=outerjoin(r.br_datamart_report_id))
    JOIN (v1
    WHERE v1.br_datamart_category_id=outerjoin(r.br_datamart_category_id)
     AND parser(v1parse)
     AND v1.parent_entity_name=outerjoin("BR_DATAMART_REPORT")
     AND v1.parent_entity_id=outerjoin(r.br_datamart_report_id)
     AND v1.mpage_param_mean=outerjoin("baseline"))
    JOIN (v2
    WHERE v2.br_datamart_category_id=outerjoin(r.br_datamart_category_id)
     AND parser(v2parse)
     AND v2.parent_entity_name=outerjoin("BR_DATAMART_REPORT")
     AND v2.parent_entity_id=outerjoin(r.br_datamart_report_id)
     AND v2.mpage_param_mean=outerjoin("target"))
    JOIN (l
    WHERE l.parent_entity_name=outerjoin("BR_DATAMART_TEXT")
     AND l.parent_entity_id=outerjoin(t.br_datamart_text_id))
   ORDER BY r.report_seq
   HEAD r.report_seq
    tcnt = 0, add_ind = 0
    IF (category_type_flag=1)
     IF (r.report_mean IN ("MP*MICRO_PATHNET", "MP*MICRO"))
      IF (r.report_mean="MP*MICRO_PATHNET"
       AND micro_ind=1)
       add_ind = 1
      ELSEIF (r.report_mean="MP*MICRO"
       AND micro_ind=0)
       add_ind = 1
      ENDIF
     ELSE
      add_ind = 1
     ENDIF
    ELSE
     add_ind = 1
    ENDIF
    IF (add_ind=1)
     rcnt = (rcnt+ 1), stat = alterlist(reply->reports,rcnt), reply->reports[rcnt].
     br_datamart_report_id = r.br_datamart_report_id,
     reply->reports[rcnt].report_name = r.report_name, reply->reports[rcnt].report_mean = r
     .report_mean, reply->reports[rcnt].report_seq = r.report_seq,
     reply->reports[rcnt].baseline_value = v1.mpage_param_value, reply->reports[rcnt].target_value =
     v2.mpage_param_value, reply->reports[rcnt].mpage_pos_flag = r.mpage_pos_flag
     IF (r.mpage_pos_flag=3)
      reply->reports[rcnt].selected_ind = 1
     ENDIF
     reply->reports[rcnt].mpage_pos_seq = r.mpage_pos_seq, reply->reports[rcnt].cond_report_mean = r
     .cond_report_mean, reply->reports[rcnt].mpage_default_ind = r.mpage_default_ind
    ENDIF
   DETAIL
    IF (add_ind=1)
     IF (l.long_text > " ")
      tcnt = (tcnt+ 1), stat = alterlist(reply->reports[rcnt].text,tcnt), reply->reports[rcnt].text[
      tcnt].text_type_mean = t.text_type_mean,
      reply->reports[rcnt].text[tcnt].text = l.long_text, reply->reports[rcnt].text[tcnt].text_seq =
      t.text_seq
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM br_datamart_report r,
    br_datamart_text t,
    br_long_text l
   PLAN (r
    WHERE (r.br_datamart_category_id=request->br_datamart_category_id))
    JOIN (t
    WHERE t.br_datamart_report_id=outerjoin(r.br_datamart_report_id))
    JOIN (l
    WHERE l.parent_entity_name=outerjoin("BR_DATAMART_TEXT")
     AND l.parent_entity_id=outerjoin(t.br_datamart_text_id))
   ORDER BY r.report_seq
   HEAD r.report_seq
    tcnt = 0, add_ind = 0
    IF (category_type_flag=1)
     IF (r.report_mean IN ("MP*MICRO_PATHNET", "MP*MICRO"))
      IF (r.report_mean="MP*MICRO_PATHNET"
       AND micro_ind=1)
       add_ind = 1
      ELSEIF (r.report_mean="MP*MICRO"
       AND micro_ind=0)
       add_ind = 1
      ENDIF
     ELSE
      add_ind = 1
     ENDIF
    ELSE
     add_ind = 1
    ENDIF
    IF (add_ind=1)
     rcnt = (rcnt+ 1), stat = alterlist(reply->reports,rcnt), reply->reports[rcnt].
     br_datamart_report_id = r.br_datamart_report_id,
     reply->reports[rcnt].report_name = r.report_name, reply->reports[rcnt].report_mean = r
     .report_mean, reply->reports[rcnt].report_seq = r.report_seq,
     reply->reports[rcnt].baseline_value = r.baseline_value, reply->reports[rcnt].target_value = r
     .target_value, reply->reports[rcnt].mpage_pos_flag = r.mpage_pos_flag
     IF (r.mpage_pos_flag=3)
      reply->reports[rcnt].selected_ind = 1
     ENDIF
     reply->reports[rcnt].mpage_pos_seq = r.mpage_pos_seq, reply->reports[rcnt].cond_report_mean = r
     .cond_report_mean, reply->reports[rcnt].mpage_default_ind = r.mpage_default_ind
    ENDIF
   DETAIL
    IF (add_ind=1)
     IF (l.long_text > " ")
      tcnt = (tcnt+ 1), stat = alterlist(reply->reports[rcnt].text,tcnt), reply->reports[rcnt].text[
      tcnt].text_type_mean = t.text_type_mean,
      reply->reports[rcnt].text[tcnt].text = l.long_text, reply->reports[rcnt].text[tcnt].text_seq =
      t.text_seq
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (category_type_flag=1
  AND (request->br_def_layout_ind=0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(reply->reports,5))),
    br_datamart_value b
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_category_id=request->br_datamart_category_id)
     AND b.parent_entity_name="BR_DATAMART_REPORT"
     AND (b.parent_entity_id=reply->reports[d.seq].br_datamart_report_id)
     AND (b.br_datamart_flex_id=request->flex_id)
     AND parser(bparse))
   ORDER BY d.seq
   HEAD d.seq
    reply->reports[d.seq].mpage_pos_flag = b.value_type_flag, reply->reports[d.seq].mpage_pos_seq = b
    .value_seq, reply->reports[d.seq].selected_ind = 1
   WITH nocounter
  ;end select
  IF (value(size(reply->reports,5))=1)
   SET reply->reports[0].selected_ind = 1
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

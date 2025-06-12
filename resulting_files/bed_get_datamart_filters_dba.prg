CREATE PROGRAM bed_get_datamart_filters:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 filter[*]
      2 br_datamart_filter_id = f8
      2 filter_mean = vc
      2 filter_display = vc
      2 filter_seq = i4
      2 denominator_ind = i2
      2 numerator_ind = i2
      2 filter_category_mean = vc
      2 text[*]
        3 text_type_mean = vc
        3 text = vc
        3 text_seq = i4
      2 defined_ind = i2
      2 mpage_label_ind = i2
      2 mpage_nbr_label_ind = i2
      2 mpage_link_ind = i2
      2 mpage_exp_collapse_ind = i2
      2 mpage_lookback_ind = i2
      2 mpage_max_results_ind = i2
      2 mpage_scroll_ind = i2
      2 mpage_truncate_ind = i2
      2 mpage_add_label_ind = i2
      2 filter_category_type_mean = vc
      2 codeset = i4
      2 filter_limit = i4
      2 mpage_date_format_ind = i2
      2 value_set_id = f8
      2 secondary_value_set_id = f8
      2 script_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET event_cds
 RECORD event_cds(
   1 events[*]
     2 event_set_cd = f8
     2 value_id = f8
 )
 FREE SET delete_hist
 RECORD delete_hist(
   1 deleted_items[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
 )
 DECLARE delete_hist_cnt = i4 WITH noconstant(0), protect
 DECLARE script_name_field_exists = i2 WITH noconstant(0), protect
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET script_name_field_exists = validate(reply->filter[1].script_name)
 DECLARE vparse = vc
 SET vparse = "v.end_effective_dt_tm > cnvtdatetime(curdate,curtime)"
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
  SET vparse = build2(vparse," and v.logical_domain_id = ",acm_get_curr_logical_domain_rep->
   logical_domain_id)
 ENDIF
 SET fcnt = 0
 SET tcnt = 0
 IF ((request->br_datamart_report_id > 0))
  SELECT INTO "nl:"
   FROM br_datamart_report_filter_r r,
    br_datamart_report dr,
    br_datamart_filter f,
    br_datamart_text t,
    br_long_text l
   PLAN (r
    WHERE (r.br_datamart_report_id=request->br_datamart_report_id))
    JOIN (dr
    WHERE dr.br_datamart_report_id=r.br_datamart_report_id)
    JOIN (f
    WHERE f.br_datamart_filter_id=r.br_datamart_filter_id)
    JOIN (t
    WHERE t.br_datamart_filter_id=outerjoin(f.br_datamart_filter_id))
    JOIN (l
    WHERE l.parent_entity_name=outerjoin("BR_DATAMART_TEXT")
     AND l.parent_entity_id=outerjoin(t.br_datamart_text_id))
   ORDER BY f.filter_seq, f.br_datamart_filter_id
   HEAD f.br_datamart_filter_id
    tcnt = 0, fcnt = (fcnt+ 1), stat = alterlist(reply->filter,fcnt),
    reply->filter[fcnt].br_datamart_filter_id = f.br_datamart_filter_id, reply->filter[fcnt].
    filter_display = f.filter_display, reply->filter[fcnt].filter_mean = f.filter_mean,
    reply->filter[fcnt].filter_seq = f.filter_seq, reply->filter[fcnt].denominator_ind = r
    .denominator_ind, reply->filter[fcnt].numerator_ind = r.numerator_ind,
    reply->filter[fcnt].filter_category_mean = f.filter_category_mean, reply->filter[fcnt].
    filter_limit = f.filter_limit, reply->filter[fcnt].value_set_id = f.expected_action_value_set_id,
    reply->filter[fcnt].secondary_value_set_id = f.inaction_reason_value_set_id, reply->filter[fcnt].
    mpage_date_format_ind = dr.mpage_date_format_ind, reply->filter[fcnt].mpage_label_ind = dr
    .mpage_label_ind,
    reply->filter[fcnt].mpage_nbr_label_ind = dr.mpage_nbr_label_ind, reply->filter[fcnt].
    mpage_link_ind = dr.mpage_link_ind, reply->filter[fcnt].mpage_exp_collapse_ind = dr
    .mpage_exp_collapse_ind,
    reply->filter[fcnt].mpage_lookback_ind = dr.mpage_lookback_ind, reply->filter[fcnt].
    mpage_max_results_ind = dr.mpage_max_results_ind, reply->filter[fcnt].mpage_scroll_ind = dr
    .mpage_scroll_ind,
    reply->filter[fcnt].mpage_truncate_ind = dr.mpage_truncate_ind, reply->filter[fcnt].
    mpage_add_label_ind = dr.mpage_add_label_ind
   HEAD t.br_datamart_text_id
    IF (l.long_text > " ")
     tcnt = (tcnt+ 1), stat = alterlist(reply->filter[fcnt].text,tcnt), reply->filter[fcnt].text[tcnt
     ].text_type_mean = t.text_type_mean,
     reply->filter[fcnt].text[tcnt].text = l.long_text, reply->filter[fcnt].text[tcnt].text_seq = t
     .text_seq
    ENDIF
   WITH nocounter
  ;end select
  IF (fcnt=0)
   GO TO exit_script
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM br_datamart_filter f,
    br_datamart_report_filter_r r,
    br_datamart_report dr,
    br_datamart_text t,
    br_long_text l
   PLAN (f
    WHERE (f.br_datamart_category_id=request->br_datamart_category_id))
    JOIN (r
    WHERE r.br_datamart_filter_id=f.br_datamart_filter_id)
    JOIN (dr
    WHERE dr.br_datamart_report_id=r.br_datamart_report_id)
    JOIN (t
    WHERE t.br_datamart_filter_id=outerjoin(f.br_datamart_filter_id))
    JOIN (l
    WHERE l.parent_entity_name=outerjoin("BR_DATAMART_TEXT")
     AND l.parent_entity_id=outerjoin(t.br_datamart_text_id))
   ORDER BY f.filter_seq, f.br_datamart_filter_id
   HEAD f.br_datamart_filter_id
    tcnt = 0, fcnt = (fcnt+ 1), stat = alterlist(reply->filter,fcnt),
    reply->filter[fcnt].br_datamart_filter_id = f.br_datamart_filter_id, reply->filter[fcnt].
    filter_display = f.filter_display, reply->filter[fcnt].filter_mean = f.filter_mean,
    reply->filter[fcnt].filter_seq = f.filter_seq, reply->filter[fcnt].denominator_ind = r
    .denominator_ind, reply->filter[fcnt].numerator_ind = r.numerator_ind,
    reply->filter[fcnt].filter_category_mean = f.filter_category_mean, reply->filter[fcnt].
    filter_limit = f.filter_limit, reply->filter[fcnt].value_set_id = f.expected_action_value_set_id,
    reply->filter[fcnt].secondary_value_set_id = f.inaction_reason_value_set_id, reply->filter[fcnt].
    mpage_date_format_ind = dr.mpage_date_format_ind, reply->filter[fcnt].mpage_label_ind = dr
    .mpage_label_ind,
    reply->filter[fcnt].mpage_nbr_label_ind = dr.mpage_nbr_label_ind, reply->filter[fcnt].
    mpage_link_ind = dr.mpage_link_ind, reply->filter[fcnt].mpage_exp_collapse_ind = dr
    .mpage_exp_collapse_ind,
    reply->filter[fcnt].mpage_lookback_ind = dr.mpage_lookback_ind, reply->filter[fcnt].
    mpage_max_results_ind = dr.mpage_max_results_ind, reply->filter[fcnt].mpage_scroll_ind = dr
    .mpage_scroll_ind,
    reply->filter[fcnt].mpage_truncate_ind = dr.mpage_truncate_ind, reply->filter[fcnt].
    mpage_add_label_ind = dr.mpage_add_label_ind
   HEAD t.br_datamart_text_id
    IF (l.long_text > " ")
     tcnt = (tcnt+ 1), stat = alterlist(reply->filter[fcnt].text,tcnt), reply->filter[fcnt].text[tcnt
     ].text_type_mean = t.text_type_mean,
     reply->filter[fcnt].text[tcnt].text = l.long_text, reply->filter[fcnt].text[tcnt].text_seq = t
     .text_seq
    ENDIF
   WITH nocounter
  ;end select
  IF (fcnt=0)
   GO TO exit_script
  ENDIF
 ENDIF
 SET event_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(fcnt)),
   br_datamart_value v,
   br_datamart_filter f
  PLAN (d)
   JOIN (v
   WHERE (v.br_datamart_category_id=request->br_datamart_category_id)
    AND (v.br_datamart_filter_id=reply->filter[d.seq].br_datamart_filter_id)
    AND parser(vparse))
   JOIN (f
   WHERE f.br_datamart_filter_id=v.br_datamart_filter_id
    AND f.filter_category_mean IN ("EVENT_SET", "PRIM_EVENT_SET", "EVENT_SET_SEQ"))
  ORDER BY d.seq
  DETAIL
   event_cnt = (event_cnt+ 1), stat = alterlist(event_cds->events,event_cnt), event_cds->events[
   event_cnt].event_set_cd = v.parent_entity_id,
   event_cds->events[event_cnt].value_id = v.br_datamart_value_id
  WITH nocounter
 ;end select
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE pos = i4 WITH noconstant(0), protect
 IF (event_cnt > 0)
  SELECT INTO "nl:"
   FROM br_datamart_value v
   PLAN (v
    WHERE expand(idx,1,size(event_cds->events,5),v.br_datamart_value_id,event_cds->events[idx].
     value_id)
     AND v.parent_entity_name="CODE_VALUE"
     AND  NOT ( EXISTS (
    (SELECT
     c.code_value
     FROM code_value c
     WHERE c.code_value=v.parent_entity_id))))
   ORDER BY v.br_datamart_value_id
   HEAD REPORT
    delete_hist_cnt = 0, stat = alterlist(delete_hist->deleted_items,100)
   HEAD v.br_datamart_value_id
    delete_hist_cnt = (delete_hist_cnt+ 1)
    IF (mod(delete_hist_cnt,100)=1
     AND delete_hist_cnt > 100)
     stat = alterlist(delete_hist->deleted_items,(delete_hist_cnt+ 99))
    ENDIF
   DETAIL
    delete_hist->deleted_items[delete_hist_cnt].parent_entity_id = v.br_datamart_value_id,
    delete_hist->deleted_items[delete_hist_cnt].parent_entity_name = "BR_DATAMART_VALUE"
   FOOT REPORT
    stat = alterlist(delete_hist->deleted_items,delete_hist_cnt)
   WITH nocounter, expand = 1
  ;end select
  CALL echorecord(delete_hist)
  SET ierrcode = 0
  DELETE  FROM (dummyt d  WITH seq = value(event_cnt)),
    br_datamart_value v
   SET v.seq = 1
   PLAN (d)
    JOIN (v
    WHERE (v.br_datamart_value_id=event_cds->events[d.seq].value_id)
     AND v.parent_entity_name="CODE_VALUE"
     AND  NOT ( EXISTS (
    (SELECT
     c.code_value
     FROM code_value c
     WHERE c.code_value=v.parent_entity_id))))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error on br_data_mart_value delete")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (delete_hist_cnt > 0)
  EXECUTE bed_ens_del_hist_rows  WITH replace("REQUEST",delete_hist)
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(fcnt)),
   br_datamart_value v
  PLAN (d)
   JOIN (v
   WHERE (v.br_datamart_category_id=request->br_datamart_category_id)
    AND (v.br_datamart_filter_id=reply->filter[d.seq].br_datamart_filter_id)
    AND (v.br_datamart_flex_id=request->flex_id)
    AND parser(vparse))
  ORDER BY d.seq
  HEAD d.seq
   reply->filter[d.seq].defined_ind = 1
  WITH nocounter
 ;end select
 IF (fcnt > 0)
  IF (script_name_field_exists=1)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(fcnt)),
     br_datamart_filter_category b
    PLAN (d)
     JOIN (b
     WHERE (b.filter_category_mean=reply->filter[d.seq].filter_category_mean))
    ORDER BY d.seq
    HEAD d.seq
     reply->filter[d.seq].filter_category_type_mean = b.filter_category_type_mean, reply->filter[d
     .seq].codeset = b.codeset, reply->filter[d.seq].script_name =
     IF (b.script_name=null) " "
     ELSE b.script_name
     ENDIF
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(fcnt)),
     br_datamart_filter_category b
    PLAN (d)
     JOIN (b
     WHERE (b.filter_category_mean=reply->filter[d.seq].filter_category_mean))
    ORDER BY d.seq
    HEAD d.seq
     reply->filter[d.seq].filter_category_type_mean = b.filter_category_type_mean, reply->filter[d
     .seq].codeset = b.codeset
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO

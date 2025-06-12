CREATE PROGRAM bed_get_datamart_cat_reports:dba
 IF ( NOT (validate(reply,0)))
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
        3 mpage_pos_flag = i2
        3 mpage_pos_seq = i4
        3 selected_ind = i2
        3 cond_report_mean = vc
        3 mpage_default_ind = i2
        3 layout_flags[*]
          4 layout_flag = i2
      2 cat_baseline_value = vc
      2 cat_target_value = vc
      2 flex_flag = i2
      2 rel_score_ind = i2
      2 base_target_ind = i2
      2 layout_flag = i2
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
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 SET reply->status_data.status = "F"
 DECLARE populateparsestringbasedonrequest(dummyvar=i2) = null
 DECLARE bparse = vc
 DECLARE v1parse = vc
 DECLARE v2parse = vc
 DECLARE reply_size = i4
 DECLARE cat_parse = vc WITH protect, noconstant("c.br_datamart_category_id > 0.0")
 SET bparse = "b.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)"
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
 IF (validate(request->search_text,"") > " ")
  CALL populateparsestringbasedonrequest(0)
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
 CALL bederrorcheck("micro_ind setting error")
 SELECT INTO "nl:"
  FROM br_datamart_category c,
   br_datamart_text t,
   br_long_text l
  PLAN (c
   WHERE parser(cat_parse)
    AND (c.category_type_flag=request->category_type_flag)
    AND  NOT (c.category_name IN ("", " ", null)))
   JOIN (t
   WHERE t.br_datamart_category_id=outerjoin(c.br_datamart_category_id)
    AND t.br_datamart_report_id=outerjoin(0)
    AND t.br_datamart_filter_id=outerjoin(0))
   JOIN (l
   WHERE l.parent_entity_name=outerjoin("BR_DATAMART_TEXT")
    AND l.parent_entity_id=outerjoin(t.br_datamart_text_id))
  ORDER BY cnvtupper(c.category_name)
  HEAD c.category_name
   tcnt = 0, ccnt = (ccnt+ 1), stat = alterlist(reply->category,ccnt),
   reply->category[ccnt].br_datamart_category_id = c.br_datamart_category_id, reply->category[ccnt].
   category_name = c.category_name, reply->category[ccnt].category_mean = c.category_mean,
   reply->category[ccnt].flex_flag = c.flex_flag, reply->category[ccnt].base_target_ind = c
   .baseline_target_ind, reply->category[ccnt].rel_score_ind = c.reliability_score_ind,
   reply->category[ccnt].layout_flag = c.layout_flag
  DETAIL
   IF (l.long_text > " ")
    tcnt = (tcnt+ 1), stat = alterlist(reply->category[ccnt].text,tcnt), reply->category[ccnt].text[
    tcnt].text_type_mean = t.text_type_mean,
    reply->category[ccnt].text[tcnt].text = l.long_text, reply->category[ccnt].text[tcnt].text_seq =
    t.text_seq
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("category retrieval error")
 IF (ccnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(ccnt)),
   br_datamart_value b
  PLAN (d)
   JOIN (b
   WHERE (b.br_datamart_category_id=reply->category[d.seq].br_datamart_category_id)
    AND b.br_datamart_filter_id IN (0, null)
    AND (b.parent_entity_id=reply->category[d.seq].br_datamart_category_id)
    AND b.parent_entity_name="BR_DATAMART_CATEGORY"
    AND cnvtupper(b.mpage_param_mean) IN ("BASELINE", "TARGET")
    AND parser(bparse))
  ORDER BY d.seq
  DETAIL
   IF (cnvtupper(b.mpage_param_mean)="BASELINE")
    reply->category[d.seq].cat_baseline_value = b.mpage_param_value
   ELSEIF (cnvtupper(b.mpage_param_mean)="TARGET")
    reply->category[d.seq].cat_target_value = b.mpage_param_value
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("datamart value retrieval error")
 SET lh_base_target_upd = 0
 SELECT INTO "nl:"
  FROM br_name_value b
  WHERE b.br_nv_key1="LH_BASE_TARGET_UPD"
  DETAIL
   lh_base_target_upd = 1
  WITH nocounter
 ;end select
 CALL bederrorcheck("lh_base_target_upd setting error")
 IF (((lh_base_target_upd=1) OR ((request->category_type_flag=4))) )
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
   ORDER BY d.seq, r.report_seq
   HEAD d.seq
    rcnt = 0
   HEAD r.report_seq
    tcnt = 0, add_ind = 0
    IF ((((request->category_type_flag=1)) OR ((request->category_type_flag=5))) )
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
     rcnt = (rcnt+ 1), stat = alterlist(reply->category[d.seq].reports,rcnt), reply->category[d.seq].
     reports[rcnt].br_datamart_report_id = r.br_datamart_report_id,
     reply->category[d.seq].reports[rcnt].report_name = r.report_name, reply->category[d.seq].
     reports[rcnt].report_mean = r.report_mean, reply->category[d.seq].reports[rcnt].report_seq = r
     .report_seq,
     reply->category[d.seq].reports[rcnt].baseline_value = v1.mpage_param_value, reply->category[d
     .seq].reports[rcnt].target_value = v2.mpage_param_value, reply->category[d.seq].reports[rcnt].
     mpage_pos_flag = r.mpage_pos_flag,
     reply->category[d.seq].reports[rcnt].mpage_pos_seq = r.mpage_pos_seq, reply->category[d.seq].
     reports[rcnt].cond_report_mean = r.cond_report_mean, reply->category[d.seq].reports[rcnt].
     mpage_default_ind = r.mpage_default_ind,
     stat = alterlist(reply->category[d.seq].reports[rcnt].layout_flags,1), reply->category[d.seq].
     reports[rcnt].layout_flags[1].layout_flag = 0
    ENDIF
   DETAIL
    IF (add_ind=1)
     IF (l.long_text > " ")
      tcnt = (tcnt+ 1), stat = alterlist(reply->category[d.seq].reports[rcnt].text,tcnt), reply->
      category[d.seq].reports[rcnt].text[tcnt].text_type_mean = t.text_type_mean,
      reply->category[d.seq].reports[rcnt].text[tcnt].text = l.long_text, reply->category[d.seq].
      reports[rcnt].text[tcnt].text_seq = t.text_seq
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  CALL bederrorcheck("type 4 report info retrieval error")
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
    tcnt = 0, add_ind = 0
    IF ((((request->category_type_flag=1)) OR ((request->category_type_flag=5))) )
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
     rcnt = (rcnt+ 1), stat = alterlist(reply->category[d.seq].reports,rcnt), reply->category[d.seq].
     reports[rcnt].br_datamart_report_id = r.br_datamart_report_id,
     reply->category[d.seq].reports[rcnt].report_name = r.report_name, reply->category[d.seq].
     reports[rcnt].report_mean = r.report_mean, reply->category[d.seq].reports[rcnt].report_seq = r
     .report_seq,
     reply->category[d.seq].reports[rcnt].baseline_value = r.baseline_value, reply->category[d.seq].
     reports[rcnt].target_value = r.target_value, reply->category[d.seq].reports[rcnt].mpage_pos_flag
      = r.mpage_pos_flag,
     reply->category[d.seq].reports[rcnt].mpage_pos_seq = r.mpage_pos_seq, reply->category[d.seq].
     reports[rcnt].cond_report_mean = r.cond_report_mean, reply->category[d.seq].reports[rcnt].
     mpage_default_ind = r.mpage_default_ind,
     stat = alterlist(reply->category[d.seq].reports[rcnt].layout_flags,1), reply->category[d.seq].
     reports[rcnt].layout_flags[1].layout_flag = 0
    ENDIF
   DETAIL
    IF (add_ind=1)
     IF (l.long_text > " ")
      tcnt = (tcnt+ 1), stat = alterlist(reply->category[d.seq].reports[rcnt].text,tcnt), reply->
      category[d.seq].reports[rcnt].text[tcnt].text_type_mean = t.text_type_mean,
      reply->category[d.seq].reports[rcnt].text[tcnt].text = l.long_text, reply->category[d.seq].
      reports[rcnt].text[tcnt].text_seq = t.text_seq
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  CALL bederrorcheck("other report info retrieval error")
 ENDIF
 IF ((((request->category_type_flag=1)) OR ((request->category_type_flag=5))) )
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(reply->category,5))),
    (dummyt d2  WITH seq = 1),
    br_datamart_value b
   PLAN (d
    WHERE maxrec(d2,size(reply->category[d.seq].reports,5)))
    JOIN (d2)
    JOIN (b
    WHERE (b.br_datamart_category_id=reply->category[d.seq].br_datamart_category_id)
     AND b.parent_entity_name="BR_DATAMART_REPORT"
     AND (b.parent_entity_id=reply->category[d.seq].reports[d2.seq].br_datamart_report_id)
     AND b.br_datamart_flex_id=0
     AND ((cnvtupper(b.mpage_param_mean) != "MP_VB_COMPONENT_STATUS") OR (b.mpage_param_mean=null))
     AND parser(bparse))
   ORDER BY d.seq, d2.seq
   HEAD d.seq
    dummy_value = 1
   HEAD d2.seq
    reply->category[d.seq].reports[d2.seq].mpage_pos_flag = b.value_type_flag, reply->category[d.seq]
    .reports[d2.seq].mpage_pos_seq = b.value_seq, reply->category[d.seq].reports[d2.seq].selected_ind
     = 1
   WITH nocounter
  ;end select
  CALL bederrorcheck("Selected reports retrieval error")
 ENDIF
 SET reply_size = size(reply->category,5)
 IF (reply_size > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(reply_size)),
    (dummyt d2  WITH seq = 1),
    br_datam_report_layout l
   PLAN (d
    WHERE maxrec(d2,size(reply->category[d.seq].reports,5)))
    JOIN (d2)
    JOIN (l
    WHERE (l.br_datamart_report_id=reply->category[d.seq].reports[d2.seq].br_datamart_report_id))
   ORDER BY d.seq, d2.seq, l.br_datamart_report_id
   HEAD d.seq
    dummy_val = 0
   HEAD d2.seq
    layout_flags_count = 0
   HEAD l.br_datamart_report_id
    stat = alterlist(reply->category[d.seq].reports[d2.seq].layout_flags,0)
   DETAIL
    layout_flags_count = (layout_flags_count+ 1), stat = alterlist(reply->category[d.seq].reports[d2
     .seq].layout_flags,layout_flags_count), reply->category[d.seq].reports[d2.seq].layout_flags[
    layout_flags_count].layout_flag = l.layout_flag
   WITH nocounter
  ;end select
  CALL bederrorcheck("report layout retrieval error")
 ENDIF
 SUBROUTINE populateparsestringbasedonrequest(dummyvar)
   IF (validate(request->search_text,"") > " ")
    IF ((request->search_type IN ("S", "s"))
     AND (request->search_text > " "))
     SET cat_parse = concat(cat_parse," and cnvtupper(c.category_name) = '",cnvtupper(trim(request->
        search_text)),"*'")
    ELSEIF ((request->search_type IN ("C", "c"))
     AND (request->search_text > " "))
     SET cat_parse = concat(cat_parse," and cnvtupper(c.category_name) = '*",cnvtupper(trim(request->
        search_text)),"*'")
    ENDIF
   ENDIF
 END ;Subroutine
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO

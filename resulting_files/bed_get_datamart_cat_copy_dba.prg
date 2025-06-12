CREATE PROGRAM bed_get_datamart_cat_copy:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 categories[*]
      2 id = f8
      2 name = vc
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
 DECLARE filtercnt = i4 WITH protect, noconstant(0)
 DECLARE cat_type_flag = i2 WITH protect, noconstant(0)
 DECLARE getallfilters(null) = i4 WITH protect
 DECLARE getfiltersforreport(null) = i4 WITH protect
 DECLARE geteligiblevalues(null) = null WITH protect
 DECLARE geteligiblenonmapvalues(null) = i4 WITH protect
 DECLARE geteligiblemapvalues(rcnt=i4) = null WITH protect
 DECLARE vparse = vc
 SET vparse = "v.br_datamart_filter_id = f.br_datamart_filter_id"
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
 RECORD temp(
   1 filters[*]
     2 mean = vc
     2 cat_mean = vc
     2 prim_val_set_id = f8
     2 sec_val_set_id = f8
     2 has_new_layout_ind = i2
     2 br_datamart_filter_id = f8
     2 map_types[*]
       3 map_type_data_cd = f8
 )
 RECORD itemstomatchnegation(
   1 values[*]
     2 value_id = f8
 )
 RECORD negatedvalues(
   1 values[*]
     2 source_id = vc
     2 source_mean = vc
     2 category_id = f8
     2 category_name = vc
 )
 IF ((request->report_id=0))
  SET filtercnt = getallfilters(null)
 ELSE
  SET filtercnt = getfiltersforreport(null)
 ENDIF
 IF (filtercnt=0)
  GO TO exit_script
 ENDIF
 CALL geteligiblevalues(null)
 SUBROUTINE getallfilters(null)
   DECLARE fcnt = i4 WITH protect, noconstant(0)
   DECLARE mapping_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_datamart_category c,
     br_datamart_filter f,
     br_datamart_filter_category fc
    PLAN (c
     WHERE (c.br_datamart_category_id=request->category_id))
     JOIN (f
     WHERE f.br_datamart_category_id=c.br_datamart_category_id)
     JOIN (fc
     WHERE fc.filter_category_mean=outerjoin(f.filter_category_mean))
    ORDER BY c.br_datamart_category_id, f.br_datamart_filter_id
    HEAD c.br_datamart_category_id
     cat_type_flag = c.category_type_flag
    HEAD f.br_datamart_filter_id
     fcnt = (fcnt+ 1), stat = alterlist(temp->filters,fcnt), temp->filters[fcnt].mean = f.filter_mean,
     temp->filters[fcnt].cat_mean = f.filter_category_mean, temp->filters[fcnt].prim_val_set_id = f
     .expected_action_value_set_id, temp->filters[fcnt].sec_val_set_id = f
     .inaction_reason_value_set_id,
     temp->filters[fcnt].br_datamart_filter_id = f.br_datamart_filter_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error getting all filters")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = fcnt),
     br_datamart_report_filter_r r,
     br_datamart_report_default rd
    PLAN (d)
     JOIN (r
     WHERE (r.br_datamart_filter_id=temp->filters[d.seq].br_datamart_filter_id))
     JOIN (rd
     WHERE rd.br_datamart_report_id=r.br_datamart_report_id
      AND rd.mpage_param_mean="MP_LOOK_BACK_CUR_ENC")
    ORDER BY d.seq, r.br_datamart_filter_id, rd.br_datamart_report_id
    DETAIL
     temp->filters[d.seq].has_new_layout_ind = 1
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error getting lookback settings.")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(temp->filters,5))),
     br_datamart_filter_category fc,
     br_datam_mapping_type m
    PLAN (d)
     JOIN (fc
     WHERE (fc.filter_category_mean=temp->filters[d.seq].cat_mean)
      AND fc.filter_category_type_mean="MAP")
     JOIN (m
     WHERE (m.br_datamart_category_id=request->category_id)
      AND m.br_datamart_filter_category_id=fc.br_datamart_filter_category_id)
    ORDER BY d.seq, m.map_data_type_cd
    HEAD d.seq
     mapping_cnt = 0
    HEAD m.map_data_type_cd
     IF (m.map_data_type_cd > 0)
      mapping_cnt = (mapping_cnt+ 1), stat = alterlist(temp->filters[d.seq].map_types,mapping_cnt),
      temp->filters[d.seq].map_types[mapping_cnt].map_type_data_cd = m.map_data_type_cd
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error getting map types")
   RETURN(fcnt)
 END ;Subroutine
 SUBROUTINE getfiltersforreport(null)
   DECLARE fcnt = i4 WITH protect, noconstant(0)
   DECLARE mapping_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_datamart_category c,
     br_datamart_filter f,
     br_datamart_report_filter_r r,
     br_datamart_filter_category fc
    PLAN (c
     WHERE (c.br_datamart_category_id=request->category_id))
     JOIN (f
     WHERE f.br_datamart_category_id=c.br_datamart_category_id)
     JOIN (r
     WHERE r.br_datamart_filter_id=f.br_datamart_filter_id
      AND (r.br_datamart_report_id=request->report_id))
     JOIN (fc
     WHERE fc.filter_category_mean=outerjoin(f.filter_category_mean))
    ORDER BY c.br_datamart_category_id, f.br_datamart_filter_id
    HEAD c.br_datamart_category_id
     cat_type_flag = c.category_type_flag
    HEAD f.br_datamart_filter_id
     fcnt = (fcnt+ 1), stat = alterlist(temp->filters,fcnt), temp->filters[fcnt].mean = f.filter_mean,
     temp->filters[fcnt].cat_mean = f.filter_category_mean, temp->filters[fcnt].prim_val_set_id = f
     .expected_action_value_set_id, temp->filters[fcnt].sec_val_set_id = f
     .inaction_reason_value_set_id,
     temp->filters[fcnt].br_datamart_filter_id = f.br_datamart_filter_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error getting report filters")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = fcnt),
     br_datamart_report_filter_r r,
     br_datamart_report_default rd
    PLAN (d)
     JOIN (r
     WHERE (r.br_datamart_filter_id=temp->filters[d.seq].br_datamart_filter_id))
     JOIN (rd
     WHERE rd.br_datamart_report_id=r.br_datamart_report_id
      AND rd.mpage_param_mean="MP_LOOK_BACK_CUR_ENC")
    ORDER BY d.seq, r.br_datamart_filter_id, rd.br_datamart_report_id
    DETAIL
     temp->filters[d.seq].has_new_layout_ind = 1
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error getting lookback settings.")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(temp->filters,5))),
     br_datamart_filter_category fc,
     br_datam_mapping_type m
    PLAN (d)
     JOIN (fc
     WHERE (fc.filter_category_mean=temp->filters[d.seq].cat_mean)
      AND fc.filter_category_type_mean="MAP")
     JOIN (m
     WHERE (m.br_datamart_category_id=request->category_id)
      AND m.br_datamart_filter_category_id=fc.br_datamart_filter_category_id)
    ORDER BY m.map_data_type_cd
    HEAD m.map_data_type_cd
     IF (m.map_data_type_cd > 0)
      mapping_cnt = (mapping_cnt+ 1), stat = alterlist(temp->filters[d.seq].map_types,mapping_cnt),
      temp->filters[d.seq].map_types[mapping_cnt].map_type_data_cd = m.map_data_type_cd
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error getting map types")
   RETURN(fcnt)
 END ;Subroutine
 SUBROUTINE geteligiblevalues(null)
   DECLARE rcnt = i4 WITH protect, noconstant(0)
   SET rcnt = geteligiblenonmapvalues(null)
   CALL geteligiblemapvalues(rcnt)
 END ;Subroutine
 SUBROUTINE geteligiblenonmapvalues(null)
   DECLARE rcnt = i4 WITH protect, noconstant(0)
   DECLARE catpos = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(temp->filters,5))),
     br_datamart_category c,
     br_datamart_report r,
     br_datamart_report_filter_r rf,
     br_datamart_report_default rd,
     br_datamart_filter f,
     br_datamart_filter_category fc,
     br_datamart_value v
    PLAN (d)
     JOIN (c
     WHERE (c.br_datamart_category_id != request->category_id)
      AND c.category_type_flag=cat_type_flag)
     JOIN (r
     WHERE r.br_datamart_category_id=c.br_datamart_category_id)
     JOIN (rf
     WHERE rf.br_datamart_report_id=r.br_datamart_report_id)
     JOIN (f
     WHERE f.br_datamart_filter_id=rf.br_datamart_filter_id
      AND (f.filter_mean=temp->filters[d.seq].mean)
      AND (f.filter_category_mean=temp->filters[d.seq].cat_mean))
     JOIN (fc
     WHERE fc.filter_category_mean=f.filter_category_mean
      AND fc.filter_category_type_mean != "MAP")
     JOIN (v
     WHERE v.br_datamart_category_id=c.br_datamart_category_id
      AND v.br_datamart_flex_id=0
      AND v.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
      AND parser(vparse))
     JOIN (rd
     WHERE rd.br_datamart_report_id=outerjoin(r.br_datamart_report_id)
      AND rd.mpage_param_mean=outerjoin("MP_LOOK_BACK_CUR_ENC"))
    ORDER BY r.br_datamart_report_id, rd.br_datamart_report_default_id, f.br_datamart_filter_id,
     v.br_datamart_category_id
    HEAD r.br_datamart_report_id
     new_lookback_settings_filter = 0
     IF (rd.br_datamart_report_default_id > 0.0)
      new_lookback_settings_filter = 1
     ENDIF
    HEAD v.br_datamart_category_id
     catpos = locateval(num,1,rcnt,v.br_datamart_category_id,reply->categories[num].id)
     IF (catpos=0
      AND v.br_datamart_category_id > 0
      AND ((f.filter_category_mean != "MP_SECT_PARAMS") OR ((new_lookback_settings_filter=temp->
     filters[d.seq].has_new_layout_ind))) )
      rcnt = (rcnt+ 1), stat = alterlist(reply->categories,rcnt), reply->categories[rcnt].id = c
      .br_datamart_category_id,
      reply->categories[rcnt].name = c.category_name
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error getting non mapped values")
   RETURN(rcnt)
 END ;Subroutine
 SUBROUTINE geteligiblemapvalues(rcnt)
   DECLARE negationcd = f8 WITH protect, noconstant(0)
   DECLARE negationcnt = i4 WITH protect, noconstant(0)
   DECLARE catpos = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=4002871
      AND cv.cdf_meaning="NEGATION"
      AND cv.active_ind=1)
    DETAIL
     negationcd = cv.code_value
    WITH nocounter
   ;end select
   SET vparse = build2(vparse,
    " and v.map_data_type_cd = temp->filters[d.seq].map_types[d2.seq].map_type_data_cd")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(temp->filters,5))),
     (dummyt d2  WITH seq = 1),
     br_datamart_category c,
     br_datamart_filter f,
     br_datamart_filter_category fc,
     br_datamart_value v,
     br_datam_val_set_item vsi,
     br_datam_val_set_item vsi2
    PLAN (d
     WHERE maxrec(d2,size(temp->filters[d.seq].map_types,5)))
     JOIN (d2)
     JOIN (c
     WHERE (c.br_datamart_category_id != request->category_id)
      AND c.category_type_flag=cat_type_flag)
     JOIN (f
     WHERE f.br_datamart_category_id=c.br_datamart_category_id
      AND (f.filter_mean=temp->filters[d.seq].mean))
     JOIN (fc
     WHERE fc.filter_category_mean=f.filter_category_mean
      AND fc.filter_category_type_mean="MAP")
     JOIN (v
     WHERE v.br_datamart_category_id=c.br_datamart_category_id
      AND v.br_datamart_flex_id=0
      AND v.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
      AND parser(vparse))
     JOIN (vsi
     WHERE vsi.br_datam_val_set_item_id=v.parent_entity_id2)
     JOIN (vsi2
     WHERE (((vsi2.br_datam_val_set_id=temp->filters[d.seq].prim_val_set_id)) OR ((vsi2
     .br_datam_val_set_id=temp->filters[d.seq].sec_val_set_id)))
      AND vsi2.source_vocab_mean=vsi.source_vocab_mean
      AND vsi2.source_vocab_item_ident=vsi.source_vocab_item_ident)
    ORDER BY d.seq, v.br_datamart_value_id
    HEAD v.br_datamart_value_id
     num = 0
     IF (v.br_datamart_category_id > 0)
      catpos = locateval(num,1,rcnt,c.br_datamart_category_id,reply->categories[num].id)
      IF ((temp->filters[d.seq].sec_val_set_id > 0)
       AND catpos=0)
       negationcnt = (negationcnt+ 1), stat = alterlist(itemstomatchnegation->values,negationcnt),
       itemstomatchnegation->values[negationcnt].value_id = v.br_datamart_value_id
      ELSEIF ((temp->filters[d.seq].sec_val_set_id=0)
       AND catpos=0)
       rcnt = (rcnt+ 1), stat = alterlist(reply->categories,rcnt), reply->categories[rcnt].id = c
       .br_datamart_category_id,
       reply->categories[rcnt].name = c.category_name
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error getting mapped values")
   IF (negationcnt > 0)
    DECLARE results_size = i4 WITH protect, noconstant(0)
    DECLARE catpos = i4 WITH protect, noconstant(0)
    DECLARE num = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM br_datamart_value v,
      br_datamart_value v2,
      (dummyt d  WITH seq = value(size(itemstomatchnegation->values,5))),
      br_datam_val_set_item vsi,
      br_datamart_category c
     PLAN (d)
      JOIN (v
      WHERE v.br_datamart_flex_id=0
       AND v.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
       AND (v.br_datamart_value_id=itemstomatchnegation->values[d.seq].value_id))
      JOIN (v2
      WHERE v.br_datamart_flex_id=0
       AND v.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
       AND v2.br_datamart_category_id=v.br_datamart_category_id
       AND v2.br_datamart_filter_id=v.br_datamart_filter_id
       AND v2.parent_entity_id=v.parent_entity_id
       AND v2.parent_entity_name=v.parent_entity_name
       AND v2.map_data_type_cd=negationcd)
      JOIN (vsi
      WHERE vsi.br_datam_val_set_item_id=v2.parent_entity_id2)
      JOIN (c
      WHERE c.br_datamart_category_id=v.br_datamart_category_id)
     ORDER BY vsi.br_datam_val_set_item_id
     HEAD vsi.br_datam_val_set_item_id
      results_size = (results_size+ 1), stat = alterlist(negatedvalues->values,results_size),
      negatedvalues->values[results_size].source_id = vsi.source_vocab_item_ident,
      negatedvalues->values[results_size].source_mean = vsi.source_vocab_mean, negatedvalues->values[
      results_size].category_id = v.br_datamart_category_id, negatedvalues->values[results_size].
      category_name = c.category_name
     WITH nocounter
    ;end select
    CALL bederrorcheck("SEL br_datamart_value (Negations from simples)")
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(temp->filters,5))),
      (dummyt d2  WITH seq = 1),
      br_datamart_category c,
      br_datamart_filter f,
      br_datamart_filter_category fc,
      br_datam_val_set_item vsi
     PLAN (d
      WHERE maxrec(d2,size(negatedvalues->values,5)))
      JOIN (d2)
      JOIN (c
      WHERE (c.br_datamart_category_id=request->category_id))
      JOIN (f
      WHERE f.br_datamart_category_id=c.br_datamart_category_id
       AND (f.filter_mean=temp->filters[d.seq].mean)
       AND f.inaction_reason_value_set_id > 0
       AND (f.inaction_reason_value_set_id=temp->filters[d.seq].sec_val_set_id))
      JOIN (fc
      WHERE fc.filter_category_mean=f.filter_category_mean
       AND fc.filter_category_type_mean="MAP")
      JOIN (vsi
      WHERE vsi.br_datam_val_set_id=f.inaction_reason_value_set_id
       AND (vsi.source_vocab_item_ident=negatedvalues->values[d2.seq].source_id)
       AND (vsi.source_vocab_mean=negatedvalues->values[d2.seq].source_mean))
     ORDER BY d2.seq
     HEAD d2.seq
      num = 0, catpos = locateval(num,1,rcnt,negatedvalues->values[d2.seq].category_id,reply->
       categories[num].id)
      IF (catpos=0)
       rcnt = (rcnt+ 1), stat = alterlist(reply->categories,rcnt), reply->categories[rcnt].id =
       negatedvalues->values[d2.seq].category_id,
       reply->categories[rcnt].name = negatedvalues->values[d2.seq].category_name
      ENDIF
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error getting negated matches")
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

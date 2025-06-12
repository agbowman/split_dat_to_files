CREATE PROGRAM bed_get_dmart_copyable_values:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 cat_pair_filters[*]
      2 copy_from_category_id = f8
      2 copy_to_category_id = f8
      2 filters[*]
        3 br_datamart_filter_id = f8
        3 filter_mean = vc
        3 filter_display = vc
        3 filter_category_mean = vc
        3 filter_seq = i4
        3 copyable_values[*]
          4 parent_entity_id = f8
          4 parent_entity_name = vc
          4 parent_entity_id2 = f8
          4 parent_entity_name2 = vc
          4 value_dt_tm = dq8
          4 freetext_desc = vc
          4 qualifier_flag = i2
          4 value_seq = i4
          4 value_type_flag = i2
          4 group_seq = i4
          4 mpage_param_mean = vc
          4 mpage_param_value = vc
          4 map_data_type_cd = f8
          4 map_data_type_mean = vc
          4 map_data_type_display = vc
        3 non_copyable_values[*]
          4 parent_entity_id = f8
          4 parent_entity_name = vc
          4 parent_entity_id2 = f8
          4 parent_entity_name2 = vc
          4 value_dt_tm = dq8
          4 freetext_desc = vc
          4 qualifier_flag = i2
          4 value_seq = i4
          4 value_type_flag = i2
          4 group_seq = i4
          4 mpage_param_mean = vc
          4 mpage_param_value = vc
          4 map_data_type_cd = f8
          4 map_data_type_mean = vc
          4 map_data_type_display = vc
          4 map_type_missing_ind = i2
          4 map_item_missing_ind = i2
          4 link_value_missing_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp(
   1 cat_pair_filters[*]
     2 copy_from_category_id = f8
     2 copy_to_category_id = f8
     2 filters[*]
       3 filter_mean = vc
       3 br_datamart_filter_category_id = f8
       3 filter_category_mean = vc
       3 filter_category_type_mean = vc
       3 from_filter_id = f8
       3 from_filter_display = vc
       3 from_filter_seq = i4
       3 to_filter_id = f8
       3 expected_action_value_set_id = f8
       3 inaction_reason_value_set_id = f8
       3 from_mpage_param_ind = i2
       3 to_mpage_param_ind = i2
       3 from_br_datamart_filter_id = f8
       3 to_br_datamart_filter_id = f8
       3 from_values[*]
         4 br_datamart_value_id = f8
         4 parent_entity_id = f8
         4 parent_entity_name = vc
         4 parent_entity_id2 = f8
         4 parent_entity_name2 = vc
         4 value_dt_tm = dq8
         4 freetext_desc = vc
         4 qualifier_flag = i2
         4 value_seq = i4
         4 value_type_flag = i2
         4 group_seq = i4
         4 mpage_param_mean = vc
         4 mpage_param_value = vc
         4 map_data_type_cd = f8
         4 map_data_type_mean = vc
         4 map_data_type_display = vc
         4 to_map_type_ind = i2
         4 to_map_item_ind = i2
         4 to_link_value_ind = i2
 ) WITH protect
 RECORD temp_req(
   1 items[*]
     2 br_datamart_value_id = f8
 )
 RECORD temp_rep(
   1 items[*]
     2 br_datamart_value_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD all_copy_to_filters(
   1 copy_to_category[*]
     2 category_id = f8
     2 copy_to_filters[*]
       3 filter_id = f8
       3 filter_mean = vc
 ) WITH protect
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
 DECLARE cp_cnt = i4 WITH protect, constant(size(request->cat_pairs,5))
 DECLARE negation = vc WITH protect, constant("NEGATION")
 DECLARE map = vc WITH protect, constant("MAP")
 DECLARE vparse = vc WITH protect, noconstant(
  "from_v.end_effective_dt_tm > cnvtdatetime(curdate,curtime)")
 DECLARE f_cnt = i4 WITH protect, noconstant(0)
 DECLARE v_cnt = i4 WITH protect, noconstant(0)
 DECLARE ncv_cnt = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE found = i2 WITH protect, noconstant(0)
 DECLARE cat_cnt = i4 WITH protect, noconstant(0)
 DECLARE fil_cnt = i4 WITH protect, noconstant(0)
 IF (cp_cnt <= 0)
  GO TO exit_script
 ENDIF
 RANGE OF v IS br_datamart_value
 RANGE OF p IS prsnl
 IF (validate(v.logical_domain_id)
  AND validate(p.logical_domain_id))
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
  SET vparse = build2(vparse," and from_v.logical_domain_id = ",acm_get_curr_logical_domain_rep->
   logical_domain_id)
 ENDIF
 FREE RANGE v
 FREE RANGE p
 SET stat = alterlist(temp->cat_pair_filters,cp_cnt)
 FOR (cp_i = 1 TO cp_cnt)
  SET temp->cat_pair_filters[cp_i].copy_from_category_id = request->cat_pairs[cp_i].
  copy_from_category_id
  SET temp->cat_pair_filters[cp_i].copy_to_category_id = request->cat_pairs[cp_i].copy_to_category_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d_cp  WITH seq = cp_cnt),
   br_datamart_category to_c,
   br_datamart_filter f
  PLAN (d_cp)
   JOIN (to_c
   WHERE (to_c.br_datamart_category_id=temp->cat_pair_filters[d_cp.seq].copy_to_category_id))
   JOIN (f
   WHERE f.br_datamart_category_id=to_c.br_datamart_category_id)
  ORDER BY to_c.br_datamart_category_id, f.br_datamart_filter_id
  HEAD to_c.br_datamart_category_id
   fil_cnt = 0, cat_cnt = (cat_cnt+ 1), stat = alterlist(all_copy_to_filters->copy_to_category,
    cat_cnt),
   all_copy_to_filters->copy_to_category[cat_cnt].category_id = to_c.br_datamart_category_id
  HEAD f.br_datamart_filter_id
   fil_cnt = (fil_cnt+ 1), stat = alterlist(all_copy_to_filters->copy_to_category[cat_cnt].
    copy_to_filters,fil_cnt), all_copy_to_filters->copy_to_category[cat_cnt].copy_to_filters[fil_cnt]
   .filter_id = f.br_datamart_filter_id,
   all_copy_to_filters->copy_to_category[cat_cnt].copy_to_filters[fil_cnt].filter_mean = f
   .filter_mean
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error getting all copy to filters")
 SELECT INTO "nl:"
  FROM (dummyt d_cp  WITH seq = cp_cnt),
   br_datamart_category from_c,
   br_datamart_category to_c,
   br_datamart_filter from_f,
   br_datamart_filter to_f,
   br_datamart_filter_category fc,
   br_datamart_value from_v,
   code_value cv
  PLAN (d_cp)
   JOIN (from_c
   WHERE (from_c.br_datamart_category_id=temp->cat_pair_filters[d_cp.seq].copy_from_category_id))
   JOIN (to_c
   WHERE (to_c.br_datamart_category_id=temp->cat_pair_filters[d_cp.seq].copy_to_category_id))
   JOIN (from_f
   WHERE from_f.br_datamart_category_id=from_c.br_datamart_category_id)
   JOIN (to_f
   WHERE to_f.br_datamart_category_id=to_c.br_datamart_category_id
    AND to_f.filter_mean=from_f.filter_mean
    AND to_f.filter_category_mean=from_f.filter_category_mean)
   JOIN (fc
   WHERE fc.filter_category_mean=to_f.filter_category_mean)
   JOIN (from_v
   WHERE from_v.br_datamart_category_id=from_c.br_datamart_category_id
    AND from_v.br_datamart_filter_id=from_f.br_datamart_filter_id
    AND from_v.br_datamart_flex_id=0
    AND parser(vparse))
   JOIN (cv
   WHERE cv.code_value=outerjoin(from_v.map_data_type_cd))
  ORDER BY d_cp.seq, from_f.filter_seq, from_f.br_datamart_filter_id,
   from_v.group_seq, from_v.value_seq
  HEAD d_cp.seq
   f_cnt = 0
  HEAD from_f.br_datamart_filter_id
   v_cnt = 0, f_cnt = (f_cnt+ 1), stat = alterlist(temp->cat_pair_filters[d_cp.seq].filters,f_cnt),
   temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_br_datamart_filter_id = from_f
   .br_datamart_filter_id, temp->cat_pair_filters[d_cp.seq].filters[f_cnt].to_br_datamart_filter_id
    = to_f.br_datamart_filter_id, temp->cat_pair_filters[d_cp.seq].filters[f_cnt].filter_mean =
   from_f.filter_mean,
   temp->cat_pair_filters[d_cp.seq].filters[f_cnt].br_datamart_filter_category_id = fc
   .br_datamart_filter_category_id, temp->cat_pair_filters[d_cp.seq].filters[f_cnt].
   filter_category_mean = fc.filter_category_mean, temp->cat_pair_filters[d_cp.seq].filters[f_cnt].
   filter_category_type_mean = fc.filter_category_type_mean,
   temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_filter_id = from_f.br_datamart_filter_id,
   temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_filter_display = from_f.filter_display, temp
   ->cat_pair_filters[d_cp.seq].filters[f_cnt].from_filter_seq = from_f.filter_seq,
   temp->cat_pair_filters[d_cp.seq].filters[f_cnt].to_filter_id = to_f.br_datamart_filter_id, temp->
   cat_pair_filters[d_cp.seq].filters[f_cnt].expected_action_value_set_id = to_f
   .expected_action_value_set_id, temp->cat_pair_filters[d_cp.seq].filters[f_cnt].
   inaction_reason_value_set_id = to_f.inaction_reason_value_set_id
  DETAIL
   v_cnt = (v_cnt+ 1), stat = alterlist(temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_values,
    v_cnt), temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_values[v_cnt].br_datamart_value_id
    = from_v.br_datamart_value_id,
   temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_values[v_cnt].parent_entity_id = from_v
   .parent_entity_id, temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_values[v_cnt].
   parent_entity_name = from_v.parent_entity_name, temp->cat_pair_filters[d_cp.seq].filters[f_cnt].
   from_values[v_cnt].parent_entity_id2 = from_v.parent_entity_id2,
   temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_values[v_cnt].parent_entity_name2 = from_v
   .parent_entity_name2, temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_values[v_cnt].
   value_dt_tm = from_v.value_dt_tm, temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_values[
   v_cnt].freetext_desc = from_v.freetext_desc,
   temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_values[v_cnt].qualifier_flag = from_v
   .qualifier_flag, temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_values[v_cnt].value_seq =
   from_v.value_seq, temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_values[v_cnt].
   value_type_flag = from_v.value_type_flag,
   temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_values[v_cnt].group_seq = from_v.group_seq,
   temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_values[v_cnt].mpage_param_mean = from_v
   .mpage_param_mean, temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_values[v_cnt].
   mpage_param_value = from_v.mpage_param_value,
   temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_values[v_cnt].map_data_type_cd = from_v
   .map_data_type_cd, temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_values[v_cnt].
   map_data_type_mean = cv.cdf_meaning
   IF ( NOT (from_v.map_data_type_cd))
    temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_values[v_cnt].to_map_type_ind = 1, temp->
    cat_pair_filters[d_cp.seq].filters[f_cnt].from_values[v_cnt].to_map_item_ind = 1
   ELSEIF (cv.cdf_meaning=negation)
    temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_values[v_cnt].to_map_type_ind = 1
   ENDIF
   IF (fc.filter_category_type_mean != map)
    temp->cat_pair_filters[d_cp.seq].filters[f_cnt].from_values[v_cnt].to_link_value_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error getting filters")
 SELECT INTO "nl:"
  FROM (dummyt d_cp  WITH seq = cp_cnt),
   (dummyt d_f  WITH seq = 1),
   br_datamart_report_filter_r rf,
   br_datamart_report_default rd
  PLAN (d_cp)
   JOIN (d_f
   WHERE maxrec(d_f,size(temp->cat_pair_filters[d_cp.seq].filters,5)))
   JOIN (rf
   WHERE (rf.br_datamart_filter_id=temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].
   from_br_datamart_filter_id))
   JOIN (rd
   WHERE rd.br_datamart_report_id=rf.br_datamart_report_id
    AND rd.mpage_param_mean="MP_LOOK_BACK_CUR_ENC")
  ORDER BY d_cp.seq, d_f.seq, rf.br_datamart_filter_id,
   rd.br_datamart_report_id
  DETAIL
   temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].from_mpage_param_ind = 1
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error getting from lookback settings.")
 SELECT INTO "nl:"
  FROM (dummyt d_cp  WITH seq = cp_cnt),
   (dummyt d_f  WITH seq = 1),
   br_datamart_report_filter_r rf,
   br_datamart_report_default rd
  PLAN (d_cp)
   JOIN (d_f
   WHERE maxrec(d_f,size(temp->cat_pair_filters[d_cp.seq].filters,5)))
   JOIN (rf
   WHERE (rf.br_datamart_filter_id=temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].
   to_br_datamart_filter_id))
   JOIN (rd
   WHERE rd.br_datamart_report_id=rf.br_datamart_report_id
    AND rd.mpage_param_mean="MP_LOOK_BACK_CUR_ENC")
  ORDER BY d_cp.seq, d_f.seq, rf.br_datamart_filter_id,
   rd.br_datamart_report_id
  DETAIL
   temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].to_mpage_param_ind = 1
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error getting to lookback settings.")
 SELECT INTO "nl:"
  FROM (dummyt d_cp  WITH seq = cp_cnt),
   (dummyt d_f  WITH seq = f_cnt),
   (dummyt d_v  WITH seq = 1)
  PLAN (d_cp
   WHERE maxrec(d_v,size(temp->cat_pair_filters[d_cp.seq].filters,5)))
   JOIN (d_f
   WHERE maxrec(d_v,size(temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].from_values,5)))
   JOIN (d_v
   WHERE (temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].from_values[d_v.seq].parent_entity_name=
   "BR_DATAMART_FILTER"))
  DETAIL
   IF ((temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].from_values[d_v.seq].freetext_desc=
   "<Temperature>"))
    FOR (i_cp = 1 TO cat_cnt)
      IF ((temp->cat_pair_filters[d_cp.seq].copy_to_category_id=all_copy_to_filters->
      copy_to_category[i_cp].category_id))
       FOR (i_f = 1 TO size(all_copy_to_filters->copy_to_category[i_cp].copy_to_filters,5))
        length = (textlen(all_copy_to_filters->copy_to_category[i_cp].copy_to_filters[i_f].
         filter_mean) - 6),
        IF (substring(length,7,all_copy_to_filters->copy_to_category[i_cp].copy_to_filters[i_f].
         filter_mean)="TEMP_CE")
         temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].from_values[d_v.seq].parent_entity_id =
         all_copy_to_filters->copy_to_category[i_cp].copy_to_filters[i_f].filter_id
        ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ELSEIF ((temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].from_values[d_v.seq].freetext_desc=
   "<Blood Pressure>"))
    FOR (i_cp = 1 TO cat_cnt)
      IF ((temp->cat_pair_filters[d_cp.seq].copy_to_category_id=all_copy_to_filters->
      copy_to_category[i_cp].category_id))
       FOR (i_f = 1 TO size(all_copy_to_filters->copy_to_category[i_cp].copy_to_filters,5))
        length = (textlen(all_copy_to_filters->copy_to_category[i_cp].copy_to_filters[i_f].
         filter_mean) - 4),
        IF (substring(length,5,all_copy_to_filters->copy_to_category[i_cp].copy_to_filters[i_f].
         filter_mean)="BP_CE")
         temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].from_values[d_v.seq].parent_entity_id =
         all_copy_to_filters->copy_to_category[i_cp].copy_to_filters[i_f].filter_id
        ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ELSEIF ((temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].from_values[d_v.seq].freetext_desc=
   "<Heart Rate>"))
    FOR (i_cp = 1 TO cat_cnt)
      IF ((temp->cat_pair_filters[d_cp.seq].copy_to_category_id=all_copy_to_filters->
      copy_to_category[i_cp].category_id))
       FOR (i_f = 1 TO size(all_copy_to_filters->copy_to_category[i_cp].copy_to_filters,5))
        length = (textlen(all_copy_to_filters->copy_to_category[i_cp].copy_to_filters[i_f].
         filter_mean) - 4),
        IF (substring(length,5,all_copy_to_filters->copy_to_category[i_cp].copy_to_filters[i_f].
         filter_mean)="HR_CE")
         temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].from_values[d_v.seq].parent_entity_id =
         all_copy_to_filters->copy_to_category[i_cp].copy_to_filters[i_f].filter_id
        ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error populating new parent entity ids")
 SELECT INTO "nl:"
  FROM (dummyt d_cp  WITH seq = cp_cnt),
   (dummyt d_f  WITH seq = f_cnt),
   (dummyt d_v  WITH seq = 1),
   br_datam_mapping_type from_mt,
   br_datam_mapping_type to_mt
  PLAN (d_cp
   WHERE maxrec(d_v,size(temp->cat_pair_filters[d_cp.seq].filters,5)))
   JOIN (d_f
   WHERE maxrec(d_v,size(temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].from_values,5)))
   JOIN (d_v)
   JOIN (from_mt
   WHERE (from_mt.br_datamart_category_id=temp->cat_pair_filters[d_cp.seq].copy_from_category_id)
    AND (from_mt.br_datamart_filter_category_id=temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].
   br_datamart_filter_category_id)
    AND (from_mt.map_data_type_cd=temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].from_values[d_v
   .seq].map_data_type_cd))
   JOIN (to_mt
   WHERE to_mt.br_datamart_category_id=outerjoin(temp->cat_pair_filters[d_cp.seq].copy_to_category_id
    )
    AND to_mt.br_datamart_filter_category_id=outerjoin(temp->cat_pair_filters[d_cp.seq].filters[d_f
    .seq].br_datamart_filter_category_id)
    AND to_mt.map_data_type_cd=outerjoin(from_mt.map_data_type_cd)
    AND to_mt.map_data_type_value=outerjoin(from_mt.map_data_type_value))
  DETAIL
   temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].from_values[d_v.seq].map_data_type_display =
   from_mt.map_data_type_display
   IF (to_mt.br_datam_mapping_type_id > 0)
    temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].from_values[d_v.seq].to_map_type_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error populating to_map_type_ind")
 SELECT INTO "nl:"
  FROM (dummyt d_cp  WITH seq = cp_cnt),
   (dummyt d_f  WITH seq = f_cnt),
   (dummyt d_v  WITH seq = 1),
   br_datam_val_set_item from_vsi,
   br_datam_val_set_item to_vsi
  PLAN (d_cp
   WHERE maxrec(d_v,size(temp->cat_pair_filters[d_cp.seq].filters,5)))
   JOIN (d_f
   WHERE maxrec(d_v,size(temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].from_values,5)))
   JOIN (d_v
   WHERE (temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].from_values[d_v.seq].parent_entity_name2=
   "BR_DATAM_VAL_SET_ITEM"))
   JOIN (from_vsi
   WHERE (from_vsi.br_datam_val_set_item_id=temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].
   from_values[d_v.seq].parent_entity_id2))
   JOIN (to_vsi
   WHERE (((negation != temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].from_values[d_v.seq].
   map_data_type_mean)
    AND (to_vsi.br_datam_val_set_id=temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].
   expected_action_value_set_id)) OR ((negation=temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].
   from_values[d_v.seq].map_data_type_mean)
    AND (to_vsi.br_datam_val_set_id=temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].
   inaction_reason_value_set_id)))
    AND to_vsi.source_vocab_mean=from_vsi.source_vocab_mean
    AND to_vsi.source_vocab_item_ident=from_vsi.source_vocab_item_ident)
  DETAIL
   temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].from_values[d_v.seq].parent_entity_id2 = to_vsi
   .br_datam_val_set_item_id, temp->cat_pair_filters[d_cp.seq].filters[d_f.seq].from_values[d_v.seq].
   to_map_item_ind = 1
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error populating to_map_item_ind")
 FOR (i_cp = 1 TO cp_cnt)
   FOR (i_f = 1 TO size(temp->cat_pair_filters[i_cp].filters,5))
     IF ((temp->cat_pair_filters[i_cp].filters[i_f].filter_category_type_mean=map))
      SET v_cnt = size(temp->cat_pair_filters[i_cp].filters[i_f].from_values,5)
      FOR (i_v = 1 TO v_cnt)
        SET stat = initrec(temp_req)
        SET stat = initrec(temp_rep)
        SET stat = alterlist(temp_req->items,1)
        SET temp_req->items[1].br_datamart_value_id = temp->cat_pair_filters[i_cp].filters[i_f].
        from_values[i_v].br_datamart_value_id
        EXECUTE bed_get_linked_values  WITH replace("REQUEST",temp_req), replace("REPLY",temp_rep)
        IF (("S" != temp_rep->status_data.status))
         CALL bederror(build("Link val: ",temp_req->items[1].br_datamart_value_id))
        ENDIF
        SET found = 1
        FOR (i_lv = 1 TO size(temp_rep->items,5))
          SET num = 0
          SET idx = locateval(num,1,v_cnt,temp_rep->items[i_lv].br_datamart_value_id,temp->
           cat_pair_filters[i_cp].filters[i_f].from_values[num].br_datamart_value_id)
          IF (((idx=0) OR ((((temp->cat_pair_filters[i_cp].filters[i_f].from_values[idx].
          to_map_item_ind=0)) OR ((temp->cat_pair_filters[i_cp].filters[i_f].from_values[idx].
          to_map_type_ind=0))) )) )
           SET found = 0
          ENDIF
        ENDFOR
        SET temp->cat_pair_filters[i_cp].filters[i_f].from_values[i_v].to_link_value_ind = found
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 SET stat = alterlist(reply->cat_pair_filters,cp_cnt)
 SET curalias rep_f reply->cat_pair_filters[i_cp].filters[i_f]
 SET curalias tmp_v temp->cat_pair_filters[i_cp].filters[i_f].from_values[i_v]
 FOR (i_cp = 1 TO cp_cnt)
   SET f_cnt = size(temp->cat_pair_filters[i_cp].filters,5)
   SET stat = alterlist(reply->cat_pair_filters[i_cp].filters,f_cnt)
   SET reply->cat_pair_filters[i_cp].copy_from_category_id = temp->cat_pair_filters[i_cp].
   copy_from_category_id
   SET reply->cat_pair_filters[i_cp].copy_to_category_id = temp->cat_pair_filters[i_cp].
   copy_to_category_id
   FOR (i_f = 1 TO f_cnt)
     SET v_cnt = 0
     SET ncv_cnt = 0
     SET rep_f->br_datamart_filter_id = temp->cat_pair_filters[i_cp].filters[i_f].from_filter_id
     SET rep_f->filter_mean = temp->cat_pair_filters[i_cp].filters[i_f].filter_mean
     SET rep_f->filter_display = temp->cat_pair_filters[i_cp].filters[i_f].from_filter_display
     SET rep_f->filter_category_mean = temp->cat_pair_filters[i_cp].filters[i_f].filter_category_mean
     SET rep_f->filter_seq = temp->cat_pair_filters[i_cp].filters[i_f].from_filter_seq
     IF ((temp->cat_pair_filters[i_cp].filters[i_f].from_mpage_param_ind=temp->cat_pair_filters[i_cp]
     .filters[i_f].to_mpage_param_ind))
      SET can_copy_layout = 1
     ELSE
      SET can_copy_layout = 0
     ENDIF
     FOR (i_v = 1 TO size(temp->cat_pair_filters[i_cp].filters[i_f].from_values,5))
       SET map_type_missing_ind = evaluate(tmp_v->to_map_type_ind,1,0,1)
       SET map_item_missing_ind = evaluate(tmp_v->to_map_item_ind,1,0,1)
       SET link_value_missing_ind = evaluate(tmp_v->to_link_value_ind,1,0,1)
       IF (((map_type_missing_ind) OR (((map_item_missing_ind) OR (((link_value_missing_ind) OR (
       can_copy_layout=0
        AND (rep_f->filter_category_mean="MPAGE_PARAM_MEAN"))) )) )) )
        SET ncv_cnt = (ncv_cnt+ 1)
        SET stat = alterlist(rep_f->non_copyable_values,ncv_cnt)
        SET rep_f->non_copyable_values[ncv_cnt].parent_entity_id = tmp_v->parent_entity_id
        SET rep_f->non_copyable_values[ncv_cnt].parent_entity_name = tmp_v->parent_entity_name
        SET rep_f->non_copyable_values[ncv_cnt].parent_entity_id2 = tmp_v->parent_entity_id2
        SET rep_f->non_copyable_values[ncv_cnt].parent_entity_name2 = tmp_v->parent_entity_name2
        SET rep_f->non_copyable_values[ncv_cnt].value_dt_tm = tmp_v->value_dt_tm
        SET rep_f->non_copyable_values[ncv_cnt].freetext_desc = tmp_v->freetext_desc
        SET rep_f->non_copyable_values[ncv_cnt].qualifier_flag = tmp_v->qualifier_flag
        SET rep_f->non_copyable_values[ncv_cnt].value_seq = tmp_v->value_seq
        SET rep_f->non_copyable_values[ncv_cnt].value_type_flag = tmp_v->value_type_flag
        SET rep_f->non_copyable_values[ncv_cnt].group_seq = tmp_v->group_seq
        SET rep_f->non_copyable_values[ncv_cnt].mpage_param_mean = tmp_v->mpage_param_mean
        SET rep_f->non_copyable_values[ncv_cnt].mpage_param_value = tmp_v->mpage_param_value
        SET rep_f->non_copyable_values[ncv_cnt].map_data_type_cd = tmp_v->map_data_type_cd
        SET rep_f->non_copyable_values[ncv_cnt].map_data_type_mean = tmp_v->map_data_type_mean
        SET rep_f->non_copyable_values[ncv_cnt].map_data_type_display = tmp_v->map_data_type_display
        SET rep_f->non_copyable_values[ncv_cnt].map_type_missing_ind = map_type_missing_ind
        SET rep_f->non_copyable_values[ncv_cnt].map_item_missing_ind = map_item_missing_ind
        SET rep_f->non_copyable_values[ncv_cnt].link_value_missing_ind = link_value_missing_ind
       ELSE
        SET v_cnt = (v_cnt+ 1)
        SET stat = alterlist(rep_f->copyable_values,v_cnt)
        SET rep_f->copyable_values[v_cnt].parent_entity_id = tmp_v->parent_entity_id
        SET rep_f->copyable_values[v_cnt].parent_entity_name = tmp_v->parent_entity_name
        SET rep_f->copyable_values[v_cnt].parent_entity_id2 = tmp_v->parent_entity_id2
        SET rep_f->copyable_values[v_cnt].parent_entity_name2 = tmp_v->parent_entity_name2
        SET rep_f->copyable_values[v_cnt].value_dt_tm = tmp_v->value_dt_tm
        SET rep_f->copyable_values[v_cnt].freetext_desc = tmp_v->freetext_desc
        SET rep_f->copyable_values[v_cnt].qualifier_flag = tmp_v->qualifier_flag
        SET rep_f->copyable_values[v_cnt].value_seq = tmp_v->value_seq
        SET rep_f->copyable_values[v_cnt].value_type_flag = tmp_v->value_type_flag
        SET rep_f->copyable_values[v_cnt].group_seq = tmp_v->group_seq
        SET rep_f->copyable_values[v_cnt].mpage_param_mean = tmp_v->mpage_param_mean
        SET rep_f->copyable_values[v_cnt].mpage_param_value = tmp_v->mpage_param_value
        SET rep_f->copyable_values[v_cnt].map_data_type_cd = tmp_v->map_data_type_cd
        SET rep_f->copyable_values[v_cnt].map_data_type_mean = tmp_v->map_data_type_mean
        SET rep_f->copyable_values[v_cnt].map_data_type_display = tmp_v->map_data_type_display
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 SET curalias rep_f off
 SET curalias tmp_v off
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO

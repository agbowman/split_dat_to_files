CREATE PROGRAM bed_get_oc_detail:dba
 FREE SET reply
 RECORD reply(
   1 clist[*]
     2 active_ind = i2
     2 code_value = f8
     2 description = c100
     2 display = c40
     2 concept_cki = c255
     2 orc_found = i2
     2 cross_map
       3 cpt4 = c10
       3 cpt4_active_ind = i2
       3 loinc_code = c10
       3 loinc_active_ind = i2
     2 synonym_found = i2
     2 synonym_list[*]
       3 active_ind = i2
       3 synonym_type = i2
       3 synonym_id = f8
       3 synonym_value = c100
     2 sr_found = i2
     2 sr_list[*]
       3 active_ind = i2
       3 code_value = f8
       3 display = c40
       3 description = c60
       3 cdf_meaning = c12
       3 default = i2
       3 sequence = i4
     2 assay_found = i2
     2 assay_list[*]
       3 source = i2
       3 active_ind = i2
       3 code_value = f8
       3 display = c40
       3 description = vc
       3 required = i2
       3 prompt_test_ind = i2
       3 post_verify_ind = i2
       3 restrict_display_ind = i2
       3 result_type
         4 code_value = f8
         4 display = vc
         4 cdf_meaning = vc
       3 activity_type
         4 code_value = f8
         4 display = vc
         4 cdf_meaning = vc
       3 event
         4 code_value = f8
         4 display = vc
       3 result_process
         4 code_value = f8
         4 display = vc
         4 cdf_meaning = vc
       3 concept
         4 concept_cki = vc
         4 concept_name = vc
         4 vocab_cd = f8
         4 vocab_disp = c40
         4 vocab_axis_cd = f8
         4 vocab_axis_disp = c40
         4 source_identifier = vc
     2 legacy_oc_found = i2
     2 legacy_oc_list[*]
       3 facility = vc
       3 short_desc = vc
       3 long_desc = vc
     2 dept_name = vc
     2 catalog_type_code_value = f8
     2 catalog_type_display = vc
     2 catalog_type_mean = vc
     2 activity_type_code_value = f8
     2 activity_type_display = vc
     2 activity_type_mean = vc
     2 activity_subtype_code_value = f8
     2 activity_subtype_display = vc
     2 activity_subtype_mean = vc
     2 order_entry_format_id = f8
     2 order_entry_format_name = vc
     2 dlist[*]
       3 dup_check_level = i2
       3 look_behind_action_code_value = f8
       3 look_behind_action_display = c40
       3 look_behind_action_cdf_mean = c12
       3 look_behind_minutes = i4
       3 look_ahead_action_code_value = f8
       3 look_ahead_action_display = c40
       3 look_ahead_action_cdf_mean = c12
       3 look_ahead_minutes = i4
       3 exact_match_action_code_value = f8
       3 exact_match_action_display = c40
       3 exact_match_action_cdf_mean = c12
     2 clin_cat_code_value = f8
     2 clin_cat_display = c40
     2 clin_cat_cdf_mean = c12
     2 schedulable_ind = i2
     2 slist[*]
       3 pat_type_code_value = f8
       3 pat_type_display = c40
       3 pat_type_cdf_mean = c12
     2 flist[*]
       3 entity_reltn_mean = vc
       3 entity2_id = f8
       3 entity2_display = vc
       3 rank_sequence = i4
       3 entity2_name = vc
     2 procedure_type
       3 code_value = f8
       3 display = vc
       3 cdf_meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET inactive_child = request->include_inactive_child_ind
 SET orc_cnt = size(request->clist,5)
 SET stat = alterlist(reply->clist,orc_cnt)
 SET tot_count = 0
 IF (orc_cnt=0)
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET load_dept_name = 0.0
 IF (validate(request->load.dept_name))
  SET load_dept_name = request->load.dept_name
 ENDIF
 SET load_types = 0.0
 IF (validate(request->load.types))
  SET load_types = request->load.types
 ENDIF
 SET load_oef = 0.0
 IF (validate(request->load.oe_format))
  SET load_oef = request->load.oe_format
 ENDIF
 SELECT INTO "NL:"
  o.description
  FROM (dummyt d  WITH seq = orc_cnt),
   order_catalog o
  PLAN (d)
   JOIN (o
   WHERE (o.catalog_cd=request->clist[d.seq].code_value))
  DETAIL
   reply->clist[d.seq].orc_found = 1, reply->clist[d.seq].description = o.description, reply->clist[d
   .seq].concept_cki = o.concept_cki,
   reply->clist[d.seq].active_ind = o.active_ind, reply->clist[d.seq].display = o.primary_mnemonic,
   reply->clist[d.seq].code_value = o.catalog_cd
   IF (load_oef > 0)
    reply->clist[d.seq].order_entry_format_id = o.oe_format_id
   ENDIF
   IF (load_types > 0)
    reply->clist[d.seq].catalog_type_code_value = o.catalog_type_cd, reply->clist[d.seq].
    activity_type_code_value = o.activity_type_cd, reply->clist[d.seq].activity_subtype_code_value =
    o.activity_subtype_cd
   ENDIF
   IF (load_dept_name > 0)
    reply->clist[d.seq].dept_name = o.dept_display_name
   ENDIF
   IF ((request->load.clin_cat_ind=1))
    reply->clist[d.seq].clin_cat_code_value = o.dcp_clin_cat_cd
   ENDIF
   IF ((request->load.sched_params_ind=1))
    reply->clist[d.seq].schedulable_ind = o.schedule_ind
   ENDIF
  WITH nocounter
 ;end select
 IF (load_dept_name > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = orc_cnt),
    service_directory s
   PLAN (d)
    JOIN (s
    WHERE (s.catalog_cd=reply->clist[d.seq].code_value)
     AND s.active_ind=1)
   DETAIL
    reply->clist[d.seq].dept_name = s.short_description, reply->clist[d.seq].procedure_type.
    code_value = s.bb_processing_cd
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = orc_cnt),
   code_value cv
  PLAN (d
   WHERE (reply->clist[d.seq].procedure_type.code_value > 0))
   JOIN (cv
   WHERE (cv.code_value=reply->clist[d.seq].procedure_type.code_value))
  DETAIL
   reply->clist[d.seq].procedure_type.display = cv.display, reply->clist[d.seq].procedure_type.
   cdf_meaning = cv.cdf_meaning
  WITH nocounter
 ;end select
 IF (load_types > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = orc_cnt),
    code_value cv
   PLAN (d
    WHERE (reply->clist[d.seq].catalog_type_code_value > 0))
    JOIN (cv
    WHERE (cv.code_value=reply->clist[d.seq].catalog_type_code_value)
     AND cv.active_ind=1)
   DETAIL
    reply->clist[d.seq].catalog_type_display = cv.display, reply->clist[d.seq].catalog_type_mean = cv
    .cdf_meaning
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = orc_cnt),
    code_value cv
   PLAN (d
    WHERE (reply->clist[d.seq].activity_type_code_value > 0))
    JOIN (cv
    WHERE (cv.code_value=reply->clist[d.seq].activity_type_code_value)
     AND cv.active_ind=1)
   DETAIL
    reply->clist[d.seq].activity_type_display = cv.display, reply->clist[d.seq].activity_type_mean =
    cv.cdf_meaning
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = orc_cnt),
    code_value cv
   PLAN (d
    WHERE (reply->clist[d.seq].activity_subtype_code_value > 0))
    JOIN (cv
    WHERE (cv.code_value=reply->clist[d.seq].activity_subtype_code_value)
     AND cv.active_ind=1)
   DETAIL
    reply->clist[d.seq].activity_subtype_display = cv.display, reply->clist[d.seq].
    activity_subtype_mean = cv.cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
 IF (load_oef > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = orc_cnt),
    order_entry_format oef
   PLAN (d
    WHERE (reply->clist[d.seq].order_entry_format_id > 0))
    JOIN (oef
    WHERE (oef.oe_format_id=reply->clist[d.seq].order_entry_format_id))
   DETAIL
    reply->clist[d.seq].order_entry_format_name = oef.oe_format_name
  ;end select
 ENDIF
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = orc_cnt),
   br_auto_order_catalog b
  PLAN (d
   WHERE (reply->clist[d.seq].orc_found != 1))
   JOIN (b
   WHERE (b.catalog_cd=request->clist[d.seq].code_value))
  DETAIL
   reply->clist[d.seq].orc_found = 1, reply->clist[d.seq].description = b.description, reply->clist[d
   .seq].concept_cki = b.concept_cki,
   reply->clist[d.seq].active_ind = 1, reply->clist[d.seq].display = b.primary_mnemonic, reply->
   clist[d.seq].code_value = b.catalog_cd
   IF ((request->load.cross_map=1))
    reply->clist[d.seq].cross_map.cpt4 = b.cpt4, reply->clist[d.seq].cross_map.cpt4_active_ind = 1,
    reply->clist[d.seq].cross_map.loinc_code = b.loinc,
    reply->clist[d.seq].cross_map.loinc_active_ind = 1
   ENDIF
  WITH skipbedrock = 1, nocounter
 ;end select
 IF ((request->load.cross_map=1))
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = orc_cnt),
    cmt_cross_map cmt
   PLAN (d
    WHERE (reply->clist[d.seq].orc_found=1)
     AND (reply->clist[d.seq].concept_cki > " "))
    JOIN (cmt
    WHERE (cmt.concept_cki=reply->clist[d.seq].concept_cki)
     AND cmt.target_concept_cki IN ("CPT4*", "LOINC*")
     AND ((cmt.active_ind=1) OR (cmt.active_ind=0
     AND inactive_child=1)) )
   DETAIL
    IF (cmt.target_concept_cki="CPT4*")
     reply->clist[d.seq].cross_map.cpt4 = substring(6,200,cmt.target_concept_cki), reply->clist[d.seq
     ].cross_map.cpt4_active_ind = cmt.active_ind
    ELSE
     reply->clist[d.seq].cross_map.loinc_code = substring(7,10,cmt.target_concept_cki), reply->clist[
     d.seq].cross_map.loinc_active_ind = cmt.active_ind
    ENDIF
   WITH skipbedrock = 1, nocounter
  ;end select
 ENDIF
 IF ((request->load.assay_list=1))
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = orc_cnt),
    profile_task_r ptr,
    code_value cv,
    discrete_task_assay dta
   PLAN (d
    WHERE (reply->clist[d.seq].orc_found=1))
    JOIN (ptr
    WHERE (ptr.catalog_cd=request->clist[d.seq].code_value)
     AND ((ptr.active_ind=1) OR (ptr.active_ind=0
     AND inactive_child=1)) )
    JOIN (cv
    WHERE cv.code_value=ptr.task_assay_cd
     AND cv.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=ptr.task_assay_cd)
   ORDER BY d.seq, ptr.sequence
   HEAD d.seq
    reply->clist[d.seq].assay_found = 1, tot_count = 0
   DETAIL
    tot_count = (tot_count+ 1), stat = alterlist(reply->clist[d.seq].assay_list,tot_count), reply->
    clist[d.seq].assay_list[tot_count].source = 1,
    reply->clist[d.seq].assay_list[tot_count].active_ind = ptr.active_ind, reply->clist[d.seq].
    assay_list[tot_count].display = cv.display, reply->clist[d.seq].assay_list[tot_count].description
     = cv.description,
    reply->clist[d.seq].assay_list[tot_count].code_value = cv.code_value, reply->clist[d.seq].
    assay_list[tot_count].required = ptr.pending_ind, reply->clist[d.seq].assay_list[tot_count].
    prompt_test_ind = ptr.item_type_flag,
    reply->clist[d.seq].assay_list[tot_count].post_verify_ind = ptr.post_prompt_ind, reply->clist[d
    .seq].assay_list[tot_count].restrict_display_ind = ptr.restrict_display_ind, reply->clist[d.seq].
    assay_list[tot_count].result_type.code_value = dta.default_result_type_cd,
    reply->clist[d.seq].assay_list[tot_count].activity_type.code_value = dta.activity_type_cd, reply
    ->clist[d.seq].assay_list[tot_count].result_process.code_value = dta.bb_result_processing_cd,
    reply->clist[d.seq].assay_list[tot_count].concept.concept_cki = dta.concept_cki
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = orc_cnt),
    br_auto_oc_dta b,
    br_auto_order_catalog oc,
    br_auto_dta dta
   PLAN (d
    WHERE (reply->clist[d.seq].orc_found=1)
     AND (reply->clist[d.seq].assay_found != 1))
    JOIN (oc
    WHERE (oc.concept_cki=reply->clist[d.seq].concept_cki))
    JOIN (b
    WHERE b.catalog_cd=oc.catalog_cd)
    JOIN (dta
    WHERE dta.task_assay_cd=outerjoin(b.task_assay_cd))
   ORDER BY d.seq, b.sequence
   HEAD d.seq
    stat = alterlist(reply->clist[d.seq].assay_list,100), reply->clist[d.seq].assay_found = 2
   DETAIL
    tot_count = (tot_count+ 1), reply->clist[d.seq].assay_list[b.sequence].source = 2, reply->clist[d
    .seq].assay_list[b.sequence].active_ind = 1,
    reply->clist[d.seq].assay_list[b.sequence].code_value = b.task_assay_cd, reply->clist[d.seq].
    assay_list[b.sequence].result_type.code_value = dta.result_type_cd, reply->clist[d.seq].
    assay_list[b.sequence].activity_type.code_value = dta.activity_type_cd,
    reply->clist[d.seq].assay_list[b.sequence].result_process.code_value = dta
    .bb_result_processing_cd
    IF (dta.mnemonic > "   ")
     reply->clist[d.seq].assay_list[b.sequence].display = dta.mnemonic, reply->clist[d.seq].
     assay_list[b.sequence].description = dta.description
    ENDIF
   FOOT  d.seq
    stat = alterlist(reply->clist[d.seq].assay_list,tot_count)
   WITH nocounter, skipbedrock = 1
  ;end select
  CALL echorecord(reply)
  SET acnt = 0
  FOR (x = 1 TO orc_cnt)
   SET acnt = size(reply->clist[x].assay_list,5)
   IF (acnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(acnt)),
      code_value c
     PLAN (d)
      JOIN (c
      WHERE (c.code_value=reply->clist[x].assay_list[d.seq].result_type.code_value))
     ORDER BY d.seq
     HEAD d.seq
      reply->clist[x].assay_list[d.seq].result_type.display = c.display, reply->clist[x].assay_list[d
      .seq].result_type.cdf_meaning = c.cdf_meaning
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(acnt)),
      code_value c
     PLAN (d
      WHERE (reply->clist[x].assay_list[d.seq].activity_type.code_value > 0))
      JOIN (c
      WHERE (c.code_value=reply->clist[x].assay_list[d.seq].activity_type.code_value))
     ORDER BY d.seq
     HEAD d.seq
      reply->clist[x].assay_list[d.seq].activity_type.display = c.display, reply->clist[x].
      assay_list[d.seq].activity_type.cdf_meaning = c.cdf_meaning
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(acnt)),
      code_value_event_r r,
      code_value c
     PLAN (d)
      JOIN (r
      WHERE (r.parent_cd=reply->clist[x].assay_list[d.seq].code_value))
      JOIN (c
      WHERE c.code_value=r.event_cd)
     ORDER BY d.seq
     HEAD d.seq
      reply->clist[x].assay_list[d.seq].event.code_value = c.code_value, reply->clist[x].assay_list[d
      .seq].event.display = c.display
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(acnt)),
      code_value c
     PLAN (d
      WHERE (reply->clist[x].assay_list[d.seq].result_process.code_value > 0))
      JOIN (c
      WHERE (c.code_value=reply->clist[x].assay_list[d.seq].result_process.code_value))
     ORDER BY d.seq
     HEAD d.seq
      reply->clist[x].assay_list[d.seq].result_process.display = c.display, reply->clist[x].
      assay_list[d.seq].result_process.cdf_meaning = c.cdf_meaning
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(acnt)),
      nomenclature n
     PLAN (d
      WHERE size(trim(reply->clist[x].assay_list[d.seq].concept.concept_cki)) > 0)
      JOIN (n
      WHERE n.primary_cterm_ind=1
       AND n.active_ind=1
       AND (n.concept_cki=reply->clist[x].assay_list[d.seq].concept.concept_cki))
     DETAIL
      reply->clist[x].assay_list[d.seq].concept.concept_name = n.source_string, reply->clist[x].
      assay_list[d.seq].concept.vocab_cd = n.source_vocabulary_cd, reply->clist[x].assay_list[d.seq].
      concept.vocab_axis_cd = n.vocab_axis_cd,
      reply->clist[x].assay_list[d.seq].concept.source_identifier = n.source_identifier
     WITH nocounter
    ;end select
   ENDIF
  ENDFOR
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = orc_cnt),
    (dummyt d2  WITH seq = size(reply->clist[d.seq].assay_list,5)),
    code_value cv
   PLAN (d
    WHERE (reply->clist[d.seq].orc_found=1)
     AND (reply->clist[d.seq].assay_found=2))
    JOIN (d2
    WHERE (reply->clist[d.seq].assay_list[d2.seq].display=null))
    JOIN (cv
    WHERE cv.code_set=14003
     AND cv.active_ind=1
     AND (cv.code_value=reply->clist[d.seq].assay_list[d2.seq].code_value))
   DETAIL
    reply->clist[d.seq].assay_list[d2.seq].display = cv.display, reply->clist[d.seq].assay_list[d2
    .seq].description = cv.description, reply->clist[d.seq].assay_list[d2.seq].active_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->load.synonym_list=1))
  SET dcp_cd = 0.0
  SET anc_cd = 0.0
  SELECT INTO "nl:"
   FROM code_value c
   PLAN (c
    WHERE c.code_set=6011
     AND c.cdf_meaning IN ("DCP", "ANCILLARY")
     AND c.active_ind=1)
   DETAIL
    IF (c.cdf_meaning="DCP")
     dcp_cd = c.code_value
    ELSE
     anc_cd = c.code_value
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   ocs.mnemonic
   FROM (dummyt d  WITH seq = orc_cnt),
    order_catalog_synonym ocs
   PLAN (d
    WHERE (reply->clist[d.seq].orc_found=1))
    JOIN (ocs
    WHERE (ocs.catalog_cd=request->clist[d.seq].code_value)
     AND ((ocs.active_ind=1) OR (ocs.active_ind=0
     AND inactive_child=1))
     AND ocs.mnemonic_type_cd IN (dcp_cd, anc_cd))
   HEAD d.seq
    tot_count = 0, reply->clist[d.seq].synonym_found = 1
   DETAIL
    tot_count = (tot_count+ 1), stat = alterlist(reply->clist[d.seq].synonym_list,tot_count), reply->
    clist[d.seq].synonym_list[tot_count].active_ind = ocs.active_ind,
    reply->clist[d.seq].synonym_list[tot_count].synonym_value = ocs.mnemonic, reply->clist[d.seq].
    synonym_list[tot_count].synonym_id = ocs.synonym_id
    IF (ocs.mnemonic_type_cd=anc_cd)
     reply->clist[d.seq].synonym_list[tot_count].synonym_type = 1
    ELSE
     reply->clist[d.seq].synonym_list[tot_count].synonym_type = 2
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = orc_cnt),
    br_auto_oc_synonym ocs
   PLAN (d
    WHERE (reply->clist[d.seq].orc_found=1)
     AND (reply->clist[d.seq].synonym_found != 1))
    JOIN (ocs
    WHERE (ocs.catalog_cd=request->clist[d.seq].code_value)
     AND ocs.mnemonic_type_cd IN (dcp_cd, anc_cd))
   HEAD d.seq
    tot_count = 0, reply->clist[d.seq].synonym_found = 1
   DETAIL
    tot_count = (tot_count+ 1), stat = alterlist(reply->clist[d.seq].synonym_list,tot_count), reply->
    clist[d.seq].synonym_list[tot_count].active_ind = 1,
    reply->clist[d.seq].synonym_list[tot_count].synonym_value = ocs.mnemonic, reply->clist[d.seq].
    synonym_list[tot_count].synonym_id = ocs.synonym_id
    IF (ocs.mnemonic_type_cd=anc_cd)
     reply->clist[d.seq].synonym_list[tot_count].synonym_type = 1
    ELSE
     reply->clist[d.seq].synonym_list[tot_count].synonym_type = 2
    ENDIF
   WITH skipbedrock = 1, nocounter
  ;end select
 ENDIF
 IF ((request->load.service_resource=1))
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = orc_cnt),
    orc_resource_list orl,
    code_value cv
   PLAN (d
    WHERE (reply->clist[d.seq].orc_found=1))
    JOIN (orl
    WHERE (orl.catalog_cd=request->clist[d.seq].code_value)
     AND ((orl.active_ind=1) OR (orl.active_ind=0
     AND inactive_child=1)) )
    JOIN (cv
    WHERE cv.code_set=221
     AND cv.code_value=orl.service_resource_cd
     AND cv.active_ind=1)
   ORDER BY d.seq, orl.sequence
   HEAD d.seq
    tot_count = 0, reply->clist[d.seq].sr_found = 1
   DETAIL
    tot_count = (tot_count+ 1), stat = alterlist(reply->clist[d.seq].sr_list,tot_count), reply->
    clist[d.seq].sr_list[tot_count].active_ind = orl.active_ind,
    reply->clist[d.seq].sr_list[tot_count].code_value = orl.service_resource_cd, reply->clist[d.seq].
    sr_list[tot_count].default = orl.primary_ind, reply->clist[d.seq].sr_list[tot_count].display = cv
    .display,
    reply->clist[d.seq].sr_list[tot_count].description = cv.description, reply->clist[d.seq].sr_list[
    tot_count].cdf_meaning = cv.cdf_meaning, reply->clist[d.seq].sr_list[tot_count].sequence = orl
    .sequence
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->load.legacy_oc=1))
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = orc_cnt),
    br_oc_work b
   PLAN (d
    WHERE (reply->clist[d.seq].orc_found=1))
    JOIN (b
    WHERE (b.match_orderable_cd=request->clist[d.seq].code_value))
   HEAD d.seq
    tot_count = 0, reply->clist[d.seq].legacy_oc_found = 1
   DETAIL
    tot_count = (tot_count+ 1), stat = alterlist(reply->clist[d.seq].legacy_oc_list,tot_count), reply
    ->clist[d.seq].legacy_oc_list[tot_count].long_desc = b.long_desc,
    reply->clist[d.seq].legacy_oc_list[tot_count].short_desc = b.short_desc, reply->clist[d.seq].
    legacy_oc_list[tot_count].facility = b.facility
   WITH nocounter
  ;end select
  FOR (i = 1 TO orc_cnt)
    SET catalog_cd = 0.0
    SELECT INTO "NL:"
     FROM order_catalog oc
     WHERE (oc.concept_cki=reply->clist[i].concept_cki)
      AND (reply->clist[i].orc_found=1)
      AND (reply->clist[i].legacy_oc_found != 1)
      AND (reply->clist[i].concept_cki > "   *")
     DETAIL
      catalog_cd = oc.catalog_cd
     WITH skipbedrock = 1, nocounter
    ;end select
    IF (catalog_cd > 0)
     SELECT INTO "NL:"
      FROM br_oc_work b
      WHERE b.match_orderable_cd=catalog_cd
      HEAD REPORT
       tot_count = 0, reply->clist[i].legacy_oc_found = 1
      DETAIL
       tot_count = (tot_count+ 1), stat = alterlist(reply->clist[i].legacy_oc_list,tot_count), reply
       ->clist[i].legacy_oc_list[tot_count].long_desc = b.long_desc,
       reply->clist[i].legacy_oc_list[tot_count].short_desc = b.short_desc, reply->clist[i].
       legacy_oc_list[tot_count].facility = b.facility
      WITH nocounter
     ;end select
    ENDIF
  ENDFOR
 ENDIF
 IF ((request->load.dup_check_ind=1))
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = orc_cnt),
    dup_checking dc,
    code_value cv1,
    code_value cv2,
    code_value cv3
   PLAN (d)
    JOIN (dc
    WHERE (dc.catalog_cd=reply->clist[d.seq].code_value)
     AND dc.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=outerjoin(dc.min_behind_action_cd))
    JOIN (cv2
    WHERE cv2.code_value=outerjoin(dc.min_ahead_action_cd))
    JOIN (cv3
    WHERE cv3.code_value=outerjoin(dc.exact_hit_action_cd))
   HEAD d.seq
    stat = alterlist(reply->clist[d.seq].dlist,3), alterlist_cnt = 0, dcnt = 0
   DETAIL
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 3)
     stat = alterlist(reply->clist[d.seq].dlist,(dcnt+ 3)), alterlist_cnt = 1
    ENDIF
    dcnt = (dcnt+ 1), reply->clist[d.seq].dlist[dcnt].dup_check_level = dc.dup_check_seq, reply->
    clist[d.seq].dlist[dcnt].look_behind_action_code_value = dc.min_behind_action_cd,
    reply->clist[d.seq].dlist[dcnt].look_behind_action_display = cv1.display, reply->clist[d.seq].
    dlist[dcnt].look_behind_action_cdf_mean = cv1.cdf_meaning, reply->clist[d.seq].dlist[dcnt].
    look_behind_minutes = dc.min_behind,
    reply->clist[d.seq].dlist[dcnt].look_ahead_action_code_value = dc.min_ahead_action_cd, reply->
    clist[d.seq].dlist[dcnt].look_ahead_action_display = cv2.display, reply->clist[d.seq].dlist[dcnt]
    .look_ahead_action_cdf_mean = cv2.cdf_meaning,
    reply->clist[d.seq].dlist[dcnt].look_ahead_minutes = dc.min_ahead, reply->clist[d.seq].dlist[dcnt
    ].exact_match_action_code_value = dc.exact_hit_action_cd, reply->clist[d.seq].dlist[dcnt].
    exact_match_action_display = cv3.display,
    reply->clist[d.seq].dlist[dcnt].exact_match_action_cdf_mean = cv3.cdf_meaning
   FOOT  d.seq
    stat = alterlist(reply->clist[d.seq].dlist,dcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->load.clin_cat_ind=1))
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = orc_cnt),
    code_value cv
   PLAN (d
    WHERE (reply->clist[d.seq].clin_cat_code_value > 0))
    JOIN (cv
    WHERE (cv.code_value=reply->clist[d.seq].clin_cat_code_value))
   DETAIL
    reply->clist[d.seq].clin_cat_display = cv.display, reply->clist[d.seq].clin_cat_cdf_mean = cv
    .cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->sched_params_ind=1))
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = orc_cnt),
    dcp_entity_reltn der,
    code_value cv
   PLAN (d)
    JOIN (der
    WHERE (der.entity1_id=reply->clist[d.seq].code_value)
     AND der.entity_reltn_mean="ORC/SCHENCTP"
     AND der.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=outerjoin(der.entity2_id))
   HEAD der.entity1_id
    stat = alterlist(reply->clist[d.seq].slist,10), alterlist_cnt = 0, scnt = 0
   DETAIL
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 10)
     stat = alterlist(reply->clist[d.seq].slist,(scnt+ 10)), alterlist_cnt = 1
    ENDIF
    scnt = (scnt+ 1), reply->clist[d.seq].slist[scnt].pat_type_code_value = der.entity2_id
    IF (der.entity2_id > 0)
     reply->clist[d.seq].slist[scnt].pat_type_display = cv.display, reply->clist[d.seq].slist[scnt].
     pat_type_cdf_mean = cv.cdf_meaning
    ELSE
     reply->clist[d.seq].slist[scnt].pat_type_display = "Future"
    ENDIF
   FOOT  der.entity1_id
    stat = alterlist(reply->clist[d.seq].slist,scnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->filter_ind=1))
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = orc_cnt),
    dcp_entity_reltn der
   PLAN (d)
    JOIN (der
    WHERE (der.entity1_id=reply->clist[d.seq].code_value)
     AND der.entity1_name="ORDER_CATALOG"
     AND der.entity2_name="CODE_VALUE"
     AND ((der.entity_reltn_mean="ORC/1*") OR (((der.entity_reltn_mean="ORC/2*") OR (((der
    .entity_reltn_mean="ORC/3*") OR (((der.entity_reltn_mean="ORC/4*") OR (((der.entity_reltn_mean=
    "ORC/5*") OR (((der.entity_reltn_mean="ORC/6*") OR (((der.entity_reltn_mean="ORC/7*") OR (((der
    .entity_reltn_mean="ORC/8*") OR (((der.entity_reltn_mean="ORC/9*") OR (der.entity_reltn_mean=
    "ORC/0*")) )) )) )) )) )) )) )) ))
     AND der.active_ind=1)
   HEAD der.entity1_id
    stat = alterlist(reply->clist[d.seq].flist,10), alterlist_cnt = 0, scnt = 0
   DETAIL
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 10)
     stat = alterlist(reply->clist[d.seq].flist,(scnt+ 10)), alterlist_cnt = 1
    ENDIF
    scnt = (scnt+ 1), reply->clist[d.seq].flist[scnt].entity2_id = der.entity2_id, reply->clist[d.seq
    ].flist[scnt].entity_reltn_mean = der.entity_reltn_mean,
    reply->clist[d.seq].flist[scnt].entity2_display = der.entity2_display, reply->clist[d.seq].flist[
    scnt].rank_sequence = der.rank_sequence, reply->clist[d.seq].flist[scnt].entity2_name = der
    .entity2_name
   FOOT  der.entity1_id
    stat = alterlist(reply->clist[d.seq].flist,scnt)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO

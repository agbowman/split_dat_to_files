CREATE PROGRAM bed_ens_custom_mpage:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 id = f8
    1 components[*]
      2 id = f8
      2 mean = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE reqcompcnt = i4 WITH protect, noconstant(0)
 DECLARE stdtextcnt = i4 WITH protect, noconstant(0)
 DECLARE next_seq = i4 WITH protect, noconstant(0)
 DECLARE compcnt = i4 WITH protect, noconstant(0)
 DECLARE filtercnt = i4 WITH protect, noconstant(0)
 DECLARE defcnt = i4 WITH protect, noconstant(0)
 DECLARE textcnt = i4 WITH protect, noconstant(0)
 DECLARE new_category_id = f8 WITH protect, noconstant(0)
 DECLARE next_filter_seq = i4 WITH protect, noconstant(0)
 DECLARE offset = i4 WITH protect, noconstant(0)
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE flex_flag_value = i2 WITH protect
 RECORD temp_components(
   1 reports[*]
     2 br_datamart_report_id = f8
 )
 RECORD temp_del_components(
   1 reports[*]
     2 br_datamart_report_id = f8
 )
 RECORD stdtext(
   1 text[*]
     2 std_category_text_id = f8
     2 std_category_long_text_id = f8
     2 new_category_text_id = f8
     2 new_category_long_text_id = f8
 )
 RECORD longtext(
   1 text[*]
     2 long_text_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 long_text = vc
 )
 RECORD temp(
   1 components[*]
     2 std_comp_id = f8
     2 new_comp_id = f8
     2 status_ind = i2
     2 comp_seq = i4
     2 defaults[*]
       3 mpage_param_mean = vc
       3 mpage_param_value = vc
     2 text[*]
       3 std_comp_text_id = f8
       3 new_comp_text_id = f8
       3 std_comp_long_text_id = f8
       3 new_comp_long_text_id = f8
     2 filters[*]
       3 new_filter_id = f8
       3 denominator_ind = i2
       3 numerator_ind = i2
       3 filter_mean = vc
       3 filter_display = vc
       3 filter_seq = i4
       3 filter_category_mean = vc
       3 filter_limit = i4
       3 details[*]
         4 oe_field_meaning = vc
         4 required_ind = i2
       3 text[*]
         4 std_filter_text_id = f8
         4 new_filter_text_id = f8
         4 std_filter_long_text_id = f8
         4 new_filter_long_text_id = f8
       3 defaults[*]
         4 new_filter_default_id = f8
         4 unique_identifier = vc
         4 cv_display = vc
         4 cv_description = vc
         4 code_set = i4
         4 result_type_flag = i2
         4 qualifier_flag = i2
         4 result_value = vc
         4 order_detail_ind = i2
         4 group_name = vc
         4 group_ce_name = vc
         4 group_ce_concept_cki = vc
         4 details[*]
           5 oe_field_meaning = vc
           5 detail_value = vc
           5 detail_cki = vc
 )
 SET reply->id = request->id
 SET reqcompcnt = 0
 SET reqcompcnt = size(request->components,5)
 IF (reqcompcnt=0)
  IF ((request->action_flag=2))
   SET ierrcode = 0
   UPDATE  FROM br_datamart_category b
    SET b.category_name = request->display, b.updt_id = reqinfo->updt_id, b.updt_dt_tm = cnvtdatetime
     (curdate,curtime3),
     b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b
     .updt_cnt+ 1)
    WHERE (b.br_datamart_category_id=request->id)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = concat(
     "Error updating into br_datamart_category table")
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
  ENDIF
  GO TO exit_script
 ELSE
  SET stat = alterlist(reply->components,reqcompcnt)
  IF ((request->action_flag IN (0, 2)))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(reqcompcnt)),
     br_datamart_report r
    PLAN (d
     WHERE (request->components[d.seq].action_flag=2))
     JOIN (r
     WHERE (r.br_datamart_report_id=request->components[d.seq].id))
    DETAIL
     reply->components[d.seq].id = r.br_datamart_report_id, reply->components[d.seq].mean = r
     .report_mean
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((request->action_flag=1))
  SET stdtextcnt = 0
  SELECT INTO "nl:"
   FROM br_datamart_category c,
    br_datamart_text t,
    br_long_text l
   PLAN (c
    WHERE c.category_type_flag=6
     AND c.category_mean="MP_VB_STD_COMP")
    JOIN (t
    WHERE t.br_datamart_category_id=c.br_datamart_category_id
     AND t.br_datamart_report_id=0
     AND t.br_datamart_filter_id=0)
    JOIN (l
    WHERE l.parent_entity_name="BR_DATAMART_TEXT"
     AND l.parent_entity_id=t.br_datamart_text_id)
   DETAIL
    stdtextcnt = (stdtextcnt+ 1), stat = alterlist(stdtext->text,stdtextcnt), stdtext->text[
    stdtextcnt].std_category_text_id = t.br_datamart_text_id,
    stdtext->text[stdtextcnt].std_category_long_text_id = l.long_text_id
   WITH nocounter
  ;end select
  IF (stdtextcnt > 0)
   SELECT INTO "nl:"
    j = seq(bedrock_seq,nextval)
    FROM (dummyt d  WITH seq = value(stdtextcnt)),
     dual dd
    PLAN (d)
     JOIN (dd)
    DETAIL
     stdtext->text[d.seq].new_category_text_id = cnvtreal(j)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    j = seq(bedrock_seq,nextval)
    FROM (dummyt d  WITH seq = value(stdtextcnt)),
     dual dd
    PLAN (d)
     JOIN (dd)
    DETAIL
     stdtext->text[d.seq].new_category_long_text_id = cnvtreal(j)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET temp_comp_cnt = 0
 SET temp_del_comp_cnt = 0
 SELECT INTO "nl:"
  FROM br_datamart_report bdr
  WHERE (bdr.br_datamart_category_id=request->id)
   AND bdr.br_datamart_report_id > 0.0
  DETAIL
   temp_comp_cnt = (temp_comp_cnt+ 1), stat = alterlist(temp_components->reports,temp_comp_cnt),
   temp_components->reports[temp_comp_cnt].br_datamart_report_id = bdr.br_datamart_report_id
  WITH nocounter
 ;end select
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE found = i2 WITH protect, noconstant(0)
 FOR (x = 1 TO temp_comp_cnt)
   SET found = - (1)
   SET found = locateval(i,1,size(request->components,5),temp_components->reports[x].
    br_datamart_report_id,request->components[i].id)
   IF (found=0)
    SET temp_del_comp_cnt = (temp_del_comp_cnt+ 1)
    SET stat = alterlist(temp_del_components->reports,temp_del_comp_cnt)
    SET temp_del_components->reports[temp_del_comp_cnt].br_datamart_report_id = temp_components->
    reports[x].br_datamart_report_id
   ENDIF
 ENDFOR
 IF (size(temp_del_components->reports,5) > 0)
  EXECUTE bed_del_datamart_reports  WITH replace("REQUEST",temp_del_components)
 ENDIF
 SET next_seq = 0
 SELECT INTO "nl:"
  FROM br_datamart_report b
  WHERE (b.br_datamart_category_id=request->id)
  ORDER BY b.report_seq
  DETAIL
   next_seq = b.report_seq
  WITH nocounter
 ;end select
 SET compcnt = 0
 SELECT INTO "nl:"
  j = seq(bedrock_seq,nextval)
  FROM (dummyt d  WITH seq = value(reqcompcnt)),
   dual dd,
   br_datamart_report b
  PLAN (d
   WHERE (request->components[d.seq].action_flag=1))
   JOIN (dd)
   JOIN (b
   WHERE (b.br_datamart_report_id=request->components[d.seq].id))
  DETAIL
   reply->components[d.seq].id = cnvtreal(j), reply->components[d.seq].mean = b.report_mean, compcnt
    = (compcnt+ 1),
   stat = alterlist(temp->components,compcnt), temp->components[compcnt].std_comp_id = request->
   components[d.seq].id, temp->components[compcnt].new_comp_id = cnvtreal(j),
   temp->components[compcnt].status_ind = request->components[d.seq].status_ind, next_seq = (next_seq
   + 1), temp->components[compcnt].comp_seq = next_seq
  WITH nocounter
 ;end select
 IF (compcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(compcnt)),
    br_datamart_report_default rd
   PLAN (d)
    JOIN (rd
    WHERE (rd.br_datamart_report_id=temp->components[d.seq].std_comp_id))
   ORDER BY d.seq
   HEAD d.seq
    dcnt = 0
   DETAIL
    dcnt = (dcnt+ 1), stat = alterlist(temp->components[d.seq].defaults,dcnt), temp->components[d.seq
    ].defaults[dcnt].mpage_param_mean = rd.mpage_param_mean,
    temp->components[d.seq].defaults[dcnt].mpage_param_value = rd.mpage_param_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(compcnt)),
    br_datamart_text t,
    br_long_text l
   PLAN (d)
    JOIN (t
    WHERE (t.br_datamart_report_id=temp->components[d.seq].std_comp_id))
    JOIN (l
    WHERE l.parent_entity_name="BR_DATAMART_TEXT"
     AND l.parent_entity_id=t.br_datamart_text_id)
   ORDER BY d.seq
   HEAD d.seq
    tcnt = 0
   DETAIL
    tcnt = (tcnt+ 1), stat = alterlist(temp->components[d.seq].text,tcnt), temp->components[d.seq].
    text[tcnt].std_comp_text_id = t.br_datamart_text_id,
    temp->components[d.seq].text[tcnt].std_comp_long_text_id = l.long_text_id
   WITH nocounter
  ;end select
  IF ((request->action_flag IN (0, 2)))
   SELECT INTO "nl:"
    FROM br_datamart_filter f
    WHERE (f.br_datamart_category_id=request->id)
    ORDER BY f.filter_seq DESC
    HEAD f.br_datamart_category_id
     next_filter_seq = f.filter_seq
    WITH nocounter
   ;end select
  ENDIF
  SET offset = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(compcnt)),
    br_datamart_report_filter_r r,
    br_datamart_filter f,
    br_datamart_category c,
    br_datamart_filter_detail fd,
    br_datamart_text t,
    br_long_text l,
    br_datamart_default def,
    br_datamart_default_detail defdet
   PLAN (d)
    JOIN (r
    WHERE (r.br_datamart_report_id=temp->components[d.seq].std_comp_id))
    JOIN (f
    WHERE f.br_datamart_filter_id=r.br_datamart_filter_id)
    JOIN (c
    WHERE c.br_datamart_category_id=f.br_datamart_category_id)
    JOIN (fd
    WHERE fd.br_datamart_filter_id=outerjoin(r.br_datamart_filter_id))
    JOIN (t
    WHERE t.br_datamart_filter_id=outerjoin(r.br_datamart_filter_id))
    JOIN (l
    WHERE l.parent_entity_id=outerjoin(t.br_datamart_text_id)
     AND l.parent_entity_name=outerjoin("BR_DATAMART_TEXT"))
    JOIN (def
    WHERE def.br_datamart_filter_id=outerjoin(r.br_datamart_filter_id))
    JOIN (defdet
    WHERE defdet.br_datamart_default_id=outerjoin(def.br_datamart_default_id))
   ORDER BY c.br_datamart_category_id, d.seq, f.br_datamart_filter_id,
    fd.br_datamart_filter_detail_id, t.br_datamart_text_id, def.br_datamart_default_id,
    defdet.br_datamart_default_detail_id
   HEAD c.br_datamart_category_id
    offset = next_filter_seq
   HEAD d.seq
    fcnt = 0
   HEAD f.br_datamart_filter_id
    fcnt = (fcnt+ 1), stat = alterlist(temp->components[d.seq].filters,fcnt), next_filter_seq = (f
    .filter_seq+ offset),
    temp->components[d.seq].filters[fcnt].denominator_ind = r.denominator_ind, temp->components[d.seq
    ].filters[fcnt].numerator_ind = r.numerator_ind, temp->components[d.seq].filters[fcnt].
    filter_mean = f.filter_mean,
    temp->components[d.seq].filters[fcnt].filter_display = f.filter_display, temp->components[d.seq].
    filters[fcnt].filter_seq = next_filter_seq, temp->components[d.seq].filters[fcnt].
    filter_category_mean = f.filter_category_mean,
    temp->components[d.seq].filters[fcnt].filter_limit = f.filter_limit, dcnt = 0, tcnt = 0,
    defcnt = 0
   HEAD fd.br_datamart_filter_detail_id
    IF (fd.br_datamart_filter_detail_id > 0)
     dcnt = (dcnt+ 1), stat = alterlist(temp->components[d.seq].filters[fcnt].details,dcnt), temp->
     components[d.seq].filters[fcnt].details[dcnt].oe_field_meaning = fd.oe_field_meaning,
     temp->components[d.seq].filters[fcnt].details[dcnt].required_ind = fd.required_ind
    ENDIF
   HEAD t.br_datamart_text_id
    IF (t.br_datamart_text_id > 0)
     tcnt = (tcnt+ 1), stat = alterlist(temp->components[d.seq].filters[fcnt].text,tcnt), temp->
     components[d.seq].filters[fcnt].text[tcnt].std_filter_text_id = t.br_datamart_text_id,
     temp->components[d.seq].filters[fcnt].text[tcnt].std_filter_long_text_id = l.long_text_id
    ENDIF
   HEAD def.br_datamart_default_id
    IF (def.br_datamart_default_id > 0)
     defcnt = (defcnt+ 1), stat = alterlist(temp->components[d.seq].filters[fcnt].defaults,defcnt),
     temp->components[d.seq].filters[fcnt].defaults[defcnt].unique_identifier = def.unique_identifier,
     temp->components[d.seq].filters[fcnt].defaults[defcnt].cv_display = def.cv_display, temp->
     components[d.seq].filters[fcnt].defaults[defcnt].cv_description = def.cv_description, temp->
     components[d.seq].filters[fcnt].defaults[defcnt].code_set = def.code_set,
     temp->components[d.seq].filters[fcnt].defaults[defcnt].result_type_flag = def.result_type_flag,
     temp->components[d.seq].filters[fcnt].defaults[defcnt].qualifier_flag = def.qualifier_flag, temp
     ->components[d.seq].filters[fcnt].defaults[defcnt].result_value = def.result_value,
     temp->components[d.seq].filters[fcnt].defaults[defcnt].order_detail_ind = def.order_detail_ind,
     temp->components[d.seq].filters[fcnt].defaults[defcnt].group_name = def.group_name, temp->
     components[d.seq].filters[fcnt].defaults[defcnt].group_ce_name = def.group_ce_name,
     temp->components[d.seq].filters[fcnt].defaults[defcnt].group_ce_concept_cki = def
     .group_ce_concept_cki
    ENDIF
    defdetcnt = 0
   HEAD defdet.br_datamart_default_detail_id
    IF (defdet.br_datamart_default_detail_id > 0)
     defdetcnt = (defdetcnt+ 1), stat = alterlist(temp->components[d.seq].filters[fcnt].defaults,
      defdetcnt), temp->components[d.seq].filters[fcnt].defaults[defcnt].details[defdetcnt].
     oe_field_meaning = defdet.oe_field_meaning,
     temp->components[d.seq].filters[fcnt].defaults[defcnt].details[defdetcnt].detail_value = defdet
     .detail_value, temp->components[d.seq].filters[fcnt].defaults[defcnt].details[defdetcnt].
     detail_cki = defdet.detail_cki
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 FOR (c = 1 TO compcnt)
   SET textcnt = 0
   SET textcnt = size(temp->components[c].text,5)
   IF (textcnt > 0)
    SELECT INTO "nl:"
     j = seq(bedrock_seq,nextval)
     FROM (dummyt d  WITH seq = value(textcnt)),
      dual dd
     PLAN (d)
      JOIN (dd)
     DETAIL
      temp->components[c].text[d.seq].new_comp_text_id = cnvtreal(j)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     j = seq(bedrock_seq,nextval)
     FROM (dummyt d  WITH seq = value(textcnt)),
      dual dd
     PLAN (d)
      JOIN (dd)
     DETAIL
      temp->components[c].text[d.seq].new_comp_long_text_id = cnvtreal(j)
     WITH nocounter
    ;end select
   ENDIF
   SET filtercnt = 0
   SET filtercnt = size(temp->components[c].filters,5)
   IF (filtercnt > 0)
    SELECT INTO "nl:"
     j = seq(bedrock_seq,nextval)
     FROM (dummyt d  WITH seq = value(filtercnt)),
      dual dd
     PLAN (d)
      JOIN (dd)
     DETAIL
      temp->components[c].filters[d.seq].new_filter_id = cnvtreal(j)
     WITH nocounter
    ;end select
    FOR (f = 1 TO filtercnt)
      SET defcnt = 0
      SET defcnt = size(temp->components[c].filters[f].defaults,5)
      IF (defcnt > 0)
       SELECT INTO "nl:"
        j = seq(bedrock_seq,nextval)
        FROM (dummyt d  WITH seq = value(defcnt)),
         dual dd
        PLAN (d)
         JOIN (dd)
        DETAIL
         temp->components[c].filters[f].defaults[d.seq].new_filter_default_id = cnvtreal(j)
        WITH nocounter
       ;end select
      ENDIF
      SET textcnt = 0
      SET textcnt = size(temp->components[c].filters[f].text,5)
      IF (textcnt > 0)
       SELECT INTO "nl:"
        j = seq(bedrock_seq,nextval)
        FROM (dummyt d  WITH seq = value(textcnt)),
         dual dd
        PLAN (d)
         JOIN (dd)
        DETAIL
         temp->components[c].filters[f].text[d.seq].new_filter_text_id = cnvtreal(j)
        WITH nocounter
       ;end select
       SELECT INTO "nl:"
        j = seq(bedrock_seq,nextval)
        FROM (dummyt d  WITH seq = value(textcnt)),
         dual dd
        PLAN (d)
         JOIN (dd)
        DETAIL
         temp->components[c].filters[f].text[d.seq].new_filter_long_text_id = cnvtreal(j)
        WITH nocounter
       ;end select
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 IF ((request->action_flag=1))
  SET new_category_id = 0.0
  SELECT INTO "NL:"
   j = seq(bedrock_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    new_category_id = cnvtreal(j)
   WITH format, counter
  ;end select
  SET flex_flag_value = 1
  IF ((((request->layout_flag=0)) OR ((((request->layout_flag=1)) OR ((((request->layout_flag=3)) OR
  ((((request->layout_flag=4)) OR ((((request->layout_flag=5)) OR ((((request->layout_flag=6)) OR (((
  (request->layout_flag=7)) OR ((((request->layout_flag=8)) OR ((((request->layout_flag=9)) OR ((
  request->layout_flag=10))) )) )) )) )) )) )) )) )) )
   SET flex_flag_value = 3
  ENDIF
  SET ierrcode = 0
  INSERT  FROM br_datamart_category b
   SET b.br_datamart_category_id = new_category_id, b.category_name = request->display, b
    .category_mean = request->identifier,
    b.category_type_flag = 1, b.beg_effective_dt_tm = null, b.end_effective_dt_tm = null,
    b.category_topic_mean = " ", b.script_name = " ", b.flex_flag = flex_flag_value,
    b.layout_flag = validate(request->layout_flag,0), b.reliability_score_ind = 0, b
    .baseline_target_ind = 0,
    b.viewpoint_capable_ind = 1, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
    updt_applctx
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into br_datamart_category table")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SET reply->id = new_category_id
  IF (stdtextcnt > 0)
   FOR (t = 1 TO stdtextcnt)
     SET ierrcode = 0
     INSERT  FROM br_datamart_text bt
      (bt.br_datamart_text_id, bt.br_datamart_category_id, bt.br_datamart_filter_id,
      bt.br_datamart_report_id, bt.text_type_mean, bt.text_seq,
      bt.updt_applctx, bt.updt_cnt, bt.updt_dt_tm,
      bt.updt_id, bt.updt_task)(SELECT
       stdtext->text[t].new_category_text_id, new_category_id, 0,
       0, bt2.text_type_mean, bt2.text_seq,
       reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime),
       reqinfo->updt_id, reqinfo->updt_task
       FROM br_datamart_text bt2
       WHERE (bt2.br_datamart_text_id=stdtext->text[t].std_category_text_id))
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat(
       "Error inserting into br_datamart_text table")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
     SET ierrcode = 0
     SET textlength = 0
     SELECT INTO "nl:"
      FROM br_long_text bt
      PLAN (bt
       WHERE (bt.long_text_id=stdtext->text[t].std_category_long_text_id))
      HEAD bt.long_text_id
       textlength = (textlength+ 1), stat = alterlist(longtext->text,textlength)
      DETAIL
       longtext->text[textlength].long_text_id = stdtext->text[t].new_category_long_text_id, longtext
       ->text[textlength].parent_entity_name = bt.parent_entity_name, longtext->text[textlength].
       parent_entity_id = stdtext->text[t].new_category_text_id,
       longtext->text[textlength].long_text = bt.long_text
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat(
       "Error selecting from br_long_text table.")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
     INSERT  FROM (dummyt d  WITH seq = textlength),
       br_long_text bt
      SET bt.long_text_id = longtext->text[d.seq].long_text_id, bt.parent_entity_name = longtext->
       text[d.seq].parent_entity_name, bt.parent_entity_id = longtext->text[d.seq].parent_entity_id,
       bt.long_text = longtext->text[d.seq].long_text, bt.updt_applctx = reqinfo->updt_applctx, bt
       .updt_cnt = 0,
       bt.updt_dt_tm = cnvtdatetime(curdate,curtime), bt.updt_id = reqinfo->updt_id, bt.updt_task =
       reqinfo->updt_task
      PLAN (d)
       JOIN (bt)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat(
       "Error inserting into br_long_text table")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
   ENDFOR
  ENDIF
  SET ierrcode = 0
  INSERT  FROM br_datamart_value v,
    (dummyt d  WITH seq = compcnt)
   SET v.br_datamart_value_id = seq(bedrock_seq,nextval), v.br_datamart_category_id = new_category_id,
    v.parent_entity_name = "BR_DATAMART_REPORT",
    v.parent_entity_id = temp->components[d.seq].new_comp_id, v.mpage_param_mean =
    "mp_vb_component_status", v.mpage_param_value = cnvtstring(temp->components[d.seq].status_ind),
    v.updt_dt_tm = cnvtdatetime(curdate,curtime3), v.updt_id = reqinfo->updt_id, v.updt_task =
    reqinfo->updt_task,
    v.updt_cnt = 0, v.updt_applctx = reqinfo->updt_applctx, v.beg_effective_dt_tm = cnvtdatetime(
     curdate,curtime3),
    v.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d)
    JOIN (v)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into br_datamart_value table")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ELSE
  SET new_category_id = request->id
  SET flex_flag_value = 1
  IF ((((request->layout_flag=0)) OR ((((request->layout_flag=1)) OR ((((request->layout_flag=3)) OR
  ((((request->layout_flag=4)) OR ((((request->layout_flag=5)) OR ((((request->layout_flag=6)) OR (((
  (request->layout_flag=7)) OR ((((request->layout_flag=8)) OR ((((request->layout_flag=9)) OR ((
  request->layout_flag=10))) )) )) )) )) )) )) )) )) )
   SET flex_flag_value = 3
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM br_datamart_category b
   SET b.category_name = request->display, b.updt_id = reqinfo->updt_id, b.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b
    .updt_cnt+ 1),
    b.flex_flag = flex_flag_value
   WHERE (b.br_datamart_category_id=request->id)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error updating into br_datamart_category table")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  INSERT  FROM br_datamart_value v,
    (dummyt d  WITH seq = compcnt)
   SET v.br_datamart_value_id = seq(bedrock_seq,nextval), v.br_datamart_category_id = request->id, v
    .parent_entity_name = "BR_DATAMART_REPORT",
    v.parent_entity_id = temp->components[d.seq].new_comp_id, v.mpage_param_mean =
    "mp_vb_component_status", v.mpage_param_value = cnvtstring(temp->components[d.seq].status_ind),
    v.updt_dt_tm = cnvtdatetime(curdate,curtime3), v.updt_id = reqinfo->updt_id, v.updt_task =
    reqinfo->updt_task,
    v.updt_cnt = 0, v.updt_applctx = reqinfo->updt_applctx, v.beg_effective_dt_tm = cnvtdatetime(
     curdate,curtime3),
    v.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d)
    JOIN (v)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into br_datamart_value table")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM br_datamart_value v,
    (dummyt d  WITH seq = value(reqcompcnt))
   SET v.mpage_param_value = cnvtstring(request->components[d.seq].status_ind), v.updt_id = reqinfo->
    updt_id, v.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    v.updt_task = reqinfo->updt_task, v.updt_applctx = reqinfo->updt_applctx, v.updt_cnt = (v
    .updt_cnt+ 1)
   PLAN (d
    WHERE (request->components[d.seq].action_flag=2))
    JOIN (v
    WHERE (v.br_datamart_category_id=request->id)
     AND v.parent_entity_name="BR_DATAMART_REPORT"
     AND (v.parent_entity_id=request->components[d.seq].id)
     AND v.mpage_param_mean="mp_vb_component_status")
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error updating into br_datamart_value table")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (c = 1 TO compcnt)
   SET ierrcode = 0
   INSERT  FROM br_datamart_report br
    (br.br_datamart_report_id, br.br_datamart_category_id, br.report_name,
    br.report_mean, br.report_seq, br.baseline_value,
    br.target_value, br.lighthouse_value, br.mpage_pos_flag,
    br.mpage_pos_seq, br.mpage_label_ind, br.mpage_nbr_label_ind,
    br.mpage_link_ind, br.mpage_exp_collapse_ind, br.mpage_lookback_ind,
    br.mpage_max_results_ind, br.mpage_scroll_ind, br.mpage_truncate_ind,
    br.cond_report_mean, br.mpage_add_label_ind, br.mpage_default_ind,
    br.mpage_date_format_ind, br.updt_applctx, br.updt_cnt,
    br.updt_dt_tm, br.updt_id, br.updt_task)(SELECT
     temp->components[c].new_comp_id, new_category_id, br2.report_name,
     br2.report_mean, temp->components[c].comp_seq, br2.baseline_value,
     br2.target_value, br2.lighthouse_value, br2.mpage_pos_flag,
     br2.mpage_pos_seq, br2.mpage_label_ind, br2.mpage_nbr_label_ind,
     br2.mpage_link_ind, br2.mpage_exp_collapse_ind, br2.mpage_lookback_ind,
     br2.mpage_max_results_ind, br2.mpage_scroll_ind, br2.mpage_truncate_ind,
     br2.cond_report_mean, br2.mpage_add_label_ind, br2.mpage_default_ind,
     br2.mpage_date_format_ind, reqinfo->updt_applctx, 0,
     cnvtdatetime(curdate,curtime), reqinfo->updt_id, reqinfo->updt_task
     FROM br_datamart_report br2
     WHERE (br2.br_datamart_report_id=temp->components[c].std_comp_id))
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = concat(
     "Error inserting into br_datamart_report table")
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
   SET textcnt = size(temp->components[c].text,5)
   FOR (t = 1 TO textcnt)
     SET ierrcode = 0
     INSERT  FROM br_datamart_text bt
      (bt.br_datamart_text_id, bt.br_datamart_category_id, bt.br_datamart_filter_id,
      bt.br_datamart_report_id, bt.text_type_mean, bt.text_seq,
      bt.updt_applctx, bt.updt_cnt, bt.updt_dt_tm,
      bt.updt_id, bt.updt_task)(SELECT
       temp->components[c].text[t].new_comp_text_id, new_category_id, 0,
       temp->components[c].new_comp_id, bt2.text_type_mean, bt2.text_seq,
       reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime),
       reqinfo->updt_id, reqinfo->updt_task
       FROM br_datamart_text bt2
       WHERE (bt2.br_datamart_text_id=temp->components[c].text[t].std_comp_text_id))
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat(
       "Error inserting into br_datamart_text table")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
     SET ierrcode = 0
     SET textlength = 0
     SET stat = alterlist(longtext->text,0)
     SELECT INTO "nl:"
      FROM br_long_text bt
      PLAN (bt
       WHERE (bt.long_text_id=temp->components[c].text[t].std_comp_long_text_id))
      HEAD bt.long_text_id
       textlength = (textlength+ 1), stat = alterlist(longtext->text,textlength)
      DETAIL
       longtext->text[textlength].long_text_id = temp->components[c].text[t].new_comp_long_text_id,
       longtext->text[textlength].parent_entity_name = bt.parent_entity_name, longtext->text[
       textlength].parent_entity_id = temp->components[c].text[t].new_comp_text_id,
       longtext->text[textlength].long_text = bt.long_text
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat(
       "Error selecting from br_long_text table.")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
     INSERT  FROM (dummyt d  WITH seq = textlength),
       br_long_text bt
      SET bt.long_text_id = longtext->text[d.seq].long_text_id, bt.parent_entity_name = longtext->
       text[d.seq].parent_entity_name, bt.parent_entity_id = longtext->text[d.seq].parent_entity_id,
       bt.long_text = longtext->text[d.seq].long_text, bt.updt_applctx = reqinfo->updt_applctx, bt
       .updt_cnt = 0,
       bt.updt_dt_tm = cnvtdatetime(curdate,curtime), bt.updt_id = reqinfo->updt_id, bt.updt_task =
       reqinfo->updt_task
      PLAN (d)
       JOIN (bt)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat(
       "Error inserting into br_long_text table")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
   ENDFOR
   SET defcnt = 0
   SET defcnt = size(temp->components[c].defaults,5)
   IF (defcnt > 0)
    SET ierrcode = 0
    INSERT  FROM br_datamart_report_default rd,
      (dummyt d  WITH seq = defcnt)
     SET rd.br_datamart_report_default_id = seq(bedrock_seq,nextval), rd.br_datamart_report_id = temp
      ->components[c].new_comp_id, rd.mpage_param_mean = temp->components[c].defaults[d.seq].
      mpage_param_mean,
      rd.mpage_param_value = temp->components[c].defaults[d.seq].mpage_param_value, rd.updt_dt_tm =
      cnvtdatetime(curdate,curtime3), rd.updt_id = reqinfo->updt_id,
      rd.updt_task = reqinfo->updt_task, rd.updt_cnt = 0, rd.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (rd)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error inserting into br_datamart_report_default table")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   SET filtercnt = 0
   SET filtercnt = size(temp->components[c].filters,5)
   IF (filtercnt > 0)
    SET ierrcode = 0
    INSERT  FROM br_datamart_filter f,
      (dummyt d  WITH seq = filtercnt)
     SET f.br_datamart_filter_id = temp->components[c].filters[d.seq].new_filter_id, f
      .br_datamart_category_id = new_category_id, f.filter_mean = temp->components[c].filters[d.seq].
      filter_mean,
      f.filter_display = temp->components[c].filters[d.seq].filter_display, f.filter_seq = temp->
      components[c].filters[d.seq].filter_seq, f.filter_category_mean = temp->components[c].filters[d
      .seq].filter_category_mean,
      f.filter_limit = temp->components[c].filters[d.seq].filter_limit, f.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), f.updt_id = reqinfo->updt_id,
      f.updt_task = reqinfo->updt_task, f.updt_cnt = 0, f.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (f)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error inserting into br_datamart_filter table")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    INSERT  FROM br_datamart_report_filter_r r,
      (dummyt d  WITH seq = filtercnt)
     SET r.br_datamart_report_filter_r_id = seq(bedrock_seq,nextval), r.br_datamart_filter_id = temp
      ->components[c].filters[d.seq].new_filter_id, r.denominator_ind = temp->components[c].filters[d
      .seq].denominator_ind,
      r.numerator_ind = temp->components[c].filters[d.seq].numerator_ind, r.br_datamart_report_id =
      temp->components[c].new_comp_id, r.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task, r.updt_cnt = 0,
      r.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (r)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error inserting into br_datamart_report_filter_r table")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    INSERT  FROM br_datamart_filter_detail fd,
      (dummyt d  WITH seq = filtercnt),
      (dummyt d2  WITH seq = 1)
     SET fd.br_datamart_filter_detail_id = seq(bedrock_seq,nextval), fd.br_datamart_filter_id = temp
      ->components[c].filters[d.seq].new_filter_id, fd.oe_field_meaning = temp->components[c].
      filters[d.seq].details[d2.seq].oe_field_meaning,
      fd.required_ind = temp->components[c].filters[d.seq].details[d2.seq].required_ind, fd
      .updt_dt_tm = cnvtdatetime(curdate,curtime3), fd.updt_id = reqinfo->updt_id,
      fd.updt_task = reqinfo->updt_task, fd.updt_cnt = 0, fd.updt_applctx = reqinfo->updt_applctx
     PLAN (d
      WHERE maxrec(d2,size(temp->components[c].filters[d.seq].details,5)))
      JOIN (d2)
      JOIN (fd)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error inserting into br_datamart_filter_detail table")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    INSERT  FROM br_datamart_default fd,
      (dummyt d  WITH seq = filtercnt),
      (dummyt d2  WITH seq = 1)
     SET fd.br_datamart_default_id = temp->components[c].filters[d.seq].defaults[d2.seq].
      new_filter_default_id, fd.br_datamart_filter_id = temp->components[c].filters[d.seq].
      new_filter_id, fd.unique_identifier = temp->components[c].filters[d.seq].defaults[d2.seq].
      unique_identifier,
      fd.cv_display = temp->components[c].filters[d.seq].defaults[d2.seq].cv_display, fd
      .cv_description = temp->components[c].filters[d.seq].defaults[d2.seq].cv_description, fd
      .code_set = temp->components[c].filters[d.seq].defaults[d2.seq].code_set,
      fd.result_type_flag = temp->components[c].filters[d.seq].defaults[d2.seq].result_type_flag, fd
      .qualifier_flag = temp->components[c].filters[d.seq].defaults[d2.seq].qualifier_flag, fd
      .result_value = temp->components[c].filters[d.seq].defaults[d2.seq].result_value,
      fd.order_detail_ind = temp->components[c].filters[d.seq].defaults[d2.seq].order_detail_ind, fd
      .group_name = temp->components[c].filters[d.seq].defaults[d2.seq].group_name, fd.group_ce_name
       = temp->components[c].filters[d.seq].defaults[d2.seq].group_ce_name,
      fd.group_ce_concept_cki = temp->components[c].filters[d.seq].defaults[d2.seq].
      group_ce_concept_cki, fd.updt_dt_tm = cnvtdatetime(curdate,curtime3), fd.updt_id = reqinfo->
      updt_id,
      fd.updt_task = reqinfo->updt_task, fd.updt_cnt = 0, fd.updt_applctx = reqinfo->updt_applctx
     PLAN (d
      WHERE maxrec(d2,size(temp->components[c].filters[d.seq].defaults,5)))
      JOIN (d2)
      JOIN (fd)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error inserting into br_datamart_default table")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    FOR (f = 1 TO filtercnt)
      SET defcnt = 0.0
      SET defcnt = size(temp->components[c].filters[f].defaults,5)
      IF (defcnt > 0)
       SET ierrcode = 0
       INSERT  FROM br_datamart_default_detail fd,
         (dummyt d  WITH seq = defcnt),
         (dummyt d2  WITH seq = 1)
        SET fd.br_datamart_default_detail_id = seq(bedrock_seq,nextval), fd.br_datamart_default_id =
         temp->components[c].filters[f].defaults[d.seq].new_filter_default_id, fd.oe_field_meaning =
         temp->components[c].filters[f].defaults[d.seq].details[d2.seq].oe_field_meaning,
         fd.detail_value = temp->components[c].filters[f].defaults[d.seq].details[d2.seq].
         detail_value, fd.detail_cki = temp->components[c].filters[f].defaults[d.seq].details[d2.seq]
         .detail_cki, fd.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         fd.updt_id = reqinfo->updt_id, fd.updt_task = reqinfo->updt_task, fd.updt_cnt = 0,
         fd.updt_applctx = reqinfo->updt_applctx
        PLAN (d
         WHERE maxrec(d2,size(temp->components[c].filters[f].defaults[d.seq].details,5)))
         JOIN (d2)
         JOIN (fd)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->status_data.subeventstatus[1].targetobjectname = concat(
         "Error inserting into br_datamart_default_detail table")
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ENDIF
      ENDIF
      SET textcnt = size(temp->components[c].filters[f].text,5)
      FOR (t = 1 TO textcnt)
        SET ierrcode = 0
        INSERT  FROM br_datamart_text bt
         (bt.br_datamart_text_id, bt.br_datamart_category_id, bt.br_datamart_filter_id,
         bt.br_datamart_report_id, bt.text_type_mean, bt.text_seq,
         bt.updt_applctx, bt.updt_cnt, bt.updt_dt_tm,
         bt.updt_id, bt.updt_task)(SELECT
          temp->components[c].filters[f].text[t].new_filter_text_id, new_category_id, temp->
          components[c].filters[f].new_filter_id,
          0, bt2.text_type_mean, bt2.text_seq,
          reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime),
          reqinfo->updt_id, reqinfo->updt_task
          FROM br_datamart_text bt2
          WHERE (bt2.br_datamart_text_id=temp->components[c].filters[f].text[t].std_filter_text_id))
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET error_flag = "Y"
         SET reply->status_data.subeventstatus[1].targetobjectname = concat(
          "Error inserting into br_datamart_text table")
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
         GO TO exit_script
        ENDIF
        SET ierrcode = 0
        SET textlength = 0
        SET stat = alterlist(longtext->text,0)
        SELECT INTO "nl:"
         FROM br_long_text bt
         PLAN (bt
          WHERE (bt.long_text_id=temp->components[c].filters[f].text[t].std_filter_long_text_id))
         HEAD bt.long_text_id
          textlength = (textlength+ 1), stat = alterlist(longtext->text,textlength)
         DETAIL
          longtext->text[textlength].long_text_id = temp->components[c].filters[f].text[t].
          new_filter_long_text_id, longtext->text[textlength].parent_entity_name = bt
          .parent_entity_name, longtext->text[textlength].parent_entity_id = temp->components[c].
          filters[f].text[t].new_filter_text_id,
          longtext->text[textlength].long_text = bt.long_text
         WITH nocounter
        ;end select
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET error_flag = "Y"
         SET reply->status_data.subeventstatus[1].targetobjectname = concat(
          "Error selecting br_long_text table.")
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
         GO TO exit_script
        ENDIF
        INSERT  FROM (dummyt d  WITH seq = textlength),
          br_long_text bt
         SET bt.long_text_id = longtext->text[d.seq].long_text_id, bt.parent_entity_name = longtext->
          text[d.seq].parent_entity_name, bt.parent_entity_id = longtext->text[d.seq].
          parent_entity_id,
          bt.long_text = longtext->text[d.seq].long_text, bt.updt_applctx = reqinfo->updt_applctx, bt
          .updt_cnt = 0,
          bt.updt_dt_tm = cnvtdatetime(curdate,curtime), bt.updt_id = reqinfo->updt_id, bt.updt_task
           = reqinfo->updt_task
         PLAN (d)
          JOIN (bt)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET error_flag = "Y"
         SET reply->status_data.subeventstatus[1].targetobjectname = concat(
          "Error inserting br_long_text table")
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
         GO TO exit_script
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
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

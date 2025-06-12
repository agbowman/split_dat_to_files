CREATE PROGRAM br_datamart_std_default_config:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting <br_datamart_std_default_config.prg> script"
 FREE SET del_ids
 RECORD del_ids(
   1 ids[*]
     2 id = f8
     2 filter_id = f8
 )
 FREE RECORD custom_filters
 RECORD custom_filters(
   1 list_0[*]
     2 filterid = f8
     2 defaultid = f8
     2 detailind = i2
     2 group_name = vc
     2 group_ce_r = vc
     2 group_ce_concept_cki = vc
     2 unique_identifier = vc
     2 short_name = vc
     2 long_name = vc
     2 code_set = vc
     2 result_type = vc
     2 qualifier = vc
     2 result_value = vc
     2 oe_field_meaning1 = vc
     2 oe_detail_value1 = vc
     2 oe_detail_cki1 = vc
     2 oe_field_meaning2 = vc
     2 oe_detail_value2 = vc
     2 oe_detail_cki2 = vc
     2 oe_field_meaning3 = vc
     2 oe_detail_value3 = vc
     2 oe_detail_cki3 = vc
     2 oe_field_meaning4 = vc
     2 oe_detail_value4 = vc
     2 oe_detail_cki4 = vc
 )
 DECLARE del_cnt = i4 WITH noconstant(0), protect
 DECLARE cnt = i4 WITH noconstant(0), protect
 DECLARE customfiltercnt = i4 WITH noconstant(0), protect
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 SET cnt = size(requestin->list_0,5)
 IF (cnt=0)
  GO TO exit_script
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: <br_datamart_std_default_config.prg> script"
 ENDIF
 DELETE  FROM br_datamart_default_detail dd
  WHERE dd.br_datamart_default_id IN (
  (SELECT
   d.br_datamart_default_id
   FROM br_datamart_category c,
    br_datamart_filter f,
    br_datamart_default d
   WHERE c.category_mean=cnvtupper(requestin->list_0[1].topic_mean)
    AND f.br_datamart_category_id=c.br_datamart_category_id
    AND d.br_datamart_filter_id=f.br_datamart_filter_id))
  WITH nocounter
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure deleting details >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM br_datamart_default d
  WHERE d.br_datamart_filter_id IN (
  (SELECT
   f.br_datamart_filter_id
   FROM br_datamart_category c,
    br_datamart_filter f
   WHERE c.category_mean=cnvtupper(requestin->list_0[1].topic_mean)
    AND f.br_datamart_category_id=c.br_datamart_category_id))
  WITH nocounter
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure deleting defaults >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 FREE RECORD br_existsinfo
 RECORD br_existsinfo(
   1 list_0[*]
     2 filterid = f8
     2 existsind = i2
     2 defaultid = f8
     2 detailind = i2
     2 group_name = vc
     2 group_ce_r = vc
     2 group_ce_concept_cki = vc
 )
 SET cnt = size(requestin->list_0,5)
 SET stat = alterlist(br_existsinfo->list_0,cnt)
 SELECT INTO "nl:"
  FROM br_datamart_category bdc,
   br_datamart_filter bdf,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (bdc
   WHERE bdc.category_mean=cnvtupper(requestin->list_0[d.seq].topic_mean))
   JOIN (bdf
   WHERE bdf.br_datamart_category_id=bdc.br_datamart_category_id
    AND bdf.filter_mean=cnvtupper(requestin->list_0[d.seq].filter_mean))
  DETAIL
   br_existsinfo->list_0[d.seq].filterid = bdf.br_datamart_filter_id
   IF (bdf.filter_category_mean="ORDER_DETAILS")
    br_existsinfo->list_0[d.seq].detailind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure getting defaults >> ",errmsg)
  GO TO exit_script
 ENDIF
 FOR (y = 1 TO cnt)
   SET br_existsinfo->list_0[y].defaultid = 0.0
   SELECT INTO "nl:"
    j = seq(bedrock_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     br_existsinfo->list_0[y].defaultid = cnvtreal(j)
    WITH format, counter
   ;end select
   IF (validate(requestin->list_0[y].group_name,"") > " ")
    SET br_existsinfo->list_0[y].group_name = requestin->list_0[y].group_name
   ELSE
    SET br_existsinfo->list_0[y].group_name = ""
   ENDIF
   IF (validate(requestin->list_0[y].group_ce_r,"") > " ")
    SET br_existsinfo->list_0[y].group_ce_r = requestin->list_0[y].group_ce_r
   ELSE
    SET br_existsinfo->list_0[y].group_ce_r = ""
   ENDIF
   IF (validate(requestin->list_0[y].group_ce_concept_cki,"") > " ")
    SET br_existsinfo->list_0[y].group_ce_concept_cki = requestin->list_0[y].group_ce_concept_cki
   ELSE
    SET br_existsinfo->list_0[y].group_ce_concept_cki = ""
   ENDIF
 ENDFOR
 INSERT  FROM br_datamart_default b,
   (dummyt d  WITH seq = value(cnt))
  SET b.br_datamart_default_id = br_existsinfo->list_0[d.seq].defaultid, b.br_datamart_filter_id =
   br_existsinfo->list_0[d.seq].filterid, b.unique_identifier = requestin->list_0[d.seq].
   unique_identifier,
   b.cv_display = requestin->list_0[d.seq].short_name, b.cv_description = requestin->list_0[d.seq].
   long_name, b.code_set =
   IF ((requestin->list_0[d.seq].code_set > " ")) cnvtint(requestin->list_0[d.seq].code_set)
   ELSE 0
   ENDIF
   ,
   b.result_type_flag =
   IF (cnvtupper(requestin->list_0[d.seq].result_type)="ALPHA") 1
   ELSEIF (cnvtupper(requestin->list_0[d.seq].result_type)="NUMERIC") 2
   ELSE 0
   ENDIF
   , b.qualifier_flag =
   IF (cnvtupper(requestin->list_0[d.seq].qualifier)="EQUAL TO") 1
   ELSEIF (cnvtupper(requestin->list_0[d.seq].qualifier)="NOT EQUAL TO") 2
   ELSEIF (cnvtupper(requestin->list_0[d.seq].qualifier)="GREATER THAN") 3
   ELSEIF (cnvtupper(requestin->list_0[d.seq].qualifier)="LESS THAN") 4
   ELSEIF (cnvtupper(requestin->list_0[d.seq].qualifier)="GREATER THAN OR EQUAL TO") 5
   ELSEIF (cnvtupper(requestin->list_0[d.seq].qualifier)="LESS THAN OR EQUAL TO") 6
   ELSE 0
   ENDIF
   , b.result_value = requestin->list_0[d.seq].result_value,
   b.order_detail_ind = br_existsinfo->list_0[d.seq].detailind, b.group_name = br_existsinfo->list_0[
   d.seq].group_name, b.group_ce_name = br_existsinfo->list_0[d.seq].group_ce_r,
   b.group_ce_concept_cki = br_existsinfo->list_0[d.seq].group_ce_concept_cki, b.updt_cnt = 0, b
   .updt_dt_tm = cnvtdatetime(sysdate),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting datamart defaults >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 FOR (y = 1 TO cnt)
   IF ((br_existsinfo->list_0[y].detailind=1))
    FREE SET temp
    RECORD temp(
      1 ord[*]
        2 mean = vc
        2 val = vc
        2 cki = vc
    )
    SET ocnt = 0
    IF ((requestin->list_0[y].oe_field_meaning1 > " "))
     SET ocnt += 1
     SET stat = alterlist(temp->ord,ocnt)
     SET temp->ord[ocnt].mean = requestin->list_0[y].oe_field_meaning1
     SET temp->ord[ocnt].val = requestin->list_0[y].oe_detail_value1
     SET temp->ord[ocnt].cki = requestin->list_0[y].oe_detail_cki1
    ENDIF
    IF ((requestin->list_0[y].oe_field_meaning2 > " "))
     SET ocnt += 1
     SET stat = alterlist(temp->ord,ocnt)
     SET temp->ord[ocnt].mean = requestin->list_0[y].oe_field_meaning2
     SET temp->ord[ocnt].val = requestin->list_0[y].oe_detail_value2
     SET temp->ord[ocnt].cki = requestin->list_0[y].oe_detail_cki2
    ENDIF
    IF ((requestin->list_0[y].oe_field_meaning3 > " "))
     SET ocnt += 1
     SET stat = alterlist(temp->ord,ocnt)
     SET temp->ord[ocnt].mean = requestin->list_0[y].oe_field_meaning3
     SET temp->ord[ocnt].val = requestin->list_0[y].oe_detail_value3
     SET temp->ord[ocnt].cki = requestin->list_0[y].oe_detail_cki3
    ENDIF
    IF ((requestin->list_0[y].oe_field_meaning4 > " "))
     SET ocnt += 1
     SET stat = alterlist(temp->ord,ocnt)
     SET temp->ord[ocnt].mean = requestin->list_0[y].oe_field_meaning4
     SET temp->ord[ocnt].val = requestin->list_0[y].oe_detail_value4
     SET temp->ord[ocnt].cki = requestin->list_0[y].oe_detail_cki4
    ENDIF
    IF (ocnt > 0)
     INSERT  FROM br_datamart_default_detail b,
       (dummyt d  WITH seq = value(ocnt))
      SET b.br_datamart_default_detail_id = seq(bedrock_seq,nextval), b.br_datamart_default_id =
       br_existsinfo->list_0[y].defaultid, b.oe_field_meaning = cnvtupper(temp->ord[d.seq].mean),
       b.detail_value = temp->ord[d.seq].val, b.detail_cki = temp->ord[d.seq].cki, b.updt_cnt = 0,
       b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->
       updt_task,
       b.updt_applctx = reqinfo->updt_applctx
      PLAN (d)
       JOIN (b)
      WITH nocounter
     ;end insert
     IF (error(errmsg,0) > 0)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failure inserting datamart default details >> ",errmsg)
      GO TO exit_script
     ELSE
      COMMIT
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_datamart_filter f,
   br_datamart_report_filter_r r,
   br_datamart_report rep,
   br_datamart_category c,
   br_datamart_default d2
  PLAN (d)
   JOIN (rep
   WHERE rep.report_mean=cnvtupper(requestin->list_0[d.seq].report_mean))
   JOIN (r
   WHERE r.br_datamart_report_id=rep.br_datamart_report_id)
   JOIN (f
   WHERE f.br_datamart_filter_id=r.br_datamart_filter_id
    AND f.filter_mean=cnvtupper(requestin->list_0[d.seq].filter_mean)
    AND f.br_datamart_category_id=rep.br_datamart_category_id)
   JOIN (c
   WHERE c.br_datamart_category_id=f.br_datamart_category_id
    AND c.category_mean="VB_*")
   JOIN (d2
   WHERE d2.br_datamart_filter_id=f.br_datamart_filter_id)
  ORDER BY d.seq, f.br_datamart_filter_id
  HEAD d.seq
   r = 1
  HEAD f.br_datamart_filter_id
   customfiltercnt += 1, stat = alterlist(custom_filters->list_0,customfiltercnt), custom_filters->
   list_0[customfiltercnt].filterid = f.br_datamart_filter_id
   IF (f.filter_category_mean="ORDER_DETAILS")
    custom_filters->list_0[d.seq].detailind = 1
   ENDIF
   IF (validate(requestin->list_0[d.seq].group_name,"") > " ")
    custom_filters->list_0[customfiltercnt].group_name = requestin->list_0[d.seq].group_name
   ELSE
    custom_filters->list_0[customfiltercnt].group_name = ""
   ENDIF
   IF (validate(requestin->list_0[d.seq].group_ce_r,"") > " ")
    custom_filters->list_0[customfiltercnt].group_ce_r = requestin->list_0[d.seq].group_ce_r
   ELSE
    custom_filters->list_0[customfiltercnt].group_ce_r = ""
   ENDIF
   IF (validate(requestin->list_0[d.seq].group_ce_concept_cki,"") > " ")
    custom_filters->list_0[customfiltercnt].group_ce_concept_cki = requestin->list_0[d.seq].
    group_ce_concept_cki
   ELSE
    custom_filters->list_0[customfiltercnt].group_ce_concept_cki = ""
   ENDIF
   custom_filters->list_0[customfiltercnt].unique_identifier = requestin->list_0[d.seq].
   unique_identifier, custom_filters->list_0[customfiltercnt].short_name = requestin->list_0[d.seq].
   short_name, custom_filters->list_0[customfiltercnt].long_name = requestin->list_0[d.seq].long_name,
   custom_filters->list_0[customfiltercnt].code_set = requestin->list_0[d.seq].code_set,
   custom_filters->list_0[customfiltercnt].result_type = requestin->list_0[d.seq].result_type,
   custom_filters->list_0[customfiltercnt].qualifier = requestin->list_0[d.seq].qualifier,
   custom_filters->list_0[customfiltercnt].result_value = requestin->list_0[d.seq].result_value,
   custom_filters->list_0[customfiltercnt].oe_field_meaning1 = requestin->list_0[d.seq].
   oe_field_meaning1, custom_filters->list_0[customfiltercnt].oe_detail_value1 = requestin->list_0[d
   .seq].oe_detail_value1,
   custom_filters->list_0[customfiltercnt].oe_detail_cki1 = requestin->list_0[d.seq].oe_detail_cki1,
   custom_filters->list_0[customfiltercnt].oe_field_meaning2 = requestin->list_0[d.seq].
   oe_field_meaning2, custom_filters->list_0[customfiltercnt].oe_detail_value2 = requestin->list_0[d
   .seq].oe_detail_value2,
   custom_filters->list_0[customfiltercnt].oe_detail_cki2 = requestin->list_0[d.seq].oe_detail_cki2,
   custom_filters->list_0[customfiltercnt].oe_field_meaning3 = requestin->list_0[d.seq].
   oe_field_meaning3, custom_filters->list_0[customfiltercnt].oe_detail_value3 = requestin->list_0[d
   .seq].oe_detail_value3,
   custom_filters->list_0[customfiltercnt].oe_detail_cki3 = requestin->list_0[d.seq].oe_detail_cki3,
   custom_filters->list_0[customfiltercnt].oe_field_meaning4 = requestin->list_0[d.seq].
   oe_field_meaning4, custom_filters->list_0[customfiltercnt].oe_detail_value4 = requestin->list_0[d
   .seq].oe_detail_value4,
   custom_filters->list_0[customfiltercnt].oe_detail_cki4 = requestin->list_0[d.seq].oe_detail_cki4
  DETAIL
   del_cnt += 1, stat = alterlist(del_ids->ids,del_cnt), del_ids->ids[del_cnt].id = d2
   .br_datamart_default_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure getting custom >> ",errmsg)
  GO TO exit_script
 ENDIF
 IF (customfiltercnt > 0)
  SELECT INTO "nl:"
   j = seq(bedrock_seq,nextval)
   FROM (dummyt d  WITH seq = value(customfiltercnt)),
    dual dd
   PLAN (d)
    JOIN (dd)
   DETAIL
    custom_filters->list_0[d.seq].defaultid = cnvtreal(j)
   WITH nocounter
  ;end select
 ENDIF
 IF (del_cnt > 0)
  DELETE  FROM br_datamart_default_detail dd,
    (dummyt d  WITH seq = value(del_cnt))
   SET dd.seq = 1
   PLAN (d)
    JOIN (dd
    WHERE (dd.br_datamart_default_id=del_ids->ids[d.seq].id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure removing custom details >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM br_datamart_default dd,
    (dummyt d  WITH seq = value(del_cnt))
   SET dd.seq = 1
   PLAN (d)
    JOIN (dd
    WHERE (dd.br_datamart_default_id=del_ids->ids[d.seq].id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure removing custom defaults >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 IF (customfiltercnt > 0)
  INSERT  FROM br_datamart_default b,
    (dummyt d  WITH seq = value(customfiltercnt))
   SET b.br_datamart_default_id = custom_filters->list_0[d.seq].defaultid, b.br_datamart_filter_id =
    custom_filters->list_0[d.seq].filterid, b.unique_identifier = custom_filters->list_0[d.seq].
    unique_identifier,
    b.cv_display = custom_filters->list_0[d.seq].short_name, b.cv_description = custom_filters->
    list_0[d.seq].long_name, b.code_set =
    IF ((custom_filters->list_0[d.seq].code_set > " ")) cnvtint(custom_filters->list_0[d.seq].
      code_set)
    ELSE 0
    ENDIF
    ,
    b.result_type_flag =
    IF (cnvtupper(custom_filters->list_0[d.seq].result_type)="ALPHA") 1
    ELSEIF (cnvtupper(custom_filters->list_0[d.seq].result_type)="NUMERIC") 2
    ELSE 0
    ENDIF
    , b.qualifier_flag =
    IF (cnvtupper(custom_filters->list_0[d.seq].qualifier)="EQUAL TO") 1
    ELSEIF (cnvtupper(custom_filters->list_0[d.seq].qualifier)="NOT EQUAL TO") 2
    ELSEIF (cnvtupper(custom_filters->list_0[d.seq].qualifier)="GREATER THAN") 3
    ELSEIF (cnvtupper(custom_filters->list_0[d.seq].qualifier)="LESS THAN") 4
    ELSEIF (cnvtupper(custom_filters->list_0[d.seq].qualifier)="GREATER THAN OR EQUAL TO") 5
    ELSEIF (cnvtupper(custom_filters->list_0[d.seq].qualifier)="LESS THAN OR EQUAL TO") 6
    ELSE 0
    ENDIF
    , b.result_value = custom_filters->list_0[d.seq].result_value,
    b.order_detail_ind = custom_filters->list_0[d.seq].detailind, b.group_name = custom_filters->
    list_0[d.seq].group_name, b.group_ce_name = custom_filters->list_0[d.seq].group_ce_r,
    b.group_ce_concept_cki = custom_filters->list_0[d.seq].group_ce_concept_cki, b.updt_cnt = 0, b
    .updt_dt_tm = cnvtdatetime(sysdate),
    b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d)
    JOIN (b)
   WITH nocounter
  ;end insert
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure inserting datamart defaults >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  FOR (y = 1 TO customfiltercnt)
    IF ((custom_filters->list_0[y].detailind=1))
     FREE SET temp
     RECORD temp(
       1 ord[*]
         2 mean = vc
         2 val = vc
         2 cki = vc
     )
     SET ocnt = 0
     IF ((custom_filters->list_0[y].oe_field_meaning1 > " "))
      SET ocnt += 1
      SET stat = alterlist(temp->ord,ocnt)
      SET temp->ord[ocnt].mean = custom_filters->list_0[y].oe_field_meaning1
      SET temp->ord[ocnt].val = custom_filters->list_0[y].oe_detail_value1
      SET temp->ord[ocnt].cki = custom_filters->list_0[y].oe_detail_cki1
     ENDIF
     IF ((custom_filters->list_0[y].oe_field_meaning2 > " "))
      SET ocnt += 1
      SET stat = alterlist(temp->ord,ocnt)
      SET temp->ord[ocnt].mean = custom_filters->list_0[y].oe_field_meaning2
      SET temp->ord[ocnt].val = custom_filters->list_0[y].oe_detail_value2
      SET temp->ord[ocnt].cki = custom_filters->list_0[y].oe_detail_cki2
     ENDIF
     IF ((custom_filters->list_0[y].oe_field_meaning3 > " "))
      SET ocnt += 1
      SET stat = alterlist(temp->ord,ocnt)
      SET temp->ord[ocnt].mean = custom_filters->list_0[y].oe_field_meaning3
      SET temp->ord[ocnt].val = custom_filters->list_0[y].oe_detail_value3
      SET temp->ord[ocnt].cki = custom_filters->list_0[y].oe_detail_cki3
     ENDIF
     IF ((custom_filters->list_0[y].oe_field_meaning4 > " "))
      SET ocnt += 1
      SET stat = alterlist(temp->ord,ocnt)
      SET temp->ord[ocnt].mean = custom_filters->list_0[y].oe_field_meaning4
      SET temp->ord[ocnt].val = custom_filters->list_0[y].oe_detail_value4
      SET temp->ord[ocnt].cki = custom_filters->list_0[y].oe_detail_cki4
     ENDIF
     IF (ocnt > 0)
      INSERT  FROM br_datamart_default_detail b,
        (dummyt d  WITH seq = value(ocnt))
       SET b.br_datamart_default_detail_id = seq(bedrock_seq,nextval), b.br_datamart_default_id =
        custom_filters->list_0[y].defaultid, b.oe_field_meaning = cnvtupper(temp->ord[d.seq].mean),
        b.detail_value = temp->ord[d.seq].val, b.detail_cki = temp->ord[d.seq].cki, b.updt_cnt = 0,
        b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->
        updt_task,
        b.updt_applctx = reqinfo->updt_applctx
       PLAN (d)
        JOIN (b)
       WITH nocounter
      ;end insert
      IF (error(errmsg,0) > 0)
       ROLLBACK
       SET readme_data->status = "F"
       SET readme_data->message = concat("Failure inserting datamart default details >> ",errmsg)
       GO TO exit_script
      ELSE
       COMMIT
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_datamart_std_default_config.prg> script"
#exit_script
 CALL echorecord(readme_data)
 FREE RECORD br_existsinfo
 FREE RECORD custom_filters
END GO

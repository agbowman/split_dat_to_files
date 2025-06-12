CREATE PROGRAM br_datamart_filter_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_datamart_filter_config.prg> script"
 SET diagnostics_file_name = concat("datamart_diagnostics_file_",currdbhandle,".dat")
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE delete_hist_cnt = i4 WITH protect, noconstant(0)
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET cnt = size(requestin->list_0,5)
 FREE RECORD br_existsinfo
 RECORD br_existsinfo(
   1 list_0[*]
     2 existsind = i2
     2 categoryid = f8
     2 filter_id = f8
     2 del_values_ind = i2
     2 category_name = vc
     2 category_mean = vc
     2 filter_name = vc
     2 filter_mean = vc
 )
 SET stat = alterlist(br_existsinfo->list_0,cnt)
 FREE RECORD filters_to_del
 RECORD filters_to_del(
   1 filters[*]
     2 category_id = f8
     2 filter_id = f8
     2 category_name = vc
     2 category_mean = vc
     2 filter_name = vc
     2 filter_mean = vc
 )
 FREE RECORD tfilter
 RECORD tfilter(
   1 filters[*]
     2 filter_limit = i4
     2 expected_action_value_set_id = f8
     2 inaction_reason_value_set_id = f8
 )
 FREE RECORD delete_hist
 RECORD delete_hist(
   1 deleted_items[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
 )
 SET stat = alterlist(tfilter->filters,cnt)
 FOR (x = 1 TO cnt)
   IF (validate(requestin->list_0[x].filter_limit,"F") != "F")
    SET tfilter->filters[x].filter_limit = cnvtint(trim(requestin->list_0[x].filter_limit))
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM br_datamart_category b,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (b
   WHERE b.category_mean=cnvtupper(requestin->list_0[d.seq].topic_mean))
  DETAIL
   br_existsinfo->list_0[d.seq].categoryid = b.br_datamart_category_id, br_existsinfo->list_0[d.seq].
   category_name = b.category_name, br_existsinfo->list_0[d.seq].category_mean = b.category_mean
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL logerror("Failed to select rows from br_datamart_category table: ",serrmsg)
 ENDIF
 SELECT INTO "nl:"
  FROM br_datam_val_set vs,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (vs
   WHERE (vs.br_datamart_category_id=br_existsinfo->list_0[d.seq].categoryid)
    AND vs.template_name=cnvtupper(validate(requestin->list_0[d.seq].template_name,""))
    AND vs.value_set_name=cnvtupper(validate(requestin->list_0[d.seq].value_set_name,"")))
  DETAIL
   tfilter->filters[d.seq].expected_action_value_set_id = vs.br_datam_val_set_id
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL logerror("Failed to select rows from br_datam_val_set table :",serrmsg)
 ENDIF
 SELECT INTO "nl:"
  FROM br_datam_val_set vs,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (vs
   WHERE (vs.br_datamart_category_id=br_existsinfo->list_0[d.seq].categoryid)
    AND (vs.template_name=
   IF (validate(requestin->list_0[d.seq].template_name,"") != "") cnvtupper(validate(requestin->
      list_0[d.seq].template_name,""))
   ELSE "VeryRandomSetNameWhichShouldntExist"
   ENDIF
   )
    AND (vs.value_set_name=
   IF (validate(requestin->list_0[d.seq].value_set_name_secondary,"") != "") cnvtupper(validate(
      requestin->list_0[d.seq].value_set_name_secondary,""))
   ELSE "VeryRandomSetNameWhichShouldntExist"
   ENDIF
   ))
  DETAIL
   tfilter->filters[d.seq].inaction_reason_value_set_id = vs.br_datam_val_set_id
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL logerror("Failed to select rows from br_datam_val_set table:",serrmsg)
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_datamart_filter f,
   br_datam_val_set vs1,
   br_datam_val_set vs2
  PLAN (d)
   JOIN (f
   WHERE (f.br_datamart_category_id=br_existsinfo->list_0[d.seq].categoryid)
    AND f.filter_mean=cnvtupper(requestin->list_0[d.seq].filter_mean))
   JOIN (vs1
   WHERE vs1.br_datam_val_set_id=f.expected_action_value_set_id)
   JOIN (vs2
   WHERE vs2.br_datam_val_set_id=f.inaction_reason_value_set_id)
  DETAIL
   br_existsinfo->list_0[d.seq].existsind = 1
   IF (((cnvtupper(f.filter_category_mean) != cnvtupper(requestin->list_0[d.seq].filter_category_mean
    )) OR ((((vs1.br_datam_val_set_id != tfilter->filters[d.seq].expected_action_value_set_id)) OR ((
   vs2.br_datam_val_set_id != tfilter->filters[d.seq].inaction_reason_value_set_id))) )) )
    br_existsinfo->list_0[d.seq].del_values_ind = 1, br_existsinfo->list_0[d.seq].filter_id = f
    .br_datamart_filter_id, br_existsinfo->list_0[d.seq].filter_name = f.filter_display,
    br_existsinfo->list_0[d.seq].filter_mean = f.filter_mean
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL logerror("Failed to select rows from br_datamart_filter and br_datam_val_set tables:",serrmsg)
 ENDIF
 DECLARE filter_mean = vc
 SELECT INTO "nl:"
  FROM br_datamart_filter b,
   br_datamart_category c
  PLAN (b
   WHERE (b.br_datamart_category_id=br_existsinfo->list_0[1].categoryid))
   JOIN (c
   WHERE (c.br_datamart_category_id=br_existsinfo->list_0[1].categoryid))
  ORDER BY b.br_datamart_filter_id
  HEAD REPORT
   tot_del = 0, filters = 0, stat = alterlist(filters_to_del->filters,100)
  DETAIL
   pos = 0, filter_mean = cnvtupper(b.filter_mean)
   FOR (i = 1 TO cnt)
     IF (filter_mean=cnvtupper(requestin->list_0[i].filter_mean))
      pos = i, i = cnt
     ENDIF
   ENDFOR
   IF (pos=0)
    tot_del += 1, filters += 1
    IF (filters > 100)
     stat = alterlist(filters_to_del->filters,(tot_del+ 100)), filters = 1
    ENDIF
    filters_to_del->filters[tot_del].category_id = b.br_datamart_category_id, filters_to_del->
    filters[tot_del].category_name = c.category_name, filters_to_del->filters[tot_del].category_mean
     = c.category_mean,
    filters_to_del->filters[tot_del].filter_id = b.br_datamart_filter_id, filters_to_del->filters[
    tot_del].filter_name = b.filter_display, filters_to_del->filters[tot_del].filter_mean = b
    .filter_mean
   ENDIF
  FOOT REPORT
   stat = alterlist(filters_to_del->filters,tot_del)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL logerror("Failed to select rows from br_datamart_filter table :",serrmsg)
 ENDIF
 SELECT INTO "nl:"
  FROM br_datamart_value v,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].del_values_ind=1))
   JOIN (v
   WHERE (v.br_datamart_category_id=br_existsinfo->list_0[d.seq].categoryid)
    AND (v.br_datamart_filter_id=br_existsinfo->list_0[d.seq].filter_id))
  ORDER BY v.br_datamart_value_id
  HEAD REPORT
   delete_hist_cnt = 0, stat = alterlist(delete_hist->deleted_items,100)
  HEAD v.br_datamart_value_id
   delete_hist_cnt += 1
   IF (mod(delete_hist_cnt,10)=1
    AND delete_hist_cnt > 100)
    stat = alterlist(delete_hist->deleted_items,(delete_hist_cnt+ 10))
   ENDIF
  DETAIL
   delete_hist->deleted_items[delete_hist_cnt].parent_entity_id = v.br_datamart_value_id, delete_hist
   ->deleted_items[delete_hist_cnt].parent_entity_name = "BR_DATAMART_VALUE"
  FOOT REPORT
   stat = alterlist(delete_hist->deleted_items,delete_hist_cnt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL logerror("Failed to select rows from br_datamart_value table :",serrmsg)
 ENDIF
 CALL echorecord(delete_hist)
 DELETE  FROM br_datamart_value b,
   (dummyt d  WITH seq = value(cnt))
  SET b.seq = 1
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].del_values_ind=1))
   JOIN (b
   WHERE (b.br_datamart_category_id=br_existsinfo->list_0[d.seq].categoryid)
    AND (b.br_datamart_filter_id=br_existsinfo->list_0[d.seq].filter_id))
  WITH nocounter
 ;end delete
 IF (validate(readme_data))
  CALL echoxml(readme_data,diagnostics_file_name,1)
 ENDIF
 IF (curqual > 0)
  SELECT INTO value(diagnostics_file_name)
   timestamp = format(cnvtdatetime(sysdate),"hh:mm:ss;;s"), first_category_id = cnvtstring(
    br_existsinfo->list_0[d.seq].categoryid), first_category_name = br_existsinfo->list_0[d.seq].
   category_name,
   first_category_mean = br_existsinfo->list_0[d.seq].category_mean, first_filter_id = cnvtstring(
    br_existsinfo->list_0[d.seq].filter_id), first_filter_name = br_existsinfo->list_0[d.seq].
   filter_name,
   first_filter_mean = br_existsinfo->list_0[d.seq].filter_mean
   FROM (dummyt d  WITH seq = value(size(br_existsinfo->list_0,5)))
   PLAN (d
    WHERE (br_existsinfo->list_0[d.seq].del_values_ind=1))
   WITH append, heading, format,
    counter, maxcol = 600, separator = "|"
  ;end select
 ENDIF
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete rows from br_datamart_value table: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM br_datamart_filter b,
   (dummyt d  WITH seq = value(cnt))
  SET b.br_datamart_filter_id = seq(bedrock_seq,nextval), b.br_datamart_category_id = br_existsinfo->
   list_0[d.seq].categoryid, b.filter_mean = cnvtupper(requestin->list_0[d.seq].filter_mean),
   b.filter_display = requestin->list_0[d.seq].display, b.filter_seq = cnvtint(requestin->list_0[d
    .seq].sequence), b.filter_category_mean = cnvtupper(requestin->list_0[d.seq].filter_category_mean
    ),
   b.filter_limit = tfilter->filters[d.seq].filter_limit, b.expected_action_value_set_id = tfilter->
   filters[d.seq].expected_action_value_set_id, b.inaction_reason_value_set_id = tfilter->filters[d
   .seq].inaction_reason_value_set_id,
   b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id,
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=0))
   JOIN (b)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to insert rows into br_datamart_filter table: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_datamart_filter b,
   (dummyt d  WITH seq = value(cnt))
  SET b.filter_display = requestin->list_0[d.seq].display, b.filter_seq = cnvtint(requestin->list_0[d
    .seq].sequence), b.filter_category_mean = cnvtupper(requestin->list_0[d.seq].filter_category_mean
    ),
   b.filter_limit = tfilter->filters[d.seq].filter_limit, b.expected_action_value_set_id = tfilter->
   filters[d.seq].expected_action_value_set_id, b.inaction_reason_value_set_id = tfilter->filters[d
   .seq].inaction_reason_value_set_id,
   b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id,
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=1))
   JOIN (b
   WHERE (b.br_datamart_category_id=br_existsinfo->list_0[d.seq].categoryid)
    AND b.filter_mean=cnvtupper(requestin->list_0[d.seq].filter_mean))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update rows into br_datamart_filter table: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET tot_del = size(filters_to_del->filters,5)
 IF (tot_del > 0)
  SELECT INTO "nl:"
   FROM br_datamart_value v,
    (dummyt d  WITH seq = value(tot_del))
   PLAN (d)
    JOIN (v
    WHERE (v.br_datamart_filter_id=filters_to_del->filters[d.seq].filter_id)
     AND (v.br_datamart_category_id=filters_to_del->filters[d.seq].category_id))
   ORDER BY v.br_datamart_value_id
   HEAD REPORT
    delete_hist_cnt = 0, stat = alterlist(delete_hist->deleted_items,100)
   HEAD v.br_datamart_value_id
    delete_hist_cnt += 1
    IF (mod(delete_hist_cnt,10)=1
     AND delete_hist_cnt > 100)
     stat = alterlist(delete_hist->deleted_items,(delete_hist_cnt+ 10))
    ENDIF
   DETAIL
    delete_hist->deleted_items[delete_hist_cnt].parent_entity_id = v.br_datamart_value_id,
    delete_hist->deleted_items[delete_hist_cnt].parent_entity_name = v.parent_entity_name
   FOOT REPORT
    stat = alterlist(delete_hist->deleted_items,delete_hist_cnt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Failed to select rows from br_datamart_value table:",serrmsg)
  ENDIF
  DELETE  FROM br_datamart_value v,
    (dummyt d  WITH seq = value(tot_del))
   SET v.seq = 1
   PLAN (d)
    JOIN (v
    WHERE (v.br_datamart_filter_id=filters_to_del->filters[d.seq].filter_id)
     AND (v.br_datamart_category_id=filters_to_del->filters[d.seq].category_id))
   WITH nocounter
  ;end delete
  IF (validate(readme_data))
   CALL echoxml(readme_data,diagnostics_file_name,1)
  ENDIF
  IF (curqual > 0)
   SELECT INTO value(diagnostics_file_name)
    timestamp = format(cnvtdatetime(sysdate),"hh:mm:ss;;s"), second_category_id = cnvtstring(
     filters_to_del->filters[d.seq].category_id), second_category_name = filters_to_del->filters[d
    .seq].category_name,
    second_category_mean = filters_to_del->filters[d.seq].category_mean, second_filter_id =
    cnvtstring(filters_to_del->filters[d.seq].filter_id), second_filter_name = filters_to_del->
    filters[d.seq].filter_name,
    second_filter_mean = filters_to_del->filters[d.seq].filter_mean
    FROM (dummyt d  WITH seq = value(size(filters_to_del->filters,5)))
    PLAN (d
     WHERE (filters_to_del->filters[d.seq].category_id > 0.0))
    WITH append, heading, format,
     counter, maxcol = 600, separator = "|"
   ;end select
  ENDIF
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to delete rows from br_datamart_value table: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM br_datamart_report_filter_r b,
    (dummyt d  WITH seq = value(tot_del))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_filter_id=filters_to_del->filters[d.seq].filter_id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to delete rows from br_datamart_report_filter table: ",
    errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  FOR (i = 1 TO tot_del)
   DELETE  FROM br_datamart_default_detail dd
    WHERE dd.br_datamart_default_id IN (
    (SELECT
     dd2.br_datamart_default_id
     FROM br_datamart_default_detail dd2,
      br_datamart_default bd
     WHERE dd2.br_datamart_default_id=bd.br_datamart_default_id
      AND (bd.br_datamart_filter_id=filters_to_del->filters[i].filter_id)))
    WITH nocounter
   ;end delete
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to delete rows from br_datamart_default_detail table: ",
     errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ENDFOR
  DELETE  FROM br_datamart_default b,
    (dummyt d  WITH seq = value(tot_del))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_filter_id=filters_to_del->filters[d.seq].filter_id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to delete rows from br_datamart_default table: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM br_datamart_text b,
    (dummyt d  WITH seq = value(tot_del))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_category_id=filters_to_del->filters[d.seq].category_id)
     AND (b.br_datamart_filter_id=filters_to_del->filters[d.seq].filter_id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to delete rows from br_datamart_text table: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM br_datamart_filter b,
    (dummyt d  WITH seq = value(tot_del))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_category_id=filters_to_del->filters[d.seq].category_id)
     AND (b.br_datamart_filter_id=filters_to_del->filters[d.seq].filter_id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to delete rows from br_datamart_filter table: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 IF (delete_hist_cnt > 0)
  DELETE  FROM br_delete_hist b
   PLAN (b
    WHERE b.br_delete_hist_id != 0.0
     AND b.create_dt_tm < cnvtlookbehind("4, M"))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to delete rows from br_delete_hist table: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  INSERT  FROM br_delete_hist his,
    (dummyt d  WITH seq = value(delete_hist_cnt))
   SET his.br_delete_hist_id = seq(bedrock_seq,nextval), his.parent_entity_name = delete_hist->
    deleted_items[d.seq].parent_entity_name, his.parent_entity_id = delete_hist->deleted_items[d.seq]
    .parent_entity_id,
    his.updt_dt_tm = cnvtdatetime(sysdate), his.updt_id = reqinfo->updt_id, his.updt_task = reqinfo->
    updt_task,
    his.updt_cnt = 0, his.updt_applctx = reqinfo->updt_applctx, his.create_dt_tm = cnvtdatetime(
     sysdate)
   PLAN (d)
    JOIN (his
    WHERE  NOT ( EXISTS (
    (SELECT
     his.parent_entity_id
     FROM br_delete_hist h
     WHERE (h.parent_entity_id=delete_hist->deleted_items[d.seq].parent_entity_id)
      AND (h.parent_entity_name=delete_hist->deleted_items[d.seq].parent_entity_name)))))
   WITH nocounter
  ;end insert
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to insert into br_delete_hist table: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_datamart_filter_config.prg> script"
 SUBROUTINE logerror(namemsg,valuemsg)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Readme Failed: ",namemsg,":",valuemsg)
   GO TO exit_script
 END ;Subroutine
#exit_script
 CALL echorecord(readme_data)
 FREE RECORD br_existsinfo
 FREE RECORD filters_to_del
 FREE RECORD tfilter
 FREE RECORD delete_hist
END GO

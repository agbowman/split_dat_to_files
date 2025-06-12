CREATE PROGRAM br_dmart_map_types_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_dmart_map_types_config.prg> script"
 FREE SET temp_import
 RECORD temp_import(
   1 records[*]
     2 br_datamart_category_id = f8
     2 br_datamart_filter_category_id = f8
     2 map_data_type_cd = f8
     2 map_data_type_value = f8
     2 map_data_type_display = vc
     2 sequence = i4
 )
 FREE SET temp_update
 RECORD temp_update(
   1 records[*]
     2 br_datamart_mapping_type_id = f8
     2 br_datamart_category_id = f8
     2 br_datamart_filter_category_id = f8
     2 map_data_type_cd = f8
     2 map_data_type_value = f8
     2 map_data_type_display = vc
     2 sequence = i4
 )
 FREE SET temp_insert
 RECORD temp_insert(
   1 records[*]
     2 br_datamart_mapping_type_id = f8
     2 br_datamart_category_id = f8
     2 br_datamart_filter_category_id = f8
     2 map_data_type_cd = f8
     2 map_data_type_value = f8
     2 map_data_type_display = vc
     2 sequence = i4
 )
 FREE SET temp_remove
 RECORD temp_remove(
   1 records[*]
     2 br_datamart_mapping_type_id = f8
     2 br_datamart_category_id = f8
     2 br_datamart_filter_category_id = f8
     2 map_data_type_cd = f8
     2 map_data_type_value = f8
     2 map_data_type_display = vc
     2 sequence = i4
     2 category_name = vc
     2 category_mean = vc
     2 filter_cat_mean = vc
     2 filter_cat_type_mean = vc
 )
 FREE SET datamart_values_req
 RECORD datamart_values_req(
   1 items[*]
     2 br_datamart_value_id = f8
 )
 FREE SET datamart_values_rep
 RECORD datamart_values_rep(
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
 FREE SET delete_hist
 RECORD delete_hist(
   1 deleted_items[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
 )
 SET diagnostics_file_name = concat("datamart_diagnostics_file_",currdbhandle,".dat")
 DECLARE delete_hist_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE cnt = i4 WITH protect
 DECLARE req_cnt = i4 WITH protect
 DECLARE insert_cnt = i4 WITH protect, noconstant(0)
 DECLARE update_cnt = i4 WITH protect, noconstant(0)
 DECLARE remove_cnt = i4 WITH protect, noconstant(0)
 DECLARE dmart_cnt = i4 WITH protect, noconstant(0)
 DECLARE dmart_rep = i4 WITH protect, noconstant(0)
 DECLARE t1 = i4 WITH protect
 DECLARE t2 = i4 WITH protect
 DECLARE ind = i4 WITH protect
 DECLARE requestindex = i4 WITH protect
 DECLARE common_cat_id = f8 WITH protect
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET req_cnt = size(requestin->list_0,5)
 SET insert_cnt = 0
 SET update_cnt = 0
 SET remove_cnt = 0
 IF (req_cnt > 0)
  SELECT INTO "nl:"
   FROM br_datamart_category dmart_cat,
    br_datamart_filter_category dmart_filter,
    code_value cv,
    (dummyt d  WITH seq = value(req_cnt))
   PLAN (d)
    JOIN (dmart_cat
    WHERE dmart_cat.category_mean=cnvtupper(requestin->list_0[d.seq].topic_mean))
    JOIN (dmart_filter
    WHERE dmart_filter.filter_category_mean=cnvtupper(requestin->list_0[d.seq].filter_category_mean))
    JOIN (cv
    WHERE cv.code_set=4002871
     AND cv.active_ind=1
     AND cv.code_value > 0
     AND cnvtupper(cv.cdf_meaning)=cnvtupper(requestin->list_0[d.seq].map_data_type))
   HEAD REPORT
    cnt = 0, stat = alterlist(temp_import->records,req_cnt)
   DETAIL
    IF ((requestin->list_0[d.seq].topic_mean > " "))
     cnt = (cnt+ 1), temp_import->records[cnt].br_datamart_category_id = dmart_cat
     .br_datamart_category_id, temp_import->records[cnt].br_datamart_filter_category_id =
     dmart_filter.br_datamart_filter_category_id,
     temp_import->records[cnt].map_data_type_cd = cv.code_value, temp_import->records[cnt].
     map_data_type_value = cnvtreal(requestin->list_0[d.seq].data_type_value), temp_import->records[
     cnt].map_data_type_display = trim(requestin->list_0[d.seq].map_data_type_display),
     temp_import->records[cnt].sequence = cnvtint(requestin->list_0[d.seq].sequence)
    ENDIF
   FOOT REPORT
    stat = alterlist(temp_import->records,cnt), req_cnt = cnt, common_cat_id = temp_import->records[
    cnt].br_datamart_category_id
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror(
    "Failed to select rows from  br_datamart_category,br_datamart_filter_category, and code_value tables :",
    serrmsg)
  ENDIF
 ENDIF
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM br_datam_mapping_type b,
   br_datamart_category c,
   br_datamart_filter_category fc
  PLAN (b
   WHERE b.br_datamart_category_id=common_cat_id)
   JOIN (c
   WHERE c.br_datamart_category_id=common_cat_id)
   JOIN (fc
   WHERE fc.br_datamart_filter_category_id=b.br_datamart_filter_category_id)
  DETAIL
   t2 = locateval(ind,1,req_cnt,b.br_datamart_filter_category_id,temp_import->records[ind].
    br_datamart_filter_category_id,
    b.map_data_type_cd,temp_import->records[ind].map_data_type_cd)
   IF (t2=0)
    remove_cnt = (remove_cnt+ 1), stat = alterlist(temp_remove->records,remove_cnt), temp_remove->
    records[remove_cnt].br_datamart_mapping_type_id = b.br_datam_mapping_type_id,
    temp_remove->records[remove_cnt].br_datamart_category_id = b.br_datamart_category_id, temp_remove
    ->records[remove_cnt].category_name = c.category_name, temp_remove->records[remove_cnt].
    category_mean = c.category_mean,
    temp_remove->records[remove_cnt].br_datamart_filter_category_id = b
    .br_datamart_filter_category_id, temp_remove->records[remove_cnt].filter_cat_mean = fc
    .filter_category_mean, temp_remove->records[remove_cnt].filter_cat_type_mean = fc
    .filter_category_type_mean,
    temp_remove->records[remove_cnt].map_data_type_cd = b.map_data_type_cd, temp_remove->records[
    remove_cnt].map_data_type_value = b.map_data_type_value, temp_remove->records[remove_cnt].
    map_data_type_display = b.map_data_type_display,
    temp_remove->records[remove_cnt].sequence = b.display_seq
   ELSE
    update_cnt = (update_cnt+ 1), stat = alterlist(temp_update->records,update_cnt), temp_update->
    records[update_cnt].br_datamart_mapping_type_id = b.br_datam_mapping_type_id,
    temp_update->records[update_cnt].br_datamart_category_id = b.br_datamart_category_id, temp_update
    ->records[update_cnt].br_datamart_filter_category_id = b.br_datamart_filter_category_id,
    temp_update->records[update_cnt].map_data_type_cd = b.map_data_type_cd,
    temp_update->records[update_cnt].map_data_type_value = b.map_data_type_value, temp_update->
    records[update_cnt].map_data_type_display = b.map_data_type_display, temp_update->records[
    update_cnt].sequence = b.display_seq
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL logerror("Failed to select rows from br_datam_mapping_type table",serrmsg)
 ENDIF
 FOR (requestindex = 1 TO req_cnt)
  IF (update_cnt > 0)
   SET t1 = locateval(ind,1,update_cnt,temp_import->records[requestindex].br_datamart_category_id,
    temp_update->records[ind].br_datamart_category_id,
    temp_import->records[requestindex].br_datamart_filter_category_id,temp_update->records[ind].
    br_datamart_filter_category_id,temp_import->records[requestindex].map_data_type_cd,temp_update->
    records[ind].map_data_type_cd)
  ENDIF
  IF (t1=0)
   SET insert_cnt = (insert_cnt+ 1)
   SET stat = alterlist(temp_insert->records,insert_cnt)
   SET temp_insert->records[insert_cnt].br_datamart_category_id = temp_import->records[requestindex].
   br_datamart_category_id
   SET temp_insert->records[insert_cnt].br_datamart_filter_category_id = temp_import->records[
   requestindex].br_datamart_filter_category_id
   SET temp_insert->records[insert_cnt].map_data_type_cd = temp_import->records[requestindex].
   map_data_type_cd
   SET temp_insert->records[insert_cnt].map_data_type_value = temp_import->records[requestindex].
   map_data_type_value
   SET temp_insert->records[insert_cnt].map_data_type_display = temp_import->records[requestindex].
   map_data_type_display
   SET temp_insert->records[insert_cnt].sequence = temp_import->records[requestindex].sequence
  ENDIF
 ENDFOR
 FOR (ind = 1 TO insert_cnt)
   SELECT INTO "NL:"
    j = seq(bedrock_seq,nextval)"##################;rp0"
    FROM dual d
    PLAN (d)
    DETAIL
     temp_insert->records[ind].br_datamart_mapping_type_id = cnvtreal(j)
    WITH format, counter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    CALL logerror("Failed to generate new IDs:",serrmsg)
   ENDIF
 ENDFOR
 IF (insert_cnt > 0)
  INSERT  FROM br_datam_mapping_type b,
    (dummyt d  WITH seq = value(insert_cnt))
   SET b.br_datam_mapping_type_id = temp_insert->records[d.seq].br_datamart_mapping_type_id, b
    .br_datamart_category_id = temp_insert->records[d.seq].br_datamart_category_id, b
    .br_datamart_filter_category_id = temp_insert->records[d.seq].br_datamart_filter_category_id,
    b.map_data_type_cd = temp_insert->records[d.seq].map_data_type_cd, b.map_data_type_value =
    temp_insert->records[d.seq].map_data_type_value, b.map_data_type_display = temp_insert->records[d
    .seq].map_data_type_display,
    b.display_seq = temp_insert->records[d.seq].sequence, b.updt_applctx = reqinfo->updt_applctx, b
    .updt_cnt = 0,
    b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
    reqinfo->updt_task
   PLAN (d)
    JOIN (b)
   WITH nocounter
  ;end insert
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to insert rows into br_datam_mapping_type table: ",
    errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 IF (update_cnt > 0)
  UPDATE  FROM br_datam_mapping_type b,
    (dummyt d  WITH seq = value(update_cnt))
   SET b.map_data_type_value = temp_update->records[d.seq].map_data_type_value, b
    .map_data_type_display = temp_update->records[d.seq].map_data_type_display, b.display_seq =
    temp_update->records[d.seq].sequence,
    b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (b
    WHERE (b.br_datam_mapping_type_id=temp_update->records[d.seq].br_datamart_mapping_type_id))
   WITH nocounter
  ;end update
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to update rows into br_datam_mapping_type table: ",
    errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 IF (remove_cnt > 0)
  IF (validate(readme_data->readme_id,0) > 0)
   CALL echoxml(readme_data,diagnostics_file_name,1)
  ENDIF
  SELECT INTO value(diagnostics_file_name)
   timestamp = format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;s"), map_category_id = cnvtstring(
    temp_remove->records[d.seq].br_datamart_category_id), map_category_name = temp_remove->records[d
   .seq].category_name,
   map_category_mean = temp_remove->records[d.seq].category_mean, map_data_type_id = cnvtstring(
    temp_remove->records[d.seq].map_data_type_cd), map_filter_cat_mean = temp_remove->records[d.seq].
   filter_cat_mean,
   map_filter_cat_type_mean = temp_remove->records[d.seq].filter_cat_type_mean
   FROM (dummyt d  WITH seq = value(size(temp_remove->records,5)))
   PLAN (d
    WHERE (temp_remove->records[d.seq].br_datamart_category_id > 0.0))
   WITH append, heading, format,
    counter, maxcol = 600, separator = "|"
  ;end select
  SELECT INTO "nl:"
   FROM br_datamart_value v,
    br_datamart_filter f,
    (dummyt d  WITH seq = value(remove_cnt))
   PLAN (d)
    JOIN (v
    WHERE (v.br_datamart_category_id=temp_remove->records[d.seq].br_datamart_category_id)
     AND (v.map_data_type_cd=temp_remove->records[d.seq].map_data_type_cd))
    JOIN (f
    WHERE f.br_datamart_filter_id=v.br_datamart_filter_id
     AND (f.filter_category_mean=temp_remove->records[d.seq].filter_cat_mean))
   DETAIL
    dmart_cnt = (dmart_cnt+ 1), stat = alterlist(datamart_values_req->items,dmart_cnt),
    datamart_values_req->items[dmart_cnt].br_datamart_value_id = v.br_datamart_value_id
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Failed to select rows from br_datamart_value table:",serrmsg)
  ENDIF
  EXECUTE br_get_linked_values  WITH replace("REQUEST",datamart_values_req), replace("REPLY",
   datamart_values_rep)
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Error executing the script br_get_linked_values: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  SET dmart_rep = size(datamart_values_rep->items,5)
  IF (dmart_rep > 0)
   SELECT INTO "nl:"
    FROM br_datamart_value v
    PLAN (v
     WHERE expand(idx,1,dmart_rep,v.br_datamart_value_id,datamart_values_rep->items[idx].
      br_datamart_value_id))
    ORDER BY v.br_datamart_value_id
    HEAD REPORT
     delete_hist_cnt = 0, stat = alterlist(delete_hist->deleted_items,10)
    HEAD v.br_datamart_value_id
     delete_hist_cnt = (delete_hist_cnt+ 1)
     IF (mod(delete_hist_cnt,10)=1
      AND delete_hist_cnt > 10)
      stat = alterlist(delete_hist->deleted_items,(delete_hist_cnt+ 10))
     ENDIF
    DETAIL
     delete_hist->deleted_items[delete_hist_cnt].parent_entity_id = v.br_datamart_value_id,
     delete_hist->deleted_items[delete_hist_cnt].parent_entity_name = "BR_DATAMART_VALUE"
    FOOT REPORT
     stat = alterlist(delete_hist->deleted_items,delete_hist_cnt)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    CALL logerror("Failed to select rows from br_datamart_value table:",serrmsg)
   ENDIF
   DELETE  FROM br_datamart_value v,
     (dummyt d  WITH seq = value(dmart_rep))
    SET v.seq = 1
    PLAN (d)
     JOIN (v
     WHERE (v.br_datamart_value_id=datamart_values_rep->items[d.seq].br_datamart_value_id))
    WITH nocounter
   ;end delete
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to delete rows from br_datamart_value table: ",errmsg)
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
     deleted_items[d.seq].parent_entity_name, his.parent_entity_id = delete_hist->deleted_items[d.seq
     ].parent_entity_id,
     his.updt_dt_tm = cnvtdatetime(curdate,curtime3), his.updt_id = reqinfo->updt_id, his.updt_task
      = reqinfo->updt_task,
     his.updt_cnt = 0, his.updt_applctx = reqinfo->updt_applctx, his.create_dt_tm = cnvtdatetime(
      curdate,curtime3)
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
  DELETE  FROM br_datam_mapping_type b,
    (dummyt d  WITH seq = value(remove_cnt))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datam_mapping_type_id=temp_remove->records[d.seq].br_datamart_mapping_type_id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to delete rows from br_datam_mapping_type table: ",
    errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_dmart_map_types_config.prg> script"
 SUBROUTINE logerror(namemsg,valuemsg)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Readme Failed: ",namemsg,":",valuemsg)
   GO TO exit_script
 END ;Subroutine
#exit_script
 CALL echorecord(readme_data)
 FREE SET temp_import
 FREE SET temp_update
 FREE SET temp_insert
 FREE SET temp_remove
 FREE SET datamart_values_req
 FREE SET datamart_values_rep
 FREE SET delete_hist
END GO

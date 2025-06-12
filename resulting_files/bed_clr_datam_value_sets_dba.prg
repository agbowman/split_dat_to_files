CREATE PROGRAM bed_clr_datam_value_sets:dba
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
 SET readme_data->message = "Readme Failed: Starting <bed_ens_clr_datam_value_sets.prg> script"
 FREE RECORD items_to_del
 RECORD items_to_del(
   1 val_sets[*]
     2 val_set_id = f8
     2 items[*]
       3 value_set_item_id = f8
 )
 FREE RECORD sets_to_del
 RECORD sets_to_del(
   1 value_sets[*]
     2 value_set_id = f8
 )
 FREE RECORD filters_to_del
 RECORD filters_to_del(
   1 filters[*]
     2 filter_id = f8
 )
 FREE RECORD collapsed_items_to_del
 RECORD collapsed_items_to_del(
   1 items[*]
     2 value_set_item_id = f8
 )
 FREE RECORD saved_values_to_del
 RECORD saved_values_to_del(
   1 items[*]
     2 br_datamart_value_id = f8
 )
 FREE RECORD relatedvalsreply
 RECORD relatedvalsreply(
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
 FREE RECORD clearedeventsreply
 RECORD clearedeventsreply(
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
 FREE RECORD filter_vals_to_delete
 RECORD filter_vals_to_delete(
   1 filters[*]
     2 filter_id = f8
 )
 FREE RECORD idstodelete
 RECORD idstodelete(
   1 deleted_items[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
 )
 FREE RECORD br_existsinfo
 RECORD br_existsinfo(
   1 list_0[*]
     2 existsind = i2
 )
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE relatedvalsreplysize = i4 WITH protect, noconstant(0)
 DECLARE clearedeventsreplysize = i4 WITH protect, noconstant(0)
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET val_sets_ct = 0
 SET value_set_item_cnt = 0
 SELECT INTO "nl:"
  FROM br_datam_val_set_item i
  WHERE  NOT ( EXISTS (
  (SELECT
   m.br_datam_val_set_item_id
   FROM br_datam_val_set_item_meas m
   WHERE m.br_datam_val_set_item_id=i.br_datam_val_set_item_id)))
  ORDER BY i.br_datam_val_set_id, i.br_datam_val_set_item_id
  HEAD REPORT
   stat = alterlist(items_to_del->val_sets,100)
  HEAD i.br_datam_val_set_id
   value_set_item_cnt = 0
   IF (i.br_datam_val_set_id > 0)
    val_sets_ct = (val_sets_ct+ 1)
    IF (mod(val_sets_ct,100)=1)
     stat = alterlist(items_to_del->val_sets,(val_sets_ct+ 99))
    ENDIF
    items_to_del->val_sets[val_sets_ct].val_set_id = i.br_datam_val_set_id, stat = alterlist(
     items_to_del->val_sets[val_sets_ct].items,100)
   ENDIF
  HEAD i.br_datam_val_set_item_id
   IF (i.br_datam_val_set_item_id > 0)
    value_set_item_cnt = (value_set_item_cnt+ 1)
    IF (mod(value_set_item_cnt,100)=1)
     stat = alterlist(items_to_del->val_sets[val_sets_ct].items,(value_set_item_cnt+ 99))
    ENDIF
    items_to_del->val_sets[val_sets_ct].items[value_set_item_cnt].value_set_item_id = i
    .br_datam_val_set_item_id
   ENDIF
  FOOT  i.br_datam_val_set_id
   stat = alterlist(items_to_del->val_sets[val_sets_ct].items,value_set_item_cnt)
  FOOT REPORT
   stat = alterlist(items_to_del->val_sets,val_sets_ct)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL logerror("Failed to select rows from br_datam_val_set_item table:",serrmsg)
 ENDIF
 IF (val_sets_ct > 0)
  SET set_item_ct = 0
  SET value_set_cnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(val_sets_ct)),
    br_datam_val_set_item i
   PLAN (d)
    JOIN (i
    WHERE (i.br_datam_val_set_id=items_to_del->val_sets[d.seq].val_set_id))
   ORDER BY i.br_datam_val_set_id, i.br_datam_val_set_item_id
   HEAD i.br_datam_val_set_id
    IF (i.br_datam_val_set_id > 0)
     set_item_ct = 0
    ENDIF
   HEAD i.br_datam_val_set_item_id
    IF (i.br_datam_val_set_item_id > 0)
     set_item_ct = (set_item_ct+ 1)
    ENDIF
   FOOT  i.br_datam_val_set_id
    IF (size(items_to_del->val_sets[d.seq].items,5)=set_item_ct)
     value_set_cnt = (value_set_cnt+ 1), stat = alterlist(sets_to_del->value_sets,value_set_cnt),
     sets_to_del->value_sets[value_set_cnt].value_set_id = i.br_datam_val_set_id
    ENDIF
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Failed to select rows from br_datam_val_set_item table:",serrmsg)
  ENDIF
 ENDIF
 SET filter_vals_cnt = 0
 SET tot_set_del = size(sets_to_del->value_sets,5)
 IF (tot_set_del > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tot_set_del)),
    br_datamart_filter f
   PLAN (d)
    JOIN (f
    WHERE (f.inaction_reason_value_set_id=sets_to_del->value_sets[d.seq].value_set_id))
   ORDER BY f.br_datamart_filter_id
   HEAD f.br_datamart_filter_id
    IF (f.br_datamart_filter_id > 0)
     filter_vals_cnt = (filter_vals_cnt+ 1), stat = alterlist(filter_vals_to_delete->filters,
      filter_vals_cnt), filter_vals_to_delete->filters[filter_vals_cnt].filter_id = f
     .br_datamart_filter_id
    ENDIF
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Failed to select rows from br_datamart_filter table:",serrmsg)
  ENDIF
 ENDIF
 IF (filter_vals_cnt > 0)
  UPDATE  FROM br_datamart_filter b,
    (dummyt d  WITH seq = value(filter_vals_cnt))
   SET b.inaction_reason_value_set_id = 0.0, b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_filter_id=filter_vals_to_delete->filters[d.seq].filter_id))
   WITH nocounter
  ;end update
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Error updating br_datamart_filter table negation: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET filter_cnt = 0
 SET idx = 0
 SET tot_set_del = size(sets_to_del->value_sets,5)
 IF (tot_set_del > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tot_set_del)),
    br_datamart_filter f
   PLAN (d)
    JOIN (f
    WHERE (f.expected_action_value_set_id=sets_to_del->value_sets[d.seq].value_set_id))
   ORDER BY f.br_datamart_filter_id
   HEAD f.br_datamart_filter_id
    IF (f.br_datamart_filter_id > 0)
     filter_vals_cnt = (filter_vals_cnt+ 1), stat = alterlist(filter_vals_to_delete->filters,
      filter_vals_cnt), filter_vals_to_delete->filters[filter_vals_cnt].filter_id = f
     .br_datamart_filter_id,
     filter_cnt = (filter_cnt+ 1), stat = alterlist(filters_to_del->filters,filter_cnt),
     filters_to_del->filters[filter_cnt].filter_id = f.br_datamart_filter_id
    ENDIF
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Failed to select rows from br_datamart_filter table:",serrmsg)
  ENDIF
 ENDIF
 SET idx = 0
 IF (filter_vals_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(filter_vals_cnt)),
    br_datamart_value b
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_filter_id=filter_vals_to_delete->filters[d.seq].filter_id))
   ORDER BY b.br_datamart_value_id
   HEAD REPORT
    cnt = 0, stat = alterlist(idstodelete->deleted_items,50)
   HEAD b.br_datamart_value_id
    cnt = (cnt+ 1)
    IF (mod(cnt,50)=1)
     stat = alterlist(idstodelete->deleted_items,(cnt+ 49))
    ENDIF
    idstodelete->deleted_items[cnt].parent_entity_id = b.br_datamart_value_id, idstodelete->
    deleted_items[cnt].parent_entity_name = "BR_DATAMART_VALUE"
   FOOT REPORT
    stat = alterlist(idstodelete->deleted_items,cnt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Failed to select rows from br_datamart_value table:",serrmsg)
  ENDIF
  DELETE  FROM br_datamart_value v,
    (dummyt d  WITH seq = value(filter_vals_cnt))
   SET v.seq = 1
   PLAN (d)
    JOIN (v
    WHERE (v.br_datamart_filter_id=filter_vals_to_delete->filters[d.seq].filter_id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Error deleting from br_datam_value table: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  IF (cnt > 0)
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
   SET stat = alterlist(br_existsinfo->list_0,cnt)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(cnt)),
     br_delete_hist his
    PLAN (d)
     JOIN (his
     WHERE (his.parent_entity_id=idstodelete->deleted_items[d.seq].parent_entity_id)
      AND (his.parent_entity_name=idstodelete->deleted_items[d.seq].parent_entity_name))
    DETAIL
     br_existsinfo->list_0[d.seq].existsind = 1
    WITH nocounter
   ;end select
   INSERT  FROM br_delete_hist his,
     (dummyt d  WITH seq = value(cnt))
    SET his.br_delete_hist_id = seq(bedrock_seq,nextval), his.parent_entity_name = idstodelete->
     deleted_items[d.seq].parent_entity_name, his.parent_entity_id = idstodelete->deleted_items[d.seq
     ].parent_entity_id,
     his.updt_dt_tm = cnvtdatetime(curdate,curtime3), his.updt_id = reqinfo->updt_id, his.updt_task
      = reqinfo->updt_task,
     his.updt_cnt = 0, his.updt_applctx = reqinfo->updt_applctx, his.create_dt_tm = cnvtdatetime(
      curdate,curtime3)
    PLAN (d)
     JOIN (his
     WHERE (br_existsinfo->list_0[d.seq].existsind=0))
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
 ENDIF
 IF (filter_cnt > 0)
  DELETE  FROM br_datamart_report_filter_r b,
    (dummyt d  WITH seq = value(filter_cnt))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_filter_id=filters_to_del->filters[d.seq].filter_id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Error deleting from br_datamart_report_filter_r: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM br_datamart_default_detail dd,
    (dummyt d  WITH seq = value(filter_cnt))
   SET dd.seq = 1
   PLAN (d)
    JOIN (dd
    WHERE dd.br_datamart_default_id IN (
    (SELECT
     dd2.br_datamart_default_id
     FROM br_datamart_default_detail dd2,
      br_datamart_default bd
     WHERE dd2.br_datamart_default_id=bd.br_datamart_default_id
      AND (bd.br_datamart_filter_id=filters_to_del->filters[d.seq].filter_id))))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Error deleting from br_datamart_default_detail: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM br_datamart_default b,
    (dummyt d  WITH seq = value(filter_cnt))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_filter_id=filters_to_del->filters[d.seq].filter_id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Error deleting from br_datamart_default: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM br_datamart_text b,
    (dummyt d  WITH seq = value(filter_cnt))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_filter_id=filters_to_del->filters[d.seq].filter_id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Error deleting from br_datamart_text: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM br_datamart_filter b,
    (dummyt d  WITH seq = value(filter_cnt))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_filter_id=filters_to_del->filters[d.seq].filter_id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Error deleting from br_datamart_filter: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET vals_to_del_cnt = 0
 IF (value_set_item_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(val_sets_ct)),
    (dummyt d2  WITH seq = 1),
    br_datamart_value v
   PLAN (d
    WHERE maxrec(d2,size(items_to_del->val_sets[d.seq].items,5)))
    JOIN (d2)
    JOIN (v
    WHERE (v.parent_entity_id2=items_to_del->val_sets[d.seq].items[d2.seq].value_set_item_id))
   ORDER BY v.br_datamart_value_id
   HEAD v.br_datamart_value_id
    IF (v.br_datamart_value_id > 0)
     vals_to_del_cnt = (vals_to_del_cnt+ 1), stat = alterlist(saved_values_to_del->items,
      vals_to_del_cnt), saved_values_to_del->items[vals_to_del_cnt].br_datamart_value_id = v
     .br_datamart_value_id
    ENDIF
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Failed to select rows from br_datamart_value table: :",serrmsg)
  ENDIF
 ENDIF
 IF (vals_to_del_cnt > 0)
  EXECUTE br_get_linked_values  WITH replace("REQUEST",saved_values_to_del), replace("REPLY",
   relatedvalsreply)
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Error executing the script br_get_linked_values: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  SET relatedvalsreplysize = size(relatedvalsreply->items,5)
  IF (relatedvalsreplysize > 0)
   EXECUTE bed_clr_used_events  WITH replace("REQUEST",relatedvalsreply), replace("REPLY",
    clearedeventsreply)
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error executing the script bed_clr_used_events: ",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ENDIF
  SET clearedeventsreplysize = size(clearedeventsreply->items,5)
  IF (clearedeventsreplysize > 0)
   DELETE  FROM br_datamart_value v,
     (dummyt d  WITH seq = value(size(clearedeventsreply->items,5)))
    SET v.seq = 1
    PLAN (d)
     JOIN (v
     WHERE (v.br_datamart_value_id=clearedeventsreply->items[d.seq].br_datamart_value_id))
    WITH nocounter
   ;end delete
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error deleting from br_datamart_default: ",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ENDIF
 ENDIF
 SET tot_item_del = size(items_to_del->val_sets,5)
 SET total_count = 0
 IF (tot_item_del > 0)
  FOR (i = 1 TO tot_item_del)
    FOR (k = 1 TO size(items_to_del->val_sets[i].items,5))
      SET total_count = (total_count+ 1)
      SET stat = alterlist(collapsed_items_to_del->items,total_count)
      SET collapsed_items_to_del->items[total_count].value_set_item_id = items_to_del->val_sets[i].
      items[k].value_set_item_id
    ENDFOR
  ENDFOR
  DELETE  FROM br_datam_val_set_item i,
    (dummyt d  WITH seq = value(total_count))
   SET i.seq = 1
   PLAN (d)
    JOIN (i
    WHERE (i.br_datam_val_set_item_id=collapsed_items_to_del->items[d.seq].value_set_item_id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Error deleting from br_datamart_default: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET tot_set_del = size(sets_to_del->value_sets,5)
 IF (tot_set_del > 0)
  DELETE  FROM br_datam_val_set v,
    (dummyt d  WITH seq = value(tot_set_del))
   SET v.seq = 1
   PLAN (d)
    JOIN (v
    WHERE (v.br_datam_val_set_id=sets_to_del->value_sets[d.seq].value_set_id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Error deleting from br_datamart_default: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <bed_ens_clr_datam_value_sets.prg> script"
 SUBROUTINE logerror(namemsg,valuemsg)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Readme Failed: ",namemsg,":",valuemsg)
   GO TO exit_script
 END ;Subroutine
#exit_script
 CALL echorecord(readme_data)
 FREE RECORD items_to_del
 FREE RECORD sets_to_del
 FREE RECORD filters_to_del
 FREE RECORD collapsed_items_to_del
 FREE RECORD saved_values_to_del
 FREE RECORD relatedvalsreply
 FREE RECORD clearedeventsreply
 FREE RECORD filter_vals_to_delete
 FREE RECORD idstodelete
END GO

CREATE PROGRAM br_upd_dmart_base_and_target:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_upd_dmart_base_and_target.prg> script"
 DECLARE errmsg = vc WITH protect
 DECLARE errcode = i4 WITH protect, noconstant(0)
 INSERT  FROM br_name_value br
  SET br.br_name_value_id = seq(bedrock_seq,nextval), br.br_nv_key1 = "LH_BASE_TARGET_UPD", br
   .br_name = " ",
   br.br_value = " ", br.updt_cnt = 0, br.updt_dt_tm = cnvtdatetime(curdate,curtime),
   br.updt_id = reqinfo->updt_id, br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo->
   updt_applctx
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Inserting br_name_value row: ",errmsg)
  GO TO exit_script
 ENDIF
 FREE SET temp
 RECORD temp(
   1 reports[*]
     2 id = f8
     2 baseline_value = vc
     2 target_value = vc
     2 category_id = f8
 )
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM br_datamart_category c,
   br_datamart_report r
  PLAN (c
   WHERE c.category_type_flag=0)
   JOIN (r
   WHERE r.br_datamart_category_id=c.br_datamart_category_id
    AND r.br_datamart_report_id > 0)
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(temp->reports,tcnt), temp->reports[tcnt].id = r
   .br_datamart_report_id,
   temp->reports[tcnt].baseline_value = r.baseline_value, temp->reports[tcnt].target_value = r
   .target_value, temp->reports[tcnt].category_id = r.br_datamart_category_id
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Selecting br_datamart_report row: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (tcnt > 0)
  INSERT  FROM br_datamart_value b,
    (dummyt d  WITH seq = value(tcnt))
   SET b.br_datamart_value_id = seq(bedrock_seq,nextval), b.br_datamart_category_id = temp->reports[d
    .seq].category_id, b.parent_entity_name = "BR_DATAMART_REPORT",
    b.parent_entity_id = temp->reports[d.seq].id, b.mpage_param_mean = "baseline", b
    .mpage_param_value = temp->reports[d.seq].baseline_value,
    b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), b.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), b.updt_cnt = 0,
    b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo
    ->updt_task,
    b.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (b)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Readme Failed: Inserting br_datamart_value row: ",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM br_datamart_value b,
    (dummyt d  WITH seq = value(tcnt))
   SET b.br_datamart_value_id = seq(bedrock_seq,nextval), b.br_datamart_category_id = temp->reports[d
    .seq].category_id, b.parent_entity_name = "BR_DATAMART_REPORT",
    b.parent_entity_id = temp->reports[d.seq].id, b.mpage_param_mean = "target", b.mpage_param_value
     = temp->reports[d.seq].target_value,
    b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), b.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), b.updt_cnt = 0,
    b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo
    ->updt_task,
    b.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (b)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Readme Failed: Inserting br_datamart_value row: ",errmsg)
   GO TO exit_script
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_upd_dmart_base_and_target.prg> script"
 IF (errcode=0)
  COMMIT
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

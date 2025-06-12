CREATE PROGRAM br_dim_import_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_dim_import_config.prg> script"
 FREE SET temp_prg
 RECORD temp_prg(
   1 programs[*]
     2 br_hlth_sntry_item_id = f8
     2 dim_item_ident = f8
     2 code_set = i4
     2 description_1 = vc
     2 description_2 = vc
     2 description_3 = vc
     2 description_4 = vc
     2 description_5 = vc
     2 description_6 = vc
     2 ignore_ind = i2
 )
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET req_cnt = size(requestin->list_0,5)
 IF (req_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt))
   PLAN (d)
   HEAD REPORT
    stat = alterlist(temp_prg->programs,req_cnt)
   DETAIL
    IF ((requestin->list_0[d.seq].dim_item_ident > " "))
     temp_prg->programs[d.seq].dim_item_ident = cnvtreal(requestin->list_0[d.seq].dim_item_ident),
     temp_prg->programs[d.seq].code_set = cnvtint(requestin->list_0[d.seq].code_set), temp_prg->
     programs[d.seq].description_1 = requestin->list_0[d.seq].description_1,
     temp_prg->programs[d.seq].description_2 = requestin->list_0[d.seq].description_2, temp_prg->
     programs[d.seq].description_3 = requestin->list_0[d.seq].description_3, temp_prg->programs[d.seq
     ].description_4 = requestin->list_0[d.seq].description_4,
     temp_prg->programs[d.seq].description_5 = requestin->list_0[d.seq].description_5, temp_prg->
     programs[d.seq].description_6 = requestin->list_0[d.seq].description_6
     IF ((temp_prg->programs[d.seq].code_set IN (200, 1021, 1022, 14003, 72)))
      temp_prg->programs[d.seq].ignore_ind = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure selecting dim data from requestin list >> ",errmsg)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt)),
    br_hlth_sntry_item hsi
   PLAN (d)
    JOIN (hsi
    WHERE (hsi.dim_item_ident=temp_prg->programs[d.seq].dim_item_ident)
     AND (hsi.code_set=temp_prg->programs[d.seq].code_set))
   DETAIL
    temp_prg->programs[d.seq].br_hlth_sntry_item_id = hsi.br_hlth_sntry_item_id
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure selecting existing health sentry items >> ",errmsg)
   GO TO exit_script
  ENDIF
  UPDATE  FROM br_hlth_sntry_item hsi,
    (dummyt d  WITH seq = value(req_cnt))
   SET hsi.description_1 = temp_prg->programs[d.seq].description_1, hsi.description_2 = temp_prg->
    programs[d.seq].description_2, hsi.description_3 = temp_prg->programs[d.seq].description_3,
    hsi.description_4 = temp_prg->programs[d.seq].description_4, hsi.description_5 = temp_prg->
    programs[d.seq].description_5, hsi.description_6 = temp_prg->programs[d.seq].description_6,
    hsi.ignore_ind = temp_prg->programs[d.seq].ignore_ind, hsi.updt_cnt = (hsi.updt_cnt+ 1), hsi
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    hsi.updt_id = reqinfo->updt_id, hsi.updt_applctx = reqinfo->updt_applctx, hsi.updt_task = reqinfo
    ->updt_task
   PLAN (d
    WHERE (temp_prg->programs[d.seq].br_hlth_sntry_item_id > 0.0))
    JOIN (hsi
    WHERE (hsi.br_hlth_sntry_item_id=temp_prg->programs[d.seq].br_hlth_sntry_item_id))
   WITH nocounter
  ;end update
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure updating health sentry items >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  INSERT  FROM br_hlth_sntry_item hsi,
    (dummyt d  WITH seq = value(req_cnt))
   SET hsi.br_hlth_sntry_item_id = seq(bedrock_seq,nextval), hsi.code_set = temp_prg->programs[d.seq]
    .code_set, hsi.dim_item_ident = temp_prg->programs[d.seq].dim_item_ident,
    hsi.description_1 = temp_prg->programs[d.seq].description_1, hsi.description_2 = temp_prg->
    programs[d.seq].description_2, hsi.description_3 = temp_prg->programs[d.seq].description_3,
    hsi.description_4 = temp_prg->programs[d.seq].description_4, hsi.description_5 = temp_prg->
    programs[d.seq].description_5, hsi.description_6 = temp_prg->programs[d.seq].description_6,
    hsi.ignore_ind = temp_prg->programs[d.seq].ignore_ind, hsi.updt_cnt = 0, hsi.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    hsi.updt_id = reqinfo->updt_id, hsi.updt_applctx = reqinfo->updt_applctx, hsi.updt_task = reqinfo
    ->updt_task
   PLAN (d
    WHERE (temp_prg->programs[d.seq].br_hlth_sntry_item_id=0.0))
    JOIN (hsi)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure inserting health sentry items >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_health_sent_items.prg> script"
#exit_script
 FREE SET temp_prg
END GO

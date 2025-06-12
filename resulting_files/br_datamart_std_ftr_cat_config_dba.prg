CREATE PROGRAM br_datamart_std_ftr_cat_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_datamart_std_ftr_cat_config.prg> script"
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 SET cnt = size(requestin->list_0,5)
 FREE RECORD br_existsinfo
 RECORD br_existsinfo(
   1 list_0[*]
     2 existsind = i2
 )
 SET stat = alterlist(br_existsinfo->list_0,cnt)
 SELECT INTO "nl:"
  FROM br_datamart_filter_category b,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (b
   WHERE b.filter_category_mean=cnvtupper(requestin->list_0[d.seq].filter_category_mean))
  DETAIL
   br_existsinfo->list_0[d.seq].existsind = 1
  WITH nocounter
 ;end select
 INSERT  FROM br_datamart_filter_category b,
   (dummyt d  WITH seq = value(cnt))
  SET b.br_datamart_filter_category_id = seq(bedrock_seq,nextval), b.filter_category_mean = cnvtupper
   (requestin->list_0[d.seq].filter_category_mean), b.filter_category_type_mean = cnvtupper(requestin
    ->list_0[d.seq].filter_type_mean),
   b.codeset = cnvtint(requestin->list_0[d.seq].filter_codeset), b.updt_cnt = 0, b.updt_dt_tm =
   cnvtdatetime(sysdate),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=0))
   JOIN (b)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting datamart filter categories >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_datamart_filter_category b,
   (dummyt d  WITH seq = value(cnt))
  SET b.filter_category_type_mean = cnvtupper(requestin->list_0[d.seq].filter_type_mean), b.codeset
    = cnvtint(requestin->list_0[d.seq].filter_codeset), b.updt_cnt = (b.updt_cnt+ 1),
   b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->
   updt_task,
   b.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=1))
   JOIN (b
   WHERE b.filter_category_mean=cnvtupper(requestin->list_0[d.seq].filter_category_mean))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure updating datamart filter categories >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_datamart_std_ftr_cat_config.prg> script"
#exit_script
 CALL echorecord(readme_data)
 FREE RECORD br_existsinfo
END GO

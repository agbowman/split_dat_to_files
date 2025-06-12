CREATE PROGRAM br_datamart_filter_det_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_datamart_filter_det_config.prg> script"
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 SET cnt = 0
 SET cnt = size(requestin->list_0,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 FREE RECORD filter
 RECORD filter(
   1 qual[*]
     2 id = f8
     2 field_mean = vc
     2 required_ind = i2
     2 exists_ind = i2
 )
 SET stat = alterlist(filter->qual,cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_datamart_filter b
  PLAN (d)
   JOIN (b
   WHERE cnvtupper(b.filter_mean)=cnvtupper(requestin->list_0[d.seq].filter_mean))
  ORDER BY d.seq
  HEAD d.seq
   filter->qual[d.seq].id = b.br_datamart_filter_id, filter->qual[d.seq].field_mean = requestin->
   list_0[d.seq].oe_field_mean
   IF ((requestin->list_0[d.seq].required_ind="Yes"))
    filter->qual[d.seq].required_ind = 1
   ELSE
    filter->qual[d.seq].required_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_datamart_filter_detail b
  PLAN (d)
   JOIN (b
   WHERE (b.br_datamart_filter_id=filter->qual[d.seq].id)
    AND (b.oe_field_meaning=filter->qual[d.seq].field_mean))
  ORDER BY d.seq
  HEAD d.seq
   filter->qual[d.seq].exists_ind = 1
  WITH nocounter
 ;end select
 INSERT  FROM br_datamart_filter_detail b,
   (dummyt d  WITH seq = value(cnt))
  SET b.br_datamart_filter_detail_id = seq(bedrock_seq,nextval), b.br_datamart_filter_id = filter->
   qual[d.seq].id, b.oe_field_meaning = filter->qual[d.seq].field_mean,
   b.required_ind = filter->qual[d.seq].required_ind, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(
    curdate,curtime),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (filter->qual[d.seq].id > 0)
    AND (filter->qual[d.seq].exists_ind=0))
   JOIN (b)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting datamart filter details >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_datamart_filter_detail b,
   (dummyt d  WITH seq = value(cnt))
  SET b.oe_field_meaning = filter->qual[d.seq].field_mean, b.required_ind = filter->qual[d.seq].
   required_ind, b.updt_cnt = (b.updt_cnt+ 1),
   b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo
   ->updt_task,
   b.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (filter->qual[d.seq].id > 0)
    AND (filter->qual[d.seq].exists_ind=1))
   JOIN (b
   WHERE (b.br_datamart_filter_id=filter->qual[d.seq].id)
    AND (b.oe_field_meaning=filter->qual[d.seq].field_mean))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure updating datamart filter details >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_datamart_filter_det_config.prg> script"
#exit_script
 CALL echorecord(readme_data)
END GO

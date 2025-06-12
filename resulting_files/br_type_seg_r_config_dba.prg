CREATE PROGRAM br_type_seg_r_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_type_seg_r_config.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET row_cnt = size(requestin->list_0,5)
 INSERT  FROM br_type_seg_r b,
   (dummyt d  WITH seq = value(row_cnt))
  SET b.br_type_seg_r_id = seq(bedrock_seq,nextval), b.interface_type = requestin->list_0[d.seq].
   interface_type, b.inbound_ind = evaluate(requestin->list_0[d.seq].inbound,"X",1,0),
   b.outbound_ind = evaluate(requestin->list_0[d.seq].outbound,"X",1,0), b.segment_name = requestin->
   list_0[d.seq].segment, b.required_ind = evaluate(requestin->list_0[d.seq].required,"X",1,0),
   b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting segments >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_type_seg_r_config.prg> script"
#exit_script
END GO

CREATE PROGRAM br_vocabulary_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_vocabulary_config.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET req_cnt = size(requestin->list_0,5)
 IF (req_cnt=0)
  SET readme_data->status = "F"
  SET readme_data->message = "Readme failed: br_vocabulary.csv has zero rows"
  GO TO exit_script
 ENDIF
 INSERT  FROM br_vocabulary b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.br_vocabulary_id = seq(bedrock_seq,nextval), b.source_name = trim(substring(1,40,requestin->
     list_0[d.seq].source_name)), b.source_identifier = trim(substring(1,50,requestin->list_0[d.seq].
     source_identifier)),
   b.source_string = trim(substring(1,255,requestin->list_0[d.seq].source_string)), b
   .source_vocab_mean = trim(substring(1,12,requestin->list_0[d.seq].source_vocabulary_mean)), b
   .updt_cnt = 0,
   b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_applctx =
   reqinfo->updt_applctx,
   b.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Insert into br_vocabulary: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_vocabulary_config.prg> script"
#exit_script
END GO

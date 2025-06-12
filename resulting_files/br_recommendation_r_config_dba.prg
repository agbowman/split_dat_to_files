CREATE PROGRAM br_recommendation_r_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_recommendation_r_config.prg> script"
 FREE SET temp_req
 RECORD temp_req(
   1 temp_list[*]
     2 rec_id = f8
     2 topic_mean = vc
     2 sol_mean = vc
 )
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET req_cnt = size(requestin->list_0,5)
 SET stat = alterlist(temp_req->temp_list,req_cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   br_rec b
  PLAN (d)
   JOIN (b
   WHERE b.rec_mean=cnvtupper(requestin->list_0[d.seq].bedrock_prog_meaning))
  HEAD d.seq
   temp_req->temp_list[d.seq].rec_id = b.rec_id, temp_req->temp_list[d.seq].topic_mean = requestin->
   list_0[d.seq].topic_meaning, temp_req->temp_list[d.seq].sol_mean = requestin->list_0[d.seq].
   solution_meaning
  WITH nocounter
 ;end select
 INSERT  FROM br_rec_r b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.rec_r_id = seq(bedrock_seq,nextval), b.rec_id = temp_req->temp_list[d.seq].rec_id, b
   .solution_mean = temp_req->temp_list[d.seq].sol_mean,
   b.topic_mean = temp_req->temp_list[d.seq].topic_mean, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
   updt_task
  PLAN (d
   WHERE (temp_req->temp_list[d.seq].rec_id > 0))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting recommendations >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_recommendation_r_config.prg> script"
#exit_script
 FREE SET temp_req
END GO

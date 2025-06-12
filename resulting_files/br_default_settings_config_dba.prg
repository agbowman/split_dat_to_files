CREATE PROGRAM br_default_settings_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_default_settings_config.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET cnt = size(requestin->list_0,5)
 IF (cnt=0)
  SET readme_data->status = "F"
  SET readme_data->message = "No Default Search Settings Found"
  GO TO exit_script
 ENDIF
 FREE RECORD rec_existence
 RECORD rec_existence(
   1 exist_lst[*]
     2 exist_ind = i2
 )
 SET stat = alterlist(rec_existence->exist_lst,cnt)
 SELECT INTO "NL:"
  FROM br_default_person_search bdps,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (bdps
   WHERE cnvtupper(bdps.setting_mean)=cnvtupper(trim(requestin->list_0[d.seq].setting_mean))
    AND bdps.empi_ind=cnvtint(requestin->list_0[d.seq].empi_ind)
    AND cnvtupper(bdps.display)=cnvtupper(trim(requestin->list_0[d.seq].display)))
  DETAIL
   rec_existence->exist_lst[d.seq].exist_ind = 1
  WITH nocounter
 ;end select
 INSERT  FROM br_default_person_search b,
   (dummyt d  WITH seq = value(cnt))
  SET b.br_default_person_search_id = seq(bedrock_seq,nextval), b.setting_mean = requestin->list_0[d
   .seq].setting_mean, b.empi_ind = cnvtint(requestin->list_0[d.seq].empi_ind),
   b.display = requestin->list_0[d.seq].display, b.sequence = cnvtint(requestin->list_0[d.seq].
    sequence), b.updt_id = reqinfo->updt_id,
   b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_task = reqinfo->updt_task,
   b.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (rec_existence->exist_lst[d.seq].exist_ind != 1))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error inserting new rows :",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_default_settings_config.prg> script"
 GO TO exit_script
#exit_script
 FREE RECORD rec_existence
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

CREATE PROGRAM br_time_zone_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_time_zone_config.prg> script"
 FREE SET reply
 RECORD reply(
   1 tzlist[*]
     2 tz_id = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET insert_cnt = 0
 SET new_id = 0.0
 SET row_cnt = size(requestin->list_0,5)
 SET stat = alterlist(reply->tzlist,row_cnt)
 FOR (x = 1 TO row_cnt)
  SELECT INTO "NL:"
   FROM br_time_zone b
   WHERE cnvtupper(b.description)=cnvtupper(requestin->list_0[x].description)
    AND cnvtupper(b.time_zone)=cnvtupper(requestin->list_0[x].time_zone)
    AND cnvtupper(b.region)=cnvtupper(requestin->list_0[x].region)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SELECT INTO "NL:"
    j = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_id = cnvtreal(j)
    WITH format, counter
   ;end select
   SET reply->tzlist[x].tz_id = new_id
   INSERT  FROM br_time_zone b
    SET b.time_zone_id = new_id, b.description = requestin->list_0[x].description, b.time_zone =
     requestin->list_0[x].time_zone,
     b.region = requestin->list_0[x].region, b.sequence = cnvtint(requestin->list_0[x].sequence), b
     .active_ind = 1,
     b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
     reqinfo->updt_task,
     b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "T"
    SET insert_cnt = (insert_cnt+ 1)
   ENDIF
  ENDIF
 ENDFOR
 GO TO exit_script
#exit_script
 IF (error_flag="T")
  SET error_msg = concat("Unable to insert: ",cnvtstring(insert_cnt))
  CALL echo(error_msg)
 ENDIF
 IF (((error_flag="N") OR (error_flag="T")) )
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: <br_time_zone_config.prg> script"
  COMMIT
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed: <br_time_zone_config.prg> script"
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

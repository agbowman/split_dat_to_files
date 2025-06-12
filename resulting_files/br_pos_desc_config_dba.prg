CREATE PROGRAM br_pos_desc_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_pos_desc_config.prg> script"
 RECORD requestin(
   1 list_0[*]
     2 position = c40
     2 description = vc
 )
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET error_flag = "N"
 DECLARE error_msg = vc
 SET position_code_value = 0
 SET pos_cnt = size(requestin->list_0,5)
 FOR (x = 1 TO pos_cnt)
   SET position_code_value = 0
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.active_ind=1
     AND cv.code_set=88
     AND cnvtupper(cv.display)=cnvtupper(requestin->list_0[x].position)
    DETAIL
     position_code_value = cv.code_value
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SELECT INTO "NL:"
     FROM br_long_text lt
     WHERE lt.parent_entity_id=position_code_value
      AND lt.parent_entity_name="CODE_VALUE"
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET new_id = 0.0
     SELECT INTO "NL:"
      j = seq(reference_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_id = cnvtreal(j)
      WITH format, counter
     ;end select
     INSERT  FROM br_long_text lt
      SET lt.long_text_id = new_id, lt.long_text = requestin->list_0[x].description, lt
       .parent_entity_id = position_code_value,
       lt.parent_entity_name = "CODE_VALUE", lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt
       .updt_id = reqinfo->updt_id,
       lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "T"
      SET error_msg = concat(trim(requestin->list_0[x].position),
       " description was not inserted into the br_long_text table.")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BR_POS_DESC_CONFIG","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 IF (((error_flag="N") OR (error_flag="T")) )
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: <br_pos_desc_config.prg> script"
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed: <br_pos_desc_config.prg> script"
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

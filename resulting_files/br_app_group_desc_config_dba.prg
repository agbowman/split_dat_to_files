CREATE PROGRAM br_app_group_desc_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_app_group_desc_config.prg> script"
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
 SET insert_cnt = 0
 SET app_group_code_value = 0.0
 SET app_cnt = size(requestin->list_0,5)
 FOR (x = 1 TO app_cnt)
   SET app_group_code_value = 0.0
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.active_ind=1
     AND cv.code_set=500
     AND cnvtupper(cv.display)=cnvtupper(requestin->list_0[x].application_group)
    DETAIL
     app_group_code_value = cv.code_value
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SELECT INTO "NL:"
     FROM br_long_text lt
     WHERE lt.parent_entity_id=app_group_code_value
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
       .parent_entity_id = app_group_code_value,
       lt.parent_entity_name = "CODE_VALUE", lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt
       .updt_id = reqinfo->updt_id,
       lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "T"
      SET insert_cnt = (insert_cnt+ 1)
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="T")
  SET error_msg = concat("Unable to insert: ",cnvtstring(insert_cnt))
  CALL echo(error_msg)
 ENDIF
 IF (((error_flag="N") OR (error_flag="T")) )
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: <br_app_group_desc_config.prg> script"
  COMMIT
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed: <br_app_group_desc_config.prg> script"
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

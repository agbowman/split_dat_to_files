CREATE PROGRAM br_pos_rel_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_pos_rel_config.prg> script"
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
 SET insert_cnt = 0
 DECLARE error_msg = vc
 SET last_position_category_id = 0.0
 SET last_position_category = fillstring(40," ")
 SET position_code_value = 0.0
 SET pos_cnt = size(requestin->list_0,5)
 SET max_sequence = 0
 FOR (x = 1 TO pos_cnt)
  IF (last_position_category != cnvtupper(requestin->list_0[x].category))
   SELECT INTO "NL:"
    FROM br_position_category bpc
    WHERE bpc.active_ind=1
     AND cnvtupper(bpc.description)=cnvtupper(requestin->list_0[x].category)
    DETAIL
     last_position_category_id = bpc.category_id, last_position_category = cnvtupper(bpc.description)
    WITH nocounter
   ;end select
  ENDIF
  IF (last_position_category_id > 0)
   SET position_code_value = 0.0
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
    IF ((requestin->list_0[x].action_flag="1"))
     SET max_sequence = 0
     SELECT INTO "NL:"
      FROM br_position_cat_comp bpcc
      WHERE bpcc.category_id=last_position_category_id
      ORDER BY bpcc.sequence
      DETAIL
       max_sequence = bpcc.sequence
      WITH nocounter
     ;end select
     SELECT INTO "NL:"
      FROM br_position_cat_comp bpcc
      WHERE bpcc.category_id=last_position_category_id
       AND bpcc.position_cd=position_code_value
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM br_position_cat_comp bpcc
       SET bpcc.category_id = last_position_category_id, bpcc.br_client_id = 1.0, bpcc.position_cd =
        position_code_value,
        bpcc.sequence = (max_sequence+ 1), bpcc.physician_ind =
        IF ((((requestin->list_0[x].physician_ind="Y")) OR ((((requestin->list_0[x].physician_ind="y"
        )) OR ((requestin->list_0[x].physician_ind="1"))) )) ) 1
        ELSE 0
        ENDIF
        , bpcc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        bpcc.updt_id = reqinfo->updt_id, bpcc.updt_task = reqinfo->updt_task, bpcc.updt_applctx =
        reqinfo->updt_applctx,
        bpcc.updt_cnt = 0
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "T"
       SET insert_cnt = (insert_cnt+ 1)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 IF (error_flag="T")
  SET error_msg = concat("Unable to insert: ",cnvtstring(insert_cnt))
 ENDIF
 IF (((error_flag="N") OR (error_flag="T")) )
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: <br_pos_rel_config.prg> script"
  COMMIT
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed: <br_pos_rel_config.prg> script"
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

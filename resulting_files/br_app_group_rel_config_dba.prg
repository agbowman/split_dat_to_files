CREATE PROGRAM br_app_group_rel_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_app_group_rel_config.prg> script"
 RECORD requestin(
   1 list_0[*]
     2 application_group = c40
     2 application_group_category = c40
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
 SET appl_grp_cnt = 0
 SET insert_cnt = 0
 DECLARE error_msg = vc
 SET last_app_group_category_id = 0.0
 SET last_app_group_category = fillstring(40," ")
 SET app_group_code_value = 0.0
 SET app_cnt = size(requestin->list_0,5)
 SET sequence = 0
 FOR (x = 1 TO app_cnt)
   IF (last_app_group_category != cnvtupper(requestin->list_0[x].application_group_category))
    SET sequence = 0
    SELECT INTO "NL:"
     FROM br_app_category bac
     WHERE bac.active_ind=1
      AND cnvtupper(bac.description)=cnvtupper(requestin->list_0[x].application_group_category)
     DETAIL
      last_app_group_category_id = bac.category_id, last_app_group_category = cnvtupper(bac
       .description)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET error_flag = "T"
     SET appl_grp_cnt = (appl_grp_cnt+ 1)
    ENDIF
   ENDIF
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
     FROM br_app_cat_comp bacc
     WHERE bacc.application_group_cd=app_group_code_value
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET sequence = (sequence+ 1)
     INSERT  FROM br_app_cat_comp bacc
      SET bacc.category_id = last_app_group_category_id, bacc.application_group_cd =
       app_group_code_value, bacc.br_client_id = 1.0,
       bacc.start_version_nbr = 3, bacc.sequence = sequence, bacc.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       bacc.updt_id = reqinfo->updt_id, bacc.updt_task = reqinfo->updt_task, bacc.updt_applctx =
       reqinfo->updt_applctx,
       bacc.updt_cnt = 0
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
  SET error_msg = concat("Unable to insert: ",cnvtstring(insert_cnt)," No Application Group: ",
   cnvtstring(appl_grp_cnt))
  CALL echo(error_msg)
 ENDIF
 IF (((error_flag="N") OR (error_flag="T")) )
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: <br_app_group_rel_config.prg> script"
  COMMIT
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed: <br_app_group_rel_config.prg> script"
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

CREATE PROGRAM afc_rdm_upd_pricing_tool_tasks:dba
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
 SET readme_data->message = "Readme afc_rdm_upd_pricing_tool_tasks failed."
 DECLARE errmsg = vc WITH protect, noconstant("")
 CALL echo("calling update_tasks")
 CALL update_tasks(1)
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme updated Pricing Tool tasks"
 GO TO exit_script
 SUBROUTINE update_tasks(dummyvar)
   DECLARE cnt = i2 WITH noconstant(0)
   DECLARE task_num = i4 WITH noconstant(0)
   SET exist_flag = 0
   FREE RECORD app_groups
   RECORD app_groups(
     1 qual[*]
       2 app_group_cd = f8
   )
   SELECT INTO "nl:"
    t.app_group_cd
    FROM task_access t
    WHERE t.task_number=951007
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(app_groups->qual,cnt), app_groups->qual[cnt].app_group_cd = t
     .app_group_cd
    WITH nocounter
   ;end select
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = build(errmsg,"Failed to get existing row for app_group.")
    GO TO exit_script
   ENDIF
   FOR (cnt = 1 TO value(size(app_groups->qual,5)))
    SET task_num = 951109
    WHILE (task_num <= 951113)
      SET exist_flag = 0
      SELECT INTO "nl:"
       FROM task_access t
       WHERE t.task_number=task_num
        AND (t.app_group_cd=app_groups->qual[cnt].app_group_cd)
       DETAIL
        exist_flag = 1
       WITH nocounter
      ;end select
      IF (error(errmsg,0) != 0)
       SET readme_data->status = "F"
       SET readme_data->message = build(errmsg,"Failed to get existing row for app_group.")
       GO TO exit_script
      ENDIF
      IF (exist_flag=0)
       INSERT  FROM task_access t
        SET t.task_number = task_num, t.app_group_cd = app_groups->qual[cnt].app_group_cd, t
         .updt_dt_tm = cnvtdatetime(curdate,curtime3),
         t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->
         updt_applctx,
         t.updt_cnt = 0
        WITH nocounter
       ;end insert
      ENDIF
      IF (error(errmsg,0) != 0)
       SET readme_data->status = "F"
       SET readme_data->message = build(errmsg,"Failed to insert a row into task_access.")
       GO TO exit_script
      ELSE
       COMMIT
      ENDIF
      SET task_num = (task_num+ 1)
    ENDWHILE
   ENDFOR
 END ;Subroutine
#exit_script
 EXECUTE dm_readme_status
 FREE RECORD app_groups
 CALL echorecord(readme_data)
END GO

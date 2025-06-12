CREATE PROGRAM appbar_task_access:dba
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
 SET readme_data->message = "Readme Failed: Starting script APPBAR_TASK_ACCESS"
 SET errmsg = fillstring(132," ")
 SET errcode = 1
 INSERT  FROM task_access ta
  (ta.app_group_cd, ta.task_number, ta.updt_dt_tm,
  ta.updt_id, ta.updt_task, ta.updt_cnt,
  ta.updt_applctx)(SELECT DISTINCT
   aa.app_group_cd, 21051, cnvtdatetime(curdate,curtime),
   0, reqinfo->updt_task, 0,
   0
   FROM application_access aa
   WHERE aa.active_ind=1
    AND aa.application_number=9000
    AND  NOT (aa.app_group_cd IN (
   (SELECT
    ta2.app_group_cd
    FROM task_access ta2
    WHERE ta2.app_group_cd=aa.app_group_cd
     AND ta2.task_number=21051))))
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode=0)
  COMMIT
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: task_access table updated"
 ELSE
  ROLLBACK
  CALL echo(build("*** ERROR: ",errmsg," ***"))
  SET readme_data->status = "F"
  SET readme_data->message = build("Readme Failed: ",errmsg)
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

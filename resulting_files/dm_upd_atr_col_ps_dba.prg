CREATE PROGRAM dm_upd_atr_col_ps:dba
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
 SELECT INTO "nl:"
  a.task_number
  FROM application_task a
  WHERE a.task_number=380030
 ;end select
 IF (curqual)
  EXECUTE dm_ocd_upd_atr_col "TASK", 380030, "active_ind",
  "0"
  EXECUTE dm_ocd_upd_atr_col "TASK", 380030, "inactive_dt_tm",
  value(cnvtdatetime(curdate,curtime3))
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "The task number does not exist on the application_task table-Success."
 ENDIF
 EXECUTE dm_readme_status
 SELECT INTO "nl:"
  r.request_number, r.requestclass
  FROM request r
  WHERE r.request_number=380101
 ;end select
 IF (curqual)
  EXECUTE dm_ocd_upd_atr_col "REQ", 380101, "active_ind",
  "0"
  EXECUTE dm_ocd_upd_atr_col "REQ", 380101, "inactive_dt_tm",
  value(cnvtdatetime(curdate,curtime3))
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "The request number does not exist on the request table-Success."
 ENDIF
 EXECUTE dm_readme_status
#exit_program
END GO

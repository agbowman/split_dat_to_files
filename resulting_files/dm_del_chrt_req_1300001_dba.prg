CREATE PROGRAM dm_del_chrt_req_1300001:dba
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
 DELETE  FROM request r
  WHERE r.request_number=1300001
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM task_request_r t
  WHERE t.request_number=1300001
  WITH nocounter
 ;end delete
 COMMIT
 SELECT INTO "NL:"
  r.request_number
  FROM request r,
   task_request_r t
  WHERE r.request_number=1300001
   AND t.request_number=r.request_number
  WITH nocounter
 ;end select
 IF (curqual != 0)
  CALL echo("Error in altering a table")
  SET readme_data->message = "Error deleting request 1300001"
  SET readme_data->status = "F"
  GO TO exit_script
 ELSE
  CALL echo("Request 1300001 has been deleted")
  SET readme_data->status = "S"
 ENDIF
 DELETE  FROM application a
  WHERE a.application_number IN (1350001, 1350022)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM application_task_r atr
  WHERE atr.application_number IN (1350001, 1350022)
  WITH nocounter
 ;end delete
 COMMIT
 SELECT INTO "NL:"
  a.application_number
  FROM application a,
   application_task_r atr
  WHERE a.application_number IN (1350001, 1350022)
   AND atr.application_number=a.application_number
  WITH nocounter
 ;end select
 IF (curqual != 0)
  CALL echo("Error in altering a table")
  SET readme_data->message = "Error deleting applications 1350001 and 1350022"
  SET readme_data->status = "F"
  GO TO exit_script
 ELSE
  CALL echo("Applications 1350001 and 1350022 have been deleted")
  SET readme_data->status = "S"
 ENDIF
#exit_script
 IF ((readme_data->status="S"))
  SET readme_data->message = "Erroneous ATR has been deleted successfully"
 ENDIF
 EXECUTE dm_readme_status
END GO

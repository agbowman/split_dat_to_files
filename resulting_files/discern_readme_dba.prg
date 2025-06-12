CREATE PROGRAM discern_readme:dba
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
 SET readme_data->message = "Starting to add Discern Physician order entry detail"
 CALL echo(readme_data->message)
 EXECUTE dm_readme_status
 EXECUTE eks_ocd_1172_oefields
 SET readme_data->message = "Done adding Discern Physician order entry detail"
 CALL echo(readme_data->message)
 EXECUTE dm_readme_status
 SET readme_data->message = "Starting to import Discern Template changes"
 CALL echo(readme_data->message)
 EXECUTE dm_readme_status
 SET input = "EKSREV"
 EXECUTE eks_import
 SET readme_data->message = "Done importing Discern Template changes"
 CALL echo(readme_data->message)
 EXECUTE dm_readme_status
 SET readme_data->message =
 "Starting to drop all modules in the dictionary but not on the EKS tables"
 CALL echo(readme_data->message)
 EXECUTE dm_readme_status
 EXECUTE eks_drop 0, 0
 SET readme_data->message = "Done dropping modules in the dictionary but not on the EKS tables"
 CALL echo(readme_data->message)
 EXECUTE dm_readme_status
 SET readme_data->message = "Starting to update table entries for Discern Dialogue"
 CALL echo(readme_data->message)
 EXECUTE dm_readme_status
 EXECUTE eks_upd_dialogue
 SET readme_data->message = "Done updating entries for Discern Dialogue"
 CALL echo(readme_data->message)
 EXECUTE dm_readme_status
 SET readme_data->message = "Starting to fix Expert Notification Task Security"
 CALL echo(readme_data->message)
 EXECUTE dm_readme_status
 EXECUTE eks_upd_notify_sec
 SET readme_data->message = "Done fixing Expert Notification Task Security"
 CALL echo(readme_data->message)
 EXECUTE dm_readme_status
 SET readme_data->message = "Starting to resave all active modules"
 CALL echo(readme_data->message)
 EXECUTE dm_readme_status
 EXECUTE eks_util_gen_ekm
 SET readme_data->message = "Done resaving active modules"
 CALL echo(readme_data->message)
 EXECUTE dm_readme_status
 SET readme_data->message = "Starting to purge EKS_MODULE_AUDIT tables"
 CALL echo(readme_data->message)
 EXECUTE dm_readme_status
 EXECUTE eks_monitor_cleanup 30
 SET readme_data->message = "Discern ReadMe has completed"
 SET readme_data->status = "S"
 CALL echo(readme_data->message)
 EXECUTE dm_readme_status
END GO

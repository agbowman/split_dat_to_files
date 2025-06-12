CREATE PROGRAM bbt_rdm_del_inv_search_prefs:dba
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
 SET readme_data->message = "Readme failed: starting script bbt_rdm_del_inv_search_prefs..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DELETE  FROM application_ini a
  WHERE a.application_number=225024
   AND a.section IN ("Default Days To Expire", "Default Historical", "Default Sort 1",
  "Default Sort 2", "Default Sort 3",
  "Default Order 1", "Default Order 2", "Default Order 3")
  WITH nocounter
 ;end delete
 IF (error(errmsg,0) > 0)
  SET readme_data->message = build("Failed to delete from APPLICATION_INI: ",errmsg)
  SET readme_data->status = "F"
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->message = "Readme successful."
 SET readme_data->status = "S"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

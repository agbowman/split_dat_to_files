CREATE PROGRAM dm_upd_combine_atrs:dba
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
 SET readme_data->message = "Executing dm_ocd_upd_atr - REQUEST - 126023"
 EXECUTE dm_readme_status
 EXECUTE dm_ocd_upd_atr "REQUEST", 126023
 SET readme_data->message = "Executing dm_ocd_upd_atr - REQUEST - 100102"
 EXECUTE dm_readme_status
 EXECUTE dm_ocd_upd_atr "REQUEST", 100102
 SET readme_data->message = "Executing dm_ocd_upd_atr - REQUEST - 100103"
 EXECUTE dm_readme_status
 EXECUTE dm_ocd_upd_atr "REQUEST", 100103
 SELECT INTO "nl:"
  FROM request
  WHERE request_number IN (126023, 100102, 100103)
  WITH nocounter
 ;end select
 IF (curqual=3)
  SET readme_data->message = "Combine atrs successfully updated."
  SET readme_data->status = "S"
 ELSE
  SET readme_data->message = "Combine atrs were NOT successfully updated."
  SET readme_data->status = "F"
 ENDIF
#exit_script
 EXECUTE dm_readme_status
END GO

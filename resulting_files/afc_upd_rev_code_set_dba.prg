CREATE PROGRAM afc_upd_rev_code_set:dba
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
 SET readme_data->message = "Executing afc_upd_rev_code_set."
 SET readme_data->message = "Updating code set 20769."
 UPDATE  FROM code_value c
  SET c.display = c.cdf_meaning
  WHERE c.code_set=20769
 ;end update
 COMMIT
 UPDATE  FROM code_value c
  SET c.display_key = c.display
  WHERE c.code_set=20769
 ;end update
 COMMIT
 IF (curqual > 0)
  SET readme_data->status = "S"
  SET readme_data->message = "Updated code set 20769."
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Code set 20769 not updated."
 ENDIF
 EXECUTE dm_readme_status
END GO

CREATE PROGRAM ct_chk_cvg_import:dba
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
 SELECT INTO "NL:"
  c.parent_code_value
  FROM code_value_group c
  WHERE c.code_set=17441
  WITH nocounter
 ;end select
 IF (curqual >= 1)
  SET readme_data->status = "S"
  SET readme_data->message = "Code_value_group succesfully imported."
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Code_value_group failed to import."
 ENDIF
 EXECUTE dm_readme_status
END GO

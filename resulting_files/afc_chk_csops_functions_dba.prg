CREATE PROGRAM afc_chk_csops_functions:dba
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
 SET readme_data->message = "Executing afc_chk_csops_functions."
 SELECT INTO "nl:"
  FROM omf_function o
  WHERE o.function_name IN ("afc_get_research_acct", "afc_get_interface_file")
  WITH nocounter
 ;end select
 IF (curqual=2)
  SET readme_data->status = "S"
  SET readme_data->message = "Found csops functions."
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Could not find csops functions."
 ENDIF
 EXECUTE dm_readme_status
END GO

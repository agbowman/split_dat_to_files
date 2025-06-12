CREATE PROGRAM aps_chk_date_format_import:dba
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
 DECLARE d_error_values = c132
 SELECT INTO "nl:"
  FROM code_value cv1,
   code_value_group cvg
  PLAN (cvg
   WHERE cvg.code_set=22669.00)
   JOIN (cv1
   WHERE cv1.code_value=cvg.parent_code_value
    AND cv1.cdf_meaning="AP*")
  DETAIL
   d_error_values = concat(trim(cnvtstring(cv1.code_value,32,2),3),",",d_error_values)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Date format import failed on code_values: ",d_error_values)
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Date format import successful"
 ENDIF
 EXECUTE dm_readme_status
END GO

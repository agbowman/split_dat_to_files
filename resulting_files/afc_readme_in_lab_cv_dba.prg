CREATE PROGRAM afc_readme_in_lab_cv:dba
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
 UPDATE  FROM code_value cv
  SET cv.active_ind = 1
  WHERE cv.code_set=13029
   AND cv.cdf_meaning="IN LAB"
  WITH nocounter
 ;end update
 SET readme_data->message = "Done activating code value"
 SET code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=13029
   AND cv.cdf_meaning="IN LAB"
  DETAIL
   code_value = cv.code_value
  WITH nocounter
 ;end select
 SET readme_data->message = "Got code value for 'IN LAB' from 13029"
 UPDATE  FROM code_value_extension cve
  SET field_value = "1"
  WHERE cve.code_value=code_value
   AND cve.field_name="CHARGE"
  WITH nocounter
 ;end update
 SET readme_data->message = "Done setting code_value_extension to '1'"
 SET readme_data->status = "S"
 EXECUTE dm_readme_status
 COMMIT
END GO

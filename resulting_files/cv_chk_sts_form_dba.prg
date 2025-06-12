CREATE PROGRAM cv_chk_sts_form:dba
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
    1 message = vc
    1 options = vc
  )
 ENDIF
 SET actual_cnt = 0
 SET expect_cnt = 1
 SET readme_type = "STS_FORM:"
 SELECT INTO "nl:"
  table_count = count(*)
  FROM dcp_forms_ref
  WHERE cnvtupper(trim(description))="CARDIOVASCULAR DATA STS"
   AND dcp_forms_ref_id=51834
  DETAIL
   actual_cnt = table_count
  WITH nocounter
 ;end select
 IF (actual_cnt < expected_cnt)
  SET readme_data->message = concat(readme_type," Expected ",trim(cnvtstring(expected_cnt),3),
   " rows but found ",trim(cnvtstring(actual_cnt),3),
   " rows.")
  SET readme_data->status = "F"
 ELSE
  SET readme_data->message = concat(readme_type," Readme Successful. ",trim(cnvtstring(actual_cnt),3),
   " rows fixed.")
  SET readme_data->status = "S"
 ENDIF
 EXECUTE dm_readme_status
 COMMIT
END GO

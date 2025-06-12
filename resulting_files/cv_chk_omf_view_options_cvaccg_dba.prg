CREATE PROGRAM cv_chk_omf_view_options_cvaccg:dba
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
 SET actual_cnt = 0
 SET expected_cnt = 403
 SET readme_type = "CVNET_OMF_VIEW_OPTIONS_CVCASE2"
 SELECT INTO "nl:"
  table_count = count(*)
  FROM omf_vo_type ovt,
   omf_vo_type_display ovd,
   code_value cv
  PLAN (cv
   WHERE cv.code_set=24549
    AND cv.display_key="CVACCG*")
   JOIN (ovt
   WHERE ovt.vo_type_cd != 0
    AND ovt.vo_indicator_cd=cv.code_value)
   JOIN (ovd
   WHERE ovd.vo_type_cd=ovt.vo_type_cd)
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

CREATE PROGRAM cv_chk_sts_validation:dba
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
 SET expected_cnt = 2125
 SET readme_type = "STS_VALIDATION:"
 SELECT INTO "nl:"
  table_count = count(*)
  FROM cv_dataset cd,
   cv_xref cx,
   cv_response cr,
   cv_xref_validation cxv
  PLAN (cd
   WHERE cnvtupper(trim(cd.dataset_internal_name))="STS")
   JOIN (cx
   WHERE cd.dataset_id=cx.dataset_id)
   JOIN (cr
   WHERE cx.xref_id=cr.xref_id)
   JOIN (cxv
   WHERE cr.response_id=cxv.response_id)
  DETAIL
   actual_cnt = table_count
  WITH nocounter
 ;end select
 IF (actual_cnt=0)
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

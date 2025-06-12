CREATE PROGRAM afc_chk_wkld_indicator_name:dba
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
 SET readme_data->message = "Executing afc_chk_wkld_indicator_name."
 SELECT INTO "nl:"
  FROM code_value cv,
   omf_indicator o
  PLAN (cv
   WHERE cv.code_set=26793
    AND cv.active_ind=1
    AND cv.cdf_meaning="INDICATOR"
    AND cv.display="CSW*")
   JOIN (o
   WHERE o.indicator_cd=cv.code_value)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET readme_data->status = "S"
  SET readme_data->message = "Found workload indicators."
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Could not find workload indicators."
 ENDIF
 EXECUTE dm_readme_status
END GO

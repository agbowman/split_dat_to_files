CREATE PROGRAM cv_omf_sts_indicator_wrapper:dba
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
 EXECUTE dm_dbimport "cer_install:cv_omf_sts_indicator.csv", "cv_ins_updt_cv_omf_filter", 1000
 EXECUTE cv_chk_omf_sts_indicator
 EXECUTE dm_readme_status
END GO

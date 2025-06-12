CREATE PROGRAM dm_run_parallel_cc_script:dba
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
 DECLARE drpcs_errmsg = vc WITH protect, noconstant("")
 DECLARE drpcs_parserstmt = vc WITH protect, noconstant("")
 IF ((validate(mn_child_failed,- (1))=- (1)))
  DECLARE mn_child_failed = i2 WITH protect, noconstant(0)
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script dm_run_parallel_cc_script.prg..."
 SET drpcs_parserstmt = concat("execute ",ms_cc_script," value(",ms_cur_min_id,"), value(",
  ms_cur_max_id,") go")
 CALL parser(drpcs_parserstmt)
 IF (error(drpcs_errmsg,0) > 0
  AND mn_child_failed=0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("_cc wrapper script caught error: ",errmsg)
  SET mn_child_failed = 1
 ENDIF
END GO

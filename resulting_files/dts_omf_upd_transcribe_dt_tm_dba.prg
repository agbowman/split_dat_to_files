CREATE PROGRAM dts_omf_upd_transcribe_dt_tm:dba
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
 SET readme_data->message = concat("Readme failure.  Starting dts_omf_upd_transcribe_dt_tm script.")
 DECLARE n_start_dt_tm = f8 WITH public, noconstant(0.0)
 DECLARE o_start_dt_tm = f8 WITH public, noconstant(0.0)
 DECLARE n_end_dt_tm = f8 WITH public, noconstant(0.0)
 DECLARE o_end_dt_tm = f8 WITH public, noconstant(0.0)
 DECLARE sstatus = c1 WITH public, noconstant("F")
 DECLARE g_err_cd = i4
 DECLARE g_err_msg = vc
 SET g_err_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=26513
   AND cv.cdf_meaning="INDICATOR"
   AND cv.cki="CKI.CODEVALUE!2704262"
  DETAIL
   o_start_dt_tm = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=26513
   AND cv.cdf_meaning="INDICATOR"
   AND cv.cki="CKI.CODEVALUE!3670407"
  DETAIL
   n_start_dt_tm = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=26513
   AND cv.cdf_meaning="INDICATOR"
   AND cv.cki="CKI.CODEVALUE!2704263"
  DETAIL
   o_end_dt_tm = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=26513
   AND cv.cdf_meaning="INDICATOR"
   AND cv.cki="CKI.CODEVALUE!3670408"
  DETAIL
   n_end_dt_tm = cv.code_value
  WITH nocounter
 ;end select
 IF (((o_start_dt_tm=0.0) OR (((n_start_dt_tm=0.0) OR (((o_end_dt_tm=0.0) OR (n_end_dt_tm=0.0)) ))
 )) )
  SET sstatus = "V"
  SET readme_data->message = "Code Value Lookup(s) failed."
  GO TO end_program
 ENDIF
 UPDATE  FROM omf_pvi_filter opf
  SET opf.indicator_cd = n_start_dt_tm
  WHERE opf.indicator_cd=o_start_dt_tm
  WITH nocounter
 ;end update
 SET g_err_cd = error(g_err_msg,1)
 IF (g_err_cd > 0)
  ROLLBACK
  SET sstatus = "V"
  SET readme_data->message =
  "FAILED: Failed while trying to update omf_pvi_filter for Start Transcribe Date/Time."
  GO TO end_program
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM omf_pvi_filter opf
  SET opf.indicator_cd = n_end_dt_tm
  WHERE opf.indicator_cd=o_end_dt_tm
  WITH nocounter
 ;end update
 SET g_err_cd = error(g_err_msg,1)
 IF (g_err_cd > 0)
  ROLLBACK
  SET sstatus = "V"
  SET readme_data->message =
  "FAILED: Failed while trying to update omf_pvi_filter for End Transcribe Date/Time."
  GO TO end_program
 ELSE
  COMMIT
 ENDIF
#end_program
 IF (sstatus="V")
  SET readme_data->status = "F"
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "All tables successfully updated."
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

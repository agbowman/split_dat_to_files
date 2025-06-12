CREATE PROGRAM dac_220831_testnlslang
 IF (validate(dac_test_reply->status,"Z")="Z")
  RECORD dac_test_reply(
    1 status = c1
    1 message = vc
  )
 ENDIF
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
 DECLARE dt_errmsg = vc WITH protect, noconstant("")
 SET dac_test_reply->status = "F"
 SET dac_test_reply->message = "Test failed: starting test dac_220831_testNlsLang..."
 CALL parser("rdb ALTER SESSION SET NLS_LANGUAGE= 'AMERICAN' go")
 IF (error(dt_errmsg,0) != 0)
  SET dac_test_reply->status = "F"
  SET dac_test_reply->message = concat("Failed to set a_nls language for session: ",dt_errmsg)
  GO TO exit_test
 ENDIF
 EXECUTE dac_create_read_synonym
 IF ((readme_data->message="Auto-success: This environment does not use _A_NLS functionality."))
  SET dac_test_reply->status = "S"
  SET dac_test_reply->message = "Test completed successfully"
 ELSE
  SET dac_test_reply->status = "F"
  SET dac_test_reply->message = concat("Failure to auto success:",readme_data->message)
 ENDIF
#exit_test
 CALL echorecord(dac_test_reply)
END GO

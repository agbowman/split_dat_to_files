CREATE PROGRAM dac_220831_testnopatmatch
 IF (validate(dac_test_reply->status,"Z")="Z")
  RECORD dac_test_reply(
    1 status = c1
    1 message = vc
  )
 ENDIF
 FREE RECORD dm_sql_reply
 RECORD dm_sql_reply(
   1 status = c1
   1 msg = vc
 )
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
 SET dac_test_reply->status = "F"
 SET dac_test_reply->message = "Test failed: starting test dac_220831_testNoPatmatch..."
 DECLARE dt_errmsg = vc WITH protect, noconstant("")
 DECLARE dt_funccheck = i2 WITH protect, noconstant(0)
 CALL parser("rdb ALTER SESSION SET NLS_LANGUAGE= 'FRENCH' go")
 IF (error(dt_errmsg,0) != 0)
  SET dac_test_reply->status = "F"
  SET dac_test_reply->message = concat("Failed to set a_nls language for session: ",dt_errmsg)
  GO TO exit_test
 ENDIF
 SELECT INTO "nl:"
  FROM user_objects uo
  WHERE uo.object_name="CERN_NLS_SORT_PATMATCH"
   AND uo.object_type="FUNCTION"
  WITH nocounter
 ;end select
 IF (error(dt_errmsg,0) != 0)
  SET dac_test_reply->status = "F"
  SET dac_test_reply->message = concat("Failed to look up CERN_NLS_SORT_PATMATCH: ",dt_errmsg)
  GO TO exit_test
 ELSEIF (curqual != 0)
  SET dt_funccheck = 1
  CALL parser(concat("rdb asis(^ drop function CERN_NLS_SORT_PATMATCH ^)go"))
  IF (error(dt_errmsg,0) != 0)
   SET dac_test_reply->status = "F"
   SET dac_test_reply->message = concat("Failed to drop CERN_NLS_SORT_PATMATCH function: ",dt_errmsg)
   GO TO exit_test
  ENDIF
 ENDIF
 EXECUTE dac_create_read_synonym
 IF ((readme_data->status="F"))
  SET dac_test_reply->status = "S"
  SET dac_test_reply->message = "Test completed all steps"
 ELSE
  SET dac_test_reply->status = "F"
  SET dac_test_reply->message = concat("Failure to report failure: ",readme_data->message)
 ENDIF
#exit_test
 IF (dt_funccheck=1)
  EXECUTE dm_readme_include_sql "cer_install:dac_a_nls_functions.sql"
  IF ((dm_sql_reply->status="F"))
   SET dac_test_reply->status = "F"
   SET dac_test_reply->message = dm_sql_reply->msg
   GO TO exit_test
  ENDIF
  EXECUTE dm_readme_include_sql_chk "CERN_NLS_SORT_PATMATCH", "FUNCTION"
  IF ((dm_sql_reply->status="F"))
   SET dac_test_reply->status = "F"
   SET dac_test_reply->message = dm_sql_reply->msg
   GO TO exit_test
  ENDIF
 ENDIF
 CALL echorecord(dac_test_reply)
END GO

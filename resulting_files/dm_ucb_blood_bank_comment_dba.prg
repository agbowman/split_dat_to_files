CREATE PROGRAM dm_ucb_blood_bank_comment:dba
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
 SET readme_data->message = "ERROR: dm_cmb_exception import failed."
 EXECUTE dm_dbimport "cer_install:dm_ucb_blood_bank_comment.csv", "dm_dm_cmb_exception_import", 10
 IF ((readme_data->status="F"))
  SET readme_data->message = "cer_install:dm_cmb_elh_prsnl.csv was not found"
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_cmb_exception dce
  WHERE dce.operation_type="UNCOMBINE"
   AND dce.parent_entity="PERSON"
   AND dce.child_entity="BLOOD_BANK_COMMENT"
 ;end select
 IF (curqual != 1)
  ROLLBACK
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "SUCCESS: all rows imported into dm_cmb_exception"
  COMMIT
 ENDIF
#end_program
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

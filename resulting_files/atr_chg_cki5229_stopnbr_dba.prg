CREATE PROGRAM atr_chg_cki5229_stopnbr:dba
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
 CALL echo("Retrieving code_value for CKI.CODEVALUE!5229...")
 SET code_val = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cki="CKI.CODEVALUE!5229"
  DETAIL
   code_val = cv.code_value
  WITH nocounter
 ;end select
 IF (code_val=0.0)
  CALL echo("FAILED to locate CODE_VALUE for cki = CKI.CODEVALUE!5229")
  SET readme_data->status = "F"
  SET readme_data->message = "FAILED to locate CODE_VALUE for cki = CKI.CODEVALUE!5229"
 ELSE
  CALL echo(build("Updating code_value_extension for (",code_val,")..."))
  UPDATE  FROM code_value_extension cve
   SET cve.field_value = "1399999", cve.updt_dt_tm = cnvtdatetime(sysdate)
   WHERE cve.code_value=code_val
    AND cve.field_name="Stop_Number"
   WITH nocounter
  ;end update
  CALL echo("Finished updating code_value_extensions...")
  SET readme_data->status = "S"
  SET readme_data->message = "Successfully updated code_value_extensions."
  CALL echo("Committing data")
  COMMIT
 ENDIF
 EXECUTE dm_readme_status
 CALL echo("*****  F I N I S H E D  *****")
 CALL echo("       ---------------")
END GO

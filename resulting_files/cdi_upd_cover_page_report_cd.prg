CREATE PROGRAM cdi_upd_cover_page_report_cd
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
 DECLARE fail_ind = i2 WITH public, noconstant(0)
 DECLARE fail_msg = vc WITH public, noconstant("Readme failed.")
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="PCREPORT"
   AND cv.cki="CKI.CODEVALUE!3379185"
   AND cv.code_set=16529
  WITH nocounter, forupdate(cv)
 ;end select
 IF (curqual=0)
  SET fail_msg = "Readme failed.  Update row could not be locked."
  GO TO set_readme_status
 ENDIF
 UPDATE  FROM code_value cv
  SET cv.active_ind = 1, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,
    curtime3)
  WHERE cv.cdf_meaning="PCREPORT"
   AND cv.cki="CKI.CODEVALUE!3379185"
   AND cv.code_set=16529
 ;end update
#set_readme_status
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="PCREPORT"
   AND cv.cki="CKI.CODEVALUE!3379185"
   AND cv.code_set=16529
  DETAIL
   IF (cv.active_ind != 1)
    fail_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET fail_ind = 1
  SET fail_msg = "Readme failed.  Update row could not be found."
 ENDIF
 IF (fail_ind=1)
  ROLLBACK
  SET readme_data->message = fail_msg
  CALL echo(build(fail_msg))
  SET readme_data->status = "F"
 ELSE
  COMMIT
  CALL echo("Readme successful.")
  SET readme_data->message = "Readme successful."
  SET readme_data->status = "S"
 ENDIF
 EXECUTE dm_readme_status
END GO

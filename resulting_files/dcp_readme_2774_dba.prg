CREATE PROGRAM dcp_readme_2774:dba
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
 DECLARE rdm_errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE rdm_errcode = i4 WITH noconstant(error(rdm_errmsg,1))
 DECLARE readme_status = c1 WITH noconstant("S")
 DECLARE maxrecs = i4 WITH constant(100)
 CALL echo("Starting dcp_readme_2774")
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6042
   AND cv.cdf_meaning="4320000"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET rdm_errmsg = "Row does not exist to be updated."
  SET readme_status = "S"
  GO TO exit_readme
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6042
   AND cv.cdf_meaning="4320000"
  WITH nocounter, forupdate(cv)
 ;end select
 IF (curqual=0)
  SET rdm_errmsg = "unable to lock code_value row for update"
  SET readme_status = "F"
  GO TO exit_readme
 ENDIF
 UPDATE  FROM code_value cv
  SET cv.cdf_meaning = "432000"
  WHERE cv.code_set=6042
   AND cv.cdf_meaning="4320000"
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET readme_status = "F"
  SET rdm_errmsg = "code_value table could not be updated"
  GO TO exit_readme
 ELSE
  CALL echo("Updated new fields on code_value table")
 ENDIF
#exit_readme
 CALL echo("Updating readme status.......")
 IF (readme_status="F")
  SET readme_data->status = "F"
  SET readme_data->message = rdm_errmsg
  ROLLBACK
 ELSEIF (readme_status="S")
  SET readme_data->status = "S"
  SET readme_data->message = "Successfully updated cdf_meaning for codeset 6042, frequency Q120 hr"
  COMMIT
 ENDIF
 CALL echo(build(readme_data->status,":",readme_data->message))
 EXECUTE dm_readme_status
END GO

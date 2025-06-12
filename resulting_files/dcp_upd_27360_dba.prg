CREATE PROGRAM dcp_upd_27360:dba
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
 SELECT INTO "nl:"
  FROM code_value
  WHERE code_set=27360
   AND cdf_meaning="ASSIGNMENT"
  WITH nocounter, forupdate(cv)
 ;end select
 IF (curqual=0)
  CALL echo("Lock row for update failed since curqual = 0")
 ENDIF
 UPDATE  FROM code_value
  SET display = "Assignment", display_key = "ASSIGNMENT"
  WHERE code_set=27360
   AND cdf_meaning="ASSIGNMENT"
  WITH nocounter
 ;end update
 SET readme_data->status = "S"
 EXECUTE dm_readme_status
 COMMIT
END GO

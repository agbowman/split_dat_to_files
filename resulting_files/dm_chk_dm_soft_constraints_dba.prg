CREATE PROGRAM dm_chk_dm_soft_constraints:dba
 SET c_mod = "DM_CHK_DM_SOFT_CONSTRAINTS 000"
 SET table_name_str = "DM_SOFT_CONSTRAINTS"
 DECLARE readme_id = f8
 SET readme_id = 2178
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
 IF (validate(readme_data->readme_id,0)=0
  AND validate(readme_data->readme_id,1)=1)
  SET readme_data->readme_id = readme_id
 ENDIF
 DECLARE expected_int = i2
 DECLARE cnt = i2
 DECLARE temp_msg = vc
 IF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET temp_msg = "Auto Success on DB2"
  CALL echo(temp_msg)
  GO TO end_program
 ENDIF
 SET readme_data->status = "F"
 SELECT INTO "nl:"
  d.parent_table
  FROM dm_soft_constraints d
  WHERE d.parent_table != ""
  HEAD REPORT
   readme_data->status = "S", temp_msg = concat("README SUCESS.  Found rows on the table ",
    table_name_str)
  DETAIL
   stat = 1
  WITH maxqual(d,10), nocounter
 ;end select
 IF ((readme_data->status="F"))
  SET temp_msg = concat("README FAILED.  No rows found on the table ",table_name_str)
 ENDIF
#end_program
 SET readme_data->message = temp_msg
 EXECUTE dm_readme_status
 COMMIT
END GO

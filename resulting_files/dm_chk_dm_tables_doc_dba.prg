CREATE PROGRAM dm_chk_dm_tables_doc:dba
 SET c_mod = "DM_CHK_DM_TABLES_DOC 000"
 SET table_name_str = "DM_TABLES_DOC"
 DECLARE readme_id = f8
 DECLARE expected_int = i4
 SET expected_int = 1622
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
 SET expected_int = (expected_int - 1)
 DECLARE cnt = i4
 DECLARE temp_msg = c255
 SET temp_msg = fillstring(255," ")
 SET readme_data->status = "F"
 SELECT INTO "nl:"
  t_count = count(d.table_name)
  FROM dm_tables_doc d
  WHERE d.reference_ind=1
  HEAD REPORT
   cnt = t_count
  WITH nocounter
 ;end select
 IF (cnt >= expected_int)
  SET readme_data->status = "S"
  SET temp_msg = concat("Readme successful.  Found at least ",build(expected_int)," rows on the ",
   table_name_str," table.")
 ELSE
  SET readme_data->status = "F"
  SET temp_msg = concat("Readme failed.  Found ",build(cnt)," rows and expected at least ",build(
    expected_int)," rows on the ",
   table_name_str," table.")
 ENDIF
 SET readme_data->message = temp_msg
 EXECUTE dm_readme_status
 COMMIT
END GO

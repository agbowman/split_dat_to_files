CREATE PROGRAM dts_chk_filter_meaning:dba
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
    1 message = vc
    1 options = vc
  )
 ENDIF
 SET v_count1 = 0
 SET v_expected_count = 6
 SELECT INTO "nl:"
  table_count = count(*)
  FROM omf_filter_meaning
  WHERE filter_meaning IN ("DTS PHYSICIAN", "DTS APPMODE", "DTS TRANSACTIONTYPE", "DTS MRN",
  "DTS RESULTSTATUS",
  "DTS LOCATION")
  DETAIL
   v_count1 = table_count
  WITH nocounter
 ;end select
 IF (v_count1 < v_expected_count)
  SET readme_data->status = "F"
  SET readme_data->message = concat("OMF_FILTER_MEANING: Expected ",trim(cnvtstring(v_expected_count),
    3)," rows but found ",trim(cnvtstring(v_count1),3)," rows")
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "README SUCCESSFUL."
 ENDIF
 EXECUTE dm_readme_status
END GO

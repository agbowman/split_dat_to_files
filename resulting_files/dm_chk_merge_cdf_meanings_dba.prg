CREATE PROGRAM dm_chk_merge_cdf_meanings:dba
 SET c_mod = "DM_CHK_MERGE_CDF_MEANINGS 000"
 DECLARE readme_id = f8
 SET readme_id = 2186
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
 DECLARE temp_msg = vc
 DECLARE cnt = i4
 SET cnt = 0
 SELECT INTO "nl:"
  FROM common_data_foundation@loc_mrg_link cdf
  WHERE  NOT ( EXISTS (
  (SELECT
   "x"
   FROM common_data_foundation cdf1
   WHERE cdf1.code_set=cdf.code_set
    AND cdf1.cdf_meaning=cdf.cdf_meaning)))
  WITH nocounter
 ;end select
 IF (curqual)
  SET readme_data->status = "F"
  SET temp_msg = "README FAILED. Unmatching rows found between the common_data_foundation tables."
 ELSE
  SET readme_data->status = "S"
  SET temp_msg =
  "README SUCCESS. No unmatching rows found between the common_data_foundation tables."
 ENDIF
 SET readme_data->message = temp_msg
 EXECUTE dm_readme_status
 COMMIT
END GO

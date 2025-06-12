CREATE PROGRAM dm_chk_dm_ref_domain_val:dba
 SET c_mod = "DM_CHK_DM_REF_DOMAIN_VAL 000"
 SET table_name_str = "DM_REF_DOMAIN"
 DECLARE readme_id = f8
 SET readme_id = 2179
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
 SET readme_data->status = "F"
 SELECT INTO "nl:"
  d.ref_domain_name
  FROM dm_ref_domain d1,
   dm_ref_domain_r d2
  PLAN (d2
   WHERE d2.group_name="ALL")
   JOIN (d1
   WHERE d2.ref_domain_name=d1.ref_domain_name)
  HEAD REPORT
   readme_data->status = "S", temp_msg = concat("README SUCCESS.  Found rows on the table ",
    table_name_str)
  DETAIL
   stat = 1
  WITH maxqual(d2,10), nocounter
 ;end select
 IF ((readme_data->status="F"))
  SET temp_msg = concat("README FAILED.  No rows found on the table ",table_name_str)
 ENDIF
 SET readme_data->message = temp_msg
 EXECUTE dm_readme_status
 COMMIT
END GO

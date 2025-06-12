CREATE PROGRAM dac_alter_mpage_tablespace:dba
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
 SET readme_data->message = "Readme failed: starting script dac_alter_mpage_tablespace..."
 DECLARE dcvmu_errmsg = vc WITH protect, noconstant("")
 DECLARE dcvmu_parserstmt = vc WITH protect, noconstant("")
 DECLARE dcvmu_username = vc WITH protect, constant("V500_MPAGE")
 DECLARE dcvmu_default_ts = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM all_users au
  WHERE au.username=dcvmu_username
  WITH nocounter
 ;end select
 IF (error(dcvmu_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to check for user existence: ",dcvmu_errmsg)
  GO TO exit_script
 ELSEIF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message = concat("Success: User '",dcvmu_username,"' does not exist")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dba_users du
  WHERE du.username=dcvmu_username
  DETAIL
   dcvmu_default_ts = du.default_tablespace
  WITH nocounter
 ;end select
 IF (error(dcvmu_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to check for user existence: ",dcvmu_errmsg)
  GO TO exit_script
 ELSEIF (dcvmu_default_ts="MISC")
  SET readme_data->status = "S"
  SET readme_data->message = concat("Success: User '",dcvmu_username,"' does not need to be altered."
   )
  GO TO exit_script
 ENDIF
 SET dcvmu_parserstmt = concat("RDB ASIS(^ ALTER USER ",dcvmu_username,
  " DEFAULT TABLESPACE MISC ^) GO")
 CALL parser(dcvmu_parserstmt)
 IF (error(dcvmu_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to alter user '",dcvmu_username,"': ",dcvmu_errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = concat("Success: '",dcvmu_username,"' user has been altered")
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

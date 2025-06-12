CREATE PROGRAM dac_create_v500_mpage_user:dba
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
 SET readme_data->message = "Readme failed: starting script dac_create_v500_mpage_user..."
 DECLARE dcvmu_errmsg = vc WITH protect, noconstant("")
 DECLARE dcvmu_parserstmt = vc WITH protect, noconstant("")
 DECLARE dcvmu_tableexistsind = i2 WITH protect, noconstant(0)
 DECLARE dcvmu_temptablespace = vc WITH protect, noconstant("")
 DECLARE dcvmu_username = vc WITH protect, constant("V500_MPAGE")
 DECLARE dcvmu_profile = vc WITH protect, constant("MPAGES")
 SELECT INTO "nl:"
  FROM all_users au
  WHERE au.username=dcvmu_username
  WITH nocounter
 ;end select
 IF (error(dcvmu_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to check for user existence: ",dcvmu_errmsg)
  GO TO exit_script
 ELSEIF (curqual > 0)
  GO TO autosuccess
 ENDIF
 SELECT INTO "nl:"
  FROM dba_profiles dp
  WHERE dp.profile=dcvmu_profile
  WITH nocounter
 ;end select
 IF (error(dcvmu_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to check for profile existence: ",dcvmu_errmsg)
  GO TO exit_script
 ELSEIF (curqual=0)
  SET dcvmu_parserstmt = concat("RDB ASIS(^ CREATE PROFILE ",dcvmu_profile,
   " LIMIT LOGICAL_READS_PER_CALL 500000 ","CPU_PER_CALL 3000 ^) GO")
  CALL parser(dcvmu_parserstmt)
  IF (error(dcvmu_errmsg,0) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to create profile '",dcvmu_profile,"': ",dcvmu_errmsg)
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dba_users du
  WHERE du.username="V500"
  DETAIL
   dcvmu_temptablespace = du.temporary_tablespace
  WITH nocounter
 ;end select
 IF (error(dcvmu_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to check for temporary tablespace: ",dcvmu_errmsg)
  GO TO exit_script
 ELSEIF (curqual=0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to find a temporary tablespace for V500: ",dcvmu_errmsg)
  GO TO exit_script
 ENDIF
 SET dcvmu_parserstmt = concat("RDB ASIS(^ CREATE USER ",dcvmu_username," IDENTIFIED BY ",
  dcvmu_username," PROFILE ",
  dcvmu_profile," DEFAULT TABLESPACE MISC TEMPORARY TABLESPACE ",dcvmu_temptablespace," ^) GO")
 CALL parser(dcvmu_parserstmt)
 IF (error(dcvmu_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to create user '",dcvmu_username,"' with profile '",
   dcvmu_profile,"': ",
   dcvmu_errmsg)
  GO TO exit_script
 ENDIF
 SET dcvmu_parserstmt = concat("RDB ASIS(^ GRANT DBA TO ",dcvmu_username," ^) GO")
 CALL parser(dcvmu_parserstmt)
 IF (error(dcvmu_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to grant DBA privileges to '",dcvmu_username,"': ",
   dcvmu_errmsg)
  GO TO exit_script
 ENDIF
#autosuccess
 SELECT INTO "nl:"
  FROM dtableattr d
  WHERE d.table_name="SHARED_LIST_GTTD"
  DETAIL
   dcvmu_tableexistsind = 1
  WITH nocounter
 ;end select
 IF (error(dcvmu_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to look for SHARED_LIST_GTTD table: ",dcvmu_errmsg)
  GO TO exit_script
 ELSEIF (dcvmu_tableexistsind=1)
  CALL parser("RDB ASIS(^ GRANT INSERT, UPDATE, DELETE ON SHARED_LIST_GTTD TO PUBLIC ^) GO")
  IF (error(dcvmu_errmsg,0) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to grant privileges to SHARED_LIST_GTTD to PUBLIC: ",
    dvmu_errmsg)
   GO TO exit_script
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = concat("Success: '",dcvmu_username,"' user has been created with '",
  dcvmu_profile,"' profile")
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

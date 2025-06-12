CREATE PROGRAM dac_alt_mpage_tmptblespace:dba
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
 SET readme_data->message = "Readme failed: starting script dac_alt_mpage_tmptblespace..."
 DECLARE dmt_errmsg = vc WITH protect, noconstant("")
 DECLARE dmt_parserstmt = vc WITH protect, noconstant("")
 DECLARE dmt_username = vc WITH protect, constant("V500_MPAGE")
 DECLARE dmt_temptablespace = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM all_users au
  WHERE au.username=dmt_username
  WITH nocounter
 ;end select
 IF (error(dmt_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to check for user existence: ",dmt_errmsg)
  GO TO exit_script
 ELSEIF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message = concat("Auto-Success: User '",dmt_username,"' does not exist")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dba_users du
  WHERE du.username="V500"
  DETAIL
   dmt_temptablespace = du.temporary_tablespace
  WITH nocounter
 ;end select
 IF (error(dmt_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to check for temporary tablespace: ",dmt_errmsg)
  GO TO exit_script
 ELSEIF (curqual=0)
  SET readme_data->status = "F"
  SET readme_data->message = "Failed to find a temporary tablespace for V500"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dba_users du
  WHERE du.username=dmt_username
   AND du.temporary_tablespace=dmt_temptablespace
  WITH nocounter
 ;end select
 IF (error(dmt_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to check for correct temporary tablespace: ",dmt_errmsg)
  GO TO exit_script
 ELSEIF (curqual=1)
  SET readme_data->status = "S"
  SET readme_data->message = concat("Auto-Success: User '",dmt_username,
   "' already has the correct temporary tablespace")
  GO TO exit_script
 ENDIF
 SET dmt_parserstmt = concat("RDB ASIS(^ ALTER USER ",dmt_username," TEMPORARY TABLESPACE ",
  dmt_temptablespace," ^) GO")
 CALL parser(dmt_parserstmt)
 IF (error(dmt_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to alter user '",dmt_username,"': ",dmt_errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = concat("Success: '",dmt_username,"' user has been altered")
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

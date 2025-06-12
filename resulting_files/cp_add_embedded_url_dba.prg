CREATE PROGRAM cp_add_embedded_url:dba
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
 DECLARE info_name = vc WITH noconstant(""), protect
 DECLARE errmsg = vc WITH noconstant(""), protect
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failure: Starting Script cp_add_embedded_url."
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="ORION"
   AND d.info_name="EMBEDDED_BASE_URL"
  DETAIL
   info_name = d.info_char
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("An error occured searching for the embedded url from dm_info: ",
   errmsg)
  GO TO exit_script
 ELSE
  IF (curqual=1)
   SET readme_data->status = "S"
   SET readme_data->message = concat(
    "Success: Readme has already populated the dm_info table with embedded server url: ",info_name)
  ELSE
   INSERT  FROM dm_info d
    SET d.info_char = "https://embedded.cerner.com/embedded/content", d.info_domain = "ORION", d
     .info_name = "EMBEDDED_BASE_URL"
    WITH nocounter
   ;end insert
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failure inserting URL: ",errmsg)
   ELSE
    COMMIT
    SET readme_data->status = "S"
    SET readme_data->message =
    "Success: Readme populated the dm_info table with the embedded server url."
   ENDIF
  ENDIF
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

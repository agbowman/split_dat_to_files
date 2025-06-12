CREATE PROGRAM dm2_rdm_ocd_readme_comp:dba
 DECLARE der_cnt = i4
 DECLARE dorc_cnt = i4
 DECLARE errcode = i4
 DECLARE errmsg = vc
 DECLARE csv_path = vc
 DECLARE prog_name = vc
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
 CALL echo("Beginning Program, Checking Domain ...")
 SET readme_data->status = "F"
 SET dfs_inhouse = 0
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   dfs_inhouse = 1
  WITH nocounter
 ;end select
 IF (dfs_inhouse)
  SET readme_data->status = "S"
  SET readme_data->message = "AUTO-SUCCESS: This cannot be executed in an inhouse/internal domain."
  CALL echo(readme_data->message)
  GO TO exit_program
 ENDIF
 CALL echo("Checking for OCD_README_COMPONENT.CSV File ...")
 IF ( NOT (findfile("cer_install:dm2_ocd_readme_component.csv")))
  SET readme_data->message =
  "Error: Could not find ocd_readme_component.csv in cer_install location."
  SET readme_data->status = "F"
  CALL echo(readme_data->message)
  GO TO exit_program
 ENDIF
 CALL echo("Checking if the synonym for OCD_README_COMPONENT table exists ...")
 SELECT INTO "nl:"
  s.*
  FROM all_synonyms s
  WHERE s.synonym_name="OCD_README_COMPONENT"
  WITH nocounter
 ;end select
 IF ( NOT (curqual))
  SET readme_data->message = "Error: The synonym for OCD_README_COMPONENT table does not exist."
  SET readme_data->status = "F"
  CALL echo(readme_data->message)
  GO TO exit_program
 ENDIF
 SET readme_data->message = "Attempting clean data in OCD_README_COMPONENT table ..."
 CALL echo(readme_data->message)
 EXECUTE dm_dbimport "cer_install:dm2_ocd_readme_component.csv", "dm2_clean_ocd_readme_comp", 1000
 IF ((readme_data->status="F"))
  SET readme_data->message = concat("ERROR:",readme_data->message)
  CALL echo(readme_data->message)
  GO TO exit_program
 ELSE
  SET readme_data->message = "Success: Cleaned data in OCD_README_COMPONENT table."
  CALL echo(readme_data->message)
 ENDIF
#exit_program
 IF (validate(readme_data->readme_id,0)=0)
  CALL echorecord(readme_data)
 ELSE
  EXECUTE dm_readme_status
 ENDIF
 CALL echo("Exiting Program")
END GO

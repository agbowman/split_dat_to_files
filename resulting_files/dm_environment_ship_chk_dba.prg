CREATE PROGRAM dm_environment_ship_chk:dba
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
 SET desc_inhouse = 0
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   desc_inhouse = 1
  WITH nocounter
 ;end select
 IF (desc_inhouse)
  SET desc_status = "S"
  GO TO exit_script
 ENDIF
 SET desc_file = fillstring(132," ")
 SET desc_cnt = 0
 SET desc_file_stat = 0
 SET desc_status = "F"
 SET desc_msg = fillstring(300," ")
 SET readme_data->status = "F"
 SET readme_data->message = "Starting Readme..."
 SET desc_afe = 1
 SET desc_con_files = 1
 SET desc_files = 1
 SET desc_functions = 1
 SET desc_redo_logs = 1
 SET desc_roll_segs = 1
 SET desc_u_id = 222
 SET desc_u_task = 333
 SET desc_file = "cer_install:dm_environment_ship.csv"
 SET desc_file_stat = findfile(desc_file)
 IF (desc_file_stat=0)
  SET desc_status = "M"
  GO TO exit_script
 ENDIF
 CALL parser(concat('set logical desc_csv_name "',desc_file,'" go'))
 SELECT INTO "nl:"
  da.synonym_name, da.owner
  FROM dba_synonyms da
  WHERE da.synonym_name="DM_ENVIRONMENT_SHIP"
   AND da.owner="PUBLIC"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET desc_status = "Y"
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 "desc_csv_name"
 SELECT INTO "nl:"
  t.line
  FROM rtl2t t
  WHERE t.line > " "
  HEAD REPORT
   desc_cnt = 0, first_one = "Y"
  DETAIL
   IF (first_one="N")
    desc_cnt = (desc_cnt+ 1)
   ENDIF
   first_one = "N"
  FOOT REPORT
   row + 0
  WITH nocounter, check
 ;end select
 SET desc_tbl_cnt = 0
 SELECT INTO "nl:"
  d.updt_dt_tm, d.updt_id, d.updt_task
  FROM dm_environment_ship d
  WHERE d.updt_dt_tm=cnvtdatetime(curdate,0)
   AND d.updt_id=desc_u_id
   AND d.updt_task=desc_u_task
  DETAIL
   desc_tbl_cnt = (desc_tbl_cnt+ 1)
  WITH nocounter, check
 ;end select
 IF (desc_tbl_cnt != desc_cnt)
  SET desc_status = "F"
  SET desc_msg =
  "Readme Failed.  The number of records inserted into DM_ENVIRONMENT_SHIP table is not correct."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d.environment_name
  FROM dm_environment_ship v,
   dm_afe_ship d
  PLAN (v
   WHERE v.updt_dt_tm=cnvtdatetime(curdate,0)
    AND v.updt_id=desc_u_id
    AND v.updt_task=desc_u_task)
   JOIN (d
   WHERE v.environment_name=d.environment_name)
  WITH nocounter
 ;end select
 SET desc_afe = curqual
 SELECT INTO "nl:"
  d.environment_name
  FROM dm_environment_ship v,
   dm_env_con_files_ship d
  PLAN (v
   WHERE v.updt_dt_tm=cnvtdatetime(curdate,0)
    AND v.updt_id=desc_u_id
    AND v.updt_task=desc_u_task)
   JOIN (d
   WHERE v.environment_name=d.environment_name)
  WITH nocounter
 ;end select
 SET desc_con_files = curqual
 SELECT INTO "nl:"
  d.environment_name
  FROM dm_environment_ship v,
   dm_env_files_ship d
  PLAN (v
   WHERE v.updt_dt_tm=cnvtdatetime(curdate,0)
    AND v.updt_id=desc_u_id
    AND v.updt_task=desc_u_task)
   JOIN (d
   WHERE v.environment_name=d.environment_name)
  WITH nocounter
 ;end select
 SET desc_files = curqual
 SELECT INTO "nl:"
  d.environment_name
  FROM dm_environment_ship v,
   dm_env_functions_ship d
  PLAN (v
   WHERE v.updt_dt_tm=cnvtdatetime(curdate,0)
    AND v.updt_id=desc_u_id
    AND v.updt_task=desc_u_task)
   JOIN (d
   WHERE v.environment_name=d.environment_name)
  WITH nocounter
 ;end select
 SET desc_functions = curqual
 SELECT INTO "nl:"
  d.environment_name
  FROM dm_environment_ship v,
   dm_env_redo_logs_ship d
  PLAN (v
   WHERE v.updt_dt_tm=cnvtdatetime(curdate,0)
    AND v.updt_id=desc_u_id
    AND v.updt_task=desc_u_task)
   JOIN (d
   WHERE v.environment_name=d.environment_name)
  WITH nocounter
 ;end select
 SET desc_redo_logs = curqual
 SELECT INTO "nl:"
  d.environment_name
  FROM dm_environment_ship v,
   dm_env_roll_segs_ship d
  PLAN (v
   WHERE v.updt_dt_tm=cnvtdatetime(curdate,0)
    AND v.updt_id=desc_u_id
    AND v.updt_task=desc_u_task)
   JOIN (d
   WHERE v.environment_name=d.environment_name)
  WITH nocounter
 ;end select
 SET desc_roll_segs = curqual
 IF (desc_afe != 0)
  SET desc_status = "F"
  SET desc_msg = "Readme Failed.  The environment_name on dm_afe_ship table are not deleted."
 ELSEIF (desc_con_files != 0)
  SET desc_status = "F"
  SET desc_msg =
  "Readme Failed.  The environment_name on dm_env_con_files_ship table are not deleted."
 ELSEIF (desc_files != 0)
  SET desc_status = "F"
  SET desc_msg = "Readme Failed.  The environment_name on dm_env_files_ship table are not deleted."
 ELSEIF (desc_functions != 0)
  SET desc_status = "F"
  SET desc_msg =
  "Readme Failed.  The environment_name on dm_env_functions_ship table are not deleted."
 ELSEIF (desc_redo_logs != 0)
  SET desc_status = "F"
  SET desc_msg =
  "Readme Failed.  The environment_name on dm_env_redo_logs_ship table are not deleted."
 ELSEIF (desc_roll_segs != 0)
  SET desc_status = "F"
  SET desc_msg =
  "Readme Failed.  The environment_name on dm_env_roll_segs_ship table are not deleted."
 ELSE
  SET desc_status = "S"
 ENDIF
#exit_script
 IF (desc_status="M")
  SET readme_data->status = "F"
  SET readme_data->message =
  "Readme Failed.  The file Cer_install:dm_environment_ship.csv could not be found"
 ELSEIF (desc_status="Y")
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed.  There is no synonym for table dm_environment_ship."
 ELSEIF (desc_status="F")
  SET readme_data->status = "F"
  SET readme_data->message = desc_msg
 ELSEIF (desc_status="S")
  SET readme_data->status = "S"
  SET readme_data->message =
  "Readme Successful.  DM_ENVIRONMENT_SHIP table was successfully updated."
 ELSE
  SET readme_data->message = "Readme Failed.  This status is invalid."
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

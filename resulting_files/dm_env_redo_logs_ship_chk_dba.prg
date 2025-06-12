CREATE PROGRAM dm_env_redo_logs_ship_chk:dba
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
 SET derc_inhouse = 0
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   derc_inhouse = 1
  WITH nocounter
 ;end select
 IF (derc_inhouse)
  SET derc_status = "S"
  GO TO exit_script
 ENDIF
 SET derc_cnt = 0
 SET derc_file = fillstring(132," ")
 SET derc_file_stat = 0
 SET derc_status = "F"
 SET readme_data->status = "F"
 SET readme_data->message = "Starting Readme..."
 SET derc_u_id = 222
 SET derc_u_task = 333
 SET derc_file = "cer_install:dm_env_redo_logs_ship.csv"
 SET derc_file_stat = findfile(derc_file)
 IF (derc_file_stat=0)
  SET derc_status = "M"
  GO TO exit_script
 ENDIF
 CALL parser(concat('set logical derc_csv_name "',derc_file,'" go'))
 SELECT INTO "nl:"
  da.synonym_name, da.owner
  FROM dba_synonyms da
  WHERE da.synonym_name="DM_ENV_REDO_LOGS_SHIP"
   AND da.owner="PUBLIC"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET derc_status = "Y"
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 "derc_csv_name"
 SELECT INTO "nl:"
  t.line
  FROM rtl2t t
  WHERE t.line > " "
  HEAD REPORT
   derc_cnt = 0, first_one = "Y"
  DETAIL
   IF (first_one="N")
    derc_cnt = (derc_cnt+ 1)
   ENDIF
   first_one = "N"
  FOOT REPORT
   row + 0
  WITH nocounter, check
 ;end select
 SET derc_tbl_cnt = 0
 SELECT INTO "nl:"
  d.updt_dt_tm, d.updt_id, d.updt_task
  FROM dm_env_redo_logs_ship d
  WHERE d.updt_dt_tm=cnvtdatetime(curdate,0)
   AND d.updt_id=derc_u_id
   AND d.updt_task=derc_u_task
  DETAIL
   derc_tbl_cnt = (derc_tbl_cnt+ 1)
  WITH nocounter, check
 ;end select
 IF (derc_tbl_cnt != derc_cnt)
  SET derc_status = "F"
 ELSE
  SET derc_status = "S"
 ENDIF
#exit_script
 IF (derc_status="M")
  SET readme_data->status = "F"
  SET readme_data->message =
  "Readme Failed.  The file Cer_install:dm_env_redo_logs_ship.csv could not be found"
 ELSEIF (derc_status="Y")
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed.  There is no synonym for table dm_env_redo_logs_ship."
 ELSEIF (derc_status="F")
  SET readme_data->status = "F"
  SET readme_data->message =
  "Readme Failed. The number of records inserted into DM_ENV_REDO_LOGS_SHIP is not correct."
 ELSEIF (derc_status="S")
  SET readme_data->status = "S"
  SET readme_data->message =
  "Readme Successful.  DM_ENV_REDO_LOGS_SHIP table was successfully updated."
 ELSE
  SET readme_data->message = "Readme Failed. This status is invalid."
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

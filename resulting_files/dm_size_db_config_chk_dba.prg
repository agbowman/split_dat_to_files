CREATE PROGRAM dm_size_db_config_chk:dba
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
 SET dsdcc_inhouse = 0
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   dsdcc_inhouse = 1
  WITH nocounter
 ;end select
 IF (dsdcc_inhouse)
  SET dsdcc_status = "S"
  GO TO exit_script
 ENDIF
 SET dsdcc_file = fillstring(132," ")
 SET dsdcc_cnt = 0
 SET dsdcc_file_stat = 0
 SET dsdcc_status = "F"
 SET readme_data->status = "F"
 SET readme_data->message = "Starting Readme..."
 SET dsdcc_u_id = 222
 SET dsdcc_u_task = 333
 SET dsdcc_file = "cer_install:dm_size_db_config.csv"
 SET dsdcc_file_stat = findfile(dsdcc_file)
 IF (dsdcc_file_stat=0)
  SET dsdcc_status = "M"
  GO TO exit_script
 ENDIF
 CALL parser(concat('set logical dsdcc_csv_name "',dsdcc_file,'" go'))
 SELECT INTO "nl:"
  da.synonym_name, da.owner
  FROM dba_synonyms da
  WHERE da.synonym_name="DM_SIZE_DB_CONFIG"
   AND da.owner="PUBLIC"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET dsdcc_status = "Y"
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 "dsdcc_csv_name"
 SELECT INTO "nl:"
  t.line
  FROM rtl2t t
  WHERE t.line > " "
  HEAD REPORT
   dsdcc_cnt = 0, first_one = "Y"
  DETAIL
   IF (first_one="N")
    dsdcc_cnt = (dsdcc_cnt+ 1)
   ENDIF
   first_one = "N"
  FOOT REPORT
   row + 0
  WITH nocounter, check
 ;end select
 SET dsdcc_tbl_cnt = 0
 SELECT INTO "nl:"
  d.updt_dt_tm, d.updt_id, d.updt_task
  FROM dm_size_db_config d
  WHERE d.updt_dt_tm=cnvtdatetime(curdate,0)
   AND d.updt_id=dsdcc_u_id
   AND d.updt_task=dsdcc_u_task
  DETAIL
   dsdcc_tbl_cnt = (dsdcc_tbl_cnt+ 1)
  WITH nocounter, check
 ;end select
 IF (dsdcc_tbl_cnt != dsdcc_cnt)
  SET dsdcc_status = "F"
 ELSE
  SET dsdcc_status = "S"
 ENDIF
#exit_script
 IF (dsdcc_status="M")
  SET readme_data->status = "F"
  SET readme_data->message =
  "Readme Failed.  The file Cer_install:dm_size_db_config.csv could not be found"
 ELSEIF (dsdcc_status="Y")
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed.  There is no synonym for table dm_size_db_config."
 ELSEIF (dsdcc_status="F")
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Readme Failed. The number of records inserted into DM_SIZE_DB_CONFIG is incorrect.")
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Successful.  DM_SIZE_DB_CONFIG table was successfully updated."
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

CREATE PROGRAM dm_size_db_ts_chk:dba
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
 SET dsdtc_inhouse = 0
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   dsdtc_inhouse = 1
  WITH nocounter
 ;end select
 IF (dsdtc_inhouse)
  SET dsdtc_status = "S"
  GO TO exit_script
 ENDIF
 SET dsdtc_file = fillstring(132," ")
 SET dsdtc_cnt = 0
 SET dsdtc_file_stat = 0
 SET dsdtc_status = "F"
 SET readme_data->status = "F"
 SET readme_data->message = "Starting Readme..."
 SET dsdtc_u_id = 222
 SET dsdtc_u_task = 333
 SET dsdtc_file = "cer_install:dm_size_db_ts.csv"
 SET dsdtc_file_stat = findfile(dsdtc_file)
 IF (dsdtc_file_stat=0)
  SET dsdtc_status = "M"
  GO TO exit_script
 ENDIF
 CALL parser(concat('set logical dsdtc_csv_name "',dsdtc_file,'" go'))
 SELECT INTO "nl:"
  da.synonym_name, da.owner
  FROM dba_synonyms da
  WHERE da.synonym_name="DM_SIZE_DB_TS"
   AND da.owner="PUBLIC"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET dsdtc_status = "Y"
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 "dsdtc_csv_name"
 SELECT INTO "nl:"
  t.line
  FROM rtl2t t
  WHERE t.line > " "
  HEAD REPORT
   dsdtc_cnt = 0, first_one = "Y"
  DETAIL
   IF (first_one="N")
    dsdtc_cnt = (dsdtc_cnt+ 1)
   ENDIF
   first_one = "N"
  FOOT REPORT
   row + 0
  WITH nocounter, check
 ;end select
 SET dsdtc_tbl_cnt = 0
 SELECT INTO "nl:"
  d.updt_dt_tm, d.updt_id, d.updt_task
  FROM dm_size_db_ts d
  WHERE d.updt_dt_tm=cnvtdatetime(curdate,0)
   AND d.updt_id=dsdtc_u_id
   AND d.updt_task=dsdtc_u_task
  DETAIL
   dsdtc_tbl_cnt = (dsdtc_tbl_cnt+ 1)
  WITH nocounter, check
 ;end select
 IF (dsdtc_tbl_cnt != dsdtc_cnt)
  SET dsdtc_status = "F"
 ELSE
  SET dsdtc_status = "S"
 ENDIF
#exit_script
 IF (dsdtc_status="M")
  SET readme_data->status = "F"
  SET readme_data->message =
  "Readme Failed.  The file Cer_install:dm_size_db_ts.csv could not be found"
 ELSEIF (dsdtc_status="Y")
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed.  There is no synonym for table dm_size_db_ts."
 ELSEIF (dsdtc_status="F")
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Readme Failed. The number of records inserted into DM_SIZE_DB_TS is incorrect.")
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Successful.  DM_SIZE_DB_TS table was successfully updated."
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

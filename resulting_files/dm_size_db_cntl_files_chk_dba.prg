CREATE PROGRAM dm_size_db_cntl_files_chk:dba
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
 SET dsdfc_inhouse = 0
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   dsdfc_inhouse = 1
  WITH nocounter
 ;end select
 IF (dsdfc_inhouse)
  SET dsdfc_status = "S"
  GO TO exit_script
 ENDIF
 SET dsdfc_file = fillstring(132," ")
 SET dsdfc_cnt = 0
 SET dsdfc_file_stat = 0
 SET dsdfc_status = "F"
 SET readme_data->status = "F"
 SET readme_data->message = "Starting Readme..."
 SET dsdfc_u_id = 222
 SET dsdfc_u_task = 333
 SET dsdfc_file = "cer_install:dm_size_db_cntl_files.csv"
 SET dsdfc_file_stat = findfile(dsdfc_file)
 IF (dsdfc_file_stat=0)
  SET dsdfc_status = "M"
  GO TO exit_script
 ENDIF
 CALL parser(concat('set logical dsdfc_csv_name "',dsdfc_file,'" go'))
 SELECT INTO "nl:"
  da.synonym_name, da.owner
  FROM dba_synonyms da
  WHERE da.synonym_name="DM_SIZE_DB_CNTL_FILES"
   AND da.owner="PUBLIC"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET dsdfc_status = "Y"
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 "dsdfc_csv_name"
 SELECT INTO "nl:"
  t.line
  FROM rtl2t t
  WHERE t.line > " "
  HEAD REPORT
   dsdfc_cnt = 0, first_one = "Y"
  DETAIL
   IF (first_one="N")
    dsdfc_cnt = (dsdfc_cnt+ 1)
   ENDIF
   first_one = "N"
  FOOT REPORT
   row + 0
  WITH nocounter, check
 ;end select
 SET dsdfc_tbl_cnt = 0
 SELECT INTO "nl:"
  d.updt_dt_tm, d.updt_id, d.updt_task
  FROM dm_size_db_cntl_files d
  WHERE d.updt_dt_tm=cnvtdatetime(curdate,0)
   AND d.updt_id=dsdfc_u_id
   AND d.updt_task=dsdfc_u_task
  DETAIL
   dsdfc_tbl_cnt = (dsdfc_tbl_cnt+ 1)
  WITH nocounter, check
 ;end select
 IF (dsdfc_tbl_cnt != dsdfc_cnt)
  SET dsdfc_status = "F"
 ELSE
  SET dsdfc_status = "S"
 ENDIF
#exit_script
 IF (dsdfc_status="M")
  SET readme_data->status = "F"
  SET readme_data->message =
  "Readme Failed.  The file Cer_install:dm_size_db_cntl_files.csv could not be found"
 ELSEIF (dsdfc_status="Y")
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed.  There is no synonym for table dm_size_db_cntl_files."
 ELSEIF (dsdfc_status="F")
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Readme Failed. The number of records inserted into DM_SIZE_DB_CNTL_FILES is incorrect.")
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message =
  "Readme Successful.  DM_SIZE_DB_CNTL_FILES table was successfully updated."
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

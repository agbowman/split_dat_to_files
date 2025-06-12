CREATE PROGRAM dm_size_db_redo_logs_chk:dba
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
 SET dsdlc_inhouse = 0
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   dsdlc_inhouse = 1
  WITH nocounter
 ;end select
 IF (dsdlc_inhouse)
  SET dsdlc_status = "S"
  GO TO exit_script
 ENDIF
 SET dsdlc_file = fillstring(132," ")
 SET dsdlc_cnt = 0
 SET dsdlc_file_stat = 0
 SET dsdlc_status = "F"
 SET readme_data->status = "F"
 SET readme_data->message = "Starting Readme..."
 SET dsdlc_u_id = 222
 SET dsdlc_u_task = 333
 SET dsdlc_file = "cer_install:dm_size_db_redo_logs.csv"
 SET dsdlc_file_stat = findfile(dsdlc_file)
 IF (dsdlc_file_stat=0)
  SET dsdlc_status = "M"
  GO TO exit_script
 ENDIF
 CALL parser(concat('set logical dsdlc_csv_name "',dsdlc_file,'" go'))
 SELECT INTO "nl:"
  da.synonym_name, da.owner
  FROM dba_synonyms da
  WHERE da.synonym_name="DM_SIZE_DB_REDO_LOGS"
   AND da.owner="PUBLIC"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET dsdlc_status = "Y"
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 "dsdlc_csv_name"
 SELECT INTO "nl:"
  t.line
  FROM rtl2t t
  WHERE t.line > " "
  HEAD REPORT
   dsdlc_cnt = 0, first_one = "Y"
  DETAIL
   IF (first_one="N")
    dsdlc_cnt = (dsdlc_cnt+ 1)
   ENDIF
   first_one = "N"
  FOOT REPORT
   row + 0
  WITH nocounter, check
 ;end select
 SET dsdlc_tbl_cnt = 0
 SELECT INTO "nl:"
  d.updt_dt_tm, d.updt_id, d.updt_task
  FROM dm_size_db_redo_logs d
  WHERE d.updt_dt_tm=cnvtdatetime(curdate,0)
   AND d.updt_id=dsdlc_u_id
   AND d.updt_task=dsdlc_u_task
  DETAIL
   dsdlc_tbl_cnt = (dsdlc_tbl_cnt+ 1)
  WITH nocounter, check
 ;end select
 IF (dsdlc_tbl_cnt != dsdlc_cnt)
  SET dsdlc_status = "F"
 ELSE
  SET dsdlc_status = "S"
 ENDIF
#exit_script
 IF (dsdlc_status="M")
  SET readme_data->status = "F"
  SET readme_data->message =
  "Readme Failed.  The file Cer_install:dm_size_db_redo_logs.csv could not be found"
 ELSEIF (dsdlc_status="Y")
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed.  There is no synonym for table dm_size_db_redo_logs."
 ELSEIF (dsdlc_status="F")
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Readme Failed. The number of records inserted into DM_SIZE_DB_REDO_LOGS is incorrect.")
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message =
  "Readme Successful.  DM_SIZE_DB_REDO_LOGS table was successfully updated."
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

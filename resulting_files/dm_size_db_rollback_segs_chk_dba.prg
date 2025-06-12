CREATE PROGRAM dm_size_db_rollback_segs_chk:dba
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
 SET dsdsc_inhouse = 0
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   dsdsc_inhouse = 1
  WITH nocounter
 ;end select
 IF (dsdsc_inhouse)
  SET dsdsc_status = "S"
  GO TO exit_script
 ENDIF
 SET dsdsc_file = fillstring(132," ")
 SET dsdsc_cnt = 0
 SET dsdsc_file_stat = 0
 SET dsdsc_status = "F"
 SET readme_data->status = "F"
 SET readme_data->message = "Starting Readme..."
 SET dsdsc_u_id = 222
 SET dsdsc_u_task = 333
 SET dsdsc_file = "cer_install:dm_size_db_rollback_segs.csv"
 SET dsdsc_file_stat = findfile(dsdsc_file)
 IF (dsdsc_file_stat=0)
  SET dsdsc_status = "M"
  GO TO exit_script
 ENDIF
 CALL parser(concat('set logical dsdsc_csv_name "',dsdsc_file,'" go'))
 SELECT INTO "nl:"
  da.synonym_name, da.owner
  FROM dba_synonyms da
  WHERE da.synonym_name="DM_SIZE_DB_ROLLBACK_SEGS"
   AND da.owner="PUBLIC"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET dsdsc_status = "Y"
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 "dsdsc_csv_name"
 SELECT INTO "nl:"
  t.line
  FROM rtl2t t
  WHERE t.line > " "
  HEAD REPORT
   dsdsc_cnt = 0, first_one = "Y"
  DETAIL
   IF (first_one="N")
    dsdsc_cnt = (dsdsc_cnt+ 1)
   ENDIF
   first_one = "N"
  FOOT REPORT
   row + 0
  WITH nocounter, check
 ;end select
 SET dsdsc_tbl_cnt = 0
 SELECT INTO "nl:"
  d.updt_dt_tm, d.updt_id, d.updt_task
  FROM dm_size_db_rollback_segs d
  WHERE d.updt_dt_tm=cnvtdatetime(curdate,0)
   AND d.updt_id=dsdsc_u_id
   AND d.updt_task=dsdsc_u_task
  DETAIL
   dsdsc_tbl_cnt = (dsdsc_tbl_cnt+ 1)
  WITH nocounter, check
 ;end select
 IF (dsdsc_tbl_cnt != dsdsc_cnt)
  SET dsdsc_status = "F"
 ELSE
  SET dsdsc_status = "S"
 ENDIF
#exit_script
 IF (dsdsc_status="M")
  SET readme_data->status = "F"
  SET readme_data->message =
  "Readme Failed.  The file Cer_install:dm_size_db_rollback_segs.csv could not be found"
 ELSEIF (dsdsc_status="Y")
  SET readme_data->status = "F"
  SET readme_data->message =
  "Readme Failed.  There is no synonym for table dm_size_db_rollback_segs."
 ELSEIF (dsdsc_status="F")
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Readme Failed. The number of records inserted into DM_SIZE_DB_ROLLBACK_SEGS is incorrect.")
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message =
  "Readme Successful.  DM_SIZE_DB_ROLLBACK_SEGS table was successfully updated."
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

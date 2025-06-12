CREATE PROGRAM dm_size_db_version_chk:dba
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
 SET dsdvc_inhouse = 0
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   dsdvc_inhouse = 1
  WITH nocounter
 ;end select
 IF (dsdvc_inhouse)
  SET dsdvc_status = "S"
  GO TO exit_script
 ENDIF
 SET dsdvc_file = fillstring(132," ")
 SET dsdvc_cnt = 0
 SET dsdvc_file_stat = 0
 SET dsdvc_status = "F"
 SET dsdvc_msg = fillstring(300," ")
 SET readme_data->status = "F"
 SET readme_data->message = "Starting Readme..."
 SET dsdvc_ts = 1
 SET dsdvc_config = 1
 SET dsdvc_cntl_files = 1
 SET dsdvc_redo_logs = 1
 SET dsdvc_rollback_segs = 1
 SET dsdvc_u_id = 222
 SET dsdvc_u_task = 333
 SET dsdvc_file = "cer_install:dm_size_db_version.csv"
 SET dsdvc_file_stat = findfile(dsdvc_file)
 IF (dsdvc_file_stat=0)
  SET dsdvc_status = "M"
  GO TO exit_script
 ENDIF
 CALL parser(concat('set logical dsdvc_csv_name "',dsdvc_file,'" go'))
 SELECT INTO "nl:"
  da.synonym_name, da.owner
  FROM dba_synonyms da
  WHERE da.synonym_name="DM_SIZE_DB_VERSION"
   AND da.owner="PUBLIC"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET dsdvc_status = "Y"
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 "dsdvc_csv_name"
 SELECT INTO "nl:"
  t.line
  FROM rtl2t t
  WHERE t.line > " "
  HEAD REPORT
   dsdvc_cnt = 0, first_one = "Y"
  DETAIL
   IF (first_one="N")
    dsdvc_cnt = (dsdvc_cnt+ 1)
   ENDIF
   first_one = "N"
  FOOT REPORT
   row + 0
  WITH nocounter, check
 ;end select
 SET dsdvc_tbl_cnt = 0
 SELECT INTO "nl:"
  d.updt_dt_tm, d.updt_id, d.updt_task
  FROM dm_size_db_version d
  WHERE d.updt_dt_tm=cnvtdatetime(curdate,0)
   AND d.updt_id=dsdvc_u_id
   AND d.updt_task=dsdvc_u_task
  DETAIL
   dsdvc_tbl_cnt = (dsdvc_tbl_cnt+ 1)
  WITH nocounter, check
 ;end select
 IF (dsdvc_tbl_cnt != dsdvc_cnt)
  SET dsdvc_status = "F"
  SET dsdvc_msg =
  "Readme Failed. The number of records inserted into DM_SIZE_DB_VERSION is incorrect."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d.db_version
  FROM dm_size_db_version v,
   dm_size_db_ts d
  PLAN (v
   WHERE v.updt_dt_tm=cnvtdatetime(curdate,0)
    AND v.updt_id=dsdvc_u_id
    AND v.updt_task=dsdvc_u_task)
   JOIN (d
   WHERE v.db_version=d.db_version)
  WITH nocounter
 ;end select
 SET dsdvc_ts = curqual
 SELECT INTO "nl:"
  d.db_version
  FROM dm_size_db_version v,
   dm_size_db_config d
  PLAN (v
   WHERE v.updt_dt_tm=cnvtdatetime(curdate,0)
    AND v.updt_id=dsdvc_u_id
    AND v.updt_task=dsdvc_u_task)
   JOIN (d
   WHERE v.db_version=d.db_version)
  WITH nocounter
 ;end select
 SET dsdvc_config = curqual
 SELECT INTO "nl:"
  d.db_version
  FROM dm_size_db_version v,
   dm_size_db_cntl_files d
  PLAN (v
   WHERE v.updt_dt_tm=cnvtdatetime(curdate,0)
    AND v.updt_id=dsdvc_u_id
    AND v.updt_task=dsdvc_u_task)
   JOIN (d
   WHERE v.db_version=d.db_version)
  WITH nocounter
 ;end select
 SET dsdvc_cntl_files = curqual
 SELECT INTO "nl:"
  d.db_version
  FROM dm_size_db_version v,
   dm_size_db_cntl_files d
  PLAN (v
   WHERE v.updt_dt_tm=cnvtdatetime(curdate,0)
    AND v.updt_id=dsdvc_u_id
    AND v.updt_task=dsdvc_u_task)
   JOIN (d
   WHERE v.db_version=d.db_version)
  WITH nocounter
 ;end select
 SET dsdvc_redo_logs = curqual
 SELECT INTO "nl:"
  d.db_version
  FROM dm_size_db_version v,
   dm_size_db_rollback_segs d
  PLAN (v
   WHERE v.updt_dt_tm=cnvtdatetime(curdate,0)
    AND v.updt_id=dsdvc_u_id
    AND v.updt_task=dsdvc_u_task)
   JOIN (d
   WHERE v.db_version=d.db_version)
  WITH nocounter
 ;end select
 SET dsdvc_rollback_segs = curqual
 IF (dsdvc_ts != 0)
  SET dsdvc_status = "F"
  SET dsdvc_msg =
  "Readme Failed.  The db_versions in csv file are not deleted from table DM_SIZE_DB_TS."
 ELSEIF (dsdvc_config != 0)
  SET dsdvc_status = "F"
  SET dsdvc_msg =
  "Readme failed.  The db_versions in csv file are not deleted from table DM_SIZE_DB_CONFIG."
 ELSEIF (dsdvc_cntl_files != 0)
  SET dsdvc_status = "F"
  SET dsdvc_msg =
  "Readme Failed.  The db_versions in csv file are not deleted from table DM_SIZE_DB_CNTL_FILES."
 ELSEIF (dsdvc_redo_logs != 0)
  SET dsdvc_status = "F"
  SET dsdvc_msg =
  "Readme Failed.  The db_versions in csv file are not deleted from table DM_SIZE_DB_REDO_LOGS."
 ELSEIF (dsdvc_rollback_segs != 0)
  SET dsdvc_status = "F"
  SET dsdvc_msg =
  "Readme Failed.  The db_versions in csv file are not deleted from table DM_SIZE_DB_ROLL_SEGS."
 ELSE
  SET dsdvc_status = "S"
 ENDIF
#exit_script
 IF (dsdvc_status="M")
  SET readme_data->status = "F"
  SET readme_data->message =
  "Readme Failed.  The file Cer_install:dm_size_db_version.csv could not be found"
 ELSEIF (dsdvc_status="Y")
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed.  There is no synonym for table dm_size_db_version."
 ELSEIF (dsdvc_status="F")
  SET readme_data->status = "F"
  SET readme_data->message = dsdvc_msg
 ELSEIF (dsdvc_status="S")
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Successful.  DM_SIZE_DB_VERSION table was successfully updated."
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

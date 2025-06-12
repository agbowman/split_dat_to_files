CREATE PROGRAM dm_afe_ship_chk:dba
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
 SET dasc_inhouse = 0
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   dasc_inhouse = 1
  WITH nocounter
 ;end select
 IF (dasc_inhouse)
  SET dasc_status = "S"
  GO TO exit_script
 ENDIF
 SET dasc_file = fillstring(132," ")
 SET dasc_cnt = 0
 SET dasc_file_stat = 0
 SET dasc_status = "F"
 SET readme_data->status = "F"
 SET readme_data->message = "Starting Readme..."
 SET dasc_i_mode = "222"
 SET dasc_c_ind = "333"
 SET dasc_file = "cer_install:dm_afe_ship.csv"
 SET dasc_file_stat = findfile(dasc_file)
 IF (dasc_file_stat=0)
  SET dasc_status = "M"
  GO TO exit_script
 ENDIF
 CALL parser(concat('set logical dasc_csv_name "',dasc_file,'" go'))
 SELECT INTO "nl:"
  da.synonym_name, da.owner
  FROM dba_synonyms da
  WHERE da.synonym_name="DM_AFE_SHIP"
   AND da.owner="PUBLIC"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET dasc_status = "Y"
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 "dasc_csv_name"
 SELECT INTO "nl:"
  t.line
  FROM rtl2t t
  WHERE t.line > " "
  HEAD REPORT
   dasc_cnt = 0, first_one = "Y"
  DETAIL
   IF (first_one="N")
    dasc_cnt = (dasc_cnt+ 1)
   ENDIF
   first_one = "N"
  FOOT REPORT
   row + 0
  WITH nocounter
 ;end select
 SET dasc_tbl_cnt = 0
 SELECT INTO "nl:"
  d.start_dt_tm, d.end_dt_tm, d.inst_mode,
  d.curr_migration_ind
  FROM dm_afe_ship d
  WHERE d.start_dt_tm=cnvtdatetime(curdate,0)
   AND d.end_dt_tm=cnvtdatetime(curdate,0)
   AND d.inst_mode=dasc_i_mode
   AND d.curr_migration_ind=dasc_c_ind
  DETAIL
   dasc_tbl_cnt = (dasc_tbl_cnt+ 1)
  WITH nocounter, check
 ;end select
 IF (dasc_tbl_cnt != dasc_cnt)
  SET dasc_status = "F"
 ELSE
  SET dasc_status = "S"
 ENDIF
#exit_script
 IF (dasc_status="M")
  SET readme_data->status = "F"
  SET readme_data->message =
  "Readme Failed.  The file Cer_install:dm_afe_ship.csv could not be found"
 ELSEIF (dasc_status="Y")
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed.  There is no synonym for table dm_afe_ship."
 ELSEIF (dasc_status="F")
  SET readme_data->status = "F"
  SET readme_data->message =
  "Readme Failed.  The number of records inserted in to DM_AFE_SHIP is not correct."
 ELSEIF (dasc_status="S")
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Successful.  DM_AFE_SHIP table was successfully updated."
 ELSE
  SET readme_data->message = "Readme Failed.  This is a invalid status."
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

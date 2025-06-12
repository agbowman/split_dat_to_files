CREATE PROGRAM dm_rdm_wrp_last_utc_ts:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script dm_rdm_wrp_last_utc_ts..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE drwlut_inhouse_ind = i2 WITH protect, noconstant(0)
 EXECUTE dm_dbimport "cer_install:dm_last_utc_ts_metadata.csv", "dm_rdm_load_last_utc_ts", 1000
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:dm_txnscn_metadata.csv", "dm_rdm_load_last_utc_ts", 1000
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name IN ("INHOUSE DOMAIN", "MILLPLUS IH EXCEPTION")
  ORDER BY d.info_name
  HEAD d.info_name
   IF (d.info_name="INHOUSE DOMAIN")
    drwlut_inhouse_ind = (drwlut_inhouse_ind+ 1)
   ELSEIF (d.info_name="MILLPLUS IH EXCEPTION")
    drwlut_inhouse_ind = (drwlut_inhouse_ind+ 2)
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select from DM_INFO: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (drwlut_inhouse_ind=3)
  EXECUTE dm2_rdm_install_luts
 ENDIF
 IF ((readme_data->status != "F"))
  COMMIT
  SET readme_data->status = "S"
  SET readme_data->message = "Success: Readme loaded the DM_INFO table"
 ELSE
  ROLLBACK
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

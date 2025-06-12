CREATE PROGRAM dac_cleanup_eod_si_releases:dba
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
 SET readme_data->message = "Readme failed: starting script dac_cleanup_eod_si_releases..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DELETE  FROM dm_core_eod_si dcei
  WHERE ((dcei.os_version_name="AXP"
   AND dcei.si_release_ident IN (2011, 2719)) OR (((dcei.os_version_name="HPX"
   AND dcei.si_release_ident=4519) OR (dcei.os_version_name="AIX"
   AND dcei.si_release_ident=3719)) ))
  WITH nocounter
 ;end delete
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from DM_CORE_EOD_SI: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM dm_info di
  WHERE di.info_domain="CORE_EOD_SI"
   AND ((di.info_name="KEY:2011*") OR (((di.info_name="KEY:2719*") OR (((di.info_name="KEY:4519*")
   OR (di.info_name="KEY:3719*")) )) ))
  WITH nocounter
 ;end delete
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from DM_INFO: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: EOD SI sets have been neutralized"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

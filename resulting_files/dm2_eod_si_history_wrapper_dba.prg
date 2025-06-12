CREATE PROGRAM dm2_eod_si_history_wrapper:dba
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
 SET readme_data->message = "Failed: Starting script dm2_eod_si_history_wrapper.prg..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE dm_dbi_parent_commit_ind = i2 WITH public, noconstant(1)
 FREE RECORD eod_dm_info
 RECORD eod_dm_info(
   1 list[*]
     2 os_version = vc
     2 version_number = i4
     2 key_version = vc
 )
 EXECUTE dm_dbimport "cer_install:dm2_eod_si_history.txt", "dm2_eod_si_history_load", 5000
 IF ((readme_data->status != "S"))
  ROLLBACK
  GO TO exit_script
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Failed to load EOD SI info on DM_INFO"
 IF (size(eod_dm_info->list,5) > 0)
  INSERT  FROM dm_info di,
    (dummyt d  WITH seq = value(size(eod_dm_info->list,5)))
   SET di.info_domain = "CORE_EOD_SI", di.info_name = eod_dm_info->list[d.seq].key_version, di
    .info_char = eod_dm_info->list[d.seq].os_version,
    di.info_number = eod_dm_info->list[d.seq].version_number, di.info_date = cnvtdatetime(curdate,
     curtime3), di.updt_applctx = reqinfo->updt_applctx,
    di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id,
    di.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (di)
   WITH nocounter
  ;end insert
 ENDIF
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->message = concat("Failed to load EOD SI info on DM_INFO:",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
  SET readme_data->status = "S"
  SET readme_data->message = "Success: EOD SI load successful"
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

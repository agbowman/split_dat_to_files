CREATE PROGRAM dm_add_stat_gather_sql_deltas:dba
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
 DECLARE dm_err_msg = c132
 DECLARE dm_exists_ind = i2
 SET dm_err_msg = fillstring(132," ")
 SET dm_exists_ind = 0
 SET readme_data->status = "F"
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="DM_STAT_GATHER"
   AND d.info_name="DM_STAT_GATHER_SQL_DELTAS"
  WITH nocounter
 ;end select
 IF (error(dm_err_msg,1) != 0)
  SET readme_data->message = concat("FAIL: ",dm_err_msg)
  GO TO exit_script
 ENDIF
 IF (curqual > 0)
  SET dm_exists_ind = 1
 ENDIF
 IF (dm_exists_ind=1)
  UPDATE  FROM dm_info d
   SET d.info_char = "ROUTINE", d.info_number = 60, d.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    d.updt_cnt = (d.updt_cnt+ 1)
   WHERE d.info_domain="DM_STAT_GATHER"
    AND d.info_name="DM_STAT_GATHER_SQL_DELTAS"
   WITH nocounter
  ;end update
 ELSE
  INSERT  FROM dm_info d
   SET d.info_domain = "DM_STAT_GATHER", d.info_name = "DM_STAT_GATHER_SQL_DELTAS", d.info_char =
    "ROUTINE",
    d.info_number = 60, d.updt_applctx = 0, d.updt_cnt = 0,
    d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = 0, d.updt_task = 0
   WITH nocounter
  ;end insert
 ENDIF
 IF (error(dm_err_msg,1) != 0)
  SET readme_data->message = concat("FAIL: ",dm_err_msg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "SUCCESS: properly added row to dm_info for stat gather deltas program"
#exit_script
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO

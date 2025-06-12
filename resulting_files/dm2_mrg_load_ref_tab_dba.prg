CREATE PROGRAM dm2_mrg_load_ref_tab:dba
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
 SET dm_err_msg = fillstring(132," ")
 SET readme_data->status = "F"
 SET readme_data->message = "FAIL: did not properly load dm_info"
 DELETE  FROM dm_info di
  WHERE di.info_domain="DM2 REFERENCE TABLE"
  WITH nocounter
 ;end delete
 IF (error(dm_err_msg,1) != 0)
  SET readme_data->message = concat("FAIL: ",dm_err_msg)
  GO TO exit_program
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dm_info di
  (di.info_domain, di.info_name, di.updt_dt_tm)(SELECT
   "DM2 REFERENCE TABLE", dt.table_name, cnvtdatetime(curdate,curtime3)
   FROM dm_tables_doc dt
   WHERE dt.reference_ind=1)
  WITH nocounter
 ;end insert
 IF (error(dm_err_msg,1) != 0)
  SET readme_data->message = concat("FAIL: ",dm_err_msg)
  GO TO exit_program
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dm_info di
  SET di.info_domain = "DM2 REFERENCE TABLE", di.info_name = "DRC_TEXT", di.updt_dt_tm = cnvtdatetime
   (curdate,curtime3)
  WITH nocounter
 ;end insert
 IF (error(dm_err_msg,1) != 0)
  SET readme_data->message = concat("FAIL: ",dm_err_msg)
  GO TO exit_program
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  dt.table_name
  FROM dm_tables_doc dt
  WHERE dt.reference_ind=1
   AND  NOT ( EXISTS (
  (SELECT
   di.info_name
   FROM dm_info di
   WHERE di.info_domain="DM2 REFERENCE TABLE"
    AND dt.table_name=di.info_name)))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET readme_data->message = "FAIL: not all rows from dm_tables_doc made it into dm_info"
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "SUCCESS: all reference tables are now listed in dm_info"
 ENDIF
#exit_program
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO

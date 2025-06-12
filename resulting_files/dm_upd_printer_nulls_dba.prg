CREATE PROGRAM dm_upd_printer_nulls:dba
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
 SET readme_data->message = "Readme failed: starting script dm_upd_printer_nulls..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 UPDATE  FROM device d
  SET d.name = null, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = (d.updt_cnt+ 1),
   d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_task
  WHERE d.name=""
  WITH nocounter
 ;end update
 CALL check_status("DEVICE.name")
 UPDATE  FROM device d
  SET d.description = null, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = (d.updt_cnt+ 1),
   d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_task
  WHERE d.description=""
  WITH nocounter
 ;end update
 CALL check_status("DEVICE.description")
 UPDATE  FROM device d
  SET d.physical_device_name = null, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = (d.updt_cnt
   + 1),
   d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_task
  WHERE d.physical_device_name=""
  WITH nocounter
 ;end update
 CALL check_status("DEVICE.physical_device_name")
 UPDATE  FROM output_dest o
  SET o.label_program_name = null, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = (o.updt_cnt+
   1),
   o.updt_dt_tm = cnvtdatetime(sysdate), o.updt_id = reqinfo->updt_task
  WHERE o.label_program_name=""
  WITH nocounter
 ;end update
 CALL check_status("OUTPUT_DEST.label_program_name")
 UPDATE  FROM output_dest o
  SET o.label_prefix = null, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = (o.updt_cnt+ 1),
   o.updt_dt_tm = cnvtdatetime(sysdate), o.updt_id = reqinfo->updt_task
  WHERE o.label_prefix=""
  WITH nocounter
 ;end update
 CALL check_status("OUTPUT_DEST.label_prefix")
 UPDATE  FROM dms_service d
  SET d.destination_server_name = null, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = (d
   .updt_cnt+ 1),
   d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_task
  WHERE d.destination_server_name=""
  WITH nocounter
 ;end update
 CALL check_status("DMS_SERVICE.destination_server_name")
 UPDATE  FROM printer p
  SET p.default_tray_name = null, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (p.updt_cnt+ 1
   ),
   p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_task
  WHERE p.default_tray_name=""
  WITH nocounter
 ;end update
 CALL check_status("PRINTER.default_tray_name")
 UPDATE  FROM printer p
  SET p.default_custom_form_name = null, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (p
   .updt_cnt+ 1),
   p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_task
  WHERE p.default_custom_form_name=""
  WITH nocounter
 ;end update
 CALL check_status("PRINTER.default_custom_form_name")
 SUBROUTINE (check_status(column=vc) =null)
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update ",concat(column,", ",errmsg))
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

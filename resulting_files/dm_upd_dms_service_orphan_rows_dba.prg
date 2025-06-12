CREATE PROGRAM dm_upd_dms_service_orphan_rows:dba
 DECLARE printer_device_type_cd = f8 WITH noconstant(0.0), public
 DECLARE incorrect_dms_device_cnt = i4 WITH noconstant(0), public
 DECLARE found_dmsservice_cnt = i4 WITH noconstant(0), public
 DECLARE stat = i4 WITH noconstant(0), public
 DECLARE created_dms_service_id = f8 WITH noconstant(0), public
 DECLARE updated = i2 WITH noconstant(0), public
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE get_next_id(dest=f8(ref)) = null
 DECLARE add_dms_service(y=i4(value)) = null
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
 FREE RECORD dms_service_orphan_row
 RECORD dms_service_orphan_row(
   1 row_data[*]
     2 dms_service_id = f8
     2 service_name = vc
     2 device_cd = f8
     2 external_flag = i2
 )
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.cdf_meaning="PRINTER"
   AND c.code_set=3000
  DETAIL
   printer_device_type_cd = c.code_value
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat("Readme failed: Cannot retrieve PRINTER code value: ",errmsg,
   " . ")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d.device_cd, d.name
  FROM device d
  WHERE d.dms_service_id=0.0
   AND d.device_type_cd=printer_device_type_cd
  DETAIL
   incorrect_dms_device_cnt = (incorrect_dms_device_cnt+ 1), stat = alterlist(dms_service_orphan_row
    ->row_data,incorrect_dms_device_cnt), dms_service_orphan_row->row_data[incorrect_dms_device_cnt].
   device_cd = d.device_cd,
   dms_service_orphan_row->row_data[incorrect_dms_device_cnt].service_name = concat(trim(d.name),
    "@DMS@PRINTER")
   IF (size(trim(d.physical_device_name)) > 0)
    dms_service_orphan_row->row_data[incorrect_dms_device_cnt].external_flag = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat("Readme error retrieving incorrect dms entires in DEVICE: ",
   errmsg," . ")
 ENDIF
 IF (incorrect_dms_device_cnt=0)
  SET readme_data->status = "S"
  SET readme_data->message = concat("No rows need updated.")
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO incorrect_dms_device_cnt)
   SELECT INTO "nl:"
    ds.dms_service_id, ds.service_name
    FROM dms_service ds
    WHERE (ds.service_name=dms_service_orphan_row->row_data[i].service_name)
     AND ds.service_type="WIN_PRINT_SERVICE"
    DETAIL
     dms_service_orphan_row->row_data[i].dms_service_id = ds.dms_service_id, found_dmsservice_cnt = (
     found_dmsservice_cnt+ 1)
    WITH nocounter
   ;end select
 ENDFOR
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat("Readme error retrieving DMS_SERVICE entries: ",errmsg," . ")
 ENDIF
 IF (incorrect_dms_device_cnt > found_dmsservice_cnt)
  FOR (y = 1 TO incorrect_dms_device_cnt)
    IF ((dms_service_orphan_row->row_data[y].dms_service_id=0)
     AND (dms_service_orphan_row->row_data[y].external_flag=0))
     CALL get_next_id(created_dms_service_id)
     CALL add_dms_service(y)
    ENDIF
  ENDFOR
 ENDIF
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat("Readme error creating DMS_SERVICE entries: ",errmsg," . ")
 ENDIF
 FOR (z = 1 TO incorrect_dms_device_cnt)
   IF ((dms_service_orphan_row->row_data[z].dms_service_id != 0))
    UPDATE  FROM device d
     SET d.dms_service_id = dms_service_orphan_row->row_data[z].dms_service_id, d.updt_cnt = (d
      .updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
      updt_applctx
     WHERE (d.device_cd=dms_service_orphan_row->row_data[z].device_cd)
    ;end update
    IF (curqual=1)
     SET updated = 1
    ENDIF
   ENDIF
   IF (updated=0)
    SELECT INTO "cer_print:dms_service_orphan_row_correction_log"
     trim(cnvtstring(dms_service_orphan_row->row_data[z].device_cd)), ","
     WITH noheading, append, format = variable
    ;end select
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Readme failures: Corresponding DMS_SERVICE entries not created for some devices",
     ", check cer_print:dms_service_orphan_row_correction_log")
   ELSE
    SET readme_data->status = "S"
    SET readme_data->message = concat("Success: Readme performed all required tasks")
   ENDIF
   SET updated = 0
 ENDFOR
 SUBROUTINE get_next_id(dest)
   SELECT INTO "nl:"
    nextseq = seq(outputctx_seq,nextval)
    FROM dual
    DETAIL
     dest = nextseq
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE add_dms_service(y)
  INSERT  FROM dms_service ds
   SET ds.dms_service_id = created_dms_service_id, ds.host_name = " ", ds.service_name =
    dms_service_orphan_row->row_data[y].service_name,
    ds.service_type = "WIN_PRINT_SERVICE", ds.destination_server_name = "", ds.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    ds.updt_id = reqinfo->updt_id, ds.updt_task = reqinfo->updt_task, ds.updt_cnt = 0,
    ds.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=1)
   SET dms_service_orphan_row->row_data[y].dms_service_id = created_dms_service_id
  ENDIF
 END ;Subroutine
#exit_script
 COMMIT
 CALL echorecord(readme_data)
END GO

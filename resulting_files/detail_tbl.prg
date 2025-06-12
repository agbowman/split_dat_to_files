CREATE PROGRAM detail_tbl
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  d.description, d.device_cd, d_device_disp = uar_get_code_display(d.device_cd),
  d.device_function_cd, d_device_function_disp = uar_get_code_display(d.device_function_cd), d
  .device_type_cd,
  d_device_type_disp = uar_get_code_display(d.device_type_cd), d.distribution_flag, d.dms_service_id,
  d.local_address, d.location_cd, d_location_disp = uar_get_code_display(d.location_cd),
  d.name, d.updt_applctx, d.updt_cnt,
  d.updt_dt_tm, d.updt_id, d.updt_task
  FROM device d
  WHERE d.device_type_cd=2282
   AND d.device_type_cd != 2287
   AND d.device_type_cd != 2283
   AND d.device_type_cd != 2260245
   AND d.device_type_cd != 2289
   AND d.device_type_cd != 2284
   AND d.device_type_cd != 2286
   AND d.device_type_cd != 2288
   AND d.device_type_cd != 2260244
  WITH maxrec = 10, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

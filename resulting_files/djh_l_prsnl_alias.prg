CREATE PROGRAM djh_l_prsnl_alias
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
  SET maxsecs = 60
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
  WHERE p.alias="*5972*"
  WITH maxrec = 50, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

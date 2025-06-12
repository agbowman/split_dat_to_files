CREATE PROGRAM djh_122931_device
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
  d.description, d.name, d.device_cd,
  d_device_disp = uar_get_code_display(d.device_cd), d.device_function_cd, d_device_function_disp =
  uar_get_code_display(d.device_function_cd),
  d.device_type_cd, d_device_type_disp = uar_get_code_display(d.device_type_cd), d.updt_dt_tm
  FROM device d
  PLAN (d
   WHERE d.device_type_cd != 2283
    AND d.device_type_cd != 2287
    AND d.device_type_cd != 2288
    AND d.device_type_cd != 2260244)
  ORDER BY d.description
  WITH maxrec = 10, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

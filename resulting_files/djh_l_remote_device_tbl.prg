CREATE PROGRAM djh_l_remote_device_tbl
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
  r.access_cd, r_access_disp = uar_get_code_display(r.access_cd), r.area_code,
  r.country_access, r.device_address_type_cd, r_device_address_type_disp = uar_get_code_display(r
   .device_address_type_cd),
  r.device_cd, r_device_disp = uar_get_code_display(r.device_cd), r.exchange,
  r.local_flag, r.phone_mask_id, r.phone_suffix,
  r.remote_dev_type_id, r.updt_applctx, r.updt_cnt,
  r.updt_dt_tm, r.updt_id, r.updt_task
  FROM remote_device r
  WITH maxrec = 5, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

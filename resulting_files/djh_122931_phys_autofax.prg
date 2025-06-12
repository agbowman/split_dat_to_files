CREATE PROGRAM djh_122931_phys_autofax
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
  d.description, r.area_code, r.exchange,
  r.phone_suffix, d_device_type_disp = uar_get_code_display(d.device_type_cd), d.updt_dt_tm,
  r.local_flag
  FROM device d,
   remote_device r
  PLAN (d)
   JOIN (r
   WHERE d.device_cd=r.device_cd
    AND r.exchange > " ")
  ORDER BY d.description
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO

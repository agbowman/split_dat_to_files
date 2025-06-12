CREATE PROGRAM djh_l_remote_device_type_tbl
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
  r.baud_rate, r.data_bits, r.data_type_cd,
  r_data_type_disp = uar_get_code_display(r.data_type_cd), r.device_mode, r.device_type_cd,
  r_device_type_disp = uar_get_code_display(r.device_type_cd), r.line_speed, r.name,
  r.output_format_cd, r_output_format_disp = uar_get_code_display(r.output_format_cd), r.parity,
  r.printer_setup_info, r.remote_dev_type_id, r.resolution,
  r.rowid, r.stop_bit, r.trans_cpi,
  r.trans_lpi, r.updt_applctx, r.updt_cnt,
  r.updt_dt_tm, r.updt_id, r.updt_task
  FROM remote_device_type r
  WITH maxrec = 10, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

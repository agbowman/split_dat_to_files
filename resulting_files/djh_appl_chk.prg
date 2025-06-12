CREATE PROGRAM djh_appl_chk
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
  SET maxsecs = 300
 ENDIF
 SELECT INTO  $OUTDEV
  ac.applctx, ac.application_dir, ac.application_image,
  ac.application_number, ac.application_status, ac.application_version,
  ac.app_ctx_id, ac.authorization_ind, ac.client_node_name,
  ac.client_start_dt_tm, ac.client_tz, ac.default_location,
  ac.device_address, ac.device_location, ac.end_dt_tm,
  ac.logdirectory, ac.name, ac.parms_flag,
  ac.person_id, ac.position_cd, ac_position_disp = uar_get_code_display(ac.position_cd),
  ac.start_dt_tm, ac.tcpip_address, ac.updt_applctx,
  ac.updt_cnt, ac.updt_dt_tm, ac.updt_id,
  ac.updt_task, ac.username
  FROM application_context ac
  PLAN (ac
   WHERE ac.start_dt_tm >= cnvtdatetime(cnvtdate(102807),0)
    AND ac.start_dt_tm <= cnvtdatetime(cnvtdate(102807),235959))
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

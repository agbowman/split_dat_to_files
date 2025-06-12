CREATE PROGRAM bhs_updt_device_phone_loc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Area Code:" = ""
  WITH outdev, area_code
 DECLARE mf_error = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",2205,"ERROR"))
 DECLARE mf_destandphone = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",2205,
   "DESTINATIONANDPHONE"))
 DECLARE ml_debug_flag = i4 WITH protect, constant(validate(bhs_debug_flag,0))
 DECLARE ms_logfile = vc WITH protect, constant(build("bhs_budpl_",format(sysdate,"YYMMDDHHMMSS;;D"),
   ".log"))
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ml_rows_updated = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 IF (validate(mc_status)=0)
  DECLARE mc_status = c1 WITH protect, noconstant("Z")
 ENDIF
 IF (validate(mc_error_msg)=0)
  DECLARE ms_error_msg = vc WITH protect, noconstant(" ")
 ENDIF
 IF (validate(mc_error_reason)=0)
  DECLARE ms_failure_reason = vc WITH protect, noconstant(" ")
 ENDIF
 SET mc_status = "F"
 SET ms_error_msg = " "
 SET ms_failure_reason = " "
 FREE RECORD m_devices
 RECORD m_devices(
   1 qual[*]
     2 f_device_cd = f8
 )
 IF (ml_debug_flag >= 1)
  CALL echo(build("Log file:",ms_logfile))
 ENDIF
 IF (cnvtint( $AREA_CODE) <= 0)
  SET ms_failure_reason = concat("Invalid area code: ",cnvtstring(cnvtint( $AREA_CODE)))
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO value(ms_logfile)
  d.*, rd.*
  FROM session_log sl,
   session_log sl2,
   device d,
   remote_device rd
  PLAN (sl
   WHERE sl.message_cd=mf_error
    AND sl.message_text="The modem returned a NO CARRIER message*")
   JOIN (sl2
   WHERE sl2.session_num=sl.session_num
    AND sl2.message_cd=mf_destandphone
    AND sl2.message_text != "Ad Hoc Fax*"
    AND sl2.message_text != "Auto Fax Station*"
    AND (substring((textlen(sl2.message_text) - 9),3,sl2.message_text)= $AREA_CODE))
   JOIN (d
   WHERE d.name=substring(1,(findstring("     ",sl2.message_text) - 1),sl2.message_text))
   JOIN (rd
   WHERE rd.device_cd=d.device_cd
    AND rd.local_flag != 1)
  WITH nocounter
 ;end select
 IF (error(ms_error_msg,1) != 0)
  SET ms_failure_reason = "Error encountered while logging devices to update"
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  rd.device_cd
  FROM session_log sl,
   session_log sl2,
   device d,
   remote_device rd
  PLAN (sl
   WHERE sl.message_cd=mf_error
    AND sl.message_text="The modem returned a NO CARRIER message*")
   JOIN (sl2
   WHERE sl2.session_num=sl.session_num
    AND sl2.message_cd=mf_destandphone
    AND sl2.message_text != "Ad Hoc Fax*"
    AND sl2.message_text != "Auto Fax Station*"
    AND (substring((textlen(sl2.message_text) - 9),3,sl2.message_text)= $AREA_CODE))
   JOIN (d
   WHERE d.name=substring(1,(findstring("     ",sl2.message_text) - 1),sl2.message_text))
   JOIN (rd
   WHERE rd.device_cd=d.device_cd
    AND rd.local_flag != 1)
  DETAIL
   ml_cnt = (ml_cnt+ 1), stat = alterlist(m_devices->qual,ml_cnt), m_devices->qual[ml_cnt].
   f_device_cd = rd.device_cd
  WITH nocounter
 ;end select
 IF (error(ms_error_msg,1) != 0)
  SET ms_failure_reason = "Error encountered while querying for devices to update"
  GO TO exit_script
 ENDIF
 IF (ml_debug_flag >= 1)
  CALL echo(build("Devices to update: ",size(m_devices->qual,5)))
 ENDIF
 IF (ml_debug_flag >= 10)
  CALL echorecord(m_devices)
 ENDIF
 UPDATE  FROM remote_device rd,
   (dummyt d  WITH seq = size(m_devices->qual,5))
  SET rd.local_flag = 1, rd.updt_cnt = (rd.updt_cnt+ 1), rd.updt_dt_tm = sysdate,
   rd.updt_id = validate(reqinfo->updt_id,0), rd.updt_applctx = validate(reqinfo->updt_applctx,0), rd
   .updt_task = validate(reqinfo->updt_task,0)
  PLAN (d)
   JOIN (rd
   WHERE (rd.device_cd=m_devices->qual[d.seq].f_device_cd))
  WITH nocounter
 ;end update
 SET ml_rows_updated = curqual
 IF (error(ms_error_msg,1) != 0)
  SET ms_failure_reason = "Error encountered while updating REMOTE_DEVICE"
  GO TO exit_script
 ENDIF
 SET mc_status = "S"
#exit_script
 IF (mc_status="S")
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 SELECT INTO value( $OUTDEV)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   ms_line = concat("Script Name:     ",curprog), row 0, col 0,
   ms_line, ms_line = concat("Log File:        ",ms_logfile), row 0,
   col 0, ms_line
   IF (mc_status="S")
    ms_line = concat("Status:          SUCCESS"), row + 1, col 0,
    ms_line, ms_line = concat("Rows sucessfully updated: ",cnvtstring(ml_rows_updated)), row + 1,
    col 0, ms_line
   ELSE
    ms_line = concat("Status:          FAILURE"), row + 1, col 0,
    ms_line, ms_line = concat("Failure Reason:  ",ms_failure_reason), row + 1,
    col 0, ms_line, ms_line = concat("Error Message:   ",ms_error_msg),
    row + 1, col 0, ms_line
   ENDIF
   ms_line = concat("Area Code:       ", $AREA_CODE), row + 2, col 0,
   ms_line, ms_line = concat("Debug Flag:      ",cnvtstring(ml_debug_flag)), row + 1,
   col 0, ms_line
  WITH nocounter, formfeed = none, format = variable,
   maxcol = 200
 ;end select
 FREE RECORD m_devices
END GO

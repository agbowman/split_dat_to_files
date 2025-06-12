CREATE PROGRAM bhs_recorded_height_efc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = curdate,
  "End Date" = curdate
  WITH outdev, p3, p4
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 IF (validate(_separator)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 150
 ENDIF
 SELECT INTO  $OUTDEV
  c.encntr_id, c_event_disp = uar_get_code_display(c.event_cd), performed_dt_tm = format(c
   .performed_dt_tm,"mm/dd/yy hhmm;;d"),
  c.result_val, c_result_units_disp = uar_get_code_display(c.result_units_cd), c.updt_id
  FROM clinical_event c
  PLAN (c
   WHERE c.event_cd=734732
    AND c.performed_dt_tm BETWEEN cnvtdatetime(cnvtdate( $P3),0) AND cnvtdatetime(cnvtdate( $P4),
    235959))
  WITH maxrec = 999999, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

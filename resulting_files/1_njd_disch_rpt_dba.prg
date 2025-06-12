CREATE PROGRAM 1_njd_disch_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 IF (validate(_separator)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  e.encntr_id, e.reg_dt_tm"@MEDIUMDATETIME", e.disch_dt_tm"@MEDIUMDATETIME",
  e.active_ind, e.reason_for_visit
  FROM encounter e
  WHERE e.active_ind=1
   AND e.disch_dt_tm >= cnvtdatetime("01-MAR-2017 00:00:01.00")
   AND e.disch_dt_tm <= cnvtdatetime("31-MAR-2017 23:59:59.00")
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

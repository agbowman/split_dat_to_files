CREATE PROGRAM 1_njd_adm_rpt:dba
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
  WHERE e.reg_dt_tm BETWEEN cnvtdatetime(cnvtdate(010117),000100) AND cnvtdatetime(cnvtdate(022817),
   235959)
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO

CREATE PROGRAM bhs_eks_adt_inp_notc_admitdttm:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encntr ID:" = 0
  WITH outdev, encntrid
 SET retval = 0
 DECLARE mf_encntr_id = f8
 DECLARE log_misc1 = vc WITH noconstant(" ")
 IF (validate(trigger_encntrid)=1)
  SET mf_encntr_id = trigger_encntrid
 ELSE
  SET mf_encntr_id =  $ENCNTRID
 ENDIF
 SELECT INTO "NL:"
  FROM encounter e
  WHERE e.encntr_id=mf_encntr_id
  DETAIL
   log_misc1 = format(cnvtdatetime(e.reg_dt_tm),"MM/DD/YYYY HH:MM;;q"),
   CALL echo(cnvtdatetime(e.reg_dt_tm))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET retval = 100
  SET log_message = build("reg_dt_tm for encntrId:",mf_encntr_id," _ ",log_misc1)
 ELSE
  SET logmisc1 = "(Failed to find Registration date)"
  SET log_message = build("reg_dt_tm for encntrId:",mf_encntr_id," not found")
 ENDIF
 CALL echo(log_message)
 CALL echo(log_misc1)
 CALL echo(build("retval:",retval))
 SELECT INTO  $OUTDEV
  FROM dummyt
  HEAD REPORT
   msg1 =
   IF (textlen(log_misc1) > 0) build("AdmitDtTm:",log_misc1)
   ELSE "No qualifying location found"
   ENDIF
   , col 0, "{PS/792 0 translate 90 rotate/}",
   y_pos = 18, row + 1, "{F/1}{CPI/7}",
   CALL print(calcpos(36,(y_pos+ 0))), msg1, row + 2
  WITH dio = 08
 ;end select
END GO

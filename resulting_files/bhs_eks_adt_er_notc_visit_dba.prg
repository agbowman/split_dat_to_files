CREATE PROGRAM bhs_eks_adt_er_notc_visit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encntr ID:" = 0
  WITH outdev, encntrid
 SET retval = 0
 DECLARE encntr_id = f8
 DECLARE log_misc1 = vc WITH noconstant(" ")
 IF (validate(trigger_encntrid)=1)
  SET encntr_id = trigger_encntrid
 ELSE
  SET encntr_id =  $ENCNTRID
 ENDIF
 SELECT INTO "NL:"
  FROM encounter e
  WHERE e.encntr_id=encntr_id
  DETAIL
   log_misc1 = e.reason_for_visit,
   CALL echo(e.reason_for_visit)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET retval = 100
  SET log_message = build("Reason for Visit for encntrId:",encntr_id," _ ",log_misc1)
 ELSE
  SET logmisc1 = "(Failed to find Reason for Visit)"
  SET log_message = build("disc_dt_tm for encntrId:",encntr_id," not found")
 ENDIF
 CALL echo(log_message)
 CALL echo(log_misc1)
 CALL echo(build("retval:",retval))
 SELECT INTO  $OUTDEV
  FROM dummyt
  HEAD REPORT
   msg1 =
   IF (textlen(log_misc1) > 0) build("Reason for Visit:",log_misc1)
   ELSE "No qualifying reason found"
   ENDIF
   , col 0, "{PS/792 0 translate 90 rotate/}",
   y_pos = 18, row + 1, "{F/1}{CPI/7}",
   CALL print(calcpos(36,(y_pos+ 0))), msg1, row + 2
  WITH dio = 08
 ;end select
END GO

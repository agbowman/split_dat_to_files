CREATE PROGRAM bhs_dvt_risk_flowsheet_rule:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Clinical Event ID of form:" = ""
  WITH outdev, eventid
 SET clinicaleventid = cnvtreal(value( $EVENTID))
 DECLARE log_misc1 = vc WITH noconstant(" ")
 DECLARE log_message = vc WITH noconstant(" ")
 DECLARE refnum = vc WITH noconstant(" ")
 DECLARE encntr_id = f8 WITH noconstant(0.0)
 DECLARE risktype = c20 WITH noconstant(" ")
 DECLARE historyexperienceof = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"HISTORYEXPERIENCEOF"
   )), protect
 DECLARE riskfactorsfordvt = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"RISKFACTORSFORDVT")),
 protect
 SET retval = 0
 SET log_message = "start of bhs_dvt_risk_flowsheet_rule"
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE ce.clinical_event_id=clinicaleventid
  DETAIL
   refnum = substring(1,findstring("!",ce.reference_nbr),ce.reference_nbr), encntr_id = ce.encntr_id
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET log_message = "Filed to find clinical event"
  GO TO exit_script
 ENDIF
 CALL echo(build2("RefNum:",refnum))
 SELECT INTO  $OUTDEV
  ce.*
  FROM clinical_event ce
  WHERE ce.encntr_id=encntr_id
   AND ce.event_cd IN (historyexperienceof, riskfactorsfordvt)
   AND ce.reference_nbr=value(concat(refnum,"*"))
  HEAD ce.event_cd
   CALL echo("####"),
   CALL echo(ce.result_val),
   CALL echo(uar_get_code_display(ce.event_cd)),
   CALL echo(textlen(risktype)),
   CALL echo(risktype)
   IF (ce.event_cd=historyexperienceof
    AND  NOT (cnvtupper(trim(ce.result_val,3)) IN ("NONE", "")))
    risktype = "High risk"
   ELSEIF (ce.event_cd=riskfactorsfordvt
    AND textlen(trim(risktype,3)) <= 0
    AND  NOT (cnvtupper(trim(ce.result_val,3)) IN ("NONE", "")))
    risktype = "Moderate risk"
   ENDIF
  WITH nocounter
 ;end select
 IF (textlen(trim(risktype,3)) <= 0)
  SET risktype = "Low risk"
 ENDIF
 SET log_misc1 = risktype
 SET log_message = risktype
 SET retval = 100
#exit_script
 CALL echo(build(log_message,"  Return Value:",retval))
 CALL echo("exit")
END GO

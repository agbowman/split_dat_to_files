CREATE PROGRAM bhs_dvt_risk_rule:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encounter ID:" = 0
  WITH outdev, encntrid
 DECLARE pharmacologicprophylaxisofdvt = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PHARMACOLOGICPROPHYLAXISOFDVT")), protect
 DECLARE dvtriskassessmentsform = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DVTRISKASSESSMENTSFORM")), protect
 DECLARE authverified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE modified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE log_misc1 = vc WITH noconstant(" ")
 DECLARE log_message = vc WITH noconstant(" ")
 DECLARE encounterid = f8 WITH noconstant(0.0)
 DECLARE historydttm = q8 WITH protect
 DECLARE formdttm = q8 WITH protect
 IF (( $ENCNTRID <= 0))
  SET encounterid = trigger_encntrid
 ELSE
  SET encounterid =  $ENCNTRID
 ENDIF
 CALL echo("Inside bhs_dvt_risk_rule")
 IF (cnvtreal(encounterid) <= 0)
  SET retval = - (1)
  SET log_message = "no encounterId entered. exiting script"
  GO TO exit_script
 ENDIF
 SET retval = 0
 CALL echo(build("historyTime:",format(cnvtdatetime(historydttm),";;q")))
 CALL echo(encounterid)
 CALL echo(pharmacologicprophylaxisofdvt)
 CALL echo(dvtriskassessmentsform)
 SELECT INTO "NL:"
  FROM clinical_event ce
  WHERE ce.encntr_id=encounterid
   AND ce.event_cd IN (pharmacologicprophylaxisofdvt, dvtriskassessmentsform)
   AND ce.result_status_cd IN (authverified, modified)
   AND ce.view_level=1
   AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
  ORDER BY ce.event_cd, ce.clinsig_updt_dt_tm DESC
  HEAD ce.event_cd
   IF (ce.event_cd=pharmacologicprophylaxisofdvt
    AND findstring("SPINAL TAP",cnvtupper(ce.result_val)) > 0)
    historydttm = ce.clinsig_updt_dt_tm
   ELSEIF (ce.event_cd=dvtriskassessmentsform)
    formdttm = ce.clinsig_updt_dt_tm
   ENDIF
   CALL echo(build(ce.event_cd,"  ",ce.result_val))
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET retval = 0
  SET log_message = "Form has NOT been charted on the patient"
  GO TO exit_script
 ELSEIF (historydttm <= 0)
  SET retval = 0
  SET log_message = "last instance of the Form did NOT have Spinal Tap selected"
  GO TO exit_script
 ENDIF
 CALL echo(build("encounterID: ",encounterid))
 CALL echo(build("historyTime:",format(cnvtdatetime(historydttm),";;q")))
 CALL echo(build("FormDtTm:",format(cnvtdatetime(formdttm),";;q")))
 IF (historydttm > 0)
  CALL echo(build("hours since DTA charted:",datetimediff(cnvtdatetime(curdate,curtime),cnvtdatetime(
      historydttm),3)))
  IF (datetimediff(cnvtdatetime(curdate,curtime),cnvtdatetime(historydttm),3) > 12)
   CALL echo("Greater then 12 hour difference")
   CALL echo(build("Time difference(Min) since form was last charted and DTA was charted: ",
     datetimediff(cnvtdatetime(formdttm),cnvtdatetime(historydttm),3)))
   IF (datetimediff(cnvtdatetime(formdttm),cnvtdatetime(historydttm),4) < 3)
    SET retval = 100
    SET log_message = "12 Hours since Spinal Tap DTA charted, form needs to be compleated again. "
   ELSE
    SET log_message = "Spinal Tap DTA charted and DVT form has been completed again. "
   ENDIF
  ELSE
   SET log_message = "It has been less then 12 hours since Spinal Tap DTA was selected. "
  ENDIF
 ENDIF
#exit_script
 CALL echo(build(log_message,"Return Value:",retval))
 CALL echo("exit")
END GO

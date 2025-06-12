CREATE PROGRAM bhs_surgical_notify_frm:dba
 PROMPT
  "outdev" = "MINE",
  "eventid" = ""
  WITH outdev, eventid
 SET clinicaleventid = cnvtreal(value( $EVENTID))
 DECLARE anesthesiareactionpreadmit = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ANESTHESIAREACTIONPREADMIT"))
 DECLARE cardiachistory3preadmit = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CARDIACHISTORY3PREADMIT"))
 DECLARE screenstatus = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"SCREENSTATUS"))
 DECLARE bodymassindex = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"BODYMASSINDEX"))
 DECLARE weight = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT"))
 DECLARE allergies = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ALLERGYLATEX"))
 DECLARE considerneedforisolation = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CONSIDERNEEDFORISOLATION"))
 DECLARE latexallergy = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"LATEXALLERGY"))
 DECLARE bookedsurgicalprocedure = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "BOOKEDSURGICALPROCEDURE"))
 DECLARE interpreterneeded = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INTERPRETERNEEDED"))
 DECLARE inptisolationprecautions = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INPTISOLATIONPRECAUTIONS"))
 DECLARE isolationprecautions = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ISOLATIONPRECAUTIONS"))
 DECLARE preopchecklistform = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PREOPCHECKLISTFORM"))
 DECLARE authverified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE modified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mrn = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE homephone = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"HOME"))
 DECLARE homeaddress = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",212,"HOME"))
 DECLARE attdoc = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE active = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE bfmc = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE FRANKLIN MEDICAL CENTER"))
 DECLARE bmc = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,"BAYSTATE MEDICAL CENTER")
  )
 DECLARE bmlh = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MARY LANE HOSPITAL"))
 DECLARE bwh = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,"BAYSTATE WING HOSPITAL"))
 DECLARE bnh = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,"BAYSTATE NOBLE HOSPITAL")
  )
 DECLARE mock = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "MOCK - BAYSTATE HEALTH SYSTEM"))
 DECLARE tempaddress = vc WITH noconstant(" ")
 DECLARE tempreason = vc WITH noconstant(" ")
 DECLARE tempreasonresults = vc WITH noconstant(" ")
 DECLARE encntrid = f8 WITH noconstant(0.0)
 DECLARE outprinterloc = f8 WITH noconstant(0.0)
 DECLARE refnbr = vc WITH noconstant(" ")
 DECLARE reffrmtype = f8 WITH noconstant(0.0)
 DECLARE wait_ind = i2 WITH noconstant(3)
 WHILE (wait_ind > 0)
  SELECT INTO "NL:"
   FROM clinical_event ce,
    encounter e
   PLAN (ce
    WHERE ce.clinical_event_id=clinicaleventid
     AND ce.clinical_event_id > 0)
    JOIN (e
    WHERE e.encntr_id=ce.encntr_id)
   DETAIL
    encntrid = ce.encntr_id, refnbr = build(trim(substring(0,(findstring("!0",ce.reference_nbr,1) - 1
       ),ce.reference_nbr),3),"*"), reffrmtype = ce.event_cd,
    outprinterloc = e.loc_facility_cd
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   SET log_message = build2("term not found for event_id ",cnvtstring(clinicaleventid)," WaitInd=",
    wait_ind)
   SET wait_ind = (wait_ind - 1)
   CALL pause(1)
  ELSE
   SET log_message = build2("term  found for clinical_event_id ",cnvtstring(clinicaleventid))
   SET wait_ind = 0
  ENDIF
 ENDWHILE
 IF (curqual <= 0)
  SET log_message = build2("failed to find CE row(clinical_event_id):",cnvtstring(clinicaleventid),
   "R",refnbr,"E",
   encntrid,"Q", $EVENTID)
  CALL echo(log_message)
  GO TO exit_script
 ELSEIF (textlen(trim(refnbr,3)) <= 1)
  SET log_message = build2("Failed to find form RefNumber(clinical_event_id):",cnvtstring(
    clinicaleventid),"R",refnbr,"E",
   encntrid,"E", $EVENTID)
  CALL echo(log_message)
  GO TO exit_script
 ENDIF
 RECORD results(
   1 qual[1]
     2 printer = c25
     2 title = vc
     2 dttm = c30
     2 patientname = c50
     2 address = vc
     2 phone = vc
     2 mrn = vc
     2 dob = vc
     2 proceduredt = c30
     2 procedure = vc
     2 surgeon = c50
     2 reasons = vc
     2 reasonresults = vc
 )
 CALL echo(refnbr)
 CALL echo(encntrid)
 SELECT INTO "NL:"
  FROM clinical_event ce,
   person p,
   encounter e,
   encntr_alias ea,
   phone ph,
   address a,
   encntr_prsnl_reltn epr,
   prsnl prl
  PLAN (ce
   WHERE ce.encntr_id=encntrid
    AND ((ce.reference_nbr=patstring(refnbr)
    AND ce.event_cd IN (anesthesiareactionpreadmit, cardiachistory3preadmit, screenstatus,
   bodymassindex, weight,
   bookedsurgicalprocedure, considerneedforisolation, inptisolationprecautions, interpreterneeded,
   isolationprecautions)) OR (reffrmtype=preopchecklistform
    AND ce.event_cd IN (anesthesiareactionpreadmit, cardiachistory3preadmit, screenstatus,
   bodymassindex, weight,
   bookedsurgicalprocedure, considerneedforisolation)))
    AND ce.view_level=1
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.result_status_cd IN (authverified, modified))
   JOIN (p
   WHERE p.person_id=ce.person_id)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id)
   JOIN (ea
   WHERE ea.encntr_id=ce.encntr_id
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=mrn)
   JOIN (ph
   WHERE ph.parent_entity_name="PERSON"
    AND ph.parent_entity_id=p.person_id
    AND ph.phone_type_cd=homephone
    AND ph.active_ind=1
    AND ph.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ph.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (a
   WHERE a.parent_entity_name="PERSON"
    AND a.parent_entity_id=p.person_id
    AND a.address_type_cd=homeaddress
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (epr
   WHERE epr.encntr_id=outerjoin(ce.encntr_id)
    AND epr.encntr_prsnl_r_cd=outerjoin(attdoc)
    AND epr.active_status_cd=outerjoin(active)
    AND ((epr.beg_effective_dt_tm+ 0) <= outerjoin(cnvtdatetime(curdate,curtime)))
    AND ((epr.end_effective_dt_tm+ 0) > outerjoin(cnvtdatetime(curdate,curtime))))
   JOIN (prl
   WHERE prl.person_id=epr.prsnl_person_id)
  HEAD p.person_id
   tempaddress = build(trim(a.street_addr,3),char(222),trim(a.street_addr2,3),char(222),trim(a
     .street_addr3,3),
    char(222),trim(a.street_addr4,3),char(222),char(13),trim(a.city,3),
    ",",trim(a.state,3)," ",trim(a.zipcode,3)), tempaddress = replace(tempaddress,build(char(222),
     char(222)),""), tempaddress = replace(tempaddress,build(char(222),char(13)),char(13)),
   tempaddress = replace(tempaddress,build(char(222)),char(13)), results->qual[1].title =
   "Surgical Notification Form", results->qual[1].dttm = format(cnvtdatetime(curdate,curtime3),
    "MM/DD/YYYY HH:MM;;q"),
   results->qual[1].patientname = substring(0,50,p.name_full_formatted), results->qual[1].address =
   tempaddress, results->qual[1].phone = trim(ph.phone_num,3),
   results->qual[1].mrn = ea.alias, results->qual[1].dob = format(cnvtdatetime(p.birth_dt_tm),
    "MM/DD/YYYY HH:MM;;q"), results->qual[1].proceduredt = format(cnvtdatetime(e.est_arrive_dt_tm),
    "MM/DD/YYYY HH:MM;;q"),
   results->qual[1].surgeon = substring(0,50,prl.name_full_formatted)
  HEAD ce.event_cd
   IF (ce.event_cd=anesthesiareactionpreadmit)
    tempreason = build(tempreason,"Anesthesia Reaction:")
    IF (findstring("DIF",cnvtupper(ce.result_val)) > 0)
     tempreasonresults = build(tempreasonresults,"Difficult intubation",char(13)), tempreason = build
     (tempreason,char(13))
    ENDIF
    IF (findstring("MAL",cnvtupper(ce.result_val)) > 0)
     tempreasonresults = build(tempreasonresults,"Malignant hypothermia",char(13)), tempreason =
     build(tempreason,char(13))
    ENDIF
   ELSEIF (ce.event_cd=cardiachistory3preadmit)
    tempreason = build(tempreason,"Cardiac history 3:")
    IF (findstring("PACEMAKER",cnvtupper(ce.result_val)) > 0)
     tempreasonresults = build(tempreasonresults,"Pacemaker",char(13)), tempreason = build(tempreason,
      char(13))
    ENDIF
    IF (findstring("DEFIBRI",cnvtupper(ce.result_val)) > 0)
     tempreasonresults = build(tempreasonresults,"Defibrilator",char(13)), tempreason = build(
      tempreason,char(13))
    ENDIF
   ELSEIF (ce.event_cd=screenstatus)
    IF (findstring("UNABLE",cnvtupper(ce.result_val)) > 0)
     tempreason = build(tempreason,"Screen Status:",char(13)), tempreasonresults = build(
      tempreasonresults,"Unable to reach",char(13))
    ENDIF
   ELSEIF (ce.event_cd=bodymassindex)
    IF (cnvtreal(ce.result_val) > 40)
     tempreason = build(tempreason,"Body Mass Index:",char(13)), tempreasonresults = build(
      tempreasonresults,"Greater than 40",char(13))
    ENDIF
   ELSEIF (ce.event_cd=weight)
    IF (cnvtreal(ce.result_val) > 136.09
     AND e.loc_facility_cd=bfmc)
     tempreason = build(tempreason,"Weight:",char(13)), tempreasonresults = build(tempreasonresults,
      "Greater than 300",char(13))
    ELSEIF (cnvtreal(ce.result_val) > 158.77)
     tempreason = build(tempreason,"Weight:",char(13)), tempreasonresults = build(tempreasonresults,
      "Greater than 350",char(13))
    ENDIF
   ELSEIF (ce.event_cd=considerneedforisolation)
    tempreason = build(tempreason,"Consider Need for isolation:",char(13)), tempreasonresults = build
    (tempreasonresults,trim(ce.result_val,3),char(13))
   ELSEIF (ce.event_cd=bookedsurgicalprocedure)
    results->qual[1].procedure = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=inptisolationprecautions
    AND trim(ce.result_val,3) != "N/A")
    tempreason = build(tempreason,"INPT Isolation Precautions:"), tempreasonresults = build(
     tempreasonresults,ce.result_val,char(13)), tempreason = build(tempreason,char(13))
   ELSEIF (ce.event_cd=isolationprecautions
    AND trim(ce.result_val,3) != "N/A")
    tempreason = build(tempreason,"Isolation Precautions:"), tempreasonresults = build(
     tempreasonresults,ce.result_val,char(13)), tempreason = build(tempreason,char(13))
   ENDIF
   IF (ce.event_cd=interpreterneeded)
    tempreason = build(tempreason,"Book interpreter for surgery:")
    IF (findstring("YES",cnvtupper(ce.result_val)) > 0)
     tempreasonresults = build(tempreasonresults,"Yes",char(13)), tempreason = build(tempreason,char(
       13))
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET log_message = build2("Failed to find form data(clinical_event_id):",clinicaleventid,"R",refnbr,
   "E",
   encntrid,"Q", $EVENTID)
  CALL echo(log_message)
  GO TO exit_script
 ENDIF
 CALL echo(build("tempReasonResults:",tempreasonresults))
 SET results->qual[1].reasons = tempreason
 SET results->qual[1].reasonresults = tempreasonresults
 CALL echorecord(results)
 CALL echo("calling layout program")
 IF (( $OUTDEV != "NL:"))
  EXECUTE bhs_surgical_notify_frm_layout  $OUTDEV
  CALL echo("screen or printer out")
 ELSEIF (outprinterloc=bmc)
  EXECUTE bhs_surgical_notify_frm_layout "bmcwh1ascpodn"
  CALL echo("printBMC")
 ELSEIF (outprinterloc=bmlh)
  EXECUTE bhs_surgical_notify_frm_layout "mlhdv2surg1"
  CALL echo("printBMLH")
 ELSEIF (outprinterloc=bfmc)
  CALL echo("printBFMC")
  EXECUTE bhs_surgical_notify_frm_layout "fmcfl1sau1"
  EXECUTE bhs_surgical_notify_frm_layout "fmcfl1surg1"
 ELSEIF (outprinterloc=bwh)
  EXECUTE bhs_surgical_notify_frm_layout ""
  CALL echo("PrintBWH")
 ELSEIF (outprinterloc=bnh)
  EXECUTE bhs_surgical_notify_frm_layout ""
  CALL echo("PrintBNH")
 ELSEIF (outprinterloc=mock)
  EXECUTE bhs_surgical_notify_frm_layout "bisis1canon1"
  CALL echo("PrintMock")
 ENDIF
 CALL echo("finishing layout program")
 SET retval = 100
 SET log_message = build2("Form Printed for clinical_event_id:",trim(cnvtstring(cnvtreal(
     clinicaleventid)),3),"  PrinterLoc:",uar_get_code_display(outprinterloc))
 CALL echo(log_message)
#exit_script
END GO

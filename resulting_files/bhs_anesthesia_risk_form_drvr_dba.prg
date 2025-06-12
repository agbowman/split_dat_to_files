CREATE PROGRAM bhs_anesthesia_risk_form_drvr:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "eventid:" = 0,
  "Output type (form / spreadsheet):" = ""
  WITH outdev, eventid, outputtype
 DECLARE bookedsurgprocedure = vc WITH constant("BOOKED_SURGICAL_PROCEDURE")
 DECLARE consultto = vc WITH constant("CONSULT_TO")
 DECLARE listofquestionscon = vc WITH constant("LIST_SPECIFIC_QUESTIONS_CONSULT")
 DECLARE othernotification = vc WITH constant("OTHER_ISSUES_NOTIFICATION")
 DECLARE historyairwaynote = vc WITH constant("HISTORY_DIFFICULT_AIRWAY_NOTIFICATION")
 DECLARE suspicionairwaynote = vc WITH constant("SUSPICION_DIFFICULT_AIRWAY_NOTIFICATION")
 DECLARE bloodproductspreop = vc WITH constant("BLOOD_PRODUCTS_PREOPERATIVE")
 DECLARE pthistcarddisease = vc WITH constant("PT_HISTORY_CARDIAC_DISEASE")
 DECLARE aorticstenosismod = vc WITH constant("AORTIC_STENOSIS_MODERATE")
 DECLARE aorticstenosissev = vc WITH constant("AORTIC_STENOSIS_SEVERE")
 DECLARE othercardiachistory = vc WITH constant("OTHER_CARDIAC_HISTORY")
 DECLARE difficultivaccess = vc WITH constant("DIFFICULT_IV_ACCESS")
 DECLARE mentallychallenged = vc WITH constant("MENTALLY_CHALLENGED")
 DECLARE floormgrnotrify1 = vc WITH constant("FLOOR_MANAGER_NOTIFICATION_FORM")
 DECLARE highrisknotify1 = vc WITH constant("HIGH_RISK_NOTIFICATION_FORM")
 DECLARE highriskconsult1 = vc WITH constant("HIGH_RISK_CONSULT_FORM")
 DECLARE mrn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"MRN")), protect
 DECLARE attdoc = f8 WITH constant(uar_get_code_by("MEANING",333,"ATTENDDOC")), protect
 DECLARE pcp = f8 WITH constant(uar_get_code_by("MEANING",333,"PCP")), protect
 DECLARE signeventcd = f8 WITH constant(uar_get_code_by("meaning",21,"SIGN")), protect
 DECLARE completedeventcd = f8 WITH constant(uar_get_code_by("meaning",103,"COMPLETED")), protect
 DECLARE consultformind = i2 WITH noconstant(0)
 DECLARE floormgrnotify = i2 WITH noconstant(0)
 DECLARE consultlist = vc
 DECLARE notifylist = vc
 DECLARE scdstoryid = f8 WITH noconstant(0.0)
 RECORD results(
   1 qual[*]
     2 title = vc
     2 surgerydt = c30
     2 patientname = c50
     2 mrn = vc
     2 age = c30
     2 procedure = vc
     2 surgeon = c50
     2 pcp = c50
     2 consulttxt = c80
     2 consultto = c50
     2 listofquestions = vc
     2 pae = vc
     2 paedt = c30
     2 event_id = f8
 )
 SET stat = alterlist(results->qual,1)
 SET results->qual[1].surgerydt = fillstring(30,"_")
 SET results->qual[1].patientname = fillstring(30,"_")
 SET results->qual[1].mrn = fillstring(30,"_")
 SET results->qual[1].age = fillstring(30,"_")
 SET results->qual[1].surgeon = fillstring(30,"_")
 SET results->qual[1].pcp = fillstring(30,"_")
 SELECT INTO "NL:"
  FROM scd_story ss,
   person p,
   prsnl prattd,
   prsnl prpcp,
   encntr_prsnl_reltn eprattd,
   encntr_prsnl_reltn eprpcp,
   encounter e,
   encntr_alias ea,
   scd_term st,
   scr_term_text stt,
   scd_term_data std,
   long_blob lb,
   scd_blob sb,
   clinical_event ce
  PLAN (ss
   WHERE ss.event_id=value( $EVENTID))
   JOIN (p
   WHERE ss.person_id=p.person_id)
   JOIN (e
   WHERE e.encntr_id=ss.encounter_id)
   JOIN (ea
   WHERE ea.encntr_id=ss.encounter_id
    AND ea.encntr_alias_type_cd=mrn)
   JOIN (eprattd
   WHERE eprattd.encntr_id=outerjoin(ea.encntr_id)
    AND eprattd.encntr_prsnl_r_cd=outerjoin(attdoc)
    AND eprattd.active_ind=outerjoin(1)
    AND ((eprattd.beg_effective_dt_tm+ 0) <= outerjoin(cnvtdatetime(curdate,curtime3)))
    AND ((eprattd.end_effective_dt_tm+ 0) > outerjoin(cnvtdatetime(curdate,curtime3))))
   JOIN (prattd
   WHERE prattd.person_id=outerjoin(eprattd.prsnl_person_id))
   JOIN (eprpcp
   WHERE eprpcp.encntr_id=outerjoin(ea.encntr_id)
    AND eprpcp.encntr_prsnl_r_cd=outerjoin(pcp)
    AND eprattd.active_ind=outerjoin(1)
    AND ((eprattd.beg_effective_dt_tm+ 0) <= outerjoin(cnvtdatetime(curdate,curtime3)))
    AND ((eprattd.end_effective_dt_tm+ 0) > outerjoin(cnvtdatetime(curdate,curtime3))))
   JOIN (prpcp
   WHERE prpcp.person_id=outerjoin(eprattd.prsnl_person_id))
   JOIN (st
   WHERE st.scd_story_id=ss.scd_story_id)
   JOIN (stt
   WHERE stt.scr_term_id=st.scr_term_id
    AND stt.definition IN (floormgrnotrify1, highriskconsult1, othernotification, bookedsurgprocedure,
   consultto,
   listofquestionscon, historyairwaynote, suspicionairwaynote, bloodproductspreop, pthistcarddisease,
   aorticstenosismod, aorticstenosissev, difficultivaccess, mentallychallenged, othercardiachistory))
   JOIN (std
   WHERE std.scd_term_data_id=outerjoin(st.scd_term_data_id))
   JOIN (lb
   WHERE lb.parent_entity_id=outerjoin(std.fkey_id)
    AND std.fkey_id > outerjoin(0.00)
    AND cnvtupper(lb.parent_entity_name)=outerjoin("SCD_BLOB"))
   JOIN (sb
   WHERE sb.scd_blob_id=outerjoin(lb.parent_entity_id))
   JOIN (ce
   WHERE ce.event_id=outerjoin(std.fkey_id))
  HEAD ss.event_id
   scdstoryid = ss.scd_story_id, results->qual[1].event_id = ss.event_id, results->qual[1].surgerydt
    = format(cnvtdatetime(e.est_arrive_dt_tm),"MM/DD/YY HH:MM;;q"),
   results->qual[1].patientname = trim(p.name_full_formatted), results->qual[1].mrn = trim(ea.alias),
   results->qual[1].age = replace(cnvtage(p.birth_dt_tm),"0123456789","0123456789",3),
   results->qual[1].surgeon = trim(prattd.name_full_formatted), results->qual[1].pcp = trim(prpcp
    .name_full_formatted)
   IF (trim(results->qual[1].surgerydt,3)="")
    results->qual[1].surgerydt = fillstring(30,"_")
   ENDIF
   IF (trim(results->qual[1].patientname,3)="")
    results->qual[1].patientname = fillstring(30,"_")
   ENDIF
   IF (trim(results->qual[1].mrn,3)="")
    results->qual[1].mrn = fillstring(30,"_")
   ENDIF
   IF (trim(results->qual[1].age,3)="")
    results->qual[1].age = fillstring(30,"_")
   ENDIF
   IF (trim(results->qual[1].surgeon,3)="")
    results->qual[1].surgeon = fillstring(30,"_")
   ENDIF
   IF (trim(results->qual[1].pcp,3)="")
    results->qual[1].pcp = fillstring(30,"_")
   ENDIF
   results->qual[1].procedure = fillstring(30,"_"), results->qual[1].consultto = fillstring(30,"_")
  DETAIL
   IF (stt.definition=bookedsurgprocedure)
    IF (ce.event_id > 0
     AND size(trim(ce.result_val,3)) > 0)
     results->qual[1].procedure = trim(ce.result_val)
    ENDIF
   ELSEIF (stt.definition IN (othernotification, listofquestionscon, othercardiachistory)
    AND size(trim(lb.long_blob,3)) > 0)
    CALL echo(lb.long_blob), tempblob = lb.long_blob, tempblob = replace(tempblob,"\pard","~!~!"),
    tempblob = replace(tempblob,"\par","|\par"), tempblob = replace(tempblob,"~!~!","\pard"),
    blob_out = fillstring(32000," "),
    CALL uar_rtf(tempblob,size(lb.long_blob),blob_out,32000,32000,0), blob_out = replace(blob_out,"|",
     char(13))
    IF (stt.definition=listofquestionscon)
     consultlist = concat(trim(blob_out,3),char(13),
      "_______________________________________________________")
    ELSE
     IF (size(notifylist) > 0)
      notifylist = concat(notifylist,char(13),trim(blob_out,3))
     ELSE
      notifylist = concat(trim(blob_out,3),char(13))
     ENDIF
    ENDIF
   ELSEIF (stt.definition IN (historyairwaynote, suspicionairwaynote, bloodproductspreop,
   pthistcarddisease, aorticstenosismod,
   aorticstenosissev, difficultivaccess, mentallychallenged))
    IF (size(notifylist) > 0)
     notifylist = concat(trim(stt.text_representation,3),char(13),notifylist)
    ELSE
     notifylist = trim(stt.text_representation,3)
    ENDIF
   ELSEIF (stt.definition=consultto)
    IF (size(trim(std.value_text,3)) > 0)
     results->qual[1].consultto = trim(std.value_text)
    ENDIF
   ELSEIF (stt.definition=highriskconsult1)
    consultformind = 1
   ELSEIF (stt.definition=floormgrnotrify1)
    floormgrnotify = 1
   ENDIF
  FOOT  ss.event_id
   IF (size(consultlist) <= 0)
    consultlist = concat("__________________________________________________________",char(13),
     "__________________________________________________________",char(13),
     "__________________________________________________________",
     char(13),"__________________________________________________________")
   ENDIF
   IF (size(notifylist) <= 0)
    notifylist = concat("__________________________________________________________",char(13),
     "__________________________________________________________",char(13),
     "__________________________________________________________",
     char(13),"__________________________________________________________")
   ENDIF
  WITH nocounter
 ;end select
 SET notifylist = concat(notifylist,char(13),
  "_______________________________________________________")
 SELECT INTO "NL:"
  FROM ce_event_prsnl cep,
   person p
  PLAN (cep
   WHERE cep.event_id=value( $EVENTID)
    AND cep.valid_until_dt_tm >= cnvtdatetime("31-DEC-2100")
    AND ((cep.action_type_cd+ 0)=signeventcd)
    AND ((cep.action_status_cd+ 0)=completedeventcd))
   JOIN (p
   WHERE p.person_id=cep.action_prsnl_id)
  ORDER BY cep.action_dt_tm DESC
  HEAD cep.event_id
   results->qual[1].pae = trim(p.name_full_formatted), results->qual[1].paedt = format(cnvtdatetime(
     cep.action_dt_tm),"MM/DD/YY HH:MM;;q")
  WITH nocounter
 ;end select
 IF (curqual > 0)
  IF (( $OUTPUTTYPE="spreadsheet"))
   SELECT INTO value( $OUTDEV)
    surgerydt = results->qual[1].surgerydt, patientname = results->qual[1].patientname, mrn = results
    ->qual[1].mrn,
    age = results->qual[1].age, surgeon = results->qual[1].surgeon, pcp = results->qual[1].pcp,
    procedure = results->qual[1].procedure, listofquestions = results->qual[1].listofquestions,
    consultto = results->qual[1].consultto,
    event_id = results->qual[1].event_id
    FROM (dummyt d2  WITH seq = 1)
    PLAN (d2)
    WITH nocounter, format, separator = " ",
     nullreport
   ;end select
  ELSE
   IF (floormgrnotify=1)
    SET results->qual[1].listofquestions = notifylist
    SET results->qual[1].title = "Floor Manager Notification"
    SET results->qual[1].consultto = ""
    SET results->qual[1].consulttxt = ""
    IF (( $OUTDEV="printer"))
     EXECUTE bhs_anesthesia_risk_form "bmcchgsurg2",  $EVENTID
     EXECUTE bhs_anesthesia_risk_form "bmcchgsurg2",  $EVENTID
    ELSE
     EXECUTE bhs_anesthesia_risk_form  $OUTDEV,  $EVENTID
    ENDIF
   ENDIF
   CALL echo(build("consultFormInd:",consultformind))
   IF (consultformind=1)
    CALL echo("executing consult form")
    SET results->qual[1].listofquestions = consultlist
    SET results->qual[1].title = "Anesthesia High Risk"
    SET results->qual[1].consulttxt = "Consult to (specify only if consult indicated):"
    IF (( $OUTDEV="printer"))
     EXECUTE bhs_anesthesia_risk_form "bmcchgsurg2",  $EVENTID
     EXECUTE bhs_anesthesia_risk_form "bmcchgsurg2",  $EVENTID
    ELSE
     EXECUTE bhs_anesthesia_risk_form  $OUTDEV,  $EVENTID
    ENDIF
   ENDIF
  ENDIF
 ENDIF
END GO

CREATE PROGRAM bhs_eks_nurse_witness5_13_2011:dba
 PROMPT
  "RuleCallType:" = "DISCERN"
  WITH ruletype
 DECLARE log_message = vc WITH noconstant(" ")
 DECLARE log_misc1 = vc WITH noconstant(" ")
 DECLARE retval = i4 WITH noconstant(0)
 DECLARE subject = vc WITH noconstant(" ")
 DECLARE body = vc WITH noconstant(" ")
 DECLARE inboxoutput = vc WITH noconstant(" ")
 DECLARE formname = vc WITH noconstant(" ")
 DECLARE nursewitnessid = f8
 DECLARE nursewitnessperformedby = f8
 DECLARE nurseattuser = f8
 DECLARE encntrid = f8
 DECLARE personid = f8
 DECLARE sendalert = i4
 DECLARE sendalertpharmacy = i4
 DECLARE alertjengroup = i4
 DECLARE alertpharmgroup = i4
 DECLARE alertorgnurse = i4
 DECLARE transfusiontagform = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"TRANSFUSIONTAGFORM"
   )), protect
 DECLARE narcoticinfandaccounabilitybhs = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "NARCOTICINFANDACCOUNABILITYBHS")), protect
 DECLARE narcoticpatchandaccountabilityform = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "NARCOTICPATCHANDACCOUNTABILITYFORM")), protect
 DECLARE autotransfusionbloodrecoveryform = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "AUTOTRANSFUSIONBLOODRECOVERYFORM")), protect
 DECLARE nursewitness = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"NURSEWITNESS")), protect
 DECLARE nursewitnesstransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "NURSEWITNESSTRANSFUSION")), protect
 DECLARE nursestatementofattestation = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "NURSESTATEMENTOFATTESTATION")), protect
 DECLARE patchappliedtime = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"PATCHAPPLIEDTIME")),
 protect
 DECLARE patchremovaltime = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"PATCHREMOVALTIME")),
 protect
 DECLARE infusionstarttime = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"INFUSIONSTARTTIME")),
 protect
 DECLARE bloodproducttransfused = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "BLOODPRODUCTTRANSFUSED")), protect
 DECLARE chartingreason = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"CHARTINGREASON")),
 protect
 DECLARE finnbr = f8 WITH constant(validatecodevalue("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE authverified = f8 WITH constant(validatecodevalue("MEANING",8,"AUTH")), protect
 DECLARE altered = f8 WITH constant(validatecodevalue("MEANING",8,"MODIFIED")), protect
 DECLARE modified = f8 WITH constant(validatecodevalue("MEANING",8,"ALTERED")), protect
 DECLARE bloodbankproduct = f8 WITH constant(validatecodevalue("DISPLAYKEY",106,"BLOODBANKPRODUCT")),
 protect
 FREE RECORD eventinfo
 RECORD eventinfo(
   1 clinical_event_id = f8
   1 parent_event_id = f8
   1 formname = vc
   1 formtype = f8
   1 refid = vc
   1 witness_id = vc
   1 performedby_id = vc
   1 performedby_en = vc
   1 performedby_prsnl_id = f8
   1 performeddttm = vc
   1 result_stats_cd = f8
   1 attestation_witness_id = vc
   1 attesttion_witness_en = vc
   1 attesttion_witness_pid = f8
   1 attestationthisevent = i4
   1 attestationnotwitnessed = i4
   1 attesttion_correctuserpostion = i4
   1 patchremovedthisevent = i4
   1 witnessfldfilledoutthisevent = i4
   1 infusiontime = vc
   1 patchapplieddttm = vc
   1 patchremoveddttm = vc
   1 log_message = vc
   1 name = vc
   1 nurseunit = vc
   1 fin = vc
   1 orderdttm = vc
   1 orderdisp = vc
   1 display_line = vc
   1 orderdisp_status = vc
   1 donotsendalert = i4
   1 donotsendalert = i4
   1 donotsendalerts = i4
 )
 SET log_message = "start of bhs_eks_nurse_witness"
 SET retval = 0
 IF (( $RULETYPE="DISCERN"))
  FREE RECORD request
  RECORD request(
    1 clin_detail_list[1]
      2 clinical_event_id = f8
  )
  SET request->clin_detail_list[1].clinical_event_id = 870255853
 ELSEIF (( $RULETYPE="TIMER"))
  SET fifteenminago = cnvtlookbehind("7,MIN",cnvtdatetime((curdate - 1),curtime))
  SET fiveminpast = cnvtlookahead("5,MIN",cnvtdatetime((curdate - 1),curtime))
  SET log_message = concat(log_message,"fifteenMinAgo:",format(cnvtdatetime(fifteenminago),";;q"))
  FREE RECORD request
  RECORD request(
    1 clin_detail_list[*]
      2 clinical_event_id = f8
  )
  SELECT INTO "NL:"
   ce.clinical_event_id
   FROM clinical_event ce
   PLAN (ce
    WHERE ce.encntr_id=link_encntrid
     AND ce.event_cd IN (transfusiontagform, autotransfusionbloodrecoveryform,
    narcoticinfandaccounabilitybhs, narcoticpatchandaccountabilityform)
     AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
     AND ce.result_status_cd IN (authverified, altered, modified)
     AND ce.performed_dt_tm BETWEEN cnvtdatetime(fifteenminago) AND cnvtdatetime(fiveminpast))
   ORDER BY ce.clinical_event_id
   HEAD REPORT
    cnt = 0
   HEAD ce.clinical_event_id
    cnt = (cnt+ 1), stat = alterlist(request->clin_detail_list,cnt), request->clin_detail_list[cnt].
    clinical_event_id = ce.clinical_event_id,
    log_message = concat(log_message,"formFound:",uar_get_code_display(ce.event_cd))
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   SET log_message = concat(log_message,"!!!_No Form Found Timer Rule !!!")
   GO TO exit_program
  ENDIF
 ENDIF
 CALL echo(log_message)
 CALL echo( $RULETYPE)
 IF (size(request->clin_detail_list,5) <= 0)
  SET log_message = concat(log_message," No Request->clin_detail_list found ")
  GO TO exit_program
 ENDIF
 CALL echo("Request values found")
 SET cnt = 0
 CALL echo(
  "find form data - parent ID represents the ID of this form the RefNumber Represents this instance of the form"
  )
 SELECT
  *
  FROM clinical_event ce,
   (dummyt d  WITH seq = size(request->clin_detail_list,5))
  PLAN (d)
   JOIN (ce
   WHERE (ce.clinical_event_id=request->clin_detail_list[d.seq].clinical_event_id)
    AND ce.event_cd IN (transfusiontagform, autotransfusionbloodrecoveryform,
   narcoticinfandaccounabilitybhs, narcoticpatchandaccountabilityform))
  ORDER BY ce.clinical_event_id
  HEAD REPORT
   IF ( NOT (ce.event_cd IN (transfusiontagform, autotransfusionbloodrecoveryform)))
    sendalertpharmacy = 1
   ENDIF
  HEAD ce.clinical_event_id
   encntrid = ce.encntr_id, personid = ce.person_id, eventinfo->clinical_event_id = ce
   .clinical_event_id,
   eventinfo->parent_event_id = ce.event_id, eventinfo->formname = uar_get_code_display(ce.event_cd),
   eventinfo->formtype = ce.event_cd,
   eventinfo->result_stats_cd = ce.result_status_cd, refstart = (findstring("!",ce.reference_nbr,1)+
   1), refend = (findstring("!",ce.reference_nbr,refstart) - 1),
   reflen = (refend - refstart),
   CALL echo(build(refstart,":",refend,":",reflen)), eventinfo->refid = concat("*",trim(substring(
      refstart,reflen,ce.reference_nbr),3),"*")
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET log_message = concat(log_message,"!!!_No Form Found !!!")
  GO TO exit_program
 ENDIF
 SET log_message = concat(log_message,"!!!Form Found !!! Form clin_event_id: ",build(eventinfo->
   clinical_event_id)," ")
 CALL echo(encntrid)
 CALL echorecord(eventinfo)
 CALL echo("find the dtas that were charted on this instance of the form")
 SELECT
  ce.event_cd, ce.event_end_dt_tm
  FROM clinical_event ce,
   prsnl p,
   ce_date_result cedr
  PLAN (ce
   WHERE ce.encntr_id=encntrid
    AND operator(ce.reference_nbr,"like",patstring(eventinfo->refid,1))
    AND ce.result_status_cd IN (authverified, altered, modified)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce.event_cd IN (nursewitness, nursewitnesstransfusion, nursestatementofattestation,
   patchremovaltime, patchappliedtime,
   infusionstarttime, chartingreason))
   JOIN (cedr
   WHERE cedr.event_id=outerjoin(ce.event_id)
    AND cedr.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime)))
   JOIN (p
   WHERE p.person_id=outerjoin(ce.performed_prsnl_id))
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  HEAD ce.event_cd
   IF (ce.event_cd IN (nursewitness, nursewitnesstransfusion))
    eventinfo->witness_id = ce.result_val, eventinfo->witnessfldfilledoutthisevent = 1
   ELSEIF (ce.event_cd=nursestatementofattestation)
    IF (cnvtupper(ce.result_val) IN ("NOT WITNESSED*"))
     eventinfo->attestationnotwitnessed = 1
    ENDIF
    eventinfo->attestation_witness_id = trim(p.name_full_formatted,3), eventinfo->
    attesttion_witness_en = trim(p.username,3), eventinfo->attesttion_witness_pid = p.person_id,
    eventinfo->attestationthisevent = 1
   ELSEIF (ce.event_cd=patchremovaltime)
    eventinfo->patchremoveddttm = format(cnvtdatetime(cedr.result_dt_tm),";;q"), eventinfo->
    patchremovedthisevent = 1
   ELSEIF (ce.event_cd=infusionstarttime)
    eventinfo->infusiontime = format(cnvtdatetime(cedr.result_dt_tm),";;q")
   ELSEIF (ce.event_cd=patchappliedtime)
    eventinfo->patchapplieddttm = format(cnvtdatetime(cedr.result_dt_tm),";;q")
   ELSEIF (ce.event_cd=chartingreason
    AND cnvtupper(trim(ce.event_tag,3)) IN ("*4 HOUR CHECK*", "*CLINICIAN DOSE*"))
    eventinfo->donotsendalerts = 1
   ENDIF
  WITH nocounter
 ;end select
 IF ((eventinfo->donotsendalerts=1))
  SET log_message = concat(log_message,"!!! Do Not Send alert 4 hour event !!!")
  GO TO exit_program
 ELSE
  SET log_message = concat(log_message,"!!! passed find DTAs on this instance of the form !!!")
 ENDIF
 CALL echorecord(eventinfo)
 CALL echo(
  "find dta's that were charted on this powerForm but not this specific instance(going by parent_id)"
  )
 IF ((eventinfo->result_stats_cd IN (altered, modified)))
  SET refidtemp = eventinfo->refid
  SELECT
   ce3.event_cd, ce3.event_end_dt_tm
   FROM clinical_event ce,
    clinical_event ce2,
    clinical_event ce3,
    ce_date_result cedr,
    prsnl p,
    dummyt t,
    dummyt t1
   PLAN (ce
    WHERE (ce.event_id=eventinfo->parent_event_id)
     AND ce.result_status_cd IN (authverified, altered, modified)
     AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime))
    JOIN (t)
    JOIN (ce2
    WHERE ce2.parent_event_id=ce.event_id
     AND ce2.result_status_cd IN (authverified, altered, modified))
    JOIN (t1)
    JOIN (ce3
    WHERE ce3.parent_event_id=ce2.event_id
     AND ce3.result_status_cd IN (authverified, altered, modified)
     AND ce3.event_cd IN (nursewitness, nursewitnesstransfusion, nursestatementofattestation,
    patchappliedtime, bloodproducttransfused,
    chartingreason))
    JOIN (cedr
    WHERE cedr.event_id=outerjoin(ce3.event_id)
     AND cedr.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime)))
    JOIN (p
    WHERE p.person_id=outerjoin(ce3.performed_prsnl_id))
   ORDER BY ce3.event_cd, ce3.event_end_dt_tm DESC
   HEAD ce3.event_cd
    IF (ce3.event_cd IN (nursewitness, nursewitnesstransfusion)
     AND textlen(eventinfo->witness_id)=0)
     eventinfo->witness_id = ce3.result_val
    ELSEIF (ce3.event_cd=nursestatementofattestation
     AND textlen(eventinfo->attestation_witness_id)=0)
     eventinfo->attestation_witness_id = trim(p.name_full_formatted,3), eventinfo->
     attesttion_witness_en = trim(p.username,3), eventinfo->attesttion_witness_pid = p.person_id
    ELSEIF (ce3.event_cd=patchappliedtime)
     eventinfo->patchapplieddttm = format(cnvtdatetime(cedr.result_dt_tm),";;q")
    ELSEIF (ce3.event_cd=infusionstarttime)
     eventinfo->infusiontime = format(cnvtdatetime(cedr.result_dt_tm),";;q")
    ELSEIF (ce.event_cd=bloodproducttransfused
     AND trim(ce.event_tag,3) IN ("Rh Immune Globulin: Intramuscular",
    "Rh Immune Globulin: Intravenous"))
     eventinfo->donotsendalerts = 1
    ELSEIF (ce.event_cd=chartingreason
     AND cnvtupper(trim(ce.event_tag,3)) IN ("*4 HOUR CHECK*", "*CLINICIAN DOSE*"))
     eventinfo->donotsendalerts = 1
    ENDIF
   WITH nocounter, outerjoin = t, outerjoin = t1
  ;end select
  IF ((eventinfo->donotsendalerts=1))
   SET log_message = concat(log_message,"!!!RH Immune blobulin - do not send alert !!!")
   GO TO exit_program
  ELSE
   SET log_message = concat(log_message,"!!! passed find DTAs charted on form, not this instnace !!!"
    )
  ENDIF
 ENDIF
 CALL echo("Find the Nurse Witness position")
 SELECT INTO "NL:"
  FROM prsnl p,
   code_value c
  PLAN (p
   WHERE (p.person_id=eventinfo->attesttion_witness_pid)
    AND p.active_ind=1)
   JOIN (c
   WHERE c.code_value=p.position_cd
    AND ((p.physician_ind=1) OR (c.display IN ("BHS ER RN", "BHS ED RN W/OE and Tasks",
   "BHS ED Management", "BHS RN Supv", "BHS RN",
   "BHS Nursing Student", "BHS Onco RN"))) )
  HEAD REPORT
   cnt = 0
  DETAIL
   eventinfo->attesttion_correctuserpostion = 1
  WITH nocounter
 ;end select
 SET log_message = concat(log_message,"locating user postion")
 CALL echo("Collect patient Demographic information")
 SELECT INTO "NL:"
  ea.alias
  FROM encntr_alias ea,
   encounter e,
   encntr_domain ed,
   person p
  PLAN (e
   WHERE e.encntr_id=encntrid)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=finnbr
    AND cnvtdatetime(curdate,curtime) BETWEEN ea.beg_effective_dt_tm AND ea.end_effective_dt_tm)
   JOIN (ed
   WHERE ed.encntr_id=e.encntr_id
    AND ed.active_ind=1
    AND cnvtdatetime(curdate,curtime) BETWEEN ed.beg_effective_dt_tm AND ed.end_effective_dt_tm)
   JOIN (p
   WHERE p.person_id=e.person_id)
  DETAIL
   eventinfo->fin = check(trim(ea.alias,3)), eventinfo->name = concat(trim(p.name_first,3)," ",trim(p
     .name_last,3)), eventinfo->nurseunit = uar_get_code_display(ed.loc_nurse_unit_cd)
  WITH nocounter
 ;end select
 SET log_message = concat(log_message," patient demo collected ")
 CALL echo("Locate orders for each of the form types")
 SELECT INTO "NL:"
  o.orig_order_dt_tm
  FROM order_catalog_synonym ocs,
   orders o
  PLAN (ocs
   WHERE ((ocs.mnemonic_key_cap IN ("PCA*")
    AND (eventinfo->formtype=narcoticinfandaccounabilitybhs)) OR (((ocs.mnemonic_key_cap IN (
   "*FENTANYL*PATCH*")
    AND (eventinfo->formtype=narcoticpatchandaccountabilityform)) OR (ocs.mnemonic_key_cap IN (
   "TRANSFUSE*", "FACTOR*", "NONRED*")
    AND ocs.activity_type_cd IN (bloodbankproduct)
    AND (eventinfo->formtype IN (transfusiontagform, autotransfusionbloodrecoveryform)))) ))
    AND ocs.active_ind=1)
   JOIN (o
   WHERE o.encntr_id=encntrid
    AND o.active_ind=1
    AND o.cs_flag IN (0, 2, 8, 32)
    AND (((eventinfo->formtype IN (narcoticinfandaccounabilitybhs, narcoticpatchandaccountabilityform
   ))
    AND o.order_id IN (
   (SELECT
    oi.order_id
    FROM order_ingredient oi
    WHERE oi.synonym_id=ocs.synonym_id))) OR ((eventinfo->formtype IN (transfusiontagform,
   autotransfusionbloodrecoveryform))
    AND o.catalog_cd=ocs.catalog_cd)) )
  ORDER BY o.orig_order_dt_tm DESC, o.updt_dt_tm DESC
  HEAD REPORT
   eventinfo->orderdttm = format(cnvtdatetime(o.orig_order_dt_tm),";;q"), eventinfo->orderdisp = o
   .ordered_as_mnemonic, eventinfo->display_line = trim(o.clinical_display_line,3),
   eventinfo->orderdisp_status = uar_get_code_display(o.order_status_cd)
  WITH nocounter
 ;end select
 SET log_message = concat(log_message," finding orders event_form cd=",build(eventinfo->formtype))
 CALL echo("find the first instance of the form and who signed it")
 SELECT
  ce.event_cd, ce.event_end_dt_tm
  FROM clinical_event ce,
   prsnl p
  PLAN (ce
   WHERE (ce.event_id=eventinfo->parent_event_id)
    AND ce.result_status_cd IN (authverified, altered, modified)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce.event_cd IN (transfusiontagform, autotransfusionbloodrecoveryform,
   narcoticinfandaccounabilitybhs, narcoticpatchandaccountabilityform))
   JOIN (p
   WHERE p.person_id=ce.performed_prsnl_id)
  ORDER BY ce.event_cd, ce.event_end_dt_tm
  HEAD ce.event_cd
   eventinfo->performedby_id = trim(p.name_full_formatted,3), eventinfo->performedby_en = trim(p
    .username,3), eventinfo->performedby_prsnl_id = p.person_id,
   eventinfo->performeddttm = format(cnvtdatetime(ce.event_end_dt_tm),";;q")
  WITH nocounter
 ;end select
 SET eventinfo->formname = replace(eventinfo->formname,"Form","")
 SET eventinfo->formname = replace(eventinfo->formname,"form","")
 IF (( $RULETYPE="TIMER"))
  IF (textlen(trim(eventinfo->attestation_witness_id,3)) <= 0)
   SET log_message = concat(log_message,"ALERT!: 24 hours later and Nurse Attestation not complete")
   SET inboxoutput = concat(inboxoutput,char(10),"Had a ",eventinfo->formname,
    " form completed and it has not had an attestation completed",
    " in greater than 24 hours.  Please investigate.",char(10),char(10))
   SET sendalert = 1
   SET alertjengroup = 1
   SET alertpharmgroup = 0
  ENDIF
 ENDIF
 IF (((( $RULETYPE IN ("CLINICAL_EVENT", "DISCERN"))) OR (( $RULETYPE="TIMER")
  AND textlen(inboxoutput) > 0)) )
  IF ((((eventinfo->result_stats_cd=authverified)) OR (( $RULETYPE="TIMER"))) )
   IF (textlen(trim(eventinfo->witness_id,3)) <= 0)
    SET log_message = concat(log_message,"ALERT!: Nurse Witness is blank")
    SET inboxoutput = concat(inboxoutput,char(10),"Had a ",eventinfo->formname,
     " form completed in which the nurse ",
     eventinfo->performedby_id," did not include a witness when completing the form.",
     " Please investigate to be sure form is completed appropriately.",char(10),char(10))
    SET sendalert = 1
    SET alertpharmgroup = 1
   ENDIF
  ENDIF
  SET log_message = concat(log_message,"!",eventinfo->witness_id,"! !",eventinfo->performedby_id,
   "!")
  IF ((((eventinfo->witnessfldfilledoutthisevent=1)
   AND (eventinfo->witness_id=eventinfo->performedby_id)) OR ((eventinfo->attestationthisevent=1)
   AND (eventinfo->attestation_witness_id=eventinfo->performedby_id))) )
   SET log_message = concat(log_message,"ALERT!: Nurse Witness is the Same as Nurse Performing")
   SET inboxoutput = concat(inboxoutput,char(10),"Had a ",eventinfo->formname,
    " form completed in which the nurse ",
    eventinfo->performedby_id," used themselves as the witnessing nurse. Please investigate",
    " to be sure form is completed appropriately.",char(10),char(10))
   SET sendalert = 1
   SET alertpharmgroup = 1
  ENDIF
  IF ((eventinfo->attestationnotwitnessed=1))
   SET log_message = concat(log_message,"ALERT!: Nurse Attestation was marked as NOT WITNESSED")
   SET inboxoutput = concat(inboxoutput,char(10),"Had a ",eventinfo->formname,
    " form completed in which the attestation section was marked as not witnessed. ",
    " Please investigate to be sure form is completed appropriately.",char(10),char(10))
   SET sendalert = 1
   SET alertpharmgroup = 1
  ENDIF
  IF ((eventinfo->attestationthisevent=1)
   AND (eventinfo->attestation_witness_id != eventinfo->witness_id))
   SET log_message = concat(log_message,
    "ALERT!: Nurse Attestation is not the same nurse form the Nurse Witness DTA")
   SET inboxoutput = concat(inboxoutput,char(10),"Had a ",eventinfo->formname,
    " form completed in which the nurse witness was selected as ",
    IF (textlen(eventinfo->witness_id) > 0) eventinfo->witness_id
    ELSE "(Not selected)"
    ENDIF
    ," yet the nurse ",eventinfo->attestation_witness_id," completed the attestation section.",
    " Please investigate to be sure form is completed appropriately.",
    char(10),char(10))
   SET sendalert = 1
   SET alertpharmgroup = 1
  ENDIF
  IF ((eventinfo->attestationthisevent=1)
   AND (eventinfo->attesttion_correctuserpostion=0))
   SET log_message = concat(log_message,
    "ALERT!: Nurse Attestation was performed by incorrect postion")
   SET inboxoutput = concat(inboxoutput,char(10),"Had a ",eventinfo->formname,
    " form completed in which the provider ",
    eventinfo->attestation_witness_id,
    " is not an authorized witness. Please investigate to be sure form is completed appropriately.",
    char(10),char(10))
   SET sendalert = 1
   SET alertjengroup = 1
  ENDIF
  IF ((eventinfo->patchremovedthisevent=1))
   IF (datetimediff(cnvtdatetime(eventinfo->patchremoveddttm),cnvtdatetime(eventinfo->
     patchapplieddttm),3) < 72)
    SET log_message = concat(log_message,"ALERT!:Patch was removed in less then 72 hours")
    SET inboxoutput = concat(inboxoutput,char(10),"Had a ",eventinfo->formname,
     " form completed in which Removal time is less than 72 hours from Patch Apply time.",
     "  Form was completed by ",eventinfo->performedby_id,
     ". Please investigate to be sure form is completed appropriately.",char(10),char(10))
    SET sendalert = 1
    SET alertpharmgroup = 1
   ENDIF
   SET log_message = build(log_message,"Patch was removed(hours):",datetimediff(cnvtdatetime(
      eventinfo->patchremoveddttm),cnvtdatetime(eventinfo->patchapplieddttm),3))
  ENDIF
 ENDIF
 IF (( $RULETYPE="TIMER"))
  SET alertpharmgroup = 0
 ENDIF
 SET inboxoutput = concat("::","Patient ",eventinfo->name," Nurse Unit: ",eventinfo->nurseunit,
  " FIN: ",eventinfo->fin,char(10),inboxoutput,char(10),
  char(10),"Power Form: ",eventinfo->formname,char(10),"Form dt/tm:",
  eventinfo->performeddttm,char(10),"Patient: ",eventinfo->name,char(10),
  "FIN: ",eventinfo->fin,char(10),"Nurse unit: ",eventinfo->nurseunit,
  char(10),char(10),"Nurse signing form: ",eventinfo->performedby_id,char(10),
  "Nurse signing form EN: ",eventinfo->performedby_en,char(10),"Nurse entered in witness box: ",
  eventinfo->witness_id,
  char(10),"Nurse performing attestation: ",eventinfo->attestation_witness_id,char(10),
  "Nurse performing attestation employee number: ",
  eventinfo->attesttion_witness_en,
  IF (textlen(eventinfo->infusiontime) > 0) concat(char(10),"Infusion begin time ",eventinfo->
    infusiontime)
  ELSEIF (textlen(eventinfo->patchapplieddttm) > 0) concat(char(10),"Patch applied time ",eventinfo->
    patchapplieddttm)
  ELSE " "
  ENDIF
  ,
  IF (textlen(eventinfo->patchremoveddttm) > 0) concat(char(10),"Patch removal time: ",eventinfo->
    patchremoveddttm)
  ELSE " "
  ENDIF
  ,char(10),
  IF (textlen(eventinfo->orderdisp) > 0) concat("Recent order: ",eventinfo->orderdisp,"   ",eventinfo
    ->orderdttm,char(10),
    "   ",eventinfo->display_line,char(10),"Order Status: ",eventinfo->orderdisp_status)
  ELSE " "
  ENDIF
  ,
  char(10))
 SET log_message = build(log_message,char(10),inboxoutput)
 SET log_message = concat( $RULETYPE,":",log_message," event Reference",eventinfo->refid)
 SET retval = 100
 IF (sendalert=1)
  SET log_message = build(log_message,char(10),"Send in box messages")
  RECORD inboxrequest(
    1 person_id = f8
    1 encntr_id = f8
    1 stat_ind = i2
    1 task_type_cd = f8
    1 task_type_meaning = c12
    1 reference_task_id = f8
    1 task_dt_tm = dq8
    1 task_activity_meaning = c12
    1 msg_text = c32768
    1 msg_subject_cd = f8
    1 msg_subject = c255
    1 confidential_ind = i2
    1 read_ind = i2
    1 delivery_ind = i2
    1 event_id = f8
    1 event_class_meaning = c12
    1 assign_prsnl_list[*]
      2 assign_prsnl_id = f8
    1 task_status_meaning = c12
  )
  RECORD inboxreply(
    1 task_status = c1
    1 task_id = f8
    1 assign_prsnl_list[*]
      2 assign_prsnl_id = f8
      2 encntr_sec_ind = i2
    1 status_data
      2 status = c1
      2 substatus = i2
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = c100
  )
  DECLARE req = i4
  DECLARE happ = i4
  DECLARE htask = i4
  DECLARE hreq = i4
  DECLARE hreply = i4
  DECLARE crmstatus = i4
  SET ecrmok = 0
  SET null = 0
  IF (validate(recdate,"Y")="Y"
   AND validate(recdate,"N")="N")
   RECORD recdate(
     1 datetime = dq8
   )
  ENDIF
  SUBROUTINE srvrequest(taskhandle,reqno)
    SET htask = taskhandle
    SET req = reqno
    SET crmstatus = uar_crmbeginreq(htask,0,req,hreq)
    IF (crmstatus != ecrmok)
     CALL echo("Invalid CrmBeginReq return status")
    ELSEIF (hreq=null)
     CALL echo("Invalid hReq handle")
    ELSE
     SET request_handle = hreq
     SET hinboxrequest = uar_crmgetrequest(hreq)
     IF (hinboxrequest=null)
      CALL echo("Invalid request handle return from CrmGetRequest")
     ELSE
      SET stat = uar_srvsetdouble(hinboxrequest,"PERSON_ID",inboxrequest->person_id)
      SET stat = uar_srvsetdouble(hinboxrequest,"ENCNTR_ID",inboxrequest->encntr_id)
      SET stat = uar_srvsetshort(hinboxrequest,"STAT_IND",cnvtint(inboxrequest->stat_ind))
      SET stat = uar_srvsetdouble(hinboxrequest,"TASK_TYPE_CD",inboxrequest->task_type_cd)
      SET stat = uar_srvsetstring(hinboxrequest,"TASK_TYPE_MEANING",nullterm(inboxrequest->
        task_type_meaning))
      SET stat = uar_srvsetdouble(hinboxrequest,"REFERENCE_TASK_ID",inboxrequest->reference_task_id)
      SET recdate->datetime = inboxrequest->task_dt_tm
      SET stat = uar_srvsetdate2(hinboxrequest,"TASK_DT_TM",recdate)
      SET stat = uar_srvsetstring(hinboxrequest,"TASK_ACTIVITY_MEANING",nullterm(inboxrequest->
        task_activity_meaning))
      SET stat = uar_srvsetstring(hinboxrequest,"MSG_TEXT",nullterm(inboxrequest->msg_text))
      SET stat = uar_srvsetdouble(hinboxrequest,"MSG_SUBJECT_CD",inboxrequest->msg_subject_cd)
      SET stat = uar_srvsetstring(hinboxrequest,"MSG_SUBJECT",nullterm(inboxrequest->msg_subject))
      SET stat = uar_srvsetshort(hinboxrequest,"CONFIDENTIAL_IND",cnvtint(inboxrequest->
        confidential_ind))
      SET stat = uar_srvsetshort(hinboxrequest,"READ_IND",cnvtint(inboxrequest->read_ind))
      SET stat = uar_srvsetshort(hinboxrequest,"DELIVERY_IND",cnvtint(inboxrequest->delivery_ind))
      SET stat = uar_srvsetdouble(hinboxrequest,"EVENT_ID",inboxrequest->event_id)
      SET stat = uar_srvsetstring(hinboxrequest,"EVENT_CLASS_MEANING",nullterm(inboxrequest->
        event_class_meaning))
      FOR (ndx1 = 1 TO size(inboxrequest->assign_prsnl_list,5))
       SET hassign_prsnl_list = uar_srvadditem(hinboxrequest,"ASSIGN_PRSNL_LIST")
       IF (hassign_prsnl_list=null)
        CALL echo("ASSIGN_PRSNL_LIST","Invalid handle")
       ELSE
        SET stat = uar_srvsetdouble(hassign_prsnl_list,"ASSIGN_PRSNL_ID",inboxrequest->
         assign_prsnl_list[ndx1].assign_prsnl_id)
       ENDIF
      ENDFOR
      SET stat = uar_srvsetstring(hinboxrequest,"TASK_STATUS_MEANING",nullterm(inboxrequest->
        task_status_meaning))
     ENDIF
    ENDIF
    IF (crmstatus=ecrmok)
     CALL echo(concat("**** Begin perform request #",cnvtstring(req)," -EKS Event @",format(curdate,
        "dd-mmm-yyyy;;d")," ",
       format(curtime,"hh:mm:ss.cc;3;m")))
     SET crmstatus = uar_crmperform(hreq)
     CALL echo(concat("**** End perform request #",cnvtstring(req)," -EKS Event @",format(curdate,
        "dd-mmm-yyyy;;d")," ",
       format(curtime,"hh:mm:ss.cc;3;m")))
     IF (crmstatus != ecrmok)
      CALL echo("Invalid CrmPerform return status")
     ENDIF
    ELSE
     CALL echo("CrmPerform not executed do to begin request error")
    ENDIF
  END ;Subroutine
  SUBROUTINE srvreply(taskhandle,reqno)
    DECLARE item_cnt = i4 WITH protect
    SET htask = taskhandle
    SET req = reqno
    IF (crmstatus=ecrmok)
     SET hinboxreply = uar_crmgetreply(hreq)
     IF (hinboxreply=null)
      CALL echo("Invalid handle from CrmGetReply")
     ELSE
      CALL echo("Retrieving reply message")
      SET inboxreply->task_status = uar_srvgetstringptr(hinboxreply,"TASK_STATUS")
      SET inboxreply->task_id = uar_srvgetdouble(hinboxreply,"TASK_ID")
      SET item_cnt = uar_srvgetitemcount(hinboxreply,"ASSIGN_PRSNL_LIST")
      SET stat = alterlist(inboxreply->assign_prsnl_list,item_cnt)
      FOR (ndx1 = 1 TO item_cnt)
       SET hassign_prsnl_list = uar_srvgetitem(hinboxreply,"ASSIGN_PRSNL_LIST",(ndx1 - 1))
       IF (hassign_prsnl_list=null)
        CALL echo("Invalid handle return from SrvGetItem for hASSIGN_PRSNL_LIST")
       ELSE
        SET inboxreply->assign_prsnl_list[ndx1].assign_prsnl_id = uar_srvgetdouble(hassign_prsnl_list,
         "ASSIGN_PRSNL_ID")
        SET inboxreply->assign_prsnl_list[ndx1].encntr_sec_ind = uar_srvgetshort(hassign_prsnl_list,
         "ENCNTR_SEC_IND")
       ENDIF
      ENDFOR
      SET hstatus_data = uar_srvgetstruct(hinboxreply,"STATUS_DATA")
      IF (hstatus_data=null)
       CALL echo("Invalid handle")
      ELSE
       SET inboxreply->status_data.status = uar_srvgetstringptr(hstatus_data,"STATUS")
       SET inboxreply->status_data.substatus = uar_srvgetshort(hstatus_data,"SUBSTATUS")
       SET item_cnt = uar_srvgetitemcount(hstatus_data,"SUBEVENTSTATUS")
       SET stat = alterlist(inboxreply->status_data.subeventstatus,item_cnt)
       FOR (ndx2 = 1 TO item_cnt)
        SET hsubeventstatus = uar_srvgetitem(hstatus_data,"SUBEVENTSTATUS",(ndx2 - 1))
        IF (hsubeventstatus=null)
         CALL echo("Invalid handle return from SrvGetItem for hSUBEVENTSTATUS")
        ELSE
         SET inboxreply->status_data.subeventstatus[ndx2].operationname = uar_srvgetstringptr(
          hsubeventstatus,"OPERATIONNAME")
         SET inboxreply->status_data.subeventstatus[ndx2].operationstatus = uar_srvgetstringptr(
          hsubeventstatus,"OPERATIONSTATUS")
         SET inboxreply->status_data.subeventstatus[ndx2].targetobjectname = uar_srvgetstringptr(
          hsubeventstatus,"TARGETOBJECTNAME")
         SET inboxreply->status_data.subeventstatus[ndx2].targetobjectvalue = uar_srvgetstringptr(
          hsubeventstatus,"TARGETOBJECTVALUE")
        ENDIF
       ENDFOR
      ENDIF
     ENDIF
    ELSE
     CALL echo("Could not retrieve reply due to CrmBegin request error")
    ENDIF
    CALL echo("Ending CRM Request")
    CALL uar_crmendreq(hreq)
  END ;Subroutine
  SET inboxrequest->person_id = personid
  SET inboxrequest->encntr_id = encntrid
  SET inboxrequest->stat_ind = 1
  SET inboxrequest->task_type_cd = 0
  SET inboxrequest->task_type_meaning = "PHONE MSG"
  SET inboxrequest->reference_task_id = 0
  SET inboxrequest->task_dt_tm = cnvtdatetime(curdate,curtime3)
  SET inboxrequest->task_activity_meaning = "comp pers"
  SET inboxrequest->msg_text = fillstring(3100," ")
  SET inboxrequest->msg_text = inboxoutput
  SET inboxrequest->msg_subject_cd = 0
  SET inboxrequest->msg_subject = concat("Nurse Witness - ",trim(eventinfo->nurseunit,3))
  SET inboxrequest->confidential_ind = 0
  SET inboxrequest->read_ind = 0
  SET inboxrequest->delivery_ind = 0
  SET inboxrequest->event_id = 0
  SET inboxrequest->event_class_meaning = " "
  SET inboxrequest->task_status_meaning = " "
  SET lcnt = 0
  SET prsnl_id = 0.0
  IF (alertjengroup=1)
   SELECT
    p.person_id
    FROM prsnl p
    WHERE p.name_last_key="INBOX"
     AND p.name_first_key="CLINICALINFORMATICS"
    DETAIL
     prsnl_id = p.person_id
    WITH nocounter
   ;end select
   IF (prsnl_id > 0)
    SET lcnt = (lcnt+ 1)
    SET stat = alterlist(inboxrequest->assign_prsnl_list,lcnt)
    SET inboxrequest->assign_prsnl_list[lcnt].assign_prsnl_id = prsnl_id
    SET prsnl_id = 0
    SET log_message = build(log_message,char(10),"found ID - sending to Jen's Team")
   ELSE
    SET log_message = build(log_message,char(10),
     "failed finding clinical informatics prsnlID to send inbox message")
   ENDIF
  ENDIF
  IF (alertpharmgroup=1
   AND sendalertpharmacy=1)
   SET prsnl_id = 0
   SELECT
    p.person_id
    FROM prsnl p
    WHERE p.name_last_key="INBOX"
     AND p.name_first_key="PHARMACY"
    DETAIL
     prsnl_id = p.person_id
    WITH nocounter
   ;end select
   IF (prsnl_id > 0)
    SET lcnt = (lcnt+ 1)
    SET stat = alterlist(inboxrequest->assign_prsnl_list,lcnt)
    SET inboxrequest->assign_prsnl_list[lcnt].assign_prsnl_id = prsnl_id
    SET log_message = build(log_message,char(10)," !!sending to pharmacy !!")
   ELSE
    SET log_message = build(log_message,char(10),
     "failed finding pharmacy inbox prsnlID to send inbox message")
   ENDIF
  ENDIF
  CALL echo(build("Exit select:",curqual))
  SET reqc = 967102
  SET happc = 0
  SET appc = 3055000
  SET taskc = 3202004
  SET htaskc = 0
  SET hreqc = 0
  SET stat = uar_crmbeginapp(appc,happc)
  SET stat = uar_crmbegintask(happc,taskc,htaskc)
  CALL echo(build("beginReq",stat))
  CALL srvrequest(htaskc,reqc)
  CALL srvreply(htaskc,reqc)
  CALL echorecord(inboxrequest)
  CALL echorecord(inboxreply)
 ENDIF
#exit_program
 SUBROUTINE validatecodevalue(type,codeset,val)
   SET codeval = 0.0
   SET codeval = uar_get_code_by(value(type),codeset,value(val))
   IF (codeval <= 0)
    SET errmsg = concat("failed finding code_val - type: ",type," codeset:",build(codeset)," val:",
     val)
    CALL echo(errmsg)
    GO TO exit_program
   ELSE
    CALL echo(concat("type: ",type," codeset:",build(codeset)," val:",
      val," Code_value=",cnvtstring(codeval)))
   ENDIF
   RETURN(codeval)
 END ;Subroutine
END GO

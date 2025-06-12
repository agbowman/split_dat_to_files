CREATE PROGRAM bhs_eks_early_warning_event:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "encntrid:" = 0,
  "clinical_event_id:" = "",
  "listype" = "ADULTEARLYWARNINGSYSTEM",
  "listowner:" = "",
  "Call Type:" = "",
  "patient at qualifying location:" = 0
  WITH outdev, encntrid, clinical_event_id,
  listtype, listowner, type,
  patlocqualifies
 CALL echo("Inside bhs_eks_early_warning_event")
 DECLARE msgpriority = i4 WITH noconstant(5)
 DECLARE sendto = vc WITH noconstant(" ")
 DECLARE msgsubject = vc WITH noconstant(" ")
 DECLARE msg = vc WITH noconstant(" ")
 DECLARE msgcls = vc WITH constant("IPM.NOTE")
 DECLARE sender = vc WITH constant("Discern_Expert@bhs.org")
 DECLARE qualifyingscore = i4 WITH constant(10)
 CALL echo("declare variables")
 DECLARE log_misc1 = vc WITH noconstant(" ")
 DECLARE templogmisc1 = vc WITH noconstant(" ")
 DECLARE log_message = vc WITH noconstant(" ")
 DECLARE retval = i4 WITH noconstant(0), public
 DECLARE eventid = f8 WITH noconstant(0.0)
 DECLARE encntr_id = f8 WITH noconstant(0.0)
 DECLARE errmsg = vc WITH noconstant("  ")
 DECLARE ewscorecnt = i4 WITH noconstant(0)
 DECLARE tempvitalscore = i4 WITH noconstant(0)
 DECLARE templabscore = i4 WITH noconstant(0)
 DECLARE temptotalscore = f8 WITH noconstant(0)
 DECLARE tempeventscore = i4 WITH noconstant(0)
 DECLARE listdesc = vc WITH noconstant(" "), public
 DECLARE patientexistsoncustomlist = i4 WITH noconstant(0)
 DECLARE patienthasactivetask = i4 WITH noconstant(0)
 DECLARE patienthadtasklast12hour = i4 WITH noconstant(0)
 DECLARE patacttype = vc WITH noconstant(" ")
 DECLARE taskliks = vc WITH noconstant("  ")
 DECLARE nurseunit = vc WITH noconstant("  ")
 DECLARE num = i4 WITH protect
 DECLARE pos = i4 WITH protect
 DECLARE ml_rsn_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_rsn_fnd_ind = i4 WITH protect, noconstant(0)
 CALL echo("declare constants")
 DECLARE mobile = f8 WITH constant(validatecodevalue("MEANING",43,"MOBILE")), protect
 DECLARE etmodify = vc WITH constant("ETMODIFY")
 DECLARE etadd = vc WITH constant("ETADD")
 DECLARE etaudit = vc WITH constant("ETAUDIT")
 DECLARE etinactivate = vc WITH constant("ETINACTIVATE")
 DECLARE vitallisttype = vc WITH constant("VITALS")
 DECLARE lablisttype = vc WITH constant("LABS")
 DECLARE altered = f8 WITH constant(validatecodevalue("MEANING",8,"ALTERED")), protect
 DECLARE modified = f8 WITH constant(validatecodevalue("MEANING",8,"MODIFIED")), protect
 DECLARE auth = f8 WITH constant(validatecodevalue("MEANING",8,"AUTH")), protect
 DECLARE earlywarningord = f8 WITH constant(validatecodevalue("DISPLAYKEY",200,"EARLYWARNING")),
 protect
 DECLARE ordered = f8 WITH constant(validatecodevalue("MEANING",6004,"ORDERED")), protect
 DECLARE inprocessord = f8 WITH constant(validatecodevalue("MEANING",6004,"INPROCESS")), protect
 DECLARE pendingtask = f8 WITH constant(validatecodevalue("MEANING",79,"PENDING")), protect
 DECLARE updt_dt_tm = dq8
 DECLARE ms_reason_txt = vc WITH protect, noconstant(" ")
 DECLARE ml_erp_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_erp_idx = i4 WITH protect, noconstant(0)
 CALL echo("declare Record structures")
 FREE RECORD ceresult
 RECORD ceresult(
   1 qual[*]
     2 clinical_event_id = f8
 )
 FREE RECORD ewevent
 RECORD ewevent(
   1 encntr_id = f8
   1 updt_dt_tm = dq8
   1 updt_id = f8
   1 qual[*]
     2 early_warning_id = f8
     2 active_ind = i4
     2 encntr_id = f8
     2 listtype = vc
     2 event_id = f8
     2 eventtype = vc
     2 event_grouper = f8
     2 range_id = f8
     2 clinical_event_id = f8
     2 event_cd = f8
     2 event_score = i4
     2 vitals_score = i4
     2 labs_score = i4
     2 total_score = i4
     2 insert_dt_tm = dq8
     2 event_end_dt_tm = dq8
 )
 FREE RECORD requesttemp
 RECORD requesttemp(
   1 clin_detail_list[*]
     2 clinical_event_id = f8
 )
 FREE RECORD ewreason
 RECORD ewreason(
   1 l_cnt = i4
   1 qual[*]
     2 f_event_cd = f8
     2 s_reason = vc
 ) WITH protect
 CALL echo("Begin logic")
 SET log_clineventid = 1.0
 SET log_orderid = 1.0
 SET tasklistuser =  $LISTOWNER
 SET listdesc = trim( $LISTTYPE,3)
 SET retval = 0
 SET log_message = " start of bhs_eks_early_warning_event; "
 IF (( $ENCNTRID <= 0))
  SET encntrid = trigger_encntrid
 ELSE
  SET encntrid = value( $ENCNTRID)
 ENDIF
 SET updt_id = reqinfo->updt_id
 SET updt_dt_tm = cnvtdatetime(sysdate)
 SET eventid = cnvtreal(value( $CLINICAL_EVENT_ID))
 SET log_message = concat(log_message,"patlocqualifies:",build( $PATLOCQUALIFIES),
  " Call event type = ", $TYPE)
 IF (listdesc="ADULTEARLYWARNINGSYSTEM")
  SET agequal = 0
  SELECT
   *
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.encntr_id=encntrid)
    JOIN (p
    WHERE p.person_id=e.person_id)
   DETAIL
    IF ((datetimecmp(cnvtdatetime(sysdate),cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1))
     > (18 * 365)))
     agequal = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (agequal=0)
   SET retval = 0
   SET log_message = concat(log_message," - list type = ",listdesc,
    " - Patient is under 18 exiting script")
   SET log_misc1 = ""
   GO TO exit_program
  ELSE
   SET log_message = concat(log_message," - list type = ",listdesc," - Patient is over 18 - ")
  ENDIF
 ENDIF
 IF (( $TYPE="EVENT"))
  IF (validate(request->clin_detail_list[1].clinical_event_id))
   SET log_message = concat(log_message," rule incoming events found; ")
   SET stat = alterlist(requesttemp->clin_detail_list,size(request->clin_detail_list,5))
   FOR (y = 1 TO size(request->clin_detail_list,5))
    SET log_message = concat(log_message,"CEID: ",build(request->clin_detail_list[y].
      clinical_event_id),"; ")
    SET requesttemp->clin_detail_list[y].clinical_event_id = request->clin_detail_list[y].
    clinical_event_id
   ENDFOR
  ELSE
   SET log_message = concat(log_message," no incoming events found; ")
   CALL echo("no rule incoming events found; ")
   SET stat = alterlist(requesttemp->clin_detail_list,1)
   SET requesttemp->clin_detail_list[1].clinical_event_id =  $CLINICAL_EVENT_ID
  ENDIF
 ELSEIF (( $TYPE="ADT"))
  IF (validate(trigger_personid) > 0)
   IF ((request->o_reg_dt_tm != request->n_reg_dt_tm))
    IF ((request->o_reg_dt_tm IN (null, 0)))
     SET patacttype = ""
     SET log_message = concat(log_message,"regdtTM ADT change; ")
    ENDIF
   ELSEIF ( NOT ((request->n_disch_dt_tm IN (null, 0)))
    AND (request->o_disch_dt_tm IN (null, 0)))
    SET log_message = concat(log_message,"discharge ADT")
    SET patacttype = "discharge"
    GO TO dischstartpoint
   ELSEIF ((request->n_loc_nurse_unit_cd != request->o_loc_nurse_unit_cd))
    SET log_message = concat(log_message," Transfer ADT; ")
    SET patacttype = "transfer"
    IF (( $PATLOCQUALIFIES=0))
     GO TO dischstartpoint
    ENDIF
   ENDIF
   SET log_message = concat(log_message,"patActType:",patacttype,";",build(request->
     o_loc_nurse_unit_cd),
    "@",build(request->o_location_cd),"!")
   IF (textlen(patacttype) <= 0)
    SET log_message = concat(log_message,"Patient ADT event did not qualify")
    SET retval = 0
    GO TO exit_program
   ENDIF
  ELSE
   SET patacttype = "admit"
  ENDIF
 ENDIF
 CALL echo("Check to see if the patient currently exists in the early warning table")
 SELECT INTO "NL:"
  ew.insert_dt_tm
  FROM bhs_early_warning ew
  WHERE ew.encntr_id=encntrid
   AND ew.active_ind=1
  ORDER BY ew.insert_dt_tm DESC
  WITH nocounter, maxrec = 1
 ;end select
 IF (curqual < 1
  AND ((( $TYPE="EVENT")) OR (( $PATLOCQUALIFIES=1)
  AND patacttype="transfer")) )
  SET log_message = concat(log_message," patient does not exist on EW table; ")
  CALL echo("no rows found so we must backload data for this patient")
  SELECT INTO "NL:"
   e.event_cd, ce.event_end_dt_tm
   FROM bhs_event_cd_list e,
    clinical_event ce
   PLAN (e
    WHERE e.listkey IN (listdesc)
     AND e.active_ind=1)
    JOIN (ce
    WHERE ce.encntr_id=encntrid
     AND ce.event_cd=e.event_cd
     AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate)
     AND ce.result_status_cd IN (altered, modified, auth)
     AND ce.view_level=1)
   ORDER BY e.event_cd, ce.event_end_dt_tm DESC
   HEAD REPORT
    ewscorecnt = 0, ewevent->encntr_id = ce.encntr_id, ewevent->updt_dt_tm = updt_dt_tm,
    ewevent->updt_id = updt_id
   HEAD e.event_cd
    IF (isnumeric(ce.result_val))
     ewscorecnt += 1, stat = alterlist(ewevent->qual,ewscorecnt), ewevent->qual[ewscorecnt].
     active_ind = 1,
     ewevent->qual[ewscorecnt].event_id = ce.event_id, ewevent->qual[ewscorecnt].listtype = e.grouper,
     ewevent->qual[ewscorecnt].clinical_event_id = ce.clinical_event_id,
     ewevent->qual[ewscorecnt].event_cd = ce.event_cd, ewevent->qual[ewscorecnt].insert_dt_tm =
     cnvtdatetime(sysdate), ewevent->qual[ewscorecnt].eventtype = etadd,
     ewevent->qual[ewscorecnt].event_grouper = e.grouper_id
    ENDIF
   WITH nocounter
  ;end select
  IF (ewscorecnt=0)
   CALL echo("******** No qualifying rows exist for this patient yet ********")
   SET log_message = concat(log_message,
    " No qualifying rows (back load of data) exist for this patient yet; ")
   GO TO exit_program
  ENDIF
  CALL echo("calculate scores for each events")
  EXECUTE bhs_eks_early_warning_score
  FOR (x = 1 TO ewscorecnt)
    SET ewevent->qual[x].early_warning_id = sequence(0)
  ENDFOR
 ELSE
  IF (( $TYPE="EVENT"))
   CALL echo("***********Patient exists on early warning table***************")
   CALL echo("Collect information about incoming event(s)")
   SET log_message = concat(log_message," patient exists on EW table; ")
   CALL echorecord(requesttemp)
   SELECT INTO "NL:"
    FROM clinical_event ce,
     bhs_event_cd_list e,
     bhs_early_warning ew,
     (dummyt d  WITH seq = size(requesttemp->clin_detail_list,5))
    PLAN (d)
     JOIN (ce
     WHERE (ce.clinical_event_id=requesttemp->clin_detail_list[d.seq].clinical_event_id)
      AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate))
     JOIN (e
     WHERE e.event_cd=ce.event_cd
      AND e.active_ind=1
      AND e.listkey=listdesc)
     JOIN (ew
     WHERE (ew.event_id= Outerjoin(ce.event_id))
      AND (ew.encntr_id= Outerjoin(ce.encntr_id))
      AND (ew.active_ind= Outerjoin(1)) )
    HEAD REPORT
     ewevent->encntr_id = ce.encntr_id, ewevent->updt_dt_tm = updt_dt_tm, ewevent->updt_id = updt_id
    HEAD ce.event_id
     IF (ew.early_warning_id=0
      AND (( NOT (ce.result_status_cd IN (altered, modified, auth))) OR (isnumeric(ce.result_val) < 1
     )) )
      log_message = concat(log_message,";notSigned;")
     ELSE
      ewscorecnt += 1, stat = alterlist(ewevent->qual,ewscorecnt), ewevent->qual[ewscorecnt].
      early_warning_id = ew.early_warning_id
      IF (ce.result_status_cd IN (altered, modified, auth))
       ewevent->qual[ewscorecnt].active_ind = 1
      ELSE
       ewevent->qual[ewscorecnt].active_ind = 0
      ENDIF
      ewevent->qual[ewscorecnt].encntr_id = ce.encntr_id, ewevent->qual[ewscorecnt].event_id = ce
      .event_id, ewevent->qual[ewscorecnt].clinical_event_id = ce.clinical_event_id,
      ewevent->qual[ewscorecnt].event_cd = ce.event_cd, ewevent->qual[ewscorecnt].insert_dt_tm =
      cnvtdatetime(sysdate), ewevent->qual[ewscorecnt].listtype = e.grouper,
      ewevent->qual[ewscorecnt].event_end_dt_tm = ce.event_end_dt_tm
      IF (ew.early_warning_id > 0)
       ewevent->qual[ewscorecnt].eventtype = etmodify, ewevent->qual[ewscorecnt].event_grouper = e
       .grouper_id
      ELSE
       ewevent->qual[ewscorecnt].eventtype = etadd, ewevent->qual[ewscorecnt].event_grouper = e
       .grouper_id
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (ewscorecnt=0)
    SET errmsg = "failed to find incoming event"
    GO TO exit_program
   ENDIF
   FOR (x = 1 TO ewscorecnt)
     IF ((ewevent->qual[x].eventtype=etadd))
      SET ewevent->qual[x].early_warning_id = sequence(0)
     ENDIF
   ENDFOR
  ENDIF
  CALL echorecord(ewevent)
  CALL echo("collect the most recent values to calculate patients score")
  SET num = 0
  SET log_message = concat(log_message," Collect most recent results; ")
  SELECT INTO "NL:"
   e.event_cd, ce.event_end_dt_tm
   FROM bhs_event_cd_list e,
    bhs_early_warning ew,
    clinical_event ce,
    bhs_range_system brs,
    dummyt d
   PLAN (e
    WHERE e.listkey IN (listdesc)
     AND e.active_ind=1)
    JOIN (ew
    WHERE ew.encntr_id=encntrid
     AND ew.active_ind=1
     AND ew.event_cd=e.event_cd)
    JOIN (ce
    WHERE ce.event_id=ew.event_id
     AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
     AND ce.result_status_cd IN (altered, modified, auth))
    JOIN (brs
    WHERE brs.parent_entity_id=e.event_cd_list_id
     AND brs.parent_entity_name="bhs_event_cd_list"
     AND brs.active_ind=1)
    JOIN (d
    WHERE ce.event_end_dt_tm >= cnvtlookbehind(concat(trim(build2(brs.look_back_hours),3),",H"),
     cnvtdatetime(sysdate)))
   ORDER BY e.event_cd, ce.event_end_dt_tm DESC
   HEAD REPORT
    ewevent->encntr_id = ce.encntr_id, ewevent->updt_dt_tm = updt_dt_tm, ewevent->updt_id = updt_id
   HEAD e.event_cd
    CALL echo(uar_get_code_display(e.event_cd)), locnum = 0, pos = 0,
    usecurrentevent = 0, pos = locateval(locnum,1,size(ewevent->qual,5),ce.event_cd,ewevent->qual[
     locnum].event_cd)
    IF (pos > 0)
     IF (cnvtdatetime(ewevent->qual[pos].event_end_dt_tm) > cnvtdatetime(ce.event_end_dt_tm))
      usecurrentevent = 1
     ENDIF
    ENDIF
    locnum = 0, pos = 0, pos = locateval(locnum,1,size(ewevent->qual,5),ce.event_id,ewevent->qual[
     locnum].event_id)
    IF (pos=0
     AND usecurrentevent=0)
     ewscorecnt += 1, stat = alterlist(ewevent->qual,ewscorecnt), ewevent->qual[ewscorecnt].encntr_id
      = ce.encntr_id,
     ewevent->qual[ewscorecnt].early_warning_id = ew.early_warning_id, ewevent->qual[ewscorecnt].
     event_id = ce.event_id, ewevent->qual[ewscorecnt].clinical_event_id = ce.clinical_event_id,
     ewevent->qual[ewscorecnt].event_cd = ce.event_cd, ewevent->qual[ewscorecnt].insert_dt_tm =
     cnvtdatetime(sysdate), ewevent->qual[ewscorecnt].listtype = e.grouper,
     ewevent->qual[ewscorecnt].eventtype = etaudit, ewevent->qual[ewscorecnt].active_ind = 1, ewevent
     ->qual[ewscorecnt].event_grouper = e.grouper_id
    ENDIF
   WITH nocounter
  ;end select
  CALL echorecord(ewevent)
 ENDIF
 IF (size(ewevent->qual,5) > 0)
  CALL echo("Calculate scores for events")
  SET log_message = concat(log_message,"calc scores; ")
  EXECUTE bhs_eks_early_warning_score
  CALL echo("calculate total scores ")
  SET log_message = concat(log_message," Calc total scores; ")
  SELECT INTO "NL:"
   event_grouper = ewevent->qual[d.seq].event_grouper
   FROM (dummyt d  WITH seq = size(ewevent->qual,5))
   PLAN (d
    WHERE (ewevent->qual[d.seq].active_ind=1))
   ORDER BY event_grouper
   HEAD event_grouper
    tempeventscore = ewevent->qual[d.seq].event_score
   DETAIL
    IF ((ewevent->qual[d.seq].event_score > tempeventscore))
     tempeventscore = ewevent->qual[d.seq].event_score
    ENDIF
   FOOT  event_grouper
    IF ((ewevent->qual[d.seq].listtype=vitallisttype))
     tempvitalscore += tempeventscore
    ELSEIF ((ewevent->qual[d.seq].listtype=lablisttype))
     templabscore += tempeventscore
    ENDIF
   WITH nocounter
  ;end select
  SET temptotalscore = (templabscore+ tempvitalscore)
  FOR (y = 1 TO ewscorecnt)
    IF ((ewevent->qual[y].eventtype IN (etadd, etinactivate, etmodify)))
     SET ewevent->qual[y].vitals_score = tempvitalscore
     SET ewevent->qual[y].labs_score = templabscore
     SET ewevent->qual[y].total_score = temptotalscore
    ENDIF
  ENDFOR
  CALL echo(build("templabScore:",templabscore))
  CALL echo(build("tempVitalScore:",tempvitalscore))
  CALL echo(build("tempTotalScore:",temptotalscore))
  CALL echo("Insert/update early warning row for new event")
  CALL echorecord(ewevent)
  IF (ewscorecnt > 0)
   FOR (y = 1 TO ewscorecnt)
     IF ((ewevent->qual[y].eventtype=etadd))
      CALL echo(build("inserting event:",ewevent->qual[y].event_cd))
      SET log_message = concat(log_message," inserted Row:",build(y),"; ")
      INSERT  FROM bhs_early_warning e
       SET e.early_warning_id = ewevent->qual[y].early_warning_id, e.encntr_id = ewevent->encntr_id,
        e.clinical_event_id = ewevent->qual[y].clinical_event_id,
        e.range_id = ewevent->qual[y].range_id, e.event_id = ewevent->qual[y].event_id, e.event_cd =
        ewevent->qual[y].event_cd,
        e.eventtype = ewevent->qual[y].eventtype, e.event_score = ewevent->qual[y].event_score, e
        .vitals_score = ewevent->qual[y].vitals_score,
        e.labs_score = ewevent->qual[y].labs_score, e.total_score = ewevent->qual[y].total_score, e
        .insert_dt_tm = cnvtdatetime(sysdate),
        e.active_ind = ewevent->qual[y].active_ind, e.updt_id = updt_id, e.updt_dt_tm = cnvtdatetime(
         updt_dt_tm)
       WITH nocounter
      ;end insert
      COMMIT
     ELSEIF ((ewevent->qual[y].eventtype IN (etmodify, etinactivate)))
      CALL echo(build("updating event:",ewevent->qual[y].event_id))
      SET log_message = concat(log_message," update Row:",build(y),"; ")
      UPDATE  FROM bhs_early_warning e
       SET e.early_warning_id = ewevent->qual[y].early_warning_id, e.clinical_event_id = ewevent->
        qual[y].clinical_event_id, e.active_ind = ewevent->qual[y].active_ind,
        e.range_id = ewevent->qual[y].range_id, e.updt_id = updt_id, e.updt_dt_tm = cnvtdatetime(
         updt_dt_tm),
        e.eventtype = ewevent->qual[y].eventtype, e.event_score = ewevent->qual[y].event_score, e
        .vitals_score = ewevent->qual[y].vitals_score,
        e.labs_score = ewevent->qual[y].labs_score, e.total_score = ewevent->qual[y].total_score
       WHERE (e.early_warning_id=ewevent->qual[y].early_warning_id)
      ;end update
      COMMIT
     ENDIF
   ENDFOR
   SET log_message = concat(log_message," scoreCnt = 0; ")
  ENDIF
 ELSE
  SET log_message = concat(log_message,
   "No active labs/results were found for this patient that qualify;")
  CALL echo("No active labs/results were found for this patient that qualify")
  SET temptotalscore = 0
 ENDIF
#dischstartpoint
 IF (( $TYPE="ADT")
  AND ((patacttype="discharge") OR (( $PATLOCQUALIFIES=0))) )
  SET log_message = concat(log_message,"inactivate all rows for user")
  UPDATE  FROM bhs_early_warning e
   SET e.active_ind = 0, e.updt_id = updt_id, e.updt_dt_tm = cnvtdatetime(updt_dt_tm),
    e.eventtype = "SYSTEMINACTIVATE"
   WHERE e.encntr_id=encntrid
    AND e.active_ind=1
  ;end update
  COMMIT
 ENDIF
 CALL echo(
  "Now we have the score evaluate the patients total score and determin if it he/she should be added to custom lists"
  )
 CALL echo("check to see if patient is on custom list")
 CALL echo("find Nurse unit")
 SELECT INTO "NL:"
  FROM encntr_domain ed
  WHERE ed.encntr_id=encntrid
   AND ed.active_ind=1
   AND cnvtdatetime(sysdate) BETWEEN ed.beg_effective_dt_tm AND ed.end_effective_dt_tm
  DETAIL
   nurseunit = trim(uar_get_code_display(ed.loc_nurse_unit_cd))
  WITH counter
 ;end select
 SET tasklist = concat("Early Warning - ",nurseunit)
 SET tempretval = retval
 CALL echo(retval)
 CALL echo("calling BHS_EKS_EWS_CHECK_CUSTOM_LIST")
 SET templogmessage = log_message
 EXECUTE bhs_eks_ews_check_custom_list value(tasklist), value(tasklistuser), 0,
 encntrid
 SET log_orderid = cnvtreal(log_misc1)
 IF (log_orderid <= 0.0)
  SET log_orderid = 12.0
 ENDIF
 SET log_clineventid = log_orderid
 SET log_message = concat(templogmessage,"&&& LIST:",tasklist," List Call Msg: ",log_message,
  "&&&")
 IF (( $TYPE="ADT")
  AND retval=0)
  SET tasklist = "*"
  EXECUTE bhs_eks_ews_check_custom_list value(tasklist), value(tasklistuser), 0,
  encntrid
  SET log_clineventid = cnvtreal(log_misc1)
 ENDIF
 SET log_message = concat(templogmessage,"&&& LIST:",tasklist,"List Call Msg ADT: ",log_message,
  "&&&")
 IF (retval=100)
  CALL echo("patient exists on custom list")
  SET log_message = build(log_message," patient exists on custom list; ")
  SET patientexistsoncustomlist = 1
 ELSE
  CALL echo("patient does NOT exists on custom list")
  SET log_message = build(log_message," patient does NOT exists on custom list; ")
  SET patientexistsoncustomlist = 0
 ENDIF
 SET retval = tempretval
 CALL echo("Check to see if patient has active order and uncomplete task")
 SELECT INTO "NL:"
  FROM orders o,
   task_activity ta
  PLAN (o
   WHERE o.encntr_id=encntrid
    AND o.catalog_cd=earlywarningord
    AND ((o.active_ind+ 0)=1)
    AND ((o.order_status_cd+ 0) IN (ordered, inprocessord))
    AND o.orig_order_dt_tm >= cnvtdatetime((curdate - 1),curtime3))
   JOIN (ta
   WHERE ta.order_id=o.order_id
    AND ta.active_ind=1)
  ORDER BY o.orig_order_dt_tm DESC
  HEAD o.order_id
   CALL echo(build("!!!!!!!!!!!@@@@@@@@@@@@",ta.task_id))
   IF (ta.task_status_cd IN (pendingtask))
    patienthasactivetask = 1, log_message = build(log_message," Patient has active task; ")
   ENDIF
   IF (12 >= datetimediff(cnvtdatetime(sysdate),cnvtdatetime(ta.updt_dt_tm),3))
    tempcurrenthour = datetimepart(cnvtdatetime(sysdate),4), temporghour = datetimepart(cnvtdatetime(
      ta.updt_dt_tm),4)
    IF (((tempcurrenthour BETWEEN 8 AND 20
     AND temporghour BETWEEN 8 AND 20) OR (((tempcurrenthour < 8) OR (tempcurrenthour > 20))
     AND ((tempcurrenthour < 8) OR (tempcurrenthour > 20)) )) )
     log_message = concat(log_message," Prev. task was ordered during this shift; "),
     patienthadtasklast12hour = 1
    ELSE
     log_message = concat(log_message," Prev. task was NOT ordered during this shift; ")
    ENDIF
   ENDIF
  WITH nocounter, maxrec = 1
 ;end select
 CALL echo("Evaluate patients score and customList/task status and set return values")
 IF ((ewreason->l_cnt > 0))
  FOR (ml_rsn_loop = 1 TO ewreason->l_cnt)
   SET ml_rsn_fnd_ind = findstring(ewreason->qual[ml_rsn_loop].s_reason,ms_reason_txt,1,0)
   IF (ml_rsn_fnd_ind=0)
    SET ml_erp_loc = locateval(ml_erp_idx,1,size(ewevent->qual,5),ewreason->qual[ml_rsn_loop].
     f_event_cd,ewevent->qual[ml_erp_idx].event_cd)
    SET ms_reason_txt = concat(ms_reason_txt,evaluate(ml_rsn_loop,1," ","; "),ewreason->qual[
     ml_rsn_loop].s_reason," - ",trim(cnvtstring(ewevent->qual[ml_erp_loc].event_score)),
     evaluate(ewevent->qual[ml_erp_loc].event_score,1," point "," points "))
   ENDIF
  ENDFOR
 ENDIF
 CALL echorecord(ewreason)
 CALL echorecord(ewevent)
 SET log_encntrid = temptotalscore
 SET log_taskassaycd = temptotalscore
 IF (temptotalscore >= qualifyingscore)
  IF (((patientexistsoncustomlist=0) OR (patacttype="transfer")) )
   SET log_message = concat(log_message," add patient to custom list; ")
   SET templogmisc1 = concat(templogmisc1,":ADDPAT:")
  ENDIF
  IF (patienthadtasklast12hour=0)
   SET log_message = concat(log_message," add task to patient; ")
   SET templogmisc1 = concat(templogmisc1,"ADDORD:")
  ENDIF
 ENDIF
 IF (((temptotalscore < qualifyingscore) OR (patacttype IN ("transfer", "discharge"))) )
  IF (patientexistsoncustomlist=1)
   SET log_message = concat(log_message," Remove patient from custom list; ")
   SET templogmisc1 = concat(templogmisc1,":REMOVEPAT:")
  ENDIF
 ENDIF
 IF (patienthasactivetask=1
  AND temptotalscore < qualifyingscore)
  SET log_message = concat(log_message," remove task from patient;")
  SET templogmisc1 = concat(templogmisc1,":REMOVEORD:")
 ENDIF
 SET retval = tempretval
 SET templogmisc1 = concat(templogmisc1,":SCRRSN: ",ms_reason_txt)
 SET log_misc1 = templogmisc1
 CALL echo("We made it to the end of the program with out errors. set RetVal")
 SET retval = 100
 SET log_message = build(log_message," Program complete. retval: ",build(retval)," log_misc1=",
  log_misc1,
  " labScore:",templabscore,"VitalScore:",tempvitalscore,"TotalScore:",
  temptotalscore,"log_clineventid:",log_clineventid,"log_orderid:",log_orderid)
#exit_program
 CALL echo(log_misc1)
 CALL echo(log_message)
 IF (textlen(trim(errmsg,3)) > 0)
  SET log_message = concat(log_message," Error: ",errmsg)
  CALL echo("ERROR**********************")
  CALL echo(errmsg)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    y_pos = 1, msg1 = errmsg, row + 1,
    "{F/1}{CPI/12}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08, mine, time = 5
  ;end select
 ENDIF
 SUBROUTINE validatecodevalue(type,codeset,val)
   SET codeval = 0.0
   SET codeval = uar_get_code_by(value(type),codeset,value(val))
   IF (codeval <= 0)
    SET errmsg = concat("failed finding code_val - type: ",type," codeset:",build(codeset)," val:",
     val)
    GO TO exit_program
   ELSE
    CALL echo(concat("type: ",type," codeset:",build(codeset)," val:",
      val," Code_value=",cnvtstring(codeval)))
   ENDIF
   RETURN(codeval)
 END ;Subroutine
 SUBROUTINE sequence(temp)
   SET early_warning_id = 0
   SELECT INTO "NL:"
    nextid = seq(bhs_eks_seq,nextval)
    FROM dual d
    DETAIL
     early_warning_id = nextid
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET errmsg = "bhs_eks_seq failed"
    GO TO exit_program
   ENDIF
   RETURN(early_warning_id)
 END ;Subroutine
END GO

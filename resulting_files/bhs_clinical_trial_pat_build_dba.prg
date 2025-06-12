CREATE PROGRAM bhs_clinical_trial_pat_build:dba
 PROMPT
  "" = "MINE",
  "Action:" = "REPORT",
  "Existing Patients:" = 0,
  "Patients to add:" = "",
  "# of days for order alert notification:" = 0,
  "# of days for email notification:" = 0,
  "IRB#" = ""
  WITH outdev, action, existingpatients,
  lstperson, alertnotify, inboxnotify,
  irb
 FREE RECORD pat
 RECORD pat(
   1 qual[*]
     2 clinical_trail_person_id = f8
     2 person_id = f8
     2 cmrn = vc
     2 alert_notify_time = i4
     2 inbox_notify_time = i4
 )
 DECLARE promptvalueerr = i2
 DECLARE cmrn = f8 WITH constant(uar_get_code_by("MEANING",4,"CMRN")), protect
 DECLARE tempalertnotifytime = dq8
 DECLARE tempinboxnotifytime = dq8
 DECLARE num = i4 WITH noconstant(0), public
 DECLARE start = i4 WITH noconstant(1), public
 DECLARE updt_dt_tm = dq8
 IF (validate(usermsg)=0)
  DECLARE usermsg = vc
  DECLARE inactivatetrial = i4 WITH public, noconstant(0)
 ENDIF
 SET updt_dt_tm = cnvtdatetime(curdate,curtime3)
 IF (cnvtupper( $ACTION)="*REPORT*")
  SET listcnt = 0
  SELECT INTO "NL:"
   p.name_full_formatted
   FROM bhs_clinical_trial_person b,
    person p,
    person_alias pa
   PLAN (b
    WHERE (b.irb_number= $IRB))
    JOIN (p
    WHERE p.person_id=b.person_id)
    JOIN (pa
    WHERE pa.person_id=p.person_id
     AND pa.person_alias_type_cd=cmrn
     AND pa.active_ind=1)
   ORDER BY b.updt_dt_tm DESC, p.name_full_formatted
   DETAIL
    pos = locateval(num,start,size(pat->qual,5),b.person_id,pat->qual[num].person_id)
    IF (pos <= 0)
     listcnt = (listcnt+ 1), stat = alterlist(pat->qual,listcnt), pat->qual[listcnt].
     clinical_trail_person_id = b.clinical_trial_person_id,
     pat->qual[listcnt].person_id = b.person_id, pat->qual[listcnt].cmrn = trim(pa.alias,3),
     temporderalertdays =
     IF (datetimecmp(datetimeadd(cnvtdatetime(b.alert_notify_start_dt_tm),b.alert_notify_length),
      cnvtdatetime(curdate,235959)) > 0) datetimecmp(datetimeadd(cnvtdatetime(b
         .alert_notify_start_dt_tm),b.alert_notify_length),cnvtdatetime(curdate,235959))
     ELSE 0
     ENDIF
     ,
     tempinboxalertdays =
     IF (datetimecmp(datetimeadd(cnvtdatetime(b.email_notify_start_dt_tm),b.email_notify_length),
      cnvtdatetime(curdate,235959)) > 0) datetimecmp(datetimeadd(cnvtdatetime(b
         .email_notify_start_dt_tm),b.email_notify_length),cnvtdatetime(curdate,235959))
     ELSE 0
     ENDIF
     , pat->qual[listcnt].alert_notify_time = temporderalertdays, pat->qual[listcnt].
     inbox_notify_time = tempinboxalertdays
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Sorry, no data was found for this trial", col 0, "{PS/792 0 translate 90 rotate/}",
     y_pos = 18, row + 1, "{F/1}{CPI/12}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1
    WITH dio = 08, mine, time = 5
   ;end select
  ELSE
   CALL echorecord(pat)
   SELECT INTO  $OUTDEV
    active =
    IF (b.active_ind < 1) "No"
    ELSE "Yes"
    ENDIF
    , p.name_full_formatted, birth_date = format(cnvtdatetime(p.birth_dt_tm),"MM/DD/YYYY;;q"),
    cmrn = pat->qual[d.seq].cmrn, days_left_order_alert =
    IF (b.active_ind > 0) pat->qual[d.seq].alert_notify_time
    ELSE 0
    ENDIF
    , days_left_inbox_alert =
    IF (b.active_ind > 0) pat->qual[d.seq].inbox_notify_time
    ELSE 0
    ENDIF
    ,
    last_updt_by = pl.name_full_formatted, last_updt_dt_tm = format(b.updt_dt_tm,";;q")
    FROM (dummyt d  WITH seq = size(pat->qual,5)),
     bhs_clinical_trial_person b,
     person p,
     prsnl pl
    PLAN (d)
     JOIN (b
     WHERE (b.clinical_trial_person_id=pat->qual[d.seq].clinical_trail_person_id))
     JOIN (p
     WHERE p.person_id=b.person_id)
     JOIN (pl
     WHERE pl.person_id=b.updt_id)
    ORDER BY b.active_ind DESC, p.name_full_formatted
    WITH format, separator = " "
   ;end select
  ENDIF
 ELSE
  SET temppatientlist = trim( $LSTPERSON,3)
  SET temppatientlist = replace(temppatientlist,"VALUE","")
  SET temppatientlist = replace(temppatientlist,"(","")
  SET temppatientlist = replace(temppatientlist,")","")
  CALL echo(build("###",temppatientlist))
  SET newpatientid = 0
  CALL echo("locate new person ID")
  SELECT
   b.clinical_trial_person_id
   FROM bhs_clinical_trial_person b
   WHERE b.clinical_trial_person_id > 0
   ORDER BY b.clinical_trial_person_id DESC
   DETAIL
    newpatientid = b.clinical_trial_person_id
   WITH maxrec = 1
  ;end select
  IF (curqual=0)
   SET newpatientid = 1
  ENDIF
  CALL echo(build("newPatientId:",newpatientid))
  IF (cnvtupper( $ACTION)="ADD")
   SET x = 0
   WHILE (x < 100
    AND x != 100)
     SET x = (x+ 1)
     CALL echo(build("###",temppatientlist))
     SET tempval = trim(piece(temppatientlist,",",x,"1",0),3)
     CALL echo(tempval)
     IF (tempval="1"
      AND x=1)
      SET stat = alterlist(pat->qual,x)
      SET pat->qual[x].person_id = cnvtreal(trim(temppatientlist,3))
     ELSEIF (textlen(tempval) > 1
      AND ((tempval != "1") OR (tempval="1"
      AND x=1)) )
      SET stat = alterlist(pat->qual,x)
      SET pat->qual[x].person_id = cnvtreal(tempval)
     ELSE
      SET x = 101
     ENDIF
     IF (x < 101)
      SET pat->qual[x].alert_notify_time =
      IF (( $ALERTNOTIFY < 1)) 0
      ELSE  $ALERTNOTIFY
      ENDIF
      SET pat->qual[x].inbox_notify_time =
      IF (( $INBOXNOTIFY < 1)) 0
      ELSE  $INBOXNOTIFY
      ENDIF
     ENDIF
   ENDWHILE
   CALL echorecord(pat)
   IF (size(pat->qual,5) > 0)
    CALL echo("Add patients to trial")
    FOR (x = 1 TO size(pat->qual,5))
     SELECT
      *
      FROM bhs_clinical_trial_person b
      WHERE (b.irb_number= $IRB)
       AND (b.person_id=pat->qual[x].person_id)
       AND b.active_ind=1
      WITH nocounter
     ;end select
     IF (curqual <= 0)
      CALL echo("Adding patient")
      SET newpatientid = (newpatientid+ 1)
      INSERT  FROM bhs_clinical_trial_person b
       SET b.clinical_trial_person_id = newpatientid, b.active_ind = 1, b.irb_number =  $IRB,
        b.alert_notify_length = pat->qual[x].alert_notify_time, b.alert_notify_start_dt_tm =
        cnvtdatetime(curdate,0), b.email_notify_length = pat->qual[x].inbox_notify_time,
        b.email_notify_start_dt_tm = cnvtdatetime(curdate,0), b.person_id = pat->qual[x].person_id, b
        .updt_dt_tm = cnvtdatetime(updt_dt_tm),
        b.updt_id = reqinfo->updt_id
      ;end insert
      IF (curqual=0)
       CALL echo("Inactivation failed")
       SET usermsg = "0Failed to insert patient in database"
       GO TO exit_script
      ENDIF
     ELSE
      SET usermsg = concat("0One or more 'patients to add' already exist on the trial.",char(13),
       "Remove duplicate patient(s) and try again")
      GO TO exit_script
     ENDIF
    ENDFOR
    IF (curqual > 0)
     SET usermsg = "1Patient(s) have been added to the trial"
     COMMIT
    ENDIF
   ELSE
    SET usermsg = "0Failed: could not find patients in list"
   ENDIF
  ELSEIF (((cnvtupper( $ACTION)="MODIFY") OR (cnvtupper( $ACTION)="INACTIVATE")) )
   SET tempclinicaltrailpatid = 0.0
   SET tempalertnotify = 0
   SET tempinboxnotify = 0
   SELECT
    b.clinical_trial_person_id
    FROM bhs_clinical_trial_person b
    WHERE (b.irb_number= $IRB)
     AND (b.person_id= $EXISTINGPATIENTS)
     AND b.active_ind=1
    DETAIL
     tempclinicaltrailpatid = b.clinical_trial_person_id
     IF (( $ALERTNOTIFY < 0))
      tempalertnotify = b.alert_notify_length, tempalertnotifytime = cnvtdatetime(b
       .alert_notify_start_dt_tm)
     ELSE
      tempalertnotify =  $ALERTNOTIFY, tempalertnotifytime = cnvtdatetime(curdate,0)
     ENDIF
     IF (( $INBOXNOTIFY < 0))
      tempinboxnotify = b.email_notify_length, tempinboxnotifytime = cnvtdatetime(b
       .email_notify_start_dt_tm)
     ELSE
      tempinboxnotify =  $INBOXNOTIFY, tempinboxnotifytime = cnvtdatetime(curdate,0)
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SET usermsg = "0Failed: could not find patient in list"
    GO TO exit_script
   ENDIF
   CALL echo("inactivating old row")
   UPDATE  FROM bhs_clinical_trial_person b
    SET b.active_ind = 0
    WHERE b.clinical_trial_person_id=tempclinicaltrailpatid
    WITH nocounter
   ;end update
   IF (curqual <= 0)
    ROLLBACK
    SET usermsg = "0Failed: update current patient information"
    GO TO exit_script
   ENDIF
   CALL echo("Inserting new values")
   INSERT  FROM bhs_clinical_trial_person b
    SET b.clinical_trial_person_id = (newpatientid+ 1), b.active_ind =
     IF (cnvtupper( $ACTION)="INACTIVATE") - (1)
     ELSE 1
     ENDIF
     , b.irb_number =  $IRB,
     b.alert_notify_length = tempalertnotify, b.alert_notify_start_dt_tm = cnvtdatetime(
      tempalertnotifytime), b.email_notify_length = tempinboxnotify,
     b.email_notify_start_dt_tm = cnvtdatetime(tempinboxnotifytime), b.person_id =  $EXISTINGPATIENTS,
     b.updt_dt_tm = cnvtdatetime(updt_dt_tm),
     b.updt_id = reqinfo->updt_id
   ;end insert
   IF (curqual=0)
    SET usermsg =
    IF (cnvtupper( $ACTION)="INACTIVATE") "0Failed to inactivate patient info"
    ELSE "0Failed to insert new patient info"
    ENDIF
    ROLLBACK
    GO TO exit_script
   ELSE
    SET usermsg =
    IF (cnvtupper( $ACTION)="INACTIVATE") "1Patient has been successfully inactivated"
    ELSE "1Patient information has been successfully updated"
    ENDIF
   ENDIF
   IF (inactivatetrial=0)
    COMMIT
   ENDIF
  ENDIF
 ENDIF
#exit_script
 CALL echo(usermsg)
 IF (( $ACTION != "REPORT"))
  SET ccl_prompt_api_disable = 1
  SET ccl_prompt_api_misc = 1
  EXECUTE ccl_prompt_api_dataset "misc"
  SET stat = setmiscsize(_out_,1)
  SET stat = setmiscrecord(_out_,1,usermsg)
  SET stat = setstatus("s")
 ENDIF
END GO

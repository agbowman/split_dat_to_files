CREATE PROGRAM bhs_clinical_trial_build:dba
 PROMPT
  "" = "MINE",
  "Action" = "",
  "IRB # (EX: IRB06-008):" = "",
  "Title:" = "",
  "Abbreviated title:" = "",
  "Principal investigator:" = "",
  "Phone number:" = "",
  "Pager number:" = "",
  "Email address (Jon.Smith@bhs.org, Jane.Smith@bhs.org):" = "",
  "Special instructions for alert:" = "",
  "           Inv. Pharm. to be notified of admits, transfers, etc." = 0,
  "'Execute' button is not used in this program" = ""
  WITH outdev, action, irb,
  title, abbtitle, pi,
  phone, pager, contactemail,
  special, pharmchk, executebutton
 DECLARE promptvalueerr = i2 WITH private
 DECLARE irbinput = vc
 DECLARE inserttrialrowind = i4 WITH noconstant(0)
 DECLARE tempmedlist = vc WITH noconstant(" ")
 DECLARE usermsg = vc WITH public
 DECLARE inactivatetrial = i4 WITH public, noconstant(0)
 DECLARE updt_dt_tm = dq8 WITH public
 SET irbinput = replace(check(trim( $IRB,3)),"ABCDEFGHIJKLMNOPQRSTUVWXYQ1234567890-",
  "ABCDEFGHIJKLMNOPQRSTUVWXYQ1234567890-",3)
 SET actioninput = trim( $ACTION,3)
 SET updt_dt_tm = cnvtdatetime(curdate,curtime3)
 RECORD trial(
   1 qual[*]
     2 rowid = f8
 )
 SET qualcnt = 0
 IF (actioninput="REPORT")
  CALL echo("Printing report")
  SELECT INTO "NL:"
   b.clinical_trial_id
   FROM bhs_clinical_trial b
   PLAN (b
    WHERE ((b.irb_number=irbinput
     AND irbinput != "-1") OR (irbinput="-1"
     AND b.clinical_trial_id > 0)) )
   ORDER BY b.irb_number, b.clinical_trial_id DESC, b.active_ind DESC
   HEAD b.irb_number
    qualcnt = (qualcnt+ 1), stat = alterlist(trial->qual,qualcnt), trial->qual[qualcnt].rowid = b
    .clinical_trial_id
  ;end select
  SELECT
   *
   FROM bhs_clinical_trial
   WITH nocounter, format, separator = " "
  ;end select
  IF (curqual <= 0)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Sorry, no data was found", col 0, "{PS/792 0 translate 90 rotate/}",
     y_pos = 18, row + 1, "{F/1}{CPI/12}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1
    WITH dio = 08, mine, time = 5
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    b.active_ind, b.irb_number, b.title,
    b.short_title, b.phone_number, b.pager_number,
    b.email_address, b.instructions, b.pharmacy_notify_ind,
    updated_by = p.name_full_formatted, last_updated = format(cnvtdatetime(b.updt_dt_tm),";;q")
    FROM bhs_clinical_trial b,
     prsnl p,
     (dummyt d  WITH seq = qualcnt)
    PLAN (d)
     JOIN (b
     WHERE (b.clinical_trial_id=trial->qual[d.seq].rowid))
     JOIN (p
     WHERE p.person_id=outerjoin(b.pi_id))
    ORDER BY b.active_ind DESC, b.irb_number
    WITH format, separator = " ", check
   ;end select
  ENDIF
  GO TO exit_script
 ENDIF
 IF (actioninput="ADD")
  SET temprowid = 0
  SELECT
   b.irb_number
   FROM bhs_clinical_trial b
   WHERE b.irb_number=irbinput
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET usermsg = "0An Error has occurred. There is already a trial with this IRB#"
   GO TO exit_script
  ENDIF
  CALL echo("*****AddTrial*****")
  SET inserttrialrowind = 1
 ELSEIF (((actioninput="MODIFY") OR (actioninput="INACTIVATE")) )
  SET temptrialid = 0
  SET tempactiveind = 0
  SELECT
   b.irb_number
   FROM bhs_clinical_trial b
   WHERE b.irb_number=irbinput
   ORDER BY b.irb_number, b.clinical_trial_id DESC
   HEAD b.irb_number
    temptrialid = b.clinical_trial_id, tempactiveind = b.active_ind
   WITH nocounter
  ;end select
  IF (actioninput="MODIFY")
   SET inserttrialrowind = 1
  ENDIF
  IF (curqual <= 0)
   SET usermsg = "0An Error has occurred. There is no trial with this IRB#"
   GO TO exit_script
  ENDIF
  IF (tempactiveind=1)
   UPDATE  FROM bhs_clinical_trial b
    SET b.active_ind = 0
    WHERE b.clinical_trial_id=temptrialid
   ;end update
   IF (curqual <= 0)
    SET usermsg = "0An Error has occurred. Failed to inactivate old row."
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET newtrialid = 0
 SELECT
  b.clinical_trial_id
  FROM bhs_clinical_trial b
  WHERE b.clinical_trial_id > 0
  ORDER BY b.clinical_trial_id DESC
  DETAIL
   newtrialid = (b.clinical_trial_id+ 1)
  WITH maxrec = 1
 ;end select
 IF (curqual=0)
  SET usermsg = "0Failed to create new row Index"
  GO TO exit_script
 ENDIF
 INSERT  FROM bhs_clinical_trial b
  SET b.active_ind =
   IF (actioninput="INACTIVATE") - (1)
   ELSE 1
   ENDIF
   , b.clinical_trial_id = newtrialid, b.irb_number = irbinput,
   b.title =  $TITLE, b.short_title =  $ABBTITLE, b.pi_id =  $PI,
   b.phone_number =  $PHONE, b.pager_number =
   IF (textlen(trim( $PAGER,3)) <= 0) " "
   ELSE  $PAGER
   ENDIF
   , b.email_address =  $CONTACTEMAIL,
   b.instructions =  $SPECIAL, b.updt_id = reqinfo->updt_id, b.updt_dt_tm = cnvtdatetime(updt_dt_tm),
   b.pharmacy_notify_ind =  $PHARMCHK
  WITH nocounter
 ;end insert
 SELECT
  b.irb_number
  FROM bhs_clinical_trial b
  WHERE b.irb_number=irbinput
   AND b.active_ind=1
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET usermsg = "1Trial has been successfully created/modified"
 ELSE
  SET usermsg = "0Failed to create/modify trial information in the database"
 ENDIF
 IF (actioninput="INACTIVATE")
  SET inactivatetrial = 1
  CALL echo("locating medications to inactivate")
  SET tempcnt = 0
  SELECT
   b.irb_number
   FROM bhs_clinical_trial_meds bm
   PLAN (bm
    WHERE bm.irb_number=irbinput
     AND bm.active_ind=1)
   DETAIL
    tempcnt = (tempcnt+ 1)
    IF (tempcnt > 1)
     tempmedlist = build2(tempmedlist,",",cnvtstring(bm.catalog_cd))
    ELSE
     tempmedlist = cnvtstring(bm.catalog_cd)
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL echo("Calling med script to inactiave meds")
   CALL echo(tempmedlist)
   EXECUTE bhs_clinical_trial_med_build "MINE", "REMOVE", 0,
   "", 0, tempmedlist,
   irbinput
   IF (substring(1,1,usermsg)="0")
    GO TO exit_script
   ENDIF
  ENDIF
  RECORD patlist(
    1 qual[*]
      2 person_id = f8
  )
  SET patcnt = 0
  SELECT INTO "NL:"
   FROM bhs_clinical_trial_person b
   WHERE b.irb_number=irbinput
    AND b.active_ind=1
   DETAIL
    patcnt = (patcnt+ 1), stat = alterlist(patlist->qual,patcnt), patlist->qual[patcnt].person_id = b
    .person_id
   WITH nocounter
  ;end select
  IF (curqual > 0)
   FOR (x = 1 TO patcnt)
    EXECUTE bhs_clinical_trial_pat_build "MINE", "INACTIVATE", patlist->qual[x].person_id,
    "", - (1), - (1),
    irbinput
    IF (substring(1,1,usermsg)="0")
     SET usermsg = "0Failed to inactivate one or more patients -  rolling back changes"
     SET x = patcnt
     GO TO exit_script
    ENDIF
   ENDFOR
  ENDIF
  SET usermsg = "1Trial has been successfully inactivated"
 ENDIF
 COMMIT
#exit_script
 IF (actioninput != "REPORT")
  SET ccl_prompt_api_disable = 1
  SET ccl_prompt_api_misc = 1
  EXECUTE ccl_prompt_api_dataset "misc"
  SET stat = setmiscsize(_out_,1)
  SET stat = setmiscrecord(_out_,1,usermsg)
  SET stat = setstatus("s")
 ENDIF
END GO

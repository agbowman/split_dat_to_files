CREATE PROGRAM bhs_clinical_trial_med_build:dba
 PROMPT
  "" = "MINE",
  "Action" = "REPORT",
  "Existing medication(s):" = 0,
  "Contraindicated medication to add:" = "",
  "Add medication(s):" = "",
  "Medication list:" = "",
  "IRB" = ""
  WITH outdev, action, existingdrugs,
  drug, adddrugs, adddrugslist,
  irb
 CALL echo("Inside bhs_clinical_trial_med_build")
 DECLARE promptvalueerr = i2
 DECLARE newtrialid = f8
 IF (validate(usermsg)=0)
  DECLARE usermsg = vc
  DECLARE inactivatetrial = i4 WITH public, noconstant(0)
 ENDIF
 IF (validate(updt_dt_tm)=0)
  DECLARE updt_dt_tm = dq8
  SET updt_dt_tm = cnvtdatetime(curdate,curtime3)
  DECLARE irbinput = vc
  SET irbinput = trim(cnvtupper( $IRB),3)
 ENDIF
 RECORD druglist(
   1 qual[*]
     2 catalog_cd = f8
 )
 SET x = 0
 WHILE (x < 100
  AND x != 100)
   SET x = (x+ 1)
   SET tempval = trim(piece( $ADDDRUGSLIST,",",x,"1",0),3)
   CALL echo(tempval)
   IF (tempval="1"
    AND x=1)
    SET stat = alterlist(druglist->qual,x)
    SET druglist->qual[x].catalog_cd = cnvtreal(trim( $ADDDRUGSLIST,3))
   ELSEIF (textlen(tempval) > 1
    AND ((tempval != "1") OR (tempval="1"
    AND x=1)) )
    SET stat = alterlist(druglist->qual,x)
    SET druglist->qual[x].catalog_cd = cnvtreal(tempval)
   ELSE
    SET x = 100
   ENDIF
 ENDWHILE
 CALL echorecord(druglist)
 SET newtrialid = 0
 CALL echo("locate trial ID")
 SELECT
  b.clinical_trial_med_id
  FROM bhs_clinical_trial_meds b
  WHERE b.clinical_trial_med_id > 0
  ORDER BY b.clinical_trial_med_id DESC
  DETAIL
   newtrialid = b.clinical_trial_med_id
  WITH maxrec = 1
 ;end select
 IF (curqual=0)
  SET newtrialid = 1
 ENDIF
 IF (cnvtupper( $ACTION)="ADD")
  CALL echo("Adding meds")
  FOR (x = 1 TO size(druglist->qual,5))
    CALL echo("insert")
    SET newtrialid = (newtrialid+ 1)
    INSERT  FROM bhs_clinical_trial_meds b
     SET b.clinical_trial_med_id = newtrialid, b.active_ind = 1, b.catalog_cd = druglist->qual[x].
      catalog_cd,
      b.irb_number =  $IRB, b.synonym_id = 0, b.updt_dt_tm = cnvtdatetime(updt_dt_tm),
      b.updt_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET usermsg = "0Failed to insert new med(s)"
     GO TO exit_script
    ENDIF
  ENDFOR
  SET usermsg = "1New Medication(s) have been added to the trial"
  COMMIT
 ELSEIF (cnvtupper( $ACTION)="REMOVE")
  CALL echo("Removing meds")
  FOR (x = 1 TO size(druglist->qual,5))
    SET newtrialid = (newtrialid+ 1)
    CALL echo("Update to inactive")
    UPDATE  FROM bhs_clinical_trial_meds b
     SET b.active_ind = 0
     WHERE (b.irb_number= $IRB)
      AND (b.catalog_cd=druglist->qual[x].catalog_cd)
      AND b.active_ind=1
     WITH nocounter
    ;end update
    INSERT  FROM bhs_clinical_trial_meds b
     SET b.clinical_trial_med_id = newtrialid, b.active_ind = - (1), b.catalog_cd = druglist->qual[x]
      .catalog_cd,
      b.irb_number =  $IRB, b.synonym_id = 0, b.updt_dt_tm = cnvtdatetime(updt_dt_tm),
      b.updt_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL echo("Inactivation failed")
     SET usermsg = "0Failed to inactivate row(s)"
     GO TO exit_script
    ENDIF
  ENDFOR
  SET usermsg = "1Medication(s) have been removed from the trial"
  IF (inactivatetrial=0)
   COMMIT
  ENDIF
 ELSEIF (cnvtupper( $ACTION)="*REPORT*")
  SELECT INTO  $OUTDEV
   b.irb_number, oc.primary_mnemonic, ocs.mnemonic,
   last_updt_by = pl.name_full_formatted, last_updt_dt_tm = format(b.updt_dt_tm,";;q")
   FROM bhs_clinical_trial_meds b,
    order_catalog oc,
    order_catalog_synonym ocs,
    prsnl pl
   PLAN (b
    WHERE (b.irb_number= $IRB)
     AND b.active_ind=1)
    JOIN (oc
    WHERE oc.catalog_cd=b.catalog_cd
     AND oc.active_ind=1)
    JOIN (ocs
    WHERE ocs.catalog_cd=oc.catalog_cd
     AND ocs.active_ind=1)
    JOIN (pl
    WHERE pl.person_id=b.updt_id)
   ORDER BY oc.catalog_cd, ocs.mnemonic
   WITH nocounter, format, separator = " "
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

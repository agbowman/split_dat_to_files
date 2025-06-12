CREATE PROGRAM bhs_sfe_outcomes_summarybuild:dba
 PROMPT
  "Defaut Prompt for any error messages:" = "MINE",
  "Beginning Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Location:" = 0,
  "Select Ambulatory Practice / Nurse Unit:" = 0,
  "Enter email address, or select  report  or spread view:" = "report"
  WITH outdev, bdate, edate,
  location, aunit, email
 IF (( $LOCATION=7)
  AND ( $AUNIT <= 0))
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "You must select an ambulatory practice / nurse unit", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_program
 ENDIF
 FREE RECORD sfeinfo
 RECORD sfeinfo(
   1 location = vc
   1 smokingcessationcnt = i4
   1 smokedlast12months = i4
   1 notsmokedlast12months = i4
   1 hasneversmoked = i4
   1 smokernoconsent = i4
   1 caregivernosmoked = i4
   1 cargiversmokedlast12 = i4
   1 unabletoobtain = i4
   1 patcresourceinfogiven = i4
   1 patcresourceinfonotgiven = i4
   1 patreqestreferral = i4
   1 patagreetocounseling = i4
   1 notreadytoquit = i4
   1 refusedcounseling = i4
   1 clinicalcondition = i4
   1 personcnt = i4
   1 patrequestnrt = i4
   1 patreqnrtgotnrt = i4
   1 patnoreqnrtgotnrt = i4
   1 smokintakereferformcnt = i4
   1 outsmokintakereferformcnt = i4
   1 smokhistandmangform = i4
   1 bmcpatientwantsrefer = i4
   1 mlhfmcpatientwantsrefer = i4
   1 bmcpatientwantsrefercompl = i4
   1 mlhfmcpatientwantsrefercompl = i4
   1 referralcnt = i4
   1 quitworks = i4
   1 freedomfromsmokcnt = i4
   1 individualcounselingcnt = i4
   1 pharmacotherapy = i4
   1 selfhelp = i4
   1 telephonecounseling = i4
   1 other = i4
   1 none = i4
   1 detailqual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 requestnrt = i4
   1 qual[*]
     2 person_id = f8
     2 eventtitle = vc
     2 event_cd = f8
     2 formtitle = vc
   1 summary[*]
     2 name = vc
     2 attending = vc
     2 smokeiocompdt = vc
     2 acctnum = vc
     2 addmindt = vc
 )
 FREE RECORD output
 RECORD output(
   1 qual[*]
     2 col1 = vc
     2 col2 = vc
 )
 DECLARE any_loc_ind = c1 WITH constant(substring(1,1,reflect(parameter(4,0)))), public
 DECLARE smokingcessation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"SMOKINGCESSATION")),
 protect
 DECLARE assessmentstage = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ASSESSMENTSTAGE")),
 protect
 DECLARE pharmacotherapypastuse = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PHARMACOTHERAPYPASTUSE")), protect
 DECLARE healthrisks = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"HEALTHRISKS")), protect
 DECLARE yearssmoking = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"YEARSSMOKING")), protect
 DECLARE cigarettesperday = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"CIGARETTESPERDAY")),
 protect
 DECLARE numberofquittingattempts = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "NUMBEROFQUITTINGATTEMPTS")), protect
 DECLARE numberofsmokersathome = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "NUMBEROFSMOKERSATHOME")), protect
 DECLARE smokingreferral = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"SMOKINGREFERRAL")),
 protect
 DECLARE smokingreferraloutcome = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SMOKINGREFERRALOUTCOME")), protect
 DECLARE mayquitworksleaveamessage = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MAYQUITWORKSLEAVEAMESSAGE")), protect
 DECLARE emailaddress = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"EMAILADDRESS")), protect
 DECLARE languagepreferred = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"LANGUAGEPREFERRED")),
 protect
 DECLARE callpreferredtime = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"CALLPREFERREDTIME")),
 protect
 DECLARE smokingintakereferralform = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SMOKINGINTAKEREFERRALFORM")), protect
 DECLARE ambulatoryintakehistoryform = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "AMBULATORYINTAKEHISTORYFORM")), protect
 DECLARE patientwantsnrtduringadmission = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PATIENTWANTSNRTDURINGADMISSION")), protect
 DECLARE patientwantsreferraltoquitsmoking = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PATIENTWANTSREFERRALTOQUITSMOKING")), protect
 DECLARE smokinghistoryandmanagementform = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SMOKINGHISTORYANDMANAGEMENTFORM")), protect
 DECLARE smokingcessationresourcesinformation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SMOKINGCESSATIONRESOURCESINFORMATION")), protect
 DECLARE smokingcessationreferral = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SMOKINGCESSATIONREFERRAL")), protect
 DECLARE smokingreferraloutpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SMOKINGREFERRALOUTPATIENT")), protect
 DECLARE cpgnicotinereplacementtherapy = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "CPGNICOTINEREPLACEMENTTHERAPY")), protect
 DECLARE nicotine = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"NICOTINE")), protect
 DECLARE bupropion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"BUPROPION")), protect
 DECLARE varenicline = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"VARENICLINE")), protect
 DECLARE patientwantsreferralquitsmokingtask = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "PATIENTWANTSREFERRALQUITSMOKING")), protect
 DECLARE patientwantsreferraltoquitsmokingtask = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "PATIENTWANTSREFERRALTOQUITSMOKING")), protect
 DECLARE taskcomplete = f8 WITH constant(uar_get_code_by("DISPLAYKEY",79,"COMPLETE")), protect
 DECLARE attenddoc = f8 WITH constant(uar_get_code_by("MEANING",333,"ATTENDDOC")), protect
 DECLARE fin_nbr = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE bmc = f8 WITH constant(673936.00), protect
 DECLARE bfmc = f8 WITH constant(673937.00), protect
 DECLARE bmlh = f8 WITH constant(673938.00), protect
 DECLARE bmcinptpsych = f8 WITH constant(679549.00), protect
 DECLARE bfmcinptpsych = f8 WITH constant(679586.00), protect
 DECLARE mineventid = f8
 DECLARE maxeventid = f8
 DECLARE nrtgiven = i2
 SET beg_date_qual = cnvtdatetime(build2( $BDATE," 00:00:00"))
 SET end_date_qual = cnvtdatetime(build2( $EDATE," 23:59:59"))
 SET end_date_qual_max = cnvtdatetime(build2( $EDATE," 00:00:00"))
 CALL echo(format(cnvtdatetime(beg_date_qual),";;q"))
 CALL echo(format(cnvtdatetime(end_date_qual),";;q"))
 CALL echo(format(cnvtdatetime(end_date_qual_max),";;q"))
 CALL echo(build("maxEventId:",maxeventid))
 IF (datetimediff(end_date_qual,beg_date_qual) > 31)
  CALL echo("Date range > 31")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is larger than 31 days.", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_program
 ELSEIF (datetimediff(end_date_qual,beg_date_qual) < 0)
  CALL echo("Date range < 0")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is incorrect", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08
  ;end select
  GO TO exit_program
 ENDIF
 DECLARE var_output = vc
 DECLARE email_ind = i4
 SET email_ind = 4
 IF (findstring("@", $EMAIL) > 0)
  SET email_ind = 1
  SET var_output = "bhssfeoutcomes"
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
 ENDIF
 SET smokingcessationcnt = 0
 SET smokedlast12months = 0
 SET notsmokedlast12months = 0
 SET hasneversmoked = 0
 SET patcresourceinfogiven = 0
 SET patcresourceinfonotgiven = 0
 SET patrequestnrt = 0
 SET patreqestreferral = 0
 SET patagreetocounseling = 0
 SET personcnt = 0
 SET smokintakereferformcnt = 0
 SET outsmokintakereferformcnt = 0
 SET sfecnt = 0
 SET sumcnt = 0
 SET count = 0
 SET sfeinfo->location =
 IF (( $LOCATION=1)) "Baystate Health System"
 ELSEIF (( $LOCATION=2)) "CIS Hospital"
 ELSEIF (( $LOCATION=3)) "CIS Office"
 ELSEIF (( $AUNIT > 0)) cnvtstring( $AUNIT)
 ELSEIF (( $LOCATION=4)) "BMC"
 ELSEIF (( $LOCATION=5)) "BMLH"
 ELSEIF (( $LOCATION=6)) "BFMC"
 ELSEIF (( $LOCATION=7)) "Ambulatory Practice"
 ELSE ""
 ENDIF
 SELECT INTO  $OUTDEV
  ce.person_id, ce.event_cd
  FROM clinical_event ce,
   encounter e,
   person p,
   encntr_alias ea
  PLAN (ce
   WHERE ce.clinsig_updt_dt_tm
    AND ce.result_status_cd BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
    AND ((ce.event_cd+ 0) IN (smokingcessation, assessmentstage, pharmacotherapypastuse, healthrisks,
   yearssmoking,
   cigarettesperday, numberofquittingattempts, numberofsmokersathome, smokingreferral,
   smokingcessationreferral,
   smokingreferraloutpatient, smokingreferraloutcome, mayquitworksleaveamessage, emailaddress,
   languagepreferred,
   callpreferredtime, smokingintakereferralform, ambulatoryintakehistoryform,
   patientwantsnrtduringadmission, patientwantsreferraltoquitsmoking,
   smokinghistoryandmanagementform, smokingcessationresourcesinformation)))
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND (( EXISTS (
   (SELECT
    el.encntr_id
    FROM encntr_loc_hist el
    WHERE el.encntr_id=ce.encntr_id
     AND ce.clinsig_updt_dt_tm BETWEEN el.beg_effective_dt_tm AND el.end_effective_dt_tm
     AND (((el.loc_nurse_unit_cd= $AUNIT)
     AND ( $AUNIT > 0)) OR (( $AUNIT=0)
     AND ((( $LOCATION=1)
     AND el.loc_facility_cd > 0) OR (((( $LOCATION=2)
     AND el.loc_facility_cd IN (bmc, bfmc, bmlh, bmcinptpsych, bfmcinptpsych)) OR (((( $LOCATION=3)
     AND  NOT (el.loc_facility_cd IN (bmc, bfmc, bmlh, bmcinptpsych, bfmcinptpsych))) OR ((((
     $LOCATION=4)
     AND el.loc_facility_cd IN (bmc, bmcinptpsych)) OR (((( $LOCATION=5)
     AND el.loc_facility_cd=bmlh) OR (((( $LOCATION=6)
     AND el.loc_facility_cd IN (bfmc, bfmcinptpsych)) OR (( $LOCATION=7))) )) )) )) )) )) )) ))) OR (
   (((e.loc_nurse_unit_cd= $AUNIT)
    AND ( $AUNIT > 0)) OR (( $AUNIT=0)
    AND ((( $LOCATION=1)
    AND e.loc_facility_cd > 0) OR (((( $LOCATION=2)
    AND e.loc_facility_cd IN (bmc, bfmc, bmlh, bmcinptpsych, bfmcinptpsych)) OR (((( $LOCATION=3)
    AND  NOT (e.loc_facility_cd IN (bmc, bfmc, bmlh, bmcinptpsych, bfmcinptpsych))) OR (((( $LOCATION
   =4)
    AND e.loc_facility_cd IN (bmc, bmcinptpsych)) OR (((( $LOCATION=5)
    AND e.loc_facility_cd=bmlh) OR (((( $LOCATION=6)
    AND e.loc_facility_cd IN (bfmc, bfmcinptpsych)) OR (( $LOCATION=7))) )) )) )) )) )) )) )) )
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(ce.encntr_id)
    AND ea.encntr_alias_type_cd=outerjoin(fin_nbr)
    AND ea.active_ind=outerjoin(1))
   JOIN (p
   WHERE p.person_id=outerjoin(ce.person_id))
  ORDER BY ce.person_id, ce.event_cd
  HEAD REPORT
   stat = alterlist(sfeinfo->detailqual,100), count = 0
  HEAD ce.person_id
   sfeinfo->personcnt = (sfeinfo->personcnt+ 1), col + 1,
   "_________________________________________________________________________",
   row + 1, count = (count+ 1)
   IF (mod(count,100)=1
    AND count != 1)
    stat = alterlist(sfeinfo->detailqual,(count+ 100))
   ENDIF
   CALL echo(ce.person_id),
   CALL echo(ce.encntr_id), sfeinfo->detailqual[count].person_id = ce.person_id,
   sfeinfo->detailqual[count].encntr_id = ce.encntr_id
  DETAIL
   sfecnt = (sfecnt+ 1), stat = alterlist(sfeinfo->qual,sfecnt), sfeinfo->qual[sfecnt].person_id = ce
   .person_id,
   sfeinfo->qual[sfecnt].eventtitle = ce.result_val, sfeinfo->qual[sfecnt].event_cd = ce.event_cd
   IF (ce.event_cd=smokingcessation)
    sfeinfo->smokingcessationcnt = (sfeinfo->smokingcessationcnt+ 1)
    IF (cnvtupper(ce.result_val)="PATIENT HAS NOT SMOKED IN THE LAST 12 MONTHS")
     sfeinfo->notsmokedlast12months = (sfeinfo->notsmokedlast12months+ 1)
    ELSEIF (cnvtupper(ce.result_val)="PATIENT HAS SMOKED IN THE LAST 12 MONTHS")
     sfeinfo->smokedlast12months = (sfeinfo->smokedlast12months+ 1)
    ELSEIF (cnvtupper(ce.result_val)="PATIENT HAS NEVER SMOKED")
     sfeinfo->hasneversmoked = (sfeinfo->hasneversmoked+ 1)
    ELSEIF (cnvtupper(ce.result_val)="PATIENT IDENTIFIED AS SMOKER/UNABLE TO CONSENT NRT/CESSATION")
     sfeinfo->smokernoconsent = (sfeinfo->smokernoconsent+ 1)
    ELSEIF (cnvtupper(ce.result_val)="CAREGIVER HAS NOT SMOKED IN THE LAST 12 MONTHS")
     sfeinfo->caregivernosmoked = (sfeinfo->caregivernosmoked+ 1)
    ELSEIF (cnvtupper(ce.result_val)="CAREGIVER HAS SMOKED IN THE LAST 12 MONTHS")
     sfeinfo->cargiversmokedlast12 = (sfeinfo->cargiversmokedlast12+ 1)
    ELSEIF (cnvtupper(ce.result_val)="UNABLE TO OBTAIN")
     sfeinfo->unabletoobtain = (sfeinfo->unabletoobtain+ 1)
    ENDIF
   ELSEIF (ce.event_cd=smokingreferraloutcome)
    IF (cnvtupper(ce.result_val)="AGREED TO COUNSELING")
     sfeinfo->patagreetocounseling = (sfeinfo->patagreetocounseling+ 1)
    ELSEIF (cnvtupper(ce.result_val)="NOT READY TO QUIT")
     sfeinfo->notreadytoquit = (sfeinfo->notreadytoquit+ 1)
    ELSEIF (cnvtupper(ce.result_val)="REFUSED COUNSELING*")
     sfeinfo->refusedcounseling = (sfeinfo->refusedcounseling+ 1)
    ELSEIF (cnvtupper(ce.result_val)="CLINICAL CONDITION PRECLUDES*")
     sfeinfo->clinicalcondition = (sfeinfo->clinicalcondition+ 1)
    ENDIF
   ELSEIF (ce.event_cd=patientwantsreferraltoquitsmoking)
    IF (cnvtupper(ce.result_val)="YES")
     sfeinfo->patreqestreferral = (sfeinfo->patreqestreferral+ 1)
    ENDIF
   ELSEIF (ce.event_cd=smokingcessationresourcesinformation)
    IF (cnvtupper(ce.result_val)="GIVEN")
     sfeinfo->patcresourceinfogiven = (sfeinfo->patcresourceinfogiven+ 1)
    ELSEIF (cnvtupper(ce.result_val)="NOT GIVEN")
     sfeinfo->patcresourceinfonotgiven = (sfeinfo->patcresourceinfonotgiven+ 1)
    ENDIF
   ELSEIF (ce.event_cd=patientwantsnrtduringadmission)
    IF (cnvtupper(ce.result_val)="YES")
     sfeinfo->detailqual[count].requestnrt = 1, sfeinfo->patrequestnrt = (sfeinfo->patrequestnrt+ 1)
    ENDIF
   ELSEIF (ce.event_cd=ambulatoryintakehistoryform)
    sfeinfo->outsmokintakereferformcnt = (sfeinfo->outsmokintakereferformcnt+ 1)
   ELSEIF (ce.event_cd=smokingintakereferralform)
    sfeinfo->smokintakereferformcnt = (sfeinfo->smokintakereferformcnt+ 1)
   ELSEIF (ce.event_cd=smokinghistoryandmanagementform)
    sfeinfo->smokhistandmangform = (sfeinfo->smokhistandmangform+ 1)
   ELSEIF (ce.event_cd IN (smokingreferral, smokingreferraloutpatient))
    sfeinfo->referralcnt = (sfeinfo->referralcnt+ 1)
    IF (findstring("QUITWORKS",cnvtupper(ce.result_val)) > 0)
     sfeinfo->quitworks = (sfeinfo->quitworks+ 1)
    ENDIF
    IF (findstring("FREEDOM FROM SMOKING",cnvtupper(ce.result_val)) > 0)
     sfeinfo->freedomfromsmokcnt = (sfeinfo->freedomfromsmokcnt+ 1)
    ENDIF
    IF (findstring("INDIVIDUAL COUNSELING",cnvtupper(ce.result_val)) > 0)
     sfeinfo->individualcounselingcnt = (sfeinfo->individualcounselingcnt+ 1)
    ENDIF
    IF (findstring("PHARMACOTHERAPY",cnvtupper(ce.result_val)) > 0)
     sfeinfo->pharmacotherapy = (sfeinfo->pharmacotherapy+ 1)
    ENDIF
    IF (((findstring("SELF-HELP",cnvtupper(ce.result_val)) > 0) OR (findstring("SELF HELP",cnvtupper(
      ce.result_val)) > 0)) )
     sfeinfo->selfhelp = (sfeinfo->selfhelp+ 1)
    ENDIF
    IF (findstring("TELEPHONE COUNSELING",cnvtupper(ce.result_val)) > 0)
     sfeinfo->telephonecounseling = (sfeinfo->telephonecounseling+ 1)
    ENDIF
    IF (findstring("OTHER:",cnvtupper(ce.result_val)) > 0)
     sfeinfo->other = (sfeinfo->other+ 1)
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(sfeinfo->detailqual,count)
  WITH nocounter, format, separator = " ",
   time = 400
 ;end select
 CALL echo("Locate orders for tasks, caresets, and orderables")
 SELECT INTO "NL:"
  FROM orders o,
   task_activity ta,
   (dummyt d  WITH seq = count)
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=sfeinfo->detailqual[d.seq].encntr_id)
    AND o.orig_order_dt_tm > cnvtdatetime(beg_date_qual)
    AND o.catalog_cd IN (patientwantsreferralquitsmokingtask, patientwantsreferraltoquitsmokingtask,
   cpgnicotinereplacementtherapy, nicotine, bupropion,
   varenicline)
    AND o.cs_order_id=0)
   JOIN (ta
   WHERE ta.order_id=outerjoin(o.order_id))
  ORDER BY o.encntr_id, o.catalog_cd, o.order_id,
   ta.task_id DESC
  HEAD o.encntr_id
   CALL echo(build("###################  ",o.encntr_id,"   ######################")), nrtgiven = 0
  HEAD o.catalog_cd
   CALL echo("@@@@@@@@@@@"),
   CALL echo(build2("person_id:",o.person_id)),
   CALL echo(build2("OrderId:",o.order_id)),
   CALL echo(uar_get_code_display(o.catalog_cd)),
   CALL echo(build2("catalogCd:",o.catalog_cd))
   IF (o.catalog_cd=patientwantsreferralquitsmokingtask)
    sfeinfo->mlhfmcpatientwantsrefer = (sfeinfo->mlhfmcpatientwantsrefer+ 1)
    IF (ta.task_status_cd=taskcomplete)
     sfeinfo->mlhfmcpatientwantsrefercompl = (sfeinfo->mlhfmcpatientwantsrefercompl+ 1)
    ENDIF
   ELSEIF (o.catalog_cd=patientwantsreferraltoquitsmokingtask)
    sfeinfo->bmcpatientwantsrefer = (sfeinfo->bmcpatientwantsrefer+ 1)
    IF (ta.task_status_cd=taskcomplete)
     sfeinfo->bmcpatientwantsrefercompl = (sfeinfo->bmcpatientwantsrefercompl+ 1)
    ENDIF
   ELSEIF (o.catalog_cd IN (cpgnicotinereplacementtherapy, nicotine, bupropion, varenicline))
    CALL echo(build2("nrtGiven",nrtgiven))
    IF (nrtgiven=0)
     nrtgiven = 1,
     CALL echo("@@@@@@@@@@@"),
     CALL echo(build2("person_id:",o.person_id)),
     CALL echo(build2("OrderId:",o.order_id)),
     CALL echo(uar_get_code_display(o.catalog_cd)),
     CALL echo(build2("catalogCd:",o.catalog_cd))
     IF ((sfeinfo->detailqual[d.seq].requestnrt=1))
      sfeinfo->patreqnrtgotnrt = (sfeinfo->patreqnrtgotnrt+ 1)
     ELSE
      sfeinfo->patnoreqnrtgotnrt = (sfeinfo->patnoreqnrtgotnrt+ 1)
     ENDIF
     CALL echo(sfeinfo->patreqnrtgotnrt)
    ENDIF
   ENDIF
  WITH nocounter, time = 100
 ;end select
 CALL echorecord(sfeinfo)
 IF (( $EMAIL="report"))
  EXECUTE bhs_sfe_outcomes_summary_frm  $OUTDEV
 ELSE
  SET stat = alterlist(output->qual,30)
  SET x = 1
  SET output->qual[x].col1 = "DATE:"
  SET output->qual[x].col2 = build2(format(cnvtdatetime(beg_date_qual),"MM/DD/YY HH:MM;;q"),"-",
   format(cnvtdatetime(end_date_qual),"MM/DD/YY HH:MM;;q"))
  SET x = (x+ 1)
  SET output->qual[x].col1 = "Smoked in the last 12 monhts"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->smokedlast12months)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "Not Smoked in the last 12 months"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->notsmokedlast12months)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "never smoked"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->hasneversmoked)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "Unable to consent"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->smokernoconsent)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "Caregiver smoked last 12 months"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->cargiversmokedlast12)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "caregiver not smoked last 12 months"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->caregivernosmoked)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "unable to obtain"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->unabletoobtain)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "pat wants referal to quit"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->patreqestreferral)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "Ambulatory resource info givin"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->patcresourceinfogiven)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "Ambulatory resource info not givin"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->patcresourceinfonotgiven)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "pat request nrt"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->patrequestnrt)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "pat got nrt"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->patreqnrtgotnrt)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "bmc pat wants referal"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->bmcpatientwantsrefer)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "bmc pat referral compleated"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->bmcpatientwantsrefercompl)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "mlhfmc pat wants referal"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->mlhfmcpatientwantsrefer)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "mlhfmc pat referral compleated"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->mlhfmcpatientwantsrefercompl)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "pat agreed to counseling"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->patagreetocounseling)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "total smoking referral"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->referralcnt)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "referal quit works"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->quitworks)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "referal Freedom from smoking"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->freedomfromsmokcnt)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "referal individual counseling"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->individualcounselingcnt)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "referal pharmacotherapy"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->pharmacotherapy)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "referal self help"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->selfhelp)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "referal telephone counseling"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->telephonecounseling)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "referal other"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->other)
  SELECT INTO  $OUTDEV
   substring(0,40,output->qual[d.seq].col1), output->qual[d.seq].col2
   FROM (dummyt d  WITH seq = x)
   PLAN (d)
   WITH nocounter, format
  ;end select
 ENDIF
#exit_program
END GO

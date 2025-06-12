CREATE PROGRAM bhs_sfe_outcomes_summary23:dba
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
   1 patreqestreferralyes = i4
   1 patreqestreferralno = i4
   1 patagreetocounseling = i4
   1 notreadytoquit = i4
   1 refusedcounseling = i4
   1 clinicalcondition = i4
   1 personcnt = i4
   1 patrequestnrtyes = i4
   1 patrequestnrtno = i4
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
 FREE RECORD formlist
 RECORD formlist(
   1 formqual[*]
     2 dcp_form_ref_id = f8
     2 dcp_form_instance_id = f8
     2 definition = vc
     2 formfound = i2
     2 formisactive = i2
 )
 FREE RECORD formactlisttemp
 RECORD formactlisttemp(
   1 qual[*]
     2 encntr_id = f8
     2 person_id = f8
     2 dcp_forms_activity_idvc = vc
     2 encntrqual = i4
     2 encntr_beg_dt_tm = q8
     2 encntr_end_dt_tm = q8
 )
 FREE RECORD formactlist
 RECORD formactlist(
   1 qual[*]
     2 encntr_id = f8
     2 person_id = f8
     2 dcp_forms_activity_idvc = vc
     2 encntrqual = i4
     2 encntr_beg_dt_tm = q8
     2 encntr_end_dt_tm = q8
 )
 FREE RECORD formactlist2
 RECORD formactlist2(
   1 qual[*]
     2 encntr_id = f8
     2 dcp_forms_activity_idvc = vc
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
 DECLARE smokingreferral = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"SMOKINGREFERRAL")),
 protect
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
 DECLARE altered = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE modified = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE auth = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE bmc = f8 WITH constant(673936.00), protect
 DECLARE bfmc = f8 WITH constant(673937.00), protect
 DECLARE bmlh = f8 WITH constant(673938.00), protect
 DECLARE bmcinptpsych = f8 WITH constant(679549.00), protect
 DECLARE bfmcinptpsych = f8 WITH constant(679586.00), protect
 DECLARE mineventid = f8
 DECLARE nrtgiven = i2
 DECLARE inactiveforms = vc WITH noconstant(" ")
 DECLARE formsnotfound = vc WITH noconstant(" ")
 DECLARE timestartcnt = q8
 DECLARE reporttimestart = q8
 DECLARE reporttimeend = vc
 DECLARE countl = i4 WITH protect
 DECLARE usrerr = vc WITH noconstant(" ")
 DECLARE expandcnt = i4 WITH protect, constant(140)
 DECLARE num = i4 WITH protect
 DECLARE pos = i4 WITH protect
 DECLARE pcnt = i4 WITH protect
 DECLARE ecnt = i4 WITH protect
 DECLARE actual_size = i4 WITH protect
 DECLARE expand_total = i4 WITH protect
 DECLARE expand_start = i4 WITH noconstant(1), protect
 DECLARE expand_stop = i4 WITH noconstant(expandcnt), protect
 SET reporttimestart = cnvtdatetime(curdate,curtime3)
 SET beg_date_qual = cnvtdatetime(build2( $BDATE," 00:00:00"))
 SET end_date_qual = cnvtdatetime(build2( $EDATE," 23:59:59"))
 SET end_date_qual_max = cnvtdatetime(build2( $EDATE," 00:00:00"))
 CALL echo(format(cnvtdatetime(beg_date_qual),";;q"))
 CALL echo(format(cnvtdatetime(end_date_qual),";;q"))
 CALL echo(format(cnvtdatetime(end_date_qual_max),";;q"))
 SET x = 0
 IF (((datetimediff(end_date_qual,beg_date_qual) > 6
  AND ( $AUNIT=0)) OR (datetimediff(end_date_qual,beg_date_qual) > 31
  AND ( $AUNIT > 0))) )
  CALL echo("Date range > 5")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 =
    IF (( $AUNIT=0)) "Your date range is larger than 5 days."
    ELSE "Your date range is larger than 31 days"
    ENDIF
    , msg2 = "  Please retry.", col 0,
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
 SET y = 0
 SET stat = alterlist(formlist->formqual,100)
 SET y = (y+ 1)
 SET formlist->formqual[y].definition = "ADMISSION ASSESSMENT I&C/YOUNG ADOL- BHS"
 SET y = (y+ 1)
 SET formlist->formqual[y].definition = "ADMISSION ASSESSMENT - BHS"
 SET y = (y+ 1)
 SET formlist->formqual[y].definition = "ADMISSION ASSESSMENT OB - BHS"
 SET y = (y+ 1)
 SET formlist->formqual[y].definition = "ADMISSION ASSESSMENT ADOLESCENT - BHS"
 SET y = (y+ 1)
 SET formlist->formqual[y].definition = "ADMISSION ASSESSMENT NEWBORN - BHS"
 SET y = (y+ 1)
 SET formlist->formqual[y].definition = "AMBULATORY INTAKE HISTORY -  BHS"
 SET y = (y+ 1)
 SET formlist->formqual[y].definition = "AMBULATORY INTAKE HISTORY - PEDI - BHS"
 SET y = (y+ 1)
 SET formlist->formqual[y].definition = "ADMISSION ASSESSMENT PSYCHIATRIC - BHS"
 SET y = (y+ 1)
 SET formlist->formqual[y].definition = "PREADMIT HEALTH QUESTIONNAIRE - BHS"
 SET y = (y+ 1)
 SET formlist->formqual[y].definition = "SMOKING INTAKE & REFERRAL - BHS"
 SET y = (y+ 1)
 SET formlist->formqual[y].definition = "SMOKING HISTORY AND MANAGEMENT - BHS"
 SET y = (y+ 1)
 SET formlist->formqual[y].definition = "ADMISSION ASSESSMENT INFANT/TODDLER - BHS"
 SET y = (y+ 1)
 SET formlist->formqual[y].definition = "ADMIT ASSESSMENT CHILD/YOUNG ADOL - BHS"
 SET y = (y+ 1)
 SET formlist->formqual[y].definition = "PREADMIT HEALTH QUESTIONNAIRE PEDI - BHS"
 SET y = (y+ 1)
 SET formlist->formqual[y].definition = "zzzDummy Form"
 SET stat = alterlist(formlist->formqual,y)
 SET num = 0
 SET locnum = 0
 SET timestartcnt = cnvtdatetime(curdate,curtime3)
 SELECT INTO "NL:"
  *
  FROM dcp_forms_ref dfr
  PLAN (dfr
   WHERE dfr.dcp_forms_ref_id > 0
    AND dfr.beg_effective_dt_tm <= cnvtdatetime(end_date_qual)
    AND dfr.end_effective_dt_tm >= cnvtdatetime(beg_date_qual)
    AND expand(num,1,size(formlist->formqual,5),cnvtupper(trim(dfr.definition)),formlist->formqual[
    num].definition))
  ORDER BY dfr.dcp_forms_ref_id, dfr.end_effective_dt_tm
  HEAD dfr.dcp_forms_ref_id
   pos = 0, locnum = 0, pos = locateval(locnum,1,size(formlist->formqual,5),cnvtupper(trim(dfr
      .definition)),formlist->formqual[locnum].definition)
   IF (pos > 0)
    formlist->formqual[pos].dcp_form_ref_id = dfr.dcp_forms_ref_id, formlist->formqual[pos].
    dcp_form_instance_id = dfr.dcp_form_instance_id, formlist->formqual[pos].formfound = 1,
    formlist->formqual[pos].formisactive = 1
    IF (cnvtdatetime(beg_date_qual)=cnvtdatetime(curdate,0)
     AND dfr.end_effective_dt_tm < cnvtdatetime(end_date_qual))
     formlist->formqual[pos].formisactive = 0
    ELSE
     formlist->formqual[pos].formisactive = 1
    ENDIF
   ENDIF
  WITH counter
 ;end select
 SET num = 0
 CALL echo("Done finding forms.")
 CALL echo(build("TEST",timestartcnt))
 CALL echo(build("locate Forms:",format(timestartcnt,";;q")))
 CALL echo(format(cnvtdatetime(curdate,curtime3),";;q"))
 SET timestartcnt = cnvtdatetime(curdate,curtime3)
 FOR (x = 1 TO size(formlist->formqual,5))
   IF ((formlist->formqual[x].formfound=0))
    SET formsnotfound = build(formsnotfound,formlist->formqual[x].definition,char(13))
   ELSEIF ((formlist->formqual[x].formisactive=0))
    SET inactiveforms = build(inactiveforms,formlist->formqual[x].definition,char(13))
   ENDIF
 ENDFOR
 CALL echo(build("For loop:",format(timestartcnt,";;q")))
 CALL echo(format(cnvtdatetime(curdate,curtime3),";;q"))
 SET timestartcnt = cnvtdatetime(curdate,curtime3)
 CALL echo(build("formsNotFound:",formsnotfound))
 CALL echo(build("inactiveForms:",inactiveforms))
 SET sfecnt = 0
 SET sumcnt = 0
 SET count = 0
 SET sfeinfo->location =
 IF (( $LOCATION=1)) "Baystate Health System"
 ELSEIF (( $LOCATION=2)) "CIS Hospital"
 ELSEIF (( $LOCATION=3)) "CIS Office"
 ELSEIF (( $AUNIT > 0)) uar_get_code_display( $AUNIT)
 ELSEIF (( $LOCATION=4)) "BMC"
 ELSEIF (( $LOCATION=5)) "BMLH"
 ELSEIF (( $LOCATION=6)) "BFMC"
 ELSEIF (( $LOCATION=7)) "Ambulatory Practice"
 ELSE ""
 ENDIF
 CALL echo("load all instances of above forms being performed")
 SELECT INTO "NL:"
  FROM dcp_forms_ref dfr,
   dcp_forms_activity dfa
  PLAN (dfr
   WHERE expand(num,1,size(formlist->formqual,5),dfr.dcp_form_instance_id,formlist->formqual[num].
    dcp_form_instance_id))
   JOIN (dfa
   WHERE dfa.dcp_forms_ref_id=dfr.dcp_forms_ref_id
    AND dfa.version_dt_tm BETWEEN dfr.beg_effective_dt_tm AND dfr.end_effective_dt_tm
    AND ((((dfa.beg_activity_dt_tm+ 0) BETWEEN datetimeadd(cnvtdatetime(beg_date_qual),- (20)) AND
   cnvtdatetime(end_date_qual))
    AND ((dfa.last_activity_dt_tm+ 0) > cnvtdatetime(beg_date_qual))) OR (((dfa.beg_activity_dt_tm+ 0
   ) < cnvtdatetime(end_date_qual))
    AND ((dfa.last_activity_dt_tm+ 0) BETWEEN cnvtdatetime(beg_date_qual) AND datetimeadd(
    cnvtdatetime(beg_date_qual),20)))) )
  ORDER BY dfa.encntr_id, dfa.dcp_forms_activity_id
  HEAD REPORT
   stat = alterlist(formactlisttemp->qual,1000), countl = 0
  HEAD dfa.dcp_forms_activity_id
   countl = (countl+ 1)
   IF (mod(countl,1000)=1
    AND countl != 1)
    stat = alterlist(formactlisttemp->qual,(countl+ 999))
   ENDIF
   formactlisttemp->qual[countl].encntr_id = dfa.encntr_id, formactlisttemp->qual[countl].person_id
    = dfa.person_id, formactlisttemp->qual[countl].dcp_forms_activity_idvc = build(trim(cnvtstring(
      dfa.dcp_forms_activity_id),3),"*"),
   formactlisttemp->qual[countl].encntr_beg_dt_tm = cnvtdatetime("01-JAN-1980 00:00:00"),
   formactlisttemp->qual[countl].encntr_end_dt_tm = cnvtdatetime("12-DEC-2200 00:00:00")
  FOOT REPORT
   stat = alterlist(formactlisttemp->qual,countl)
  WITH counter, time = 600
 ;end select
 IF (size(formactlisttemp->qual,5) <= 0)
  SET usrerr = "No form activities Found"
  CALL echo(usrerr)
  GO TO exit_program
 ENDIF
 CALL echo(build("# of Encounters found for form: ",countl))
 CALL echo(build("Form Activity",format(timestartcnt,";;q")))
 CALL echo(format(cnvtdatetime(curdate,curtime3),";;q"))
 SET timestartcnt = cnvtdatetime(curdate,curtime)
 IF (( $LOCATION > 1))
  CALL echo("Filtering encounters")
  SET actual_size = countl
  SET expand_total = 0.0
  SET expand_start = 1
  SET expand_stop = expandcnt
  IF (mod(actual_size,expandcnt) != 0)
   SET expand_total = (actual_size+ (expandcnt - mod(actual_size,expandcnt)))
   SET stat = alterlist(formactlisttemp->qual,expand_total)
   FOR (idx = (actual_size+ 1) TO expand_total)
     SET formactlisttemp->qual[idx].encntr_id = formactlisttemp->qual[actual_size].encntr_id
     SET formactlisttemp->qual[idx].person_id = formactlisttemp->qual[actual_size].person_id
     SET formactlisttemp->qual[idx].dcp_forms_activity_idvc = formactlisttemp->qual[actual_size].
     dcp_forms_activity_idvc
   ENDFOR
  ELSE
   SET expand_total = actual_size
  ENDIF
  SET countl = 0
  SELECT INTO "NL:"
   e.encntr_id
   FROM encounter e,
    (dummyt d  WITH seq = value((expand_total/ expandcnt)))
   PLAN (d
    WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expandcnt)))
     AND assign(expand_stop,(expand_start+ (expandcnt - 1))))
    JOIN (e
    WHERE expand(num,expand_start,expand_stop,e.encntr_id,formactlisttemp->qual[num].encntr_id)
     AND (((e.loc_nurse_unit_cd= $AUNIT)
     AND ( $AUNIT > 0)) OR (( $AUNIT <= 0)
     AND ((( $LOCATION=2)
     AND e.loc_facility_cd IN (bmc, bfmc, bmlh, bmcinptpsych, bfmcinptpsych)) OR (((( $LOCATION=3)
     AND  NOT (e.loc_facility_cd IN (bmc, bfmc, bmlh, bmcinptpsych, bfmcinptpsych))) OR ((((
     $LOCATION=4)
     AND e.loc_facility_cd IN (bmc, bmcinptpsych)) OR (((( $LOCATION=5)
     AND e.loc_facility_cd=bmlh) OR (((( $LOCATION=6)
     AND e.loc_facility_cd IN (bfmc, bfmcinptpsych)) OR (( $LOCATION=7))) )) )) )) )) )) )
   ORDER BY e.encntr_id
   HEAD e.encntr_id
    pos = 0, locnum = 0, pos = locateval(locnum,1,size(formactlisttemp->qual,5),e.encntr_id,
     formactlisttemp->qual[locnum].encntr_id)
    IF (pos > 0)
     formactlisttemp->qual[pos].encntrqual = 1, formactlisttemp->qual[pos].encntr_beg_dt_tm = e
     .beg_effective_dt_tm, formactlisttemp->qual[pos].encntr_end_dt_tm = e.end_effective_dt_tm
    ENDIF
   WITH counter
  ;end select
  SET expand_start = 1
  SET expand_stop = expandcnt
  SET num = 0
  SELECT INTO "NL:"
   e.encntr_id
   FROM encounter e,
    encntr_loc_hist el,
    (dummyt d  WITH seq = value((expand_total/ expandcnt)))
   PLAN (d
    WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expandcnt)))
     AND assign(expand_stop,(expand_start+ (expandcnt - 1))))
    JOIN (e
    WHERE expand(num,expand_start,expand_stop,e.encntr_id,formactlisttemp->qual[num].encntr_id))
    JOIN (el
    WHERE el.encntr_id=e.encntr_id
     AND el.beg_effective_dt_tm <= cnvtdatetime(end_date_qual)
     AND el.end_effective_dt_tm >= cnvtdatetime(beg_date_qual)
     AND (((el.loc_nurse_unit_cd= $AUNIT)
     AND ( $AUNIT > 0)) OR (( $AUNIT=0)
     AND ((( $LOCATION=2)
     AND el.loc_facility_cd IN (bmc, bfmc, bmlh, bmcinptpsych, bfmcinptpsych)) OR (((( $LOCATION=3)
     AND  NOT (el.loc_facility_cd IN (bmc, bfmc, bmlh, bmcinptpsych, bfmcinptpsych))) OR ((((
     $LOCATION=4)
     AND el.loc_facility_cd IN (bmc, bmcinptpsych)) OR (((( $LOCATION=5)
     AND el.loc_facility_cd=bmlh) OR (((( $LOCATION=6)
     AND el.loc_facility_cd IN (bfmc, bfmcinptpsych)) OR (( $LOCATION=7))) )) )) )) )) )) )
   ORDER BY e.encntr_id
   HEAD e.encntr_id
    pos = 0, locnum = 0, pos = locateval(locnum,1,size(formactlisttemp->qual,5),e.encntr_id,
     formactlisttemp->qual[locnum].encntr_id)
    IF (pos > 0)
     formactlisttemp->qual[pos].encntrqual = 1, formactlisttemp->qual[pos].encntr_beg_dt_tm = el
     .beg_effective_dt_tm, formactlisttemp->qual[pos].encntr_end_dt_tm = el.end_effective_dt_tm
    ENDIF
   WITH counter
  ;end select
  SET count = 0
  SET stat = alterlist(formactlist->qual,actual_size)
  CALL echo("For Loop: locate qualifying encounters")
  CALL echo(actual_size)
  FOR (x = 1 TO actual_size)
    IF ((formactlisttemp->qual[x].encntrqual=1))
     SET count = (count+ 1)
     SET formactlist->qual[count].encntr_id = formactlisttemp->qual[x].encntr_id
     SET formactlist->qual[count].person_id = formactlisttemp->qual[x].person_id
     SET formactlist->qual[count].dcp_forms_activity_idvc = formactlisttemp->qual[x].
     dcp_forms_activity_idvc
     SET formactlist->qual[count].encntr_beg_dt_tm = formactlisttemp->qual[pos].encntr_beg_dt_tm
     SET formactlist->qual[count].encntr_end_dt_tm = formactlisttemp->qual[pos].encntr_end_dt_tm
    ENDIF
  ENDFOR
  SET stat = alterlist(formactlist->qual,count)
 ELSE
  CALL echo("No encounter filters needed")
  SET formactlist = formactlisttemp
 ENDIF
 IF (size(formactlist->qual,5) <= 0)
  SET usrerr = "No qualifying encounters Found"
  CALL echo(usrerr)
  GO TO exit_program
 ENDIF
 CALL echo(build("# of Encounters found for form: ",countl))
 CALL echo(build("filter Encounter start time:",format(timestartcnt,";;q")))
 CALL echo(build("Filter end time:",format(cnvtdatetime(curdate,curtime3),";;q")))
 SET actual_size = size(formactlist->qual,5)
 SET expand_total = 0.0
 SET expand_start = 1
 SET expand_stop = expandcnt
 SET locnum = 0
 SET pos = 0
 SET num = 0
 SET idx = 0
 IF (mod(actual_size,expandcnt) != 0)
  SET expand_total = (actual_size+ (expandcnt - mod(actual_size,expandcnt)))
  SET stat = alterlist(formactlist->qual,expand_total)
  FOR (idx = (actual_size+ 1) TO expand_total)
    SET formactlist->qual[idx].encntr_id = formactlist->qual[actual_size].encntr_id
    SET formactlist->qual[idx].person_id = formactlist->qual[actual_size].person_id
    SET formactlist->qual[idx].dcp_forms_activity_idvc = formactlist->qual[actual_size].
    dcp_forms_activity_idvc
  ENDFOR
 ELSE
  SET expand_total = actual_size
 ENDIF
 SET testcnt = 0
 CALL echo("Load clinical event information into recordStruct")
 CALL echo(build("expand_total",expand_total))
 SELECT INTO "NL:"
  ce.encntr_id, ce.event_cd, ce.event_id,
  ce.clinical_event_id
  FROM clinical_event ce,
   (dummyt d  WITH seq = value((expand_total/ expandcnt)))
  PLAN (d
   WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expandcnt)))
    AND assign(expand_stop,(expand_start+ (expandcnt - 1))))
   JOIN (ce
   WHERE expand(num,expand_start,expand_stop,ce.encntr_id,formactlist->qual[num].encntr_id)
    AND ((ce.event_cd+ 0) IN (smokingcessation, assessmentstage, pharmacotherapypastuse, healthrisks,
   yearssmoking,
   cigarettesperday, numberofquittingattempts, numberofsmokersathome, smokingreferral,
   smokingcessationreferral,
   smokingreferraloutpatient, smokingreferraloutcome, mayquitworksleaveamessage, emailaddress,
   languagepreferred,
   callpreferredtime, smokingintakereferralform, ambulatoryintakehistoryform,
   patientwantsnrtduringadmission, patientwantsreferraltoquitsmoking,
   smokinghistoryandmanagementform, smokingcessationresourcesinformation))
    AND ((ce.clinsig_updt_dt_tm+ 0) BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(
    end_date_qual))
    AND ((ce.result_status_cd+ 0) IN (altered, modified, auth))
    AND ((ce.event_class_cd+ 0) != 654645.00)
    AND ((ce.authentic_flag+ 0)=1))
  ORDER BY ce.encntr_id, ce.event_cd, ce.event_id,
   ce.clinical_event_id DESC
  HEAD REPORT
   stat = alterlist(sfeinfo->detailqual,1000), stat, stat = alterlist(sfeinfo->qual,1000),
   count = 0
  HEAD ce.encntr_id
   sfeinfo->personcnt = (sfeinfo->personcnt+ 1), col + 1,
   "_________________________________________________________________________",
   row + 1, count = (count+ 1)
   IF (mod(count,1000)=1
    AND count != 1)
    stat = alterlist(sfeinfo->detailqual,(count+ 999))
   ENDIF
   sfeinfo->detailqual[count].person_id = ce.person_id, sfeinfo->detailqual[count].encntr_id = ce
   .encntr_id
  HEAD ce.event_id
   pos = 0, locnum = 0, pos = locateval(locnum,1,size(formactlist->qual,5),ce.encntr_id,formactlist->
    qual[locnum].encntr_id)
   IF (pos > 0
    AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(formactlist->qual[pos].encntr_beg_dt_tm) AND
   cnvtdatetime(formactlist->qual[pos].encntr_end_dt_tm))
    sfecnt = (sfecnt+ 1)
    IF (mod(sfecnt,1000)=1
     AND sfecnt != 1)
     stat = alterlist(sfeinfo->qual,(sfecnt+ 999))
    ENDIF
    sfeinfo->qual[sfecnt].person_id = ce.person_id, sfeinfo->qual[sfecnt].eventtitle = ce.result_val,
    sfeinfo->qual[sfecnt].event_cd = ce.event_cd
    IF (ce.event_cd=smokingcessation)
     testcnt = (testcnt+ 1), stat = alterlist(formactlist2->qual,testcnt), formactlist2->qual[testcnt
     ].encntr_id = ce.encntr_id,
     formactlist2->qual[testcnt].dcp_forms_activity_idvc = formactlist->qual[d.seq].
     dcp_forms_activity_idvc, sfeinfo->smokingcessationcnt = (sfeinfo->smokingcessationcnt+ 1)
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
      sfeinfo->patreqestreferralyes = (sfeinfo->patreqestreferralyes+ 1)
     ELSE
      sfeinfo->patreqestreferralno = (sfeinfo->patreqestreferralno+ 1)
     ENDIF
    ELSEIF (ce.event_cd=smokingcessationresourcesinformation)
     IF (cnvtupper(ce.result_val)="GIVEN")
      sfeinfo->patcresourceinfogiven = (sfeinfo->patcresourceinfogiven+ 1)
     ELSEIF (cnvtupper(ce.result_val)="NOT GIVEN")
      sfeinfo->patcresourceinfonotgiven = (sfeinfo->patcresourceinfonotgiven+ 1)
     ENDIF
    ELSEIF (ce.event_cd=patientwantsnrtduringadmission)
     IF (cnvtupper(ce.result_val)="YES")
      sfeinfo->detailqual[count].requestnrt = (sfeinfo->detailqual[count].requestnrt+ 1), sfeinfo->
      patrequestnrtyes = (sfeinfo->patrequestnrtyes+ 1)
     ELSE
      sfeinfo->patrequestnrtno = (sfeinfo->patrequestnrtno+ 1)
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
     IF (((findstring("SELF-HELP",cnvtupper(ce.result_val)) > 0) OR (findstring("SELF HELP",cnvtupper
      (ce.result_val)) > 0)) )
      sfeinfo->selfhelp = (sfeinfo->selfhelp+ 1)
     ENDIF
     IF (findstring("TELEPHONE COUNSELING",cnvtupper(ce.result_val)) > 0)
      sfeinfo->telephonecounseling = (sfeinfo->telephonecounseling+ 1)
     ENDIF
     IF (findstring("OTHER:",cnvtupper(ce.result_val)) > 0)
      sfeinfo->other = (sfeinfo->other+ 1)
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(sfeinfo->detailqual,count)
  WITH counter, format, separator = " ",
   time = 500
 ;end select
 IF (curqual <= 0)
  SET usrerr = "No qualfying clinical events Found"
  CALL echo(usrerr)
  GO TO exit_program
 ENDIF
 CALL echo(build("Clinical Event start time:",format(timestartcnt,";;q")))
 CALL echo(build("Clinical Event stop time:",format(cnvtdatetime(curdate,curtime3),";;q")))
 CALL echo(build("SFECNT!!!!!!!!",sfecnt))
 CALL echo(build("sfeInfo->SMOKINGCESSATIONCnt=",sfeinfo->smokingcessationcnt))
 SET timestartcnt = cnvtdatetime(curdate,curtime3)
 CALL echo("Locate orders for tasks, caresets, and orderables")
 SET expand_total = 0.0
 SET expand_start = 1
 SET actual_size = 0
 SET expand_stop = expandcnt
 SET locnum = 0
 SET pos = 0
 SET num = 0
 SET idx = 0
 SET actual_size = count
 IF (mod(actual_size,expandcnt) != 0)
  SET expand_total = (actual_size+ (expandcnt - mod(actual_size,expandcnt)))
  SET stat = alterlist(sfeinfo->detailqual,expand_total)
  FOR (idx = (actual_size+ 1) TO expand_total)
   SET sfeinfo->detailqual[idx].person_id = sfeinfo->detailqual[actual_size].person_id
   SET sfeinfo->detailqual[idx].encntr_id = sfeinfo->detailqual[actual_size].encntr_id
  ENDFOR
 ELSE
  SET expand_total = actual_size
 ENDIF
 SELECT INTO "NL:"
  o.encntr_id, o.catalog_cd, o.order_id,
  ta.task_id
  FROM orders o,
   task_activity ta,
   (dummyt d  WITH seq = value((expand_total/ expandcnt)))
  PLAN (d
   WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expandcnt)))
    AND assign(expand_stop,(expand_start+ (expandcnt - 1))))
   JOIN (o
   WHERE expand(num,expand_start,expand_stop,o.person_id,sfeinfo->detailqual[num].person_id)
    AND o.catalog_cd IN (patientwantsreferralquitsmokingtask, patientwantsreferraltoquitsmokingtask,
   cpgnicotinereplacementtherapy, nicotine, bupropion,
   varenicline)
    AND o.orig_order_dt_tm > cnvtdatetime(beg_date_qual)
    AND ((o.cs_order_id+ 0)=0))
   JOIN (ta
   WHERE ((ta.order_id=o.order_id) OR (ta.task_id=0)) )
  ORDER BY o.encntr_id, o.catalog_cd, o.order_id,
   ta.task_id DESC
  HEAD o.encntr_id
   nrtgiven = 0
  HEAD o.catalog_cd
   pos = 0, locnum = 0, pos = locateval(locnum,1,size(sfeinfo->detailqual,5),o.encntr_id,sfeinfo->
    detailqual[locnum].encntr_id)
   IF (pos > 0)
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
     IF ((((nrtgiven < sfeinfo->detailqual[pos].requestnrt)) OR (nrtgiven=0
      AND (sfeinfo->detailqual[pos].requestnrt=0))) )
      CALL echo(o.encntr_id), nrtgiven = (nrtgiven+ 1)
      IF ((sfeinfo->detailqual[pos].requestnrt > 0))
       sfeinfo->patreqnrtgotnrt = (sfeinfo->patreqnrtgotnrt+ 1)
      ELSE
       sfeinfo->patnoreqnrtgotnrt = (sfeinfo->patnoreqnrtgotnrt+ 1)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH counter
 ;end select
 CALL echo(build("orders:",format(timestartcnt,";;q")))
 CALL echo(format(cnvtdatetime(curdate,curtime3),";;q"))
 SET reporttimeend = build2(datetimediff(cnvtdatetime(curdate,curtime3),reporttimestart,5))
 CALL echo(build("reportTimeEnd:",reporttimeend))
 SET stat = alterlist(sfeinfo->summary,1)
 SET stat = alterlist(sfeinfo->qual,1)
 SET stat = alterlist(sfeinfo->detailqual,1)
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
  SET output->qual[x].col1 = "Smoking CessationCnt"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->smokingcessationcnt)
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
  SET output->qual[x].col2 = cnvtstring(sfeinfo->patreqestreferralyes)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "pat wants referal to quit"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->patreqestreferralno)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "Ambulatory resource info givin"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->patcresourceinfogiven)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "Ambulatory resource info not givin"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->patcresourceinfonotgiven)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "pat request nrt - Yes"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->patrequestnrtyes)
  SET x = (x+ 1)
  SET output->qual[x].col1 = "pat request - No"
  SET output->qual[x].col2 = cnvtstring(sfeinfo->patrequestnrtno)
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
   encntr = formactlist2->qual[d.seq].encntr_id, dcp = formactlist2->qual[d.seq].
   dcp_forms_activity_idvc
   FROM (dummyt d  WITH seq = size(formactlist2->qual,5))
   PLAN (d)
   WITH counter, format
  ;end select
 ENDIF
#exit_program
 IF (textlen(trim(usrerr,3)) > 1)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = usrerr, msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
 ENDIF
END GO

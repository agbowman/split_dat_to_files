CREATE PROGRAM ang_eks_clinical_trial_inbox:dba
 PROMPT
  "personid" = "",
  "encntrid" = ""
  WITH personid, encntrid
 DECLARE log_message = vc WITH noconstant(" ")
 DECLARE log_misc1 = vc WITH noconstant(" ")
 DECLARE patacttype = vc WITH noconstant(" ")
 DECLARE attdphyid = f8 WITH noconstant(0.0)
 DECLARE irb = vc WITH noconstant(" ")
 DECLARE alert = i4 WITH noconstant(0)
 DECLARE timealertfail = i4 WITH noconstant(0)
 DECLARE attdname = vc WITH noconstant(" ")
 DECLARE patientexpired = i4 WITH noconstant(0)
 DECLARE trialcnt = i4 WITH noconstant(0)
 DECLARE d = vc WITH noconstant(" ")
 DECLARE tempval = vc WITH protect, noconstant("")
 DECLARE msgpriority = i4 WITH noconstant(5)
 DECLARE sendto = vc WITH noconstant(" ")
 DECLARE msgsubject = vc WITH noconstant(" ")
 DECLARE msg = vc WITH noconstant(" ")
 DECLARE msgcls = vc WITH constant("IPM.NOTE")
 DECLARE sender = vc WITH constant("Discern_Expert@bhs.org")
 DECLARE attenddoc = f8 WITH constant(uar_get_code_by("MEANING",333,"ATTENDDOC")), protect
 DECLARE cmrn = f8 WITH constant(uar_get_code_by("MEANING",4,"CMRN")), protect
 DECLARE expiredobv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDOBV")), protect
 DECLARE expireddaystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDDAYSTAY")),
 protect
 DECLARE expiredip = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP")), protect
 DECLARE expiredes = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDES")), protect
 SET tab = fillstring(6,char(32))
 RECORD pattrialinfo(
   1 qual[*]
     2 emailpharmacy = i4
     2 patientname = vc
     2 patientlocation = vc
     2 patientnurseunit = vc
     2 patientroom = vc
     2 patientcmrn = vc
     2 irb = vc
     2 trialemailaccounts = vc
     2 trialtitle = vc
     2 specialinstructions = vc
     2 trialpiname = vc
     2 trialcontactinfo = vc
     2 trialmedication = vc
 )
 RECORD email(
   1 trial[*]
     2 qual[*]
       3 account = vc
 )
 CALL echo(expiredes)
 SET retval = 0
 IF (validate(trigger_personid) > 0)
  SET person_id = trigger_personid
  SET encntr_id = trigger_encntrid
 ELSE
  SET person_id =  $PERSONID
  SET encntr_id =  $ENCNTRID
 ENDIF
 CALL echo(person_id)
 CALL echo(encntr_id)
 SET log_message = build("encntr_id=",encntr_id)
 SET patacttype = "discharge"
 SET log_message = build(log_message,"_patActionType=",patacttype)
 SELECT INTO "NL:"
  FROM bhs_clinical_trial_person bp,
   bhs_clinical_trial b,
   person p,
   prsnl pl,
   person_alias pa,
   bhs_clinical_trial_meds bm,
   encntr_loc_hist elh,
   encounter e,
   order_catalog oc,
   dummyt d
  PLAN (bp
   WHERE bp.person_id=person_id
    AND bp.active_ind=1)
   JOIN (b
   WHERE b.irb_number=bp.irb_number
    AND b.active_ind=1)
   JOIN (p
   WHERE p.person_id=bp.person_id)
   JOIN (pl
   WHERE pl.person_id=b.pi_id)
   JOIN (e
   WHERE e.encntr_id=encntr_id)
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(p.person_id))
    AND (pa.person_alias_type_cd= Outerjoin(cmrn))
    AND (pa.active_ind= Outerjoin(1)) )
   JOIN (bm
   WHERE (bm.irb_number= Outerjoin(bp.irb_number))
    AND (bm.active_ind= Outerjoin(1)) )
   JOIN (oc
   WHERE (oc.catalog_cd= Outerjoin(bm.catalog_cd))
    AND (oc.active_ind= Outerjoin(1)) )
   JOIN (d)
   JOIN (elh
   WHERE (elh.encntr_id= Outerjoin(encntr_id))
    AND (elh.active_ind= Outerjoin(1))
    AND elh.encntr_loc_hist_id IN (
   (SELECT
    max(elh1.encntr_loc_hist_id)
    FROM encntr_loc_hist elh1
    WHERE elh1.encntr_id=encntr_id)))
  ORDER BY b.irb_number, oc.primary_mnemonic
  HEAD bp.irb_number
   trialcnt += 1, stat = alterlist(pattrialinfo->qual,trialcnt), log_message = build(log_message,
    "_trial_found_"),
   CALL echo("detail")
   IF (datetimecmp(datetimeadd(cnvtdatetime(bp.email_notify_start_dt_tm),bp.email_notify_length),
    cnvtdatetime(curdate,235959)) > 0)
    log_message = build(log_message,"_Trial qualified_"),
    CALL echo("Alert timeframe qualified"), alert = 1
    IF (e.encntr_type_cd IN (expiredobv, expireddaystay, expiredip, expiredes)
     AND patacttype="discharge")
     patientexpired = 1
    ENDIF
    pattrialinfo->qual[trialcnt].emailpharmacy = b.pharmacy_notify_ind, pattrialinfo->qual[trialcnt].
    patientname = concat(trim(p.name_first,3)," ",trim(p.name_last,3)), pattrialinfo->qual[trialcnt].
    patientlocation = trim(uar_get_code_display(elh.loc_building_cd),3),
    pattrialinfo->qual[trialcnt].patientnurseunit = trim(uar_get_code_display(elh.loc_nurse_unit_cd),
     3), pattrialinfo->qual[trialcnt].patientroom = concat(trim(uar_get_code_display(elh.loc_room_cd),
      3),"-",trim(uar_get_code_display(elh.loc_bed_cd),3)), pattrialinfo->qual[trialcnt].patientcmrn
     = trim(pa.alias,3),
    pattrialinfo->qual[trialcnt].irb = b.irb_number, pattrialinfo->qual[trialcnt].trialemailaccounts
     = b.email_address, pattrialinfo->qual[trialcnt].trialtitle = b.title,
    pattrialinfo->qual[trialcnt].specialinstructions = trim(b.instructions,3), pattrialinfo->qual[
    trialcnt].specialinstructions = replace(pattrialinfo->qual[trialcnt].specialinstructions,":"," "),
    pattrialinfo->qual[trialcnt].trialpiname = concat(trim(pl.name_first,3)," ",trim(pl.name_last,3)),
    pattrialinfo->qual[trialcnt].trialcontactinfo = concat(pattrialinfo->qual[trialcnt].trialpiname,
     char(10),tab,"Phone: ",trim(b.phone_number,3),
     IF (textlen(trim(b.pager_number,3)) > 0) concat(char(10),tab,"Pager: ",trim(b.pager_number,3))
     ELSE ""
     ENDIF
     ,char(10),tab,"Email: ",trim(b.email_address,3))
   ELSE
    log_message = build(log_message,"_trial did not qualify for times_"), timealertfail = 1
   ENDIF
  HEAD oc.catalog_cd
   IF (oc.catalog_cd > 0)
    pattrialinfo->qual[trialcnt].trialmedication = concat(pattrialinfo->qual[trialcnt].
     trialmedication,trim(oc.primary_mnemonic,3),char(10))
   ENDIF
  WITH nocounter, outjoin = d
 ;end select
 IF (alert <= 0)
  SET log_message = concat(log_message,"Patient is NOT on an active clinical trial",
   "timeQualifyFailed(1=true)",trim(cnvtstring(timealertfail),3)," ",
   build2("enID:",encntr_id,"_pID",person_id,"__",
    patacttype,irb,"_",attdphyid))
  SET retval = 0
  GO TO exit_script
 ELSE
  SET log_message = build(log_message,"_patient did qualify_")
 ENDIF
 SELECT INTO "NL:"
  FROM encntr_prsnl_reltn epr,
   prsnl p
  PLAN (epr
   WHERE epr.encntr_id=encntr_id
    AND epr.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN epr.beg_effective_dt_tm AND epr.end_effective_dt_tm
    AND epr.encntr_prsnl_r_cd=attenddoc)
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id)
  DETAIL
   attdphyid = epr.prsnl_person_id, attdname = concat(trim(p.name_first,3)," ",trim(p.name_last,3))
  WITH nocounter
 ;end select
 CALL echorecord(pattrialinfo)
 SET stat = alterlist(email->trial,trialcnt)
 SET log_message = build(log_message,"_startSendingEmails_")
 FOR (tcnt = 1 TO trialcnt)
   SET x = 0
   SET log_message = build(log_message,"_emails_")
   CALL echo("HERE")
   WHILE (x < 10
    AND x != 10)
     CALL echo("HERE2")
     SET x += 1
     CALL echo(tcnt)
     SET d = trim(pattrialinfo->qual[tcnt].trialemailaccounts,3)
     CALL echo(trim(piece(d,";",1,"1",0),3))
     CALL echo("HERE23")
     IF (findstring(",",d) > 0)
      SET d = concat(d,",")
      SET d = replace(d,",,",",")
      SET tempval = trim(piece(d,",",x,"1",0),3)
     ELSEIF (findstring(";",d) > 0)
      CALL echo("INHERE")
      SET d = concat(d,";")
      SET d = replace(d,";;",";")
      CALL echo(d)
      CALL echo(x)
      SET tempval = trim(piece(d,";",x,"1",0),3)
      CALL echo(tempval)
     ELSE
      SET tempval = "1"
     ENDIF
     CALL echo(tempval)
     IF (tempval="1"
      AND x=1)
      SET stat = alterlist(email->trial[tcnt].qual,x)
      SET email->trial[tcnt].qual[x].account = trim(pattrialinfo->qual[tcnt].trialemailaccounts,3)
     ELSEIF (textlen(tempval) > 1
      AND ((tempval != "1") OR (tempval="1"
      AND x=1)) )
      SET stat = alterlist(email->trial[tcnt].qual,x)
      SET email->trial[tcnt].qual[x].account = tempval
     ELSE
      SET x = 100
     ENDIF
   ENDWHILE
   CALL echorecord(email)
   SET msgsubject = "Clinical Trial Alert"
   SET msg = concat("Trial: ",trim(pattrialinfo->qual[tcnt].trialtitle,3),char(10),char(10),
    "The clinical trial patient ",
    pattrialinfo->qual[tcnt].patientname," (CMRN:",pattrialinfo->qual[tcnt].patientcmrn,
    IF (patacttype="admit") ") has been admitted to:"
    ELSEIF (patacttype="discharge")
     IF (patientexpired=0) ") has been discharged from:"
     ELSE ") has expired."
     ENDIF
    ELSEIF (patacttype="transfer") ") has been transferred to:"
    ENDIF
    ,char(10),
    char(10),"Location: ",pattrialinfo->qual[tcnt].patientlocation,char(10),"Nurse Unit: ",
    pattrialinfo->qual[tcnt].patientnurseunit,char(10),"Room: ",pattrialinfo->qual[tcnt].patientroom,
    char(10),
    char(10),"Attending physician: ",trim(attdname),char(10),char(10),
    "Trial information",char(10),"---------------------------",char(10),tab,
    "contact: ",pattrialinfo->qual[tcnt].trialcontactinfo,
    IF (textlen(trim(pattrialinfo->qual[tcnt].specialinstructions,3)) > 0) concat(char(10),char(10),
      "Special Instructions:",char(10),tab,
      trim(pattrialinfo->qual[tcnt].specialinstructions,3))
    ELSE char(10)
    ENDIF
    ,
    IF (textlen(pattrialinfo->qual[tcnt].trialmedication) > 0) concat(char(10),char(10),
      "Drugs deemed contraindicated for this trial",char(10),
      "-------------------------------------------",
      char(10),pattrialinfo->qual[tcnt].trialmedication)
    ELSE char(10)
    ENDIF
    )
   DECLARE tempemailnames = vc WITH noconstant(" ")
   SET log_message = build(log_message,"_StartingToSendingEmails_")
   FOR (x = 1 TO size(email->trial[tcnt].qual,5))
     SET sendto = replace(cnvtlower(email->trial[tcnt].qual[x].account),"baystatehealth.org",
      "bhs.org")
     SET tempemailnames = concat(tempemailnames,",",sendto)
     CALL echo(concat("Email sent to: ",sendto))
     SET log_message = build(log_message,"_email Sent To_",sendto,"_")
   ENDFOR
   IF ((pattrialinfo->qual[trialcnt].emailpharmacy=1))
    SET sendto = "gerald.korona@bhs.org"
    CALL echo("pharmacy email")
    CALL echo(concat("Email sent to: ",sendto))
    SET tempemailnames = concat(tempemailnames," ","pharmacy")
    SET sendto = "scott.gray@bhs.org"
    CALL echo("pharmacy email")
    CALL echo(concat("Email sent to: ",sendto))
    SET tempemailnames = concat(tempemailnames," ","pharmacy")
    SET log_message = build(log_message,"_Email sent topharm: ",sendto,"_")
   ENDIF
   CALL echo("*********************phyEmail***********************")
   CALL echo(msg)
   CALL echo("***************************************************")
   SET msg = concat(tempemailnames,char(10),msg)
   SET msgsubject = "Clinical Trial Alert"
   SET pattrialinfo->qual[tcnt].trialcontactinfo = replace(pattrialinfo->qual[tcnt].trialcontactinfo,
    ":",tab)
   SET msg = value(concat(concat(
      "You are receiving this notification because you are listed in CIS as this patient's",
      " attending physician"),char(10),char(10),"The clinical trial patient ",pattrialinfo->qual[tcnt
     ].patientname,
     " (CMRN ",pattrialinfo->qual[tcnt].patientcmrn,
     IF (patacttype="admit") ") has been admitted to "
     ELSEIF (patacttype="discharge")
      IF (patientexpired=0) ") has been discharged from "
      ELSE ") has expired."
      ENDIF
     ELSEIF (patacttype="transfer") ") has been transferred to "
     ENDIF
     ,char(10),char(10),
     "Location   ",tab,pattrialinfo->qual[tcnt].patientlocation,char(10),"Nurse Unit",
     tab,pattrialinfo->qual[tcnt].patientnurseunit,char(10),"Room       ",tab,
     pattrialinfo->qual[tcnt].patientroom,char(10),char(10),concat(
      "This patient is participating in the following clinical trial. Please contact ",pattrialinfo->
      qual[tcnt].trialpiname," for further information."),char(10),
     char(10),"Trial - ",trim(pattrialinfo->qual[tcnt].trialtitle,3),char(10),char(10),
     "Contact information",char(10),tab,pattrialinfo->qual[tcnt].trialcontactinfo,
     IF (textlen(trim(pattrialinfo->qual[tcnt].specialinstructions,3)) > 0) concat(char(10),char(10),
       "Special Instructions ",char(10),tab,
       trim(pattrialinfo->qual[tcnt].specialinstructions,3))
     ELSE char(10)
     ENDIF
     ,
     IF (textlen(pattrialinfo->qual[tcnt].trialmedication) > 0) concat(char(10),char(10),
       "Drugs deemed contraindicated for this trial",char(10),
       "-------------------------------------------",
       char(10),pattrialinfo->qual[tcnt].trialmedication)
     ELSE char(10)
     ENDIF
     ))
   CALL echo(msg)
 ENDFOR
 SET retval = 100
 SET log_message = build(log_message,"done sending emails")
#exit_script
 SET log_message = build(log_message,"newloc_",uar_get_code_display(request->n_location_cd),"oldloc_",
  uar_get_code_display(request->0_location_cd),
  "newNurse_",uar_get_code_display(request->n_loc_nurse_unit_cd),"newNurse_",uar_get_code_display(
   request->o_loc_nurse_unit_cd),"newRoom_",
  uar_get_code_display(request->n_loc_room_cd),"oldRoom_",uar_get_code_display(request->o_loc_room_cd
   ),"newroom_",uar_get_code_display(request->o_loc_bed_cd),
  "oldRoom_",uar_get_code_display(request->o_loc_bed_cd))
 CALL echo(log_message)
END GO

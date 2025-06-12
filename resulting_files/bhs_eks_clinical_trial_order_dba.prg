CREATE PROGRAM bhs_eks_clinical_trial_order:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "personid:" = 0,
  "synonym id:" = ""
  WITH outdev, personid, synonymid
 DECLARE alert = i4 WITH noconstant(0)
 DECLARE timequalifyfail = i4 WITH noconstant(0)
 DECLARE irb = vc WITH noconstant(" ")
 DECLARE catalog_cd = f8 WITH noconstant(0.0)
 DECLARE alertcnt = i4 WITH noconstant(0)
 DECLARE msg = vc WITH noconstant(" ")
 DECLARE irb = vc WITH noconstant(" ")
 DECLARE log_message = vc WITH noconstant(" ")
 DECLARE log_misc1 = vc WITH noconstant(" ")
 DECLARE log_orderid = f8 WITH noconstant(0.0)
 DECLARE alertmsg = vc WITH noconstant(" ")
 DECLARE temporderfound = i4 WITH noconstant(0)
 SET header = "{\rtf1\ansi \deff0{\fonttbl{\f0\fmodern\fprq1\fcharset0 r_ansi;}}"
 SET colortable =
 "{{\colortbl;\red0\green0\blue0;\red255\green255\blue255;\red0\green128\blue0;\red255\green0\blue0;}"
 SET rh2r = "\f0 \fs18 \cb2 \pard\sl0 "
 SET red = "\viewkind4\uc1\pard\cf4\f0\fs20 "
 SET black = "\viewkind4\uc1\pard\cf1\f0\fs20 "
 IF (validate(trigger_personid) > 0)
  SET person_id = trigger_personid
 ELSE
  SET person_id =  $PERSONID
 ENDIF
 RECORD syn(
   1 qual[*]
     2 catalog_cd = f8
     2 synonym_id = f8
     2 synmnemonic = vc
 )
 SET catcnt = 0
 CALL echo("Locating synonyms")
 FOR (x = 1 TO size(request->orderlist,5))
   IF (size(request->orderlist[1].ingredientlist,5) > 0)
    FOR (y = 1 TO size(request->orderlist[x].ingredientlist,5))
      SET catcnt = (catcnt+ 1)
      SET stat = alterlist(syn->qual,catcnt)
      SET syn->qual[catcnt].synonym_id = request->orderlist[x].ingredientlist[y].synonymid
    ENDFOR
   ELSE
    SET catcnt = (catcnt+ 1)
    SET stat = alterlist(syn->qual,catcnt)
    SET syn->qual[catcnt].synonym_id = request->orderlist[x].synonym_code
   ENDIF
 ENDFOR
 IF (size(request->orderlist,5) > 1)
  SET stat = alterlist(request->orderlist,1)
 ENDIF
 IF (catcnt > 0)
  CALL echo("grabbing catalog_cds")
  SELECT INTO "NL:"
   *
   FROM order_catalog_synonym ocs,
    (dummyt d  WITH seq = size(syn->qual,5))
   PLAN (d)
    JOIN (ocs
    WHERE (ocs.synonym_id=syn->qual[d.seq].synonym_id))
   HEAD ocs.synonym_id
    syn->qual[d.seq].catalog_cd = ocs.catalog_cd, syn->qual[d.seq].synmnemonic = ocs.mnemonic
   WITH nocounter
  ;end select
 ENDIF
 SET log_message = build2(syn->qual[1].catalog_cd,"!",size(request->orderlist,5),"!",size(request->
   orderlist[1].ingredientlist,5),
  "##",size(syn->qual,5))
 CALL echo(log_message)
 CALL echo(build2(person_id,"Validating if patient is on trial"))
 SELECT INTO "NL:"
  FROM bhs_clinical_trial_person bp,
   bhs_clinical_trial b,
   person p,
   prsnl pl,
   bhs_clinical_trial_meds bm,
   (dummyt d  WITH seq = size(syn->qual,5))
  PLAN (d)
   JOIN (bp
   WHERE bp.person_id=person_id
    AND bp.active_ind=1)
   JOIN (b
   WHERE b.irb_number=bp.irb_number
    AND b.active_ind=1)
   JOIN (p
   WHERE p.person_id=bp.person_id)
   JOIN (pl
   WHERE pl.person_id=b.pi_id)
   JOIN (bm
   WHERE bm.irb_number=outerjoin(bp.irb_number)
    AND bm.active_ind=outerjoin(1)
    AND bm.catalog_cd=outerjoin(syn->qual[d.seq].catalog_cd))
  ORDER BY bp.irb_number
  HEAD bp.irb_number
   irb = concat(irb," ",b.irb_number),
   CALL echo("Patient found"), temporderfound = 0
   IF (datetimecmp(datetimeadd(cnvtdatetime(bp.alert_notify_start_dt_tm),bp.alert_notify_length),
    cnvtdatetime(curdate,235959)) > 0)
    CALL echo("Alert timeframe qualified"), alert = 1
    IF (bm.clinical_trial_med_id > 0)
     CALL echo("contraindicated med was found"), temporderfound = 1, log_orderid = 1,
     msg = concat(red,"\fs30 \b WARNING: Contraindicated medication \b0 \fs20 ",black,"\par ","\par ",
      "You are attempting to place an order on \b ",trim(p.name_first,3)," ",trim(p.name_last,3),
      " \b0 who is on the following clinical trial: ",
      "\par \par ","    \b ",trim(b.title,3)," \b0 \par ","\par ",
      "The medication you are attempting to order (",trim(syn->qual[d.seq].synmnemonic,3),
      ") has been deemed as contraindicated for this clinical trial.")
    ELSE
     msg = concat(red,"\fs30 \b WARNING: Clinical trial participant \b0 \fs20 ",black,"\par ","\par ",
      "You are attempting to place orders on \b ",trim(p.name_first,3)," ",trim(p.name_last,3),
      " \b0 who is on the following clinical trial: ",
      "\par \par ","    \b ",trim(b.title,3)," \b0 \par ")
    ENDIF
    IF (textlen(trim(b.instructions,3)) > 0)
     msg = concat(msg,"\par ","\par ",
      "Please be aware of the following special considerations for patients in this clinical trial.",
      "\par \par ",
      "\i Special considerations: \i0 ","\par ","    ",trim(b.instructions,3))
    ENDIF
    msg = concat(msg,"\par ","\par ","For further information please contact:","\par ",
     "    ",trim(pl.name_first,3)," ",trim(pl.name_last,3),"\par ",
     "    Phone: ",trim(b.phone_number,3),
     IF (textlen(trim(b.pager_number,3)) > 0) concat("\par ","    Pager: ",trim(b.pager_number,3))
     ELSE ""
     ENDIF
     ,"\par ","    Email: ",
     b.email_address),
    CALL echo(msg), alertcnt = (alertcnt+ 1)
    IF (alertcnt > 1)
     IF (temporderfound > 0)
      alertmsg = concat(msg,"\par ","\par ",alertmsg)
     ELSE
      alertmsg = concat(alertmsg,"\par ","\par ",msg)
     ENDIF
    ELSE
     alertmsg = msg
    ENDIF
   ELSE
    timequalifyfail = 1
   ENDIF
  WITH format
 ;end select
 IF (alert > 0)
  SET retval = 100
  SET log_misc1 = alertmsg
  SET alertmsg = concat(alertmsg)
 ELSE
  CALL echo("failed to find any rows")
 ENDIF
 SET log_message = concat("Patient qualified:",
  IF (alert > 0) "YES"
  ELSE "NO"
  ENDIF
  ,"  timeAlertfail(1 = true) = ",cnvtstring(timequalifyfail),char(13),
  IF (log_orderid > 0) " / Contraindicated drug found"
  ELSE "  / No contraindicated drug found"
  ENDIF
  ,"  / IRB:",irb," / retval:",cnvtstring(retval))
 CALL echo(log_misc1)
 CALL echo(log_message)
END GO

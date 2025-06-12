CREATE PROGRAM dcp_rpt_iv_units:dba
 PROMPT
  "Enter output device (MINE): " = "MINE",
  "Enter the starting date (mmddyyyy): " = "",
  "Enter the starting time (hhmm): " = 0000,
  "Enter the ending date (mmddyyyy): " = "",
  "Enter the ending time (hhmm): " = 2359,
  "Enter a specific order_id if desired: " = 0,
  "Do you want to perform the update (Y or N)? " = "N"
 SET modify = predeclare
 DECLARE utcdatetime(ddatetime=vc,lindex=i4,bshowtz=i2,sformat=vc) = vc
 DECLARE utcshorttz(lindex=i4) = vc
 DECLARE sutcdatetime = vc WITH protect, noconstant(" ")
 DECLARE dutcdatetime = f8 WITH protect, noconstant(0.0)
 DECLARE cutc = i2 WITH protect, constant(curutc)
 SUBROUTINE utcdatetime(sdatetime,lindex,bshowtz,sformat)
   DECLARE offset = i2 WITH protect, noconstant(0)
   DECLARE daylight = i2 WITH protect, noconstant(0)
   DECLARE lnewindex = i4 WITH protect, noconstant(curtimezoneapp)
   DECLARE snewdatetime = vc WITH protect, noconstant(" ")
   DECLARE ctime_zone_format = vc WITH protect, constant("ZZZ")
   IF (lindex > 0)
    SET lnewindex = lindex
   ENDIF
   SET snewdatetime = datetimezoneformat(sdatetime,lnewindex,sformat)
   IF (cutc=1
    AND bshowtz=1)
    IF (size(trim(snewdatetime)) > 0)
     SET snewdatetime = concat(snewdatetime," ",datetimezoneformat(sdatetime,lnewindex,
       ctime_zone_format))
    ENDIF
   ENDIF
   SET snewdatetime = trim(snewdatetime)
   RETURN(snewdatetime)
 END ;Subroutine
 SUBROUTINE utcshorttz(lindex)
   DECLARE offset = i2 WITH protect, noconstant(0)
   DECLARE daylight = i2 WITH protect, noconstant(0)
   DECLARE lnewindex = i4 WITH protect, noconstant(curtimezoneapp)
   DECLARE snewshorttz = vc WITH protect, noconstant(" ")
   DECLARE ctime_zone_format = i2 WITH protect, constant(7)
   IF (cutc=1)
    IF (lindex > 0)
     SET lnewindex = lindex
    ENDIF
    SET snewshorttz = datetimezonebyindex(lnewindex,offset,daylight,ctime_zone_format)
   ENDIF
   SET snewshorttz = trim(snewshorttz)
   RETURN(snewshorttz)
 END ;Subroutine
 RECORD events(
   1 qual[*]
     2 order_id = f8
     2 event_id = f8
     2 initial_dosage = f8
     2 admin_dosage = f8
     2 dosage_unit_cd = f8
     2 strength_unit_cd = f8
     2 admin_start_dt_tm = dq8
     2 admin_start_tz = i4
     2 admin_note = vc
     2 initial_volume = f8
     2 infused_volume = f8
     2 infused_volume_unit_cd = f8
     2 volume_unit_cd = f8
     2 event_tag = vc
     2 return_status = vc
 )
 DECLARE civ_order_type = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE cfin_nbr = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE civparent = f8 WITH protect, constant(uar_get_code_by("MEANING",72,"IVPARENT"))
 DECLARE cbegin_bag = f8 WITH protect, constant(uar_get_code_by("MEANING",180,"BEGIN"))
 DECLARE cbolus = f8 WITH protect, constant(uar_get_code_by("MEANING",180,"BOLUS"))
 DECLARE cinfuse = f8 WITH protect, constant(uar_get_code_by("MEANING",180,"INFUSE"))
 DECLARE crate = f8 WITH protect, constant(uar_get_code_by("MEANING",180,"RATECHG"))
 DECLARE csite = f8 WITH protect, constant(uar_get_code_by("MEANING",180,"SITECHG"))
 DECLARE cwaste = f8 WITH protect, constant(uar_get_code_by("MEANING",180,"WASTE"))
 DECLARE cbase = i4 WITH protect, constant(2)
 DECLARE cadditive = i4 WITH protect, constant(3)
 DECLARE line = vc WITH protect, noconstant("")
 DECLARE out_dev = vc WITH protect, noconstant("")
 DECLARE from_dt = q8 WITH protect
 DECLARE from_tm = i4 WITH protect, noconstant(0)
 DECLARE to_dt = q8 WITH protect
 DECLARE to_tm = i4 WITH protect, noconstant(0)
 DECLARE begin_dt_tm = q8 WITH protect
 DECLARE end_dt_tm = q8 WITH protect
 DECLARE dorderid = f8 WITH protect, noconstant(0.0)
 DECLARE nnameflag = i2 WITH protect, noconstant(0)
 DECLARE nfinflag = i2 WITH protect, noconstant(0)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE spatname = vc WITH protect, noconstant("")
 DECLARE sfinnbr = vc WITH protect, noconstant("")
 DECLARE sdisplay = vc WITH protect, noconstant("")
 DECLARE sdosage = vc WITH protect, noconstant("")
 DECLARE svolume = vc WITH protect, noconstant("")
 DECLARE ddosage = f8 WITH protect, noconstant(0.0)
 DECLARE dvolume = f8 WITH protect, noconstant(0.0)
 DECLARE lactseq = i4 WITH protect, noconstant(0)
 DECLARE lcnt2 = i4 WITH protect, noconstant(0)
 DECLARE schar = c1 WITH protect, noconstant("")
 DECLARE llength = i4 WITH protect, noconstant(0)
 DECLARE sreal = vc WITH protect, noconstant("")
 DECLARE ltypeflag = i4 WITH protect, noconstant(0)
 DECLARE stype = vc WITH protect, noconstant("")
 DECLARE sfilename = vc WITH protect, noconstant("")
 DECLARE last_mod = c3 WITH protect, noconstant("")
 DECLARE mod_date = vc WITH protect, noconstant("")
 DECLARE lret = i4 WITH protect, noconstant(0)
 DECLARE lappid = i4 WITH protect, noconstant(1000012)
 DECLARE ltaskid = i4 WITH protect, noconstant(1000012)
 DECLARE lreqid = i4 WITH protect, noconstant(1000012)
 DECLARE happ = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hreq = i4 WITH protect, noconstant(0)
 DECLARE hstce = i4 WITH protect, noconstant(0)
 DECLARE hstmrl = i4 WITH protect, noconstant(0)
 DECLARE lsrvstat = i4 WITH protect, noconstant(0)
 DECLARE leventcnt = i4 WITH protect, noconstant(0)
 DECLARE lupdate = i4 WITH protect, noconstant(0)
 SET line = fillstring(127,"-")
 SET out_dev = cnvtupper( $1)
 SET from_dt = cnvtdate( $2)
 SET from_tm = cnvtreal( $3)
 SET to_dt = cnvtdate( $4)
 SET to_tm = cnvtreal( $5)
 SET dorderid = cnvtreal( $6)
 SET begin_dt_tm = cnvtdatetime(from_dt,from_tm)
 SET end_dt_tm = cnvtdatetime(to_dt,to_tm)
 CALL echo("-")
 CALL echo("Retrieving data..")
 SELECT
  IF (dorderid > 0)
   PLAN (o
    WHERE o.order_id=dorderid
     AND o.med_order_type_cd=civ_order_type)
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND oa.core_ind=1)
    JOIN (oi
    WHERE oi.order_id=oa.order_id
     AND oi.action_sequence <= oa.action_sequence
     AND oi.strength > 0
     AND oi.strength_unit > 0
     AND oi.volume > 0
     AND oi.volume_unit > 0)
    JOIN (cver
    WHERE cver.parent_cd=oi.catalog_cd)
    JOIN (ce
    WHERE ce.order_id=o.order_id
     AND ce.updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
     AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
     AND ce.event_cd=cver.event_cd)
    JOIN (ce2
    WHERE ce2.event_id=ce.parent_event_id)
    JOIN (cmr
    WHERE cmr.event_id=ce.event_id
     AND cmr.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
     AND ((cmr.iv_event_cd IN (cbolus, cinfuse, cwaste)
     AND cmr.admin_dosage > 0
     AND cmr.infused_volume > 0
     AND ((cmr.dosage_unit_cd != oi.strength_unit) OR (cmr.infused_volume_unit_cd != oi.volume_unit
    )) ) OR (cmr.iv_event_cd IN (cbegin_bag, crate, csite)
     AND ((cmr.initial_dosage > 0
     AND cmr.dosage_unit_cd != oi.strength_unit) OR (cmr.initial_volume > 0
     AND cmr.infused_volume_unit_cd != oi.volume_unit)) )) )
    JOIN (p
    WHERE p.person_id=ce.person_id)
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(ce.encntr_id)
     AND ea.encntr_alias_type_cd=outerjoin(cfin_nbr))
  ELSE
   PLAN (o
    WHERE o.order_id > 0
     AND o.med_order_type_cd=civ_order_type)
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND oa.core_ind=1)
    JOIN (oi
    WHERE oi.order_id=oa.order_id
     AND oi.action_sequence <= oa.action_sequence
     AND oi.strength > 0
     AND oi.strength_unit > 0
     AND oi.volume > 0
     AND oi.volume_unit > 0)
    JOIN (cver
    WHERE cver.parent_cd=oi.catalog_cd)
    JOIN (ce
    WHERE ce.order_id=o.order_id
     AND ce.updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
     AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
     AND ce.event_cd=cver.event_cd)
    JOIN (ce2
    WHERE ce2.event_id=ce.parent_event_id)
    JOIN (cmr
    WHERE cmr.event_id=ce.event_id
     AND cmr.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
     AND ((cmr.iv_event_cd IN (cbolus, cinfuse, cwaste)
     AND cmr.admin_dosage > 0
     AND cmr.infused_volume > 0
     AND ((cmr.dosage_unit_cd != oi.strength_unit) OR (cmr.infused_volume_unit_cd != oi.volume_unit
    )) ) OR (cmr.iv_event_cd IN (cbegin_bag, crate, csite)
     AND ((cmr.initial_dosage > 0
     AND cmr.dosage_unit_cd != oi.strength_unit) OR (cmr.initial_volume > 0
     AND cmr.infused_volume_unit_cd != oi.volume_unit)) )) )
    JOIN (p
    WHERE p.person_id=ce.person_id)
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(ce.encntr_id)
     AND ea.encntr_alias_type_cd=outerjoin(cfin_nbr))
  ENDIF
  INTO  $1
  FROM orders o,
   order_action oa,
   order_ingredient oi,
   code_value_event_r cver,
   clinical_event ce,
   clinical_event ce2,
   ce_med_result cmr,
   person p,
   encntr_alias ea
  ORDER BY p.name_full_formatted, ce.encntr_id, o.order_id,
   cmr.event_id, oi.action_sequence DESC
  HEAD REPORT
   lcnt = 0,
   MACRO (formatrealstring)
    lcnt2 = textlen(sreal)
    WHILE (lcnt2 > 0)
      schar = substring(lcnt2,1,sreal)
      IF (((schar=".") OR (schar != "0")) )
       llength = lcnt2
       IF (schar=".")
        llength = (llength - 1)
       ENDIF
       lcnt2 = 0
      ENDIF
      lcnt2 = (lcnt2 - 1)
    ENDWHILE
    sreal = trim(substring(1,llength,sreal),3)
   ENDMACRO
  HEAD PAGE
   IF ( NOT (out_dev IN ("MINE")))
    col 00, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
   ENDIF
   col 00, "DCP_RPT_IV_UNITS", col 117,
   "Page: ", curpage"###", row + 1,
   col 00, "Date Range: ", sdisplay = ""
   IF (begin_dt_tm > 0)
    sutcdatetime = concat(format(begin_dt_tm,"MM/DD/YY HH:MM;;D")," ",utcshorttz(0)), sdisplay =
    sutcdatetime
   ENDIF
   IF (end_dt_tm > 0)
    sutcdatetime = concat(format(end_dt_tm,"MM/DD/YY HH:MM;;D")," ",utcshorttz(0)), sdisplay = build2
    (sdisplay," - ",sutcdatetime)
   ENDIF
   IF (textlen(sdisplay) > 0)
    col 12, sdisplay
   ENDIF
   col 91, "Run Date: ", curdate"mm/dd/yyyy;;d",
   " Time: ", curtime"hh:mm;;s", row + 1,
   col 00, line, row + 2
  HEAD p.name_full_formatted
   nnameflag = 1
  HEAD ce.encntr_id
   nfinflag = 1
  HEAD cmr.event_id
   IF (findstring(";",ce.collating_seq,1,1) > 0)
    lactseq = cnvtint(substring(1,(findstring(";",ce.collating_seq,1,1) - 1),ce.collating_seq))
   ELSE
    lactseq = cnvtint(ce.collating_seq)
   ENDIF
   ltypeflag = oi.ingredient_type_flag
   IF (oi.action_sequence=lactseq)
    IF (nnameflag=1)
     spatname = trim(build2("Patient Name: ",p.name_full_formatted)), col 00, spatname,
     nnameflag = 0
    ENDIF
    IF (nfinflag=1
     AND ea.encntr_alias_type_cd=cfin_nbr)
     sfinnbr = trim(build2("FIN: ",cnvtalias(ea.alias,ea.alias_pool_cd))), row + 1, col 00,
     sfinnbr, nfinflag = 0
    ENDIF
    lcnt = (lcnt+ 1), dstat = alterlist(events->qual,lcnt), events->qual[lcnt].order_id = o.order_id,
    events->qual[lcnt].event_id = cmr.event_id, events->qual[lcnt].dosage_unit_cd = cmr
    .dosage_unit_cd, events->qual[lcnt].admin_start_dt_tm = cmr.admin_start_dt_tm,
    events->qual[lcnt].admin_start_tz = cmr.admin_start_tz, events->qual[lcnt].return_status =
    "No Update", row + 1,
    sdisplay = build2("Event ID: ",trim(cnvtstring(ce.event_id,20,2),3),"     Order ID: ",trim(
      cnvtstring(o.order_id,20,2),3),"     Action Seq: ",
     trim(cnvtstring(lactseq,20,2),3),"     Order Mnemonic: ",trim(oi.order_mnemonic,3)), col 05,
    sdisplay,
    row + 1, sutcdatetime = trim(concat(format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;D")," ",utcshorttz
      (ce.event_end_tz)),3), sdisplay = build2("Event Date/Time: ",sutcdatetime,"     Event Type: ",
     trim(uar_get_code_display(cmr.iv_event_cd),3)),
    col 05, sdisplay
    IF (ltypeflag=cbase)
     stype = "Base"
    ELSE
     stype = "Additive"
    ENDIF
    row + 1, sdisplay = build2("Order Ingred Strength: ",trim(format(oi.strength,"#############.##"),
      3)," ",trim(uar_get_code_display(oi.strength_unit),3),"     Order Ingred Volume: ",
     trim(format(oi.volume,"#############.##"),3)," ",trim(uar_get_code_display(oi.volume_unit),3),
     "     Order Ingred Type: ",stype), col 05,
    sdisplay
    IF (cmr.iv_event_cd IN (cbegin_bag))
     row + 1, sdisplay = build2("Event Initial Dosage: ",trim(format(cmr.initial_dosage,
        "#############.##"),3)," ",trim(uar_get_code_display(cmr.dosage_unit_cd),3),
      "     Event Initial Volume: ",
      trim(format(cmr.initial_volume,"#############.##"),3)," ",trim(uar_get_code_display(cmr
        .infused_volume_unit_cd),3)), col 05,
     sdisplay
     IF (cmr.initial_volume > 0)
      ddosage = ((oi.strength/ oi.volume) * cmr.initial_volume)
      IF (((ddosage != cmr.initial_dosage) OR (cmr.dosage_unit_cd != oi.strength_unit)) )
       row + 1, sdisplay = build2("Initial dosage will be changed to: ",trim(format(ddosage,
          "#############.##"),3)," ",trim(uar_get_code_display(oi.strength_unit),3)), col 10,
       sdisplay, events->qual[lcnt].initial_dosage = ddosage, events->qual[lcnt].dosage_unit_cd = oi
       .strength_unit,
       sreal = format(round(events->qual[lcnt].initial_dosage,4),"#############.####;,;f"),
       formatrealstring, sdosage = sreal,
       events->qual[lcnt].admin_note = build2("Initial dosage was updated to ",sdosage," ",trim(
         uar_get_code_display(events->qual[lcnt].dosage_unit_cd),3),".")
      ENDIF
      IF (cmr.infused_volume_unit_cd != oi.volume_unit)
       events->qual[lcnt].infused_volume_unit_cd = oi.volume_unit, row + 1, sdisplay = build2(
        "Initial volume unit code will be changed to: ",trim(uar_get_code_display(oi.volume_unit),3)),
       col 10, sdisplay
       IF ((events->qual[lcnt].initial_dosage > 0))
        events->qual[lcnt].admin_note = build2(events->qual[lcnt].admin_note,
         "  Infused volume unit was updated from ",trim(uar_get_code_display(cmr
           .infused_volume_unit_cd),3)," to ",trim(uar_get_code_display(oi.volume_unit),3),
         ".")
       ELSE
        events->qual[lcnt].volume_unit_cd = oi.volume_unit, events->qual[lcnt].admin_note = build2(
         "Infused volume unit was updated from ",trim(uar_get_code_display(cmr.infused_volume_unit_cd
           ),3)," to ",trim(uar_get_code_display(oi.volume_unit),3),".")
       ENDIF
      ENDIF
     ELSE
      IF (cmr.dosage_unit_cd != oi.strength_unit)
       events->qual[lcnt].strength_unit_cd = oi.strength_unit, row + 1, sdisplay = build2(
        "Initial dosage unit code will be changed to: ",trim(uar_get_code_display(oi.strength_unit),3
         )),
       col 10, sdisplay, events->qual[lcnt].admin_note = build2("Dosage unit was updated from ",trim(
         uar_get_code_display(cmr.dosage_unit_cd),3)," to ",trim(uar_get_code_display(oi
          .strength_unit),3),".")
      ELSEIF (cmr.infused_volume_unit_cd != oi.volume_unit)
       events->qual[lcnt].volume_unit_cd = oi.volume_unit, row + 1, sdisplay = build2(
        "Initial volume unit code will be changed to: ",trim(uar_get_code_display(oi.volume_unit),3)),
       col 10, sdisplay, events->qual[lcnt].admin_note = build2(
        "Infused volume unit was updated from ",trim(uar_get_code_display(cmr.infused_volume_unit_cd),
         3)," to ",trim(uar_get_code_display(oi.volume_unit),3),".")
      ENDIF
     ENDIF
     IF (cmr.initial_volume > 0)
      sreal = format(round(cmr.initial_volume,2),"#############.##;,;f"), formatrealstring, events->
      qual[lcnt].event_tag = build2(trim(uar_get_code_display(cmr.iv_event_cd),3)," ",sreal," ",trim(
        uar_get_code_display(oi.volume_unit),3))
     ELSEIF (cmr.initial_dosage > 0)
      sreal = format(round(cmr.initial_dosage,2),"#############.##;,;f"), formatrealstring, events->
      qual[lcnt].event_tag = build2(trim(uar_get_code_display(cmr.iv_event_cd),3)," ",sreal," ",trim(
        uar_get_code_display(oi.strength_unit),3))
     ENDIF
    ELSEIF (cmr.iv_event_cd IN (cinfuse, cbolus, cwaste))
     row + 1, sdisplay = build2("Event Admin Dosage: ",trim(format(cmr.admin_dosage,
        "#############.##"),3)," ",trim(uar_get_code_display(cmr.dosage_unit_cd),3),
      "     Event Infused Volume: ",
      trim(format(cmr.infused_volume,"#############.##"),3)," ",trim(uar_get_code_display(cmr
        .infused_volume_unit_cd),3)), col 05,
     sdisplay
     IF (cmr.infused_volume > 0)
      IF (cmr.dosage_unit_cd != oi.strength_unit)
       events->qual[lcnt].strength_unit_cd = oi.strength_unit, row + 1, sdisplay = build2(
        "Admin dosage unit code will be changed to: ",trim(uar_get_code_display(oi.strength_unit),3)),
       col 10, sdisplay, events->qual[lcnt].admin_note = build2("Dosage unit was updated from ",trim(
         uar_get_code_display(cmr.dosage_unit_cd),3)," to ",trim(uar_get_code_display(oi
          .strength_unit),3),".")
      ELSEIF (cmr.infused_volume_unit_cd != oi.volume_unit)
       events->qual[lcnt].volume_unit_cd = oi.volume_unit, row + 1, sdisplay = build2(
        "Infused volume unit code will be changed to: ",trim(uar_get_code_display(oi.volume_unit),3)),
       col 10, sdisplay, events->qual[lcnt].admin_note = build2(
        "Infused volume unit was updated from ",trim(uar_get_code_display(cmr.infused_volume_unit_cd),
         3)," to ",trim(uar_get_code_display(oi.volume_unit),3),".")
      ENDIF
     ELSE
      row + 1, ddosage = ((oi.strength/ oi.volume) * cmr.admin_dosage), sdisplay = build2(
       "Admin dosage will be changed to: ",trim(format(ddosage,"#############.##"),3)," ",trim(
        uar_get_code_display(oi.strength_unit),3)),
      col 10, sdisplay, events->qual[lcnt].admin_dosage = ddosage,
      events->qual[lcnt].dosage_unit_cd = oi.strength_unit, row + 1, sdisplay = build2(
       "Infused volume will be changed to: ",trim(format(cmr.admin_dosage,"#############.##"),3)," ",
       trim(uar_get_code_display(oi.volume_unit),3)),
      col 10, sdisplay, events->qual[lcnt].infused_volume = cmr.admin_dosage,
      events->qual[lcnt].infused_volume_unit_cd = oi.volume_unit, sreal = format(round(events->qual[
        lcnt].admin_dosage,4),"#############.####;,;f"), formatrealstring,
      sdosage = sreal, sreal = format(round(events->qual[lcnt].infused_volume,4),
       "#############.####;,;f"), formatrealstring,
      svolume = sreal, events->qual[lcnt].admin_note = build2("Admin dosage was updated to ",sdosage,
       " ",trim(uar_get_code_display(events->qual[lcnt].dosage_unit_cd),3),".  ",
       "Infused volume was updated to ",svolume," ",trim(uar_get_code_display(events->qual[lcnt].
         infused_volume_unit_cd),3),".")
     ENDIF
     IF ((events->qual[lcnt].admin_dosage > 0))
      sreal = format(round(events->qual[lcnt].admin_dosage,4),"#############.####;,;f"),
      formatrealstring, events->qual[lcnt].event_tag = build2(sreal," ",trim(uar_get_code_display(oi
         .strength_unit),3))
      IF ((events->qual[lcnt].infused_volume > 0))
       sreal = format(round(events->qual[lcnt].infused_volume,4),"#############.####;,;f"),
       formatrealstring, events->qual[lcnt].event_tag = build2(events->qual[lcnt].event_tag,"/",sreal,
        " ",trim(uar_get_code_display(oi.volume_unit),3))
      ENDIF
     ELSEIF (cmr.admin_dosage > 0)
      sreal = format(round(cmr.admin_dosage,4),"#############.####;,;f"), formatrealstring, events->
      qual[lcnt].event_tag = build2(sreal," ",trim(uar_get_code_display(oi.strength_unit),3))
      IF (cmr.infused_volume > 0)
       sreal = format(round(cmr.infused_volume,4),"#############.####;,;f"), formatrealstring, events
       ->qual[lcnt].event_tag = build2(events->qual[lcnt].event_tag,"/",sreal," ",trim(
         uar_get_code_display(oi.volume_unit),3))
      ENDIF
     ELSEIF (cmr.initial_volume > 0)
      sreal = format(round(cmr.initial_volume,4),"#############.####;,;f"), formatrealstring, events
      ->qual[lcnt].event_tag = build2(sreal," ",trim(uar_get_code_display(oi.volume_unit),3))
     ENDIF
    ELSEIF (cmr.iv_event_cd IN (crate, csite))
     row + 1, sdisplay = build2("Event Initial Dosage: ",trim(format(cmr.initial_dosage,
        "#############.##"),3)," ",trim(uar_get_code_display(cmr.dosage_unit_cd),3),
      "     Event Initial Volume: ",
      trim(format(cmr.initial_volume,"#############.##"),3)," ",trim(uar_get_code_display(cmr
        .infused_volume_unit_cd),3)), col 05,
     sdisplay
     IF (cmr.initial_volume > 0
      AND cmr.initial_volume != oi.volume)
      IF (cmr.dosage_unit_cd != oi.strength_unit)
       events->qual[lcnt].dosage_unit_cd = oi.strength_unit, row + 1, sdisplay = build2(
        "Initial dosage unit code will be changed to: ",trim(uar_get_code_display(oi.strength_unit),3
         )),
       col 10, sdisplay, events->qual[lcnt].admin_note = build2(
        "Initial dosage unit was updated from ",trim(uar_get_code_display(cmr.dosage_unit_cd),3),
        " to ",trim(uar_get_code_display(oi.strength_unit),3),".")
      ENDIF
      row + 1, dvolume = oi.volume, sdisplay = build2("Initial volume will be changed to: ",trim(
        format(dvolume,"#############.##"),3)," ",trim(uar_get_code_display(oi.volume_unit),3)),
      col 10, sdisplay, events->qual[lcnt].initial_volume = dvolume,
      events->qual[lcnt].infused_volume_unit_cd = oi.volume_unit, sreal = format(round(events->qual[
        lcnt].initial_volume,4),"#############.####;,;f"), formatrealstring,
      svolume = sreal
      IF ((events->qual[lcnt].dosage_unit_cd > 0))
       events->qual[lcnt].admin_note = build2(events->qual[lcnt].admin_note,
        "  Initial volume was updated to ",svolume," ",trim(uar_get_code_display(events->qual[lcnt].
          infused_volume_unit_cd),3),
        ".")
      ELSE
       events->qual[lcnt].admin_note = build2("Initial volume was updated to ",svolume," ",trim(
         uar_get_code_display(events->qual[lcnt].infused_volume_unit_cd),3),".")
      ENDIF
     ELSE
      IF (cmr.dosage_unit_cd != oi.strength_unit)
       events->qual[lcnt].strength_unit_cd = oi.strength_unit, row + 1, sdisplay = build2(
        "Initial dosage unit code will be changed to: ",trim(uar_get_code_display(oi.strength_unit),3
         )),
       col 10, sdisplay, events->qual[lcnt].admin_note = build2("Dosage unit was updated from ",trim(
         uar_get_code_display(cmr.dosage_unit_cd),3)," to ",trim(uar_get_code_display(oi
          .strength_unit),3),".")
      ELSEIF (cmr.infused_volume_unit_cd != oi.volume_unit)
       events->qual[lcnt].volume_unit_cd = oi.volume_unit, row + 1, sdisplay = build2(
        "Initial volume unit code will be changed to: ",trim(uar_get_code_display(oi.volume_unit),3)),
       col 10, sdisplay, events->qual[lcnt].admin_note = build2(
        "Infused volume unit was updated from ",trim(uar_get_code_display(cmr.infused_volume_unit_cd),
         3)," to ",trim(uar_get_code_display(oi.volume_unit),3),".")
      ENDIF
     ENDIF
    ENDIF
    row + 1
   ENDIF
  FOOT  p.name_full_formatted
   IF (nnameflag=0)
    row + 1
   ENDIF
  FOOT REPORT
   IF (lcnt=0)
    CALL center("***** No Results Qualified *****",1,130)
   ELSE
    sdisplay = build2("***** ",trim(cnvtstring(lcnt),3)," Event(s) Found"," *****"),
    CALL center(sdisplay,1,130)
   ENDIF
  WITH dio = postscript, maxrow = 45, maxcol = 300,
   nullreport
 ;end select
 SET leventcnt = value(size(events->qual,5))
 CALL echo(" - ")
 CALL echo(build("lEventCnt: ",leventcnt))
 IF (cnvtupper( $7)="Y"
  AND leventcnt > 0)
  SET modify = nopredeclare
  EXECUTE crmrtl
  EXECUTE srvrtl
  SET modify = predeclare
  SET lret = uar_crmbeginapp(lappid,happ)
  IF (lret != 0)
   CALL echo(build("CrmBeginApp Error: ",lret))
   GO TO exit_script
  ENDIF
  SET lret = uar_crmbegintask(happ,ltaskid,htask)
  IF (lret != 0)
   CALL echo(build("CrmBeginTask Error: ",lret))
   GO TO exit_script
  ENDIF
  SET lret = uar_crmbeginreq(htask,"",lreqid,hstep)
  IF (lret != 0)
   CALL echo(build("CrmBeginReq Error: ",lret))
   GO TO exit_script
  ENDIF
  SET hreq = uar_crmgetrequest(hstep)
  SET lsrvstat = uar_srvsetshort(hreq,"ensure_type",2)
  SET hstce = uar_srvgetstruct(hreq,"clin_event")
  SET hstmrl = uar_srvadditem(hstce,"med_result_list")
  CALL echo(" - ")
  CALL echo(build("Total events to ensure: ",leventcnt))
  CALL echo(" - ")
  CALL echo("******************************")
  CALL echo("Beginning Event Server Ensure")
  CALL echo("******************************")
  CALL echo(" - ")
  CALL echo("*** Updating Data ***")
  FOR (x = 1 TO leventcnt)
    SET lsrvstat = uar_srvsetdouble(hstce,"event_id",events->qual[x].event_id)
    SET lsrvstat = uar_srvsetshort(hstce,"view_level_ind",1)
    SET lsrvstat = uar_srvsetshort(hstce,"authentic_flag_ind",1)
    SET lsrvstat = uar_srvsetshort(hstce,"publish_flag_ind",1)
    SET lsrvstat = uar_srvsetshort(hstce,"performed_dt_tm_ind",1)
    SET lsrvstat = uar_srvsetstring(hstce,"event_tag",nullterm(events->qual[x].event_tag))
    SET lsrvstat = uar_srvsetdouble(hstmrl,"event_id",events->qual[x].event_id)
    SET lsrvstat = uar_srvsetdate(hstmrl,"admin_start_dt_tm",cnvtdatetime(events->qual[x].
      admin_start_dt_tm))
    SET lsrvstat = uar_srvsetlong(hstmrl,"admin_start_tz",events->qual[x].admin_start_tz)
    SET lsrvstat = uar_srvsetshort(hstmrl,"admin_end_dt_tm_ind",1)
    SET lsrvstat = uar_srvsetshort(hstmrl,"initial_dosage_ind",1)
    SET lsrvstat = uar_srvsetshort(hstmrl,"initial_volume_ind",1)
    SET lsrvstat = uar_srvsetshort(hstmrl,"total_intake_volume_ind",1)
    SET lsrvstat = uar_srvsetshort(hstmrl,"infusion_rate_ind",1)
    SET lsrvstat = uar_srvsetshort(hstmrl,"reason_required_flag_ind",1)
    SET lsrvstat = uar_srvsetshort(hstmrl,"response_required_flag_ind",1)
    SET lsrvstat = uar_srvsetshort(hstmrl,"admin_strength_ind",1)
    SET lsrvstat = uar_srvsetshort(hstmrl,"remaining_volume_ind",1)
    SET lsrvstat = uar_srvsetstring(hstmrl,"admin_note",nullterm(events->qual[x].admin_note))
    IF ((events->qual[x].initial_dosage > 0))
     SET lupdate = 1
     SET lsrvstat = uar_srvsetshort(hstmrl,"initial_dosage_ind",0)
     SET lsrvstat = uar_srvsetdouble(hstmrl,"initial_dosage",events->qual[x].initial_dosage)
     SET lsrvstat = uar_srvsetdouble(hstmrl,"dosage_unit_cd",events->qual[x].dosage_unit_cd)
     IF ((events->qual[x].infused_volume_unit_cd > 0))
      SET lsrvstat = uar_srvsetdouble(hstmrl,"infused_volume_unit_cd",events->qual[x].
       infused_volume_unit_cd)
     ENDIF
    ELSEIF ((events->qual[x].initial_volume > 0))
     SET lupdate = 1
     SET lsrvstat = uar_srvsetshort(hstmrl,"initial_volume_ind",0)
     SET lsrvstat = uar_srvsetdouble(hstmrl,"initial_volume",events->qual[x].initial_volume)
     SET lsrvstat = uar_srvsetdouble(hstmrl,"infused_volume_unit_cd",events->qual[x].
      infused_volume_unit_cd)
     IF ((events->qual[x].dosage_unit_cd > 0))
      SET lsrvstat = uar_srvsetdouble(hstmrl,"dosage_unit_cd",events->qual[x].dosage_unit_cd)
     ENDIF
    ELSEIF ((events->qual[x].admin_dosage > 0))
     SET lupdate = 1
     SET lsrvstat = uar_srvsetshort(hstmrl,"admin_dosage_ind",0)
     SET lsrvstat = uar_srvsetdouble(hstmrl,"admin_dosage",events->qual[x].admin_dosage)
     SET lsrvstat = uar_srvsetdouble(hstmrl,"dosage_unit_cd",events->qual[x].dosage_unit_cd)
     SET lsrvstat = uar_srvsetshort(hstmrl,"infused_volume_ind",0)
     SET lsrvstat = uar_srvsetdouble(hstmrl,"infused_volume",events->qual[x].infused_volume)
     SET lsrvstat = uar_srvsetdouble(hstmrl,"infused_volume_unit_cd",events->qual[x].
      infused_volume_unit_cd)
    ELSE
     IF ((events->qual[x].strength_unit_cd > 0))
      SET lupdate = 1
      SET lsrvstat = uar_srvsetdouble(hstmrl,"dosage_unit_cd",events->qual[x].strength_unit_cd)
     ENDIF
     IF ((events->qual[x].volume_unit_cd > 0))
      SET lupdate = 1
      SET lsrvstat = uar_srvsetdouble(hstmrl,"infused_volume_unit_cd",events->qual[x].volume_unit_cd)
     ENDIF
     SET lsrvstat = uar_srvsetshort(hstmrl,"admin_dosage_ind",1)
     SET lsrvstat = uar_srvsetshort(hstmrl,"infused_volume_ind",1)
    ENDIF
    IF (lupdate=1)
     SET lret = uar_crmperformas(hstep,"event_update")
     IF (lret=0)
      SET events->qual[x].return_status = "Updated Event Successfully"
     ELSE
      SET events->qual[x].return_status = build2("Failure: uar_CrmPerformAs returned a ",trim(
        cnvtstring(lret),3))
     ENDIF
     SET lupdate = 0
    ENDIF
  ENDFOR
  CALL uar_crmendreq(hstep)
  CALL uar_crmendtask(htask)
  CALL uar_crmendapp(happ)
  CALL echo(" - ")
  CALL echo("******************************")
  CALL echo("Completed Event Server Ensure")
  CALL echo("******************************")
  CALL echo(" - ")
  SET sfilename = concat("event_update_",format(curdate,"DD-MMM-YYYY;;D"),"_",cnvtstring(curtime2))
  CALL echorecord(events,sfilename)
 ELSE
  CALL echo(" - ")
  CALL echo("***** No results were updated *****")
  CALL echo(" - ")
 ENDIF
#exit_script
 FREE RECORD events
 SET last_mod = "001"
 SET mod_date = "08/22/2005"
 SET modify = nopredeclare
END GO

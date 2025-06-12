CREATE PROGRAM bhs_eks_dlg_pmr_audit:dba
 PROMPT
  "Output to File/Printer/MINE (MINE):" = "MINE",
  "Begin Date, mmddyy (today):" = "CURDATE",
  "BeginTime, hhmm (0000):" = "CURTIME",
  "End Date, mmddyy (today):" = "CURDATE",
  "End Time, hhmm (2359):" = "CURTIME",
  "Module Name, pattern match OK (*):" = "bhs_syn_pmr",
  "Output Type - (B)ackend CSV, (F)rontend CSV, or (R)eport (R):" = "R",
  "Show (S)ummary or (D)etails (D):" = "D",
  "Sort by (A)lert Recipient or (M)odule (M):" = "A"
  WITH outputtype, begindate, begintime,
  enddate, endtime, modulename,
  outtype, details, sort
 DECLARE outfile = vc
 DECLARE startdt = vc
 DECLARE enddt = vc
 DECLARE starttm = c4
 DECLARE endtm = c4
 DECLARE modulename = vc
 DECLARE parsestring = vc
 DECLARE validstring = vc
 DECLARE nxtchr = c1
 DECLARE asterisk = c1
 DECLARE asterpos = i4
 DECLARE underpos = i4
 DECLARE msg = vc
 DECLARE showdetails = c1
 DECLARE sorttype = c1
 SET asterisk = char(ichar("*"))
 SET modulename = trim(cnvtupper( $6))
 SET sorttype = trim(cnvtupper( $9))
 SET startdt =  $2
 IF (trim(cnvtupper(startdt))="CURDATE")
  SET startdt = format(curdate,"mmddyy;;d")
 ELSEIF (((size(startdt) != 6) OR ( NOT (isnumeric(startdt)))) )
  CALL echo("Start date must be in mmddyy format")
  GO TO endprogram
 ELSEIF (((cnvtint(substring(1,2,startdt)) > 12) OR (cnvtint(substring(1,2,startdt)) <= 0)) )
  CALL echo("Start month must be 01 through 12")
  GO TO endprogram
 ELSEIF (((cnvtint(substring(3,2,startdt)) > 31) OR (cnvtint(substring(3,2,startdt)) <= 0)) )
  CALL echo("Start day must be 01 through 31")
  GO TO endprogram
 ENDIF
 SET starttm =  $3
 IF (((size(starttm) != 4) OR ( NOT (isnumeric(starttm)))) )
  CALL echo("Start time must be in hhmm format")
  GO TO endprogram
 ELSEIF (cnvtint(substring(1,2,starttm)) > 23)
  CALL echo("Start hour must be < 24")
  GO TO endprogram
 ELSEIF (cnvtint(substring(3,2,starttm)) > 59)
  CALL echo("Start minute must be < 60")
  GO TO endprogram
 ENDIF
 SET enddt =  $4
 IF (trim(cnvtupper(enddt))="CURDATE")
  SET enddt = format(curdate,"mmddyy;;d")
 ELSEIF (((size(enddt) != 6) OR ( NOT (isnumeric(enddt)))) )
  CALL echo("End date must be in mmddyy format")
  GO TO endprogram
 ELSEIF (((cnvtint(substring(1,2,enddt)) > 12) OR (cnvtint(substring(1,2,enddt)) <= 0)) )
  CALL echo("End month must be 01 through 12")
  GO TO endprogram
 ELSEIF (((cnvtint(substring(3,2,enddt)) > 31) OR (cnvtint(substring(3,2,enddt)) <= 0)) )
  CALL echo("End day must be 01 through 31")
  GO TO endprogram
 ENDIF
 SET endtm =  $5
 IF (((size(endtm) != 4) OR ( NOT (isnumeric(endtm)))) )
  CALL echo("End time must be in hhmm format")
  GO TO endprogram
 ELSEIF (cnvtint(substring(1,2,endtm)) > 23)
  CALL echo("End hour must be < 24")
  GO TO endprogram
 ELSEIF (cnvtint(substring(3,2,endtm)) > 59)
  CALL echo("End minute must be < 60")
  GO TO endprogram
 ENDIF
 IF ( NOT (( $OUTTYPE IN ("R", "B", "F"))))
  CALL echo("Output Type must be either 'R' or 'B' or 'F'")
  GO TO endprogram
 ENDIF
 SET showdetails = trim(cnvtupper( $8))
 IF ( NOT (showdetails IN ("D", "S")))
  CALL echo("Show Details must be either 'D' or 'S'")
  GO TO endprogram
 ENDIF
 SET startdttm = cnvtdatetime(cnvtdate2(startdt,"MMDDYY"),cnvtint(starttm))
 SET enddttm = cnvtdatetime(cnvtdate2(enddt,"MMDDYY"),cnvtint(endtm))
 CALL echo(concat("startDtTm = ",format(startdttm,";;q"),"  endDtTm = ",format(enddttm,";;q")))
 SET asterpos = findstring(asterisk,modulename)
 SET underpos = findstring("_",modulename)
 IF (asterpos > 1)
  SET modulename = concat(asterisk,modulename)
 ELSEIF ( NOT (asterpos))
  IF (underpos)
   SET modulename = concat(substring(1,underpos,modulename),"EKM!",modulename)
  ELSE
   IF (findstring("DRUG",modulename))
    SET modulename = concat("MUL_MED!",modulename)
   ELSE
    SET modulename = concat(asterisk,modulename)
   ENDIF
  ENDIF
 ENDIF
 CALL echo(concat("dlg_name = ",modulename))
 RECORD eksdlg_input(
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 module_name = c30
 )
 RECORD eksdlgevent(
   1 qual_cnt = i4
   1 status = c1
   1 status_msg = vc
   1 qual[*]
     2 dlg_event_id = f8
     2 dlg_name = vc
     2 module_name = c30
     2 dlg_prsnl_id = f8
     2 updt_dt_tm = dq8
     2 person_id = f8
     2 encntr_id = f8
     2 long_text_id = f8
     2 trigger_entity_id = f8
     2 trigger_entity_name = c32
     2 trigger_order_id = f8
     2 override_reason_cd = f8
     2 long_text_id = f8
     2 alert_long_text_id = f8
     2 srcstring = vc
     2 catdisp = c40
     2 severity = vc
     2 attr_cnt = i4
     2 attr[*]
       3 attr_name = c32
       3 attr_id = f8
       3 attr_value = vc
 )
 SET eksdlg_input->module_name = modulename
 SET eksdlg_input->start_dt_tm = startdttm
 SET eksdlg_input->end_dt_tm = enddttm
 EXECUTE eks_get_dlg_event
 CALL echo(concat("Number found = ",build(eksdlgevent->qual_cnt)))
 IF (eksdlgevent->qual_cnt)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = eksdlgevent->qual_cnt),
    (dummyt d2  WITH seq = eksdlgevent->qual[d1.seq].attr_cnt),
    nomenclature n
   PLAN (d1
    WHERE maxrec(d2,eksdlgevent->qual[d1.seq].attr_cnt))
    JOIN (d2
    WHERE (eksdlgevent->qual[d1.seq].attr[d2.seq].attr_name="NOMENCLATURE_ID")
     AND (eksdlgevent->qual[d1.seq].attr[d2.seq].attr_id > 0))
    JOIN (n
    WHERE (eksdlgevent->qual[d1.seq].attr[d2.seq].attr_id=n.nomenclature_id))
   DETAIL
    eksdlgevent->qual[d1.seq].srcstring = n.source_string
   WITH nocounter
  ;end select
  IF (( $OUTTYPE IN ("B", "F")))
   CALL echo(concat("Creating CSV for ",modulename," that fired between"))
   CALL echo(concat(format(startdttm,";;q")," and ",format(enddttm,";;q")))
   CALL echo(concat("Number found = ",build(eksdlgevent->qual_cnt),"  sortType = ",sorttype))
   SELECT
    IF (( $OUTTYPE="B")
     AND sorttype="M")
     ORDER BY dlgname, dlgdttm, eksdlgevent->qual[d1.seq].encntr_id,
      eksdlgevent->qual[d1.seq].dlg_event_id, 0
     WITH format = stream, pcformat('"',",",1), nocounter,
      separator = " "
    ELSEIF (( $OUTTYPE="B")
     AND sorttype != "M")
     ORDER BY recipient, dlgname, dlgdttm,
      eksdlgevent->qual[d1.seq].encntr_id, eksdlgevent->qual[d1.seq].dlg_event_id, 0
     WITH format = stream, pcformat('"',",",1), nocounter,
      separator = " "
    ELSEIF (( $OUTTYPE != "B")
     AND sorttype="M")
     ORDER BY dlgname, dlgdttm, eksdlgevent->qual[d1.seq].encntr_id,
      eksdlgevent->qual[d1.seq].dlg_event_id, 0
     WITH format, nocounter, separator = " "
    ELSE
     ORDER BY recipient, dlgname, dlgdttm,
      eksdlgevent->qual[d1.seq].encntr_id, eksdlgevent->qual[d1.seq].dlg_event_id, 0
     WITH format, nocounter, separator = " "
    ENDIF
    DISTINCT INTO value( $OUTPUTTYPE)
    dlgdttm = format(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm),"yyyy/mm/dd hh:mm:ss;;d"),
    trigger = trim(uar_get_code_display(eksdlgevent->qual[d1.seq].trigger_entity_id)), recipient =
    trim(p.name_full_formatted),
    dlgname = substring(1,255,eksdlgevent->qual[d1.seq].dlg_name), reason = trim(uar_get_code_display
     (eksdlgevent->qual[d1.seq].override_reason_cd)), facility = trim(uar_get_code_display(eh
      .loc_facility_cd)),
    building = trim(uar_get_code_display(eh.loc_building_cd)), nurseunit = trim(uar_get_code_display(
      eh.loc_nurse_unit_cd)), room = trim(uar_get_code_display(eh.loc_room_cd)),
    bed = trim(uar_get_code_display(eh.loc_bed_cd)), ft_reason =
    IF (lt.long_text_id > 0) substring(1,75,lt.long_text)
    ELSE " "
    ENDIF
    , allergy = substring(1,50,eksdlgevent->qual[d1.seq].srcstring),
    interaction = trim(eksdlgevent->qual[d1.seq].catdisp), severity = eksdlgevent->qual[d1.seq].
    severity, recipientposn = trim(uar_get_code_display(p.position_cd))
    FROM (dummyt d1  WITH seq = eksdlgevent->qual_cnt),
     prsnl p,
     encounter e,
     encntr_loc_hist eh,
     long_text lt
    PLAN (d1)
     JOIN (lt
     WHERE (eksdlgevent->qual[d1.seq].long_text_id=lt.long_text_id))
     JOIN (p
     WHERE (eksdlgevent->qual[d1.seq].dlg_prsnl_id=p.person_id))
     JOIN (e
     WHERE (eksdlgevent->qual[d1.seq].encntr_id=e.encntr_id))
     JOIN (eh
     WHERE outerjoin(e.encntr_id)=eh.encntr_id
      AND outerjoin(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm)) > eh.beg_effective_dt_tm
      AND outerjoin(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm)) < eh.end_effective_dt_tm)
   ;end select
  ELSE
   SET equalline = fillstring(125,"=")
   SET dashline = fillstring(117,"-")
   DECLARE modname = vc
   IF (sorttype="M")
    SELECT INTO  $1
     dlgdttm = format(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm),"yyyy/mm/dd hh:mm:ss;;d"),
     utrigger = trim(cnvtupper(uar_get_code_display(eksdlgevent->qual[d1.seq].trigger_entity_id))),
     trigger = trim(uar_get_code_display(eksdlgevent->qual[d1.seq].trigger_entity_id)),
     recipient = trim(p.name_full_formatted), dlgname = substring(1,255,eksdlgevent->qual[d1.seq].
      module_name), dlgeventid = eksdlgevent->qual[d1.seq].dlg_event_id,
     reason = trim(substring(1,30,uar_get_code_display(eksdlgevent->qual[d1.seq].override_reason_cd))
      ), facility = trim(uar_get_code_display(eh.loc_facility_cd)), building = trim(
      uar_get_code_display(eh.loc_building_cd)),
     nurseunit = trim(uar_get_code_display(eh.loc_nurse_unit_cd)), room = trim(uar_get_code_display(
       eh.loc_room_cd)), bed = trim(uar_get_code_display(eh.loc_bed_cd)),
     ft_reason = substring(1,75,lt.long_text), allergy = eksdlgevent->qual[d1.seq].srcstring,
     interaction = trim(eksdlgevent->qual[d1.seq].catdisp),
     severity = eksdlgevent->qual[d1.seq].severity
     FROM (dummyt d1  WITH seq = eksdlgevent->qual_cnt),
      prsnl p,
      person p2,
      encounter e,
      encntr_loc_hist eh,
      long_text lt
     PLAN (d1)
      JOIN (p
      WHERE (eksdlgevent->qual[d1.seq].dlg_prsnl_id=p.person_id))
      JOIN (p2
      WHERE (eksdlgevent->qual[d1.seq].person_id=p2.person_id))
      JOIN (lt
      WHERE (eksdlgevent->qual[d1.seq].long_text_id=lt.long_text_id))
      JOIN (e
      WHERE (eksdlgevent->qual[d1.seq].encntr_id=e.encntr_id))
      JOIN (eh
      WHERE outerjoin(e.encntr_id)=eh.encntr_id
       AND outerjoin(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm)) > eh.beg_effective_dt_tm
       AND outerjoin(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm)) < eh.end_effective_dt_tm)
     ORDER BY dlgname, utrigger, dlgdttm,
      dlgeventid
     HEAD REPORT
      totalalerts = 0, totaloverrides = 0, row + 2
      IF (showdetails="S")
       msg = concat("***  Expert Summary Audit for Module(s) ", $6," Sorted By Module Name ***")
      ELSE
       msg = concat("***  Expert Detail Audit for Module(s) ", $6," Sorted By Module Name ***")
      ENDIF
      cc = (66 - (size(msg)/ 2)), col cc, msg,
      row + 2, col 9, "Audit Date/Time Range:",
      col 88, "Report Date/Time:", row + 1,
      col 11, startdttm";;q", msg = format(cnvtdatetime(curdate,curtime3),";;q"),
      col 90, msg, row + 1,
      col 13, enddttm";;q", row + 2,
      col 1, equalline, row + 1,
      col 1, "MODULE NAME", row + 1,
      col 9, "Trigger"
      IF (showdetails="D")
       row + 1, col 13, "Alert Date/Time",
       col 34, "Patient", col 64,
       "Alert Recipient", col 97, "Override Reason",
       row + 1, col 20, "Location",
       col 55, "*Freetext Override Reason", row + 1
      ENDIF
      col 1, equalline
     HEAD dlgname
      row + 1, modname = dlgname, col 1,
      modname
      IF (modname="DRUGDRUG")
       col 70, "Severity", col 80,
       "Interacting Drug"
      ELSEIF (modname="DRUGALLERGY")
       col 80, "Interacting Allergy"
      ENDIF
      IF (showdetails="S")
       row + 1, col 9, dashline
      ENDIF
      modulecnt = 0, moduleover = 0
     HEAD trigger
      IF (showdetails="D")
       row + 1, col 9, trigger
      ENDIF
      triggercnt = 0, triggerover = 0
     HEAD dlgeventid
      triggercnt = (triggercnt+ 1)
      IF (reason > " ")
       triggerover = (triggerover+ 1)
      ENDIF
      IF (showdetails="D")
       row + 1, col 13, dlgdttm,
       msg = substring(1,30,p2.name_full_formatted), col 34, msg,
       msg = substring(1,30,p.name_full_formatted), col 64, msg
       IF (trim(ft_reason) > " "
        AND lt.long_text_id > 0)
        col 96, "*"
       ENDIF
       col 97, reason, row + 1,
       msg = " "
       IF (facility > " ")
        msg = trim(facility)
       ENDIF
       IF (building > " ")
        msg = concat(msg,"=>",trim(building))
       ENDIF
       IF (nurseunit > " ")
        msg = concat(msg,"=>",trim(nurseunit))
       ENDIF
       IF (room > " ")
        msg = concat(msg,"=>",trim(room))
       ENDIF
       IF (bed > " ")
        msg = concat(msg,"=>",trim(bed))
       ENDIF
       col 20, msg
      ENDIF
     DETAIL
      msg = " "
      IF (showdetails="D"
       AND modname IN ("DRUGDRUG", "DRUGALLERGY"))
       IF (trim(eksdlgevent->qual[d1.seq].catdisp) > " ")
        msg = trim(substring(1,50,eksdlgevent->qual[d1.seq].catdisp)), col 80, msg
       ELSEIF (trim(eksdlgevent->qual[d1.seq].srcstring) > " ")
        msg = trim(substring(1,50,eksdlgevent->qual[d1.seq].srcstring)), col 80, msg
       ENDIF
       IF (trim(eksdlgevent->qual[d1.seq].severity) > " ")
        msg = trim(eksdlgevent->qual[d1.seq].severity), col 74, msg
       ENDIF
      ENDIF
      IF (trim(ft_reason) > " "
       AND lt.long_text_id > 0)
       row + 1, msg = substring(1,75,ft_reason), col 55,
       "*", col 56, msg
      ENDIF
     FOOT  trigger
      row + 1
      IF (showdetails="D")
       col 9, dashline, row + 1
      ENDIF
      msg = concat("Trigger (",trim(trigger),")"), col 9, msg,
      msg = concat("Total:  ",format(triggercnt,"#######")," Alert(s)     ",format(triggerover,
        "#######")," Override(s)"), col 61, msg
      IF (showdetails="D")
       row + 1, col 9, dashline
      ENDIF
      modulecnt = (modulecnt+ triggercnt), moduleover = (moduleover+ triggerover)
     FOOT  dlgname
      IF (showdetails="S")
       row + 1, col 9, dashline
      ENDIF
      row + 1, msg = concat("Module (",modname,")"), col 1,
      msg, msg = concat("Total:  ",format(modulecnt,"#######")," Alert(s)     ",format(moduleover,
        "#######")," Override(s)"), col 61,
      msg, row + 1, col 1,
      equalline, totalalerts = (totalalerts+ modulecnt), totaloverrides = (totaloverrides+ moduleover
      )
     FOOT REPORT
      row + 1, col 1, equalline,
      row + 1, col 1, "All Modules:",
      msg = concat("Total:  ",format(totalalerts,"#######")," Alert(s)     ",format(totaloverrides,
        "#######")," Override(s)"), col 61, msg,
      row + 1, col 1, equalline
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO  $1
     dlgdttm = format(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm),"yyyy/mm/dd hh:mm:ss;;d"),
     utrigger = trim(cnvtupper(uar_get_code_display(eksdlgevent->qual[d1.seq].trigger_entity_id))),
     trigger = trim(uar_get_code_display(eksdlgevent->qual[d1.seq].trigger_entity_id)),
     recipient = trim(p.name_full_formatted), dlgname = substring(1,255,eksdlgevent->qual[d1.seq].
      module_name), dlgeventid = eksdlgevent->qual[d1.seq].dlg_event_id,
     reason = trim(substring(1,30,uar_get_code_display(eksdlgevent->qual[d1.seq].override_reason_cd))
      ), facility = trim(uar_get_code_display(eh.loc_facility_cd)), building = trim(
      uar_get_code_display(eh.loc_building_cd)),
     nurseunit = trim(uar_get_code_display(eh.loc_nurse_unit_cd)), room = trim(uar_get_code_display(
       eh.loc_room_cd)), bed = trim(uar_get_code_display(eh.loc_bed_cd)),
     ft_reason = substring(1,75,lt.long_text), allergy = eksdlgevent->qual[d1.seq].srcstring,
     interaction = trim(eksdlgevent->qual[d1.seq].catdisp),
     severity = eksdlgevent->qual[d1.seq].severity, recipientposn = trim(uar_get_code_display(p
       .position_cd))
     FROM (dummyt d1  WITH seq = eksdlgevent->qual_cnt),
      prsnl p,
      person p2,
      encounter e,
      encntr_loc_hist eh,
      long_text lt
     PLAN (d1)
      JOIN (p
      WHERE (eksdlgevent->qual[d1.seq].dlg_prsnl_id=p.person_id))
      JOIN (p2
      WHERE (eksdlgevent->qual[d1.seq].person_id=p2.person_id))
      JOIN (lt
      WHERE (eksdlgevent->qual[d1.seq].long_text_id=lt.long_text_id))
      JOIN (e
      WHERE (eksdlgevent->qual[d1.seq].encntr_id=e.encntr_id))
      JOIN (eh
      WHERE outerjoin(e.encntr_id)=eh.encntr_id
       AND outerjoin(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm)) > eh.beg_effective_dt_tm
       AND outerjoin(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm)) < eh.end_effective_dt_tm)
     ORDER BY recipient, dlgname, utrigger,
      dlgdttm, dlgeventid
     HEAD REPORT
      totalalerts = 0, totaloverrides = 0, row + 2
      IF (showdetails="S")
       msg = concat("***  Expert Summary Audit for Module(s) ", $6," Sorted By Alert Recipient ***")
      ELSE
       msg = concat("***  Expert Detail Audit for Module(s) ", $6," Sorted By Alert Recipient ***")
      ENDIF
      cc = (66 - (size(msg)/ 2)), col cc, msg,
      row + 2, col 9, "Audit Date/Time Range:",
      col 88, "Report Date/Time:", row + 1,
      col 11, startdttm";;q", msg = format(cnvtdatetime(curdate,curtime3),";;q"),
      col 90, msg, row + 1,
      col 13, enddttm";;q", row + 2,
      col 1, equalline, row + 1,
      col 1, "ALERT RECIPIENT", col 64,
      "Recipient Position", row + 1, col 9,
      "Module Name"
      IF (showdetails="D")
       row + 1, col 13, "Alert Date/Time",
       col 34, "Patient", col 64,
       "Trigger", col 97, "Override Reason",
       row + 1, col 20, "Location",
       col 55, "*Freetext Override Reason", row + 1
      ENDIF
      col 1, equalline
     HEAD recipient
      row + 1, msg = substring(1,30,recipient), col 1,
      msg, col 64, recipientposn
      IF (showdetails="S")
       row + 1, col 9, dashline
      ENDIF
      modulecnt = 0, moduleover = 0
     HEAD dlgname
      modname = dlgname
      IF (showdetails="D")
       row + 1, col 9, modname
       IF (modname="DRUGDRUG")
        col 70, "Severity", col 80,
        "Interacting Drug"
       ELSEIF (modname="DRUGALLERGY")
        col 70, "Severity", col 80,
        "Interacting Allergy"
       ENDIF
      ENDIF
      triggercnt = 0, triggerover = 0
     HEAD dlgeventid
      triggercnt = (triggercnt+ 1)
      IF (reason > " ")
       triggerover = (triggerover+ 1)
      ENDIF
      IF (showdetails="D")
       row + 1, col 13, dlgdttm,
       msg = substring(1,30,p2.name_full_formatted), col 34, msg,
       col 64, trigger
       IF (trim(ft_reason) > " "
        AND lt.long_text_id > 0)
        col 96, "*"
       ENDIF
       col 97, reason, row + 1,
       msg = " "
       IF (facility > " ")
        msg = trim(facility)
       ENDIF
       IF (building > " ")
        msg = concat(msg,"=>",trim(building))
       ENDIF
       IF (nurseunit > " ")
        msg = concat(msg,"=>",trim(nurseunit))
       ENDIF
       IF (room > " ")
        msg = concat(msg,"=>",trim(room))
       ENDIF
       IF (bed > " ")
        msg = concat(msg,"=>",trim(bed))
       ENDIF
       col 20, msg
      ENDIF
     DETAIL
      IF (showdetails="D"
       AND modname IN ("DRUGDRUG", "DRUGALLERGY"))
       IF (trim(eksdlgevent->qual[d1.seq].catdisp) > " ")
        msg = trim(substring(1,50,eksdlgevent->qual[d1.seq].catdisp)), col 80, msg
       ELSEIF (trim(eksdlgevent->qual[d1.seq].srcstring) > " ")
        msg = trim(substring(1,50,eksdlgevent->qual[d1.seq].srcstring)), col 80, msg
       ENDIF
       IF (trim(eksdlgevent->qual[d1.seq].severity) > " ")
        msg = trim(eksdlgevent->qual[d1.seq].severity), col 74, msg
       ENDIF
      ENDIF
      IF (trim(ft_reason) > " "
       AND lt.long_text_id > 0)
       row + 1, msg = substring(1,75,ft_reason), col 55,
       "*", col 56, msg
      ENDIF
     FOOT  dlgname
      row + 1
      IF (showdetails="D")
       col 9, dashline, row + 1
      ENDIF
      msg = concat("Module Name (",trim(modname),")"), col 9, msg,
      msg = concat("Total:  ",format(triggercnt,"#######")," Alert(s)     ",format(triggerover,
        "#######")," Override(s)"), col 61, msg
      IF (showdetails="D")
       row + 1, col 9, dashline
      ENDIF
      modulecnt = (modulecnt+ triggercnt), moduleover = (moduleover+ triggerover)
     FOOT  recipient
      IF (showdetails="S")
       row + 1, col 9, dashline
      ENDIF
      row + 1, msg = concat("Recipient (",trim(recipient),")"), col 1,
      msg, msg = concat("Total:  ",format(modulecnt,"#######")," Alert(s)     ",format(moduleover,
        "#######")," Override(s)"), col 61,
      msg, row + 1, col 1,
      equalline, totalalerts = (totalalerts+ modulecnt), totaloverrides = (totaloverrides+ moduleover
      )
     FOOT REPORT
      row + 1, col 1, equalline,
      row + 1, col 1, "All Recipients:",
      msg = concat("Total:  ",format(totalalerts,"#######")," Alert(s)     ",format(totaloverrides,
        "#######")," Override(s)"), col 61, msg,
      row + 1, col 1, equalline
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
#endprogram
END GO

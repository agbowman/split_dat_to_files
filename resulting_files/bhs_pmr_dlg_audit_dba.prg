CREATE PROGRAM bhs_pmr_dlg_audit:dba
 PROMPT
  "Output to File/Printer/MINE (MINE):" = "MINE",
  "Begin Date, mmddyy (today):" = curdate,
  "BeginTime, hhmm (0000):" = "CURTIME",
  "End Date, mmddyy (today):" = curdate,
  "End Time, hhmm (2359):" = "CURTIME"
  WITH outputtype, begindate, begintime,
  enddate, endtime
 DECLARE startdt = vc
 DECLARE enddt = vc
 DECLARE starttm = c4
 DECLARE endtm = c4
 DECLARE modulename = vc
 DECLARE msg = vc
 DECLARE showdetails = c1
 DECLARE sorttype = c1
 DECLARE outtype = c1
 SET startdt =  $2
 SET starttm =  $3
 SET startdttm = cnvtdatetime(cnvtdate2(startdt,"MMDDYY"),cnvtint(starttm))
 SET enddt =  $4
 SET endtm =  $5
 SET enddttm = cnvtdatetime(cnvtdate2(enddt,"MMDDYY"),cnvtint(endtm))
 SET modulename = trim(cnvtupper("BHS_SYN_PMR"))
 SET outtype = trim(cnvtupper("R"))
 SET showdetails = trim(cnvtupper("D"))
 SET sorttype = trim(cnvtupper("M"))
 SET equalline = fillstring(125,"=")
 SET dashline = fillstring(117,"-")
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
 SELECT INTO  $1
  dlgdttm = format(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm),"yyyy/mm/dd hh:mm:ss;;d"),
  utrigger = trim(cnvtupper(uar_get_code_display(eksdlgevent->qual[d1.seq].trigger_entity_id))),
  trigger = trim(uar_get_code_display(eksdlgevent->qual[d1.seq].trigger_entity_id)),
  recipient = trim(p.name_full_formatted), dlgname = substring(1,255,eksdlgevent->qual[d1.seq].
   module_name), dlgeventid = eksdlgevent->qual[d1.seq].dlg_event_id,
  reason = trim(substring(1,30,uar_get_code_display(eksdlgevent->qual[d1.seq].override_reason_cd))),
  facility = trim(uar_get_code_display(eh.loc_facility_cd)), building = trim(uar_get_code_display(eh
    .loc_building_cd)),
  nurseunit = trim(uar_get_code_display(eh.loc_nurse_unit_cd)), room = trim(uar_get_code_display(eh
    .loc_room_cd)), bed = trim(uar_get_code_display(eh.loc_bed_cd)),
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
   totalalerts = 0, totaloverrides = 0, row + 2,
   msg = concat("***  Expert Detail Audit for Module(s) ",modulename," Sorted By Alert Recipient ***"
    ), cc = (66 - (size(msg)/ 2)), col cc,
   msg, row + 2, col 9,
   "Audit Date/Time Range:", col 88, "Report Date/Time:",
   row + 1, col 11, startdttm";;q",
   msg = format(cnvtdatetime(curdate,curtime3),";;q"), col 90, msg,
   row + 1, col 13, enddttm";;q",
   row + 2, col 1, equalline,
   row + 1, col 1, "ALERT RECIPIENT",
   col 64, "Recipient Position", row + 1,
   col 9, "Module Name", row + 1,
   col 13, "Alert Date/Time", col 34,
   "Patient", col 64, "Trigger",
   col 97, "Override Reason", row + 1,
   col 20, "Location", col 55,
   "*Freetext Override Reason", row + 1, col 1,
   equalline
  WITH nocounter
 ;end select
END GO

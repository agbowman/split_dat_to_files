CREATE PROGRAM bhs_ma_mltm_audit_em:dba
 PROMPT
  "Output to MINE (mine): " = mine,
  "Start Date, mmddyy (today): " = "curdate",
  "Start Time, hhmm (0000): " = "0000",
  "End Date, mmddyy (today): " = "curdate",
  "End Time, hhmm (2359): " = "2359"
 EXECUTE cclseclogin
 SET cfin = 0.0
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,cfin)
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
 SET startdttm = cnvtdatetime(cnvtdate2(startdt,"MMDDYY"),cnvtint(starttm))
 SET enddttm = cnvtdatetime(cnvtdate2(enddt,"MMDDYY"),cnvtint(endtm))
 SELECT INTO  $1
  dlg_event_id = ed.dlg_event_id, user = trim(substring(1,35,p1.name_full_formatted)), recipient =
  trim(substring(1,35,p.name_full_formatted)),
  finnbr = substring(1,12,ea.alias), facility = trim(substring(1,15,uar_get_code_display(e
     .loc_facility_cd))), building = trim(substring(1,15,uar_get_code_display(e.loc_building_cd))),
  nurseunit = trim(substring(1,15,uar_get_code_display(e.loc_nurse_unit_cd))), room = trim(substring(
    1,10,uar_get_code_display(e.loc_room_cd))), bed = trim(substring(1,10,uar_get_code_display(e
     .loc_bed_cd))),
  interaction_type = trim(substring(1,20,ed.dlg_name)), user_alerted = format(ed.dlg_dt_tm,cclfmt->
   shortdatetime), severity = trim(substring(1,10,dea.attr_value)),
  triggering_order_id = ed.trigger_order_id, order_detail1 = trim(substring(1,80,o.dept_misc_line)),
  start_dt_tm1 = format(o.orig_order_dt_tm,cclfmt->shortdatetime),
  interacting_order_id = dea1.attr_id, order_detail2 = trim(substring(1,80,o1.dept_misc_line)),
  start_dt_tm2 = format(o1.orig_order_dt_tm,cclfmt->shortdatetime),
  overide_reason = substring(1,45,trim(uar_get_code_display(ed.override_reason_cd))),
  overide_freetext_reason = substring(1,200,lt.long_text)
  FROM eks_dlg_event ed,
   eks_dlg_event_attr dea,
   eks_dlg_event_attr dea1,
   person p,
   person p1,
   encntr_loc_hist e,
   encntr_alias ea,
   orders o,
   orders o1,
   long_text lt,
   dummyt d,
   dummyt d2,
   dummyt d3,
   dummyt d4
  PLAN (ed
   WHERE ed.dlg_name="MUL_MED!*"
    AND ed.dlg_dt_tm BETWEEN cnvtdatetime(startdttm) AND cnvtdatetime(enddttm)
    AND ed.dlg_prsnl_id > 0)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND ed.dlg_dt_tm BETWEEN e.beg_effective_dt_tm AND e.end_effective_dt_tm)
   JOIN (ea
   WHERE ea.encntr_id=ed.encntr_id
    AND ea.encntr_alias_type_cd=cfin)
   JOIN (p
   WHERE p.person_id=ed.person_id)
   JOIN (p1
   WHERE p1.person_id=ed.dlg_prsnl_id)
   JOIN (d)
   JOIN (o
   WHERE o.order_id=ed.trigger_order_id)
   JOIN (d2)
   JOIN (lt
   WHERE ed.long_text_id=lt.long_text_id)
   JOIN (d3)
   JOIN (dea
   WHERE ed.dlg_event_id=dea.dlg_event_id
    AND dea.attr_name="SEVERITY_LEVEL")
   JOIN (d4)
   JOIN (dea1
   WHERE ed.dlg_event_id=dea1.dlg_event_id
    AND dea1.attr_name="ORDER_ID")
   JOIN (o1
   WHERE dea1.attr_id=o1.order_id)
  ORDER BY user, triggering_order_id
  HEAD REPORT
   col 0, "{ps/792}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1,
   line = fillstring(120,"_"), col 40, "*****MULTUM INTERACTIONS AUDIT REPORT*****#",
   date_stamp = cnvtdatetime(curdate,curtime3), print_time = format(date_stamp,"mmm.dd.yy hh:mm;;d"),
   col 90,
   "Printed: #", print_time, "#",
   row + 1, col 0, "DLG_EVENT_ID#",
   col 20, "USER#", col 60,
   "RECIPIENT#", col 105, "FINNBR#",
   col 120, "FACILITY#", col 140,
   "BUILDING#", col 160, "NURSEUNIT#",
   col 180, "ROOM#", col 195,
   "BED#", col 210, "INTERACTION_TYPE#",
   col 240, "USER_ALERTED#", col 265,
   "SEVERITY#", col 290, "TRIGGERING_ORDER_ID#",
   col 330, "ORDER_DETAIL1#", col 420,
   "START_DT_TM1#", col 450, "INTERACTING_ORDER_ID#",
   col 480, "ORDER_DETAIL2#", col 575,
   "START_DT_TM2#", col 600, "OVERIDE_REASON#",
   col 650, "OVERIDE_FREETEXT_REASON#", row + 1
  DETAIL
   col 0, dlg_event_id, "#",
   col 20, user, "#",
   col 60, recipient, "#",
   col 105, finnbr, "#",
   col 120, facility, "#",
   col 140, building, "#",
   col 160, nurseunit, "#",
   col 180, room, "#",
   col 195, bed, "#",
   col 210, interaction_type, "#",
   col 240, user_alerted, "#",
   col 265, severity, "#",
   col 290, triggering_order_id, "#",
   col 330, order_detail1, "#",
   col 420, start_dt_tm1, "#",
   col 450, interacting_order_id, "#",
   col 480, order_detail2, "#",
   col 575, start_dt_tm2, "#",
   col 600, overide_reason, "#",
   col 650, overide_freetext_reason, "#",
   row + 1
  WITH format = variable, maxcol = 1000, noformfeed,
   check, outerjoin = d, outerjoin = d3
 ;end select
#endprogram
END GO

CREATE PROGRAM ecase_rr_rpt
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "SYSDATE",
  "End Date" = "SYSDATE"
  WITH outdev, sdate1, edate1
 SET rr_cd = 0
 SET sdate = cnvtdatetime( $SDATE1)
 SET edate = cnvtdatetime( $EDATE1)
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=72
   AND cv.display_key="REPORTABILITYRESPONSEPUBLICHEALTH"
  DETAIL
   rr_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  name = substring(1,30,p.name_full_formatted), fin = substring(1,15,ea.alias), result_date = format(
   c.event_start_dt_tm,"mm/dd/yy hh:mm;;d"),
  reg_date = format(e.reg_dt_tm,"mm/dd/yy hh:mm;;d"), disch_date = format(e.disch_dt_tm,"mm/dd/yy"),
  encntr_type = substring(1,11,uar_get_code_display(e.encntr_type_class_cd)),
  loc = substring(1,30,o.org_name)
  FROM clinical_event c,
   person p,
   encounter e,
   encntr_alias ea,
   organization o
  PLAN (c
   WHERE c.event_cd=rr_cd
    AND c.view_level=1
    AND c.event_start_dt_tm BETWEEN cnvtdatetime(sdate) AND cnvtdatetime(edate))
   JOIN (p
   WHERE c.person_id=p.person_id)
   JOIN (e
   WHERE c.encntr_id=e.encntr_id)
   JOIN (ea
   WHERE c.encntr_id=ea.encntr_id
    AND ea.encntr_alias_type_cd=1077)
   JOIN (o
   WHERE e.organization_id=o.organization_id)
  ORDER BY e.organization_id, p.person_id, c.event_start_dt_tm DESC,
   e.reg_dt_tm DESC
  HEAD REPORT
   CALL center("eCase Reportability Response",0,130), row + 1, line = fillstring(130,"="),
   line2 = fillstring(125,"-"), row + 2, col 5,
   "Name ", col 35, "FIN",
   col 50, "Type", col 65,
   "Reg Date", col 85, "DC Date",
   col 97, "RR Date/Time", row + 1
  HEAD e.organization_id
   col 0, loc, row + 1,
   col 0, line, row + 1
  HEAD p.person_id
   row + 0, col 5, name,
   col 35, fin, col 50,
   encntr_type, col 65, reg_date,
   col 85, disch_date
  DETAIL
   col 97, result_date, row + 1
  FOOT  p.person_id
   row + 0, row + 1
  FOOT  e.organization_id
   row + 1
  WITH nocounter
 ;end select
END GO

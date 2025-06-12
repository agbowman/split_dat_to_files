CREATE PROGRAM dl_events:dba
 PROMPT
  "printer " = "MINE"
 SELECT INTO  $1
  display = uar_get_code_display(ce.event_cd), res_val = cnvtreal(ce.result_val), parent2 =
  IF (ce2.event_cd=11895) ce2.event_title_text
  ELSE uar_get_code_display(ce2.event_cd)
  ENDIF
  ,
  parent3 =
  IF (ce3.event_cd=11895) ce3.event_title_text
  ELSE uar_get_code_display(ce3.event_cd)
  ENDIF
  , cs = substring(1,50,build("1=",ce.collating_seq,"2=",ce2.collating_seq,"3=",
    ce3.collating_seq))
  FROM clinical_event ce,
   clinical_event ce2,
   clinical_event ce3
  PLAN (ce
   WHERE ce.encntr_id=1136059
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
   JOIN (ce2
   WHERE outerjoin(ce.parent_event_id)=ce2.event_id)
   JOIN (ce3
   WHERE outerjoin(ce2.parent_event_id)=ce3.event_id)
  ORDER BY cs, parent3, ce.parent_event_id
  HEAD REPORT
   line2 = fillstring(70,"_"), line1 = fillstring(80,"=")
  HEAD cs
   col + 0
  HEAD parent3
   col + 0, line1, row + 1,
   col 05, "{b} ", parent3,
   row + 1, line1, row + 1
  HEAD ce.parent_event_id
   col 15, "{b} ", parent2,
   " ", col 40, ce.parent_event_id,
   row + 1, cs, "{endb}",
   row + 1
  DETAIL
   IF (ce.event_tag != ce.result_val)
    zz = substring(1,100,concat(trim(uar_get_code_display(ce.event_cd)),": ",trim(ce.event_tag)," ",
      trim(ce.result_val),
      "   ",format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d")))
   ELSE
    zz = substring(1,100,concat(trim(uar_get_code_display(ce.event_cd))," ",trim(ce.result_val),"   ",
      format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d")))
   ENDIF
   col 20, zz, row + 1
  WITH maxqual(ce.person_id,1), maxcol = 333
 ;end select
END GO

CREATE PROGRAM bhs_rpt_early_warning_fin:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  ew.event_id, ce.event_end_dt_tm, 0,
  e.event_cd, d = uar_get_code_display(e.event_cd), ce.event_id,
  enddttm = format(ce.event_end_dt_tm,";;q"), insertdatetime = format(ew.insert_dt_tm,";;q"),
  enddatebackhours = datetimediff(cnvtdatetime(curdate,curtime),ce.event_end_dt_tm,3),
  ce.result_val, ew.event_score, ew.active_ind,
  ew.total_score
  FROM bhs_event_cd_list e,
   bhs_early_warning ew,
   clinical_event ce,
   bhs_range_system brs,
   dummyt d
  PLAN (e
   WHERE e.listkey IN ("ADULTEARLYWARNINGSYSTEM")
    AND e.active_ind=1)
   JOIN (ew
   WHERE ew.encntr_id=53025092
    AND ew.event_cd=e.event_cd)
   JOIN (ce
   WHERE ce.event_id=ew.event_id
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ce.result_status_cd IN (25.0, 34.00, 703418.00, 35.00))
   JOIN (brs
   WHERE brs.parent_entity_id=e.event_cd_list_id
    AND brs.parent_entity_name="bhs_event_cd_list"
    AND brs.active_ind=1)
   JOIN (d
   WHERE ce.event_end_dt_tm >= cnvtlookbehind(concat(trim(build2(brs.look_back_hours),3),",H"),
    cnvtdatetime(curdate,curtime)))
  ORDER BY ce.event_end_dt_tm DESC, 0
  HEAD REPORT
   x = 0, col x, "fin",
   x = (x+ 15), col x, "event_cd",
   x = (x+ 15), col x, "event",
   x = (x+ 30), col x, "event_id",
   x = (x+ 15), col x, "insert_Date_Time",
   x = (x+ 20), col x, "event_end_dt_tm",
   x = (x+ 20), col x, "EndDateBackHours",
   x = (x+ 25), col x, "Result_val",
   x = (x+ 15), col x, "event_score",
   x = (x+ 15), col x, "active_ind",
   x = (x+ 15), col x, "TotalScoreAtTimeOfEvent",
   x = (x+ 30), row + 1
  HEAD ew.event_id
   x = 0, col x, "52082953",
   x = (x+ 15), col x, e.event_cd,
   x = (x+ 15), col x, d,
   x = (x+ 30), col x, ce.event_id,
   x = (x+ 15), col x, insertdatetime,
   x = (x+ 20), col x, enddttm,
   x = (x+ 20), col x, enddatebackhours,
   x = (x+ 25), col x, ce.result_val,
   x = (x+ 15), col x, ew.event_score,
   x = (x+ 15), col x, ew.active_ind,
   x = (x+ 15), col x, ew.total_score,
   x = (x+ 30), row + 1
  HEAD ce.event_end_dt_tm
   stat = 0
  WITH format, format(date,";;q"), separator = " ",
   maxcol = 20000, formfeed = none
 ;end select
 SELECT INTO "nl:"
  DETAIL
   row + 0
  WITH skipreport = value(1)
 ;end select
END GO

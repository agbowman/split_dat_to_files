CREATE PROGRAM bhs_rpt_ews_ce_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Fin:" = ""
  WITH outdev, fin
 RECORD temp(
   1 qual[*]
     2 clinical_event_id = f8
     2 event_id = f8
 )
 SET cnt = 0
 SET encntr_id = 0.0
 SELECT
  *
  FROM encntr_alias ea
  WHERE ea.alias=trim( $FIN,3)
   AND ea.encntr_alias_type_cd=1077
   AND ea.active_ind=1
  DETAIL
   encntr_id = ea.encntr_id
  WITH nocounter
 ;end select
 SELECT
  e.event_cd, d = uar_get_code_display(e.event_cd), ce.event_id,
  ce.event_end_dt_tm, enddatebackhours = datetimediff(cnvtdatetime(curdate,curtime),ce
   .event_end_dt_tm,3), ce.result_val,
  ew.event_score, ew.active_ind, ew.total_score
  FROM bhs_event_cd_list e,
   clinical_event ce,
   bhs_range_system brs,
   dummyt d
  PLAN (e
   WHERE e.active_ind=1)
   JOIN (ce
   WHERE ce.event_cd=e.event_cd
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ce.result_status_cd IN (25.0, 34.00, 703418.00, 35.00))
   JOIN (brs
   WHERE brs.parent_entity_id=e.event_cd_list_id
    AND brs.parent_entity_name="bhs_event_cd_list"
    AND brs.active_ind=1)
   JOIN (d
   WHERE ce.event_end_dt_tm >= cnvtlookbehind(concat(trim(build2(brs.look_back_hours),3),",H"),
    cnvtdatetime(curdate,curtime)))
  ORDER BY e.grouper_id, ce.event_end_dt_tm DESC
  HEAD REPORT
   cnt = 0
  HEAD e.grouper_id
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].clinical_event_id = ce
   .clinical_event_id,
   temp->qual[cnt].event_id = ce.event_id
  HEAD ce.event_end_dt_tm
   stat = 0
  WITH format(date,";;q"), format
 ;end select
 SELECT INTO  $OUTDEV
  e.grouper_id, ce.event_end_dt_tm, ce.event_cd,
  event = uar_get_code_display(e.event_cd), ce.event_id, ce.event_end_dt_tm,
  enddatebackhours = datetimediff(cnvtdatetime(curdate,curtime),ce.event_end_dt_tm,3), ce.result_val
  FROM bhs_event_cd_list e,
   clinical_event ce,
   (dummyt d  WITH seq = cnt)
  PLAN (d)
   JOIN (e
   WHERE e.active_ind=1)
   JOIN (ce
   WHERE (ce.clinical_event_id=temp->qual[d.seq].clinical_event_id)
    AND (ce.event_id=temp->qual[d.seq].event_id)
    AND ce.active_ind=1
    AND ce.event_cd=e.event_cd
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ce.result_status_cd IN (25.0, 34.00, 703418.00, 35.00))
  WITH format(date,";;q"), format, separator = " "
 ;end select
END GO

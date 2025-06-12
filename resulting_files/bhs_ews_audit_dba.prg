CREATE PROGRAM bhs_ews_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "encntr_id" = 0
  WITH outdev, encntr_id
 RECORD temp(
   1 enc[*]
     2 encntr_id = f8
     2 last_score = vc
     2 qual[*]
       3 clinical_event_id = f8
 )
 SET cnt = 0
 SET cnt2 = 0
 SELECT INTO "NL:"
  ew.encntr_id, ew.event_cd, ew.updt_dt_tm
  FROM bhs_event_cd_list e,
   bhs_early_warning ew,
   clinical_event ce
  PLAN (e
   WHERE e.active_ind=1)
   JOIN (ew
   WHERE (ew.encntr_id= $ENCNTR_ID)
    AND ew.active_ind=1
    AND ew.event_cd=e.event_cd)
   JOIN (ce
   WHERE ce.event_id=outerjoin(ew.event_id)
    AND ce.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime)))
  ORDER BY ew.encntr_id, ew.event_cd, ew.updt_dt_tm DESC
  HEAD ew.encntr_id
   cnt = (cnt+ 1), stat = alterlist(temp->enc,cnt), temp->enc[cnt].encntr_id = ew.encntr_id,
   cnt2 = 0
  HEAD ew.event_cd
   cnt2 = (cnt2+ 1), stat = alterlist(temp->enc[cnt].qual,cnt2), temp->enc[cnt].qual[cnt2].
   clinical_event_id = ew.clinical_event_id
  HEAD ew.updt_dt_tm
   stat = 0
  WITH format(date,";;q")
 ;end select
 SELECT INTO "NL:"
  ew.encntr_id, ew.updt_dt_tm
  FROM bhs_early_warning ew,
   (dummyt d  WITH seq = cnt)
  PLAN (d)
   JOIN (ew
   WHERE (ew.encntr_id=temp->enc[d.seq].encntr_id))
  ORDER BY ew.encntr_id, ew.updt_dt_tm DESC
  HEAD ew.encntr_id
   temp->enc[d.seq].last_score = cnvtstring(ew.total_score)
  HEAD ew.updt_dt_tm
   stat = 0
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  ce.encntr_id, ce.clinical_event_id, ce.event_cd,
  event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm,
  ew.event_score, total_score = temp->enc[d1.seq].last_score, ew.active_ind,
  ew.updt_dt_tm
  FROM bhs_early_warning ew,
   clinical_event ce,
   (dummyt d1  WITH seq = cnt),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(temp->enc[d1.seq].qual,5)))
   JOIN (d2)
   JOIN (ce
   WHERE (ce.clinical_event_id=temp->enc[d1.seq].qual[d2.seq].clinical_event_id))
   JOIN (ew
   WHERE ew.encntr_id=outerjoin(ce.encntr_id)
    AND ew.clinical_event_id=outerjoin(ce.clinical_event_id)
    AND ew.active_ind=outerjoin(1))
  ORDER BY ce.encntr_id, ce.event_end_dt_tm DESC
  WITH format(date,";;q"), format, separator = " "
 ;end select
END GO

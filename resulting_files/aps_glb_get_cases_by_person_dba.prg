CREATE PROGRAM aps_glb_get_cases_by_person:dba
 RECORD temp(
   1 qual[*]
     2 case_id = f8
     2 accession_nbr = c20
     2 case_collect_dt_tm = dq8
     2 encntr_id = f8
     2 rpt_qual[*]
       3 report_sequence = i4
       3 report_id = f8
       3 event_id = f8
       3 status_cd = f8
       3 cancel_dt_tm = dq8
       3 cancel_prsnl_id = f8
       3 order_id = f8
       3 priority_cd = f8
 )
#script
 SET num_of_recs = 0
 SET bcheckce = 0
 SET max_rcnt = 0
 SET collect_date_time_where = fillstring(500," ")
 SET q_cnt = reply->qual_cnt
 IF ((request->collect_dt_tm_begin=0.0))
  SET collect_date_time_where = " 0 = 0 "
 ELSE
  SET collect_date_time_where = concat("pc.case_collect_dt_tm between cnvtdatetime(",
   "request->collect_dt_tm_begin) and cnvtdatetime(","request->collect_dt_tm_end)")
 ENDIF
 SELECT INTO "nl:"
  pc.case_id, rt_exists = decode(rt.seq,1,0)
  FROM pathology_case pc,
   case_report cr,
   (dummyt d  WITH seq = 1),
   report_task rt
  PLAN (pc
   WHERE (pc.person_id=request->person_id)
    AND parser(collect_date_time_where))
   JOIN (cr
   WHERE pc.case_id=cr.case_id)
   JOIN (d
   WHERE 1=d.seq)
   JOIN (rt
   WHERE cr.report_id=rt.report_id)
  ORDER BY pc.case_id
  HEAD REPORT
   cnt = 0, rcnt = 0
  HEAD pc.case_id
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].case_id = pc.case_id,
   temp->qual[cnt].accession_nbr = pc.accession_nbr, temp->qual[cnt].case_collect_dt_tm =
   cnvtdatetime(pc.case_collect_dt_tm), temp->qual[cnt].encntr_id = pc.encntr_id,
   rcnt = 0
  DETAIL
   IF (((rt_exists=0) OR (rt_exists=1
    AND rt.order_id != 0.0)) )
    rcnt = (rcnt+ 1)
    IF (rcnt > max_rcnt)
     max_rcnt = rcnt
    ENDIF
    stat = alterlist(temp->qual[cnt].rpt_qual,rcnt), temp->qual[cnt].rpt_qual[rcnt].report_sequence
     = cr.report_sequence, temp->qual[cnt].rpt_qual[rcnt].report_id = cr.report_id,
    temp->qual[cnt].rpt_qual[rcnt].event_id = cr.event_id, temp->qual[cnt].rpt_qual[rcnt].status_cd
     = cr.status_cd, temp->qual[cnt].rpt_qual[rcnt].cancel_dt_tm = cnvtdatetime(cr.cancel_dt_tm),
    temp->qual[cnt].rpt_qual[rcnt].cancel_prsnl_id = cr.cancel_prsnl_id
    IF (rt_exists=1)
     temp->qual[cnt].rpt_qual[rcnt].order_id = rt.order_id, temp->qual[cnt].rpt_qual[rcnt].
     priority_cd = rt.priority_cd
    ELSE
     bcheckce = 1
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 IF (bcheckce=1)
  SELECT INTO "nl:"
   ce.order_id, d.seq, d1.seq
   FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
    (dummyt d1  WITH seq = value(max_rcnt)),
    clinical_event ce
   PLAN (d)
    JOIN (d1
    WHERE d1.seq <= size(temp->qual[d.seq].rpt_qual,5))
    JOIN (ce
    WHERE (temp->qual[d.seq].rpt_qual[d1.seq].order_id=0.0)
     AND (temp->qual[d.seq].rpt_qual[d1.seq].event_id=ce.event_id)
     AND ce.valid_until_dt_tm > cnvtdatetime(sysdate))
   DETAIL
    temp->qual[d.seq].rpt_qual[d1.seq].order_id = ce.order_id
   WITH nocounter
  ;end select
 ENDIF
 IF (size(temp->qual,5) > 0)
  SELECT INTO "nl:"
   o.activity_type_cd, d.seq, d4.seq,
   oc.seq, oc.*, o.order_id,
   cs.case_specimen_id, od.seq, cv_od.seq
   FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
    (dummyt d4  WITH seq = value(max_rcnt)),
    orders o,
    encounter e,
    case_specimen cs,
    prsnl prl,
    order_comment oc,
    dummyt d1,
    dummyt d2,
    order_alias oal,
    dummyt d3,
    order_detail od,
    code_value cv_od
   PLAN (d)
    JOIN (d4
    WHERE d4.seq <= size(temp->qual[d.seq].rpt_qual,5))
    JOIN (o
    WHERE (temp->qual[d.seq].rpt_qual[d4.seq].order_id != 0.0)
     AND (temp->qual[d.seq].rpt_qual[d4.seq].order_id=o.order_id))
    JOIN (prl
    WHERE o.last_update_provider_id=prl.person_id)
    JOIN (e
    WHERE (temp->qual[d.seq].encntr_id=e.encntr_id))
    JOIN (cs
    WHERE (temp->qual[d.seq].case_id=cs.case_id)
     AND cs.cancel_cd IN (null, 0.0))
    JOIN (d1)
    JOIN (oc
    WHERE oc.order_id=o.order_id
     AND oc.comment_type_cd IN (order_comment_cd, order_note_cd, cancel_comment_cd))
    JOIN (d2)
    JOIN (oal
    WHERE oal.order_id=o.order_id
     AND oal.order_alias_type_cd=esi_alias_placerordid_cd)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (od
    WHERE od.order_id=o.order_id
     AND od.oe_field_meaning_id=oe_meaning_cancel_reason_id)
    JOIN (cv_od
    WHERE cv_od.code_value=od.oe_field_value)
   ORDER BY d.seq, d4.seq, o.order_id,
    cs.case_specimen_id
   HEAD REPORT
    collect_date_ind = 0, highest_container_status_flag = - (1), rpt_seq = 0
   HEAD d.seq
    collect_date_ind = 0
   HEAD d4.seq
    collect_date_ind = 0, highest_container_status_flag = - (1), q_cnt = (q_cnt+ 1),
    reply->qual_cnt = q_cnt, stat = alterlist(reply->qual,q_cnt), reply->qual[q_cnt].order_id = o
    .order_id,
    reply->qual[q_cnt].updt_cnt = o.updt_cnt, reply->qual[q_cnt].catalog_cd = o.catalog_cd, reply->
    qual[q_cnt].catalog_type_cd = o.catalog_type_cd
    IF ((temp->qual[d.seq].rpt_qual[d4.seq].report_sequence > 0))
     rpt_seq = (temp->qual[d.seq].rpt_qual[d4.seq].report_sequence+ 1), reply->qual[q_cnt].
     order_mnemonic = concat(trim(o.order_mnemonic)," ",cnvtstring(rpt_seq))
    ELSE
     reply->qual[q_cnt].order_mnemonic = o.order_mnemonic
    ENDIF
    reply->qual[q_cnt].activity_type_cd = o.activity_type_cd, reply->qual[q_cnt].orig_order_dt_tm = o
    .orig_order_dt_tm, reply->qual[q_cnt].order_status_cd = temp->qual[d.seq].rpt_qual[d4.seq].
    status_cd,
    reply->qual[q_cnt].cancel_prsnl_id = temp->qual[d.seq].rpt_qual[d4.seq].cancel_prsnl_id, reply->
    qual[q_cnt].cancel_dt_tm = cnvtdatetime(temp->qual[d.seq].rpt_qual[d4.seq].cancel_dt_tm), reply->
    qual[q_cnt].encntr_id = o.encntr_id,
    reply->qual[q_cnt].last_update_provider_id = o.last_update_provider_id, reply->qual[q_cnt].
    report_priority_cd = temp->qual[d.seq].rpt_qual[d4.seq].priority_cd, reply->qual[q_cnt].
    order_comment_ind = 0,
    spec_cnt = 0
   HEAD cs.case_specimen_id
    spec_cnt = (spec_cnt+ 1), stat = alterlist(reply->qual[q_cnt].spec_qual,spec_cnt), reply->qual[
    q_cnt].spec_qual[spec_cnt].specimen_cd = cs.specimen_cd,
    reply->qual[q_cnt].spec_cnt = spec_cnt
   DETAIL
    collect_date_ind = 1, reply->qual[q_cnt].last_update_provider_name = prl.name_full_formatted
    IF (e.seq > 0)
     reply->qual[q_cnt].loc_nurse_unit_cd = e.loc_nurse_unit_cd, reply->qual[q_cnt].loc_room_cd = e
     .loc_room_cd, reply->qual[q_cnt].loc_bed_cd = e.loc_bed_cd,
     reply->qual[q_cnt].reason_for_visit = e.reason_for_visit
    ENDIF
    reply->qual[q_cnt].accession = temp->qual[d.seq].accession_nbr, reply->qual[q_cnt].drawn_dt_tm =
    temp->qual[d.seq].case_collect_dt_tm
    IF (oc.seq > 0)
     reply->qual[q_cnt].order_comment_ind = 1
    ENDIF
    reply->qual[q_cnt].order_alias = oal.alias
    IF (od.seq > 0)
     reply->qual[q_cnt].cancel_reason = cv_od.display
    ENDIF
   FOOT  o.order_id
    IF (collect_date_ind=0)
     q_cnt = (q_cnt - 1), reply->qual_cnt = (reply->qual_cnt - 1), stat = alterlist(reply->qual,q_cnt
      )
    ENDIF
   WITH nocounter, maxread(oc,1), outerjoin = d1,
    dontcare = oc, outerjoin = d2, dontcare = oal,
    outerjoin = d3, dontcare = od, dontcare = cv_od
  ;end select
 ENDIF
 IF (q_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET stat = alterlist(reply->qual,q_cnt)
#exit_script
END GO

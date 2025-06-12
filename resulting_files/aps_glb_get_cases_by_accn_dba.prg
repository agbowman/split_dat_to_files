CREATE PROGRAM aps_glb_get_cases_by_accn:dba
 RECORD temp(
   1 case_id = f8
   1 accession_nbr = c20
   1 case_collect_dt_tm = dq8
   1 encntr_id = f8
   1 rpt_qual[*]
     2 report_sequence = i4
     2 report_id = f8
     2 event_id = f8
     2 status_cd = f8
     2 cancel_dt_tm = dq8
     2 cancel_prsnl_id = f8
     2 order_id = f8
     2 priority_cd = f8
 )
#script
 SET num_of_recs = 0
 SET bcheckce = 0
 SET q_cnt = reply->qual_cnt
 SELECT INTO "nl:"
  rt_exists = decode(rt.seq,1,0)
  FROM pathology_case pc,
   case_report cr,
   (dummyt d  WITH seq = 1),
   report_task rt
  PLAN (pc
   WHERE (pc.accession_nbr=request->accession))
   JOIN (cr
   WHERE pc.case_id=cr.case_id)
   JOIN (d
   WHERE 1=d.seq)
   JOIN (rt
   WHERE cr.report_id=rt.report_id)
  HEAD REPORT
   cnt = 0, temp->case_id = pc.case_id, temp->accession_nbr = pc.accession_nbr,
   temp->case_collect_dt_tm = cnvtdatetime(pc.case_collect_dt_tm), temp->encntr_id = pc.encntr_id
  DETAIL
   IF (((rt_exists=0) OR (rt_exists=1
    AND rt.order_id != 0.0)) )
    cnt = (cnt+ 1), stat = alterlist(temp->rpt_qual,cnt), temp->rpt_qual[cnt].report_sequence = cr
    .report_sequence,
    temp->rpt_qual[cnt].report_id = cr.report_id, temp->rpt_qual[cnt].event_id = cr.event_id, temp->
    rpt_qual[cnt].status_cd = cr.status_cd,
    temp->rpt_qual[cnt].cancel_dt_tm = cnvtdatetime(cr.cancel_dt_tm), temp->rpt_qual[cnt].
    cancel_prsnl_id = cr.cancel_prsnl_id
    IF (rt_exists=1)
     temp->rpt_qual[cnt].order_id = rt.order_id, temp->rpt_qual[cnt].priority_cd = rt.priority_cd
    ELSE
     bcheckce = 1
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 IF (bcheckce=1)
  SELECT INTO "nl:"
   ce.order_id, d.seq
   FROM (dummyt d  WITH seq = value(size(temp->rpt_qual,5))),
    clinical_event ce
   PLAN (d)
    JOIN (ce
    WHERE (temp->rpt_qual[d.seq].order_id=0.0)
     AND (temp->rpt_qual[d.seq].event_id=ce.event_id)
     AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
   DETAIL
    temp->rpt_qual[d.seq].order_id = ce.order_id
   WITH nocounter
  ;end select
 ENDIF
 IF (size(temp->rpt_qual,5) > 0)
  SELECT INTO "nl:"
   o.order_id, o.updt_cnt, o.catalog_cd,
   o.catalog_type_cd, o.order_mnemonic, o.activity_type_cd,
   o.orig_order_dt_tm, o.encntr_id, cs.case_specimen_id,
   cs.specimen_description, prl.name_full_formatted, e.loc_nurse_unit_cd,
   e.loc_room_cd, e.loc_bed_cd, e.reason_for_visit,
   d.seq, oal.seq, od.seq,
   cv_od.seq
   FROM (dummyt d  WITH seq = value(size(temp->rpt_qual,5))),
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
    JOIN (o
    WHERE (temp->rpt_qual[d.seq].order_id != 0.0)
     AND (temp->rpt_qual[d.seq].order_id=o.order_id))
    JOIN (prl
    WHERE o.last_update_provider_id=prl.person_id)
    JOIN (e
    WHERE (temp->encntr_id=e.encntr_id))
    JOIN (cs
    WHERE (temp->case_id=cs.case_id)
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
   ORDER BY d.seq, o.order_id, cs.case_specimen_id
   HEAD REPORT
    collect_date_ind = 0, highest_container_status_flag = - (1), rpt_seq = 0
   HEAD d.seq
    collect_date_ind = 0, highest_container_status_flag = - (1), q_cnt = (q_cnt+ 1),
    reply->qual_cnt = q_cnt, stat = alterlist(reply->qual,q_cnt), reply->qual[q_cnt].order_id = o
    .order_id,
    reply->qual[q_cnt].updt_cnt = o.updt_cnt, reply->qual[q_cnt].catalog_cd = o.catalog_cd, reply->
    qual[q_cnt].catalog_type_cd = o.catalog_type_cd
    IF ((temp->rpt_qual[d.seq].report_sequence > 0))
     rpt_seq = (temp->rpt_qual[d.seq].report_sequence+ 1), reply->qual[q_cnt].order_mnemonic = concat
     (trim(o.order_mnemonic)," ",cnvtstring(rpt_seq))
    ELSE
     reply->qual[q_cnt].order_mnemonic = o.order_mnemonic
    ENDIF
    reply->qual[q_cnt].activity_type_cd = o.activity_type_cd, reply->qual[q_cnt].orig_order_dt_tm = o
    .orig_order_dt_tm, reply->qual[q_cnt].order_status_cd = temp->rpt_qual[d.seq].status_cd,
    reply->qual[q_cnt].cancel_dt_tm = cnvtdatetime(temp->rpt_qual[d.seq].cancel_dt_tm), reply->qual[
    q_cnt].cancel_prsnl_id = temp->rpt_qual[d.seq].cancel_prsnl_id, reply->qual[q_cnt].encntr_id = o
    .encntr_id,
    reply->qual[q_cnt].last_update_provider_id = o.last_update_provider_id, reply->qual[q_cnt].
    report_priority_cd = temp->rpt_qual[d.seq].priority_cd, reply->qual[q_cnt].order_comment_ind = 0,
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
    reply->qual[q_cnt].accession = temp->accession_nbr, reply->qual[q_cnt].drawn_dt_tm = cnvtdatetime
    (temp->case_collect_dt_tm)
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

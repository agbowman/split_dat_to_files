CREATE PROGRAM bbt_get_xm_validation_info:dba
 RECORD reply(
   1 qual[*]
     2 product_event_id = f8
     2 person_id = f8
     2 accession = c20
     2 person_full_name = vc
     2 event_type_cd = f8
     2 event_type_disp = c40
     2 event_type_desc = c60
     2 event_type_mean = c12
     2 active_ind = i4
     2 result_value_numeric = f8
     2 result_value_dt_tm = dq8
     2 result_value_alpha = vc
     2 string_identifier = vc
     2 perform_dt_tm = dq8
     2 bb_result_processing_cd = f8
     2 bb_result_processing_disp = c40
     2 bb_result_processing_mean = c12
     2 result_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET cv_required_recs = 4
 DECLARE cv_cnt = i4
 SET product_states_codeset = 1610
 SET in_progress_cdf = "16"
 SET crossmatch_cdf = "3"
 SET bb_result_process_codeset = 1636
 SET history_upd_cdf = "HISTRY & UPD"
 SET history_cdf = "HISTRY ONLY"
 DECLARE in_progress_cd = f8
 DECLARE crossmatch_cd = f8
 DECLARE xm_interp_cd = f8
 DECLARE xm_hist_only_interp_cd = f8
 DECLARE q_cnt = i4
 DECLARE d_cnt = i4
 DECLARE process_cd = f8
 SET reply->status_data.status = "F"
 SET q_cnt = 0
 SET d_cnt = 0
 DECLARE srch_idx = i4 WITH noconstant(0), public
 SET cv_cnt = 0
 SELECT INTO "nl:"
  cv.code_set, cv.code_value
  FROM code_value cv
  WHERE cv.code_set IN (product_states_codeset, bb_result_process_codeset)
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   IF (cv.code_set=product_states_codeset)
    CASE (cv.cdf_meaning)
     OF in_progress_cdf:
      in_progress_cd = cv.code_value,cv_cnt += 1
     OF crossmatch_cdf:
      crossmatch_cd = cv.code_value,cv_cnt += 1
    ENDCASE
   ENDIF
   IF (cv.code_set=bb_result_process_codeset)
    CASE (cv.cdf_meaning)
     OF history_upd_cdf:
      xm_interp_cd = cv.code_value,cv_cnt += 1
     OF history_cdf:
      xm_hist_only_interp_cd = cv.code_value,cv_cnt += 1
    ENDCASE
   ENDIF
  WITH nocounter
 ;end select
 IF (cv_cnt != cv_required_recs)
  GO TO resize_reply
 ENDIF
 SELECT INTO "nl:"
  pe.product_id, pe.event_type_cd, pe.order_id,
  pe.bb_result_id, c.person_id, d1.seq,
  aor.seq, o.order_id, p.person_id,
  d2.seq, result_exists = decode(r.seq,"Y","N"), ptr.task_assay_cd,
  r.order_id, r.task_assay_cd, r.bb_result_id,
  r.result_id, pr.result_id, pr.result_status_cd,
  n.nomenclature_id
  FROM product_event pe,
   crossmatch c,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   accession_order_r aor,
   orders o,
   person p,
   profile_task_r ptr,
   result r,
   perform_result pr,
   nomenclature n,
   discrete_task_assay dta
  PLAN (pe
   WHERE (pe.product_id=request->product_id)
    AND pe.product_event_id > 0
    AND ((pe.event_type_cd=in_progress_cd
    AND pe.active_ind=1) OR (pe.event_type_cd=crossmatch_cd)) )
   JOIN (aor
   WHERE aor.order_id=pe.order_id
    AND aor.order_id > 0
    AND aor.primary_flag=0)
   JOIN (o
   WHERE o.order_id=pe.order_id)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (ptr
   WHERE ptr.catalog_cd=o.catalog_cd
    AND ptr.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd
    AND ((dta.bb_result_processing_cd=xm_interp_cd) OR (dta.bb_result_processing_cd=
   xm_hist_only_interp_cd)) )
   JOIN (d1)
   JOIN (c
   WHERE c.product_event_id=pe.product_event_id)
   JOIN (d2)
   JOIN (r
   WHERE r.order_id=o.order_id
    AND r.task_assay_cd=ptr.task_assay_cd
    AND r.bb_result_id=pe.bb_result_id)
   JOIN (pr
   WHERE pr.result_id=r.result_id
    AND pr.result_status_cd=r.result_status_cd)
   JOIN (n
   WHERE n.nomenclature_id=pr.nomenclature_id)
  HEAD REPORT
   q_cnt = 0
  DETAIL
   IF (pe.active_ind=0
    AND pe.event_type_cd=crossmatch_cd
    AND result_exists="Y")
    IF ((c.person_id=request->person_id))
     q_cnt += 1, stat = alterlist(reply->qual,q_cnt), reply->qual[q_cnt].product_event_id = pe
     .product_event_id,
     reply->qual[q_cnt].result_id = r.result_id, reply->qual[q_cnt].person_id = o.person_id, reply->
     qual[q_cnt].accession = aor.accession,
     reply->qual[q_cnt].person_full_name = p.name_full_formatted, reply->qual[q_cnt].event_type_cd =
     pe.event_type_cd, reply->qual[q_cnt].active_ind = pe.active_ind,
     reply->qual[q_cnt].result_value_numeric = pr.result_value_numeric, reply->qual[q_cnt].
     result_value_dt_tm = pr.result_value_dt_tm, reply->qual[q_cnt].result_value_alpha = pr
     .result_value_alpha,
     reply->qual[q_cnt].perform_dt_tm = pr.perform_dt_tm, reply->qual[q_cnt].string_identifier = n
     .source_string_keycap, reply->qual[q_cnt].bb_result_processing_cd = dta.bb_result_processing_cd
    ENDIF
   ELSEIF (((pe.active_ind=1
    AND pe.event_type_cd=crossmatch_cd
    AND result_exists="Y") OR (pe.active_ind=1
    AND pe.event_type_cd=in_progress_cd)) )
    q_cnt += 1, stat = alterlist(reply->qual,q_cnt), reply->qual[q_cnt].product_event_id = pe
    .product_event_id,
    reply->qual[q_cnt].result_id = r.result_id, reply->qual[q_cnt].person_id = o.person_id, reply->
    qual[q_cnt].accession = aor.accession,
    reply->qual[q_cnt].person_full_name = p.name_full_formatted, reply->qual[q_cnt].event_type_cd =
    pe.event_type_cd, reply->qual[q_cnt].active_ind = pe.active_ind,
    reply->qual[q_cnt].bb_result_processing_cd = dta.bb_result_processing_cd
    IF (result_exists="Y")
     reply->qual[q_cnt].result_value_numeric = pr.result_value_numeric, reply->qual[q_cnt].
     result_value_dt_tm = pr.result_value_dt_tm, reply->qual[q_cnt].result_value_alpha = pr
     .result_value_alpha,
     reply->qual[q_cnt].perform_dt_tm = pr.perform_dt_tm, reply->qual[q_cnt].string_identifier = n
     .source_string_keycap
    ENDIF
   ENDIF
  WITH nocounter, dontcare = c, outerjoin = d1,
   outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  pe.product_id, pe.event_type_cd, pe.order_id,
  pe.bb_result_id, c.person_id, d1.seq,
  aor.seq, o.order_id, p.person_id,
  d2.seq, result_exists = decode(r.seq,"Y","N"), pg.task_assay_cd,
  r.order_id, r.task_assay_cd, r.bb_result_id,
  r.result_id, pr.result_id, pr.result_status_cd,
  n.nomenclature_id
  FROM product_event pe,
   crossmatch c,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   accession_order_r aor,
   orders o,
   person p,
   result r,
   perform_result pr,
   nomenclature n,
   bb_order_phase bbop,
   phase_group pg,
   discrete_task_assay dta
  PLAN (pe
   WHERE (pe.product_id=request->product_id)
    AND pe.product_event_id > 0
    AND ((pe.event_type_cd=in_progress_cd
    AND pe.active_ind=1) OR (pe.event_type_cd=crossmatch_cd)) )
   JOIN (aor
   WHERE aor.order_id=pe.order_id
    AND aor.order_id > 0
    AND aor.primary_flag=0)
   JOIN (o
   WHERE o.order_id=pe.order_id)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (bbop
   WHERE bbop.order_id=o.order_id)
   JOIN (pg
   WHERE pg.phase_group_cd=bbop.phase_grp_cd)
   JOIN (dta
   WHERE dta.task_assay_cd=pg.task_assay_cd
    AND ((dta.bb_result_processing_cd=xm_interp_cd) OR (dta.bb_result_processing_cd=
   xm_hist_only_interp_cd)) )
   JOIN (d1)
   JOIN (c
   WHERE c.product_event_id=pe.product_event_id)
   JOIN (d2)
   JOIN (r
   WHERE r.order_id=o.order_id
    AND r.task_assay_cd=pg.task_assay_cd
    AND r.bb_result_id=pe.bb_result_id)
   JOIN (pr
   WHERE pr.result_id=r.result_id
    AND pr.result_status_cd=r.result_status_cd)
   JOIN (n
   WHERE n.nomenclature_id=pr.nomenclature_id)
  HEAD REPORT
   row + 0
  DETAIL
   IF (pe.active_ind=0
    AND pe.event_type_cd=crossmatch_cd
    AND result_exists="Y")
    IF ((c.person_id=request->person_id))
     q_cnt += 1, stat = alterlist(reply->qual,q_cnt), reply->qual[q_cnt].product_event_id = pe
     .product_event_id,
     reply->qual[q_cnt].result_id = r.result_id, reply->qual[q_cnt].person_id = o.person_id, reply->
     qual[q_cnt].accession = aor.accession,
     reply->qual[q_cnt].person_full_name = p.name_full_formatted, reply->qual[q_cnt].event_type_cd =
     pe.event_type_cd, reply->qual[q_cnt].active_ind = pe.active_ind,
     reply->qual[q_cnt].result_value_numeric = pr.result_value_numeric, reply->qual[q_cnt].
     result_value_dt_tm = pr.result_value_dt_tm, reply->qual[q_cnt].result_value_alpha = pr
     .result_value_alpha,
     reply->qual[q_cnt].perform_dt_tm = pr.perform_dt_tm, reply->qual[q_cnt].string_identifier = n
     .source_string_keycap, reply->qual[q_cnt].bb_result_processing_cd = dta.bb_result_processing_cd
    ENDIF
   ELSEIF (((pe.active_ind=1
    AND pe.event_type_cd=crossmatch_cd
    AND result_exists="Y") OR (pe.active_ind=1
    AND pe.event_type_cd=in_progress_cd)) )
    q_cnt += 1, stat = alterlist(reply->qual,q_cnt), reply->qual[q_cnt].product_event_id = pe
    .product_event_id,
    reply->qual[q_cnt].result_id = r.result_id, reply->qual[q_cnt].person_id = o.person_id, reply->
    qual[q_cnt].accession = aor.accession,
    reply->qual[q_cnt].person_full_name = p.name_full_formatted, reply->qual[q_cnt].event_type_cd =
    pe.event_type_cd, reply->qual[q_cnt].active_ind = pe.active_ind,
    reply->qual[q_cnt].bb_result_processing_cd = dta.bb_result_processing_cd
    IF (result_exists="Y")
     reply->qual[q_cnt].result_value_numeric = pr.result_value_numeric, reply->qual[q_cnt].
     result_value_dt_tm = pr.result_value_dt_tm, reply->qual[q_cnt].result_value_alpha = pr
     .result_value_alpha,
     reply->qual[q_cnt].perform_dt_tm = pr.perform_dt_tm, reply->qual[q_cnt].string_identifier = n
     .source_string_keycap
    ENDIF
   ENDIF
  WITH nocounter, dontcare = c, outerjoin = d1,
   outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  pe.product_id, pe.event_type_cd, pe.order_id,
  pe.bb_result_id, pe.event_dt_tm, aor.seq,
  o.order_id, p.person_id, result_exists = decode(r.seq,"Y","N"),
  ptr.task_assay_cd, r.order_id, r.task_assay_cd,
  r.bb_result_id, r.result_id, pr.result_id,
  pr.result_status_cd, n.nomenclature_id
  FROM product_event pe,
   accession_order_r aor,
   orders o,
   person p,
   profile_task_r ptr,
   result r,
   perform_result pr,
   nomenclature n,
   discrete_task_assay dta
  PLAN (pe
   WHERE (pe.product_id=request->product_id)
    AND pe.product_event_id > 0
    AND pe.bb_result_id > 0.0
    AND pe.event_type_cd=in_progress_cd
    AND pe.active_ind=0)
   JOIN (o
   WHERE o.order_id=pe.order_id
    AND (o.person_id=request->person_id))
   JOIN (aor
   WHERE aor.order_id=pe.order_id
    AND aor.order_id > 0
    AND aor.primary_flag=0)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (ptr
   WHERE ptr.catalog_cd=o.catalog_cd
    AND ptr.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd
    AND ((dta.bb_result_processing_cd=xm_interp_cd) OR (dta.bb_result_processing_cd=
   xm_hist_only_interp_cd)) )
   JOIN (r
   WHERE r.order_id=o.order_id
    AND r.task_assay_cd=ptr.task_assay_cd
    AND r.bb_result_id=pe.bb_result_id)
   JOIN (pr
   WHERE pr.result_id=r.result_id
    AND pr.result_status_cd=r.result_status_cd)
   JOIN (n
   WHERE n.nomenclature_id=pr.nomenclature_id)
  ORDER BY cnvtdatetime(pr.perform_dt_tm)
  DETAIL
   IF (result_exists="Y")
    IF (locateval(srch_idx,1,size(reply->qual,5),pe.product_event_id,reply->qual[srch_idx].
     product_event_id)=0
     AND locateval(srch_idx,1,size(reply->qual,5),pr.perform_dt_tm,reply->qual[srch_idx].
     perform_dt_tm)=0)
     q_cnt += 1, stat = alterlist(reply->qual,q_cnt), reply->qual[q_cnt].product_event_id = pe
     .product_event_id,
     reply->qual[q_cnt].result_id = r.result_id, reply->qual[q_cnt].person_id = o.person_id, reply->
     qual[q_cnt].accession = aor.accession,
     reply->qual[q_cnt].person_full_name = p.name_full_formatted, reply->qual[q_cnt].event_type_cd =
     pe.event_type_cd, reply->qual[q_cnt].active_ind = pe.active_ind,
     reply->qual[q_cnt].result_value_numeric = pr.result_value_numeric, reply->qual[q_cnt].
     result_value_dt_tm = pr.result_value_dt_tm, reply->qual[q_cnt].result_value_alpha = pr
     .result_value_alpha,
     reply->qual[q_cnt].perform_dt_tm = pr.perform_dt_tm, reply->qual[q_cnt].string_identifier = n
     .source_string_keycap, reply->qual[q_cnt].bb_result_processing_cd = dta.bb_result_processing_cd
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pe.product_id, pe.event_type_cd, pe.order_id,
  pe.bb_result_id, pe.event_dt_tm, aor.seq,
  o.order_id, p.person_id, result_exists = decode(r.seq,"Y","N"),
  pg.task_assay_cd, r.order_id, r.task_assay_cd,
  r.bb_result_id, r.result_id, pr.result_id,
  pr.result_status_cd, n.nomenclature_id
  FROM product_event pe,
   accession_order_r aor,
   orders o,
   person p,
   result r,
   perform_result pr,
   nomenclature n,
   bb_order_phase bbop,
   phase_group pg,
   discrete_task_assay dta
  PLAN (pe
   WHERE (pe.product_id=request->product_id)
    AND pe.product_event_id > 0
    AND pe.bb_result_id > 0.0
    AND pe.event_type_cd=in_progress_cd
    AND pe.active_ind=0)
   JOIN (o
   WHERE o.order_id=pe.order_id
    AND (o.person_id=request->person_id))
   JOIN (aor
   WHERE aor.order_id=pe.order_id
    AND aor.order_id > 0
    AND aor.primary_flag=0)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (bbop
   WHERE bbop.order_id=o.order_id)
   JOIN (pg
   WHERE pg.phase_group_cd=bbop.phase_grp_cd)
   JOIN (dta
   WHERE dta.task_assay_cd=pg.task_assay_cd
    AND ((dta.bb_result_processing_cd=xm_interp_cd) OR (dta.bb_result_processing_cd=
   xm_hist_only_interp_cd)) )
   JOIN (r
   WHERE r.order_id=o.order_id
    AND r.task_assay_cd=pg.task_assay_cd
    AND r.bb_result_id=pe.bb_result_id)
   JOIN (pr
   WHERE pr.result_id=r.result_id
    AND pr.result_status_cd=r.result_status_cd)
   JOIN (n
   WHERE n.nomenclature_id=pr.nomenclature_id)
  ORDER BY cnvtdatetime(pr.perform_dt_tm)
  DETAIL
   IF (result_exists="Y")
    IF (locateval(srch_idx,1,size(reply->qual,5),pe.product_event_id,reply->qual[srch_idx].
     product_event_id)=0
     AND locateval(srch_idx,1,size(reply->qual,5),pr.perform_dt_tm,reply->qual[srch_idx].
     perform_dt_tm)=0)
     q_cnt += 1, stat = alterlist(reply->qual,q_cnt), reply->qual[q_cnt].product_event_id = pe
     .product_event_id,
     reply->qual[q_cnt].result_id = r.result_id, reply->qual[q_cnt].person_id = o.person_id, reply->
     qual[q_cnt].accession = aor.accession,
     reply->qual[q_cnt].person_full_name = p.name_full_formatted, reply->qual[q_cnt].event_type_cd =
     pe.event_type_cd, reply->qual[q_cnt].active_ind = pe.active_ind,
     reply->qual[q_cnt].result_value_numeric = pr.result_value_numeric, reply->qual[q_cnt].
     result_value_dt_tm = pr.result_value_dt_tm, reply->qual[q_cnt].result_value_alpha = pr
     .result_value_alpha,
     reply->qual[q_cnt].perform_dt_tm = pr.perform_dt_tm, reply->qual[q_cnt].string_identifier = n
     .source_string_keycap, reply->qual[q_cnt].bb_result_processing_cd = dta.bb_result_processing_cd
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
#resize_reply
 IF (q_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to retrieve xm info"
  SET q_cnt = 1
 ENDIF
 SET stat = alterlist(reply->qual,q_cnt)
END GO

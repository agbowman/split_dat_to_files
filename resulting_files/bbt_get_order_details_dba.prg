CREATE PROGRAM bbt_get_order_details:dba
 RECORD reply(
   1 qual[*]
     2 order_id = f8
     2 catalog_cd = f8
     2 order_mnemonic = vc
     2 assays_cnt = i4
     2 assays[*]
       3 task_assay_cd = f8
       3 task_assay_disp = vc
       3 sequence = i4
       3 bb_result_processing_cd = f8
       3 result_cnt = i4
       3 result[*]
         4 result_id = f8
         4 bb_result_id = f8
         4 bb_control_cell_cd = f8
         4 bb_control_cell_disp = vc
         4 product_id = f8
         4 product_nbr = c20
         4 result_status_cd = f8
         4 result_status_disp = vc
         4 result_status_mean = c12
         4 result_type_cd = f8
         4 result_type_disp = vc
         4 result_type_mean = c12
         4 result_value_dt_tm = dq8
         4 result_value_numeric = f8
         4 numeric_raw_value = f8
         4 less_great_flag = i2
         4 result_value_alpha = vc
         4 long_text_id = f8
         4 rtf_text = vc
         4 ascii_text = vc
         4 result_code_set_cd = f8
         4 result_code_set_disp = vc
         4 perform_dt_tm = dq8
         4 perform_personnel_id = f8
         4 name_full_formatted = vc
         4 normal_cd = f8
         4 normal_disp = vc
         4 normal_mean = c12
         4 critical_cd = f8
         4 critical_disp = vc
         4 critical_mean = c12
         4 review_cd = f8
         4 review_disp = vc
         4 review_mean = c12
         4 delta_cd = f8
         4 delta_disp = vc
         4 delta_mean = c12
         4 normal_range_flag = i2
         4 normal_low = f8
         4 normal_high = f8
         4 normal_alpha = vc
         4 data_map_ind = i2
         4 max_digits = i4
         4 min_digits = i4
         4 min_decimal_places = i4
         4 result_comment_ind = i2
         4 service_resource_cd = f8
         4 notify_cd = f8
         4 notify_disp = vc
         4 notify_mean = c12
       3 pending_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 qual[*]
     2 order_id = f8
     2 catalog_cd = f8
     2 order_mnemonic = vc
     2 assays_cnt = i4
     2 assays[*]
       3 task_assay_cd = f8
       3 task_assay_disp = vc
       3 sequence = i4
       3 result_cnt = i4
       3 bb_result_processing_cd = f8
       3 bb_result_processing_disp = vc
       3 result[*]
         4 bb_result_id = f8
         4 orv_sequence = i4
       3 pending_ind = i2
 )
#script
 SET cv_required_recs = 3
 DECLARE cv_cnt = i4
 SET comment_type_codeset = 14
 SET result_comment_cdf = "RES COMMENT"
 SET result_note_cdf = "RES NOTE"
 SET product_states_codeset = 1610
 SET product_states_16_cdf = "16"
 SET data_map_type_flag = 0
 SET subsection_cdf = "SUBSECTION"
 SET serv_res_type_codeset = 223
 DECLARE result_comment_cd = f8
 DECLARE result_note_cd = f8
 DECLARE in_progress_cd = f8
 DECLARE q_cnt = i4
 DECLARE a_cnt = i4
 DECLARE r_cnt = i4
 DECLARE max_q_cnt = i4
 DECLARE max_a_cnt = i4
 DECLARE max_r_cnt = i4
 DECLARE max_reply_q_cnt = i2
 DECLARE max_reply_a_cnt = i2
 DECLARE stat = i4
 DECLARE max_tempr_cnt = i4
 DECLARE bb_rslt_proc_cs = i4 WITH protect, constant(1636)
 DECLARE ab_scrn_intp_cdf = c12 WITH protect, constant("AB SCRN INTP")
 DECLARE ab_titer_cdf = c12 WITH protect, constant("AB TITER")
 DECLARE abid_interp_cdf = c12 WITH protect, constant("ABID INTERP")
 DECLARE absc_ci = c12 WITH protect, constant("ABSC CI")
 DECLARE absc_interp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ab_titer_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ab_id_interp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE absc_comp_interp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE o_cnt = i4 WITH protect, noconstant(0)
 DECLARE serv_res_subsection_cd = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET q_cnt = 0
 SET a_cnt = 0
 SET r_cnt = 0
 SET o_cnt = 0
 SET max_q_cnt = 0
 SET max_a_cnt = 0
 SET max_r_cnt = 0
 SET max_reply_q_cnt = 0
 SET max_reply_a_cnt = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET uar_failed = 0
 SET cdf_meaning = result_note_cdf
 SET stat = uar_get_meaning_by_codeset(comment_type_codeset,cdf_meaning,1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET result_note_cd = code_value
 ENDIF
 SET cdf_meaning = result_comment_cdf
 SET stat = uar_get_meaning_by_codeset(comment_type_codeset,cdf_meaning,1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET result_comment_cd = code_value
 ENDIF
 SET cdf_meaning = product_states_16_cdf
 SET stat = uar_get_meaning_by_codeset(product_states_codeset,cdf_meaning,1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET in_progress_cd = code_value
 ENDIF
 SET cdf_meaning = ab_scrn_intp_cdf
 SET stat = uar_get_meaning_by_codeset(bb_rslt_proc_cs,nullterm(cdf_meaning),1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET absc_interp_cd = code_value
 ENDIF
 SET cdf_meaning = ab_titer_cdf
 SET stat = uar_get_meaning_by_codeset(bb_rslt_proc_cs,nullterm(cdf_meaning),1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET ab_titer_cd = code_value
 ENDIF
 SET cdf_meaning = abid_interp_cdf
 SET stat = uar_get_meaning_by_codeset(bb_rslt_proc_cs,nullterm(cdf_meaning),1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET ab_id_interp_cd = code_value
 ENDIF
 SET cdf_meaning = absc_ci
 SET stat = uar_get_meaning_by_codeset(bb_rslt_proc_cs,nullterm(cdf_meaning),1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET absc_comp_interp_cd = code_value
 ENDIF
 SET cdf_meaning = subsection_cdf
 SET stat = uar_get_meaning_by_codeset(serv_res_type_codeset,nullterm(cdf_meaning),1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET serv_res_subsection_cd = code_value
 ENDIF
#skip_rest
 IF (uar_failed=1)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 IF ((request->entire_accession_ind=1))
  SELECT INTO "nl:"
   aor1.order_id, aor1.accession, aor2.accession,
   aor2.order_id, o.order_id, o.catalog_cd,
   o.order_mnemonic
   FROM accession_order_r aor1,
    accession_order_r aor2,
    orders o
   PLAN (aor1
    WHERE (aor1.order_id=request->order_id)
     AND aor1.primary_flag=0)
    JOIN (aor2
    WHERE aor2.accession=aor1.accession)
    JOIN (o
    WHERE o.order_id=aor2.order_id)
   ORDER BY o.catalog_cd
   HEAD REPORT
    q_cnt = 0
   DETAIL
    q_cnt += 1
    IF (mod(q_cnt,10)=1)
     stat = alterlist(temp->qual,(q_cnt+ 9))
    ENDIF
    temp->qual[q_cnt].order_id = o.order_id, temp->qual[q_cnt].catalog_cd = o.catalog_cd, temp->qual[
    q_cnt].order_mnemonic = o.order_mnemonic,
    temp->qual[q_cnt].assays_cnt = 0
   FOOT REPORT
    stat = alterlist(temp->qual,q_cnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   o.order_id, o.catalog_cd, o.order_mnemonic
   FROM orders o
   PLAN (o
    WHERE (o.order_id=request->order_id))
   HEAD REPORT
    q_cnt = 0
   DETAIL
    q_cnt += 1, stat = alterlist(temp->qual,q_cnt), temp->qual[q_cnt].order_id = o.order_id,
    temp->qual[q_cnt].catalog_cd = o.catalog_cd, temp->qual[q_cnt].order_mnemonic = o.order_mnemonic,
    temp->qual[q_cnt].assays_cnt = 0
   WITH nocounter
  ;end select
 ENDIF
 IF (q_cnt > 0)
  SET max_q_cnt = q_cnt
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d.seq, bop.seq, pg.seq,
  pg.sequence, dta.bb_result_processing_cd, r.bb_result_id
  FROM (dummyt d  WITH seq = value(max_q_cnt)),
   bb_order_phase bop,
   phase_group pg,
   discrete_task_assay dta,
   result r
  PLAN (d)
   JOIN (bop
   WHERE (bop.order_id=temp->qual[d.seq].order_id))
   JOIN (pg
   WHERE pg.phase_group_cd=bop.phase_grp_cd
    AND pg.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=pg.task_assay_cd)
   JOIN (r
   WHERE (r.order_id= Outerjoin(temp->qual[d.seq].order_id))
    AND (r.task_assay_cd= Outerjoin(pg.task_assay_cd)) )
  ORDER BY d.seq, r.bb_result_id, pg.sequence
  HEAD REPORT
   q_cnt = 0, a_cnt = 0, r_cnt = 0
  HEAD d.seq
   q_cnt = d.seq, a_cnt = 0, o_cnt = 0
  HEAD pg.sequence
   a_cnt += 1
   IF (mod(a_cnt,10)=1)
    stat = alterlist(temp->qual[q_cnt].assays,(a_cnt+ 9))
   ENDIF
   IF (a_cnt > max_a_cnt)
    max_a_cnt = a_cnt
   ENDIF
   temp->qual[q_cnt].assays_cnt = a_cnt, temp->qual[q_cnt].assays[a_cnt].task_assay_cd = pg
   .task_assay_cd, temp->qual[q_cnt].assays[a_cnt].task_assay_disp = uar_get_code_display(pg
    .task_assay_cd),
   temp->qual[q_cnt].assays[a_cnt].sequence = pg.sequence, temp->qual[q_cnt].assays[a_cnt].
   bb_result_processing_cd = dta.bb_result_processing_cd, temp->qual[q_cnt].assays[a_cnt].
   bb_result_processing_disp = uar_get_code_display(dta.bb_result_processing_cd),
   r_cnt = 0
  DETAIL
   o_cnt += 1, r_cnt += 1
   IF (r_cnt > max_tempr_cnt)
    max_tempr_cnt = r_cnt
   ENDIF
   IF (size(temp->qual[q_cnt].assays[a_cnt].result,5) < r_cnt)
    stat = alterlist(temp->qual[q_cnt].assays[a_cnt].result,r_cnt)
   ENDIF
   temp->qual[q_cnt].assays[a_cnt].result_cnt = r_cnt, temp->qual[q_cnt].assays[a_cnt].result[r_cnt].
   bb_result_id = r.bb_result_id, temp->qual[q_cnt].assays[a_cnt].result[r_cnt].orv_sequence = o_cnt
  FOOT  pg.sequence
   stat = alterlist(temp->qual[q_cnt].assays[a_cnt].result,r_cnt)
  FOOT  d.seq
   stat = alterlist(temp->qual[q_cnt].assays,a_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq, ptr.sequence, ptr.pending_ind,
  dta.bb_result_processing_cd, r.bb_result_id, ptr_seq_dta_cd = build(format(ptr.sequence,"######;P0"
    ),"_",format(ptr.task_assay_cd,"########################;P0"))
  FROM (dummyt d  WITH seq = value(max_q_cnt)),
   profile_task_r ptr,
   discrete_task_assay dta,
   result r
  PLAN (d)
   JOIN (ptr
   WHERE (ptr.catalog_cd=temp->qual[d.seq].catalog_cd))
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd)
   JOIN (r
   WHERE (r.order_id= Outerjoin(temp->qual[d.seq].order_id))
    AND (r.task_assay_cd= Outerjoin(ptr.task_assay_cd)) )
  ORDER BY d.seq, ptr_seq_dta_cd, r.bb_result_id
  HEAD REPORT
   q_cnt = 0, a_cnt = 0, r_cnt = 0,
   loop_cnt = 0, bmatch_found = "F"
  HEAD d.seq
   q_cnt = d.seq, a_cnt = temp->qual[q_cnt].assays_cnt
  HEAD ptr_seq_dta_cd
   IF (((ptr.active_ind=1) OR (r.result_id > 0.0)) )
    a_cnt += 1
    IF (size(temp->qual[q_cnt].assays,5) <= a_cnt)
     stat = alterlist(temp->qual[q_cnt].assays,(a_cnt+ 9))
    ENDIF
    IF (a_cnt > max_a_cnt)
     max_a_cnt = a_cnt
    ENDIF
    temp->qual[q_cnt].assays_cnt = a_cnt, temp->qual[q_cnt].assays[a_cnt].task_assay_cd = ptr
    .task_assay_cd, temp->qual[q_cnt].assays[a_cnt].task_assay_disp = uar_get_code_display(ptr
     .task_assay_cd),
    temp->qual[q_cnt].assays[a_cnt].sequence = a_cnt, temp->qual[q_cnt].assays[a_cnt].
    bb_result_processing_cd = dta.bb_result_processing_cd, temp->qual[q_cnt].assays[a_cnt].
    bb_result_processing_disp = uar_get_code_display(dta.bb_result_processing_cd),
    temp->qual[q_cnt].assays[a_cnt].pending_ind = ptr.pending_ind, r_cnt = 0
   ENDIF
  HEAD r.bb_result_id
   IF (((ptr.active_ind=1) OR (r.result_id > 0.0)) )
    bmatch_found = "F", o_cnt += 1, r_cnt += 1
    IF (r_cnt > max_tempr_cnt)
     max_tempr_cnt = r_cnt
    ENDIF
    IF (size(temp->qual[q_cnt].assays[a_cnt].result,5) < r_cnt)
     stat = alterlist(temp->qual[q_cnt].assays[a_cnt].result,r_cnt)
    ENDIF
    temp->qual[q_cnt].assays[a_cnt].result_cnt = r_cnt, temp->qual[q_cnt].assays[a_cnt].result[r_cnt]
    .bb_result_id = r.bb_result_id
    IF (r.bb_result_id=0)
     IF (dta.bb_result_processing_cd IN (absc_interp_cd, ab_titer_cd, ab_id_interp_cd,
     absc_comp_interp_cd))
      temp->qual[q_cnt].assays[a_cnt].result[r_cnt].orv_sequence = o_cnt
     ELSE
      temp->qual[q_cnt].assays[a_cnt].result[r_cnt].orv_sequence = 0, o_cnt -= 1
     ENDIF
    ELSE
     FOR (loop_1 = 1 TO temp->qual[q_cnt].assays_cnt)
       FOR (loop_2 = 1 TO temp->qual[q_cnt].assays[loop_1].result_cnt)
         IF ((r.bb_result_id=temp->qual[q_cnt].assays[loop_1].result[loop_2].bb_result_id))
          IF ((temp->qual[q_cnt].assays[loop_1].result[loop_2].orv_sequence=0))
           temp->qual[q_cnt].assays[a_cnt].result[r_cnt].orv_sequence = r_cnt
          ELSE
           temp->qual[q_cnt].assays[a_cnt].result[r_cnt].orv_sequence = temp->qual[q_cnt].assays[
           loop_1].result[loop_2].orv_sequence, bmatch_found = "T"
          ENDIF
         ENDIF
       ENDFOR
     ENDFOR
     IF (bmatch_found="F")
      temp->qual[q_cnt].assays[a_cnt].result[r_cnt].orv_sequence = o_cnt
     ENDIF
    ENDIF
   ENDIF
  DETAIL
   row + 0
  FOOT  d.seq
   stat = alterlist(temp->qual[q_cnt].assays,a_cnt)
  WITH nocounter
 ;end select
 IF (((max_q_cnt=0) OR (max_a_cnt=0)) )
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d1.seq, order_id = temp->qual[d1.seq].order_id, d2.seq,
  task_assay_cd = temp->qual[d1.seq].assays[d2.seq].task_assay_cd, sequence = temp->qual[d1.seq].
  assays[d2.seq].result[d_orv.seq].orv_sequence, sequence2 = temp->qual[d1.seq].assays[d2.seq].
  sequence,
  d3.seq, r.seq, r.bb_result_id,
  r.result_id, pr.seq, pnl.seq,
  table_ind = decode(boc.seq,"boc",pe.seq,"pe ","xxx"), product_id = decode(p_boc.seq,p_boc
   .product_id,p_pe.seq,p_pe.product_id,0.0), product_nbr = decode(p_boc.seq,p_boc.product_nbr,p_pe
   .seq,p_pe.product_nbr," "),
  product_sub_nbr = decode(p_boc.seq,p_boc.product_sub_nbr,p_pe.seq,p_pe.product_sub_nbr," "),
  normal_low_null_ind = nullind(pr.normal_low), normal_high_null_ind = nullind(pr.normal_high)
  FROM (dummyt d1  WITH seq = value(max_q_cnt)),
   (dummyt d2  WITH seq = value(max_a_cnt)),
   (dummyt d_orv  WITH seq = value(max_tempr_cnt)),
   (dummyt d3  WITH seq = 1),
   result r,
   perform_result pr,
   result_event re,
   prsnl pnl,
   (dummyt d4  WITH seq = 1),
   bb_order_cell boc,
   (dummyt d_p_boc  WITH seq = 1),
   product p_boc,
   product_event pe,
   product p_pe
  PLAN (d1)
   JOIN (d2
   WHERE (d2.seq <= temp->qual[d1.seq].assays_cnt))
   JOIN (d_orv
   WHERE (d_orv.seq <= temp->qual[d1.seq].assays[d2.seq].result_cnt))
   JOIN (d3
   WHERE d3.seq=1)
   JOIN (r
   WHERE (r.order_id=temp->qual[d1.seq].order_id)
    AND (r.task_assay_cd=temp->qual[d1.seq].assays[d2.seq].task_assay_cd)
    AND (r.bb_result_id=temp->qual[d1.seq].assays[d2.seq].result[d_orv.seq].bb_result_id))
   JOIN (pr
   WHERE pr.result_id=r.result_id
    AND pr.result_status_cd=r.result_status_cd)
   JOIN (re
   WHERE re.result_id=r.result_id
    AND re.event_type_cd=r.result_status_cd)
   JOIN (pnl
   WHERE pnl.person_id=re.event_personnel_id)
   JOIN (d4
   WHERE d4.seq=1)
   JOIN (((boc
   WHERE boc.order_id=r.order_id
    AND boc.bb_result_id=r.bb_result_id
    AND boc.bb_result_id != null
    AND boc.bb_result_id > 0)
   JOIN (d_p_boc
   WHERE d_p_boc.seq=1)
   JOIN (p_boc
   WHERE p_boc.product_id=boc.product_id
    AND p_boc.product_id != null
    AND p_boc.product_id > 0)
   ) ORJOIN ((pe
   WHERE pe.order_id=r.order_id
    AND pe.bb_result_id=r.bb_result_id
    AND pe.event_type_cd=in_progress_cd
    AND pe.bb_result_id != null
    AND pe.bb_result_id > 0
    AND pe.product_id != null
    AND pe.product_id > 0)
   JOIN (p_pe
   WHERE p_pe.product_id=pe.product_id)
   ))
  ORDER BY order_id, sequence, sequence2,
   task_assay_cd, r.result_id, re.event_sequence
  HEAD REPORT
   q_cnt = 0, a_cnt = 0, r_cnt = 0
  HEAD order_id
   q_cnt += 1
   IF (mod(q_cnt,10)=1)
    stat = alterlist(reply->qual,(q_cnt+ 9))
   ENDIF
   IF (q_cnt > max_reply_q_cnt)
    max_reply_q_cnt = q_cnt
   ENDIF
   reply->qual[q_cnt].order_id = temp->qual[d1.seq].order_id, reply->qual[q_cnt].catalog_cd = temp->
   qual[d1.seq].catalog_cd, reply->qual[q_cnt].order_mnemonic = temp->qual[d1.seq].order_mnemonic,
   reply->qual[q_cnt].assays_cnt = temp->qual[d1.seq].assays_cnt, a_cnt = 0
  HEAD sequence
   row + 0
  HEAD sequence2
   row + 0
  HEAD task_assay_cd
   a_cnt += 1
   IF (mod(a_cnt,10)=1)
    stat = alterlist(reply->qual[q_cnt].assays,(a_cnt+ 9))
   ENDIF
   IF (a_cnt > max_reply_a_cnt)
    max_reply_a_cnt = a_cnt
   ENDIF
   reply->qual[q_cnt].assays[a_cnt].task_assay_cd = temp->qual[d1.seq].assays[d2.seq].task_assay_cd,
   reply->qual[q_cnt].assays[a_cnt].task_assay_disp = temp->qual[d1.seq].assays[d2.seq].
   task_assay_disp, reply->qual[q_cnt].assays[a_cnt].sequence = temp->qual[d1.seq].assays[d2.seq].
   sequence,
   reply->qual[q_cnt].assays[a_cnt].bb_result_processing_cd = temp->qual[d1.seq].assays[d2.seq].
   bb_result_processing_cd, reply->qual[q_cnt].assays[a_cnt].pending_ind = temp->qual[d1.seq].assays[
   d2.seq].pending_ind, r_cnt = 0
  HEAD r.result_id
   r_cnt += 1
   IF (r_cnt > max_r_cnt)
    max_r_cnt = r_cnt
   ENDIF
   stat = alterlist(reply->qual[q_cnt].assays[a_cnt].result,r_cnt), reply->qual[q_cnt].assays[a_cnt].
   result_cnt = r_cnt, reply->qual[q_cnt].assays[a_cnt].result[r_cnt].result_id = r.result_id,
   reply->qual[q_cnt].assays[a_cnt].result[r_cnt].bb_result_id = r.bb_result_id
   IF (table_ind="boc")
    reply->qual[q_cnt].assays[a_cnt].result[r_cnt].bb_control_cell_cd = boc.cell_cd, reply->qual[
    q_cnt].assays[a_cnt].result[r_cnt].bb_control_cell_disp = uar_get_code_display(boc.cell_cd)
   ELSE
    reply->qual[q_cnt].assays[a_cnt].result[r_cnt].bb_control_cell_cd = r.bb_control_cell_cd, reply->
    qual[q_cnt].assays[a_cnt].result[r_cnt].bb_control_cell_disp = uar_get_code_display(r
     .bb_control_cell_cd)
   ENDIF
   reply->qual[q_cnt].assays[a_cnt].result[r_cnt].product_id = product_id, reply->qual[q_cnt].assays[
   a_cnt].result[r_cnt].product_nbr = product_nbr, reply->qual[q_cnt].assays[a_cnt].result[r_cnt].
   result_status_cd = r.result_status_cd,
   reply->qual[q_cnt].assays[a_cnt].result[r_cnt].service_resource_cd = pr.service_resource_cd, reply
   ->qual[q_cnt].assays[a_cnt].result[r_cnt].long_text_id = pr.long_text_id, reply->qual[q_cnt].
   assays[a_cnt].result[r_cnt].result_type_cd = pr.result_type_cd,
   reply->qual[q_cnt].assays[a_cnt].result[r_cnt].result_value_dt_tm = cnvtdatetime(pr
    .result_value_dt_tm), reply->qual[q_cnt].assays[a_cnt].result[r_cnt].result_value_numeric = pr
   .result_value_numeric, reply->qual[q_cnt].assays[a_cnt].result[r_cnt].numeric_raw_value = pr
   .numeric_raw_value,
   reply->qual[q_cnt].assays[a_cnt].result[r_cnt].less_great_flag = pr.less_great_flag, reply->qual[
   q_cnt].assays[a_cnt].result[r_cnt].result_value_alpha = pr.result_value_alpha, reply->qual[q_cnt].
   assays[a_cnt].result[r_cnt].ascii_text = pr.ascii_text,
   reply->qual[q_cnt].assays[a_cnt].result[r_cnt].result_code_set_cd = pr.result_code_set_cd, reply->
   qual[q_cnt].assays[a_cnt].result[r_cnt].normal_cd = pr.normal_cd, reply->qual[q_cnt].assays[a_cnt]
   .result[r_cnt].critical_cd = pr.critical_cd,
   reply->qual[q_cnt].assays[a_cnt].result[r_cnt].review_cd = pr.review_cd, reply->qual[q_cnt].
   assays[a_cnt].result[r_cnt].delta_cd = pr.delta_cd, reply->qual[q_cnt].assays[a_cnt].result[r_cnt]
   .notify_cd = pr.notify_cd
   IF (normal_low_null_ind=0
    AND normal_high_null_ind=1)
    reply->qual[q_cnt].assays[a_cnt].result[r_cnt].normal_range_flag = 1
   ELSEIF (normal_low_null_ind=1
    AND normal_high_null_ind=0)
    reply->qual[q_cnt].assays[a_cnt].result[r_cnt].normal_range_flag = 2
   ELSEIF (normal_low_null_ind=0
    AND normal_high_null_ind=0)
    reply->qual[q_cnt].assays[a_cnt].result[r_cnt].normal_range_flag = 3
   ELSE
    reply->qual[q_cnt].assays[a_cnt].result[r_cnt].normal_range_flag = 0
   ENDIF
   reply->qual[q_cnt].assays[a_cnt].result[r_cnt].normal_low = pr.normal_low, reply->qual[q_cnt].
   assays[a_cnt].result[r_cnt].normal_high = pr.normal_high, reply->qual[q_cnt].assays[a_cnt].result[
   r_cnt].normal_alpha = pr.normal_alpha
  DETAIL
   reply->qual[q_cnt].assays[a_cnt].result[r_cnt].perform_dt_tm = cnvtdatetime(re.event_dt_tm), reply
   ->qual[q_cnt].assays[a_cnt].result[r_cnt].perform_personnel_id = re.event_personnel_id
   IF ((reply->qual[q_cnt].assays[a_cnt].result[r_cnt].perform_personnel_id > 0.0))
    reply->qual[q_cnt].assays[a_cnt].result[r_cnt].name_full_formatted = pnl.name_full_formatted
   ENDIF
  FOOT  task_assay_cd
   stat = alterlist(reply->qual[q_cnt].assays[a_cnt].result,r_cnt)
  FOOT  order_id
   stat = alterlist(reply->qual[q_cnt].assays,a_cnt), reply->qual[q_cnt].assays_cnt = a_cnt
  FOOT REPORT
   stat = alterlist(reply->qual,q_cnt)
  WITH nocounter, outerjoin = d3, outerjoin = d4,
   outerjoin = d_p_boc, orahintcbo("index(r XIE2RESULT)")
 ;end select
 SELECT INTO "nl:"
  d1.seq, d2.seq, d3.seq,
  lt1.seq, d4.seq, dm_exists = evaluate(nullind(dm.seq),1,"N","Y"),
  dm.seq, d5.seq, rg_exists = evaluate(nullind(rg.seq),1,"N","Y"),
  rg.seq, d6.seq, rc1_exists = decode(rc1.seq,"Y","N"),
  rc1.seq
  FROM (dummyt d1  WITH seq = value(max_reply_q_cnt)),
   (dummyt d2  WITH seq = value(max_reply_a_cnt)),
   (dummyt d3  WITH seq = value(max_r_cnt)),
   long_text lt1,
   dummyt d4,
   data_map dm,
   dummyt d5,
   resource_group rg,
   dummyt d6,
   result_comment rc1
  PLAN (d1)
   JOIN (d2
   WHERE (d2.seq <= reply->qual[d1.seq].assays_cnt))
   JOIN (d3
   WHERE (d3.seq <= reply->qual[d1.seq].assays[d2.seq].result_cnt))
   JOIN (lt1
   WHERE (lt1.long_text_id=reply->qual[d1.seq].assays[d2.seq].result[d3.seq].long_text_id))
   JOIN (d4
   WHERE d4.seq=1)
   JOIN (dm
   WHERE (dm.task_assay_cd=reply->qual[d1.seq].assays[d2.seq].task_assay_cd)
    AND dm.data_map_type_flag=data_map_type_flag
    AND dm.active_ind=1
    AND dm.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND dm.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (d5
   WHERE d5.seq=1)
   JOIN (rg
   WHERE rg.parent_service_resource_cd=dm.service_resource_cd
    AND (rg.child_service_resource_cd=reply->qual[d1.seq].assays[d2.seq].result[d3.seq].
   service_resource_cd)
    AND rg.resource_group_type_cd=serv_res_subsection_cd
    AND rg.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND rg.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND rg.root_service_resource_cd=0.0)
   JOIN (d6
   WHERE d6.seq=1)
   JOIN (rc1
   WHERE (rc1.result_id=reply->qual[d1.seq].assays[d2.seq].result[d3.seq].result_id)
    AND rc1.comment_type_cd IN (result_comment_cd, result_note_cd))
  HEAD REPORT
   data_map_level = 0
  HEAD d1.seq
   data_map_level = 0
  HEAD d2.seq
   data_map_level = 0
  HEAD d3.seq
   data_map_level = 0
  DETAIL
   cnt = d1.seq, a_cnt = d2.seq, r_cnt = d3.seq
   IF (lt1.long_text_id > 0.0)
    reply->qual[cnt].assays[a_cnt].result[r_cnt].rtf_text = lt1.long_text
   ENDIF
   IF (dm_exists="Y")
    IF (data_map_level <= 2
     AND dm.service_resource_cd > 0.0
     AND (dm.service_resource_cd=reply->qual[cnt].assays[a_cnt].result[r_cnt].service_resource_cd))
     data_map_level = 3, reply->qual[cnt].assays[a_cnt].result[r_cnt].data_map_ind = 1, reply->qual[
     cnt].assays[a_cnt].result[r_cnt].max_digits = dm.max_digits,
     reply->qual[cnt].assays[a_cnt].result[r_cnt].min_digits = dm.min_digits, reply->qual[cnt].
     assays[a_cnt].result[r_cnt].min_decimal_places = dm.min_decimal_places
    ENDIF
    IF (data_map_level <= 1
     AND dm.service_resource_cd > 0.0
     AND rg_exists="Y"
     AND rg.parent_service_resource_cd=dm.service_resource_cd
     AND (rg.child_service_resource_cd=reply->qual[cnt].assays[a_cnt].result[r_cnt].
    service_resource_cd))
     data_map_level = 2, reply->qual[cnt].assays[a_cnt].result[r_cnt].data_map_ind = 1, reply->qual[
     cnt].assays[a_cnt].result[r_cnt].max_digits = dm.max_digits,
     reply->qual[cnt].assays[a_cnt].result[r_cnt].min_digits = dm.min_digits, reply->qual[cnt].
     assays[a_cnt].result[r_cnt].min_decimal_places = dm.min_decimal_places
    ENDIF
    IF (data_map_level=0
     AND dm.service_resource_cd=0.0)
     data_map_level = 1, reply->qual[cnt].assays[a_cnt].result[r_cnt].data_map_ind = 1, reply->qual[
     cnt].assays[a_cnt].result[r_cnt].max_digits = dm.max_digits,
     reply->qual[cnt].assays[a_cnt].result[r_cnt].min_digits = dm.min_digits, reply->qual[cnt].
     assays[a_cnt].result[r_cnt].min_decimal_places = dm.min_decimal_places
    ENDIF
   ENDIF
   IF (rc1_exists="Y"
    AND rc1.result_id > 0)
    reply->qual[cnt].assays[a_cnt].result[r_cnt].result_comment_ind = 1
   ELSE
    reply->qual[cnt].assays[a_cnt].result[r_cnt].result_comment_ind = 0
   ENDIF
  WITH nocounter, outerjoin = d4, dontcare = dm,
   outerjoin = d5, outerjoin = d6, dontcare = rg,
   dontcare = rc1, maxqual(rc1,1)
 ;end select
 IF (max_q_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO

CREATE PROGRAM bbt_get_xm_batch_release_info:dba
 RECORD reply(
   1 qual[*]
     2 product_id = f8
     2 supplier_prefix = c5
     2 product_nbr = c20
     2 product_sub_nbr = c5
     2 product_cd = f8
     2 product_disp = c40
     2 cur_unit_meas_cd = f8
     2 cur_unit_meas_disp = c40
     2 cur_expire_dt_tm = dq8
     2 product_updt_cnt = i4
     2 comments_ind = i2
     2 product_type = c2
     2 cur_abo_cd = f8
     2 cur_abo_disp = c40
     2 cur_rh_cd = f8
     2 cur_rh_disp = c40
     2 deriv_updt_cnt = i4
     2 nbr_of_states = i4
     2 qual2[*]
       3 product_event_id = f8
       3 product_id = f8
       3 person_id = f8
       3 encntr_id = f8
       3 order_id = f8
       3 bb_result_id = f8
       3 event_type_cd = f8
       3 event_type_disp = c40
       3 event_type_mean = c60
       3 event_dt_tm = dq8
       3 event_prsnl_id = f8
       3 event_updt_cnt = i4
       3 xm_updt_cnt = i4
       3 xm_deriv_qty = i4
       3 xm_reason_cd = f8
       3 xm_reason_disp = c40
       3 xm_crossmatch_exp_dt_tm = dq8
       3 patient_name = c100
       3 person_alias = c100
       3 pat_abo_cd = f8
       3 pat_abo_disp = c15
       3 pat_rh_cd = f8
       3 pat_rh_disp = c15
       3 accession_number = c20
       3 xm_result = c20
     2 status = c2
     2 err_message = c20
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE num = i2 WITH protect, noconstant(0)
 SET event_date = cnvtdatetime(curdate,curtime3)
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET count2 = 0
 SET xm_event_id = 0.0
 SET mrn_code = 0.0
 SET tablefrom = "   "
 SET crossmatch_event_type_cd = 0.0
 SET verified_status_cd = 0.0
 SET corrected_status_cd = 0.0
 SET xm_interp_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET stscnt = 0
 SET uar_failed = 0
 SET cdf_meaning = "HISTRY & UPD"
 SET stat = uar_get_meaning_by_codeset(1636,cdf_meaning,1,xm_interp_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
 SET cdf_meaning = "VERIFIED"
 SET stat = uar_get_meaning_by_codeset(1901,cdf_meaning,1,verified_status_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
 SET cdf_meaning = "CORRECTED"
 SET stat = uar_get_meaning_by_codeset(1901,cdf_meaning,1,corrected_status_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
 SET cdf_meaning = "MRN"
 SET stat = uar_get_meaning_by_codeset(4,cdf_meaning,1,mrn_code)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
 SET cdf_meaning = "3"
 SET stat = uar_get_meaning_by_codeset(1610,cdf_meaning,1,crossmatch_event_type_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
#skip_rest
 IF (uar_failed=1)
  SET reply->status_data.status = "F"
  SET stscnt = (stscnt+ 1)
  SET stat = alterlist(reply->status_data.subeventstatus,stscnt)
  SET reply->status_data.subeventstatus[stscnt].operationname =
  "get code values (uar_get_meaning_by_codeset)"
  SET reply->status_data.subeventstatus[stscnt].operationstatus = "F"
  SET reply->status_data.subeventstatus[stscnt].targetobjectname = cdf_meaning
  SET reply->status_data.subeventstatus[stscnt].targetobjectvalue = "F"
  GO TO exit_script
 ENDIF
 SET event_date = datetimeadd(event_date,(request->look_ahead_hrs/ 24.0))
 SELECT
  IF (size(request->inv_area_qual,5) > 0)
   PLAN (xm
    WHERE xm.active_ind=1
     AND cnvtdatetime(event_date) >= xm.crossmatch_exp_dt_tm
     AND xm.product_id != 0.0
     AND xm.product_id != null)
    JOIN (p
    WHERE xm.product_id=p.product_id
     AND p.product_id != 0.0
     AND p.product_id != null
     AND expand(num,1,size(request->inv_area_qual,5),p.cur_inv_area_cd,request->inv_area_qual[num].
     inv_area_cd))
  ELSE
   PLAN (xm
    WHERE xm.active_ind=1
     AND cnvtdatetime(event_date) >= xm.crossmatch_exp_dt_tm
     AND xm.product_id != 0.0
     AND xm.product_id != null)
    JOIN (p
    WHERE xm.product_id=p.product_id
     AND p.product_id != 0.0
     AND p.product_id != null)
  ENDIF
  DISTINCT INTO "nl:"
  xm.product_id, p.product_id
  FROM crossmatch xm,
   product p
  ORDER BY p.product_id
  HEAD REPORT
   count1 = 0
  HEAD p.product_id
   count1 = (count1+ 1)
   IF (count1 > size(reply->qual,5))
    stat = alterlist(reply->qual,(count1+ 10))
   ENDIF
  DETAIL
   reply->qual[count1].product_id = p.product_id
   IF (p.locked_ind=1)
    reply->qual[count1].status = "PL"
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,count1)
 SET count2 = count1
 SET count1 = cnvtint(size(reply->qual,5))
 FOR (count = 1 TO count1)
  UPDATE  FROM product p
   SET p.locked_ind = 1, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
    updt_applctx
   PLAN (p
    WHERE (p.product_id=reply->qual[count].product_id)
     AND p.product_id != 0.0
     AND p.product_id != null
     AND ((p.locked_ind=0) OR (p.locked_ind=null)) )
   WITH nocounter
  ;end update
  IF (curqual=0)
   IF ((reply->qual[count].status != "PL"))
    SET reply->qual[count].status = "LF"
   ENDIF
   SET reply->qual[count].err_message = "Unable to lock product table"
  ELSE
   SET reply->qual[count].product_updt_cnt = (reply->qual[count].product_updt_cnt+ 1)
   SET reply->qual[count].status = "L"
  ENDIF
 ENDFOR
 COMMIT
 SET count = 0
 SELECT INTO "nl:"
  p.product_id, p.product_nbr, p.product_sub_nbr,
  p.cur_expire_dt_tm, p.product_cd, p.updt_cnt,
  pn.product_id, b.cur_volume, b.cur_abo_cd,
  b.cur_rh_cd, dr.updt_cnt, com_found = decode(pn.seq,"cf","xx"),
  tablefrom = decode(b.seq,"b",dr.seq,"d","x")
  FROM product p,
   blood_product b,
   derivative dr,
   product_note pn,
   (dummyt d_pn  WITH seq = 1),
   (dummyt d1  WITH seq = 1),
   (dummyt d  WITH seq = value(count2))
  PLAN (d)
   JOIN (p
   WHERE (reply->qual[d.seq].product_id=p.product_id)
    AND p.product_id != 0.0
    AND p.product_id != null)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (((b
   WHERE b.product_id=p.product_id)
   ) ORJOIN ((dr
   WHERE dr.product_id=p.product_id)
   )) JOIN (d_pn
   WHERE d_pn.seq=1)
   JOIN (pn
   WHERE pn.product_id=p.product_id
    AND pn.active_ind=1)
  ORDER BY p.product_nbr, p.product_id
  HEAD p.product_id
   count1 = d.seq
  DETAIL
   reply->qual[count1].product_id = p.product_id, reply->qual[count1].product_nbr = p.product_nbr,
   reply->qual[count1].product_sub_nbr = p.product_sub_nbr,
   reply->qual[count1].product_updt_cnt = p.updt_cnt, reply->qual[count1].product_cd = p.product_cd,
   reply->qual[count1].cur_unit_meas_cd = p.cur_unit_meas_cd,
   reply->qual[count1].cur_expire_dt_tm = cnvtdatetime(p.cur_expire_dt_tm)
   IF (com_found="cf")
    reply->qual[count1].comments_ind = 1
   ELSE
    reply->qual[count1].comments_ind = 0
   ENDIF
   IF (b.seq=1)
    reply->qual[count1].product_type = "B", reply->qual[count1].supplier_prefix = b.supplier_prefix,
    reply->qual[count1].product_nbr = build(trim(b.supplier_prefix),trim(p.product_nbr)),
    reply->qual[count1].cur_abo_cd = b.cur_abo_cd, reply->qual[count1].cur_rh_cd = b.cur_rh_cd
   ELSEIF (d.seq=1)
    reply->qual[count1].product_type = "D", reply->qual[count1].deriv_updt_cnt = dr.updt_cnt
   ENDIF
  WITH nocounter, outerjoin = d_pn
 ;end select
 SET count1 = size(reply->qual,5)
 SET count = 0
 SELECT INTO "nl:"
  e.product_event_id, e.product_id, xm.product_event_id,
  xm.crossmatch_exp_dt_tm
  FROM product_event e,
   crossmatch xm,
   person per,
   person_alias pra,
   person_aborh abo,
   accession_order_r aor,
   result r,
   discrete_task_assay dta,
   perform_result pr,
   (dummyt d1  WITH seq = 1),
   (dummyt d  WITH seq = value(count1))
  PLAN (d)
   JOIN (xm
   WHERE (xm.product_id=reply->qual[d.seq].product_id)
    AND xm.active_ind=1
    AND (((reply->qual[d.seq].status != "LF")) OR ((reply->qual[d.seq].status != "PL")))
    AND (reply->qual[d.seq].status != "F"))
   JOIN (e
   WHERE e.product_event_id=xm.product_event_id
    AND e.event_type_cd=crossmatch_event_type_cd
    AND e.active_ind=1)
   JOIN (per
   WHERE per.person_id=e.person_id
    AND per.active_ind=1)
   JOIN (aor
   WHERE aor.order_id=e.order_id
    AND aor.primary_flag=0)
   JOIN (pra
   WHERE pra.person_id=outerjoin(e.person_id)
    AND pra.active_ind=outerjoin(1)
    AND pra.person_alias_type_cd=outerjoin(mrn_code))
   JOIN (abo
   WHERE abo.person_id=outerjoin(e.person_id)
    AND abo.active_ind=outerjoin(1))
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (r
   WHERE r.bb_result_id=e.bb_result_id
    AND e.event_type_cd=crossmatch_event_type_cd)
   JOIN (dta
   WHERE dta.task_assay_cd=r.task_assay_cd
    AND dta.bb_result_processing_cd=xm_interp_cd)
   JOIN (pr
   WHERE pr.result_id=r.result_id
    AND ((pr.result_status_cd=verified_status_cd) OR (pr.result_status_cd=corrected_status_cd)) )
  ORDER BY xm.product_id
  HEAD xm.product_id
   count2 = 0, xm_event_id = 0.0
  DETAIL
   IF (xm_event_id != e.product_event_id)
    count2 = (count2+ 1), stat = alterlist(reply->qual[d.seq].qual2,count2), reply->qual[d.seq].
    qual2[count2].product_event_id = e.product_event_id,
    reply->qual[d.seq].qual2[count2].product_id = e.product_id, reply->qual[d.seq].qual2[count2].
    person_id = e.person_id, reply->qual[d.seq].qual2[count2].encntr_id = e.encntr_id,
    reply->qual[d.seq].qual2[count2].order_id = e.order_id, reply->qual[d.seq].qual2[count2].
    event_type_cd = e.event_type_cd, reply->qual[d.seq].qual2[count2].event_dt_tm = cnvtdatetime(e
     .event_dt_tm),
    reply->qual[d.seq].qual2[count2].event_prsnl_id = e.event_prsnl_id, reply->qual[d.seq].qual2[
    count2].event_updt_cnt = e.updt_cnt, xm_event_id = e.product_event_id,
    reply->qual[d.seq].qual2[count2].xm_deriv_qty = xm.crossmatch_qty, reply->qual[d.seq].qual2[
    count2].xm_updt_cnt = xm.updt_cnt, reply->qual[d.seq].qual2[count2].xm_reason_cd = xm
    .xm_reason_cd,
    reply->qual[d.seq].qual2[count2].xm_crossmatch_exp_dt_tm = cnvtdatetime(xm.crossmatch_exp_dt_tm),
    reply->qual[d.seq].qual2[count2].patient_name = per.name_full_formatted, reply->qual[d.seq].
    qual2[count2].person_alias = pra.alias,
    reply->qual[d.seq].qual2[count2].pat_abo_cd = abo.abo_cd, reply->qual[d.seq].qual2[count2].
    pat_rh_cd = abo.rh_cd, reply->qual[d.seq].qual2[count2].accession_number = cnvtacc(aor.accession),
    reply->qual[d.seq].qual2[count2].xm_result = pr.result_value_alpha
   ENDIF
  FOOT  xm.product_id
   reply->qual[d.seq].nbr_of_states = count2
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  e.product_event_id
  FROM product_event e,
   (dummyt d  WITH seq = value(count1))
  PLAN (d)
   JOIN (e
   WHERE (reply->qual[d.seq].product_id=e.product_id)
    AND e.active_ind=1
    AND ((e.event_status_flag < 1) OR (e.event_status_flag=null))
    AND (((reply->qual[d.seq].status != "LF")) OR ((reply->qual[d.seq].status != "PL")))
    AND (reply->qual[d.seq].status != "F")
    AND e.event_type_cd > 0.0
    AND e.event_type_cd != crossmatch_event_type_cd)
  ORDER BY e.product_id
  HEAD e.product_id
   count2 = size(reply->qual[d.seq].qual2,5)
  DETAIL
   count2 = (count2+ 1), stat = alterlist(reply->qual[d.seq].qual2,count2), reply->qual[d.seq].qual2[
   count2].product_event_id = e.product_event_id,
   reply->qual[d.seq].qual2[count2].product_id = e.product_id, reply->qual[d.seq].qual2[count2].
   person_id = e.person_id, reply->qual[d.seq].qual2[count2].encntr_id = e.encntr_id,
   reply->qual[d.seq].qual2[count2].order_id = e.order_id, reply->qual[d.seq].qual2[count2].
   event_type_cd = e.event_type_cd, reply->qual[d.seq].qual2[count2].event_dt_tm = cnvtdatetime(e
    .event_dt_tm),
   reply->qual[d.seq].qual2[count2].event_prsnl_id = e.event_prsnl_id, reply->qual[d.seq].qual2[
   count2].event_updt_cnt = e.updt_cnt
  FOOT  e.product_id
   reply->qual[d.seq].nbr_of_states = count2
  WITH nocounter
 ;end select
 SET count1 = size(reply->qual,5)
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO

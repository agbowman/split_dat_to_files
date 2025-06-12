CREATE PROGRAM bbd_get_lookback_donor:dba
 RECORD reply(
   1 qual[*]
     2 drawn_dt_tm = dq8
     2 product_nbr = vc
     2 product_sub_nbr = vc
     2 product_cd = f8
     2 product_cd_disp = vc
     2 cur_abo_cd = f8
     2 cur_abo_cd_disp = vc
     2 cur_rh_cd = f8
     2 cur_rh_cd_disp = vc
     2 expire_dt_tm = dq8
     2 product_event[*]
       3 event_type_cd = f8
       3 event_type_cd_disp = vc
       3 name_full_formatted = vc
       3 reason_cd_disp = vc
       3 mrn = vc
       3 transfuse_dt_tm = dq8
       3 reason_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD prod(
   1 prod_list[*]
     2 prod_id = f8
 )
 SET stat = alterlist(prod->prod_list,10)
 SET prod_idx = 0
 SET reply->status_data.status = "F"
 SET count = 0
 SET count1 = 0
 SET outcome_success = 0.0
 SET mrn_code = 0.0
 SET dispose_code = 0.0
 SET transfuse_code = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET code_cnt = 1
 SET code_set = 14221
 SET cdf_meaning = "SUCCESS"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),code_cnt,outcome_success)
 SET code_set = 4
 SET cdf_meaning = "MRN"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),code_cnt,mrn_code)
 SET code_set = 1610
 SET cdf_meaning = "5"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),code_cnt,dispose_code)
 SET cdf_meaning = "7"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),code_cnt,transfuse_code)
 DECLARE success_cdf = c12 WITH constant("SUCCESS")
 SET product_id_hold = 0.0
 SET hold_idx = 0
 SET prod_found = "F"
 SELECT INTO "nl:"
  pr1.product_id, pr2.product_id, pr3.product_id,
  suc_cdf = uar_get_code_meaning(dr.outcome_cd)
  FROM bbd_donation_results dr,
   bbd_don_product_r dp,
   product pr1,
   (dummyt d1  WITH seq = 1),
   product pr2,
   (dummyt d2  WITH seq = 1),
   product pr3
  PLAN (dr
   WHERE (dr.person_id=request->person_id)
    AND dr.active_ind=1)
   JOIN (dp
   WHERE dr.donation_result_id=dp.donation_results_id
    AND dp.product_id > 0)
   JOIN (pr1
   WHERE dp.product_id=pr1.product_id
    AND pr1.active_ind=1)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (pr2
   WHERE pr1.pooled_product_id > 0
    AND pr1.pooled_product_id=pr2.product_id
    AND pr2.active_ind=1)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (pr3
   WHERE pr2.pooled_product_id > 0
    AND pr2.pooled_product_id=pr3.product_id
    AND pr3.active_ind=1)
  DETAIL
   IF (suc_cdf=success_cdf)
    prod_found = "F", hold_idx = 1
    WHILE (hold_idx <= prod_idx
     AND prod_found="F")
     IF (pr1.product_id > 0)
      IF ((prod->prod_list[hold_idx].prod_id=pr1.product_id))
       prod_found = "T"
      ENDIF
     ELSE
      prod_found = "T"
     ENDIF
     ,hold_idx = (hold_idx+ 1)
    ENDWHILE
    IF (prod_found="F")
     prod_idx = (prod_idx+ 1)
     IF (size(prod->prod_list,5) <= prod_idx)
      stat = alterlist(prod->prod_list,(prod_idx+ 9))
     ENDIF
     prod->prod_list[prod_idx].prod_id = pr1.product_id
    ENDIF
    prod_found = "F", hold_idx = 1
    WHILE (hold_idx <= prod_idx
     AND prod_found="F")
     IF (pr2.product_id > 0)
      IF ((prod->prod_list[hold_idx].prod_id=pr2.product_id))
       prod_found = "T"
      ENDIF
     ELSE
      prod_found = "T"
     ENDIF
     ,hold_idx = (hold_idx+ 1)
    ENDWHILE
    IF (prod_found="F")
     prod_idx = (prod_idx+ 1)
     IF (size(prod->prod_list,5) <= prod_idx)
      stat = alterlist(prod->prod_list,(prod_idx+ 9))
     ENDIF
     prod->prod_list[prod_idx].prod_id = pr2.product_id
    ENDIF
    prod_found = "F", hold_idx = 1
    WHILE (hold_idx <= prod_idx
     AND prod_found="F")
     IF (pr3.product_id > 0)
      IF ((prod->prod_list[hold_idx].prod_id=pr3.product_id))
       prod_found = "T"
      ENDIF
     ELSE
      prod_found = "T"
     ENDIF
     ,hold_idx = (hold_idx+ 1)
    ENDWHILE
    IF (prod_found="F")
     prod_idx = (prod_idx+ 1)
     IF (size(prod->prod_list,5) <= prod_idx)
      stat = alterlist(prod->prod_list,(prod_idx+ 9))
     ENDIF
     prod->prod_list[prod_idx].prod_id = pr3.product_id
    ENDIF
    col 1, pr1.product_id, col 21,
    pr2.product_id, col 41, pr3.product_id,
    row + 2, row + 1, hold_idx = 1
    WHILE (hold_idx <= prod_idx)
      col 1, prod->prod_list[hold_idx].prod_id, hold_idx = (hold_idx+ 1),
      row + 1
    ENDWHILE
   ENDIF
  WITH counter, outerjoin(d1), outerjoin(d2)
 ;end select
 SELECT INTO "nl:"
  pr1.product_id, pr2.product_id, pr3.product_id,
  suc_cdf = uar_get_code_meaning(dr.outcome_cd)
  FROM bbd_donation_results dr,
   bbd_don_product_r dp,
   product pr1,
   (dummyt d1  WITH seq = 1),
   product pr2,
   (dummyt d2  WITH seq = 1),
   product pr3
  PLAN (dr
   WHERE (dr.person_id=request->person_id)
    AND dr.active_ind=1)
   JOIN (dp
   WHERE dr.donation_result_id=dp.donation_results_id
    AND dp.product_id > 0)
   JOIN (pr1
   WHERE dp.product_id=pr1.product_id
    AND pr1.active_ind=1)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (pr2
   WHERE pr1.modified_product_ind=1
    AND pr1.product_id=pr2.modified_product_id
    AND pr2.active_ind=1)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (pr3
   WHERE pr2.modified_product_ind=1
    AND pr2.product_id=pr3.modified_product_id
    AND pr3.active_ind=1)
  DETAIL
   IF (suc_cdf=success_cdf)
    prod_found = "F", hold_idx = 1
    WHILE (hold_idx <= prod_idx
     AND prod_found="F")
     IF (pr1.product_id > 0)
      IF ((prod->prod_list[hold_idx].prod_id=pr1.product_id))
       prod_found = "T"
      ENDIF
     ELSE
      prod_found = "T"
     ENDIF
     ,hold_idx = (hold_idx+ 1)
    ENDWHILE
    IF (prod_found="F")
     prod_idx = (prod_idx+ 1)
     IF (size(prod->prod_list,5) <= prod_idx)
      stat = alterlist(prod->prod_list,(prod_idx+ 9))
     ENDIF
     prod->prod_list[prod_idx].prod_id = pr1.product_id
    ENDIF
    prod_found = "F", hold_idx = 1
    WHILE (hold_idx <= prod_idx
     AND prod_found="F")
     IF (pr2.product_id > 0)
      IF ((prod->prod_list[hold_idx].prod_id=pr2.product_id))
       prod_found = "T"
      ENDIF
     ELSE
      prod_found = "T"
     ENDIF
     ,hold_idx = (hold_idx+ 1)
    ENDWHILE
    IF (prod_found="F")
     prod_idx = (prod_idx+ 1)
     IF (size(prod->prod_list,5) <= prod_idx)
      stat = alterlist(prod->prod_list,(prod_idx+ 9))
     ENDIF
     prod->prod_list[prod_idx].prod_id = pr2.product_id
    ENDIF
    prod_found = "F", hold_idx = 1
    WHILE (hold_idx <= prod_idx
     AND prod_found="F")
     IF (pr3.product_id > 0)
      IF ((prod->prod_list[hold_idx].prod_id=pr3.product_id))
       prod_found = "T"
      ENDIF
     ELSE
      prod_found = "T"
     ENDIF
     ,hold_idx = (hold_idx+ 1)
    ENDWHILE
    IF (prod_found="F")
     prod_idx = (prod_idx+ 1)
     IF (size(prod->prod_list,5) <= prod_idx)
      stat = alterlist(prod->prod_list,(prod_idx+ 9))
     ENDIF
     prod->prod_list[prod_idx].prod_id = pr3.product_id
    ENDIF
   ENDIF
  WITH counter, outerjoin(d1), outerjoin(d2)
 ;end select
 IF (curqual > 0)
  SET stat = alterlist(prod->prod_list,prod_idx)
  SELECT INTO "nl:"
   pr.product_id, pr.product_nbr, pr.product_sub_nbr,
   pr.cur_expire_dt_tm, pe.event_dt_tm, dp.reason_cd,
   pa.alias, pa.alias_pool_cd, p.name_full_formatted,
   alias = cnvtalias(pa.alias,pa.alias_pool_cd), pe.product_event_id, pe.event_type_cd,
   bp.cur_abo_cd, bp.cur_rh_cd
   FROM (dummyt d1  WITH seq = value(prod_idx)),
    product pr,
    blood_product bp,
    (dummyt d3  WITH seq = 1),
    product_event pe,
    (dummyt d5  WITH seq = 1),
    disposition dp,
    (dummyt d4  WITH seq = 1),
    person_alias pa,
    (dummyt d6  WITH seq = 1),
    person p
   PLAN (d1)
    JOIN (pr
    WHERE (pr.product_id=prod->prod_list[d1.seq].prod_id))
    JOIN (bp
    WHERE pr.product_id=bp.product_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (pe
    WHERE pr.product_id=pe.product_id
     AND ((pe.active_ind=1) OR (pe.event_type_cd=dispose_code)) )
    JOIN (d5
    WHERE d5.seq=1)
    JOIN (dp
    WHERE pe.product_event_id=dp.product_event_id)
    JOIN (d4
    WHERE d4.seq=1)
    JOIN (p
    WHERE pe.person_id=p.person_id)
    JOIN (d6
    WHERE d6.seq=1)
    JOIN (pa
    WHERE p.person_id=pa.person_id
     AND pa.person_alias_type_cd=mrn_code)
   ORDER BY pr.product_id
   HEAD pr.product_id
    count = (count+ 1)
    IF (size(count,5)=1)
     stat = alterlist(reply->qual,(count+ 9))
    ENDIF
    reply->qual[count].drawn_dt_tm = cnvtdatetime(bp.drawn_dt_tm), reply->qual[count].product_nbr =
    pr.product_nbr, reply->qual[count].product_sub_nbr = pr.product_sub_nbr,
    reply->qual[count].product_cd = pr.product_cd, reply->qual[count].cur_abo_cd = bp.cur_abo_cd,
    reply->qual[count].cur_rh_cd = bp.cur_rh_cd,
    reply->qual[count].expire_dt_tm = cnvtdatetime(pr.cur_expire_dt_tm)
   HEAD pe.product_event_id
    count1 = 0, count1 = (count1+ 1)
    IF (size(count1,5)=1)
     stat = alterlist(reply->qual[count].product_event,(count1+ 9))
    ENDIF
    reply->qual[count].product_event[count1].event_type_cd = pe.event_type_cd, reply->qual[count].
    product_event[count1].transfuse_dt_tm = cnvtdatetime(pe.event_dt_tm), reply->qual[count].
    product_event[count1].mrn = alias,
    reply->qual[count].product_event[count1].name_full_formatted = p.name_full_formatted, reply->
    qual[count].product_event[count1].reason_cd = dp.reason_cd
   FOOT  pe.product_event_id
    stat = alterlist(reply->qual[count].product_event,count1)
   FOOT  pr.product_id
    stat = alterlist(reply->qual,count)
   WITH counter, outerjoin(d1), outerjoin(d3),
    outerjoin(d4), outerjoin(d5), outerjoin = d6,
    dontcare = dp, dontcare = pa
  ;end select
 ENDIF
#exitscript
 SET reply->status_data.status = "S"
END GO

CREATE PROGRAM bbd_get_lookback_product:dba
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
     2 event_type_cd = f8
     2 event_type_cd_disp = vc
     2 transfuse_dt_tm = dq8
     2 mrn = vc
     2 name_full_formatted = vc
     2 new_repeat_product = vc
     2 reason_cd = f8
     2 reason_cd_disp = vc
     2 donor_nbr = vc
     2 donor_name_full_formatted = vc
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
 SET outcome_success = 0.0
 SET mrn_code = 0.0
 SET donorid_code = 0.0
 SET dispose_code = 0.0
 SET transfuse_code = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET code_cnt = 1
 SET code_set = 14221
 SET cdf_meaning = "SUCCESS"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,outcome_success)
 SET code_set = 4
 SET cdf_meaning = "MRN"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,mrn_code)
 SET cdf_meaning = "DONORID"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,donorid_code)
 SET code_set = 1610
 SET cdf_meaning = "5"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,dispose_code)
 SET cdf_meaning = "7"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,transfuse_code)
 SET product_id_hold = 0.0
 SET hold_idx = 0
 SET prod_found = "F"
 SELECT INTO "nl:"
  pr1.product_id, pr1.product_nbr, pr2.product_id,
  pr2.product_nbr, pr3.product_id, pr3.product_nbr
  FROM product pr1,
   (dummyt d3  WITH seq = 1),
   bbd_don_product_r dp,
   (dummyt d1  WITH seq = 1),
   product pr2,
   (dummyt d2  WITH seq = 1),
   product pr3
  PLAN (pr1
   WHERE (pr1.product_id=request->product_id))
   JOIN (d3
   WHERE d3.seq=1)
   JOIN (dp
   WHERE pr1.product_id=dp.product_id)
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
    IF (mod(prod_idx,10)=1
     AND prod_idx != 1)
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
    IF (mod(prod_idx,10)=1
     AND prod_idx != 1)
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
    IF (mod(prod_idx,10)=1
     AND prod_idx != 1)
     stat = alterlist(prod->prod_list,(prod_idx+ 9))
    ENDIF
    prod->prod_list[prod_idx].prod_id = pr3.product_id
   ENDIF
   col 1, pr1.product_id, col 21,
   pr1.product_nbr, col 41, pr2.product_id,
   col 61, pr2.product_nbr, col 81,
   pr3.product_id, col 101, pr3.product_nbr,
   row + 1, col 1, "break",
   row + 1, hold_idx = 1
   WHILE (hold_idx <= prod_idx)
     col 1, prod->prod_list[hold_idx].prod_id, hold_idx = (hold_idx+ 1),
     row + 1
   ENDWHILE
  WITH counter, outerjoin(d1), outerjoin(d2),
   outerjoin(d3), dontcare(dp)
 ;end select
 SELECT INTO "nl:"
  pr1.product_id, pr1.product_nbr, pr2.product_id,
  pr2.product_nbr, pr3.product_id, pr3.product_nbr
  FROM product pr1,
   (dummyt d3  WITH seq = 1),
   bbd_don_product_r dp,
   (dummyt d1  WITH seq = 1),
   product pr2,
   (dummyt d2  WITH seq = 1),
   product pr3
  PLAN (pr1
   WHERE (pr1.product_id=request->product_id))
   JOIN (d3
   WHERE d3.seq=1)
   JOIN (dp
   WHERE pr1.product_id=dp.product_id)
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
    IF (mod(prod_idx,10)=1
     AND prod_idx != 1)
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
    IF (mod(prod_idx,10)=1
     AND prod_idx != 1)
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
    IF (mod(prod_idx,10)=1
     AND prod_idx != 1)
     stat = alterlist(prod->prod_list,(prod_idx+ 9))
    ENDIF
    prod->prod_list[prod_idx].prod_id = pr3.product_id
   ENDIF
   col 1, pr1.product_id, col 21,
   pr1.product_nbr, col 41, pr2.product_id,
   col 61, pr1.product_nbr, col 81,
   pr3.product_id, col 101, pr1.product_nbr,
   row + 1, col 1, "break",
   row + 1, hold_idx = 1
   WHILE (hold_idx <= prod_idx)
     col 1, prod->prod_list[hold_idx].prod_id, hold_idx = (hold_idx+ 1),
     row + 1
   ENDWHILE
  WITH counter, outerjoin(d1), outerjoin(d2),
   outerjoin(d3)
 ;end select
 IF (curqual > 0)
  SET stat = alterlist(prod->prod_list,prod_idx)
  SELECT INTO "nl:"
   pr.product_id, pr.product_nbr, pr.product_sub_nbr,
   pr.cur_expire_dt_tm, pe.event_dt_tm, dp.reason_cd,
   pa.alias, p.name_full_formatted, pe.product_event_id,
   pe.event_type_cd, bp.cur_abo_cd, bp.cur_rh_cd,
   pa2.alias, p2.name_full_formatted
   FROM (dummyt d1  WITH seq = value(prod_idx)),
    product pr,
    (dummyt d2  WITH seq = 1),
    blood_product bp,
    (dummyt d3  WITH seq = 1),
    product_event pe,
    (dummyt d5  WITH seq = 1),
    disposition dp,
    (dummyt d4  WITH seq = 1),
    person_alias pa,
    (dummyt d7  WITH seq = 1),
    person p,
    (dummyt d6  WITH seq = 1),
    bbd_don_product_r dpr,
    person_alias pa2,
    person p2
   PLAN (d1)
    JOIN (pr
    WHERE (prod->prod_list[d1.seq].prod_id > 0)
     AND (pr.product_id=prod->prod_list[d1.seq].prod_id))
    JOIN (d2
    WHERE d2.seq=1)
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
    JOIN (d7
    WHERE d7.seq=1)
    JOIN (pa
    WHERE pe.person_id > 0
     AND pe.person_id=pa.person_id
     AND pa.person_alias_type_cd=mrn_code)
    JOIN (d6
    WHERE d6.seq=1)
    JOIN (dpr
    WHERE pr.product_id=dpr.product_id)
    JOIN (pa2
    WHERE pa2.person_alias_type_cd=donorid_code
     AND dpr.person_id=pa2.person_id)
    JOIN (p2
    WHERE dpr.person_id=p2.person_id)
   ORDER BY pr.product_id
   HEAD REPORT
    first_time = "Y"
   DETAIL
    count = (count+ 1), stat = alterlist(reply->qual,count)
    IF (product_id_hold=pr.product_id
     AND  NOT (first_time="Y"))
     reply->qual[count].new_repeat_product = "REPEAT"
    ELSE
     product_id_hold = pr.product_id, first_time = "N", reply->qual[count].new_repeat_product = "NEW"
    ENDIF
    reply->qual[count].drawn_dt_tm = cnvtdatetime(bp.drawn_dt_tm), reply->qual[count].product_nbr =
    pr.product_nbr, reply->qual[count].product_sub_nbr = pr.product_sub_nbr,
    reply->qual[count].product_cd = pr.product_cd, reply->qual[count].cur_abo_cd = bp.cur_abo_cd,
    reply->qual[count].cur_rh_cd = bp.cur_rh_cd,
    reply->qual[count].expire_dt_tm = cnvtdatetime(pr.cur_expire_dt_tm), reply->qual[count].
    event_type_cd = pe.event_type_cd
    IF (pe.event_type_cd=transfuse_code)
     reply->qual[count].transfuse_dt_tm = cnvtdatetime(pe.event_dt_tm)
    ENDIF
    reply->qual[count].mrn = pa.alias, reply->qual[count].name_full_formatted = p.name_full_formatted,
    reply->qual[count].reason_cd = dp.reason_cd,
    reply->qual[count].donor_nbr = pa2.alias, reply->qual[count].donor_name_full_formatted = p2
    .name_full_formatted, col 1,
    pr.product_id, col 21, pr.product_nbr,
    col 31, pr.product_sub_nbr, col 41,
    reply->qual[count].new_repeat_product, col 51, pr.cur_expire_dt_tm"yymmmdd;;d",
    col 71, pe.event_type_cd, col 91,
    transfuse_code, col 111, pe.event_dt_tm"yymmmdd;;d",
    row + 1, col 1, p.name_full_formatted"####################",
    col 21, pa.alias"###############", col 41,
    p2.name_full_formatted"####################", col 61, pa2.alias"###############",
    row + 1, col 1, prod_idx,
    row + 1
   WITH counter, outerjoin(d1), outerjoin(d2),
    outerjoin(d3), outerjoin(d4), outerjoin(d5),
    outerjoin(d6), outerjoin(d7), dontcare(dp),
    dontcare(bp), dontcare(pe), dontcare(p),
    dontcare(pa), dontcare(dpr), dontcare(p2),
    dontcare(pa2)
  ;end select
 ENDIF
 IF (curqual != 0)
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exitscript
 ENDIF
#exitscript
END GO

CREATE PROGRAM bbt_get_auto_dir_for_disp:dba
 RECORD reply(
   1 products_present = c1
   1 qual[*]
     2 good_product_ind = c1
     2 product_id = f8
     2 product_cd = f8
     2 product_disp = c15
     2 product_nbr = c20
     2 product_sub_nbr = c5
     2 cur_expire_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD products(
   1 productlist[*]
     2 product_id = f8
 )
 RECORD revents(
   1 event_list[*]
     2 event_id = f8
     2 event_type_cd = f8
 )
 RECORD rresult(
   1 qual[*]
     2 event_list[*]
       3 event_type_cd = f8
 )
 DECLARE intransit_event_cd = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET reply->products_present = "F"
 SET count1 = 0
 SET count2 = 0
 SET quarantined_event_cd = 0.0
 SET crossmatched_event_cd = 0.0
 SET issued_event_cd = 0.0
 SET disposed_event_cd = 0.0
 SET transferred_event_cd = 0.0
 SET transfused_event_cd = 0.0
 SET unconfirmed_event_cd = 0.0
 SET autologous_event_cd = 0.0
 SET directed_event_cd = 0.0
 SET available_event_cd = 0.0
 SET destroyed_event_cd = 0.0
 SET shipped_event_cd = 0.0
 SET xm_in_progress_event_cd = 0.0
 SET drawn_event_cd = 0.0
 SET product_cnt = 0
 SET cnt = 0
 SET count1 = 0
 SET count2 = 0
 SET good_product = "F"
 SET bad_product = "F"
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 1610
 SET code_value = 0.0
 SET uar_failed = 0
 SET cdf_meaning = "1"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET assigned_event_cd = code_value
 ENDIF
 SET cdf_meaning = "2"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET quarantined_event_cd = code_value
 ENDIF
 SET cdf_meaning = "3"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET crossmatched_event_cd = code_value
 ENDIF
 SET cdf_meaning = "4"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET issued_event_cd = code_value
 ENDIF
 SET cdf_meaning = "5"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET disposed_event_cd = code_value
 ENDIF
 SET cdf_meaning = "6"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET transferred_event_cd = code_value
 ENDIF
 SET cdf_meaning = "7"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET transfused_event_cd = code_value
 ENDIF
 SET cdf_meaning = "9"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET unconfirmed_event_cd = code_value
 ENDIF
 SET cdf_meaning = "10"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET autologous_event_cd = code_value
 ENDIF
 SET cdf_meaning = "11"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET directed_event_cd = code_value
 ENDIF
 SET cdf_meaning = "12"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET available_event_cd = code_value
 ENDIF
 SET cdf_meaning = "14"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET destroyed_event_cd = code_value
 ENDIF
 SET cdf_meaning = "15"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET shipped_event_cd = code_value
 ENDIF
 SET cdf_meaning = "16"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET xm_in_progress_event_cd = code_value
 ENDIF
 SET cdf_meaning = "20"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET drawn_event_cd = code_value
 ENDIF
 SET cdf_meaning = "25"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ELSE
  SET intransit_event_cd = code_value
 ENDIF
#skip_rest
 IF (uar_failed=1)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "uar_get_meaning_by_codeset failed"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = cdf_meaning
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "could not get code_value"
  GO TO exit_script
 ENDIF
 SET product_cnt = 0
 SET stat = alterlist(products->productlist,10)
 SELECT INTO "nl:"
  pe.product_id
  FROM auto_directed ad
  WHERE (ad.person_id=request->person_id)
   AND ad.active_ind=1
   AND ad.person_id != null
   AND ad.person_id > 0.0
  ORDER BY ad.product_id
  HEAD ad.product_id
   product_cnt += 1
   IF (mod(product_cnt,10)=1
    AND product_cnt != 1)
    stat = alterlist(products->productlist,(product_cnt+ 9))
   ENDIF
   products->productlist[product_cnt].product_id = ad.product_id
  FOOT REPORT
   stat = alterlist(products->productlist,product_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d_p  WITH seq = value(product_cnt)),
   product_event pe,
   product p,
   blood_product bp,
   (dummyt d  WITH seq = 1)
  PLAN (d_p)
   JOIN (pe
   WHERE (pe.product_id=products->productlist[d_p.seq].product_id)
    AND pe.active_ind=1
    AND (pe.person_id=request->person_id))
   JOIN (p
   WHERE p.product_id=pe.product_id
    AND p.product_id > 0
    AND p.product_id != null)
   JOIN (d
   WHERE d.seq=1)
   JOIN (bp
   WHERE p.product_id=bp.product_id)
  ORDER BY pe.product_id, pe.product_event_id
  HEAD REPORT
   count1 = 0
  HEAD pe.product_id
   count1 += 1, stat = alterlist(reply->qual,count1), good_product = "F",
   bad_product = "F", count2 = 0, reply->qual[count1].product_id = pe.product_id,
   reply->qual[count1].product_cd = p.product_cd, reply->qual[count1].product_nbr = p.product_nbr,
   reply->qual[count1].product_sub_nbr = p.product_sub_nbr,
   reply->qual[count1].cur_expire_dt_tm = p.cur_expire_dt_tm
  HEAD pe.product_event_id
   IF ((reply->qual[count1].product_id=pe.product_id))
    IF (((pe.event_type_cd=destroyed_event_cd) OR (((pe.event_type_cd=disposed_event_cd) OR (((pe
    .event_type_cd=transfused_event_cd) OR (((pe.event_type_cd=transferred_event_cd) OR (((pe
    .event_type_cd=issued_event_cd) OR (((pe.event_type_cd=shipped_event_cd) OR (((pe.event_type_cd=
    available_event_cd) OR (pe.event_type_cd=intransit_event_cd)) )) )) )) )) )) )) )
     bad_product = "T"
    ELSEIF (bad_product != "T")
     count2 += 1, stat = alterlist(revents->event_list,count2), revents->event_list[count2].event_id
      = pe.product_event_id,
     revents->event_list[count2].event_type_cd = pe.event_type_cd, good_product = "T"
    ENDIF
   ENDIF
  FOOT  pe.product_id
   IF (good_product="T"
    AND bad_product="F"
    AND count2 > 0)
    reply->qual[count1].good_product_ind = "T", cnt += 1
   ELSE
    reply->qual[count1].good_product_ind = "F"
   ENDIF
  WITH nocounter, outerjoin(d)
 ;end select
 IF (cnt > 0)
  SET reply->products_present = "T"
  SET reply->status_data.status = "S"
 ELSE
  SET reply->products_present = "F"
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO

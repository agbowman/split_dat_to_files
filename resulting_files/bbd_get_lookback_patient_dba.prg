CREATE PROGRAM bbd_get_lookback_patient:dba
 RECORD reply(
   1 qual[*]
     2 product_nbr = vc
     2 product_sub_nbr = vc
     2 product_cd = f8
     2 product_cd_disp = vc
     2 cur_abo_cd = f8
     2 cur_abo_cd_disp = vc
     2 cur_rh_cd = f8
     2 cur_rh_cd_disp = vc
     2 expire_dt_tm = dq8
     2 eventlist[*]
       3 event_type_cd = f8
       3 event_type_cd_disp = vc
     2 drawn_dt_tm = dq8
     2 transfuse_dt_tm = dq8
     2 donor_nbr = vc
     2 donor_name_full_formatted = vc
     2 reason_cd = f8
     2 reason_cd_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET count2 = 0
 SET new_product = "T"
 SET person_alias_type_code = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_cnt = 1
 SET code_set = 4
 SET cdf_meaning = "DONORID"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,person_alias_type_code)
 SELECT INTO "nl:"
  tr.product_id, pr.product_nbr, pr.product_sub_nbr,
  pr.product_cd, pr.cur_expire_dt_tm, bp.cur_abo_cd,
  bp.cur_rh_cd, pe.event_type_cd, pe.event_dt_tm,
  dp.person_id, p.name_full_formatted, pa.alias,
  pa.alias_pool_cd, alias = cnvtalias(pa.alias,pa.alias_pool_cd)
  FROM transfusion tr,
   product pr,
   blood_product bp,
   product_event pe,
   (dummyt d1  WITH seq = 1),
   bbd_don_product_r dp,
   person_alias pa,
   person p
  PLAN (tr
   WHERE (tr.person_id=request->person_id)
    AND tr.active_ind=1)
   JOIN (pr
   WHERE tr.product_id=pr.product_id)
   JOIN (bp
   WHERE pr.product_id=bp.product_id)
   JOIN (pe
   WHERE pr.product_id=pe.product_id
    AND pe.active_ind=1)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (dp
   WHERE tr.product_id=dp.product_id)
   JOIN (p
   WHERE p.person_id=dp.person_id)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=person_alias_type_code)
  ORDER BY tr.product_id
  HEAD tr.product_id
   new_product = "T", count2 = 0
  DETAIL
   IF (new_product="T")
    new_product = "F", count1 = (count1+ 1), stat = alterlist(reply->qual,count1),
    reply->qual[count1].product_nbr = pr.product_nbr, reply->qual[count1].product_sub_nbr = pr
    .product_sub_nbr, reply->qual[count1].product_cd = pr.product_cd,
    reply->qual[count1].expire_dt_tm = pr.cur_expire_dt_tm, reply->qual[count1].cur_abo_cd = bp
    .cur_abo_cd, reply->qual[count1].cur_rh_cd = bp.cur_rh_cd,
    reply->qual[count1].transfuse_dt_tm = pe.event_dt_tm, reply->qual[count1].transfuse_dt_tm = pe
    .event_dt_tm, reply->qual[count1].donor_nbr = alias,
    reply->qual[count1].donor_name_full_formatted = p.name_full_formatted
   ENDIF
   count2 = (count2+ 1), stat = alterlist(reply->qual[count1].eventlist,count2), reply->qual[count1].
   eventlist[count2].event_type_cd = pe.event_type_cd
  WITH counter, outerjoin(d1)
 ;end select
#exitscript
END GO

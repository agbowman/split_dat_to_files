CREATE PROGRAM bbd_get_existing_ad_drawn:dba
 RECORD reply(
   1 drawn_product_event_id = f8
   1 drawn_product_event_updt_cnt = i4
   1 auto_dir_product_event_id = f8
   1 auto_dir_product_event_updt_cnt = i4
   1 auto_directed_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ad_event_type_cd = 0.0
 SET drawn_event_type_cd = 0.0
 SET cv_cnt = 1
 IF ((request->event_type_mean="10"))
  SET stat = uar_get_meaning_by_codeset(1610,"10",cv_cnt,ad_event_type_cd)
 ELSE
  SET stat = uar_get_meaning_by_codeset(1610,"11",cv_cnt,ad_event_type_cd)
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1610,"20",cv_cnt,drawn_event_type_cd)
 SELECT INTO "nl:"
  pe.*
  FROM product_event pe,
   (dummyt d1  WITH seq = 1),
   auto_directed ad
  PLAN (pe
   WHERE (pe.product_id=request->product_id)
    AND ((pe.event_type_cd=ad_event_type_cd) OR (pe.event_type_cd=drawn_event_type_cd)) )
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (ad
   WHERE ad.product_event_id=pe.product_event_id
    AND ad.active_ind=1)
  DETAIL
   IF (pe.event_type_cd=ad_event_type_cd)
    reply->auto_dir_product_event_id = pe.product_event_id, reply->auto_dir_product_event_updt_cnt =
    pe.updt_cnt, reply->auto_directed_updt_cnt = ad.updt_cnt
   ELSE
    reply->drawn_product_event_id = pe.product_event_id, reply->drawn_product_event_updt_cnt = pe
    .updt_cnt
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO

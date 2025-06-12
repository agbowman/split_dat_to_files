CREATE PROGRAM cps_get_consult_info:dba
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->consult_list,5))
 SELECT INTO "nl:"
  o.order_id
  FROM (dummyt d  WITH seq = value(nbr_to_get)),
   orders o,
   encounter e
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=request->consult_list[d.seq].order_id))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
  ORDER BY o.order_id
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->qual,5))
    stat = alterlist(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].order_id = o.order_id, reply->qual[count1].loc_facility_cd = e.loc_facility_cd,
   reply->qual[count1].loc_nurse_unit_cd = e.loc_nurse_unit_cd,
   reply->qual[count1].loc_room_cd = e.loc_room_cd, reply->qual[count1].loc_bed_cd = e.loc_bed_cd,
   reply->qual[count1].order_mnemonic = o.order_mnemonic,
   reply->qual[count1].order_detail_display_line = o.order_detail_display_line
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH check
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

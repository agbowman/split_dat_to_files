CREATE PROGRAM dcp_get_location_cd:dba
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->encntr_list,5))
 DECLARE setreply_location(null) = null
 IF (nbr_to_get > 0)
  SELECT INTO "nl:"
   e.encntr_id
   FROM (dummyt d  WITH seq = value(nbr_to_get)),
    encounter e
   PLAN (d)
    JOIN (e
    WHERE (e.encntr_id=request->encntr_list[d.seq].encntr_id)
     AND e.active_ind=1
     AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
   ORDER BY e.encntr_id
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1
    IF (count1 > size(reply->get_list,5))
     stat = alterlist(reply->get_list,(count1+ 10))
    ENDIF
    reply->get_list[count1].encntr_id = e.encntr_id, reply->get_list[count1].loc_nurse_unit_cd = e
    .loc_nurse_unit_cd, reply->get_list[count1].loc_room_cd = e.loc_room_cd,
    reply->get_list[count1].loc_bed_cd = e.loc_bed_cd,
    CALL setreply_location(null)
   FOOT REPORT
    stat = alterlist(reply->get_list,count1)
   WITH check
  ;end select
 ENDIF
 SUBROUTINE setreply_location(null)
   IF (validate(reply->get_list.organization_id)=1)
    SET reply->get_list[count1].organization_id = e.organization_id
   ENDIF
 END ;Subroutine
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

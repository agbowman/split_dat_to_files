CREATE PROGRAM dcp_get_result_info:dba
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->event_list,5))
 IF (nbr_to_get > 0)
  SELECT INTO "nl:"
   cmr.event_id
   FROM (dummyt d  WITH seq = value(nbr_to_get)),
    ce_med_result cmr
   PLAN (d)
    JOIN (cmr
    WHERE (cmr.event_id=request->event_list[d.seq].event_id))
   ORDER BY cmr.event_id
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1
    IF (count1 > size(reply->get_list,5))
     stat = alterlist(reply->get_list,(count1+ 10))
    ENDIF
    reply->get_list[count1].event_id = cmr.event_id, reply->get_list[count1].response_required_flag
     = cmr.response_required_flag
   FOOT REPORT
    stat = alterlist(reply->get_list,count1)
   WITH check
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

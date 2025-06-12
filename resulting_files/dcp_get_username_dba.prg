CREATE PROGRAM dcp_get_username:dba
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->person_list,5))
 IF (nbr_to_get > 0)
  SELECT INTO "nl:"
   p.person_id
   FROM (dummyt d  WITH seq = value(nbr_to_get)),
    prsnl p
   PLAN (d)
    JOIN (p
    WHERE (p.person_id=request->person_list[d.seq].person_id)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
   ORDER BY p.person_id
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1
    IF (count1 > size(reply->get_list,5))
     stat = alterlist(reply->get_list,(count1+ 10))
    ENDIF
    reply->get_list[count1].person_id = p.person_id, reply->get_list[count1].username = p
    .name_full_formatted
   FOOT REPORT
    stat = alterlist(reply->get_list,count1)
   WITH check
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

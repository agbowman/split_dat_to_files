CREATE PROGRAM dcp_get_msg_text:dba
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->msg_text_list,5))
 IF (nbr_to_get > 0)
  SELECT INTO "nl:"
   lt.long_text_id
   FROM (dummyt d  WITH seq = value(nbr_to_get)),
    long_text lt
   PLAN (d)
    JOIN (lt
    WHERE (request->msg_text_list[d.seq].msg_text_id=lt.long_text_id)
     AND lt.active_ind=1)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1
    IF (count1 > size(reply->get_list,5))
     stat = alterlist(reply->get_list,(count1+ 10))
    ENDIF
    reply->get_list[count1].msg_text_id = lt.long_text_id, reply->get_list[count1].msg_text = lt
    .long_text
   FOOT REPORT
    stat = alterlist(reply->get_list,count1)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

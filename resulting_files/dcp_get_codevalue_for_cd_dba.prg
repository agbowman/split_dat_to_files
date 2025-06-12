CREATE PROGRAM dcp_get_codevalue_for_cd:dba
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->code_list,5))
 IF (nbr_to_get > 0)
  SELECT INTO "nl:"
   c.code_value
   FROM (dummyt d  WITH seq = value(nbr_to_get)),
    code_value c
   PLAN (d)
    JOIN (c
    WHERE (c.code_value=request->code_list[d.seq].code_value)
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
     AND c.end_effective_dt_tm > cnvtdatetime(sysdate))
   ORDER BY c.code_value
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1
    IF (count1 > size(reply->get_list,5))
     stat = alterlist(reply->get_list,(count1+ 10))
    ENDIF
    reply->get_list[count1].code_value = c.code_value, reply->get_list[count1].display = c.display,
    reply->get_list[count1].description = c.description,
    reply->get_list[count1].cdf_meaning = c.cdf_meaning, reply->get_list[count1].display_key = c
    .display_key
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
